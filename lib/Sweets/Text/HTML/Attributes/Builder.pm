package Sweets::Text::HTML::Attributes::Builder;

use strict;
use warnings;

use Any::Moose;

has array => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

sub add {
    my $self = shift;
    my %pairs = @_;

    push @{$self->array}, map {
        { name => $_ || '', value => $pairs{$_} || '' }
    } keys %pairs;

    $self;
}

sub remove {
    my $self = shift;
    my %names = map { $_ => 1 } @_;

    my @array = grep {
        my $n = ( ref $_? $_->{name}: '' ) || '';
        $names{$n}? 0: 1;
    } @{$self->array};
    $self->array(\@array);

    $self;
}

sub clear {
    my $self = shift;
    $self->array([]);
    $self;
}

sub as_string {
    my $self = shift;
    my ( $sort ) = @_;

    my @pairs = @{$self->array};
    @pairs = sort {
        ( ref $a
            ? $a->{name} || ''
            : '' )
        cmp
        ( ref $b
            ? $b->{name} || ''
            : '' )
        } @pairs if $sort;

    join( ' ', map {
        if ( ref $_ ) {
            my $name = $_->{name} || '';
            $name = qq{"$name"} if $name =~ /[\s"']/;
            my $value = $_->{value};
            $value =~ s/"/\\"/g;
            $name? qq{$name="$value"}: qq{"$value"};
        } else {
            qq{"$_"};
        }
    } @pairs );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
