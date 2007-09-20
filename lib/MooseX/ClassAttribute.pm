package MooseX::ClassAttribute;

use warnings;
use strict;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:DROLSKY';

use Moose;
use MooseX::ClassAttribute::Meta::Method::Accessor;

extends 'Moose::Meta::Attribute';

sub accessor_metaclass { 'MooseX::ClassAttribute::Meta::Method::Accessor' }

# This is called when an object is constructed.
sub initialize_instance_slot
{
    return;
}


# This is the bit of magic that lets you specify the metaclass as
# 'ClassAttribute', rather than the full name, when creating an
# attribute.
package Moose::Meta::Attribute::Custom::ClassAttribute;

sub register_implementation { 'MooseX::ClassAttribute' }


1;

__END__

=pod

=head1 NAME

MooseX::ClassAttribute - The fantastic new MooseX::ClassAttribute!

=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use MooseX::ClassAttribute;

    my $foo = MooseX::ClassAttribute->new();

    ...

=head1 METHODS

This class provides the following methods

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-moosex-classattribute@rt.cpan.org>,
or through the web interface at L<http://rt.cpan.org>.  I will be
notified, and then you'll automatically be notified of progress on
your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
