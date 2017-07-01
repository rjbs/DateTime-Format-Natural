#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use Test::MockTime qw(set_fixed_time);
use DateTime::Format::Natural;
use DateTime::Format::Natural::Test ':set';
use Test::More;

set_fixed_time(
    '01.11.2006 00:00:00',
    '%d.%m.%Y %H:%M:%S',
);

my @simple = (
    { 'morning'             => '02.11.2006 08:00:00' },
    { 'afternoon'           => '02.11.2006 14:00:00' },
    { 'evening'             => '02.11.2006 20:00:00' },
    { 'noon'                => '02.11.2006 12:00:00' },
    { 'midnight'            => '02.11.2006 00:00:00' },
    { 'wednesday'           => '08.11.2006 00:00:00' },
    { 'wednesday morning'   => '08.11.2006 08:00:00' },
    { 'wednesday afternoon' => '08.11.2006 14:00:00' },
    { 'wednesday evening'   => '08.11.2006 20:00:00' },
    { '00:00:00 wednesday'  => '08.11.2006 00:00:00' },
    { '12{ }am wednesday'   => '08.11.2006 00:00:00' },
    { '12{ }pm wednesday'   => '08.11.2006 12:00:00' },
    { 'november'            => '01.11.2007 00:00:00' },
    { '00:00:00'            => '02.11.2006 00:00:00' },
    { '12{ }am'             => '02.11.2006 00:00:00' },
    { '12{ }pm'             => '02.11.2006 12:00:00' },
);

my @combined = (
    { '1st november'            => '01.11.2007 00:00:00' },
    { 'november 1st'            => '01.11.2007 00:00:00' },
    { 'wednesday {at} 00:00:00' => '08.11.2006 00:00:00' },
    { 'wednesday {at} 12{ }am'  => '08.11.2006 00:00:00' },
    { 'wednesday {at} 12{ }pm'  => '08.11.2006 12:00:00' },
    { '00:00:00 on wednesday'   => '08.11.2006 00:00:00' },
    { '12{ }am on wednesday'    => '08.11.2006 00:00:00' },
    { '12{ }pm on wednesday'    => '08.11.2006 12:00:00' },
);

_run_tests(37, [ [ \@simple ], [ \@combined ] ], \&compare);

sub compare
{
    my $aref = shift;

    foreach my $href (@$aref) {
        my $key = (keys %$href)[0];
        foreach my $entry ($time_entries->($key, $href->{$key})) {
            foreach my $string ($case_strings->($entry->[0])) {
                compare_strings($string, $entry->[1]);
            }
        }
    }
}

sub compare_strings
{
    my ($string, $result) = @_;

    my $parser = DateTime::Format::Natural->new(demand_future => true);
    my $dt = $parser->parse_datetime($string);

    if ($parser->success) {
        is(_result_string($dt), $result, _message($string));
    }
    else {
        fail(_message($string));
    }
}
