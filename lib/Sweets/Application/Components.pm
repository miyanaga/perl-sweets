package Sweets::Application::Components;

use strict;
use warnings;

use Any::Moose;
use Sweets::Application::Component;
use Sweets::Application::Component::Plugin;
use Sweets::Application::Components::Config;

has config_paths => ( is => 'rw', isa => 'ArrayRef', default => sub { [qw(config/default.yml)] } );
has all => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );
has dictionary => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has config => ( is => 'ro', isa => 'Sweets::Application::Components::Config', lazy_build => 1, builder => sub {
    my $self = shift;
    my $config = Sweets::Application::Components::Config->new;
    $config->container($self);
    $config;
});

sub component {
    my $self = shift;
    my ( $id ) = @_;
    $self->dictionary->{$id};
}

sub add {
    my $self = shift;
    my ( $c ) = @_;

    die "Component whose id is " . $c->id . " has already exist"
        if $self->dictionary->{$c->id};

    my $last = $self->last;
    $last->chain($c) if $last;

    push @{$self->all}, $c;
    $self->dictionary->{$c->id} = $c;

    $c;
}

sub first {
    shift->all->[0];
}

sub last {
    shift->all->[-1];
}

sub core {
    shift->dictionary->{core};
}

sub private {
    shift->dictionary->{private};
}

sub load_component {
    my $self = shift;
    my ( $path, $id ) = @_;

    my $component = Sweets::Application::Component->new(
        container => $self,
        path    => $path,
        $id? ( id => $id ): (),
    );
    $self->add($component);
}

sub load_plugins {
    my $self = shift;

    my %plugins;
    my @plugins;
    my $index = 0;

    for my $path ( @_ ) {
        next unless -d $path;

        my %dirs;
        opendir( my $dh, $path );
        while ( my $dir = readdir($dh) ) {
            next if $dir =~ /^\./;
            my $fullpath = File::Spec->catdir( $path, $dir );
            next unless -d $fullpath;
            $dirs{$dir} = $fullpath;
        }
        closedir($dh);

        for my $dir ( sort { $a cmp $b } keys %dirs ) {
            my $fullpath = $dirs{$dir};

            my $plugin = Sweets::Application::Component::Plugin->new(
                container => $self,
                path    => $fullpath,
            );

            die "Plugin at $dir has no id" unless $plugin->id;

            $plugins[$index] = $plugin;
            $plugins{$plugin->id} = $index;
            $index++;
        }
    }

    for my $i ( sort { $a <=> $b } values %plugins ) {
        my $plugin = $plugins[$i] || next;
        $self->add($plugin);
    }
}

sub plugins {
    my @components = grep { $_->is_plugin } shift->all;
    wantarray? @components: \@components;
}

sub file_path_to {
    for my $c ( reverse @{shift->all} ) {
        my $path = $c->path_to(@_);
        return $path if -f $path;
    }
}

sub dir_path_to {
    for my $c ( reverse @{shift->all} ) {
        my $path = $c->path_to(@_);
        return $path if -d $path;
    }
}

sub file_paths_to {
    my @paths;
    for my $c ( reverse @{shift->all} ) {
        my $path = $c->path_to(@_);
        push @paths, $path if -f $path;
    }
    wantarray? @paths: \@paths;
}

sub dir_paths_to {
    my @paths;
    for my $c ( reverse @{shift->all} ) {
        my $path = $c->path_to(@_);
        push @paths, $path if -d $path;
    }
    wantarray? @paths: \@paths;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
