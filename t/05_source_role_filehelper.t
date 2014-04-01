#!/usr/bin/perl

use warnings;
use strict;
use Test::More;
use Test::Deep;
use Config::Loader;

{
    package Config::Loader::Source::FilesTest;

    use Moo;
    extends 'Config::Loader::Source::Profile::Default';
    with 'Config::Loader::SourceRole::FileHelper';

}

my $tests = do 't/share/test_data_for_filehelper.pl';

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

            cmp_deeply(
                [$o->files_loaded],
                bag( grep -e, @{$test->{true_file_names}} ),
                "files loaded"
            );

        }

    }


}

done_testing;
