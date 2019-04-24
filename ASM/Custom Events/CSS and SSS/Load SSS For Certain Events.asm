#To be inserted at 801bab28
.include "../../Globals.s"

stb	r0, 0x000A (r31)

.set EventID,7
.set PageID,8

#Get Hovered Over Event ID in r23
	lwz	r4, -0x77C0 (r13)
	lbz	EventID, 0x0535 (r4)

#Get Current Page
  lbz PageID,CurrentEventPage(r4)

#Get pointer page's string array
	bl	SkipJumpTable

##### Page List #######
	bl	GeneralTech
	bl	SpacieTech
#######################

SkipJumpTable:
  mflr	r4		#Jump Table Start in r4
  mulli	r5,PageID,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r5,r4,r5		#Gets Address in r4

#Loop Through Whitelisted Events
  subi	r5,r5,0x1
Loop:
  lbzu	r6,0x1(r5)
  extsb	r0,r6
  cmpwi	r0,-1
  beq	original
  cmpw	r6,EventID
  beq	SSS
  b	Loop

SSS:
#Store SSS as Next Scene
  load	r3,SceneController
  li	r4,0x3
  stb	r4,0x5(r3)
  b original

#########################

GeneralTech:
.byte Event.LCancel
.byte Event.Ledgedash
.byte Event.Eggs
.byte Event.Reversal
.byte Event.LedgeTech
.byte Event.AmsahTech
.byte Event.Combo
.byte 0xFF
.align 2

SpacieTech:
.byte Event.LedgetechCounter
.byte 0xFF
.align 2

#########################

original:
