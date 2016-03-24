use strict;
use warnings;
use 5.014;

package miniKanren;

use base 'Exporter';
our @EXPORT = qw(run var append);

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

sub append {
  return @_;
}

1;
