#To be inserted at 8006ab88
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set actionableFlag,28
.set hitbool,27

#Check For Function Pointer
lwz	r12,TM_AnimCallback(r31)
cmpwi	r12,0x0
beq	SkipFunctionBlrl
mtlr	r12
addi	r3, r30, 0
blrl
SkipFunctionBlrl:

#################################
## Check To End Combo Progress ##
#################################

#Check Hitstun
	lbz	r0, 0x221C (r31)
	rlwinm.	r0, r0, 31, 31, 31
	bne	InjectionExit
#Am I in Missfoot?
	lwz	r3,0x10(playerdata)
	cmpwi	r3,0xFB
	beq	InjectionExit
#Am I in Non-IASA Landing?
	cmpwi	r3,0x2A
	bne	SkipIASALandingCheck
	lfs	f1, 0x0894 (playerdata)
	lfs	f0, 0x01F4 (playerdata)
	fcmpo	cr0,f1,f0
	blt	InjectionExit
	SkipIASALandingCheck:
#Am I in Missed Tech, Tech Roll, Slow Getup, Or Getup Attack
	lwz	r0,0x10(playerdata)
	cmpwi	r0,0xB7
	blt	EndCombo
	cmpwi	r0,0xC9
	bgt	CheckGrab
	b	InjectionExit
CheckGrab:
	cmpwi	r0,0xDF
	blt	EndCombo
	cmpwi	r0,0xE8
	bgt	CheckThrow
	b	InjectionExit
CheckThrow:
	cmpwi	r0,0xEF
	blt	EndCombo
	cmpwi	r0,0xF3
	bgt	CheckSpecialThrows
	b	InjectionExit
CheckSpecialThrows:
	cmpwi	r0,0x10A
	blt	EndCombo
	cmpwi	r0,0x130
	bgt	EndCombo
	b	InjectionExit

EndCombo:
	lbz	r3, 0x000C (r31)
	lbz	r4, 0x221F (r31)
	rlwinm	r4, r4, 29, 31, 31
	branchl	r12,0x800411c4


InjectionExit:
lwz	r0, 0x0034 (sp)
