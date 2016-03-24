use strict;
use warnings;

package miniKanren;

use base 'Exporter';
our @EXPORT = qw(run var);

sub run {
}

sub var {
  my @res = ();
  if (scalar(@_) > 1) {
    foreach my $x (@_) {
      push @res, $x;
    }
    return @res;
  } else {
    return $_[0];
  }
}

1;
