package Sweets::Variant::Set;

use strict;
use warnings;

use Any::Moose;
use Hash::Merge;

has set => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    $class->$orig( set => \@_ );
};

sub push_after {
    push @{shift->set}, grep {
        eval { $_->isa('Sweets::Variant') }
    } @_;
}

sub as_array {
    my $self = shift;
    wantarray? @{$self->set}: $self->set;
}

sub merge_arrays {
    my @array;
    my ( $variant_filter ) = @_;
    for my $v ( @{shift->as_array} ) {
        next unless $v->is_arrayable;
        next if ref $variant_filter eq 'CODE' && !$variant_filter->($v);
        push @array, @{$v->as_array};
    }
    Sweets::Variant->new(\@array);
}

sub merge_hashes {
    my %result;
    my ( $reverse ) = 1;
    my $merger = Hash::Merge->new($reverse? 'RIGHT_PRECEDENT': 'LEFT_PRECEDENT');
    for my $v ( @{shift->set} ) {
        my $hash = $v->as_hash || next;
        %result = %{$merger->merge( \%result, $hash )};
    }
    Sweets::Variant->new(\%result);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
