#To be inserted at 0x80005530
.include "../Globals.s"
.include "../../m-ex/Header.s"

#############################################
.set ID,31
.set LoopCount,30
.set Name,29

backup

#Get ID
  mr  ID,r3
#Get Names
  mr  Name,r4
#Init Loop Count
  li  LoopCount,0

SearchStringTable_Loop:
#Check if we are up to the correct name
  cmpw ID,LoopCount
  beq SearchStringTable_Exit
#Get string length
  mr  r3,Name
  branchl r12,0x80325b04
#Add to current name pointer
  add Name,Name,r3
  addi Name,Name,1
#Inc Loop Count
  addi LoopCount,LoopCount,1
  b SearchStringTable_Loop

SearchStringTable_Exit:
mr  r3,Name
restore
blr

###################################
