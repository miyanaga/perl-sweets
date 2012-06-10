use strict;
use warnings;

use Test::More;
use Sweets::Callback::Engine;

{
    my $hint = {
        counter => {},
        history => [],
        arguments => [],
    };

    my $code = sub {
        my ( $cb, $arg ) = @_;
        $cb->hint->{counter}->{$cb->event} ||= 0;
        $cb->hint->{counter}->{$cb->event}++;
        push @{$cb->hint->{history}}, $cb;
        push @{$cb->hint->{arguments}}, $arg;

        $cb->hint->{counter}->{$cb->event};
    };

    my $engine = Sweets::Callback::Engine->new;

    my $entry = new Sweets::Callback::Entry->new(
        event => 'EVENT1',
        priority => 1,
        code => $code,
        hint => $hint,
    );

    my $cb11 = $engine->add(
        event => 'EVENT1',
        priority => 1,
        code => $code,
        hint => $hint,
    );

    my $cb12 = $engine->add(new Sweets::Callback::Entry->new(
        event => 'EVENT1',
        priority => 2,
        code => $code,
        hint => $hint,
    ));

    my $cb21 = $engine->add(new Sweets::Callback::Entry->new(
        event => 'EVENT2',
        code => $code,
        hint => $hint,
    ));

    # Run all.
    my @all1 = $engine->run_all('EVENT1', 'ALL1');
    is_deeply \@all1, [1, 2];
    is $hint->{counter}->{EVENT1}, 2;
    is_deeply $hint->{arguments}, [qw/ALL1 ALL1/];

    # Run until.
    my $until1 = $engine->run_until('EVENT1', 'UNTIL1');
    is $until1, 3;
    is $hint->{counter}->{EVENT1}, 3;
    is_deeply $hint->{arguments}, [qw/ALL1 ALL1 UNTIL1/];
    is_deeply $hint->{history}, [ $cb11, $cb12, $cb11 ];

    # Remove entry.
    $engine->remove($cb12);
    my @all3 = $engine->run_all('EVENT1');
    is_deeply \@all3, [4];

    # Run another event.
    my $all2 = $engine->run_all('EVENT2');
    is_deeply $all2, [1];
    is $hint->{counter}->{EVENT2}, 1;
}

done_testing;
