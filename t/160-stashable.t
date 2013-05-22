package Stashable;

use strict;
use warnings;
use lib 'blib';
use parent 'Sweets::Aspect::Stashable::AnyEvent';

package main;

use strict;
use warnings;

use Test::More;
use AnyEvent;

{
    my $stashable = Stashable->new(
        stash_expires => 0.5,
    );

    is $stashable->stash('KEY'), undef;
    is $stashable->stash_or('KEY', 'DEFAULT'), 'DEFAULT';
    $stashable->stash('KEY', 'VALUE');
    is $stashable->stash('KEY'), 'VALUE';

    my $array = [];
    $stashable->stash('ARRAY', $array);
    is $stashable->stash('ARRAY'), $array;
    is $stashable->stash('KEY'), 'VALUE';

    my $scalar = 'SCALAR';
    is $stashable->object_stash($scalar, 'KEY'), undef;
    is $stashable->object_stash_or($scalar, 'KEY', 'DEFAULT'), 'DEFAULT';
    $stashable->object_stash($scalar, 'KEY', $array);
    is $stashable->object_stash($scalar, 'KEY'), $array;

    my $hash = {};
    $stashable->object_stash($hash, 'KEY', 'VALUE');
    is $stashable->object_stash($hash, 'KEY'), 'VALUE';
    is $stashable->object_stash($scalar, 'KEY'), $array;

    my $object = Stashable->new;
    $stashable->object_stash($object, 'KEY', $hash);
    is $stashable->object_stash($object, 'KEY'), $hash;
    is $stashable->object_stash($scalar, 'KEY'), $array;

    $stashable->object_stash($object, 'KEY', $array);
    is $stashable->object_stash($object, 'KEY'), $array;

    $stashable->clear_stashes;
    is $stashable->stash('KEY'), undef;
    is $stashable->stash('ARRAY'), undef;
    is $stashable->object_stash($scalar, 'KEY'), undef;
    is $stashable->object_stash($hash, 'KEY'), undef;
    is $stashable->object_stash($object, 'KEY'), undef;

    is $stashable->stash_or('KEY', 'DEFAULT', 1), 'DEFAULT';
    is $stashable->stash('KEY'), undef;
    is $stashable->stash_or('KEY', 'DEFAULT'), 'DEFAULT';
    is $stashable->stash('KEY'), 'DEFAULT';

    is $stashable->object_stash_or($object, 'KEY', 'DEFAULT', 1), 'DEFAULT';
    is $stashable->object_stash($object, 'KEY'), undef;
    is $stashable->object_stash_or($object, 'KEY', 'DEFAULT'), 'DEFAULT';
    is $stashable->object_stash($object, 'KEY'), 'DEFAULT';

    my $cv = AnyEvent->condvar;
    my $timer; $timer = AnyEvent->timer(
        after => 0.5,
        cb => sub {
            $cv->send;
        }
    );

    $cv->recv;

    #is $stashable->stash('KEY'), undef;
    #is $stashable->object_stash($object, 'KEY'), undef;
}

done_testing;
