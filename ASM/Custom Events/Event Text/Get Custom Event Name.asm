#To be inserted at 80005524
.include "../../Globals.s"

.set EventID,31

backup

mr EventID,r3

#Get Events Text
  bl	SkipJumpTable
  #bl	PlaceHolder
  #bl	PlaceHolder
  #bl	PlaceHolder
  bl	Event4
  bl	Event5
  bl	Event6
  bl	Event7
  bl	Event8
  bl	Event9
  bl	Event10
  bl	Event11
  bl	Event12
  bl	Event13
  bl	Event14
  bl	Event15
  bl	Event16
  bl	Event17
  bl	Event18
SkipJumpTable:
  mflr	r4		#Jump Table Start in r4
  mulli	r5,EventID,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r3,r4,r5		#Gets ASCII Address in r4
  b Exit

PlaceHolder:
.string "Placeholder"
.align 2

Event4:
#L-Cancel Training
.string "L-Cancel Training"
.align 2

Event5:
#Ledgedash Training
.string "Ledgedash Training"
.align 2

Event6:
#Eggs-ercise
.string "Eggs-ercise"
.align 2

Event7:
#SDI Training
.string "SDI Training"
.align 2

Event8:
#Reversal Training
.string "Reversal Training"
.align 2

Event9:
#Powershield Training
.string "Powershield Training"
.align 2

Event10:
#Shield Drop Training
.string "Shield Drop Training"
.align 2

Event11:
#Attack On Shield
.string "Attack On Shield"
.align 2

Event12:
#Ledge-Tech Training
.string "Ledge-Tech Training"
.align 2

Event13:
#Amsah-Tech Training
.string "Amsah-Tech Training"
.align 2

Event14:
#Combo Training
.string "Combo Training"
.align 2

Event15:
#Waveshine SDI
.string "Waveshine SDI"
.align 2

VanillaEvent:
li  r3,0

Exit:
restore
blr
