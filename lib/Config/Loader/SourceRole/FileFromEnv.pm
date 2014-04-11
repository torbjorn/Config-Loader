package Config::Loader::SourceRole::FileFromEnv;

=begin comments

Implement the role to cover the needs of CPCL, JFDI and ZOMG

# Classes to cover:

## CPCL

Looks at $ENV{ MYAPP_CONFIG } and $ENV{ CATALYST_CONFIG }

MYAPP is uc of catalyst name, after having been passed through
Catalyst::Utils::appprefix, will probably reimplement that here.

This means, we must require a name parameter. This will be an app
name, the catalyst name or any arbitrary name given to the instance.

CPCL uses this as a partial filepath and will append an optional local
suffix and extension.

See sub Catalyst::Plugin::ConfigLoader::find_files at line 118

## JFDI

Fetches path from $ENV{ NAME_CONFIG } where NAME is the app name or
similar, like for CPCL.

## ZOMG

Works just like JFDI

# Design thoughts

* ENV provides the "path" attribute in said classes. It is fetched
whenever the classes are about to report files

* The said classes have a "path", but not necessarily a
  "file". However Source::File handles them seemlessly as it has magic
  to choose between stem and file. Furthermore File requires a file
  attribute be set.

* Since file is ro in Source::File, the attribute must be read from
  %ENV around BUILD

* Extending Profile::Default and simply adding a File source that
  points to %ENV path should solve it!

=cut

use Moo::Role;
use namespace::clean;
use Sub::Quote 'quote_sub';
use MooX::HandlesVia;
use File::Spec qw(catfile);

requires qw/name sources _build_loader/;

has env_lookup => (
   is => 'ro',
   coerce => sub { ref $_[0] eq "ARRAY" && $_[0] || [$_[0]] },
   handles_via => "Array",
   handles => { "env_lookups" => "elements" },
   default => sub { [] },
);
has no_env => (
    is => 'ro',
    default => 0
);

before _build_loader => sub {

    my $self = shift;

    if ( not $self->no_env ) {

        for my $prefix ( grep defined, $self->name, $self->env_lookups ) {

            my $value = _env($prefix,'CONFIG');

            if (defined $value) {

                if ( -d $value ) {
                    $value = catfile( $value, $self->name );
                }

                ## At this point, the ENV value overrides all other
                ## sources. However arguments to File sources needs to
                ## be preserved

                my @file_args;

                ## 1: (possible File sources passed through constructor as "File")
                if ( defined my $file_source = delete $self->overrides->{File} ) {
                }



                ## 2: Remove any sources that are "File"
                $self->{sources} = [  grep $_->[0] ne "File", @{$self->sources}  ];

                ## 3: Setup a new source for the file set in env
                unshift @{ $self->sources }, [ File => { file => $value } ];

                last;

            }
        }

    }

};

sub _env (@) {
    my $key = uc join "_", @_;
    $key =~ s/::/_/g;
    $key =~ s/\W/_/g;
    return $ENV{$key};
}

1;
