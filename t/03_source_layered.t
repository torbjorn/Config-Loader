#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Config::Loader;

use Data::Dumper;


my $tests = [
    {
        title => "File Loads File",
        put => {
            sources => [ [ 'File', { file => "t/etc/config" } ] ],
        },
        get => {
            foo => "bar",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        line    => __LINE__,
    },
    {
        title => "File is put in sources and loads File",
        put => {
            File => { file => "t/etc/config" },
        },
        get => {
            foo => "bar",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        line    => __LINE__,
    },
    {
        title => "File without file returns {}",
        put => { },
        get => { },
        line    => __LINE__,
    },
    {
        title => "File with invalid file returns {}",
        put => { File => { file => "/invalid/path" } },
        get => { },
        line    => __LINE__,
    },
];

for my $test ( @{ $tests } ) {

    # Fn
    is_deeply(
        get_config( %{ $test->{put} }, getopts_argv_key => undef ),
        $test->{get},
        sprintf( "Line %d: %s (Fn)", $test->{line}, $test->{title} ),
    );

   # OO
   is_deeply(
       Config::Loader->new_source( 'Profile::Default', $test->{put} )->load_config,
       $test->{get},
       sprintf( "Line %d: %s (OO)", $test->{line}, $test->{title} ),
   );
}

done_testing;
