package MooseX::ClassAttribute::Trait::Role;

use strict;
use warnings;

our $VERSION   = '0.12';

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

MooseX::ClassAttribute::Trait::Role - A trait for roles with class attributes

=head1 SYNOPSIS

  for my $attr ( HasClassAttributes->meta()->get_all_class_attributes() )
  {
      print $attr->name();
  }

=head1 DESCRIPTION

This role adds awareness of class attributes to a role metaclass object. It
provides a set of introspection methods that largely parallel the existing
attribute methods, except they operate on class attributes.

=head1 METHODS

Every method provided by this role has an analogous method in
C<Class::MOP::Class> or C<Moose::Meta::Class> for regular attributes.

=head2 $meta->has_class_attribute($name)

=head2 $meta->get_class_attribute($name)

=head2 $meta->get_class_attribute_list()

These methods are exactly like their counterparts in
L<MooseX::ClassAttribute::Trait::Class>.

=head2 $meta->add_class_attribute(...)

This accepts the same options as the L<Moose::Meta::Attribute>
C<add_attribute()> method. However, if an attribute is specified as
"required" an error will be thrown.

=head2 $meta->remove_class_attribute($name)

If the named class attribute exists, it is removed from the role.

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=head1 COPYRIGHT & LICENSE

Copyright 2007-2010 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
