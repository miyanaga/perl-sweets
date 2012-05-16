package Sweets::Variant::Set;

use strict;
use warnings;

use Hash::Merge;

sub new {
    my $pkg = shift;
    $pkg = ref $pkg if ref $pkg;

    my $self = bless { set => [] }, $pkg;
    $self->_push( @_ );
    $self;
}

sub _push {
    push @{shift->{set}}, grep {
        eval { $_->isa('Sweets::Variant') }
    } @_;
}

sub _array {
    my $self = shift;
    wantarray? @{$self->{set}}: $self->{set};
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
    for my $v ( @{shift->{set}} ) {
        my $hash = $v->_hash || next;
        %result = %{$merger->merge( \%result, $hash )};
    }
    Sweets::Variant->new(\%result);
}

1;
__END__
