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

sub lookup {
    my $self = shift;
    my $key = shift || '';
    $self->hash->{$key};
}

sub find_all {
    my $self = shift;
    my $key = shift || '';
    my @values = map {
        $_->{value};
    } grep { $_ && $_->{name} eq $key } @{$self->array};

    wantarray? @values: \@values;
}

sub remove {
    my $self = shift;
    my %keys = map { $_ => 1 } @_;
    my @values;

    for ( my $i = 0; $i < scalar @{$self->array}; $i++ ) {
        my $pair = $self->array->[$i] || next;
        next unless defined $pair->{name};
        next unless $keys{$pair->{name}};
        my $value = $pair->{value};

        push @values, $value;
        delete $self->array->[$i];
    }
    for my $key ( keys %keys ) {
        delete $self->hash->{$key};
    }

    @values;
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
