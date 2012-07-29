package Sweets::Text::NanoTemplate;

use strict;
use warnings;

use Any::Moose;
use Sweets::String qw(trim);
use Try::Tiny;

has prefix => ( is => 'rw', isa => 'Str' );
has block_handlers => ( is => 'rw', isa => 'HashRef[Code]', default => sub { {} } );
has function_handlers => ( is => 'rw', isa => 'HashRef[Code]', default => sub { {} } );
has block_tags_regex => ( is => 'rw', isa => 'RegexpRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my $tags = join( '|', sort { length($a) <=> length($b) } grep { $_ } keys %{$self->block_handlers} );
    qr/$tags/;
});
has function_tags_regex => ( is => 'rw', isa => 'RegexpRef', lazy_build => 1, builder => sub {
    my $self = shift;
    my $tags = join( '|', sort { length($a) <=> length($b) } grep { $_ } keys %{$self->function_handlers} );
    qr/$tags/;
});
has raw_args => ( is => 'rw', isa => 'Str' );
has hash_args => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has array_args => ( is => 'rw', isa => 'ArrayRef', default => sub { [] } );
has stash_store => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has template => ( is => 'rw', isa => 'Str' );
has error => ( is => 'rw', isa => 'Str' );

sub handles_block {
    my $self = shift;
    my %handlers = @_;
    while ( my ( $name, $code ) = each %handlers ) {
        Carp::confess('Handler must have name and code reference')
            if !$name || ref $code ne 'CODE';
        $self->block_handlers->{$name} = $code;
        $self->clear_block_tags_regex;
    }
    $self;
}

sub handles_function {
    my $self = shift;
    my %handlers = @_;
    while ( my ( $name, $code ) = each %handlers ) {
        Carp::confess('Handler must have name and code reference')
            if !$name || ref $code ne 'CODE';
        $self->function_handlers->{$name} = $code;
        $self->clear_function_tags_regex;
    }
    $self;
}

sub stash {
    my $self = shift;
    my ( $name, $value ) = @_;
    $self->stash_store->{$name} = $value if defined $value;
    $self->stash_store->{$name};
}

sub parse_attributes {
    my $self = shift;
    my ( $args ) = @_;

    my @array;
    my %hash;
    while ( $args =~ /\s*(?:([^\s=]+)\s*=\s*)?(?:([^"'][^\s]+)|(["'])(.*?)(?<!\\)(\3))\s*/isg ) {
        my $name = $1 || '';
        my $q = $3;
        my $value = $2 || $4;
        $value =~ s/\\$q/$q/g if $q;

        push @array, $name? { name => $name, value => $value }: $value;
        $hash{$name} = $value;
    }

    ( \%hash, \@array );
}

sub render {
    my $self = shift;
    my ( $source ) = @_;

    my $prefix = $self->prefix || Carp::confess('Required prefix to render nano template');

    unless ( $source ) {
        # Start to render
        $source = $self->template || '';
        $self->error('');
    }

    try {
        my $process = sub {
            my ( $before, $tag, $raw_args, $inner ) = @_;

            if ( $inner && $inner =~ m!<$prefix:$tag(\s+[^>]*>|>)!is ) {
                $self->error("<$prefix:$tag> is nested.");
                return;
            }

            my ( $hash, $array ) = $self->parse_attributes($raw_args);
            $self->raw_args($raw_args);
            $self->hash_args($hash);
            $self->array_args($array);

            if ( my $block_handler = $self->block_handlers->{$tag} ) {
                return $block_handler->($self, $hash, $inner);
            } elsif ( my $function_handler = $self->function_handlers->{$tag} ) {
                return $function_handler->($self, $hash);
            } else {
                # Unknown handler.
                $self->error("Unknown tag <$prefix:$tag>.");
                return;
            }
        };

        my $blocks = $self->block_tags_regex;
        my $functions = $self->function_tags_regex;

        $source =~ s/(?:<$prefix:($blocks)(\s+.*?|\s*?)>(.*?)<\/$prefix:\1(\s+.*?|\s*?)>)|(?:<$prefix:($functions)(\s+.*?|\s*?)\/?>)/{
            my $original = $&;
            my $partial;
            if ( $1 ) {
                $partial = $process->($`, $1, $2, $3);
            } elsif ( $5 ) {
                $partial = $process->($`, $5, $6);
            }
            defined $partial? $partial: $original;
        }/isge;

    } catch {
        $self->error($_);
        return undef;
    };

    $source;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
