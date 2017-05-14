#!/usr/local/bin/perl-5.22.0

use utf8;
use strict;
use warnings;

use Encode;
use Capture::Tiny qw/capture tee/;
use File::Temp qw/tempfile/;
use Test::More;

use C2Flow;

use constant TEST_CODE => "
// diff基本文法
func0 {
    nop1
-   nop2
+   nop3
    nop4
}

// 前(func0)のdiff状態を引きずっていないか確認
func1 {
    nop1
    nop2
}

// 関数にdiff記号が付いた場合は関数名にも色を付ける
+ func2 {
+     nop1
+     nop2
+ }

// 関数の閉じカッコにdiff記号はあっても無くても描画には影響しない
+ func3 {
+     nop1
+     nop2
  }
";

subtest "C2Flow->diff" => sub {
    my $p = C2Flow->new();
    my $fn = 0;

    my ($fh, $filename) = tempfile(UNLINK => 1);
    print $fh encode('utf-8', TEST_CODE);
    close($fh);

    my ($stdout, $stderr) = capture {
        $p->read($filename);
        $p->div_function();
        $p->div_control();
        $p->gen_node();
        $p->gen_mermaid();
    };

    is($stderr, '', 'STDERR is blank.');

    my @div;
    push(@div, $stdout =~ m|<div.*?>(.*?)</div>|sg);

    # func0
    like($div[$fn], qr/class id2a diffAdd/, 'func'.$fn.': like class diffAdd');
    like($div[$fn], qr/class id1a diffDel/, 'func'.$fn.': like class diffDel');
    $fn++;

    # func1
    unlike($div[$fn], qr/class /, 'func'.$fn.': unlike class diffAdd & diffDel');
    $fn++;

    # func2
    like($div[$fn], qr/class start id0a id1a return diffAdd/, 'func'.$fn.': like class diffAdd');
    unlike($div[$fn], qr/class .* diffDel/, 'func'.$fn.': unlike class diffDel');
    $fn++;

   # func3
    like($div[$fn], qr/class start id0a id1a return diffAdd/, 'func'.$fn.': like class diffAdd');
    unlike($div[$fn], qr/class .* diffDel/, 'func'.$fn.': unlike class diffDel');
    $fn++;

};

done_testing;

