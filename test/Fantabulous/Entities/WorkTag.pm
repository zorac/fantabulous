package Fantabulous::Entities::WorkTag;

use strict;
use base qw( Fantabulous::Entity );
use constant TABLE => 'work_tags';

sub new {
    my ($self, $values) = @_;

    return $self->SUPER::new([ qw(
        work_id tag_id position
    ) ], $values);
}

1;
