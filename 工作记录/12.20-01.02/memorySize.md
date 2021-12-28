## 发现的问题

1. `Range.cc`里没有`getValueRange`系列函数；
2. 不同的`function`中会出现命名一致的变量；

## 总结

1. 关于结构体`struct`的宽度

   ```c
   #include <stdio.h>
   #include <string.h>
   
   typedef struct test_size {
       unsigned short a;
       unsigned short b;
       unsigned char d;
       unsigned char e;
       unsigned short f;
       unsigned int g;
       unsigned int h;
   
       char *i;
   } ts;
   
   int main() {
       int si = sizeof(ts);
       int us = sizeof(unsigned short);
       int uc = sizeof(unsigned char);
       int ui = sizeof(unsigned int);
       int c = sizeof(char *);
       printf("%d %d %d %d %d", si, us, uc, ui, c);
   
       return 0;
   }
   
   // 结果为24 2 1 4 8
   // 可以看出，指针类型的宽度为，其指向类型的宽度 X 8
   ```

2. 对于`memcpy_s`这种类型的函数，获取其`Funtion`对象的方法

   ```c
   // 从callees里查找
   FuncSet &CEEs = Ctx->Callees[&CI];
   for (FuncSet::iterator i = CEEs.begin(), e = CEEs.end(); i != e; ++i) {
       // skip vaarg and builtin functions
       Function* ceeFun = *i;
       if(ceeFun == NULL){
       	return "null";
       }else{
           StringRef name = ceeFun->getName();
           return ceeFun->getName();
       }
   }
   ```

   

3. 

