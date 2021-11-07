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

<img src="D:\git_repository\buffer_overflow.assets\image-20211107200741832.png" alt="image-20211107200741832" style="zoom:50%;" />

<img src="D:\git_repository\buffer_overflow.assets\image-20211107200721650.png" alt="image-20211107200721650" style="zoom:50%;" />

## hw_demo

- `1_IOTOBO.c`

  缺陷发生情景：尝试使用来自键入的长度值分配数组。

  潜在的缺陷：如果`data * sizeof(int) > SIZE_MAX`，则会出现溢出。因此进行初始化的for循环导致缓冲区溢出 。

  <img src="D:\git_repository\buffer_overflow.assets\image-20211106164301191.png" alt="image-20211106164301191" style="zoom:60%;" />

  <img src="D:\git_repository\buffer_overflow.assets\image-20211106164333622.png" alt="image-20211106164333622" style="zoom:60%;" />

  <img src="D:\git_repository\buffer_overflow.assets\image-20211106165212139.png" alt="image-20211106165212139" style="zoom:80%;" />

  

- `2_ArrayIndex.c`

  缺陷发生情景：使用循环将数据复制到字符串。

  在`wmenset`中的缺陷：将数据初始化为一个比循环中使用的小缓冲区更大的大缓冲区。

  潜在缺陷：如果`date`的长度大于`dest`的长度，可能会发生缓冲区溢出。

  

- `3_PtrOffset.c` and `3_Ptroffset_01.c`

  缺陷发生情景：使用`strcat`将数据复制到字符串。

  缺陷：使用更大的缓存为小缓冲区赋值。

  

- `4_libFunction.c`

  缺陷发生情景：使用`memcpy`复制数据到字符串。

  缺陷：如果`date`的长度大于`dest`的长度，可能会发生缓冲区溢出。

  修补：

  ```c
  memcpy(dest, data, strlen(dest)*sizeof(char));
  ```

  

- `5_multiFlow.c`

  缺陷发生场景：使用循环将`twoIntsStruct`数组复制到数据。

  缺陷：分配和指向数据到一个小的缓冲区，这个小的缓冲区比sink中使用的大的缓冲区要小。



