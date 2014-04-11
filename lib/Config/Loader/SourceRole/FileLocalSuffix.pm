package Config::Loader::SourceRole::FileLocalSuffix;

use Moo::Role;
use namespace::clean;

use Sub::Quote 'quote_sub';
use MooX::HandlesVia;
use File::Basename qw/fileparse/;
use File::Spec::Functions qw/catfile/;
use Devel::Dwarn;
has no_local => (
   is => 'ro',
   default => quote_sub q{ 0 },
);

has local_suffix => (
   is => 'lazy',
   default => 'local',
   builder => sub {
       my $self = shift;
       return unless $self->name;
       return $ENV{ uc $self->name . '_CONFIG_LOCAL_SUFFIX' };
   }
);

requires qw/name sources/;

## Simply add an additional File source for every file, that has a
## _local suffix in it.
before _build_loader => sub {

    my $self = shift;

    return if $self->no_local;

    my @local_sources;

    for my $source (@{$self->sources}) {

        if ( $source->[0] eq "File" ) {

            if ( exists $source->[1]{file} ) {

                print "# FLS: ADDING FILE\n";

                my %source_args = %{$source->[1]};
                my $file = delete $source_args{file};

                ## This assumes $file is a file or a stem. Cases where it
                ## is a directory needs to be explored later
                my( $name, $dirs, $suffix ) = fileparse( $file, qr/\.[^.]*/ );

                my $new_with_local = $name . "_" . $self->local_suffix;

                my $new_local_file = catfile( $dirs, $new_with_local );

                $new_local_file .= $suffix ? $suffix : "";
                $source_args{file} = $new_local_file;

                push @local_sources,
                    [ File => { %source_args } ];

            }

        }

    }

    push @{$self->sources}, @local_sources;

};

1;
