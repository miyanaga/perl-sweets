package Sweets::Package;

use strict;
use warnings;

use Carp;

sub available {
    my $this = shift;
    my ( $pkg ) = @_;

    eval '# line ' . __LINE__ . ' ' . __FILE__ . "\nrequire $pkg;"
}

sub require {
    my $this = shift;
    for my $pkg ( @_ ) {
        $this->available($pkg)
            or Carp::confess("failed loading package $pkg: $@");
    }

    scalar @_;
}

1;
__END__
