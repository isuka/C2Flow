#!/usr/local/bin/perl-5.22.0

use utf8;
use strict;
use warnings;

use Test::More;
#use Devel::Cover;

use C2Flow;

use_ok('C2Flow');

# オブジェクト作成
subtest "C2Flow->new" => sub {
    my $p = C2Flow->new();
    isa_ok($p, "C2Flow");
};

#
# Read Test
#
subtest "C2Flow->read01: comment" => sub {
    my $p = C2Flow->new();

    $p->read('./t/read01.txt');
    ok(${$p->{'read_src'}} eq '
test begin

1
2 
 3  
test end', 'Read Test') || diag explain $p->{'read_src'};
};

done_testing;
