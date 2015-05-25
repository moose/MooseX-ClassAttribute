package MooseX::ClassAttribute::Meta::Role::Attribute;

use strict;
use warnings;

use namespace::autoclean;
use Moose;

extends 'Moose::Meta::Role::Attribute';

sub new {
    my ( $class, $name, %options ) = @_;

    $options{traits} = [
        _uniq( @{ $options{traits} || [] } ),
        'MooseX::ClassAttribute::Trait::Attribute'
    ];

    return $class->SUPER::new( $name, %options );
}

sub _uniq { keys %{ +{ map { $_ => undef } @_ } } }

1;

# ABSTRACT: An attribute metaclass for class attributes in roles

__END__

=pod

=head1 DESCRIPTION

This class overrides L<Moose::Meta::Role::Attribute> to support class
attribute declaration in roles.

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=cut
