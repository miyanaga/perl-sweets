package Sweets::Application::Components::Config;

use strict;
use warnings;
use parent 'Sweets::Variant::Cascading';

use Any::Moose;

has container => ( is => 'rw', isa => 'Sweets::Application::Components' );

sub _cascade_to {
    my $c = shift->container || return;
    my $last = $c->last || return;
    $last->config;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
