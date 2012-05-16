package Sweets::Variant::Cascading;

use strict;
use warnings;
use parent 'Sweets::Variant';

use Sweets::Variant::Set;

sub new {
    my $self = shift->SUPER::new(@_);
}

sub _cascade_to {
    my $self = shift;
    $self->{cascade} = $_[0] if @_;
    $self->{cascade};
}

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
    shift->_cascade_find_first($_[0]);
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

1;
__END__
