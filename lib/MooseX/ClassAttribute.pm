package MooseX::ClassAttribute;

use strict;
use warnings;

our $VERSION = '0.05';
our $AUTHORITY = 'cpan:DROLSKY';

use Moose ();
use Moose::Exporter;
use MooseX::ClassAttribute::Role::Meta::Class;
use MooseX::ClassAttribute::Role::Meta::Attribute;

Moose::Exporter->setup_import_methods
    ( with_caller => [ 'class_has' ] );


sub init_meta
{
    shift;
    my %p = @_;

    Moose->init_meta(%p);

    return
        Moose::Util::MetaRole::apply_metaclass_roles
            ( for_class       => $p{for_class},
              metaclass_roles => [ 'MooseX::ClassAttribute::Role::Meta::Class' ],
            );
}

sub class_has
{
    my $caller  = shift;
    my $name    = shift;
    my %options = @_;

    my $attrs = ref $name eq 'ARRAY' ? $name : [$name];

    Class::MOP::Class
            ->initialize($caller)
            ->add_class_attribute( $_, %options )
                for @{ $attrs };
}

1;

__END__

=pod

=head1 NAME

MooseX::ClassAttribute - Declare class attributes Moose-style

=head1 SYNOPSIS

    package My::Class;

    use Moose;
    use MooseX::ClassAttribute;

    class_has 'Cache' =>
        ( is      => 'rw',
          isa     => 'HashRef',
          default => sub { {} },
        );

    __PACKAGE__->meta()->make_immutable();

    no Moose;
    no MooseX::ClassAttribute;

    # then later ...

    My::Class->Cache()->{thing} = ...;


=head1 DESCRIPTION

This module allows you to declare class attributes in exactly the same
way as object attributes, using C<class_has()> instead of C<has()>.

You can use any feature of Moose's attribute declarations, including
overriding a parent's attributes, delegation (C<handles>), and
attribute metaclasses, and it should just work. The one exception is
the "required" flag, which is not allowed for class attributes.

The accessor methods for class attribute may be called on the class
directly, or on objects of that class. Passing a class attribute to
the constructor will not set it.

=head1 FUNCTIONS

This class exports one function when you use it, C<class_has()>. This
works exactly like Moose's C<has()>, but it declares class attributes.

One little nit is that if you include C<no Moose> in your class, you
won't remove the C<class_has()> function. To do that you must include
C<no MooseX::ClassAttribute> as well.

=head2 Implementation and Immutability

This module will add a role to your class's metaclass, See
L<MooseX::ClassAttribute::Role::Meta::Class> for details. This role
provides introspection methods for class attributes.

Class attributes themselves do the
L<MooseX::ClassAttribute::Role::Meta::Attribute> role.

There is also a L<MooseX::ClassAttribute::Meta::Method::Accessor>
which provides part of the inlining implementation for class
attributes.

=head2 Cooperation with Metaclasses and Traits

This module should work with most attribute metaclasses and traits,
but it's possible that conflicts could occur. This module has been
tested to work with C<MooseX::AttributeHelpers>.

=head1 DONATIONS

If you'd like to thank me for the work I've done on this module,
please consider making a "donation" to me via PayPal. I spend a lot of
free time creating free software, and would appreciate any support
you'd care to offer.

Please note that B<I am not suggesting that you must do this> in order
for me to continue working on this particular software. I will
continue to do so, inasmuch as I have in the past, for as long as it
interests me.

Similarly, a donation made in this way will probably not make me work
on this software much more, unless I get so many donations that I can
consider working on free software full time, which seems unlikely at
best.

To donate, log into PayPal and send money to autarch@urth.org or use
the button on this page:
L<http://www.urth.org/~autarch/fs-donation.html>

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-moosex-classattribute@rt.cpan.org>, or through the web interface
at L<http://rt.cpan.org>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007-2008 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
