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
// 複数の制御の組み合わせ(連続使用)
func1 {
    // 処理のみの関数
    process 01
    process 02

    while start
    while (condition1) {
      nop
    }
    while end

    until start
    until (condition1) {
      nop
    }
    until end

    do while start
    do {
      nop
    } while (condition1)
    do while end

    for start
    for (condition1) {
      nop
    }
    for end

    for2 start
    for (i = 0; i < hoge; i++) {
      nop
    }
    for2 end

    switch start
    switch (condition1) {
    case fuga
        nop1
        break
    case piyo
        nop2
    default
        nop3
    }
    switch end

    if start
    if (condition1) {
        nop
    }
    if end

    else start
    if (condition1) {
        nop1
    } else {
        nop2
    }
    else end

    else if start
    if (condition1) {
        nop1
    } else if (condition2) {
        nop2
    } else {
        nop3
    }
    else if end

    else  if start
    if (condition1) {
        nop1
    } else  if (condition2) {
        nop2
    } else {
        nop3
    }
    else  if end
}

//
// 関数内に複数処理があり、空行の行頭がスペースで揃えられている
//

// whileテスト
func2 {
    while (condition1) {
      nop1
      nop2
      
      nop3
    }
}

// untilテスト
func3 {
    until (condition1) {
      nop1
      nop2
      
      nop3
    }
}

// do whileテスト
func4 {
    do {
      nop1
      nop2
      
      nop3
    } while (condition1)
}

// forテスト(疑似コード)
func5 {
    for (condition1) {
      nop1
      nop2
      
      nop3
    }
}

// forテスト(ソースコード)
func6 {
    for (i = 0; i < hoge; i++) {
      nop1
      nop2
      
      nop3
    }
}

// switchテスト
func7 {
    switch (condition1) {
    case fuga
        nop1
        nop2
        
        nop3
        break
    case piyo
        nop4
        nop5
        nop6
    default

        nop7
        nop8
        nop9
    }
}

// ifテスト(if単体)
func8 {
    if (condition1) {
        nop1
        nop2
        nop3
    }
}

// ifテスト(if, else使用)
func9 {
    if (condition1) {
        nop1
        nop2
        
        nop3
    } else {
        nop4
        
        nop5
        nop6
    }
}

// ifテスト(if, else if, else使用)
func10 {
    if (condition1) {
        nop1
        nop2
        
        nop3
    } else if (condition2) {
        nop4
        
        nop5
        nop6
    } else {
        
        nop7
        nop8
        nop9
    }
}

// ifテスト(else ifの間に複数の空白を使用)
func11 {
    if (condition1) {
        nop1
        nop2
        nop3
    } else  if (condition2) {
        nop4
        nop5
        nop6
        
    } else {
        nop7
        
        nop8
        
        nop9
    }
}

//
// 制御コードのネスト
//

// whileテスト
func12 {
    while (condition1) {
        nop1
        while (condition2) {
            nop2
        }
    }
    nop3
}

// untilテスト
func13 {
    until (condition1) {
        nop1
        until (condition2) {
            nop2
        }
    }
    nop3
}

// do whileテスト
func14 {
    do {
        nop1
        do {
            nop2
        } while (condition2)
    } while (condition1)
    nop3
}

// forテスト(疑似コード)
func15 {
    for (condition1) {
        nop1
        for (condition2) {
            nop2
        }
    }
    nop3
}

// forテスト(ソースコード)
func16 {
    for (i = 0; i < hoge; i++) {
        nop1
        for (j = 0; j < fuga; j++) {
            nop2
        }       
    }
    nop3
}

// switchテスト
func17 {
    switch (condition1) {
    case fuga
        switch (condition 2) {
        case fuga2
            nop1
            nop2
        
            nop3
            break
        }
    case piyo
        nop4
        switch (condition 3) {
        case piyo 2
            nop5
            break
        case piyo 3
            nop6
        }
        break
    default
        nop7
        switch (condition 4) {
        default
            nop8
        }
        nop9
    }
}

