#To be inserted at 801b9090
.include "../../Globals.s"

#Store Pointer to onStartMelee function
  lwz	r4, -0x77C0 (r13)
  addi	r4, r4, 3992
  bl  Rotations_Init
  mflr r5
  stw r5,0x44(r4)
  b InjectionExit

#region Rotations_Init
Rotations_Init:
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
  bl  Rotations_Think
  mflr r4
  li  r5,23
  branchl r12,GObj_AddProc

Rotations_InitExit:
restore
blr

#endregion

#region Rotations_Think
Rotations_Think:
blrl

#Registers
.set REG_GObj,31
.set REG_GObjData,30

#Data Offsets
.set GameState,0x0    #byte
.set P1Slot,0x1       #byte
.set P2Slot,0x2       #byte
.set LastPlayerSpawned,0x3  #byte

#Definitions
#GameState
  .set FirstFrame,0x0
  .set InProgress,0x1

#Constants
  .set FreezeFrames, 1 * 60

backup

#Init Pointers
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)

#Check state of game
  lbz r3,GameState(REG_GObjData)
  cmpwi r3,FirstFrame
  beq Rotations_Think_FirstFrame
  cmpwi r3,InProgress
  beq Rotations_Think_InProgress

#region FirstFrame
Rotations_Think_FirstFrame:
#Ensure over 2 players are present
  branchl r12,0x8016b558
  cmpwi r3,3
  bge Rotations_Think_FirstFrameContinue
#Destroy Think Function
  mr  r3,REG_GObj
  branchl r12,0x80390228
  b Rotations_ThinkExit

Rotations_Think_FirstFrameContinue:
.set REG_LoopCount,29
.set REG_PlayerSlotIndex,28
#Init Loop
  li  REG_LoopCount,0
  li  REG_PlayerSlotIndex,0
Rotations_Think_FirstFrameLoop:
#Check Players Presence
  mr  r3,REG_LoopCount
  branchl r12,0x800322c0
  cmpwi r3,0x2
  bne Rotations_Think_FirstFrameIncLoop
#Player exists, store to data
  addi r3,REG_GObjData,P1Slot
  stbx REG_LoopCount,REG_PlayerSlotIndex,r3
#Store as last player spawned
  stb REG_LoopCount,LastPlayerSpawned(REG_GObjData)
#Now do next player
  addi REG_PlayerSlotIndex,REG_PlayerSlotIndex,1
#Check if finished doing both players
  cmpwi REG_PlayerSlotIndex,2
  bge Rotations_Think_FirstFrameSleepRemainingPlayersIncLoop
Rotations_Think_FirstFrameIncLoop:
  addi REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,6
  blt Rotations_Think_FirstFrameLoop

#Now sleep the other players
Rotations_Think_FirstFrameSleepRemainingPlayersLoop:
.set REG_PlayerGObj,27
#Check Players Presence
  mr  r3,REG_LoopCount
  branchl r12,0x800322c0
  cmpwi r3,0x2
  bne Rotations_Think_FirstFrameSleepRemainingPlayersIncLoop
#Get players GObj
  mr  r3,REG_LoopCount
  branchl r12,0x80034110
  mr  REG_PlayerGObj,r3
#Sleep player
  branchl r12,0x800bfd04
#Check if they have a follower
  lwz r3,0x2C(REG_PlayerGObj)
  lbz r3,0x2222(r3)
  rlwinm.	r0, r3, 30, 31, 31
  beq Rotations_Think_FirstFrameSleepRemainingPlayers_DestroyHUD
#Get Follower GObj
  mr  r3,REG_LoopCount
  li  r4,1
  branchl r12,0x8003418c
#SLeep them as well
  branchl r12,0x800bfd04
Rotations_Think_FirstFrameSleepRemainingPlayers_DestroyHUD:
#Destroy their percent HUD
  load r3,0x804a10c8
  mulli r4,REG_LoopCount,100
  add r3,r3,r4
  lbz	r4, 0x0010 (r3)
  li  r5,1
  rlwimi r4,r5,7,24,24
  rlwimi r4,r5,6,25,25
  stb	r4, 0x0010 (r3)

Rotations_Think_FirstFrameSleepRemainingPlayersIncLoop:
  addi REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,6
  blt Rotations_Think_FirstFrameSleepRemainingPlayersLoop

#Change state to every frame
  li  r3,InProgress
  stb r3,GameState(REG_GObjData)

  b Rotations_ThinkExit
#endregion

#region InProgress
Rotations_Think_InProgress:
#Check For Dead Players
.set REG_PlayerSlot,29
.set REG_PlayerSlotIndex,28
.set REG_PlayerGObj,27
#Init Loop
  li  REG_PlayerSlotIndex,0

#################################
## Check For Dead Players Loop ##
#################################
Rotations_Think_InProgressLoop:
#Get Players Slot
  addi r3,REG_GObjData,P1Slot
  lbzx  REG_PlayerSlot,REG_PlayerSlotIndex,r3
#Get Players GObj
  mr  r3,REG_PlayerSlot
  branchl r12,0x80034110
  mr  REG_PlayerGObj,r3
  lwz r3,0x2C(r3)
#Check If Player is still active (not sleep)
  lbz r4,0x221F(r3)
  rlwinm. r4,r4,0,27,27
  bne Rotations_Think_InProgressIncLoop
