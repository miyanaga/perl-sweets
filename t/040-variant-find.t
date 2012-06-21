use strict;
use warnings;

use Test::More;

use Sweets::Variant;

my $simple_hash = Sweets::Variant->new({a => 1, b => 2, c => 3});
my $simple_array = Sweets::Variant->new([1,2,3]);

{
    # at hash tests => 5
    isa_ok $simple_hash->at, 'Sweets::Variant';
    is $simple_hash->at('a')->as_scalar, 1, 'at "a" to hash';
    is $simple_array->at(1)->as_scalar, 2, 'at 1 to array';
    is $simple_hash->at(1)->as_scalar, undef, 'at 1 to hash';
    is $simple_array->at('a')->as_scalar, undef, 'at "a" to array';
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
    isa_ok $deep_hash->find(qw/a b c/), 'Sweets::Variant';
    is $deep_hash->find(qw/a b c/)->as_scalar, 1, 'Existing path';
    is $deep_hash->find(qw/a b c d/)->as_scalar, undef, 'Not existing path';
    is $deep_hash->find(qw/b c/)->as_scalar, undef, 'Not existing path';
    is $deep_array->find(qw/0 0 0/)->as_scalar, 1, 'Existing array path';
    is $deep_array->find(qw/1 0 0/)->as_scalar, undef, 'Not existing array path';
    is $deep_array->find(qw/0 0 a/)->as_scalar, undef, 'Not existing array path';
    is $mixed->find(qw/a 0 b 0 c/)->as_scalar, 1, 'Existing mixed path';
    is $mixed->find(qw/a 0 b 0 c 0/)->as_scalar, undef, 'Not existing mixed path';
    is $mixed->find(qw/a b c/)->as_scalar, undef, 'Not existing mixed path';

}

{
    is $deep_hash->find([qw/d a/], [qw/d b/], [qw/d c/])->as_scalar, 1;
    is $deep_hash->find([qw/d a/], [qw/d b/], 'd')->as_scalar, undef;
}

done_testing;
