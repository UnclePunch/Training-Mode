#To be inserted at 801c154c
.include "../Globals.s"

#Initialize data
  li  r4,516
  branchl r12,ZeroAreaLength

Exit:
  cmplwi	r26, 0
