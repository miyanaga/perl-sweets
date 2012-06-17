package Sweets::Callback::Engine;

use strict;
use warnings;

use Any::Moose;
use Sweets::Callback::Entry;

our $MAX_PRIORITY = 10;
our $MIN_PRIORITY = 1;

has events => ( is => 'ro', isa => 'HashRef', default => sub { {} } );

sub chain_for {
    my $self = shift;
    my ( $event, $priority ) = @_;

    $priority = $priority < $MIN_PRIORITY ? $MIN_PRIORITY
        : $priority > $MAX_PRIORITY ? $MAX_PRIORITY
        : $priority;

    my $priorities = ( $self->events->{$event} ||= [] );
    ( $priorities->[$priority] ||= [] );
}

sub add {
    my $self = shift;
    my ( $entry ) = @_;
    unless ( eval { $entry->isa('Sweets::Callback::Entry') } ) {
        $entry = Sweets::Callback::Entry->new(@_);
    }

    my $chain = $self->chain_for($entry->event, $entry->priority);
    push @$chain, $entry;

    $entry;
}

sub remove {
    my $self = shift;
    my ( $entry ) = @_;

    my $chain = $self->chain_for($entry->event, $entry->priority);
    for( my $i = 0; $i < scalar @$chain; $i++ ) {
        if ( $entry == $chain->[$i] ) {
            delete $chain->[$i];
            last;
        }
    }
}

sub _run_through {
    my $self = shift;
    my $finish = shift;
    my $event = shift;

    my @results;

    if ( my $priorities = $self->events->{$event} ) {
        CHAIN: foreach my $chain ( grep { defined $_ } @$priorities ) {
            foreach my $entry ( grep { defined $_ } @$chain ) {
                my $result = $entry->run( $entry, @_ );
                push @results, $result if defined $result;
                last CHAIN if $finish->($result, $entry);
            }
        }
    }

    wantarray? @results: \@results;
}

sub run_all {
    my $self = shift;
    my @results = $self->_run_through( sub { 0 }, @_ );
    wantarray? @results: \@results;
}

sub run_until {
    my $self = shift;
    my @results = $self->_run_through( sub { defined($_[0]); }, @_ );
    pop @results;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
