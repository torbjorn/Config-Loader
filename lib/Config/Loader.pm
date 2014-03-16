package Config::Loader;
use warnings;
use strict;
use Module::Runtime qw( use_module );
use 5.008008;

our $VERSION = "0.001000";
$VERSION = eval $VERSION;

# Functional Interface.
sub import {
    my ( $class, $default_source, $export ) = @_;
    $default_source ||= "Profile::Default";
    $export ||= "get_config";

    my $target = caller() . "::" . $export;

    no strict 'refs';
    *$target = sub {
        my @args = @_;
        my $source;
        if (ref($args[0]) eq 'HASH') {
            $args[0] = { %{ $args[0] } };
            $source = delete $args[0]->{source};
        }
        $source ||= $default_source;
        return $class->new_source( $source, @args )->load_config;
    };
}

# OO Interface
sub _load_source {
    my ( $class, $source ) = @_;

    if ( substr( $source, 0, 1 ) eq '+' ) {
        return use_module( substr( $source, 1 ) );
    }
    return use_module( "Config::Loader::Source::$source" );
}

sub new_source {
    my ( $class, $source, @args ) = @_;

    $class->_load_source( $source )->new( @args );
}

## ::ZOMG compability code

use File::Spec::Functions;
use File::Basename qw(fileparse);

## Create input that Profile::Default can work with
sub _process_args {

    ## Need an object that:
    ## 1) loads config on ->load
    ## 2) fetches config on load, like ->load->{'some-conf-key'}
    ## 3) Can the P::Default be shoehorned to do this?
    my %args = @{$_[0]};

    $args{sources} = [];

    my $zomg_name = delete $args{name};

    ## Get to work...
    if ( defined $zomg_name ) {

        ## One or more config files. Delete the path key in the
        ## process as ::Default don't use them

        my @files;

        ## Filenames come in env variables
        if ( defined (my $env_filepath =
                          $ENV{ uc $zomg_name . "_CONFIG" } )) {

            push @files, $env_filepath;

        }
        ##.. or are found locally
        elsif ( defined ( my $dir = delete $args{path} ) ) {

            ## Extra verbose variable names at this point
            my $fname = $zomg_name;

            my $filepath = catfile( $dir, $fname );

            push @files, $filepath;

        }

        ## Add them as sources
        for my $file (@files) {

            push @{$args{sources}},
                [ 'File', { file => $file } ];

            ## also push a _local sibling, ::File does the right thing if
            ## it doesn't exist.
            if ( not $file =~ /_local/ ) {

                my($new_fname,$dirs,$ext) = fileparse $file, qr/\.[^.]*/;

                ## in time the "local" part will be dynamic
                $new_fname .= "_" . "local" . $ext;;

                push @{$args{sources}},
                    [ 'File', { file => catfile($dirs,$new_fname) } ];

            }


        }

    }

    return \%args;

};

sub _make_object {
    my $self = shift;
    return $self->{obj} = $self->new_source( "Profile::Default",
                                      _process_args($self->{args}) );
}

sub new {

    my $class = shift;
    my @args = @_;

    ## holding onto the args for a rainy day
    my $self = bless { args => \@args }, $class;
    $self->_make_object;

    return $self;

}

sub load {
    return shift->{obj}->load;
}

sub reload {
    my $self = shift;
    $self->_make_object;
    return 1;
}

1;

=head1 NAME

Config::Loader - The Universal Configuration Loader

=head1 DESCRIPTION

Config.::Loader provides a consistent interface to loading configuration
data from files, command line input, environment variables and anything
else you'd like to load configuration from.

This document will describe the way Config::Loader works by default.

Other Documentation

=over4

=item * L<Config::Loader::Cookbook::Introduction> - Detailed information
on how Config::Loader works.

=item * L<Config::Loader::Cookbook::Sources> - How to make Config::Loader
work with your favorite method of loading configuration data.

=back

