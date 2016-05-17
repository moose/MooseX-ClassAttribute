package MooseX::ClassAttribute;

use strict;
use warnings;

our $VERSION = '0.29';

# This module doesn't really need these pragmas - this is just for the benefit
# of prereq scanning.
use namespace::clean 0.20     ();
use namespace::autoclean 0.11 ();

use Moose 2.00 ();
use Moose::Exporter;
use Moose::Util;
use MooseX::ClassAttribute::Trait::Class;
use MooseX::ClassAttribute::Trait::Role;
use MooseX::ClassAttribute::Trait::Application::ToClass;
use MooseX::ClassAttribute::Trait::Application::ToRole;

Moose::Exporter->setup_import_methods(
    with_meta       => ['class_has'],
    class_metaroles => {
        class => ['MooseX::ClassAttribute::Trait::Class'],
    },
    role_metaroles => {
        role => ['MooseX::ClassAttribute::Trait::Role'],
        application_to_class =>
            ['MooseX::ClassAttribute::Trait::Application::ToClass'],
        application_to_role =>
            ['MooseX::ClassAttribute::Trait::Application::ToRole'],
    },
);

sub class_has {
    my $meta = shift;
    my $name = shift;

    my $attrs = ref $name eq 'ARRAY' ? $name : [$name];

    my %options = ( definition_context => _caller_info(), @_ );

    $meta->add_class_attribute( $_, %options ) for @{$attrs};
}

# Copied from Moose::Util in 2.06
sub _caller_info {
    my $level = @_ ? ( $_[0] + 1 ) : 2;
    my %info;
    @info{qw(package file line)} = caller($level);
    return \%info;
}

1;

# ABSTRACT: Declare class attributes Moose-style

__END__

=pod

=head1 SYNOPSIS

    package My::Class;

    use Moose;
    use MooseX::ClassAttribute;

    class_has 'Cache' =>
        ( is      => 'rw',
          isa     => 'HashRef',
          default => sub { {} },
        );

    __PACKAGE__->meta()->make_immutable();

    no Moose;
    no MooseX::ClassAttribute;

    # then later ...

    My::Class->Cache()->{thing} = ...;

=head1 DESCRIPTION

This module allows you to declare class attributes in exactly the same
way as object attributes, using C<class_has()> instead of C<has()>.

You can use any feature of Moose's attribute declarations, including
overriding a parent's attributes, delegation (C<handles>), attribute traits,
etc. All features should just work. The one exception is the "required" flag,
which is not allowed for class attributes.

The accessor methods for class attribute may be called on the class
directly, or on objects of that class. Passing a class attribute to
the constructor will not set that attribute.

=head1 FUNCTIONS

This class exports one function when you use it, C<class_has()>. This
works exactly like Moose's C<has()>, but it declares class attributes.

One little nit is that if you include C<no Moose> in your class, you won't
remove the C<class_has()> function. To do that you must include C<no
MooseX::ClassAttribute> as well. Or you can just use L<namespace::autoclean>
instead.

=head2 Implementation and Immutability

This module will add a role to your class's metaclass, See
L<MooseX::ClassAttribute::Trait::Class> for details. This role
provides introspection methods for class attributes.

Class attributes themselves do the
L<MooseX::ClassAttribute::Trait::Attribute> role.

=head2 Cooperation with Metaclasses and Traits

This module should work with most attribute metaclasses and traits,
but it's possible that conflicts could occur. This module has been
tested to work with Moose's native traits.

=head2 Class Attributes in Roles

You can add a class attribute to a role. When that role is applied to a class,
the class will have the relevant class attributes added. Note that attribute
defaults will be calculated when the class attribute is composed into the
class.

=cut
