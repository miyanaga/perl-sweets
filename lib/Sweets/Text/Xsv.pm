package Sweets::Text::Xsv;

use strict;
use warnings;

use Any::Moose;

has separator => ( is => 'ro', isa => 'Str', default => ',' );
has line_break => ( is => 'ro', isa => 'Str', default => "\n" );
has quotes => ( is => 'ro', isa => 'Str', default => q{"'} );
has rows => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );

sub parse {
    my $self = shift;
    my ( $source ) = @_;

    my $sep = $self->separator;
    my $eol = $self->line_break;
    my $quo = $self->quotes; $quo = qr/[$quo]/;
    my @rows;
    my $cols;

    $source .= $eol if $source !~ /$eol$/;
    while ( $source =~ /(?:(?:($quo)(.*?)(?:(?<!\\)\1|$))|(.*?))($sep|$eol)/sg ) {
        my $quote = $1;
        my $value = defined $2? $2: $3;
        $value =~ s/\\$quote/$quote/g if $quote && $value;
        my $suffix = $4;

        $cols ||= [];
        push @$cols, $value;
        if ( $suffix && $suffix eq $eol ) {
            push @rows, $cols;
            $cols = undef;
        }
    }
    push @rows, $cols if $cols;

    $self->rows(\@rows);
    $self;
}

sub header {
    my $self = shift;
    $self->rows->[0];
}

sub hash_array {
    my $self = shift;
    my @rows = @{$self->rows};
    my @results;
    my $header = shift @rows || return \@results;
    return \@results if ref $header ne 'ARRAY';
    for my $row ( @rows ) {
        next if ref $row ne 'ARRAY';
        my %result;
        for ( my $i = 0; $i < scalar @$header; $i++ ) {
            $result{$header->[$i]} = $row->[$i];
        }
        push @results, \%result;
    }

    \@results;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
