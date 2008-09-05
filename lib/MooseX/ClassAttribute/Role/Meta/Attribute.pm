package MooseX::ClassAttribute::Role::Meta::Attribute;

use strict;
use warnings;

use MooseX::ClassAttribute::Meta::Method::Accessor;

use Moose::Role;

# This is the worst role evar! Really, this should be a subclass,
# because it overrides a lot of behavior. However, as a subclass it
# won't cooperate with _other_ subclasses like
# MX::AttributeHelpers::Base.

around 'accessor_metaclass' => sub
{
    return 'MooseX::ClassAttribute::Meta::Method::Accessor';
};

around '_process_options' => sub
{
    my $orig    = shift;
    my $class   = shift;
    my $name    = shift;
    my $options = shift;

    confess 'A class attribute cannot be required'
        if $options->{required};

    return $class->$orig( $name, $options );
};

around attach_to_class => sub
{
    my $orig = shift;
    my $self = shift;
    my $meta = shift;

    $self->$orig($meta);

    $self->_initialize($meta)
        unless $self->is_lazy();
};

around 'detach_from_class' => sub
{
    my $orig = shift;
    my $self = shift;
    my $meta = shift;

    $self->clear_value($meta);

    $self->$orig($meta);
};

sub _initialize
{
    my $self = shift;

    if ( $self->has_default() )
    {
        $self->set_value( $self->default() );
    }
    elsif ( $self->has_builder() )
    {
        $self->set_value( $self->_call_builder() );
    }
}

around 'default' => sub
{
    my $orig = shift;
    my $self = shift;

    my $default = $self->$orig();

    if ( $self->is_default_a_coderef() )
    {
        return $default->( $self->associated_class() );
    }

    return $default;
};

around '_call_builder' => sub
{
    shift;
    my $self  = shift;
    my $class = shift;

    my $builder = $self->builder();

    return $class->$builder()
        if $class->can( $self->builder );

    confess(  "$class does not support builder method '"
            . $self->builder
            . "' for attribute '"
            . $self->name
            . "'" );
};

around 'set_value' => sub
{
    shift;
    my $self  = shift;
    my $value = shift;

    $self->associated_class()->set_class_attribute_value( $self->name() => $value );
};

around 'get_value' => sub
{
    shift;
    my $self  = shift;

    return $self->associated_class()->get_class_attribute_value( $self->name() );
};

around 'has_value' => sub
{
    shift;
    my $self  = shift;

    return $self->associated_class()->has_class_attribute_value( $self->name() );
};

around 'clear_value' => sub
{
    shift;
    my $self  = shift;

    return $self->associated_class()->clear_class_attribute_value( $self->name() );
};

no Moose::Role;

1;
