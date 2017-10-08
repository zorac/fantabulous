package Fantabulous::Entities::Series;

use strict;
use base qw( Fantabulous::Entity );
use constant TABLE => 'series';

sub new {
    my ($self, $values) = @_;

    return $self->SUPER::new([ qw(
        id created updated name
    ) ], $values);
}

1;
