package t::lib::TestUtils;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT = qw/test_text permute_roles_except/;

## work test values from test hash:
## args: constructor args
## get: test values
## files: files and/or stems for input as "file"
## true_file_names: files expected to have been found
## expected_files: files to resolve to before load, ex. "_local"
## 		   files added would be visible here
##                 defaults to input files
## title: descriptive text of this test case
## env: key+values to set in %ENV

## Trying to use an object for this.. growing complex now
{
    package TestData;

    use File::Basename;
    use Hash::Merge::Simple qw(merge);
    use Moo;

    has get => ( is => "ro", default => sub {{}} );
    has datafile => ( is => "ro", required => 1 );
    has line => ( is => "ro", required => 1 );
    has title => ( is => "ro", required => 1 );

    has args => ( is => "ro", default => sub {{}} );
    has files => ( is => "ro", default => sub {[]} );
    has true_file_names => ( is => "ro", default => sub{ [] } );
    has expected_files => ( is => "lazy",
                            builder => sub {
                                my $self = shift;
                                return $self->files
                            });

    has sources => ( is => "rw",
                 default => sub { TestBaseClass->_default_sources }
             );
    has env => ( is => "ro", default => sub { {} } );

    sub sources_from {

        my ($self, $what) = (shift,shift);
        $what //= "files";

        if ( $what eq "files" ) {
            $self->sources( [ map [ File => { file => $_ } ], @{$self->files} ] );
        }
        elsif ( $what eq "expected_files" ) {
            $self->sources( [ map [ File => { file => $_ } ], @{$self->expected_files} ] );
        }
        else {
            die "Don't know how to report sources from '$what'";
        }

        return $self->sources;

    }

    sub test_text {

        my $self = shift;

        my($additional) = @_;

        $additional = ' - ' . $additional
            if defined $additional;

        return sprintf(
            '%s, %d: %s%s',
            basename($self->datafile),
            $self->line,
            $self->title,
            $additional||''
        );

    }

    sub compose_args {
        my $self = shift;
        my %extra = @_;
        return merge $self->args, \%extra;
    }

    sub env_mod_hash {
        my $self = shift;
        return %{ $self->env };
    }

    1;
}

## Section for permuted roles testing

{
    ## base class that roles will get applied to
    package TestBaseClass;

    use Moo;
    extends 'Config::Loader::Source::Profile::Default';

    ## need this for some of the roles
    has name => (is => "ro");

}

use Math::Combinatorics qw/combine permute/;
require Role::Tiny;

my @roles_to_test = map {
    "Config::Loader::SourceRole::" . $_
} qw(
        FileFromEnv
        FileHelper
        FileLocalSuffix
);

sub permute_roles_except {

    my( $role ) = @_;

    die "Need a role to exclude" unless defined $role;

    if ( $role !~ /^Config::Loader::SourceRole::/ ) {
        $role = "Config::Loader::SourceRole::" . $role;
    }

    my %h;
    @h{@roles_to_test} = (1)x@roles_to_test;
    unless ( delete $h{$role} ) {
        die "Role must be one of: @roles_to_test\n";
    };

    ## Return permutations of the rest, haven't found anything better
    ## than this

    my @roles = keys %h;
    my @role_combinations = map {
        combine( $_, @roles )
    } 1..(0+@roles);

    ## For each role combination, add $role, and then permute
    my @final_list = map {

        push @$_, $role;
        permute(@$_);

    } @role_combinations;

    unshift @final_list, [$role];

    return @final_list;

}
