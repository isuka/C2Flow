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
subtest "C2Flow->div_function: complex" => sub {
    my $p = C2Flow->new();
    my %exp;
    my $fn = 0;

    $p->read('./t/div_function02.txt');
    $p->div_function();

    #--- function 1
    %exp = (
        'name'   => 'func',
        'css'    => 'diff=,',
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
        'css'    => 'diff=,',
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
        'css'    => 'diff=,',
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
        'css'    => 'diff=,',
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
        'css'    => 'diff=,',
        'src'    => "
    nop
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

    #--- function 6
    %exp = (
        'name'   => 'void func6(int argc,char *argv)',
        'css'    => 'diff=,',
        'src'    => "
    nop
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

};

done_testing;
