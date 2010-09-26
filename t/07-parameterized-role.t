use strict;
use warnings;

use Test::More;
use Test::Exception;

plan skip_all =>
    'This test will not pass without changes to MooseX::Role::Parmeterized';

{
    package Role;

    use MooseX::Role::Parameterized;
    use MooseX::ClassAttribute;

    parameter foo => ( is => 'rw' );

    role {
        my $p = shift;

        class_has $p => ( is => 'rw' );
    };
}

{
    package Class;

    use Moose;

    with 'Role' => { foo => 'foo' };
}

my $instance = Class->new();
isa_ok( $instance, 'Class' );

lives_and {
    $instance->foo('bar');
    is( $instance->foo(), 'bar' );
}
'used class attribute from parameterized role';

done_testing();
