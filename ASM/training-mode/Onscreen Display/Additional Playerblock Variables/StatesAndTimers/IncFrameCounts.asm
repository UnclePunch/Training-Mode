#To be inserted at 8006ab78
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

# Inc Frame Count + Frames Tangible + Hitstun

#Don't Run During Hitlag
lbz	r0, 0x2219 (r31)
rlwinm.	r0, r0, 30, 31, 31
bne	exit

########################
## Increment AS Frame ##
########################

lhz	r3,TM_FramesinCurrentAS(r31)
addi	r3,r3,0x1
sth	r3,TM_FramesinCurrentAS(r31)

##################################
## Increment Tangibility Frames ##
##################################

#Check Timer Intangible Count
lwz	r3,0x1990(r31)
cmpwi	r3,0x0
bgt	IsIntangible

#Ensure Player Had Ledge Intang FIRST
lhz	r3,TM_TangibleFrameCount(r31)
cmpwi	r3,0x0
bne	IncTangibleFrames
#Check For Subaction Intang
lwz	r3,0x1988(r31)
cmpwi	r3,0x2
bne	IncTangibleFrames

#Set Tangible Frames to 0 When Player Has Intangibility
IsIntangible:
li	r3,0x0
sth	r3,TM_TangibleFrameCount(r31)			#Store Tangible Frame Count
b	Tangible_End

IncTangibleFrames:
lhz	r3,TM_TangibleFrameCount(r31)
addi	r3,r3,0x1
sth	r3,TM_TangibleFrameCount(r31)

Tangible_End:

exit:
mr	r3, r30
