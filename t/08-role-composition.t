use strict;
use warnings;

use Test::More;

{
    package Role;

    use Moose::Role;
    use MooseX::ClassAttribute;

    class_has 'CA' => (
        is      => 'ro',
        isa     => 'HashRef',
        default => sub { {} },
    );
}

{
    package Role2;
    use Moose::Role;
}

{
    package Bar;
    use Moose;

    with 'Role2', 'Role';
}

ok(
    Bar->can('CA'),
    'Class attributes are preserved during role composition'
);

{
    package Role3;
    use Moose::Role;
    with 'Role';
}

{
    package Baz;
    use Moose;

    with 'Role3';
}

ok(
    Baz->can('CA'),
    'Class attributes are preserved when role is applied to another role'
);

done_testing();
