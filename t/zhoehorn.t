#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;
use Test::Most;
use Test::FailWarnings;

use Config::Loader::Shoehorn::ZOMG;

ok( Config::ZOMG::Source::Loader::file_extension(
    "foo.bar"), "foo.bar has extension"
);
ok( !Config::ZOMG::Source::Loader::file_extension(
    "foo"), "foo does not"
);

done_testing;
