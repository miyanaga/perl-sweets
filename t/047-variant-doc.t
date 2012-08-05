use strict;
use warnings;

use Sweets::Variant;
use Test::More;

{
    my $var = Sweets::Variant->from_doc(<<'DOC');
@value1 VALUE1
    @value2 VALUE 2
@value3 INCLUDE \@
@value4 LINE \
BREAK
@hash/value5 VALUE5
@hash/child/value6 VALUE6
DOC

    is_deeply $var->as_hash, {
        value1 => 'VALUE1',
        value2 => 'VALUE 2',
        value3 => 'INCLUDE @',
        value4 => "LINE \nBREAK",
        hash => {
            value5 => 'VALUE5',
            child => {
                value6 => 'VALUE6',
            },
        },
    };
}

done_testing;
