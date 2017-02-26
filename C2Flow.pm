#!/usr/local/bin/perl-5.22.0

=pod
- 1行1処理のまとまりとして処理する。

行の属性は段階的に付与していくか？
何が属性として必要か？
まずは関数単位に分割したい最初に見つけたが閉じられるまで


擬似コードを表示できるようにする必要があるか？
> 擬似コードを表示する(保持する)場合
  どこで表示する？表示する場所があるなら。
　SIML機能入れないなら擬似コードを元の構造で保つ必要はないだろう。
> 表示しない場合
　パースする時に元の構造を保持する必要が無いので楽。

異常を見つけた時にコードのおかしいところが必要か。
元の構造は維持しないと厳しいかなあ。

論理確認のSIMLは無くても困らないかな。
多分そこまで間に合わない。


サポートする制御構文
改行位置に関わらず解析できる必要がある。

セミコロンを不要にする代わりに、制御構文は行頭に無ければならない。
ただし、空白とコメントはあっても良い。

if (hoge) {
} else if (fuga) {
} else {
}

switch (hoge) {
case fuga:
    break;
default:
}

while (hoge) {
}

until (hoge) {
}

do {
} while (hoge);

for (i=0; i < hoge; i++) {
}

読み込む時に行番号と対応付けたハッシュデータで保持する？

前提として、ifとかwhileの前に処理を書くとか無いと信じる。
そういう書き方はコーディングの時にでもどうぞ。

というわけなので、制御文は行単位に解析で良い。
行番号に紐付けた構造で管理して、頭から順番に解析していく。

中括弧で囲まれた部分が処理単位なので、一番内側の中括弧を外しながら処理をしていく？
面倒くさそう？
サポートする制御は以下。
それぞれ形式が異なるので解析が面倒くさい。
人によって書き方違うかもしれないし。
絶対守ってほしいこと制御文は文の行頭(スペースを除く)から始めるという事。

解析は行単位に見ていき、制御文字を探す。
見つかった場合はその制御の最後(ifなら閉じ括弧と次の行にelseが続いていないか)を確認する。

if (hoge) { hogehoge; } else if (piyo) { piyopiyo; } else { fugafuga; }
switch (hoge) { case FOO: hogehoge; break; case BAR: piyopiyo; break; default: fugafuga; }
while (hoge) { hogehoge; }
for (i=0;i<=n;i++) { hogehoge; }

@src : ファイルを1行ごとに読み込んで格納
 |
 +-> % 

制御文のデータ構造
%{ ctrl => "define" : 関数定義
           "call"   : 関数コール
           "proc"   : 表示のみの処理
           "if"
           "switch"
           "while"
           "for"
   name => 関数名
   condition => true, false, null, or value
   proc => @処理、次の階層を繋げる場合もある
   prev => 一つ上の階層のハッシュ
   judgment => @条件
}

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
        s/\/\/.*$//; # 一行コメントを削除
        ${$self->{'read_src'}} .= $_;
    }
    ${$self->{'read_src'}} =~ s/\/\*.*?\*\///gs; # コメント行を削除
