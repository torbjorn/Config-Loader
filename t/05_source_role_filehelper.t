#!/usr/bin/perl

use warnings;
use strict;
use Test::More;
use Test::Deep;
use Config::Loader;
use File::Basename;

use t::lib::TestUtils;

{
    package FilesTest;

    use Moo;
    extends 'Config::Loader::Source::Profile::Default';
    with 'Config::Loader::SourceRole::FileHelper';

}

my $tests = do 't/share/test_data_for_filehelper.pl';

for my $test (@$tests) {

    my @files = @{$test->{files}};
    my @args = @{$test->{args}};

    my $expected_sources = [ map [ File => { file => $_ } ], @files ];

    ## OO - try to fit this into the for loop above
    my $o = Config::Loader->new_source("+FilesTest",@args);

    is_deeply(
        $o->sources, $expected_sources,
        test_text( $test, 'sources correct setup from input (OO)' )
    );

    is_deeply(
        $o->load_config,
        $test->{get},
        test_text( $test, 'config loaded (OO)' )
    );

    cmp_deeply(
        [$o->files_loaded],
        bag( grep -e, @{$test->{true_file_names}} ),
        test_text( $test, 'correct files loaded (OO)' )
    );

}

done_testing;
