package Sweets::Pager::Request;

use strict;
use warnings;

use Any::Moose;
use Sweets::Pager::Result;

has base => ( is => 'ro', isa => 'Int', default => 1 );
has per_page => ( is => 'ro', isa => 'Int', required => 1 );
has page => ( is => 'rw', isa => 'Int', default => 0 );

sub zero_base {
    - shift->base + shift;
}

sub based {
    shift->base + shift;
}

sub zero_based_page {
    my $self = shift;
    $self->zero_base($self->page);
}

sub offset {
    my $self = shift;
    $self->zero_based_page * $self->per_page;
}

sub limit {
    shift->per_page;
}

sub offset_from {
    shift->offset;
}

sub offset_to {
    my $self = shift;
    $self->offset_from + $self->limit;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
