
use strict;
use warnings;

use Test::More tests => 13;
use Sweets::Variant;

{
    # Undef tests => 2
    my $v = Sweets::Variant->new;
    isa_ok $v, 'Sweets::Variant';
    is $v->_raw, undef, 'Default is undef';
}

{
    # Scalar tests => 3
    my $v = Sweets::Variant->new(1);
    is $v->_scalar, 1, 'Scalar 1';
    my $a = $v->_array;
    is_deeply $a, [ 1 ], 'As array';
    is $v->_hash, undef, 'As hash';
}

{
    # Array tests => 3
    my $v = Sweets::Variant->new([1,2,3,1]);
    is $v->_scalar, undef, 'Array is not convertable to scalar';
    my $a = $v->_array;
    is_deeply $a, [1,2,3,1], 'As array';
    my $u = $v->_unique_array;
    is_deeply $u, [1,2,3], 'As unique array';
}

{
    # Scalar to array tests => 2
    my $v = Sweets::Variant->new('a,b, c');
    is $v->_scalar, 'a,b, c', 'Raw scalar';
    my $a = $v->_array;
    is_deeply $a, [qw/a b c/], 'Converted to array';
}

{
    # Hash tests => 3
    my $v = Sweets::Variant->new({a => 1, b => 2});
    is $v->_scalar, undef, 'Not comvertable to scalar';
    my @a = sort { $a <=> $b } $v->_array;
    is_deeply \@a, [1,2], 'As array, equal values';
    is_deeply $v->_hash, {a=> 1, b => 2}, 'Raw hash';
}
