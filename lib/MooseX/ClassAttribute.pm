package MooseX::ClassAttribute;

use strict;
use warnings;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:DROLSKY';

our @EXPORT = 'class_has'; ## no critic ProhibitAutomaticExportation
use Exporter qw( import );

use B qw( svref_2object );
use Sub::Name;


sub class_has ## no critic RequireArgUnpacking
{
    my $caller = caller();

    my $caller_meta = $caller->meta();

    my @parents = $caller_meta->superclasses();

    my $container_pkg = _make_container_class( $caller, @parents );

    my $has = $container_pkg->can('has');
    $has->(@_);

    my $container_meta = $container_pkg->meta();
    for my $meth ( grep { $_ ne 'instance' } $container_meta->get_method_list() )
    {
        next if $caller_meta->has_method($meth);

        my $sub = sub { shift;
                        my $instance = $container_pkg->instance();
                        return $instance->$meth(@_); };

        $caller_meta->add_method( $meth => $sub );
    }

    return;
}

{
    # This should probably be an attribute of the metaclass, but that
    # would require extending Moose::Meta::Class, which would conflict
    # with anything else that wanted to do so as well (we need
    # metaclass roles or something).
    my %Name;

    sub _make_container_class ## no critic RequireArgUnpacking
    {
        my $caller  = shift;

        return $Name{$caller} if $Name{$caller};

        my @parents = map { container_class($_) || () } @_;

        my $container_pkg = 'MooseX::ClassAttribute::Container::' . $caller;

        my $code = "package $container_pkg;\n";
        $code .= "use Moose;\n\n";

        if (@parents)
        {
            $code .= "extends qw( @parents );\n";
        }

        $code .= <<'EOF';

my $Self;
sub instance
{
    return $Self ||= shift->new(@_);
}
EOF


        eval $code; ## no critic ProhibitStringyEval
        die $@ if $@;

        return $Name{$caller} = $container_pkg;
    }

    sub container_class
    {
        my $pkg = shift || caller();

        return $Name{$pkg};
    }
}

# This is basically copied from Moose.pm
sub unimport ## no critic RequireFinalReturn
{
    my $caller = caller();

    no strict 'refs'; ## no critic ProhibitNoStrict
    foreach my $name (@EXPORT)
    {
        if ( defined &{ $caller . '::' . $name } )
        {
            my $keyword = \&{ $caller . '::' . $name };

            my $pkg_name =
                eval { svref_2object($keyword)->GV()->STASH()->NAME() };

            next if $@;
            next if $pkg_name ne __PACKAGE__;

            delete ${ $caller . '::' }{$name};
        }
    }
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
    MooseX::ClassAttribute::containing_class()->meta()->make_immutable();

    no Moose;
    no MooseX::ClassAttribute;

    # then later ...

    My::Class->Cache()->{thing} = ...;


=head1 DESCRIPTION

This module allows you to declare class attributes in exactly the same
way as you declare object attributes, except using C<class_has()>
instead of C<has()>. It is also possible to make these attributes
immutable (and faster) just as you can with normal Moose attributes.

You can use any feature of Moose's attribute declarations, including
overriding a parent's attributes, delegation (C<handles>), and
attribute metaclasses, and it should just work.

The accessors methods for class attribute may be called on the class
directly, or on objects of that class. Passing a class attribute to
the constructor will not set it.

=head1 FUNCTIONS

This class exports one function when you use it, C<class_has()>. This
works exactly like Moose's C<has()>, but it declares class attributes.

Own little nit is that if you include C<no Moose> in your class, you
won't remove the C<class_has()> function. To do that you must include
C<no MooseX::ClassAttribute> as well.

=head2 Implementation and Immutability

Underneath the hood, this class creates one new class for each class
which has class attributes and sets up delegating methods in the class
for which you're creating class attributes. You don't need to worry
about this too much, except when it comes to making a class immutable.

Since the class attributes are not really stored in your class, you
need to make the containing class immutable as well as your own ...

  __PACKAGE__->meta()->make_immutable();
  MooseX::ClassAttribute::containing_class()->meta()->make_immutable();

I<This may change in the future!>

=head1 AUTHOR

Dave Rolsky, C<< <autarch@urth.org> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-moosex-classattribute@rt.cpan.org>, or through the web interface
at L<http://rt.cpan.org>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 COPYRIGHT & LICENSE

Copyright 2007 Dave Rolsky, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
