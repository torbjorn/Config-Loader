#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Test::Deep;
use Test::Warnings;
use Config::Loader qw( FileWithLocal );

my $tests = [

    {
        datafile => __FILE__,
        line    => __LINE__,
        name => "Vanilla find _local file from stem",
        get => {
            name => "MyApp",
            foo => "not bar after all!",
        },
        put => ["t/etc/myapp"],
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        name => "Don't find _local file from stem",
        get => {
            name => "MyApp",
            foo => "bar",
        },
        put => {
            file => "t/etc/myapp",
            no_local => 1,
        }
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        name => "File with ext and _local",
        get => {
            name => "MyApp",
            foo => "not bar after all!",
        },
        put => ["t/etc/myapp.conf"],
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        name => "File with ext and NO _local",
        get => {
            name => "MyApp",
            foo => "bar",
        },
        put => {
            file => "t/etc/myapp.conf",
            no_local => 1,
        }
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        name => "File without file returns {}",
        get => { },
        put => { },
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        name => "File without file returns {} - no local",
        get => { },
        put => { no_local => 1 },
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        name => "File with invalid file returns {}",
        get => { },
        put => ["/invalid/path"],
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        name => "File with invalid file returns {} - no local",
        get => { },
        put => {
            file => "/invalid/path",
            no_local => 1,
        }
    },

];

for my $test ( @{ $tests } ) {

    $test->{put} //= {};
    my @args = ref $test->{put} eq "ARRAY" ? @{$test->{put}} : %{$test->{put}};

    # Functional
    # is_deeply( get_config( %{ $test->{put} } ), $test->{get},$test->{name}.' from line '.$test->{line} );
    # OO

    my $o = Config::Loader->new_source( 'FileWithLocal', @args );

    is_deeply(
        $o->load_config,
        $test->{get},
        $test->{name}.' from line '.$test->{line}
    );

}

done_testing;