=head1 SYNOPSIS

    #!/usr/bin/perl
    use warnings;
    use strict;
    use Config::Loader;

    my $config = get_config({
        file => "/etc/my_app",
        default => {
            host        => "localhost",
            port        => 8080,
            name        => "My Application",
        },
    });

    printf("Configured %s on http://%s:%s/",
        $config->{name}, $config->{host}, $config->{port}
    );


=head1 METHODS

=head2 get_config()

This is the only method exported by Config::Loader.  By default it uses four sources
for configuration data.  Each source of data can be added to and overwritten by each
successive source of configuration data.

=head3 default

The default data structure is defined when initially making the call the get_config().

    my $config = get_config({
        default => {
            some_key            => "some string",
            some_other_key      => [qw( some array elements )]
            a_hash_ref          => { key => "value" },
        }.
    });

This structure is the initial configuration, further some sources use this information
in making decisions on configuration, such as Getopts, and ENV as we will see later.

=head3 ConfigAny

The next source of configuration data that is looked at is a configuration file loaded
by L<Config::Any>.  To specify a file to check for configuration data use the accessor
B<file> in your call.

    my $config = get_config({
        file => "/etc/my_app",
        default => {
            some_key            => "some string",
            some_other_key      => [qw( some array elements )]
            a_hash_ref          => { key => "value" },
        }.
    });

Now the file B</etc/my_app.*> will be checked, you must use a file extension that
L<Config::Any> recognizes.  If any of some_key, some_other_key or a_hash_ref are
defined in the configuration file, they will overwrite the values in the default data
structure.

Any new keys given by GetOpts will be added to the data structure.

=head3 GetOpts

The next source looked at will be GetOpts.  By default, any top-level key that exists in
the default data structure will be checked for its type (string, array, hash ref, boolean)
and used for the configuration for a call to GetOptions.

You can specific your own instruction set for the GetOptions call by adding the accessor
GetOptions and passing an array reference for values to check.  Keep in mind this will
B<not> add to the structure checked by the default data structure, but completely substitute
it.

    my $config = get_config({
        file => "/etc/my_app",
        default => {
            some_key            => "some string",
            some_other_key      => [qw( some array elements )]
            a_hash_ref          => { key => "value" },
        },
        GetOptions => [qw( some_key=s some_other_key=@ a_hash_ref=% email=s )]
    });

This will mimic the structure that would have been created by the default data structure,
but adds the string email as well.

If any key which is already defined is returned by GetOptions it will overwrite the data
structure as it is to this point.

Any new keys given by GetOpts will be added to the data structure.

=head3 ENV

The next source looked at it ENV.  This source will check the default data structure and
check for CONFIG_$key_name in the environment variables, is found it will replace it
in the configuration.


    my $config = get_config({
        file => "/etc/my_app",
        default => {
            some_key            => "some string",
            some_other_key      => [qw( some array elements )]
            a_hash_ref          => { key => "value" },
        },
        GetOptions => [qw( some_key=s some_other_key=@ a_hash_ref=% email=s )]
    });

If you run the script with C<CONFIG_SOME_KEY=foo ./script> some_key's value will be replaced
with the value C<foo>.  No values which are not a top-level key in the data structure will be checked.

=head1 AUTHOR

=over4

Kaitlyn Parkhurst (SymKat) I<E<lt>symkat@symkat.comE<gt>> ( Blog: L<http://symkat.com/> )

=back

=head1 CONTRIBUTORS

=over4

=item * Matt S. Trout (mst) I<E<lt>mst@shadowcat.co.ukE<gt>>

=back

=head1 SPONSORS

=head1 COPYRIGHT

Copyright (c) 2012 the Config::Loader L</AUTHOR>, L</CONTRIBUTORS>, and
L</SPONSORS> as listed above.

=head1 LICENSE

This library is free software and may be distributed under the same terms as perl itself.

=head1 AVAILABILITY

1;
