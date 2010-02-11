package MooseX::ClassAttribute::Trait::Application::ToClass;

use strict;
use warnings;

our $VERSION   = '0.13';

use namespace::autoclean;
use Moose::Role;

with 'MooseX::ClassAttribute::Trait::Application';

sub _apply_class_attributes {
    my $self  = shift;
    my $role  = shift;
    my $class = shift;

    $class = Moose::Util::MetaRole::apply_metaclass_roles(
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

__END__

=pod

=head1 NAME

MooseX::ClassAttribute::Trait::Application::ToClass - A trait that supports applying class attributes to classes

=head1 DESCRIPTION

This trait is used to allow the application of roles containing class
attributes to classes.

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=head1 COPYRIGHT & LICENSE

Copyright 2007-2010 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
