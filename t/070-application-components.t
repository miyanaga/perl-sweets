use strict;
use warnings;

use Test::More;
use Sweets::Application::Components;

my $components = Sweets::Application::Components->new(

);

$components->load_component('t/app', 'core');
$components->load_plugins('t/app/buildins', 't/app/private/plugins');
$components->load_component('t/app/private', 'private');

my $core = $components->component('core');
my $plugin1 = $components->component('plugin1');
my $buildin1 = $components->component('buildin1');
my $common = $components->component('common');
my $private = $components->component('private');

{
    is $core->id, 'core';
    is $core->path, 't/app';

    is $buildin1->id, 'buildin1';
    is $buildin1->path, 't/app/buildins/buildin1';

    is $common->id, 'common';
    is $common->path, 't/app/private/plugins/common';

    is $plugin1->id, 'plugin1';
    is $plugin1->path, 't/app/private/plugins/plugin1';

    is $private->id, 'private';
    is $private->path, 't/app/private';
}

{
    is $core->chain_next, $buildin1;
    is $buildin1->chain_next, $common;
    is $common->chain_next, $plugin1;
    is $plugin1->chain_next, $private;
    is $private->chain_next, undef;

    is $private->chain_prev, $plugin1;
    is $plugin1->chain_prev, $common;
    is $common->chain_prev, $buildin1;
    is $buildin1->chain_prev, $core;
    is $core->chain_prev, undef;
}

{
    is $core->config->_find(qw/private_overrides here/)->_scalar, 'core';
    is $buildin1->config->_find(qw/private_overrides here/)->_scalar, 'buildin1';
    is $common->config->_find(qw/private_overrides here/)->_scalar, 'plugin_common';
    is $plugin1->config->_find(qw/private_overrides here/)->_scalar, 'plugin1';
    is $private->config->_find(qw/private_overrides here/)->_scalar, 'private';
}

{
    is $components->config->_cascade_find(qw/only_core here/)->_scalar, 'core';
    is $components->config->_cascade_find(qw/buildin_overrides here/)->_scalar, 'buildin1';
    is $components->config->_cascade_find(qw/common_overrides here/)->_scalar, 'plugin_common';
    is $components->config->_cascade_find(qw/plugin_overrides here/)->_scalar, 'plugin1';
    is $components->config->_cascade_find(qw/private_overrides here/)->_scalar, 'private';
}

{
    my $dirs = $components->dir_paths_to('lib');
    is_deeply $dirs, [qw(t/app/private/lib t/app/private/plugins/plugin1/lib t/app/buildins/buildin1/lib t/app/lib)];

    my $files = $components->file_paths_to('static/index.html');
    is_deeply $files, [qw(t/app/private/plugins/plugin1/static/index.html t/app/buildins/buildin1/static/index.html)];

    is $components->dir_path_to('lib'), 't/app/private/lib';
    is $components->file_path_to('static/index.html'), 't/app/private/plugins/plugin1/static/index.html';

}

done_testing;
