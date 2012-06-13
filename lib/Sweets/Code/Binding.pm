package Sweets::Code::Binding;

use strict;
use warnings;

use Any::Moose;
use parent 'Sweets::Code';

has bound_package => ( is => 'rw', isa => 'Str' );
has bound_method => ( is => 'rw', isa => 'Str' );
has original => ( is => 'rw', isa => 'CodeRef' );

sub bind {
    my $self = shift;
    my ( $pkg, $method ) = @_;

    eval '# line ' . __LINE__ . ' ' . __FILE__ . "\nrequire $pkg;"
        or Carp::confess("failed loading package $pkg: $@");
    my $name = $pkg . '::' . $method;

    no warnings qw( redefine );
    no strict qw(refs);
    $self->original(\&$name);
    $self->bound_package($pkg);
    $self->bound_method($method);

    *$name = sub { $self->run(@_) };
}

sub run {
    my $self = shift;
    my $pre_run = $self->pre_run( @_, $self->original );
    return $pre_run if defined($pre_run);

    my $result = $self->SUPER::run( @_, $self->original );

    my $post_run = $self->post_run( $result, @_, $self->original );
    return $post_run if defined($post_run);

    $result;
}

sub pre_run { }
sub post_run { }

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
