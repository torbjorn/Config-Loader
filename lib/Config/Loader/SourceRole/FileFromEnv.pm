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
use Sub::Quote 'quote_sub';
use MooX::HandlesVia;
use File::Spec qw(catfile);

requires qw/name sources/;

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

## THIS MUST BE CHANGED TO GO BEFORE _build_loader!!
## IMPORTANT - DO THIS!
##
## Mental note: ZOMG does a reload. Clear loader to mimic this
## behaviour. As loader is rebuilt, any File sources added will be
## taken care of.

around BUILDARGS => sub {

    my($orig,$class) = (shift,shift);

    my $args = $orig->($class,@_);

    if ( not $args->{no_env} ) {

        my $e = $args->{env_lookups};
        $args->{env_lookups} = ref $e eq "ARRAY" && $e || [$e];

        ## file from env takes precedence
        delete $args->{File};

        for my $prefix ( grep defined, $args->{name}, @{ $args->{env_lookup} } ) {
            my $value = _env($prefix,'CONFIG');
            if (defined $value) {

                if ( -d $value ) {
                    $value = catfile( $value, $args->{name} );
                }

                push @{ $args->{sources} }, [ File => { file => $value } ];
                last;
            }
        }

    }

    return $args;

};

sub _env (@) {
    my $key = uc join "_", @_;
    $key =~ s/::/_/g;
    $key =~ s/\W/_/g;
    return $ENV{$key};
}

1;
