use strict;
use warnings;

use Test::More;
use Sweets::Code;
use lib 't/lib';

{
    local $@;
    eval {
        my $bad_format = Sweets::Code->new( code => 1 );
    };

    like $@, qr/not valid code/;
}

{
    local $@;
    eval {
        my $syntax_error = Sweets::Code->new(
            code => q/
sub { # Not closed.
/
        );
    };

    like $@, qr/failed evaluation/;
}

{
    local $@;
    eval {
        my $bad_package = Sweets::Code->new(
            code => 'Bad::Package::test'
        );
    };

    like $@, qr/failed loading/;
}

{
    local $@;
    eval {
        my $bad_package = Sweets::Code->new(
            code => 'Bad::Package->test'
        );
    };

    like $@, qr/failed loading/;
}

{
    local $@;
    eval {
        my $bad_raw_sub = Sweets::Code->new(
            code => 'Sweets::Code::Test::bad_sub'
        );
    };

    like $@, qr/can not run/;
}

{
    local $@;
    eval {
        my $bad_pkg_sub = Sweets::Code->new(
            code => 'Sweets::Code::Test->bad_sub'
        );
    };

    like $@, qr/can not run/;
}

{
    local $@;
    eval {
        my $changing = Sweets::Code->new(
            code => sub {}
        );
        $changing->code(1);
    };

    like $@, qr/not valid code/;
}

done_testing;
