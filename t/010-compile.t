# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Sweets.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More;

use_ok('Sweets');
use_ok('Sweets::Variant');
use_ok('Sweets::Variant::Set');
use_ok('Sweets::Variant::Cascading');
use_ok('Sweets::Tree::MultiPath::Node');

use_ok('Sweets::Application::Component');
use_ok('Sweets::Application::Component::Config');
use_ok('Sweets::Application::Component::Plugin');
use_ok('Sweets::Application::Components');
use_ok('Sweets::Application::Components::Config');

use_ok('Sweets::Package');
use_ok('Sweets::Code');
use_ok('Sweets::Code::Binding');
use_ok('Sweets::Callback');
use_ok('Sweets::Pager');

done_testing;

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.
