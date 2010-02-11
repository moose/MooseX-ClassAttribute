package MooseX::ClassAttribute::Trait::Application::ToRole;

use strict;
use warnings;

our $VERSION   = '0.13';

use Moose::Util::MetaRole;
use MooseX::ClassAttribute::Trait::Application::ToClass;

use namespace::autoclean;
use Moose::Role;

with 'MooseX::ClassAttribute::Trait::Application';

sub _apply_class_attributes {
    my $self  = shift;
    my $role1 = shift;
    my $role2 = shift;

    $role2 = Moose::Util::MetaRole::apply_metaclass_roles(
        for            => $role2,
        role_metaroles => {
            role => ['MooseX::ClassAttribute::Trait::Role'],
            application_to_class =>
                ['MooseX::ClassAttribute::Trait::Application::ToClass'],
            application_to_role =>
                ['MooseX::ClassAttribute::Trait::Application::ToRole'],
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

__END__

=pod

=head1 NAME

MooseX::ClassAttribute::Trait::Application::ToRole - A trait that supports applying class attributes to roles

=head1 DESCRIPTION

This trait is used to allow the application of roles containing class
attributes to roles.

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=head1 COPYRIGHT & LICENSE

Copyright 2007-2010 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
