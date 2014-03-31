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

my $tests = [

    # {
    #     line    => __LINE__,
    #     title => "Vanilla find _local file from stem",
    #     files => [qw(t/etc/myapp)],
    #     expected_files => [qw(t/etc/myapp t/etc/myapp_local)],
    #     true_file_names => [qw(t/etc/myapp.conf t/etc/myapp_local.conf)],
    #     get => {
    #         name => "MyApp",
    #         foo => "not bar after all!",
    #     },
    #     no_local => 0,
    # },

    # {
    #     line    => __LINE__,
    #     title => "Don't find _local file from stem",
    #     files => [qw(t/etc/myapp)],
    #     expected_files => [qw(t/etc/myapp)],
    #     true_file_names => [qw(t/etc/myapp.conf)],
    #     get => {
    #         name => "MyApp",
    #         foo => "bar",
    #     },
    #     no_local => 1,
    # },




    # {
    #     line    => __LINE__,
    #     title => "File with ext and _local",
    #     files => [qw(t/etc/myapp.conf)],
    #     expected_files => [qw(t/etc/myapp.conf t/etc/myapp_local.conf)],
    #     true_file_names => [qw(t/etc/myapp.conf t/etc/myapp_local.conf)],
    #     get => {
    #         name => "MyApp",
    #         foo => "not bar after all!",
    #     },
    #     no_local => 0,
    # },

    # {
    #     line    => __LINE__,
    #     title => "File with ext and NO _local",
    #     files => [qw(t/etc/myapp.conf)],
    #     expected_files => [qw(t/etc/myapp.conf)],
    #     true_file_names => [qw(t/etc/myapp.conf)],
    #     get => {
    #         name => "MyApp",
    #         foo => "bar",
    #     },
    #     no_local => 1,
    # },



    # {
    #     line    => __LINE__,
    #     title => "Many conf files",
    #     files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
    #     expected_files => [qw(
    #                              t/etc/config
    #                              t/etc/stem1.conf
    #                              t/etc/stem1.pl

    #                              t/etc/config_local
    #                              t/etc/stem1_local.conf
    #                              t/etc/stem1_local.pl
    #                      )],

    #     true_file_names => [qw(
    #                               t/etc/config.perl
    #                               t/etc/stem1.conf
    #                               t/etc/stem1.pl

    #                               t/etc/config_local.perl
    #                               t/etc/stem1_local.conf
    #                               t/etc/stem1_local.pl
    #                       )],
    #     get => {
    #         foo => "bar",
    #         baz => "test",
    #         blee => "baz",
    #         bar => [ "this", "that" ],
    #     },
    #     no_local => 0,
    # },


    # {
    #     line    => __LINE__,
    #     title => "Many conf files",
    #     files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
    #     expected_files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
    #     true_file_names => [qw(t/etc/config.perl t/etc/stem1.conf t/etc/stem1.pl)],
    #     get => {
    #         foo => "bar",
    #         baz => "test",
    #         blee => "baz",
    #         bar => [ "this", "that" ],
    #     },
    #     no_local => 1,
    # },





    # {
    #     line    => __LINE__,
    #     title => "File without file returns {}",
    #     files => [ ],
    #     expected_files => [ ],
    #     true_file_names => [ ],
    #     get => { },
    #     no_local => 0,
    # },
    # {
    #     line    => __LINE__,
    #     title => "File without file returns {}",
    #     files => [ ],
    #     expected_files => [ ],
    #     true_file_names => [ ],
    #     get => { },
    #     no_local => 1,
    # },



    {
        line    => __LINE__,
        title => "File with invalid file returns {}",
        files => ["/invalid/path"],
        expected_files => [qw(/invalid/path /invalid/path_local)],
        true_file_names => [ ],
        get => { },
        no_local => 0,
    },

    {
        line    => __LINE__,
        title => "File with invalid file returns {} - no local",
        files => [qw(/invalid/path)],
        expected_files => [qw(/invalid/path)],
        true_file_names => [ ],
        get => { },
        no_local => 1,
    },

];

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
            'sources correct setup from input (OO)'
        );

        is_deeply(
            $o->load_config,
            $expected_config,
            'config loaded (OO)',
        );


        my @files_loaded =
            map { @{$_->files_loaded} }
                grep { $_->isa("Config::Loader::Source::File") }
                    @{ $o->loader->source->source_objects };

        cmp_deeply(
            [@files_loaded],
            bag( grep -e, @{$test->{true_file_names}} ),
            "files loaded"
        );

    }


}

done_testing;
