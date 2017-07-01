#!/usr/bin/perl

use strict;
use warnings;
use boolean qw(true);

use Test::MockTime qw(set_fixed_time);
use DateTime::Format::Natural;
use DateTime::Format::Natural::Test ':set';
use Test::More;

my $date = join '.', map $time{$_}, qw(day month year);
my $time = join ':', map $time{$_}, qw(hour minute second);

set_fixed_time(
    "$date $time",
    '%d.%m.%Y %H:%M:%S',
);

my @simple = (
    # These are the tests from parse_prefer_future, which we'd expect to pass
    # except in cases where they didn't properly prefer the future. -- rjbs,
    # 2017-07-01
    { 'friday'             => '24.11.2006 00:00:00'     }, # <-- okay to fail?
    { 'monday'             => '27.11.2006 00:00:00'     },
    { 'morning'            => '24.11.2006 08:00:00'     },
    { 'afternoon'          => '24.11.2006 14:00:00'     },
    { 'evening'            => '24.11.2006 20:00:00'     },
    { 'thursday morning'   => '30.11.2006 08:00:00'     },
    { 'thursday afternoon' => '30.11.2006 14:00:00'     },
    { 'thursday evening'   => '30.11.2006 20:00:00'     },
    { 'noon'               => '24.11.2006 12:00:00'     },
    { 'midnight'           => '25.11.2006 00:00:00'     },
    { 'november'           => '01.11.2007 00:00:00'     },
    { 'january'            => '01.01.2007 00:00:00'     },
    { 'last january'       => '01.01.2005 00:00:00'     },
    { 'next january'       => '01.01.2007 00:00:00'     },
    { 'next friday'        => '01.12.2006 00:00:00'     },
    { 'last friday'        => '17.11.2006 00:00:00'     },
    { '00:30:15'           => '25.11.2006 00:30:15'     },
    { '00:00{sec}'         => '25.11.2006 00:00:{sec}'  },
    { '12{min_sec}{ }am'   => '25.11.2006 00:{min_sec}' },
    { '12:30{sec}{ }am'    => '25.11.2006 00:30:{sec}'  },
    { '4{min_sec}{ }pm'    => '24.11.2006 16:{min_sec}' },
    { '4:20{sec}{ }pm'     => '24.11.2006 16:20:{sec}'  },
    { '12:56:06{ }am'      => '25.11.2006 00:56:06'     },
    { '12:56:06{ }pm'      => '24.11.2006 12:56:06'     },

    # These are the tests provided in the original parse_demand_future, updated
    # for using default testing time. -- rjbs, 2017-07-01
    { 'morning'             => '25.11.2006 08:00:00' },
    { 'afternoon'           => '25.11.2006 14:00:00' },
    { 'evening'             => '25.11.2006 20:00:00' },
    { 'noon'                => '25.11.2006 12:00:00' },
    { 'midnight'            => '25.11.2006 00:00:00' },
    { 'wednesday'           => '29.11.2006 00:00:00' },
    { 'wednesday morning'   => '29.11.2006 08:00:00' },
    { 'wednesday afternoon' => '29.11.2006 14:00:00' },
    { 'wednesday evening'   => '29.11.2006 20:00:00' },
    { '00:00:00 wednesday'  => '29.11.2006 00:00:00' },
    { '12{ }am wednesday'   => '29.11.2006 00:00:00' },
    { '12{ }pm wednesday'   => '29.11.2006 12:00:00' },
    { 'november'            => '01.11.2007 00:00:00' },
    { '00:00:00'            => '25.11.2006 00:00:00' },
    { '12{ }am'             => '25.11.2006 00:00:00' },
    { '12{ }pm'             => '25.11.2006 12:00:00' },
);

my @combined = (
    { '1st november'            => '01.11.2007 00:00:00' },
    { 'november 1st'            => '01.11.2007 00:00:00' },
    { 'wednesday {at} 00:00:00' => '29.11.2006 00:00:00' },
    { 'wednesday {at} 12{ }am'  => '29.11.2006 00:00:00' },
    { 'wednesday {at} 12{ }pm'  => '29.11.2006 12:00:00' },
    { '00:00:00 on wednesday'   => '29.11.2006 00:00:00' },
    { '12{ }am on wednesday'    => '29.11.2006 00:00:00' },
    { '12{ }pm on wednesday'    => '29.11.2006 12:00:00' },
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
