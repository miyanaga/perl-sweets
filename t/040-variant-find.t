use strict;
use warnings;

use Test::More;

use Sweets::Variant;

my $simple_hash = Sweets::Variant->new({a => 1, b => 2, c => 3});
my $simple_array = Sweets::Variant->new([1,2,3]);

{
    # at hash tests => 5
    isa_ok $simple_hash->_at, 'Sweets::Variant';
    is $simple_hash->_at('a')->_scalar, 1, 'at "a" to hash';
    is $simple_array->_at(1)->_scalar, 2, 'at 1 to array';
    is $simple_hash->_at(1)->_scalar, undef, 'at 1 to hash';
    is $simple_array->_at('a')->_scalar, undef, 'at "a" to array';
}

my $deep_hash = Sweets::Variant->new({
    a => {
        b => {
            c => 1,
        }
    }
});
my $deep_array = Sweets::Variant->new([
    [
        [1,2,3],
    ]
]);
my $mixed = Sweets::Variant->new({
    a => [
        {
            b => [
                {
                    c => 1,
                }
            ]
        }
    ]
});

{
    # find deeply tests => 10
    isa_ok $deep_hash->_find(qw/a b c/), 'Sweets::Variant';
    is $deep_hash->_find(qw/a b c/)->_scalar, 1, 'Existing path';
    is $deep_hash->_find(qw/a b c d/)->_scalar, undef, 'Not existing path';
    is $deep_hash->_find(qw/b c/)->_scalar, undef, 'Not existing path';
    is $deep_array->_find(qw/0 0 0/)->_scalar, 1, 'Existing array path';
    is $deep_array->_find(qw/1 0 0/)->_scalar, undef, 'Not existing array path';
    is $deep_array->_find(qw/0 0 a/)->_scalar, undef, 'Not existing array path';
    is $mixed->_find(qw/a 0 b 0 c/)->_scalar, 1, 'Existing mixed path';
    is $mixed->_find(qw/a 0 b 0 c 0/)->_scalar, undef, 'Not existing mixed path';
    is $mixed->_find(qw/a b c/)->_scalar, undef, 'Not existing mixed path';

}

{
    is $deep_hash->_find([qw/d a/], [qw/d b/], [qw/d c/])->_scalar, 1;
    is $deep_hash->_find([qw/d a/], [qw/d b/], 'd')->_scalar, undef;
}

{
    # By accessor tests => 3
    is $deep_hash->a->b->c->_scalar, 1, 'Existing path';
    is $deep_hash->a->b->c->d->_scalar, undef, 'Not existing path';
    is $deep_hash->a->b->_hash->{c}, 1, 'Hash mixed path';

}

done_testing;
