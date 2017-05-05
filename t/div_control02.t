#!/usr/local/bin/perl-5.22.0

use utf8;
use strict;
use warnings;

use Test::More;
#use Devel::Cover;

use C2Flow;

#
# Divide Function Test
#
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

done_testing;
