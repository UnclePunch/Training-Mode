#To be inserted at 8015cf60
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

#r3 = event
#r4 = event score pointer

.set REG_EventID,3
.set REG_EventScorePointer,4
.set REG_PageID,5
.set REG_HighScoreTable,6

backup

#Get page ID
  lbz REG_PageID,CurrentEventPage(REG_EventScorePointer)
#Get event's score offset using table
  bl  EventHighScores
  mflr REG_HighScoreTable
  lbzx REG_PageID,REG_PageID,REG_HighScoreTable
#Multiply and add to score pointer
  mulli REG_PageID,REG_PageID,4
  add REG_EventScorePointer,REG_PageID,REG_EventScorePointer
#Now this events offset
  mulli REG_EventID,REG_EventID,4
  add REG_EventScorePointer,REG_EventID,REG_EventScorePointer
#Load score
  lwz	r3, 0x1A70 (REG_EventScorePointer)
  b Exit

EventHighScores

Exit:
restore
blr
