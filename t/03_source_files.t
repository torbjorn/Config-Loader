#!/usr/bin/perl

use warnings;
use strict;
use Config::Loader qw(Files);
use Test::More;
use Test::Deep;

{
    package Config::Loader::Source::FilesTest;

    use Moo;
    extends 'Config::Loader::Source::Profile::Default';
    with 'Config::Loader::SourceRole::FileHelper';

}

my $tests = [
    {
        title => "Many conf files",
        files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
        true_file_names => [qw(t/etc/config.perl t/etc/stem1.conf t/etc/stem1.pl)],
        get => {
            foo => "bar",
            baz => "test",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        line    => __LINE__,
    },
    {
        title => "One conf file",
        files => [qw(t/etc/config)],
        true_file_names => [qw(t/etc/config.perl)],
        get => {
            foo => "bar",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        line    => __LINE__,
    },
    {
        title => "File without file returns {}",
        files => [ ],
        true_file_names => [ ],
        get => { },
        line    => __LINE__,
    },
    {
        title => "File with invalid file returns {}",
        files => ["/invalid/path"],
        true_file_names => [ ],
        get => { },
        line    => __LINE__,
    },
];

for my $test (@$tests) {

    my @files = @{$test->{files}};

    my @variations = (
        { args => [  files   => \@files ], title => "plain hash" },
        { args => [ {files   => \@files} ], title => "hash ref" },
        { args => [  sources => [ map [ File => { file => $_ } ], @files ] ], title => "with sources" },
        { args => [ {sources => [ map [ File => { file => $_ } ], @files ] } ], title => "with sources hashref" },
    );

    my $expected_sources = $variations[3]->{args}[0]{sources};
    my $expected_config = $test->{get};

    subtest $test->{title}.' from line '.$test->{line} => sub {

        for my $variation (@variations) {

            my @args = @{$variation->{args}};

            ## OO - try to fit this into the for loop above
            my $o = Config::Loader->new_source("FilesTest",@args);

            is_deeply(
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
last;
        }

    }


}

done_testing;
