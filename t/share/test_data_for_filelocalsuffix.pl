[

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "Vanilla find _local file from stem",
        files => [qw(t/etc/myapp)],
        expected_files => [qw(t/etc/myapp t/etc/myapp_local)],
        true_file_names => [qw(t/etc/myapp.conf t/etc/myapp_local.conf)],
        get => {
            name => "MyApp",
            foo => "not bar after all!",
        },
        no_local => 0,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "Don't find _local file from stem",
        files => [qw(t/etc/myapp)],
        expected_files => [qw(t/etc/myapp)],
        true_file_names => [qw(t/etc/myapp.conf)],
        get => {
            name => "MyApp",
            foo => "bar",
        },
        no_local => 1,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "File with ext and _local",
        files => [qw(t/etc/myapp.conf)],
        expected_files => [qw(t/etc/myapp.conf t/etc/myapp_local.conf)],
        true_file_names => [qw(t/etc/myapp.conf t/etc/myapp_local.conf)],
        get => {
            name => "MyApp",
            foo => "not bar after all!",
        },
        no_local => 0,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "File with ext and NO _local",
        files => [qw(t/etc/myapp.conf)],
        expected_files => [qw(t/etc/myapp.conf)],
        true_file_names => [qw(t/etc/myapp.conf)],
        get => {
            name => "MyApp",
            foo => "bar",
        },
        no_local => 1,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "Mixing files that have and don't have a _local",
        files => [qw(t/etc/myapp t/etc/stem1.pl)],
        expected_files => [qw(t/etc/myapp t/etc/stem1.pl t/etc/myapp_local t/etc/stem1_local.pl)],
        true_file_names => [qw(t/etc/myapp.conf t/etc/myapp_local.conf t/etc/stem1.pl)],
        get => {
            name => "MyApp",
            foo => "not bar after all!",
            baz => "test",
        },
        no_local => 0,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "Mixing files that have and don't have a _local - no local",
        files => [qw(t/etc/myapp t/etc/stem1.pl)],
        expected_files => [qw(t/etc/myapp t/etc/stem1.pl)],
        true_file_names => [qw(t/etc/myapp.conf t/etc/stem1.pl)],
        get => {
            name => "MyApp",
            foo => "bar",
            baz => "test",
        },
        no_local => 1,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "Many conf files",
        files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
        expected_files => [qw(
                                 t/etc/config
                                 t/etc/stem1.conf
                                 t/etc/stem1.pl

                                 t/etc/config_local
                                 t/etc/stem1_local.conf
                                 t/etc/stem1_local.pl
                         )],

        true_file_names => [qw(
                                  t/etc/config.perl
                                  t/etc/stem1.conf
                                  t/etc/stem1.pl

                                  t/etc/config_local.perl
                                  t/etc/stem1_local.conf
                                  t/etc/stem1_local.pl
                          )],
        get => {
            foo => "bar",
            baz => "test",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        no_local => 0,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "Many conf files - no local",
        files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
        expected_files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
        true_file_names => [qw(t/etc/config.perl t/etc/stem1.conf t/etc/stem1.pl)],
        get => {
            foo => "bar",
            baz => "test",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        no_local => 1,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "File without file returns {}",
        files => [ ],
        expected_files => [ ],
        true_file_names => [ ],
        get => { },
        no_local => 0,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "File without file returns {} - no local",
        files => [ ],
        expected_files => [ ],
        true_file_names => [ ],
        get => { },
        no_local => 1,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "File with invalid file returns {}",
        files => ["/invalid/path"],
        expected_files => [qw(/invalid/path /invalid/path_local)],
        true_file_names => [ ],
        get => { },
        no_local => 0,
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "File with invalid file returns {} - no local",
        files => [qw(/invalid/path)],
        expected_files => [qw(/invalid/path)],
        true_file_names => [ ],
        get => { },
        no_local => 1,
    },

];
