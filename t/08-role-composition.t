use strict;
use warnings;

use Test::More;
use Test::Exception;

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

{
    local $TODO = 'Class attributes are lost during role composition';
    can_ok( 'Bar', 'CA', );
}

done_testing();
