# buffer_overflow

## examples

### use-after-free

```c
#include<stdio.h>
#include<stdlib.h>

int main(int argc, const char* argv[]) {
	void* ptr = malloc(sizeof(char));
	free(ptr);
	memset(ptr, 0, sizeof(char) * 2);
	return 0;
}
```

<img src=".\buffer_overflow.assets\image-20211107200741832.png" alt="image-20211107200741832" style="zoom:50%;" />

<img src=".\buffer_overflow.assets\image-20211107200721650.png" alt="image-20211107200721650" style="zoom:50%;" />

## hw_demo

- `1_IOTOBO.c`

  **缺陷发生情景**：尝试使用来自键入的长度值分配数组。

  **潜在的缺陷**：如果`data * sizeof(int) > SIZE_MAX`，则会出现**整数溢出导致内存越界**。因此进行初始化的for循环导致缓冲区溢出 。

  <img src=".\buffer_overflow.assets\image-20211106164301191.png" alt="image-20211106164301191" style="zoom:60%;" />

  <img src=".\buffer_overflow.assets\image-20211106164333622.png" alt="image-20211106164333622" style="zoom:60%;" />

  <img src=".\buffer_overflow.assets\image-20211106165212139.png" alt="image-20211106165212139" style="zoom:80%;" />

  **使用`AddressSanitizer`进行分析**：

  

- `2_ArrayIndex.c`

  **缺陷发生情景**：使用循环将数据复制到字符串。

  **在`wmenset`中的缺陷**：将数据初始化为一个比循环中使用的小缓冲区更大的大缓冲区。

  **潜在缺陷**：如果`date`的长度大于`dest`的长度，可能会发生**数组下标越界**。

  **使用`AddressSanitizer`进行分析**：

  <img src=".\buffer_overflow.assets\image-20211109154859525.png" alt="image-20211109154859525" style="zoom:100%;" />

  ```
  =================================================================
  ==4987==ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7fff4ff0ca08 at pc 0x0000004c3017 bp 0x7fff4ff0c910 sp 0x7fff4ff0c908
  WRITE of size 4 at 0x7fff4ff0ca08 thread T0
      #0 0x4c3016 in CWE121_Stack_Based_Buffer_Overflow__CWE806_wchar_t_alloca_loop_01_bad /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/2_ArrayIndex.c:63:21
      #1 0x4c317c in main /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/2_ArrayIndex.c:86:5
      #2 0x7f6aa4896bf6 in __libc_start_main /build/glibc-S9d2JN/glibc-2.27/csu/../csu/libc-start.c:310
      #3 0x41ae49 in _start (/home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/2_ArrayIndex+0x41ae49)
  
  Address 0x7fff4ff0ca08 is located in stack of thread T0 at offset 232 in frame
      #0 0x4c2d5f in CWE121_Stack_Based_Buffer_Overflow__CWE806_wchar_t_alloca_loop_01_bad /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/2_ArrayIndex.c:49
  
    This frame has 2 object(s):
      [32, 232) 'dest' (line 57) <== Memory access at offset 232 overflows this variable
      [304, 704) ''
  HINT: this may be a false positive if your program uses some custom stack unwind mechanism, swapcontext or vfork
        (longjmp and C++ exceptions *are* supported)
  SUMMARY: AddressSanitizer: stack-buffer-overflow /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/2_ArrayIndex.c:63:21 in CWE121_Stack_Based_Buffer_Overflow__CWE806_wchar_t_alloca_loop_01_bad
  Shadow bytes around the buggy address:
    0x100069fd98f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x100069fd9900: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x100069fd9910: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x100069fd9920: 00 00 00 00 f1 f1 f1 f1 00 00 00 00 00 00 00 00
    0x100069fd9930: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  =>0x100069fd9940: 00[f2]f2 f2 f2 f2 f2 f2 f2 f2 00 00 00 00 00 00
    0x100069fd9950: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x100069fd9960: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x100069fd9970: 00 00 00 00 00 00 00 00 00 00 00 00 f3 f3 f3 f3
    0x100069fd9980: f3 f3 f3 f3 00 00 00 00 00 00 00 00 00 00 00 00
    0x100069fd9990: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  Shadow byte legend (one shadow byte represents 8 application bytes):
    Addressable:           00
    Partially addressable: 01 02 03 04 05 06 07 
    Heap left redzone:       fa
    Freed heap region:       fd
    Stack left redzone:      f1
    Stack mid redzone:       f2
    Stack right redzone:     f3
    Stack after return:      f5
    Stack use after scope:   f8
    Global redzone:          f9
    Global init order:       f6
    Poisoned by user:        f7
    Container overflow:      fc
    Array cookie:            ac
    Intra object redzone:    bb
    ASan internal:           fe
    Left alloca redzone:     ca
    Right alloca redzone:    cb
    Shadow gap:              cc
  ==4987==ABORTING
  ```

  

