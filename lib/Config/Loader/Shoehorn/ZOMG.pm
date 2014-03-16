package Config::Loader::Shoehorn::ZOMG;

use strict;
use warnings;

## ::ZOMG compability code

use File::Spec::Functions;
use File::Basename qw(fileparse);
use Config::Any;

use base 'Exporter';
our @EXPORT = qw/
                    new
                    open

                    load
                    reload

                    find
                    found

                    _path_to

/;

## ZOMG API

sub new {

    my $class = shift;
    my @args = @_;

    if ( @args == 1) {
        unshift @args, "file";
    }

    ## holding onto the args for a rainy day
    my $self = bless {
        args => \@args,
        config => undef,
        obj => undef,
    }, $class;
    $self->_make_object;

    return $self;

}
sub load {
    my $self = shift;
    return $self->{config} //= $self->{obj}->load_config;
}
sub reload {
    my $self = shift;
    $self->_make_object;
    return $self->load;
}
sub open {

    my $self = shift;

    if ( ref $self ) {

        warn "You called ->open on an instantiated object with arguments" if @_;

    }
    else {

        $self = $self->new(@_);

    }

    if ( not $self->find ) {
        return;
    }

    if ( wantarray ) {
        return( $self->load, $self );
    }

    return $self->load;

}

## Return files that have been found and processed
## don't really distinguish between the two.
## Will have to see about that
sub found {
    my $self = shift;
    return $self->find if $self->{config};
}
## return files that config will be loaded from
sub find {
    my $self = shift;
    my @files;

    for my $source (@{$self->{obj}->sources}) {

        next unless $source->[0] eq "File";

        if ( ref $source->[1] eq "HASH" and
                 defined $source->[1]{file} ) {
            push @files, $source->[1]{file};
        }

    }

    return @files;

}


## Zhoehorn internals
sub _make_object {
    my $self = shift;
    $self->{config} = undef;
    return $self->{obj} = $self->new_source( "Profile::Default",
                                      _process_args($self->{args}) );
}

sub _create_local_siblings {

    my @files = @_;
    my @local_siblings;

    for my $file (@files) {

        die "blew up" unless defined $file;

        if ( not $file =~ /_local/ ) {

            my($new_fname,$dirs,$ext) = fileparse $file, qr/\.[^.]*/;

            ## in time, the "local" part will be dynamic
            $new_fname .= "_" . "local" . $ext;

            push @local_siblings, catfile($dirs,$new_fname);

        }

    }

    return @local_siblings;

}

## the file types we know
sub _get_extensions { @{ Config::Any->extensions } }

sub _has_extension {
    my ($f,$d,$ext) = fileparse shift, qr/\.[^.]*/;
    return $ext;
}

## Create an input that Profile::Default can work with
sub _process_args {

    ## Need an object that:
    ## 1) loads config on ->load
    ## 2) fetches config on load, like ->load->{'some-conf-key'}
    ## 3) Can the P::Default be shoehorned to do this?
    my %args = @{$_[0]};

    my %args_for_p_default = ( sources => [] );

    my @files;

    use Data::Dumper;
    # print Dumper \%args;

    my $zomg_name = $args{name};
    my $zomg_path = $args{path};
    my $zomg_file = $args{file};
    my $add_local = not $args{no_local};
    my $add_env   = not $args{no_env};
    my $zomg_env  = defined($zomg_name) ?
        $ENV{ uc $zomg_name . "_CONFIG" } : undef;
    my $local_suffix = $args{local_suffix};

    ## some checks that are tested for
    if ( defined $local_suffix and defined $zomg_file  ) {
        warn "Warning, 'local_suffix' will be ignored if 'file' is given, use 'path' instead";
    }

    ## Get to work...

    ## Filenames come in env variables
    if ( $add_env ) {

        ## Either one var configured
        if (defined $zomg_env) {
            push @files, $zomg_env, _create_local_siblings($zomg_env)
                if defined $zomg_env;

        }
        ## .. or optional candidates
        elsif ( defined $args{env_lookup} ) {

            $args{env_lookup} = [$args{env_lookup}] unless
                ref $args{env_lookup} eq "ARRAY";

            my @env_names = map { uc $_ . "_CONFIG" } @{$args{env_lookup}};

            my @files_found = grep { defined $_ } @ENV{@env_names};
            push @files, @files_found, _create_local_siblings(@files_found);

        }

    }
    if ( not @files ) {
        ##.. or are found locally
        if ( defined $zomg_file ) {
            push @files, $zomg_file
        }
        ##.. one way or another
        elsif ( defined $zomg_path and defined $zomg_name ) {
            my $fp = catfile( $zomg_path, $zomg_name );

            push @files, $fp, $add_local ?
                _create_local_siblings($fp) : ();

        } elsif ( defined $zomg_path ) {

            push @files, $zomg_path, $add_local ?
                _create_local_siblings($zomg_path) : ();

        }
    }

    ## files without extension gets all
    my @files_without_extension = grep { not _has_extension $_ } @files;
    my @files_with_extension = grep { _has_extension $_ } @files;

    for my $file_wo (@files_without_extension) {
        push @files_with_extension, map {
            $file_wo . "." . $_
        } _get_extensions;
    }

    ## sort them to match ZOMG::Loader line 91
    ## should have seen this coming sooner
    @files_with_extension = sort {

        my $a3 = (my $a2 = $a) =~ s/_local//;
        my $b3 = (my $b2 = $b) =~ s/_local//;

            return
                $a3 cmp $b3
                    ||
                 $a2 cmp $b2

    } @files_with_extension;

    ## Add them as sources
    for my $file (grep {-f} @files_with_extension) {

        push @{$args_for_p_default{sources}},
            [ 'File', { file => $file } ];

    }

    ## Add defaults
    if ( exists $args{default} ) {
        $args_for_p_default{default} = $args{default};
    }

    return \%args_for_p_default;

};

sub _path_to {}

{
    package Config::ZOMG::Source::Loader;

    sub file_extension ($) {
        my $path = shift;
        return if -d $path;
        my ($extension) = $path =~ m{\.([^/\.]{1,4})$};
        return $extension;
    }

}

1;
