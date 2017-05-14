#!/usr/local/bin/perl-5.22.0

use utf8;
use strict;
use warnings;

use Encode;
use File::Temp qw/tempfile/;
use Test::More;
#use Devel::Cover;

use C2Flow;

use constant TEST_CODE => "
test begin
// 1行コメント
1// 途中から始まる1行コメント
2 // 途中から始まる1行コメント
 3  // 途中から始まる1行コメント
test end";

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

    my ($fh, $filename) = tempfile(UNLINK => 1);
    print $fh encode('utf-8', TEST_CODE);
    close($fh);

    $p->read($filename);
    ok(${$p->{'read_src'}} eq '
test begin

1
2 
 3  
test end', 'Read Test') || diag explain $p->{'read_src'};
};

done_testing;
