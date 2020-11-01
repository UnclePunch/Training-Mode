#To be inserted at 80080638
.include "../../Globals.s"

.set  REG_PlayerData,31
.set  REG_ItemGObj,30
.set  REG_ItemData,29

backup

#Check char
  lwz r3,0x4(REG_PlayerData)
  cmpwi r3,Link.Int
  beq Link
  cmpwi r3,Popo.Int
  beq Nana
  /*
  cmpwi r3,Pikachu.Int
  beq Pikachu
  cmpwi r3,Pichu.Int
  beq Pikachu
  */
  b Exit
##########################
Link:
#Check if boomerang exists
  lwz REG_ItemGObj,0x2234(REG_PlayerData)
  cmpwi REG_ItemGObj,0
  beq Link_NoBoomerang
#Check if in state 3 (returning)
  lwz REG_ItemData,0x2C(REG_ItemGObj)
  lwz r3,0x24(REG_ItemData)
  cmpwi r3,3
  bne Link_NoBoomerang
#Draw circle of 6 radius around links current position
  lfs f1,0xB0(REG_PlayerData)
  stfs f1,0x80(sp)
  lfs f1,0xB4(REG_PlayerData)
  lwz r3,0x2D4(REG_PlayerData)
  lfs f2,0x28(r3)
  fadds f1,f1,f2
  stfs f1,0x84(sp)
  lfs f1,0xB8(REG_PlayerData)
  stfs f1,0x88(sp)
  addi  r3,sp,0x80
  lwz r4,0xC4(REG_ItemData)
  lwz r4,0x4(r4)
  lfs f1,0x2C(r4)
  bl  DrawBubble
Link_NoBoomerang:
/*
#Check if chain exists
  lwz REG_ItemGObj,0x2238(REG_PlayerData)
  cmpwi REG_ItemGObj,0
  beq Link_NoChain
#Check if in state 8 (hangwait)
  lwz REG_ItemData,0x2C(REG_ItemGObj)
  lwz r3,0x24(REG_ItemData)
  cmpwi r3,8
  bne Link_NoChain
#Draw circle of 6 radius around the end of the hook
  lfs f1,0xB0(REG_PlayerData)
  stfs f1,0x80(sp)
  lfs f1,0xB4(REG_PlayerData)
  lwz r3,0x2D4(REG_PlayerData)
  lfs f2,0x28(r3)
  fadds f1,f1,f2
  stfs f1,0x84(sp)
  lfs f1,0xB8(REG_PlayerData)
  stfs f1,0x88(sp)
  addi  r3,sp,0x80
  lwz r4,0xC4(REG_ItemData)
  lwz r4,0x4(r4)
  lfs f1,0x40(r4)
  bl  DrawBubble
*/

Link_NoChain:
  b Exit

##########################

Nana:
#up b nana search radius
  lwz r3,0x10(REG_PlayerData)
  cmpwi r3,0x160
  beq Nana_UpB
  cmpwi r3,0x15B
  beq Nana_UpB
  b Nana_NoUpB

Nana_UpB:
#Check if frame 4
  li  r3,0
  li  r4,4
  branchl r12,cvt_sll_flt
  lfs f2,0x894(REG_PlayerData)
  fcmpo cr0,f1,f2
  bne Nana_NoUpB

#Draw circle
  addi  r3,REG_PlayerData,0xB0
  lwz r4,0x2D4(REG_PlayerData)
  lfs f1,0x7C(r4)
  bl  DrawBubble

Nana_NoUpB:
  b Exit

##########################
/*
Pikachu:
#Check AS
  lwz r3,0x10(REG_PlayerData)
  cmpwi r3,0x168
  beq Pikachu_DownB
  cmpwi r3,0x15C
  beq Pikachu_DownB
  b Pikachu_NoDownB
#Get thunder position
  lwz r3,0x2340(REG_PlayerData)
  cmpwi r3,0
  beq Pikachu_NoDownB
  addi  r4,sp,0x80
  branchl r12,0x802b1fe8
*/


Pikachu_NoDownB:
  b Exit

##########################

DrawBubble:
backup
mr  r4,r3
bl  BubbleColors
mflr  r5
addi  r6,r5,4
branchl r12,0x80008fc8
restore
blr

BubbleColors:
blrl
.byte 255,255,255,128
.byte 128,0,0,128
##########################

Exit:
#Return
  restore
  lbz	r0, 0x221D (r31)
