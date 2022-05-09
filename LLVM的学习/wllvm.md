可以使用WLLVM项目来获取LLVM Bitcode

github链接：https://github.com/travitch/whole-program-llvm

# WLLVM使用

## 1 获取whole-program-llvm

```bash
git clone https://github.com/travitch/whole-program-llvm.git
```

该步骤在当前工作目录下获取该github项目名为whole-program-llvm的文件夹，如果工作目录非home,需要有管理员权限，在命令前加上sudo即可

## 2 文件夹简单介绍

该项目使用python编写，所以在装有python的系统下面是可直接执行的，不需要安装等步骤

主要关注的有4个文件：

1. wllvm这是将系统默认C编译器替换成LLVM前端clang或llvm-gcc的工具
2. wllvm++是将系统默认C++编译器替换成LLVM前端clang++或llvm-g++的工具

3. extract-bc是从由wllvm编译生成的可执行文件获取LLVM Bitcode的工具

4. wllvm-sanity-checker 查看wllvm的一些环境变量的设置

## 3 如何使用

为了使用方便，我们将whole-program-llvm目录添加到系统环境变量PATH中，这样就可直接通过wllvm、wllvm++、extract-bc和wllvm-sanity-checker命令直接使用这些工具了，方法是多样的。

我的方法是，首先在~/.bashrc文件末中添加下面的命令

```bash
export PATH=/path/to/whole-program-llvm:$PATH
```

注意/path/to/whole-program-llvm是你的whole-program-llvm目录，然后在shell里面执行下面的命令

```bash
$ source ~/.bashrc
```

### 3.1 介绍一些wllvm的环境变量

- LLVM_COMPILER：指定LLVM使用的C/C++编译器，有两个选择clang或dragonegg
- LLVM_GCC_PREFIX：应该设为gcc版本的前缀，如llvm-gcc就应设为llvm-,该变量应该和dragonegg插件一起使用，如果环境变量LLVM_COMPILER=clang，那么可以不用设置该变量

- LLVM_DRAGONEGG_PLUGIN：插件dragonegg的目录，同上，如果环境变量LLVM_COMPILER=clang，那么可以不用设置该变量

- LLVM_CC_NAME：有时候安装的编译器的名字不是clang而是clang-3.4，那么该变量就应该设为clang-3.4。需要注意的是，使用clang作为编译器时，即使编译器的名字是clang-3.4，LLVM_COMPILER变量也应设为clang。llvm-gcc的情况类似。

- 其他环境变量LLVM_COMPILER_PATH和WLLVM_CONFIGUER_ONLY、WLLVM_OUTPUT等看文档了解一下就行了


### 3.2 使用wllvm编译coreuitls并获取LLVM Bitcode

```bash
export LLVM_COMPILER=clang
export WLLVM_OUPUT=DEBUG
cd /path/to/coreutils-6.11/obj-llvm/
CC=wllvm CXX=wllvm++ ../configure --disable-nls CFLAGS="-g"
# 如果在makefile文件里对CC和CXX进行过定义则需要按上一行进行修改 

#进行这一步时曾遇到报错情况，报错信息为
#**C compiler cannot create executables**，
#查看config.log显示
#**wllvm: command not found**
#网上搜解决方案时得到灵感是权限问题，我原来的工作目录是在/usr/local
#后来把工作目录改为/home/user问题就没有了

···在新的工作目录里面，前面的命令一样···
CC=wllvm CXX=wllvm++ make
···工作正常，没有报错···

#找到你要获取LLVM Bitcode的可执行文件，coreutils在src目录下
cd /path/to/coreutils-6.11/obj-llvm/src
#例如要获取cat的LLVM Bitcode
extract-bc cat
#在当前目录下出现一个cat.bc文件即为cat的LLVM Bitcode
```

# 总结

这里我并没有解释wllvm是怎样获取到LLVM Bitcode的，其原理可以查看官方文档