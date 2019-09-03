#To be inserted at 801ba544
.include "../../../Globals.s"

.set  REG_MinorData,31
.set  REG_IronManData,30
.set  REG_MatchData,29

.set IronManData,0x8040a5e0

backup

#Save r3, cant get it otherwise
  mr  REG_MinorData,r3
#Get iron man data
  load  REG_IronManData,IronManData
#Get Match data
  lwz REG_MatchData,0x14(REG_MinorData)

IronMan_InitLineupInit:
.set  REG_Count,20
#Init
  li  REG_Count,0
IronMan_InitLineupLoop:
  mr  r3,REG_MatchData
  mr  r4,REG_Count
  bl  GetPlayersMatchInfo       #Get the players data
  cmpwi r3,-1
  beq IronMan_InitLineupEnd
#Create Lineup
  mulli r3,REG_Count,0x1C
  add r3,r3,REG_IronManData
  bl  CreateLineupArray

IronMan_InitLineupIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt IronMan_InitLineupLoop
IronMan_InitLineupEnd:

#Set match bits to skip game end checks (doing this myself)
  li  r3,0x80
  stb r3,0x15(REG_MatchData)

#Next Minor in-game
  load  r3,SceneController
  li  r4,1
  stb r4,Scene.CurrentMinor(r3)
b Exit

###############################################################
CreateLineupArray:
.set  REG_Array,31
.set  REG_BaseArray,30
.set  REG_Index,29

#backup
  backup
  mr  REG_Array,r3
#Initialize Runtime Index
  li  r3,25
  stb r3,0x0(REG_Array)
#Initialzie Stock Counter
  lwz	r3, -0x77C0 (r13)
  lbz	r3,6228(r3)
  stb r3,0x1B(REG_Array)
  addi  REG_Array,REG_Array,1
#Get base array
  bl  IronManArray
  mflr  REG_BaseArray
#Copy Lineup Array
  mr  r3,REG_Array
  mr  r4,REG_BaseArray
  li  r5,26
  branchl r12,memcpy

#Initialize Shuffle Index
  li  REG_Index,25
CreateLineupArray_Loop:
#Get random number between 0-25
  li  r3,26
  branchl r12,HSD_Randi
#Swap the current index with this element
  lbzx  r4,r3,REG_Array
  lbzx  r5,REG_Index,REG_Array
  stbx  r4,REG_Index,REG_Array
  stbx  r5,r3,REG_Array
#Decrement index
  subi  REG_Index,REG_Index,1
  cmpwi REG_Index,0
  bge CreateLineupArray_Loop

CreateLineupArray_Exit:
  restore
  blr

###############################################################
GetPlayersMatchInfo:
.set  REG_LoopCount,9
.set  REG_Count,10
.set  REG_MatchData,11
.set  REG_Player,12

#Backup
  addi  REG_MatchData,r3,0x70
  mr  REG_Player,r4
  li  REG_Count,0
  li  REG_LoopCount,0

GetPlayersMatchInfo_Loop:
  lbz r3,0x1(REG_MatchData)
  cmpwi r3,0x3
  beq GetPlayersMatchInfo_IncLoop
#Check if this is the desired player
  cmpw  REG_Count,REG_Player
  beq GetPlayersMatchInfo_Exit
  addi  REG_Count,REG_Count,1
GetPlayersMatchInfo_IncLoop:
  addi  REG_MatchData,REG_MatchData,0x24
  addi  REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,6
  blt GetPlayersMatchInfo_Loop
#Not Found
  li  r3,-1
  b GetPlayersMatchInfo_Blr

GetPlayersMatchInfo_Exit:
  mr  r3,REG_MatchData
  mr  r4,REG_LoopCount
GetPlayersMatchInfo_Blr:
  blr

###############################################################

IronManArray:
blrl
.byte 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25
.align 2

###############################################################

Exit:
  mr  r3,REG_MinorData
  restore
  lwz	r4, -0x77C0 (r13)
