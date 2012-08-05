use strict;
use warnings;

use Test::More;
use Sweets::Text::HTML::Attributes::Parser;
use Sweets::Text::HTML::Attributes::Builder;

subtest 'Parse Attribute' => sub {
    my ( $hash, $array ) = Sweets::Text::HTML::Attributes::Parser->parse(q{noquoted=NOQUOTED
        singlequoted='SINGLE QUOTED' singleescaped='SINGLE \'ESCAPED\''
        doublequoted="DOUBLE QUOTED" doubleescaped="DOUBLE \"ESCAPED\""
        mixedquoted="MIXED 'QUOTED'" mixedquoted2='MIXED "QUOTED" 2'
        spaced = "SPACED"
        linebroken="LINE
BROKEN" NONAME 'NONAME SINGLE QUOTED' "NONAME DOUBLE QUOTED"
'NONAME SINGLE \'ESCAPED\'' "NONAME DOUBLE \"ESCAPED\""});

    is_deeply $hash, {
        noquoted => 'NOQUOTED',
        singlequoted => 'SINGLE QUOTED', singleescaped => 'SINGLE \'ESCAPED\'',
        doublequoted => "DOUBLE QUOTED", doubleescaped => "DOUBLE \"ESCAPED\"",
        mixedquoted => "MIXED 'QUOTED'", mixedquoted2 => 'MIXED "QUOTED" 2',
        spaced => "SPACED",
        linebroken => "LINE\nBROKEN",
        '' => "NONAME DOUBLE \"ESCAPED\"",
    };

    is_deeply $array, [
        { name => 'noquoted', value => 'NOQUOTED' },
        { name => 'singlequoted', value => 'SINGLE QUOTED'}, { name => 'singleescaped', value => 'SINGLE \'ESCAPED\'' },
        { name => 'doublequoted', value => "DOUBLE QUOTED"}, { name => 'doubleescaped', value => "DOUBLE \"ESCAPED\"" },
        { name => 'mixedquoted', value => "MIXED 'QUOTED'" }, { name => 'mixedquoted2', value => 'MIXED "QUOTED" 2' },
        { name => 'spaced', value => "SPACED" },
        { name => 'linebroken', value => "LINE\nBROKEN" },
        'NONAME', 'NONAME SINGLE QUOTED', "NONAME DOUBLE QUOTED",
        'NONAME SINGLE \'ESCAPED\'', "NONAME DOUBLE \"ESCAPED\"",
    ];
};

subtest 'Parse and Build' => sub {
    my $parser = Sweets::Text::HTML::Attributes::Parser->new(
        raw => q{name1=VALUE1 name2="VALUE 2" name3='VALUE 3' VALUE4 "VALUE 5"}
    );

    is $parser->as_string, q{name1="VALUE1" name2="VALUE 2" name3="VALUE 3" "VALUE4" "VALUE 5"};
    is $parser->as_string(1), q{"VALUE4" "VALUE 5" name1="VALUE1" name2="VALUE 2" name3="VALUE 3"};

    my $builder = $parser->build_on;
    $builder->add( value6 => 'VALUE 6', 'value 7' => 'VALUE 7' );
    is $builder->as_string, q{name1="VALUE1" name2="VALUE 2" name3="VALUE 3" "VALUE4" "VALUE 5" "value 7"="VALUE 7" value6="VALUE 6"};
    $builder->remove(qw/name1 name2 name3/);
    is $builder->as_string, q{"VALUE4" "VALUE 5" "value 7"="VALUE 7" value6="VALUE 6"};
    $builder->clear;
    is $builder->as_string, q{};
};

done_testing;
