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
subtest "C2Flow->div_function: simple" => sub {
    my $p = C2Flow->new();
    my %exp;
    my $fn = 0;

    $p->read('./t/div_function01.txt');
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
