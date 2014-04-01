use strict;
use warnings;

my $test_data = [

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "Many conf files",
        files => [qw(t/etc/config t/etc/stem1.conf t/etc/stem1.pl)],
        true_file_names => [qw(t/etc/config.perl t/etc/stem1.conf t/etc/stem1.pl)],
        get => {
            foo => "bar",
            baz => "test",
            blee => "baz",
            bar => [ "this", "that" ],
        },
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "One conf file",
        files => [qw(t/etc/config)],
        true_file_names => [qw(t/etc/config.perl)],
        get => {
            foo => "bar",
            blee => "baz",
            bar => [ "this", "that" ],
        },
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "File without file returns {}",
        files => [ ],
        true_file_names => [ ],
        get => { },
    },

    {
        datafile => __FILE__,
        line    => __LINE__,
        title => "File with invalid file returns {}",
        files => ["/invalid/path"],
        true_file_names => [ ],
        get => { },
    },

];

## Create all variations of constructor
[ map {

    ## 1. hash constructor with files argument
    my %variation_1 = %$_;
    $variation_1{args} = [ files => [ @{$_->{files}} ] ];
    $variation_1{title} .= "; hash constructor with files argument";

    ## 2. hash ref constructor with files argument
    my %variation_2 = %$_;
    $variation_2{args} = [ { files => [ @{$_->{files}} ] } ];
    $variation_2{title} .= "; hash ref constructor with files argument";

    ## 3. hash constuctor with File sources
    my %variation_3 = %$_;
    $variation_3{args} = [  sources => [ map [ File => { file => $_ } ], @{$_->{files}} ] ];
    $variation_3{title} .= "; hash constructor with File sources";

    ## 4. hash ref constructof wirh File sources
    my %variation_4 = %$_;
    $variation_4{args} = [ {sources => [ map [ File => { file => $_ } ], @{$_->{files}} ] } ];
    $variation_4{title} .= "; hash ref constructor with File sources";

    ( {%variation_1},{%variation_2},{%variation_3},{%variation_4} );

} @$test_data ];
