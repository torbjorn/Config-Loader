#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;
use Test::Most;
use Test::FailWarnings;

use Config::Loader;

ok( Config::Loader::_has_extension("foo.bar"), "foo.bar has extension" );
ok( Config::Loader::_has_extension("foo"), "foo does not" );

done_testing;
