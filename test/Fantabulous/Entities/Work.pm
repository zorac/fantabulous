package Fantabulous::Entities::Work;

use strict;
use base qw( Fantabulous::Entity );
use constant TABLE => 'works';

sub new {
    my ($self, $values) = @_;

    return $self->SUPER::new([ qw(
        id created updated majorly_updated name
    ) ], $values);
}

1;
