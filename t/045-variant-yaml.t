use strict;
use warnings;

use Sweets::Variant;
use Test::More;

my $backup = Sweets::Variant->new({
    a => 1,
    c => {
        d => 2,
    },
    b => 3,
});

{
    my $yaml = $backup->to_yaml;

    my $restore = Sweets::Variant->new->from_yaml($yaml);
    is $restore->find('a')->as_scalar, 1;
    is $restore->find(qw/c d/)->as_scalar, 2;

    my $class_method = Sweets::Variant->from_yaml($yaml);
    is $class_method->find(qw/a/)->as_scalar, 1;
    is $class_method->find(qw/c d/)->as_scalar, 2;
}

{
    my $file = 'backup.yaml';
    $backup->save_yaml($file);

    my $restore = Sweets::Variant->new->load_yaml($file);
    is $restore->find(qw/a/)->as_scalar, 1;
    is $restore->find(qw/c d/)->as_scalar, 2;

    my $class_method = Sweets::Variant->load_yaml($file);
    is $class_method->find(qw/a/)->as_scalar, 1;
    is $class_method->find(qw/c d/)->as_scalar, 2;

    unlink $file;
}

{
    my $scalar = Sweets::Variant->new(1);
    my $yaml = $scalar->to_yaml;
    my $restore = Sweets::Variant->from_yaml($yaml);
    is_deeply $restore->raw, $scalar->raw;
}

{
    my $array = Sweets::Variant->new([1,2,3]);
    my $yaml = $array->to_yaml;
    my $restore = Sweets::Variant->from_yaml($yaml);
    is_deeply $restore->raw, $array->raw;
}

{
    my $override = Sweets::Variant->new({
        a => 1,
        b => {
            c => 2,
        },
    });

    $override->merge_hash({
        a => 2,
        b => {
            d => 3,
        },
    });

    is $override->find(qw/a/)->as_scalar, 2;
    is $override->find(qw/b c/)->as_scalar, 2;
    is $override->find(qw/b d/)->as_scalar, 3;
}

{
    my $no_override = Sweets::Variant->new({
        a => 1,
        b => {
            c => 2,
        },
    });

    $no_override->merge_hash({
        a => 2,
        b => {
            d => 3,
        },
    }, 0);

    is $no_override->find(qw/a/)->as_scalar, 1;
    is $no_override->find(qw/b c/)->as_scalar, 2;
    is $no_override->find(qw/b d/)->as_scalar, 3;
}

done_testing;
