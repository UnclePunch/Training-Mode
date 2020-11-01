#To be inserted at 801af6f4
.include "../Globals.s"

.set MEMCARD_HASSAVE,0x0
.set MEMCARD_NOSAVE,0x4
.set MEMCARD_NONE,0xF
.set MEMCARD_NONE2,0xD

#Check if no memcard inserted
  cmpwi r29,MEMCARD_HASSAVE
  beq Original
  cmpwi r29,MEMCARD_NOSAVE
  beq NoSave  
  cmpwi r29,MEMCARD_NONE
  beq NoMemcard
  cmpwi r29,MEMCARD_NONE2
  beq NoMemcard

  b NoSave

NoSave:
bl InitSave
b Original

NoMemcard:
bl InitSave

#Exit memcard think and disable saving
  branch r12,0x801b01ac

InitSave:
backup

  OnSaveCreate

restore
blr

Original:
  cmpwi r29,0
