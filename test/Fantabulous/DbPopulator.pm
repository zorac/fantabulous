package Fantabulous::DbPopulator;

use strict;

use Fantabulous::Entities::Chapter;
use Fantabulous::Entities::Pseud;
use Fantabulous::Entities::Series;
use Fantabulous::Entities::SeriesWork;
use Fantabulous::Entities::Tag;
use Fantabulous::Entities::User;
use Fantabulous::Entities::Work;
use Fantabulous::Entities::WorkPseud;
use Fantabulous::Entities::WorkTag;

my $NUM_USERS = 1000;
my $USER_PSEUDS = [ 1, 1, 1, 1, 1, 2, 2, 2, 3, 1 .. 5 ];
my $NUM_FANDOMS = 100;
my $FANDOM_CHARACTERS = [ 10 .. 20 ];
my $FANDOM_SHIPS = [ 20 .. 30 ];
my $SHIP_CHARACTERS = [ 2, 2, 2, 2, 2, 2, 2, 3, 3, 2 .. 4 ];
my $SHIP_TYPES = [ '/', '/', ' & ' ];
my $NUM_GENERICS = 1000;
my $NUM_WORKS = 1000;
my $WORK_PSEUDS = [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 1 .. 3 ];
my $WORK_FANDOMS = [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 1 .. 5 ];
my $WORK_FANDOM_CHARACTERS = [ 1 .. 5 ];
my $WORK_FANDOM_SHIPS = [ 1 .. 3 ];
my $WORK_WARNINGS = [ 1, 1, 1, 1, 1, 2, 2, 3, 1 .. 4 ];
my $WORK_GENERICS = [ 1 .. 10 ];
my $NUM_SERIES = 100;
my $SERIES_WORKS = [ 1 .. 10 ];
my @WORDS = ( '/usr/share/dict/words', 4 );
my @JOINS = ( '/usr/share/dict/connectives' );
my @NAMES = ( '/usr/share/dict/propernames' );
my @WARNINGS = (
    'Choose Not To Use Archive Warnings',
    'Graphic Depictions Of Violence',
    'Major Character Death',
    'No Archive Warnings Apply',
    'Rape/Non-Con',
    'Underage',
);

sub new {
    my ($this) = @_;
    my $class = ref($this) || $this;
    my $self = { seen => { } };

    bless($self, $class);

    $self->{words} = $self->load_words(@WORDS);
    $self->{joins} = $self->load_words(@JOINS);
    $self->{names} = $self->load_words(@NAMES);

    return $self;
}

sub load_words {
    my ($self, $file, $min_length) = @_;
    my @words;

    print STDERR "Loading words from $file: ";
    open(IN, $file);

    while (defined(my $word = <IN>)) {
        chomp($word);
        next if ($min_length && (length($word) < $min_length));
        push(@words, $word);
    }

    print STDERR scalar(@words), "\n";

    return \@words;
}

sub random {
    my ($self, $values, $count) = @_;
    my $total = @{$values};
    my (@result, %seen);

    if (!defined($count)) {
        $count = 1;
    } elsif (ref($count) eq 'ARRAY') {
        $count = $count->[int(rand(@{$count}))];
    }

    die ("COUNT=$count, TOTAL=$total") if ($count >= $total);

    for (my $i = 0; $i < $count; $i++) {
        my $index;

        do {
            $index = int(rand($total));
        } while (exists($seen{$index}));

        $seen{$index} = undef;
        push(@result, $values->[$index])
    }

    return wantarray ? @result : $result[0];
}

sub make_user_name {
    my ($self) = @_;
    my $result;

    do {
        my @names = $self->random($self->{names}, 2);

        $result = $names[0] . $names[1];
    } while (exists($self->{seen}{$result}));

    $self->{seen}{$result} = undef;

    return $result;
}

sub make_character_name {
    my ($self) = @_;
    my $result;

    do {
        my @names = $self->random($self->{names}, 2);

        $result = $names[0] . ' ' . $names[1];
    } while (exists($self->{seen}{$result}));

    $self->{seen}{$result} = undef;

    return $result;
}

sub make_fandom_name {
    my ($self) = @_;
    my $result;

    do {
        my $name = $self->random($self->{names});
        my @joins = $self->random($self->{joins}, 2);
        my $word = $self->random($self->{words});

        $result = $name . ' ' . $joins[0] . ' ' . $joins[1] . ' ' . $word;
    } while (exists($self->{seen}{$result}));

    $self->{seen}{$result} = undef;

    return $result;
}

sub make_title {
    my ($self) = @_;
    my $result;

    do {
        my @joins = $self->random($self->{joins}, 2);
        my @words = $self->random($self->{words}, 2);

        $result = ucfirst($joins[0]) . ' ' . ucfirst($words[0]) . ' '
                . $joins[1] . ' ' . ucfirst($words[1]);
    } while (exists($self->{seen}{$result}));

    $self->{seen}{$result} = undef;

    return $result;
}

