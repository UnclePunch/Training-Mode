#To be inserted at 800693ec
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"


# Store Previous AS + Reset AS Frame Count Timer

###################
## Shift AS ID's ##
###################

#SHIFT AS ID's
li	r12,TM_PrevASSlots-2			#Loop Count

ASLoop:
addi	r3,r26,TM_PrevASStart			#Get Start of AS List
mulli	r4,r12,2			#Current AS ID * Length
add	r4,r3,r4			#Get AS Offset in Playerblock
lhz	r3,0x0(r4)			#Load Previous AS
sth	r3,0x2(r4)			#Push Back

ASIncLoop:
subi	r12,r12,1
cmpwi	r12,0x0
bge	ASLoop

#Move Current AS To Last AS
lwz	r3,0x10(r26)		#get action state that we just left
sth	r3,TM_PrevASStart(r26)		#store as last action state

#########################
## SHIFT FRAME NUMBERS ##
#########################

#SHIFT AS Frame #'s
li	r12,TM_PrevASSlots-2			#Loop Count

FrameCountLoop:
addi	r3,r26,TM_FramesInPrevASStart			#Get to the Start of the Frame Counts
mulli	r4,r12,2			#Current AS ID * Length
add	r4,r3,r4			#Get AS Offset in Playerblock
lhz	r3,0x0(r4)			#Load Previous AS
sth	r3,0x2(r4)			#Push up

FrameCountIncLoop:
subi	r12,r12,1
cmpwi	r12,0x0
bge	FrameCountLoop

#Move Current AS Frame To Last AS Frame
addi	r3,r26,TM_FramesInPrevASStart			#Get to the Start of the Frame Counts
lhz	r4,TM_FramesinCurrentAS(r26)			#Get AS Frame Number we Just Left
sth	r4,0x0(r3)

###########################################
## Init Current AS Frame To Int Variable ##
###########################################



#lfs	f1,0x894(r26)
#fctiwz	f1,f1
#stfd	f1,0x8(sp)
#lwz	r3,0xC(sp)
li	r3,0x0
sth	r3,TM_FramesinCurrentAS(r26)

exit:
cmplwi	r27, 0
