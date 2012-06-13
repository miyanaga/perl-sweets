use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Sweets::Code::Test::Bound;
use Sweets::Code::Test::Wrap;

{
    my $method = Sweets::Code::Test::Wrap::PreRun->new(
        code => sub {
            my $bound = shift;
            my ( $arg, $orig ) = @_;
            [ $bound->prop, $arg, 'overridden' ];
        },
    );
    $method->bind( 'Sweets::Code::Test::Bound', 'method_pre_run' );

    my $bound = Sweets::Code::Test::Bound->new( prop => 'PROP' );
    my $result = $bound->method_pre_run('test');
    is_deeply $result, [qw/test pre_run/];
}

{
    my $method = Sweets::Code::Test::Wrap::PostRun->new(
        code => sub {
            my $bound = shift;
            my ( $arg, $orig ) = @_;
            [ $bound->prop, $arg, 'overridden' ];
        },
    );
    $method->bind( 'Sweets::Code::Test::Bound', 'method_post_run' );

    my $bound = Sweets::Code::Test::Bound->new( prop => 'PROP' );
    my $result = $bound->method_post_run('test');
    is_deeply $result, [qw/PROP test overridden test post_run/];
}

done_testing;
