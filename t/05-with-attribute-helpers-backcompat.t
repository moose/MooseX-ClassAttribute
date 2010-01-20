use strict;
use warnings;

use Test::More;

BEGIN {
    eval "use MooseX::AttributeHelpers 0.13;";
    plan skip_all => 'This test requires MooseX::AttributeHelpers 0.13+'
        if $@;
}

{
    package MyClass;

    use Moose;
    use MooseX::ClassAttribute;
    use MooseX::AttributeHelpers;

    class_has counter =>
        ( metaclass => 'Counter',
          is        => 'ro',
          provides  => { inc => 'inc_counter',
                       },
        );
}

is( MyClass->counter(), 0 );

MyClass->inc_counter();
is( MyClass->counter(), 1 );

done_testing();
