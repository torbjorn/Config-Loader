#!/usr/bin/perl

use warnings;
use strict;
use Test::More;
use Test::Deep;

{
    package RoleTest;
    use Moo;
    extends "Config::Loader::Source::Profile::Default";

    has name => ( is => 'ro', required => 1 );

    with "Config::Loader::SourceRole::FileFromEnv";

}

my $tests = do 't/share/test_data_for_filefromenv.pl';

for my $test (@$tests) {

    my %h = %{ $test->{env} };

    local @ENV{keys %h} = values %h;

    my $o = Config::Loader->new_source(
        '+RoleTest',
        $test->{args},
    );

    my $cfg = $o->load_config;

    cmp_deeply( $cfg, $test->{get}, $test->{title} );

}




done_testing;
