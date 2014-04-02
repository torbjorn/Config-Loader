package Config::Loader::SourceRole::FileHelper;

use Moo::Role;
use namespace::clean;

requires qw/sources loader/;

sub _keys_to_propagate {
    return qw/load_args load_type/;
}

## Transform the supplied files => [..] to a sources => [...] that is
## something that ::Merged would accept as sources
##
## Technically this doesn't prevent other sources, and technically
## there is no need to, so this module could load other sources if
## someone wants to take the trouble, but we help loading files only,
## for other sources, the user is on his own
sub BUILDARGS {
    my ($class, @args) = @_;

    my $args;
    if (  (ref($args[0])||'') eq 'HASH'  ) {
        $args = $args[0];
    }
    else {
        $args = {@args};
    }

    ## propagate certain arguments to the File objects
    my %file_arg;
    for (_keys_to_propagate) {
        if ( exists $args->{$_} ) {
            $file_arg{$_} = delete $args->{$_};
        }
    }

    ## modify the hash and setup sources from supplied 'files'
    $args->{sources} //= [];

    push @{ $args->{sources} },
        map { [ File => { %file_arg, file => $_ } ] }
            @{delete $args->{files} or []};

    return $args;

};

sub files_loaded {

    my $self = shift;

    ## Change to Safe::Isa? or check it ourselves?
    return
        map { @{$_->files_loaded} }
        grep { $_->isa("Config::Loader::Source::File") }
        ## This needs to be fixed: P::D may give a Merged or a Filter
        @{ $self->loader->source->source_objects };

}

1;
