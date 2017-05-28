C code to Flowchart
====

## Overview

Cライクな疑似コードからフローチャート図を生成するツール。

Generate flowcharts from the pseudocode like C.

## Description

オフィススイートで仕様書のフローチャートを描くのにうんざりしたので作ったツール。
疑似コードから関数単位のフローチャートに変換し、html形式で出力します。
フローチャートを言語的に描けるようにする事によって、実装作業の一部を行える事を目的としています。

I was tired of drawing flowcharts in the office suite, so I made this tool.
It converts from psuedocode into flowchart of function unit and outputs it in HTML format.
This tool aims to make it possible to perform a part of programming by enabling it to draw flow charts linguistically.

## Features

* 1行を1つの処理として認識
* C言語のif/switch/while/until/do-while/forをサポート
* 文法的に正しいかは見ていない
* 行末のセミコロン(;)、caseのコロン(:)は不要
* C言語のマクロ、変数定義は解析できない(ただの処理として表示される)

* Treat one line as one process.
* Supports C language control syntax, 'if', 'switch', 'while', 'until', 'do-while', and 'for'.
* This tool does not check grammatical correctness.
* Semicolon at the end of line, colon for 'case' is unnecessary.
* C language macros and variable definitions can not be analyzed.(Displayed as a simple process)

## Requirement

C2Flowを使用するために必要なモジュールは無いが、出力されたHTMLファイルをブラウザで表示する時はmermaidがHTMLと同じディレクトリに必要。

There is nothing necessary for using C2Flow, but mermaid is necessary to display HTML.

- [mermaid](https://github.com/knsv/mermaid)

## Usage

1. You write psuedocode.
```
// This is comment
// If you write the title tag in the comment, you can give a title to the figure.
// <titile>example 1</title>
int function1 {
    some process
    return 0
}

/* This is comment, too.
 * <title>example 2</title>
 */
function2 (void)
{
    some process

    if (a < b) {
        some process a < b
    } else if (a > b){
        some process a > b
    } else {
        some process a == b
        return
    }

    switch (c) {
    case CASE1
        some process 1
        break
    case CASE2
        some process 2
        break
    default
        // 'exit' has the same meaning as 'return'.
        exit
    }

    while (d > 0) {
        some process
        d--
    }

    until (e != 0) {
        some process
    }

    do {
        some process
    } while(f > 0)

    for (loop at 100 times) {
        some process
    }
}
```

2. Convert from the psuedocode to flowchart HTML.
```perl
use C2Flow;

my $file_name = $ARGV[0];
my $p = C2Flow->new();

$p->read($file_name);
$p->div_function();
$p->div_control();
$p->gen_node();
$p->gen_mermaid();
```

3. Display in browser.

![](https://raw.githubusercontent.com/wiki/isuka/C2Flow/images/readme_usage.png)

## Installation

モジュールパスの通った所にC2Flowを配置。

You place C2Flow where the module passes.

## Licence

[MIT](https://github.com/isuka/C2Flow/blob/master/LICENCE)

## Author

[isuka](https://github.com/isuka)
