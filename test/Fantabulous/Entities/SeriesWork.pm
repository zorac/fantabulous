package Fantabulous::Entities::SeriesWork;

use strict;
use base qw( Fantabulous::Entity );
use constant TABLE => 'series_works';

sub new {
    my ($self, $values) = @_;

    return $self->SUPER::new([ qw(
        series_id work_id position
    ) ], $values);
}

1;
