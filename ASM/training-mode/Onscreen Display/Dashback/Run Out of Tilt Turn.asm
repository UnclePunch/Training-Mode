#To be inserted at 800c9b88
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

backupall

	#Ensure NOT Coming From Dash or Crouch
	lhz	r3,TM_OneASAgo(playerdata)			#load last AS
	cmpwi	r3,0x14
	beq	Moonwalk_Exit
	cmpwi	r3,0x28
	beq	Moonwalk_Exit

	#Check If Dashed Back (Flag at 0x2340)
	mr	r3,player
	lhz	r4,0x894(playerdata)
	cmpwi	r4,0x4000
	beq	0xC
	li	r4,0x0
	b	0x8
	li	r4,0x1
	branchl	r12,0x80005518

Moonwalk_Exit:
restoreall
mr	r3,r30
li	r4,0x0
