use strict;
use warnings;
use 5.014;

package miniKanren;

use base 'Exporter';
our @EXPORT = qw(run var append fresh eql true false);

use constant false => 0;
use constant true => 1;

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

# my $x = fresh();
# my ($x, $y) = fresh(2);
sub fresh {
  return [] unless $_[0];

  my @fresh = ();
  for my $i (1..$_[0]) {
    push @fresh, [];
  }
  return @fresh;
}

sub eql {}
1;
