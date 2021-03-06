#!/usr/local/bin/perl-5.22.0

=pod

TODO:
- 複数行の処理を扱えるようにする。

- 異常を見つけた時にコードのおかしいところを指摘する。
  ->擬似コードを表示できるようにする必要がある

https://ds504.awmdm.jp
FJ-EMM

=cut

package C2Flow;

use utf8;
use strict;
use warnings;

sub new
{
    my $class = shift;

    my $read_src;
    my @funclist;

    my $self = {
        'read_src' => \$read_src,
        'funclist' => \@funclist
    };

    bless $self, $class;

    return $self;
}

sub read {
    my $self = shift;
    my $file = shift;

    open (my $fh, '<', $file) or die 'cannot open file';
    while (<$fh>) {
        s/[\r\n]+$/\n/; # 改行コードを\nに統一
        s/\t/ /g;       # タブを空白に置換
        s/　/  /g;      # 全角空白を半角空白x2に置換

        # titleタグがあれば保存する
        my $title = m|(<title>.*?</title>)| ? $1 : '';
        
        s/\/\/.*$//;    # 一行コメントを削除
        ${$self->{'read_src'}} .= $title;
        ${$self->{'read_src'}} .= $_;
    }
    ${$self->{'read_src'}} =~ s/\/\*.*?\*\///gs; # コメント行を削除
}

