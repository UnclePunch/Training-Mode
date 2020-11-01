#To be inserted at 8006ab48
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set player,31
.set playerdata,31

#Am I in Hitstun? (Ran prior to the injection)

#Am I in Missfoot?
lwz	r3,0x10(playerdata)
cmpwi	r3,0xFB
beq	ContinueCombo

#Am I in Non-IASA Landing?
cmpwi	r3,0x2A
bne	SkipIASALandingCheck
lfs	f1, 0x0894 (playerdata)
lfs	f0, 0x01F4 (playerdata)
fcmpo	cr0,f1,f0
blt	ContinueCombo
SkipIASALandingCheck:

#Am I in Missed Tech, Tech Roll, Slow Getup, Or Getup Attack
lwz	r0,0x10(playerdata)
cmpwi	r0,0xB7
blt	EndCombo
cmpwi	r0,0xC9
bgt	CheckGrab
b	ContinueCombo

CheckGrab:
cmpwi	r0,0xDF
blt	EndCombo
cmpwi	r0,0xE8
bgt	CheckThrow
b	ContinueCombo

CheckThrow:
cmpwi	r0,0xEF
blt	EndCombo
cmpwi	r0,0xF3
bgt	CheckSpecialThrows
b	ContinueCombo

CheckSpecialThrows:
cmpwi	r0,0x10A
blt	EndCombo
cmpwi	r0,0x130
bgt	EndCombo
b	ContinueCombo

ContinueCombo:
branch	r12,0x8006ab58

EndCombo:
lbz	r4, 0x221F (r31)
