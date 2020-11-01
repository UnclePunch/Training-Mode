#To be inserted at 80395704
.include "../../../Globals.s"

#Get Held Buttons
  lwz r3,0xC0(r30)
#Check for LRZ
  cmpwi r3,0x70
  beq  PressedButtons
#Not Pressing LRZ
  branch r12,0x80395728

PressedButtons:
