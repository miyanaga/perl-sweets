package Sweets::Variant::Cascading;

use strict;
use warnings;
use parent 'Sweets::Variant';

use Any::Moose;
use Sweets::Variant::Set;

has _cascade_to => ( is => 'rw', isa => 'Sweets::Variant::Cascading' );

sub _cascade_find {
    my $variant = shift;
    my $pkg = ref $variant;
    while ( $variant ) {
        if ( my $found = $variant->_find(@_)->_is_defined ) {
            return $found;
        }
        $variant = $variant->_cascade_to;
    }
    Sweets::Variant->new;
}

sub _cascade_at {
    shift->_cascade_find($_[0]);
}

sub _cascade_set {
    my $variant = shift;
    my @set;
    while ( $variant ) {
        if ( my $found = $variant->_find(@_)->_is_defined ) {
            push @set, $found;
        }
        $variant = $variant->_cascade_to;
    }

    Sweets::Variant::Set->new(@set);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
