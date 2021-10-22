; ModuleID = 'test.ll'
source_filename = "test.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

define dso_local i32 @main() {
entry:
  %retval = alloca i32, align 4
  %sum = alloca i32, align 4
  %limit = alloca i32, align 4
  %i = alloca i32, align 4
  store i32 0, i32* %retval, align 4
  store i32 0, i32* %sum, align 4
  store i32 12, i32* %limit, align 4
  store i32 0, i32* %i, align 4
  %0 = load i32, i32* %limit, align 4
  %sub = sub nsw i32 %0, 2
  %i.promoted = load i32, i32* %i, align 4
  %sum.promoted = load i32, i32* %sum, align 4
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %add2 = phi i32 [ %add, %for.inc ], [ %sum.promoted, %entry ]
  %inc1 = phi i32 [ %inc, %for.inc ], [ %i.promoted, %entry ]
  %cmp = icmp slt i32 %inc1, %sub
  br i1 %cmp, label %for.body, label %for.end

for.body:                                         ; preds = %for.cond
  %add = add nsw i32 %add2, %inc1
  br label %for.inc

for.inc:                                          ; preds = %for.body
  %inc = add nsw i32 %inc1, 1
  br label %for.cond

for.end:                                          ; preds = %for.cond
  %add2.lcssa = phi i32 [ %add2, %for.cond ]
  %inc1.lcssa = phi i32 [ %inc1, %for.cond ]
  store i32 %inc1.lcssa, i32* %i, align 4
  store i32 %add2.lcssa, i32* %sum, align 4
  ret i32 0
}

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.0 "}
