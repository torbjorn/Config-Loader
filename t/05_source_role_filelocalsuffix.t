#!/usr/bin/perl

use warnings;
use strict;
use Test::More;
use Test::Deep;

use Config::Loader;

{
    package FileLocalSuffixTest;

    use Moo;
    use namespace::clean;
    extends 'Config::Loader::Source::Profile::Default';

    ## need this for test with other roles
    has name => ( is => "ro" );
}

use t::lib::TestUtils;

require Moo::Role;

my $tests = do 't/share/test_data_for_filelocalsuffix.pl';

for my $test (@$tests) {

    my $test_obj = TestData->new($test);
    my @files = @{ $test_obj->files };

    my %args = %{ $test_obj->args };
    $args{no_env} = 1;

    my @expected_files = @{$test_obj->expected_files};

    my $expected_sources = $test_obj->sources_from("expected_files");
    my $expected_config = $test->{get};

    my $obj_gen = sub {

            my $roles = shift;

            $args{sources} = $test_obj->sources_from("files");

            for (@$roles) {
                if ( !/^Config::Loader::SourceRole::/ ) {
                    $_ = "Config::Loader::SourceRole::" . $_;
                }
            }

            my $cl = Moo::Role->create_class_with_roles(
                "FileLocalSuffixTest",
                @$roles,
            );

            my $o = $cl->new(%args);

            return $o;

        };

    my @roles_to_test = permute_roles_except("FileLocalSuffix");

    subtest 'Test data at line '.$test->{line} => sub {

        for my $roles ( @roles_to_test ) {

            my $roles_text = join ", ", map { s/.*:://; $_ } @$roles;
            note "Testing with role combination: $roles_text";

            my $o = $obj_gen->($roles);

            ok( $o );

            $o->loader; # trigger _build_loader that injects _local files

            cmp_deeply(
                $o->sources, $expected_sources,
                $test_obj->test_text( 'sources correct setup from input (OO)' )
            );

            is_deeply(
                $o->load_config,
                $expected_config,
                $test_obj->test_text( 'config loaded (OO)' ),
            );

            my @files_actually_loaded =
                map { @{$_->files_loaded} }
                grep { $_->isa("Config::Loader::Source::File") }
                @{ $o->loader->source->source_objects };

            cmp_deeply(
                [@files_actually_loaded],
                bag( grep -e, @{$test->{true_file_names}} ),
                $test_obj->test_text( 'files loaded' )
            );

        }

    };

}

done_testing;
