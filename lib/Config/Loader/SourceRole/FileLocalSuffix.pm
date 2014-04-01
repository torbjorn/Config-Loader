package Config::Loader::SourceRole::FileLocalSuffix;

use Moo::Role;

use Sub::Quote 'quote_sub';
use MooX::HandlesVia;
use File::Basename qw/fileparse/;
use File::Spec::Functions qw/catfile/;

has no_local => (
   is => 'ro',
   default => quote_sub q{ 0 },
);

has local_suffix => (
   is => 'ro',
   default => quote_sub q{ 'local' },
);

requires qw/sources/;

## Simply add an additional File source for every file, that has a
## _local suffix in it.
before _build_loader => sub {

    my $self = shift;

    return if $self->no_local;

    my @local_sources;

    for my $source (@{$self->sources}) {

        if ( $source->[0] eq "File" ) {

            my $file = $source->[1]{file};

            ## This assumes $file is a file or a stem. Cases where it
            ## is a directory needs to be explored later
            my( $name, $dirs, $suffix ) = fileparse( $file, qr/\.[^.]*/ );

            my $new_with_local = $name . "_" . $self->local_suffix;

            my $new_local_file = catfile( $dirs, $new_with_local );

            $new_local_file .= $suffix ? $suffix : "";

            push @local_sources,
                [ File => { file => $new_local_file } ];

        }

    }

    push @{$self->sources}, @local_sources;

};

1;
