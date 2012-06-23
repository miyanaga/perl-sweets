package Sweets::Aspect::Stashable;

use strict;
use warnings;

use Any::Moose;

has stash_store => ( is => 'ro', isa => 'HashRef', lazy_build => 1, builder => sub { {} });
has object_stash_store => ( is => 'ro', isa => 'HashRef', lazy_build => 1, builder => sub { {} });

sub stash {
    my $self = shift;
    my ( $key, $value ) = @_;

    Carp::confess('stash required a key') unless $key;

    $self->stash_store->{$key} = $value if defined($value);
    $self->stash_store->{$key};
}

sub object_stash {
    my $self = shift;
    my $object = scalar shift;
    my ( $key, $value ) = @_;

    Carp::confess('object_stash required a object') unless $object;
    Carp::confess('object_stash required a key') unless $key;

    $self->object_stash_store->{$object} ||= {};
    $self->object_stash_store->{$object}{$key} = $value if defined($value);
    $self->object_stash_store->{$object}{$key};
}

no Any::Moose;

1;
__END__
