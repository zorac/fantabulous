package Fantabulous::Entity;

use strict;

sub new {
    my ($this, $fields, $values) = @_;
    my $class = ref($this) || $this;
    my $self = { };

    if ($fields) {
        foreach my $field (@{$fields}) {
            $self->{$field} = undef;
        }
    }

    if ($values) {
        foreach my $field (keys(%{$values})) {
            $self->{$field} = $values->{$field};
        }
    }

    return bless($self, $class);
}

sub insert {
    my ($self, $dbh) = @_;
    my @values;
    my $sql = 'INSERT INTO ' . $self->TABLE . ' SET ' . join(',', map {
        push(@values, $self->{$_}); $_ . ' = ?';
    } grep {
        defined($self->{$_});
    } keys(%{$self}));
    my $sth = $dbh->prepare($sql);

    if ($sth->execute(@values) && exists($self->{id})) {
        $self->{id} = $dbh->{'mysql_insertid'};
    }

    return $self;
}

1;
