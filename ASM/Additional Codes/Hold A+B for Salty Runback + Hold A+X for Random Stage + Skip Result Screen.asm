#To be inserted at 801B15E4
.include "../Globals.s"

addi	r30, r3, 0
backup
mr r28,r5

#Get all players inputs
  li  r3,4
  branchl r12,0x801a3680

#Check Inputs
  rlwinm. r0, r4, 0, 23, 23 #check A
  beq- LoadCSS
  rlwinm. r0, r4, 0, 22, 22 #check B
  bne- Runback
  rlwinm. r0, r4, 0, 21, 21 #check X
  bne RandomStage
  b LoadCSS

Runback:
  li r4,0x2 #reload match scene
  b exit

RandomStage:
  branchl r12,0x802599EC #get random stage ID

  #convert SSS ID to internal stage ID
    load r4,0x803f06D0   #load stage ID table
    mulli	r3, r3, 28     #stage ID to offset
    add r4,r4,r3         #add to start of table
    lbz r3,0xB(r4)       #get internal stage ID

  load r4,0x8045AC64     #load VS match struct

  sth r3,0x2(r4)             #store stage half to struct
  load r4,0x8043207c         #Preload Cache
  stw r3,0xC(r4)             #Store to Preload Cache
  li r4,0x2                  #reload match scene
  b exit

LoadCSS:
  li r4,0x0  #load CSS

exit:
mr r3,r30
mr r5,r28
restore
