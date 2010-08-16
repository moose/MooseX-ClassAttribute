use strict;
use warnings;

use Test::More tests => 2;

use Test::Requires {
    'MooseX::AttributeHelpers' => 0.23, # skip all if not installed
};


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

