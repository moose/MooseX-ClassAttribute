package MooseX::ClassAttribute::Meta::Attribute;

use strict;
use warnings;

use MooseX::ClassAttribute::Meta::Method::Accessor;

use Moose;

extends 'Moose::Meta::Attribute';


sub accessor_metaclass { 'MooseX::ClassAttribute::Meta::Method::Accessor' }

sub _process_options
{
    my $class   = shift;
    my $name    = shift;
    my $options = shift;

    confess 'A class attribute cannot be required'
        if $options->{required};

    return $class->SUPER::_process_options( $name, $options );
}

sub attach_to_class
{
    my $self = shift;
    my $meta = shift;

    $self->SUPER::attach_to_class($meta);

    $self->_initialize($meta)
        unless $self->is_lazy();
}

sub detach_from_class
{
    my $self = shift;
    my $meta = shift;

    $self->clear_value($meta);

    $self->SUPER::detach_from_class($meta);
}

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

sub default
{
    my $self = shift;

    my $default = $self->SUPER::default();

    if ( $self->is_default_a_coderef() )
    {
        return $default->( $self->associated_class() );
    }

    return $default;
}

sub _call_builder
{
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
}

sub set_value
{
    my $self  = shift;
    my $value = shift;

    $self->associated_class()->set_class_attribute_value( $self->name() => $value );
}

sub get_value
{
    my $self  = shift;

    return $self->associated_class()->get_class_attribute_value( $self->name() );
}

sub has_value
{
    my $self  = shift;

    return $self->associated_class()->has_class_attribute_value( $self->name() );
}

sub clear_value
{
    my $self  = shift;

    return $self->associated_class()->clear_class_attribute_value( $self->name() );
}

no Moose;

1;