sub make_generic_name {
    my ($self) = @_;
    my $result;

    do {
        my @words = $self->random($self->{words}, 3);

        $result = ucfirst($words[0]) . ' ' . $words[1] . ' ' . $words[2];
    } while (exists($self->{seen}{$result}));

    $self->{seen}{$result} = undef;

    return $result;
}

sub populate {
    my ($self, $dbh) = @_;
    my (@users, @pseuds, @fandoms, @warnings, @generics, @works, @series);

    print STDERR "Creating Users: ";

    foreach my $u (1 .. $NUM_USERS) {
        print STDERR 'u';

        my $name = $self->make_user_name;

        push(@users, my $user = Fantabulous::Entities::User->new({
             name => $name,
             email => lc($name) . '@fantabulous.xyz',
             salt => 'SALT',
             password => 'PASSWORD'
        })->insert($dbh));

        foreach my $p (1 .. $self->random($USER_PSEUDS)) {
            print STDERR 'p';

            $name = $self->make_user_name if ($p > 1);

            push(@pseuds, Fantabulous::Entities::Pseud->new({
                 name => $name,
                 user_id => $user->{id}
            })->insert($dbh));
        }
    }

    print STDERR "\nCreating Tags: ";

    foreach my $warning (@WARNINGS) {
        print STDERR 'w';

        push(@warnings, Fantabulous::Entities::Tag->new({
            type => 'Warning',
            name => $warning
        })->insert($dbh));
    }

    foreach my $f (1 .. $NUM_FANDOMS) {
        print STDERR 'f';

        my (@characters, @ships);
        my $fandom = Fantabulous::Entities::Tag->new({
            type => 'Fandom',
            name => $self->make_fandom_name
        })->insert($dbh);

        foreach my $c (1 .. $self->random($FANDOM_CHARACTERS)) {
            print STDERR 'c';

            push(@characters, Fantabulous::Entities::Tag->new({
                type => 'Character',
                name => $self->make_character_name
            })->insert($dbh));
        }

        foreach my $s (1 .. $self->random($FANDOM_SHIPS)) {
            print STDERR 's';

            my (@chars, $name);

            do {
                @chars = sort($self->random(\@characters, $SHIP_CHARACTERS));
                $name = join($self->random($SHIP_TYPES), map { $_->{name} } @chars);
            } while (exists($self->{seen}{$name}));

            $self->{seen}{$name} = undef;

            push(@ships, Fantabulous::Entities::Tag->new({
                type => 'Ship',
                name => $name
            })->insert($dbh));
        }

        push(@fandoms, {
            fandom => $fandom,
            characters => \@characters,
            ships => \@ships
        });
    }

    foreach my $g (1 .. $NUM_GENERICS) {
        print STDERR 'g';

        push(@generics, Fantabulous::Entities::Tag->new({
            type => 'Generic',
            name => $self->make_generic_name
        })->insert($dbh));
    }

    print STDERR "\nCreating works: ";

    foreach my $w (1 .. $NUM_WORKS) {
        print STDERR 'w';

        my (@work_fandoms, @work_ships, @work_characters);
        my $p = 1;
        my $t = 1;

        push(@works, my $work = Fantabulous::Entities::Work->new({
            name => $self->make_title
        })->insert($dbh));

        foreach my $pseud ($self->random(\@pseuds, $WORK_PSEUDS)) {
            print STDERR 'p';

            Fantabulous::Entities::WorkPseud->new({
                work_id => $work->{id},
                pseud_id => $pseud->{id},
                position => $p++
            })->insert($dbh);
        }

        foreach my $fandom ($self->random(\@fandoms, $WORK_FANDOMS)) {
            push(@work_fandoms, $fandom->{fandom});
            push(@work_ships, $self->random($fandom->{ships}, $WORK_FANDOM_SHIPS));
            push(@work_characters, $self->random($fandom->{characters}, $WORK_FANDOM_CHARACTERS));
        }

        foreach my $tag (@work_fandoms,
                $self->random(\@warnings, $WORK_WARNINGS),
                @work_ships, @work_characters,
                $self->random(\@generics, $WORK_GENERICS)) {
            print STDERR 't';

            Fantabulous::Entities::WorkTag->new({
                work_id => $work->{id},
                tag_id => $tag->{id},
                position => $t++
            })->insert($dbh);
        }
    }

    print STDERR "\nCreating series: ";

    foreach my $s (1 .. $NUM_SERIES) {
        print STDERR 's';

        my $w = 1;

        push(@series, my $series = Fantabulous::Entities::Series->new({
            name => $self->make_title
        })->insert($dbh));

        foreach my $work ($self->random(\@works, $SERIES_WORKS)) {
            print STDERR 'w';

            Fantabulous::Entities::SeriesWork->new({
                series_id => $series->{id},
                work_id => $work->{id},
                position => $w++
            })->insert($dbh);
        }
    }

    print STDERR "\nDone!\n";
}

1;
