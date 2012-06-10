package Sweets::Code::Test;

use strict;
use warnings;

sub increment_raw_method {
    my ( $ref ) = @_;
    $$ref++;
}

sub increment_pkg_method {
    my $pkg = shift;
    my ( $ref ) = @_;
    $$ref++;
}

1;
