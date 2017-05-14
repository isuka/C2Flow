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
// 戻り値型無し, 引数無し, return無し
func {
    nop
}

// 戻り値型無し, 引数無し, return有り(void)
func2
{
    nop

    return
}

// 戻り値型無し, 引数無し, return有り(non void)
func3
{
    return var
}

// 戻り値型有り, 引数無し, return有り(non void)
int func4
{
    return var
}
";

#
# Divide Function Test
#
subtest "C2Flow->div_function: simple" => sub {
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
        'css'    => 'diff=,',
        'src'    => "
    nop
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

    #--- function 2
    %exp = (
        'name'   => 'func2',
        'css'    => 'diff=,',
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
        'css'    => 'diff=,',
        'src'    => "
    return var
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;

    #--- function 4
    %exp = (
        'name'   => 'int func4',
        'css'    => 'diff=,',
        'src'    => "
    return var
",
    );
    is_deeply($p->{'functions'}[$fn], \%exp) || diag explain $p->{'functions'}[$fn];
    $fn++;
};

done_testing;
