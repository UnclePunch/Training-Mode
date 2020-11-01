#To be inserted at 801b8e80
.include "../../Globals.s"

#Store Pointer to onStartMelee function
  lwz	r4, -0x77C0 (r13)
  addi	r4, r4, 3672
  bl  TagMelee_Init
  mflr r5
  stw r5,0x44(r4)
  b InjectionExit

#region TagMelee_Init
TagMelee_Init:
blrl

.set REG_GObj,31
.set REG_Data,30

.set DataSize,64

backup

#Create GObj
  li  r3,22
  li  r4,23
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
  bl  TagMelee_Think
  mflr r4
  li  r5,23
  branchl r12,GObj_AddProc

TagMelee_InitExit:
restore
blr

#endregion

#region TagMelee_Think
TagMelee_Think:
blrl

#Registers
.set REG_GObj,31
.set REG_GObjData,30

#Data Offsets
.set GameState,0x0    #byte
.set ItSlot,0x1       #byte
.set Timer,0x2        #half

#Definitions
#GameState
  .set Start,0x0
  .set InProgress,0x1
  .set Frozen,0x2

#Constants
  .set FreezeFrames, 1 * 60

backup

#Init Pointers
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)

#Check state of game
  lbz r3,GameState(REG_GObjData)
  cmpwi r3,Start
  beq TagMelee_Think_Start
  cmpwi r3,InProgress
  beq TagMelee_Think_InProgress
  cmpwi r3,Frozen
  beq TagMelee_Think_Frozen

#region Start
TagMelee_Think_Start:

.set REG_LoopCount,29
.set REG_TotalPlayerCount,28

#########################################
## Start by counting all alive players ##
#########################################
#Init Loop
  li  REG_LoopCount,0
  li  REG_TotalPlayerCount,0
TagMelee_Think_StartCountAllPlayers:
#Check Players Presence
  mr  r3,REG_LoopCount
  branchl r12,0x800322c0
  cmpwi r3,0x2
  bne TagMelee_Think_StartCountAllPlayersIncLoop
#Check if player has stocks remaining
  mr  r3,REG_LoopCount
  branchl r12,0x80033bd8
  cmpwi r3,0
  ble TagMelee_Think_StartCountAllPlayersIncLoop
#Get Players GObj
  mr  r3,REG_LoopCount
  branchl r12,0x80034110
  lwz r3,0x2C(r3)
#Check if READY,GO is over
  lbz r4,0x221D(r3)
  rlwinm. r4,r4,0,28,28
  bne TagMelee_ThinkExit
#Player exists, increment total count
  addi REG_TotalPlayerCount,REG_TotalPlayerCount,1
TagMelee_Think_StartCountAllPlayersIncLoop:
  addi REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,6
  blt TagMelee_Think_StartCountAllPlayers

#############################
## Now get a random player ##
#############################
.set REG_RandomPlayer,27

  mr  r3,REG_TotalPlayerCount
  branchl r12,HSD_Randi
  mr  REG_RandomPlayer,r3

#######################################
## Get the corresponding player slot ##
#######################################
#Init Loop
  li  REG_LoopCount,0
  li  REG_TotalPlayerCount,0
TagMelee_Think_StartGetItSlot:
#Check Players Presence
  mr  r3,REG_LoopCount
  branchl r12,0x800322c0
  cmpwi r3,0x2
  bne TagMelee_Think_StartGetItSlotIncLoop
#Check if player has stocks remaining
  mr  r3,REG_LoopCount
  branchl r12,0x80033bd8
  cmpwi r3,0
  ble TagMelee_Think_StartGetItSlotIncLoop
#Is this who im looking for?
  cmpw REG_RandomPlayer,REG_TotalPlayerCount
  beq TagMelee_Think_StartFoundIt
#Player exists, increment total count
  addi REG_TotalPlayerCount,REG_TotalPlayerCount,1
TagMelee_Think_StartGetItSlotIncLoop:
  addi REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,6
  blt TagMelee_Think_StartGetItSlot

###################
## Store as "it" ##
###################

TagMelee_Think_StartFoundIt:
  stb REG_LoopCount,ItSlot(REG_GObjData)

.set TimerMin, 10 * 60
.set TimerMax, 30 * 60

#Start random timer
  li  r3,TimerMax-TimerMin
  branchl r12,HSD_Randi
  addi r3,r3,TimerMin
  sth r3,Timer(REG_GObjData)

#Change state to InProgress
  li  r3,InProgress
  stb r3,GameState(REG_GObjData)

b TagMelee_Think_InProgress

#endregion

#region InProgress
TagMelee_Think_InProgress:

.set REG_LoopCount,29
.set REG_TotalPlayerCount,28
#Init Loop
  li  REG_LoopCount,0
  li  REG_TotalPlayerCount,0