- `3_PtrOffset.c` and `3_Ptroffset_01.c`

  **缺陷发生情景**：使用`strcat`将数据复制到字符串。

  **缺陷**：**指针偏移异常**，出现了使用更大的缓存为小缓冲区赋值的情况，导致越界。

  **使用`AddressSanitizer`进行分析**：

  ![image-20211109160123453](.\buffer_overflow.assets\image-20211109160123453.png)

  ```
  =================================================================
  ==5742==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x606000000112 at pc 0x000000492a90 bp 0x7ffcff71fa30 sp 0x7ffcff71f1f8
  WRITE of size 2 at 0x606000000112 thread T0
      #0 0x492a8f in __asan_memcpy /home/brian/src/final/llvm-project/compiler-rt/lib/asan/asan_interceptors_memintrinsics.cpp:22:3
      #1 0x4c2ef3 in Buffer_Overflow__c_src_char_memcpy_ptrOffset_bad /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/3_PtrOffset_01.c:67:13
      #2 0x4c3008 in CWE122_Heap_Based_Buffer_Overflow__c_src_char_cat_12_bad /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/3_PtrOffset_01.c:86:5
      #3 0x4c304c in main /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/3_PtrOffset_01.c:105:5
      #4 0x7f8a2584cbf6 in __libc_start_main /build/glibc-S9d2JN/glibc-2.27/csu/../csu/libc-start.c:310
      #5 0x41ae49 in _start (/home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/3_PtrOffset_01+0x41ae49)
  
  0x606000000112 is located 0 bytes to the right of 50-byte region [0x6060000000e0,0x606000000112)
  allocated by thread T0 here:
      #0 0x49358d in malloc /home/brian/src/final/llvm-project/compiler-rt/lib/asan/asan_malloc_linux.cpp:145:3
      #1 0x4c2d8c in Buffer_Overflow__c_src_char_memcpy_ptrOffset_bad /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/3_PtrOffset_01.c:57:36
      #2 0x4c3008 in CWE122_Heap_Based_Buffer_Overflow__c_src_char_cat_12_bad /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/3_PtrOffset_01.c:86:5
      #3 0x4c304c in main /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/3_PtrOffset_01.c:105:5
      #4 0x7f8a2584cbf6 in __libc_start_main /build/glibc-S9d2JN/glibc-2.27/csu/../csu/libc-start.c:310
  
  SUMMARY: AddressSanitizer: heap-buffer-overflow /home/brian/src/final/llvm-project/compiler-rt/lib/asan/asan_interceptors_memintrinsics.cpp:22:3 in __asan_memcpy
  Shadow bytes around the buggy address:
    0x0c0c7fff7fd0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x0c0c7fff7fe0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x0c0c7fff7ff0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x0c0c7fff8000: fa fa fa fa fd fd fd fd fd fd fd fa fa fa fa fa
    0x0c0c7fff8010: 00 00 00 00 00 00 03 fa fa fa fa fa 00 00 00 00
  =>0x0c0c7fff8020: 00 00[02]fa fa fa fa fa fa fa fa fa fa fa fa fa
    0x0c0c7fff8030: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
    0x0c0c7fff8040: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
    0x0c0c7fff8050: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
    0x0c0c7fff8060: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
    0x0c0c7fff8070: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  Shadow byte legend (one shadow byte represents 8 application bytes):
    Addressable:           00
    Partially addressable: 01 02 03 04 05 06 07 
    Heap left redzone:       fa
    Freed heap region:       fd
    Stack left redzone:      f1
    Stack mid redzone:       f2
    Stack right redzone:     f3
    Stack after return:      f5
    Stack use after scope:   f8
    Global redzone:          f9
    Global init order:       f6
    Poisoned by user:        f7
    Container overflow:      fc
    Array cookie:            ac
    Intra object redzone:    bb
    ASan internal:           fe
    Left alloca redzone:     ca
    Right alloca redzone:    cb
    Shadow gap:              cc
  ==5742==ABORTING
  ```

  

