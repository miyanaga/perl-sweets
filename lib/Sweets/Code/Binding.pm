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
    $self->SUPER::run( @_, $self->original );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
