package Config::Loader::Source::File;

use Config::Any;
use Hash::Merge::Simple qw(merge);
use File::Spec;
use Moo;

use Devel::Dwarn;

with 'Config::Loader::SourceRole::OneArgNew';

sub one_arg_name { 'file' }

has files_loaded => (is => 'rw', default => sub{ [] } );

has file => (is => 'ro', required => 1);
has load_args => (is => 'ro', default => sub { {} });
has load_type => (is => 'lazy', builder => sub {
  (File::Spec->splitpath($_[0]->file))[2] =~ /\./ ? 'files' : 'stems'
});

sub load_config {
  my ($self) = @_;

  my $raw_cfg = $self->_load_config_any;

  ## Sort them based on file name to make it consistent
  $raw_cfg = [ sort {
      (keys %$a)[0] cmp (keys %$b)[0]
  } @$raw_cfg ];

  ## related to stems giving > 1 file
  if ( @$raw_cfg > 1 and not $ENV{CONFIG_LOADER_SOURCE_FILE_MANY_FILES_ALLOW} ) {

      if ( $ENV{CONFIG_LOADER_SOURCE_FILE_MANY_FILES_WARN_ONLY} ) {
          warn sprintf "%s found %d files for stem '%s' - this is most likely not something you want",
              __PACKAGE__, scalar(@$raw_cfg), $self->file;
      }
      else {
          die sprintf "%s found more than 1 file for stem '%s'",
              __PACKAGE__, $self->file;
      }

  }

  ## store the files processed
  $self->files_loaded([ map { keys %$_ } @$raw_cfg ]);

  my $cfg = merge map { values %$_ } @{ $raw_cfg };
  return $cfg || {};
}

sub _load_config_any {
  my ($self) = @_;
  my $cfg = Config::Any->${\"load_${\$self->load_type}"}({
    $self->load_type => [ $self->file ],
    use_ext => (not exists $self->load_args->{force_plugins}),
    %{$self->load_args},
  });
  return $cfg;
}

1;
