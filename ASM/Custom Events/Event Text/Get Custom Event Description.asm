#To be inserted at 80005528
.include "../../Globals.s"

.set EventID,31

backup

mr EventID,r3

#Check For Custom Event
  branchl r12,0x80005520
  cmpwi r3,0x0
  beq VanillaEvent
#Get Events Text
  bl	SkipJumpTable
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
  subi	r5,EventID,0x3		#Start at Event 0, so 0-Index
  mulli	r5,r5,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r3,r4,r5		#Gets ASCII Address in r4
  b Exit

Event4:
#L-Cancel Training
.string "Practice L-Cancelling on
a stationary CPU."
.align 2

Event5:
#Ledgedash Training
.string "Practice Ledgedashes!
Use D-Pad to change ledge"
.align 2

Event6:
#Eggs-ercise
.string "Break the eggs! Only strong hits will
break them. DPad down = free practice"
.align 2

Event7:
#SDI Training
.string "Practice Smash DI'ing
Fox's up-air!"
.align 2

Event8:
#Reversal Training
.string "Practice OoS punishes! DPad left/right
moves characters closer and further apart."
.align 2

Event9:
#Powershield Training
.string "Powershield Falco's laser!
Pause to change fire-rate."
.align 2

Event10:
#Shield Drop Training
.string "Counter with a shield-drop aerial!
DPad left/right moves players apart."
.align 2

Event11:
#Attack On Shield
.string "Practice attacks on a shielding opponent!
Pause to change their OoS option."
.align 2

Event12:
#Ledge-Tech Training
.string "Practice ledge-teching
Falco's down-smash!"
.align 2

Event13:
#Amsah-Tech Training
.string "Taunt to have Marth Up-B,
then ASDI down and tech!"
.align 2

Event14:
#Combo Training
.string "L+DPad adjusts percent/DPadDown moves CPU
DPad right/left saves and loads positions."
.align 2

Event15:
#Waveshine SDI
.string "Use Smash DI to get out
of Fox's waveshine!"
.align 2

VanillaEvent:
li  r3,0

Exit:
restore
blr
