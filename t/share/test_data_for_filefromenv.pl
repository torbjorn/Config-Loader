[

    {
        line    => __LINE__,
        title => "Vanilla - find file from env",
        args => { name => "myapp" },
        env => { MYAPP_CONFIG => "t/etc/config" },
        get => {
            foo  => "bar",
            blee => "baz",
            bar  => [ "this", "that" ],
        },
    },

    {
        line    => __LINE__,
        title => "Vanilla - find file from env takes precedence",
        args => { name => "myapp2", File => {file => "t/etc/config"} },
        env => { MYAPP2_CONFIG => "t/etc/stem1.pl" },
        get => {
            baz => "test",
        },
    },

    {
        line    => __LINE__,
        title => "Vanilla - no_env prevents env file lookup",
        args => { name => "myapp2", File => {file => "t/etc/config"}, no_env => 1 },
        env => { MYAPP2_CONFIG => "t/etc/stem1.pl" },
        get => {
            foo  => "bar",
            blee => "baz",
            bar  => [ "this", "that" ],
        },
    },

    {
        line    => __LINE__,
        title => "Different env_lookup",
        args => { name => "myapp", env_lookup => [qw/myfile/] },
        env => { MYFILE_CONFIG => "t/etc/config" },
        get => {
            foo  => "bar",
            blee => "baz",
            bar  => [ "this", "that" ],
        },
    },

    {
        line    => __LINE__,
        title => "Different env_lookup - array coercion",
        args => { name => "myapp", env_lookup => "myfile" },
        env => { MYFILE_CONFIG => "t/etc/config" },
        get => {
            foo  => "bar",
            blee => "baz",
            bar  => [ "this", "that" ],
        },
    },

];
