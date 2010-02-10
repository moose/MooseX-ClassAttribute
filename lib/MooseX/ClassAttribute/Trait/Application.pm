package MooseX::ClassAttribute::Trait::Application;

use strict;
use warnings;

our $VERSION   = '0.12';

use namespace::autoclean;
use Moose::Role;

after apply_attributes => sub {
    shift->_apply_class_attributes(@_);
};

1;

__END__

=pod

=head1 NAME

MooseX::ClassAttribute::Trait::Application - A trait that supports role application for roles with class attributes

=head1 DESCRIPTION

This trait is used to allow the application of roles containing class
attributes.

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

See L<MooseX::ClassAttribute> for details.

=head1 COPYRIGHT & LICENSE

Copyright 2007-2010 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
