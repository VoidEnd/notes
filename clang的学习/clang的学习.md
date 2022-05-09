# clang指令学习

## 生成和链接静态库

- 生成静态库

  源文件add.c，静态库文件的命名规则是: `lib****.a`(将`****`替换成自定义名字)，将`add.cpp`编译成一个目标文件，然后打包成为一个静态库，具体操作如下:

  ```bash
  clang -c add.c				# 将目标文件add.c编译成目标文件add.o
  ar -r libadd.c add.o	# 使用ar指令将目标文件add.o打包为静态库文件libadd.a
  
  # -r︰添加或替换指定的文件到归档中;
  # ar -r libtest.a test.o
  # -V︰显示冗余的信息;
  # ar -rv libtest.a test.o
  # -t :按顺序显示归档中的文件名;
  # ar -t libtest.a
  # -d:从归档里删除指定的文件;
  # ar -d libtest.a test.o
  ```

- 生成动态库

  ```bash
  clang++ test.o -shared -fPIC -o libtest.so	# 生成一个动态库文件: libtest.so
  
  # -shared :表明生成的文件是动态库文件;
  # -fPIC:表明生成的动态库是位置独立的代码(Position-independent Code)
  # -o︰指定生成的文件名;
  ```

- 链接静态库/动态库

  生成完静态库了，然后该如何使用这个生成的静态库文件呢?看下面的具体操作:1.

  ```bash
  clang++ -c main.cpp								# 将main.cpp模块编译成为目标文件main.o
  clang++ main.o -L. -ladd -o main	# 将目标文件 main.o和静态库文件libadd.a链接成为可执行文件main
  ./main														# 运行可执行文件 main
  
  # -L.∶将当前目录添加至编译器库搜索目录中，如果动态库和静态库同时存在，会优先选择动态库;
  # -ladd:表示查找静态库名是:libadd.a或动态库名是: libadd.so的库文件进行链接，优先选择动态库;
  # Ldir:将dir添加编译器的库查找路径中，编译器默认仅仅搜索/usr/lib和/usr/local/lib这两个文件夹;
  # -lname :查找静态库名是: libname.a或动态库名是: libname.so的库文件进行链接，优先选择动态库;
  ```

## 基本指令

