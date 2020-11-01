#To be inserted at 801a5b14
.include "../Globals.s"

.set REG_LoopCount,29

#Init loop
  li  REG_LoopCount,0
Loop:
#Get players inputs
  mr  r3,REG_LoopCount
  branchl r12,0x801a3680

#Check Inputs
  rlwinm. r0, r4, 0, 23, 23 #check A
  beq- LoopInc
  rlwinm. r0, r4, 0, 22, 22 #check B
  bne- Runback
  rlwinm. r0, r4, 0, 21, 21 #check X
  bne RandomStage

LoopInc:
  addi  REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,4
  blt Loop
  b LoadCSS

Runback:
  li r27,0x2 #reload match scene
  b exit

RandomStage:
  branchl r12,0x802599EC #get random stage ID

#convert SSS ID to internal stage ID
  load r4,0x803f06D0   #load stage ID table
  mulli	r3, r3, 28     #stage ID to offset
  add r4,r4,r3         #add to start of table
  lbz r3,0xB(r4)       #get internal stage ID
#Store to match struct
  load r4,0x8045AC64     #load VS match struct
  sth r3,0x2(r4)             #store stage half to struct
#Store to preload table
  load r4,0x8043207c         #Preload Cache
  stw r3,0xC(r4)             #Store to Preload Cache
#Request Load
  branchl r12,0x80018254

  li r27,0x2                  #reload match scene
  b exit

LoadCSS:
  li r27,0 # 4 is results

exit:
Original:
  li	r29, 0
