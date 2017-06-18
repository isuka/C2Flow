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
// whileテスト
func1 {
    while ((cond-1) && (cond-2)) {
      nop1
    }
}

// untilテスト
func2 {
    until ((cond-1) && (cond-2)) {
      nop1
    }
}

// do whileテスト
func3 {
    do {
      nop1
    } while ((cond-1) && (cond-2))
}

// forテスト
func4 {
    for ((cond-1) && (cond-2)) {
      nop1
    }
}

// switchテスト
func5 {
    switch ((cond-1) && (cond-2)) {
    case fuga
        nop1
    case piyo
        nop2
    default
        nop3
    }
}

// ifテスト(if単体)
func6 {
    if ((cond-1) && (cond-2)) {
        nop1
    }
}

// ifテスト(if, else使用)
func7 {
    if ((cond-1) && (cond-2)) {
        nop1
    } else {
        nop2
    }
}

// ifテスト(if, else if, else使用)
func8 {
    if ((cond-1) && (cond-2)) {
        nop1
    } else if ((cond-3) && (cond-4)) {
        nop2
    } else {
        nop3
    }
}

//
// 制御コードのネスト
//

// whileテスト
func20 {
    while ((cond-1) && (cond-2)) {
        nop1
        while ((cond-3) && (cond-4)) {
            nop2
        }
    }
    nop3
}

// untilテスト
func21 {
    until ((cond-1) && (cond-2)) {
        nop1
        until ((cond-3) && (cond-4)) {
            nop2
        }
    }
    nop3
}

// do whileテスト
func22 {
    do {
        nop1
        do {
            nop2
        } while ((cond-3) && (cond-4))
    } while ((cond-1) && (cond-2))
    nop3
}

// forテスト
func23 {
    for ((cond-1) && (cond-2)) {
        nop1
        for ((cond-3) && (cond-4)) {
            nop2
        }
    }
    nop3
}

// switchテスト
func24 {
    switch ((cond-1) && (cond-2)) {
    case fuga
        switch ((cond-f1) && (cond-f2)) {
        case fuga2
            nop1
            break
        }
    case piyo
        nop4
        switch ((cond-p1) && (cond-p2)) {
        case piyo 2
            nop5
            break
        case piyo 3
            nop6
        }
        break
    default
        nop7
        switch ((cond-d1) && (cond-d2)) {
        default
            nop8
        }
        nop9
    }
}

// ifテスト(if単体)
func25 {
    if ((cond-1) && (cond-2)) {
        nop1
        if ((cond-3) && (cond-4)) {
            nop2
        }
    }
    nop3
}

// ifテスト(if, else使用)
func26 {
    if ((cond-1) && (cond-2)) {
        nop1
        if ((cond-3) && (cond-4)) {
            nop2
        }
        nop3
    } else {
        nop4
        if ((cond-5) && (cond-6)) {
            nop5
        } else {
            nop6
        }        
    }
}

// ifテスト(if, else if, else使用)
func27 {
    nop0
    if ((cond-1) && (cond-2)) {
        nop1
        if ((cond-3) && (cond-4)) {
            nop2
            nop3
        }
    } else if ((cond-5) && (cond-6)) {
        if ((cond-7) && (cond-8)) {
            nop4
        } else if ((cond-9) && (cond-10)) {
            nop5
        } else {
            nop6
        }
    } else {
        nop7
        nop8
        if ((cond-11) && (cond-12)) {
            nop9
            nop10
        } else if ((cond-13) && (cond-14)) {
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

    #--- function 1
    @proc = ();
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 2
    @proc = ();
    push(@proc, {
        'type'       => 'until',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 3
    @proc = ();
    push(@proc, {
        'type'       => 'do',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 4
    @proc = ();
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 5
    @proc = ();
    push(@proc, {
        'type'       => 'switch',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop2', 'css' => 'diff=,' },
                            { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop3', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 6
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 7
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['(cond-1) && (cond-2)'],
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
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 10
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['(cond-3) && (cond-4)'],
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
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 20
    @proc = ();
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'while',
                                'conditions' => ['(cond-3) && (cond-4)'],
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

    #--- function 21
    @proc = ();
    push(@proc, {
        'type'       => 'until',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'until',
                                'conditions' => ['(cond-3) && (cond-4)'],
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

    #--- function 22
    @proc = ();
    push(@proc, {
        'type'       => 'do',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'do',
                                'conditions' => ['(cond-3) && (cond-4)'],
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

    #--- function 23
    @proc = ();
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'for',
                                'conditions' => ['(cond-3) && (cond-4)'],
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

    #--- function 24
    @proc = ();
    push(@proc, {
        'type'       => 'switch',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case', 'css' => 'diff=,' },
                            {
                                'type'       => 'switch',
                                'conditions' => ['(cond-f1) && (cond-f2)'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'ctrl', 'conditions' => ['fuga2'], 'code' => 'case', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                                    { 'type' => 'ctrl', 'code' => 'break', 'css' => 'diff=,' },
                                ]
                            },
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case', 'css' => 'diff=,' },
                            { 'type' => 'proc', 'code' => 'nop4', 'css' => 'diff=,' },
                            {
                                'type'       => 'switch',
                                'conditions' => ['(cond-p1) && (cond-p2)'],
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
                                'conditions' => ['(cond-d1) && (cond-d2)'],
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

    #--- function 25
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'if',
                                'conditions' => ['(cond-3) && (cond-4)'],
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

    #--- function 26
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,' },
                            {
                                'type'       => 'if',
                                'conditions' => ['(cond-3) && (cond-4)'],
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
                                'conditions' => ['(cond-5) && (cond-6)'],
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

    #--- function 27
    @proc = ();
    push(@proc, { 'type' => 'proc', 'code' => 'nop0', 'css' => 'diff=,' });
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['(cond-1) && (cond-2)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1', 'css' => 'diff=,'},
                            {
                                'type'       => 'if',
                                'conditions' => ['(cond-3) && (cond-4)'],
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
        'conditions' => ['(cond-5) && (cond-6)'],
        'src'        => '',
        'css'        => 'diff=,',
        'proc'       => [
                            {
                                'type'       => 'if',
                                'conditions' => ['(cond-7) && (cond-8)'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop4', 'css' => 'diff=,' },
                                ]
                            },
                            {
                                'type'       => 'else if',
                                'conditions' => ['(cond-9) && (cond-10)'],
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
                                'conditions' => ['(cond-11) && (cond-12)'],
                                'src'        => '',
                                'css'        => 'diff=,',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop9', 'css' => 'diff=,' },
                                    { 'type' => 'proc', 'code' => 'nop10', 'css' => 'diff=,' },
                                ]
                            },
                            {
                                'type'       => 'else if',
                                'conditions' => ['(cond-13) && (cond-14)'],
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
