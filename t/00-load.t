#!perl -T
use 5.006;
use strict;
use warnings;
use Test::More;

plan tests => 1;

BEGIN {
    use_ok( 'Test2::Aggregate' ) || print "Bail out!\n";
}

diag( "Testing Test2::Aggregate $Test2::Aggregate::VERSION, Perl $], $^X" );
