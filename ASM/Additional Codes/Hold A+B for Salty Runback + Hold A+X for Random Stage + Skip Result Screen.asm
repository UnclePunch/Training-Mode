#To be inserted at 801B15E4
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

.set entity,31
.set player,31

addi	r30, r3, 0
backup
mr r28,r5

#START INPUT LOOP CHECK
  load r5,0x8046B108
  li r4,0x0

loop:
lwz r3,0x0(r5) #get inputs

  rlwinm. r0, r3, 0, 6, 6 #check A
  beq- checkZ
  rlwinm. r0, r3, 0, 7, 7 #check B
  beq- checkZ

runback:
  li r4,0x2 #reload match scene
  b exit

checkZ:
  rlwinm. r0, r3, 0, 5, 5 #check X
  beq increment

randomStage:
  branchl r12,0x802599EC #get random stage ID

  #convert SSS ID to internal stage ID
    load r4,0x803f06D0   #load stage ID table
    mulli	r3, r3, 28     #stage ID to offset
    add r4,r4,r3         #add to start of table
    lbz r3,0xB(r4)       #get internal stage ID

  load r4,0x8045AC64     #load VS match struct
#  lhz r5,0x2(r4)			 #get current stage
#  cmpw r3,r5            #check if same stage
#  beq randomStage

  sth r3,0x2(r4)             #store stage half to struct
  load r4,PreloadTableQueue  #Preload Cache
  stw r3,0xC(r4)             #Store to Preload Cache
  li r4,0x2                  #reload match scene
  b exit

increment:
  addi r4,r4,1
  addi r5,r5,0xC
  cmpwi r4,0x4
  blt loop

  li r4,0x0  #load CSS

exit:
mr r3,r30
mr r5,r28
restore