- `4_libFunction.c`

  **缺陷发生情景**：使用`memcpy`复制数据到字符串。

  **缺陷**：**库函数参数**不合理，如果`date`的长度大于`dest`的长度，可能会发生缓冲区溢出。

  **修补**：

  ```c
  memcpy(dest, data, strlen(dest)*sizeof(char));
  ```

  **使用`AddressSanitizer`进行分析**：

  ![image-20211109160452763](.\buffer_overflow.assets\image-20211109160452763.png)

  ```
  =================================================================
  ==5981==ERROR: AddressSanitizer: stack-buffer-overflow on address 0x7ffe8a4fbe32 at pc 0x00000049298a bp 0x7ffe8a4fbdd0 sp 0x7ffe8a4fb598
  READ of size 99 at 0x7ffe8a4fbe32 thread T0
      #0 0x492989 in __asan_memcpy /home/brian/src/final/llvm-project/compiler-rt/lib/asan/asan_interceptors_memintrinsics.cpp:22:3
      #1 0x4c3018 in CWE126_Buffer_Overread__char_declare_memcpy_01_bad /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/4_libFunction.c:62:9
      #2 0x4c317c in main /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/4_libFunction.c:84:5
      #3 0x7f2e9f078bf6 in __libc_start_main /build/glibc-S9d2JN/glibc-2.27/csu/../csu/libc-start.c:310
      #4 0x41adf9 in _start (/home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/4_libFunction+0x41adf9)
  
  Address 0x7ffe8a4fbe32 is located in stack of thread T0 at offset 82 in frame
      #0 0x4c2d0f in CWE126_Buffer_Overread__char_declare_memcpy_01_bad /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/4_libFunction.c:47
  
    This frame has 3 object(s):
      [32, 82) 'dataBadBuffer' (line 49)
      [128, 228) 'dataGoodBuffer' (line 50) <== Memory access at offset 82 partially underflows this variable
      [272, 372) 'dest' (line 57)
  HINT: this may be a false positive if your program uses some custom stack unwind mechanism, swapcontext or vfork
        (longjmp and C++ exceptions *are* supported)
  SUMMARY: AddressSanitizer: stack-buffer-overflow /home/brian/src/final/llvm-project/compiler-rt/lib/asan/asan_interceptors_memintrinsics.cpp:22:3 in __asan_memcpy
  Shadow bytes around the buggy address:
    0x100051497770: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x100051497780: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x100051497790: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x1000514977a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x1000514977b0: 00 00 00 00 00 00 00 00 00 00 00 00 f1 f1 f1 f1
  =>0x1000514977c0: 00 00 00 00 00 00[02]f2 f2 f2 f2 f2 00 00 00 00
    0x1000514977d0: 00 00 00 00 00 00 00 00 04 f2 f2 f2 f2 f2 00 00
    0x1000514977e0: 00 00 00 00 00 00 00 00 00 00 04 f3 f3 f3 f3 f3
    0x1000514977f0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x100051497800: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    0x100051497810: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  Shadow byte legend (one shadow byte represents 8 application bytes):
    Addressable:           00
    Partially addressable: 01 02 03 04 05 06 07 
    Heap left redzone:       fa
    Freed heap region:       fd
    Stack left redzone:      f1
    Stack mid redzone:       f2
    Stack right redzone:     f3
    Stack after return:      f5
    Stack use after scope:   f8
    Global redzone:          f9
    Global init order:       f6
    Poisoned by user:        f7
    Container overflow:      fc
    Array cookie:            ac
    Intra object redzone:    bb
    ASan internal:           fe
    Left alloca redzone:     ca
    Right alloca redzone:    cb
    Shadow gap:              cc
  ==5981==ABORTING
  ```

  

