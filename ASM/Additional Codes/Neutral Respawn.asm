#To be inserted at 8016721c
.include "../Globals.s"

.set PlayerSlot,27
.set StaticBlock,26
.set SpawnTable,25
.set SpawnOrder,24
.set SpawnID,23

backup

#Don't run in singleplayer
  branchl r12,0x8016b41c
  cmpwi r3,0
  bne Original
#Don't run for players 5 and 6
  cmpwi PlayerSlot,5
  bge Original

#Get static block
  mr  r3,PlayerSlot
  branchl r12,Playerblock_LoadStaticBlock
  mr  StaticBlock,r3

#Get Neutral Spawn Table
  bl NeutralRespawnTable
  mflr SpawnTable

#Get this players spawn order
  mr  r3,PlayerSlot
  bl  GetSpawnOrder
  mr  SpawnOrder,r3

#Get stage ID
  lwz		r6,-0x6CB8 (r13)
  li    r5,0
#Get stage's spawn info
StageSearchLoop:
  mulli r4,r5,0x5         #table length
  add   r4,r4,SpawnTable  #get stage start
  lbz   r3,0x0(r4)        #get stage ID
  extsb r3,r3
  cmpwi r3,-1             #check for end of table
  beq   Original
  cmpw  r3,r6             #check for matching stage ID
  addi  r5,r5,1           #inc count
  bne   StageSearchLoop

#Get ID
  addi r4,r4,1            #Skip past stage ID
  lbzx r3,SpawnOrder,r4

  b Exit

######################
GetSpawnOrder:
.set LoopCount,31
.set SpawnOrder,30
.set PlayerSlot,28

backup
#Init variables
  mr  PlayerSlot,r3
  li  SpawnOrder,0
  li  LoopCount,0

#Start Loop
GetSpawnOrder_Loop:
#Load slot type
  mr  r3,LoopCount
  branchl r12,PlayerBlock_LoadSlotType
  cmpwi r3,0x1
  bgt GetSpawnOrder_IncLoop      #If >1, no player present
#Player is present, check if this is the one were looking for
  cmpw PlayerSlot,LoopCount
  beq GetSpawnOrder_Exit
#Increment offset
  addi  SpawnOrder,SpawnOrder,1

GetSpawnOrder_IncLoop:
  addi LoopCount,LoopCount,1
  cmpwi LoopCount,4
  ble GetSpawnOrder_Loop

GetSpawnOrder_Exit:
  mr  r3,SpawnOrder    #Return spawn order
  restore
  blr
######################
NeutralRespawnTable:
blrl
#FD
.byte 0x20                  #Stage ID
.byte 0x00,0x01,0x02,0x03   #Nuetral Spawn Index
#Battlefield
.byte 0x1F                  #Stage ID
.byte 0x02,0x03,0x00,0x01   #Nuetral Spawn Index
#Yoshi's Story
.byte 0x08                  #Stage ID
.byte 0x00,0x01,0x03,0x02   #Nuetral Spawn Index
#Dream Land
.byte 0x1C                  #Stage ID
.byte 0x01,0x03,0x00,0x02   #Nuetral Spawn Index
#FoD
.byte 0x02                  #Stage ID
.byte 0x00,0x01,0x02,0x03   #Nuetral Spawn Index
#Pokemon Stadium
.byte 0x03                  #Stage ID
.byte 0x00,0x01,0x02,0x03   #Nuetral Spawn Index
#Terminator
.byte 0xFF
.align 2
######################

Original:
restore
addi	r3, r27, 0
b Skip
Exit:
restore
Skip:
