use strict;
use warnings;

use Test::More;
use Sweets::Helper::HTML;

{
    my $helper = Sweets::Helper::HTML->new;

    is $helper->escape_html('<a href="you&me">'), '&lt;a href=&quot;you&amp;me&quot;&gt;';
    is $helper->escape_uri('/test/index.html?value=test&escape=-^@[:],./'),
        '%2Ftest%2Findex.html%3Fvalue%3Dtest%26escape%3D-%5E%40%5B%3A%5D%2C.%2F';
    is $helper->escape_js(q!&foo"bar'</script>!), '\u0026foo\u0022bar\u0027\u003c/script\u003e';
}

{
    my $helper = Sweets::Helper::HTML->new;

    is $helper->element('i', class => 'icon-test'), '<i class="icon-test">';
    is $helper->element('i', attr => { class => 'icon-test' }), '<i class="icon-test">';
    is $helper->element('i', class => 'icon-test', attr => { 'data-attr' => 'value' }), '<i class="icon-test" data-attr="value">';
    is $helper->element('i', id => 'ID', class => 'icon-test', attr => { 'data-attr' => 'value' }), '<i id="ID" class="icon-test" data-attr="value">';
    is $helper->element('i', attr => { class => [qw/icon icon-test/] }), '<i class="icon icon-test">';
    is $helper->element('i', xhtml => 1, attr => { class => 'icon-test' }), '<i class="icon-test" />';
    is $helper->element('i', attr => { 'data-attr' => '&' }), '<i data-attr="&">';
    is $helper->element('i', raw_attr => { 'data-attr' => '&' }), '<i data-attr="&amp;">';

    is $helper->element('a', attr => { href => '/test/' }, inner => 'ANCHOR'), '<a href="/test/">ANCHOR</a>';
    is $helper->element('a', attr => { href => '/test/' }, inner => sub { 'ANCHOR' }), '<a href="/test/">ANCHOR</a>';
}

{
    my $helper = Sweets::Helper::HTML->new(xhtml => 1);

    is $helper->element('i', attr => { class => 'icon-test' }), '<i class="icon-test" />';
    is $helper->element('a', attr => { href => '/test/' }, inner => 'ANCHOR'), '<a href="/test/">ANCHOR</a>';
}

done_testing;
