LLVM中的独立工具：

- opt：在IR级对程序进行优化的工具，输入必须是LLVM的bitcode，生成的输出文件必须具有相同的类型。
- llc：通过特定后端将LLVM bitcode转换成目标汇编或目标问价的工具。
- llvm-mc：能够汇编指令并生成像ELF、MachO、PE等对象格式的目标文件，也可以反汇编相同的对象，从而转存这些指令的相应汇编信息和内部LLVM机器指令数据结构。
- lli：LLVM IP的解释器和JIT编译器。
- llvm-link：将几个LLVM bitcode链接在一起，产生一个包含你所有输入的LLVM bitcode。
- llvm-as：将人工可读的LLVM IR文件转换为LLVM bitcode。
- llvm-dis：将LLVM bitcode解码成LLVM汇编码。



```bash
# -emit-llvm标记会告诉clang根据是否存在-c或-S来生成LLVM bitcode或是LLVM汇编码等信息
clang -emit-llvm -c size.c -o size.bc
clang -emit-llvm -S -c size.c -o size.ll

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

attributes #0 = { noinline nounwind optnone uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="all" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
```

