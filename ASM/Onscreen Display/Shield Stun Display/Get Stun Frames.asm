#To be inserted at 800930d4
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28

#GET SHIELD STUN
lfs     f1,-28872(r2)				#GET FLOAT 20
lfs	f0, -0x7468 (rtoc)			#GET FLOAT 0.1
fadds	f0,f0,f1			#GET FLOAT 20.1
fdivs	f0,f0,f31
fdivs	f4,f1,f0			#GET ACTUAL STUN FLOAT IN f1

#FLOOR THIS VALUE
fctiwz	f1,f4
stfd	f1,-0x14(sp)
lwz	r3,-0x10(sp)


/*
#GET FRAME NUMBER IN F1 WITHOUT DECIMAL POINT
fctiwz	f1,f4
stfd	f1,-0x14(sp)
lwz	r3,-0x10(sp)
xoris    r4,r3,0x8000
lis   	 r5,0x4330
stw   	 r5,-0x14(sp)
stw   	 r4,-0x10(sp)
lfd   	 f1,-0x14(sp)
lfd	 f2,-0x7470(rtoc)    			#load magic number
fsubs    f1,f1,f2

#SUBTRACT ROUNDED DOWN NUMBER FROM ORIGINAL TO GET DECIMAL POINT
fsubs	f1,f4,f1
lis	r5,0x3f00
stw	r5,-0x14(sp)
lfs	f2,-0x14(sp)			#get 0.5 float

#CHECK IF LESS THAN OR EQUAL TO .5
fcmpo	cr0,f1,f2
blt	storeFrameCount

RoundUp:
addi	r3,r3,0x1

*/
storeFrameCount:
stw	r3,0x23FC(playerdata)

/*
RemoveOldDisplayOnShieldHit:
load	r3,0x804a1f6c			#timer bytes
lbz	r4,0xC(playerdata)
li	r5,0x1
stbx	r5,r3,r4
*/

exit:
lis	r3, 0x8009
