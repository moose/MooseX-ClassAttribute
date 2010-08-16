use strict;
use warnings;

use Test::More tests => 3;
use Test::Exception;

use Test::Requires {
    'MooseX::Role::Parameterized' => 0.23, # skip all if not installed
};

{
    package Role;
    use MooseX::Role::Parameterized;
    use MooseX::ClassAttribute;
    
    parameter foo => (is => 'rw');

    role {
        my $p = shift;

        class_has $p => (is => 'rw');
    };

    package Class;
    use Moose;
    with 'Role' => { foo => 'foo' };
}

ok((my $instance = Class->new), 'instance');

lives_and {
    $instance->foo('bar');
    is $instance->foo, 'bar';
} 'used class attribute from parameterized role';

