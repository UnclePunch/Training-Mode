#To be inserted at 801ba5d0
.include "../../../Globals.s"

.set  REG_MinorData,31
.set  REG_IronManData,30
.set  REG_MatchData,29
.set IronManData,0x8040a5e0

backup

  mr  REG_MinorData,r3

#Get Match Data
  lwz	REG_MatchData, -0x77C0 (r13)
  addi	REG_MatchData, REG_MatchData, 4624
  load  REG_IronManData,IronManData

#Destroy Existing Heap

#Reset cache
  branchl r12,0x80018c6c
  branchl r12,0x80018254
  li  r3,4
  branchl r12,0x80017700

IronMan_SetupMatchInit:
.set  REG_Count,20
.set  REG_PlayerCount,21
.set  REG_Port,22
#Init
  li  REG_PlayerCount,0
  li  REG_Count,0
IronMan_SetupMatchLoop:
  mr  r3,REG_MatchData
  mr  r4,REG_Count
  bl  GetPlayersMatchInfo       #Get the players data
  cmpwi r3,-1
  beq IronMan_SetupMatchEnd
#Set the first character as the current character
  mr  REG_Port,r4
  mulli r5,REG_PlayerCount,0x1C
  add  r5,r5,REG_IronManData
  lbz r6,0x0(r5)               #Get the next iron man character
  addi  r5,r5,1
  lbzx  r5,r6,r5
  stb r5,0x0(r3)                #Store character to match data
  stb REG_PlayerCount,0x3(r3)   #Store costume to match data
#Get Prelod Table
  load  r3,0x8043208c
  mulli r4,REG_Port,0x8
  add r4,r3,r4
  stw r5,0x0(r4)                 #Store to preload table
  stb REG_PlayerCount,0x4(r4)                  #Store costume
  addi  REG_PlayerCount,REG_PlayerCount,1

IronMan_SetupMatchIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt IronMan_SetupMatchLoop

IronMan_SetupMatchEnd:
#Now get a random stage
  branchl r12,0x8025bbd4
  sth r3,0x16(REG_MatchData)
  load  r4,0x80432088
  stw r3,0x0(r4)                #Store to prelaod
#Request preload
  branchl r12,0x80018254

#Store Pointer to onStartMelee function
  lwz	r4, -0x77C0 (r13)
  addi	r4, r4, 4624
  bl  IronMan_Init
  mflr r5
  stw r5,0x4C(r4)
  b InjectionExit

#region IronMan_Init
IronMan_Init:
blrl

.set REG_GObj,31
.set REG_Data,30

.set DataSize,64

backup

#Create GObj
  li  r3,22
  li  r4,0
  li  r5,0
  branchl r12,GObj_Create
  mr  REG_GObj,r3

#Alloc Mem
  li  r3,DataSize
  branchl r12,HSD_MemAlloc
  mr  REG_Data,r3

#Zero Data
  mr  r3,REG_Data
  li  r4,DataSize
  branchl r12,ZeroAreaLength

#Attach Data
  mr  r3,REG_GObj
  li  r4,14
  load r5,HSD_Free
  mr  r6,REG_Data
  branchl r12,GObj_AddUserData

#Attach Process
  mr  r3,REG_GObj
  bl  IronMan_Think
  mflr r4
  li  r5,23
  branchl r12,GObj_AddProc

#Create Text
.set  REG_Count,20
.set  REG_IronManData,21
.set  REG_PlayerCount,22
.set  REG_Temp,23
.set  REG_Text,24
#Init
  li  REG_PlayerCount,0
  li  REG_Count,0
  load  REG_IronManData,IronManData
IronMan_Init_AdjustStocksLoop:
#Check if exists
  mr  r3,REG_Count
  branchl r12,PlayerBlock_LoadMainCharDataOffset
  cmpwi r3,0
  beq IronMan_Init_AdjustStocksIncLoop
#Increment player count
  addi  REG_PlayerCount,REG_PlayerCount,1
  subi  r4,REG_PlayerCount,1
  mulli r4,r4,0x1C
  add REG_Temp,r4,REG_IronManData
