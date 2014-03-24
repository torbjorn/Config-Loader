package Config::Loader::Source::Files;

use Moo;
extends 'Config::Loader::Source::Merged';

## create a 'sources' from supplied 'files' that ::Merged would accept
##
## Technically this doesn't prevent other sources, and technically
## there is no need to, so its available if someone wants to take the
## trouble, but we help loading files
sub BUILDARGS {
    my ($class, @args) = @_;

    my $build_sources_in_hash = sub {

        my $args = shift;

        $args->{sources} //= [];

        ## add real sources from 'files' input
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
