
use strict;
use warnings;

use Test::More;
use Sweets::Variant;

{
    my $v = Sweets::Variant->new;
    isa_ok $v, 'Sweets::Variant';
    is $v->raw, undef, 'Default is undef';

    my $arr = $v->as_array;
    is_deeply $arr, [];

    my @arr = $v->as_array;
    is_deeply \@arr, [];
}

{
    my $v = Sweets::Variant->new(1);
    is $v->as_scalar, 1, 'Scalar 1';
    my $a = $v->as_array;
    is_deeply $a, [ 1 ], 'As array';
    is $v->as_hash, undef, 'As hash';
    my @a = $v->as_array;
    is_deeply \@a, [1];
}

{
    my $v = Sweets::Variant->new([1,2,3,1]);
    is $v->as_scalar, undef, 'Array is not convertable to scalar';
    my $a = $v->as_array;
    is_deeply $a, [1,2,3,1], 'As array';
    my $u = $v->unique_array;
    is_deeply $u, [1,2,3], 'As unique array';
    my @a = $v->unique_array;
    is_deeply \@a, [1,2,3];
}

{
    my $v = Sweets::Variant->new('a,b, c');
    is $v->as_scalar, 'a,b, c', 'Raw scalar';
    my $a = $v->as_array;
    is_deeply $a, [qw/a b c/], 'Converted to array';
    my @a = $v->as_array;
    is_deeply \@a, [qw/a b c/];
}

{
    my $v = Sweets::Variant->new({a => 1, b => 2});
    is $v->as_scalar, undef, 'Not comvertable to scalar';
    my @a = sort { $a <=> $b } $v->as_array;
    is_deeply \@a, [1,2], 'As array, equal values';
    is_deeply $v->as_hash, {a=> 1, b => 2}, 'Raw hash';
}

{
    # Onwership
    my $v = Sweets::Variant->new();
    ok !defined $v->owner;
    $v->owner(1);
    is $v->owner, 1;
}

done_testing;
