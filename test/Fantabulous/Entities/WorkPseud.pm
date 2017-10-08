package Fantabulous::Entities::WorkPseud;

use strict;
use base qw( Fantabulous::Entity );
use constant TABLE => 'work_pseuds';

sub new {
    my ($self, $values) = @_;

    return $self->SUPER::new([ qw(
        work_id pseud_id position
    ) ], $values);
}

1;
