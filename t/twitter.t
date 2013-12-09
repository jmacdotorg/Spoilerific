#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Spoilerific::Schema::Result::Post;

use FindBin;
use lib (
    "$FindBin::Bin/lib",
    "$FindBin::Bin/../lib",
);
use SpoilerificTest;


cmp_ok ( Spoilerific::Schema::Result::Post->url_length,
         '>',
        10,
        "url_length is not weirdly small"
    );

cmp_ok ( Spoilerific::Schema::Result::Post->url_length,
         '<',
        30,
        "url_length is not weirdly large",
    );


done_testing();
