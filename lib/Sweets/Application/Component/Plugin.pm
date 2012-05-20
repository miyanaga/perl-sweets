package Sweets::Application::Component::Plugin;

use strict;
use warnings;
use parent 'Sweets::Application::Component';

use Any::Moose;

sub is_plugin { 1 }

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
