package MooseX::ClassAttribute::Trait::Role;

use strict;
use warnings;

use MooseX::ClassAttribute::Meta::Role::Attribute;
use Scalar::Util qw( blessed );

use namespace::autoclean;
use Moose::Role;

with 'MooseX::ClassAttribute::Trait::Mixin::HasClassAttributes';

around add_class_attribute => sub {
    my $orig = shift;
    my $self = shift;
    my $attr = (
        blessed $_[0] && $_[0]->isa('Class::MOP::Mixin::AttributeCore')
        ? $_[0]
        : MooseX::ClassAttribute::Meta::Role::Attribute->new(@_)
    );

    $self->$orig($attr);

    return $attr;
};

sub _attach_class_attribute {
    my ( $self, $attribute ) = @_;

    $attribute->attach_to_role($self);
}

1;

__END__

=pod

=head1 NAME

MooseX::ClassAttribute::Trait::Class - A metaclass role for classes with class attributes

=head1 SYNOPSIS

  for my $attr ( HasClassAttributes->meta()->get_all_class_attributes() )
  {
      print $attr->name();
  }

=head1 DESCRIPTION

This role adds awareness of class attributes to a metaclass object. It
provides a set of introspection methods that largely parallel the
existing attribute methods, except they operate on class attributes.

=head1 METHODS

Every method provided by this role has an analogous method in
C<Class::MOP::Class> or C<Moose::Meta::Class> for regular attributes.

=head2 $meta->has_class_attribute($name)

=head2 $meta->get_class_attribute($name)

=head2 $meta->get_class_attribute_list()

=head2 $meta->get_class_attribute_map()

These methods operate on the current metaclass only.

=head2 $meta->add_class_attribute(...)

This accepts the same options as the L<Moose::Meta::Attribute>
C<add_attribute()> method. However, if an attribute is specified as
"required" an error will be thrown.

=head2 $meta->remove_class_attribute($name)

If the named class attribute exists, it is removed from the class,
along with its accessor methods.

=head2 $meta->get_all_class_attributes()

This method returns a list of attribute objects for the class and all
its parent classes.

=head2 $meta->find_class_attribute_by_name($name)

This method looks at the class and all its parent classes for the
named class attribute.

=head2 $meta->get_class_attribute_value($name)

=head2 $meta->set_class_attribute_value($name, $value)

=head2 $meta->set_class_attribute_value($name)

=head2 $meta->clear_class_attribute_value($name)

These methods operate on the storage for class attribute values, which
is attached to the metaclass object.

There's really no good reason for you to call these methods unless
you're doing some deep hacking. They are named as public methods
solely because they are used by other meta roles and classes in this
distribution.

=head2 inline_class_slot_access($name)

=head2 inline_get_class_slot_value($name)

=head2 inline_set_class_slot_value($name, $val_name)

=head2 inline_is_class_slot_initialized($name)

=head2 inline_deinitialize_class_slot($name)

=head2 inline_weaken_class_slot_value($name)

These methods return code snippets for inlining.

There's really no good reason for you to call these methods unless
you're doing some deep hacking. They are named as public methods
solely because they are used by other meta roles and classes in this
distribution.

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=head1 COPYRIGHT & LICENSE

Copyright 2007-2008 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
