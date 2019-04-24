#To be inserted at 801BFA20
.include "../../Globals.s"

.set LoopCount,12
.set InputStruct,11

#Check if any player is pressing Z
  li  LoopCount,0
  load InputStruct,InputStructStart
#Loop through inputs
InputLoop:
  mulli	r0, LoopCount, 68
  add	  r3, r0, InputStruct
  lwz	  r3, 0 (r3)
  rlwinm. r0,r3,0,21,21     #Check For X
  bne LoadCSS
  addi LoopCount,LoopCount,1
  cmpwi LoopCount,4
  blt InputLoop
  b LoadEventMenu

LoadCSS:
#Play SFX
  li  r3,1
  branchl r12,SFX_MenuCommonSound
  li  r3,2
  b Exit

#Boot to Event Menu
LoadEventMenu:
  li	r3, 1

Exit:
