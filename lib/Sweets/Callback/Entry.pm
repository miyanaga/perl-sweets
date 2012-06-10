package Sweets::Callback::Entry;

use strict;
use warnings;

use Any::Moose;
use parent 'Sweets::Code';

has event => ( is => 'ro', isa => 'Str', default => '', required => 1 );
has priority => ( is => 'ro', isa => 'Int', default => 5 );
has hint => ( is => 'rw', isa => 'Any' );

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
