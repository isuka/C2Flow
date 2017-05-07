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
