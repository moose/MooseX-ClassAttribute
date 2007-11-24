use strict;
use warnings;

use lib 't/lib';

use SharedTests;

HasClassAttribute->make_immutable();
Child->make_immutable();

SharedTests::run_tests();
