use strict;
use warnings;

use Test::More;
use Sweets::Text::NanoTemplate;

package TestTemplate;

#use Any::Moose;
use parent 'Sweets::Text::NanoTemplate';

sub BUILD {
    my $self = shift;
    $self->prefix('t');
    $self->handles_block(
        block => sub {
            my ( $tmpl, $attr, $inner ) = @_;
            '[BLOCK]' . $tmpl->render($inner) . '[/BLOCK]';
        },
        nest => sub {
            my ( $tmpl, $attr, $inner ) = @_;
            '[NESTED]' . $tmpl->render($inner) . '[/NESTED]';
        },
        ignore => sub { '' }
    );

    $self->handles_function(
        func => sub {
            my ( $tmpl, $attr ) = @_;
            $attr->{error} and die $attr->{error};
            $attr->{value} || 'FUNC';
        }
    );
}

#no Any::Moose;
#__PACKAGE__->meta->make_immutable;

package main;

subtest 'Parse Attribute' => sub {
    my $tmpl = TestTemplate->new;

    my ( $hash, $array ) = $tmpl->parse_attributes(q{noquoted=NOQUOTED
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

subtest 'Normal' => sub {
    my $source = <<'SOURCE';
Hello, <t:func>
<t:block>This is first template: <t:func value="IN BLOCK">.
<t:nest>Nested <t:func value="FINISED WITH /" /></t:nest>
</t:block>
<t:ignore>
Ignored
</t:ignore>
Bye
SOURCE

    my $tmpl = TestTemplate->new(
        template => $source,
    );

    is $tmpl->render, <<'RESULT';
Hello, FUNC
[BLOCK]This is first template: IN BLOCK.
[NESTED]Nested FINISED WITH /[/NESTED]
[/BLOCK]

Bye
RESULT
};

subtest 'Nested Tag' => sub {
    my $source = <<'SOURCE';
<t:block><t:block>nested</t:block></t:block>
SOURCE

    my $tmpl = TestTemplate->new(
        template => $source
    );

    $tmpl->render;
    is $tmpl->error, '<t:block> is nested.';
};

subtest 'Runtime Error' => sub {
    my $source = <<'SOURCE';
<t:func error="ERROR">
SOURCE

    my $tmpl = TestTemplate->new(
        template => $source
    );

    $tmpl->render;
    is $tmpl->error, "ERROR at t/190-text-nano-template.t line 30.\n";
};

done_testing;
