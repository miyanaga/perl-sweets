package Sweets::String;

use strict;
use warnings;
use utf8;
use base 'Exporter';

our @EXPORT_OK = qw(utf8_substr utf8_length utf8_ellipsis);

sub utf8_substr {
    my ( $str, $o, $l, $r ) = @_;

    my $is_utf8 = utf8::is_utf8($str);
    utf8::decode($str) unless $is_utf8;
    my $result = defined($r)
        ? substr($str, $o, $l, $r)
        : defined($l)
            ? substr($str, $o, $l)
            : substr($str, $o);

    utf8::encode($result) unless $is_utf8;
    $result;
}

sub utf8_length {
    my ( $str ) = @_;

    utf8::decode($str) unless utf8::is_utf8($str);
    length($str);
}

sub utf8_ellipsis {
    my ( $str, $len, $leading ) = @_;
    $leading ||= '...';

    my $is_utf8 = utf8::is_utf8($str);
    utf8::decode($str) unless $is_utf8;
    utf8::decode($leading) unless $is_utf8;

    $str = substr($str, 0, $len) . $leading
        if length($str) > $len;

    utf8::encode($str) unless $is_utf8;
    return $str;
}

1;
__END__
