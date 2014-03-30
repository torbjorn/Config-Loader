package Config::Loader::SourceRole::Filter;

use Moo::Role;

requires 'filter_config';

has source => (is => 'ro', required => 1);

sub load_config {
  my ($self) = @_;
  return $self->filter_config($self->source->load_config);
}

1;

## Rewrite this? shouldn't require a distinct class to use this, would
## be nice if it would fit on P::D or ::Merged
