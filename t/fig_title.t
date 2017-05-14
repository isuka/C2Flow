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
// タイトル表示機能
// <title>figure title 0</title>
func0 {
    nop1
}

// 複数回titleタグが出現した場合は最後のタグが有効。
// <title>figure title 1-1</title>
// <title>figure title 1-2</title>
func1 {
    nop1
}

// マルチラインコメントで囲まれていてもタイトルとして認識。
// titleタグが関数の直前でなくても問題ない。
/* <title>figure title 2</title>
   hogehoge
 */
func2 {
    nop1
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
    like($div[$fn], qr/subgraph figure title 0/, 'func'.$fn.': like subgraph');
    $fn++;

    # func1
    like($div[$fn], qr/subgraph figure title 1-2/, 'func'.$fn.': like subgraph');
    $fn++;

    # func2
    like($div[$fn], qr/subgraph figure title 2/, 'func'.$fn.': like subgraph');
    $fn++;

};

done_testing;

