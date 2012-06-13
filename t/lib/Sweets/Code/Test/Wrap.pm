package Sweets::Code::Test::Wrap;

package Sweets::Code::Test::Wrap::PreRun;

use strict;
use warnings;
use parent 'Sweets::Code::Binding';

sub pre_run {
    my $code = shift;
    my $self = shift;
    my ( $arg ) = @_;
    [ $arg, 'pre_run' ];
}

package Sweets::Code::Test::Wrap::PostRun;

use strict;
use warnings;
use parent 'Sweets::Code::Binding';

sub post_run {
    my $code = shift;
    my $result = shift;
    my $self = shift;
    my ( $arg ) = @_;
    [ @$result, $arg, 'post_run' ];
}

1;
__END__
