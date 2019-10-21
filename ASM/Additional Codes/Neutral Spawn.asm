#To be inserted at 8016e510
.include "../Globals.s"


.set MatchInfo,31
.set SpawnTable,30
.set REG_PlayerSlot,28

backup

#Don't run in singleplayer
  branchl r12,0x8016b41c
  cmpwi r3,0
  bne Exit
#Don't run for players 5 and 6
  cmpwi REG_PlayerSlot,5
  bge Exit

#Check if teams
  lbz	r3, 0x24D0 (MatchInfo)
  cmpwi r3,1
  beq isTeams

#region isSingles
isSingles:
#Get this players spawn order
.set LoopCount,26
.set SpawnOrder,25
  li  SpawnOrder,0
  li  LoopCount,0
isSingles_Loop:
#Load slot type
  mr  r3,LoopCount
  branchl r12,PlayerBlock_LoadSlotType
  cmpwi r3,0x3
  beq isSingles_IncLoop      #If =3, no player present
#Player is present, check if this is the one were looking for
  cmpw REG_PlayerSlot,LoopCount
  beq isSingles_Exit
#Increment offset
  addi  SpawnOrder,SpawnOrder,1
isSingles_IncLoop:
  addi LoopCount,LoopCount,1
  cmpwi LoopCount,4
  ble isSingles_Loop
isSingles_Exit:
  mr  r3,REG_PlayerSlot
  mr  r4,SpawnOrder
  lbz	r5, 0x24D0 (MatchInfo)
  bl  SetSpawn
  b Exit
#endregion

#region isTeams
isTeams:
CheckIf2v2:
.set REG_TeamID,26
  li  REG_TeamID,0
CheckIf2v2_Loop:
#Check how many players are on this team
  GetTeamCount:
  .set REG_Count,25
  .set REG_TeamMembers,24
    li  REG_TeamMembers,0
    li  REG_Count,0
  GetTeamCount_Loop:
  #Load slot type
    mr  r3,REG_Count
    branchl r12,PlayerBlock_LoadSlotType
    cmpwi r3,0x3
    beq GetTeamCount_IncLoop      #If =3, no player present
  #Get Team
    mr  r3,REG_Count
    branchl r12,0x80033370
    cmpw  r3,REG_TeamID
    bne GetTeamCount_IncLoop
  #Increment team members
    addi  REG_TeamMembers,REG_TeamMembers,1
  GetTeamCount_IncLoop:
    addi  REG_Count,REG_Count,1
    cmpwi REG_Count,4
    blt GetTeamCount_Loop
#If =1 or >2, exit
  cmpwi REG_TeamMembers,1
  beq Exit
  cmpwi REG_TeamMembers,2
  bgt Exit
CheckIf2v2_IncLoop:
  addi  REG_TeamID,REG_TeamID,1
  cmpwi REG_TeamID,3
  blt CheckIf2v2_Loop


#Create an array
CreateTeamArray:
.set REG_TeamID,25
.set REG_TeamArray,26
.set REG_ArraySize,24
  li  REG_TeamID,0
  addi  REG_TeamArray,sp,0x80
  li  REG_ArraySize,0
CreateTeamArray_Loop:
#Check how many players are on this team
  CheckTeam:
  .set REG_Count,23
  .set REG_TeamMembers,22
    li  REG_TeamMembers,0
    li  REG_Count,0
  CheckTeam_Loop:
  #Load slot type
    mr  r3,REG_Count
    branchl r12,PlayerBlock_LoadSlotType
    cmpwi r3,0x3
    beq CheckTeam_IncLoop      #If =3, no player present
  #Get Team
    mr  r3,REG_Count
    branchl r12,0x80033370
    cmpw  r3,REG_TeamID
    bne CheckTeam_IncLoop
  #Add to array
    stbx  REG_Count,REG_ArraySize,REG_TeamArray
    addi  REG_ArraySize,REG_ArraySize,1
  CheckTeam_IncLoop:
    addi  REG_Count,REG_Count,1
    cmpwi REG_Count,4
    blt CheckTeam_Loop
CreateTeamArray_IncLoop:
  addi  REG_TeamID,REG_TeamID,1
  cmpwi REG_TeamID,3
  blt CreateTeamArray_Loop

#Now search for this players ID
SearchForPlayerID:
.set  REG_Count,25
  li  REG_Count,0
SearchForPlayerID_Loop:
  lbzx  r3,REG_Count,REG_TeamArray
  cmpw  r3,REG_PlayerSlot
  beq SearchForPlayerID_Exit
SearchForPlayerID_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,4
  blt SearchForPlayerID_Loop
SearchForPlayerID_Exit:
  mr  r3,REG_PlayerSlot
  mr  r4,REG_Count
  lbz	r5, 0x24D0 (MatchInfo)
  bl  SetSpawn
  b Exit
#endregion

#region SetSpawn
SetSpawn:
.set  REG_PlayerSlot,31
.set  REG_SpawnID,30
.set  REG_IsTeams,29
.set  REG_SpawnTable,28

#Init
  backup
  mr  REG_PlayerSlot,r3
  mr  REG_SpawnID,r4
  mr  REG_IsTeams,r5

#Get Neutral Spawn Table
  bl NeutralSpawnTable
  mflr REG_SpawnTable

#Get stage ID
  lwz		r6,-0x6CB8 (r13)
  li    r5,0
