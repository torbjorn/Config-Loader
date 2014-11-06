package Config::Loader::Source::FileFromEnv;

use Moo;
use MooX::HandlesVia;
use Config::Loader ();

has name => qw/is ro required 1/;
has env_lookup => (
   is => 'ro',
   ## puts it in an array if its not already
   coerce => sub { ref $_[0] eq "ARRAY" && $_[0] || [$_[0]] },
   default => sub { [] },
);
has no_env => qw/is ro/;

sub _env_lookup {

    my $self = shift;

    return if $self->no_env;

    my @suffix = @_;

    my $name = $self->name;
    my @lookups = grep defined, $self->name, @{ $self->env_lookup };

    for my $prefix (@lookups) {
        my $value = _env($prefix, @suffix);
        return $value if defined $value;
    }

    return;
}

sub _env (@) {
    my $key = uc join "_", @_;
    $key =~ s/::/_/g;
    $key =~ s/\W/_/g;
    return $ENV{$key};
}

sub path {
    shift->_env_lookup('CONFIG')
}

sub suffix {
    shift->_env_lookup('CONFIG_LOCAL_SUFFIX')
}

sub load_config {

    my $self = shift;

    return {
        file   => $self->path,
        suffix => $self->suffix,
    };

}

1;
