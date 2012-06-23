use strict;
use warnings;

use Test::More;
use Sweets::String qw(trim utf8_substr utf8_length utf8_ellipsis);

{
    is trim('abcd'), 'abcd';
    is trim(' abcd'), 'abcd';
    is trim('  abcd  '), 'abcd';
}

{
    my $str = 'abcdefghij';
    is utf8_length($str), 10;

    is utf8_substr($str, 0, 5), 'abcde';
    is utf8_substr($str, 5), 'fghij';
    is utf8_substr($str, 2, 3), 'cde';

    is utf8_ellipsis($str, 5), 'abcde...';
    is utf8_ellipsis($str, 5, '(ry'), 'abcde(ry';
    is utf8_ellipsis($str, 10), $str;
    is utf8_ellipsis($str, 11), $str;
}

{
    my $str = 'いろはにほへとちりぬ';
    is utf8_length($str), 10;

    is utf8_substr($str, 0, 5), 'いろはにほ';
    is utf8_substr($str, 5), 'へとちりぬ';
    is utf8_substr($str, 2, 3), 'はにほ';

    is utf8_ellipsis($str, 5), 'いろはにほ...';
    is utf8_ellipsis($str, 5, '(ry'), 'いろはにほ(ry';
    is utf8_ellipsis($str, 10), $str;
    is utf8_ellipsis($str, 11), $str;
}

done_testing;