# $self->'read_src'を関数に分割する
# 分割した関数は$self->'functions'(@array)に以下のhashをpushする
#   % {
#     'name'
#     'src'
#   }
sub div_function {
    my $self = shift;
    my @functions;

    $self->{'functions'} = \@functions;
    my $depth = 0;
    my ($name, $src);
    while (${$self->{'read_src'}} =~ m/(.)/gs) {
        my $char = $1;

        if ($char eq '{') {
            if ($depth == 0) {
                # 深さが1以上になるなら関数が始まるので新規にハッシュを宣言する
                my %f;
                push(@functions, \%f);

                # 改行と前後のスペースを取り除いて関数名を確定させる
                # この時、中括弧は保存しない
                $name =~ s/\n//g;

                my $title;
                if ($name =~ s|<title>(.*?)</title>||g) {
                    $title = $1;
                } else {
                    $title = '';
                }

                $name =~ s/^ +//g;
                $name =~ s/ +$//g;

                # 行頭のunified diff形式を解釈する。
                if ($name =~ s/^([\+\-]) +//) {
                    $f{'css'} = 'diff=' . $1 . ',';
                } else {
                    $f{'css'} = 'diff=,';
                }

                $f{'name'} = $name;
                $f{'title'} = $title;
                $name = '';
            } else {
                # 深さが1以上なら関数中の中括弧なのでソースに含める
                $src .= $char;
            }
            $depth++;
        } elsif ($char eq '}') {
            $depth--;
            if ($depth == 0) {
                # 深さが0に戻るなら関数は終了なのでソースを確定させる
                # この時、中括弧は保存しない
                # ここでは%fのスコープは無いのでリファレンス経由でアクセスする
                $functions[$#functions]->{'src'} = $src;
                $src = '';
            } else {
                # 深さが1以上なら関数中の中括弧なのでソースに含める
                $src .= $char;
            }
        } else {
            if ($depth == 0) {
                $name .= $char;
            } else {
                $src .= $char;
            }
        }
    }
}

# セミコロンの記述を不要にする代わりに、制御構文は空白を除いた行頭になければならない。
# {
#    'functions' => \@function
#                   + [n] {
#                            'name' => func name
#                            'src'  => souece code
#                            'proc' => \@proc
#                                      + [n] {
#                                              -- process
#                                              'type' => proc tyep
#                                              'code' => proc code
#
#                                              -- other
#                                              'type'       => while|untile|do|for|switch|if
#                                              'conditions' => \@conditions
#                                              'src'        => source code
#                                              'proc'       => \@proc ... 再帰的に格納
#                                            }
#                         }
# }

sub div_control {
    my $self = shift;
    my $functions = $self->{'functions'};

    foreach (@{$functions}) { &source2proc($_); }
}

sub source2proc {
    my $f = shift; # function|procハッシュのリファレンス
    my $src = $f->{'src'};
    my @proc;         # 関数の最上位proc
    my @ctrl_refs;    # ネストしていった時のctrl系hashのリファレンス、ネストしたreturn先にもなる、depthをインデックスとして使用する
    my @ctrls = (''); # [0]の最初は何の制御も行っていないのでNULLで初期化する
    my $ctrl_ref;
    my $depth = 0;

    # 呼び出しで渡されたリファレンス(処理のカレントになるハッシュ)をctrl_refsに保存する。
    push(@ctrl_refs, $f);
    $ctrl_ref = $f;

    # 処理した(する)srcは削除
    # 改行のみの行はforeachがスキップされてしまうので、この位置でクリアが必要
    $f->{'src'} = '';

    foreach my $line (split(/\n/, $src)) {
        my $src_ctrl = '';
        # $srcが''(procに分割済)の時に再起呼び出しされるとprocを別のリファレンスで
        # 書き潰してしまうので冗長だがこの位置でリファレンス代入
        $f->{'proc'} = \@proc;

        # 行頭のunified diff形式を解釈する。
        if ($line =~ s/^([\+\-]) +//) {
            $src_ctrl = 'diff=' . $1 . ',';
        } else {
            $src_ctrl = 'diff=,';
        }

        # 行頭と行末の空白を削除
        $line =~ s/^ +//;
        $line =~ s/ +$//;

        # 空行は飛ばす
        if ($line eq '') { next; }

        # 疑似コードの処理部にて、文頭に書かれた制御文字を誤認識しないよう厳密にマッチをかける
        # ただし、switchのcaseとdefaultは疑似コードの文法上(コロンが無い)、処理コードと見分けが付けられないため
        # コードのみでマッチをかけている。
        #   ex) 以下の1行目を制御文と解釈してはならない
        #       do ループの前処理
        #       do {
        #           do ループ処理
        #       } while(継続条件)
        if ($line =~ m/(while *\(.+\)( *\{)*|until *\(.*\) *\{|do *\{|for *\(.+\) *\{|switch *\(.+\) *\{|if *\(.+\) *\{|\} *else +if *\(.+\) *\{|\} *else *\{|case|default)/) {
            # doを識別中のwhile、ifを識別中のelse if|elseでは新しいハッシュを作成しない
            my $match_ctrl = $1;            
            # 制御コード以外(条件部や中括弧)を除去
            $match_ctrl =~ s/ *\(.+\)//; # while, untile, for, switch, if, else ifの条件部を削除
            $match_ctrl =~ s/\} *//;     # else if, elseの閉じ中括弧を削除
            $match_ctrl =~ s/ *\{//;     # while, untile, for, switch, if, else if, else, doの開き中括弧を削除
            $match_ctrl =~ s/else +if/else if/;

            if (($ctrls[$#ctrls] eq 'switch') && ($match_ctrl eq 'case')) {
                # 条件を取り出し
                $line =~ s/.*case +(.+?):?$//;
                my $condition = $1;

                # @conditionsにpushした同一インデックスの@procにprocハッシュ作成
                my @conditions = ();
                my @proc_child = ();
                my %f_case = (
                    'type'       => 'ctrl',
                    'conditions' => \@conditions,
                    'code'       => 'case',
                    'css'        => $src_ctrl,
                    );
                push(@conditions, $condition); # type=caseの場合conditionのメンバー数は1

                push(@{$ctrl_ref->{'proc'}}, \%f_case);
            } elsif (($ctrls[$#ctrls] eq 'switch') && ($match_ctrl eq 'default')) {
                # @conditionsにpushした同一インデックスの@procにprocハッシュ作成
                my @conditions = ();
                my @proc_child = ();
                my %f_case = (
                    'type'       => 'ctrl',
                    'conditions' => \@conditions,
                    'code'       => 'case',
                    'css'        => $src_ctrl,
                    );
                push(@conditions, 'default'); # defaultのconditionはdefaultとする
                
                push(@{$ctrl_ref->{'proc'}}, \%f_case);
            } elsif (($ctrls[$#ctrls] eq 'do') && ($match_ctrl eq 'while')) {
                # TODO: '}'とwhileは同じ行にある想定かつ、whileの条件文も同じ行にある想定の処理
                $line =~ s/[^\(]*\( *(.*) *\).*/$1/;
                $ctrl_ref->{'conditions'}[0] = $line;

                &source2proc($ctrl_ref);
                $depth--;
                pop(@ctrl_refs);
                $ctrl_ref = $ctrl_refs[$#ctrl_refs];

                if ($depth == 0) {
                    $ctrls[$#ctrls] = '';
                } else {
                    pop(@ctrls);
                }
            } else {
                # elseで中括弧が閉じられたらそこまでのsrcをprocに分解するため再帰呼び出しを行う。
                if (($match_ctrl eq 'else') || ($match_ctrl eq 'else if')) {
                    &source2proc($ctrl_ref);
                    pop(@ctrls);
                    $depth--;
                    pop(@ctrl_refs);
                    $ctrl_ref = $ctrl_refs[$#ctrl_refs];
                }

                # 識別中の制御を更新
                push(@ctrls, $match_ctrl);
                my @conditions = ();
                my @proc_child = ();

                # 今までは@proc(トップのproc)に順番にpushしていた
                # これは1階層しか無い場合はpushすべきprocも一つなので問題ない。
                # これを複数階層に対応させようとすると、pushしたprocのprocに次の階層をpushしていかなければならない
                # @proc [
                #   proc { .. }
                #   proc { .. }  <- 今まではこれのリファレンスを$ctrl_refに入れていた
                # ]
                #
                # @proc [
                #   proc { .. }
                #   proc {
                #     @proc [
                #       proc { .. } <- ここのリファレンスが必要
                #     ]
                #   } 
                #

                # +- procs ----+
                # | proc       |
                # +------------+
                # | ctrl       |   +- procs-----+
                # | + proc ------> | proc       |
                # +------------+   +------------+
                # | proc       |   | proc       |
                # +------------+   +------------+
                #                  | ctrl       |   +- procs-----+  <- 2.
                #                  | + proc ------> | proc       |  <- 1.
                #                  +------------+   +------------+
                #
                # 1. ctrl系の文字列がマッチすると無名ハッシュを作成してprocにpushする。
                # 2. ctrl_refを更新、pushしたprocがctrl_refになる。
                #
                my %noname_hash = (
                    'type'       => $ctrls[$#ctrls],
                    'conditions' => \@conditions,
                    'src'        => '',
                    'proc'       => \@proc_child,
                    'css'        => $src_ctrl,
                    );

                push(@{$ctrl_ref->{'proc'}}, \%noname_hash);
                # 次のカレントは作成したハッシュになるので、ctrl_refsとctrl_refを更新する
                push(@ctrl_refs, \%noname_hash);
                $ctrl_ref = \%noname_hash;

                # 同一行で中括弧を開いて閉じてはしないものとする
                # 開き中括弧は制御文字と同一行にあるものとする
                $depth++;

                if ($match_ctrl eq 'else') {
                    my $condition = 'else';
                    push(@conditions, $condition);
                } else {
                    $line =~ s/(.+)\{ *//;
                    if ($line ne '') {
                        $ctrl_ref->{'src'} .= $line . "\n";
                    }
                    my $condition = $1;
                    $condition =~ s/[^\(]*\( *(.*) *\).*/$1/;
                    push(@conditions, $condition);
                }
            }

        } elsif ($line =~ m/\}/) {
            &source2proc($ctrl_ref);
            pop(@ctrls);

            $depth--;
            pop(@ctrl_refs);
            $ctrl_ref = $ctrl_refs[$#ctrl_refs];
        } else {
            if ($line =~ m/(?:return|exit)/) {
                push(@{$ctrl_ref->{'proc'}}, {
                         'type'    => 'ctrl',
                         'code'    => $line,
                         'css'     => $src_ctrl,
                     });
            } elsif ($line =~ m/(break)/) {
                push(@{$ctrl_ref->{'proc'}}, {
                         'type'    => 'ctrl',
                         'code'    => $1,
                         'css'     => $src_ctrl,
                     });
            } else {
                push(@{$ctrl_ref->{'proc'}}, {
                        'type'    => 'proc',
                        'code'    => $line,
                        'css'     => $src_ctrl,
                     });
            }
        }
    }
}

# ノード間の接続を作成する
# %function {
#     node => [
#               % {
#                   id    => ''
#                   shape => 'square|round square|circle|diamond'
#                   text  => ''
#                   next  => @ [
#                                % {
#                                    id   => ''
#                                    link => 'allow|open|dot|thick'
#                                    text => ''
#                                }
#                           ]
#               }
#             ]
# }
sub gen_node {
    my $self = shift;
    my $functions = $self->{'functions'};
    
    foreach (@{$functions}) {
        my $function = $_;
        my @node;
        
        # 関数開始のノード作成
        push(@node, {'id' => 'start', 'shape' => 'round square', 'text' => $function->{'name'}, 'css' => $function->{'css'},
                         'next' => [
                             {
                                 'id'   => 'id0a',
                                 'link' => 'allow',
                                 'text' => '',
                             }
                         ]});
        $function->{'node'} = \@node;
        # 関数内のノード作成
        &proc2node($function->{'node'}, $function->{'proc'}, 'id', 'return', 'return');
        # 関数終了(return)のノード作成
        # @nodeの最後にreturn|exitが無い場合はreturnを生成する
        my $last_node = $node[$#node];
        if ($last_node->{'text'} !~ m/(?:return|exit)/) {
            push(@node, {'id' => 'return', 'shape' => 'round square', 'text' => 'return', 'css' => $function->{'css'}});
        }
    }
}

# この関数はgen_nodeから呼ばれる場合と、再帰呼出しで呼ばれる2種類起動方法がある。
# そのため、引数はどの方法で呼ばれても矛盾無く動作しなければならない。
sub proc2node {
    my $node_ref  = shift;
    my $proc_ref  = shift;
    my $parent_id = shift;
    my $return_id = shift;
    my $break_id  = shift;

    # switch文内の処理を解析する時、先にcaseのリンク先を作った後、procを生成する。
    # この時、break無しcaseは下のcase文に処理を繋ぎ直さないとならないので、最初に生成したリンク先を
    # 編集する必要があるため、何番目のリンク先を繋ぎ直すか覚えておく必要がある。
    my $sw_case_count = 0;

    for (my $i = 0; $i < scalar(@$proc_ref); $i++) {
        my $proc = $proc_ref->[$i];
        my $type = $proc->{'type'};
        my $css  = $proc->{'css'};
#        printf("> type=%s, code=%s\n", $type, defined($proc->{'code'}) ? $proc->{'code'} : 'no');
        if ($type eq 'proc') {
            my $id = sprintf("%s%da", $parent_id, $i);

            my @next;
            if ($i == $#{$proc_ref}) {
                push(@next, {
                        'id'   => $return_id,
                        'link' => 'allow',
                        'text' => ''
                     });
            } else {
                push(@next, {
                        'id'   => sprintf("%s%da", $parent_id, $i + 1),
                        'link' => 'allow',
                        'text' => ''
                     });
            }

            push(@$node_ref, {
                    'id'    => $id,
                    'shape' => 'square',
                    'text'  => $proc->{'code'},
                    'css'   => $css,
                    'next'  => \@next
                 });
        } elsif (($type eq 'while') || ($type eq 'for')) {
            my $id = sprintf("%s%da", $parent_id, $i);
            my $proc_ret_id;
            if ($i == $#{$proc_ref}) {
                $proc_ret_id = $return_id;
            } else {
                $proc_ret_id = sprintf("%s%da", $parent_id, $i + 1);
            }
            
            my @next;
            # falseのlink先を作成
            push(@next, {
                    'id'   => $proc_ret_id,
                    'link' => 'allow',
                    'text' => 'false',
                 });
            # trueのlink先を作成
            if (scalar(@{$proc->{'proc'}}) > 0) {
                # 再帰呼び出しで1段下がったプロセスになるので、今のIDに1桁増やしたIDになる。
                push(@next, {
                        'id'   => sprintf("%s0a", $id),
                        'link' => 'allow',
                        'text' => 'true'
                     });
            } else {
                # procが何も無い場合、接続先をfalseと同じreturn_idにする。
                push(@next, {
                        'id'   => $proc_ret_id,
                        'link' => 'allow',
                        'text' => 'true'
                     });
            }

            push(@$node_ref, {
                    'id'    => $id,
                    'shape' => 'diamond',
                    'text'  => $proc->{'conditions'}->[0],
                    'css'   => $css,
                    'next'  => \@next,
                 });

            # procを再帰呼び出しで作成。
            if (scalar(@{$proc->{'proc'}}) > 0) {
                &proc2node($node_ref, $proc->{'proc'}, $id, $id, $proc_ret_id);
            }
        } elsif ($type eq 'until') {
            my $id = sprintf("%s%da", $parent_id, $i);
            my $proc_ret_id;
            if ($i == $#{$proc_ref}) {
                $proc_ret_id = $return_id;
            } else {
                $proc_ret_id = sprintf("%s%da", $parent_id, $i + 1);
            }

            my @next;
            # trueのlink先を作成
            push(@next, {
                    'id'   => $proc_ret_id,
                    'link' => 'allow',
                    'text' => 'true',
                 });
            # falseのlink先を作成
            if (scalar(@{$proc->{'proc'}}) > 0) {
                # 再帰呼び出しで1段下がったプロセスになるので、今のIDに1桁増やしたIDになる。
                push(@next, {
                        'id'   => sprintf("%s0a", $id),
                        'link' => 'allow',
                        'text' => 'false'
                     });
            } else {
                # procが何も無い場合、接続先をtrueと同じreturn_idにする。
                push(@next, {
                        'id'   => $proc_ret_id,
                        'link' => 'allow',
                        'text' => 'false'
                     });
            }

            push(@$node_ref, {
                    'id'    => $id,
                    'shape' => 'diamond',
                    'text'  => $proc->{'conditions'}->[0],
                    'css'   => $css,
                    'next'  => \@next,
                 });

            # procを再帰呼び出しで作成。
            if (scalar(@{$proc->{'proc'}}) > 0) {
                &proc2node($node_ref, $proc->{'proc'}, $id, $id, $proc_ret_id);
            }
        } elsif ($type eq 'do') {
            # circleとdiamond用のIDを計算
            my $id_a = sprintf("%s%da", $parent_id, $i);
            my $id_b = sprintf("%s%db", $parent_id, $i);
            my $proc_ret_id;
            if ($i == $#{$proc_ref}) {
                $proc_ret_id = $return_id;
            } else {
                $proc_ret_id = sprintf("%s%da", $parent_id, $i + 1);
            }

            # doの場合は分岐の合流から処理が始まるので、最初はサークルを描く
            if (scalar(@{$proc->{'proc'}}) > 0) {
                # 再帰呼び出しで1段下がったプロセスになるので、今のIDに1桁増やしたIDになる。
                push(@$node_ref, {
                        'id'    => $id_a,
                        'shape' => 'circle',
                        'text'  => ' ',
                        'css'   => $css,
                        'next'  => [
                            {
                                'id' => sprintf("%s0a", $id_a),
                                    'link' => 'allow',
                                    'text' => ''
                            }
                        ]});
            } else {
                # procが何も無い場合、whileの条件文に接続する。
                push(@$node_ref, {
                        'id'    => $id_a,
                        'shape' => 'circle',
                        'text'  => ' ',
                        'css'   => $css,
                        'next'  => [
                            {
                                'id' => $id_b,
                                'link' => 'allow',
                                'text' => ''
                            }
                        ]});
            }

            my @next;
            # falseのlink先を作成
            push(@next, {
                    'id'   => $proc_ret_id,
                    'link' => 'allow',
                    'text' => 'false',
                 });
            # trueのlink先を作成
            # 再帰呼び出しで1段下がったプロセスになるので、今のIDに1桁増やしたIDになる。
            push(@next, {
                    'id'   => sprintf("%s", $id_a),
                    'link' => 'allow',
                    'text' => 'true'
                 });

            push(@$node_ref, {
                    'id'    => $id_b,
                    'shape' => 'diamond',
                    'text'  => $proc->{'conditions'}->[0],
                    'css'   => $css,
                    'next'  => \@next,
                 });

            # procを再帰呼び出しで作成。
            if (scalar(@{$proc->{'proc'}}) > 0) {
                &proc2node($node_ref, $proc->{'proc'}, $id_a, $id_b, $proc_ret_id);
            }
        } elsif ($type eq 'switch') {
            my $id = sprintf("%s%da", $parent_id, $i);
            my $proc_ret_id;
            if ($i == $#{$proc_ref}) {
                $proc_ret_id = $return_id;
            } else {
                $proc_ret_id = sprintf("%s%da", $parent_id, $i + 1);
            }
            
            # $proc->{'proc'}の中からcase文を全て探してnextにpushする
            my @next;
            my $sw_proc = $proc->{'proc'};
            for (my $j = 0; $j < scalar(@$sw_proc); $j++) {
                my $sw_type = $sw_proc->[$j]->{'type'};
                
                # sw_proc内にあるcase文を探す
                if (($sw_type eq 'ctrl') && ($sw_proc->[$j]->{'code'} eq 'case')) {
                    # switchからの接続先はcase文の次なので、link先のidはcaseが無くなった先を探す
                    for (my $k = 1; $k < scalar(@$sw_proc); $k++) {
                        if (($sw_proc->[$j + $k]->{'type'} ne 'ctrl') || ($sw_proc->[$j + $k]->{'code'} ne 'case')) {
                            my $sw_cond = $sw_proc->[$j]->{'conditions'}->[0];
                            push(@next, {
                                    'id'   => sprintf("%s%da", $id, $j + $k),
                                    'link' => 'allow',
                                    'text' => $sw_cond,
                                 });
                            last;
                        }
                    }
                }
            }
            
            if (scalar(@{$proc->{'proc'}}) > 0) {
                push(@$node_ref, {
                        'id'    => $id,
                        'shape' => 'diamond',
                        'text'  => $proc->{'conditions'}->[0],
                        'css'   => $css,
                        'next'  => \@next,
                     });
            } else {
                push(@next, {
                        'id'   => $proc_ret_id,
                        'link' => 'allow',
                        'text' => '',
                     });

                push(@$node_ref, {
                        'id'    => $id,
                        'shape' => 'diamond',
                        'text'  => $proc->{'conditions'}->[0],
                        'css'   => $css,
                        'next'  => \@next,
                     });
            }

            # switch内のprocを再帰呼び出しで作成。
            # switchは条件の次の要素が戻り先になるので、proc_refが最後ならreturn_idが戻り先になる
            if (scalar(@{$proc->{'proc'}}) > 0) {
                &proc2node($node_ref, $proc->{'proc'}, $id, $proc_ret_id, $proc_ret_id);
            }
        } elsif ($type eq 'ctrl') {
            my $id = sprintf("%s%da", $parent_id, $i);
            
            my $code = $proc->{'code'};
            if ($code eq 'case') {
                # 先頭のcase文なら何もしない
                if ($i == 0) { $sw_case_count++; next; }
                
                # 一つ前の処理がreturnまたはexitなら何もしない
                my $prev_proc = $proc_ref->[$i - 1];;
                if (($prev_proc->{'type'} eq 'proc') && ($prev_proc->{'code'} =~ m/return/)) { $sw_case_count++; next; }
                if (($prev_proc->{'type'} eq 'proc') && ($prev_proc->{'code'} =~ m/exit/))   { $sw_case_count++; next; }

                # 一つ前の処理がbreakなら何もしない
                if (($prev_proc->{'type'} eq 'ctrl') && ($prev_proc->{'code'} eq 'break')) { $sw_case_count++; next; }
                
                # 一つ前の処理がcaseならリンクリストのlink先はswitch文の処理で作成済なので何もしない
                if (($prev_proc->{'type'} eq 'ctrl') && ($prev_proc->{'code'} eq 'case')) { $sw_case_count++; next; }

                # node_ref内でidに一致する宛先を一つ先に繋ぎ変える
                my $next_id = sprintf("%s%da", $parent_id, $i + 1);
                for (my $j = 0; $j < scalar(@$node_ref); $j++) {
                    if (!defined($node_ref->[$j]->{'next'})) { next; }
                    my $next_ref = $node_ref->[$j]->{'next'};
                    for (my $k = 0; $k < scalar(@$next_ref); $k++) {
                        my $node_ref = $next_ref->[$k];
                        if ($node_ref->{'id'} eq $id) {
                            $node_ref->{'id'} = $next_id;
                        }
                    }
                }
                
                $sw_case_count++;
            }  elsif ($code eq 'break') {
                my $id = sprintf("%s%da", $parent_id, $i);
                
                # node_ref内でidに一致する宛先をbreak先に変更する
                for (my $j = 0; $j < scalar(@$node_ref); $j++) {
                    if (!defined($node_ref->[$j]->{'next'})) { next; }
                    my $next_ref = $node_ref->[$j]->{'next'};
                    for (my $k = 0; $k < scalar(@$next_ref); $k++) {
                        my $node_ref = $next_ref->[$k];
                        if ($node_ref->{'id'} eq $id) {
                            $node_ref->{'id'} = $break_id;
                        }
                    }
                }
            } elsif ($code =~ m/(?:return|exit)/) {
                push(@$node_ref, {
                        'id'    => $id,
                        'shape' => 'round square',
                        'text'  => $code,
                        'css'   => $css,
                     });
            }
        } elsif (($type eq 'if') || ($type eq 'else if')) {
            my $id = sprintf("%s%da", $parent_id, $i);
            my $proc_ret_id;
            if ($i == $#{$proc_ref}) {
                $proc_ret_id = $return_id;
            } else {
                # 次が'else'ならfalse側(1段下がったノード)へリンク、それ以外('else if'含む)なら次のノードへリンク
                my $next_proc = $proc_ref->[$i + 1];
                if ($next_proc->{'type'} eq 'else') {
                    # elseの戻り先はproc処理の有無によって一段下がるか、次のノードになるか分かれる。
                    if (scalar(@{$proc->{'proc'}}) > 0) {
                        $proc_ret_id = sprintf("%s%da0a", $parent_id, $i + 1);
                    } else {
                        # procの中身が無かった場合、戻り先を探す
                        # 戻り先は'else', 'else if'が無くなった次のノードになる。
                        $proc_ret_id = $return_id;
                        for (my $j = 1; $i + $j < scalar(@$proc_ref); $j++) {
                            my $next_proc = $proc_ref->[$i + $j];
                            my $next_type = $next_proc->{'type'};
                            if (($next_type eq 'else if') or ($next_type eq 'else')) { next; }
                
                            $proc_ret_id = sprintf("%s%da", $parent_id, $i + $j);
                            last;
                        }
                    }
                } else {
                    $proc_ret_id = sprintf("%s%da", $parent_id, $i + 1);
                }
            }

            my @next;
            # falseのlink先を作成
            push(@next, {
                    'id'   => $proc_ret_id,
                    'link' => 'allow',
                    'text' => 'false',
                 });
            
            # trueのlink先を作成
            # 再帰呼び出しで1段下がったプロセスになるので、今のIDに1桁増やしたIDになる。
            if (scalar(@{$proc->{'proc'}}) > 0) {
                push(@next, {
                        'id'   => sprintf("%s0a", $id),
                        'link' => 'allow',
                        'text' => 'true'
                     });
            } else {
                # procの中身が無かった場合、戻り先を探す
                # 戻り先は'else', 'else if'が無くなった次のノードになる。
                $proc_ret_id = $return_id;
                for (my $j = 1; $i + $j < scalar(@$proc_ref); $j++) {
                    my $next_proc = $proc_ref->[$i + $j];
                    my $next_type = $next_proc->{'type'};
                    if (($next_type eq 'else if') or ($next_type eq 'else')) { next; }
        
                    $proc_ret_id = sprintf("%s%da", $parent_id, $i + $j);
                    last;
                }

                push(@next, {
                        'id'   => $proc_ret_id,
                        'link' => 'allow',
                        'text' => 'true'
                     });
            }

            push(@$node_ref, {
                    'id'    => $id,
                    'shape' => 'diamond',
                    'text'  => $proc->{'conditions'}->[0],
                    'css'   => $css,
                    'next'  => \@next,
                 });

            # procを再帰呼び出しで作成。
            # procの中身が無かった場合、戻り先を探す
            # 戻り先は'else', 'else if'が無くなった次のノードになる。
            $proc_ret_id = $return_id;
            for (my $j = 1; $i + $j < scalar(@$proc_ref); $j++) {
                my $next_proc = $proc_ref->[$i + $j];
                my $next_type = $next_proc->{'type'};
                if (($next_type eq 'else if') or ($next_type eq 'else')) { next; }

                $proc_ret_id = sprintf("%s%da", $parent_id, $i + $j);
                last;
            }

            if (scalar(@{$proc->{'proc'}}) > 0) {
                &proc2node($node_ref, $proc->{'proc'}, $id, $proc_ret_id, $break_id);
            }
        } elsif ($type eq 'else') {
            my $id = sprintf("%s%da", $parent_id, $i);
            my $proc_ret_id = $i == $#{$proc_ref} ? $return_id : sprintf("%s%da", $parent_id, $i + 1);
            if (scalar(@{$proc->{'proc'}}) > 0) {
                &proc2node($node_ref, $proc->{'proc'}, $id, $proc_ret_id, $break_id);
            }
        }
    }
}

sub gen_mermaid {
    my $self = shift;
    my $functions = $self->{'functions'};

    print <<EOL;
<!doctype html>
<html>
<head>
    <meta charset="utf-8">
    <title></title>

    <link href="mermaid.css" rel="stylesheet" type="text/css"/>
    <script src="mermaid.js"></script>
    <script>
        var config = {
            startOnLoad:true,
            flowchart:{
                    useMaxWidth:false
            }
        };
        mermaid.initialize(config);
    </script>

</head>

<body class="index">
EOL

    foreach (@{$functions}) {
        my $function = $_;
        my (@css_diff_add, @css_diff_del);
        printf("<div class=\"mermaid\">graph TB\n");
        printf("subgraph %s\n", $function->{'title'});

        foreach (@{$function->{'node'}}) {
            my $node = $_;
            my $shape = $node->{'shape'};
            my ($shape_b, $shape_e); # shape begin/end

            if ($shape eq 'square') {
                ($shape_b, $shape_e) = ('[', ']');
            } elsif ($shape eq 'round square') {
                ($shape_b, $shape_e) = ('(', ')');
            } elsif ($shape eq 'circle') {
                ($shape_b, $shape_e) = ('((', '))');
            } elsif ($shape eq 'diamond') {
                ($shape_b, $shape_e) = ('{', '}');
            } else {
                printf("unknown shape: %s\n", $shape);
                die;
            }

            if (defined($node->{'next'})) {
                my $next_ref = $node->{'next'};
                foreach (@{$next_ref}) {
                    my $next = $_;
                    my $link_text = '';
                    if (defined($next->{'text'}) && ($next->{'text'} ne '')) { $link_text = '|"' . $next->{'text'} . '"|'; }
                    printf("%s%s\"%s\"%s-->%s%s\n",
                           $node->{'id'}, $shape_b, $node->{'text'}, $shape_e, $link_text, $next->{'id'});
                }
            } else {
                printf("%s%s\"%s\"%s\n",
                       $node->{'id'}, $shape_b, $node->{'text'}, $shape_e);
            }

            # CSSスタイル作成
            foreach (split(/,/,$node->{'css'})) {
                my ($key, $val) = split(/=/, $_);
                if ($key eq 'diff') {
                    if ($val eq '+') {
                        push(@css_diff_add, $node->{'id'});
                    } elsif ($val eq '-') {
                        push(@css_diff_del, $node->{'id'});
                    }
                    next;
                }
            }
        }

        # CSS Classes
        printf("classDef diffAdd fill:#eaffea,stroke-width:1px\n");
        printf("classDef diffDel fill:#ffecec,stroke-width:1px\n");
        foreach (@css_diff_add) {
            print("class " . $_ . " diffAdd\n");
        }
        foreach (@css_diff_del) {
            print("class " . $_ . " diffDel\n");
        }
        
        printf("end\n"); # subgraph end
        printf("</div>\n");
    }

    print <<EOL;
</body>
</html>
EOL
    
}

1;