TagMelee_Think_PunishPlayers:
#Check Players Presence
  mr  r3,REG_LoopCount
  branchl r12,0x800322c0
  cmpwi r3,0x2
  bne TagMelee_Think_PunishPlayersIncLoop
#Check if player has stocks remaining
  mr  r3,REG_LoopCount
  branchl r12,0x80033bd8
  cmpwi r3,0
  ble TagMelee_Think_PunishPlayersIncLoop
#Ensure this player os not it
  lbz r3,ItSlot(REG_GObjData)
  cmpw r3,REG_LoopCount
  beq TagMelee_Think_PunishPlayersIncLoop
#Get this players gobj
  mr  r3,REG_LoopCount
  branchl r12,PlayerBlock_LoadMainCharDataOffset
  mr  REG_PlayerGObj,r3
  lwz REG_PlayerData,0x2C(REG_PlayerGObj)
#Check if they have a victim
  lwz r3,0x2094(REG_PlayerData)
  cmpwi r3,0
  beq TagMelee_Think_PunishPlayersIncLoop
#If victim is not it, give the damage they just dealt
  lwz r4,0x2C(r3)


TagMelee_Think_PunishPlayersIncLoop:
  addi REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,6
  blt TagMelee_Think_PunishPlayers

##################
## Monitor "It" ##
##################
TagMelee_Think_InProgressMonitorIt:
#Get Players GObj
  lbz r3,ItSlot(REG_GObjData)
  branchl r12,0x80034110
  mr  REG_PlayerGObj,r3
#Check if player died
#Check if Blastzone code is being skipped
  lwz r3,0x2C(REG_PlayerGObj)
  lbz r4,0x2219(r3)
  rlwinm. r4,r4,0,25,25
  beq TagMelee_Think_InProgressMonitorItCheckForVictim
#Rebirth gets here too, check if NOT rebirth/rebirthWait
  lwz r4,0x10(r3)
  cmpwi r4,ASID_Rebirth
  beq TagMelee_Think_InProgressMonitorItCheckForVictim
  cmpwi r4,ASID_RebirthWait
  beq TagMelee_Think_InProgressMonitorItCheckForVictim
#If in any Star KO State, enter them into DeadUp
  cmpwi r4,ASID_DeadUpStar
  beq TagMelee_Think_InProgressEnterDeadUp
  cmpwi r4,ASID_DeadUpStarIce
  beq TagMelee_Think_InProgressEnterDeadUp
  cmpwi r4,ASID_DeadUpFall
  beq TagMelee_Think_InProgressEnterDeadUp
  b  TagMelee_Think_InProgressFreezeAllPlayers
TagMelee_Think_InProgressEnterDeadUp:
#Enter DeadUp
  lwz r3,0x0(r3)
  branchl r12,0x800d3e40
  b TagMelee_Think_InProgressFreezeAllPlayers
TagMelee_Think_InProgressMonitorItCheckForVictim:
#Check if player has a victim
  lwz r3,0x2C(REG_PlayerGObj)
  lwz r4,0x2094(r3)
  cmpwi r4,0
  beq TagMelee_Think_InProgressNoTag
#Ensure there is no hitbox exception (this should catch Thrown hitboxes)
  lwz r5,0x1198(r3)
  cmpwi r5,0
  bne TagMelee_Think_InProgressRemoveVictim
#Get the victims damage source
  lwz r5,0x2C(r4)
  lwz r5,0x1868(r5)
#Check if source pointer exists
  cmpwi r5,0x0
  beq TagMelee_Think_InProgressRemoveVictim
#Check if source pointer is live (check userdata pointer)
  lwz r6,0x2C(r5)
  cmpwi r6,0        #if not, item most likely was removed on hit, so assume it was an item
  beq TagMelee_Think_InProgressRemoveVictim
#Check if they were hit by an "item"
  lhz r6,0x0(r5)
  cmpwi r6,6
  beq TagMelee_Think_InProgressNoTag
  b TagMelee_Think_InProgressSetNewIt

/*  bne TagMelee_Think_InProgressSetNewIt
#Check if hitbox is still active
  lwz r6,0x2C(r5)
  addi r6,r6,0x5D4    #Start of hitbox struct
  lwz r5,0x0(r6)      #check if hitbox is active
  cmpwi r5,0x0
  beq TagMelee_Think_InProgressSetNewIt
#Ensure it was non reflectable
  lbz r5,0x42(r6)     #get collision bools
  rlwinm.	r5, r5, 29, 31, 31
  bne	TagMelee_Think_InProgressNoTag
*/

TagMelee_Think_InProgressRemoveVictim:
  li  r4,0
  stw r4,0x2094(r3)
  b TagMelee_Think_InProgressNoTag

TagMelee_Think_InProgressSetNewIt:
#Set this as new "it"
  mr  REG_PlayerGObj,r4
  lwz r3,0x2C(r4)
  lbz r4,0xC(r3)
  stb r4,ItSlot(REG_GObjData)

