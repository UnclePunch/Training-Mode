#To be inserted at 801af6f4
.include "../../Globals.s"

.set MEMCARD_NONE,0xF
.set MEMCARD_NONE2,0xD

#Check if no memcard inserted
  cmpwi r29,MEMCARD_NONE
  beq NoMemcard
  cmpwi r29,MEMCARD_NONE2
  beq NoMemcard
  b Original

NoMemcard:
#Exit memcard think and disable saving
  branch r12,0x801b01ac

Original:
  cmpwi r29,0
