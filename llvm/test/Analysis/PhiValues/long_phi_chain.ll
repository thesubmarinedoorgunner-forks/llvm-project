; RUN: opt < %s -passes='print<phi-values>' -disable-output 2>&1 | FileCheck %s

; This test uses a long chain of phis that take themselves as an operand, which causes
; phi values analysis to segfault if it's not careful about that kind of thing.

; CHECK-LABEL: PHI Values for function: fn
define void @fn(ptr %arg, i1 %arg1) {
entry:
  br label %while1.cond

while1.cond:
; CHECK: PHI %phi1 has values:
; CHECK: ptr %arg
  %phi1 = phi ptr [ %arg, %entry ], [ %phi2, %while1.then ]
  br i1 %arg1, label %while1.end, label %while1.body

while1.body:
  br i1 %arg1, label %while1.then, label %while1.if

while1.if:
  br label %while1.then

while1.then:
; CHECK: PHI %phi2 has values:
; CHECK: ptr %arg
  %phi2 = phi ptr [ %arg, %while1.if ], [ %phi1, %while1.body ]
  br label %while1.cond

while1.end:
  br label %while2.cond1

while2.cond1:
; CHECK: PHI %phi3 has values:
; CHECK: ptr %arg
  %phi3 = phi ptr [ %phi1, %while1.end ], [ %phi5, %while2.then ]
  br i1 %arg1, label %while2.end, label %while2.body1

while2.body1:
  br i1 %arg1, label %while2.cond2, label %while2.then

while2.cond2:
; CHECK: PHI %phi4 has values:
; CHECK: ptr %arg
  %phi4 = phi ptr [ %phi3, %while2.body1 ], [ %phi4, %while2.if ]
  br i1 %arg1, label %while2.then, label %while2.if

while2.if:
  br label %while2.cond2

while2.then:
; CHECK: PHI %phi5 has values:
; CHECK: ptr %arg
  %phi5 = phi ptr [ %phi3, %while2.body1 ], [ %phi4, %while2.cond2 ]
  br label %while2.cond1

while2.end:
  br label %while3.cond1

while3.cond1:
; CHECK: PHI %phi6 has values:
; CHECK: ptr %arg
  %phi6 = phi ptr [ %phi3, %while2.end ], [ %phi7, %while3.cond2 ]
  br i1 %arg1, label %while3.end, label %while3.cond2

while3.cond2:
; CHECK: PHI %phi7 has values:
; CHECK: ptr %arg
  %phi7 = phi ptr [ %phi6, %while3.cond1 ], [ %phi7, %while3.body ]
  br i1 %arg1, label %while3.cond1, label %while3.body

while3.body:
  br label %while3.cond2

while3.end:
  br label %while4.cond1

while4.cond1:
; CHECK: PHI %phi8 has values:
; CHECK: ptr %arg
  %phi8 = phi ptr [ %phi6, %while3.end ], [ %phi10, %while4.then ]
  br i1 %arg1, label %while4.end, label %while4.if

while4.if:
  br i1 %arg1, label %while4.cond2, label %while4.then

while4.cond2:
; CHECK: PHI %phi9 has values:
; CHECK: ptr %arg
  %phi9 = phi ptr [ %phi8, %while4.if ], [ %phi9, %while4.body ]
  br i1 %arg1, label %while4.then, label %while4.body

while4.body:
  br label %while4.cond2

while4.then:
; CHECK: PHI %phi10 has values:
; CHECK: ptr %arg
  %phi10 = phi ptr [ %phi8, %while4.if ], [ %phi9, %while4.cond2 ]
  br label %while4.cond1

while4.end:
  br label %while5.cond

while5.cond:
; CHECK: PHI %phi11 has values:
; CHECK: ptr %arg
  %phi11 = phi ptr [ %phi8, %while4.end ], [ %phi13, %while5.then ]
  br i1 %arg1, label %while5.end, label %while5.body1

while5.body1:
  br i1 %arg1, label %while5.if, label %while5.then

while5.if:
; CHECK: PHI %phi12 has values:
; CHECK: ptr %arg
  %phi12 = phi ptr [ %phi11, %while5.body1 ], [ %phi12, %while5.body2 ]
  br i1 %arg1, label %while5.then, label %while5.body2

while5.body2:
  br label %while5.if

while5.then:
; CHECK: PHI %phi13 has values:
; CHECK: ptr %arg
  %phi13 = phi ptr [ %phi11, %while5.body1 ], [ %phi12, %while5.if ]
  br label %while5.cond

while5.end:
  br label %while6.cond1

while6.cond1:
; CHECK: PHI %phi14 has values:
; CHECK: ptr %arg
  %phi14 = phi ptr [ %phi11, %while5.end ], [ %phi14, %while6.cond1 ]
  br i1 %arg1, label %while6.cond2, label %while6.cond1

while6.cond2:
; CHECK: PHI %phi15 has values:
; CHECK: ptr %arg
  %phi15 = phi ptr [ %phi14, %while6.cond1 ], [ %phi15, %while6.cond2 ]
  br label %while6.cond2
}