#Create Text
  li  r3,2
  load  r4,0x804a1f58
  lwz r4,0x0(r4)
  branchl r12,Text_CreateTextStruct
  mr  REG_Text,r3
  addi r3,REG_GObjData,OFST_TextPointers
  mulli r4,REG_Count,4
  stwx  REG_Text,r3,r4
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(REG_Text)
#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(REG_Text)
#Update Text Contents
	load	r4,0x804a0ff0
	mulli	r3,REG_Count,0xC			#HUD Info is 0xC Long Per Player
	lfsx	f1,r3,r4			        #Get This Players HUD Info
  bl  ScorePosition
  mflr  r5
  lfs f2,0x0(r5)
  mr  r3,REG_Text
  bl  ScoreText
  mflr  r4
  lbz r5,0x0(REG_Temp)
  extsb r5,r5
  addi  r5,r5,1
  branchl r12,Text_InitializeSubtext
#Update Size
  mr  r3,REG_Text
  li  r4,0
  lfs	f1, -0x1DB4 (rtoc)
  lfs	f2, -0x1DB4 (rtoc)
  branchl r12,Text_UpdateSubtextSize
IronMan_Init_AdjustStocksIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt IronMan_Init_AdjustStocksLoop

IronMan_InitExit:
restore
blr

#endregion

#region IronMan_Think
IronMan_Think:
blrl

#Registers
.set  REG_GObj,31
.set  REG_GObjData,30
.set  REG_IronManData,29

#Offsets
.set OFST_TextPointers,0x0
.set OFST_IsSpawning,0x18
  .set OFST_IsSpawningLength,0x2

#Constants
.set EndTimer,60

backup

#Init Pointers
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  load  REG_IronManData,IronManData

#Set match bits to not declare player defeated
  branchl r12,0x8016ae38
  li  r4,0
  stb r4,0x5(r3)


#Check if match is pending a character load
.set  REG_Count,20
#Init
  li  REG_Count,0
#Check if pending a load
IronMan_Think_CheckForPendingSpawnLoop:
  addi  r3,REG_GObjData,OFST_IsSpawning
  mulli r4,REG_Count,OFST_IsSpawningLength
  add r4,r3,r4
  lhz  r3,0x0(r4)
  cmpwi r3,0
  beq IronMan_Think_CheckForPendingSpawnIncLoop
#Check if load is finished
  subi  r3,r3,1
  sth  r3,0x0(r4)
  cmpwi r3,0
  bgt IronMan_Think_CheckForPendingSpawnIncLoop
#Spawn in player
  load  r3,0x80480590         #Match info
  mulli r4,REG_Count,0x24
  add r4,r3,r4
  mr  r3,REG_Count
  branchl r12,0x8016eddc
#Enter in Rebirth
  mr  r3,REG_Count
  branchl r12,PlayerBlock_LoadMainCharDataOffset
	li r4,0x1
	branchl	r12,0x800bfd9c
IronMan_Think_CheckForPendingSpawnIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt IronMan_Think_CheckForPendingSpawnLoop
IronMan_Think_CheckForPendingSpawnEnd:

IronMan_Think_DeathCheckInit:
.set  REG_Count,20
.set  REG_SomeoneDied,21
.set  REG_PlayerCount,22
.set  REG_PlayerData,23
.set  REG_IronManLineup,24
#Init
  li  REG_PlayerCount,0
  li  REG_Count,0
  li  REG_SomeoneDied,0
IronMan_Think_DeathCheckLoop:
#Check if exists
  mr  r3,REG_Count
  branchl r12,PlayerBlock_LoadMainCharDataOffset
  mr. REG_PlayerData,r3
  beq IronMan_Think_DeathCheckIncLoop
#Increment player count
  addi  REG_PlayerCount,REG_PlayerCount,1
#Update stock counter in ironman data
  mr  r3,REG_Count
  branchl r12,PlayerBlock_LoadStocksLeft
  subi  r4,REG_PlayerCount,1
  mulli r4,r4,0x1C
  add REG_IronManLineup,r4,REG_IronManData
  stb r3,0x1B(REG_IronManLineup)
#Check if no stocks left
  cmpwi r3,0
  bgt IronMan_Think_DeathCheckIncLoop
#Decrement their ironman index
  lbz r3,0x0(REG_IronManLineup)
  subi  r3,r3,1
  stb r3,0x0(REG_IronManLineup)
#Check if theyre completely dead
  extsb r3,r3
  cmpwi r3,0
  blt IronMan_Think_DeathCheckEndGame
#Give them max stocks
  lwz	r3, -0x77C0 (r13)
  lbz	r3,6228(r3)
  stb r3,0x1B(REG_IronManLineup)
