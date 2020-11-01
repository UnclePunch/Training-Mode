#To be inserted at 8008f71c
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

#Get Victims Data
  lwz r6,0x2C(r31)
#Get Attacker GObj
  lwz r5,0x1868(r6)
#If Pointer doesn't exist, its most likely environmental damage (break the targets walls)
  cmpwi r5,0x0
  beq ResetSDICount
#Check if Player
  lhz r0,0(r5)        #Entity Type
  lwz r5,0x2C(r5)     #Get Attacker Data
  cmpwi r0,4          #Player
  beq LastPlayerMove
  cmpwi r0,6          #Item
  beq LastItemMove
  b  exit             #If neither, exit

LastPlayerMove:
#Get current Move Instance from attacker
  lhz r4,0x2088(r5)
  b   GetLastMoveVictimHitBy
LastItemMove:
#Get current Move Instance from attacker
  lhz r4,0xDA8(r5)

GetLastMoveVictimHitBy:
#Get last Move Instance Victim was hit by
  lhz r3,TM_PreviousMoveInstanceHitBy(r6)

#If the move instance is 0, was most likely a stage element (corneria lasers)
  cmpwi r4,0
  beq ResetSDICount

#Check If New Hit
  cmpw	r3,r4
  beq	exit

#Reset SDI Counter
ResetSDICount:
  li	r0, 0x0
  sth	r0, TM_SuccessfulSDIInputs (r6)
  sth	r0, TM_TotalSDIInputs (r6)

exit:
cmpwi	r30, 0
