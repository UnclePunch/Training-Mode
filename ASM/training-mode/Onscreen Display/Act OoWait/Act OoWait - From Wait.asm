#To be inserted at 8008A630
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

#Check If Interrupted
	cmpwi	r3,0x0
	beq	Moonwalk_Exit

#Get Playerdata
	lwz	playerdata,0x2C(player)

#Ensure I'm Actually Coming from Wait (Wait interrupt is used for certain IASA)
	lhz	r3,TM_OneASAgo(playerdata)
	cmpwi	r3,0xE
	bne	Moonwalk_Exit

#Make Sure Player Didn't Buffer Crouch, Shield, or Walk
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xF
	beq	Moonwalk_Exit
	cmpwi	r3,0x10
	beq	Moonwalk_Exit
	cmpwi	r3,0x11
	beq	Moonwalk_Exit
	cmpwi	r3,0x27
	beq	Moonwalk_Exit
	cmpwi	r3,0xB2
	beq	Moonwalk_Exit
	cmpwi r3,ASID_SquatWait
	beq	Moonwalk_Exit

#Check To Display OSD
	mr	r3,r31
	branchl	r12,0x8000551c

Moonwalk_Exit:
restoreall
lwz	r0, 0x001C (sp)
