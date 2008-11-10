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
        $self->set_value( undef, $self->default() );
    }
    elsif ( $self->has_builder() )
    {
        $self->set_value( undef, $self->_call_builder() );
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
    my $self     = shift;
    shift; # ignoring instance or class name
    my $value    = shift;

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

__END__

=pod

=head1 NAME

MooseX::ClassAttribute::Role::Meta::Attribute - An attribute role for classes with class attributes

=head1 DESCRIPTION

This role modifies the behavior of class attributes in various
ways. It really should be a subclass of C<Moose::Meta::Attribute>, but
if it were then it couldn't be combined with other attribute
metaclasses, like C<MooseX::AttributeHelpers>.

There are no new public methods implemented by this role. All it does
is change the behavior of a number of existing methods.

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=head1 COPYRIGHT & LICENSE

Copyright 2007-2008 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut


