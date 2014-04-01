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

}

use t::lib::TestUtils;

my $tests = do 't/share/test_data_for_filelocalsuffix.pl';

for my $test (@$tests) {

    my @files = @{$test->{files}};

    my %args = ( sources => [ map [ File => { file => $_ } ], @files ],
             no_local => $test->{no_local} );

    my @expected_files = @{$test->{expected_files}};

    my $expected_sources = [ map [ File => { file => $_ } ], @expected_files ];
    my $expected_config = $test->{get};

    subtest 'Test data at line '.$test->{line} => sub {

        my $o = Config::Loader->new_source("+FileLocalSuffixTest",%args);

        $o->loader; # trigger _build_loader that injects _local files

        cmp_deeply(
            $o->sources, $expected_sources,
            test_text( $test, 'sources correct setup from input (OO)' )
        );

        is_deeply(
            $o->load_config,
            $expected_config,
            test_text( $test, 'config loaded (OO)' ),
        );

        my @files_actually_loaded =
            map { @{$_->files_loaded} }
                grep { $_->isa("Config::Loader::Source::File") }
                    @{ $o->loader->source->source_objects };

        cmp_deeply(
            [@files_actually_loaded],
            bag( grep -e, @{$test->{true_file_names}} ),
            test_text( $test, "files loaded" )
        );

    }


}

done_testing;
