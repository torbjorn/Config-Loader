#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Test::Deep;
use Config::Loader qw( File );

my $tests = [
    {
        name => "File Loads File",
        line => __LINE__,
        put => {
            file => "t/etc/config",
        },
        get => {
            foo => "bar",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        files_loaded => [qw(t/etc/config.perl)],
    },
    {
        name => "File with invalid file returns {}",
        line => __LINE__,
        put => { file => "/invalid/path" },
        get => { },
        files_loaded => [],
    },
];

for my $test ( @{ $tests } ) {
    # Functional
    is_deeply( get_config( %{ $test->{put} } ), $test->{get},$test->{name}.' from line '.$test->{line} );
    # OO
    my $o = Config::Loader->new_source( 'File', %{ $test->{put} }  );
    is_deeply(
        $o->load_config,
        $test->{get},
        $test->{name}.' from line '.$test->{line}
    );
    cmp_deeply(
        $o->files_loaded,
        bag( @{ $test->{files_loaded} } ),
        $test->{name}.' from line '.$test->{line}.', files loaded'
    );
}

done_testing;
