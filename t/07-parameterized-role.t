use strict;
use warnings;
use Test::More;
use Test::Exception;

BEGIN {
    unless (eval { require MooseX::Role::Parameterized }) {
        plan skip_all => 'This test needs MooseX::Role::Parameterized';
    }
}

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

done_testing;
