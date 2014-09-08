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

## This gets the object and the config after load
sub filter_config {

    my $self = shift;
    my ($cfg) = @_;

    my $matcher = join( '|', $self->substitutions );

    for ( %$cfg ) {
        s{__($matcher)(?:\((.+?)\))?__}{ $self->substitution($1)->( $self, $2 ? split( /,/, $2 ) : () ) }eg;
    }

    $cfg;

}

1;
