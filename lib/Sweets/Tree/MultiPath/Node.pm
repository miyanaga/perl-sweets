package Sweets::Tree::MultiPath::Node;

use strict;
use warnings;

use Any::Moose;

our $DEFAULT_ORDER = 1000;
our $DEFAULT_NS = '';
our $DEFAULT_SEPARATOR = '/';

has parent => ( is => 'rw', isa => 'Sweets::Tree::MultiPath::Node' );
has namespaces => ( is => 'ro', isa => 'HashRef', default => sub { {} } );
has order => ( is => 'rw', isa => 'Int', default => sub { $DEFAULT_ORDER } );
has names => ( is => 'rw', isa => 'HashRef', default => sub { {} } );
has depth => ( is => 'rw', isa => 'Int', lazy_build => 1, builder => sub {
    my $parent = shift->parent || return 0;
    $parent->depth + 1;
});

sub name {
    my $self = shift;
    my ( $ns, $value ) = @_;
    $ns ||= $DEFAULT_NS;
    $self->names->{$ns} = $value if defined $value;
    $self->names->{$ns};
}

sub children {
    my $self = shift;
    my ( $ns, $filter ) = @_;
    $ns ||= $DEFAULT_NS;
    my $children = $self->namespaces->{$ns};
    return if ref $children ne 'HASH';

    my %children = map {
        $_ => $children->{$_}
    } grep {
        defined $filter && ref $filter eq 'CODE'
            ? $filter->($_, $children->{$_})
            : 1;
    } keys %$children;

    \%children;
}

sub find {
    my $self = shift;
    my $ns = shift;
    $ns ||= $DEFAULT_NS;
    my $name = shift;
    return $self unless defined $name;

    if ( my $child = $self->namespaces->{$ns}->{$name} ) {
        return $child->find($ns, @_);
    }

    return undef;
}

sub add {
    my $self = shift;
    my ( $node ) = shift;
    die 'add requires Sweets::Tree::MultiPath::Node' unless eval { $node->isa('Sweets::Tree::MultiPath::Node') };

    # Remove duplicated children at first.
    while ( my ($ns, $name) = each %{$node->names} ) {
        if ( my $n = $self->find($ns, $name) ) {
            $n->remove;
        }
    }

    while ( my ($ns, $name) = each %{$node->names} ) {
        $self->namespaces->{$ns}->{$name} = $node;
    }

    $node->parent($self);
}

sub remove {
    my $self = shift;
    return unless defined $self->parent;

    while ( my ($ns, $name) = each %{$self->names} ) {
        delete $self->parent->namespaces->{$ns}->{$name};
    }
}

sub parents {
    my $self = shift;
    my @parents;

    my $p = $self;
    while ( $p = $p->parent ) {
        push @parents, $p;
    }

    wantarray? @parents: \@parents;
}

sub parents_and_self {
    my $self = shift;
    my @parents = $self->parents;
    unshift @parents, $self;

    wantarray? @parents: \@parents;
}

sub parent_at {
    my $self = shift;
    my @traverse = reverse $self->parents_and_self;
    my $depth = int($_[0]);
    $depth = $self->depth + $depth if $depth < 0;
    return undef if $depth < 0;

    $traverse[$depth];
}

sub build_path {
    my $self = shift;
    my ( $ns, $separator ) = @_;
    $ns ||= $DEFAULT_NS;
    $separator = $DEFAULT_SEPARATOR unless defined($separator);
    my @parents = $self->parents_and_self;

    join( $separator, map { $_->name($ns) || '' } reverse @parents );
}

sub sorted_children {
    my $self = shift;

    my @children = sort {
        $a->order <=> $b->order
    } values %{$self->children(@_)};

    wantarray? @children: \@children;
}

sub _sibling {
    my $self = shift;
    my $offset = shift;
    return undef if !defined $self->parent;

    my @siblings = $self->parent->sorted_children(@_);
    for ( my $i = 0; $i < scalar @siblings; $i++ ) {
        if ( $self == $siblings[$i] ) {
            return undef if $i + $offset < 0;
            return $siblings[$i + $offset];
        }
    }

    return undef;
}

sub next_sibling {
    shift->_sibling(1, @_);
}

sub prev_sibling {
    shift->_sibling(-1, @_);
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
