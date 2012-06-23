package Sweets::Helper::HTML;

use strict;
use warnings;

use Any::Moose;
use HTML::Entities;
use URI::Escape;
use JavaScript::Value::Escape;

has xhtml => ( is => 'rw', isa => 'Bool', default => 0 );
has query_delimiter => ( is => 'rw', isa => 'Str', default => ',' );

sub escape_html {
    my $self = shift;
    my ( $html ) = @_;
    HTML::Entities::encode_entities($html);
}

sub escape_url {
    my $self = shift;
    my ( $uri ) = @_;
    uri_escape($uri);
}

sub escape_js {
    my $self = shift;
    my ( $str ) = @_;
    javascript_value_escape($str);
}

sub element {
    my $self = shift;
    my $tag = shift;
    my %args = @_;
    my @html;
    my $attrs = $args{attr} || {};
    my $raw_attrs = $args{raw_attr} || {};
    my $xhtml = $self->xhtml;
    $xhtml = $args{xhtml} if defined $args{xhtml};

    # inner
    my $inner = $args{inner};
    if ( $inner ) {
        Carp::confess('inner must be a code')
            if ref $inner eq '' && ref $inner eq 'CODE';
        $inner = $inner->() if ref $inner eq 'CODE';
    }

    # tag
    Carp::confess('tag must be a scalar') if ref $tag;
    push @html, $tag;

    # id & class
    $attrs->{id} = $args{id} if $args{id};
    $attrs->{class} = ref $args{class} eq 'ARRAY'
        ? join(' ', @{$args{class}})
        : $args{class}
            if $args{class};

    # attributes
    for my $name ( sort { $a eq 'id'? -1: $b eq 'id'? 1: $a eq 'class'? -1: $b eq 'class'? 1: $a cmp $b; } keys %$attrs ) {
        my $value = $attrs->{$name};
        delete $raw_attrs->{$name};
        $value = join(' ', @$value) if ref $value eq 'ARRAY';
        Carp::confess('values in attr must be scalar or array')
            if ref $value;

        push @html, $name . '="' . scalar $value . '"';
    }

    # raw attributes
    for my $name ( sort { $a eq 'id'? -1: $b eq 'id'? 1: $a eq 'class'? -1: $b eq 'class'? 1: $a cmp $b; } keys %$raw_attrs ) {
        my $value = $raw_attrs->{$name};
        $value = join(' ', @$value) if ref $value eq 'ARRAY';
        Carp::confess('values in raw_attr must be scalar or array')
            if ref $value;

        push @html, $name . '="' . $self->escape_html(scalar $value) . '"';
    }

    # xhtml style
    push @html, '/' if $xhtml && !$inner;

    # open tag, inner and close tag.
    my $html = '<' . join(' ', @html) . '>';
    $html .= $inner . '</' . $tag . '>' if $inner;

    $html;
}

sub url {
    my $self = shift;
    my ( $base, $queries, $hash ) = @_;

    $base ||= '';
    if ( ref $queries eq 'HASH' ) {
        my @pairs;
        my $delim = $self->query_delimiter;
        for my $name ( sort { $a cmp $b } keys %$queries ) {
            next unless $name;
            my $value = $queries->{$name};

            $name = $self->escape_url($name);
            push @pairs, ref $value eq 'ARRAY'
                ? join('=', $name, $self->escape_url(join($delim, @$value)))
                : $value && !ref $value
                    ? $name . '=' . $self->escape_url($value)
                    : $name;
        }
        $queries = \@pairs;
    }

    if ( ref $queries eq 'ARRAY' ) {
        $queries = join('&', grep { $_ } @$queries);
    }

    if ( $queries && !ref $queries ) {
        $base .= '?' unless $base =~ /\?/;
        $base .= $queries;
    }

    $base .= '#' . $hash if defined($hash);
    $base;
}

no Any::Moose;
__PACKAGE__->meta->make_immutable;

1;
__END__
