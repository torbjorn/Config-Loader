package t::lib::TestUtils;

use strict;
use warnings;
use File::Basename;

use base 'Exporter';
our @EXPORT = qw/test_text/;

sub test_text {

    my($test,$additional) = @_;

    $additional = ' - ' . $additional
        if defined $additional;

    return sprintf '%s, %d: %s%s',
        basename($test->{datafile}), $test->{line}, $test->{title},
            $additional||'';

}

1;
