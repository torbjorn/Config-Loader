#!/usr/bin/perl

use warnings;
use strict;
use Test::More;
use Test::Deep;

use Config::Loader;

{
    package FileLocalSuffixTest;

    use Moo;
    extends 'Config::Loader::Source::Profile::Default';
    with 'Config::Loader::SourceRole::FileLocalSuffix';
    with 'Config::Loader::SourceRole::FileHelper';

}

my $tests = [

    {
        title => "Vanilla find _local file",
        files => [qw(t/etc/myapp)],
        expected_files => [qw(t/etc/myapp t/etc/myapp_local)],
        true_file_names => [qw(t/etc/myapp.conf t/etc/myapp_local.conf)],
        get => {
            name => "MyApp",
            foo => "not bar after all!",
        },
        line    => __LINE__,
    },

    # {
    #     title => "Many conf files",
    #     files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
    #     true_file_names => [qw(t/etc/config.perl t/etc/stem1.conf t/etc/stem1.pl)],
    #     get => {
    #         foo => "bar",
    #         baz => "test",
    #         blee => "baz",
    #         bar => [ "this", "that" ],
    #     },
    #     line    => __LINE__,
    # },

    # {
    #     title => "File without file returns {}",
    #     files => [ ],
    #     true_file_names => [ ],
    #     get => { },
    #     line    => __LINE__,
    # },
    # {
    #     title => "File with invalid file returns {}",
    #     files => ["/invalid/path"],
    #     true_file_names => [ ],
    #     get => { },
    #     line    => __LINE__,
    # },

];

for my $test (@$tests) {

    my @files = @{$test->{files}};

    my @variations = (
        # { args => [  files   => \@files ], title => "plain hash" },
        # { args => [ {files   => \@files} ], title => "hash ref" },
        # { args => [  sources => [ map [ File => { file => $_ } ], @files ] ], title => "with sources" },
        { args => [ {sources => [ map [ File => { file => $_ } ], @files ] } ], title => "with sources hashref" },
    );

    my @expected_files = @{$test->{expected_files}};

    my $expected_sources = [ map [ File => { file => $_ } ], @expected_files ];
    my $expected_config = $test->{get};

    subtest $test->{title}.' at line '.$test->{line} => sub {

        for my $variation (@variations) {

            my @args = @{$variation->{args}};

            ## OO - try to fit this into the for loop above
            my $o = Config::Loader->new_source("+FileLocalSuffixTest",@args);

            $o->loader; ## trigger _build_loader

            cmp_deeply(
                $o->sources, $expected_sources,
                $variation->{title}.': sources correct setup from input (OO)'
            );

            is_deeply(
                $o->load_config,
                $expected_config,
                $variation->{title}.': config loaded (OO)',
            );

            # note explain $o->source_objects->[1]->files_loaded;

            cmp_deeply(
                [$o->files_loaded],
                bag( grep -e, @{$test->{true_file_names}} ),
                "files loaded"
            );

        }

    }


}

done_testing;
