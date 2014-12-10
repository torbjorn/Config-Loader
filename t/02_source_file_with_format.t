#!/usr/bin/perl
use warnings;
use strict;
use Test::More;
use Test::Deep;
use Test::Exception;
use Test::Warn;
use Test::Warnings;
use Config::Loader qw( File );

require_ok "Config::Any::General" or
    BAIL_OUT "Need Config::Any::General for this test to make sense";

my $test = {
    name => "using format",
    line => __LINE__,
    put => {
        file => "t/etc/myapp.conf",
        format => "General",
    },
    get => {
        name => "MyApp",
        foo => "bar",
    },
    files_loaded => [qw(t/etc/myapp.conf)],
};

note "plain use of format";

is_deeply(
    get_config( %{ $test->{put} } ),
    $test->{get},
    'test data correct (Fn)' );
my $o = Config::Loader->new_source( 'File', %{ $test->{put} }  );
is_deeply(
    $o->load_config,
    $test->{get},
    'test data correct (OO)'
);
cmp_deeply(
    $o->files_loaded,
    bag( @{ $test->{files_loaded} } ),
    'files loaded (OO)'
);

note "invalid format";

{

    local $test->{put}{format} = "ThisWontWork";

    throws_ok { get_config( %{ $test->{put} } ) }
        qr/is not supported/, "invalid format dies (Fn)";

    my $o = Config::Loader->new_source( 'File', %{ $test->{put} }  );

    throws_ok { $o->load_config }
        qr/is not supported/, "invalid format dies (OO)";

    cmp_deeply $o->files_loaded, [], "files loaded (OO)";

};

note "format and force_plugins collide";

{

    local $test->{put}{load_args} = { force_plugins => [qw<this will not affect things>] };

    # Functional
    my $cfg1;
    warning_like { $cfg1 = get_config( %{ $test->{put} } ) }
        qr/Both .* and format were specified/,
        "warns with conflicting arguments (Fn)";
    is_deeply $cfg1, $test->{get}, "test data correct (Fn)";

    # OO
    my $o = Config::Loader->new_source( "File", %{ $test->{put} }  );
    my $cfg2;
    warning_like { $cfg2 = $o->load_config }
        qr/Both .* and format were specified/,
        "warns with conflicting arguments (OO)";
    is_deeply $cfg2, $test->{get}, "test data correct (OO)";
    cmp_deeply(
        $o->files_loaded,
        bag( @{ $test->{files_loaded} } ),
        "no files loaded",
    );

};

done_testing;
