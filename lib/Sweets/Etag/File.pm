package Sweets::Etag::File;

use strict;
use warnings;
use base 'Exporter';

our @EXPORT_OK = qw(apache_style);

sub apache_style {
    my ( $file ) = @_;

    return unless -f $file;
    my $ino = (stat $file)[1] || return 'no ino';
    my $size = (stat _)[7] || return 'no size';
    my $mtime = (stat _)[9] || return 'no mtime';

    sprintf('%x-%x-%x', $ino, $size, $mtime * 1000000);
}

1;
__END__
