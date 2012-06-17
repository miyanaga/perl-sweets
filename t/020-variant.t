
use strict;
use warnings;

use Test::More;
use Sweets::Variant;

{
    my $v = Sweets::Variant->new;
    isa_ok $v, 'Sweets::Variant';
    is $v->_raw, undef, 'Default is undef';

    my $arr = $v->_array;
    is_deeply $arr, [];

    my @arr = $v->_array;
    is_deeply \@arr, [];
}

{
    my $v = Sweets::Variant->new(1);
    is $v->_scalar, 1, 'Scalar 1';
    my $a = $v->_array;
    is_deeply $a, [ 1 ], 'As array';
    is $v->_hash, undef, 'As hash';
    my @a = $v->_array;
    is_deeply \@a, [1];
}

{
    my $v = Sweets::Variant->new([1,2,3,1]);
    is $v->_scalar, undef, 'Array is not convertable to scalar';
    my $a = $v->_array;
    is_deeply $a, [1,2,3,1], 'As array';
    my $u = $v->_unique_array;
    is_deeply $u, [1,2,3], 'As unique array';
    my @a = $v->_unique_array;
    is_deeply \@a, [1,2,3];
}

{
    my $v = Sweets::Variant->new('a,b, c');
    is $v->_scalar, 'a,b, c', 'Raw scalar';
    my $a = $v->_array;
    is_deeply $a, [qw/a b c/], 'Converted to array';
    my @a = $v->_array;
    is_deeply \@a, [qw/a b c/];
}

{
    my $v = Sweets::Variant->new({a => 1, b => 2});
    is $v->_scalar, undef, 'Not comvertable to scalar';
    my @a = sort { $a <=> $b } $v->_array;
    is_deeply \@a, [1,2], 'As array, equal values';
    is_deeply $v->_hash, {a=> 1, b => 2}, 'Raw hash';
}

{
    # Onwership
    my $v = Sweets::Variant->new();
    ok !defined $v->_owner;
    $v->_owner(1);
    is $v->_owner, 1;
}

done_testing;
