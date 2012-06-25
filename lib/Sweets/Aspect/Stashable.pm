package Sweets::Aspect::Stashable;

use strict;
use warnings;

our $DEFAULT_EXPIRES = 300;

use Any::Moose;

has stash_expires => ( is => 'ro', isa => 'Num', default => $DEFAULT_EXPIRES );
has stash_store => ( is => 'ro', isa => 'HashRef', lazy_build => 1, builder => sub { {} } );
has object_stash_store => ( is => 'ro', isa => 'HashRef', lazy_build => 1, builder => sub { {} } );

sub stash {
    my $self = shift;
    my ( $key, $value ) = @_;

    Carp::confess('stash required a key') unless $key;

    $self->stash_store->{$key} = Sweets::Aspect::Stashable::Entry->new(
        stasher => $self,
        value => ref $value eq 'CODE'? $value->(): $value,
    ) if defined($value);

    my $entry = $self->stash_store->{$key};
    $entry? $entry->value: undef;
}

sub stash_or {
    my $self = shift;
    my ( $key, $default, $notset ) = @_;

    Carp::confess('stash_or required a default') unless defined($default);

    my $value = $self->stash($key);
    return $value if defined($value);

    $self->stash($key, $default) unless $notset;
    $default;
}

sub object_stash {
    my $self = shift;
    my $object = scalar shift;
    my ( $key, $value ) = @_;

    Carp::confess('object_stash required a object') unless $object;
    Carp::confess('object_stash required a key') unless $key;

    my $entry = ($self->object_stash_store->{$object} ||= Sweets::Aspect::Stashable::Entry->new(
        stasher => $self,
        value => {},
    ));
    $entry->value->{$key} = ref $value eq 'CODE'? $value->(): $value
        if defined($value);

    $entry->value->{$key};
}

sub object_stash_or {
    my $self = shift;
    my $object = scalar shift;
    my ( $key, $default, $notset ) = @_;

    Carp::confess('object_stash_or required a default') unless defined($default);

    my $value = $self->object_stash($key, $default);
    return $value if defined($value);

    $self->object_stash($object, $key, $default) unless $notset;
    $default;
}

sub clear_stashes {
    my $self = shift;
    $self->clear_stash_store;
    $self->clear_object_stash_store;
}

sub cleanup_stashes {
    my $self = shift;
    my $now = AnyEvent->time;
    for my $store ( $self->stash_store, $self->object_stash_store ) {
        for my $key ( keys %$store ) {
            my $entry = $store->{$key} || next;
            delete $store->{$key}
                if $entry->expires_on >= $now;
        }
    }
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;


package Sweets::Aspect::Stashable::Entry;

use strict;
use warnings;

use Any::Moose;
use AnyEvent;

has stasher => ( is => 'ro', isa => 'Sweets::Aspect::Stashable', required => 1 );
has value => ( is => 'rw', isa => 'Any' );
has expires_on => ( is => 'rw', isa => 'Num' );

{
    sub touch {
        my $self = shift;
        $self->expires_on( AnyEvent->time + $self->stasher->stash_expires );
    }
}

after value => sub {
    shift->touch;
};

sub BUILD {
    shift->touch;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
