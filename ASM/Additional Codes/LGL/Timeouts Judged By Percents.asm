#To be inserted at 80165c48
.include "../../Globals.s"

.set  REG_MatchData,31
.set  REG_Winners,30

.set  MaxLedgegrabs,60

#Init
  backupall
  mr  REG_MatchData,r3

#Ensure match timed out
  lbz r3,0x4(REG_MatchData)
  cmpwi r3,0x1
  bne Exit

#Get all winners
.set  OFST_NumOfWinners,0x0
.set  OFST_StartWinners,0x1
.set  REG_Count,29
  addi  REG_Winners,sp,0x80
  li  REG_Count,0
  li  r3,0
  stw r3,0x0(REG_Winners)
  stw r3,0x4(REG_Winners)
GetWinnersLoop:
  mulli r3,REG_Count,0xA8
  add r4,r3,REG_MatchData
#Check if valid player
  lbz r3,0x58(r4)
  cmpwi r3,3
  beq GetWinnersIncLoop
#Check if won
  lbz r3,0x5D(r4)
  cmpwi r3,0
  bne GetWinnersIncLoop
#Add to list
  lbz r3,OFST_NumOfWinners(REG_Winners)
  addi  r3,r3,1
  stb r3,OFST_NumOfWinners(REG_Winners)
  addi  r4,REG_Winners,OFST_StartWinners
  subi  r3,r3,1
  stbx  REG_Count,r3,r4
GetWinnersIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt GetWinnersLoop

#Check if more than one winner
  lbz r3,OFST_NumOfWinners(REG_Winners)
  cmpwi r3,1
  ble  TieBreakerExit

#Get player with the lowest percent
.set  REG_LowestPercentPlayer,29
.set  REG_LowestPercent,28
  li  REG_LowestPercentPlayer,0
GetLowestPercentLoop:
#Get this players percent
  addi  r3,REG_Winners,OFST_StartWinners
  lbzx  r3,r3,REG_LowestPercentPlayer
  branchl r12,0x800342b4
  mr  REG_LowestPercent,r3

#Now compare against all other winners
.set  REG_ComparePercentCount,27
  li  REG_ComparePercentCount,0
ComparePercentLoop:
#First check if this is the player with the current lowest percent
  cmpw  REG_ComparePercentCount,REG_LowestPercentPlayer
  beq ComparePercentIncLoop
#Now get this players percent
  addi  r3,REG_Winners,OFST_StartWinners
  lbzx  r3,r3,REG_ComparePercentCount
  branchl r12,0x800342b4
#Check if its lower
  cmpw  r3,REG_LowestPercent
  bge ComparePercentIncLoop
#Found a new low percent, start checking with this one
  mr  REG_LowestPercentPlayer,REG_ComparePercentCount
  b GetLowestPercentLoop
ComparePercentIncLoop:
  addi  REG_ComparePercentCount,REG_ComparePercentCount,1
  lbz r3,OFST_NumOfWinners(REG_Winners)
  cmpw REG_ComparePercentCount,r3
  blt ComparePercentLoop
#No other player has a lower percent, this player is the winner
  b DeclareNewWinner
GetLowestPercentIncLoop:
  addi  REG_LowestPercentPlayer,REG_LowestPercentPlayer,1
  b GetLowestPercentLoop


DeclareNewWinner:
.set  REG_Count,27
  li  REG_Count,0
DeclareNewWinnerLoop:
#Get this players ID
  addi  r3,REG_Winners,OFST_StartWinners
  lbzx  r4,r3,REG_Count
#Get their offset in the match data
  mulli r3,r4,0xA8
  add r3,r3,REG_MatchData
#Check if this player is the winner
  addi  r5,REG_Winners,OFST_StartWinners
  lbzx  r5,r5,REG_LowestPercentPlayer
  cmpw  r4,r5
  beq DeclareNewWinnerLoop_IsWinner
DeclareNewWinnerLoop_IsLoser:
  li  r4,1
  b DeclareNewWinnerLoop_StorePlacing
DeclareNewWinnerLoop_IsWinner:
  li  r4,0
DeclareNewWinnerLoop_StorePlacing:
  stb r4,0x5D(r3)
  stb r4,0x5E(r3)
DeclareNewWinnerIncLoop:
  addi  REG_Count,REG_Count,1
  lbz r3,OFST_NumOfWinners(REG_Winners)
  cmpw REG_Count,r3
  blt DeclareNewWinnerLoop

#Check for any other players with this percent
CheckForDraw:
.set  REG_Count,27
.set  REG_CurrentPlayerID,26
  li  REG_Count,0
