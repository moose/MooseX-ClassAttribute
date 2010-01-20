package SharedTests;

use strict;
use warnings;

use Scalar::Util qw( isweak );
use Test::More;

use vars qw($Lazy);
$Lazy = 0;

our %Attrs = (
    ObjectCount => {
        is      => 'rw',
        isa     => 'Int',
        default => 0,
    },
    WeakAttribute => {
        is       => 'rw',
        isa      => 'Object',
        weak_ref => 1,
    },
    LazyAttribute => {
        is   => 'rw',
        isa  => 'Int',
        lazy => 1,
        # The side effect is used to test that this was called
        # lazily.
        default => sub { $Lazy = 1 },
    },
    ReadOnlyAttribute => {
        is      => 'ro',
        isa     => 'Int',
        default => 10,
    },
    ManyNames => {
        is        => 'rw',
        isa       => 'Int',
        reader    => 'M',
        writer    => 'SetM',
        clearer   => 'ClearM',
        predicate => 'HasM',
    },
    Delegatee => {
        is      => 'rw',
        isa     => 'Delegatee',
        handles => [ 'units', 'color' ],
        # if it's not lazy it makes a new object before we define
        # Delegatee's attributes.
        lazy    => 1,
        default => sub { Delegatee->new() },
    },
    Mapping => {
        traits  => ['Hash'],
        is      => 'rw',
        isa     => 'HashRef[Str]',
        default => sub { {} },
        handles => {
            'ExistsInMapping' => 'exists',
            'IdsInMapping'    => 'keys',
            'GetMapping'      => 'get',
            'SetMapping'      => 'set',
        },
    },
    Built => {
        is      => 'ro',
        builder => '_BuildIt',
    },
    LazyBuilt => {
        is      => 'ro',
        lazy    => 1,
        builder => '_BuildIt',
    },
    Triggerish => {
        is      => 'rw',
        trigger => sub { shift->_CallTrigger(@_) },
    },
);

{
    package HasClassAttribute;

    use Moose qw( has );
    use MooseX::ClassAttribute;

    while ( my ( $name, $def ) = each %SharedTests::Attrs ) {
        class_has $name => %{$def};
    }

    has 'size' => (
        is      => 'rw',
        isa     => 'Int',
        default => 5,
    );

    no Moose;

    sub BUILD {
        my $self = shift;

        $self->ObjectCount( $self->ObjectCount() + 1 );
    }

    sub _BuildIt {42}

    our @Triggered;

    sub _CallTrigger {
        push @Triggered, [@_];
    }

    sub make_immutable {
        my $class = shift;

        $class->meta()->make_immutable();
        Delegatee->meta()->make_immutable();
    }
}

{
    package Delegatee;

    use Moose;

    has 'units' => (
        is      => 'ro',
        default => 5,
    );

    has 'color' => (
        is      => 'ro',
        default => 'blue',
    );

    no Moose;
}

{
    package Child;

    use Moose;
    use MooseX::ClassAttribute;

    extends 'HasClassAttribute';

    class_has '+ReadOnlyAttribute' => ( default => 30 );

    class_has 'YetAnotherAttribute' => (
        is      => 'ro',
        default => 'thing',
    );

    no Moose;
}

sub run_tests {
    local $Test::Builder::Level = $Test::Builder::Level + 1;

    {
        is(
            HasClassAttribute->ObjectCount(), 0,
            'ObjectCount() is 0'
        );

        my $hca1 = HasClassAttribute->new();
        is(
            $hca1->size(), 5,
            'size is 5 - object attribute works as expected'
        );
        is(
            HasClassAttribute->ObjectCount(), 1,
            'ObjectCount() is 1'
        );

        my $hca2 = HasClassAttribute->new( size => 10 );
        is(
            $hca2->size(), 10,
            'size is 10 - object attribute can be set via constructor'
        );
        is(
            HasClassAttribute->ObjectCount(), 2,
            'ObjectCount() is 2'
        );
        is(
            $hca2->ObjectCount(), 2,
            'ObjectCount() is 2 - can call class attribute accessor on object'
        );
    }

    {
        my $hca3 = HasClassAttribute->new( ObjectCount => 20 );
        is(
            $hca3->ObjectCount(), 3,
            'class attributes passed to the constructor do not get set in the object'
        );
        is(
            HasClassAttribute->ObjectCount(), 3,
            'class attributes are not affected by constructor params'
        );
    }

    {
        my $object = bless {}, 'Thing';

        HasClassAttribute->WeakAttribute($object);

        undef $object;

        ok(
            !defined HasClassAttribute->WeakAttribute(),
            'weak class attributes are weak'
        );
    }

    {
        is(
            $SharedTests::Lazy, 0,
            '$SharedTests::Lazy is 0'
        );

        is(
            HasClassAttribute->LazyAttribute(), 1,
            'HasClassAttribute->LazyAttribute() is 1'
        );

        is(
            $SharedTests::Lazy, 1,
            '$SharedTests::Lazy is 1 after calling LazyAttribute'
        );
    }

    {
        eval { HasClassAttribute->ReadOnlyAttribute(20) };
        like(
            $@, qr/\QCannot assign a value to a read-only accessor/,
            'cannot set read-only class attribute'
        );
    }

    {
        is(
            Child->ReadOnlyAttribute(), 30,
            q{Child class can extend parent's class attribute}
        );
    }

    {
        ok(
            !HasClassAttribute->HasM(),
            'HasM() returns false before M is set'
        );

        HasClassAttribute->SetM(22);

        ok(
            HasClassAttribute->HasM(),
            'HasM() returns true after M is set'
        );
        is(
            HasClassAttribute->M(), 22,
            'M() returns 22'
        );

        HasClassAttribute->ClearM();

        ok(
            !HasClassAttribute->HasM(),
            'HasM() returns false after M is cleared'
        );
    }

    {
        isa_ok(
            HasClassAttribute->Delegatee(), 'Delegatee',
            'has a Delegetee object'
        );
        is(
            HasClassAttribute->units(), 5,
            'units() delegates to Delegatee and returns 5'
        );
    }

    {
        my @ids = HasClassAttribute->IdsInMapping();
        is(
            scalar @ids, 0,
            'there are no keys in the mapping yet'
        );

        ok(
            !HasClassAttribute->ExistsInMapping('a'),
            'key does not exist in mapping'
        );

        HasClassAttribute->SetMapping( a => 20 );

        ok(
            HasClassAttribute->ExistsInMapping('a'),
            'key does exist in mapping'
        );

        is(
            HasClassAttribute->GetMapping('a'), 20,
            'value for a in mapping is 20'
        );
    }

    {
        is(
            HasClassAttribute->Built(), 42,
            'attribute with builder works'
        );

        is(
            HasClassAttribute->LazyBuilt(), 42,
            'attribute with lazy builder works'
        );
    }

    {
        HasClassAttribute->Triggerish(42);
        is( scalar @HasClassAttribute::Triggered, 1, 'trigger was called' );
        is( HasClassAttribute->Triggerish(), 42, 'Triggerish is now 42' );

        HasClassAttribute->Triggerish(84);
        is( HasClassAttribute->Triggerish(), 84, 'Triggerish is now 84' );

        is_deeply(
            \@HasClassAttribute::Triggered,
            [
                [qw( HasClassAttribute 42 )],
                [qw( HasClassAttribute 84 42 )],
            ],
            'trigger passes old value correctly'
        );
    }

    done_testing();
}

1;
