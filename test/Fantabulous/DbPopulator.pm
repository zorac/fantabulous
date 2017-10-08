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

sub new {
    my ($this) = @_;
    my $class = ref($this) || $this;
    my $self = { };

    return bless($self, $class);
}

sub random {
    my ($self, $picks, $deck) = @_;
    my $picks_left = $picks;
    my $num_left = @$deck;
    my @result;
    my $idx = 0;

    while ($picks_left > 0 ) {  # when we have all our picks, stop
        my $rand = int(rand($num_left));

        if ($rand < $picks_left ) {
            push @result, $deck->[$idx];
            $picks_left--;
        }

        $num_left--;
        $idx++;
    }

    return @result;
}

sub populate {
    my ($self, $dbh) = @_;
    my (@users, @pseuds, @fandoms, @warnings, @generics, @works, @series);

    foreach my $u (1..20) {
        push(@users, my $user = Fantabulous::Entities::User->new({
             name => "user$u",
             email => "user$u\@fantabulous.xyz",
             salt => 'SALT',
             password => 'PASSWORD'
        })->insert($dbh));

        foreach my $p (1..3) {
            push(@pseuds, Fantabulous::Entities::Pseud->new({
                 name => "user${u}pseud$p",
                 user_id => $user->{id}
            })->insert($dbh));
        }
    }

    foreach my $f (1..10) {
        my (@characters, @ships);
        my $fandom = Fantabulous::Entities::Tag->new({
            type => 'Fandom',
            name => "Fabulous Fandom $f"
        })->insert($dbh);

        foreach my $c (1..10) {
            push(@characters, Fantabulous::Entities::Tag->new({
                type => 'Character',
                name => "Mx $f $c"
            })->insert($dbh));
        }

        foreach my $s (1..30) {
            my ($a, $b) = $self->random(2, \@characters);
            my $ship = Fantabulous::Entities::Tag->new({
                type => 'Ship',
                name => "$a->{name}/$b->{name}"
            })->insert($dbh);

            push(@ships, $ship) if ($ship->{id}); # My be dup'd
        }

        push(@fandoms, {
            fandom => $fandom,
            characters => \@characters,
            ships => \@ships
        });
    }

    foreach my $w (1..10) {
        push(@warnings, Fantabulous::Entities::Tag->new({
            type => 'Warning',
            name => "Warning No. $w"
        })->insert($dbh));
    }

    foreach my $g (1..50) {
        push(@generics, Fantabulous::Entities::Tag->new({
            type => 'Generic',
            name => "Generic Tag $g"
        })->insert($dbh));
    }

    foreach my $w (1..100) {
        my (@work_fandoms, @work_ships, @work_characters);
        my $p = 1;
        my $t = 1;

        push(@works, my $work = Fantabulous::Entities::Work->new({
            name => "Winsome Work $w"
        })->insert($dbh));

        foreach my $pseud ($self->random(int(1 + rand(2)), \@pseuds)) {
            Fantabulous::Entities::WorkPseud->new({
                work_id => $work->{id},
                pseud_id => $pseud->{id},
                position => $p++
            })->insert($dbh);
        }

        foreach my $fandom ($self->random(int(1 + rand(2)), \@fandoms)) {
            push(@work_fandoms, $fandom->{fandom});
            push(@work_ships, $self->random(int(rand(4)), $fandom->{ships}));
            push(@work_characters, $self->random(int(rand(6)), $fandom->{characters}));
        }

        foreach my $tag (@work_fandoms,
                $self->random(int(rand(4)), \@warnings),
                @work_ships, @work_characters,
                $self->random(int(rand(10)), \@generics)) {
            Fantabulous::Entities::WorkTag->new({
                work_id => $work->{id},
                tag_id => $tag->{id},
                position => $t++
            })->insert($dbh);
        }
    }

    foreach my $s (1..20) {
        my $w = 1;

        push(@series, my $series = Fantabulous::Entities::Series->new({
            name => "Superb Series $s"
        })->insert($dbh));

        foreach my $work ($self->random(int(1 + rand(5)), \@works)) {
            Fantabulous::Entities::SeriesWork->new({
                series_id => $series->{id},
                work_id => $work->{id},
                position => $w++
            })->insert($dbh);
        }
    }
}

1;
