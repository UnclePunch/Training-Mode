#To be inserted at 80005528
.include "../../../Globals.s"

.set EventID,31
.set PageID,30

backup

#Backup Requested Event
  mr EventID,r3

#Get Current Page
  lwz r3,MemcardData(r13)
  lbz PageID,CurrentEventPage(r3)
  bl  SkipPageList

##### Page List #######

  bl  GeneralTech
  bl  SpacieTech

#######################

GeneralTech:
#L-Cancel Training
.string "Practice L-Cancelling on
a stationary CPU."

#Ledgedash Training
.string "Practice Ledgedashes!
Use D-Pad to change ledge."

#Eggs-ercise
.string "Break the eggs! Only strong hits will
break them. DPad down = free practice."

#SDI Training
.string "Practice Smash DI'ing
Fox's up-air!"

#Reversal Training
.string "Practice OoS punishes! DPad left/right
moves characters closer and further apart."

#Powershield Training
.string "Powershield Falco's laser!
Pause to change fire-rate."

#Shield Drop Training
.string "Counter with a shield-drop aerial!
DPad left/right moves players apart."

#Attack On Shield
.string "Practice attacks on a shielding opponent!
Pause to change their OoS option."

#Ledge-Tech Training
.string "Practice ledge-teching
Falco's down-smash!"

#Amsah-Tech Training
.string "Taunt to have Marth Up-B,
then ASDI down and tech!"

#Combo Training
.string "L+DPad adjusts percent/DPadDown moves CPU
DPad right/left saves and loads positions."

#Waveshine SDI
.string "Use Smash DI to get out
of Fox's waveshine!"
.align 2

#######################

SpacieTech:
#Ledgetech Marths Counter
.string "Practice ledge-teching
Marth's counter!"

#Armada-Shine Practice
.string "Finish off the enemy
Fox with an Aramda-Shine!"

.align 2
#######################

SkipPageList:
  mflr	r4		#Jump Table Start in r4
  mulli	r5,PageID,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
#Get String
  mr  r3,EventID
  add	r4,r4,r5		#Gets ASCII Address in r4
  branchl r12,SearchStringTable

Exit:
restore
blr
