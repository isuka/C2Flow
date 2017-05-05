#!/usr/local/bin/perl-5.22.0

use utf8;
use strict;
use warnings;

use Test::More;
#use Devel::Cover;

use C2Flow;

#
# Read Test
#
subtest "C2Flow->read02: multi comment" => sub {
    my $p = C2Flow->new();

    $p->read('./t/read02.txt');
    ok(${$p->{'read_src'}} eq '
test begin

1
2 
3 
5 
6  6
test end', 'Read Test') || diag explain $p->{'read_src'};
};

done_testing;
