use strict;
use warnings;

use Test::More;
use Sweets::Etag::File qw(apache_style);

is apache_style('notexists'), undef;
my $etag = apache_style(__FILE__);
like $etag, qr/^[0-9a-f]+-[0-9a-f]+-[0-9a-f]+$/;

done_testing;
