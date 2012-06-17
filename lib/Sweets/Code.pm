package Sweets::Code;

use strict;
use warnings;

use Any::Moose;
use Sweets::Package;

has code => ( is => 'rw', isa => 'Any', default => 'sub {}', required => 1 );
has ref => ( is => 'rw', isa => 'CodeRef' );

sub BUILD {
    shift->_eval_code;
}

sub _eval_code {
    my $self = shift;
    my $code = $self->code;

    if ( ref $code eq 'CODE' ) {
        $self->ref($code);
        return;
    }

    if ( $code =~ /^\s*sub\s*\{/s ) {
        $self->ref(eval $code or Carp::confess("failed evaluation code $@\n$code"));
        return;
    }

    if ( $code =~ /^([\w+:]+)->(\w+)$/ ) {
        my $pkg = $1;
        my $method = $2;

        Sweets::Package->require($pkg);
        Carp::confess("$pkg can not run $method") unless $pkg->can($method);

        $self->ref( sub {
            $pkg->$method(@_);
        } );
        return;
    }

    if ( $code =~ /^([\w+:]+)::(\w+)$/ ) {
        my $pkg = $1;
        my $method = $2;

        Sweets::Package->require($pkg);
        Carp::confess("$pkg can not run $method") unless $pkg->can($method);

        my $ref = \&$code;
        Carp::confess("$code is not subroutine") if !$ref || ref $ref ne 'CODE';
        $self->ref($ref);
        return;
    }

    Carp::confess("$code is not valid code");
}

after 'code' => sub {
    my $self = shift;
    return unless @_;
    $self->_eval_code;
};

sub run {
    my $ref = shift->ref;
    Carp::confess("tried to run not a code ref") if ref $ref ne 'CODE';
    if (wantarray) {
        my @result = $ref->(@_);
        return @result;
    }
    $ref->(@_);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
