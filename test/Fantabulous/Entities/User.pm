package Fantabulous::Entities::User;

use strict;
use base qw( Fantabulous::Entity );
use constant TABLE => 'users';

sub new {
    my ($self, $values) = @_;

    return $self->SUPER::new([ qw(
        id created updated name email salt password
    ) ], $values);
}

1;
