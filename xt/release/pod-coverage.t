use strict;
use warnings;

use Test::More;

plan skip_all => 'This test is only run for the module author'
    unless -d '.git' || $ENV{IS_MAINTAINER};

eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage"
    if $@;

# This is a stripped down version of all_pod_coverage_ok which lets us
# vary the trustme parameter per module.
my @modules = all_modules();
plan tests => scalar @modules;

my %trustme = (
    'MooseX::ClassAttribute' => [ 'init_meta', 'class_has' ],
    'MooseX::ClassAttribute::Meta::Method::Accessor' => ['.+'],
    'MooseX::ClassAttribute::Meta::Role::Attribute'  => ['new'],
    'MooseX::ClassAttribute::Trait::Class' =>
        ['compute_all_applicable_class_attributes'],
    'MooseX::ClassAttribute::Trait::Mixin::HasClassAttributes' => [
        qw( add_class_attribute get_class_attribute_map remove_class_attribute )
    ],
);

for my $module ( sort @modules ) {
    my $trustme;

    if ( $trustme{$module} ) {
        my $methods = join '|', @{ $trustme{$module} };
        $trustme = [qr/^(?:$methods)/];
    }

    pod_coverage_ok(
        $module, { trustme => $trustme },
        "Pod coverage for $module"
    );
}
