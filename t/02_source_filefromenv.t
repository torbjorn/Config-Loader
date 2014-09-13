#!/usr/bin/perl

use strict;
use warnings;
use utf8::all;
use Test::Most;
use Test::Warnings;

use Config::Loader ();

{
    local $ENV{MYAPP_CONFIG} = 't/etc/myapp.conf';

    my $cfg = Config::Loader->new_source( 'FileFromEnv', name => 'MYAPP' );

    cmp_deeply( $cfg->load_config,
                {
                    file => 't/etc/myapp.conf',
                    suffix => undef,
                },
                'test 1 - only file, not suffix'
            )

}

{
    local $ENV{MYAPP2_CONFIG} = 't/etc/myapp.conf';
    local $ENV{MYAPP2_CONFIG_LOCAL_SUFFIX} = 'notsimplylocal';

    my $cfg = Config::Loader->new_source( 'FileFromEnv', name => 'MYAPP2' );

    cmp_deeply( $cfg->load_config,
                {
                    file => 't/etc/myapp.conf',
                    suffix => 'notsimplylocal',
                },
                'test 2 - file and suffix'
            )

}

{
    local $ENV{MYAPP3_CONFIG} = 't/etc/myapp.conf';
    local $ENV{MYAPP3_CONFIG_LOCAL_SUFFIX} = 'notsimplylocal';

    my $cfg = Config::Loader->new_source( 'FileFromEnv', name => 'SOMETHINGELSE' );

    cmp_deeply( $cfg->load_config,
                {
                    file   => undef,
                    suffix => undef,
                },
                'test 3 - env not found'
            )

}

done_testing;
