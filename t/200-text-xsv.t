use strict;
use warnings;

use Test::More;
use Sweets::Text::Xsv;

subtest 'Simple' => sub {
    my $source = <<'CSV';
col1,col2,col3
val1-1,val1-2,val1-3
val2-1,val2-2,val2-3
val3'1,val3"2
CSV

    my $csv = Sweets::Text::Xsv->new->parse($source)->rows;
    is_deeply $csv, [
        [ 'col1', 'col2', 'col3' ],
        [ 'val1-1', 'val1-2', 'val1-3' ],
        [ 'val2-1', 'val2-2', 'val2-3' ],
        [ "val3'1", 'val3"2' ],
    ];
};

subtest 'Single Quoted' => sub {
    my $source = <<'CSV';
'col1','col2','col3'
'val1-1','val1-2','val1-3'
'val2-1','val2-2','val2-3'
'val3\'1','val3"2','val3\"3'
CSV

    my $csv = Sweets::Text::Xsv->new->parse($source)->rows;
    is_deeply $csv, [
        [ 'col1', 'col2', 'col3' ],
        [ 'val1-1', 'val1-2', 'val1-3' ],
        [ 'val2-1', 'val2-2', 'val2-3' ],
        [ 'val3\'1', 'val3"2', 'val3\"3' ],
    ];
};

subtest 'Double Quoted' => sub {
    my $source = <<'CSV';
"col1","col2","col3"
"val1-1","val1-2","val1-3"
"val2-1","val2-2","val2-3"
CSV

    my $csv = Sweets::Text::Xsv->new->parse($source)->rows;
    is_deeply $csv, [
        [ 'col1', 'col2', 'col3' ],
        [ 'val1-1', 'val1-2', 'val1-3' ],
        [ 'val2-1', 'val2-2', 'val2-3' ],
    ];
};

subtest 'Broken Quoted' => sub {
    my $source = <<'CSV';
col1,'col2',"col3"
val1-1,'val1-2',"val1-3
CSV

    my $csv = Sweets::Text::Xsv->new->parse($source)->rows;
    is_deeply $csv, [
        [ 'col1', 'col2', 'col3' ],
        [ 'val1-1', 'val1-2', 'val1-3' ],
    ];
};

subtest 'Mixed Quoted' => sub {
    my $source = <<'CSV';
col1,'col2',"col3"
val1-1,'val1-2',"val1-3"
val2-1,'val2-2',"val2-3"
CSV

    my $csv = Sweets::Text::Xsv->new->parse($source)->rows;
    is_deeply $csv, [
        [ 'col1', 'col2', 'col3' ],
        [ 'val1-1', 'val1-2', 'val1-3' ],
        [ 'val2-1', 'val2-2', 'val2-3' ],
    ];
};

subtest 'Empty' => sub {
    my $source = <<'CSV';
col1,'col2',"col3",
,,

val1-1,'val1-2',"val1-3"
CSV

    my $csv = Sweets::Text::Xsv->new->parse($source)->rows;
    is_deeply $csv, [
        [ 'col1', 'col2', 'col3', '' ],
        [ '', '', '' ],
        [ '' ],
        [ 'val1-1', 'val1-2', 'val1-3' ],
    ];
};

subtest 'Mixed Linebreak and separator' => sub {
    my $source = <<'CSV';
col1,'col2',"col3"
val1-1,'val1,2',"val1
3"
val2-1,'val2,,2',"val2

3"
CSV

    my $csv = Sweets::Text::Xsv->new->parse($source)->rows;
    is_deeply $csv, [
        [ 'col1', 'col2', 'col3' ],
        [ 'val1-1', 'val1,2', "val1\n3" ],
        [ 'val2-1', 'val2,,2', "val2\n\n3" ],
    ];
};

subtest 'TSV' => sub {
    my $source = <<'TSV';
col1	'col2'	"col3"
val1-1	'val1	2'	"val1
3"
val2-1	'val2		2'	"val2

3"
val3-1	'val3-2
TSV

    my $tsv = Sweets::Text::Xsv->new( separator => "\t" )->parse($source)->rows;
    is_deeply $tsv, [
        [ 'col1', 'col2', 'col3' ],
        [ 'val1-1', "val1\t2", "val1\n3" ],
        [ 'val2-1', "val2\t\t2", "val2\n\n3" ],
        [ 'val3-1', "val3-2" ],
    ];
};

subtest 'Transform' => sub {
    my $source = <<'CSV';
col1,'col2',"col3"
val1-1,'val1,2',"val1
3"
val2-1,'val2,,2',"val2

3"
CSV

    my $csv = Sweets::Text::Xsv->new->parse($source);
    is_deeply $csv->header, [qw/col1 col2 col3/];
    is_deeply $csv->hash_array, [
        { col1 => 'val1-1', col2 => 'val1,2', col3 => "val1\n3" },
        { col1 => 'val2-1', col2 => 'val2,,2', col3 => "val2\n\n3" },
    ];
};

done_testing;
