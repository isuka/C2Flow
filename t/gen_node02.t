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
// return, exitでフローが切れる
func1 {
    if (cond1) {
        nop1
        return
    } else if (cond2) {
        nop2
        exit
    }

    nop3
}

func2 {
    switch (cond1) {
    case fuga
        nop1
        return
    case piyo
        nop2
        break
    default
        nop3
        exit 1
    }
    return 0
}

func3 {
    while (cond1) {
        return
    }
    nop1
}

func4 {
    exit 1
}

// if文の下に処理が継続する時
func5 {
    if (cond1) {
        nop1
    }
    
    nop2
}

func6 {
    if (cond1) {
        nop1
    }
    
    if (cond2) {
        nop2
    }
    
    nop3
}

func7 {
    if (cond1) {
        nop1
    } else if (cond2) {
        nop2
    }

    nop3
    
    if (cond4) {
        nop4
    } else if (cond5) {
        nop5
    } else {
        nop6
    }

    nop7
}

// case文が2つ重なるとdefaultの接続先がnop2になってしまう。
func8 {

    nop

    switch (cond1) {
    case foo1
    case foo2
        nop2
        break
    default
        nop3
        return 3
    }

    return 0
}

func9 {

    nop

    switch (cond1) {
    case foo1
    case foo2
        nop2
        break
    case foo3
    default
        nop4
        return 4
    }

    return 0
}

// 同一種類の解析のネスト
func10 while nest
{
    while (condition1) {
        nop1
        while (condition11) {
            nop11
            nop12
        }
        nop2
    }
}

func11 until nest
{
    until (condition1) {
        nop1
        until (condition10) {
            nop11
            nop12
        }
        nop2
    }
}

func12 do nest
{
    do {
        nop1
        do {
            nop11
            nop12
        } while (condition10)
        nop2
    } while (condition1)
}

func13 for nest
{
    for (condition1) {
        nop1
        for (condition10) {
            nop11
            nop12
        }
        nop2
    }
}

func14-1 switch nest
{
    switch (condition1) {
    case fuga
        switch (condition10) {
        case fuga10
            nop11
            break
        case piyo10
            nop12
        default
            nop13
        }
        nop1
        break
    case piyo
        nop2
    default
        nop3
    }
}

func14-2 switch nest
{
    switch (condition1) {
    case fuga
        nop1
        switch (condition10) {
        case fuga10
            nop11
            break
        case piyo10
            nop12
        default
            nop13
        }
        break
    case piyo
        nop2
    default
        nop3
    }
}

func15 if nest
{
    if (condition1) {
        nop1
        if (condition10) {
            nop10
            nop11
        } else if (condition11) {
            nop12
            nop13
        } else {
            nop14
            nop15
        }
        nop2
    } else if (condition2) {
        nop3
        nop4
    } else {
        nop5
        nop6
    }
}

// switchでcaseのあとbreakだけのケース
func16-1 switch case only 1
{
    switch (condition1) {
    case fuga
        break
    case piyo
    default
        break
    }
}

func16-2 switch case only 2
{
    switch (condition1) {
    case fuga
    case piyo
        break
    default
        break
    }
    nop1
}

func16-3 switch case only 3
{
    switch (condition1) {
    case fuga
    case piyo
        break
    default
        nop1
        break
    }
    nop2
}

func16-4 switch multi case
{
    switch (condition1) {
    case fuga
    case piyo
    case hogehoge
        break
    default
        nop1
        break
    }
    nop2
}

func16-5 switch multi case
{
    switch (condition1) {
    case fuga
    case piyo
    case hogehoge
    case fugafuga
        nop1
        break
    default
        nop2
        break
    }
    nop2
}

// whileの中にifがあり、その中でbreakするとwhileがbreakされる
func17-1 while break from if
{
    nop1
    while (cond1) {
        nop2
        if (cond2) {
            nop3
            break
        }
        nop4
    }
    nop5
}

// untilの中にifがあり、その中でbreakするとwhileがbreakされる
func17-2 until break from if
{
    nop1
    until (cond1) {
        nop2
        if (cond2) {
            nop3
            break
        }
        nop4
    }
    nop5
}

// doの中にifがあり、その中でbreakするとwhileがbreakされる
func17-3 do break from if
{
    nop1
    do {
        nop2
        if (cond2) {
            nop3
            break
        }
        nop4
    } while (cond1)
    nop5
}

// forの中にifがあり、その中でbreakするとwhileがbreakされる
func17-4 for break from if
{
    nop1
    for (cond1) {
        nop2
        if (cond2) {
            nop3
            break
        }
        nop4
    }
    nop5
}

func 17-5 switch break from if
{
    switch (cond1) {
    case hoge1
        if (cond2) {
            nop11
        } else {
            nop12
        }
        break
    default
        nop d
    }
}

