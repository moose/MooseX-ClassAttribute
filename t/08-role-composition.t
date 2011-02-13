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

    with( 'Role2', 'Role' );
}

ok(
    Bar->can('CA'),
    'Class attributes are preserved during role composition'
);

done_testing();
