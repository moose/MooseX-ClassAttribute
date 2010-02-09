use strict;
use warnings;

use lib 't/lib';

use SharedTests;
use Test::More;

use Moose::Util qw( apply_all_roles );

{
    package RoleHCA;

    use Moose::Role;
    use MooseX::ClassAttribute;

    while ( my ( $name, $def ) = each %SharedTests::Attrs ) {
        class_has $name => %{$def};
    }
}

{
    package ClassWithRoleHCA;

    use Moose;

    with 'RoleHCA';

    has 'size' => (
        is      => 'rw',
        isa     => 'Int',
        default => 5,
    );

    sub BUILD {
        my $self = shift;

        $self->ObjectCount( $self->ObjectCount() + 1 );
    }

    sub _BuildIt {42}

    sub _CallTrigger {
        push @{ $_[0]->TriggerRecord() }, [@_];
    }
}

SharedTests::run_tests('ClassWithRoleHCA');

# These next tests are aimed at testing to-role application followed by
# to-class application
{
    package RoleWithRoleHCA;

    use Moose::Role;
    use MooseX::ClassAttribute;

    with 'RoleHCA';
}

{
    package ClassWithRoleWithRoleHCA;

    use Moose;

    with 'RoleWithRoleHCA';

    has 'size' => (
        is      => 'rw',
        isa     => 'Int',
        default => 5,
    );

    sub BUILD {
        my $self = shift;

        $self->ObjectCount( $self->ObjectCount() + 1 );
    }

    sub _BuildIt {42}

    sub _CallTrigger {
        push @{ $_[0]->TriggerRecord() }, [@_];
    }
}

SharedTests::run_tests('ClassWithRoleWithRoleHCA');

{
    package InstanceWithRoleHCA;

    use Moose;

    has 'size' => (
        is      => 'rw',
        isa     => 'Int',
        default => 5,
    );

    sub _BuildIt {42}

    sub _CallTrigger {
        push @{ $_[0]->TriggerRecord() }, [@_];
    }
}

my $instance = InstanceWithRoleHCA->new();

apply_all_roles( $instance, 'RoleHCA' );

$instance->ObjectCount(1);

SharedTests::run_tests($instance);

done_testing();
