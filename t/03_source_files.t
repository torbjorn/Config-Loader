#!/usr/bin/perl
use warnings;
use strict;
use Config::Loader qw(Files);
use Test::More;

my $tests = [
    {
        title => "Detailed sources",
        files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
        # put => {
        #         sources => [
        #             [ 'File', { file => "t/etc/config" } ],
        #             [ 'File', { file => "t/etc/stem1.conf" } ],
        #             [ 'File', { file => "t/etc/stem1.pl" } ],
        #         ],
        # },
        get => {
            foo => "bar",
            baz => "test",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        line    => __LINE__,
    },
    {
        title => "File without file returns {}",
        files => [ ],
        get => { },
        line    => __LINE__,
    },
    {
        title => "File with invalid file returns {}",
        files => ["/invalid/path"],
        get => { },
        line    => __LINE__,
    },
];

for my $test (@$tests) {

    my @files = @{$test->{files}};

    my @variations = (
        { args => [  files  => \@files ], title => "plain hash" },
        { args => [ {files  => \@files} ], title => "hash ref" },
        { args => [  source => [ map [ File => { file => $_ } ], @files ] ], title => "detailed sources" },
        { args => [ {source => [ map [ File => { file => $_ } ], @files ] } ], title => "detailed sources hashref" },
    );

    my $expected_sources = $variations[3]->{args}[0]{source};
    my $expected_config = $test->{get};

    for my $variation (@variations) {

        my @args = @{$variation->{args}};

        ## OO - try to fit this into the for loop above
        my $o = Config::Loader->new_source("Files",@args);

        is_deeply(
            $o->sources, $expected_sources,
            $test->{title}.' from line '.$test->{line}.', '.$variation->{title}.', sources correct setup from input'
        );

        is_deeply(
            $o->load_config,
            $expected_config,
            $test->{title}.' from line '.$test->{line}.', '.$variation->{title}.', config loaded',
        );

    }

}



# my @files = qw[
#                   t/etc/stem1.conf
#                   t/etc/stem1.pl
#               ];


# ## OO - try to fit this into the for loop above
# isa_ok( my $o = Config::Loader->new_source("Files",files => \@files), "Config::Loader::Source::Files" );
# is_deeply( $o->sources, [ [File => {file=>"t/etc/stem1.conf"}], [File => {file=>"t/etc/stem1.pl"}] ],
#        "sources correct setup from input" );

# is_deeply(
#     $o->load_config,
#     { foo => "bar", baz => "test" },
#     "files read"
# );

done_testing;
