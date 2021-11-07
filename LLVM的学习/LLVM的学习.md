# LLVM中的独立工具

- opt：在IR级对程序进行优化的工具，输入必须是LLVM的bitcode，生成的输出文件必须具有相同的类型。
- llc：通过特定后端将LLVM bitcode转换成目标汇编或目标问价的工具。
- llvm-mc：能够汇编指令并生成像ELF、MachO、PE等对象格式的目标文件，也可以反汇编相同的对象，从而转存这些指令的相应汇编信息和内部LLVM机器指令数据结构。
- lli：LLVM IP的解释器和JIT编译器。
- llvm-link：将几个LLVM bitcode链接在一起，产生一个包含你所有输入的LLVM bitcode。
- llvm-as：将人工可读的LLVM IR文件转换为LLVM bitcode。
- llvm-dis：将LLVM bitcode解码成LLVM汇编码。



# 尝试运行licm优化

```bash
# -emit-llvm标记会告诉clang根据是否存在-c或-S来生成LLVM bitcode或是LLVM汇编码等信息
clang -emit-llvm -c test.c -o test.bc
clang -emit-llvm -S test.c -o test.ll

# -fno-discard-value-names取消自动删除变量名
clang -fno-discard-value-names -emit-llvm -S test.c -o test1.ll

# llvm-dis工具可以将bc文件转化为ll汇编码文件
llvm-dis test2.bc -o test2.ll

# opt是另外的独立工具，可以做优化
opt -licm test.ll -S -o test2.ll
opt -licm test.bc -c -o test2.bc
opt -help
```



```
# 在最初生成的ll文件中有这么一行语句，当此语句定义的optnone属性存在时，opt就根本不会触及该函数。

; Function Attrs: noinline nounwind optnone uwtable

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
```



## 工具

*Doxygen*是一种开源跨平台的，以类似JavaDoc风格描述的文档系统，完全支持C、C++、Java、Objective-C和IDL语言，部分支持PHP、C#。注释的语法与Qt-Doc、KDoc和JavaDoc兼容。

https://llvm.org/doxygen/LICM_8cpp_source.html源码



## 资料

- 在**算法导论**中定义的循环不变式的性质：

  1. 初始化（循环第一次迭代之前）的时候，它为真；
  2. 如果循环的某次迭代之前它为真，那么下次迭代之前它仍为真；
  3. 循环结束的时候，不变式为我们提供一个有用的性质，该性质有助于证明算法是正确的。

- 在**opt -help**中，--licm —— Loop Invariant Code Motion。

