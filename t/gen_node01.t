#!/usr/local/bin/perl-5.22.0

use utf8;
use strict;
use warnings;

use Test::More;
#use Devel::Cover;

use C2Flow;

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

done_testing;