#    printf(">>%s\n", ${$self->{'read_src'}});
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
                $name =~ s/^ +//g;
                $name =~ s/ +$//g;
                $f{'name'} = $name;
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
#
# 各制御構文における構造例
# - while
#   \@proc
#   + [n] {
#           'type'       => while
#           'conditions' => whileの条件
#           'src'        => while内のソース(改行コード付、最後にNULL)
#           'proc'       => \@proc ... while内の処理
#         }
#
# - while|untile|do|for|switch|if
#   \@proc
#   + [n] {
#           'type'       => while|untile|do|for|switch|if
#           'conditions' => \@conditions
#           'src'        => source code
#           'proc'       => \@proc ... 再帰的に格納
#         }
#
# - while|untile|do|for|switch|if
#   \@proc
#   + [n] {
#           'type'       => while|untile|do|for|switch|if
#           'conditions' => \@conditions
#           'src'        => source code
#           'proc'       => \@proc ... 再帰的に格納
#         }
#
# - while|untile|do|for|switch|if
#   \@proc
#   + [n] {
#           'type'       => while|untile|do|for|switch|if
#           'conditions' => \@conditions
#           'src'        => source code
#           'proc'       => \@proc ... 再帰的に格納
#         }
#
# - while|untile|do|for|switch|if
#   \@proc
#   + [n] {
#           'type'       => while|untile|do|for|switch|if
#           'conditions' => \@conditions
#           'src'        => source code
#           'proc'       => \@proc ... 再帰的に格納
#         }
#
# - if
#   \@proc
#   + [n] {
#           'type'       => while|untile|do|for|switch|if
#           'conditions' => \@conditions
#           'src'        => source code
#           'proc'       => \@proc ... 再帰的に格納
#         }
#
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
        # $srcが''(procに分割済)の時に再起呼び出しされるとprocを別のリファレンスで
        # 書き潰してしまうので冗長だがこの位置でリファレンス代入
        $f->{'proc'} = \@proc;

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
                $line =~ s/.*case +(.+$)//;
                my $condition = $1;

                # @conditionsにpushした同一インデックスの@procにprocハッシュ作成
                my @conditions = ();
                my @proc_child = ();
                my %f_case = (
                    'type'       => 'ctrl',
                    'conditions' => \@conditions,
                    'code'       => 'case',
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
                    );
                push(@conditions, 'default'); # defaultのconditionはdefaultとする
                
                push(@{$ctrl_ref->{'proc'}}, \%f_case);
            } elsif (($ctrls[$#ctrls] eq 'do') && ($match_ctrl eq 'while')) {
                # TODO: '}'とwhileは同じ行にある想定かつ、whileの条件文も同じ行にある想定の処理
                $line =~ s/.*\( *(.*?) *\).*/$1/;
                $ctrl_ref->{'conditions'}[0] = $line;

                &source2proc($ctrl_ref);
                $depth--;
                pop(@ctrl_refs);
                $ctrl_ref = $ctrl_refs[$#ctrl_refs];

                if ($depth == 0) {
                    $ctrls[$#ctrls] = ''; # TODO: ここクリア？pop？
                }
            } else {
                # elseで中括弧が閉じられたらそこまでのsrcをprocに分解するため再帰呼び出しを行う。
                if (($match_ctrl eq 'else') || ($match_ctrl eq 'else if')) {
                    &source2proc($ctrl_ref);
                    $depth--;
                    pop(@ctrl_refs);
                    $ctrl_ref = $ctrl_refs[$#ctrl_refs];
                }

                # 識別中の制御を更新
                $ctrls[$#ctrls] = $match_ctrl; # TODO: ここ更新？push？
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
                    );
                push(@{$ctrl_ref->{'proc'}}, \%noname_hash);
                # 次のカレントは作成したハッシュになるので、ctrl_refsとctrl_refを更新する
                push(@ctrl_refs, \%noname_hash);
                $ctrl_ref = \%noname_hash;
#                printf(">>> type=%s, ctrl_ref=%x, ctrl_refs=%d, ctrl_refs[0/1]=%x/%x\n", $noname_hash{'type'}, \%noname_hash, $#ctrl_refs, $ctrl_refs[0], $ctrl_refs[1]);

                # 同一行で中括弧を開いて閉じてはしないものとする
                # 開き中括弧は制御文字と同一行にあるものとする
                $depth++;

                if ($match_ctrl eq 'else') {
                    my $condition = 'else';
                    push(@conditions, $condition);
                } else {
                    $line =~ s/(.+?)\{ *//;
                    if ($line ne '') {
                        $ctrl_ref->{'src'} .= $line . "\n";
                    }
                    my $condition = $1;
                    $condition =~ s/.*\( *(.*?) *\).*/$1/;
                    push(@conditions, $condition);
                }
            }

        } elsif ($line =~ m/\}/) {
            &source2proc($ctrl_ref);
            $ctrls[$#ctrls] = ''; # TODO: ここクリア？pop？

            $depth--;
            pop(@ctrl_refs);
            $ctrl_ref = $ctrl_refs[$#ctrl_refs];
        } else {
            if ($ctrls[$#ctrls] eq '') {
                push(@proc, {
                    'type' => 'proc',
                    'code' => $line
                     });
            } elsif ($ctrls[$#ctrls] eq 'switch') {
                if ($line =~ m/break/) {
                    push(@{$ctrl_ref->{'proc'}}, {
                        'type' => 'ctrl',
                        'code' => $line,
                         });
                } else {
                    push(@{$ctrl_ref->{'proc'}}, {
                        'type' => 'proc',
                        'code' => $line
                         });
                }
            } elsif ($ctrls[$#ctrls] eq 'if') {
                push(@{$ctrl_ref->{'proc'}}, {
                    'type' => 'proc',
                    'code' => $line
                     });
            } else {
                push(@{$ctrl_ref->{'proc'}}, {
                    'type' => 'proc',
                    'code' => $line
                     });
            }
        }
    }
}

# 最終的にはXML出力にしてみたいが、時間が無いのでproc構造体をHTML出力し易いように変換するのみ
# 必要な情報
# - id
# - 箱のタイプ(start, end, operation, subroutine, condition, io?)
# - 箱の文字列
# - conditionの場合、yes/noがつながる先のid
# {
#   'functions' =>\@function
#                   + [n] {
#                            'name' => func name
#                            'proc' => \@proc
# }
sub conv_func {
    my $self = shift;
    my $functions = $self->{'functions'};

    # topのprocを全てflowに展開する
    foreach (@{$functions}) {
        my @flow;
        $_->{'flow'} = \@flow;

        &proc2struct($_->{'proc'}, \@flow, ''); # 戻り先は無いので3rd引数はnull
    }
}

sub proc2struct {
    my $self = shift; # procハッシュのリファレンス
    my $flow = shift;
    my $to   = shift; # $selfを展開し終わった時の戻り先
    
    for (my $i = 0; $i <= $#{$self}; $i++) {
        my $proc = $self->[$i];
        my $type = $proc->{'type'};

        if ($type eq 'ctrl') {
            # switchのcaseとbreakが該当する
            if ($proc->{'code'} eq 'case') {
                # case文はconditionに変換する
                my %struct;
                my (@flow_y, @flow_n);
                $struct{'type'}  = 'condition';
                $struct{'value'} = $proc->{'conditions'}->[0];
                $struct{'yes'} = \@flow_y;
                push(@{$flow}, \%struct);

                # case単位にこの条件が実行され@{$flow}のインデックスがインクリメントされる
                # case戻り先をswitchを抜けた先に設定するためcaseまたはdefaultが何個あるか確認する
                # caseとdefaultはどちらもcode=ctrlになっている
                my $j;
                my $next_case_index;
                my $case_cnt = 0;
                my $next_case = '';
                for ($j = 1; ($i + $j) <= $#{$self}; $j++) {
                    if (($self->[$i + $j]->{'type'} eq 'ctrl') && ($self->[$i + $j]->{'code'} eq 'case')) {
                        $case_cnt++;
                        if ($next_case eq '') {
                            $next_case_index = $j - 1; # このcaseの最後までインデックスを進める
                            $next_case = $self->[$i + $j]->{'conditions'}->[0];
                        }
                        next;
                    }
                }

                # breakが現れるか配列が終了するまで$selfの先を検索して、テンポラリ配列を作成する
                # 作成した配列を使って再起呼び出し。
                # 戻り先はswitchの先に設定する
                my @tmp_proc = ();
                for ($j = 1; ($i + $j) <= $#{$self}; $j++) {
                    if (($self->[$i + $j]->{'type'} eq 'ctrl') && ($self->[$i + $j]->{'code'} eq 'break')) {
                        last;
                    }
                    # case文はpushしない
                    if (!(($self->[$i + $j]->{'type'} eq 'ctrl') && ($self->[$i + $j]->{'code'} eq 'case'))) {
                        push(@tmp_proc, $self->[$i + $j]);
                    }
                }
                &proc2struct(\@tmp_proc, \@flow_y, $to);

                # noはこの後の配列にcaseまたはdefault(どちらもcode=case)が存在すれば繋ぐ
                # 無ければ分岐はここで終了
                if ($case_cnt > 0) {
                    $struct{'no'} = \@flow_n;
                    $flow_n[0] = { 'to' => sprintf("%x_%04d", $flow, $#{$flow} + $j) };
                    $i += $next_case_index;
                }
            }
        } elsif ($type eq 'while') {
            my %struct;
            my (@flow_y, @flow_n);
            $struct{'type'}  = 'condition';
            $struct{'value'} = $proc->{'conditions'}->[0];
            $struct{'yes'} = \@flow_y;
            $struct{'no'} = \@flow_n;
            push(@{$flow}, \%struct);
            &proc2struct($proc->{'proc'}, \@flow_y, sprintf("%x_%04d", $flow, $#{$flow}));
            $flow_n[0] = { 'to' => sprintf("%x_%04d", $flow, $#{$flow} + 1) };
        } elsif ($type eq 'until') {
            my %struct;
            my (@flow_y, @flow_n);
            $struct{'type'}  = 'condition';
            $struct{'value'} = $proc->{'conditions'}->[0];
            $struct{'yes'} = \@flow_y;
            $struct{'no'} = \@flow_n;
            push(@{$flow}, \%struct);
            &proc2struct($proc->{'proc'}, \@flow_n, sprintf("%x_%04d", $flow, $#{$flow}));
            $flow_y[0] = { 'to' => sprintf("%x_%04d", $flow, $#{$flow} + 1) };
        } elsif ($type eq 'do') {
            my %struct;
            my (@flow_y, @flow_n);
            $struct{'type'}  = 'condition';
            $struct{'value'} = $proc->{'conditions'}->[0];
            $struct{'yes'} = \@flow_y;
            $struct{'no'} = \@flow_n;
            push(@{$flow}, \%struct);
            &proc2struct($proc->{'proc'}, \@flow_y, sprintf("%x_%04d", $flow, $#{$flow}));
            $flow_n[0] = { 'to' => sprintf("%x_%04d", $flow, $#{$flow} + 1) };
        } elsif ($type eq 'for') {
            my %struct;
            my (@flow_y, @flow_n);
            $struct{'type'}  = 'condition';
            $struct{'value'} = $proc->{'conditions'}->[0];
            $struct{'yes'} = \@flow_y;
            $struct{'no'} = \@flow_n;
            push(@{$flow}, \%struct);
            &proc2struct($proc->{'proc'}, \@flow_y, sprintf("%x_%04d", $flow, $#{$flow}));
            $flow_n[0] = { 'to' => sprintf("%x_%04d", $flow, $#{$flow} + 1) };
        } elsif ($type eq 'switch') {
            # switchの条件は必ずyesにして、その直下のcase文で分岐させる図とする
            my %struct;
            my (@flow_y, @flow_n);
            $struct{'type'}  = 'condition';
            $struct{'value'} = $proc->{'conditions'}->[0];
            $struct{'yes'} = \@flow_y;
            push(@{$flow}, \%struct);
            &proc2struct($proc->{'proc'}, \@flow_y, sprintf("%x_%04d", $flow, $#{$flow} + 1));
        } elsif ($type eq 'if') {
            my %struct;
            my (@flow_y, @flow_n);
            $struct{'type'}  = 'condition';
            $struct{'value'} = $proc->{'conditions'}->[0];
            $struct{'yes'} = \@flow_y;
            $struct{'no'} = \@flow_n;
            push(@{$flow}, \%struct);
            # yesの戻り先は次以降の配列でelse ifまたはelseが見つからなくなるまで検索した先
            my $j;
            for ($j = 1; ($i + $j) <= $#{$self}; $j++) {
                if ($self->[$i + $j]->{'type'} eq 'else if' || $self->[$i + $j]->{'type'} eq 'else') {
                    next;
                } else {
                    last;
                }
            }
            &proc2struct($proc->{'proc'}, \@flow_y, sprintf("%x_%04d", $flow, $#{$flow} + $j));
            # noは次のelse ifまたはelseに接続するため+1のインデックスにつなぐ
            $flow_n[0] = { 'to' => sprintf("%x_%04d", $flow, $#{$flow} + 1) };
        } elsif ($type eq 'else if') {
            my %struct;
            my (@flow_y, @flow_n);
            $struct{'type'}  = 'condition';
            $struct{'value'} = $proc->{'conditions'}->[0];
            $struct{'yes'} = \@flow_y;
            $struct{'no'} = \@flow_n;
            push(@{$flow}, \%struct);
            # yesの戻り先は次以降の配列でelse ifまたはelseが見つからなくなるまで検索した先
            my $j;
            for ($j = 1; ($i + $j) <= $#{$self}; $j++) {
                if ($self->[$i + $j]->{'type'} eq 'else if' || $self->[$i + $j]->{'type'} eq 'else') {
                    next;
                } else {
                    last;
                }
            }
            &proc2struct($proc->{'proc'}, \@flow_y, sprintf("%x_%04d", $flow, $#{$flow} + $j));
            # noは次のelse ifまたはelseに接続するため+1のインデックスにつなぐ
            $flow_n[0] = { 'to' => sprintf("%x_%04d", $flow, $#{$flow} + 1) };
        } elsif ($type eq 'else') {
            my %struct;
            my @flow_y;
            $struct{'type'}  = 'condition';
            $struct{'value'} = $proc->{'conditions'}->[0];
            $struct{'yes'} = \@flow_y;
            push(@{$flow}, \%struct);
            # elseにはyesの戻り先しかない
            &proc2struct($proc->{'proc'}, \@flow_y, sprintf("%x_%04d", $flow, $#{$flow} + 1));
        } else {
            # どれにも当てはまらなかったら'proc'と同等と判断する
            my %struct;
            $struct{'type'}  = 'operation';
            $struct{'value'} = $proc->{'code'};
            push(@{$flow}, \%struct);
        }
    }

    # 配列の最後に戻り先のIDを格納する
    if ($to eq '') {
        if ($#{$flow} < 0) {
            push(@{$flow}, { 'type' => 'end', 'value' => 'return' });
        } elsif ($flow->[$#{$flow}]->{'value'} =~ m/return/) {
            # ユーザがreturnを書いていた場合typeをendに書き換える
            $flow->[$#{$flow}]->{'type'} = 'end';
        } else {
            # 配列の最後にendを追加する
            push(@{$flow}, { 'type' => 'end', 'value' => 'return' });
        }
    } else {    
        $flow->[$#{$flow}]->{'to'} = $to;
    }
}

sub gen_html {
    my $self = shift;
    my $functions = $self->{'functions'};
    
    print <<EOL;
<!DOCTYPE html>
<html>
<head>
<meta charset='utf-8'>
</head>
<body>

<script src="raphael.min.js"></script>
<script src="flowchart.js"></script>

<div id="diagram"></div>
<script>
EOL

    foreach (@{$functions}) {
        my $flow = $_->{'flow'};

        print <<EOL;
    var str=(function(){/*
EOL
        printf("st=>start: %s\n", $_->{'name'});
        &struct2box($flow);

        printf("st->");
        &struct2flow($flow);

        print <<EOL;

*/}).toString().split('*')[1];
	console.log("input str:");
	console.log(str);
	var diagram = flowchart.parse(str);
	diagram.drawSVG('diagram', {
		"line-width": 2,
		'scale': 0.7,
		"fill": "#eee"
	});
EOL
    }

    print <<EOL;
</script>

</body>
</html>
EOL
}

sub struct2box {
    my $p = shift;

    for (my $i = 0; $i <= $#{$p}; $i++) {
        if (exists($p->[$i]->{'type'})) {
            if ($p->[$i]->{'type'} eq 'condition') {
                printf("id_%x_%04d=>%s: %s\n", $p, $i,
                       $p->[$i]->{'type'}, $p->[$i]->{'value'});
                if (exists($p->[$i]->{'yes'})) {
                    &struct2box($p->[$i]->{'yes'});
                }
                if (exists($p->[$i]->{'no'})) {
                    &struct2box($p->[$i]->{'no'});
                }
            } elsif ($p->[$i]->{'type'} eq 'end') {
                printf("id_%x_%04d=>%s: %s\n", $p, $i,
                       $p->[$i]->{'type'}, $p->[$i]->{'value'});
            } else {
                printf("id_%x_%04d=>%s: %s\n", $p, $i,
                       $p->[$i]->{'type'}, $p->[$i]->{'value'});
            }
        }
    }
}

sub struct2flow {
    my $p = shift;

    for (my $i = 0; $i <= $#{$p}; $i++) {
        if (exists($p->[$i]->{'type'})) {
            if ($p->[$i]->{'type'} eq 'condition') {
                printf("id_%x_%04d\n", $p, $i);
                if (exists($p->[$i]->{'yes'})) {
                    printf("id_%x_%04d(yes)->", $p, $i);
                    &struct2flow($p->[$i]->{'yes'});
                }
                if (exists($p->[$i]->{'no'})) {
                    printf("id_%x_%04d(no)->", $p, $i);
                    &struct2flow($p->[$i]->{'no'});
                }
            } else {
                printf("id_%x_%04d->", $p, $i);
            }
    
            if (exists($p->[$i]->{'to'})) {
                printf("id_%s\n", $p->[$i]->{'to'});
            }    
        }
    }
}

1;
