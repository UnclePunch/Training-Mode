#To be inserted at 80265220
.include "../../Globals.s"

#Check If Player Won Last Game
  mr  r3,r29
  bl  CheckIfWonLastGame
  cmpwi r3,0x0
  beq Exit

#Change Text Color
  lwz	r3, 0 (r27)
  li  r4,0
  load r5,0xFFD70000
  stw r5,0x100(sp)
  addi r5,sp,0x100
  branchl r12,0x803a74f0
  b Exit

#########################################################

CheckIfWonLastGame:
.set MatchEndStruct,31
.set MatchEndPlayerStruct,30
.set PlayerSlot,29

backup

mr  PlayerSlot,r3
load  MatchEndStruct,0x80479da4
mulli MatchEndPlayerStruct,PlayerSlot,0xA8
add   MatchEndPlayerStruct,MatchEndPlayerStruct,MatchEndStruct

#Check if last game data exists
  lbz r3,0x4(MatchEndStruct)
  cmpwi r3,0x0
  beq  CheckIfWonLastGame_DidNotWin

#Check if last game was same Mode (Teams/FFA)
  load r3,0x8046b6a0
  lbz r3,0x24D0(r3)
  lbz r4,0x6(MatchEndStruct)
  cmpw r3,r4
  bne CheckIfWonLastGame_DidNotWin

#Check if player partook in last game
  lbz r3,0x58(MatchEndPlayerStruct)
  cmpwi r3,3
  beq CheckIfWonLastGame_DidNotWin

#Check if last game was an LRA Start
  lbz r3,0x4(MatchEndStruct)
  cmpwi r3,0x7
  bne CheckIfWonLastGame_CheckForTeams
  #Check if this was a team LRA Start
    lbz r3,0x6(MatchEndStruct)
    cmpwi r3,0x1
    bne CheckIfWonLastGame_FFA_LRAStart
    CheckIfWonLastGame_Team_LRAStart:
    #Check who LRA started
      lbz r3,0x0(MatchEndStruct)
    #Get his team ID
      mulli r3,r3,0xA8
      add   r3,r3,MatchEndStruct
      lbz   r3,0x5F(r3)
    #Get current players team ID
      lbz   r4,0x5F(MatchEndPlayerStruct)
    #Check If Same Team
      cmpw  r3,r4
      beq CheckIfWonLastGame_DidNotWin
      b CheckIfWonLastGame_Won

    CheckIfWonLastGame_FFA_LRAStart:
    #Check who LRA started
      lbz r3,0x0(MatchEndStruct)
      #If this player did, return 0
        cmpw r3,PlayerSlot
        beq CheckIfWonLastGame_DidNotWin
        b CheckIfWonLastGame_Won

CheckIfWonLastGame_CheckForTeams:
#Check if Teams Match
  lbz r3,0x6(MatchEndStruct)
  cmpwi r3,0x1
  bne CheckIfWonLastGame_FFA
  #If so find winning team
    mr  r3,MatchEndStruct
    branchl r12,0x801654a0
  #Check this players team
    lbz   r4,0x5F(MatchEndPlayerStruct)
  #If this player was on winning team, return 1, if not return 0
    cmpw r3,r4
    beq CheckIfWonLastGame_Won
    b CheckIfWonLastGame_DidNotWin

CheckIfWonLastGame_FFA:
#Check If Player Won
  lbz   r3,0x5D(MatchEndPlayerStruct)
   #if so return 1, if not return 0
   cmpwi  r3,0
   beq  CheckIfWonLastGame_Won
   b CheckIfWonLastGame_DidNotWin

CheckIfWonLastGame_DidNotWin:
li  r3,0
b 0x8
CheckIfWonLastGame_Won:
li  r3,1

restore
blr

#########################################################

Exit:
  lbz	r0, -0x49AB (r13)