- 在**LLVM的手册**中对licm的说明

  此传递执行licm，尝试从循环体中删除尽可能多的代码。它通过**将代码提升到 preheader 块**中，或者在安全的情况下**将代码下沉到 exit 块**中来做到这一点。此传递还将循环中**必须别名的内存位置提升到寄存器**中，从而提升和下沉“不变”加载和存储。

  循环外提操作是一种规范化转换。它启用并简化了中端的后续优化。重新实现提升指令以减少寄存器压力是后端的责任，它具有关于寄存器压力的更准确信息，并且还处理比 LICM 增加有效范围的其他优化。

  此过程使用别名分析有两个目的：

  1. 移动循环不变加载和循环外调用。如果我们可以确定循环内的加载或调用永远不会对存储的任何内容进行别名，我们可以像任何其他指令一样提升或下沉它。

  2. 内存的标量提升。如果循环内部有存储指令，我们尝试将存储移动到循环之后而不是循环内部。这只有在满足以下几个条件时才会发生：

     1. 通过存储的指针是循环不变的。
     2. 循环中没有可能为指针别名的存储或加载。循环中没有对指针进行修改/引用的调用。

     如果这些条件为真，我们可以将指针循环中的加载和存储提升为使用临时 alloca 变量。然后我们使用[mem2reg](https://llvm.org/docs/Passes.html#passes-mem2reg)功能为变量构造适当的 SSA 形式。

- 





## 实例

### first

```c
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int main()
{
	int sum =0;
	int limit = 12;

	for(int i=0;i<limit-2;i++)  // limit - 2 是循环不变量
	{
		sum += i;
	}
	
	return 0;

}
```

![image-20211022213816114](/Users/mukyuuhate/Documents/GitHub/notes/LLVM的学习/LLVM的学习.assets/image-20211022213816114.png)

此示例我的主要关注点在`limit - 2`上，这是个显而易见的函数不变量，它存在于for循环的cond部分。

将函数不变量`limit - 2`的计算从循环条件for.cond中移动到了循环入口entry处，这样就不需要每次循环时计算它了。

```c
# for循环的结构
for(init; cond; inc) {
    body
}
```

### second

```c
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int main(){
  int a = 0, b = 1, tmp;

  for(int i = 0; i < 10; ++i) {
		tmp = a;
    a = b;
    b = b + tmp;
  }
  
  return 0;
}
```

此例中在for循环的的cond部分没有了函数不变量，所以我侧重关注此情况的优化方案。

显而易见的是变量tmp只是中间变量，变量b和a分别为斐波那契数列的当前项的值和前一项的值。

循环不变式是在循环体的每次执行前后均为真的谓词。循环是重复多次实现的，要证明循环的结果是正确的，就要仿照数学归纳法的方法，即如这次满足某一性质那么下次也满足，则循环完毕性质也成立，显然,循环不变式是很重要的。

在此例子中，b和a分别为斐波那契数列的当前项的值和前一项的值且他们之和为下一项的值，显然在不断的循环中一直为真。

![image-20211025165006152](/Users/mukyuuhate/Documents/GitHub/notes/LLVM的学习/LLVM的学习.assets/image-20211025165006152.png)

![image-20211025165047276](/Users/mukyuuhate/Documents/GitHub/notes/LLVM的学习/LLVM的学习.assets/image-20211025165047276.png)

- promoted：代码提升后缀，应该只是一种命名。
- lcssa：loop closed ssa，闭环静态单赋值形式，应该只是一种命名，在exit块中使用，含义目前未知。

首先源代码中没有明显的表面上的循环不变式，而从结果上看，算法导论中所定义的循环不变式并没有做相应处理，不过这也在意料之中，因为算法导论中所定义的循环不变式是算法层面的，类似于递归调用，是形式不变，而例一中所处理的是形式和值的不变。所以这一层面的处理在此例中基本没有。（个人想法）

然后我们再根据licm的解释来分析，核心目标是尽量减少循环体中的代码，包括向preheader提升和向exit下沉，其次是构建ssa形式。这里提升和下沉代码要依靠别名分析（感觉是分析相应变量满不满足外提的条件？）。

- 通过phi构建了ssa形式；
- 将body中计算后的store操作下沉至了end中。

### thrid

```c
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int main()
{
	int sum = 0;
	int len = 12;

	for(int i = 0; i < len; i++){
		sum += 1;
	}

    printf("%d", sum);

    return 0;
}
```

![image-20211028142357665](/Users/mukyuuhate/Documents/GitHub/notes/LLVM的学习/LLVM的学习.assets/image-20211028142357665.png)

licm的优化并没有直接获得结果，没有预期中的高级。

### fourth

```c
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

int main()
{
	int a = 0;
	int len = 10;

    char *ptr = malloc(10);

    for(int i = 0; i < len; i++){
        a = a + 2;
        ptr ++;
    }

	return 0;
}
```

![image-20211028142657672](/Users/mukyuuhate/Documents/GitHub/notes/LLVM的学习/LLVM的学习.assets/image-20211028142657672.png)

licm的优化也没有直接得到`a = 2 * len`和`ptr = len`，而是通过循环进行计算的。





# LLVM 指令集

LLVM 指令集由几种不同分类的指令组成：[终止符指令](https://llvm.org/docs/LangRef.html#terminators)、[二进制指令](https://llvm.org/docs/LangRef.html#binaryops)、[按位二进制指令](https://llvm.org/docs/LangRef.html#bitwiseops)、[内存指令](https://llvm.org/docs/LangRef.html#memoryops)和 [其他指令](https://llvm.org/docs/LangRef.html#otherops)。

## 终止符指令

终止指令：  [ret](https://llvm.org/docs/LangRef.html#i-ret) ， [br](https://llvm.org/docs/LangRef.html#i-br) ， [switch](https://llvm.org/docs/LangRef.html#i-switch)， [indirectbr](https://llvm.org/docs/LangRef.html#i-indirectbr) ， [invoke](https://llvm.org/docs/LangRef.html#i-invoke)，[callbr](https://llvm.org/docs/LangRef.html#i-callbr)， [resume](https://llvm.org/docs/LangRef.html#i-resume)，  [catchswitch](https://llvm.org/docs/LangRef.html#i-catchswitch) ，  [catchret](https://llvm.org/docs/LangRef.html#i-catchret) ，  [cleanupret](https://llvm.org/docs/LangRef.html#i-cleanupret) 和[unreachable](https://llvm.org/docs/LangRef.html#i-unreachable)。

- ret

  `ret`指令用于将控制流（和可选的值）从函数返回给调用者。

  `ret` 指令有两种形式：一种返回一个值然后引起控制流，另一种只引起控制流发生。

  当执行“ `ret`”指令时，控制流返回到调用函数的上下文。如果调用者是“[call](https://llvm.org/docs/LangRef.html#i-call)”指令，则在调用后的指令处继续执行。如果调用者是“ [invoke](https://llvm.org/docs/LangRef.html#i-invoke) ”指令，则在“正常”目标块的开头继续执行。如果指令返回一个值，该值应设置调用或调用指令的返回值。

  ```assembly
  ret <type> <value>       ; Return a value from a non-void function
  ret void                 ; Return from void function
  
  ret i32 5                       ; Return an integer value of 5
  ret void                        ; Return from a void function
  ret { i32, i8 } { i32 4, i8 2 } ; Return a struct of values 4 and 2
  ```

- br

  `br`指令用于使控制流转移到当前函数中的不同基本块。该指令有两种形式，分别对应条件分支和无条件分支。

  在执行条件“ `br`”指令时，将评估`i1`参数。如果值为`true`，则控制流向`<iftrue>label`参数。如果`cond`是`false`，则控制流向 ' `<iffalse>label`参数。如果`cond`是`poison`或`undef`，则该指令具有未定义的行为。

  ```assembly
  br i1 <cond>, label <iftrue>, label <iffalse>
  br label <dest>          ; Unconditional branch
  
  Test:
    %cond = icmp eq i32 %a, %b
    br i1 %cond, label %IfEqual, label %IfUnequal
  IfEqual:
    ret i32 1
  IfUnequal:
    ret i32 0
  ```

- switch

  `switch`指令用于将控制流转移到几个不同的地方之一。它是`br`指令的概括，允许分支发生到许多可能的目的地之一。

- indirectbr

  `indirectbr`指令实现了一个指向当前函数内的标签的间接分支，其地址由 `address`指定。地址必须从派生 [blockaddress](https://llvm.org/docs/LangRef.html#blockaddress)不变。

- invoke

  `invoke`指令使控制转移到指定的函数，控制流转移到“`normal`标签或`exception`标签的可能性。如果被调用函数以“ `ret`”指令返回，则控制流将返回到“正常”标签。如果被调用者（或任何间接被调用者）通过 [resume](https://llvm.org/docs/LangRef.html#i-resume) 指令或其他异常处理机制返回，控制将被中断并在动态最近的“异常”标签处继续。

  `exception`标签是例外的[着陆板](https://llvm.org/docs/ExceptionHandling.html#overview)。因此，`exception`标签需要包含 [landingpad](https://llvm.org/docs/LangRef.html#i-landingpad) 指令，该指令包含有关展开发生后程序行为的信息，作为其第一条非 PHI 指令。对`landingpad`指令的限制将其与`invoke`指令紧密耦合，因此`landingpad`指令中包含的重要信息不会因为正常的代码移动而丢失。

- callbr

  `callbr`指令使控制转移到指定的函数，控制流转移到`fallthrough`标签或`indirect`标签之一的可能性。

  此指令仅应用于实现 gcc 样式内联汇编的“goto”功能。任何其他用法都是 IR 验证器中的错误。

- resume

  `resume`指令是没有后继的终止符指令。

- catchswitch

  [LLVM 的异常处理系统](https://llvm.org/docs/ExceptionHandling.html#overview)使用`catchswitch`指令来描述可能由[EH 个性例程](https://llvm.org/docs/LangRef.html#personalityfn)执行的一组可能的捕获处理[程序](https://llvm.org/docs/LangRef.html#personalityfn)。

- catcher

  `catchret`指令是具有单个后继的终止符指令。

- cleanupret

  `cleanupret`指令是具有可选后继的终止符指令。

- unreachable

  `unreachable`指令没有定义的语义。该指令用于通知优化器无法访问代码的特定部分。这可用于指示无法访问无返回函数之后的代码以及其他事实。

## 单目运算符

一元运算符需要单个操作数，对其执行操作并生成单个值。操作数可能表示多个数据，就像[向量](https://llvm.org/docs/LangRef.html#t-vector)数据类型一样。结果值与其操作数具有相同的类型。

- fneg

  `fneg`指令返回其操作数的否定。

  ```assembly
  <result> = fneg [fast-math flags]* <ty> <op1>   ; yields ty:result
  ```

## 双目运算符

二元运算符用于完成程序中的大部分计算。它们需要两个相同类型的操作数，对它们执行操作，并生成一个值。操作数可能表示多个数据，就像[向量](https://llvm.org/docs/LangRef.html#t-vector)数据类型一样。结果值与其操作数具有相同的类型。

- add

  `add`指令返回其两个操作数的和。

  产生的值是两个操作数的整数和。

  如果和有无符号溢出，返回的结果是数学结果模 $2^n$，其中 $n$ 是结果的位宽。

  由于 LLVM 整数使用二进制补码表示，因此该指令适用于有符号和无符号整数。

  `nuw`并分别`nsw`代表“No Unsigned Wrap”和“No Signed Wrap”。如果存在`nuw`和/或`nsw`关键字，则分别发生无符号和/或有符号溢出时， 的结果值`add`是[毒值](https://llvm.org/docs/LangRef.html#poisonvalues)。

  ```assembly
  <result> = add <ty> <op1>, <op2>          ; yields ty:result
  <result> = add nuw <ty> <op1>, <op2>      ; yields ty:result
  <result> = add nsw <ty> <op1>, <op2>      ; yields ty:result
  <result> = add nuw nsw <ty> <op1>, <op2>  ; yields ty:result
  
  <result> = add i32 4, %var          ; yields i32:result = 4 + %var
  ```

- fadd

  `fadd`指令返回其两个操作数的和。

  `fadd`指令的两个参数必须是 [浮点数](https://llvm.org/docs/LangRef.html#t-floating)或浮点数[向量](https://llvm.org/docs/LangRef.html#t-vector)。两个参数必须具有相同的类型。

- sub

  `sub`指令返回其两个操作数的差值。

  请注意，`sub`指令用于表示大多数其他中间表示中存在的`neg`指令。

  产生的值是两个操作数的整数差。

  如果差值有无符号溢出，则返回的结果是数学结果模 $2^n$，其中$n$是结果的位宽。

  由于 LLVM 整数使用二进制补码表示，因此该指令适用于有符号和无符号整数。

  `nuw`并分别`nsw`代表“No Unsigned Wrap”和“No Signed Wrap”。如果存在`nuw`和/或`nsw`关键字，则分别发生无符号和/或有符号溢出时， 的结果值`sub`是[毒值](https://llvm.org/docs/LangRef.html#poisonvalues)。

  ```assembly
  <result> = sub <ty> <op1>, <op2>          ; yields ty:result
  <result> = sub nuw <ty> <op1>, <op2>      ; yields ty:result
  <result> = sub nsw <ty> <op1>, <op2>      ; yields ty:result
  <result> = sub nuw nsw <ty> <op1>, <op2>  ; yields ty:result
  
  <result> = sub i32 4, %var          ; yields i32:result = 4 - %var
  <result> = sub i32 0, %val          ; yields i32:result = -%var
  ```

- fsub

  `fsub`指令返回其两个操作数的差值。

  `fsub`指令的两个参数必须是 [浮点数](https://llvm.org/docs/LangRef.html#t-floating)或浮点数[向量](https://llvm.org/docs/LangRef.html#t-vector)。两个参数必须具有相同的类型。

- mul

  `mul`指令返回其两个操作数的乘积。

- fmul

- udiv

  `udiv`指令返回其两个操作数的商。

  产生的值是两个操作数的无符号整数商。

- sdiv

  `udiv`指令返回其两个操作数的商。

  产生的值是两个操作数的有符号整数商。

- fdiv

- urem

  `urem`指令返回其两个参数的无符号除法的余数。

  该指令返回除法的无符号整数*余数*。该指令始终执行无符号除法以获取余数。

- srem

  `srem`指令返回其两个操作数的有符号除法的余数。此指令还可以采用 值的[向量](https://llvm.org/docs/LangRef.html#t-vector)版本，在这种情况下，元素必须是整数。

- frem

- 

## 按位二元计算（[Bitwise Binary Operations](https://llvm.org/docs/LangRef.html#id1769)）

按位二元运算符用于在程序中进行各种形式的位操作。它们通常是非常有效的指令，并且通常可以从其他指令中降低强度。它们需要两个相同类型的操作数，对它们执行操作，并生成一个值。结果值与其操作数的类型相同。

- shl

  `shl`指令返回第一个向左移动指定位数的操作数。

- lshr

  `lshr`指令（逻辑右移）返回第一个操作数右移指定位数的零填充。

- ashr

  `ashr`指令（算术右移）返回第一个右移指定位数并带有符号扩展的操作数。

- and

  `and`指令返回其两个操作数的按位逻辑和。

- or

  `or`指令返回其两个操作数的按位逻辑包含或。

- xor

  `xor`指令返回其两个操作数的按位逻辑异或。将`xor`用于实施“one’s complement”的操作，这是C中的“〜”运算符

- 



## 向量运算（[Vector Operations](https://llvm.org/docs/LangRef.html#id1806)）

LLVM 支持多种指令以独立于目标的方式表示向量操作。这些指令涵盖了有效处理向量所需的元素访问和特定于向量的操作。虽然 LLVM 确实直接支持这些向量操作，但许多复杂的算法将希望使用特定于目标的内在函数来充分利用特定目标。

- extractelement

  `extractelement`指令从指定索引处的向量中提取单个标量元素

- insertelement

  `insertelement`指令将标量元素插入到指定索引处的向量中。

- shufflevector

  `shufflevector`指令从两个输入向量构造元素的排列，返回一个与输入具有相同元素类型且长度与混洗掩码相同的向量。

- 



## 聚合操作（[Aggregate Operations](https://llvm.org/docs/LangRef.html#id1825)）

LLVM 支持多种处理[聚合](https://llvm.org/docs/LangRef.html#t-aggregate)值的指令 。

- extractvalue

  `extractvalue`指令从[聚合](https://llvm.org/docs/LangRef.html#t-aggregate)值中提取成员字段的值

- insertvalue

  `insertvalue`指令将一个值插入到[聚合](https://llvm.org/docs/LangRef.html#t-aggregate)值的成员字段中。

- 



## 内存访问和寻址操作（[Memory Access and Addressing Operations](https://llvm.org/docs/LangRef.html#id1838)）

基于 SSA 的表示的一个关键设计点是它如何表示内存。在 LLVM 中，没有内存位置是 SSA 形式的，这使得事情变得非常简单。本节介绍如何在 LLVM 中读取、写入和分配内存。

- alloca

  `alloca`指令在当前正在执行的函数的堆栈帧上分配内存，当这个函数返回到它的调用者时自动释放。如果未明确指定地址空间，则对象将在数据[布局字符串](https://llvm.org/docs/LangRef.html#langref-datalayout)的 alloca 地址空间中分配 。

  内存已分配；返回一个指针。分配的内存未初始化，从未初始化的内存加载会产生一个未定义的值。如果分配的堆栈空间不足，则操作本身是未定义的。`alloca` 内存在函数返回时自动释放。`alloca`'指令通常用于表示必须具有可用地址的自动变量。当函数返回时（使用`ret`或`resume`指令），内存被回收。分配零字节是合法的，但返回的指针可能不是唯一的。没有指定内存分配的顺序（即堆栈增长的方式）。

  请注意，数据[布局字符串中](https://llvm.org/docs/LangRef.html#langref-datalayout)alloca 地址空间之外的`alloca`仅在目标已为其分配语义时才有意义。

  ```assembly
  <result> = alloca [inalloca] <type> [, <ty> <NumElements>] [, align <alignment>] [, addrspace(<num>)]     ; yields type addrspace(num)*:result
  
  %ptr = alloca i32                             ; yields i32*:ptr
  %ptr = alloca i32, i32 4                      ; yields i32*:ptr
  %ptr = alloca i32, i32 4, align 1024          ; yields i32*:ptr
  %ptr = alloca i32, align 1024                 ; yields i32*:ptr
  # align 的意思是“对齐”
  # “对齐”的意义是：若一个结构中含有一个int,一个char，一个int则他应该占用4*3=12字节，虽然char本身只占用一个字节的空间
  # 但由于要向4“对齐”所以其占用内存空间仍为4（根据大端小端分别存储）
  ```

- load

  `load`指令用于从内存中读取。

  所指向的内存位置已加载。如果加载的值是标量类型，则读取的字节数不超过保存该类型所有位所需的最小字节数。例如，加载一个`i24`最多读取三个字节。当加载`i20`大小不是整数字节的类型的值时，如果该值最初不是使用相同类型的存储写入的，则结果是不确定的。如果加载的值是聚合类型，则可以访问与填充对应的字节，但会被忽略，因为无法从加载的聚合值中观察填充。如果`<pointer>`不是明确定义的值，则行为未定义。

  ```assembly
  <result> = load [volatile] <ty>, <ty>* <pointer>[, align <alignment>][, !nontemporal !<nontemp_node>][, !invariant.load !<empty_node>][, !invariant.group !<empty_node>][, !nonnull !<empty_node>][, !dereferenceable !<deref_bytes_node>][, !dereferenceable_or_null !<deref_bytes_node>][, !align !<align_node>][, !noundef !<empty_node>]
  <result> = load atomic [volatile] <ty>, <ty>* <pointer> [syncscope("<target-scope>")] <ordering>, align <alignment> [, !invariant.group !<empty_node>]
  !<nontemp_node> = !{ i32 1 }
  !<empty_node> = !{}
  !<deref_bytes_node> = !{ i64 <dereferenceable_bytes> }
  !<align_node> = !{ i64 <value_alignment> }
  
  %ptr = alloca i32                               ; yields i32*:ptr
  store i32 3, i32* %ptr                          ; yields void
  %val = load i32, i32* %ptr                      ; yields i32:val = i32 3
  ```

- store

  `store`指令用于写入内存。

  内存的内容被更新以包含`<value>`在`<pointer>`操作数指定的位置。如果`<value>`是标量类型，则写入的字节数不超过保存该类型所有位所需的最小字节数。例如，存储一个`i24`写入最多三个字节。当写入`i20`大小不是整数字节的类型的值时，未指定不属于该类型的额外位会发生什么情况，但它们通常会被覆盖。如果`<value>`是聚合类型，填充用[undef](https://llvm.org/docs/LangRef.html#undefvalues)填充 。如果`<pointer>`不是明确定义的值，则行为未定义。

  ```assembly
  store [volatile] <ty> <value>, <ty>* <pointer>[, align <alignment>][, !nontemporal !<nontemp_node>][, !invariant.group !<empty_node>]        ; yields void
  store atomic [volatile] <ty> <value>, <ty>* <pointer> [syncscope("<target-scope>")] <ordering>, align <alignment> [, !invariant.group !<empty_node>] ; yields void
  !<nontemp_node> = !{ i32 1 }
  !<empty_node> = !{}
  
  %ptr = alloca i32                               ; yields i32*:ptr
  store i32 3, i32* %ptr                          ; yields void
  %val = load i32, i32* %ptr                      ; yields i32:val = i32 3
  ```

- fence

  `fence`指令用于在操作之间引入happens-before 边缘。

- campchg

  `cmpxchg`指令用于原子地修改内存。它在内存中加载一个值并将其与给定值进行比较。如果它们相等，它会尝试将一个新值存储到内存中。

- atomicrmw

  `atomicrmw`指令用于原子地修改内存。

- getelementptr

  `getelementptr`指令用于获取[聚合](https://llvm.org/docs/LangRef.html#t-aggregate)数据结构的子元素的地址。它只执行地址计算，不访问内存。该指令还可用于计算此类地址的向量。

- 



## 转化操作（[Conversion Operations](https://llvm.org/docs/LangRef.html#id1882)）

此类别中的指令是转换指令（强制转换），它们都采用单个操作数和类型。它们对操作数执行各种位转换。

- trunc ... to

  `trunc`指令将其操作数截断为`ty2`类型。

- zext  ... to

  `zext`指令零将其操作数扩展为 `ty2`类型。

- sext ... to

  `sext`符号扩展`value`到`ty2`类型。

- fpturnc ... to

  `fptrunc`指令截断`value`为`ty2`类型。

- fpext ... to

  `fpext`将浮点扩展为`value`更大的浮点值。

- fptoui ... to

  `fptoui`将一个浮点数转换`value`为它的等价于 type 的无符号整数`ty2`。

- fptosi ... to

  `fptosi`指令将[浮点数](https://llvm.org/docs/LangRef.html#t-floating) 转换`value`为`ty2`类型。

- uitofp ... to

  `uitofp`指令视为`value`无符号整数并将该值转换为`ty2`类型。

- setoff ... to

  `sitofp`指令`value`视为有符号整数并将该值转换为`ty2`类型。

- ptrtoint ... to

  `ptrtoint`指令将指针或指针向量转换为`value`整数（或整数向量）类型`ty2`。

- Intooptr ... to

  `inttoptr`指令将整数`value`转换为指针类型，`ty2`。

- bitcast ... to

  `bitcast`指令`value`在`ty2`不改变任何位的情况下转换为类型。

- addspacecast ... to

  在`addrspacecast`指令将`ptrval`来自`pty`在地址空间`n`中键入`pty2`的地址空间`m`。

-  



## 其他操作（[Other Operations](https://llvm.org/docs/LangRef.html#id1961)[¶](https://llvm.org/docs/LangRef.html#other-operations)）

此类别中的指令是“杂项”指令，无法进行更好的分类。

- icmp

  `icmp`指令根据其两个整数、整数向量、指针或指针向量操作数的比较返回一个布尔值或一个布尔值向量。

  在`icmp`进行比较`op1`，并`op2`根据给定为条件码`cond`。执行的比较总是产生 [i1](https://llvm.org/docs/LangRef.html#t-integer)或`i1`结果向量，如下所示：

  1. `eq`:`true`如果操作数相等则产生，`false` 否则产生。不需要或执行符号解释。
  2. `ne`:`true`如果操作数不相等，`false` 则产生，否则产生。不需要或执行符号解释。
  3. `ugt`: 将操作数解释为无符号值并产生 `true`if`op1`大于`op2`。
  4. `uge`: 将操作数解释为无符号值并产生 `true`if`op1`大于或等于`op2`。
  5. `ult`: 将操作数解释为无符号值并产生 `true`if`op1`小于`op2`。
  6. `ule`: 将操作数解释为无符号值并产生 `true`if`op1`小于或等于`op2`。
  7. `sgt`: 将操作数解释为有符号值并产生`true` if`op1`大于`op2`。
  8. `sge`: 将操作数解释为有符号值并产生`true` if`op1`大于或等于`op2`。
  9. `slt`: 将操作数解释为有符号值并产生`true` if`op1`小于`op2`。
  10. `sle`: 将操作数解释为有符号值并产生`true` if`op1`小于或等于`op2`。

  如果操作数是[指针](https://llvm.org/docs/LangRef.html#t-pointer)类型的，则将指针值作为整数进行比较。

  如果操作数是整数向量，则将它们逐个进行比较。结果是一个`i1`与要比较的值具有相同元素数量的向量。否则，结果为`i1`。

  ```assembly
  <result> = icmp <cond> <ty> <op1>, <op2>   ; yields i1 or <N x i1>:result
  
  <result> = icmp eq i32 4, 5          ; yields: result=false
  <result> = icmp ne float* %X, %X     ; yields: result=false
  <result> = icmp ult i16  4, 5        ; yields: result=true
  <result> = icmp sgt i16  4, 5        ; yields: result=false
  <result> = icmp ule i16 -4, 5        ; yields: result=false
  <result> = icmp sge i16  4, 5        ; yields: result=false
  ```

- fcmp

  `fcmp`指令根据其操作数的比较返回一个布尔值或布尔值向量。

  如果操作数是浮点标量，则结果类型是布尔值 ( [i1](https://llvm.org/docs/LangRef.html#t-integer) )。

  如果操作数是浮点向量，则结果类型是布尔向量，其元素数与被比较的操作数相同。

- phi

  `phi`指令用于在表示函数的 SSA 图中实现 $φ$ 节点。（静态单一表示）

  在运行时，`phi`指令在逻辑上采用与紧接在当前块之前执行的前驱基本块对应的对指定的值。

  ```assembly
  <result> = phi [fast-math-flags] <ty> [ <val0>, <label0>], ...
  
  Loop:       ; Infinite loop that counts from 0 on up...
    %indvar = phi i32 [ 0, %LoopHeader ], [ %nextindvar, %Loop ]
    %nextindvar = add i32 %indvar, 1
    br label %Loop
  ```

  在运行时，phi 指令根据“在当前 block 之前执行的是哪一个 predecessor(前任) block”来得到相应的值。

  以上面示例中的 phi 指令为例，如果当前 block 之前执行的是 LoopHeader，则该 phi 指令的值是 0，而如果是从 Loop label 过来的，则该 phi 指令的值是 %nextindvar。

  在 phi 指令的语法中，后面是一个列表，列表中的每个元素是一个 value/label 对，每个 label 表示一个当前 block 的 predecessor block，phi 指令就是根据 label 选相应的 value。

  phi 指令必须在 basic block 的最前面，也就是在一个 basic block 中，在 phi 指令之前不允许有非 phi 指令。

- select

  `select`指令用于根据条件选择一个值，没有 IR 级分支。

- freeze

  `freeze`指令用于停止传播 [undef](https://llvm.org/docs/LangRef.html#undefvalues)和[毒药](https://llvm.org/docs/LangRef.html#poisonvalues)值。

- call

  `call`指令代表一个简单的函数调用。

- va_arg

  `va_arg`指令用于访问通过函数调用的“可变参数”区域传递的参数。它用于`va_arg`在 C 中实现宏。

- landingpad

  [LLVM 的异常处理系统](https://llvm.org/docs/ExceptionHandling.html#overview)使用`landingpad`指令来指定一个基本块是一个着陆垫 - 一个异常着陆的地方，并对应于在`try`/`catch`序列的`catch`部分中找到的代码。它定义了重新进入[函数](https://llvm.org/docs/LangRef.html#personalityfn)时由[个性函数](https://llvm.org/docs/LangRef.html#personalityfn)提供的值。在`resultval`有`resultty`型。

- catchpad

- cleanuppad

- 

# 
