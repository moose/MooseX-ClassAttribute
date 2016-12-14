use strict;
use warnings;

use lib 't/lib';

use SharedTests;
use Test::More 0.88;

HasClassAttribute->meta()->make_immutable();
Child->meta()->make_immutable();

SharedTests::run_tests();

done_testing();
