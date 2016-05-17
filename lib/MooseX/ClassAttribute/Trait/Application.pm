package MooseX::ClassAttribute::Trait::Application;

use strict;
use warnings;

our $VERSION = '0.28';

use namespace::autoclean;
use Moose::Role;

after apply_attributes => sub {
    shift->_apply_class_attributes(@_);
};

1;

# ABSTRACT: A trait that supports role application for roles with class attributes

__END__

=pod

=head1 DESCRIPTION

This trait is used to allow the application of roles containing class
attributes.

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=cut
