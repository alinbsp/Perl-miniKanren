package miniKanren;

use strict;
use warnings;
use Exporter 'import';

our @EXPORT_OK = qw(
    var is_var walk ext_s unify
    succeed fail eq conj disj call_fresh
);

our $VERSION = '0.01';

# Global counter for fresh variable names.
my $var_counter = 0;

=head2 var

Generates a fresh logic variable.
  
    my $x = var();

=cut
sub var {
    return "var_" . (++$var_counter);
}

=head2 is_var

Checks if a value is a logic variable (a string beginning with "var_").

    if (is_var($x)) { ... }

=cut
sub is_var {
    my ($x) = @_;
    return (ref($x) eq '' && $x =~ /^var_/);
}

=head2 walk

Recursively resolves a term through the substitution.
  
    my $val = walk($term, $subs);

=cut
sub walk {
    my ($v, $subs) = @_;
    while (is_var($v) && exists $subs->{$v}) {
        $v = $subs->{$v};
    }
    return $v;
}

=head2 ext_s

Extends a substitution with a new mapping.

    my $new_subs = ext_s($var, $val, $subs);

=cut
sub ext_s {
    my ($v, $val, $subs) = @_;
    my %new_subs = %$subs;
    $new_subs{$v} = $val;
    return \%new_subs;
}

=head2 unify

Attempts to unify two terms under a given substitution.
  
    my $new_subs = unify($u, $v, $subs);

=cut
sub unify {
    my ($u, $v, $subs) = @_;
    $u = walk($u, $subs);
    $v = walk($v, $subs);
    if (is_var($u) && is_var($v) && $u eq $v) {
        return $subs;
    }
    if (is_var($u)) {
        return ext_s($u, $v, $subs);
    }
    if (is_var($v)) {
        return ext_s($v, $u, $subs);
    }
    # If both are arrays, unify element-wise.
    if (ref($u) eq 'ARRAY' && ref($v) eq 'ARRAY') {
        return undef unless @$u == @$v;
        for (my $i = 0; $i < @$u; $i++) {
            $subs = unify($u->[$i], $v->[$i], $subs);
            return undef unless defined $subs;
        }
        return $subs;
    }
    # Otherwise, check for equality.
    return ($u eq $v) ? $subs : undef;
}

=head2 succeed

A goal that always succeeds and returns the current state.

=cut
sub succeed {
    return sub {
        my ($state) = @_;
        return [$state];
    };
}

=head2 fail

A goal that always fails, returning an empty list.

=cut
sub fail {
    return sub {
        my ($state) = @_;
        return [];
    };
}

=head2 eq

Creates a goal enforcing the equality of two terms.

    my $goal = eq($u, $v);

=cut
sub eq {
    my ($u, $v) = @_;
    return sub {
        my ($state) = @_;
        my $subs = unify($u, $v, $state);
        return defined $subs ? [$subs] : [];
    };
}

=head2 conj

Combines two goals using logical AND (conjunction).

    my $goal = conj($goal1, $goal2);

=cut
sub conj {
    my ($g1, $g2) = @_;
    return sub {
        my ($state) = @_;
        my $results = [];
        for my $s (@{ $g1->($state) }) {
            push @$results, @{ $g2->($s) };
        }
        return $results;
    };
}

=head2 disj

Combines two goals using logical OR (disjunction).

    my $goal = disj($goal1, $goal2);

=cut
sub disj {
    my ($g1, $g2) = @_;
    return sub {
        my ($state) = @_;
        return [ @{ $g1->($state) }, @{ $g2->($state) } ];
    };
}

=head2 call_fresh

Introduces a new logic variable into the scope of a goal.

    my $goal = call_fresh(sub {
        my $x = shift;
        return eq($x, 5);
    });

=cut
sub call_fresh {
    my ($f) = @_;
    return sub {
        my ($state) = @_;
        my $new_var = var();
        return $f->($new_var)->($state);
    };
}

1;  # End of miniKanren module

__END__

=head1 NAME

miniKanren - A minimal miniKanren-style logic programming library in Perl

=head1 SYNOPSIS

  use miniKanren qw(var eq conj disj call_fresh);
  
  # Example: Find X such that X equals either 5 or 6.
  my $goal = call_fresh(sub {
      my $x = shift;
      return disj(eq($x, 5), eq($x, 6));
  });
  
  my $solutions = $goal->({});
  use Data::Dumper;
  print Dumper($solutions);

=head1 DESCRIPTION

This module provides a minimal implementation of a miniKanren-style logic programming system in Perl.
It supports logic variables, unification, and basic goal combinators, which you can extend to suit your needs.

=head1 FUNCTIONS

=over 4

=item var

Generates a fresh logic variable.

=item is_var

Checks if a given value is a logic variable.

=item walk

Resolves a term through the current substitution.

=item ext_s

Extends a substitution with a new binding.

=item unify

Attempts to unify two terms given a substitution.

=item succeed

A goal that always succeeds.

=item fail

A goal that always fails.

=item eq

Creates a goal that enforces the equality of two terms.

=item conj

Combines two goals in a logical AND.

=item disj

Combines two goals in a logical OR.

=item call_fresh

Introduces a fresh logic variable into a goal.

=back

=head1 AUTHOR

Alin Iacob

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut
