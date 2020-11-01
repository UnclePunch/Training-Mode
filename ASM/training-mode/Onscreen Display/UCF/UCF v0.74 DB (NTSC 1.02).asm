#To be inserted at 800C9A44
.include "../../Globals.s"

.set REG_PlayerData,31
.set REG_Floats,30
.set REG_InputIndex,29
.set REG_PrevInput,28

#Original codeline
	stfs f0,0x2C(REG_PlayerData)    # Entry point, store new facing direction

#Init
	backup
	bl	Floats
	mflr	REG_Floats

#CHECK IF ENABLED
	li	r0,OSD.UCF			#PowerShield ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	Injection_Exit

CHECK_IF_SLOW_TURN:
	lfs f1,0x894(REG_PlayerData)  							# Check if 2nd frame of turn
	lfs	f2,OFST_SlowTurnFrame(REG_Floats)				# 2fp
	fcmpo	cr0,f1,f2
	bne Injection_Exit

CHECK_SMASH_TURN_INPUT_CONDITIONS:
	lwz r4,-0x514C(r13)
	lfs f1,0x0620(REG_PlayerData)
	fabs f1,f1
	lfs f2,0x3C(r4)				#PlCo constant 0.8
	fcmpo cr0,f1,f2				# Load control stick x-inputs and compare to 0.8
	blt Injection_Exit
#Check that cardinal direction not held 2+ frames
	lbz r3,0x0670(REG_PlayerData)
	cmpwi r3,2
	bge- Injection_Exit		# Skip if no dash input

SKIP_IF_NANA:
	lbz r3,0x221f(REG_PlayerData)    # load flags
	rlwinm. r0,r3,0,28,28    # (08) = secondary character
	bne Injection_Exit

BEGIN_HW_INPUTS:
	load r3,0x804c1f78
	lbz REG_InputIndex,0x1(r3)    # HSD_PadRenewMasterStatus gets index for which inputs to get from here

LOAD_2_FRAMES_PAST_INPUTS:
	subi r3, REG_InputIndex, 2
	lbz r4, 0x618(REG_PlayerData)   # load controller port
	bl FETCH_INPUT
	mr	REG_PrevInput,r3
LOAD_CURRENT_FRAME_INPUT:
	mr r3,REG_InputIndex
	lbz r4, 0x618(REG_PlayerData)   # load controller port
	bl FETCH_INPUT

CALCULATE_DIFFERENCE:
	sub	r3,r3,REG_PrevInput
	mullw r3, r3, r3  # Take square to get positive value for comparison
THRESHOLD_TEST:
	cmpwi r3, 0x15F9   # compare square of input difference between current frame and 2 frames ago to square of 75
	ble- Injection_Exit

CHANGE_TO_SMASH_TURN:
	li r0, 1
	stw r0, 0x2358(REG_PlayerData)
	stw r0, 0x2340(REG_PlayerData)   # Change smash turn and can dash flags
#Check if Popo
	lwz	r4,0x4(REG_PlayerData)	# Load character id
	cmpwi	r4,0xA    						# Check if Popo
	bne+ Injection_Exit					# Skip if not Popo
#Get Nana's Block From Popo's in r4
  lbz	r3,0xC(REG_PlayerData)		#P1 Slot
  li	r4,0x1		#Subchar Bool
  branchl	r12,0x8003418c
  cmpwi	r3,0x0
  beq	Injection_Exit
  lwz	r4,0x2C(r3)
#Adjust Nana's inputs
	lwz r4,0x1ECC(r4) # Load address where popos inputs were last stored
	lfs	f1,0x2C(REG_PlayerData)    # get popos facing direction
	stfs f1,0x18(r4)  						# Store popos direction for nana
#Check which direction popo turned
	lfs	f2,OFST_ZeroFP(REG_Floats)				#0fp
	fcmpo	cr0,f1,f2
	bgt- POPO_TURNED_RIGHT
	li r3,0x80      		# leftward 1.0
	b StoreNanaDirection
POPO_TURNED_RIGHT:
	li r3,0x7f					#rightward 1.0
StoreNanaDirection:
	stb r3,0x6(r4) 			# Store rightward 1.0 input for Nana
	b	Injection_Exit

###################
FETCH_INPUT:   # Gets hw input according to controller port and frame index in r5
#r3 = index
#r4 = controller port

#Backup controller port
	mr	r5,r4
#FIX_INDEX_AND_CHECK_IF_LESS_THAN_ZERO
	subi r3, r3, 1
	cmpwi r3,0
	bge- GET_INPUT
#INDEX_IS_ZERO
	addi r3, r3, 5

GET_INPUT:
	load r4,0x8046b108  # Input array location.
	mulli r3, r3, 48
	add r4, r4, r3  # Add index to get inputs from the right frame
	mulli r3, r5, 0xC
	add r4, r4, r3
	lbz r3, 0x02(r4)   # load x-input
	extsb r3, r3    # convert to 32-bit signed int
	blr
###################
Floats:
.set	OFST_SlowTurnFrame,0x0
.set	OFST_ZeroFP,0x4
	blrl
	.float 2
	.float 0
	.align 2
###################

Injection_Exit:
	restore
