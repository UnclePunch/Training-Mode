#To be inserted at 801af6f4
.include "../../Globals.s"

.set MEMCARD_NONE,0xF

#Check if no memcard inserted
  cmpwi r29,MEMCARD_NONE
  bne Original

#Exit memcard think and disable saving
  branch r12,0x801b01ac

Original:
  cmpwi r29,0
