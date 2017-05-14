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
// 関数内に中括弧がある(制御構文ではない)
func {
    nop
    {
        nop
    }
}

// 関数内に中括弧がある(制御構文)
void func2 {
    nop
    if (condition) {
        nop1
    } else if (condition) {
        nop2
    } else {
        nop3
    }
    return
}

// 関数内の中括弧が深くネストしている
int func3(args)
{
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
}

// 関数内に関数定義がある(インライン関数を想定だが、多分無いパターン)
  void func4 ( arg1, arg2 ) 
  {
      void func4-1 ( args ) {
          nop
      }
  }

// 関数の引数に関数ポインタを使用している
void func5 (int *arg)
{
    nop
}

void func6(int argc,char *argv)
{
    nop
}
";

#
# Divide Function Test
#
subtest "C2Flow->div_function: complex" => sub {
    my $p = C2Flow->new();
    my %exp;
    my $fn = 0;

    my ($fh, $filename) = tempfile(UNLINK => 1);
    print $fh encode('utf-8', TEST_CODE);
    close($fh);

    $p->read($filename);
    $p->div_function();

    #--- function 1
    %exp = (
        'name'   => 'func',
        'title'  => '',
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
        'title'  => '',
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
        'title'  => '',
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
        'title'  => '',
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
        'title'  => '',
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
        'title'  => '',
        'css'    => 'diff=,',
        'src'    => "
    nop
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

};

done_testing;