TagMelee_Think_InProgressNoTag:
#Apply GFX to "it"
  lwz r3,0x2C(REG_PlayerGObj)
  li	r4,0x23		# darkness body aura
  li	r5,0
  branchl r12,0x800bffd0
  lwz r4,0x2C(REG_PlayerGObj)
  li	r3,0
  stw	r3,0x430(r4)

  lhz r3,Timer(REG_GObjData)
  subi r3,r3,1
  sth r3,Timer(REG_GObjData)
#Check if up
  cmpwi r3,0
  bgt TagMelee_ThinkExit

#Timer up, kill "it"
  addi  r3,REG_PlayerGObj,0
  branchl r12,0x800d3e40

########################
## Freeze All Players ##
########################

.set REG_LoopCount,29
.set REG_TotalPlayerCount,28
.set REG_PlayerGObj,27
.set REG_PlayerData,26
TagMelee_Think_InProgressFreezeAllPlayers:
#Init Loop
  li  REG_LoopCount,0
  li  REG_TotalPlayerCount,0
TagMelee_Think_InProgressFreezeAllPlayersLoop:
#Check Players Presence
  mr  r3,REG_LoopCount
  branchl r12,0x800322c0
  cmpwi r3,0x2
  bne TagMelee_Think_InProgressFreezeAllPlayersIncLoop
#Check if player has stocks remaining
  mr  r3,REG_LoopCount
  branchl r12,0x80033bd8
  cmpwi r3,0
  ble TagMelee_Think_InProgressFreezeAllPlayersIncLoop
#Player exists, get pointers
  mr  r3,REG_LoopCount
  branchl r12,0x80034110
  mr  REG_PlayerGObj,r3
  lwz REG_PlayerData,0x2C(REG_PlayerGObj)
#Freeze bool
  li	r5,1
  lbz	r4,0x2219(REG_PlayerData)
  rlwimi r4,r5,2,29,29
  stb	r4,0x2219(REG_PlayerData)
#Remove any hitlag
  li  r4,0
  stw r4,0x195C(REG_PlayerData)
  stw r4,0x1958(REG_PlayerData)
#Skip Blastzone and Hitbox Collision Detection Code
  lbz r3,0x2219(REG_PlayerData)
  li  r4,1
  rlwimi r3,r4,6,25,25
  stb r3,0x2219(REG_PlayerData)
#Freeze GFX if not dead
  lbz r3,0x221E(REG_PlayerData)
  rlwinm. r0,r3,0,24,24
  bne TagMelee_Think_InProgressFreezeAllPlayersIncLoop
  mr  r3,REG_PlayerGObj
  branchl r12,0x8005ba40

TagMelee_Think_InProgressFreezeAllPlayersIncLoop:
  addi REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,6
  blt TagMelee_Think_InProgressFreezeAllPlayersLoop

#Set timer
  li  r3,60
  sth r3,Timer(REG_GObjData)

#Change state to frozen
  li  r3,Frozen
  stb r3,GameState(REG_GObjData)
  b TagMelee_ThinkExit


#endregion

#region Frozen
TagMelee_Think_Frozen:
#Dec Timer
  lhz r3,Timer(REG_GObjData)
  subi r3,r3,1
  sth r3,Timer(REG_GObjData)
#Check if up
  cmpwi r3,0
  bgt TagMelee_ThinkExit

#Respawn all
.set REG_LoopCount,29
.set REG_TotalPlayerCount,28
.set REG_PlayerGObj,27

#Init Loop
  li  REG_LoopCount,0
  li  REG_TotalPlayerCount,0
TagMelee_Think_FrozenRespawnAllPlayersLoop:
#Check Players Presence
  mr  r3,REG_LoopCount
  branchl r12,0x800322c0
  cmpwi r3,0x2
  bne TagMelee_Think_FrozenRespawnAllPlayersIncLoop
#Check if player has stocks remaining
  mr  r3,REG_LoopCount
  branchl r12,0x80033bd8
  cmpwi r3,0
  ble TagMelee_Think_FrozenRespawnAllPlayersIncLoop
#Get data
  mr  r3,REG_LoopCount
  branchl r12,0x80034110
  mr  REG_PlayerGObj,r3
#Remove Items + Etc
  mr  r3,REG_PlayerGObj
  branchl r12,0x800d331c
#Enter into Sleep
  mr  r3,REG_PlayerGObj
	li r4,0x1
	branchl	r12,0x800bfd9c
TagMelee_Think_FrozenRespawnAllPlayersIncLoop:
  addi REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,6
  blt TagMelee_Think_FrozenRespawnAllPlayersLoop

#Change state to start
  li  r3,Start
  stb r3,GameState(REG_GObjData)
  b TagMelee_ThinkExit

#endregion

TagMelee_ThinkExit:
restore
blr

#endregion

InjectionExit:
  li  r6,0
