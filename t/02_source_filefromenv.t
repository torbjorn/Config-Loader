#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;
use Test::Most;
use Test::Warnings;

use Config::Loader ();

{
    local $ENV{MYAPP_CONFIG} = 't/etc/myapp.conf';

    isa_ok( my $cfg = Config::Loader->new_source( 'FileFromEnv', name => 'MYAPP' ),
            'Config::Loader::Source::FileFromEnv' );

    cmp_deeply( $cfg->load_config,
                {
                    file => $ENV{MYAPP_CONFIG},
                    suffix => undef,
                },
                'load_config'
            )

}

done_testing;
