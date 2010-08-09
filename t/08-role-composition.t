use strict;
use warnings;
use Test::More;
use Test::Exception;

lives_ok {
    Bar->new->_connections;
} 'finds a class attribute under role composition';

done_testing;

BEGIN {

package Role;
use Moose::Role;
use MooseX::ClassAttribute;

class_has '_connections' => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
   );

package Role2;
use Moose::Role;

package Bar;
use Moose;

with ('Role2','Role');

}