#Despawn this player
  mr  r3,REG_Count
  branchl r12,0x8016ef98
#Remove all of their items

#Kill all of their SFX

#Setup spawn struct
  lbz r3,0x0(REG_IronManLineup)
  addi  r4,REG_IronManLineup,1
  lbzx  r5,r3,r4
  load  r3,0x80480590         #Match info
  mulli r4,REG_Count,0x24
  add r4,r3,r4
  stb r5,0x0(r4)                #Store character to match data
  stb REG_Count,0x3(r4)         #Store costume to match data
#Begin Preloading next character
  mr  r3,r5
  mr  r4,REG_Count
  bl  LoadCharacter
#Start Preload
#Set isSpawning flag
  addi  r3,REG_GObjData,OFST_IsSpawning
  mulli r4,REG_Count,OFST_IsSpawningLength
  add r4,r3,r4
  li  r3,3*60
  sth  r3,0x0(r4)
#Update Text
#Get text pointer
  addi r3,REG_GObjData,OFST_TextPointers
  mulli r4,REG_Count,4
  lwzx  r3,r3,r4
  li  r4,0
  bl  ScoreText
  mflr  r5
  lbz r6,0x0(REG_IronManLineup)
  extsb r6,r6
  addi  r6,r6,1
  branchl r12,Text_UpdateSubtextContents
  b IronMan_Think_DeathCheckIncLoop
IronMan_Think_DeathCheckEndGame:
#This player is out of characters, display GAME
  li  r3,5
  branchl r12,0x8016b33c
#Delay
  li  r3,40
  branchl r12,0x8016b378
#End game
  branchl r12,0x8016b328
#Destroy GObj
  mr  r3,REG_GObj
  branchl r12,GObj_Destroy
  b IronMan_ThinkExit
IronMan_Think_DeathCheckIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt IronMan_Think_DeathCheckLoop

IronMan_ThinkExit:
restore
blr

#endregion

###############################################################
ScoreText:
blrl
.string "%d Left"
.align 2

ScorePosition:
blrl
.float -15.5
###############################################################
GetPlayersMatchInfo:
.set  REG_LoopCount,9
.set  REG_Count,10
.set  REG_MatchData,11
.set  REG_Player,12

#Backup
  addi  REG_MatchData,r3,0x68
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

LoadCharacter:
.set  REG_ExtCharID,31
.set  REG_CostumeID,30

#Init
  backup
  mr  REG_ExtCharID,r3
  mr  REG_CostumeID,r4

#Store to preload table
  load  r3,0x8043209c
  mulli r4,REG_CostumeID,0x8
  add r4,r3,r4
  stw REG_ExtCharID,0x0(r4)                 #Store to preload table
  stb REG_CostumeID,0x4(r4)                 #Store costume
  branchl r12,0x80018254

#Load present characters SFX
LoadCharacter_DeathCheckSFXLoad:
.set  REG_SFXLoopCount,25
.set  REG_SFXMatchInfo,26
.set  REG_AudioBit1,27
.set  REG_AudioBit2,28
  li  REG_SFXLoopCount,0
  li  REG_AudioBit1,0
  li  REG_AudioBit2,0
  load  REG_SFXMatchInfo,0x80480590         #Match info
LoadCharacter_DeathCheckSFXLoadLoop:
  mulli r3,REG_SFXLoopCount,0x24
  add r3,r3,REG_SFXMatchInfo
  lbz r3,0x0(r3)
  extsb r3,r3
  branchl r12,0x80026e84
  or  REG_AudioBit1,REG_AudioBit1,r3
  or  REG_AudioBit2,REG_AudioBit2,r4
LoadCharacter_DeathCheckSFXLoadIncLoop:
  addi  REG_SFXLoopCount,REG_SFXLoopCount,1
  cmpwi REG_SFXLoopCount,6
  blt LoadCharacter_DeathCheckSFXLoadLoop
#Unk
  li  r3,28
  branchl r12,0x80026f2c
#Request the SFX load
  li  r3,4
  mr  r5,REG_AudioBit1
  mr  r6,REG_AudioBit2
  branchl r12,0x8002702c
  branchl r12,0x80027168

LoadCharacter_Exit:
  restore
  blr

###############################################################

InjectionExit:
  mr  r3,REG_MinorData
  restore
  li  r5,0
  li  r6,0
