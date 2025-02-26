#!/usr/bin/perl
use strict;
use warnings;
use Test::More tests => 8;
use miniKanren qw(var eq conj disj call_fresh);

# Test 1: var() returns a valid logic variable.
my $v = var();
ok($v =~ /^var_\d+$/, "var() returns a valid logic variable");

# Test 2: The eq goal unifies a fresh variable with 42.
my $goal_eq = call_fresh(sub {
    my $x = shift;
    return eq($x, 42);
});
my $result_eq = $goal_eq->({});
ok(@$result_eq == 1, "eq goal returns one solution");
my $sol_eq = $result_eq->[0];
my ($x_var) = keys %$sol_eq;
is($sol_eq->{$x_var}, 42, "eq goal unifies variable with 42");

# Test 3: call_fresh introduces a new variable and unifies it with 99.
my $goal_fresh = call_fresh(sub {
    my $x = shift;
    return eq($x, 99);
});
my $result_fresh = $goal_fresh->({});
ok(@$result_fresh == 1, "call_fresh returns one solution");
my $sol_fresh = $result_fresh->[0];
my ($fresh_var) = keys %$sol_fresh;
is($sol_fresh->{$fresh_var}, 99, "call_fresh unifies variable with 99");

# Test 4: The disj goal returns two solutions.
my $goal_disj = call_fresh(sub {
    my $x = shift;
    return disj(eq($x, 1), eq($x, 2));
});
my $result_disj = $goal_disj->({});
ok(@$result_disj == 2, "disj returns two solutions");
my $sol_disj1 = $result_disj->[0];
my $sol_disj2 = $result_disj->[1];
my ($x_var1) = keys %$sol_disj1;
my ($x_var2) = keys %$sol_disj2;
is($sol_disj1->{$x_var1}, 1, "First disj solution unifies variable with 1");
is($sol_disj2->{$x_var2}, 2, "Second disj solution unifies variable with 2");

done_testing();
