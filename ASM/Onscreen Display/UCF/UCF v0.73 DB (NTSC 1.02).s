#To be inserted at 800C9A44
.include "../../Globals.s"

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


	#CHECK IF ENABLED
	li	r0,OSD.UCF			#PowerShield ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	END

CHECK_IF_SLOW_TURN:
lhz r4,0x3E8(r31)  # Check if 2nd frame of turn
cmpwi r4,0x4000
bne- END

CHECK_SMASH_TURN_INPUT_CONDITIONS:

lwz r4,-0x514C(r13)
lfs f1,0x0620(r31)
lfs f2,0x2344(r31)
fmuls f1,f1,f2
lfs f2,0x3C(r4)
fcmpo cr0,f1,f2     # Load control stick x-inputs and compare to 0.8
cror 2,1,2
bne- END
lbz r5,0x0670(r31)
cmpwi r5,2  # Check that cardinal direction not held 2+ frames
bge- END  # Skip if no dash input

SKIP_IF_NANA:
lbz r4,0x221f(r31)    # load flags
rlwinm. r4,r4,0,28,28    # (08) = secondary character
beq+ BEGIN_HW_INPUTS
b END

BEGIN_HW_INPUTS:
lis r4, 0x804c
ori r4, r4, 0x1f78
lbz r5, 0x0001(r4)    # HSD_PadRenewMasterStatus gets index for which inputs to get from here
stb r5, -0x0008(sp)

b LOAD_2_FRAMES_PAST_INPUTS

FETCH_INPUT:   # Gets hw input according to controller port and frame index in r5

FIX_INDEX_AND_CHECK_IF_LESS_THAN_ZERO:
subi r5, r5, 1
cmpwi r5,0
bge- GET_INPUT

INDEX_IS_ZERO:
addi r5, r5, 5

GET_INPUT:
lis r4, 0x8046  # Input array location.
ori r4, r4, 0xb108
mulli r5, r5, 48
add r4, r4, r5  # Add index to get inputs from the right frame
lbz r5, 0x618(r31)   # load controller port
mulli r5, r5, 0xC
add r4, r4, r5
lbz r5, 0x02(r4)   # load x-input
extsb r5, r5    # convert to 32-bit signed int
blr

LOAD_2_FRAMES_PAST_INPUTS:
subi r5, r5, 2
bl FETCH_INPUT
stw r5, -0x000C(sp)

LOAD_CURRENT_FRAME_INPUT:
lbz r5, -0x0008(sp)
bl FETCH_INPUT

CALCULATE_DIFFERENCE:
lwz r4, -0x000C(sp) # Load 2 frames old x-input
sub r5, r5, r4
mullw r5, r5, r5  # Take square to get positive value for comparison

THRESHOLD_TEST:
cmpwi r5, 0x15F9   # compare square of input difference between current frame and 2 frames ago to square of 75
ble- END

CHANGE_TO_SMASH_TURN:
li r0, 1
stw r0, 0x2358(r31)
stw r0, 0x2340(r31)   # Change smash turn and can dash flags


CHECK_IF_POPO:
lwz  r4,0x4(r31)   # Load character id
cmpwi  r4, 0xA    # Check if Popo
bne+ END          # Skip if not Popo

#Get Nana's Block From Popo's in r4
  lbz	r3,0xC(r31)		#P1 Slot
  li	r4,0x1		#Subchar Bool
  branchl	r12,0x8003418c
  cmpwi	r3,0x0
  beq	END
  lwz	r4,0x2C(r3)

STORE_INPUTS_FOR_NANA:
lwz r4,0x1ECC(r4) # Load address where popos inputs were last stored
stfs f0,0x18(r4)   # Store popos direction for nana
lwz r5,0x18(r4)    # Load the direction to get dash direction
lis r12,0x3F80
cmpw r5,r12  # Compare to rightward

beq- POPO_TURNED_RIGHT
li r5,0x80      # This part is run if Popos direction was leftward
stb r5,0x6(r4)  # Store leftward 1.0 input for Nana.
b END

POPO_TURNED_RIGHT:
li r5,0x7f
stb r5,0x6(r4) # Store rightward 1.0 input for Nana

END:
stfs f0, 0x002C(r31)    # Entry point, store new facing direction
