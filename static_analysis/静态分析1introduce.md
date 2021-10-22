# 软件分析（静态程序分析）

程序设计语言与静态分析——static program analysis

# introduction

## contents

1. PL and static analysis
2. Why we learn static analysis ?
3. what is static analysis ?
4. static analysis features and examples
5. teaching plan
6. Evaluation criteria

## PL and static analysis

### PL的结构：

-  theory: language design, type system, semantics and logics
- environment: compilers, runtime system
- **application**(可靠、安全、速度): **program analysis**, program verification, program synthesis

### PL的类别：

命令式编程语言（C/C++，JAVA）、函数式编程语言（js，python）、逻辑式语言（声名式）

语言的核心一直都没有变（core），但是语用环境变了，语言写的程序、软件越来越大。

**Challenge**

保证大的复杂的软件的reliability、security和其他promises

## Why we learn static analysis

- program reliability: null pointer dereference(逆向引用), memory leak
- program security: private information leak, injection(注入) attack
- compiler optimization: dead code elimination(死代码消除), code motion(代码移动)
- program understanding: IDE call hierarchy(IDE调用层次结构), type indication(类型推断) 

## what is static analysis

在运行程序P（静态时刻，编译时分析）之前，就要了解这个程序相关的所有的行为，并且我知道关于这些行为的性质能不能满足。

### Rice's Theorem:

- 并不存在一种方法能够准确得判断程序是否满足那些**non-trivial properties**（不平凡的性质），即yes or no。

- 如果这个程序是由递归可枚举的语言所编写，则它的non-trivial properties是undecidable（不可判断的）。

- non-trivial properties即有兴趣的、有价值的，是与程序动态运行时的行为（run-time behaviors）相关的性质。

- perfect static analysis 是不存在的。即同时满足（and）**sound**（超集，有误报没漏报，overapproximate，必要条件，广度）和**complete**（子集，有漏报没误报，underapproximate，充分条件，精度），所以truth就是充要条件。

  <img src="/Users/mukyuuhate/Documents/Github/notes/static_analysis/静态分析1introduce.assets/image-20211016181031684.png" alt="image-20211016181031684" style="zoom:30%;" />

- useful static analysis是可以的，即满足以下条件中至少一个（or），~~compromise soundness（**false negetive**，假阴性，漏报？）~~，compromise completeness（**false positives**，假阳性，误报？），但是在绝大部分静态分析中，都是妥协completeness，换句话说，**我们追求的是sound but not fully-precise**

  <img src="/Users/mukyuuhate/Documents/Github/notes/static_analysis/静态分析1introduce.assets/image-20211016195756740.png" alt="image-20211016195756740" style="zoom:30%;" />

### necessity of soundness

- 正确性、安全性、全面性，对某些静态分析，如编译优化、程序验证，是缺一不可的。cast——强制类型转换。
- 在几乎所有的分析中，soundness越好，结果就越好。如bug detection，宁可误报，不能漏报，宁可牺牲一些精度

## statice analysis —— bird's eye view（概括）

静态分析要打破动态思维。

<img src="/Users/mukyuuhate/Documents/Github/notes/static_analysis/静态分析1introduce.assets/image-20211016202425400.png" alt="image-20211016202425400" style="zoom:30%;" />

ensure (or get close to ) **soundness**, while making good **trade-offs**（平衡） between analysis **precision** and analysis **speed**. 

## two words to conclude static analysis

- abstraction（抽象）

  <img src="/Users/mukyuuhate/Documents/Github/notes/static_analysis/静态分析1introduce.assets/image-20211017111914596.png" alt="image-20211017111914596" style="zoom:30%;" />

  将程序里具体的域值映射到抽象符号里，后续的操作要基于抽象值来进行。unknown——top、undefined——bottom。

- over-approximation（过近似）：transfer functions、control flows

  - **transfer functions**

    对不同的程序语句和抽象符号之间建立转换规则，抽象函数根据analysis problem和不同程序语句的semantics来设计。

    <img src="/Users/mukyuuhate/Documents/Github/notes/static_analysis/静态分析1introduce.assets/image-20211017113807479.png" alt="image-20211017113807479" style="zoom:20%;" />

  - **control flows**

    建立控制流图，control flow汇聚的地方（循环结束、条件判断结束等），要进行merge，要过近似。

    由于我们没有办法枚举所有的路径 ，所以flow merging（作为control flow的一种近似方式），是静态分析中默认采取的一种方式。

    <img src="/Users/mukyuuhate/Documents/Github/notes/static_analysis/静态分析1introduce.assets/image-20211017113900567.png" alt="image-20211017113900567" style="zoom:30%;" />

tentative——暂定的

## important

- What are the differences between static analysis and (dynamic) testing?
- Understand soundness, completeness, false negatives, and false positives.
- Why soundness is usually required by static analysis?
- How to understand abstraction and over-approximation?













