# buffer_overflow_range_analysis

## range_test

### test01

----------------------

```c
#include <stdio.h>
#include <stdlib.h>

int a = 0;
int b[2] = {1,2};
int foo(){
    b[2] = 5;
    return 0;
}

int i = 0;
int main()
{
    b[1] = 0;
    foo();
    for(; i < 3; i++)
        b[i] = i;
    return 0;
}

PA (Using pointer analysis to reslove indirect calls) 
#Total Callsites: 1
#Total Indirect Callsites: 0
#Resolved Indirect Callsites: 0
#Total Number of ICS targets: 0
main.arrayidx full-set
main.retval [0,1)
ret.foo [0,1)
ret.main [0,1)
var.a [0,1)
var.i full-set
#############################################
	      Array Bound Checks Pass          
#############################################
[GEP instruction detected]
  i32* getelementptr inbounds ([2 x i32], [2 x i32]* @b, i64 1, i64 0)
    ****************************************
      Array Access Violation detected!
      Array index: 2 >= Array size: 2
    ***************************************

[GEP instruction detected]
  i32* getelementptr inbounds ([2 x i32], [2 x i32]* @b, i64 0, i64 1)
    No Violation. Array size: 2, Access index: 1

[GEP instruction detected]
    %arrayidx = getelementptr inbounds [2 x i32], [2 x i32]* @b, i64 0, i64 %idxprom, !dbg !33
      KintID:var.i
    ****************************************
      Array Access Violation detected!
      Array index: full-set >= Array size: 2
    ***************************************
```

### test02

```c
#include <stdio.h>
#include <stdlib.h>

int a;
int c = 0;
int foo(int a,int b){
    return 1;
}

int main(){
    int b = rand() % 5;
    if(b < 3)
        a = 8;
        c = foo(a, b);
    a = 0;
    
    return 0;
}

----------------------
PA (Using pointer analysis to reslove indirect calls) 
#Total Callsites: 2
#Total Indirect Callsites: 0
#Resolved Indirect Callsites: 0
#Total Number of ICS targets: 0
arg.foo.0 [0,9)
arg.foo.1 [5,6)
foo.a.addr [0,9)
foo.b.addr [5,6)
main.b [5,6)
main.retval [0,1)
ret.foo [1,2)
ret.main [0,1)
var._test02.a [0,9)
var.c [0,2)
#############################################
	      Array Bound Checks Pass          
#############################################

```



### test03

```c
#include <stdio.h>
#include <stdlib.h>

int a;

int main(){
    int b = rand() % 5;
    if(b < 3)
        a = 8;
    else
        a = 0;
}

----------------------
PA (Using pointer analysis to reslove indirect calls) 
#Total Callsites: 1
#Total Indirect Callsites: 0
#Resolved Indirect Callsites: 0
#Total Number of ICS targets: 0
main.b [5,6)
main.retval [0,1)
ret.main [0,1)
var._test03.a [0,9)
#############################################
	      Array Bound Checks Pass          
#############################################
```

​    

### test04

```c
#include <stdio.h>
#include <stdlib.h>

int a = 0;

int main(){
    for(a = 0; a < 2; a++){
        a++;
    }
    return 0;
}

----------------------
PA (Using pointer analysis to reslove indirect calls) 
#Total Callsites: 0
#Total Indirect Callsites: 0
#Resolved Indirect Callsites: 0
#Total Number of ICS targets: 0
main.retval [0,1)
ret.main [0,1)
var.a full-set
#############################################
	      Array Bound Checks Pass          
#############################################
```



### test05

```c
#include <stdio.h>
#include <stdlib.h>

int a = 0;
int foo(int a){
    return a + 1;
}

int main(){
    foo(a);
    return 0;
}

----------------------
PA (Using pointer analysis to reslove indirect calls) 
#Total Callsites: 1
#Total Indirect Callsites: 0
#Resolved Indirect Callsites: 0
#Total Number of ICS targets: 0
arg.foo.0 [0,1)
foo.a.addr [0,1)
main.retval [0,1)
ret.foo [1,2)
ret.main [0,1)
var.a [0,1)
#############################################
	      Array Bound Checks Pass          
#############################################
```



### test06

```c
#include <stdio.h>
#include <stdlib.h>

int a = 12;
int b = 2;
int c = 3;

int main(){
    a = 6;
    b = 4;
    c = a % b;
    return 0;
}

----------------------
PA (Using pointer analysis to reslove indirect calls) 
#Total Callsites: 0
#Total Indirect Callsites: 0
#Resolved Indirect Callsites: 0
#Total Number of ICS targets: 0
main.retval [0,1)
ret.main [0,1)
var.a [6,13)
var.b [2,5)
var.c [2,5)
#############################################
	      Array Bound Checks Pass          
#############################################
```

# Improving Integer Security for Systems with KINT

