package MooseX::ClassAttribute::Trait::Application::ToClass;

use strict;
use warnings;

use namespace::autoclean;
use Moose::Role;

with 'MooseX::ClassAttribute::Trait::Application';

sub _apply_class_attributes {
    my $self  = shift;
    my $role  = shift;
    my $class = shift;

    $class = Moose::Util::MetaRole::apply_metaroles(
        for             => $class,
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

# ABSTRACT: A trait that supports applying class attributes to classes

__END__

=pod

=head1 DESCRIPTION

This trait is used to allow the application of roles containing class
attributes to classes.

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=cut
