#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;
use Test::Most;
use Test::FailWarnings;

use t::lib::TestUtils;

throws_ok { permute_roles_except("foo") }
    qr/Role must be one of/,
    "Bad role causes error";

throws_ok { permute_roles_except }
    qr/Need a role to exclude/,
    "Missing role causes error";


note "Testing role permutations on FileFromEnv";

{
    my @roles = permute_roles_except( "FileFromEnv" );
    shift @roles;

    cmp_deeply(
        \@roles,
        bag(
            ['Config::Loader::SourceRole::FileLocalSuffix'],
            ['Config::Loader::SourceRole::FileHelper'],
            bag(
                'Config::Loader::SourceRole::FileHelper',
                'Config::Loader::SourceRole::FileLocalSuffix',
            )
        ),
        "Role permutations ok"
    );
}


{
    note "Testing role permutations on FileHelper";

    my @roles = permute_roles_except( "FileHelper" );
    shift @roles;

    cmp_deeply(
        \@roles,
        bag(
            [
                'Config::Loader::SourceRole::FileFromEnv',
            ],
            [
                'Config::Loader::SourceRole::FileLocalSuffix',
            ],
            bag(
                'Config::Loader::SourceRole::FileFromEnv',
                'Config::Loader::SourceRole::FileLocalSuffix'
            )
        ),
        "Role permutations ok"
    );
}


{
    note "Testing role permutations on FileLocalSuffix";

    my @roles = permute_roles_except( "FileLocalSuffix" );
    shift @roles;

    cmp_deeply(
        \@roles,
        bag(
            [
                'Config::Loader::SourceRole::FileFromEnv',
            ],
            [
                'Config::Loader::SourceRole::FileHelper',
            ],
            bag(
                'Config::Loader::SourceRole::FileFromEnv',
                'Config::Loader::SourceRole::FileHelper',
            )
        ),
        "Role permutations ok"
    );
}


done_testing;
