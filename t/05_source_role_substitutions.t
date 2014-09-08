#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;
use Test::Most;
use Test::Warnings;

use Config::Loader::Source::Static;
use Config::Loader::Source::Filter::Substitution;

my $static = Config::Loader::Source::Static->new(
    config => {
        foo => '__bar(5)__'
    }
);

ok( my $s = Config::Loader::Source::Filter::Substitution->new(source=>$static),
    'object creation'
);

$s->substitute(
    bar => sub { $_[1] + 10 }
);

cmp_deeply(
    $s->load_config,
    { foo => 15 },
    "very simple test case"
);

done_testing;