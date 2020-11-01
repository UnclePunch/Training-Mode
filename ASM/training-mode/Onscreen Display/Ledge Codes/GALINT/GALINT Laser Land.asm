#To be inserted at 80082c40
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27


##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

#Search last 5 AS's for CliffWait
  li  r5,0x0
  lwz r6,0x2C(28)
CliffWaitSearch:
  mulli r3,r5,0x2
  addi  r3,r3,TM_PrevASStart
  lhzx r3,r3,r6
  cmpwi	r3,0xFD
  beq	DisplayGALINT
  addi r5,r5,1
  cmpwi r5,5
  ble CliffWaitSearch
  b Moonwalk_Exit

#Display GALINT
DisplayGALINT:
  mr  r3,r28
  li  r4,0
  branchl	r12,0x80005514

Moonwalk_Exit:
restoreall
mr	r3, r28
