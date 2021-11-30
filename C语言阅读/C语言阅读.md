# C语言阅读



## 函数

- **int atoi(const char \*str)** 

  在头文件<stdlib.h>中定义。

  把参数 **str** 所指向的字符串转换为一个整数（类型为 int 型）。

  ```
  字符串值 = 98993489, 整型值 = 98993489
  字符串值 = runoob.com, 整型值 = 0
  ```

- **char \*fgets(char \*str, int n, FILE \*stream)** 

  在头文件<stdio.h>中定义。

  从指定的流 stream 读取一行，并把它存储在 **str** 所指向的字符串内。当读取 **(n-1)** 个字符时，或者读取到换行符时，或者到达文件末尾时，它会停止，具体视情况而定。

  - **str** -- 这是指向一个字符数组的指针，该数组存储了要读取的字符串。
  - **n** -- 这是要读取的最大字符数（包括最后的空字符）。通常是使用以 str 传递的数组长度。
  - **stream** -- 这是指向 FILE 对象的指针，该 FILE 对象标识了要从中读取字符的流。键盘键入的数据流为**stdin**。

- **void \*malloc(size_t size)** 

  在头文件<stdlib.h>中定义。

  分配所需的内存空间，并返回一个指向它的指针。

  - **size** -- 内存块的大小，以字节为单位。

- **size_t，wchar_t**

  `size_t`是一种“整型”类型，里面保存的是一个整数，就像`int`, `long`那样。这种整数用来记录一个大小(size)。`size_t`的全称应该是size type，就是说“**一种用来记录大小的数据类型**”。通常我们用`sizeof(XXX)`操作，这个操作所得到的结果就是`size_t`类型。因为`size_t`类型的数据其实是保存了一个整数，所以它也可以做加减乘除，也可以转化为`int`并赋值给`int`类型的变量。

  ```c
  int i; 										// 定义一个int类型的变量i
  size_t size = sizeof(i); 	// 用sizeof操作得到变量i的大小，这是一个size_t类型的值
  // 可以用来对一个size_t类型的变量做初始化
  i = (int)size; 						// size_t类型的值可以转化为int类型的值
  ```

  `wchar_t`就是wide char type，“一种用来记录一个宽字符的数据类型”。

  ```c
  char c = 'a'; 			// c保存了字符a，占一个字节
  wchar_t wc = L'a'; 	// wc保存了宽字符a，占两个字节。注意'a'表示字符a，L'a'表示宽字符a
  ```

- **void *alloca(size_t size)**

  在头文件<alloc.h>中定义。

  `alloca`与`malloc`，`calloc`，`realloc`类似，需要注意的是它申请的是“栈(stack)”空间的内存，用完会在退出栈时自动释放，无需手动释放。alloca不宜使用在必须广泛移植的程序中，因为有些机器不一定有传统意义上的"堆栈"。

  - **size** -- 申请分配内存的尺寸
  - **返回值** -- 分配到的内存地址

- **wchar_t * wmemset(wchar_t * dest，wchar_t ch，size_t count)**

  在头文件<wchar.h>中定义。

  将宽字符复制`ch`到`count`宽字符数组（或兼容类型的整数数组）的第一个宽字符中`dest`。

  如果发生溢出，则行为未定义。

  如果`count`为零，则该功能不执行任何操作。

  - **dest** -- 指向宽字符数组来填充
  - **ch** -- 填写宽字符
  - **count** -- 要填写的宽字符数
  - **返回值** -- 返回的副本`dest`

- **size_t wcslen(const wchar_t * str)**

  在头文件<wchar.h>中定义。

  返回宽字符串的长度，即在终止空宽字符之前的非空宽字符数。

  - **str** --  指向要检查的以空字符结尾的宽字符串
  - 以空字符结束的宽字符串的长度`str`。

- **void \*memset(void \*str, int c, size_t n)** 

  在头文件<string.h>中定义。

  复制字符 **c**（一个无符号字符）到参数 **str** 所指向的字符串的前 **n** 个字符。

  - **str** -- 指向要填充的内存块。
  - **c** -- 要被设置的值。该值以 int 形式传递，但是函数在填充内存块时是使用该值的无符号字符形式。
  - **n** -- 要被设置为该值的字符数。
  - **返回值** -- 该值返回一个指向存储区 str 的指针。

- **void \*memcpy(void \*str1, const void \*str2, size_t n)** 

  从存储区 **str2** 复制 **n** 个字节到存储区 **str1**。

  - **str1** -- 指向用于存储复制内容的目标数组，类型强制转换为 void* 指针。
  - **str2** -- 指向要复制的数据源，类型强制转换为 void* 指针。
  - **n** -- 要被复制的字节数。
  - **返回值** -- 该函数返回一个指向目标存储区 str1 的指针。

- **char \*strcpy(char \*dest, const char \*src)**

  在头文件<string.h>中定义。

   **src** 所指向的字符串复制到 **dest**。需要注意的是如果目标数组 dest 不够大，而源字符串的长度又太长，可能会造成缓冲溢出的情况。

  - **dest** -- 指向用于存储复制内容的目标数组。
  - **src** -- 要复制的字符串。
  - **返回值** -- 该函数返回一个指向最终的目标字符串 dest 的指针。

- **int sprintf(char \*str, const char \*format, ...)** 

  在头文件<stdio.h>中定义。

  发送格式化输出到 **str** 所指向的字符串。

  - **str** -- 这是指向一个字符数组的指针，该数组存储了 C 字符串。
  - **format** -- 这是字符串，包含了要被写入到字符串 str 的文本。它可以包含嵌入的 format 标签，format 标签可被随后的附加参数中指定的值替换，并按需求进行格式化。

- **char \*strcat(char \*dest, const char \*src)** 

  在头文件<string.h>中定义。

  - **dest** -- 指向目标数组，该数组包含了一个 C 字符串，且足够容纳追加后的字符串。
  - **src** -- 指向要追加的字符串，该字符串不会覆盖目标字符串。

- **char \*strcpy(char \*dest, const char \*src)**

  在头文件<string.h>中定义。

  - **dest** -- 指向用于存储复制内容的目标数组。
  - **src** -- 要复制的字符串。

- 

## 指针

- 指针多流程 -- 不同if分支下，两块不同业务流程对统一指针申请内存，申请大小不同，使用时按大块内存使用。（数据共享）
- 

## Buffer 0verflow 类型

- heap buffer overflow

- stack buffer overflow

- integer overflow to buffer overflow

  有可能 a+b 发生 integer overflow,  导致 ptr 申请到比较小的内存区域，memcpy 的时候发生溢出。

  ```c
  unsigned int a;
  unsigned int b;
  int *ptr =  (int *)malloc(a+b);
  memcpy(ptr,  buf, a);
  ```

- 

## 符号

-  `|=` 意思为：按位或后赋值
- 