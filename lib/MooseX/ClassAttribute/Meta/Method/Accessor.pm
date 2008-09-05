package MooseX::ClassAttribute::Meta::Method::Accessor;

use strict;
use warnings;

use Moose;

extends 'Moose::Meta::Method::Accessor';


sub generate_predicate_method_inline
{
    my $attr      = (shift)->associated_attribute;
    my $attr_name = $attr->name;

    my $code =
        eval 'sub {'
        . $attr->associated_class()->inline_is_class_slot_initialized( "'$attr_name'" )
        . '}';

    confess "Could not generate inline predicate because : $@" if $@;

    return $code;
}

sub generate_clearer_method_inline
{
    my $attr          = (shift)->associated_attribute;
    my $attr_name     = $attr->name;
    my $meta_instance = $attr->associated_class->instance_metaclass;

    my $code =
        eval 'sub {'
        . $attr->associated_class()->inline_deinitialize_class_slot( "'$attr_name'" )
        . '}';

    confess "Could not generate inline clearer because : $@" if $@;

    return $code;
}

sub _inline_store
{
    my $self  = shift;
    shift;
    my $value = shift;

    my $attr = $self->associated_attribute();

    my $slot_name = sprintf "'%s'", $attr->slots();

    my $meta = $attr->associated_class();

    my $code = $meta->inline_set_class_slot_value($slot_name, $value)    . ";";
    $code   .= $meta->inline_weaken_class_slot_value($slot_name, $value) . ";"
        if $attr->is_weak_ref();

    return $code;
}

sub _inline_get
{
    my $self  = shift;

    my $attr = $self->associated_attribute;
    my $meta = $attr->associated_class();

    my $slot_name = sprintf "'%s'", $attr->slots;

    return $meta->inline_get_class_slot_value($slot_name);
}

sub _inline_access
{
    my $self  = shift;

    my $attr = $self->associated_attribute;
    my $meta = $attr->associated_class();

    my $slot_name = sprintf "'%s'", $attr->slots;

    return $meta->inline_class_slot_access($slot_name);
}

sub _inline_has
{
    my $self = shift;

    my $attr = $self->associated_attribute;
    my $meta = $attr->associated_class();

    my $slot_name = sprintf "'%s'", $attr->slots;

    return $meta->inline_is_class_slot_initialized($slot_name);
}

sub _inline_init_slot
{
    my $self = shift;

    return $self->_inline_store( undef, $_[-1] );
}

sub _inline_check_lazy
{
    my $self = shift;

    return
        $self->SUPER::_inline_check_lazy
            ( q{'} . $self->associated_attribute()->associated_class()->name() . q{'} );
}

no Moose;

1;

=pod

=head1 NAME

MooseX::ClassAttribute::Meta::Method::Accessor - Accessor method generation for class attributes

=head1 DESCRIPTION

This class overrides L<Moose::Meta::Method::Accessor> to do code
generation properly for class attributes.

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=head1 COPYRIGHT & LICENSE

Copyright 2007-2008 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
