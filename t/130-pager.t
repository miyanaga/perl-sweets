use strict;
use warnings;

use Test::More;
use Sweets::Pager;

{
    # Zero based 10 per page
    my $req = Sweets::Pager::Request->new(
        base => 0,
        per_page => 10,
        page => 0,
    );

    is $req->offset, 0;
    $req->page(1);
    is $req->offset, 10;
    $req->page(2);
    is $req->offset, 20;

    $req->page(0);
    my $res = Sweets::Pager::Result->new(
        request => $req,
        count => 5,
    );
    my $windows;

    is $res->pages, 1;
    is $res->last_page, 0;
    is $res->has_next_page, 0;
    is $res->has_previous_page, 0;
    is $res->is_out_of_range, 0;

    $res->page(1);
    is $res->is_out_of_range, 1;

    $res->count(10);
    $res->page(0);
    is $res->pages, 1;
    is $res->last_page, 0;

    $windows = $res->windows(2);
    is_deeply $windows, [[0]];

    $res->count(11);
    is $res->pages, 2;
    is $res->last_page, 1;

    $windows = $res->windows(2);
    is_deeply $windows, [[0,1]];

    $res->count(20);
    is $res->pages, 2;
    is $res->last_page, 1;

    $windows = $res->windows(2);
    is_deeply $windows, [[0,1]];

    $res->count(21);
    is $res->pages, 3;
    is $res->last_page, 2;

    $windows = $res->windows(2);
    is_deeply $windows, [[0,1,2]];

    $res->page(1);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1,2]];

    $res->page(2);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1,2]];

    $res->count(110);
    $res->page(0);
    is $res->pages, 11;
    is $res->last_page, 10;

    $windows = $res->windows(2);
    is_deeply $windows, [[0,1,2,3,4],[9,10]];

    $res->page(1);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1,2,3,4],[9,10]];

    $res->page(2);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1,2,3,4],[9,10]];

    $res->page(3);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1,2,3,4,5],[9,10]];

    $res->page(4);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1,2,3,4,5,6],[9,10]];

    $res->page(5);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1],[3,4,5,6,7],[9,10]];

    $res->page(6);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1],[4,5,6,7,8,9,10]];

    $res->page(7);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1],[5,6,7,8,9,10]];

    $res->page(8);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1],[6,7,8,9,10]];

    $res->page(9);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1],[7,8,9,10]];

    $res->page(10);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1],[8,9,10]];

    $res->page(11);
    $windows = $res->windows(2);
    is_deeply $windows, [[0,1],[8,9,10]];

    $res->page(4);
    $windows = $res->windows(3, 1, 1);
    is_deeply $windows, [[0,1,2,3,4,5,6,7],[10]];

    $res->page(5);
    $windows = $res->windows(3, 1, 1);
    is_deeply $windows, [[0],[2,3,4,5,6,7,8],[10]];

    $res->page(6);
    $windows = $res->windows(3, 1, 1);
    is_deeply $windows, [[0],[3,4,5,6,7,8,9,10]];

}

{
    # One based 5 per page
    my $req = Sweets::Pager::Request->new(
        base => 1,
        per_page => 5,
        page => 1,
    );

    is $req->offset, 0;
    $req->page(2);
    is $req->offset, 5;
    $req->page(3);
    is $req->offset, 10;
}

{
    # One based 10 per page
    my $req = Sweets::Pager::Request->new(
        base => 1,
        per_page => 10,
        page => 1,
    );

    is $req->offset, 0;
    $req->page(2);
    is $req->offset, 10;
    $req->page(3);
    is $req->offset, 20;

    $req->page(1);
    my $res = Sweets::Pager::Result->new(
        request => $req,
        count => 5,
    );
    my $windows;

    is $res->pages, 1;
    is $res->last_page, 1;
    is $res->has_next_page, 0;
    is $res->has_previous_page, 0;
    is $res->is_out_of_range, 0;

    $res->page(2);
    is $res->is_out_of_range, 1;

    $res->count(10);
    $res->page(1);
    is $res->pages, 1;
    is $res->last_page, 1;

    $windows = $res->windows(2);
    is_deeply $windows, [[1]];

    $res->count(11);
    is $res->pages, 2;
    is $res->last_page, 2;

    $windows = $res->windows(2);
    is_deeply $windows, [[1,2]];

    $res->count(20);
    is $res->pages, 2;
    is $res->last_page, 2;

    $windows = $res->windows(2);
    is_deeply $windows, [[1,2]];

    $res->count(21);
    is $res->pages, 3;
    is $res->last_page, 3;

    $windows = $res->windows(2);
    is_deeply $windows, [[1,2,3]];

    $res->page(1);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2,3]];

    $res->page(2);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2,3]];

    $res->count(110);
    $res->page(0);
    is $res->pages, 11;
    is $res->last_page, 11;

    $windows = $res->windows(2);
    is_deeply $windows, [[1,2,3,4,5],[10,11]];

    $res->page(2);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2,3,4,5],[10,11]];

    $res->page(3);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2,3,4,5],[10,11]];

    $res->page(4);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2,3,4,5,6],[10,11]];

    $res->page(5);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2,3,4,5,6,7],[10,11]];

    $res->page(6);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2],[4,5,6,7,8],[10,11]];

    $res->page(7);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2],[5,6,7,8,9,10,11]];

    $res->page(8);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2],[6,7,8,9,10,11]];

    $res->page(9);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2],[7,8,9,10,11]];

    $res->page(10);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2],[8,9,10,11]];

    $res->page(11);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2],[9,10,11]];

    $res->page(12);
    $windows = $res->windows(2);
    is_deeply $windows, [[1,2],[9,10,11]];

    $res->page(5);
    $windows = $res->windows(3, 1, 1);
    is_deeply $windows, [[1,2,3,4,5,6,7,8],[11]];

    $res->page(6);
    $windows = $res->windows(3, 1, 1);
    is_deeply $windows, [[1],[3,4,5,6,7,8,9],[11]];

    $res->page(7);
    $windows = $res->windows(3, 1, 1);
    is_deeply $windows, [[1],[4,5,6,7,8,9,10,11]];

}

done_testing;
