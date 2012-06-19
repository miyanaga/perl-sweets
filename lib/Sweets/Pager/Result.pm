package Sweets::Pager::Result;

use strict;
use warnings;

use Any::Moose;
use Sweets::Pager::Request;

has request => ( is => 'ro', isa => 'Sweets::Pager::Request' );

has count => ( is => 'rw', isa => 'Int', required => 1 );
has data => ( is => 'rw', isa => 'ArrayRef' );
has page => ( is => 'rw', isa => 'Int', lazy_build =>1, builder => sub {
    shift->request->page;
});

sub pages {
    my $self = shift;
    my $pages = int($self->count / $self->request->per_page);
    $pages++ if $self->count % $self->request->per_page;

    $pages;
}

sub last_page {
    my $self = shift;
    $self->request->base + $self->pages - 1;
}

sub normalize_page {
    my $self = shift;
    my ( $page ) = @_;
    my $base = $self->request->base;
    my $last = $self->last_page;
    $page = $base unless defined($page);

    $page < $base?
        $base
        : $page > $last? $last
            : $page;
}

sub normalized_page {
    my $self = shift;
    $self->normalize_page($self->page);
}

sub is_out_of_range {
    my $self = shift;
    $self->page != $self->normalized_page? 1: 0;
}

sub has_next_page {
    my $self = shift;
    $self->page < $self->last_page? 1: 0;
}

sub has_previous_page {
    my $self = shift;

    $self->page > $self->request->base? 1: 0;
}

sub next_page {
    shift->page + 1;
}

sub previous_page {
    shift->page - 1;
}

sub windows {
    my $self = shift;
    my ( $around, $left, $right ) = @_;
    $around = 1 unless $around;
    $left = $around unless defined($left);
    $right = $around unless defined($right);

    # No windows
    if ( $self->pages == 0 ) {
        return [];
    }

    # Windows
    my $base = $self->request->base;
    my $current = $self->normalized_page;
    my $last = $self->last_page;

    my $second_from = $current - $around;
    $second_from = $base if $second_from <= $base + $left;
    my $second_to = $second_from + $around * 2;
    $second_to = $current + $around if $current + $around > $second_to;
    $second_to = $last if $second_to >= $last - $right;
    my $second = [$second_from..$second_to];

    my $first = $second_from > $base? [$base..($base + $left - 1)]: undef;
    my $third = $second_to < $last? [($last - $right + 1)..$last]: undef;

    # Make array
    my @windows = grep { $_ } ($first, $second, $third);
    wantarray? @windows: \@windows;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
