package Fantabulous::Entities::Chapter;

use strict;
use base qw( Fantabulous::Entity );
use constant TABLE => 'chapters';

sub new {
    my ($self, $values) = @_;

    return $self->SUPER::new([ qw(
        id created updated work_id position name
    ) ], $values);
}

1;
