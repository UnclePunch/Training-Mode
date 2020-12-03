#To be inserted at 800C9A44
.include "../../Globals.s"
.include "../Header.s"

.set REG_PlayerData,31
.set REG_Floats,30
.set REG_InputIndex,29
.set REG_PrevInput,28

NTSC102:
	.set	Injection,0x800C9A44
	.set	OFST_PlCo,-0x514C
	.set	InputIndex,0x804c1f78
	.set	InputArray,0x8046b108
	.set	PlayerBlock_LoadPlayerGObj,0x8003418c
/*
NTSC101:
	.set	Injection,0x800C97D0
	.set	OFST_PlCo,-0x514C
	.set	InputIndex,0x804c1258
	.set	InputArray,0x8046a428
	.set	PlayerBlock_LoadPlayerGObj,0x8003418C
NTSC100:
	.set	Injection,0x800C968C
	.set	OFST_PlCo,-0x514C
	.set	InputIndex,0x804bfdf8
	.set	InputArray,0x80469140
	.set	PlayerBlock_LoadPlayerGObj,0x8003410C
PAL100:
	.set	Injection,0x800CA1E8
	.set	OFST_PlCo,-0x4F0C
	.set	InputIndex,0x804b2ff8
	.set	InputArray,0x8045bf10
	.set	PlayerBlock_LoadPlayerGObj,0x80034780
*/

#Original codeline
	stfs f0,0x2C(REG_PlayerData)    # Entry point, store new facing direction

#Init
	backup
	bl	Floats
	mflr	REG_Floats

CHECK_IF_SLOW_TURN:
	lfs f1,0x894(REG_PlayerData)  							# Check if 2nd frame of turn
	lfs	f2,OFST_SlowTurnFrame(REG_Floats)				# 2fp
	fcmpo	cr0,f1,f2
	bne Injection_Exit

CHECK_SMASH_TURN_INPUT_CONDITIONS:
	lwz r4,OFST_PlCo(r13)
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

LOAD_2_FRAMES_PAST_INPUTS:
	lbz	REG_PrevInput, MEX_UCF2fX (REG_PlayerData)
	extsb	REG_PrevInput,REG_PrevInput
	
LOAD_CURRENT_FRAME_INPUT:
	lbz r3, MEX_UCFCurrX (REG_PlayerData)
	extsb r3,r3

CALCULATE_DIFFERENCE:
	sub	r3,REG_PrevInput,r3
	mullw r3, r3, r3  # Take square to get positive value for comparison
THRESHOLD_TEST:
	cmpwi r3, 3600   # compare square of input difference between current frame and 2 frames ago to square of 60 (formerly 75 because different units)
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
	branchl	r12,PlayerBlock_LoadPlayerGObj
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
