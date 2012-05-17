use strict;
use warnings;

use Sweets::Variant;
use Test::More tests => 10;

my $backup = Sweets::Variant->new({
    a => 1,
    c => {
        d => 2,
    },
    b => 3,
});

{
    my $yaml = $backup->_to_yaml;

    my $restore = Sweets::Variant->new->_from_yaml($yaml);
    is $restore->a->_scalar, 1;
    is $restore->c->d->_scalar, 2;

    my $class_method = Sweets::Variant->_from_yaml($yaml);
    is $class_method->a->_scalar, 1;
    is $class_method->c->d->_scalar, 2;
}

{
    my $file = 'backup.yaml';
    $backup->_save_yaml($file);

    my $restore = Sweets::Variant->new->_load_yaml($file);
    is $restore->a->_scalar, 1;
    is $restore->c->d->_scalar, 2;

    my $class_method = Sweets::Variant->_load_yaml($file);
    is $class_method->a->_scalar, 1;
    is $class_method->c->d->_scalar, 2;

    unlink $file;
}

{
    my $scalar = Sweets::Variant->new(1);
    my $yaml = $scalar->_to_yaml;
    my $restore = Sweets::Variant->_from_yaml($yaml);
    is_deeply $restore->_raw, $scalar->_raw;
}

{
    my $array = Sweets::Variant->new([1,2,3]);
    my $yaml = $array->_to_yaml;
    my $restore = Sweets::Variant->_from_yaml($yaml);
    is_deeply $restore->_raw, $array->_raw;
}
