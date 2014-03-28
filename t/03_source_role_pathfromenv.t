#!/usr/bin/perl

use warnings;
use strict;
use Test::More;
use Test::Deep;
use Config::Loader;

{
    package Config::Loader::Source::RoleTest;
    use Moo;

    extends "Config::Loader::Source::Profile::Default";

    has name => ( is => 'ro', required => 1 );

    with "Config::Loader::SourceRole::FileFromEnv";

}

{

    local $ENV{MYAPP_CONFIG} = "t/etc/config";

    my $o = Config::Loader->new_source(
        'RoleTest',
        { name => "myapp" }
    );

    my $cfg = $o->load_config;

    is_deeply $cfg,
        {
            foo  => "bar",
            blee => "baz",
            bar  => [ "this", "that" ],
        }, "config loaded";

}



done_testing;
