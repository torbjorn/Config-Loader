package Config::Loader::Source::FileWithLocal;

use Moo;
use MooX::HandlesVia;
use Config::Loader::Source::Merged;
use File::Basename qw/fileparse/;
use File::Spec::Functions qw/catfile/;

has source => (
    is => "ro",
    handles => [qw/load_config/],
);

## Accepts a filename as one arg and sets up a ::Merged with that and
## a _local source

around BUILDARGS => sub {

    my ($orig, $class) = (shift, shift);

    my ($file,$new_local_file,$no_local);

    if (@_ == 1 and (ref($_[0])||'') ne 'HASH') {
        $file = shift;
    }

    my $args = $class->$orig(@_);
    $file //= delete $args->{file};

    if ( defined($file) and not ($no_local = delete $args->{no_local}) ) {

        my $local_suffix = $args->{local_suffix} // "local";

        my( $name, $dirs, $suffix ) = fileparse( $file, qr/\.[^.]*/ );
        my $new_with_local = $name . "_" . $local_suffix;
        $new_local_file = catfile( $dirs, $new_with_local );
        $new_local_file .= $suffix ? $suffix : "";

    }

    $args->{source} = Config::Loader::Source::Merged->new(
        sources => [
            ( defined $file               ? ([ "File" => { file => $file, %$args           } ]) : () ),
            ( defined $file && !$no_local ? ([ "File" => { file => $new_local_file, %$args } ]) : () ),
        ]
    );

    return $args;

};

1;
