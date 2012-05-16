package Sweets::Variant;

use strict;
use warnings;

use Sweets;
# use AutoLoader qw(AUTOLOAD);

sub new {
    my $pkg = shift;
    $pkg = ref $pkg if ref $pkg;
    my ( $value ) = @_;

    bless { raw => $value }, $pkg;
}

sub DESTROY {
    delete shift->{raw};
}

sub _raw {
    shift->{raw};
}

sub _is_defined {
    my $self = shift;
    defined($self->{raw})? $self: undef;
}

sub _is_scalar {
    my $self = shift;
    my $raw = $self->{raw};
    defined($raw) && !ref $raw? $self: undef;
}

sub _is_array {
    my $self = shift;
    my $raw = $self->{raw};
    defined($raw) && ref $raw eq 'ARRAY'? $self: undef;
}

sub _is_arrayable {
    my $self = shift;
    my $raw = $self->{raw};
    defined($raw) && ( !ref $raw || ref $raw eq 'ARRAY' || ref $raw eq 'HASH' )
        ? $self: undef;
}

sub _is_hash {
    my $self = shift;
    my $raw = $self->{raw};
    defined($raw) && ref $raw eq 'HASH'? $self: undef;
}

sub _scalar {
    my $value = shift->{raw};
    ref $value? undef: $value;
}

sub _array {
    my $value = shift->{raw};

    return wantarray? @$value: $value
        if ref $value eq 'ARRAY';

    my @array;
    if ( ref $value eq 'HASH' ) {
        @array = values %$value;
    } elsif ( !ref $value && length($value) ) {
        @array = split( /\s*,\s*/, $value );
    } else {
        return;
    }

    wantarray? @array: \@array;
}

sub _sorted_hash_array {
    my $self = shift;
    my ( $sorter ) = @_;
    $sorter ||= $Sweets::DEFAULT_SORTER;

    my @array = soft {
        ( $a->{$sorter} || $Sweets::DEFAULT_ORDER )
            <=> ( $b->{$sorter} || $Sweets::DEFAULT_ORDER );
    } grep {
        ref $_ eq 'HASH';
    } $self->_array;

    wantarray? @array: \@array;
}

sub _unique_array {
    my %unique;
    my @array;
    for my $v ( @{shift->_array} ) {
        # TODO: How to handle if not a scalar?
        next if $unique{$v};
        $unique{$v} = 1;
        push @array, $v;
    }
    wantarray? @array: \@array;
}

sub _hash {
    my $value = shift->{raw};
    ref $value eq 'HASH'? $value: undef;
}

sub _find {
    my $raw = shift->{raw};
    my ( $needle ) = @_;

    my $traverse = $raw;
    for my $needle ( @_ ) {
        unless ( defined($needle) ) {
            $traverse = undef;
            last;
        }

        if ( ref $traverse eq 'HASH' && defined($traverse->{$needle}) ) {
            $traverse = $traverse->{$needle};
        } elsif ( ref $traverse eq 'ARRAY' && $needle =~ /^[0-9]+$/ && defined($traverse->[$needle]) ) {
            $traverse = $traverse->[$needle];
        } else {
            $traverse = undef;
            last;
        }
    }

    return Sweets::Variant->new($traverse);
}

sub _at {
    shift->_find($_[0]);
}

sub AUTOLOAD {
    my $self = shift;
    our $AUTOLOAD;
    if ( $AUTOLOAD =~ /.*::(.*)/ ) {
        my $name = $1;
        my $raw = $self->{raw};
        my $v;
        $v = $raw->{$name} if ref $raw eq 'HASH';
        return Sweets::Variant->new($v);
    }
}

1;
__END__
