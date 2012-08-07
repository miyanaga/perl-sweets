use strict;
use warnings;

use Sweets::Variant;
use Test::More;

{
    my $var = Sweets::Variant->from_javadoc(<<'DOC');
@value1 VALUE1
    @value2 VALUE 2
@value3 INCLUDE \@
@value4 LINE \
BREAK
@hash/value5 VALUE5
@hash/child/value6 VALUE6
@value7: WITH COLON
@value.8 WITH DOT
@value,9 WITH COMMA
@value.10: WITH COMMA AND COLON
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
        value7 => 'WITH COLON',
        'value.8' => 'WITH DOT',
        'value,9' => 'WITH COMMA',
        'value.10' => 'WITH COMMA AND COLON',
    };
}

{
    my $var = Sweets::Variant->from_javadoc('value1 Not end with new line');
    is_deeply $var->as_hash, {
        value1 => 'Not end with new line'
    };
}

done_testing;
