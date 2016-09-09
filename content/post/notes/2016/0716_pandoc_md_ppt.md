---
title: "Pandoc+Mardown生成Web Slide"
date: "2016-07-16"
categories:
 - "笔记"
tags:
 - "Markdown"
 - "Slide"
toc: true
---

## 背景

在我司PPT被称为胶片。一层层的汇报都是胶片承载，胶片也是做得非常漂亮。像我所在领域，架构师主要产出也是胶片，俨然无胶片就无架构。一方面个人非常羡慕胶片写得好（内容与外观）的人，另一方面觉得像使用MS的PowerPoint几乎要把一半的精力放在外观而不是内容上。甚至感觉到为了一个格式、一个颜色，调整都需要老半天时间。大家的胶片都做得漂亮，而你不可能也就只草草准备，尤其是给领导的胶片，人在江湖，身不由已。但做一名技术人员，内心还是比较抵触形式大于内容的胶片。昨天，一名同事给我展示了一个由Markdown生成Slide，给人感觉是耳目一新。

Markdown是一种内容与形式的分享的轻量级标记语言，受到越来越多的人喜欢，只要只简单的文本编辑器，都能书写文本内容。那有什么工具能快速方便地生成Slide呢。Markdown本身是为了方便输出到HTML格式。而HTML+CSS+JS是一个开放的，可扩展的技术。自然Markdown也可以通过工具生成像PPT一样可以上下翻页的HTML Slide，同样借助CSS与JS的结合，Slide一样可以做得像PPT一样格式漂亮，动作酷炫。
<!--more-->

## Pandoc

[Pandoc](http://pandoc.org/) 则是一款非常优秀的开源文本格式转化神器。Markdown转换为HTML Slide也自然不在话下。Pandoc是由Haskell开发，Pandoc作者John MacFarlane一位来自美国加州大学伯克利分校的哲学教授。Haskell是一种函数式编程语言。而文本格式转换，看似简单，其实非常麻烦。Haskell干这脏活、累活的最恰当选择，Pandoc也的确成功了，并已成功在短期内构建一个完整的生态链。

### 安装

个人PC使用的Macbook，所以安装比较简单：

    $ brew install pandoc


### 检验

```
$ pandoc --version
pandoc 1.17.1
Compiled with texmath 0.8.6.3, highlighting-kate 0.6.2.
Syntax highlighting is supported for the following languages:
    abc, actionscript, ada, agda, apache, asn1, asp, awk, bash, bibtex, boo, c,
    changelog, clojure, cmake, coffee, coldfusion, commonlisp, cpp, cs, css,
    curry, d, diff, djangotemplate, dockerfile, dot, doxygen, doxygenlua, dtd,
    eiffel, elixir, email, erlang, fasm, fortran, fsharp, gcc, glsl,
    gnuassembler, go, hamlet, haskell, haxe, html, idris, ini, isocpp, java,
    javadoc, javascript, json, jsp, julia, kotlin, latex, lex, lilypond,
    literatecurry, literatehaskell, llvm, lua, m4, makefile, mandoc, markdown,
    mathematica, matlab, maxima, mediawiki, metafont, mips, modelines, modula2,
    modula3, monobasic, nasm, noweb, objectivec, objectivecpp, ocaml, octave,
    opencl, pascal, perl, php, pike, postscript, prolog, pure, python, r,
    relaxng, relaxngcompact, rest, rhtml, roff, ruby, rust, scala, scheme, sci,
    sed, sgml, sql, sqlmysql, sqlpostgresql, tcl, tcsh, texinfo, verilog, vhdl,
    xml, xorg, xslt, xul, yacc, yaml, zsh
......
```

可见，Pandoc支持多种语言的高亮显示，程序员不愁写PPT了。

### 样例

```markdown
% Markdown + Pandoc
% lanlingzi
% 2016-07-16

## Web-based slideshow

- is a slide show which can be played (viewed or presented) using a web browser
- is typically generated to or authored in HTML, JavaScript and CSS code (files)
- are generated from presentation software
- offer templates allowing the slide show to be easily edited and changed.

## Features

- Keyboard navigation
- Slide transitions and animations
- Auto-play/timed transitions
- Displays a table of contents
- Nested slides
- Separate slide notes for the speaker
- Full screen support, with automatic text and images resizing to fit full screen
- .....

```

Pandoc对分级标题、列表、插入图片等标准的Markdown语法均被支持，和平常用Markdown记笔记写博客无异。在文本开头需要包含三行以%打头的元信息：标题、作者和日期。

默认情况下每个二级标题是一张独立的幻灯片，所以，注意把每个二级标题下的内容控制在适当的长度。列表的显示效果可以人为设定，例如在幻灯片演示的时候逐条渐入。也可以直接在文本中嵌入HTML，用于显示Markdown等标记语言不支持的表格，或控制字体大小，以及进行其他更加复杂的排版。当然，如果用到的HTML标签过多，这不是Markdown这些轻量级标记语言的错，也许是做幻灯片的方式出了问题。因为演示本身要传达的是内容，复杂的排版没有任何意义。

### 命令

    $ pandoc -s -i -t slidy demo.md -o demo.html


其中`-t slidy`是生成Slide采用样式框架，目前Pandoc包含了对五种HTML Slide框架的支持:

- [DZSlides](https://github.com/paulrouget/dzslides)
- [Slidy](http://www.w3.org/Talks/Tools/Slidy2/)
- [S5](http://meyerweb.com/eric/tools/s5/)
- [Slideous](http://goessner.net/articles/slideous/slideous.html)
- [revealjs](http://lab.hakim.se/reveal-js)

其中`-i`表示渐进显示，即控制列表的显示效果（逐条渐入）。

## 后记

采用Pandoc把Markdown转化为Slide也不是万能的。受限于Markdown的标签表达能力，其中的表格、复杂公式、多国语言、上下标、交叉引用、图表对齐较多的场合，它并不适合。使用Pandoc，只是喜欢Slide的样式，不用去辛辛苦苦的做PPT， 也有PPT的展示效果，何乐而不为呢？
