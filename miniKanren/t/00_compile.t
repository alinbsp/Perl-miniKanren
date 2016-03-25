use strict;
use Test::More;

BEGIN { use_ok 'miniKanren' }
use miniKanren;

my $q = fresh;
ok(run($q, eql(true, $q)) ~~ (true), "Run binding");

done_testing();
