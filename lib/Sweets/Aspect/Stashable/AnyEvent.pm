package Sweets::Aspect::Stashable::AnyEvent;

use strict;
use warnings;

use parent 'Sweets::Aspect::Stashable';

use Any::Moose;
use AnyEvent;

has stash_interval => ( is => 'ro', isa => 'Num', lazy_build => 1, builder => sub {
    shift->stash_expires;
} );
has stash_gc => ( is => 'ro', isa => 'Any', default => sub {
    my $self = shift;
    my $timer = AE::timer(
        $self->stash_interval,
        $self->stash_interval,
        sub {
            $self->cleanup_stashes;
        },
    );
    $timer;
} );


no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
