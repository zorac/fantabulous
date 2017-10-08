package Fantabulous::Entities::Pseud;

use strict;
use base qw( Fantabulous::Entity );
use constant TABLE => 'pseuds';

sub new {
    my ($self, $values) = @_;

    return $self->SUPER::new([ qw(
        id user_id created updated name
    ) ], $values);
}

1;