CheckForDrawLoop:
#Get this players ID
  addi  r3,REG_Winners,OFST_StartWinners
  lbzx  REG_CurrentPlayerID,r3,REG_Count
#Check if this is the player with the lowest
  addi  r3,REG_Winners,OFST_StartWinners
  lbzx  r3,r3,REG_LowestPercentPlayer
  cmpw  REG_CurrentPlayerID,r3
  beq CheckForDrawIncLoop
#Get this players percent
  mr  r3,REG_CurrentPlayerID
  branchl r12,0x800342b4
#Check if the same as the lowest
  cmpw  r3,REG_LowestPercent
  bne CheckForDrawIncLoop
#This players percent is the same as the lowest percent, he should win as well
  mulli r3,REG_CurrentPlayerID,0xA8
  add r3,r3,REG_MatchData
  li  r4,0
  stb r4,0x5D(r3)
  stb r4,0x5E(r3)
CheckForDrawIncLoop:
  addi  REG_Count,REG_Count,1
  lbz r3,OFST_NumOfWinners(REG_Winners)
  cmpw REG_Count,r3
  blt CheckForDrawLoop
TieBreakerExit:
##############################
## Now check for ledgegrabs ##
##############################

#Check if all winners have 60 or more ledgegrabs
#Get all winners
.set  REG_Count,29
.set  REG_WinnerCount,28
  li  REG_Count,0
  li  REG_WinnerCount,0
CheckIfAllMaxLedgegrabs:
  mulli r3,REG_Count,0xA8
  add r4,r3,REG_MatchData
#Check if valid player
  lbz r3,0x58(r4)
  cmpwi r3,3
  beq CheckIfAllMaxLedgegrabs_IncLoop
#Check if won
  lbz r3,0x5D(r4)
  cmpwi r3,0
  bne CheckIfAllMaxLedgegrabs_IncLoop
#Check if over 60 ledgegrabs
  mr  r3,REG_Count
  branchl r12,0x80040af0
  cmpwi r3,MaxLedgegrabs
  blt CheckIfAllMaxLedgegrabs_IncLoop
#Increment Winner Count
  addi  REG_WinnerCount,REG_WinnerCount,1
CheckIfAllMaxLedgegrabs_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt CheckIfAllMaxLedgegrabs
#If more than 1 winner had over 60 LGs, dont adjust placings
  cmpwi REG_WinnerCount,1
  bgt Exit
#If 0 winners had over 60 LGs, dont adjust placings
  cmpwi REG_WinnerCount,0
  beq Exit

LosersWin:
.set  REG_Count,29
  li  REG_Count,0
LosersWin_Loop:
  mulli r3,REG_Count,0xA8
  add r4,r3,REG_MatchData
#Check if valid player
  lbz r3,0x58(r4)
  cmpwi r3,3
  beq LosersWin_IncLoop
#Check if got first OR second
  lbz r3,0x5D(r4)
  cmpwi r3,0
  beq LosersWin_CheckLG
  cmpwi r3,1
  beq LosersWin_CheckLG
  b LosersWin_IncLoop
LosersWin_CheckLG:
#Check if over 60 ledgegrabs
  mr  r3,REG_Count
  branchl r12,0x80040af0
  cmpwi r3,MaxLedgegrabs
  bge LosersWin_IncLoop
#Make this player win
  mulli r3,REG_Count,0xA8
  add r4,r3,REG_MatchData
  li  r3,0
  stb r3,0x5D(r4)
  stb r3,0x5E(r4)
LosersWin_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt LosersWin_Loop

#Make all winners with 60 or more ledgegrabs lose
MaxLedgegrabsLose:
.set  REG_Count,29
  li  REG_Count,0
MaxLedgegrabsLose_Loop:
  mulli r3,REG_Count,0xA8
  add r4,r3,REG_MatchData
#Check if valid player
  lbz r3,0x58(r4)
  cmpwi r3,3
  beq MaxLedgegrabsLose_IncLoop
#Check if won
  lbz r3,0x5D(r4)
  cmpwi r3,0
  bne MaxLedgegrabsLose_IncLoop
#Check if over 60 ledgegrabs
  mr  r3,REG_Count
  branchl r12,0x80040af0
  cmpwi r3,MaxLedgegrabs
  blt MaxLedgegrabsLose_IncLoop
#Make this player lose
  mulli r3,REG_Count,0xA8
  add r4,r3,REG_MatchData
  li  r3,1
  stb r3,0x5D(r4)
  stb r3,0x5E(r4)
MaxLedgegrabsLose_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,6
  blt MaxLedgegrabsLose_Loop

Exit:
  restoreall
  lbz	r0, 0x000F (r3)
