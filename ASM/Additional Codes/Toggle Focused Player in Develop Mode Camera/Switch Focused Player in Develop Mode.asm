#To be inserted at 802276f4
.include "../../Globals.s"

.set REG_Inputs,31
.set REG_FocusedPlayer,30
.set REG_CameraStruct,29
.set REG_Additive,28

backup

#Get Current Focused Player
  load REG_CameraStruct,0x80453004
  lwz  REG_FocusedPlayer,0x4(REG_CameraStruct)

#Init REG_Additive
  li  REG_Additive,0

#Check Dpad Left
CheckDPadLeft:
  rlwinm. r0,REG_Inputs,0,25,25
  beq CheckDPadRight
#Pressing Left
  li  REG_Additive,-1
  b GetNextPlayer
#Check Dpad Right
CheckDPadRight:
  rlwinm. r0,REG_Inputs,0,26,26
  beq GetNextPlayer
#Pressing Right
  li  REG_Additive,1
  b GetNextPlayer

GetNextPlayer:
  cmpwi REG_Additive,0
  beq Exit
GetNextPlayerLoop:
  add REG_FocusedPlayer,REG_FocusedPlayer,REG_Additive
#Check if Under 4
  cmpwi REG_FocusedPlayer,4
  blt GetNextPlayer_Under4
#Loop around back to 0
  li  REG_FocusedPlayer,0
GetNextPlayer_Under4:
#Check if Over 4
  cmpwi REG_FocusedPlayer,0
  bge GetNextPlayer_CheckIfExists
#Loop around back to 3
  li  REG_FocusedPlayer,3
GetNextPlayer_CheckIfExists:
  mr  r3,REG_FocusedPlayer
  branchl r12,0x80034110
  cmpwi r3,0x0
  beq GetNextPlayerLoop

#Store New Focused Player
stw REG_FocusedPlayer,0x4(REG_CameraStruct)

Exit:
  restore
  branchl r12,0x80030a50
