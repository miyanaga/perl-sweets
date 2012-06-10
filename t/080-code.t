use strict;
use warnings;

use Test::More;
use Sweets::Code;

use lib 't/lib';

{
    my $result = 0;
    my $raw_code = Sweets::Code->new(
        code => sub { $result++ }
    );

    $raw_code->ref->();
    is $result, 1;

    $raw_code->run;
    is $result, 2;
}

{
    my $text_code = Sweets::Code->new(
        code => q/
sub {
    my ( $ref ) = @_;
    $$ref++;
}/
    );

    my $result = 0;
    $text_code->ref->(\$result);
    is $result, 1;

    $text_code->run(\$result);
    is $result, 2;
}

{
    my $pkg_code = Sweets::Code->new(
        code => 'Sweets::Code::Test::increment_raw_method'
    );

    my $result = 0;
    $pkg_code->ref->(\$result);
    is $result, 1;

    $pkg_code->run(\$result);
    is $result, 2;
}

{
    my $pkg_code = Sweets::Code->new(
        code => 'Sweets::Code::Test->increment_pkg_method'
    );

    my $result = 0;
    $pkg_code->ref->(\$result);
    is $result, 1;

    $pkg_code->run(\$result);
    is $result, 2;
}

done_testing;
