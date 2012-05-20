package Sweets::Variant::Set;

use strict;
use warnings;

use Any::Moose;
use Hash::Merge;

has _set => ( is => 'ro', isa => 'ArrayRef', default => sub { [] } );

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    $class->$orig( _set => \@_ );
};

sub _push {
    push @{shift->_set}, grep {
        eval { $_->isa('Sweets::Variant') }
    } @_;
}

sub _array {
    my $self = shift;
    wantarray? @{$self->_set}: $self->_set;
}

sub _merge_arrays {
    my @array;
    my ( $variant_filter ) = @_;
    for my $v ( shift->_array ) {
        next unless $v->_is_arrayable;
        next if ref $variant_filter eq 'CODE' && !$variant_filter->($v);
        push @array, @{$v->_array};
    }
    Sweets::Variant->new(\@array);
}

sub _merge_hashes {
    my %result;
    my ( $reverse ) = 1;
    my $merger = Hash::Merge->new($reverse? 'RIGHT_PRECEDENT': 'LEFT_PRECEDENT');
    for my $v ( @{shift->_set} ) {
        my $hash = $v->_hash || next;
        %result = %{$merger->merge( \%result, $hash )};
    }
    Sweets::Variant->new(\%result);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