func 17-6 switch break from if
{
    switch (cond1) {
    case hoge1
        if (cond2) {
            nop11
        } else {
            nop12
        }
    default
        nop d
    }
}

func 17-7 switch break from if
{
    switch (cond1) {
    case hoge1
        if (cond2) {
            nop11
        } else if (cond3){
            nop12
        } else {
            nop13
        }
    case hoge2
        if (cond4) {
            nop21
        } else if (cond5){
            nop22
        } else {
            nop23
        }
    default
        if (cond6) {
            nop31
        } else if (cond7){
            nop32
        } else {
            nop33
        }
    }
}

// 処理の無い分岐
func 18-1
{
    while (cond1) {
    }
}

func 18-2
{
    for (cond1) {
    }
}

func 18-3
{
    until (cond1) {
    }
}

func 18-4
{
    do {
    } while(cond1)
}

func 18-5
{
    switch (cond1) {
    }
}

func 18-6
{
    if (cond1) {
    } else if (cond2) {
    } else {
    }
}

func 19-1
{
    nop1
    while (cond1) {
    }
    nop2
}

func 19-2
{
    nop1
    for (cond1) {
    }
    nop2
}

func 19-3
{
    nop1
    until (cond1) {
    }
    nop2
}

func 19-4
{
    nop1
    do {
    } while(cond1)
    nop2
}

func 19-5
{
    nop1
    switch (cond1) {
    }
    nop2
}

func 19-6
{
    nop1
    if (cond1) {
    } else if (cond2) {
    } else {
    }
    nop2
}

// 関数名に引数のカッコがあるとsubgraphが表示されない
// func9 () {
//     nop
// }

// C言語の配列定義をブロックステートと勘違いしてしまう
// func8 ()
// {
//     uint32_t buf[] = {head, body}
//     return
// }
";

