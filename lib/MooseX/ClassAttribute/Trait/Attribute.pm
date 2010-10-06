package MooseX::ClassAttribute::Trait::Attribute;

use strict;
use warnings;

use namespace::autoclean;
use Moose::Role;

# This is the worst role evar! Really, this should be a subclass,
# because it overrides a lot of behavior. However, as a subclass it
# won't cooperate with _other_ subclasses.

around '_process_options' => sub {
    my $orig    = shift;
    my $class   = shift;
    my $name    = shift;
    my $options = shift;

    confess 'A class attribute cannot be required'
        if $options->{required};

    return $class->$orig( $name, $options );
};

around attach_to_class => sub {
    my $orig = shift;
    my $self = shift;
    my $meta = shift;

    $self->$orig($meta);

    $self->_initialize($meta)
        unless $self->is_lazy();
};

around 'detach_from_class' => sub {
    my $orig = shift;
    my $self = shift;
    my $meta = shift;

    $self->clear_value($meta);

    $self->$orig($meta);
};

sub _initialize {
    my $self      = shift;
    my $metaclass = shift;

    if ( $self->has_default() ) {
        $self->set_value( undef, $self->default() );
    }
    elsif ( $self->has_builder() ) {
        $self->set_value( undef, $self->_call_builder( $metaclass->name() ) );
    }
}

around 'default' => sub {
    my $orig = shift;
    my $self = shift;

    my $default = $self->$orig();

    if ( $self->is_default_a_coderef() ) {
        return $default->( $self->associated_class() );
    }

    return $default;
};

around '_call_builder' => sub {
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

around 'set_value' => sub {
    shift;
    my $self = shift;
    shift;    # ignoring instance or class name
    my $value = shift;

    $self->associated_class()
        ->set_class_attribute_value( $self->name() => $value );
};

around 'get_value' => sub {
    shift;
    my $self = shift;

    return $self->associated_class()
        ->get_class_attribute_value( $self->name() );
};

around 'has_value' => sub {
    shift;
    my $self = shift;

    return $self->associated_class()
        ->has_class_attribute_value( $self->name() );
};

around 'clear_value' => sub {
    shift;
    my $self = shift;

    return $self->associated_class()
        ->clear_class_attribute_value( $self->name() );
};

around 'inline_get' => sub {
    shift;
    my $self = shift;

    return $self->associated_class()
        ->inline_get_class_slot_value( $self->slots() );
};

around 'inline_set' => sub {
    shift;
    my $self  = shift;
    shift;
    my $value = shift;

    my $meta = $self->associated_class();

    my $code
        = $meta->inline_set_class_slot_value( $self->slots(), $value ) . ";";
    $code
        .= $meta->inline_weaken_class_slot_value( $self->slots(), $value )
        . "    if ref $value;"
        if $self->is_weak_ref();

    return $code;
};

around 'inline_has' => sub {
    shift;
    my $self = shift;

    return $self->associated_class()
        ->inline_is_class_slot_initialized( $self->slots() );
};

around 'inline_clear' => sub {
    shift;
    my $self = shift;

    return $self->associated_class()
        ->inline_deinitialize_class_slot( $self->slots() );
};

1;

# ABSTRACT: A trait for class attributes

__END__

=pod

=head1 DESCRIPTION

This role modifies the behavior of class attributes in various
ways. It really should be a subclass of C<Moose::Meta::Attribute>, but
if it were then it couldn't be combined with other attribute
metaclasses, like C<MooseX::AttributeHelpers>.

There are no new public methods implemented by this role. All it does
is change the behavior of a number of existing methods.

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=cut
