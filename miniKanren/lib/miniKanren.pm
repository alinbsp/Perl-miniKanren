use strict;
use warnings;
package miniKanren;

use base 'Exporter';
our @EXPORT = qw(run var);

sub run {
}

sub var {
  my @var = shift;
  return @var;
}

1;
