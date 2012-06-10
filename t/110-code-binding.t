use strict;
use warnings;
use lib 't/lib';

use Test::More;
use Sweets::Code::Binding;
use Sweets::Code::Test::Bound;

{
    my $method = Sweets::Code::Binding->new(
        code => sub {
            my $bound = shift;
            my ( $orig ) = @_;
            [ $orig->($bound), 'overridden' ];
        },
    );
    $method->bind( 'Sweets::Code::Test::Bound', 'method' );

    my $bound = Sweets::Code::Test::Bound->new( prop => 'PROP' );
    is_deeply $bound->method, [qw/overriding PROP overridden/];

    my $prop = Sweets::Code::Binding->new(
        code => sub {
            my $bound = shift;
            my $orig = pop;
            lc($orig->($bound, @_));
        }
    );
    $prop->bind( 'Sweets::Code::Test::Bound', 'prop' );

    is $bound->prop, 'prop';
    $bound->prop('CHANGED');
    is $bound->prop, 'changed';
}

done_testing;
