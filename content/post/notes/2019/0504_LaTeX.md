---
title: "支持LateX"
date: "2019-05-04"
categories:
 - "笔记"
tags:
 - "theme"
toc: true
---

五一放假只好有点时间，于是计划完成这个 Issue: [Is it possible to add latex support and maybe flowchart feature of markdown? Also disqus or livere comment system? Maybe google analytics?](https://github.com/xtfly/hugo-theme-next/issues/8)，要解决支持LateX，只需要集成[MathJax](https://github.com/mathjax/MathJax)。
<!--more>

# 如何集成

在主题`layouts/partials/script.html` 增加如下，采用了cloudflare的CDN，国内可能稍慢些。

```
<script type="text/x-mathjax-config">
  MathJax.Hub.Config({
    extensions: ["tex2jax.js"],
    jax: ["input/TeX", "output/HTML-CSS"],
    tex2jax: {
      inlineMath: [ ['$','$'] ],
      displayMath: [ ['$$','$$'] ],
      processEscapes: true
    },
    "HTML-CSS": { fonts: ["TeX"] }
  });
</script>
<script src='https://cdnjs.cloudflare.com/ajax/libs/mathjax/2.7.5/MathJax.js?config=TeX-AMS-MML_HTMLorMML' async></script>
```

加上 `TeX-AMS-MML_HTMLorMML` 使得我们可以支持Tex和MathML公式，表示如果浏览器支持MathML解析，那么就使用它，否则会使用HTML-with-CSS来显示数学公式。

# 如何使用

 LaTeX 格式的公式使用主要有两种形式：

  - 包含在段落之中，见上面的inlineMath配置，采用以 `$...$` 引用
  - 独立于其他文字，见上面的displayMath配置，采用以 `$$...$$` 引用


## 样例

### 段落行内显示

```
 When $ a \ne 0 $, there are two solutions to $ax^2 + bx + c = 0$ and they are
```

将会生成

When $ a \ne 0 $, there are two solutions to $ax^2 + bx + c = 0$ and they are


### 独立段落显示

```
 $$ x = {-b \pm \sqrt{b^2-4ac} \over 2a}. $$

 $$ |AB| = \sqrt{(x_1-x_2)^2 + (y_1-y_2)^2} $$
```

将会生成

  $$ x = {-b \pm \sqrt{b^2-4ac} \over 2a}. $$

  $$ |AB| = \sqrt{(x_1-x_2)^2 + (y_1-y_2)^2} $$

