package MooseX::ClassAttribute::Meta::Role::Attribute;

use strict;
use warnings;

our $VERSION   = '0.12';

use List::MoreUtils qw( uniq );

use namespace::autoclean;
use Moose;

extends 'Moose::Meta::Role::Attribute';

sub new {
    my ( $class, $name, %options ) = @_;

    $options{traits} = [
        uniq( @{ $options{traits} || [] } ),
        'MooseX::ClassAttribute::Trait::Attribute'
    ];

    return $class->SUPER::new( $name, %options );
}

1;

__END__

=pod

=head1 NAME

MooseX::ClassAttribute::Meta::Role::Attribute - An attribute metaclass for class attributes in roles

=head1 DESCRIPTION

This class overrides L<Moose::Meta::Role::Attribute> to support class
attribute declaration in roles.

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=head1 COPYRIGHT & LICENSE

Copyright 2007-2010 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
