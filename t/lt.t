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

    #--- function 5
    %exp = (
        'name'   => 'void func5 (int *arg)',
        'src'    => "
    nop
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

    #--- function 6
    %exp = (
        'name'   => 'void func6(int argc,char *argv)',
        'src'    => "
    nop
",
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

    #--- function 14
    @proc = ();
    push(@proc, {
        'type'       => 'do',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            {
                                'type'       => 'do',
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

    #--- function 15
    @proc = ();
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            {
                                'type'       => 'for',
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

    #--- function 16
    @proc = ();
    push(@proc, {
        'type'       => 'for',
        'conditions' => ['i = 0; i < hoge; i++'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            {
                                'type'       => 'for',
                                'conditions' => ['j = 0; j < fuga; j++'],
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

    #--- function 17
    @proc = ();
    push(@proc, {
        'type'       => 'switch',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case'},
                            {
                                'type'       => 'switch',
                                'conditions' => ['condition 2'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'ctrl', 'conditions' => ['fuga2'], 'code' => 'case'},
                                    { 'type' => 'proc', 'code' => 'nop1'},
                                    { 'type' => 'proc', 'code' => 'nop2'},
                                    { 'type' => 'proc', 'code' => 'nop3'},
                                    { 'type' => 'ctrl', 'code' => 'break'},
                                ]
                            },
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case'},
                            { 'type' => 'proc', 'code' => 'nop4'},
                            {
                                'type'       => 'switch',
                                'conditions' => ['condition 3'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'ctrl', 'conditions' => ['piyo 2'], 'code' => 'case'},
                                    { 'type' => 'proc', 'code' => 'nop5'},
                                    { 'type' => 'ctrl', 'code' => 'break'},
                                    { 'type' => 'ctrl', 'conditions' => ['piyo 3'], 'code' => 'case'},
                                    { 'type' => 'proc', 'code' => 'nop6'},
                                ]
                            },
                            { 'type' => 'ctrl', 'code' => 'break'},
                            { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case'},
                            { 'type' => 'proc', 'code' => 'nop7'},
                            {
                                'type'       => 'switch',
                                'conditions' => ['condition 4'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case'},
                                    { 'type' => 'proc', 'code' => 'nop8'},
                                ]
                            },
                            { 'type' => 'proc', 'code' => 'nop9'},
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
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            {
                                'type'       => 'if',
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

    #--- function 19
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            {
                                'type'       => 'if',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2' },
                                ]
                            },
                            { 'type' => 'proc', 'code' => 'nop3'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop4'},
                            {
                                'type'       => 'if',
                                'conditions' => ['condition3'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop5' },
                                ]
                            },
                            {
                                'type'       => 'else',
                                'conditions' => ['else'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop6' },
                                ]
                            },
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 20
    @proc = ();
    push(@proc, { 'type' => 'proc', 'code' => 'nop0' });
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['condition1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1'},
                            {
                                'type'       => 'if',
                                'conditions' => ['condition2'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop2' },
                                    { 'type' => 'proc', 'code' => 'nop3' },
                                ]
                            },
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['condition3'],
        'src'        => '',
        'proc'       => [
                            {
                                'type'       => 'if',
                                'conditions' => ['condition4'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop4' },
                                ]
                            },
                            {
                                'type'       => 'else if',
                                'conditions' => ['condition5'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop5' },
                                ]
                            },
                            {
                                'type'       => 'else',
                                'conditions' => ['else'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop6' },
                                ]
                            },
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop7'},
                            { 'type' => 'proc', 'code' => 'nop8'},
                            {
                                'type'       => 'if',
                                'conditions' => ['condition6'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop9' },
                                    { 'type' => 'proc', 'code' => 'nop10' },
                                ]
                            },
                            {
                                'type'       => 'else if',
                                'conditions' => ['condition7'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop11' },
                                    { 'type' => 'proc', 'code' => 'nop12' },
                                ]
                            },
                            {
                                'type'       => 'else',
                                'conditions' => ['else'],
                                'src'        => '',
                                'proc'       => [
                                    { 'type' => 'proc', 'code' => 'nop13' },
                                    { 'type' => 'proc', 'code' => 'nop14' },
                                ]
                            },
                            { 'type' => 'proc', 'code' => 'nop15'},
                            { 'type' => 'proc', 'code' => 'nop16'},
                        ]
         });
    push(@proc, { 'type' => 'proc', 'code' => 'nop17' });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

};

subtest "C2Flow->div_control: misc" => sub {
    my $p = C2Flow->new();
    my @proc; # 処理を格納する配列
    my $fn = 0;

    $p->read('./t/div_control03.txt');
    $p->div_function();
    $p->div_control();

    #--- function 1
    @proc = ();
    push(@proc, {'type' => 'proc', 'code' => 'nop1'});
    ok($p->{'functions'}[$fn]->{'name'} eq 'func1 (int argc, char *argv)');
    $fn++;

    #--- function 2
    @proc = ();
    push(@proc, {
        'type'       => 'if',
        'conditions' => ['cond1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'ctrl', 'code' => 'return'},
                        ]
         });
    push(@proc, {
        'type'       => 'else if',
        'conditions' => ['cond2'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'ctrl', 'code' => 'exit'},
                        ]
         });
    push(@proc, {
        'type'       => 'else',
        'conditions' => ['else'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'ctrl', 'code' => 'return 1'},
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
        'proc'       => [
                            { 'type' => 'ctrl', 'conditions' => ['fuga'], 'code' => 'case' },
                            { 'type' => 'ctrl', 'code' => 'return'},
                            { 'type' => 'ctrl', 'conditions' => ['piyo'], 'code' => 'case' },
                            { 'type' => 'proc', 'code' => 'nop'},
                            { 'type' => 'ctrl', 'code' => 'break'},
                            { 'type' => 'ctrl', 'conditions' => ['default'], 'code' => 'case' },
                            { 'type' => 'ctrl', 'code' => 'exit 1'},
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 4
    @proc = ();
    push(@proc, {'type' => 'ctrl', 'code' => 'return 1'});
    push(@proc, {'type' => 'ctrl', 'code' => 'exit 2'});
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

    #--- function 5
    @proc = ();
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['cond1'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop1' },
                            { 'type' => 'ctrl', 'code' => 'return 1'},
                        ]
         });
    push(@proc, {
        'type'       => 'while',
        'conditions' => ['cond2'],
        'src'        => '',
        'proc'       => [
                            { 'type' => 'proc', 'code' => 'nop2' },
                            { 'type' => 'ctrl', 'code' => 'exit 2'},
                        ]
         });
    is_deeply($p->{'functions'}[$fn]->{'proc'}, \@proc) || diag explain $p->{'functions'}[$fn]->{'proc'};
    $fn++;

};

#
# Node Generation Test
#
subtest "C2Flow->gen_node: simple" => sub {
    my $p = C2Flow->new();
    my @node; # 処理を格納する配列
    my $fn = 0;

    $p->read('./t/gen_node01.txt');
    $p->div_function();
    $p->div_control();
    $p->gen_node();

    #--- function 1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func1',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func2',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 3
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func3',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func4',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'circle', 'text' => ' ',
                     'next' => [
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0b', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0b',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func5',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 6
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func6',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'i = 0; i < hoge; i++',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 7
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func7',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
                             'id'   => 'id0a6a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0a6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a6a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 8
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func8',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 9
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func9',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
                     'next' => [
                         {
                             'id'   => 'id1a0a',
                             'link' => 'allow',
                             'text' => 'false'
                         },
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'square', 'text' => 'nop4',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 10
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func10',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'condition2',
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
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'square', 'text' => 'nop4',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a0a', 'shape' => 'square', 'text' => 'nop5',
                     'next' => [
                         {
                             'id'   => 'id2a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a1a', 'shape' => 'square', 'text' => 'nop6',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

};

subtest "C2Flow->gen_node: complex" => sub {
#    plan skip_all => 'TBD';
    my $p = C2Flow->new();
    my @node; # 処理を格納する配列
    my $fn = 0;

    $p->read('./t/gen_node02.txt');
    $p->div_function();
    $p->div_control();
    $p->gen_node();

    #--- function 1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func1',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'round square', 'text' => 'return'});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'round square', 'text' => 'exit'});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func2',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'round square', 'text' => 'return'});
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a7a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'id0a8a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a8a', 'shape' => 'round square', 'text' => 'exit 1'});
    push(@node, {'id' => 'id1a', 'shape' => 'round square', 'text' => 'return 0'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 3
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func3',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'round square', 'text' => 'return',});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func4',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'round square', 'text' => 'exit 1',});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func5',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 6
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func6',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 7
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func7',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'id3a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id3a', 'shape' => 'diamond', 'text' => 'cond4',
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
    push(@node, {'id' => 'id3a0a', 'shape' => 'square', 'text' => 'nop4',
                     'next' => [
                         {
                             'id'   => 'id6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id4a', 'shape' => 'diamond', 'text' => 'cond5',
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
    push(@node, {'id' => 'id4a0a', 'shape' => 'square', 'text' => 'nop5',
                     'next' => [
                         {
                             'id'   => 'id6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id5a0a', 'shape' => 'square', 'text' => 'nop6',
                     'next' => [
                         {
                             'id'   => 'id6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id6a', 'shape' => 'square', 'text' => 'nop7',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 8
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func8',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a5a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'id1a6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a6a', 'shape' => 'round square', 'text' => 'return 3'});
    push(@node, {'id' => 'id2a', 'shape' => 'round square', 'text' => 'return 0'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 9
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func9',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a6a', 'shape' => 'square', 'text' => 'nop4',
                     'next' => [
                         {
                             'id'   => 'id1a7a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a7a', 'shape' => 'round square', 'text' => 'return 4'});
    push(@node, {'id' => 'id2a', 'shape' => 'round square', 'text' => 'return 0'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 10
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func10 while nest',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'condition11',
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
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop12',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 11
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func11 until nest',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'condition10',
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
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop12',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 12
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func12 do nest',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'circle', 'text' => ' ',
                     'next' => [
                         {
                             'id'   => 'id0a0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0b', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'circle', 'text' => ' ',
                     'next' => [
                         {
                             'id'   => 'id0a1a0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1b', 'shape' => 'diamond', 'text' => 'condition10',
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
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop12',
                     'next' => [
                         {
                             'id'   => 'id0a1b',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0b',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 10
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func13 for nest',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'condition10',
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
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop12',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 14-1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func14-1 switch nest',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'condition10',
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
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop11',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a4a', 'shape' => 'square', 'text' => 'nop12',
                     'next' => [
                         {
                             'id'   => 'id0a1a6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a6a', 'shape' => 'square', 'text' => 'nop13',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a5a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0a7a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a7a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 14-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func14-2 switch nest',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a1a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'diamond', 'text' => 'condition10',
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
    push(@node, {'id' => 'id0a2a1a', 'shape' => 'square', 'text' => 'nop11',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a4a', 'shape' => 'square', 'text' => 'nop12',
                     'next' => [
                         {
                             'id'   => 'id0a2a6a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a6a', 'shape' => 'square', 'text' => 'nop13',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a5a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id0a7a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a7a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 15
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func15 if nest',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id0a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'condition10',
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
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop10',
                     'next' => [
                         {
                             'id'   => 'id0a1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a1a1a', 'shape' => 'square', 'text' => 'nop11',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'diamond', 'text' => 'condition11',
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
    push(@node, {'id' => 'id0a2a0a', 'shape' => 'square', 'text' => 'nop12',
                     'next' => [
                         {
                             'id'   => 'id0a2a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a1a', 'shape' => 'square', 'text' => 'nop13',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a3a0a', 'shape' => 'square', 'text' => 'nop14',
                     'next' => [
                         {
                             'id'   => 'id0a3a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a3a1a', 'shape' => 'square', 'text' => 'nop15',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'condition2',
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
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'square', 'text' => 'nop4',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a0a', 'shape' => 'square', 'text' => 'nop5',
                     'next' => [
                         {
                             'id'   => 'id2a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a1a', 'shape' => 'square', 'text' => 'nop6',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 16-1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func16-1 switch case only 1',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 16-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func16-2 switch case only 2',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 16-3
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func16-3 switch case only 3',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 16-4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func16-4 switch multi case',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a5a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 16-5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func16-5 switch multi case',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'diamond', 'text' => 'condition1',
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
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a7a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func17-1 while break from if',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'id1a1a0a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop4',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop5',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func17-2 until break from if',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'id1a1a0a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop4',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop5',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func17-3 do break from if',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'circle', 'text' => ' ',
                     'next' => [
                         {
                             'id'   => 'id1a0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1b', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'id1a1a0a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop4',
                     'next' => [
                         {
                             'id'   => 'id1b',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop5',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 17-4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func17-4 for break from if',
                     'next' => [
                         {
                             'id'   => 'id0a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a', 'shape' => 'square', 'text' => 'nop1',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'id1a0a', 'shape' => 'square', 'text' => 'nop2',
                     'next' => [
                         {
                             'id'   => 'id1a1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a1a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'id1a1a0a', 'shape' => 'square', 'text' => 'nop3',
                     'next' => [
                         {
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id1a2a', 'shape' => 'square', 'text' => 'nop4',
                     'next' => [
                         {
                             'id'   => 'id1a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop5',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

};

done_testing;
