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
// 関数ポインタを使用した関数
func1 (int argc, char *argv) {
    nop1
}

// return, exitの場合はtypeがctrlに分類される
func2 {
    if (cond1) {
        return
    } else if (cond2) {
        exit
    } else {
        return 1
    }
}

func3 {
    switch (cond1) {
    case fuga
        return
    case piyo
        nop
        break
    default
        exit 1
    }
}

func4 {
    return 1
    exit 2
}

func5 {
    while (cond1) {
        nop1
        return 1
    }

    while (cond2) {
        nop2
        exit 2
    }
}
";

#
# Divide Function Test
#
subtest "C2Flow->div_control: misc" => sub {
    my $p = C2Flow->new();
    my @proc; # 処理を格納する配列
    my $fn = 0;

    my ($fh, $filename) = tempfile(UNLINK => 1);
    print $fh encode('utf-8', TEST_CODE);
    close($fh);

    $p->read($filename);
    $p->div_function();
    $p->div_control();

    #--- function 1
    @proc = ();
    push(@proc, {'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' });
    ok($p->{'functions'}[$fn]->{'name'} eq 'func1 (int argc, char *argv)');
    $fn++;

    #--- function 2
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['cond1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'ctrl', 'code' => 'return', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['cond2'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'ctrl', 'code' => 'exit', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'ctrl', 'code' => 'return 1', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 3
    @proc = ();
    push(@proc, {
        'type'       => 'switch',
        'conditions' => ['cond1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'code' => 'return', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'code' => 'break', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'code' => 'exit 1', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 4
    @proc = ();
    push(@proc, {'type' => 'ctrl', 'code' => 'return 1', 'css' => 'diff=,' });
    push(@proc, {'type' => 'ctrl', 'code' => 'exit 2', 'css' => 'diff=,' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 5
    @proc = ();
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['cond1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'code' => 'return 1', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['cond2'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'code' => 'exit 2', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

};

done_testing;
