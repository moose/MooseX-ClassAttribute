package SharedTests;

use strict;
use warnings;

use Scalar::Util qw( isweak );
use Test::More tests => 9;


{
    package HasClassAttribute;

    use Moose;
    use MooseX::ClassAttribute;

    has 'ObjectCount' =>
        ( metaclass => 'ClassAttribute',
          is        => 'rw',
          isa       => 'Int',
          default   => 0,
        );

    has 'WeakAttribute' =>
        ( metaclass => 'ClassAttribute',
          is        => 'rw',
          isa       => 'Object',
          weak_ref  => 1,
        );

    has 'size' =>
        ( is      => 'rw',
          isa     => 'Int',
          default => 5,
        );

    sub BUILD
    {
        my $self = shift;

        $self->ObjectCount( $self->ObjectCount() + 1 );
    }
}

sub run_tests
{
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    {
        is( HasClassAttribute->ObjectCount(), 0,
            'ObjectCount() is 0' );

        my $hca1 = HasClassAttribute->new();
        is( $hca1->size(), 5,
            'size is 5 - object attribute works as expected' );
        is( HasClassAttribute->ObjectCount(), 1,
            'ObjectCount() is 1' );

        my $hca2 = HasClassAttribute->new( size => 10 );
        is( $hca2->size(), 10,
            'size is 10 - object attribute can be set via constructor' );
        is( HasClassAttribute->ObjectCount(), 2,
            'ObjectCount() is 2' );
        is( $hca2->ObjectCount(), 2,
            'ObjectCount() is 2 - can call class attribute accessor on object' );
    }

    {
        eval { HasClassAttribute->new( ObjectCount => 20 ) };
        like( $@, qr/\QCannot set a class attribute via the constructor (ObjectCount)/,
              'passing a class attribute to the constructor throws an error' );
        is( HasClassAttribute->ObjectCount(), 2,
            'class attributes are not affected by constructor params' );
    }

    {
        my $object = bless {}, 'Thing';

        HasClassAttribute->WeakAttribute($object);

        undef $object;

        ok( ! defined HasClassAttribute->WeakAttribute(),
            'weak class attributes are weak' );
    }
}


1;
