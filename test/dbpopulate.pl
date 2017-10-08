#!/usr/bin/perl -w

use strict;

use Carp qw( cluck confess verbose );
use DBI;
use DBD::mysql;
use Fantabulous::DbPopulator;

$SIG{__DIE__} = \&confess;
$SIG{__WARN__} = \&cluck;

my $dbh = DBI->connect('dbi:mysql:fantabulous', 'fantabulous', 'changeme');
my $populator = Fantabulous::DbPopulator->new;

$populator->populate($dbh);
