[
    {
        title => "Many conf files",
        files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
        true_file_names => [qw(t/etc/config.perl t/etc/stem1.conf t/etc/stem1.pl)],
        get => {
            foo => "bar",
            baz => "test",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        line    => __LINE__,
    },
    {
        title => "One conf file",
        files => [qw(t/etc/config)],
        true_file_names => [qw(t/etc/config.perl)],
        get => {
            foo => "bar",
            blee => "baz",
            bar => [ "this", "that" ],
        },
        line    => __LINE__,
    },
    {
        title => "File without file returns {}",
        files => [ ],
        true_file_names => [ ],
        get => { },
        line    => __LINE__,
    },
    {
        title => "File with invalid file returns {}",
        files => ["/invalid/path"],
        true_file_names => [ ],
        get => { },
        line    => __LINE__,
    },
];
