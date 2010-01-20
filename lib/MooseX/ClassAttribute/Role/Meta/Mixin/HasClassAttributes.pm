package MooseX::ClassAttribute::Role::Meta::Mixin::HasClassAttributes;

use strict;
use warnings;

use namespace::autoclean;
use Moose::Role;

has _class_attribute_map => (
    traits  => ['Hash'],
    is      => 'ro',
    isa     => 'HashRef[Moose::Meta::Attribute]',
    handles => {
        '_add_class_attribute'     => 'set',
        'has_class_attribute'      => 'exists',
        'get_class_attribute'      => 'get',
        '_remove_class_attribute'  => 'delete',
        'get_class_attribute_list' => 'keys',
    },
    default  => sub { {} },
    init_arg => undef,
);

sub get_class_attribute_map {
    return $_[0]->_class_attribute_map();
}

1;
