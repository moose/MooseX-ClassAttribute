use strict;
use warnings;

use Module::Build;

my $builder = Module::Build->new
    ( module_name         => 'MooseX::ClassAttribute',
      license             => 'perl',
      requires            => { 'Moose'      => 0.57,
                             },
      build_requires      => { 'Scalar::Util' => 0,
                               'Test::More'   => 0,
                             },
      create_makefile_pl  => 'passthrough',
      create_readme       => 1,
      sign                => 1,
    );

$builder->create_build_script();
