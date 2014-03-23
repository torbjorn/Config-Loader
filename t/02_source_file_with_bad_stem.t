#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Test::Deep;
use Test::Exception;
use Test::Warn;
use Config::Loader qw( File );

my $test = {
    name => "A stem with two existing file completions",
    line => __LINE__,
    put => {
        file => "t/etc/stem1",
    },
    get => {
        foo => "bar",
        baz => "test",
    },
    files_loaded => [qw(t/etc/stem1.pl t/etc/stem1.conf)]
};

{
    note( "No ENV variables set - should cause death" );
    # Functional
    throws_ok { get_config( %{ $test->{put} } ) }
        qr/found more than 1 file for stem/,
        'dies when no ENV variables set (Fn)';
    # OO
    my $o = Config::Loader->new_source( 'File', %{ $test->{put} }  );
    throws_ok { $o->load_config }
        qr/found more than 1 file for stem/,
        'dies when no ENV variables set (OO)';
    cmp_deeply( $o->files_loaded, [],
        'no files loaded',
    );
};

{
    note( "ENV set to warn" );
    # Functional
    local $ENV{CONFIG_LOADER_SOURCE_FILE_MANY_FILES_WARN_ONLY} = 1;
    warning_like { get_config( %{ $test->{put} } ) }
        qr/found \d+ files for stem '.+' - this is most likely not something you want/,
        'warning ok with ENV variables set to warn (Fn)';
    # OO
    my $o = Config::Loader->new_source( 'File', %{ $test->{put} } );
    warning_like { $o->load_config }
        qr/.+ found \d+ files for stem '.+' - this is most likely not something you want/,
        'warning ok with ENV variables set to warn (OO)';
    ## check the files
    cmp_deeply(
        $o->files_loaded,
        bag( @{ $test->{files_loaded} } ),
        'found files loaded',
    );
};

{
    note( "ENV set to allow" );
    local $ENV{CONFIG_LOADER_SOURCE_FILE_MANY_FILES_ALLOW} = 1;
    # Functional
    is_deeply( get_config( %{ $test->{put} } ), $test->{get},
               'no warn or die when ENV variables set to allow (Fn)' );
    # OO
    my $o = Config::Loader->new_source( 'File', %{ $test->{put} }  );
    is_deeply(
        $o->load_config,
        $test->{get},
        'no warn or die when ENV variables set to allow (OO)'
    );
    cmp_deeply(
        $o->files_loaded,
        bag( @{ $test->{files_loaded} } ),
        'found files loaded',
    );
};

done_testing;
