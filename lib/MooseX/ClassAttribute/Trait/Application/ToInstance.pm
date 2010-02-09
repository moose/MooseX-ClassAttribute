package MooseX::ClassAttribute::Trait::Application::ToInstance;

use strict;
use warnings;

use Class::MOP;

use namespace::autoclean;
use Moose::Role;

after apply => sub {
    shift->apply_class_attributes(@_);
};

sub apply_class_attributes {
    my $self   = shift;
    my $role   = shift;
    my $object = shift;

    my $class = Moose::Util::MetaRole::apply_metaclass_roles(
        for             => ref $object,
        class_metaroles => {
            class => ['MooseX::ClassAttribute::Trait::Class'],
        },
    );

    my $attr_metaclass = $class->attribute_metaclass();

    foreach my $attribute_name ( $role->get_class_attribute_list() ) {
        if (   $class->has_class_attribute($attribute_name)
            && $class->get_class_attribute($attribute_name)
            != $role->get_class_attribute($attribute_name) ) {
            next;
        }
        else {
            $class->add_class_attribute(
                $role->get_class_attribute($attribute_name)
                    ->attribute_for_class($attr_metaclass) );
        }
    }
}

1;
