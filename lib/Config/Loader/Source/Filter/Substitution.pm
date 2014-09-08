package Config::Loader::Source::Filter::Substitution;

use Moo;
use MooX::HandlesVia;

has _substitutions => (
    is => 'ro',
    handles_via => 'Hash',
    handles => {
        substitution  => 'get',
        substitute    => 'set',
        substitutions => 'keys',
    },
    default => sub { {} },
);

with 'Config::Loader::SourceRole::Filter';

## @_ = ($self, $cfg)
## $cfg is the result of calling load_config on $self->source
sub filter_config {

    my ($self,$cfg) = (shift,shift);

    my $matcher = join( '|', $self->substitutions );

    for ( values %$cfg ) {
        s{__($matcher)(?:\((.+?)\))?__}{ $self->substitution($1)->( $self, $2 ? split( /,/, $2 ) : () ) }eg;
    }

    return $cfg;

}

1;
