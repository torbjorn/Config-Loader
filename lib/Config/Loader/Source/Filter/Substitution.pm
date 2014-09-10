package Config::Loader::Source::Filter::Substitution;

use Moo;
use MooX::HandlesVia;

has substitutions => (
    is => 'ro',
    default => sub { {} },
);

with 'Config::Loader::SourceRole::Filter';

## @_ = ($self, $cfg)
## $cfg is the result of calling load_config on $self->source
sub filter_config {

    my ($self,$cfg) = (shift,shift);

    my $matcher = join( '|', keys %{$self->substitutions} );

    for ( values %$cfg ) {
        s{__($matcher)(?:\((.+?)\))?__}{ $self->substitutions->{$1}->( $self, $2 ? split( /,/, $2 ) : () ) }eg;
    }

    return $cfg;

}

1;