#
# Node Generation Test
#
subtest "C2Flow->gen_node: complex" => sub {
    my $p = C2Flow->new();
    my @node; # 処理を格納する配列
    my $fn = 0;

    my ($fh, $filename) = tempfile(UNLINK => 1);
    print $fh encode('utf-8', TEST_CODE);
    close($fh);

    $p->read($filename);
    $p->div_function();
    $p->div_control();
    $p->gen_node();

    #--- function 1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'round square', 'text' => 'exit', 'css' => 'diff=,'});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => 'fuga'
                         },
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => 'piyo'
                         },
                         {
                             'id'   => 'id0a7a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a7a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a8a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a8a', 'shape' => 'round square', 'text' => 'exit 1', 'css' => 'diff=,'});
    push(@node, {'id' => 'id1a', 'shape' => 'round square', 'text' => 'return 0', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 3
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'round square', 'text' => 'exit 1', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 6
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func6', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 7
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func7', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id3a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id3a', 'shape' => 'diamond', 'text' => 'cond4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id4a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id3a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id3a0a', 'shape' => 'square', 'text' => 'nop4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id4a', 'shape' => 'diamond', 'text' => 'cond5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id5a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id4a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id4a0a', 'shape' => 'square', 'text' => 'nop5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id5a0a', 'shape' => 'square', 'text' => 'nop6', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id6a', 'shape' => 'square', 'text' => 'nop7', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 8
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func8', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a2a',
                             'link' => 'allow',
                             'text' => 'foo1'
                         },
                         {
                             'id'   => 'id1a2a',
                             'link' => 'allow',
                             'text' => 'foo2'
                         },
                         {
                             'id'   => 'id1a5a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a5a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a6a', 'shape' => 'round square', 'text' => 'return 3', 'css' => 'diff=,'});
    push(@node, {'id' => 'id2a', 'shape' => 'round square', 'text' => 'return 0', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 9
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func9', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a2a',
                             'link' => 'allow',
                             'text' => 'foo1'
                         },
                         {
                             'id'   => 'id1a2a',
                             'link' => 'allow',
                             'text' => 'foo2'
                         },
                         {
                             'id'   => 'id1a6a',
                             'link' => 'allow',
                             'text' => 'foo3'
                         },
                         {
                             'id'   => 'id1a6a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a6a', 'shape' => 'square', 'text' => 'nop4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a7a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a7a', 'shape' => 'round square', 'text' => 'return 4', 'css' => 'diff=,'});
    push(@node, {'id' => 'id2a', 'shape' => 'round square', 'text' => 'return 0', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 10
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func10 while nest', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'condition11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop12', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 11
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func11 until nest', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'true'
                         },
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'condition10', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => 'true'
                         },
                         {
                             'id'   => 'id0a1a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop12', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 12
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func12 do nest', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'circle', 'text' => ' ', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0b', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'circle', 'text' => ' ', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1b', 'shape' => 'diamond', 'text' => 'condition10', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop12', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1b',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0b',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 10
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func13 for nest', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'condition10', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop12', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 14-1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func14-1 switch nest', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => 'fuga'
                         },
                         {
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => 'piyo'
                         },
                         {
                             'id'   => 'id0a7a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'condition10', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => 'fuga10'
                         },
                         {
                             'id'   => 'id0a1a4a',
                             'link' => 'allow',
                             'text' => 'piyo10'
                         },
                         {
                             'id'   => 'id0a1a6a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a4a', 'shape' => 'square', 'text' => 'nop12', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a6a', 'shape' => 'square', 'text' => 'nop13', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a5a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a7a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a7a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 14-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func14-2 switch nest', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => 'fuga'
                         },
                         {
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => 'piyo'
                         },
                         {
                             'id'   => 'id0a7a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'diamond', 'text' => 'condition10', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a1a',
                             'link' => 'allow',
                             'text' => 'fuga10'
                         },
                         {
                             'id'   => 'id0a2a4a',
                             'link' => 'allow',
                             'text' => 'piyo10'
                         },
                         {
                             'id'   => 'id0a2a6a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a2a1a', 'shape' => 'square', 'text' => 'nop11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a4a', 'shape' => 'square', 'text' => 'nop12', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a6a', 'shape' => 'square', 'text' => 'nop13', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a5a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a7a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a7a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 15
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func15 if nest', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'condition10', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop10', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'diamond', 'text' => 'condition11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a3a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a2a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a2a0a', 'shape' => 'square', 'text' => 'nop12', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a1a', 'shape' => 'square', 'text' => 'nop13', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a3a0a', 'shape' => 'square', 'text' => 'nop14', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a3a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a3a1a', 'shape' => 'square', 'text' => 'nop15', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'condition2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'square', 'text' => 'nop4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a0a', 'shape' => 'square', 'text' => 'nop5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a1a', 'shape' => 'square', 'text' => 'nop6', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 16-1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func16-1 switch case only 1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'fuga'
                         },
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'piyo'
                         },
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 16-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func16-2 switch case only 2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'fuga'
                         },
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'piyo'
                         },
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 16-3
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func16-3 switch case only 3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'fuga'
                         },
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'piyo'
                         },
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 16-4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func16-4 switch multi case', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'fuga'
                         },
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'piyo'
                         },
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'hogehoge'
                         },
                         {
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a5a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 16-5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func16-5 switch multi case', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => 'fuga'
                         },
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => 'piyo'
                         },
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => 'hogehoge'
                         },
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => 'fugafuga'
                         },
                         {
                             'id'   => 'id0a7a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a7a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func17-1 while break from if', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a1a0a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func17-2 until break from if', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'true'
                         },
                         {
                             'id'   => 'id1a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         }
                     ]});
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a1a0a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func17-3 do break from if', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'circle', 'text' => ' ', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1b', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a1a0a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1b',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func17-4 for break from if', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a1a0a', 'shape' => 'square', 'text' => 'nop3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 17-5 switch break from if', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => 'hoge1'
                         },
                         {
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a0a', 'shape' => 'square', 'text' => 'nop12', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a5a', 'shape' => 'square', 'text' => 'nop d', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-6
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 17-6 switch break from if', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => 'hoge1'
                         },
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a0a', 'shape' => 'square', 'text' => 'nop12', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop d', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-7
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 17-7 switch break from if', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => 'hoge1'
                         },
                         {
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => 'hoge2'
                         },
                         {
                             'id'   => 'id0a9a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a1a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'diamond', 'text' => 'cond3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a3a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a2a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a2a0a', 'shape' => 'square', 'text' => 'nop12', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a3a0a', 'shape' => 'square', 'text' => 'nop13', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a5a', 'shape' => 'diamond', 'text' => 'cond4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a6a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a5a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a5a0a', 'shape' => 'square', 'text' => 'nop21', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a9a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a6a', 'shape' => 'diamond', 'text' => 'cond5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a7a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a6a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a6a0a', 'shape' => 'square', 'text' => 'nop22', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a9a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a7a0a', 'shape' => 'square', 'text' => 'nop23', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a9a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a9a', 'shape' => 'diamond', 'text' => 'cond6', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a10a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a9a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a9a0a', 'shape' => 'square', 'text' => 'nop31', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a10a', 'shape' => 'diamond', 'text' => 'cond7', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a11a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a10a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a10a0a', 'shape' => 'square', 'text' => 'nop32', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a11a0a', 'shape' => 'square', 'text' => 'nop33', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-3
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'true'
                         },
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'false'
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'circle', 'text' => ' ', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0b',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0b', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-6
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-6', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 19-1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 19-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 19-3
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-3', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'true'
                         },
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 19-4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-4', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'circle', 'text' => ' ', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1b',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1b', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 19-5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-5', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 19-6
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-6', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id4a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'diamond', 'text' => 'cond2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'id4a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id4a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id4a', 'shape' => 'square', 'text' => 'nop2', 'css' => 'diff=,',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => 'diff=,'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

};

done_testing;