- `5_multiFlow.c`

  **缺陷发生场景**：使用循环将`twoIntsStruct`数组复制到数据。

  **缺陷**：分配数据到一个小的缓冲区，这个小的缓冲区比sink中使用的大的缓冲区要小。
  
  **使用`AddressSanitizer`进行分析**：
  
  ![image-20211109161713505](.\buffer_overflow.assets\image-20211109161713505.png)

```
=================================================================
==6369==ERROR: AddressSanitizer: heap-buffer-overflow on address 0x6140000001d0 at pc 0x000000492ad0 bp 0x7ffeb2da9bd0 sp 0x7ffeb2da9398
WRITE of size 8 at 0x6140000001d0 thread T0
    #0 0x492acf in __asan_memcpy /home/brian/src/final/llvm-project/compiler-rt/lib/asan/asan_interceptors_memintrinsics.cpp:22:3
    #1 0x4c3135 in CWE122_Heap_Based_Buffer_Overflow__c_CWE805_struct_loop_12_bad /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/5_multiFlow.c:89:27
    #2 0x4c321c in main /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/5_multiFlow.c:113:5
    #3 0x7f01c2191bf6 in __libc_start_main /build/glibc-S9d2JN/glibc-2.27/csu/../csu/libc-start.c:310
    #4 0x41ae89 in _start (/home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/5_multiFlow+0x41ae89)

0x6140000001d0 is located 0 bytes to the right of 400-byte region [0x614000000040,0x6140000001d0)
allocated by thread T0 here:
    #0 0x4935cd in malloc /home/brian/src/final/llvm-project/compiler-rt/lib/asan/asan_malloc_linux.cpp:145:3
    #1 0x4c2f9a in CWE122_Heap_Based_Buffer_Overflow__c_CWE805_struct_loop_12_bad /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/5_multiFlow.c:69:33
    #2 0x4c321c in main /home/mukyuuhate/Documents/cpp/test/hw-demos/buffer_overflow/5_multiFlow.c:113:5
    #3 0x7f01c2191bf6 in __libc_start_main /build/glibc-S9d2JN/glibc-2.27/csu/../csu/libc-start.c:310

SUMMARY: AddressSanitizer: heap-buffer-overflow /home/brian/src/final/llvm-project/compiler-rt/lib/asan/asan_interceptors_memintrinsics.cpp:22:3 in __asan_memcpy
Shadow bytes around the buggy address:
  0x0c287fff7fe0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c287fff7ff0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c287fff8000: fa fa fa fa fa fa fa fa 00 00 00 00 00 00 00 00
  0x0c287fff8010: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
  0x0c287fff8020: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
=>0x0c287fff8030: 00 00 00 00 00 00 00 00 00 00[fa]fa fa fa fa fa
  0x0c287fff8040: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c287fff8050: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c287fff8060: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c287fff8070: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
  0x0c287fff8080: fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa fa
Shadow byte legend (one shadow byte represents 8 application bytes):
  Addressable:           00
  Partially addressable: 01 02 03 04 05 06 07 
  Heap left redzone:       fa
  Freed heap region:       fd
  Stack left redzone:      f1
  Stack mid redzone:       f2
  Stack right redzone:     f3
  Stack after return:      f5
  Stack use after scope:   f8
  Global redzone:          f9
  Global init order:       f6
  Poisoned by user:        f7
  Container overflow:      fc
  Array cookie:            ac
  Intra object redzone:    bb
  ASan internal:           fe
  Left alloca redzone:     ca
  Right alloca redzone:    cb
  Shadow gap:              cc
==6369==ABORTING
```

