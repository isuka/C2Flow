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
/* コメント */
1/* コメント */
2 /* 複数行にまたがるコメント
*/
3 /* 複数行にまたがるコメント
4 */
5 /*
   * こんな複数行コメントもある
   */
6 /* 行中にコメント */ 6
test end";

#
# Read Test
#
subtest "C2Flow->read02: multi comment" => sub {
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
5 
6  6
test end', 'Read Test') || diag explain $p->{'read_src'};
};

done_testing;
