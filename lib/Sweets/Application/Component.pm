package Sweets::Application::Component;

use strict;
use warnings;

use Any::Moose;

use Sweets::Application::Component::Config;
use File::Spec;

has container => ( is => 'ro', isa => 'Sweets::Application::Components', required => 1 );
has path => ( is => 'ro', isa => 'Str', required => 1 );
has config => ( is => 'ro', isa => 'Sweets::Application::Component::Config', lazy_build => 1, builder => sub {
    my $self = shift;
    my $config = Sweets::Application::Component::Config->new;
    $config->container($self);

    for my $path ( @{$self->container->config_paths} ) {
        my $fullpath = File::Spec->catdir($self->path, $path);
        my $yaml = Sweets::Variant->load_yaml($fullpath)->as_hash || next;

        $config->merge_hash($yaml);
    }

    $config;
});
has chain_next => ( is => 'rw', isa => 'Sweets::Application::Component' );
has chain_prev => ( is => 'rw', isa => 'Sweets::Application::Component' );
has id => ( is => 'ro', isa => 'Str', lazy_build => 1, builder => sub {
    shift->config->id->as_scalar;
});

sub BUILD {
    my $self = shift;
    Carp::confess("The directory path " . $self->path . " does not exist")
        unless -d $self->path;
}

sub chain {
    my $self = shift;
    my ( $c ) = @_;

    $self->chain_next($c);
    $c->chain_prev($self);
}

sub path_to {
    my $self = shift;
    File::Spec->catdir($self->path, @_);
}

sub is_plugin { 0 }

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
