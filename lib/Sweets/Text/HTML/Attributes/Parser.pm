package Sweets::Text::HTML::Attributes::Parser;

use strict;
use warnings;

use Any::Moose;
use Sweets::Text::HTML::Attributes::Builder;

has raw => ( is => 'rw', isa => 'Str', default => '' );
has array => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has hash => ( is => 'rw', isa => 'HashRef', default => sub { {} } );

sub BUILD {
    shift->_parse_raw;
}

sub parse {
    my $pkg = shift;
    my ( $attributes ) = @_;

    my $attr = $pkg->new( raw => $attributes );
    ( $attr->hash, $attr->array );
}

after raw => sub {
    my $self = shift;
    shift->_parse_raw if @_;
};

{
    sub _parse_raw {
        my $self = shift;
        my @array;
        my %hash;
        my $raw = $self->raw;
        while ( $raw =~ /\s*(?:([^\s=]+)\s*=\s*)?(?:([^"'][^\s]+)|(["'])(.*?)(?<!\\)(\3))\s*/isg ) {
            my $name = $1 || '';
            my $quote = $3;
            my $value = $2 || $4;
            $value =~ s/\\$quote/$quote/g if $quote;

            push @array, $name? { name => $name, value => $value }: $value;
            $hash{$name} = $value;
        }

        $self->array(\@array);
        $self->hash(\%hash);
    }
}

sub as_array {
    shift->array;
}

sub as_hash {
    shift->hash;
}

sub build_on {
    my $self = shift;
    Sweets::Text::HTML::Attributes::Builder->new(
        array => $self->array,
    );
}

sub as_string {
    shift->build_on->as_string(@_);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
