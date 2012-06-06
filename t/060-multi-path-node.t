use strict;
use warnings;

use Test::More;
use Sweets::Tree::MultiPath::Node;

my $root = Sweets::Tree::MultiPath::Node->new(
    names => { first => 'root', second => 'ROOT' },
    order => 1,
);

my $child1 = Sweets::Tree::MultiPath::Node->new(
    names => { first => 'child1', second => 'CHILD1' },
    order => 1,
);
$root->add($child1);

my $child2 = Sweets::Tree::MultiPath::Node->new(
    names => { first => 'child2', second => 'CHILD2' },
    order => 2,
);
$root->add($child2);

my $child11 = Sweets::Tree::MultiPath::Node->new(
    names => { first => 'child11', second => 'CHILD11' },
    order => 2,
);
$child1->add($child11);

my $child12 = Sweets::Tree::MultiPath::Node->new(
    names => { first => 'child12', second => 'CHILD12' },
    order => 1,
);
$child1->add($child12);

my $child13 = Sweets::Tree::MultiPath::Node->new(
    names => { first => 'child13', second => 'CHILD13' },
    order => 3,
);
$child1->add($child13);

my $no_child11_filter = sub {
    my ( $name, $node ) = @_;
    $name ne 'child11' && $node->name('first') ne 'child11';
};

{
    $root->name('third', 'Root');
    is $root->name('third'), 'Root';
}

{
    is $root->depth, 0;
    is $child1->depth, 1;
    is $child11->depth, 2;
}

{
    my $first = $child1->name('first');
    is $first, 'child1';

    my $second = $child1->name('second');
    is $second, 'CHILD1';
}

{
    my $found = $root->find('first', 'child1');
    is $found, $child1;

    $found = $root->find('first', 'child1', 'child11');
    is $found, $child11;

    $found = $child1->find('first', 'child12');
    is $found, $child12;

    $found = $root->find('second', 'CHILD1');
    is $found, $child1;

    $found = $root->find('second', 'CHILD1', 'CHILD11');
    is $found, $child11;

    $found = $child1->find('second', 'CHILD12');
    is $found, $child12;
}

{
    my $parents = $child11->parents;
    is_deeply $parents, [ $child1, $root ];

    my $parents_and_self = $child11->parents_and_self;
    is_deeply $parents_and_self, [ $child11, $child1, $root ];

    my $path = $child11->build_path('first', '/');
    is $path, 'root/child1/child11';

    $path = $child11->build_path('second', '-');
    is $path, 'ROOT-CHILD1-CHILD11';
}

{
    my $children = $root->children('first');
    is_deeply $children, { child1 => $child1, child2 => $child2 };

    $children = $root->children('second');
    is_deeply $children, { CHILD1 => $child1, CHILD2 => $child2 };

    $children = $child1->children('first', $no_child11_filter);
    is_deeply $children, { child12 => $child12, child13 => $child13 };
}

{
    my $children = $root->sorted_children('first');
    is_deeply $children, [ $child1, $child2 ];

    $children = $child1->sorted_children('second');
    is_deeply $children, [ $child12, $child11, $child13 ];

    $children = $child1->sorted_children('first', $no_child11_filter);
    is_deeply $children, [ $child12, $child13 ];
}

{
    my $next = $child12->next_sibling('first');
    is $next, $child11;

    my $undefined = $child13->next_sibling('first');
    ok !defined $undefined;

    my $prev = $child11->prev_sibling('first');
    is $prev, $child12;

    $undefined = $child12->prev_sibling('first');
    ok !defined $undefined;

    my $filtered = $child12->next_sibling('first', $no_child11_filter);
    is $filtered, $child13;
}

{
    my $new_child = Sweets::Tree::MultiPath::Node->new(
        names => { 'first' => 'child2', 'third' => 'Child2' },
        order => 1,
    );

    $root->add($new_child);

    my $found = $root->find('first', 'child2');
    is $found, $new_child;

    $found = $root->find('third', 'Child2');
    is $found, $new_child;

    $found = $root->find('second', 'CHILD2');
    ok !defined($found);
}

{
    $child12->remove;

    my $found = $child1->find('first', 'child12');
    ok !defined $found;

    $found = $child1->find('second', 'CHILD12');
    ok !defined $found;
}

done_testing;
