use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Sweets::Package;

{
    my $require = Sweets::Package->require(qw/Test::More Sweets::Package Sweets::Code::Test/);
    is $require, 3;

    eval {
        Sweets::Package->require(qw/Test::More Sweets::Code::Test::Unknown/);
    };

    like $@, qr/failed/;
}

done_testing;
