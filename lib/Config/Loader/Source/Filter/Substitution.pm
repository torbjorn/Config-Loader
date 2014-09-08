package Config::Loader::Source::Filter::Substitution;

use Moo;
use MooX::HandlesVia;

has _substitutions => (
    is => 'ro',
    handles_via => 'Hash',
    handles => {
        substitution => 'get',
        substitute => 'set',
        substitutions => 'keys',
    },
    default => sub { {} },
);

with 'Config::Loader::SourceRole::Filter';

# sub substitute { ## CPCL
#     my $self    = shift;
#     my $subs = $c->config->{ 'Plugin::ConfigLoader' }->{ substitutions }
#         || {};
#     $subs->{ HOME }    ||= sub { shift->path_to( '' ); };
#     $subs->{ ENV }    ||=
#         sub {
#             my ( $c, $v ) = @_;
#             if (! defined($ENV{$v})) {
#                 Catalyst::Exception->throw( message =>
#                     "Missing environment variable: $v" );
#                 return "";
#             } else {
#                 return $ENV{ $v };
#             }
#         };
#     $subs->{ path_to } ||= sub { shift->path_to( @_ ); };
#     $subs->{ literal } ||= sub { return $_[ 1 ]; };
#     my $subsre = join( '|', keys %$subs );

#     for ( @_ ) {
#         s{__($subsre)(?:\((.+?)\))?__}{ $subs->{ $1 }->( $c, $2 ? split( /,/, $2 ) : () ) }eg;
#     }
# }
# sub substitute { ## JFDI
#     my $self = shift;

#     my $substitution = $self->_substitution;
#     $substitution->{ HOME }    ||= sub { shift->path_to( '' ); };
#     $substitution->{ path_to } ||= sub { shift->path_to( @_ ); };
#     $substitution->{ literal } ||= sub { return $_[ 1 ]; };
#     my $matcher = join( '|', keys %$substitution );

#     for ( @_ ) {
#         s{__($matcher)(?:\((.+?)\))?__}{ $substitution->{ $1 }->( $self, $2 ? split( /,/, $2 ) : () ) }eg;
#     }
# }

## This gets the config after its loaded
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
