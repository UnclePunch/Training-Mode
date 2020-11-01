#To be inserted at 800d6228
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set playerdata,30
.set player,31
.set text,29
.set textprop,28
.set hitbool,27

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

#Get Playerdata
	lwz	playerdata,0x2C(player)

#Check If Interrupted
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0x27
	beq	Moonwalk_Exit

#Make Sure Player Didn't Buffer Shield
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xB2
	beq	Moonwalk_Exit

#Ensure I'm Actually Coming from Wait
	lhz	r3,TM_TwoASAgo(playerdata)
	cmpwi	r3,0xE
	bne	Moonwalk_Exit

#Check To Display OSD
	mr	r3,r31
	branchl	r12,0x8000551c

Moonwalk_Exit:
restoreall
lwz	r0, 0x0024 (sp)