// ifテスト(if単体)
func18 {
    if (condition1) {
        nop1
        if (condition2) {
            nop2
        }
    }
    nop3
}

// ifテスト(if, else使用)
func19 {
    if (condition1) {
        nop1
        if (condition2) {
            nop2
        }
        nop3
    } else {
        nop4
        if (condition3) {
            nop5
        } else {
            nop6
        }        
    }
}

// ifテスト(if, else if, else使用)
func20 {
    nop0
    if (condition1) {
        nop1
        if (condition2) {
            nop2
            nop3
        }
    } else if (condition3) {
        if (condition4) {
            nop4
        } else if (condition5) {
            nop5
        } else {
            nop6
        }
    } else {
        nop7
        nop8
        if (condition6) {
            nop9
            nop10
        } else if (condition7) {
            nop11
            nop12
        } else {
            nop13
            nop14
        }
        nop15
        nop16
    }
    nop17
}
";

#
# Divide Function Test
#
subtest "C2Flow->div_control: complex" => sub {
    my $p = C2Flow->new();
    my @proc; # 処理を格納する配列
    my $fn = 0;

    my ($fh, $filename) = tempfile(UNLINK => 1);
    print $fh encode('utf-8', TEST_CODE);
    close($fh);

    $p->read($filename);
    $p->div_function();
    $p->div_control();

    #--- func1
    @proc = ();
    push(@proc, {'type' => 'proc', 'code' => 'process 01', 'css' => 'diff=,' });
    push(@proc, {'type' => 'proc', 'code' => 'process 02', 'css' => 'diff=,' });

    ##--- while
    push(@proc, {'type' => 'proc', 'code' => 'while start', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop', 'css' => 'diff=,' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'while end', 'css' => 'diff=,' });

    ##--- until
    push(@proc, {'type' => 'proc', 'code' => 'until start', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'until',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop', 'css' => 'diff=,' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'until end', 'css' => 'diff=,' });

    ##--- do while
    push(@proc, {'type' => 'proc', 'code' => 'do while start', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'do',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop', 'css' => 'diff=,' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'do while end', 'css' => 'diff=,' });

    ##--- for
    push(@proc, {'type' => 'proc', 'code' => 'for start', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop', 'css' => 'diff=,' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'for end', 'css' => 'diff=,' });

    ##--- for2
    push(@proc, {'type' => 'proc', 'code' => 'for2 start', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['i = 0; i < hoge; i++'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop', 'css' => 'diff=,' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'for2 end', 'css' => 'diff=,' });

    ##--- switch
    push(@proc, {'type' => 'proc', 'code' => 'switch start', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'switch',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'code' => 'break', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {'type' => 'proc', 'code' => 'switch end', 'css' => 'diff=,' });

    ##--- if
    push(@proc, {'type' => 'proc', 'code' => 'if start', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop', 'css' => 'diff=,' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'if end', 'css' => 'diff=,' });

    ##--- else
    push(@proc, {'type' => 'proc', 'code' => 'else start', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {'type' => 'proc', 'code' => 'else end', 'css' => 'diff=,' });

    ##--- else if
    push(@proc, {'type' => 'proc', 'code' => 'else if start', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition2'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                              { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {'type' => 'proc', 'code' => 'else if end', 'css' => 'diff=,' });

    ##--- else  if
    push(@proc, {'type' => 'proc', 'code' => 'else  if start', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition2'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                              { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {'type' => 'proc', 'code' => 'else  if end', 'css' => 'diff=,' });

    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 2
    @proc = ();
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 3
    @proc = ();
    push(@proc, {
        'type'       => 'until',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 4
    @proc = ();
    push(@proc, {
        'type'       => 'do',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 5
    @proc = ();
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 6
    @proc = ();
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['i = 0; i < hoge; i++'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 7
    @proc = ();
    push(@proc, {
        'type'       => 'switch',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'code' => 'break', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop4', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop5', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop6', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop7', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop8', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop9', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 8
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 9
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop4', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop5', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop6', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 10
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition2'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop4', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop5', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop6', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop7', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop8', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop9', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 11
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition2'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop4', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop5', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop6', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop7', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop8', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop9', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 12
    @proc = ();
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'while',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                                ]
                            },
                        ]
         });
    push(@proc, { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 13
    @proc = ();
    push(@proc, {
        'type'       => 'until',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'until',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                                ]
                            },
                        ]
         });
    push(@proc, { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 14
    @proc = ();
    push(@proc, {
        'type'       => 'do',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'do',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                                ]
                            },
                        ]
         });
    push(@proc, { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 15
    @proc = ();
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'for',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                                ]
                            },
                        ]
         });
    push(@proc, { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 16
    @proc = ();
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['i = 0; i < hoge; i++'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,'},
                            {
                                'type'       => 'for',
                                'conditions' => ['j = 0; j < fuga; j++'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                                ]
                            },
                        ]
         });
    push(@proc, { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 17
    @proc = ();
    push(@proc, {
        'type'       => 'switch',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case', 'css' => 'diff=,' },
                            {
                                'type'       => 'switch',
                                'conditions' => ['condition 2'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'ctrl', 'conditions' => ['fuga2'], 'code' => 'case', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                                    { 'type' => 'ctrl', 'code' => 'break', 'css' => 'diff=,' },
                                ]
                            },
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop4', 'css' => 'diff=,' },
                            {
                                'type'       => 'switch',
                                'conditions' => ['condition 3'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'ctrl', 'conditions' => ['piyo 2'], 'code' => 'case', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop5', 'css' => 'diff=,' },
                                    { 'type' => 'ctrl', 'code' => 'break', 'css' => 'diff=,' },
                                    { 'type' => 'ctrl', 'conditions' => ['piyo 3'], 'code' => 'case', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop6', 'css' => 'diff=,' },
                                ]
                            },
                            { 'type' => 'ctrl', 'code' => 'break', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop7', 'css' => 'diff=,' },
                            {
                                'type'       => 'switch',
                                'conditions' => ['condition 4'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop8', 'css' => 'diff=,' },
                                ]
                            },
                            { 'type' => 'proc', 'code' => 'nop9', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 18
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'if',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                                ]
                            },
                        ]
         });
    push(@proc, { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 19
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'if',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                                ]
                            },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop4', 'css' => 'diff=,' },
                            {
                                'type'       => 'if',
                                'conditions' => ['condition3'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop5', 'css' => 'diff=,' },
                                ]
                            },
                            {
                                'type'       => 'else',
                                'conditions' => ['else'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop6', 'css' => 'diff=,' },
                                ]
                            },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 20
    @proc = ();
    push(@proc, { 'type' => 'proc', 'code' => 'nop0', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,'},
                            {
                                'type'       => 'if',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                                ]
                            },
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition3'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            {
                                'type'       => 'if',
                                'conditions' => ['condition4'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop4', 'css' => 'diff=,' },
                                ]
                            },
                            {
                                'type'       => 'else if',
                                'conditions' => ['condition5'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop5', 'css' => 'diff=,' },
                                ]
                            },
                            {
                                'type'       => 'else',
                                'conditions' => ['else'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop6', 'css' => 'diff=,' },
                                ]
                            },
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop7', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop8', 'css' => 'diff=,' },
                            {
                                'type'       => 'if',
                                'conditions' => ['condition6'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop9', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop10', 'css' => 'diff=,' },
                                ]
                            },
                            {
                                'type'       => 'else if',
                                'conditions' => ['condition7'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop11', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop12', 'css' => 'diff=,' },
                                ]
                            },
                            {
                                'type'       => 'else',
                                'conditions' => ['else'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop13', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop14', 'css' => 'diff=,' },
                                ]
                            },
                            { 'type' => 'proc', 'code' => 'nop15', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop16', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, { 'type' => 'proc', 'code' => 'nop17', 'css' => 'diff=,' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

};

done_testing;