#Get stage's spawn info
SetSpawn_StageSearchLoop:
  lwz   r3,StageID(REG_SpawnTable)            #get stage ID
  cmpwi r3,-1                     #check for end of table
  beq   SetSpawn_NotFound
  cmpw  r3,r6             #check for matching stage ID
  beq SetSpawn_FoundStage
  addi  REG_SpawnTable,REG_SpawnTable,EntryLength
  b SetSpawn_StageSearchLoop

SetSpawn_FoundStage:
#Get Players Spawn Point and Facing Direction Pointer
  addi REG_SpawnTable,REG_SpawnTable,SpawnData      #Skip past stage ID
  mulli r3,REG_IsTeams,SpawnDataLength
  add REG_SpawnTable,REG_SpawnTable,r3              #Get to teams/singles data
  mulli r3,REG_SpawnID,SpawnDataLengthPerPlayer     #Get to this players data
  add REG_SpawnTable,REG_SpawnTable,r3

#Set players new spawn coordinates
  addi  r4,sp,0x80
  lfs f1,SpawnX(REG_SpawnTable)
  stfs  f1,0x0(r4)
  lfs f1,SpawnY(REG_SpawnTable)
  stfs  f1,0x4(r4)
  li  r3,0
  stw  r3,0x8(r4)
  mr  r3,REG_PlayerSlot
  branchl r12,0x80032768
  b SetSpawn_UpdateFacingDirection

SetSpawn_NotFound:
#If singles, use spawn order
  cmpwi REG_IsTeams,1
  beq SetSpawn_NotFound_Teams
  mr  r3,REG_SpawnID
  b SetSpawn_NotFound_UpdatePosition
SetSpawn_NotFound_Teams:
  bl  NeutralSpawnTable_NotFound
  mflr  r3
  lbzx  r3,r3,REG_SpawnID
  b SetSpawn_NotFound_UpdatePosition
SetSpawn_NotFound_UpdatePosition:
#Get XYZ from spawn ID
  addi  r4,sp,0x80
  branchl r12,0x80224e64
#Set new XYZ spawn
  mr  r3,REG_PlayerSlot
  addi  r4,sp,0x80
  branchl r12,0x80032768
  b SetSpawn_UpdateFacingDirection

SetSpawn_UpdateFacingDirection:
#Load X Position
  mr  r3,REG_PlayerSlot
  addi  r4,sp,0x80
  branchl r12,0x800326cc
  lfs f1,0x80(sp)
#Compare to 0
  lfs	f0, -0x5718 (rtoc)
  fcmpo cr0,f1,f0
  ble SetSpawn_UpdateFacingDirection_FacingRight
SetSpawn_UpdateFacingDirection_FacingLeft:
  lfs	f1, -0x5708 (rtoc)
  b SetSpawn_UpdateFacingDirection_Store
SetSpawn_UpdateFacingDirection_FacingRight:
  lfs	f1, -0x5734 (rtoc)
SetSpawn_UpdateFacingDirection_Store:
#Update Facing Direction
  mr  r3,REG_PlayerSlot
  branchl r12,0x80033094

SetSpawn_AdjustEntryFrames:
  mr  r3,REG_PlayerSlot
  mulli r4,REG_SpawnID,5
  branchl r12,0x80035fdc

SetSpawn_Exit:
  restore
  blr
#endregion

######################
NeutralSpawnTable:
blrl
.set  EntryLength,0x4 + SpawnDataLength * 2
.set  SpawnDataLength,0x8 *4
.set  SpawnDataLengthPerPlayer,0x8

.set  StageID,0x0
.set  SpawnData,0x4
  .set  SpawnX,0x0
  .set  SpawnY,0x4

#FD
.long 0x20                  #Stage ID
  #Singles Data
    .float -60,10
    .float 60,10
    .float -20,10
    .float 20,10
  #Teams Data
    .float -20,10
    .float -60,10
    .float 20,10
    .float 60,10
#Battlefield
.long 0x1F                  #Stage ID
  #Singles Data
    .float -38.8,35.2
    .float 38.8,35.2
    .float 0,8
    .float 0,62.4
  #Teams Data
    .float -38.8,35.2
    .float -38.8,5
    .float 38.8,35.2
    .float 38.8,5
#Yoshi's Story
.long 0x08                  #Stage ID
  #Singles Data
    .float -42,26.6
    .float 42,28
    .float 0,46.9
    .float 0,4.9
  #Teams Data
    .float -42,26.6
    .float -42,5
    .float 42,28
    .float 42,5
#Dream Land
.long 0x1C                  #Stage ID
  #Singles Data
    .float -46.6,37.2
    .float 47.4,37.3
    .float 0,7
    .float 0,58.5
  #Teams Data
    .float -46.6,37.2
    .float -46.6,5
    .float 47.4,37.3
    .float 47.4,5
#FoD
.long 0x02                  #Stage ID
  #Singles Data
    .float -41.25,21
    .float 41.25,27
    .float 0,5.25
    .float 0,48
  #Teams Data
    .float -41.25,21
    .float -41.25,5
    .float 41.25,27
    .float 41.25,5
#Pokemon Stadium
.long 0x03                  #Stage ID
  #Singles Data
    .float -40,32
    .float 40,32
    .float 70,7
    .float -70,7
  #Teams Data
    .float -40,32
    .float -40,5
    .float 40,32
    .float 40,5
#Terminator
.long -1
.align 2

NeutralSpawnTable_NotFound:
blrl
#Doubles
.long 0x00030102
.align 2
######################

Exit:
  restore
  lbz	r0, 0x24D0 (r31)
