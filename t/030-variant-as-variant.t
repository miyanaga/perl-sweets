use strict;
use warnings;

use Test::More tests => 5;

use Sweets::Variant;

my $simple_hash = Sweets::Variant->new({a => 1, b => 2, c => 3});
my $simple_array = Sweets::Variant->new([1,2,3]);
{
    # Accessor tests => 5
    my $a = $simple_hash->a;
    isa_ok $a, 'Sweets::Variant';
    is $a->_scalar, 1, 'Variant to scalar';
    is $a->undefined->_scalar, undef, 'Undefined child';
    my $s = Sweets::Variant->new(1);
    isa_ok $s->a, 'Sweets::Variant';
    is $s->a->_scalar, undef, 'Not an error to scalar variant';
}
