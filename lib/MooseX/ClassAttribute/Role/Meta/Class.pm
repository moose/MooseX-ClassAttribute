package MooseX::ClassAttribute::Role::Meta::Class;

use strict;
use warnings;

use MooseX::AttributeHelpers;
use MooseX::ClassAttribute::Role::Meta::Attribute;
use Scalar::Util qw( blessed );

use Moose::Role;


has class_attribute_map =>
    ( metaclass => 'Collection::Hash',
      is        => 'ro',
      isa       => 'HashRef[Moose::Meta::Attribute]',
      provides  => { set    => '_add_class_attribute',
                     exists => 'has_class_attribute',
                     get    => 'get_class_attribute',
                     delete => '_remove_class_attribute',
                     keys   => 'get_class_attribute_list',
                   },
      default   => sub { {} },
      reader    => 'get_class_attribute_map',
    );

has _class_attribute_values =>
    ( metaclass => 'Collection::Hash',
      is        => 'ro',
      isa       => 'HashRef',
      provides  => { get    => 'get_class_attribute_value',
                     set    => 'set_class_attribute_value',
                     exists => 'has_class_attribute_value',
                     delete => 'clear_class_attribute_value',
                   },
      lazy      => 1,
      default   => sub { $_[0]->_class_attribute_values_hashref() },
    );


sub add_class_attribute
{
    my $self = shift;

    my $attr =
        blessed $_[0] && $_[0]->isa('Class::MOP::Attribute')
        ? $_[0]
        : $self->_process_class_attribute(@_);

    my $name = $attr->name();

    $self->remove_class_attribute($name)
        if $self->has_class_attribute($name);

    $attr->attach_to_class($self);

    $self->_add_class_attribute( $name => $attr );

    my $e = do { local $@; eval { $attr->install_accessors() }; $@ };

    if ( $e )
    {
        $self->remove_attribute($name);
        die $e;
    }

    return $attr;
}

# It'd be nice if I didn't have to replicate this for class
# attributes, since it's basically just a copy of
# Moose::Meta::Class->_process_attribute
sub _process_class_attribute
{
    my $self = shift;
    my $name = shift;
    my @args = @_;

    @args = %{$args[0]} if scalar @args == 1 && ref($args[0]) eq 'HASH';

    if ($name =~ /^\+(.*)/)
    {
        return $self->_process_inherited_class_attribute( $1, @args );
    }
    else
    {
        return $self->_process_new_class_attribute( $name, @args );
    }
}

sub _process_new_class_attribute
{
    my $self = shift;
    my $name = shift;
    my %p    = @_;

    if ( $p{traits} )
    {
        push @{ $p{traits} },'MooseX::ClassAttribute::Role::Meta::Attribute'
    }
    else
    {
        $p{traits} = [ 'MooseX::ClassAttribute::Role::Meta::Attribute' ];
    }

    return Moose::Meta::Attribute->interpolate_class_and_new( $name, %p );
}

sub _process_inherited_class_attribute
{
    my $self = shift;
    my $name = shift;
    my %p    = @_;

    my $inherited_attr = $self->find_class_attribute_by_name($name);

    (defined $inherited_attr)
        || confess "Could not find an attribute by the name of '$name' to inherit from";

    return $inherited_attr->clone_and_inherit_options(%p);
}

sub remove_class_attribute
{
    my $self = shift;
    my $name = shift;

    (defined $name && $name)
        || confess 'You must provide an attribute name';

    my $removed_attr = $self->get_class_attribute($name);
    return unless $removed_attr;

    $self->_remove_class_attribute($name);

    $removed_attr->remove_accessors();
    $removed_attr->detach_from_class();

    return $removed_attr;
}

sub get_all_class_attributes
{
    my $self = shift;

    my %attrs =
        map { my $meta = Class::MOP::class_of($_);
              $meta && $meta->can('get_class_attribute_map')
              ? %{ $meta->get_class_attribute_map() }
              : ()
            }
        reverse $self->linearized_isa;

    return values %attrs;
}

sub compute_all_applicable_class_attributes
{
    warn 'The compute_all_applicable_class_attributes method has been deprecated.'
        . " Use get_all_class_attributes instead.\n";

    shift->compute_all_applicable_class_attributes(@_);
}

sub find_class_attribute_by_name
{
    my $self = shift;
    my $name = shift;

    foreach my $class ( $self->linearized_isa() )
    {
        my $meta = Class::MOP::class_of($class)
            or next;

        return $meta->get_class_attribute($name)
            if $meta->can('has_class_attribute') && $meta->has_class_attribute($name);
    }

    return;
}

sub _class_attribute_values_hashref
{
    my $self = shift;

    no strict 'refs';
    return \%{ $self->_class_attribute_var_name() };
}

sub _class_attribute_var_name
{
    my $self = shift;

    return $self->name() . q'::__ClassAttributeValues';
}

sub inline_class_slot_access
{
    my $self = shift;
    my $name = shift;

    return '$' . $self->_class_attribute_var_name . '{"' . quotemeta($name) . '"}';
}

sub inline_get_class_slot_value
{
    my $self = shift;
    my $name = shift;

    return $self->inline_class_slot_access($name);
}

sub inline_set_class_slot_value
{
    my $self     = shift;
    my $name     = shift;
    my $val_name = shift;

    return $self->inline_class_slot_access($name) . ' = ' . $val_name;
}

sub inline_is_class_slot_initialized
{
    my $self     = shift;
    my $name     = shift;

    return 'exists ' . $self->inline_class_slot_access($name);
}

sub inline_deinitialize_class_slot
{
    my $self     = shift;
    my $name     = shift;

    return 'delete ' . $self->inline_class_slot_access($name);
}

sub inline_weaken_class_slot_value
{
    my $self     = shift;
    my $name     = shift;

    return 'Scalar::Util::weaken( ' . $self->inline_class_slot_access($name) . ')';
}

no Moose::Role;

1;

__END__

=pod

=head1 NAME

MooseX::ClassAttribute::Role::Meta::Class - A metaclass role for classes with class attributes

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
