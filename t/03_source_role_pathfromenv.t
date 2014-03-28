#!/usr/bin/perl

use warnings;
use strict;
use Test::More;
use Test::Deep;
use Config::Loader;

{
    package Config::Loader::Source::RoleTest;
    use Moo;

    extends "Config::Loader::Source::File";

    has name => ( is => 'ro', required => 1 );
    has path => ( is => 'ro' );

    with "Config::Loader::SourceRole::PathFromEnv";

    1;
}

{

    local $ENV{MYAPP_CONFIG} = "t/etc/config";

    my $o = Config::Loader->new_source(
        'RoleTest',
        { name => "myapp", file => undef, load_type => "stems" }
    );
    $o->{file} = ( $o->path );

    is $o->path, "t/etc/config", "path read from \%ENV" ;

    my $cfg = $o->load_config;

    is_deeply $cfg,
        {
            foo => "bar",
            blee => "baz",
            bar => [ "this", "that" ],
        }, "config loaded";

}



done_testing;
