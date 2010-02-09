package MooseX::ClassAttribute::Role::Meta::Application;

use strict;
use warnings;

use namespace::autoclean;
use Moose::Role;

after apply_attributes => sub {
    shift->apply_class_attributes(@_);
};

1;
