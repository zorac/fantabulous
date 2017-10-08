package Fantabulous::Entities::Tag;

use strict;
use base qw( Fantabulous::Entity );
use constant TABLE => 'tags';

sub new {
    my ($self, $values) = @_;

    return $self->SUPER::new([ qw(
        id alias_for created updated type name
    ) ], $values);
}

1;
