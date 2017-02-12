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

#
# Divide Function Test
#
subtest "C2Flow->div_function: simple" => sub {
    my $p = C2Flow->new();
    my %exp;
    my $fn = 0;

    $p->read('./t/div_function01.txt');
    $p->div_function();

    #--- function 1
    %exp = (
        'name'   => 'func',
        'src'    => "
    nop
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

    #--- function 2
    %exp = (
        'name'   => 'func2',
        'src'    => "
    nop

    return
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

    #--- function 3
    %exp = (
        'name'   => 'func3',
        'src'    => "
    return var
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

    #--- function 4
    %exp = (
        'name'   => 'int func4',
        'src'    => "
    return var
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;
};

subtest "C2Flow->div_function: complex" => sub {
    my $p = C2Flow->new();
    my %exp;
    my $fn = 0;

    $p->read('./t/div_function02.txt');
    $p->div_function();

    #--- function 1
    %exp = (
        'name'   => 'func',
        'src'    => "
    nop
    {
        nop
    }
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

    #--- function 2
    %exp = (
        'name'   => 'void func2',
        'src'    => "
    nop
    if (condition) {
        nop1
    } else if (condition) {
        nop2
    } else {
        nop3
    }
    return
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

    #--- function 3
    %exp = (
        'name'   => 'int func3(args)',
        'src'    => "
    {
        {
            {
                {
                    { nop }
                }
            }
        }
    }
    {{{{ nop }}}}
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

    #--- function 4
    %exp = (
        'name'   => 'void func4 ( arg1, arg2 )',
        'src'    => "
      void func4-1 ( args ) {
          nop
      }
  ", # 閉じ中括弧の手前にスペースがある
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

};

#
# Divide Function Test
#
subtest "C2Flow->div_control: simple" => sub {
    my $p = C2Flow->new();
    my @proc; # 処理を格納する配列
    my $fn = 0;

    $p->read('./t/div_control01.txt');
    $p->div_function();
    $p->div_control();

    #--- function 1
    @proc = ();
    push(@proc, {'type' => 'proc', 'code' => 'nop1'});
    push(@proc, {'type' => 'proc', 'code' => 'nop2'});
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 2
    @proc = ();
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 3
    @proc = ();
    push(@proc, {
        'type'       => 'until',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 4
    @proc = ();
    push(@proc, {
        'type'       => 'do',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 5
    @proc = ();
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 6
    @proc = ();
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['i = 0; i < hoge; i++'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 7
    @proc = ();
    push(@proc, {
        'type'       => 'switch',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case' },
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'ctrl', 'code' => 'break'},
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case' },
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case' },
                            { 'type' => 'proc', 'code' => 'nop3'},
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
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 9
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop2'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition2'],
        'src'        => '',
        'proc'       => [
                              { 'type' => 'proc', 'code' => 'nop2'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop3'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition2'],
        'src'        => '',
        'proc'       => [
                              { 'type' => 'proc', 'code' => 'nop2'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop3'},
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

};

subtest "C2Flow->div_control: complex" => sub {
    my $p = C2Flow->new();
    my @proc; # 処理を格納する配列
    my $fn = 0;

    $p->read('./t/div_control02.txt');
    $p->div_function();
    $p->div_control();

    #--- func1
    @proc = ();
    push(@proc, {'type' => 'proc', 'code' => 'process 01'});
    push(@proc, {'type' => 'proc', 'code' => 'process 02'});

    ##--- while
    push(@proc, {'type' => 'proc', 'code' => 'while start'});
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'while end'});

    ##--- until
    push(@proc, {'type' => 'proc', 'code' => 'until start'});
    push(@proc, {
        'type'       => 'until',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'until end'});

    ##--- do while
    push(@proc, {'type' => 'proc', 'code' => 'do while start'});
    push(@proc, {
        'type'       => 'do',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'do while end'});

    ##--- for
    push(@proc, {'type' => 'proc', 'code' => 'for start'});
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'for end'});

    ##--- for2
    push(@proc, {'type' => 'proc', 'code' => 'for2 start'});
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['i = 0; i < hoge; i++'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'for2 end'});

    ##--- switch
    push(@proc, {'type' => 'proc', 'code' => 'switch start'});
    push(@proc, {
        'type'       => 'switch',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case' },
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'ctrl', 'code' => 'break'},
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case' },
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case' },
                            { 'type' => 'proc', 'code' => 'nop3'},
                        ]
         });
    push(@proc, {'type' => 'proc', 'code' => 'switch end'});

    ##--- if
    push(@proc, {'type' => 'proc', 'code' => 'if start'});
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [{ 'type' => 'proc', 'code' => 'nop' }]
         });
    push(@proc, {'type' => 'proc', 'code' => 'if end'});

    ##--- else
    push(@proc, {'type' => 'proc', 'code' => 'else start'});
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop2'},
                        ]
         });
    push(@proc, {'type' => 'proc', 'code' => 'else end'});

    ##--- else if
    push(@proc, {'type' => 'proc', 'code' => 'else if start'});
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition2'],
        'src'        => '',
        'proc'       => [
                              { 'type' => 'proc', 'code' => 'nop2'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop3'},
                        ]
         });
    push(@proc, {'type' => 'proc', 'code' => 'else if end'});

    ##--- else  if
    push(@proc, {'type' => 'proc', 'code' => 'else  if start'});
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition2'],
        'src'        => '',
        'proc'       => [
                              { 'type' => 'proc', 'code' => 'nop2'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop3'},
                        ]
         });
    push(@proc, {'type' => 'proc', 'code' => 'else  if end'});

    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 2
    @proc = ();
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'proc', 'code' => 'nop3'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'proc', 'code' => 'nop3'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'proc', 'code' => 'nop3'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'proc', 'code' => 'nop3'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'proc', 'code' => 'nop3'},
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
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case' },
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'proc', 'code' => 'nop3'},
                            { 'type' => 'ctrl', 'code' => 'break'},
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case' },
                            { 'type' => 'proc', 'code' => 'nop4'},
                            { 'type' => 'proc', 'code' => 'nop5'},
                            { 'type' => 'proc', 'code' => 'nop6'},
                            { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case' },
                            { 'type' => 'proc', 'code' => 'nop7'},
                            { 'type' => 'proc', 'code' => 'nop8'},
                            { 'type' => 'proc', 'code' => 'nop9'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'proc', 'code' => 'nop3'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'proc', 'code' => 'nop3'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop4'},
                            { 'type' => 'proc', 'code' => 'nop5'},
                            { 'type' => 'proc', 'code' => 'nop6'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'proc', 'code' => 'nop3'},
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition2'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop4'},
                            { 'type' => 'proc', 'code' => 'nop5'},
                            { 'type' => 'proc', 'code' => 'nop6'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop7'},
                            { 'type' => 'proc', 'code' => 'nop8'},
                            { 'type' => 'proc', 'code' => 'nop9'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            { 'type' => 'proc', 'code' => 'nop2'},
                            { 'type' => 'proc', 'code' => 'nop3'},
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition2'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop4'},
                            { 'type' => 'proc', 'code' => 'nop5'},
                            { 'type' => 'proc', 'code' => 'nop6'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop7'},
                            { 'type' => 'proc', 'code' => 'nop8'},
                            { 'type' => 'proc', 'code' => 'nop9'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            {
                                'type'       => 'while',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2' },
                                ]
                            },
                        ]
         });
    push(@proc, { 'type' => 'proc', 'code' => 'nop3' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 13
    @proc = ();
    push(@proc, {
        'type'       => 'until',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            {
                                'type'       => 'until',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2' },
                                ]
                            },
                        ]
         });
    push(@proc, { 'type' => 'proc', 'code' => 'nop3' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

};

done_testing;
