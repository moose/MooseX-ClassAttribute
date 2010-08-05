use strict;
use warnings;
use Test::More;

BEGIN {
    unless (eval { require MooseX::Role::Parameterized }) {
        plan skip_all => 'This test needs MooseX::Role::Parameterized';
    }
}

eval <<'EOF';
    package Role;
    use MooseX::Role::Parameterized;
    use MooseX::ClassAttribute;
    role {};

    package Class;
    use Moose;
    with 'Role';
EOF

ok((not $@), 'used MooseX::ClassAttribute in MooseX::Role::Parameterized role');
diag $@ if $@;

done_testing;
