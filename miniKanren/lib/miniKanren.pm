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

sub prepare {
  my $self = shift;
  unshift @_, @{$self->{args}} if defined $self->{args} && @{$self->{args}};
  return @_;
}

sub reduce {
  my $self = shift;
  my ($array, $iterator, $memo, $context) = $self->repare(@_);

  die 'No list or memo' if !defined $array && !defined $memo;

  return $memo unless defined $array;

  my $initial = defined $memo;

  foreach (@$array) {
      if (!$initial && defined $_) {
          $memo = $_;
          $initial = 1;
      } else {
          $memo = $iterator->($memo, $_, $context) if defined $_;
      }
    }
    die 'No memo' if !$initial;
    return $self->_finalize($memo);
}

sub find_in_pairs {
  my $self = shift;
  my ($key, $pairs) = $self->prepare(@_);
  return reduce($pairs, &{ sub { return $_[1] == $key ? $_[1] : $_[0]} }(), false);
}
#xxx
sub walk {
  return $_[1] unless (ref $_[0] eq "Array") #xxx This can't be right
  my $a = find_in_pairs($_[0], $_[1]);
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

sub eql {
  my ($u, $v) = @_;
    my $s = unify($u, $v, $s);
}

1;
