#To be inserted at 801bab28
.include "../Globals.s"

stb	r0, 0x000A (r31)

#Get Current Event Number
lwz	r4, -0x77C0 (r13)
lbz	r7, 0x0535 (r4)

#Init Loop
bl	SSSEvents
mflr	r5
subi	r5,r5,0x1

#Loop Through Whitelisted Events
Loop:
lbzu	r6,0x1(r5)
extsb	r0,r6
cmpwi	r0,-1
beq	original
cmpw	r6,r7
beq	SSS
b	Loop

SSSEvents:
blrl
.byte Event.LCancel
.byte Event.Ledgedash
.byte Event.Eggs
.byte Event.Reversal
.byte Event.LedgeTech
.byte Event.AmsahTech
.byte Event.Combo
.byte 0xFF
.align 2

SSS:
#Store SSS as Next Scene
load	r3,SceneController
li	r4,0x3
stb	r4,0x5(r3)
original:
