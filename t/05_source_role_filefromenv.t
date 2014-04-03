#!/usr/bin/perl

use warnings;
use strict;
use Test::More;
use Test::Deep;
use File::Basename;
require Moo::Role;

use t::lib::TestUtils;

my $tests = do 't/share/test_data_for_filefromenv.pl';

for my $test (@$tests) {

    my $test_obj = TestData->new($test);

    my %h = $test_obj->env_mod_hash;
    local @ENV{keys %h} = values %h;

    my $obj_gen = sub {

            my $roles = shift;

            for (@$roles) {
                if ( !/^Config::Loader::SourceRole::/ ) {
                    $_ = "Config::Loader::SourceRole::" . $_;
                }
            }

            my $cl = Moo::Role->create_class_with_roles(
                "TestBaseClass",
                @$roles,
            );

            my $o = $cl->new($test_obj->compose_args(no_local=>1) );

        };

    my @roles_to_test = permute_roles_except("FileFromEnv");

    subtest 'Test data at line '.$test_obj->line => sub {

        for my $roles ( @roles_to_test ) {

            my $roles_text = join ", ", map { s/.*:://; $_ } @$roles;
            note "Testing with role combination: $roles_text";

            # note explain $test_obj->compose_args(no_local=>1);
            my $o = $obj_gen->($roles);

            is_deeply(
                $o->load_config,
                $test_obj->get,
                $test_obj->test_text( 'config loaded (OO)' ),
            );

            my @files_actually_loaded =
                map { @{$_->files_loaded} }
                grep { $_->isa("Config::Loader::Source::File") }
                @{ $o->loader->source->source_objects };

            cmp_deeply(
                [@files_actually_loaded],
                bag( grep -e, @{$test_obj->true_file_names} ),
                $test_obj->test_text( 'files loaded (OO)' )
            );

            cmp_deeply(
                $o->sources, $test_obj->sources_from("expected_files"),
                $test_obj->test_text( 'sources correct setup from input (OO)' )
            );

        }

    };

}


done_testing;
