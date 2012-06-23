package Stashable;

use strict;
use warnings;
use lib 'blib';
use parent 'Sweets::Aspect::Stashable';

package main;

use strict;
use warnings;

use Test::More;

{
    my $stashable = Stashable->new;

    is $stashable->stash('KEY'), undef;
    $stashable->stash('KEY', 'VALUE');
    is $stashable->stash('KEY'), 'VALUE';

    my $array = [];
    $stashable->stash('ARRAY', $array);
    is $stashable->stash('ARRAY'), $array;
    is $stashable->stash('KEY'), 'VALUE';

    my $scalar = 'SCALAR';
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
}

done_testing;