- [-g](https://clang.llvm.org/docs/UsersManual.html#cmdoption-g) —— 生成完整的调试信息
- 



# `makefile`文件

## 注意事项

- 只有要执行的命令前要加上`tab`，而且有的文本编辑器里的`tab`是四个空格，要格外注意，尽量用vim比较规范，且`/etc/vimrc`里不能设置`set expandtab`

- Juliet Test make报错：std_thread.c:(.text+0xae): undefined reference to `pthread_create‘，解决方法：

  ```
  修改Makefile下面这行（60行）：
  $(TARGET) : $(OBJECTS)
            $(CPP) $(LFLAGS) $(OBJECTS) -o $(TARGET)
  
  修改为：
  $(TARGET) : $(OBJECTS)
            $(CPP) $(OBJECTS) -o $(TARGET) $(LFLAGS)
  
  ```

- 批量编译带mem2reg选项的bc文件

  ```makefile
  AR=ar
  LD=ld
  CCPATH=
  CC=$(CCPATH)clang
  #CXX=$(CCPATH)clang++
  INC = -I./testcasesupport
  LIBS = -lm #-lpthread -lm -lstdc++
  CFLAGS = -emit-llvm -S -g -Xclang -disable-O0-optnone
  #注："\"后面不能有空格，并且该句写完后最好有个换行
  
  #注释部分推荐在单独的一行编写
  
  #只改下面几行变量值就够了
  #动态库需要 -fPIC  -shared
  
  SOFLAGS = #-O2 -fPIC -shared
  # Search paths
  VPATH =
  SRC_ROOT = .
  
  #这里递归遍历3级子目录
  DIRS := $(shell find $(SRC_ROOT) -type d)
  
  #这里循环遍历目录的cpp文件
  
  #CPPFILES := $(foreach dir,$(DIRS),$(wildcard $(dir)/*.cpp))
  CFILES += $(foreach dir,$(DIRS),$(wildcard $(dir)/*.c))
  LLFILES += $(foreach dir,$(DIRS),$(wildcard $(dir)/*.ll))
  CBCFILES += $(foreach dir,$(DIRS),$(wildcard $(dir)/*.bc))
  
  #定义宏
  DEF = #-DLINUX -DENABLE_EPOLL
  
  #CPPLLS := $(patsubst %.cpp,%.ll, $(CPPFILES))
  CLLS := $(patsubst %.c,%.ll, $(CFILES))
  BCFILES := $(patsubst %.c,%.bc, $(CFILES))
  MEM2REGFILES := $(patsubst %.c,%_mem2reg.ll, $(CFILES))
  
  
  
  all:$(CLLS) $(BCFILES) $(MEM2REGFILES) $(LOGFILES)
  
  $(CLLS):%.ll:%.c
  	$(CC) $(CFLAGS) $< $(LLVMFLAGS) $(INC) -o $@ 
  
  $(BCFILES):%.bc:%.ll
  	opt -mem2reg  $^ -o $@
  
  $(MEM2REGFILES):%_mem2reg.ll:%.bc
  	llvm-dis $^  -o $@
  
  
  .PHONY: clean
  clean:
  	rm -rf $(LLFILES) $(CBCFILES)
  
  ```

  

- 



# `CMake`

`CMakeLists`文件 —— `cmake` —— `make`

## `CMakeLists`文件

### [Embedding LLVM in your project](https://llvm.org/docs/CMake.html#id17)

```cmake
cmake_minimum_required(VERSION 3.13.4)
project(SimpleProject)

find_package(LLVM REQUIRED CONFIG)

message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

# Set your project compile flags.
# E.g. if using the C++ header files
# you will need to enable C++11 support
# for your compiler.

include_directories(${LLVM_INCLUDE_DIRS})
separate_arguments(LLVM_DEFINITIONS_LIST NATIVE_COMMAND ${LLVM_DEFINITIONS})
add_definitions(${LLVM_DEFINITIONS_LIST})

# Now build our tools
add_executable(simple-tool tool.cpp)

# Find the libraries that correspond to the LLVM components
# that we wish to use
# llvm_map_components_to_libnames(llvm_libs support core irreader)

# Link against LLVM libraries
# target_link_libraries(simple-tool ${llvm_libs})
target_link_libraries(simple-tool LLVM)
```



### 调试

```cmake
SET(CMAKE_BUILD_TYPE "Debug")
SET(CMAKE_CXX_FLAGS_DEBUG "$ENV{CXXFLAGS} -O0 -Wall -g2 -ggdb")
SET(CMAKE_CXX_FLAGS_RELEASE "$ENV{CXXFLAGS} -O3 -Wall")
```

### 问题

- "Duplicate option categories"' failed. 重复选项类别，一点要注意，依赖库不要重复。

  可能原因是比如cl::opt 的工作方式从根本上不能很好地与共享库配合使用。

  ```
  CommandLine Error: Option 'debug' registered more than once!
  LLVM ERROR: inconsistency in registered CommandLine options
  ```

- 



## `VScode` `cmake`配置

- `${workspaceFolder}`是当前工作空间（或`vscode`所打开根文件夹）在操作系统中绝对路径
-  `${workspaceFolderBasename}`是当前工作空间（或`vscode`所打开根文件夹）的名称

在`VScode`底部依次运行，`cmake`，`build`，`debug`，其中将`[all]`切换为想要进行`debug`的可执行文件

### `task.json`

`tasks.json` 这是`VSCode`任务的配置文件，通过配置它可以快速执行各种命令。这里我们利用它来配置**编译构建流程**。我们要执行的任务为**建立build文件夹，在build文件夹中使用`CMake`生成并编译**。通过这个任务配置，**统一全平台下的程序编译命令**。

```json
{
    // See https://go.microsoft.com/fwlink/?LinkId=733558
    // for the documentation about the tasks.json format
    "version": "2.0.0",
    "tasks": [
        { // 在根文件夹中执行创建文件夹build的命令
            // 除windows系统外执行的命令为`mkdir -p build`
            // windows系统是在powershell中执行命令`mkdir -Force build`
            "label": "build_dir",
            "command": "mkdir",
            "type": "shell",
            "args": [
                "-p",
                "build"
            ],
            "windows": {
                "options": {
                    "shell": {
                        "executable": "powershell.exe"
                    }
                },
                "args": [
                    "-Force",
                    "build"
                ],
            }
        },
        { // 在build文件夹中调用cmake进行项目配置
            // 除windows系统外执行的命令为`cmake -DCMAKE_BUILD_TYPE=<Debug|Release|RelWithDebInfo|MinSizeRel> ../`
            // windows系统是在visual stuido的环境中执行命令`cmake -DCMAKE_BUILD_TYPE=<Debug|Release|RelWithDebInfo|MinSizeRel>  ../ -G "CodeBlocks - NMake Makefiles"`
            "label": "cmake",
            "type": "shell",
            "command": "cmake",
            "args": [
                "-DCMAKE_BUILD_TYPE=${input:CMAKE_BUILD_TYPE}",
                "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON", // 生成compile_commands.json 供c/c++扩展提示使用
                "../"
            ],
            "options": {
                "cwd": "${workspaceFolder}/src/build",
            },
            "windows": {
                "args": [
                    "-DCMAKE_BUILD_TYPE=${input:CMAKE_BUILD_TYPE}",
                    "-DCMAKE_EXPORT_COMPILE_COMMANDS=ON",
                    "../",
                    "-G",
                    "\"CodeBlocks - NMake Makefiles\""
                ],
                "options": {
                    "shell": {
                        // "executable": "C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\vcvarsall.bat",
                        // 需要根据安装的vs版本调用vs工具命令提示符
                        "executable": "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Auxiliary\\Build\\vcvarsall.bat",
                        "args": [
                            "${input:PLATFORM}", //指定平台
                            "-vcvars_ver=${input:vcvars_ver}", //指定vc环境版本
                            "&&"
                        ]
                    }
                },
            },
            "dependsOn": [
                "build_dir" // 在task `build_dir` 后执行该task
            ]
        },
        { // 在build文件夹中调用cmake编译构建debug程序
            // 执行的命令为`cmake --build ./ --target all --`
            //  windows系统如上需要在visual stuido的环境中执行命令
            "label": "build",
            "group": "build",
            "type": "shell",
            "command": "cmake",
            "args": [
                "--build",
                "./",
                "--target",
                "all",
                "--"
            ],
            "options": {
                "cwd": "${workspaceFolder}/src/build",
            },
            "problemMatcher": "$gcc",
            "windows": {
                "options": {
                    "shell": {
                        // "executable": "C:\\Program Files (x86)\\Microsoft Visual Studio 12.0\\VC\\vcvarsall.bat",
                        "executable": "C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\Community\\VC\\Auxiliary\\Build\\vcvarsall.bat",
                        "args": [
                            "${input:PLATFORM}",
                            "-vcvars_ver=${input:vcvars_ver}",
                            "&&"
                        ]
                    }
                },
                "problemMatcher": "$msCompile"
            },
            "dependsOn": [
                "cmake" // 在task `cmake` 后执行该task
            ]
        }
    ],
    "inputs": [
        {
            "id": "CMAKE_BUILD_TYPE",
            "type": "pickString",
            "description": "What CMAKE_BUILD_TYPE do you want to create?",
            "options": [
                "Debug",
                "Release",
                "RelWithDebInfo",
                "MinSizeRel",
            ],
            "default": "Debug"
        },
        {
            "id": "PLATFORM",
            "type": "pickString",
            "description": "What PLATFORM do you want to create?",
            "options": [
                "x86",
                "amd64",
                "arm",
                "x86_arm",
                "x86_amd64",
                "amd64_x86",
                "amd64_arm",
            ],
            "default": "amd64"
        },
        {
            "id": "vcvars_ver",
            "type": "pickString",
            "description": "What vcvars_ver do you want to create?",
            "options": [
                "14.2", // 2019
                "14.1", // 2017
                "14.0", // 2015
            ],
            "default": "14.2"
        }
    ]
}

```

### `launch.json`

`launch.json` 这是`VSCode`运行调试的配置文件。**全平台统一的调试体验**就靠它了。依赖于`VSCode`的`C/C++`扩展。这里需要告诉`VSCode`你的**`C/C++`程序在哪**，以及**运行参数**，**工作目录**等，**用哪个调试器调试**。

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [

        {
            "name": "(gdb) Launch",
            "type": "cppdbg",
            "request": "launch",
            // Resolved by CMake Tools:
            "program": "${workspaceFolder}/${command:cmake.launchTargetPath}",
            "args": [],
            "stopAtEntry": false,
            "cwd": "${workspaceFolder}",
            "environment": [],
            "externalConsole": true,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Enable pretty-printing for gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                }
            ]
        }
    ]
}
```

### `c_cpp_properties.json`

```json
{
    "configurations": [
        {
            "name": "Linux",
            // 头文件地址
            "includePath": [
                "${workspaceFolder}/**",
                "/home/mukyuu/Downloads/BufferOverflow_RangeAnalysis/LLVM-10.0.0/build/bin"
            ],
            "defines": [],
            "compilerPath": "/home/mukyuu/Downloads/BufferOverflow_RangeAnalysis/LLVM-10.0.0/build/bin/clang",
            "cStandard": "c11",
            "cppStandard": "c++14",
            "intelliSenseMode": "linux-clang-x64",
            "configurationProvider": "ms-vscode.cmake-tools"
        }
    ],
    "version": 4
}
```



## `cmake`设置生成文件的位置

1. `CMAKE_ARCHIVE_OUTPUT_DIRECTORY`：默认存放静态库的文件夹位置；
2. `CMAKE_LIBRARY_OUTPUT_DIRECTORY`：默认存放动态库的文件夹位置；
3. `LIBRARY_OUTPUT_PATH`：默认存放库文件的位置，如果产生的是静态库并且没有指定 CMAKE_ARCHIVE_OUTPUT_DIRECTORY 则存放在该目录下，动态库也类似；
4. `CMAKE_RUNTIME_OUTPUT_DIRECTORY`：存放可执行软件的目录；

```cmake
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/archive)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/library)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/runtime)
set(LIBRARY_OUTPUT_PATH ${CMAKE_SOURCE_DIR}/path)
```



# 调试工具

`gdb`和`lldb`

## `lldb`

[官方文档](https://lldb.llvm.org/use/tutorial.html)

版本需要6.0

### 常用指令

```text
break (b) - 设置断点，也就是程序暂停的地方
run (r) - 启动目标程序，如果遇到断点则暂停
step (s) - 进入下一条指令中的函数内部
backtrace (bt) - 显示当前的有效函数
frame (f) - 默认显示当前栈的内容，可以通过 frame arg 进入特定的 frame（用作输出本地变量）
next (n) - 运行当前箭头指向行
continue (c) - 继续运行程序直到遇到断点。
```



## `gdb`

[官方文档](http://www.gnu.org/software/gdb/documentation/)

### 常用指令

```bash
help：查看命令帮助，具体命令查询在gdb中输入help + 命令,简写h
run：重新开始运行文件（run-text：加载文本文件，run-bin：加载二进制文件）,简写r
start：单步执行，运行程序，停在第一执行语句
list：查看原代码（list-n,从第n行开始查看代码。list+ 函数名：查看具体函数）,简写l
set：设置变量的值
next：单步调试（逐过程，函数直接执行）,简写n
step：单步调试（逐语句：跳入自定义函数内部执行）,简写s
backtrace：查看函数的调用的栈帧和层级关系,简写bt
frame：切换函数的栈帧,简写f
info：查看函数内部局部变量的数值,简写i
finish：结束当前函数，返回到函数调用点
continue：继续运行,简写c
print：打印值及地址,简写p
quit：退出gdb,简写q

break+num：在第num行设置断点,简写b
info breakpoints：查看当前设置的所有断点
delete breakpoints num：删除第num个断点,简写d
display：追踪查看具体变量值
undisplay：取消追踪观察变量
watch：被设置观察点的变量发生修改时，打印显示
i watch：显示观察点
enable breakpoints：启用断点
disable breakpoints：禁用断点
x：查看内存x/20xw 显示20个单元，16进制，4字节每单元
run argv[1] argv[2]：调试时命令行传参

如要查看所有的gdb命令，可以在gdb下键入两次Tab(制表符)，运行“help command”可以查看命令command的详细使用格式。
```



# clang static analyzer

## 简介

[Clang Static Analyzer](https://clang-analyzer.llvm.org/) 是一个工业级的静态源码检测工具，可以用来发现 C、C++ 和 Objective-C 程序中的 Bug。它既可以作为一个独立工具（`scan-build`）使用，也可以集成在 Xcode 中使用。

Clang Static Analyzer 建立在 [Clang](https://translate.googleusercontent.com/translate_c?depth=1&hl=en&ie=UTF8&prev=_t&rurl=translate.google.com&sl=en&sp=nmt4&tl=zh-CN&u=http://clang.llvm.org/&xid=25657,15700022,15700124,15700149,15700186,15700191,15700201,15700214,15700230&usg=ALkJrhj9knBnTdXjPrAgXaC9z2j7dV8gtw) 和 [LLVM](https://translate.googleusercontent.com/translate_c?depth=1&hl=en&ie=UTF8&prev=_t&rurl=translate.google.com&sl=en&sp=nmt4&tl=zh-CN&u=http://llvm.org/&xid=25657,15700022,15700124,15700149,15700186,15700191,15700201,15700214,15700230&usg=ALkJrhjIJQVcd1RzZDUK95Dk6dujPHquDQ) 之上。严格地讲，它是 Clang 的一部分，因此它是完全开源的。Clang Static Analyzer 使用的静态分析引擎被实现为一个 C++ 库，可以在不同的客户端中重用，因此拥有很高的可扩展性。

### 简单使用

`scan-build` 就是 Clang Static Analyzer 的命令行工具。

注意：`scan-build` 会使用 `clang/clang++` 做 analyzer，即便指定编译器为 `gcc/g++`。

```c
// memleak.c
#include<stdio.h>
#include<stdlib.h>

int main(int argc, const char* argv[]) {
 void* ptr = malloc(sizeof(char));
 free(ptr);
 memset(ptr, 0, sizeof(char) * 2);
 return 0;
}
```

```bash
scan-build -o memleak gcc memleak.c
#上述命令即对 memleak.c 进行检测，其中 -o 参数用于指定检测结果存放路径，检测结果会以 html 文件的形式保存

scan-build --use-cc gcc --use-c++ g++ make
# 更好的方式是将 scan-build 直接与构建系统串接起来一起协同工作
```

# kint

## 简介

KINT是一个使用可伸缩静态分析来检测C程序中整数错误的工具。

- 论文： Improving Integer Security for Systems with KINT 
- 会议：OSDI2012
- static analysis , detect integer errors
- 主页：http://css.csail.mit.edu/kint/

<img src="/Users/mukyuuhate/Documents/GitHub/notes/clang的学习/clang的学习.assets/image-20211107235143069.png" alt="image-20211107235143069" style="zoom:60%;" />

Kint在LLVM bitcode上工作。分析一个软件项目，第一步是生成LLVM bitcode。Kint提供了一个名为`kint-build`的脚本，它调用`gcc`（或`g++`）并同时使用Clang从你的源代码中获取LLVM bitcode，并储存到`.ll`文件。例如：

```bash
$ cd /path/to/your/project
$ kint-build make
```

## 整数溢出检查

要查找整数溢出，您可以首先对生成的LLVM bitcode（`.ll`文件）运行Kint的全局分析，以生成一些将减少后续分析步骤中的误报的整个程序约束。这一步是可选的，如果它不能工作（例如，由于一些bug），你可以跳过它继续下一步。

这个全局分析将其输出写回LLVM bitcode`.ll`文件，因此它不产生终端输出(除非指定`-v`标志)。在我们的例子中，你可以像下面这样运行全局分析:

```bash
$ find . -name "*.ll" > bitcode.lst
$ intglobal @bitcode.lst
$ intglobal ./test01.ll
```

最后，在项目目录中运行以下命令：

```bash
$ pintck
```

你可以在 "pintck.txt" 中找到错误报告。

### Taint 注释

为了帮助您关注高风险报告，全局分析执行**taint analysis**，标记从生成的LLVM bitcode中不受信任的输入导出的值。你可以通过在目标软件的源代码中注释这个内在函数来告诉Kint什么是**taint source**：

```c
int __kint_taint(const char *description, value, ...);
```

Kint将第二个参数（值）标记为**taint source**。`value`可以是任何整数或指针类型。如果使用`__kint_taint()`的返回值，也会被认为是一个污点。

例如，对于Linux内核，我们重新定义了宏`copy_from_user()`和`get_user()`，如下所示：

```c
#define copy_from_user(to, from, n) \
	__kint_taint("copy_from_user", (to), from, n)
#define get_user(x, ptr) \
	({ (x) = *(ptr); __kint_taint("get_user", (x)); })
```

要注释敏感上下文（taint sinks，比如分配大小），你应该在Kint的`src/Annotation.cc`中更改`annotateSink()`。`Allocs`数组中的每一对都指定了一个函数名和它的参数中哪个是敏感的。如果Kint发现这份报告的value被玷污或溢出，达到了这种说法，他会强调这份报告。

您可以获得我们的注释linux内核源代码如下:

```bash
$ git clone -b kint git://g.csail.mit.edu/kint-linux
```

## 同义反复的对比检查

重复的控制流决策(例如，总是采取或从未采取的分支)通常是错误的指示。要找到它们，只需在项目目录中运行以下命令。

```bash
$ pcmpck
```

你可以在 "pcmpck.txt" 中找到错误报告。

## range analysis

功能：推断一个值的范围

range计算：

<img src="/Users/mukyuuhate/Documents/GitHub/notes/clang的学习/clang的学习.assets/image-20211101170850640.png" alt="image-20211101170850640" style="zoom:50%;" />

KINT的范围分析推断了跨多个函数（即函数参数、返回值、全局变量和结构字段）的值的可能范围。

```
One limitation of per-function analysis is that it cannot capture invariants that hold across functions. Generating constraints based on an entire large system such as the Linux kernel could lead to more accurate error reports, but constraint solvers cannot scale to such large constraints. To achieve more accurate error reports while still scaling to large systems such as the Linux kernel, KINT employs a specialized strategy for capturing certain kinds of cross-function invariants. In particular, KINT’s range analysis infers the possible ranges of values that span multiple functions (i.e., function parameters, return values, global variables, and structure fields). For example, if the value of a parameter x ranges from 1 to 10, KINT generates the range x ∈ [1,10]. 
KINT keeps a range for each cross-function entity in a global range table. Initially, KINT sets the ranges of untrusted entities (i.e., the programmer-annotated sources described in §5.2) to full sets and the rest to empty. Then it updates ranges iteratively, until the ranges converge, or sets the ranges to full after a limited number of rounds. 
The iteration works as follows. KINT scans through every function of the entire code base. When encountering accesses to a cross-function entity, such as loads from a structure field or a global variable, KINT retrieves the entity’s value range from the global range table. Within a function, KINT propagates value ranges using range arithmetic [18]. When a value reaches an external sink through argument passing, function returns, or stores to structure fields or global variables, the corresponding range table entry is updated by merging its previous range with the range of the incoming value. 
To propagate ranges across functions, KINT requires a system-wide call graph. To do so, KINT builds the call graph iteratively. For each indirect call site (i.e., function pointers), KINT collects possible target functions from initialization code and stores to the function pointer. 
KINT’s range analysis assumes strict-aliasing rules; that is, one memory location cannot be accessed as two different types (e.g., two different structs). Violations of this assumption can cause the range analysis to generateincorrect ranges.
After the range table converges or (more likely) a fixed number of iterations, the range analysis halts and outputs its range table, which will be used by constraint generation to generate more precise constraints for the solver.

单函数分析的一个限制是它不能捕获跨函数持有的不变量。基于整个大型系统(如Linux内核)生成约束可能导致更准确的错误报告，但约束求解器无法扩展到如此大的约束。为了实现更准确的错误报告，同时仍然可以扩展到Linux内核这样的大型系统，KINT采用了一种专门的策略来捕获某些类型的跨函数不变量。特别地，KINT的范围分析推断跨多个函数的值的可能范围(即，函数参数、返回值、全局变量和结构字段)。例如，当参数x的取值范围为1 ~ 10时，KINT生成的范围为x∈[1,10]。
KINT在全局范围表中为每个跨函数实体保留一个范围。最初，KINT将不可信实体(即§5.2中描述的程序员注释的源)的范围设置为完整集，其余的设置为空。然后迭代更新范围，直到范围收敛，或者在有限的轮数之后将范围设置为满。
迭代的工作方式如下。KINT扫描整个代码库的每个函数。当遇到对跨功能实体的访问时，比如从结构字段或全局变量加载时，KINT从全局范围表中检索实体的值范围。在函数中，KINT使用范围算术[18]传播值范围。当一个值通过传递参数、函数返回或存储到结构字段或全局变量而到达外部接收器时，相应的范围表项将通过合并之前的范围和传入值的范围来更新。
为了跨函数传播范围，KINT需要一个系统范围的调用图。为此，KINT以迭代的方式构建调用图。对于每个间接调用点(即函数指针)，KINT从初始化代码中收集可能的目标函数并存储到函数指针中。
KINT的范围分析采用了严格的混叠规则;也就是说，一个内存位置不能作为两种不同的类型被访问(例如，两个不同的结构体)。违反这个假设会导致范围分析生成不正确的范围。
在范围表收敛或(更有可能)固定的迭代次数后，范围分析停止并输出它的范围表，约束属将使用它为求解器生成更精确的约束。
```

# `AddressSanitizer`

`AddressSanitizer`是一个内存检查工具，可以定位越界访问，也可以进行内存泄露检查功能。

## 可检测内存错误

- Use after free：访问堆上已经被释放的内存
- Heap buffer overflow：堆上缓冲区访问溢出
- Stack buffer overflow：栈上缓冲区访问溢出
- Global buffer overflow：全局缓冲区访问溢出
- Use after return：访问栈上已被释放的内存
- Use after scope：栈对象使用超过定义范围
- Initialization order bugs：初始化命令错误
- Memory leaks：内存泄漏

## 指令：

```bash
-fsanitize=address   			#开启地址越界检查功能
-fno-omit-frame-pointer	  #开启后，可以出界更详细的错误信息
-fsanitize=leak  					#开启内存泄露检查功能
```