#Check if READY,GO is over
  lbz r4,0x221D(r3)
  rlwinm. r4,r4,0,28,28
  bne Rotations_Think_InProgressIncLoop
#Check if Blastzone code is being skipped
  lbz r4,0x2219(r3)
  rlwinm. r4,r4,0,25,25
  beq Rotations_Think_InProgressIncLoop
#Rebirth gets here too, check if NOT rebirth/rebirthWait
  lwz r4,0x10(r3)
  cmpwi r4,ASID_Rebirth
  beq Rotations_Think_InProgressIncLoop
  cmpwi r4,ASID_RebirthWait
  beq Rotations_Think_InProgressIncLoop
#If in any Star KO State, enter them into DeadUp
  cmpwi r4,ASID_DeadUpStar
  beq Rotations_Think_InProgressEnterDeadUp
  cmpwi r4,ASID_DeadUpStarIce
  beq Rotations_Think_InProgressEnterDeadUp
  cmpwi r4,ASID_DeadUpFall
  beq Rotations_Think_InProgressEnterDeadUp
  b  Rotations_Think_InProgressCheckDeadFrame
Rotations_Think_InProgressEnterDeadUp:
#Enter DeadUp
  mr  r3,REG_PlayerGObj
  branchl r12,0x800d3e40
  b Rotations_Think_InProgressIncLoop
Rotations_Think_InProgressCheckDeadFrame:
#Here we know the player is in a dead state
#Ensure he is in frame X of the dead animation
  lwz r3,0x2C(REG_PlayerGObj)
  lwz r4,0x2340(r3)
  cmpwi r4,1
  bgt Rotations_Think_InProgressIncLoop

#################################
## Search For Next Player Loop ##
#################################
Rotations_Think_InProgressSearchForNextPlayer:
.set REG_LoopCount,26
.set REG_OtherPlayerSlot,25
.set REG_LastPlayerSpawned,24

#Get other player
  xori r3,REG_PlayerSlotIndex,0x1
  addi r4,REG_GObjData,P1Slot
  lbzx REG_OtherPlayerSlot,r3,r4
#Loop starts at LastPlayerSpawned+1
  lbz REG_LastPlayerSpawned,LastPlayerSpawned(REG_GObjData)
  mr REG_LoopCount,REG_LastPlayerSpawned
  b Rotations_Think_InProgressSearchForNextPlayerIncLoop
Rotations_Think_InProgressSearchForNextPlayerLoop:
#Player who just died is in REG_PlayerSlot
#Player who is alive is in REG_OtherPlayerSlot
#Check if player is present
  mr  r3,REG_LoopCount
  branchl r12,0x800322c0
  cmpwi r3,0x2
  bne Rotations_Think_InProgressSearchForNextPlayerIncLoop
#Ensure this isnt the player who just died
  cmpw REG_LoopCount,REG_PlayerSlot
  beq Rotations_Think_InProgressSearchForNextPlayerIncLoop
#Ensure this isnt the other player
  cmpw REG_LoopCount,REG_OtherPlayerSlot
  beq Rotations_Think_InProgressSearchForNextPlayerIncLoop
#This is a unique player, check if they have stock remainings
  mr  r3,REG_LoopCount
  branchl r12,0x80033bd8
  cmpwi r3,0
  ble Rotations_Think_InProgressSearchForNextPlayerIncLoop
#Get GObj First
  mr  r3,REG_LoopCount
  branchl r12,0x80034110
#Respawn
	li r4,0x1
	branchl	r12,0x800bfd9c
#Save their slot to the GObjData
  addi r3,REG_GObjData,P1Slot
  stbx REG_LoopCount,REG_PlayerSlotIndex,r3
#Save this as the last player spawned
  stb REG_LoopCount,LastPlayerSpawned(REG_GObjData)
#Now enter the recently deceased player into perm sleep
  mr  r3,REG_PlayerGObj
  branchl r12,0x800bfd04
#Check if they have a follower
  lwz r4,0x2C(REG_PlayerGObj)
  lbz r3,0x2222(r4)
  rlwinm.	r0, r3, 30, 31, 31
  beq Rotations_Think_InProgressIncLoop
#Get Follower GObj
  lbz r3,0xC(r4)
  li  r4,1
  branchl r12,0x8003418c
#SLeep them as well
  branchl r12,0x800bfd04
  b Rotations_Think_InProgressIncLoop
Rotations_Think_InProgressSearchForNextPlayerIncLoop:
  addi REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,6
  blt Rotations_Think_InProgressSearchForNextPlayerIncLoopCheckIfDone
#Player count is over 6, loop back to 0
  li  REG_LoopCount,0
Rotations_Think_InProgressSearchForNextPlayerIncLoopCheckIfDone:
#Now check if we did a full loop
  cmpw REG_LoopCount,REG_LastPlayerSpawned
  bne Rotations_Think_InProgressSearchForNextPlayerLoop
#If we get here, no other players are reported as alive, so do nothing for normal respawn behvior

Rotations_Think_InProgressIncLoop:
  addi REG_PlayerSlotIndex,REG_PlayerSlotIndex,1
  cmpwi REG_PlayerSlotIndex,2
  blt Rotations_Think_InProgressLoop
#Neither player is dead, exit think function
  b Rotations_ThinkExit

#endregion

Rotations_ThinkExit:
restore
blr

#endregion

InjectionExit:
  li  r6,0
