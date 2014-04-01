#!/usr/bin/perl

use warnings;
use strict;
use Test::More;
use Test::Deep;
use Role::Tiny;

use Config::Loader;

{
    package FileLocalSuffixTest;

    use Moo;
    extends 'Config::Loader::Source::Profile::Default';
    with 'Config::Loader::SourceRole::FileLocalSuffix';

    ## need this for test with other roles
    has name => ( is => "ro" );

}

use t::lib::TestUtils;

my $tests = do 't/share/test_data_for_filelocalsuffix.pl';

for my $test (@$tests) {

    my $test_obj = TestData->new($test);
    my @files = @{ $test_obj->files };

    my %args = %{ $test_obj->args };
    @args{qw/no_env no_local/} = (1,1);

    $args{sources} = $test_obj->sources_from("files");
    my @expected_files = @{$test_obj->expected_files};

    my $expected_sources = $test_obj->sources_from("expected_files");
    my $expected_config = $test->{get};

    subtest 'Test data at line '.$test->{line} => sub {

        my $obj_gen = sub {
            my $roles = shift;
            my $o = Config::Loader->new_source("+FileLocalSuffixTest",%args);
            if ( defined $roles ) {
                ## $roles must be an ARRAY at this point, not enforced
                for (@$roles) {
                    if ( !/^Config::Loader::SourceRole::/ ) {
                        $_ = "Config::Loader::SourceRole::" . $_;
                    }
                }
                Role::Tiny->apply_roles_to_object( $o, @$roles );
            }
            return $o;
          };

        my @roles_to_test = permute_roles_except("FileLocalSuffix");

        for my $roles ( @roles_to_test ) {

            my $roles_text = defined $roles ? join ", ", map { s/.*:://; $_ } @$roles : "";

            note "Testing with roles $roles_text" if $roles_text;

            my $o = $obj_gen->($roles);

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

    };

    last;

}

done_testing;
