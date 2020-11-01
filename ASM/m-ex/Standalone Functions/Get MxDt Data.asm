#To be inserted @ 803d7094
.include "../../Globals.s"
.include "../Header.s"

backup

# check if over
  cmpwi  r3,8
  bge Assert

# get jump table
  bl  SkipJumpTable
#*****************************#
bl  FtIntNum
bl  FtExtNum
bl  FtIconNum
bl  MnSlChrIcon
bl  GrIntNum
bl  GrExtNum
bl  GrIconNum
bl  MnSlMpIcon
#*****************************#
SkipJumpTable:
#Get effect type
  mflr	r4		#Jump Table Start in r4
#Get Event Code Pointer
  mulli	r5,r3,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r4,r4,r5		#Gets ASCII Address in r4
  mtctr	r4
  bctr


FtIntNum:
  lwz r3,OFST_Metadata_FtIntNum(rtoc)
  b Exit
FtExtNum:
  lwz r3,OFST_Metadata_FtExtNum(rtoc)
  b Exit
FtIconNum:
  lwz r3,OFST_Metadata_CSSIconCount(rtoc)
  b Exit
MnSlChrIcon:
  lwz r3,OFST_MnSlChrIconData(rtoc)
  b Exit
GrIntNum:
  lwz r3,OFST_MetaData_GrIntNum(rtoc)
  b Exit
GrExtNum:
  lwz r3,OFST_MetaData_GrExtNum(rtoc)
  b Exit
GrIconNum:
  lwz r3,OFST_Metadata_SSSIconCount(rtoc)
  b Exit
MnSlMpIcon:
  lwz r3,OFST_Menu_SSS(rtoc)
  b Exit

#############################################
Assert:
#OSReport
  mr r4,r3
  bl  ErrorString
  mflr  r3
  branchl r12,0x803456a8
#Assert
  bl  Assert_Name
  mflr  r3
  li  r4,0
  load  r5,0x804d3940
  branchl r12,0x80388220
Assert_Name:
blrl
.string "m-ex"
.align 2
ErrorString:
blrl
.string "error: MEX_GetData() does not have data for id %d\n"
.align 2
###############################################


Exit:
  restore
  blr