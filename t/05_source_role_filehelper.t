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

    ## need this for some of the roles
    has name => (is => "ro");

}

require Moo::Role;

my $tests = do 't/share/test_data_for_filehelper.pl';

for my $test (@$tests) {

    my $test_obj = TestData->new($test);
    my @args = @{ $test_obj->args };

    ## make sure we don't test for stuff in other roles
    push @args, no_env => 1, no_local => 1;

    my $obj_gen = sub {

            my $roles = shift;

            for (@$roles) {
                if ( !/^Config::Loader::SourceRole::/ ) {
                    $_ = "Config::Loader::SourceRole::" . $_;
                }
            }

            my $cl = Moo::Role->create_class_with_roles(
                "FilesTest",
                @$roles,
            );

            my $o = $cl->new(@args);

        };

    my @roles_to_test = permute_roles_except("FileHelper");

    subtest 'Test data at line '.$test_obj->line => sub {

        for my $roles ( @roles_to_test ) {

            my $roles_text = join ", ", map { s/.*:://; $_ } @$roles;
            note "Testing with role combination: $roles_text";

            my $o = $obj_gen->($roles);

            cmp_deeply(
                $o->load_config,
                $test_obj->get,
                $test_obj->test_text( 'config loaded (OO)' )
            );

            cmp_deeply(
                [$o->files_loaded],
                bag( grep -e, @{$test_obj->true_file_names} ),
                $test_obj->test_text( 'correct files loaded (OO)' )
            );

            cmp_deeply(
                $o->sources, $test_obj->sources_from("expected_files"),
                $test_obj->test_text( 'sources correct setup from input (OO)' )
            );

        }

    };

}

done_testing;
