#!/usr/bin/perl
use warnings;
use strict;
use Config::Loader qw(Files);
use Test::More;

my $tests = [
    {
        title => "Detailed sources",
        put => [
            sources => [
                [ 'File', { file => "t/etc/config" } ],
                [ 'File', { file => "t/etc/stem1.pl" } ],
                [ 'File', { file => "t/etc/stem1.conf" } ],
            ],
        ],
        get => {
            foo => "bar",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        line    => __LINE__,
    },
    {
        title => "File without file returns {}",
        put => [ ],
        get => { },
        line    => __LINE__,
    },
    {
        title => "File with invalid file returns {}",
        put => [ File => { file => "/invalid/path" } ],
        get => { },
        line    => __LINE__,
    },
];

for my $test (@$tests) {



}



my @files = qw[
                  t/etc/stem1.conf
                  t/etc/stem1.pl
              ];


## OO - try to fit this into the for loop above
isa_ok( my $o = Config::Loader->new_source("Files",@files), "Config::Loader::Source::Files" );
is_deeply( $o->sources, [ [File => {file=>"t/etc/stem1.conf"}], [File => {file=>"t/etc/stem1.pl"}] ],
       "sources correct setup from input" );

is_deeply(
    $o->load_config,
    { foo => "bar", baz => "test" },
    "files read"
);

done_testing;
