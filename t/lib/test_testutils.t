#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;
use Test::Most;
use Test::FailWarnings;

use t::lib::TestUtils;

{
    my $o = TestBase->new;

    throws_ok { object_with_permuted_roles($o, "foo") }
        qr/Starting role must be one of/,
            "Bad role causes error";
}

{
    my $o = TestBase->new;

    throws_ok { object_with_permuted_roles($o) }
        qr/Need one fixed role/,
            "Missing role causes error";
}

{
    note "Testing role permutations on FileFromEnv";
    my $o = TestBase->new;

    my @roles = object_with_permuted_roles( $o, "FileFromEnv" );

    ok( $o->does("Config::Loader::SourceRole::FileFromEnv"), "object does FileFromEnv" );

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
    my $o = TestBase->new;

    my @roles = object_with_permuted_roles( $o, "FileHelper" );

    ok( $o->does("Config::Loader::SourceRole::FileHelper"), "object does FileHelper" );

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
    my $o = TestBase->new;

    my @roles = object_with_permuted_roles( $o, "FileLocalSuffix" );

    ok( $o->does("Config::Loader::SourceRole::FileLocalSuffix"), "object does FileLocalSuffix" );

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
