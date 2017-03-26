#!/usr/local/bin/perl

use utf8;
use strict;
use warnings;

use C2Flow;

my $file_name = $ARGV[0];
my $p = C2Flow->new();

$p->read($file_name);
$p->div_function();
$p->div_control();
$p->gen_node();
$p->gen_mermaid();
#$p->conv_func();
#$p->gen_html();

