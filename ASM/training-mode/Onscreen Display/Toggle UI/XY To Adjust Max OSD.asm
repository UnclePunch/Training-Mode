#To be inserted at 802360f8
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set Text,30
.set TextProp,28

.set MaxWindows,4-1

#Injected into CursorMovement Check

backup

#CHECK FLAG IN RULES STRUCT
load	r4,0x804a04f0
lbz	r0, 0x0011 (r4)
cmpwi	r0,0x2
blt exit

li  r3,4
branchl r12,Inputs_GetPlayerInstantInputs

lwz	r20,-0x77C0(r13)			#Get Memcard Data

#############################################
CheckY:
rlwinm.	r0, r4, 0, 20, 20 		#Check For Y
beq	CheckX

#Increase Number
lbz	r3,0x1f28(r20)
addi	r3,r3,0x1
#Check If Over Max
cmpwi	r3,MaxWindows
ble	CheckY_Store
#Loop Back to 0
li	r3,0x0
CheckY_Store:
stb	r3,0x1f28(r20)

b	UpdateText
#############################################

CheckX:
rlwinm.	r0, r4, 0, 21, 21 		#Check For X
beq	CheckZ

#Decrease Number
lbz	r3,0x1f28(r20)
subi	r3,r3,0x1
#Check If Over Max
cmpwi	r3,0
bge	CheckX_Store
#Loop Back to MaxWindows
li	r3,MaxWindows
CheckX_Store:
stb	r3,0x1f28(r20)

b	UpdateText
#############################################

CheckZ:
rlwinm.	r0, r4, 0, 27, 27 		#Check For Z
beq	exit

#Toggle option
  lbz	r3,OSDRecommended(r20)
  xori r3,r3,1
  stb	r3,OSDRecommended(r20)
#Get Options String
  bl  FDDRecommendedOptions
  mflr  r4
  branchl r12,SearchStringTable
#Update Text
  mr  r6,r3
  lwz	r3,0x40(r29)			#Get Text Structure
  lbz	r4,0x49(r29)			#Get Subtext ID
  bl	FDDRecommended
  mflr	r5
  crclr 6
  branchl r12,Text_UpdateSubtextContents

b PlaySFX
#############################################

UpdateText:
lwz	r3,0x40(r29)			#Get Text Structure
lbz	r4,0x48(r29)			#Get Subtext ID
bl	UpdateText_Text
mflr	r5
lbz	r6,0x1f28(r20)
addi	r6,r6,0x1
branchl	r12,0x803a70a0

b	PlaySFX
#############################################

UpdateText_Text:
blrl
.string "Max OSD's: %d"
.align 2

FDDRecommended:
blrl
.string "Suggested OSDs: %s"
.align 2

FDDRecommendedOptions:
blrl
.string "On"
.string "Off"
.align 2
########################################

PlaySFX:
  li  r3,2
  branchl r12,0x80024030

exit:
restore
rlwinm.	r0, r28, 0, 23, 23
