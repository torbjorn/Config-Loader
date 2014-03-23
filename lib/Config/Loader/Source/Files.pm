package Config::Loader::Source::Files;

use Moo;
extends 'Config::Loader::Source::Merged';

around BUILDARGS => sub {
    my ($orig, $class) = (shift, shift);

    if (
        (ref($_[0])||'') ne 'HASH' and
        not ( ($_[0]||'') eq 'files' and defined $_[1] ) ) {

        my @sources = map {
            [ File => { file => $_ } ],
        } @_;

        return { sources => \@sources };
    }

    return $class->$orig(@_);
};

1;
