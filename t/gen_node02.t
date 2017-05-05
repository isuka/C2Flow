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
subtest "C2Flow->gen_node: complex" => sub {
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

    #--- function 17-5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 17-5 switch break from if',
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
                             'text' => 'hoge1'
                         },
                         {
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a0a', 'shape' => 'square', 'text' => 'nop12',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a5a', 'shape' => 'square', 'text' => 'nop d',
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

    #--- function 17-6
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 17-6 switch break from if',
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
                             'text' => 'hoge1'
                         },
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => 'default'
                         }
                     ]});
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'id0a1a0a', 'shape' => 'square', 'text' => 'nop11',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a0a', 'shape' => 'square', 'text' => 'nop12',
                     'next' => [
                         {
                             'id'   => 'id0a4a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a4a', 'shape' => 'square', 'text' => 'nop d',
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

    #--- function 17-7
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 17-7 switch break from if',
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
    push(@node, {'id' => 'id0a1a', 'shape' => 'diamond', 'text' => 'cond2',
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
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a2a', 'shape' => 'diamond', 'text' => 'cond3',
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
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a3a0a', 'shape' => 'square', 'text' => 'nop13',
                     'next' => [
                         {
                             'id'   => 'id0a5a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a5a', 'shape' => 'diamond', 'text' => 'cond4',
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
    push(@node, {'id' => 'id0a5a0a', 'shape' => 'square', 'text' => 'nop21',
                     'next' => [
                         {
                             'id'   => 'id0a9a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a6a', 'shape' => 'diamond', 'text' => 'cond5',
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
    push(@node, {'id' => 'id0a6a0a', 'shape' => 'square', 'text' => 'nop22',
                     'next' => [
                         {
                             'id'   => 'id0a9a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a7a0a', 'shape' => 'square', 'text' => 'nop23',
                     'next' => [
                         {
                             'id'   => 'id0a9a',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a9a', 'shape' => 'diamond', 'text' => 'cond6',
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
    push(@node, {'id' => 'id0a9a0a', 'shape' => 'square', 'text' => 'nop31',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a10a', 'shape' => 'diamond', 'text' => 'cond7',
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
    push(@node, {'id' => 'id0a10a0a', 'shape' => 'square', 'text' => 'nop32',
                     'next' => [
                         {
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0a11a0a', 'shape' => 'square', 'text' => 'nop33',
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

    #--- function 18-1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-1',
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
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-2',
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
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-3
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-3',
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
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-4',
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
                             'id'   => 'id0b',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id0b', 'shape' => 'diamond', 'text' => 'cond1',
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
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-5',
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
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 18-6
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 18-6',
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
                             'id'   => 'return',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id1a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return'});
    is_deeply($p->{'functions'}[$fn]->{'node'}, \@node) || diag explain $p->{'functions'}[$fn]->{'node'};
    $fn++;

    #--- function 19-1
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-1',
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
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop2',
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

    #--- function 19-2
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-2',
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
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop2',
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

    #--- function 19-3
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-3',
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
                             'id'   => 'id2a',
                             'link' => 'allow',
                             'text' => 'false'
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop2',
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

    #--- function 19-4
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-4',
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
                             'id'   => 'id1b',
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
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop2',
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

    #--- function 19-5
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-5',
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
                             'text' => ''
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'square', 'text' => 'nop2',
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

    #--- function 19-6
    @node = ();
    push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => 'func 19-6',
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
                             'id'   => 'id4a',
                             'link' => 'allow',
                             'text' => 'true'
                         }
                     ]});
    push(@node, {'id' => 'id2a', 'shape' => 'diamond', 'text' => 'cond2',
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
    push(@node, {'id' => 'id4a', 'shape' => 'square', 'text' => 'nop2',
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
