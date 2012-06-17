package Sweets::Variant;

use strict;
use warnings;

use Sweets;

use Any::Moose;
use YAML::Syck;
use Hash::Merge;
# use AutoLoader qw(AUTOLOAD);

sub BEGIN {
    $YAML::Syck::SortKeys = 1;
    $YAML::Syck::Headless = 1;
}

has _raw => ( is => 'rw' );

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    $class->$orig( _raw => shift );
};

sub _owner {
    my $self = shift;
    $self->{owner} = $_[0] if defined $_[0];
    $self->{owner};
}

sub _is_defined {
    my $self = shift;
    defined($self->_raw)? $self: undef;
}

sub _is_scalar {
    my $self = shift;
    my $raw = $self->_raw;
    defined($raw) && !ref $raw? $self: undef;
}

sub _is_array {
    my $self = shift;
    my $raw = $self->_raw;
    defined($raw) && ref $raw eq 'ARRAY'? $self: undef;
}

sub _is_arrayable {
    my $self = shift;
    my $raw = $self->_raw;
    defined($raw) && ( !ref $raw || ref $raw eq 'ARRAY' || ref $raw eq 'HASH' )
        ? $self: undef;
}

sub _is_hash {
    my $self = shift;
    my $raw = $self->_raw;
    defined($raw) && ref $raw eq 'HASH'? $self: undef;
}

sub _scalar {
    my $value = shift->_raw;
    ref $value? undef: $value;
}

sub _array {
    my $value = shift->_raw;

    return wantarray? @$value: $value
        if ref $value eq 'ARRAY';

    my @array;
    if ( ref $value eq 'HASH' ) {
        @array = values %$value;
    } elsif ( !ref $value && length($value) ) {
        @array = split( /\s*,\s*/, $value );
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
    my $value = shift->_raw;
    ref $value eq 'HASH'? $value: undef;
}

sub _merge_hash {
    my $self = shift;
    my ( $merging, $override ) = @_;
    $merging = $merging->_hash if eval { $merging->isa('Sweets::Variant') };
    $merging = {} if ref $merging ne 'HASH';
    $override = 1 unless defined $override;
    my $hash = $self->_hash || {};

    my $merger = Hash::Merge->new( $override? 'RIGHT_PRECEDENT': 'LEFT_PRECEDENT' );
    $self->_raw($merger->merge( $hash, $merging ));
}

sub _find {
    my $raw = shift->_raw;

    my $traverse = $raw;
    TRAVERSE: for my $needle ( @_ ) {
        unless ( defined($needle) ) {
            $traverse = undef;
            last;
        }

        my @needles = ref $needle eq 'ARRAY'? @$needle: ($needle);
        my $canditate;
        NEEDLE: for my $n ( @needles ) {
            if ( ref $traverse eq 'HASH' && defined($traverse->{$n}) ) {
                $traverse = $traverse->{$n};
                next TRAVERSE;
            } elsif ( ref $traverse eq 'ARRAY' && $n =~ /^[0-9]+$/ && defined($traverse->[$n]) ) {
                $traverse = $traverse->[$n];
                next TRAVERSE;
            }
        }

        $traverse = undef;
        last TRAVERSE;
    }

    return Sweets::Variant->new($traverse);
}

sub _at {
    shift->_find($_[0]);
}

sub _from_yaml {
    my $self = shift;
    $self = $self->new unless ref $self;
    my ( $yaml ) = @_;
    $self->_raw(YAML::Syck::Load($yaml));
    $self;
}

sub _to_yaml {
    my $self = shift;
    YAML::Syck::Dump($self->_raw);
}

sub _load_yaml {
    my $self = shift;
    $self = $self->new unless ref $self;
    my ( $file ) = @_;
    return $self unless -f $file;

    $self->_raw(YAML::Syck::LoadFile($file));
    $self;
}

sub _save_yaml {
    my $self = shift;
    my ( $file ) = @_;
    YAML::Syck::DumpFile($file, $self->_raw);
}

sub AUTOLOAD {
    my $self = shift;
    our $AUTOLOAD;
    if ( $AUTOLOAD =~ /.*::(.*)/ ) {
        my $name = $1;
        my $raw = $self->_raw;
        my $v;
        $v = $raw->{$name} if ref $raw eq 'HASH';
        return Sweets::Variant->new($v);
    }
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
