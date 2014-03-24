package Config::Loader::Source::Files;

use Moo;
extends 'Config::Loader::Source::Merged';

## Transform the supplied files => [..] to a sources => [...] that is
## something that ::Merged would accept as sources
##
## Technically this doesn't prevent other sources, and technically
## there is no need to, so this module could load other sources if
## someone wants to take the trouble, but we help loading files only,
## for other sources, the user is on his own
sub BUILDARGS {
    my ($class, @args) = @_;

    my $build_sources_in_hash = sub {

        my $args = shift;

        ## modify the hash and setup sources from supplied 'files'
        $args->{sources} //= [];

        push @{ $args->{sources} },
            map { [ File => { file => $_ } ] }
            @{delete $args->{files} or []}

    };

    if (  (ref($args[0])||'') eq 'HASH'  ) {

        $build_sources_in_hash->($args[0]);
        return $args[0];

    }
    ## pass it as is and let any errors bouble
    else {

        my $args = {@args};
        $build_sources_in_hash->($args);

        return $args;

    }

};

1;
