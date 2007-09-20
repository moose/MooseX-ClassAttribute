package MooseX::ClassAttribute::Meta::Method::Accessor;

use warnings;
use strict;

our $VERSION = '0.01';
our $AUTHORITY = 'cpan:DROLSKY';

use Moose;

extends 'Moose::Meta::Method::Accessor';


sub _inline_store {
    my $self     = shift;
    my $instance = shift;
    my $value    = shift;

    my $attr = $self->associated_attribute();

    my $mi = $attr->associated_class()->get_meta_instance();
    my $slot_name = $attr->slots();

    my $package_var = sprintf q{$%s::__ClassAttribute{'%s'}}, $attr->associated_class()->name(), $slot_name;

    my $code = "$package_var = $value;";
    $code   .= "Scalar::Util::weaken $package_var;"
        if $attr->is_weak_ref();

    return $code;
}

sub _inline_get {
    my $self     = shift;
    my $instance = shift;

    my $attr = $self->associated_attribute();

    my $mi = $attr->associated_class()->get_meta_instance();
    my $slot_name = $attr->slots();

    return sprintf q{$%s::__ClassAttribute{'%s'}}, $attr->associated_class()->name(), $slot_name;
}


1;
