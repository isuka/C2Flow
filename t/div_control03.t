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

done_testing;
