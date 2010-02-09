package MooseX::ClassAttribute::Role::Meta::Application::ToRole;

use strict;
use warnings;

use Moose::Util::MetaRole;
use MooseX::ClassAttribute::Role::Meta::Application::ToClass;
use MooseX::ClassAttribute::Role::Meta::Application::ToInstance;

use namespace::autoclean;
use Moose::Role;

with 'MooseX::ClassAttribute::Role::Meta::Application';

sub apply_class_attributes {
    my $self  = shift;
    my $role1 = shift;
    my $role2 = shift;

    $role2 = Moose::Util::MetaRole::apply_metaclass_roles(
        for            => $role2,
        role_metaroles => {
            role => ['MooseX::ClassAttribute::Role::Meta::Role'],
            application_to_class =>
                ['MooseX::ClassAttribute::Role::Meta::Application::ToClass'],
            application_to_role =>
                ['MooseX::ClassAttribute::Role::Meta::Application::ToRole'],
            application_to_instance => [
                'MooseX::ClassAttribute::Role::Meta::Application::ToInstance'
            ],
        },
    );

    foreach my $attribute_name ( $role1->get_class_attribute_list() ) {
        if (   $role2->has_class_attribute($attribute_name)
            && $role2->get_class_attribute($attribute_name)
            != $role1->get_class_attribute($attribute_name) ) {

            require Moose;
            Moose->throw_error( "Role '"
                    . $role1->name()
                    . "' has encountered a class attribute conflict "
                    . "during composition. This is fatal error and cannot be disambiguated."
            );
        }
        else {
            $role2->add_class_attribute(
                $role1->get_class_attribute($attribute_name)->clone() );
        }
    }
}

1;
