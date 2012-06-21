package Sweets::Application::Component::Config;

use strict;
use warnings;
use parent 'Sweets::Variant::Cascading';

use Any::Moose;
use Sweets::Application::Component;

has container => ( is => 'rw', isa => 'Sweets::Application::Component' );

sub id {
    shift->find('id');
}

sub cascade_to {
    my $c = shift->container || return undef;
    my $prev = $c->chain_prev || return undef;
    $prev->config;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
