package Config::Loader::Source::FileWithLocal;

use Moo;
use MooX::HandlesVia;
use Config::Loader::Source::Merged;
use File::Basename qw/fileparse/;
use File::Spec::Functions qw/catfile/;

has source => (
    is => "lazy",
    handles => [qw/load_config/],
);
has no_local => (
   is => 'ro',
   default => 0,
);
has local_suffix => (
   is => 'lazy',
   default => 'local',
);

# ::File attributes
has file => qw/is ro/;
has load_args => qw/is ro/;
has load_type => qw/is ro/;

with 'Config::Loader::SourceRole::OneArgNew';

sub one_arg_name { 'file' }

sub file_args {
    my ($self,$file) = (shift,shift);
    return {
        file => $file // $self->file,
        defined $self->load_args ? (load_args => $self->load_args) : (),
        defined $self->load_type ? (load_type => $self->load_type) : (),
    };
}

sub _build_source {

    my $self = shift;

    my @sources;

    if (defined $self->file) {

        push @sources, [
            'File' => $self->file_args,
        ];

        unless ( $self->no_local ) {

            my( $name, $dirs, $suffix ) = fileparse( $self->file, qr/\.[^.]*/ );

            my $new_with_local = $name . "_" . $self->local_suffix;
            my $new_local_file = catfile( $dirs, $new_with_local );
            $new_local_file .= $suffix ? $suffix : "";

            push @sources, [
                'File' => $self->file_args($new_local_file)
            ];

        }

    }

    return Config::Loader::Source::Merged->new(sources => \@sources);

}

sub files_loaded {
    my $self = shift;
    return ([
        map { @{$_->files_loaded} }
            grep { $_->can("files_loaded") }
                @{ $self->source->source_objects }
            ]);
}

1;
