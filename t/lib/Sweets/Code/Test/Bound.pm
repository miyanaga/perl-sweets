package Sweets::Code::Test::Bound;

use strict;
use warnings;

use Any::Moose;

has prop => ( is => 'rw', isa => 'Any' );

sub method {
    my $self = shift;
    ( 'overriding', $self->prop );
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
