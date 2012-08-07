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

has raw => ( is => 'rw' );

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    $class->$orig( raw => shift );
};

sub owner {
    my $self = shift;
    $self->{owner} = $_[0] if defined $_[0];
    $self->{owner};
}

sub is_defined {
    my $self = shift;
    defined($self->raw)? $self: undef;
}

sub is_scalar {
    my $self = shift;
    my $raw = $self->raw;
    defined($raw) && !ref $raw? $self: undef;
}

sub is_array {
    my $self = shift;
    my $raw = $self->raw;
    defined($raw) && ref $raw eq 'ARRAY'? $self: undef;
}

sub is_arrayable {
    my $self = shift;
    my $raw = $self->raw;
    defined($raw) && ( !ref $raw || ref $raw eq 'ARRAY' || ref $raw eq 'HASH' )
        ? $self: undef;
}

sub is_hash {
    my $self = shift;
    my $raw = $self->raw;
    defined($raw) && ref $raw eq 'HASH'? $self: undef;
}

sub as_scalar {
    my $value = shift->raw;
    ref $value? undef: $value;
}

sub as_array {
    my $value = shift->raw;

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

sub sorted_hash_array {
    my $self = shift;
    my ( $sorter ) = @_;
    $sorter ||= $Sweets::DEFAULT_SORTER;

    my @array = soft {
        ( $a->{$sorter} || $Sweets::DEFAULT_ORDER )
            <=> ( $b->{$sorter} || $Sweets::DEFAULT_ORDER );
    } grep {
        ref $_ eq 'HASH';
    } $self->as_array;

    wantarray? @array: \@array;
}

sub unique_array {
    my %unique;
    my @array;
    for my $v ( @{shift->as_array} ) {
        # TODO: How to handle if not a scalar?
        next if $unique{$v};
        $unique{$v} = 1;
        push @array, $v;
    }
    wantarray? @array: \@array;
}

sub as_hash {
    my $value = shift->raw;
    ref $value eq 'HASH'? $value: undef;
}

sub merge_hash {
    my $self = shift;
    my ( $merging, $override ) = @_;
    $merging = $merging->as_hash if eval { $merging->isa('Sweets::Variant') };
    $merging = {} if ref $merging ne 'HASH';
    $override = 1 unless defined $override;
    my $hash = $self->as_hash || {};

    my $merger = Hash::Merge->new( $override? 'RIGHT_PRECEDENT': 'LEFT_PRECEDENT' );
    $self->raw($merger->merge( $hash, $merging ));
}

sub find {
    my $raw = shift->raw;

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

sub at {
    shift->find($_[0]);
}

sub from_yaml {
    my $self = shift;
    $self = $self->new unless ref $self;
    my ( $yaml ) = @_;
    $self->raw(YAML::Syck::Load($yaml));
    $self;
}

sub to_yaml {
    my $self = shift;
    YAML::Syck::Dump($self->raw);
}

sub load_yaml {
    my $self = shift;
    $self = $self->new unless ref $self;
    my ( $file ) = @_;
    return $self unless -f $file;

    $self->raw(YAML::Syck::LoadFile($file));
    $self;
}

sub save_yaml {
    my $self = shift;
    my ( $file ) = @_;
    YAML::Syck::DumpFile($file, $self->raw);
}

sub from_javadoc {
    my $self = shift;
    $self = $self->new unless ref $self;
    my ( $doc ) = @_;
    $doc .= "\n" if substr($doc, -1, 1) ne "\n";

    my %values;
    while ( $doc =~ /(?<!\\)\@(.+?)(?<!\\)\n/igs ) {
        my ( $name, $value ) = split( /\s+/, $1, 2 );
        $value =~ s/\\([\n\@])/$1/g;
        $name =~ s/:+$//;

        if ( $name =~ m!/! ) {
            my @dig = grep { $_ } split m!/!, $name;
            $name = pop @dig;

            my $hash = \%values;
            for my $p ( @dig ) {
                $hash = ( $hash->{$p} ||= {} );
            }
            $hash->{$name} = $value;
        } else {
            $values{$name} = $value;
        }
    }

    $self->raw(\%values);
    $self;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
