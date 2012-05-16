use strict;
use warnings;

use Test::More tests => 9;

use Sweets::Variant::Cascading;

my $global = Sweets::Variant::Cascading->new({
    only_global => {
        value => 'global',
    },
    local_precedence => {
        value => 'global',
    },
    private_precedence => {
        value => 'global',
    },
    merge_all => [qw/global1 global2 global1/],
    hash_all => {
        global1  => 'GLOBAL1',
        global2  => 'GLOBAL2',
    }
});
my $local = Sweets::Variant::Cascading->new({
    local_precedence => {
        value => 'local',
    },
    private_precedence => {
        value => 'local',
    },
    merge_all => 'local',
    merge_local_private => 'local',
    hash_all => {
        local   => 'LOCAL',
    },
    hash_private_local => {
        local   => 'LOCAL',
    },
});
$local->_cascade_to($global);
my $private = Sweets::Variant::Cascading->new({
    private_precedence => {
        value => 'private',
    },
    merge_all => {
        value => 'private',
    },
    merge_local_private => {
        value => 'private',
    },
    hash_all => {
        private => 'PRIVATE',
    },
    hash_private_local => {
        private => 'PRIVATE',
    },
});
$private->_cascade_to($local);

{
    my $only_global = $private->_cascade_find(qw/only_global value/);
    isa_ok $only_global, 'Sweets::Variant';
    is $only_global->_scalar, 'global';
    is $private->_cascade_find(qw/local_precedence value/)->_scalar, 'local';
    is $private->_cascade_find(qw/private_precedence value/)->_scalar, 'private';
}

{
    my $merge_all = $private->_cascade_set(qw/merge_all/);
    my $array = $merge_all->_merge_arrays;
    is_deeply [$array->_array], [ qw/private local global1 global2 global1/ ];
}

{
    my $merged = $private->_cascade_set(qw/merge_local_private/);
    my $array = $merged->_merge_arrays;
    is_deeply [$array->_array], [ qw/private local/ ];
}

{
    my $merge_all = $private->_cascade_set(qw/merge_all/);
    my $array = $merge_all->_merge_arrays;
    is_deeply [$array->_unique_array], [ qw/private local global1 global2/ ];
}

{
    my $hash_all = $private->_cascade_set(qw/hash_all/);
    my $hash = $hash_all->_merge_hashes;
    is_deeply $hash->_hash, {
        private => 'PRIVATE',
        local   => 'LOCAL',
        global1 => 'GLOBAL1',
        global2 => 'GLOBAL2',
    };
}

{
    my $hash_all = $private->_cascade_set(qw/hash_private_local/);
    my $hash = $hash_all->_merge_hashes;
    is_deeply $hash->_hash, {
        private => 'PRIVATE',
        local   => 'LOCAL',
    };
}
