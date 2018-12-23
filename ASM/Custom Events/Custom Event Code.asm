#To be inserted at 801bb128
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

#r25 = event ID
#r26 = final match struct
#r28 = same as r26
#r29 = event struct index (0x0 of this, then 0x8 of that to get the specifics)


#################
## Custom Code ##
#################

#all registers free

#CHECK IF CUSTOM EVENT
  lwz	r3, -0x77C0 (r13)
  lbz	r3, 0x0535 (r3)
  branchl r12,0x80005520
  cmpwi r3,0x0
  beq exit

	#1 PLAYER, NO ITEMS, TIME COUNTING UP
	lwz	r9,0x0(r29)		#get event pointers

	#ZERO OUT p2-p6 STRUCT
	li	r4,0x0
	stw	r4,0x18(r9)
	stw	r4,0x1C(r9)
	stw	r4,0x20(r9)
	stw	r4,0x24(r9)
	stw	r4,0x28(r9)

	#Disable All-Star Flag
	li	r3,0x0
	stb	r3,0x0(r9)

	#1 Player
	li	r3,0x20
	stb	r3,0x1(r9)

	#P1 = Choose Char + Normal Modifiers
	bl	P1Struct
	mflr	r3
	stw	r3,0x14(r9)

	#STORE MATCH SETTINGS
	load	r3,0x0bA0027c		#HUD and timer behavior
	stw	r3,0x0(r26)
	load	r3,0x90800000
	stw	r3,0x4(r26)		#think functions
	li	r3,0xFF
	stb	r3,0xB(r26)		#items to none
	li	r3,0x0
	stw	r3,0x10(r26)		#time amount

	#STORE UNLIM STOCKS
	li	r3,0xFF
	stb	r3,0x62(r26)		#p1 stocks

	#SET FALL FLAG
	li	r3,0x0
	stb	r3,0x6C(r26)

  #Store SSS Stage
  load	r3,0x80497758
  lha	r4, 0x001E (r3)
  sth	r4,0xE(r26)

bl	SkipJumpTable
bl	LCancel
bl	Ledgedash
bl	Eggs
bl	SDITraining
bl	Reversal
bl	Powershield
bl	ShieldDrop
bl	AttackOnShield
bl	Ledgetech
bl	AmsahTech
bl	ComboTraining
bl	WaveshineSDI
bl	Event16
bl	Event17
bl	Event18
bl	Event19
bl	Event20

SkipJumpTable:
mflr	r4		#Jump Table Start in r4
subi	r5,r25,0x3		#Start at Event 3, so 0-Index
mulli	r5,r5,0x4		#Each Pointer is 0x4 Long
add	r4,r4,r5		#Get Event's Pointer Address
lwz	r5,0x0(r4)		#Get bl Instruction
rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
add	r4,r4,r5		#Gets ASCII Address in r4
mtctr	r4
bctr


#########################
## L Cancel HIJACK INFO ##
#########################

LCancel:
#STORE STAGE
#li	r3,0x20
#sth	r3,0xE(r26)

#Create Copy Of Player Struct
li	r3,0x1C
branchl	r12,HSD_MemAlloc
mr	r20,r3
bl	P2Struct
mflr	r4
li	r5,0x1C
branchl	r12,memcpy

#STORE CPU
lwz	r4,0x0(r29)
stw	r20,0x18(r4)		#p2 pointer

#Store Character Choice
load	r5,0x8043207c		#get preload table
lwz	r6,0x18(r5)		#get p2 character ID
cmpwi	r6,0x12
bne	0x8
li	r6,0x13		#Make Zelda Sheik
stb	r6,0x0(r20)		#store chosen char
lbz	r6,0x1C(r5)		#get p2 costume ID
stb	r6,0x3(r20)		#store p2 costume ID
li	r5,0x0		#make player controlled
stb	r5,0x1(r20)

#SPAWN 2 PLAYERS
LCancelSetSpawnAmount:
li	r3,0x40
stb	r3,0x1(r4)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x00000003
or	r3,r3,r4
stw	r3,0x1F24(r5)

#STORE THINK FUNCTION
bl	LCancelLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit


	########################
	## L Cancel LOAD FUNCT ##
	########################
	LCancelLoad:
	blrl

	backup

	#Schedule Think
	bl	LCancelThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
  li  r5,0    #No Option Menu
	bl	CreateEventThinkFunction

	b	LCancelLoadExit



		#########################
		## L Cancel THINK FUNCT ##
		#########################

		LCancelThink:
		blrl

    .set EventData,31
    .set P1Data,27
    .set P1GObj,28
    .set P2Data,29
    .set P2GObj,30

		backup

		lwz	EventData,0x2c(r3)

    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4
    mr P2GObj,r5
    mr P2Data,r6

		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	LCancelNotFirstFrame

    #Init Positions
      bl  PlacePlayersCenterStage
		#Check if P2-P4 Is Using the Event
			lbz	r3, -0x5108 (r13)
			cmpwi	r3,0x0
			beq	LCancelIsP1
			li	r3,0x0		#Make CPU Controlled by P1
			stb	r3,0x618(r29)
    LCancelIsP1:
    #Clear Inputs
      bl  RemoveFirstFrameInputs
		LCancelNotFirstFrame:

		#Check For P2 Dpad Down Press
		lwz	r3,0x668(r29)		#Inputs
		rlwinm.	r0,r3,0,29,29
		beq	LCancelThink_CheckForInvinc
		#Toggle Invinc Bit
		lbz	r3,0x0(r31)
		nand 	3,3,3
		stb	r3,0x0(r31)



		LCancelThink_CheckForInvinc:
		lbz	r3,0x0(r31)
		cmpwi	r3,0x0
		bne	LCancelThink_CheckForSaveState
		#Give Invincibility To P1
		mr	r3,r30
		li	r4,0x2
		bl	GiveInvincibility




		LCancelThink_CheckForSaveState:
		#Poll For Savestates
		addi r3,EventData,0x10
		bl	CheckForSaveAndLoad

    mr  r3,P1GObj
    mr  r4,P2GObj
    addi r5,EventData,0x10
		bl	MoveCPU
		bl	GiveFullShields
		bl	UpdateAllGFX


	LCancelLoadExit:
	restore
	blr




################################################################################
################################################################################





#########################
## Ledgedash HIJACK INFO ##
#########################

Ledgedash:
#STORE RANDOM LEGAL STAGE
#li	r3,6		#6 Legal Stages
#branchl	r12,HSD_Randi
#bl	LegalStages
#mflr	r4
#lbzx	r3,r3,r4
#sth	r3,0xE(r26)

#Make HUD Centered For 1P and No Timer
li	r3,0x0420
sth	r3,0x0(r26)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x04000000
or	r3,r3,r4
stw	r3,0x1F24(r5)

#SET EVENT TYPE TO KOs
load	r5,0x8045abf0		#Static Match Struct
lbz	r3,0xB(r5)		#Get Event Score Behavior Byte
li	r4,0x0
rlwimi	r3,r4,1,30,30		#Zero Out Time Bit
stb	r3,0xB(r5)		#Set Event Score Behavior Byte

#If IC's Make SoPo
lbz	r3,0x2(r30)		#P1 External ID
cmpwi	r3,0xE
bne	LedgedashStoreThink
li	r3,0x20
stb	r3,0x2(r30)		#Make SoPo

#STORE THINK FUNCTION
LedgedashStoreThink:
bl	LedgedashLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Ledgedash LOAD FUNCT ##
	########################
	LedgedashLoad:
	blrl

	backup

	#Schedule Think
	bl	LedgedashThink
	mflr	r3
	li	r4,9		#Priority (After Interrupt)
  bl  LedgedashWindowInfo
  mflr r5
  bl LedgedashWindowText
  mflr r6
	bl	CreateEventThinkFunction

	bl	InitializeHighScore

	b	LedgedashLoadExit


		#########################
		## Ledgedash THINK FUNCT ##
		#########################

    #Registers
    .set EventData,31
    .set MenuData,27
    .set P1GObj,30
    .set P1Data,29

    #Offsets
		.set firstFrameFlag,0x0
		.set eventState,0x1
		.set hitboxFoundFlag,0x2
    .set currentLedge,0x3
		.set timer,0x4
		.set CameraBox,0x8
		.set StartingLocation,OptionMenuMemory+0x2+0x0
		.set AutoRestore,OptionMenuMemory+0x2+0x1
    .set StartingLocationToggled,OptionMenuToggled+0x0
		.set AutoRestoreToggled,OptionMenuToggled+0x1

		LedgedashThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31
		lwz   MenuData,MenuDataPointer(EventData)

    bl    GetAllPlayerPointers
		mr		P1GObj,r3			#player block in r30
		mr		P1Data,r4			#player data in r29


		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	LedgedashThinkMain

			#Create Camera Box
				branchl	r12,CreateCameraBox
				stw r3,CameraBox(r31)
			#Place on Ledge
				lbz r3,currentLedge(EventData)		#Left Ledge
				bl	Ledgedash_PlaceOnLedge
			#Set Camera To Be Zoomed Out More
				load	r4,0x8049e6c8
				load	r3,0x3FE66666
				stw	r3,0x28(r4)
			#Set Tangible Frames High So It Doesn't Constantly Show
				li	r3,100
				stw	r3,0x2408(r29)
      #Clear Inputs
        bl  RemoveFirstFrameInputs
			#Save State
				addi r3,EventData,0x10
				bl	SaveState_Save

			#Set Frame 1 As Over
				li		r3,0x1
				stb		r3,firstFrameFlag(r31)


		LedgedashThinkMain:

		#Update HUD Score
		lhz	r3,-0x4ea8(r13)
		branchl	r12,HUD_KOCounter_UpdateKOs

		#Check If Toggled Starting Location
			lbz r3,StartingLocationToggled(MenuData)
      cmpwi r3,0x0
			beq	Ledgedash_SkipToggledLoadState
			b		Ledgedash_LoadState
		Ledgedash_SkipToggledLoadState:

		#Reset If Anyone Dies
			bl	IsAnyoneDead
			cmpwi	r3,0x0
			bne	Ledgedash_LoadState

		#Infinite Time While on Rebirth Platform
			lwz	r3,0x10(P1Data)
			cmpwi	r3,0xD
			bne	LedgedashSkipRebirthTimer
			li	r3,0x2
			stw	r3,0x2340(P1Data)
		LedgedashSkipRebirthTimer:

    #Infinite Time While Holding Ledge
      lwz	r3,0x10(P1Data)
      cmpwi	r3,0xFD
      bne	LedgedashSkipCliffTimer
      li  r3,2
      bl  IntToFloat
      stfs f1,0x2344(P1Data)
    LedgedashSkipCliffTimer:

		#Make sure nothing else is held
			lhz	r3,0x662(P1Data)
			cmpwi	r3,0x0
			bne GetProgressAndAS
		#CHECK FOR DPAD TO CHANGE LEDGE
			lwz	r3,0x668(P1Data)			#Get DPad
			rlwinm.	r0,r3,0,30,30
			beq	Ledgedash_CheckLeft
		#Load Most Recent State
			#addi r3,EventData,0x10
			#bl		SaveState_Load
		#Place on Right Ledge
      li	r3,1
      stb r3,currentLedge(EventData)
			bl	Ledgedash_PlaceOnLedge
		#Save State
			addi r3,EventData,0x10
			bl		SaveState_Save
			b	Ledgedash_LoadState
		Ledgedash_CheckLeft:
			rlwinm.	r0,r3,0,31,31
			beq	GetProgressAndAS
		#Load Most Recent State
			#addi r3,EventData,0x10
			#bl		SaveState_Load
		#Place on Left Ledge
			li	r3,0
      stb r3,currentLedge(EventData)
			bl	Ledgedash_PlaceOnLedge
		#Save State
			addi r3,EventData,0x10
			bl		SaveState_Save
			b	Ledgedash_LoadState

		GetProgressAndAS:
		#Check If AutoRestore is enabled
			lbz	r3,AutoRestore(MenuData)
			cmpwi r3,0x1
			beq	LedgedashThinkEnd
		#Check If Timer Is Set
			lbz	r3,timer(r31)
			cmpwi	r3,0x0
			bgt	Ledgedash_CheckToReset
		#Get Progress + AS
			lbz	r3,eventState(r31)		#Progress Byte

		bl	LedgedashSkipJumpTable
		bl	LedgedashProg0
		bl	LedgedashProg1
		bl	LedgedashProg2
		bl	LedgedashProg3
		bl	LedgedashProg4

		LedgedashSkipJumpTable:
		mflr	r4		#Jump Table Start in r4
		mulli	r5,r3,0x4		#Each Pointer is 0x4 Long
		lwzx	r3,r4,r5		#Get bl Instruction
		rlwinm	r3,r3,0,6,29		#Mask Bits 6-29 (the offset)
		add	r3,r4,r3		#Gets Address in r3
		add	r3,r3,r5		#Offset From Start Of Jump Table

		#Init Loop
		subi	r3,r3,0x2
		lwz	r6,0x10(r29)		#AS

		#Check For BlackListed AS
		## Terminator = FFFF
		## Jump to    = 7FXX
		LedgedashASCheckLoop:
		lhzu	r4,0x2(r3)		#Get Next Value
		extsb	r0,r4
		cmpwi	r0,-1		#Check For Terminator
		beq	Ledgedash_ResetProg
		rlwinm	r0,r4,0,15,23		#Isolate Left Half
		cmpwi	r0,0x7F00		#Check If New "Jump To"
		bne	LedgedashCompareAS
		rlwinm	r5,r4,0,24,31		#Isolate Right Half to r5
		b	LedgedashASCheckLoop
		LedgedashCompareAS:
		cmpw	r6,r4
		bne	LedgedashASCheckLoop
		stb	r5,0x1(r31)		#Progress Byte
		b	LedgedashThinkEnd


		LedgedashThinkEnd:
    mr  r3,MenuData
    bl  ClearToggledOptions
		restore
		blr


		####################
		## Reset Progress ##
		####################

		Ledgedash_ResetProg:
		#Check If On Ground
		lwz	r3,0xE0(r29)
		cmpwi	r3,0x0
		beq	Ledgedash_Reset
		#Check If Dead
		lbz	r3,0x221F(r29)
		rlwinm.	r3,r3,0,25,25
		bne	Ledgedash_Reset
		#Check If Frame 9 Of Wrong Move
		lwz	r3,0x894(r29)			#Frames in State
		lis	r5,0x4110			#9fp
		cmpw	r3,r5
		blt	LedgedashThinkEnd

		Ledgedash_Reset:
		#Play Success or Failure Noise
		lhz	r3,OneASAgo(r29)			#Check Prev AS
		cmpwi	r3,0x2B			#If Landing, Success
		beq	Ledgedash_PlaySuccess
		cmpwi	r3,0xE			#If Wait, Success (Frame Perfect Action)
		beq	Ledgedash_PlaySuccess

		lwz	r3,CurrentAS(r29)
		cmpwi	r3,0x2A			#If Aerial Interrupt, Check If Can IASA Yet
		beq	Ledgedash_AerialInterruptCheck
		cmpwi	r3,0xE			#If No Impact Land, Success
		beq	Ledgedash_PlaySuccess

		b	Ledgedash_PlayFailure

		Ledgedash_AerialInterruptCheck:
		#Check If Coming From an Aerial Attack
		lhz	r3,OneASAgo(r29)			#Check Prev AS
		cmpwi	r3,0x41
		blt	Ledgedash_PlayFailure
		cmpwi	r3,0x45
		bgt	Ledgedash_PlayFailure

		#Check If Interruptable Yet
		lfs	f2,0x1F4(r29)			#Check Which Frame Landing is Interruptable
		li	r3,1
		bl	IntToFloat
		fsubs	f1,f2,f1			#Sub 1 Because Order of Operations
		lfs	f2,0x894(r29)			#Check Current Frame
		fcmpo	cr0,f2,f1
		blt	LedgedashThinkEnd

		Ledgedash_PlaySuccess:
		#Increment Score
			lhz	r3,-0x4ea8(r13)
			addi	r3,r3,0x1
			sth	r3,-0x4ea8(r13)
		#Check To Make New High Score
			lhz	r3,-0x4ea8(r13)
			lhz	r4,-0x4ea6(r13)
			cmpw	r3,r4
			ble	Ledgedash_PlaySuccess_PlaySound
		#Copy To High Score
			sth	r3,-0x4ea6(r13)
		Ledgedash_PlaySuccess_PlaySound:
		#Play Sound
			li		r3,0xAD
			bl PlaySFX
		#Set Timer
			li	r3,30
			stb	r3,timer(r31)
			b	LedgedashThinkEnd

		Ledgedash_PlayFailure:
		#Reset Score
			li	r3,0
			sth	r3,-0x4ea8(r13)
		#Play Sound
			li	r3,0xAF
			Ledgedash_PlaySound:
			bl PlaySFX
      bl Ledgedash_PlaceOnLedge
			b	Ledgedash_LoadState


		Ledgedash_CheckToReset:
		lbz	r3,timer(r31)				#Check If Timer is Set
		cmpwi	r3,0x0
		ble	LedgedashThinkEnd

		Ledgedash_CheckForInvincibleMove:
		lbz	r3,hitboxFoundFlag(r31)				#Check If Hitbox Was Already Found
		cmpwi	r3,0x1
		beq	Ledgedash_DecrementTimer
		lwz	r3,0x1990(r29)				#Check If Char is Invincible
		cmpwi	r3,0x0
		ble	Ledgedash_DecrementTimer
		mr	r3,r30				#Check If a Hitbox is Active
		bl	CheckForActiveHitboxes
		cmpwi	r3,0x0
		beq	Ledgedash_DecrementTimer
		li	r3,0xAA				#Play Sound
		branchl	r12,SFX_PlaySoundAtFullVolume
		li	r3,1				#Mark As Found
		stb	r3,hitboxFoundFlag(r31)

		Ledgedash_DecrementTimer:
			lbz	r3,timer(r31)
			subi	r3,r3,0x1			#Decrement
			stb	r3,timer(r31)
			cmpwi	r3,0x0
			bgt	LedgedashThinkEnd
      bl	Ledgedash_PlaceOnLedge
    #Save State
      addi r3,EventData,0x10
      bl		SaveState_Save

		Ledgedash_LoadState:
		#Reset all event variables
			li		r3,0x0
			stb		r3,eventState(r31)				#Progress Byte
			stb		r3,hitboxFoundFlag(r31)		#Invincible Move Bool
			stb		r3,timer(r31)							#Timer
			addi r3,EventData,0x10
			bl		SaveState_Load
		#Create Respawn Platform If Enabled
			lbz		r3,StartingLocation(MenuData)
			cmpwi	r3,0x0
			beq	Ledgedash_LoadState_SkipRespawnPlatform
		#Remember Facing Direction (Rebirth changes this)
			lfs	f31,0x2C(r29)
		#Enter P1 Into Rebirth Again
			mr		r3,r30
			branchl		r12,AS_Rebirth
		#Restore Facing Direction
			stfs	f31,0x2C(r29)
		#Randomize Location
		#Get Stage's Ledges
			lwz		r3,-0x6CB8 (r13)			#External Stage ID
			bl		LedgedashCliffIDs
			mflr  r4
			mulli	r3,r3,0x2
			lhzx	r3,r3,r4
		#Get Correct Ledge From Facing Direction
			lfs	f1, 0x002C (r29)
			lfs	f0, -0x7660 (rtoc)
			fcmpo	cr0,f1,f0
			ble	Ledgedash_LoadState_GetRightLedge
		Ledgedash_LoadState_GetLeftLedge:
		#Get Ledge X and Y Coordinates
			rlwinm	r3,r3,24,24,31
			addi	r4,sp,0x80
			branchl	r12,Stage_GetLeftOfLineCoordinates
			b	Ledgedash_LoadState_RandomizePosition
		Ledgedash_LoadState_GetRightLedge:
		#Get Ledge X and Y Coordinates
			rlwinm	r3,r3,0,24,31
			addi	r4,sp,0x80
			branchl	r12,Stage_GetRightOfLineCoordinates
		Ledgedash_LoadState_RandomizePosition:
		#Get Random Distance from this
			.set RandomDistanceMinX,30
			.set RandomDistanceMaxX,55
			.set RandomDistanceMinY,-30
			.set RandomDistanceMaxY,30
			li	r3,RandomDistanceMinX
			li	r4,RandomDistanceMaxX
			bl	RandFloat
			fmr	f31,f1
			li	r3,RandomDistanceMinY
			li	r4,RandomDistanceMaxY
			bl	RandFloat
			fmr	f30,f1
		#Add to Ledge Coordinates
			lfs	f1,0x2C(r29)	#Facing Direction
			fneg f1,f1
			fmuls f31,f1,f31
			lfs	f0,0x80(sp)		#Ledge X
			fadds f31,f0,f31
			lfs	f1,0x84(sp)		#Ledge Y
			fadds f30,f1,f30
		#Store to Player Block
			stfs f31,0xB0(r29)
			stfs f30,0xB4(r29)
		#Enter RebirthWait
			mr		r3,r30
			branchl		r12,AS_RebirthWait
		#Store Blr as Physics
			bl		BlrFunctionPointer
			mflr		r3
			stw		r3,0x21A4(r29)
		#Store Custom RebirthWait Interrupt
			bl	Custom_InterruptRebirthWait
			mflr	r3
			stw		r3,0x219C(r29)
    #Update RebirthPlat Position
      mr  r3,P1GObj
      branchl r12,RebirthPlatform_UpdatePosition

		Ledgedash_LoadState_SkipRespawnPlatform:
      mr  r3,r30
      bl  UpdatePosition

    #Update Camera Box
      mr  r3,P1GObj
      bl  UpdateCameraBox

		b		LedgedashThinkEnd


		#####################
		## PlaceAboveLedge ##
		#####################
		Ledgedash_PlaceOnLedge:
    backup

		#Backup Ledge Choice (0 = Left, 1 = Right)
		lbz r20,currentLedge(EventData)

		#RESET PROGRESS
		li		r3,0x0
		stb		r3,eventState(r31)

		#Get Stage's Ledge IDs
			lwz		r3,-0x6CB8 (r13)			#External Stage ID
			bl		LedgedashCliffIDs
			mflr  r4
			mulli	r3,r3,0x2
			lhzx	r3,r3,r4
		#Get Requested Ledge
			cmpwi r20,0x0
			beq	Ledgedash_PlaceOnLedge_GetLeftLedgeID

		Ledgedash_PlaceOnLedge_GetRightLedgeID:
			rlwinm	r21,r3,0,24,31
		#Change Facing Direction
			li	r3,-1
			bl	IntToFloat
			stfs	f1,0x2C(r29)
			b	Ledgedash_PlaceOnLedge_StoreLedgeIDAndPosition

		Ledgedash_PlaceOnLedge_GetLeftLedgeID:
			rlwinm	r21,r3,24,24,31
		#Change Facing Direction
			li	r3,1
			bl	IntToFloat
			stfs	f1,0x2C(r29)
			b	Ledgedash_PlaceOnLedge_StoreLedgeIDAndPosition

		Ledgedash_PlaceOnLedge_StoreLedgeIDAndPosition:
		#Store Ledge to Player Block
			stw r21,0x2340(r29)
		#Enter CliffWait
			mr	r3,r30
			branchl r12,AS_CliffWait
    #Get Jump Back
      mr r3,r29
      branchl r12,Air_StoreBool_LoseGroundJump_NoECBfor10Frames
    #Set ECB Update Flag
      mr  r3,P1Data
      branchl r12,DataOffset_ECBBottomUpdateEnable
		#Move Player To Ledge
			mr	r3,r30
			branchl r12,MovePlayerToLedge
		#Update Position
			mr	r3,r30
			bl UpdatePosition
		#Kill Velocity
			li		r3,0x0
			stw		r3,0x80(r29)			#X Velocity
			stw		r3,0x84(r29)			#Y Velocity

		#Give Intangibility (30)
			mr	r3,r30
			lwz	r4, -0x514C (r13)
			lwz	r4, 0x049C (r4)
			branchl	r12,ApplyIntangibility

		#Adjust Ledge Camera Box Accordingly
		#Get Ledge Coordinates
			mr	r3,r21
			addi	r4,sp,0xD0
			lfs	f1, 0x002C (r29)
			lfs	f0, -0x7660 (rtoc)
			fcmpo	cr0,f1,f0
			ble Ledgedash_PlaceOnLedge_CameraBoxRightLedge
		Ledgedash_PlaceOnLedge_CameraBoxLeftLedge:
			branchl	r12,Stage_GetLeftOfLineCoordinates
			b	Ledgedash_PlaceOnLedge_UpdateCameraBox
		Ledgedash_PlaceOnLedge_CameraBoxRightLedge:
			branchl r12,Stage_GetRightOfLineCoordinates
		Ledgedash_PlaceOnLedge_UpdateCameraBox:
		#Get CameraBox
			lwz r20,CameraBox(r31)
		#Position Base of CameraBox at the Ledge
			lfs f1,0xD0(sp)		#Ledge X
			stfs f1,0x10(r20)  #Camera X Position
			lfs f1,0xD4(sp)		#Ledge Y
			stfs f1,0x14(r20)  #Camera X Position
		#Make Boundaries around ledge position
		#Left Bound
			li	r3,-10
			bl	IntToFloat
			stfs	f1,0x40(r20)
		#Right Bound
			li	r3,10
			bl	IntToFloat
			stfs	f1,0x44(r20)
		#Top Bound
			li	r3,10
			bl	IntToFloat
			stfs	f1,0x48(r20)
		#Lower Bound
			li	r3,-10
			bl	IntToFloat
			stfs	f1,0x4C(r20)

    #Update Camera Box
      mr  r3,P1GObj
      bl  UpdateCameraBox

		restore
		blr

####################################

LedgedashCliffIDs:
blrl
.long 0xFFFFFFFF #Dummy, TEST
.long 0x03073336 #FoD, Pokemon Stadium
.long 0x030D2945 #Peach's Castle, Kongo Jungle
.long 0x0511091A #Brinstar, Corneria
.long 0x02061517 #Yoshi's Story, Onett
.long 0x0000434C #Mute City, Rainbow Cruise
.long 0x00000000 #Jungle Japes, Great Bay
.long 0x0E0D0000 #Hyrule Temple, Brinstar Depths
.long 0x00051E2E #Yoshi's Island, Green Greens
.long 0x0C0E0204 #Fourside, MKI
.long 0x03050000 #MKII, Akaneia
.long 0x06120000 #Venom, PokeFloats
.long 0xD7E20000 #Big Blue, Icicle Mountain
.long 0x00000000 #Icetop, Flatzone
.long 0x0305030B #Dream Land, Yoshis Island 64
.long 0x06100005 #Kongo Jungle 64, Battlefield
.long 0x00020101 #Final Destination



####################################
/*
#Fall -> GliffGrab
LedgedashProg0:
.long 0x7F00001D
.long 0x7F0100FC
.long 0xFFFF0000

#CliffGrab -> GliffWait
LedgedashProg1:
.long 0x7F0100FC
.long 0x7F0200FD
.long 0xFFFF0000
*/

#CliffWait -> Fall
LedgedashProg0:
.long 0x7F0000FC
.long 0x00FD000D
.long 0x7F01001D
.long 0x7F02001B
.long 0x001C001C
.long 0xFFFF0000

#Fall -> JumpAerial
LedgedashProg1:
.long 0x7F0000FC
.long 0x7F01001D
.long 0x00CB00CB
.long 0x7F02001B
.long 0x001C0155
.long 0x01620166
.long 0x01670170
.long 0x01640023
.long 0x015e015f
.long 0x0160016B
.long 0x0171015C
.long 0x016D0165
.long 0x016E0168
.long 0x01610176
.long 0x015DFFFF

#JumpAerial -> Airdodge
LedgedashProg2:
.long 0x7F02001B
.long 0x00CB00CB
.long 0x001C0155
.long 0x01620166
.long 0x01670170
.long 0x01640023
.long 0x015e015f
.long 0x0160016B
.long 0x0171015C
.long 0x016D016E
.long 0x01650168
.long 0x01610176
.long 0x015D001D
.long 0x7F0300EC
.long 0x00410042
.long 0x00430044
.long 0x00450045
.long 0x002B7F00
.long 0x00FCFFFF

#Airdodge -> Landing
LedgedashProg3:
.long 0x7F0300AA
.long 0x7F04002B
.long 0x002AFFFF

#Landing -> Wait
LedgedashProg4:
.long 0x7F04002B
#.long 0x002A002A
.long 0x7F02001D
.long 0xFFFFFFFF

####################################

LedgedashWindowInfo:
blrl
.long 0x010101FF  #1 window, Respawn Platform has 2 options, AutoRestore has 2 options

LedgedashWindowText:
blrl

#Option Title = Starting Location
.string "Starting Location"
.align 2

#Option 1 = Ledge
.string "Ledge"
.align 2

#Option 2 = Respawn Platform
.string "Respawn Platform"
.align 2

#Option Title = AutoRestore
.string "AutoRestore"
.align 2

#Option 1 = On
.string "On"
.align 2

#Option 2 = Off
.string "Off"
.align 2


####################################

LedgedashLoadExit:
restore
blr



################################################################################
################################################################################




#########################
## Eggs-ercise HIJACK INFO ##
#########################

Eggs:

#COUNT DOWN TIME
li	r3,0x6
stb	r3,0x0(r26)

#1 Minute On the Clock
li	r3,60
stw	r3,0x10(r26)

#Store Match Type to READY, GO!
li	r3,0x80
stb	r3,0x1(r26)

#SET EVENT TYPE TO KOs
load	r5,0x8045abf0		#Static Match Struct
lbz	r3,0xB(r5)		#Get Event Score Behavior Byte
li	r4,0x0
rlwimi	r3,r4,1,30,30		#Zero Out Time Bit
stb	r3,0xB(r5)		#Set Event Score Behavior Byte

#STORE THINK FUNCTION
bl	EggsLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Eggs-ercise LOAD FUNCT ##
	########################
	EggsLoad:
	blrl

	backup

	#Schedule Think
	bl	EggsThink
	mflr	r3
	li	r4,9		#Priority (After Interrupt)
  bl	EggsWindowInfo
  mflr	r5
  bl	EggsWindowText
  mflr	r6
	bl	CreateEventThinkFunction

  #r3 = function to run each frame
  #r4 = priority
  #r5 = pointer to Window and Option Count
  #r6 = pointer to ASCII struct

	bl	InitializeHighScore

	b	EggsLoadExit


		#########################
		## Eggs-ercise THINK FUNCT ##
		#########################

    #Registers
    .set EventData,31
    .set MenuData,26
    .set P1Data,27
    .set P1GObj,28

    #Offsets
		.set	DamageThreshold,(OptionMenuMemory+0x2) +0x0
		.set	DamageThresholdToggled,(OptionMenuToggled) +0x0

		EggsThink:
		blrl
		backup

		#Get and Backup Event Data
		mr	r30,r3			#r30 = think entity
		lwz	EventData,0x2c(r3)			#backup data pointer in r31
    lwz MenuData,MenuDataPointer(EventData)

		#Get Player Data
    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4

		#No Staling
		bl	ResetStaleMoves

		#Check If Free Practice
		lbz	r3,0x5(r31)
		cmpwi	r3,0x0
		bne	EggsSkipFreePracticeCheck
		#Check DPad Down
		lwz	r0,0x668(r27)
		rlwinm.	r0,r0,0,29,29
		beq	EggsSkipFreePracticeCheck
		#Toggle Free Practice On
		li	r3,0x1
		stb	r3,0x5(r31)
		#Timer Now Counts Up
		load	r3,0x8046b6a0
		lbz	r0,0x24C8(r3)
		li	r4,1
		rlwimi	r0,r4,0,31,31
		stb	r0,0x24C8(r3)
		#Play Sound To Indicate
		li	r3,0x82
		branchl	r12,SFX_PlaySoundAtFullVolume
		EggsSkipFreePracticeCheck:

    #Check If Toggled
      lbz r3,DamageThresholdToggled(MenuData)
		  cmpwi	r3,0x0
		  beq	EggsSkipToggleCheck
		#Check If Already Free Practice
		  lbz	r3,0x5(r31)
		  cmpwi	r3,0x0
		  bne	EggsSkipToggleCheck
		#Make Free Practice
		  li	r3,0x1
		  stb	r3,0x5(r31)
		#Timer Now Counts Up
		  load	r3,0x8046b6a0
		  lbz	r0,0x24C8(r3)
		  li	r4,1
		  rlwimi	r0,r4,0,31,31
		  stb	r0,0x24C8(r3)
		#Play Sound To Indicate
		  li	r3,0x82
		  branchl	r12,SFX_PlaySoundAtFullVolume
    EggsSkipToggleCheck:

		#Check For First Frame
		lbz	r3,0x4(r31)
		cmpwi	r3,0x0
		bne	EggsNotFirstFrame

			#Check If Player Can Move
			li	r3,0x0
			branchl	r12,PlayerBlock_LoadMainCharDataOffset	 #get player block
			lwz	r3,0x2c(r3)		#player data in r29

			lbz	r3,0x221D(r3)
			rlwinm.	r3,r3,0,28,28
			bne	EggsThinkExit

			#Set First Frame Over
			li	r3,0x1
			stb	r3,0x4(r31)
			EggsNotFirstFrame:

		#Check If Target is Spawned
		EggsTargetCheck:
    #Check If Pointer is Stored
		  lwz	r3,0x0(r31)
		  cmpwi	r3,0x0
		  beq	EggsThinkSpawn
    #Check if Item GObj is live
      lwz r3,0x2C(r3)
      cmpwi r3,0x0
      beq EggsThinkSpawn
      b   EggsThinkSkipSpawn

    ################
		# Spawn Target #
    ################
/*
			EggsThinkSpawn:
			#Get Random X Value that falls between ledges
        #Get Stage's Ledge IDs
          lwz		r3,-0x6CB8 (r13)			#External Stage ID
          bl		LedgedashCliffIDs
          mflr  r4
          mulli	r3,r3,0x2
          lhzx	r20,r3,r4
        #Get Left Ledge X and Y Coordinates
          rlwinm	r3,r20,24,24,31
          addi	r4,sp,0x80
          branchl	r12,Stage_GetLeftOfLineCoordinates
        #Get Right Ledge X and Y Coordinates
          rlwinm	r3,r20,0,24,31
          addi	r4,sp,0x90
          branchl	r12,Stage_GetRightOfLineCoordinates
        #Convert Ledge X Values to Int
          lfs f1,0x80(sp)     #Left Ledge X
          lfs f2,0x90(sp)     #Right Ledge X
          fctiwz f1,f1
          stfd  f1,0x9C(sp)
          lwz   r20,0xA0(sp)
          fctiwz f2,f2
          stfd  f2,0x9C(sp)
          lwz   r21,0xA0(sp)
        #Get amount of all possible values between the two
          sub r3,r21,r20
          subi  r3,r3,8       #Minus 8, pad by 4 on each side
        #Get Random Number in Range
          branchl	r12,HSD_Randi
          addi  r3,r3,4       #Shift over by 4 to make it evenly distrubuted again
        #Get X Value by adding to leftmost coordinate
          add r20,r20,r3     #r20 = X

      #Convert Ledge Y Values to Int
        lfs f1,0x84(sp)     #Left Ledge Y
        lfs f2,0x94(sp)     #Right Ledge Y
        fctiwz f1,f1
        stfd  f1,0x9C(sp)
        lwz   r21,0xA0(sp)
        fctiwz f2,f2
        stfd  f2,0x9C(sp)
        lwz   r4,0xA0(sp)
      #Keep Highest Cliff Y Value
        cmpw r21,r4
        bge 0x8
        mr  r21,r4
			#Get Random Y (1-50)
			   li	r3,50
			   branchl	r12,HSD_Randi
      #Starts at Cliff Y Value + 1
        add r21,r3,r21
        addi r21,r21,1

			#Get Random Y Velocity
			   li	r22,0x2			#r22 = Y vel int

			#Get Y Velocity Decimal
			   branchl	r12,HSD_Randf
			   fmr	f4,f1			#f4 = Y Vel Decimal

			#Convert To Float
			#Get as Floats
			#X
			   mr r3,r20
         bl  IntToFloat
         fmr  f21,f1
			#Y
        mr r3,r21
        bl  IntToFloat
        fmr  f22,f1
			#Y Vel
        mr r3,r22
        bl  IntToFloat
			#Add Decimal to Y Vel
			  fadds	f20,f1,f4

      #Check If Egg is Above Ground
        li  r3,0
        fmr f1,f21
        fmr f2,f22
        bl  FindGroundUnderCoordinate
        cmpwi r3,0x0
        beq EggsThinkSpawn
*/

.set LeftCameraBound,20
.set RightCameraBound,21
.set TopCameraBound,22
.set BottomCameraBound,23

    EggsThinkSpawn:
    .if debug==1
    li r24,0      #Init loop count
    .endif

    EggsThinkSpawnLoop:

    .if debug==1
    addi r24,r24,1  #Inc Loop Count
    .endif

    #Get OnScreen Boundaries
    #Left Camera
      branchl r12,StageInfo_CameraLimitLeft_Load
      fctiwz f1,f1
      stfd f1,0x80(sp)
      lwz LeftCameraBound,0x84(sp)
    #Right Camera
      branchl r12,StageInfo_CameraLimitRight_Load
      fctiwz f1,f1
      stfd f1,0x80(sp)
      lwz RightCameraBound,0x84(sp)
    #Top Camera
      branchl r12,StageInfo_CameraLimitTop_Load
      fctiwz f1,f1
      stfd f1,0x80(sp)
      lwz TopCameraBound,0x84(sp)
    #Bottom Camera
      branchl r12,StageInfo_CameraLimitBottom_Load
      fctiwz f1,f1
      stfd f1,0x80(sp)
      lwz BottomCameraBound,0x84(sp)

    #Get Random Velocity
			branchl	r12,HSD_Randf
      fmr f20,f1
      li  r3,2
      bl  IntToFloat
      fadds f20,f20,f1

    #Get Random X Value Between These
      mr  r3,LeftCameraBound
      mr  r4,RightCameraBound
      bl  RandFloat
      fmr f21,f1

    #Get Random Y Value Between These
      mr   r3,BottomCameraBound
      subi  r4,TopCameraBound,70        #Minus 40 so it doesnt fly up offscreen
      bl  RandFloat
      fmr f22,f1

    #Check If Egg is Above Ground
      fmr f1,f21
      fmr f2,f22
      bl  FindGroundUnderCoordinate
      cmpwi r3,0x0
      beq EggsThinkSpawnLoop

    .if debug==1
    #OSReport Loop Count
      load r3,0x803ead3c
      mr r4,r24
      branchl r12,OSReport
    .endif

			SpawnEgg:
			addi	r3,sp,0x80
			li	r4,0x0
			stw	r4,0x0(r3)	#Player Pointer
			stw	r4,0x4(r3)	#Player Pointer
			li	r4,0x03
			stw	r4,0x8(r3)	#Item ID
			lfs	f0, -0x2858 (rtoc)
			stfs	f21,0x14(r3)	#X Coord
			stfs	f22,0x18(r3)	#Y Coord
			stfs	f0,0x1C(r3)	#Z Coord
			stfs	f21,0x20(r3)	#X Coord
			stfs	f22,0x24(r3)	#Y Coord
			stfs	f0,0x28(r3)	#Z Coord
			stfs	f0,0x2C(r3)	#Unk
			stfs	f0,0x30(r3)	#Unk
			stfs	f0,0x34(r3)	#X Vel
			stfs	f0,0x38(r3)	#Y Vel
			li	r4,0x1
			sth	r4,0x3C(r3)
			branchl	r12,EntityItemSpawn
			mr	r29,r3		#Backup Entity Pointer

			stw	r29,0x0(r31)		#Store Pointer To Target In Event Think

			#Store Pointer To Event Think In Target
			lwz	r4,0x2C(r29)
			stw	r31,0xDDC(r4)

			#Store Y Velocity
			stfs	f20,0x44(r4)

			#Get OnDestroy
			lwz	r4,0x2C(r29)
			lwz	r4,0xB8(r4)

			#Store OnCollision
			bl	OnCollision
			mflr	r3
			stw	r3,0x1C(r4)

			#Create Camera Box
			branchl	r12,CreateCameraBox
			#Attach to Entity
			lwz	r4,0x2c(r29)
			stw	r3, 0x0520 (r4)
			#Enable Camera Box Bit
			lbz	r0, 0x0DCD (r4)
			li	r5,0x22
			rlwimi	r0, r5, 5, 24, 25
			stb	r0, 0x0DCD (r4)
			#Copy Some Stuff To Camera Box
			lwz	r4, -0x4978 (r13)
			lfs	f0, 0x014C (r4)
			stfs	f0, 0x0040 (r3)
			lfs	f0, 0x0150 (r4)
			stfs	f0, 0x0044 (r3)
			lfs	f0, 0x0154 (r4)
			stfs	f0, 0x0048 (r3)
			lfs	f0, 0x0158 (r4)
			stfs	f0, 0x004C (r3)

			#Never Timeout
			lwz	r5, 0x002C (r29)
			lbz	r3,0xDD0(r5)
			li	r4,0x1
			rlwimi	r3,r4,4,27,27
			stb	r3,0xDD0(r5)

			#Not Grabbable
			lbz	r3, 0x0DCA (r5)
			li	r4,0x0
			rlwimi	r3,r4,2,29,29
			stb	r3, 0x0DCA (r5)

			#Un-Nudgeable?
			lbz	r3, 0x0DCB (r5)
			li	r4,0x0
			rlwimi	r3,r4,3,28,28
			stb	r3, 0x0DCB (r5)

      EggsThinkSkipSpawn:
      #Not Grabbable Every Frame
      lwz	r5,0x0(r31)
      lwz	r5,0x2c(r5)
      lbz	r3, 0x0DCA (r5)
      li	r4,0x0
      rlwimi	r3,r4,2,29,29
      stb	r3, 0x0DCA (r5)

      #Update HUD Score
      li	r3,0
      li	r4,5
      branchl	r12,Playerblock_LoadTimesR3KilledR4
      branchl	r12,HUD_KOCounter_UpdateKOs

      #Check If Free Practice
        lbz	r3,0x5(r31)
        cmpwi	r3,0x0
        bne	EggsThinkExit
      #Check For TimeUp
        branchl	r12,MatchInfo_LoadSeconds		#Seconds Left
        cmpwi	r3,0x0
        bne	EggsThinkExit
        branchl	r12,MatchInfo_LoadSubSeconds		#Sub-Seconds Left
        cmpwi	r3,59
        bne	EggsThinkExit

      #On Event End
        mr	r3,r30
        branchl	r12,EventMatch_OnWinCondition			#EventMatch_OnWinCondition

EggsThinkExit:
  mr  r3,MenuData
  bl  ClearToggledOptions
  restore
  blr


			OnCollision:
			blrl

			backup
			mr	r30,r3
			lwz	r31,0x2C(r3)			#Get Data

			#Check If Any Attack Should Break
			lwz	r3,0xDDC(r31)			         #Get Event Data
      lwz r3,MenuDataPointer(r3)     #Get Menu Data
			lbz	r3,DamageThreshold(r3)			#Damage Behavior
			cmpwi	r3,0x1
			beq	Eggs_OnCollisionBreakEgg
			#Check Damage Dealt Before Exploding
			lwz	r3,0xCA0(r31)
			cmpwi	r3,11
			blt	Egg_OnCollisionExit

			Eggs_OnCollisionBreakEgg:
			#Increment Score
			li	r3,0
			li	r4,0
			li	r5,5
			branchl	r12,Playerblock_StoreTimesR3KilledR4

			#Display Effect
			li	r3,1232
			mr	r4,r30
			addi	r5, r31, 76
			crclr	6
			branchl	r12,Textures_DisplayEffectTextures

			#Play Pop Sound
			mr	r3,r31
			li	r4,244
			li	r5,127
			li	r6,64
			branchl	r12,0x8026ae84

			#Explode
			mr	r3,r30
			branchl	r12,0x80289158

			#Spawn New Egg
			lwz	r3,0xDDC(r31)			#Get Event Think
			li	r4,0x0			#Get 0
			stw	r4,0x0(r3)			#Zero Pointer

			Egg_OnCollisionExit:
			li	r3,0x0
			Egg_OnCollisionExitSkip:
			restore
			blr

EggsLoadExit:
restore
blr

####################################################

EggsWindowInfo:
blrl
#amount of options, amount of options in each window

.long 0x0001FFFF  #1 window, Smash Attack has 2 options

####################################################

EggsWindowText:
blrl

######################
## Damage Threshold ##
######################

#Window Title = Damage Threshold
.long 0x44616d61
.long 0x67652054
.long 0x68726573
.long 0x686f6c64
.long 0x

#Option 1 = 12+ Damage
.long 0x3132817B
.long 0x2044616d
.long 0x61676500
.long 0x
.long 0x

#Option 2 = Any Damage
.long 0x416e7920
.long 0x44616d61
.long 0x67650000
.long 0x
.long 0x


################################################################################
################################################################################





#########################
## SDI Training HIJACK INFO ##
#########################

SDITraining:
#STORE STAGE
li	r3,0x20
sth	r3,0xE(r26)

#STORE CPU
lwz	r4,0x0(r29)
bl	P2Struct
mflr	r3
stw	r3,0x18(r4)		#p2 pointer
li	r5,0x2		#fox ext ID
stb	r5,0x0(r3)		#make fox p2
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x10000400
or	r3,r3,r4
stw	r3,0x1F24(r5)

#If IC's Make SoPo
lbz	r3,0x2(r30)		#P1 External ID
cmpwi	r3,0xE
bne	SDITrainingStoreThink
li	r3,0x20
stb	r3,0x2(r30)		#Make SoPo

#STORE THINK FUNCTION
SDITrainingStoreThink:
bl	SDITrainingLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit


	########################
	## SDI Training LOAD FUNCT ##
	########################
	SDITrainingLoad:
	blrl

	backup

	bl	InitializeHighScore

	#Schedule Think
	bl	SDITrainingThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
  li  r5,0    #No Option Menu
	bl	CreateEventThinkFunction

	b	SDITrainingLoadExit


		#########################
		## SDI Training THINK FUNCT ##
		#########################

    .set EventData,31
    .set P1Data,27
    .set P1GObj,28
    .set P2Data,29
    .set P2GObj,30

		SDITrainingThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31

    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4
    mr P2GObj,r5
    mr P2Data,r6

		li	r3,0xF
		stw	r3,0x1A94(r29)
		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	SDITrainingThinkMain

  			bl	SDITrainingFloats
  			mflr	r3
  			bl	Event_EnterGrab
			#Store 999 To Breakout
  			lis	r3,0x4461
  			stw	r3,0x1A4C(r27)
			#Give Percent
  			bl	SDITrainingStartingPercents
  			mflr	r4
  			lwz	r3,0x4(r27)		#Get Char ID
  			lbzx	r3,r3,r4		#Get Percent
  			load	r4,0x80453080		#P1 Static Block
  			sth	r3,0x60(r4)		#Store Percent Int To Display Value
  			sth	r3,0x62(r4)		#Store Percent Int To Display Value (Subchar)
  			bl	IntToFloat
  			stfs	f1,0x1830(r27)		#Store to Actual Damage Value
      #Clear Inputs
        bl  RemoveFirstFrameInputs
			#Save State
  			addi r3,EventData,0x10
  			bl	SaveState_Save
			#Random Start Time
  			li	r3,60
  			branchl	r12,HSD_Randi
  			li	r4,0
  			sub	r3,r4,r3
  			stw	r3,0x4(r31)		#Reset Timer


		SDITrainingThinkMain:

		#Inc Timer
			lwz	r3,0x4(r31)
			addi	r3,r3,0x1
			stw	r3,0x4(r31)

		#Check If SDI'd UpAir (Damage_LightHit + No Hitstun)
		#Check If Already Incremented
			lbz	r3,0xA(r31)
			cmpwi	r3,0x1
			beq	SDITraining_SkipSDICheck
		#Check AS
			lwz	r3,0x10(r27)
			cmpwi	r3,0x55
			bne	SDITraining_SkipSDICheck
		#Check For Hitstun
			lbz	r3, 0x221C (r27)
			rlwinm.	r0, r3, 31, 31, 31
			bne	SDITraining_SkipSDICheck
		#Set Flag
			li	r3,0x1
			stb	r3,0xA(r31)
		#Play Sound
			li		r3,0xAD
			bl PlaySFX
		#Increment Score
			lhz	r3,-0x4ea8(r13)
			addi	r3,r3,0x1
			sth	r3,-0x4ea8(r13)
		#Check To Make New High Score
			lhz	r3,-0x4ea8(r13)
			lhz	r4,-0x4ea6(r13)
			cmpw	r3,r4
			ble	SDITraining_SkipSDICheck
		#Copy To High Score
			sth	r3,-0x4ea6(r13)
		SDITraining_SkipSDICheck:

		#Check If Missed SDI	(Fox in UpAir + P1 in Damage Heavy State)
		#Check If Fox Is Up-Airing
			lwz	r3,0x10(r29)
			cmpwi	r3,0x44
			bne	SDITraining_SkipMissedSDICheck
		#Check If P1 is in Hitlag
			lbz	r3,0x221A(r27)			#Check If in Hitlag
			rlwinm.	r3,r3,0,26,26
			beq	SDITraining_SkipMissedSDICheck
		#Check If Fox is Past Frame 11
			li	r3,11
			bl	IntToFloat
			lfs	f2,0x894(r29)
			fcmpo	cr0,f2,f1
			blt	SDITraining_SkipMissedSDICheck
		#Reset Score
			li	r3,0
			sth	r3,-0x4ea8(r13)
		SDITraining_SkipMissedSDICheck:

		#Update Score
			lhz	r3,-0x4ea8(r13)
			branchl	r12,HUD_KOCounter_UpdateKOs

		#Check State
			lbz	r3,0x8(r31)
			cmpwi	r3,0
			beq	SDITrainingUpThrowThink
			cmpwi	r3,1
			beq	SDITrainingFollowOpponentThink
			cmpwi	r3,2
			beq	SDITrainingJumpThink
			cmpwi	r3,3
			beq	SDITrainingUpAirThink
			cmpwi	r3,4
			beq	SDITrainingCheckForReset


#******************************************************#

		SDITrainingUpThrowThink:
		#Check Timer
			lwz	r3,0x4(r31)
			cmpwi	r3,0x0
			blt	SDITrainingThinkExit
		#Check If In Wait
			lwz	r3,0x10(r29)
			cmpwi	r3,0xE
			bne	SDITrainingUpThrowThink_InputUpThrow

			#Advance to Next State
				li	r3,0x1
				stb	r3,0x8(r31)
				b	SDITrainingFollowOpponentThink

		SDITrainingUpThrowThink_InputUpThrow:
		#UpThrow
			li	r3,127
			stb	r3,0x1A8D(r29)
			b	SDITrainingThinkExit

#******************************************************#

		SDITrainingFollowOpponentThink:

		SDITrainingFollowOpponentThink_CheckIfAirbourne:
			lwz	r3,0xE0(r29)
			cmpwi	r3,0x1
			bne	SDITrainingFollowOpponentThink_CheckDistance
			li	r3,0x2
			stb	r3,0x8(r31)
			b	SDITrainingJumpThink

		SDITrainingFollowOpponentThink_CheckDistance:
			#Determine Which Distance Value
			lwz	r3,0x10(r29)
			cmpwi	r3,0x14
			bne	0xC
			li	r3,15
			b	0x8
			li	r3,10
			bl	SDITrainingInputTowardsOpponent
		#Check If Already Jumping, If So Follow Through
			lwz	r4,0x10(r29)
			cmpwi	r4,0x18
			beq	SDITrainingFollowOpponentThink_CheckIfJumping
			cmpwi	r3,0x1			#Checks If In Range of Opponent
			bne	SDITrainingThinkExit

		#Check If Jumping
		SDITrainingFollowOpponentThink_CheckIfJumping:
			lwz	r3,0x10(r29)
			cmpwi	r3,0x18
			bne	SDITrainingFollowOpponentThink_InputJump
		#If Less than 32 Mm Away, Short Hop
			lfs	f1,0xB4(r27)		#P1 X Coord
			lfs	f2,0xB4(r29)		#P2 X Coord
			fsubs	f3,f2,f1		#Get Difference
			li	r3,32
			bl	IntToFloat
			fabs	f2,f3
			fcmpo	cr0,f2,f1
			blt	SDITrainingThinkExit

		#Input Jump
		SDITrainingFollowOpponentThink_InputJump:
			li	r3,0x800
			stw	r3,0x1A88(r29)
			b	SDITrainingThinkExit

#******************************************************#

		SDITrainingJumpThink:
		#Follow Opponent
			li	r3,5
			bl	SDITrainingInputTowardsOpponent
		#When Less Than 35 Mm Away in the Y Direction, Up Air
			lfs	f1,0xB4(r27)		#P1 X Coord
			lfs	f2,0xB4(r29)		#P2 X Coord
			fsubs	f3,f2,f1		#Get Difference
			li	r3,35
			bl	IntToFloat
			fabs	f2,f3
			fcmpo	cr0,f2,f1
			bgt	SDITrainingJumpThink_CheckToDJ
		#Input UpAir
			li	r3,127
			stb	r3,0x1A8F(r29)
		#Set Timer To Reset
			li	r3,60
			stb	r3,0x9(r31)
		#Advance State
			li	r3,0x3
			stb	r3,0x8(r31)
			b	SDITrainingUpAirThink

		SDITrainingJumpThink_CheckToDJ:
		#If in Frame X Of Jump, DJ
			lwz	r3,0x10(r29)
			cmpwi	r3,0x19
			beq	SDITrainingJumpThink_CheckToDJ_InJump
			cmpwi	r3,0x1A
			beq	SDITrainingJumpThink_CheckToDJ_InJump
			b	SDITrainingThinkExit
			SDITrainingJumpThink_CheckToDJ_InJump:
			li	r3,4
			bl	IntToFloat
			lfs	f2,0x894(r29)
			fcmpo	cr0,f1,f2
			bne	SDITrainingThinkExit
		#Enter DJ
			li	r3,0x800
			stw	r3,0x1A88(r29)
			b	SDITrainingThinkExit

#******************************************************#

		SDITrainingUpAirThink:
		#Check If UpAir Hitboxes Are Over
			li	r3,12
			bl	IntToFloat
			lfs	f2,0x894(r29)
			fcmpo	cr0,f2,f1
			bge	SDITrainingCheckForReset
		#Follow Opponent
			li	r3,5
			bl	SDITrainingInputTowardsOpponent
		#Check If Back On Ground
			lwz	r3,0xE0(r29)
			cmpwi	r3,0x0
			bne	SDITrainingCheckForReset
		#Advance State
			li	r3,0x4
			stb	r3,0x8(r31)
			b	SDITrainingCheckForReset

#******************************************************#

SDITrainingInputTowardsOpponent:
#Returns a bool indicating if the character is within range

backup

mr	r31,r3			#Backup Distance Threshold

#Get X Distance
	lfs	f1,0xB0(r27)		#P1 X Coord
	lfs	f2,0xB0(r29)		#P2 X Coord
	fsubs	f3,f2,f1		#Get Difference
#If Within 4 Mm, Jump
	mr	r3,r31
	bl	IntToFloat
	fabs	f2,f3
	fcmpo	cr0,f2,f1
	bgt	SDITrainingFollowOpponentThink_InputTowardsOpponent
	li	r3,0x1
	b	SDITrainingInputTowardsOpponent_Exit

SDITrainingFollowOpponentThink_InputTowardsOpponent:
#Push Towards Opponent's Direction
	bl	GetDirectionInRelationToP1
	mulli	r3,r3,-1		#Negate This
	li	r4,127
	mullw	r3,r3,r4
	stb	r3,0x1A8C(r29)
	li	r3,0x0

SDITrainingInputTowardsOpponent_Exit:
	restore
	blr

#******************************************************#


		SDITrainingCheckForReset:
			lbz	r3,0x9(r31)
			cmpwi	r3,0x0
			beq	SDITrainingThinkExit
			subi	r3,r3,0x1
			stb	r3,0x9(r31)
			cmpwi	r3,0x0
			bne	SDITrainingThinkExit
		#Load State
			addi r3,EventData,0x10
			bl	SaveState_Load
			addi r3,EventData,0x10
			bl	SaveState_Load
		#Random Timer
			li	r3,60
			branchl	r12,HSD_Randi
			mulli	r3,r3,-1
			stw	r3,0x4(r31)
		#Reset State
			li	r3,0
			stb	r3,0x8(r31)
		#Reset SDI'd Flag
			li	r3,0x0
			stb	r3,0xA(r31)

		SDITrainingThinkExit:
		restore
		blr

##############

Event_EnterGrab:
backup

mr	r20,r3

#Move P1
lfs	f1,0x0(r20)
stfs	f1,0xB0(r27)
lfs	f1,0x4(r20)
stfs	f1,0xB4(r27)
mr	r3,r28
bl  UpdatePosition
mr	r3,r28
bl	CheckIfPlayerHasAFollower
cmpwi	r3,0
beq	Event_EnterGrab_MoveP2
#Move Subchar
lfs	f1,0x0(r20)
stfs	f1,0xB0(r5)
lfs	f1,0x4(r20)
stfs	f1,0xB4(r5)
bl  UpdatePosition


Event_EnterGrab_MoveP2:
#Move P2
lfs	f1,0x8(r20)
stfs	f1,0xB0(r29)
lfs	f1,0xC(r20)
stfs	f1,0xB4(r29)
mr	r3,r30
bl  UpdatePosition
mr	r3,r30
bl	CheckIfPlayerHasAFollower
cmpwi	r3,0
beq	Event_EnterGrab_EnterGrabAS
#Move Subchar
lfs	f1,0x8(r20)
stfs	f1,0xB0(r5)
lfs	f1,0xC(r20)
stfs	f1,0xB4(r5)
bl  UpdatePosition

Event_EnterGrab_EnterGrabAS:
#Store P1 into P2 Grab Pointer
stw	r28,0x1A58(r29)

#Enter P2 Into Grab
mr	r3,r30			#P2 Enters Grab
branchl	r12,AS_GrabOpponent

#Enter P1 Into Grabbed
mr	r3,r28			#P1 Grabbed
mr	r4,r30			#P2 = Grabber
branchl	r12,AS_Grabbed

#Enter P2 Into GrabWait
mr	r3,r30			#P2 Enters GrabWait
branchl	r12,AS_CatchWait

#Enter P2 Into Grounded
mr	r3,r29
branchl	r12,SetAsGrounded

#Remove P2's GFX Pointer That Is Crashing the Game
li	r3,0x0
stw	r3,0x60C(r29)

restore
blr

##############

SDITrainingStartingPercents:
blrl
.long 0x085F8040 # Mario = 8 / Fox = 95 / Falcon = 70 / DK = 25
.long 0x0030190F # Kirby = 0 / Bowser = 25 / Link = 25 / Sheik = 15
.long 0x00000000 # Ness = 0 / Peach = 0 / Popo = 0 / Nana = 0
.long 0x08050F00 # Pikachu = 8 / Samus = 5 / Yoshi = 15 / Jiggs = 0
.long 0x00001400 # Mewtwo = 0 / Luigi = 0 / Marth = 20 / Zelda = 0
.long 0x19085F00 # YLink = 25 / Doc = 8 / Falco = 95 / Pichu = 0
.long 0x002D3A00 # GaW = 0 / Ganon = 45 / Roy = 58

SDITrainingFloats:
blrl
.long 0xC02CCCCD		#P1 X Position
.long 0x00000000		#P1 Y Position
.long 0x4144CCCD		#P2 X Position
.long 0x00000000		#P2 Y Position

SDITrainingLoadExit:
restore
blr




################################################################################
################################################################################



#########################
## Reversal HIJACK INFO ##
#########################

Reversal:
#STORE STAGE
#li	r3,0x20
#sth	r3,0xE(r26)

#STORE CPU
lwz	r4,0x0(r29)
bl	P2Struct
mflr	r3
stw	r3,0x18(r4)		#p2 pointer
load	r5,0x8043207c		#get preload table
lwz	r6,0x18(r5)		#get p2 character ID
cmpwi	r6,0x12
bne	0x8
li	r6,0x13		#Make Zelda Sheik
stb	r6,0x0(r3)		#store chosen char
lbz	r6,0x1C(r5)		#get p2 costume ID
stb	r6,0x3(r3)		#store p2 costume ID
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x002C0009
or	r3,r3,r4
stw	r3,0x1F24(r5)

#STORE THINK FUNCTION
bl	ReversalLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Reversal LOAD FUNCT ##
	########################
	ReversalLoad:
	blrl

	backup

	#Schedule Think
	bl	ReversalThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
  bl	ReversalWindowInfo
  mflr	r5
  bl	ReversalWindowText
  mflr	r6
	bl	CreateEventThinkFunction

	b	ReversalLoadExit


		#########################
		## Reversal THINK FUNCT ##
		#########################

    .set MenuData,26
    .set EventData,31
    .set P1Data,27
    .set P1GObj,28
    .set P2Data,29
    .set P2GObj,30

		.set firstFrameFlag,0x0
		.set timer,0x4
		.set CPUAttack,(OptionMenuMemory+0x2)+(0x0)
		.set P1FacingDirection,(OptionMenuMemory+0x2)+(0x1)
		.set CPUFacingDirection,(OptionMenuMemory+0x2)+(0x2)
    .set CPUAttackToggled,OptionMenuToggled+(0x0)
    .set P1FacingDirectionToggled,OptionMenuToggled+(0x1)
    .set CPUFacingDirectionToggled,OptionMenuToggled+(0x2)
		.set AerialThinkStruct,0x20

		ReversalThink:
		blrl

    .set EventData,31

		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31
    lwz MenuData,MenuDataPointer(EventData)

    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4
    mr P2GObj,r5
    mr P2Data,r6

		li	r3,0xF
		stb	r3,0x1A94(r29)
		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	ReversalThinkMain

  			#bl	Reversal_Floats
  			#mflr r3
  			#bl	InitializePositions
      #Move PLayers Center Stage
        bl  PlacePlayersCenterStage
      #Clear Inputs
        bl  RemoveFirstFrameInputs
      #SaveState
        addi  r3,EventData,0x10       #SaveState start
  			bl	SaveState_Save
			#Set Frame 1 As Over
  			li		r3,0x1
  			stb		r3,0x0(r31)
			#Set Timer to -60
  			li		r3,-60
  			stw		r3,0x4(r31)


		ReversalThinkMain:

		bl	GiveFullShields

    #Reset when menu is toggled
      lbz r3,P1FacingDirectionToggled(MenuData)
  		cmpwi	r3,0x0
  		bne	ReversalReset			#Only Run When Hovered Over Facing Direction
      lbz r3,CPUFacingDirectionToggled(MenuData)
  		cmpwi	r3,0x0
  		bne	ReversalReset			#Only Run When Hovered Over Facing Direction
      lbz r3,CPUAttackToggled(MenuData)
      cmpwi r3,0x0
      bne ReversalReset
		ReversalSkipFacingReset:

		#Move Players Apart With DPad
      addi  r3,EventData,0x10       #SaveState start
  		bl	AdjustResetDistance
  		cmpwi	r3,-1
  		bne	ReversalReset

		ReversalThinkSequence:

		#Increment Timer
		lwz	r20,0x4(r31)		#get timer
		addi	r20,r20,0x1
		stw	r20,0x4(r31)		#store timer

		#Give Invincibility in Wait, Squat Reverse, IASA Flag Flipped
		lwz	r3,0x10(r29)
		cmpwi	r3,0xE
		beq	ReversalGiveInvincibility
		cmpwi	r3,0x29
		beq	ReversalGiveInvincibility
		lbz	r3, 0x2218 (r29)
		rlwinm.	r3, r3, 25, 31, 31
		bne	ReversalGiveInvincibility
		b	ReversalCheckToAttack

		ReversalGiveInvincibility:
		mr	r3,r30
		li	r4,0x2
		bl	GiveInvincibility

		#Check To Attack
		ReversalCheckToAttack:
		#Check Timer
			cmpwi	r20,45
			blt	ReversalThinkExit
		#Check If Attack is Over
			lbz r3,AerialThinkStruct(r31)
			cmpwi r3,0x0
			bne ReversalCheckToReset


		ReversalDecideSmashAttack:
		lbz	r3,CPUAttack(MenuData)
		cmpwi	r3,0x0
		beq	ReversalRandomSmashAttack
		cmpwi	r3,0x1
		beq	ReversalFSmash
		cmpwi	r3,0x2
		beq	ReversalDSmash
		cmpwi	r3,0x3
		beq	ReversalUSmash
		cmpwi r3,0x4
		beq	ReversalRandomAerial
		cmpwi r3,0x5
		beq	ReversalNair
		cmpwi r3,0x6
		beq	ReversalFair
		cmpwi r3,0x7
		beq	ReversalDair
		cmpwi	r3,0x8
		beq	ReversalFTilt
		cmpwi	r3,0x9
		beq	ReversalDTilt
		cmpwi	r3,0xA
		beq	ReversalUTilt

		ReversalRandomSmashAttack:
			li	r3,3
			branchl	r12,HSD_Randi
			mr	r21,r3
		#Check If Move is Blacklisted
			lwz	r4,0x4(r29)		#Char ID
			bl	Reversal_Blacklist
			mflr	r5		#Get Frame Data Table
			mulli	r4,r4,0x4		#Get Characters Offset
			add	r4,r4,r5		#Get Characters Table Entry Start
			lbzx	r4,r21,r4		#Get Moves Entry
			cmpwi	r4,0x1		#Is Move BlackListed?
			beq	ReversalRandomSmashAttack

		#Perform Move
			cmpwi	r21,0x0
			beq	ReversalFSmash
			cmpwi	r21,0x1
			beq	ReversalUSmash
			cmpwi	r21,0x2
			beq	ReversalDSmash
		ReversalFSmash:
		#Input Atack
			li	r3,127		#Forward
			lfs	f1,0x2C(r29)		#Facing Direction
			fctiwz	f1,f1
			stfd	f1,0xF0(sp)
			lwz	r4,0xF4(sp)
			mullw	r3,r3,r4		#Forward * facing direction
			stb	r3,0x1A8E(r29)
		#Set Attack as ended
			li	r3,0x1
			stb r3,AerialThinkStruct(r31)
			b	ReversalCheckToReset
		ReversalUSmash:
			li	r3,127
			stb	r3,0x1A8F(r29)
			b	ReversalCheckToReset
		#Set Attack as ended
			li	r3,0x1
			stb r3,AerialThinkStruct(r31)
		ReversalDSmash:
			li	r3,-127
			stb	r3,0x1A8F(r29)
		#Set Attack as ended
			li	r3,0x1
			stb r3,AerialThinkStruct(r31)
			b		ReversalCheckToReset
		ReversalRandomAerial:
		#Perform Aerial
			mr		r3,r30
			addi	r4,r31,AerialThinkStruct
			li		r5,0		#Random Aerial
			bl		PerformAerialThink
			b		ReversalCheckToReset
		ReversalNair:
		ReversalFair:
		ReversalDair:
		#Perform Aerial
			subi	r5,r3,0x4
			mr		r3,r30
			addi	r4,r31,AerialThinkStruct
			bl		PerformAerialThink
			b		ReversalCheckToReset
		ReversalFTilt:
			li	r3,45
			lfs	f1,0x2C(r29)		#Facing Direction
			fctiwz	f1,f1
			stfd	f1,0xF0(sp)
			lwz	r4,0xF4(sp)
			mullw	r3,r3,r4		#Forward * facing direction
			stb	r3,0x1A8C(r29)
			li	r3,0x100
			stw	r3,0x1A88(r29)
		#Set Attack as ended
			li	r3,0x1
			stb r3,AerialThinkStruct(r31)
			b	ReversalCheckToReset
		ReversalUTilt:
			li	r3,45
			stb	r3,0x1A8D(r29)
			li	r3,0x100
			stw	r3,0x1A88(r29)
		#Set Attack as ended
			li	r3,0x1
			stb r3,AerialThinkStruct(r31)
			b	ReversalCheckToReset
		ReversalDTilt:
			li	r3,-45
			stb	r3,0x1A8D(r29)
			li	r3,0x100
			stw	r3,0x1A88(r29)
		#Set Attack as ended
			li	r3,0x1
			stb r3,AerialThinkStruct(r31)
			b	ReversalCheckToReset


		ReversalCheckToReset:
			cmpwi	r20,150		#Restore After 120 Frames
			blt	ReversalThinkExit
		ReversalReset:
		#Check to Swap Position
			li	r3,2        #1/2 Chance to swap positions
			branchl r12,HSD_Randi
      cmpwi r3,0x0
      beq ReversalReset_NoSwap
    #Swap Position
        addi r5,EventData,0x10
      #Get P1 Data
        lwz r3,0x0(r5)
        lfs f1,0xB0(r3)
        lfs f2,0xB4(r3)
        lfs f3,0x2C(r3)
      #Get P2 Data
        lwz r4,0x8(r5)
        lfs f4,0xB0(r4)
        lfs f5,0xB4(r4)
        lfs f6,0x2C(r4)
      #Swap Data
        stfs f1,0xB0(r4)
        stfs f2,0xB4(r4)
        stfs f3,0x2C(r4)
        stfs f4,0xB0(r3)
        stfs f5,0xB4(r3)
        stfs f6,0x2C(r3)
		ReversalReset_NoSwap:
		#Adjust P1 Facing Direction Based on Preference
      addi r5,EventData,0x10
			lbz	r3,P1FacingDirection(MenuData)
			cmpwi	r3,0x1
			bne	ReversalAdjustCPUDirection
		#Invert P1 Facing Direction
			lwz	r3,0x0(r5)
			lfs	f1,0x2C(r3)
			fneg	f1,f1
			stfs	f1,0x2C(r3)
		#Adjust CPU Facing Direction Based on Preference
		ReversalAdjustCPUDirection:
			lbz	r3,CPUFacingDirection(MenuData)
			cmpwi	r3,0x1
			bne	ReversalLoadState
		#Invert P1 Facing Direction
			lwz	r3,0x8(r5)
			lfs	f1,0x2C(r3)
			fneg	f1,f1
			stfs	f1,0x2C(r3)
		#Restore
		ReversalLoadState:
			addi r3,EventData,0x10
			bl	SaveState_Load
		#Reset Timer
			li	r3,30
			branchl	r12,HSD_Randi
			li	r4,0
			sub	r3,r4,r3
			stw	r3,0x4(r31)
		#Reset AerialThinkStruct
			li	r3,0x0
			stw r3,AerialThinkStruct(r31)

		ReversalThinkExit:
      mr  r3,MenuData
      bl  ClearToggledOptions
			bl	UpdateAllGFX
			restore
			blr


#################################

Reversal_Floats:
blrl
.long 0xC0F9999A		#P1 X Position
.long 0x40F9999A		#P2 X Position
.long 0x38d1b717		#FD Floor Y Coord
.long 0x38d1b717		#FD Floor Y Coord

#################################

Reversal_Blacklist:
blrl
#Mario
.long 0x00000000		#FSmash USmash DSmash

#Fox
.long 0x01000000 	#FSmash USmash DSmash

#Cptn Falcon
.long 0x00000000		#FSmash USmash DSmash

#DK
.long 0x00010000		#FSmash USmash DSmash

#Kirby
.long 0x00000000		#FSmash USmash DSmash

#Bowser
.long 0x00010000		#FSmash USmash DSmash

#link
.long 0x00000000		#FSmash USmash DSmash

#Sheik
.long 0x01000000		#FSmash USmash DSmash

#Ness
.long 0x00010100		#FSmash USmash DSmash

#Peach
.long 0x00010000		#FSmash USmash DSmash

#Popo
.long 0x00000000		#FSmash USmash DSmash

#Nana
.long 0x00000000		#FSmash USmash DSmash

#Pikachu
.long 0x00000000		#FSmash USmash DSmash

#Samus
.long 0x00010000		#FSmash USmash DSmash

#Yoshi
.long 0x00010000		#FSmash USmash DSmash

#Jiggs
.long 0x00010000		#FSmash USmash DSmash

#mewtwo
.long 0x00010000		#FSmash USmash DSmash

#Luigi
.long 0x00000000		#FSmash USmash DSmash

#Marth
.long 0x00010000		#FSmash USmash DSmash

#Zelda
.long 0x00010000		#FSmash USmash DSmash

#YLink
.long 0x00000000		#FSmash USmash DSmash

#Doc
.long 0x00000000		#FSmash USmash DSmash

#Falco
.long 0x01000000		#FSmash USmash DSmash

#Pichu
.long 0x00000000		#FSmash USmash DSmash

#GaW
.long 0x00000100		#FSmash USmash DSmash

#Ganon
.long 0x00000000		#FSmash USmash DSmash

#Roy
.long 0x00010000		#FSmash USmash DSmash

####################################################

ReversalWindowInfo:
blrl
#amount of options, amount of options in each window

.long 0x020A0101  #3 window, Smash Attack has 11 options, Facing Direction Has 2

####################################################

ReversalWindowText:
blrl

########
## DI ##
########

#Window Title = CPU Attack
.long 0x43505520
.long 0x41747461
.long 0x636b0000

#Option 1 = Random Smash Attack
.long 0x52616e64
.long 0x6f6d2053
.long 0x6d617368
.long 0x20417474
.long 0x61636b00

#Option 2 = Forward Smash
.long 0x466f7277
.long 0x61726420
.long 0x536d6173
.long 0x68000000

#Option 3 = Down Smash
.long 0x446f776e
.long 0x20536d61
.long 0x73680000

#Option 4 = Up Smash
.long 0x55702053
.long 0x6d617368
.long 0x

#Option 5 = Random Aerial
.long 0x52616e64
.long 0x6f6d2041
.long 0x65726961
.long 0x6c000000

#Option 6 = Fair
.long 0x46616972
.long 0x

#Option 7 = Nair
.long 0x4e616972
.long 0x

#Option 8 = Dair
.long 0x44616972
.long 0x

#Option 9 = FTilt
.long 0x4654696c
.long 0x74000000

#Option 10 = DTilt
.long 0x4454696c
.long 0x74000000

#Option 11 = UTilt
.long 0x5554696c
.long 0x74000000

#########$$$#############
## P1 Facing Direction ##
##########$$$############

#Window Title = Facing Direction
.long 0x50312046
.long 0x6163696e
.long 0x67204469
.long 0x72656374
.long 0x696f6e00

#Option 1 = Towards
.long 0x546f7761
.long 0x72647300
.long 0x
.long 0x
.long 0x

#Option 2 = Away
.long 0x41776179
.long 0x
.long 0x
.long 0x
.long 0x

#########$$$##############
## CPU Facing Direction ##
##########$$$#############

#Window Title = CP Facing Direction
.long 0x43502046
.long 0x6163696e
.long 0x67204469
.long 0x72656374
.long 0x696f6e00


#Option 1 = Towards
.long 0x546f7761
.long 0x72647300
.long 0x
.long 0x
.long 0x

#Option 2 = Away
.long 0x41776179
.long 0x
.long 0x
.long 0x
.long 0x

####################################################

ReversalLoadExit:
restore
blr



################################################################################
################################################################################


#########################
## Powershield HIJACK INFO ##
#########################

Powershield:
#STORE STAGE
li	r3,0x20
sth	r3,0xE(r26)

#STORE CPU
lwz	r4,0x0(r29)
bl	P2Struct
mflr	r3
stw	r3,0x18(r4)		#p2 pointer
li	r5,0x14		#fox ext ID
stb	r5,0x0(r3)		#make fox p2
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x00000200
or	r3,r3,r4
stw	r3,0x1F24(r5)

#STORE THINK FUNCTION
bl	PowershieldLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Powershield LOAD FUNCT ##
	########################
	PowershieldLoad:
	blrl

	backup

	#Schedule Think
	bl	PowershieldThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
  bl	PowershieldWindowInfo
  mflr	r5
  bl	PowershieldWindowText
  mflr	r6
	bl	CreateEventThinkFunction

	bl	InitializeHighScore

	b	PowershieldLoadExit


		#########################
		## Powershield THINK FUNCT ##
		#########################

    #Registers
    .set MenuData,26
    .set EventData,31
    .set P1Data,27
    .set P1GObj,28
    .set P2Data,29
    .set P2GObj,30

    #Offsets
		.set FireSpeed,(OptionMenuMemory+0x2)+0x0

		PowershieldThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31
    lwz   MenuData,MenuDataPointer(EventData)

    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4
    mr P2GObj,r5
    mr P2Data,r6

		bl	StoreCPUTypeAndZeroInputs

		#Make P2 A Follower (No Nudge)
		#li	r3,0x8
		#stb	r3,0x221F(r29)
		#li	r3,0x1
		lbz	r0, 0x221D (r29)
		rlwimi	r0,r3,2,29,29
		stb	r0, 0x221D (r29)

		#Update GFX
		mr	r3,r30
		bl	UpdateAllGFX

		#Give Invincibility To P2
		mr	r3,r30
		li	r4,0x2
		bl	GiveInvincibility

		#Reset All Stale Moves
		bl	ResetStaleMoves

		#DPad Changes Falco's Side
		lhz	r3,0x662(r27)			#Get Held Buttons
		cmpwi	r3,0x0
		bne	Powershield_SkipPositionChange
		#CHECK FOR DPAD TO CHANGE Side
		lwz	r3,0x668(r27)			#Get DPad
		rlwinm.	r0,r3,0,30,30
		beq	Powershield_CheckLeft
		lwz	r3,0x10(r31)			#P1's Backup
		lfs	f1,0xB0(r3)			#X Pos
		fabs	f1,f1
		stfs	f1,0xB0(r3)			#X Pos
		lfs	f1,0x2C(r3)			#Facing
		fabs	f1,f1
		fneg	f1,f1			#Negate Always
		stfs	f1,0x2C(r3)			#Facing

		lwz	r3,0x18(r31)			#P2's Backup
		lfs	f1,0xB0(r3)			#X Pos
		fabs	f1,f1
		fneg	f1,f1			#Negate Always
		stfs	f1,0xB0(r3)			#X Pos
		lfs	f1,0x2C(r3)			#Facing
		fabs	f1,f1			#Always Positive
		stfs	f1,0x2C(r3)			#Facing
		b	PowershieldRestore

		Powershield_CheckLeft:
		rlwinm.	r0,r3,0,31,31
		beq	Powershield_SkipPositionChange
		lwz	r3,0x10(r31)			#P1's Backup
		lfs	f1,0xB0(r3)			#X Pos
		fabs	f1,f1
		fneg	f1,f1			#Negate Always
		stfs	f1,0xB0(r3)			#X Pos
		lfs	f1,0x2C(r3)			#Facing
		fabs	f1,f1			#Always Positive
		stfs	f1,0x2C(r3)			#Facing

		lwz	r3,0x18(r31)			#P2's Backup
		lfs	f1,0xB0(r3)			#X Pos
		fabs	f1,f1
		stfs	f1,0xB0(r3)			#X Pos
		lfs	f1,0x2C(r3)			#Facing
		fabs	f1,f1
		fneg	f1,f1			#Negate Always
		stfs	f1,0x2C(r3)			#Facing
		b	PowershieldRestore
		Powershield_SkipPositionChange:

		#Act Out Of Laser Hit
		bl	ActOutOfLaserHitDisplay

		#Check For Powershield Reflect
		#Check For Shield Action State
			lwz	r3,0x10(r27)
			cmpwi	r3,0xB6		#Shield Start
			bne	Powershield_SkipPowershieldCheck
		#Check For Powershield Bool
			lwz	r3,0x2368(r27)
			cmpwi	r3,0x0
			beq	Powershield_SkipPowershieldCheck
		#Remove Flag
			li	r3,0x0
			stw	r3,0x2368(r27)
		#Increment Score
			lhz	r3,-0x4ea8(r13)
			addi	r3,r3,0x1
			sth	r3,-0x4ea8(r13)
		#Check To Make New High Score
			lhz	r3,-0x4ea8(r13)
			lhz	r4,-0x4ea6(r13)
			cmpw	r3,r4
			ble	Powershield_SkipPowershieldCheck
		#Copy To High Score
			sth	r3,-0x4ea6(r13)
		Powershield_SkipPowershieldCheck:

		#Check For Powershield Miss
		#Check For Shield Stun
			lwz	r3,0x10(r27)
			cmpwi	r3,0xB5		#Shield Stun
			beq	Powershield_ResetScore
		#Check For Hitstun
			lbz	r3, 0x221C (r27)
			rlwinm.	r0, r3, 31, 31, 31
			bne	Powershield_ResetScore
			b	Powershield_SkipMissedPowershieldCheck
		Powershield_ResetScore:
		#Reset Score
			li	r3,0
			sth	r3,-0x4ea8(r13)
		Powershield_SkipMissedPowershieldCheck:

		#Update HUD Score
		lhz	r3,-0x4ea8(r13)
		branchl	r12,HUD_KOCounter_UpdateKOs


		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	PowershieldThinkMain

		#Set Timer to -60
		li		r3,-60
		stw		r3,0x4(r31)
		#Fix Inputs
		bl	CurrentInputsAsLastFramesInputs
		#SaveState
		addi r3,EventData,0x10
		bl	SaveState_Save


		PowershieldThinkMain:
		bl	GiveFullShields

		PowershieldThinkSequence:
		#Increment Timer
		lwz	r20,0x4(r31)		#get timer
		addi	r20,r20,0x1
		stw	r20,0x4(r31)		#store timer

		#KneeBend(shorthop)
		cmpwi	r20,0
		blt	PowershieldThinkExit
		bne	PowershieldSkipJump
		li	r3,0x800
		stw	r3,0x1A88(r29)
		b	PowershieldThinkExit

		#Get Random Laser Timing in JumpF
		PowershieldSkipJump:
		lwz	r3,0x10(r29)
		cmpwi	r3,0x19
		bne	PowershieldSkipLaser
		li	r3,4
		bl	IntToFloat
		lfs	f2,0x894(r29)
		fcmpo	cr0,f1,f2
		bne	PowershieldThinkExit
		#Random Laser Timing
		li	r3,2
		branchl	r12,HSD_Randi
		addi	r3,r3,5		#Start on Frame 5
		stw	r3,0x8(r31)
		#Input Laser
		li	r3,0x200
		stw	r3,0x1A88(r29)
		b	PowershieldThinkExit

		PowershieldSkipLaser:
		#Check if in Laser Shoot
		lwz	r3,0x10(r29)
		cmpwi	r3,0x159
		bne	PowershieldCheckForIASA
		#Check in on the right frame
		lwz	r3,0x8(r31)
		bl	IntToFloat
		lfs	f2,0x894(r29)
		fcmpo	cr0,f1,f2
		bne	PowershieldCheckForIASA
		#Input a FF
		li	r3,-127
		stb	r3,0x1A8D(r29)
		b	PowershieldThinkExit


		PowershieldCheckForIASA:
		#Check if in Landing
		lwz	r3,0x10(r29)
		cmpwi	r3,0x2A
		bne	PowershieldThinkExit
		#Check If Can Interrupt
		li	r3,3
		bl	IntToFloat
		lfs	f2,0x894(r29)
		fcmpo	cr0,f2,f1
		blt	PowershieldThinkExit
		bne	PowershieldRandom
		li	r3,14
		branchl	r12,HSD_Randi
		addi	r3,r3,15
		stb	r3,0xF(r31)
		#Get Interval
		lbz	r3,FireSpeed(MenuData)
		cmpwi	r3,0x0
		beq	PowershieldRandom
		cmpwi	r3,0x1
		beq	PowershieldSlow
		cmpwi	r3,0x2
		beq	PowershieldMedium
		cmpwi	r3,0x3
		beq	PowershieldFast
		cmpwi	r3,0x4
		beq	PowershieldVeryFast

		PowershieldRandom:
		lbz	r3,0xF(r31)
		bl	IntToFloat
		lfs	f2,0x894(r29)
		fcmpo	cr0,f2,f1
		blt	PowershieldThinkExit
		li	r3,-1
		stw	r3,0x4(r31)
		b	PowershieldThinkExit

		PowershieldSlow:
		#Reset Timer
		li	r3,-30
		stw	r3,0x4(r31)
		b	PowershieldThinkExit

		PowershieldMedium:
		#Reset Timer
		li	r3,-15
		stw	r3,0x4(r31)
		b	PowershieldThinkExit

		PowershieldFast:
		#Reset Timer
		li	r3,-8
		stw	r3,0x4(r31)
		b	PowershieldThinkExit

		PowershieldVeryFast:
		#Reset Timer
		li	r3,-1
		stw	r3,0x4(r31)
		b	PowershieldThinkExit

		PowershieldThinkExit:
    mr  r3,MenuData
    bl  ClearToggledOptions
		restore
		blr


PowershieldLoadExit:
restore
blr

##################################

PowershieldRestore:
addi r3,EventData,0x10
bl	SaveState_Load
addi r3,EventData,0x10
bl	SaveState_Load
b	PowershieldThinkExit

##################################

PowershieldWindowInfo:
blrl
.long 0x00040000		#1 window, 5 options

PowershieldWindowText:
blrl

#Title
.long 0x46697265
.long 0x20537065
.long 0x65640000
.long 0x00000000
.long 0x00000000

#Random
.long 0x52616e64
.long 0x6f6d0000
.long 0x
.long 0x
.long 0x

#Slow
.long 0x536c6f77
.long 0x
.long 0x
.long 0x
.long 0x

#Medium
.long 0x4d656469
.long 0x756d0000
.long 0x
.long 0x
.long 0x

#Fast
.long 0x46617374
.long 0x
.long 0x
.long 0x
.long 0x

#Very Fast
.long 0x56657279
.long 0x20466173
.long 0x74000000
.long 0x
.long 0x



##################################




################################################################################
################################################################################

#########################
## Shield Drop HIJACK INFO ##
#########################

ShieldDrop:
#STORE STAGE
li	r3,0x1f
sth	r3,0xE(r26)

#STORE CPU
lwz	r4,0x0(r29)
bl	P2Struct
mflr	r3
stw	r3,0x18(r4)		#p2 pointer
load	r5,0x8043207c		#get preload table
lwz	r6,0x18(r5)		#get p2 character ID
cmpwi	r6,0x12
bne	0x8
li	r6,0x13		#Make Zelda Sheik
stb	r6,0x0(r3)		#store chosen char
lbz	r6,0x1C(r5)		#get p2 costume ID
stb	r6,0x3(r3)		#store p2 costume ID
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x00200048
or	r3,r3,r4
stw	r3,0x1F24(r5)

#STORE THINK FUNCTION
bl	ShieldDropLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Shield Drop LOAD FUNCT ##
	########################
	ShieldDropLoad:
	blrl

	backup

	#Schedule Think
	bl	ShieldDropThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
  bl	ShieldDropWindowInfo
  mflr	r5
  bl	ShieldDropWindowText
  mflr	r6
	bl	CreateEventThinkFunction

	b	ShieldDropLoadExit


		##########################
		## Shield Drop THINK FUNCT ##
		##########################

    #Registers
    .set MenuData,26
    .set EventData,31
    .set P1Data,27
    .set P1GObj,28
    .set P2Data,29
    .set P2GObj,30

    #Offsets
		.set FacingDirection,(OptionMenuMemory+0x2)+0x0
    .set FacingDirectionToggled,(OptionMenuToggled)+0x0

		ShieldDropThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31
    lwz   MenuData,MenuDataPointer(EventData)

    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4
    mr P2GObj,r5
    mr P2Data,r6

		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	ShieldDropThinkMain

			#Set Frame 1 As Over
  			li	r3,0x1
  			stb	r3,0x0(r31)
  			bl	ShieldDrop_Floats
  			mflr	r3
  			bl	InitializePositions
      #Clear Inputs
        bl  RemoveFirstFrameInputs
			#Store Y Position to Last Known Y Position
  			lfs	f1,0xB4(r29)
  			stfs	f1,0x834(r29)
			#Save State
  			addi r3,EventData,0x10
  			bl	SaveState_Save
			#Set Timer to -60
  			li	r3,-60
  			stw	r3,0x4(r31)



		ShieldDropThinkMain:
		.set AerialThinkStruct,0x8

		bl	GiveFullShields

		lbz r3,FacingDirectionToggled(MenuData)
		cmpwi	r3,0			#Check If Toggled An Option
		bne	ShieldDropReset
    lbz r3,FacingDirectionToggled(MenuData)
		cmpwi	r3,0			#Check If Toggled An Option
		bne	ShieldDropReset

		#Move Players Apart With DPad
    addi  r3,EventData,0x10       #SaveState start
		bl	AdjustResetDistance
		cmpwi	r3,-1
		bne	ShieldDropReset

		ShieldDropThinkSequence:
		#Increment Timer
		lwz	r20,0x4(r31)		#get timer
		addi	r20,r20,0x1
		stw	r20,0x4(r31)		#store timer

		#Check if In Wait
			lwz	r3,0x10(r29)
			cmpwi	r3,0xE
			bne ShieldDropNoIntangibility
		#Give Intangibility in Wait
			mr	r3,r30
			li	r4,0x2
			bl	GiveInvincibility
		ShieldDropNoIntangibility:

		#Check To Start Aerial
		cmpwi	r20,40
		blt	ShieldDropThinkExit

		#Perform Aerial
			mr	r3,r30
			addi	r4,r31,AerialThinkStruct
			li		r5,0		#Random Attack
			bl	PerformAerialThink

		ShieldDropCheckToShield:
		#Check If CPU is done with Aerial Sequence
			lbz	r3,AerialThinkStruct(r31)
			cmpwi	r3,0x0
			beq	ShieldDropCheckToReset
		#Hold Shield
			li	r3,0xC0		#Hit L
			stw	r3,0x1A88(r29)		#Hold Shield

		ShieldDropCheckToReset:
		cmpwi	r20,140
		bne	ShieldDropThinkExit
		ShieldDropReset:
		#Randomize Position
		li	r3,0x1			#Opposing Sides of Stage
		bl	Randomize_LeftorRightSide
		#Adjust Facing Direction Based on Preference
		lbz	r3,FacingDirection(MenuData)
		cmpwi	r3,0x1
		bne	ShieldDropLoadState
		#Invert P1 Facing Direction
		lwz	r3,0x10(r31)
		lfs	f1,0x2C(r3)
		fneg	f1,f1
		stfs	f1,0x2C(r3)
		ShieldDropLoadState:
		#Backup P1 Analog Timers
		lwz	r23,0x620(r27)
		lwz	r24,0x624(r27)
		#Restore
		addi r3,EventData,0x10
		bl	SaveState_Load
		#Restore P1 Analog Timers
		lwz	r23,0x620(r27)
		lwz	r24,0x624(r27)
		#Reset Timer
		li	r3,50
		branchl	r12,HSD_Randi
		li	r4,0
		sub	r3,r4,r3
		stw	r3,0x4(r31)
		#Reset Aerial Move Think Struct
		li	r3,0
		stw	r3,AerialThinkStruct(r31)

		ShieldDropThinkExit:
    mr  r3,MenuData
    bl  ClearToggledOptions
		bl	UpdateAllGFX
		restore
		blr

#################################

ShieldDrop_Floats:
blrl
.long 0xC0F9999A		#P1 X Position
.long 0x40F9999A		#P2 X Position
.long 0x425999b4		#Top Plat Y Position
.long 0x425999b4		#Top Plat Y Position
.long 0x3E99999A  #Y Vel to Attack
.long 0x40A00000  #Distance from Ground to L Cancel

#################################

ShieldDropWindowInfo:
blrl

.long 0x0001FFFF  #1 Window, Facing Direction Has 2 Options

################################

ShieldDropWindowText:
blrl

######################
## Facing Direction ##
######################

#Window Title = Facing Direction
.long 0x46616369
.long 0x6e672044
.long 0x69726563
.long 0x74696f6e
.long 0x

#Option 1 = Towards
.long 0x546f7761
.long 0x72647300
.long 0x
.long 0x
.long 0x

#Option 2 = Away
.long 0x41776179
.long 0x
.long 0x
.long 0x
.long 0x


#################################

ShieldDropLoadExit:
restore
blr

################################################################################

#########################
## Attack On Shield HIJACK INFO ##
#########################

AttackOnShield:
#STORE STAGE
li	r3,0x20
sth	r3,0xE(r26)

#li	r5,0x14

#STORE CPU
lwz	r4,0x0(r29)
bl	P2Struct
mflr	r3
stw	r3,0x18(r4)		#p2 pointer
load	r5,0x8043207c		#get preload table
lwz	r6,0x18(r5)		#get p2 character ID
cmpwi	r6,0x12
bne	0x8
li	r6,0x13		#Make Zelda Sheik
stb	r6,0x0(r3)		#store chosen char
lbz	r6,0x1C(r5)		#get p2 costume ID
stb	r6,0x3(r3)		#store p2 costume ID
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x00200000
or	r3,r3,r4
stw	r3,0x1F24(r5)

#STORE THINK FUNCTION
bl	AttackOnShieldLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Attack On Shield LOAD FUNCT ##
	########################
	AttackOnShieldLoad:
	blrl

	backup

	#Schedule Think
	bl	AttackOnShieldThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
  bl	AttackOnShieldWindowInfo
  mflr	r5
  bl	AttackOnShieldWindowText
  mflr	r6
	bl	CreateEventThinkFunction


	b	AttackOnShieldLoadExit


		#########################
		## Attack On Shield THINK FUNCT ##
		#########################

    #Registers
    .set MenuData,26
    .set EventData,31
    .set P1Data,27
    .set P1GObj,28
    .set P2Data,29
    .set P2GObj,30

		.set firstFrameFlag,0x0
		.set timer,0x4
		.set OoSOption,OptionMenuMemory+0x2 + 0x0
  	.set OoSOptionToggled,OptionMenuToggled + 0x0

		AttackOnShieldThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31
    lwz MenuData,MenuDataPointer(EventData)

    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4
    mr P2GObj,r5
    mr P2Data,r6

		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
  		bl	CheckIfFirstFrame
  		cmpwi	r3,0x0
  		beq	AttackOnShieldThinkMain
			#Set Frame 1 As Over
  			li		r3,0x1
  			stb		r3,0x0(r31)
  			bl		AttackOnShield_Floats
  			mflr	r3
  			bl		InitializePositions
      #Clear Inputs
        bl  RemoveFirstFrameInputs
			#Save State
  			addi r3,EventData,0x10
  			bl		SaveState_Save



		AttackOnShieldThinkMain:
		bl	GiveFullShields

		#Reset If Anyone Dies
		bl	IsAnyoneDead
		cmpwi	r3,0x0
		bne	AttackOnShieldRestoreState

		AttackOnShieldThinkSequence:

      lbz r3,OoSOptionToggled(MenuData)
			cmpwi	r3,0
			beq	AttackOnShieldNoOptionToggled
		#Clear Last AS So CPU Doesnt Act Immediately
			li	r3,0
			sth	r3,OneASAgo(r29)
		AttackOnShieldNoOptionToggled:

		#Get Floats
		bl	AttackOnShield_Floats
		mflr	r21
		#Get Frames as Int
		lfs	f1,0x894(r29)
		fctiwz	f1,f1
		stfd	f1,0xF0(sp)
		lwz	r22,0xF4(sp)

		#Check If Perfroming OoS Option
		lwz	r3,0x4(r31)
		cmpwi	r3,0x0
		ble	AttackOnShieldShieldWait
		#Branch To OoSThink
		lbz	r3,OoSOption(MenuData)
		cmpwi	r3,0x1
		beq	AttackOnShieldNairThink
		cmpwi	r3,0x2
		beq	AttackOnShieldUpBThink
		cmpwi r3,0x3
		beq AttackOnShieldUpSmashThink
		cmpwi	r3,0x4
		beq	AttackOnShieldShineThink
    cmpwi	r3,0x7
		beq	AttackOnShieldWavedashThink
		b	AttackOnShieldShieldWait

			AttackOnShieldNairThink:
			lwz	r3,0x10(r29)
			cmpwi	r3,0x19
			bne	AttackOnShieldCheckToReset
			#Input Nair
			li	r3,0x100
			stw	r3,0x1A88(r29)
			b	AttackOnShieldCheckToReset

			AttackOnShieldUpBThink:
			lwz	r3,0x10(r29)
			cmpwi	r3,0x18
			bne	AttackOnShieldCheckToReset
			li	r3,127
			stb	r3,0x1A8D(r29)			#Press Up
			li	r3,0x200
			stw	r3,0x1A88(r29)			#Press B
			b	AttackOnShieldCheckToReset

			AttackOnShieldUpSmashThink:
			lwz	r3,0x10(r29)
			cmpwi	r3,0x18
			bne	AttackOnShieldCheckToReset
			li	r3,127
			stb	r3,0x1A8D(r29)			#Press Up
			li	r3,0x100
			stw	r3,0x1A88(r29)			#Press A
			b	AttackOnShieldCheckToReset

			AttackOnShieldShineThink:
			lwz	r3,0x10(r29)
			cmpwi	r3,0x19
			bne	AttackOnShieldCheckToReset
			#Input Shine
			li	r3,-127
			stb	r3,0x1A8D(r29)
			li	r3,0x200
			stw	r3,0x1A88(r29)
			b	AttackOnShieldCheckToReset

      AttackOnShieldWavedashThink:
      lwz	r3,0x10(r29)
			cmpwi	r3,0x19
			bne	AttackOnShieldCheckToReset
      #Get Random Airdodge Angle
  			li	r3,30		#30 Different Angles
  			branchl	r12,HSD_Randi
  			addi	r3,r3,310		#Start at 310°
  			bl	ComboTrainingDecideStickAngle_ConvertAngle
        mr  r20,r3
  		#Joystick X = X Component * (OpponentDirection)
        bl  GetDirectionInRelationToP1
  			mullw	r3,r3,r20
  			stb	r3,0x1A8C(r29)
  		#Joystick Y = Y Component
  			stb	r4,0x1A8D(r29)
  		#Press L To Wavedash
  			li	r3,0xC0
  			stw	r3,0x1A88(r29)
			b	AttackOnShieldCheckToReset

		AttackOnShieldShieldWait:
		#Always Hold L
		li	r3,0xC0		#Hit L
		stw	r3,0x1A88(r29)		#Held Buttons

		#Check If Got Shield Poked
		#Hitlag
			lbz	r3,0x221A(r29)			#Check If in Hitlag
			rlwinm.	r3,r3,0,26,26
			beq	AttackOnShieldCheckForShieldHit
		#Damage State
			lwz	r3,0x10(r29)
			cmpwi	r3,0x4B
			blt	AttackOnShieldCheckForShieldHit
			cmpwi	r3,0x5B
			bgt	AttackOnShieldCheckForShieldHit
		#Was Hit, Start Reset Timer
			li	r3,48		#Init Timer
			stw	r3,0x4(r31)
			b	AttackOnShieldThinkExit

		AttackOnShieldCheckForShieldHit:
		#Check If In ShieldWait (0xb3)
		lwz	r3,0x10(r29)
		cmpwi	r3,0xB3
		bne	AttackOnShieldCheckToReset
		#Check If Was Just in ShieldStun
		lhz	r3,OneASAgo(r29)
		cmpwi	r3,0xB5
		bne	AttackOnShieldCheckToReset
		#Input OoS Option
		lbz	r3,OoSOption(MenuData)
		cmpwi 	r3,0x0
		beq	AttackOnShieldInputGrab
		cmpwi 	r3,0x1
		beq	AttackOnShieldNair
		cmpwi 	r3,0x2
		beq	AttackOnShieldUpB
		cmpwi		r3,0x3
		beq AttackOnShieldUpSmash
		cmpwi 	r3,0x4
		beq	AttackOnShieldShine
		cmpwi 	r3,0x5
		beq	AttackOnShieldSpotdodge
		cmpwi 	r3,0x6
		beq	AttackOnShieldRoll
    cmpwi 	r3,0x7
		beq	AttackOnShieldWavedash
		cmpwi 	r3,0x8
		beq	AttackOnShieldNone

		AttackOnShieldInputGrab:
		li	r3,0x1C0
		stw	r3,0x1A88(r29)		#Press R+A
		li	r3,48		#Init Timer
		stw	r3,0x4(r31)
		b	AttackOnShieldThinkExit

		AttackOnShieldNair:
		li	r3,0xCC0
		stw	r3,0x1A88(r29)		#Press X/Y
		li	r3,48		#Init Timer
		stw	r3,0x4(r31)
		b	AttackOnShieldThinkExit

		AttackOnShieldUpB:
		li	r3,127
		stb	r3,0x1A8D(r29)		#Press Up
		li	r3,48		#Init Timer
		stw	r3,0x4(r31)
		b	AttackOnShieldThinkExit

		AttackOnShieldUpSmash:
		li	r3,127
		stb	r3,0x1A8D(r29)		#Press Up
		li	r3,48		#Init Timer
		stw	r3,0x4(r31)
		b	AttackOnShieldThinkExit

		AttackOnShieldShine:
		li	r3,0xCC0
		stw	r3,0x1A88(r29)		#Press X/Y
		li	r3,48		#Init Timer
		stw	r3,0x4(r31)
		b	AttackOnShieldThinkExit

		AttackOnShieldSpotdodge:
		li	r3,-127
		stb	r3,0x1A8D(r29)		#Press Down
		li	r3,0xC0
		stw	r3,0x1A88(r29)		#Press R
		li	r3,48		#Init Timer
		stw	r3,0x4(r31)
		b	AttackOnShieldThinkExit

		AttackOnShieldRoll:
		li	r3,0xC0
		stw	r3,0x1A88(r29)		#Press R
		#Push Towards Opponent's Direction
		bl	GetDirectionInRelationToP1
		li	r4,127
		mullw	r3,r3,r4
		stb	r3,0x1A8C(r29)		#Press Away
		li	r3,48		#Init Timer
		stw	r3,0x4(r31)
		b	AttackOnShieldThinkExit

    AttackOnShieldWavedash:
    li	r3,0xCC0
		stw	r3,0x1A88(r29)		#Press X/Y
    li	r3,48		#Init Timer
		stw	r3,0x4(r31)
		b	AttackOnShieldThinkExit

		AttackOnShieldNone:
		b	AttackOnShieldThinkExit

		#Check To Reset
		AttackOnShieldCheckToReset:
		lwz	r3,0x4(r31)		#get timer	#Get Timer
		cmpwi	r3,0x0		#Check if >0
		ble	AttackOnShieldThinkExit
		#Dec Timer
		subi	r3,r3,0x1
		stw	r3,0x4(r31)		#store timer
		cmpwi	r3,0x0		#Check if 0 now
		bne	AttackOnShieldThinkExit	#Exit If Not

		#Randomize P1's X Coord
		#Get Random X Coord
		lbz	r23,0x10(r21)		#Starting X Coord
		lbz	r24,0x11(r21)		#Furthest X Coord
		sub	r3,r24,r23		#Get Range
		branchl	r12,HSD_Randi		#Get Random Number in Between
		add	r3,r3,r23		#Add to Starting Coord
		#Cast to Float
		bl  IntToFloat
		lwz	r3,0x10(r31)		#P1 Backup
		stfs	f1,0xB0(r3)		#P1 Backup X Pos
		li	r3,0x1			#Opposing Sides of Stage
		bl	Randomize_LeftorRightSide

		AttackOnShieldRestoreState:
		#Restore State
		addi r3,EventData,0x10
		bl	SaveState_Load
		b	AttackOnShieldThinkExit

		AttackOnShieldThinkExit:
    mr  r3,MenuData
    bl  ClearToggledOptions
		restore
		blr


#################################

AttackOnShield_Floats:
blrl
.long 0xC1A00000		#P1 X Position
.long 0x41A00000		#P2 X Position
.long 0x38d1b717		#FD Floor Y Coord
.long 0x38d1b717		#FD Floor Y Coord
.long 0x14460000  #P1 X Rand Pos Range

#################################

AttackOnShieldWindowInfo:
blrl
#amount of options, amount of options in each window

.long 0x0008FFFF  #1 window, OoS Option has 10 options

####################################################

AttackOnShieldWindowText:
blrl

################
## OoS Option ##
################

#Window Title = OoS Option
.long 0x4f6f5320
.long 0x4f707469
.long 0x6f6e0000

#Option 1 = Grab
.long 0x47726162
.long 0x00000000

#Option 2 = Nair
.long 0x4e616972
.long 0x00000000

#Option 3 = Up B
.long 0x55702042
.long 0x00000000

#Option 5 = Up Smash
.long 0x55702d53
.long 0x6d617368
.long 0x

#Option 6 = Shine
.long 0x5368696e
.long 0x65000000

#Option 7 = Spotdodge
.long 0x53706f74
.long 0x646f6467
.long 0x65000000

#Option 8 = Roll Away
.long 0x526f6c6c
.long 0x20417761
.long 0x79000000

#Option 9 = Wavedash Away
.long 0x57617665
.long 0x64617368
.long 0x20417761
.long 0x79000000

#Option 10 = None
.long 0x4E6F6E65
.long 0x00000000

AttackOnShieldLoadExit:
restore
blr


################################################################################











#########################
## Ledgetech HIJACK INFO ##
#########################

Ledgetech:
#GET RANDOM TOP TIER
#li	r3,10		#Get Random Top Tier
#branchl	r12,HSD_Randi
#bl	TopTiers
#mflr	r4
#lbzx	r5,r3,r4

#Create Copy Of Player Struct
li	r3,0x1C
branchl	r12,HSD_MemAlloc
mr	r20,r3
bl	P2Struct
mflr	r4
li	r5,0x1C
branchl	r12,memcpy

#STORE CPU
lwz	r4,0x0(r29)
stw	r20,0x18(r4)		#p2 pointer
li	r5,0x14 #Falco
stb	r5,0x0(r20)		#make top tier p2
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r20)
#BUFF DEFENSE RATIO
lis	r3,0x3f00
stw	r3,0x14(r20)

#SPAWN 2 PLAYERS
li	r3,0x40
lwz	r4,0x0(r29)
stb	r3,0x1(r4)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x00000404
or	r3,r3,r4
stw	r3,0x1F24(r5)

#If IC's Make SoPo
lbz	r3,0x2(r30)		#P1 External ID
cmpwi	r3,0xE
bne	LedgetechStoreThink
li	r3,0x20
stb	r3,0x2(r30)		#Make SoPo

#STORE THINK FUNCTION
LedgetechStoreThink:
bl	LedgetechLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Ledgetech LOAD FUNCT ##
	########################
	LedgetechLoad:
	blrl

	backup

	bl	InitializeHighScore

	#Schedule Think
	bl	LedgetechThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
  li  r5,0    #No Option Menu
	bl	CreateEventThinkFunction

	b	LedgetechLoadExit


		#########################
		## Ledgetech THINK FUNCT ##
		#########################


		LedgetechThink:
		blrl

    .set P1Data,27
    .set P1GObj,28
    .set P2Data,29
    .set P2GObj,30
    .set EventData,31

		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31

    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4
    mr P2GObj,r5
    mr P2Data,r6

		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	LedgetechThinkMain

    #Clear Inputs
      bl  RemoveFirstFrameInputs
    #Random Side of Stage
      li  r3,2
      branchl r12,HSD_Randi
      bl  Ledgetech_InitializePositions
		#P1 Has 90%
			li	r3,90
			load	r4,0x80453080		#P1 Static Block
			sth	r3,0x60(r4)		#Store Percent Int To Display Value
			lis	r3,0x42B4
			stw	r3,0x1830(r27)
    #Always Hold Down (Crouch Cancel)
      li	r3,-127
      stb	r3,0x1A8D(P2Data)
		#Save State
			addi r3,EventData,0x10
			bl		SaveState_Save



		LedgetechThinkMain:
		bl	GiveFullShields

		LedgetechThinkSequence:
		#Get Floats
		bl	Ledgetech_Floats
		mflr	r21

		#Reset if P1 Is In a Dead State
		lbz	r3,0x221F(r27)
		rlwinm.	r3,r3,0,25,25
		bne	LedgetechRestoreState

		#D-Pad Left Restores State
		lwz	r3,0x668(r27)
		rlwinm.	r0, r3, 0, 31, 31
		bne	LedgetechRestoreState

		#Always Hold Down (Crouch Cancel)
		li	r3,-127
		stb	r3,0x1A8D(r29)

		#Start Timer When Leaving Rebirth Plat
		lbz	r3,0x8(r31)		#Check If Left Plat Already
		cmpwi	r3,0x0
		bne	LedgetechSkipTimerStart
		lwz	r3,0x10(r27)
		cmpwi	r3,0xD
		beq	LedgetechIncreaseRespawnPlatTime
		#Set Flag
		li	r3,0x1
		stb	r3,0x8(r31)
		#Remove Invinc
		li	r3,0x0
		stw	r3,0x198C(r27)
		stw	r3,0x1990(r27)
		stw	r3,0x1994(r27)
		mr	r3,r28
		branchl	r12,GFX_RemoveAll
		#Set Timer
		li	r3,180
		stw	r3,0x4(r31)
		b	LedgetechSkipTimerStart

		LedgetechIncreaseRespawnPlatTime:
		li	r3,0x2
		stw	r3,0x2340(r27)
		LedgetechSkipTimerStart:

		#Freeze Falco On Frame X
		lwz	r3,0x10(r29)
		cmpwi	r3,0x40
		bne	LedgetechSkipFalcoFreze
		li	r3,0x6
		bl	IntToFloat
		lfs	f2,0x894(r29)
		fcmpo	cr0,f1,f2
		bne	LedgetechSkipFalcoFreze
		li	r3,0
		bl	IntToFloat
		mr	r3,r30
		branchl	r12,FrameSpeedChange
		LedgetechSkipFalcoFreze:


		#If Player 1 Ledge Tech's, Set Timer to 2 Seconds
		#Check Gatekeeper Flag
			lbz	r3,0xA(r31)
			cmpwi	r3,0x1
			beq	Ledgetech_UpdateLedgetechFlags

		#Check For Tech
			lwz	r3,0x10(r27)
			cmpwi	r3,0xCA
			beq	LedgetechWallTeched
			cmpwi	r3,0xCB
			beq	LedgetechWallTeched
			b	Ledgetech_UpdateLedgetechFlags
		LedgetechWallTeched:
			#Extend Timer
				li	r3,180
				stw	r3,0x4(r31)
			#Set Tech Bool
				li	r3,1
				stb	r3,0x9(r31)
			#Set Gatekeeper Flag
				li	r3,1
				stb	r3,0xA(r31)

		Ledgetech_UpdateLedgetechFlags:
		#Check If Still Ledgeteching
			lwz	r3,0x10(r27)
			cmpwi	r3,0xCA
			beq	LedgetechUpdateScore
			cmpwi	r3,0xCB
			beq	LedgetechUpdateScore
		#Not Ledgeteching, Remove Gatekeeper Flag
			li	r3,0
			stb	r3,0xA(r31)
			b	LedgetechUpdateScoreHUD

		LedgetechUpdateScore:
		#Check To Increment Score
		#Check Ledgetech Bool
			lbz	r3,0x9(r31)
			cmpwi	r3,0x1
			bne	LedgetechUpdateScoreHUD
		#Reset LedgeTech Bool
			li	r3,0
			stb	r3,0x9(r31)
		#Increment Score
			lhz	r3,-0x4ea8(r13)
			addi	r3,r3,0x1
			sth	r3,-0x4ea8(r13)
		#Check To Make New High Score
			lhz	r3,-0x4ea8(r13)
			lhz	r4,-0x4ea6(r13)
			cmpw	r3,r4
			ble	LedgetechUpdateScoreHUD
		#Copy To High Score
			sth	r3,-0x4ea6(r13)

		LedgetechUpdateScoreHUD:
		#Update HUD Score
			lhz	r3,-0x4ea8(r13)
			branchl	r12,HUD_KOCounter_UpdateKOs


		#Unfreeze Falco On Hit
		li	r3,0x0
		bl	IntToFloat
		lfs	f2,0x89C(r29)
		fcmpo	cr0,f1,f2
		bne	LedgetechSkipFalcoUnfreeze
		lwz	r3,0x988(r29)
		cmpwi	r3,0x0
		beq	LedgetechSkipFalcoUnfreeze
		li	r3,1
		bl	IntToFloat
		mr	r3,r30
		branchl	r12,FrameSpeedChange
		LedgetechSkipFalcoUnfreeze:

		LedgetechCheckIfCrouching:
		#Only Attempt to DSmash in Squat and SquatWait
		lwz	r3,0x10(r29)
		cmpwi	r3,0x27
		beq	LedgetechCheckDistance
		cmpwi	r3,0x28
		beq	LedgetechCheckDistance
		b	LedgetechCheckToReset
		LedgetechCheckDistance:
		#Distance Formula	(Get Distance in f1)
		lfs	f3,0xB0(r29)	#P2 X
		lfs	f4,0xB4(r29) #P2 Y
		lfs	f5,0xB0(r27) #P1 X
		lfs	f6,0xB4(r27) #P1 Y
		fsubs	f1,f5,f3
		fsubs	f2,f4,f6
		fmuls	f1,f1,f1
		fmuls	f2,f2,f2
		fadds	f2,f1,f2
		frsqrte	f1,f2
		fmuls	f1,f1,f2
		lfs	f2,0x10(r21)
		fcmpo	cr0,f1,f2
		bgt	LedgetechCheckToReset
		#Enter DSmash
		li	r3,-127
		stb	r3,0x1A8F(r29)
		#Initiate Reset Timer
		lwz	r3,0x4(r31)		#Get Timer
		cmpwi	r3,0x0		#If Already Set, Skip
		bne	LedgetechCheckToReset
		li	r3,60
		stw	r3,0x4(r31)



		#Check To Reset
		LedgetechCheckToReset:
		lwz	r3,0x4(r31)		#get timer	#Get Timer
		cmpwi	r3,0x0		#Check if >0
		ble	LedgetechThinkExit
		#Dec Timer
		subi	r3,r3,0x1
		stw	r3,0x4(r31)		#store timer
		cmpwi	r3,0x0		#Check if 0 now
		bne	LedgetechThinkExit	#Exit If Not

		LedgetechRestoreState:
	  #Restore State
    	addi r3,EventData,0x10
    	bl	SaveState_Load
    #Random Side of Stage
      li  r3,2
      branchl r12,HSD_Randi
      bl  Ledgetech_InitializePositions

		#Set Timer
		li	r3,0
		stw	r3,0x4(r31)
		#Reset Rebirth Plat Fall Flag
		stb	r3,0x8(r31)
		#Reset Tech and Gatekeeper Flag
		stb	r3,0x9(r31)
		stb	r3,0xA(r31)
		#Reset Score
		li	r3,0
		sth	r3,-0x4ea8(r13)
		b	LedgetechThinkExit

		LedgetechThinkExit:
		restore
		blr

#################################

Ledgetech_Floats:
blrl
.long 0x4308ca0c		#P1 X Position
.long 0x42942371		#P2 X Position
.long 0x41A00000  #P1 Y Position
.long 0x38d1b717		#FD Floor Y Coord
.long 0x420C0000		#Distance to Initiate DSmash

#################################

BlrFunctionPointer:
blrl
blr

#################################

Ledgetech_InitializePositions:
backup

.set LedgeSide,20
.set LedgeID,21

  #Backup Ledge Choice (0 = Left, 1 = Right)
    mr	LedgeSide,r3

  #Get Stage's Ledge IDs
    lwz		r3,-0x6CB8 (r13)			#External Stage ID
    bl		LedgedashCliffIDs
    mflr  r4
    mulli	r3,r3,0x2
    lhzx	r3,r3,r4
  #Get Requested Ledge
  	cmpwi LedgeSide,0x0
  	beq	Ledgetech_InitializePositions_GetLeftLedgeID

  Ledgetech_InitializePositions_GetRightLedgeID:
    rlwinm	LedgeID,r3,0,24,31
   #Change Facing Direction
  	li	r3,-1
  	bl	IntToFloat
  	stfs	f1,0x2C(P1Data)
    li	r3,1
    bl	IntToFloat
    stfs	f1,0x2C(P2Data)
  #Get Ledge Coords (0x80 = X, 0x84 = Y)
    mr  r3,LedgeID
    addi	r4,sp,0x80
    branchl	r12,Stage_GetRightOfLineCoordinates
  	b	Ledgetech_InitializePositions_StorePosition

  Ledgetech_InitializePositions_GetLeftLedgeID:
  	rlwinm	LedgeID,r3,24,24,31
  #Change Facing Direction
  	li	r3,1
  	bl	IntToFloat
  	stfs	f1,0x2C(P1Data)
    li	r3,-1
    bl	IntToFloat
    stfs	f1,0x2C(P2Data)
  #Get Ledge Coords (0x80 = X, 0x84 = Y)
    mr  r3,LedgeID
    addi	r4,sp,0x80
    branchl	r12,Stage_GetLeftOfLineCoordinates
  	b	Ledgetech_InitializePositions_StorePosition

  Ledgetech_InitializePositions_StorePosition:
  #Place P2 a few Mm behind it
    li  r3,10
    bl  IntToFloat
    lfs f2,0x2C(P2Data)
    fmuls f1,f1,f2
    lfs f2,0x80(sp)
    fsubs f1,f2,f1
    stfs f1,0xB0(P2Data)
    lfs f1,0x84(sp)
    stfs f1,0xB4(P2Data)
  #Find Ground Below Player
    mr  r3,P2GObj
    bl  FindGroundNearPlayer
    cmpwi r3,0    #Check if ground was found
    beq Ledgetech_InitializePositions_SkipGroundCorrection
    stfs f1,0xB0(P2Data)
    stfs f2,0xB4(P2Data)
    stw r4,0x83C(P2Data)
    Ledgetech_InitializePositions_SkipGroundCorrection:
  #Enter SquatWait
    mr r3,P2GObj
    branchl r12,AS_SquatWait
  #Update Position
    mr  r3,P2GObj
    bl  UpdatePosition
  #Update ECB Values for the ground ID
    mr r3,P2GObj
    branchl r12,EnvironmentCollision_WaitLanding
  #Set Grounded
    mr r3,P2Data
    branchl r12,Air_SetAsGrounded
  #Update Camera
    mr r3,P2GObj
    bl  UpdateCameraBox

  #Enter Rebirth
    lwz	r26,0x2C(P1Data)
    mr		r3,P1GObj
    branchl		r12,AS_Rebirth
    stw	r26,0x2C(P1Data)
  #Place P1 a few Mm in front of it
    li  r3,60
    bl  IntToFloat
    lfs f2,0x2C(P1Data)
    fmuls f1,f1,f2
    lfs f2,0x80(sp)
    fsubs f1,f2,f1
    stfs f1,0xB0(P1Data)
    lfs f1,0x84(sp)
    stfs f1,0xB4(P1Data)
  #Enter RebirthWait
    mr		r3,P1GObj
    branchl		r12,AS_RebirthWait
  #Update Position
    mr  r3,P1GObj
    bl  UpdatePosition
  #Store Blr as Physics
		bl		BlrFunctionPointer
		mflr		r3
		stw		r3,0x21A4(P1Data)
	#Store Custom RebirthWait Interrupt
		bl	Custom_InterruptRebirthWait
		mflr	r3
		stw		r3,0x219C(P1Data)
  #Update RebirthPlat Position
    mr  r3,P1GObj
    branchl r12,RebirthPlatform_UpdatePosition
  #Update Camera
    mr r3,P1GObj
    bl  UpdateCameraBox

restore
blr

#################################

LedgetechLoadExit:
restore
blr



###################################################





#########################
## Amsah Tech HIJACK INFO ##
#########################

AmsahTech:

#GET RANDOM TOP TIER
#li	r3,10		#Get Random Top Tier
#branchl	r12,HSD_Randi
#bl	TopTiers
#mflr	r4
#lbzx	r5,r3,r4

li	r5,0x9		#Marth

#STORE CPU
lwz	r4,0x0(r29)
bl	P2Struct
mflr	r3
stw	r3,0x18(r4)		#p2 pointer
stb	r5,0x0(r3)		#make top tier p2
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x00000004
or	r3,r3,r4
stw	r3,0x1F24(r5)

#STORE THINK FUNCTION
bl	AmsahTechLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Amsah Tech LOAD FUNCT ##
	########################
	AmsahTechLoad:
	blrl

	backup

	#Schedule Think
	bl	AmsahTechThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
  li  r5,0    #No Option Menu
	bl	CreateEventThinkFunction

	b	AmsahTechLoadExit


		#########################
		## Amsah Tech THINK FUNCT ##
		#########################

    .set EventData,31
    .set P1Gobj,28
    .set P1Data,27
    .set P2GObj,30
    .set P2Data,29

    #Offsets
    .set Timer,0x8

		AmsahTechThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31

    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4
    mr P2GObj,r5
    mr P2Data,r6

		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	AmsahTechThinkMain

      #Move Players
        bl  PlacePlayersCenterStage
			#P1 Has 120%
  			li	r3,120
  			load	r4,0x80453080		#P1 Static Block
  			sth	r3,0x60(r4)		#Store Percent Int To Display Value
  			bl	IntToFloat
  			stfs	f1,0x1830(P1Data)
      #Clear Inputs
        bl  RemoveFirstFrameInputs
			#Save State
  			addi r3,EventData,0x10
  			bl	SaveState_Save



		AmsahTechThinkMain:

		#Make P2 A Follower (No Nudge)
		#li	r3,0x8
		#stb	r3,0x221F(r29)
		li	r3,0x1
		lbz	r0, 0x221D (r29)
		rlwimi	r0,r3,2,29,29
		stb	r0, 0x221D (r29)

		#Give Invincibility To P2
		mr	r3,r30
		li	r4,0x2
		bl	GiveInvincibility

		#Update GFX
		mr	r3,r30
		bl	UpdateAllGFX

		#Reset If Anyone Dies
		bl	IsAnyoneDead
		cmpwi	r3,0x0
		bne	AmsahTechRestoreState

		AmsahTechThinkSequence:
		#Get Floats
		bl	AmsahTech_Floats
		mflr	r21

		#Check If Timer Started Already
		lwz	r3,0x4(r31)
		cmpwi	r3,0x0
		bne	AmsahTechCheckUpBTimer

		#Check For P1 Taunt
		lwz	r3,0x10(r27)
		cmpwi	r3,0x108
		beq	AmsahTechIsTaunting
		cmpwi	r3,0x109
		beq	AmsahTechIsTaunting

		#Check For Doc Taunt
		lwz	r3,0x4(r27)
		cmpwi	r3,0x15
		bne	AmsahTechCheckYLink
		#Check For AS 155
		lwz	r3,0x10(r27)
		cmpwi	r3,0x155
		beq	AmsahTechIsTaunting

		#Check For YLink Taunt
		AmsahTechCheckYLink:
		lwz	r3,0x4(r27)
		cmpwi	r3,0x14
		bne	AmsahTechCheckUpBTimer
		#Check For AS 156
		lwz	r3,0x10(r27)
		cmpwi	r3,0x156
		beq	AmsahTechIsTaunting
		b	AmsahTechCheckUpBTimer

		AmsahTechIsTaunting:
  #Check for Frame 1 of Taunt
    lhz r3,0x23EC(P1Data)
    cmpwi r3,0x1
    bne AmsahTechCheckUpBTimer
  #Check If UpB Timer is Set
		lwz	r3,0x8(r31)
		cmpwi	r3,0x0		#Timer Already Set
		bne	AmsahTechCheckUpBTimer
		#Check If Marth is In Wait
		lwz	r3,0x10(r29)
		cmpwi	r3,0xE
		bne	AmsahTechCheckUpBTimer

  #Move Marth X Mm in front of P1, facing him
  #Get Position
    li  r3,10
    bl  IntToFloat          #Offset from P1
    lfs f3,0xB0(P1Data)     #P1 X
    lfs f2,0xB4(P1Data)     #P1 Y
    lfs f4,0x2C(P1Data)     #Facing Direction
    fmuls f1,f1,f4
    fadds f1,f1,f3
  #Check If P2 Will Be Grounded
    li  r3,0
    bl  FindGroundNearPlayer
    cmpwi r3,0    #Check if ground was found
    beq AmsahTech_NoGroundFound
    stfs f1,0xB0(P2Data)
    stfs f2,0xB4(P2Data)
    stw r4,0x83C(P2Data)
    lfs f1,0x2C(P1Data)
    fneg f1,f1
    stfs f1,0x2C(P2Data)
  #Enter Wait
    mr  r3,P2GObj
    branchl r12,AS_Wait
  #Update Position
    mr  r3,P2GObj
    bl  UpdatePosition
  #Update ECB Values for the ground ID
    mr r3,P2GObj
    branchl r12,EnvironmentCollision_WaitLanding
  #Set Grounded
    mr r3,P2Data
    branchl r12,Air_SetAsGrounded
  #Set UpB Timer
    li	r3,30
    stw	r3,Timer(EventData)
  #Store To Backups as Well
    lwz	r3,0x18(EventData)		#P2 Backup
    lfs	f1,0xB0(P2Data)	     	#Get P2 X
    stfs	f1,0xB0(r3)	       	#Store to P2 Backup
    lfs	f1,0xB4(P2Data)	     	#Get P2 Y
    stfs	f1,0xB4(r3)	       	#Store to P2 Backup
    lfs	f1,0x2C(P2Data)	     	#Get P2 Facing
    stfs	f1,0x2C(r3)	       	#Store to P2 Backup
    lwz r4,0x83C(P2Data)      #Get P2 Ground ID
    stw r4,0x83C(r3)          #Store to P2 Backup
    lwz	r3,0x10(EventData)		#P1 Backup
    lfs	f1,0xB0(P1Data)	    	#Get P1 X
    stfs	f1,0xB0(r3)	       	#Store to P1 Backup
    lfs	f1,0xB4(P1Data)	    	#Get P1 X
    stfs	f1,0xB4(r3)	       	#Store to P1 Backup
    lfs	f1,0x2C(P1Data)	     	#Get P1 Facing
    stfs	f1,0x2C(r3)		      #Store to P1 Backup
    lwz r4,0x83C(P1Data)      #Get P1 Ground ID
    stw r4,0x83C(r3)          #Store to P1 Backup
  	mr	r3,P1GObj
  	bl	CheckIfPlayerHasAFollower
  	cmpwi	r3,0x0
  	beq	AmsahTechNoSubchar
  	lwz	r3,0x14(EventData)		#P1 Subchar Backup
  	lfs	f1,0xB0(r4)		#Get P1 Subchar X
  	stfs	f1,0xB0(r3)		#Store to P1 Subchar Backup
  	lfs	f1,0x2C(r4)		#Get P1 Subchar Facing
  	stfs	f1,0x2C(r3)		#Store to P1 Subchar Backup
	AmsahTechNoSubchar:
    b AmsahTechCheckToReset

  AmsahTech_NoGroundFound:
  #Play Error SFX
    li	r3,0xAF
    bl PlaySFX
    b AmsahTechCheckToReset

		AmsahTechCheckUpBTimer:
		#Check For UpBTimer
		lwz	r3,0x8(r31)
		cmpwi	r3,0x0		#No UpB Timer Set Yet
		ble	AmsahTechCheckToReset
		#Dec Timer
		subi	r3,r3,0x1
		stw	r3,0x8(r31)		#store timer
		cmpwi	r3,0x0		#Check if 0 now
		bne	AmsahTechCheckToReset	#Exit If Not
		#Move Marth in Front of P1 Again (Fox's
		lfs	f1,0xB0(r27)		#Get P1 X
		lfs	f2,0x2C(r27)		#Get P1 Facing
		lfs	f3,0x10(r21)		#Get Marth Distance
		fmuls	f2,f2,f3		#Distance * Facing Direction
		fadds	f1,f1,f2		#P1.X + (Distance * Facing Direction)
		stfs	f1,0xB0(r29)		#Store Position to P2
		#Enter UpB
		li	r3,0x200
		stw	r3,0x1A88(r29)
		li	r3,127
		stb	r3,0x1A8D(r29)
		#Initiate Reset Timer
		li	r3,120
		stw	r3,0x4(r31)

		#Check To Reset
		AmsahTechCheckToReset:
		lwz	r3,0x4(r31)		#get timer	#Get Timer
		cmpwi	r3,0x0		#No Reset Timer Set Yet
		ble	AmsahTechThinkExit
		#Dec Timer
		subi	r3,r3,0x1
		stw	r3,0x4(r31)		#store timer
		cmpwi	r3,0x0		#Check if 0 now
		bne	AmsahTechThinkExit	#Exit If Not

		AmsahTechRestoreState:
		#Restore State
		addi r3,EventData,0x10
		bl	SaveState_Load
		#Restore Timers Just In Case
		li	r3,0x0
		stw	r3,0x4(r31)
		stw	r3,0x8(r31)

		AmsahTechThinkExit:
		restore
		blr

#################################

AmsahTech_Floats:
blrl
.long 0x4308ca0c		#P1 X Position
.long 0x42942371		#P2 X Position
.long 0x00000000  #P1 Y Position
.long 0x38d1b717		#FD Floor Y Coord
.long 0x41800000 	#Distance to place Marth from P1
.long 0x428C0000  #FD Stage Boundary X

#################################

AmsahTechLoadExit:
restore
blr



###########################################






#########################
## Combo Training HIJACK INFO ##
#########################

ComboTraining:
#STORE STAGE
#li	r3,0x20
#sth	r3,0xE(r26)

#STORE CPU
lwz	r4,0x0(r29)
bl	P2Struct
mflr	r3
stw	r3,0x18(r4)		#p2 pointer
load	r5,0x8043207c		#get preload table
lwz	r6,0x18(r5)		#get p2 character ID
cmpwi	r6,0x12
bne	0x8
li	r6,0x13		#Make Zelda Sheik
stb	r6,0x0(r3)		#store chosen char
lbz	r6,0x1C(r5)		#get p2 costume ID
stb	r6,0x3(r3)		#store p2 costume ID
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x01010020
or	r3,r3,r4
stw	r3,0x1F24(r5)

#STORE THINK FUNCTION
bl	ComboTrainingLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Combo Training LOAD FUNCT ##
	########################
	ComboTrainingLoad:
	blrl

	backup

	#Schedule Think
	bl	ComboTrainingThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
  bl	ComboTrainingWindowInfo			#r4 = pointer to option info
  mflr	r5
  bl	ComboTrainingWindowText			#r5 = pointer to ASCII struct
  mflr	r6
	bl	CreateEventThinkFunction

	bl	InitializeHighScore

	b	ComboTrainingLoadExit


		#########################
		## Combo Training THINK FUNCT ##
		#########################

    #Registers
    .set MenuData,26
    .set EventData,31
    .set P1Data,27
    .set P1GObj,28
    .set P2Data,29
    .set P2GObj,30

    #Offsets
		.set EventState,0x8
		.set DIBehavior,(OptionMenuMemory+0x2)+0x0
		.set SDIBehavior,(OptionMenuMemory+0x2)+0x1
		.set TechOption,(OptionMenuMemory+0x2)+0x2
		.set PostHitstunAction,(OptionMenuMemory+0x2)+0x3
		.set GrabMashout,(OptionMenuMemory+0x2)+0x4
    .set DIBehaviorToggled,(OptionMenuToggled)+0x0
		.set SDIBehaviorToggled,(OptionMenuToggled)+0x1
		.set TechOptionToggled,(OptionMenuToggled)+0x2
		.set PostHitstunActionToggled,(OptionMenuToggled)+0x3
		.set GrabMashoutToggled,(OptionMenuToggled)+0x4

		ComboTrainingThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		r31,0x2c(r3)			#backup data pointer in r31

    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4
    mr P2GObj,r5
    mr P2Data,r6

    lwz MenuData,MenuDataPointer(EventData)

		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	ComboTrainingThinkMain

        bl  PlacePlayersCenterStage
      #Clear Inputs
        bl  RemoveFirstFrameInputs
			#Save State
  			addi r3,EventData,0x10
  			bl	SaveState_Save
			#Init Score Count
  			lhz	r3,-0x4ea8(r13)
  			branchl	r12,HUD_KOCounter_UpdateKOs


		ComboTrainingThinkMain:

		#Set Combo As Score
			li	r3,0x0
			branchl	r12,0x8004134c
			sth	r3,-0x4ea8(r13)
		#Check To Make New High Score
			lhz	r3,-0x4ea8(r13)
			lhz	r4,-0x4ea6(r13)
			cmpw	r3,r4
			ble	ComboTraining_SkipNewHighscore
		#Copy To High Score
			sth	r3,-0x4ea6(r13)
		ComboTraining_SkipNewHighscore:

		#Update HUD Score
		lhz	r3,-0x4ea8(r13)
		cmpwi	r3,0x1
		blt	ComboTraining_SkipHUDUpdate
		branchl	r12,HUD_KOCounter_UpdateKOs
		ComboTraining_SkipHUDUpdate:

		#DPad Right Makes New Savestate
		#Check If Trying to SaveState
		lwz	r3,0x668(r27)
		rlwinm.	r0,r3,0,30,30
		beq	ComboTraining_CheckForSaveAndLoad
		#Only Allow a Save If Event State is 0
		lbz	r3,EventState(r31)
		cmpwi	r3,0x0
		bne	ComboTraining_SkipCheckForSaveAndLoad
		#Only Allow a Save If P2 is in Wait
		lwz	r3,0x10(r29)
		cmpwi	r3,0xE
		bne	ComboTraining_SkipCheckForSaveAndLoad
		ComboTraining_CheckForSaveAndLoad:
		addi	r3,EventData,0x10
		bl	CheckForSaveAndLoad
		#Check If Loaded Successfully
		cmpwi	r3,0x1
		bne	ComboTraining_SkipCheckForSaveAndLoad
		#Restore Event State And Timer
		li	r3,0x0
		stb	r3,EventState(r31)
		stw	r3,0x4(r31)
		ComboTraining_SkipCheckForSaveAndLoad:

		#DPad Down Moves CPU In Front
		#Only If Event State = 0
		lbz	r3,EventState(r31)
		cmpwi	r3,0x0
		bne	ComboTrainingSkipMoveCPU
    mr  r3,P1GObj
    mr  r4,P2GObj
    addi r5,EventData,0x10
		bl	MoveCPU
		ComboTrainingSkipMoveCPU:

		#L+DPad Controls CPU Percent
		bl	DPadCPUPercent

		bl	GiveFullShields

		#Reset If Anyone Dies
		bl	IsAnyoneDead
		cmpwi	r3,0x0
		bne	ComboTrainingRestoreState


	############################
	## Check If Was Hit Again ##
	############################

		#Don't Run If Over 6 Frames in Escape Air
		lwz	r3,0x10(r29)
		cmpwi	r3,0xEC
		bne	ComboTrainingCheckIfP2isGrabbed
		li	r3,6
		bl	IntToFloat
		lfs	f2,0x894(r29)
		fcmpo	cr0,f1,f2
		bge	ComboTrainingCheckState
		#Check If P2 is Grabbed (Any Grab State)
		ComboTrainingCheckIfP2isGrabbed:
		lwz	r3,0x10(r29)
		cmpwi	r3,0xDF
		blt	ComboTrainingStartCheckIfHit
		cmpwi	r3,0xE8
		bgt	ComboTrainingStartCheckIfHit
		b	ComboTrainingChangeToRandomDIandTech
		#Check If P2 is Hit
		ComboTrainingStartCheckIfHit:
		lbz	r3,0x221A(r29)			#Check If in Hitlag
		rlwinm.	r3,r3,0,26,26
		bne	ComboTrainingCheckIfBeingHit
		b	ComboTrainingCheckState
		ComboTrainingCheckIfBeingHit:
		lwz	r3,0x10(r29)
		cmpwi	r3,0x4B
		blt	ComboTrainingCheckState
		cmpwi	r3,0x5B
		bgt	ComboTrainingCheckState
		ComboTrainingChangeToRandomDIandTech:
		#Change To Random DI and Tech
		li	r3,0x1
		stb	r3,EventState(r31)
		b	ComboTrainingRandomDIAndTech

		#Get Which State
		ComboTrainingCheckState:
		lbz	r3,EventState(r31)
		cmpwi	r3,0x0
		beq	ComboTrainingStart
		cmpwi	r3,0x1
		beq	ComboTrainingRandomDIAndTech
		cmpwi	r3,0x2
		beq	ComboTrainingPostHitstun


		ComboTrainingStart:
		b	ComboTrainingCheckToReset

		ComboTrainingRandomDIAndTech:
		bl	ComboTrainingCheckExitStates
		cmpwi	r3,0x0
		beq	ComboTrainingRandomDIAndTechNoJiggs
		b	ComboTrainingChangeStateToPostHitstun


		ComboTrainingRandomDIAndTechNoJiggs:
		lwz	r3,0x10(r29)
		cmpwi	r3,0xB8		#Missed Tech, Needs to Input a Roll or Attack
		beq	ComboTrainingMissedTechThink
		cmpwi	r3,0xC0		#Missed Tech, Needs to Input a Roll or Attack
		beq	ComboTrainingMissedTechThink
		#Check If Still Grabbed
		cmpwi	r3,0xDF		#CapturePulledLow
		blt	ComboTrainingDecideInputs
		cmpwi	r3,0xE8 		#CapturePulledHi
		bgt	ComboTrainingDecideInputs

		#When Grabbed
		#Check Mash Out Behavior
		lbz	r3,GrabMashout(MenuData)
		cmpwi	r3,0x0
		beq	ComboTrainingRandomDIAndTech_RandomMash
		cmpwi	r3,0x1
		beq	ComboTrainingRandomDIAndTech_RandomMash_AnalogInput
		cmpwi	r3,0x2								#No Mash
		beq	ComboTrainingCheckToReset


		#Random Mash Out
		ComboTrainingRandomDIAndTech_RandomMash:
		li	r3,4										#4 Numbers
		branchl	r12,HSD_Randi
		cmpwi	r3,1									#1 and 2 Are No Input
		ble	ComboTrainingCheckToReset
		cmpwi	r3,0x2									#2 = Button Only, 3 = Both Analog and Button
		beq	ComboTrainingRandomDIAndTech_RandomMash_ButtonPress

		ComboTrainingRandomDIAndTech_RandomMash_AnalogInput:
		li	r3,127
		stb	r3,0x1A8C(r29)			#Push Analog Stick Forward
		li	r3,-1
		stb	r3,0x1A50(r29)			#Spoof Analog Stick as First Frame Pushed

		ComboTrainingRandomDIAndTech_RandomMash_ButtonPress:
		#Input Button Press
		li	r3,0x100
		stw	r3,0x1A88(r29)			#Press A
		li	r3,0
		stw	r3,0x65C(r29)			#Spoof Prev Frame Buttons as Nothing Pushed

		b	ComboTrainingCheckToReset


		ComboTrainingChangeStateToPostHitstun:
		#Change State
		li	r3,0x2
		stb	r3,EventState(r31)
		b	ComboTrainingPostHitstun





		ComboTrainingDecideInputs:


		#CHECK TO DI ATTACK
		ComboTrainingDIThrowsAndHits:
		#Check If in Hitlag
			lbz	r3,0x221A(r29)
			rlwinm.	r3,r3,0,26,26
			beq	ComboTrainingCheckIfBeingThrown
		#Check If In Last Frame of Hitlag
			lfs	f1,-0x7418(rtoc)		#1fp
			lfs	f2,0x195C(r29)		  #hitlag frames left
			fcmpo	cr0,f1,f2
			bne	ComboTrainingCheckToReset
		#Check If Attack Was Strong
		#DI Attack
			lbz	r3,DIBehavior(MenuData)		#Get DI Behavior
			cmpwi	r3,0x1		#Check If Slight In
			bne	0x8
			li	r3,0x0		#Override To Never Slight DI In Attacks
			b	0x8
			li	r3,0x2
			bl	ComboTrainingDecideStickAngle
		#SDI Attack
			lbz	r3,SDIBehavior(MenuData)		#Get SDI Behavior
			cmpwi	r3,0x3		#No SDI
			beq	ComboTrainingNoSDI
			cmpwi	r3,0x2		#Always SDI
			beq	ComboTrainingCheckToReset

			li	r3,0x3
			branchl	r12,HSD_Randi
			lbz	r4,SDIBehavior(MenuData)		#Get SDI Behavior
			cmpwi	r4,0x0
			beq	ComboTraining33PercentSDI
			cmpwi	r4,0x1
			beq	ComboTraining66PercentSDI
			ComboTraining33PercentSDI:
			li	r4,0
			b	ComboTrainingCompareSDIChance
			ComboTraining66PercentSDI:
			li	r4,1
			b	ComboTrainingCompareSDIChance

			ComboTrainingCompareSDIChance:
			cmpw	r3,r4
			ble	ComboTrainingGetChanceToTech
		#Don't SDI
		ComboTrainingNoSDI:
			mr	r3,r29
			branchl	r12,CPU_JoystickXAxis_Convert
			stfs	f1,0x620(r29)
			mr	r3,r29
			branchl	r12,CPU_JoystickYAxis_Convert
			stfs	f1,0x624(r29)
			b	ComboTrainingGetChanceToTech





		#CHECK TO DI A THROW
		ComboTrainingCheckIfBeingThrown:
		#Check If Being Thrown
			lwz	r3,0x10(r29)
			cmpwi	r3,0xEF
			blt	ComboTrainingCheckToJumpOutOfHitstun
			cmpwi	r3,0xF3
			bgt	ComboTrainingCheckToJumpOutOfHitstun
		ComboTrainingInputDI:
			lbz	r3,DIBehavior(MenuData)
			bl	ComboTrainingDecideStickAngle
			b	ComboTrainingCheckToReset






		#NOT BEING THROWN OR LAST FRAME OF HITLAG
		#CHECK TO JUMP OUT OF HITSTUN AND BECOME INVINCIBLE
		ComboTrainingCheckToJumpOutOfHitstun:
		#Check If in Damage State
		lwz	r3,0x10(r29)
		cmpwi	r3,0x26		#Tumble
		beq	ComboTrainingCheckIfInAir
		cmpwi	r3,0x4B
		blt	ComboTrainingCheckToReset
		cmpwi	r3,0x5B
		bgt	ComboTrainingCheckToReset

		#IN A DAMAGE STATE
		#Check If In Air
		ComboTrainingCheckIfInAir:
		lwz	r3,0xE0(r29)
		cmpwi	r3,0x0
		beq	ComboTrainingDamageGrounded

		#IN THE AIR
		#Check If Still in Hitstun
		lbz	r3,0x221C(r29)
		rlwinm.	r3,r3,0,30,30
		bne	ComboTrainingGetChanceToTech

		#NOT IN HITSTUN
		#Check Post Hitstun Behavior
		lbz	r3,PostHitstunAction(MenuData)
		cmpwi	r3,0x0
		beq	ComboTrainingAirdodge
		cmpwi	r3,0x1
		beq	ComboTrainingJumpAndInvincible
		cmpwi	r3,0x2
		beq	ComboTrainingAerialAttack

			ComboTrainingJumpAndInvincible:
			#Always Jump
			#li	r3,0
			#stw	r3,0x1A8C(r29)		#Nuetralize Stick Inputs
			#i	r3,0x400
			#stw	r3,0x1A88(r29)		#X Button
			b	ComboTrainingChangeStateToPostHitstun

			ComboTrainingAirdodge:
			#Wiggle Out of Hitstun
			li	r3,127
			stb	r3,0x1A8C(r29)
			#Last Frame's Stick Was Centered
			li	r3,0x0
			stw	r3,0x628(r29)
			stw	r3,0x62C(r29)
			#Stick Frame Timer Reset
			li	r3,255
			stb	r3,0x670(r29)
			#Change State
			li	r3,0x2
			stb r3,0x8(r31)
			b	ComboTrainingPostHitstun

			ComboTrainingAerialAttack:
			#li	r3,0x100
			#stw	r3,0x1A88(r29)		#Nair
			#Change State
			li	r3,0x2
			stb	r3,EventState(r31)
			b	ComboTrainingPostHitstun



		#CHECK TO BECOME INVINCIBLE OUT OF GROUNDED LIGHT DAMAGE STATES
		ComboTrainingDamageGrounded:
		#Check For Hitstun (Can Act Out of Certain Light Damage States)
		lbz	r3,0x221C(r29)
		rlwinm.	r3,r3,0,30,30
		bne	ComboTrainingCheckToReset
		#Grounded, No Hitstun Left, Become Invincible and Spotdodge
			#Check Post Hitstun Behavior
			lbz	r3,PostHitstunAction(MenuData)
			cmpwi	r3,0x0
			beq	ComboTrainingGroundedSpotdodge
			cmpwi	r3,0x1
			beq	ComboTrainingGroundedInvincibility
			cmpwi	r3,0x2
			beq	ComboTrainingGroundedAttack

			ComboTrainingGroundedInvincibility:
			b	ComboTrainingChangeStateToPostHitstun

			ComboTrainingGroundedSpotdodge:
			li	r3,0xC0		#Hit L
			stw	r3,0x1A88(r29)		#Held Buttons
			li	r3,-127		#Hold Down
			stb r3,0x1A8D(r29)		#Stick Y
			b	ComboTrainingChangeStateToPostHitstun

			ComboTrainingGroundedAttack:
			#li	r3,0x100		#Hit A
			#stw	r3,0x1A88(r29)		#Held Buttons
			b	ComboTrainingChangeStateToPostHitstun




		ComboTrainingGetChanceToTech:

		#INPUT A TECH WHEN IN AERIAL HITSTUN
		lbz	r3,TechOption(MenuData)		#Get Tech Behavior
		cmpwi	r3,0x0		#Random Tech (Original Behavior)
		beq	ComboTrainingRandomTech
		cmpwi	r3,0x1		#Miss Tech
		beq	ComboTrainingMissTech
		cmpwi	r3,0x2
		beq	ComboTrainingTechInPlace
		cmpwi	r3,0x3
		beq	ComboTrainingTechTowards
		cmpwi	r3,0x4
		beq	ComboTrainingTechAway

		ComboTrainingRandomTech:
		#Chance to Not Tech
		li	r3,4
		branchl	r12,HSD_Randi
		cmpwi	r3,0x0
		beq	ComboTrainingMissTech
		#Hold L
		#li	r3,0xC0
		#stw	r3,0x1A88(r29)
		#Reset Tech Cooldown Window Constantly
		li	r3,0x1
		stb	r3,0x680(r29)		#Frames Since Pressed L/R
		li	r3,0xFF
		stb	r3,0x684(r29)		#L/R Lockout Window

		#Check If In Hitlag Before Inputting Random Side (Messes Up DI Otherwise)
		lbz	r3,0x221A(r29)
		rlwinm.	r3,r3,0,26,26
		bne	ComboTrainingCheckToReset
		#Tech Random Side
		ComboTrainingRandomTech_GetStickAngle:
		li	r3,0x0		#0 = random direction
		bl	ComboTrainingDecideStickAngle
		#Check If Held Up
		lbz	r3,0x1A8D(r29)
		cmpwi	r3,0x0
		beq	ComboTrainingCheckToReset
		li	r3,0x0
		stb	r3,0x1A8D(r29)
		b	ComboTrainingCheckToReset
		ComboTrainingMissTech:
		li	r3,0x0
		stw	r3,0x1A88(r29)
		#Fail Tech Cooldown
		li	r3,0xFF
		stb	r3,0x680(r29)
		li	r3,0x00
		stb	r3,0x684(r29)
		b	ComboTrainingCheckToReset

		ComboTrainingTechInPlace:
		#Hold L
		li	r3,0xC0
		stw	r3,0x1A88(r29)
		#Reset Tech Cooldown Window Constantly
		li	r3,0x0
		stb	r3,0x680(r29)
		li	r3,0xFF
		stb	r3,0x684(r29)
		#Check If In Hitlag Before Inputting Random Side (Messes Up DI Otherwise)
		lbz	r3,0x221A(r29)
		rlwinm.	r3,r3,0,26,26
		bne	ComboTrainingCheckToReset
		li	r3,0x0
		stb	r3,0x1A8C(r29)
		b	ComboTrainingCheckToReset

		ComboTrainingTechTowards:
		#Hold L
		li	r3,0xC0
		stw	r3,0x1A88(r29)
		#Reset Tech Cooldown Window Constantly
		li	r3,0x0
		stb	r3,0x680(r29)
		li	r3,0xFF
		stb	r3,0x684(r29)
		#Check If In Hitlag Before Inputting Random Side (Messes Up DI Otherwise)
		lbz	r3,0x221A(r29)
		rlwinm.	r3,r3,0,26,26
		bne	ComboTrainingCheckToReset
		#Push Towards Opponent's Direction
		bl	GetDirectionInRelationToP1
		mulli	r3,r3,-1		#Negate This
		li	r4,127
		mullw	r3,r3,r4
		stb	r3,0x1A8C(r29)
		b	ComboTrainingCheckToReset

		ComboTrainingTechAway:
		#Hold L
		li	r3,0xC0
		stw	r3,0x1A88(r29)
		#Reset Tech Cooldown Window Constantly
		li	r3,0x0
		stb	r3,0x680(r29)
		li	r3,0xFF
		stb	r3,0x684(r29)
		#Check If In Hitlag Before Inputting Random Side (Messes Up DI Otherwise)
		lbz	r3,0x221A(r29)
		rlwinm.	r3,r3,0,26,26
		bne	ComboTrainingCheckToReset
		bl	GetDirectionInRelationToP1
		li	r4,127
		mullw	r3,r3,r4
		stb	r3,0x1A8C(r29)
		b	ComboTrainingCheckToReset

		#INPUT AN ATTACK OR DIRECTION WHEN MISSED A TECH
		ComboTrainingMissedTechThink:
			li	r3,4		#1/4 chance to getup attack
			branchl	r12,HSD_Randi
			cmpwi	r3,0x0
			beq	ComboTrainingMissedTech_GetupAttack
		#No Getup Attack, Input Random Direction
			li r3,0
			bl	ComboTrainingDecideStickAngle
			b		ComboTrainingCheckToReset
		#Input Getup Attack
		ComboTrainingMissedTech_GetupAttack:
			li	r3,0x100		#Press A To Getup Attack
			stw	r3,0x1A88(r29)
			b	ComboTrainingCheckToReset



		########################
		## Post Hitstun Think ##
		########################


		ComboTrainingPostHitstun:

		#Check Post Hitstun Behavior
		lbz	r3,PostHitstunAction(MenuData)
		cmpwi	r3,0x0
		beq		ComboTrainingPostHitstun_AirdodgeSpotdodge
		cmpwi	r3,0x1
		beq		ComboTrainingPostHitstun_GiveInvinc
		cmpwi	r3,0x2
		beq		ComboTrainingPostHitstun_Attack

			ComboTrainingPostHitstun_GiveInvinc:
			#Constantly Press Jump If In The Air
			lwz	r3,0xE0(r29)
			cmpwi	r3,0x0
			beq	ComboTrainingPostHitstun_GiveInvinc_ApplyInvinc
			li	r3,0x800
			stw	r3,0x1A88(r29)
			#Clear Prev Frame Jump Input
			li	r3,0x0
			stw	r3,0x668(r29)
			#Apply Invinc
			ComboTrainingPostHitstun_GiveInvinc_ApplyInvinc:
			mr	r3,r30
			li	r4,30
			branchl	r12,ApplyIntangibility
			#UpdateGFX
			mr	r3,r30
			branchl	r12,GFX_UpdatePlayerGFX
			#Set Timer if Not Set
			lwz	r3,0x4(r31)
			cmpwi	r3,0x0
			bgt	ComboTrainingCheckToReset
			#Set Timer
			li	r3,30
			stw	r3,0x4(r31)
			b	ComboTrainingCheckToReset

		#****************************************************************#

			ComboTrainingPostHitstun_AirdodgeSpotdodge:
			#Check If In Airdodge
			#Check If In Gained Invuln From Air/Spotdodge
			lwz	r3,0x1988(r29)
			cmpwi	r3,0x0
			beq	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckToAirdodge
			b	ComboTrainingPostHitstun_EnteredAirdodgeSpotdodge
			ComboTrainingPostHitstun_EnteredAirdodgeSpotdodge:
			#Set Timer if Not Set
			lwz	r3,0x4(r31)
			cmpwi	r3,0x0
			bgt	ComboTrainingCheckToReset
			#Set Timer
			li	r3,30
			stw	r3,0x4(r31)
			#Give Invince and Exit
			b	ComboTrainingCheckToReset

		#****************************************************************#

			ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckToAirdodge:
			#If in An Exit State, Reset State
			bl	ComboTrainingCheckExitStates
			cmpwi	r3,0x0
			beq	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState
			#Except Fall
			lwz	r3,0x10(r29)
			cmpwi	r3,0x1D
			beq	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState
			#Except Landing
			cmpwi	r3,0x2A
			beq	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState
			#Except Wait
			cmpwi	r3,0xE
			beq	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState
			#Set Timer if Not Set
			lwz	r3,0x4(r31)
			cmpwi	r3,0x0
			bgt	ComboTrainingCheckToReset
			#Set Timer
			li	r3,30
			stw	r3,0x4(r31)

			ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState:
			#Check If in Air
			lwz	r3,0xE0(r29)
			cmpwi	r3,0x0
			beq	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckToAirdodge_CheckToSpotdodge
			#Check If In DamageLightHit With No Hitstun Left (Same interrupts as Fall)
				lwz	r3,0x10(r29)
				cmpwi	r3,0x56
				beq	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState_InputAirdodge
			ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState_CheckToWiggleOut:
			#Check If In Damage States
				lwz	r3,0x10(r29)
				cmpwi	r3,0x4B
				blt	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState_CheckForFall
				cmpwi	r3,0x5B
				bgt	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState_CheckForFall
			#Wiggle Out to Enter Fall
				li	r3,127
				stb	r3,0x1A8C(r29)
				b	ComboTrainingCheckToReset
			#Check If In Fall
				ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState_CheckForFall:
				lwz	r3,0x10(r29)
				cmpwi	r3,0x1D
				bne	ComboTrainingCheckToReset
			ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckAirState_InputAirdodge:
			#Airdodge
				li	r3,0
				stb	r3,0x1A8C(r29)
				li	r3,0xC0
				stw	r3,0x1A88(r29)
			#Clear Buttons From Last Frame
				li	r3,0x0
				stw	r3,0x65C(r29)
				b	ComboTrainingCheckToReset
			ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckToAirdodge_CheckToSpotdodge:
			#Check If Grounded and Actionable
				lwz	r3,0x10(r29)
				cmpwi	r3,0xE		#Wait
				beq	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckToAirdodge_Spotdodge
				cmpwi	r3,0xB6		#Shielding
				beq	ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckToAirdodge_Spotdodge
				cmpwi	r3,0x2A		#Land
				bne	ComboTrainingCheckToReset
				#Check If Can Interrupt Land
					lfs	f1,0x894(r29)
					lfs	f2,0x1F4(r29)
					fcmpo	cr0,f1,f2
					blt	ComboTrainingCheckToReset
			ComboTrainingPostHitstun_AirdodgeSpotdodge_CheckToAirdodge_Spotdodge:
			#Clear Buttons From Last Frame
			li	r3,0x0
			stw	r3,0x65C(r29)
			#Input Spotdodge
			li	r3,0xC0
			stw	r3,0x1A88(r29)
			li	r3,-127
			stb	r3,0x1A8D(r29)
			b	ComboTrainingCheckToReset

		#****************************************************************#

			ComboTrainingPostHitstun_Attack:

			#Clear Buttons From Last Frame
			li	r3,0x0
			stw	r3,0x65C(r29)

			#Get Air or Ground
			lwz	r3,0xE0(r29)
			cmpwi	r3,0x0
			beq	ComboTrainingPostHitstun_AttackGround

			ComboTrainingPostHitstun_AttackAir:
			bl	ComboTrainingAttackList
			mflr	r5
			lwz	r4,0x4(r29)
			lbzx	r3,r4,r5
			rlwinm	r3,r3,0,28,31		#Get Right Bits
			b	ComboTrainingPostHitstun_Attack_BranchToAttack

			ComboTrainingPostHitstun_AttackGround:
			bl	ComboTrainingAttackList
			mflr	r5
			lwz	r4,0x4(r29)
			lbzx	r3,r4,r5
			rlwinm	r3,r3,28,28,31		#Get Left Bits
			b	ComboTrainingPostHitstun_Attack_BranchToAttack


			ComboTrainingPostHitstun_Attack_BranchToAttack:
			cmpwi	r3,0x0
			beq	ComboTrainingPostHitstun_Attack_A
			cmpwi	r3,0x1
			beq	ComboTrainingPostHitstun_Attack_ForwardA
			cmpwi	r3,0x2
			beq	ComboTrainingPostHitstun_Attack_BackA
			cmpwi	r3,0x3
			beq	ComboTrainingPostHitstun_Attack_DownA
			cmpwi	r3,0x4
			beq	ComboTrainingPostHitstun_Attack_UpA
			cmpwi	r3,0x5
			beq	ComboTrainingPostHitstun_Attack_DownSmash
			cmpwi	r3,0x6
			beq	ComboTrainingPostHitstun_Attack_UpB
			cmpwi	r3,0x7
			beq	ComboTrainingPostHitstun_Attack_DownB

				ComboTrainingPostHitstun_Attack_A:
				li	r3,0x100		#Hit A
				stw	r3,0x1A88(r29)		#Held Buttons
				b	ComboTrainingPostHitstun_Attack_CheckForHitbox

				ComboTrainingPostHitstun_Attack_ForwardA:
				#Push Towards Opponent's Direction
				bl	GetDirectionInRelationToP1
				mulli	r3,r3,-1		#Negate This
				li	r4,60
				mullw	r3,r3,r4
				stb	r3,0x1A8C(r29)
				li	r3,0x100		#Hit A
				stw	r3,0x1A88(r29)		#Held Buttons
				b	ComboTrainingPostHitstun_Attack_CheckForHitbox

				ComboTrainingPostHitstun_Attack_BackA:
				#Push Away Opponent's Direction
				bl	GetDirectionInRelationToP1
				li	r4,60
				mullw	r3,r3,r4
				stb	r3,0x1A8C(r29)
				li	r3,0x100		#Hit A
				stw	r3,0x1A88(r29)		#Held Buttons
				b	ComboTrainingPostHitstun_Attack_CheckForHitbox

				ComboTrainingPostHitstun_Attack_DownA:
				li	r3,60
				stb	r3,0x1A8D(r29)
				li	r3,0x100		#Hit A
				stw	r3,0x1A88(r29)		#Held Buttons
				b	ComboTrainingPostHitstun_Attack_CheckForHitbox

				ComboTrainingPostHitstun_Attack_UpA:
				li	r3,60
				stb	r3,0x1A8D(r29)
				li	r3,0x100		#Hit A
				stw	r3,0x1A88(r29)		#Held Buttons
				b	ComboTrainingPostHitstun_Attack_CheckForHitbox

				ComboTrainingPostHitstun_Attack_DownSmash:
				li	r3,-127
				stb	r3,0x1A8F(r29)
				b	ComboTrainingPostHitstun_Attack_CheckForHitbox

				ComboTrainingPostHitstun_Attack_UpB:
				li	r3,127
				stb	r3,0x1A8D(r29)
				li	r3,0x200		#Hit B
				stw	r3,0x1A88(r29)		#Held Buttons
				b	ComboTrainingPostHitstun_Attack_CheckForHitbox

				ComboTrainingPostHitstun_Attack_DownB:
				li	r3,-127
				stb	r3,0x1A8D(r29)
				li	r3,0x200		#Hit B
				stw	r3,0x1A88(r29)		#Held Buttons
				b	ComboTrainingPostHitstun_Attack_CheckForHitbox



			#Search For Active Hitbox
			ComboTrainingPostHitstun_Attack_CheckForHitbox:
			mr	r3,r30
			bl	CheckForActiveHitboxes
			cmpwi	r3,0x0
			bne	ComboTrainingPostHitstun_GiveInvinc_ApplyInvinc
			#Harcoded Fox Grounded Shine Check =(
			lwz	r3,0x4(r29)
			cmpwi	r3,0x1
			beq	ComboTrainingPostHitstun_Attack_CheckForGroundShine
			cmpwi	r3,0x16
			beq	ComboTrainingPostHitstun_Attack_CheckForGroundShine
			#Hardcoded Puff Rest Check =(
			cmpwi	r3,0xF
			beq	ComboTrainingPostHitstun_Attack_CheckForRest
			b	ComboTrainingCheckToReset
			ComboTrainingPostHitstun_Attack_CheckForGroundShine:
			lwz	r3,0x10(r29)
			cmpwi	r3,0x168
			beq	ComboTrainingPostHitstun_GiveInvinc_ApplyInvinc
			b	ComboTrainingCheckToReset
			ComboTrainingPostHitstun_Attack_CheckForRest:
			lwz	r3,0x10(r29)
			cmpwi	r3,0x171
			beq	ComboTrainingPostHitstun_GiveInvinc_ApplyInvinc
			b	ComboTrainingCheckToReset


		#****************************************************************#

		#Check To Reset
		ComboTrainingCheckToReset:
		lwz	r3,0x4(r31)		#get timer
		cmpwi	r3,0x0		#No Reset Timer Set Yet
		ble	ComboTrainingThinkExit
		#Dec Timer
		subi	r3,r3,0x1
		stw	r3,0x4(r31)		#store timer
		cmpwi	r3,0x0		#Check if 0 now
		bne	ComboTrainingThinkExit	#Exit If Not

		ComboTrainingRestoreState:
		#Restore State
		addi r3,EventData,0x10
		bl	SaveState_Load
		addi r3,EventData,0x10
		bl	SaveState_Load
		#Reset State ID
		li	r3,0x0
		stb	r3,EventState(r31)
		ComboTrainingThinkExit:
    mr  r3,MenuData
    bl  ClearToggledOptions
		bl	UpdateAllGFX
		restore
		blr

#################################

ComboTraining_StartingGroundIDs:
blrl
#Ground IDs to start on
.long 0xFFFFFFFF #Dummy, TEST
.long 0x00050022 #FoD, Pokemon Stadium
.long 0x00050037 #Peach's Castle, Kongo Jungle
.long 0x000B0012 #Brinstar, Corneria
.long 0x00030019 #Yoshi's Story, Onett
.long 0x00000048 #Mute City, Rainbow Cruise
.long 0x00000024 #Jungle Japes, Great Bay
.long 0x00190007 #Hyrule Temple, Brinstar Depths
.long 0x000E0026 #Yoshi's Island, Green Greens
.long 0x00040003 #Fourside, MKI
.long 0x00040000 #MKII, Akaneia
.long 0x00010105 #Venom, PokeFloats
.long 0x00D9015B #Big Blue, Icicle Mountain
.long 0x00000064 #Icetop, Flatzone
.long 0x00040009 #Dream Land, Yoshis Island 64
.long 0x000b0001 #Kongo Jungle 64, Battlefield
.long 0x00010000 #Final Destination
#################################

ComboTrainingDecideStickAngle:
#Decide Stick Angle
backup

#Clear Stick Inputs Just in Case
li	r4,0x0
stb	r4,0x1A8C(r29)
stb	r4,0x1A8D(r29)

#Check Which Type Of DI To Perform
cmpwi	r3,0x0
beq	ComboTrainingDecideStickAngle_RandomDI
cmpwi	r3,0x1
beq	ComboTrainingDecideStickAngle_SlightDI
cmpwi	r3,0x2
beq	ComboTrainingDecideStickAngle_SurvivalDI
cmpwi	r3,0x3
beq	ComboTrainingDecideStickAngle_ComboDI
cmpwi	r3,0x4
beq	ComboTrainingDecideStickAngle_DownAwayDI
cmpwi	r3,0x5
beq	ComboTrainingDecideStickAngle_NoDI


###############
## Random DI ##
###############

#Get RNG Out of 3
ComboTrainingDecideStickAngle_RandomDI:
li	r3,3
branchl	r12,HSD_Randi
cmpwi	r3,0x0
beq	ComboTrainingDecideStickAngle_RandomDI_UpStick
cmpwi	r3,0x1
beq	ComboTrainingDecideStickAngle_RandomDI_LeftStick
cmpwi	r3,0x2
beq	ComboTrainingDecideStickAngle_RandomDI_RightStick

ComboTrainingDecideStickAngle_RandomDI_UpStick:
li	r3,127
stb	r3,0x1A8D(r29)
b	ComboTrainingDecideStickAngleExit

ComboTrainingDecideStickAngle_RandomDI_LeftStick:
#Get Random Stick X Input 77-127
li	r3,50
branchl	r12,HSD_Randi
addi	r3,r3,77		#Start at 77
mulli	r3,r3,-1
stb	r3,0x1A8C(r29)
b	ComboTrainingDecideStickAngleExit

ComboTrainingDecideStickAngle_RandomDI_RightStick:
#Get Random Stick X Input 77-127
li	r3,50
branchl	r12,HSD_Randi
addi	r3,r3,77		#Start at 77
stb	r3,0x1A8C(r29)
b	ComboTrainingDecideStickAngleExit

#######################
## Slight DI Towards ##
#######################

ComboTrainingDecideStickAngle_SlightDI:

#Get Random Stick X Input 86-105, 86-95 go in front, 96-105 go behind shiek behind
li	r3,19
branchl	r12,HSD_Randi
addi	r3,r3,86		#Start at 86
lfs	f1,0x2C(r27)
fneg	f1,f1
fctiwz	f1,f1
stfd	f1,0xF0(sp)
lwz	r4,0xF4(sp)		#Facing direction as int
mullw	r3,r3,r4
stb	r3,0x1A8C(r29)
b	ComboTrainingDecideStickAngleExit

#################
## Survival DI ##
#################

ComboTrainingDecideStickAngle_SurvivalDI:
#Check If In Throw
bl	ComboTrainingCheckForThrowAngle
cmpwi	r3,-1
bne	ComboTrainingDecideStickAngle_SurvivalDI_UsingThrowAngle
#Get Knockback Angle
lwz	r3,0x1848(r29)
ComboTrainingDecideStickAngle_SurvivalDI_UsingThrowAngle:

#Get Perpendicular Angle
#Get Damage Direction
cmpwi	r3,0x169		#Check For Sakurai Angle
bne	0xC
li	r3,0x2D
li	r4,0x2D
cmpwi	r3,90
bge	ComboTrainingDecideStickAngle_SurvivalDI_Above90
b	ComboTrainingDecideStickAngle_SurvivalDI_RightSide
ComboTrainingDecideStickAngle_SurvivalDI_Above90:
cmpwi	r3,269
blt	ComboTrainingDecideStickAngle_SurvivalDI_LeftSide
ComboTrainingDecideStickAngle_SurvivalDI_RightSide:
addi	r3,r3,90
cmpwi	r3,360
blt	0x8
subi	r3,r3,360
b	ComboTrainingDecideStickAngle_SurvivalDI_GetXY
ComboTrainingDecideStickAngle_SurvivalDI_LeftSide:
subi	r3,r3,90
cmpwi	r3,0
bgt	0x8
addi	r3,r3,360
b	ComboTrainingDecideStickAngle_SurvivalDI_GetXY

ComboTrainingDecideStickAngle_SurvivalDI_GetXY:
bl	ComboTrainingDecideStickAngle_ConvertAngle
stb	r3,0x1A8C(r29)
stb	r4,0x1A8D(r29)
bl	GetDirectionInRelationToP1
#mulli	r3,r3,-1		#Negate This Value
lbz	r4,0x1A8C(r29)
mullw	r3,r3,r4
stb	r3,0x1A8C(r29)		#Point Towards Opponent
b	ComboTrainingDecideStickAngleExit

##############
## Combo DI ##
##############

ComboTrainingDecideStickAngle_ComboDI:

#Check If In Throw
bl	ComboTrainingCheckForThrowAngle
cmpwi	r3,-1
bne	ComboTrainingDecideStickAngle_ComboDI_UsingThrowAngle
#Get Knockback Angle
lwz	r3,0x1848(r29)
ComboTrainingDecideStickAngle_ComboDI_UsingThrowAngle:
mr	r24,r3		#Backup Original Angle We're Using

#Get Perpendicular Angle
#Get Damage Direction
cmpwi	r3,0x169		#Check For Sakurai Angle
bne	0xC
li	r3,0x2D
li	r4,0x2D
cmpwi	r3,90
bge	ComboTrainingDecideStickAngle_ComboDI_Above90
b	ComboTrainingDecideStickAngle_ComboDI_RightSide
ComboTrainingDecideStickAngle_ComboDI_Above90:
cmpwi	r3,269
blt	ComboTrainingDecideStickAngle_ComboDI_LeftSide
ComboTrainingDecideStickAngle_ComboDI_RightSide:
subi	r3,r3,90
cmpwi	r3,0
bgt	0x8
addi	r3,r3,360
b	ComboTrainingDecideStickAngle_ComboDI_GetXY
ComboTrainingDecideStickAngle_ComboDI_LeftSide:
addi	r3,r3,90
cmpwi	r3,360
blt	0x8
subi	r3,r3,360
b	ComboTrainingDecideStickAngle_ComboDI_GetXY

ComboTrainingDecideStickAngle_ComboDI_GetXY:
bl	ComboTrainingDecideStickAngle_ConvertAngle
stb	r3,0x1A8C(r29)
stb	r4,0x1A8D(r29)

#If In a Throw, Always DI The Direction Of The Angle
lwz	r3,0x10(r29)
cmpwi	r3,0xEF
blt	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionNoThrow
cmpwi	r3,0xF3
bgt	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionNoThrow

ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow:
cmpwi	r24,90
bge	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_Above90
b	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_RightSide
ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_Above90:
cmpwi	r3,269
blt	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_LeftSide

ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_RightSide:
#Always Facing Direction

li	r3,0x0
bl	IntToFloat
lfs	f2,0x2C(r27)
fcmpo	cr0,f2,f1
bgt	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_RightSide_Abs
ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_RightSide_AbsNeg:
lbz	r3,0x1A8C(r29)
extsb	r3,r3
bl	IntToFloat
fabs	f1,f1
fneg	f1,f1
b	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_RightSide_StoreX
ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_RightSide_Abs:
lbz	r3,0x1A8C(r29)
extsb	r3,r3
bl	IntToFloat
fabs	f1,f1
b	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_RightSide_StoreX
ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_RightSide_StoreX:
fctiwz	f1,f1
stfd	f1,0xF0(sp)
lwz	r3,0xF4(sp)
stb	r3,0x1A8C(r29)
b	ComboTrainingDecideStickAngleExit

ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_LeftSide:
#Always Opposite My Facing Direction

li	r3,0x0
bl	IntToFloat
lfs	f2,0x2C(r27)
fcmpo	cr0,f2,f1
bgt	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_LeftSide_AbsNeg
ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_LeftSide_Abs:
lbz	r3,0x1A8C(r29)
extsb	r3,r3
bl	IntToFloat
fabs	f1,f1
b	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_LeftSide_StoreX
ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_LeftSide_AbsNeg:
lbz	r3,0x1A8C(r29)
extsb	r3,r3
bl	IntToFloat
fabs	f1,f1
fneg	f1,f1
b	ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_LeftSide_StoreX
ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionInThrow_LeftSide_StoreX:
fctiwz	f1,f1
stfd	f1,0xF0(sp)
lwz	r3,0xF4(sp)
stb	r3,0x1A8C(r29)
b	ComboTrainingDecideStickAngleExit

ComboTrainingDecideStickAngle_ComboDI_AdjustDirectionNoThrow:
bl	GetDirectionInRelationToP1
#mulli	r3,r3,-1		#Negate This Value
lbz	r4,0x1A8C(r29)
mullw	r3,r3,r4
stb	r3,0x1A8C(r29)		#Point Towards Opponent
b	ComboTrainingDecideStickAngleExit

######################
## Down And Away DI ##
######################

ComboTrainingDecideStickAngle_DownAwayDI:
#Load X Value
bl	GetDirectionInRelationToP1
#Point Away From P1
li	r4,89
mullw	r3,r3,r4
stb	r3, 0x1A8C (r29)
#Load Y Value
li	r3,-89
stb	r3, 0x1A8D (r29)

b	ComboTrainingDecideStickAngleExit

###########
## No DI ##
###########

ComboTrainingDecideStickAngle_NoDI:

ComboTrainingDecideStickAngleExit:
restore
blr


#######################################################

ComboTrainingDecideStickAngle_ConvertAngle:
#Convert New Angle To Float
backup

bl		IntToFloat

#Get Pi/180
lfs	f2,-0x7510(rtoc)

#Get Angle As Radian
fmuls	f31,f1,f2

#Get 127 as Float
li	r3,127
bl		IntToFloat
fmr		f30,f1

#Convert To X and Y Components
fmr	f1,f31
branchl	r12,cos		#load cosine function
fmuls	f1,f1,f30		#Get X Component As Float
fctiwz	f1,f1
stfd	f1,0xF0(sp)
lwz	r20,0xF4(sp)

fmr	f1,f31
branchl	r12,sin	#load sine function
fmuls	f1,f1,f30		#Get X Component As Float
fctiwz	f1,f1
stfd	f1,0xF0(sp)
lwz	r21,0xF4(sp)

#Clamp Deadzones
ComboTrainingDecideStickAngle_ConvertAngle_ClampX:
mr	r3,r20
bl	IntToFloat
fabs	f3,f1
li	r3,36
bl	IntToFloat
fcmpo	cr0,f3,f1
bge	ComboTrainingDecideStickAngle_ConvertAngle_ClampY
li	r20,0x0

ComboTrainingDecideStickAngle_ConvertAngle_ClampY:
mr	r3,r21
bl	IntToFloat
fabs	f3,f1
li	r3,36
bl	IntToFloat
fcmpo	cr0,f3,f1
bge	ComboTrainingDecideStickAngle_ConvertAngle_Exit
li	r21,0x0

ComboTrainingDecideStickAngle_ConvertAngle_Exit:
#Return X Y Stick Values
mr	r3,r20
mr	r4,r21

restore
blr

##############################################################

ComboTrainingCheckForThrowAngle:
#Check If In Throw First (Must Retrieve Angle Manually)
lwz	r3,0x10(r29)		#CPU AS
cmpwi	r3,0xEF
blt	ComboTrainingCheckForThrowAngle_NoThrow
cmpwi	r3,0xF3
bgt	ComboTrainingCheckForThrowAngle_NoThrow

#Get Throw Angle
addi	r4,r27,0xdf4		#P1 Throw Hitbox Info?
lwz	r3,0x20(r4)		#Throw Angle
b	ComboTrainingCheckForThrowAngle_NoThrowExit

ComboTrainingCheckForThrowAngle_NoThrow:
li	r3,-1

ComboTrainingCheckForThrowAngle_NoThrowExit:
blr

####################################################

ComboTrainingCheckExitStates:

#Check For Exit States
	lwz	r3,0x10(r29)
	cmpwi	r3,0xE		#Wait
	beq	ComboTrainingCheckExitStates_ExitState
	cmpwi	r3,0x1D		#Fall
	beq	ComboTrainingCheckExitStates_ExitState
	cmpwi	r3,0x1B		#DJ
	beq	ComboTrainingCheckExitStates_ExitState
	cmpwi	r3,0xFD		#CliffWait
	beq	ComboTrainingCheckExitStates_ExitState
	cmpwi	r3,0xF5		#Teeter
	beq	ComboTrainingCheckExitStates_ExitState
	cmpwi	r3,0x1C		#JumpB Aerial
	beq	ComboTrainingCheckExitStates_ExitState
	cmpwi	r3,0x2A		#Land
	bne	ComboTrainingCheckExitStates_CheckJiggsJump
		#Check If Can Interrupt Land
		lfs	f1,0x894(r29)
		lfs	f2,0x1F4(r29)
		fcmpo	cr0,f1,f2
		bge	ComboTrainingCheckExitStates_ExitState

	ComboTrainingCheckExitStates_CheckJiggsJump:
	lwz	r4,0x4(r29)
	cmpwi	r4,0xF		#Check If Jiggs
	bne	ComboTrainingCheckExitStates_NoExitState
		cmpwi	r3,0x155
		beq	ComboTrainingCheckExitStates_ExitState

ComboTrainingCheckExitStates_NoExitState:
li	r3,0x0
b	ComboTrainingCheckExitStates_Exit

ComboTrainingCheckExitStates_ExitState:
li	r3,0x1
b	ComboTrainingCheckExitStates_Exit

ComboTrainingCheckExitStates_Exit:
blr

####################################################

ComboTrainingWindowInfo:
blrl
#amount of options, amount of options in each window

.long 0x04050304  #5 windows, DI has 6 options, SDI has 4 Options, Tech Has 5 Options
.long 0x02020000  #PostHitstun has 3 options, Mash has 3 options

####################################################

ComboTrainingWindowText:
blrl

########
## DI ##
########

#Window Title = DI Behavior
.long 0x44492042
.long 0x65686176
.long 0x696f7200

#Option 1 = Random DI
.long 0x52616e64
.long 0x6f6d2044
.long 0x49000000

#Option 2 = Slight DI Towards
.long 0x536c6967
.long 0x68742044
.long 0x4920546f
.long 0x77617264
.long 0x73000000

#Option 3 = Survival DI
.long 0x53757276
.long 0x6976616c
.long 0x20444900

#Option 4 = Combo DI
.long 0x436f6d62
.long 0x6f204449
.long 0x00000000

#Option 5 = Down and Away DI
.long 0x446f776e
.long 0x20616e64
.long 0x20417761
.long 0x79204449
.long 0x00000000

#Option 6 = No DI
.long 0x4e6f2044
.long 0x49000000

#########
## SDI ##
#########

#SDI Behavior
.long 0x53444920
.long 0x42656861
.long 0x76696f72
.long 0x00000000

#Option 1 = 33% Chance to SDI
.long 0x33338193
.long 0x20436861
.long 0x6e636520
.long 0x746f2053
.long 0x44490000

#Option 2 = 66% Chance to SDI
.long 0x36368193
.long 0x20436861
.long 0x6e636520
.long 0x746f2053
.long 0x44490000

#Option 3 = Always SDI
.long 0x416c7761
.long 0x79732053
.long 0x44490000

#Option 4 = No SDI
.long 0x4e6f2053
.long 0x44490000

#################
## Tech Option ##
#################

#Tech Option
.long 0x54656368
.long 0x204f7074
.long 0x696f6e00

#Option 1 = Random
.long 0x52616e64
.long 0x6f6d0000

#Option 2 = Missed Tech
.long 0x4d697373
.long 0x65642054
.long 0x65636800

#Option 3 = Tech In Place
.long 0x54656368
.long 0x20496e20
.long 0x506c6163
.long 0x65000000

#Option 4 = Tech In
.long 0x54656368
.long 0x20496e00

#Option 5 = Tech Away
.long 0x54656368
.long 0x20417761
.long 0x79000000


#################
## Tech Option ##
#################

#Post Hitstun Action
.long 0x506f7374
.long 0x20486974
.long 0x7374756e
.long 0x20416374
.long 0x696f6e00

#Airdodge/Spotdodge
.long 0x41697264
.long 0x6f646765
.long 0x815e5370
.long 0x6f74646f
.long 0x64676500

#Invincible
.long 0x496e7669
.long 0x6e636962
.long 0x6c650000

#Attack
.long 0x41747461
.long 0x636b0000


###################
## Grab Mash-Out ##
###################

#Grab Mash-Out
.long 0x47726162
.long 0x204d6173
.long 0x682d4f75
.long 0x74000000
.long 0x

#Random Mash
.long 0x52616e64
.long 0x6f6d204d
.long 0x61736800
.long 0x
.long 0x

#Frame Perfect
.long 0x4672616d
.long 0x65205065
.long 0x72666563
.long 0x74000000
.long 0x

#No Mash-Out
.long 0x4e6f204d
.long 0x6173682d
.long 0x4f757400
.long 0x
.long 0x

####################################################

ComboTrainingAttackList:
blrl
.long 0x00700466
.long 0x02660000
.long 0x30000303
.long 0x04660073
.long 0x30000152
.long 0x00007000
.long 0x660400FF

####################################################



ComboTrainingLoadExit:
restore
blr







##################################################


#########################
## Waveshine SDI HIJACK INFO ##
#########################

WaveshineSDI:
#STORE STAGE
li	r3,0x20
sth	r3,0xE(r26)

li	r5,0x2		#Fox

#STORE CPU
lwz	r4,0x0(r29)
bl	P2Struct
mflr	r3
stw	r3,0x18(r4)		#p2 pointer
stb	r5,0x0(r3)		#make top tier p2
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)

#Store Events FDD Toggles
lwz	r5,-0x77C0(r13)
lwz	r3,0x1F24(r5)
load	r4,0x10000400
or	r3,r3,r4
stw	r3,0x1F24(r5)

#If IC's Make SoPo
lbz	r3,0x2(r30)		#P1 External ID
cmpwi	r3,0xE
bne	WaveshineSDIStoreThink
li	r3,0x20
stb	r3,0x2(r30)		#Make SoPo

#STORE THINK FUNCTION
WaveshineSDIStoreThink:
bl	WaveshineSDILoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Waveshine SDI LOAD FUNCT ##
	########################
	WaveshineSDILoad:
	blrl

	backup

	#Schedule Think
	bl	WaveshineSDIThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
  li  r5,0
	bl	CreateEventThinkFunction

/*
	#Make Long Destination
	#Get Stage DAT Pointer
	load	r3,0x80432290
	lwz	r3,0x10(r3)
	lwz	r6,0x4(r3)
  lis r3, 0x4040
  li r5, 0x0
  ori r4, r5, 0xF488
  stwx r3, r6, r4
  ori r4, r5, 0xF4CC
  stwx r3, r6, r4
  ori r4, r5, 0xF4D0
  stwx r3, r6, r4
  ori r4, r5, 0xF590
  stwx r3, r6, r4
  lis r4, 0x1
  ori r4, r4, 0x88
  stwx r3, r6, r4
  lis r4, 0x1
  ori r4, r4, 0x608
  stwx r3, r6, r4
  lis r3, 0x4248
  ori r4, r5, 0xF4D8
  stwx r3, r6, r4
  lis r4, 0x5
  ori r4, r4, 0x1B90
  stwx r5, r6, r4
  lis r5, 0x5
  lis r3, 0xC3AA
  ori r3, r3, 0x91EC
  ori r4, r5, 0x1F20
  stwx r3, r6, r4
  lis r3, 0x43AA
  ori r3, r3, 0x91EC
  ori r4, r5, 0x1F60
  stwx r3, r6, r4
  lis r3, 0xC3D0
  ori r3, r3, 0x91EC
  ori r4, r5, 0x1FA0
  stwx r3, r6, r4
  lis r3, 0x43D0
  ori r3, r3, 0x91EC
  ori r4, r5, 0x1FE0
  stwx r3, r6, r4
*/

	b	WaveshineSDILoadExit


		#########################
		## Waveshine SDI THINK FUNCT ##
		#########################


		WaveshineSDIThink:
			blrl

      .set EventData,31
      .set P1Data,27
      .set P1GObj,28
      .set P2Data,29
      .set P2GObj,30

			backup

		#INIT FUNCTION VARIABLES
			lwz		EventData,0x2c(r3)			#backup data pointer in r31

      bl  GetAllPlayerPointers
      mr P1GObj,r3
      mr P1Data,r4
      mr P2GObj,r5
      mr P2Data,r6

		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	WaveshineSDIThinkMain

				#Set Frame 1 As Over
					li		r3,0x1
					stb		r3,0x0(r31)
				#Set Facing Directions
					lis	r3,0x3f80
					stw	r3,0x2C(r29)
					lis	r3,0xBf80
					stw	r3,0x2C(r27)
				#Initlize Positions
					bl	WaveshineSDI_Floats
					mflr	r3
					bl	InitializePositions
        #Clear Inputs
          bl  RemoveFirstFrameInputs
				#Store Ground As Last Known Position
					lfs	f1, 0x00B4 (r29)
					stfs	f1, 0x0834 (r29)
				#Save State
					addi r3,EventData,0x10
					bl	SaveState_Save
				#Set Timer to -60
					li		r3,-60
					stw		r3,0x4(r31)



		WaveshineSDIThinkMain:
		WaveshineSDIThinkSequence:
		#Inc Timer
			lwz	r3,0x4(r31)
			addi	r3,r3,0x1
			stw	r3,0x4(r31)

		#Get Floats
			bl	WaveshineSDI_Floats
			mflr	r21

		#Check Timer
			cmpwi	r3,0x0
			blt	WaveshineSDICheckToReset

		#Check If Edge Of Stage
			lfs	f1,0xB0(r29)		#P1 X Coord
			lfs	f2,0x18(r21)		#Max X Coord
			fabs	f1,f1
			fabs	f2,f2
			fcmpo	cr0,f1,f2
			blt	WaveshineSDISkipBoundaryCheck
		#Freeze Fox If So
			lbz	r0,0x2219(r29)
			li	r3,1
			rlwimi	r0,r3,2,29,29
			stb	r0,0x2219(r29)
			lwz 	r3,0xC(r31)
			cmpwi	r3,0x0		#No Reset Timer Set Yet
			bgt	WaveshineSDICheckToReset
			li	r3,60		#Set Timer If Not Set Yet
			stw	r3,0xC(r31)
			b	WaveshineSDICheckToReset
		WaveshineSDISkipBoundaryCheck:

		#Check If Fox Grabbed Marth
			lwz	r3,0x10(r29)
			cmpwi	r3,0xD8
			bne	WaveshineSDICheckDrillOrWaveshine
			lwz	r3,0xC(r31)
			cmpwi	r3,0x0
			bgt	WaveshineSDICheckDrillOrWaveshine
			li	r3,60
			stw	r3,0xC(r31)

		#Check If Drilling or Waveshining
			WaveshineSDICheckDrillOrWaveshine:
			lbz	r3,0x8(r31)
			cmpwi	r3,0x1
			bge	WaveshineSDIWaveshineThink

		#Run Drill Code
			WaveshineSDIDrillThink:
			lwz	r3,0x10(r29)

		WaveshineSDIDrillThink_CheckToJump:
			cmpwi	r3,0xE
			bne	WaveshineSDIDrillThink_CheckToDair
			li	r3,0x400
			stw	r3,0x1A88(r29)
			b	WaveshineSDICheckToReset

		WaveshineSDIDrillThink_CheckToDair:
			cmpwi	r3,0x19
			bne	WaveshineSDI_CheckToFF
			li	r3,-127
			stb	r3,0x1A8F(r29)
			b	WaveshineSDICheckToReset

		WaveshineSDI_CheckToFF:
		#Check If Drilling
			cmpwi	r3,0x45
			bne	WaveshineSDICheckToReset
		#Joystick X = 36 * Facing Direction (Drift Forward during drill
			lfs	f1,0x2C(r29)
			fctiwz	f1,f1
			stfd	f1,0xF0(sp)
			lwz	r4,0xF4(sp)
			li	r3,36		#X Stick
			mullw	r3,r3,r4
			stb	r3,0x1A8C(r29)
		#Check If Already FF'ing
			lbz	r3,0x221A(r29)
			rlwinm.	r3,r3,0,28,28
			bne	WaveshineSDICheckToLCancel
		#Check If Falling
			lfs	f2,0x84(r29)
			lfs	f0, -0x76B0 (rtoc)
			fcmpo	cr0,f2,f0
			bge	WaveshineSDICheckToReset
		#Input Down to FF
			li	r3,-127
			stb	r3,0x1A8D(r29)		#Ananlog Y

		WaveshineSDICheckToLCancel:
		#Check If Under 5Mm Above Ground
			lfs	f2,0xB4(r29)
			lfs	f0,0x834(r29)		#Last Grounded Y Pos
			fsubs	f2,f2,f0		#Distance from Floor
			lfs	f0,0x10(r21)		#5 fp
			fcmpo	cr0,f2,f0		#If less than 5 Mm away, Input L Cancel
			bgt	WaveshineSDICheckToReset
			li	r3,0xC0		#Hit L
			stw	r3,0x1A88(r29)		#Held Buttons
			li	r3,0x1		#Set Start Waveshine Flag
			stb	r3,0x8(r31)
			b	WaveshineSDICheckToReset


		#Run Waveshine Code
		WaveshineSDIWaveshineThink:
			lwz	r3,0x10(r29)


		#Shine If In Wait
			cmpwi	r3,0xE
			bne	WaveshineSDICheckToJump
		#Check If First Shine Or FollowUp Shine
			lbz	r4,0x8(r31)
			cmpwi	r4,0x2
			beq	WaveshineSDIWaveshine_FollowOpponent
		#Input Shine
			li	r3,-127
			stb	r3,0x1A8D(r29)
			li	r3,0x200
			stw	r3,0x1A88(r29)
		#Set Flag as Mid-Waveshine
			li	r3,0x2
			stb	r3,0x8(r31)
		#Get JC Timing
			li	r3,3
			branchl	r12,HSD_Randi
			stb	r3,0x9(r31)
			b	WaveshineSDICheckToReset

		#Jump If In Shine Loop
		WaveshineSDICheckToJump:
		#Check
			#Check For Shine Loop
				cmpwi	r3,0x169
				bne	WaveshineSDICheckToAirdodge
			#Check For JC Frame
				lbz	r3,0x9(r31)		#Get JC Timing
				bl	IntToFloat
				lfs	f2,0x894(r29)
				fcmpo	cr0,f1,f2
				bne	WaveshineSDICheckToReset
			#Jump
				li	r3,0x400
				stw	r3,0x1A88(r29)
				b	WaveshineSDICheckToReset

		#Airdodge If In JumpF
		WaveshineSDICheckToAirdodge:
			cmpwi	r3,0x19
			bne	WaveshineSDIWaveshine_CheckIfFollowingOpponent
		#Get Random Airdodge Angle
			li	r3,30		#30 Different Angles
			branchl	r12,HSD_Randi
			addi	r3,r3,310		#Start at 310°
			bl	ComboTrainingDecideStickAngle_ConvertAngle
		#Joystick X = X Component * Facing Direction
			lfs	f1,0x2C(r29)
			fctiwz	f1,f1
			stfd	f1,0xF0(sp)
			lwz	r5,0xF4(sp)
			mullw	r3,r3,r5
			stb	r3,0x1A8C(r29)
		#Joystick Y = Y Component
			stb	r4,0x1A8D(r29)
		#Press L To Wavedash
			li	r3,0xC0
			stw	r3,0x1A88(r29)
			b	WaveshineSDICheckToReset

		WaveshineSDIWaveshine_CheckIfFollowingOpponent:
			cmpwi	r3,0xf		#Check if Walking
			blt	WaveshineSDICheckIfInTeeter
			cmpwi	r3,0x11		#Check if Walking
			bgt	WaveshineSDICheckIfInTeeter
			b	WaveshineSDIWaveshine_FollowOpponent

		WaveshineSDICheckIfInTeeter:
			cmpwi	r3,0xf5
			bne	WaveshineSDICheckToReset
			b	WaveshineSDIRestoreState

		WaveshineSDIWaveshine_FollowOpponent:
		#Determine Distance From Opponent
			lfs	f1,0xB0(r27)
			lfs	f2,0xB0(r29)
			fsubs	f1,f1,f2
			lfs	f2,-0x7414(rtoc)		#0f
			fcmpo	cr0,f1,f2
			bge	WaveshineSDIWaveshine_FollowOpponent_FacingRight

		WaveshineSDIWaveshine_FollowOpponent_FacingLeft:
		#Check If Close Enough To Shine
			lfs	f2,0x14(r21)
			fneg	f2,f2
			fcmpo	cr0,f1,f2
			blt	WaveshineSDIWaveshine_FollowOpponent_WalkTowards
			b	WaveshineSDIWaveshine_FollowOpponent_EnterShine
			#b	WaveshineSDIWaveshine_FollowOpponent_CheckMarth
		WaveshineSDIWaveshine_FollowOpponent_FacingRight:
			lfs	f2,0x14(r21)
			fcmpo	cr0,f1,f2
			bgt	WaveshineSDIWaveshine_FollowOpponent_WalkTowards
			b	WaveshineSDIWaveshine_FollowOpponent_EnterShine
		#Check Opponent
		WaveshineSDIWaveshine_FollowOpponent_CheckMarth:
			lwz	r3,0x4(r27)
			cmpwi	r3,0x12		#Marth
			beq	WaveshineSDIWaveshine_FollowOpponent_EnterGrab
		WaveshineSDIWaveshine_FollowOpponent_EnterShine:
			#Shine
				li	r3,-127
				stb	r3,0x1A8D(r29)
				li	r3,0x200
				stw	r3,0x1A88(r29)
			#Get JC Timing
				li	r3,3
				branchl	r12,HSD_Randi
				stb	r3,0x9(r31)
				b	WaveshineSDICheckToReset
		WaveshineSDIWaveshine_FollowOpponent_EnterGrab:
			li	r3,0x1C0
			stw	r3,0x1A88(r29)
			b	WaveshineSDICheckToReset
		WaveshineSDIWaveshine_FollowOpponent_WalkTowards:
		#Walk Towards Opponent
		#Stick Forward
			lfs	f1,0x2C(r29)
			fctiwz	f2,f1
			stfd	f2,0xF0(sp)
			lwz	r4,0xF4(sp)
			li	r3,127		#X Stick
			mullw	r3,r3,r4
			stb	r3,0x1A8C(r29)
		#Override Analog Smash Counter So Always Walking (Set Facing As Prev X Input)
			stfs	f1,0x620(r29)
			b	WaveshineSDICheckToReset


		#Initiate Reset Timer
			li	r3,120
			stw	r3,0xC(r31)

		#Check To Reset
		WaveshineSDICheckToReset:
			lwz	r3,0xC(r31)		#get timer	#Get Timer
			cmpwi	r3,0x0		#No Reset Timer Set Yet
			ble	WaveshineSDIThinkExit
		#Dec Timer
			subi	r3,r3,0x1
			stw	r3,0xC(r31)		#store timer
			cmpwi	r3,0x0		#Check if 0 now
			bne	WaveshineSDIThinkExit	#Exit If Not
		WaveshineSDIRestoreState:
		#Invert Facing Directions
			lwz	r4,0x10(r31)
			lwz	r5,0x18(r31)
			lfs	f1,0x2C(r4)
			fneg	f1,f1
			stfs	f1,0x2C(r4)
			lfs	f1,0x2C(r5)
			fneg	f1,f1
			stfs	f1,0x2C(r5)
			#Invert X Positions
			lfs	f1,0xB0(r4)
			fneg	f1,f1
			stfs	f1,0xB0(r4)
			lfs	f1,0xB0(r5)
			fneg	f1,f1
			stfs	f1,0xB0(r5)
		#Restore State
			addi r3,EventData,0x10
			bl	SaveState_Load
		#Reset Timer
			li	r3,60
			branchl	r12,HSD_Randi
			li	r4,0
			sub	r3,r4,r3
			stw	r3,0x4(r31)
		#Reset Mid-Waveshine Flag
			li	r3,0x0
			stb	r3,0x8(r31)

		WaveshineSDIThinkExit:
		restore
		blr

#################################

WaveshineSDI_Floats:
blrl
.long 0xC28C0000		#P1 X Position
.long 0xc2982e6c 	#P2 X Position
.long 0x38d1b717  #P1 Y Position
.long 0x38d1b717		#FD Floor Y Coord
.long 0x40A00000  #5fp
.long 0x40F00000  #Distance From Opponent to Waveshine
.long 0x42A00000  #X Coord To Stop

#################################

WaveshineSDILoadExit:
restore
blr







##################################################










#########################
## Event 16 HIJACK INFO ##
#########################

Event16:
#STORE STAGE
li	r3,0x20
sth	r3,0xE(r26)

li	r5,0xE		#Ice Climbers

#STORE CPU
bl	P2Struct
mflr	r3
lwz	r4,0x0(r29)
stw	r3,0x18(r4)		#p2 pointer
stb	r5,0x0(r3)		#make top tier p2
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)

#STORE THINK FUNCTION
bl	Event16Load
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	#########################
	## Event 16 LOAD FUNCT ##
	#########################
	Event16Load:
	blrl

	backup

	#Schedule Think
	bl	Event16Think
	mflr	r3
  li  r4,3
  li  r5,0
	bl	CreateEventThinkFunction

	b	Event16LoadExit


		##########################
		## Event 16 THINK FUNCT ##
		##########################


		Event16Think:
		blrl

    .set EventData,31
    .set P1Data,27
    .set P1GObj,28
    .set P2Data,29
    .set P2GObj,30

		backup

		#INIT FUNCTION VARIABLES
			lwz		EventData,0x2c(r3)			#backup data pointer in r31

      bl  GetAllPlayerPointers
      mr P1GObj,r3
      mr P1Data,r4
      mr P2GObj,r5
      mr P2Data,r6

		li	r3,0xF
		stw	r3,0x1A94(r29)
		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	Event16ThinkMain

				#Set Frame 1 As Over
					li		r3,0x1
					stb		r3,0x0(r31)
				#Set Facing Directions
					lis	r3,0x3f80
					stw	r3,0x2C(r29)
					lis	r3,0xBf80
					stw	r3,0x2C(r27)
				#Initlize Positions
					bl	Event16_Floats
					mflr	r3
					bl	Event_EnterGrab
        #Clear Inputs
          bl  RemoveFirstFrameInputs
				#Store Ground As Last Known Position
					lfs	f1, 0x00B4 (r29)
					stfs	f1, 0x0834 (r29)
				#Save State
					addi r3,EventData,0x10
					bl	SaveState_Save


		Event16ThinkMain:



		Event16ThinkExit:
		restore
		blr

#################################################

Event16_Floats:
blrl
.long 0x4144CCCD 	#P1 X Position
.long 0x00000000		#P1 Y Position
.long 0xC02CCCCD		#P2 X Position
.long 0x00000000		#P2 Y Position

#################################################

Event16LoadExit:
restore
blr

##################################################

























/*

#########################
## Event 16 HIJACK INFO ##
#########################

Event16:
#STORE STAGE
li	r3,0x20
sth	r3,0xE(r26)

li	r5,0x2		#Ice Climbers
li	r5,0x14

#STORE CPU
lwz	r4,0x0(r29)
bl	P2Struct
mflr	r3
stw	r3,0x18(r4)		#p2 pointer
stb	r5,0x0(r3)		#make top tier p2
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)


#STORE THINK FUNCTION
bl	Event16Load
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Event 16 LOAD FUNCT ##
	########################
	Event16Load:
	blrl

	backup

	#Schedule Think
	bl	Event16Think
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
	bl	CreateEventThinkFunction

	b	Event16LoadExit


		#########################
		## Event 16 THINK FUNCT ##
		#########################


		Event16Think:
			blrl
			backup

		#INIT FUNCTION VARIABLES
			lwz		r31,0x2c(r3)			#backup data pointer in r31

		#Get P2
			li		r3,0x1
			branchl		r12,PlayerBlock_LoadMainCharDataOffset			#get player block
			mr		r30,r3			#player block in r30
			lwz		r29,0x2c(r30)			#player data in r29

		#Get P1
			li		r3,0x0
			branchl		r12,PlayerBlock_LoadMainCharDataOffset			#get player block
			mr		r28,r3			#player block in r28
			lwz		r27,0x2c(r28)			#player data in r27

		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
			lbz	r3,0x0(r31)
			cmpwi	r3,0x0
			bne	Event16ThinkMain

				lbz	r3,0x221D(r29)
				rlwinm.	r3,r3,0,28,28
				bne	Event16ThinkExit

				#Set Frame 1 As Over
					li		r3,0x1
					stb		r3,0x0(r31)
				#Initlize Positions
					bl	Event16_Floats
					mflr	r3
					#bl	InitializePositions
        #Clear Inputs
          bl  RemoveFirstFrameInputs
				#Save State
					mr	r3,r31
					bl	SaveState_Save
				#Set Timer to -60
					li		r3,-60
					stw		r3,0x4(r31)



		Event16ThinkMain:
		Event16ThinkSequence:
		#Inc Timer
			lwz	r3,0x4(r31)
			addi	r3,r3,0x1
			stw	r3,0x4(r31)

		#Get Floats
			bl	Event16_Floats
			mflr	r21

		#L+DPad Controls CPU Percent
		bl	DPadCPUPercent

		#Check If Already in A Recovery Mode
			lbz	r3,0x8(r31)
			cmpwi	r3,0x1
			beq	Event16CheckRecoveryFlag

		#Check If CPU Is Offstage
			mr	r3,r29
			branchl	r12,0x800a2c80
			cmpwi	r3,0x0
			beq	Event16CheckRecoveryFlag

			#Check If Still in Hitstun
				lbz	r3,0x221C(r29)
				rlwinm.	r3,r3,0,30,30
				bne	Event16CheckRecoveryFlag

			#Check If Below Ledge
			#Hold Towards Ledge

				#Get Random Recovery Option
				Event16GetRandomRecovery:
					li	r3,3		#Number of Recovery Options (Side B Immediately,Jump Then Side B, ShineStall-Jump-SideB)
					branchl	r12,HSD_Randi
					cmpwi	r3,0x0
					bne	Event16StoreRecoveryType
				#Check If Can Side B Only
					#Check If Above Ledge
						lfs	f1,0xB4(r29)	#Get Y Coord
						#lfs	f2,0x10(r21)
						#fcmpo	cr0,f1,f2
						#bgt	Event16GetRandomRecovery
						#lfs	f2,0x10(r21)
					#Check If Below Ledge
						lfs	f2,0x14(r21)
						fcmpo	cr0,f1,f2
						blt	Event16GetRandomRecovery

				Event16StoreRecoveryType:
					stb	r3,0x9(r31)
				#Init Recovery Flag
					li	r3,0x1
					stb	r3,0x8(r31)


		Event16CheckRecoveryFlag:
		#Check Recovery Flag
			lbz	r3,0x8(r31)
			cmpwi	r3,0x0
			beq	Event16CheckToReset

#******************************************************************#

#IsRecovering

		#If Timer Is Set, Dont Run Any of This
		lwz	r3,0xC(r31)		#get timer	#Get Timer
		cmpwi	r3,0x0		#No Reset Timer Set Yet
		bgt	Event16GetRecoveryID

		#Hold Towards Stage
		li	r3,127
		lfs	f0,0x00B0 (r29)	#X Pos
		lfs	f1,0x1ADC (r29) #Last Grounded X Pos
		fcmpo	cr0,f1,f0
		bgt	Event16HoldTowardsRight
		neg	r3,r3
		Event16HoldTowardsRight:
		stb	r3,0x1A8C(r29)

			#Check If Died
			lbz	r3,0x221F(r29)
			rlwinm.	r3,r3,0,25,25
			bne	Event16SideBThink_Reset

			#Check If In Hitlag
			#Recover again
			lbz	r3,0x221A(r29)
			rlwinm.	r3,r3,0,26,26
			bne	Event16RecoverAgain

			#Check If Made It Back
			#Check Ground Flag
			lwz	r3,0xE0(r29)
			cmpwi	r3,0x0
			beq	Event16SideBThink_Reset
			#Check CliffCatch
			lwz	r3,0x10(r29)
			cmpwi	r3,0xFC
			beq	Event16SideBThink_Reset

			b	Event16GetRecoveryID

			Event16RecoverAgain:
			#Recover Again
			li	r3,0x0
			stb	r3,0x8(r31)
			stb	r3,0x9(r31)
			b	Event16CheckToReset

			Event16SideBThink_Reset:
			#Set Timer
			lwz	r3,0xC(r31)		#get timer	#Get Timer
			cmpwi	r3,0x0		#No Reset Timer Set Yet
			bgt	Event16CheckToReset	#Reset Timer Set
			li	r3,30
			stw	r3,0xC(r31)		#Store Reset Timer
			b	Event16CheckToReset

		#Run Recovery Think
		#Get Which Recovery To Perform
		Event16GetRecoveryID:
		lbz	r3,0x9(r31)
		cmpwi	r3,0x0
		beq	Event16SideBOnly
		cmpwi	r3,0x1
		beq	Event16JumpSideB
		cmpwi	r3,0x2
		beq	Event16SSJumpSideB
		cmpwi	r3,0x3
		beq	Event16SideBThink

	#*************************************************#

		Event16SideBOnly:
		#Be in ledge Y range, Check if next frame will be out of Y range
			bl	Event16CheckIfLineUpWithLedge
			cmpwi	r3,-1			#Not In Range Yet
			beq	Event16CheckToReset
			cmpwi	r3,0x0
			beq	Event16ChanceToInputSideB

		#If OoRange Next Frame + Descending, Side B Immediately
			lfs	f0, -0x7208 (rtoc)
			lfs	f1,0xCC(r29)
			fcmpo	cr0,f1,f0
			blt	Event16InputSideB

			Event16ChanceToInputSideB:
			li	r3,5
			branchl	r12,HSD_Randi
			cmpwi	r3,0x0
			beq	Event16InputSideB
			b	Event16CheckToReset

			Event16InputSideB:
				#Joystick X = 120 * Facing Direction
				lfs	f1,0x2C(r29)
				fctiwz	f1,f1
				stfd	f1,0xF0(sp)
				lwz	r4,0xF4(sp)
				li	r3,120		#X Stick
				mullw	r3,r3,r4
				stb	r3,0x1A8C(r29)
				li	r3,0x200
				stw	r3,0x1A88(r29)
				#li	r3,0x0
				#stb	r3,0x8(r31)

				#Change State to Mid-Side B
				li	r3,3
				stb	r3,0x9(r31)
				b	Event16CheckToReset

	#*************************************************#

		Event16JumpSideB:
		#Be above bottom most coord, Check if next frame will be out of Y range
		#Be in ledge Y range, Check if next frame will be out of Y range

		#Check If Above Bottom-most
		lfs	f1,0xB4(r29)	#Get Next Frames Y Coord
		lfs	f2,0x84(r29)
		fadds	f1,f1,f2
		lfs	f2,0x18(r21)	#Get Bottom Y Coord
		fcmpo	cr0,f1,f2
		blt	Event16JumpSideB_Jump

		Event16JumpSideB_ChanceToJump:
		li	r3,20		#1 in 4 Chance
		branchl	r12,HSD_Randi
		cmpwi	r3,0x0
		beq	Event16JumpSideB_Jump
		b	Event16CheckToReset

		Event16JumpSideB_Jump:
		li	r3,0x800
		stw	r3,0x1A88(r29)
		#Advance to Next State
		li	r3,0x0
		stb	r3,0x9(r31)
		b	Event16CheckToReset

	#*************************************************#

		Event16SSJumpSideB:
		#Hold Down B
		#Be above bottom most coord, Check if next frame will be out of Y range
		#Be in ledge Y range, Check if next frame will be out of Y range

		#Always Hold Down B
		li	r3,-127
		stb	r3,0x1A8D(r29)
		li	r3,0x200
		stw	r3,0x1A88(r29)

		#Wait Until in Shine Loop
		lwz	r3,0x10(r29)
		cmpwi	r3,0x16E
		bne	Event16CheckToReset

		#Check If Above Bottom-most
		lfs	f1,0xB4(r29)	#Get Next Frames Y Coord
		lfs	f2,0x84(r29)
		fadds	f1,f1,f2
		lfs	f2,0x18(r21)	#Get Bottom Y Coord
		fcmpo	cr0,f1,f2
		blt	Event16SSJumpSideB_Jump

		Event16SSJumpSideB_ChanceToJump:
		li	r3,15		#1 in 6 Chance
		branchl	r12,HSD_Randi
		cmpwi	r3,0x0
		beq	Event16SSJumpSideB_Jump
		b	Event16CheckToReset

		Event16SSJumpSideB_Jump:
		li	r3,0x800
		stw	r3,0x1A88(r29)
		#Advance to Next State
		li	r3,0x0
		stb	r3,0x9(r31)
		b	Event16CheckToReset

	#*************************************************#

		Event16SideBThink:

		b	Event16CheckToReset

	#*************************************************#

		#Check To Reset
		Event16CheckToReset:
			lwz	r3,0xC(r31)		#Get Timer
			cmpwi	r3,0x0		#No Reset Timer Set Yet
			ble	Event16ThinkExit
		#Dec Timer
			subi	r3,r3,0x1
			stw	r3,0xC(r31)		#store timer
			cmpwi	r3,0x0		#Check if 0 now
			bne	Event16ThinkExit	#Exit If Not
		Event16RestoreState:
		#Restore State
			mr	r3,r31
			bl	SaveState_Load
		#Reset Timer
			li	r3,60
			branchl	r12,HSD_Randi
			li	r4,0
			sub	r3,r4,r3
			stw	r3,0x4(r31)
			li	r3,0x0
			stb	r3,0x8(r31)

		Event16ThinkExit:
		restore
		blr

#################################

Event16_Floats:
blrl
.long 0xC28C0000		#P1 X Position
.long 0xc2982e6c 	#P2 X Position
.long 0x38d1b717  #P1 Y Position
.long 0x38d1b717		#FD Floor Y Coord
.long 0x40A00000		#Top Most Y Value = -5
.long 0xC1700000	 #Bottom-most Y Value = -15
.long 0xC25C0000		#Shine Stall Bottom Most Coord

#################################

Event16CheckIfLineUpWithLedge:
#-1 = Not In Any Range Yet
#0 = In Range This And Next Frame
#1 = In Range This but NOT Next Frame

#Check If In Range This Frame
lfs	f1,0xB4(r29)	#Get Y Coord
lfs	f2,0x10(r21)
fcmpo	cr0,f1,f2
bgt	Event16CheckIfLineUpWithLedge_NotInRange
lfs	f2,0x14(r21)
fcmpo	cr0,f1,f2
blt	Event16CheckIfLineUpWithLedge_NotInRange

Event16CheckIfLineUpWithLedge_CheckNextFrame:
#Check If Out Of Range Next Range
lfs	f1,0xB4(r29)	#Get Y Coord
lfs	f2,0x84(r29)	#Get Y Vel
fadds	f1,f1,f2	    #Get Next Frames Position
#Check If Will Be Above Ledge Next Frame
lfs	f2,0x10(r21)
fcmpo	cr0,f1,f2
bgt	Event16CheckIfLineUpWithLedge_OutOfRangeNextFrame
lfs	f2,0x10(r21)
#Check If Will Be Below Ledge Next Frame
lfs	f2,0x14(r21)
fcmpo	cr0,f1,f2
blt	Event16CheckIfLineUpWithLedge_OutOfRangeNextFrame
b	Event16CheckIfLineUpWithLedge_InRangeThisAndNextFrame

Event16CheckIfLineUpWithLedge_NotInRange:
li	r3,-1
b	Event16CheckIfLineUpWithLedge_Exit
Event16CheckIfLineUpWithLedge_InRangeThisAndNextFrame:
li	r3,0x0
b	Event16CheckIfLineUpWithLedge_Exit
Event16CheckIfLineUpWithLedge_OutOfRangeNextFrame:
li	r3,0x1

Event16CheckIfLineUpWithLedge_Exit:
blr

#################################


Event16LoadExit:
restore
blr


*/

/*
#########################
## Shield Drop HIJACK INFO ##
#########################

ShieldDrop:
#STORE STAGE
li	r3,0x20
sth	r3,0xE(r26)

#STORE CPU
lwz	r4,0x0(r29)
bl	P2Struct
mflr	r3
stw	r3,0x18(r4)		#p2 pointer
li	r5,0x2		#fox ext ID
stb	r5,0x0(r3)		#make fox p2
li	r5,0x1		#make CPU controlled
stb	r5,0x1(r3)

#SPAWN 2 PLAYERS
li	r3,0x40
stb	r3,0x1(r4)


#STORE THINK FUNCTION
bl	ShieldDropLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Shield Drop LOAD FUNCT ##
	########################
	ShieldDropLoad:
	blrl

	backup

	#Schedule Think
	bl	ShieldDropThink
	mflr	r3
	li	r4,3		#Priority (After Interrupt)
	bl	CreateEventThinkFunction

	b	ShieldDropLoadExit


		#########################
		## Shield Drop THINK FUNCT ##
		#########################


		ShieldDropThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		r31,0x2c(r3)			#backup data pointer in r31

		#Get P2
		li		r3,0x1
		branchl		r12,PlayerBlock_LoadMainCharDataOffset			#get player block
		mr		r30,r3			#player block in r30
		lwz		r29,0x2c(r30)			#player data in r29

		#Get P1
		li		r3,0x0
		branchl		r12,PlayerBlock_LoadMainCharDataOffset			#get player block
		mr		r28,r3			#player block in r28
		lwz		r27,0x2c(r28)			#player data in r27

		bl	StoreCPUTypeAndZeroInputs


		#ON FIRST FRAME
		lbz	r3,0x0(r31)
		cmpwi	r3,0x0
		bne	ShieldDropThinkMain

			lbz	r3,0x221D(r29)
			rlwinm.	r3,r3,0,28,28
			bne	ShieldDropThinkExit

			#Set Frame 1 As Over
			li		r3,0x1
			stb		r3,0x0(r31)
			bl		ShieldDrop_InitializePositions
			mr		r3,r31
			bl		SaveState_Save



		ShieldDropThinkMain:
		bl	GiveFullShields

		ShieldDropThinkSequence:
		#Get Floats and Frame Info
		bl	ShieldDropFloats
		mflr	r21		#Get Floats
		lwz	r20,0x4(r31)		#Get State
		lfs	f1,0x894(r29)
		fctiwz	f1,f1
		stfd	f1,0xF0(sp)
		lwz	r24,0xF4(sp)		#Frame Number in r24

		#Get Distance and Direction
		#f1 = distance
		#r22= towards direction
		#r23= away direction
		lfs	f1,0xB0(r27)
		lfs	f2,0xB0(r29)
		fsubs	f1,f1,f2
		lfs	f0, -0x6768 (rtoc)
		fcmpo	cr0,f1,f0
		bgt	ShieldDropRight
		ShieldDropLeft:
		li	r22,-127
		li	r23,127
		b	ShieldDropCheckState
		ShieldDropRight:
		li	r22,127
		li	r23,-127

		ShieldDropCheckState:
		#When DDing, Move In Facing Direction
		cmpwi	r20,0x1
		bne	ShieldDrop_SkipHoldForward
		lfs	f2,0x2C(r29)
		fctiwz	f2,f2
		stfd	f2,0xF0(sp)
		lwz	r3,0xF4(sp)		#Facing direction as int
		mulli	r3,r3,127
		stb	r3,0x1A8C(r29)		#Move Towards

		ShieldDrop_SkipHoldForward:
		fabs	f1,f1		#abs distance
		cmpwi	r20,0x0
		beq	ShieldDropDashDanceStart
		cmpwi	r20,0x1
		beq	ShieldDropDashDanceThink
		cmpwi	r20,0x2
		beq	ShieldDropJumpThink
		cmpwi	r20,0x3
		beq	ShieldDropLCancelThink
		cmpwi	r20,0x4
		beq	ShieldDropInvincibleThink


		ShieldDropDashDanceStart:
			stb	r23,0x1A8C(r29)		#Move Away
			li	r3,0x1		 #Enter DDThink
			stw	r3,0x4(r31)
			b	ShieldDropThinkExit

		ShieldDropDashDanceThink:
			#Check If Too Close
			ShieldDropDashDanceThink_CheckIfTooClose:
			lfs	f2,0x0(r21)
			fcmpo	cr0,f1,f2
			bgt	ShieldDropDashDanceThink_CheckIfTooFar
			stb	r23,0x1A8C(r29)		#Move Away
			b	ShieldDropThinkExit
			ShieldDropDashDanceThink_CheckIfTooFar:
			lfs	f2,0x4(r21)
			fcmpo	cr0,f1,f2
			blt	ShieldDropDashDanceThink_CheckToAttack
			stb	r22,0x1A8C(r29)		#Move Towards
			b	ShieldDropThinkExit

			ShieldDropDashDanceThink_CheckToAttack:
			lfs	f2,0x8(r21)
			fcmpo	cr0,f1,f2
			bgt	ShieldDropDashDanceThink_CheckToChangeDirection
			ShieldDropDashDanceThink_CheckIfFacingOpponent:
			lfs	f2,0x2C(r29)
			fctiwz	f2,f2
			stfd	f2,0xF0(sp)
			lwz	r3,0xF4(sp)		#Facing direction as int
			cmpwi	r3,0x0
			blt	ShieldDropDashDanceThink_FacingLeft
			ShieldDropDashDanceThink_FacingRight:
			cmpwi	r22,0x0
			bgt	ShieldDropDashDanceThink_FacingOpponent
			b	ShieldDropDashDanceThink_NotFacingOpponent
			ShieldDropDashDanceThink_FacingLeft:
			cmpwi	r22,0x0
			blt	ShieldDropDashDanceThink_FacingOpponent
			b	ShieldDropDashDanceThink_NotFacingOpponent
			ShieldDropDashDanceThink_FacingOpponent:
			li	r3,0x1
			b	0x8
			ShieldDropDashDanceThink_NotFacingOpponent:
			li	r3,0x0
			cmpwi	r3,0x0
			beq	ShieldDropDashDanceThink_CheckToChangeDirection
			#RNG Chance To Attack
			li	r3,20
			branchl	r12,HSD_Randi
			cmpwi	r3,0x0
			bne	ShieldDropDashDanceThink_CheckToChangeDirection
			li	r3,0x400		#X Button
			stw	r3,0x1A88(r29)		#Held Buttons
			li	r3,0x2		#JumpThink
			stw	r3,0x4(r31)
			b	ShieldDropThinkExit


		ShieldDropDashDanceThink_CheckToChangeDirection:
		#Move if in Wait
		lwz	r3,0x10(r29)
		cmpwi	r3,0xE
		beq	ShieldDropDashDanceThink_ChangeDirection
		#At least frame 3 of dash
		cmpwi	r24,6
		blt	ShieldDropThinkExit
		cmpwi	r24,11
		bge	ShieldDropDashDanceThink_ChangeDirection
		#RNG Chance To ChangeDirection
		li	r3,7
		branchl	r12,HSD_Randi
		cmpwi	r3,0x0
		bne	ShieldDropThinkExit
		ShieldDropDashDanceThink_ChangeDirection:
		lfs	f2,0x2C(r29)
		fctiwz	f2,f2
		stfd	f2,0xF0(sp)
		lwz	r3,0xF4(sp)		#Facing direction as int
		mulli	r3,r3,127
		mulli	r3,r3,-1
		stb	r3,0x1A8C(r29)		#Move Away
		b	ShieldDropThinkExit

		ShieldDropJumpThink:
		lwz	r3,0xE0(r29)
		cmpwi	r3,0x0
		beq	ShieldDropThinkExit
		li	r3,0x100		#A Button
		stw	r3,0x1A88(r29)		#Held Buttons
		li	r3,0x3		#LCancelThink
		stw	r3,0x4(r31)
		b	ShieldDropThinkExit

		ShieldDropLCancelThink:
		ShieldDropLCancelInputFF:
		lfs	f2,0x84(r29)
		lfs	f0, -0x76B0 (rtoc)
		fcmpo	cr0,f2,f0
		bge	ShieldDropThinkExit
		#Input Down to FF
		li	r3,-127
		stb	r3,0x1A8D(r29)		#Ananlog Y
		#Check If Under 5Mm Above Ground
		lfs	f2,0xB4(r29)
		lfs	f0,0xC(r21)
		fcmpo	cr0,f2,f0
		bgt	ShieldDropThinkExit
		li	r3,0xC0		#Hit L
		stw	r3,0x1A88(r29)		#Held Buttons
		#Enter InvincibleThink + Init Counter
		li	r3,0x4		#State
		stw	r3,0x4(r31)
		li	r3,60
		stw	r3,0x8(r31)		#Counter
		b	ShieldDropThinkExit

		ShieldDropInvincibleThink:
		#Dec Counter And Check To Restore
		lwz	r3,0x8(r31)
		subi	r3,r3,0x1
		stw	r3,0x8(r31)
		cmpwi	r3,0x0
		bgt	ShieldDrop_CheckToMakeInvincible
		#Reset State ID
		li	r3,0x0
		stw	r3,0x4(r31)
		#Restore Savestate
		mr	r3,r31
		bl	SaveState_Load
		b	ShieldDropThinkExit
		ShieldDrop_CheckToMakeInvincible:
		lwz	r3,0x10(r29)
		cmpwi	r3,0xE
		#bne	ShieldDropThinkExit
		#Make Invincible
		#mr	r3,r30
		#li	r4,0x2
		#branchl	r12,ApplyInvincibility
		#b	ShieldDropThinkExit


		#Multishine
		mr	r3,r29
		bl	CPUActions_MultiShine
		b	ShieldDropThinkExit

		ShieldDropThinkExit:
		restore
		blr


##########################

ShieldDropFloats:
blrl
.long 0x41A00000 #no closer than this
.long 0x42180000 #no further than this
.long 0x41C80000 #at least this close to jump
.long 0x40000000 #below this Y coord to L Cancel
.long 0xC02CCCCD		#P1 X Position
.long 0x4144CCCD		#P2 X Position

#################################

ShieldDrop_InitializePositions:
backup

#P1 @ -2.7
#P2 @ 12.3

#Get Floats
bl	ShieldDropFloats
mflr	r20

#Move P1
mr	r3,r28
branchl	r12,0x8008a2bc		#Enter Wait
lfs	f1,0x10(r20)
stfs	f1,0xB0(r27)
mr	r3,r28
bl  UpdatePosition

#Move P2
mr	r3,r30
branchl	r12,0x8008a2bc		#Enter Wait
lfs	f1,0x14(r20)
stfs	f1,0xB0(r29)
mr	r3,r30
bl  UpdatePosition

restore
blr

###################################

ShieldDropLoadExit:
restore
blr

*/















































































/*

#########################
## Eggs-ercise HIJACK INFO ##
#########################

Eggs:
#STORE THINK FUNCTION
bl	EggsLoad
mflr	r3
stw	r3,0x44(r26)		#on match load

b	exit

	########################
	## Eggs-ercise LOAD FUNCT ##
	########################
	EggsLoad:
	blrl

	backup

	#Schedule Think
	bl	EggsThink
	mflr	r3
	bl	CreateEventThinkFunction

	b	EggsLoadExit


		#########################
		## Eggs-ercise THINK FUNCT ##
		#########################


		EggsThink:
		blrl
		backup



		EggsThinkExit:
		restore
		blr


EggsLoadExit:
restore
blr

*/

####################################################

###############
## P1 STRUCT ##
###############
P1Struct:
blrl

.long 0x01000202 #external char, player type, stocks, costume
.long 0xff000400 #spawn point, subcolor,team,voice pitch
.long 0x00040700 #player flag
.long 0x00000000 #level and starting %
.long 0x3f800000 #attk ratio
.long 0x3f800000 #def ratio
.long 0x3f800000 #model scale

###############
## P2 STRUCT ##
###############
P2Struct:
blrl

.long 0x01010202 #external char, player type, stocks, costume
.long 0xff000400 #spawn point, subcolor,team,voice pitch
.long 0x00040700 #player flag
.long 0x00000000 #level and starting %
.long 0x3f800000 #attk ratio
.long 0x3f800000 #def ratio
.long 0x3f800000 #model scale


###########################
## Create Think Function ##
###########################
CreateEventThinkFunction:

#in
#r3 = function to run each frame
#r4 = priority
#r5 = pointer to Window and Option Count
#r6 = pointer to ASCII struct

.set WindowOptionCount,31
.set ASCIIStruct,30
.set EventGObj,29
.set EventData,28
.set MenuGObj,27
.set MenuData,26
.set Priority,25
.set Function,24

#Offsets
.set DataspaceSize,0x50
.set MenuDataPointer,(DataspaceSize-0x4)
.set EventDataPointer,(DataspaceSize-0x4)
.set WindowOptionCountPointer,0x0
.set ASCIIStructPointer,0x4
.set OptionMenuMemory,0x8

backup

mr	Function,r3
mr	Priority,r4
mr  WindowOptionCount,r5
mr  ASCIIStruct,r6

########################
## Create Event Think ##
########################

#Create GObj
  li	r3,6		#GObj Type
  li	r4,7		#On-Pause Function
  li	r5,80
  branchl	r12,GObj_Create

#Backup Allocation
  mr	EventGObj,r3

#Schedule Task
  mr	r4,Function
  mr	r5,Priority
  branchl	r12,SchedulePerFrameProcess

#Give Task Some Data Space
  li	r3,DataspaceSize		#50 bytes of space
  branchl	r12,HSD_MemAlloc		#HSD_MemAlloc
  mr	EventData,r3

#Initalize GObj
  mr	r6,r3
  mr	r3,EventGObj		#task space
  li	r4,0x0		#typedef
  load	r5,HSD_Free		#destructor (HSD_Free)
  branchl	r12,GObj_Initialize		#Create Data Block

#Zero Dataspace
  mr	r3,EventData
  li	r4,DataspaceSize
  branchl	r12,ZeroAreaLength		#zero length

##############################
## Create Option Menu Think ##
##############################

#Check if Option Menu is enabled for this event
  cmpwi WindowOptionCount,0
  beq CreateEventThinkFunction_Exit

#Create GObj
  li	r3,6		#GObj Type
  li	r4,0		#On-Pause Function
  li	r5,80
  branchl	r12,GObj_Create

#Backup Allocation
  mr	MenuGObj,r3

#Schedule Task
  bl  OptionMenuThink
  mflr r4
  li	r5,22          #Last Function to Run
  branchl	r12,SchedulePerFrameProcess

#Give Task Some Data Space
  li	r3,DataspaceSize		#50 bytes of space
  branchl	r12,HSD_MemAlloc		#HSD_MemAlloc
  mr	MenuData,r3

#Initalize GObj
  mr	r6,MenuData
  mr	r3,MenuGObj		#task space
  li	r4,0x0	    	#typedef
  load	r5,HSD_Free		#destructor (HSD_Free)
  branchl	r12,GObj_Initialize		#Create Data Block

#Zero Dataspace
  mr	r3,MenuData
  li	r4,DataspaceSize
  branchl	r12,ZeroAreaLength		#zero length

#Store Option Menu info to Dataspace
  stw WindowOptionCount,WindowOptionCountPointer(MenuData)
  stw ASCIIStruct,ASCIIStructPointer(MenuData)

#Store Pointers to Each Other
  stw MenuData,MenuDataPointer(EventData)
  stw EventData,EventDataPointer(MenuData)

CreateEventThinkFunction_Exit:
restore
blr

####################################
## Create Option Menu When Paused ##
####################################

OptionMenuThink:
blrl

.set MenuData,31
.set OptionMenuToggled,0x28

backup

#Load Data Pointer
  lwz MenuData,0x2C(r3)

#Check If Paused
  li  r3,1
  branchl r12,DevelopMode_FrameAdvanceCheck
  cmpwi r3,0x2
  bne OptionMenuThink_Exit

#Run OptionThink Code
OptionMenuThink_CheckInputs:
  addi r3,MenuData,OptionMenuMemory
  lwz r4,WindowOptionCountPointer(MenuData)
  lwz r5,ASCIIStructPointer(MenuData)
  bl	OptionWindow

#Store Modified Option Bool
  cmpwi r3,0
  beq OptionMenuThink_Exit
  addi r5,MenuData,OptionMenuToggled
  stbx r3,r4,r5

OptionMenuThink_Exit:
restore
blr

##########################
## Clear Option Toggled ##
##########################

ClearToggledOptions:

#in
#r3 = Menu Data

#Get Amount of Options
  lwz r4,WindowOptionCountPointer(r3)
  lbz r4,0x0(r4)

#Loop Through All Data
  addi r3,r3,OptionMenuToggled
  li  r5,0

ClearToggledOptions_Loop:
  stbx r5,r3,r4     #Zero Byte
  subi r4,r4,1
  cmpwi r4,0
  bge ClearToggledOptions_Loop

ClearToggledOptions_Exit:
  blr

######################
## Save States Main ##
######################


#0x0 -> 0x23EC = player block
#0x23EC -> 0x24EC = Static Block
#0x24EC = Camera Flag






################################
## Save State Quick Functions ##
################################

SaveState_Save:
	backup

	#Backup Task Data
	mr	r31,r3

	#Save Camera Info Here

	#Count Players in Match
	branchl	r3,0x8016b558

	#Move Player Number to r30
	mr	r30,r3

	#Init Save Loop
	li	r29,0x0		#player ID
	li	r23,0x0		#main/sub char bool

		SaveState_SaveLoop:
		#Get This Player's Backup Pointer in r28
		mulli		r4,r29,0x8		#8 bytes per player pointer
		add		r28,r4,r31		#r28 contains this players block backup

		#Check If Backup Exists
		cmpwi		r23,0x0
		beq		SaveState_Save_MainChar
		SaveState_Save_SubChar:
		lwz 		r3,0x4(r28)		#get pointer to backup if it exists
		b		SaveState_Save_CheckIfExists
		SaveState_Save_MainChar:
		lwz 		r3,0x0(r28)		#get pointer to backup if it exists
		SaveState_Save_CheckIfExists:
		cmpwi		r3,0x0
		beq		SaveState_SaveStart

		#Remove Old Backup (HSD_Free)
		branchl		r12,HSD_Free



		SaveState_SaveStart:

		#Get Proper Player Data
		mr		r3,r29
		mr		r4,r23
		bl		SaveState_GetPlayerDataPointer		#returns player slot,player pointer and player data
		cmpwi		r3,0xFF				#check if player didnt exist
		beq		SaveState_SaveLoopInc				#move on with loop
		mr		r22,r3				#r22 contains actual player slot
		mr		r26,r5				#r26 contains real player block

		#Get Player Data Length
		SaveState_Save_GetPlayerBlockLength:
		load		r3,0x80458fd0
		lwz    		r25,0x20(r3)			#get player block length in r25
		mr		r3,r25
		addi		r3,r3,0x100			#add static block length
		addi		r3,r3,0x10			#add additional storage
		branchl		r12,HSD_MemAlloc			#HSD_MemAlloc

		#Store Pointer To Task Struct
		cmpwi		r23,0x0
		bne		Savestate_Save_StoreBackupSubChar
		stw		r3,0x0(r28)
		b		Savestate_Save_StoreBackupEnd
		Savestate_Save_StoreBackupSubChar:
		stw		r3,0x4(r28)
		Savestate_Save_StoreBackupEnd:
		mr		r27,r3				#r27 contains playerblock backup

		#Copy Player Block to Backup
		mr		r3,r27			#r3 = destination to copy to
		mr		r4,r26			#r4 = source
		mr 		r5,r25			#r5 = playerblock length
		branchl		r12,memcpy			#mempcy


		#Copy Static Block to Backup
		add		r3,r25,r27			#get end of playerblock in r4
		load		r4,0x80453080			#get static block in r4
		li		r5,0xE90
		mullw		r5,r5,r22
		add		r4,r4,r5
		li		r5,0x100			#only copying the first 100 bytes
		branchl		r12,memcpy			#mempcy

		#Save Camera Flag
		lwz		r3,0x890(r26)
		lwz		r3,0x8(r3)
		add		r4,r25,r27		#get end of player block in r4
		addi		r4,r4,0x100		#get end of static block
		stw		r3,0x0(r4)		#store to end of block

		SaveState_SaveLoopInc:
		#Check For Subchar Before Looping
		cmpwi		r23,0x1
		beq		SaveState_SaveLoopInc_ToggleSubCharOff
		li		r23,0x1
		b		SaveState_SaveLoop

		SaveState_SaveLoopInc_ToggleSubCharOff:
		li		r23,0x0
		addi		r29,r29,0x1
		cmpw		r29,r30
		blt		SaveState_SaveLoop

	restore
	blr

SaveState_Load:
	backup

	mr	r31,r3

	#Count Players in Match
	branchl	r3,0x8016b558

	#Move Player Number to r30
	mr	r30,r3

	#Restore Camera Info Here


	#Init Load Loop
	li	r29,0x0		#player count
	li	r23,0x0		#main/subchar bool

		SaveState_LoadLoop:
		#Get This Player's Backup Pointer in r28
		mulli		r4,r29,0x8		#8 bytes per player pointer
		add		r28,r4,r31		#r28 contains this players block backup

		#Check If Backup Exists
		cmpwi		r23,0x0
		beq		SaveState_Load_MainChar
		SaveState_Load_SubChar:
		lwz 		r3,0x4(r28)		#get pointer to backup if it exists
		b		SaveState_Load_CheckIfExists
		SaveState_Load_MainChar:
		lwz 		r3,0x0(r28)		#get pointer to backup if it exists
		SaveState_Load_CheckIfExists:
		cmpwi		r3,0x0
		beq		SaveState_LoadLoopInc


		SaveState_LoadStart:

		#Get Proper Player Data
		mr		r3,r29
		mr		r4,r23
		bl		SaveState_GetPlayerDataPointer		#returns player slot,player pointer and player data
		cmpwi		r3,0xFF				#check if player didnt exist
		beq		SaveState_LoadLoopInc				#move on with loop
		mr		r22,r3				#r22 contains actual player slot
		mr		r25,r4				#r25 contains external player
		mr		r26,r5				#r26 contains real player block

		#Get Player Block Length in r24
		SaveState_Load_GetPlayerBlockLength:
		load		r24,0x80458fd0
		lwz    		r24,0x20(r24)		#r24 = length

		#Get Pointer From Task Struct
		cmpwi		r23,0x0		#check if subcharacter
		beq		Savestate_Load_GetBackupMainChar
		Savestate_Load_GetBackupSubChar:
		lwz		r27,0x4(r28)		#r27 contains playerblock backup
		b		Savestate_Load_RestoreFacingDirection
		Savestate_Load_GetBackupMainChar:
		lwz		r27,0x0(r28)		#r27 contains playerblock backup

		#Restore Facing Direction
		Savestate_Load_RestoreFacingDirection:
		lwz		r3,0x2C(r27)		#backed up Facing Direction
		stw		r3,0x2C(r26)

		#Enter Into Sleep
		mr		r3,r25
		li		r4,0x1
		branchl		r12,AS_Sleep

		#Remove On Death Function Pointer
		li		r3,0x0
		stw		r3,0x21E4(r26)
		stw		r3,0x21E8(r26)

		#Enter Into Backed Up State
		mr		r3,r25
		lwz		r4,0x10(r27)		#backed up AS
		li		r5,0x0
		li		r6,0x0
		lfs		f1,0x894(r27)		#backed up Frame Number
		lfs		f2,0x89C(r27)		#backed up Frame Speed
		lfs		f3,0x8A4(r27)		#backup up Blend Amount
		branchl		r12,ActionStateChange		#ASC

		#Keep Previous Frame Buttons From Current Block
		lwz		r3,0x620(r26)
		stw		r3,0xD0(sp)
		lwz		r3,0x624(r26)
		stw		r3,0xD4(sp)
		lwz		r3,0x65C(r26)
		stw		r3,0xD8(sp)

		#Keep Collision Bubble Toggles
		lwz		r3,0x21FC(r26)
		stw		r3,0xDC(sp)

		#Copy PlayerBlock Backup to Real
		mr		r3,r26
		mr		r4,r27
		mr		r5,r24
		branchl		r12,memcpy	#mempcy

		#Copy Static Block Backup to Real
		load		r3,0x80453080			#get static block in r3
		li		r4,0xE90
		mullw		r4,r4,r22
		add		r3,r3,r4
		add		r4,r24,r27			#get end of block in r4
		li		r5,0x100			#length is 0x100
		branchl		r12,memcpy			#mempcy

		#Restore Previous Frame Buttons From Current Block
		lwz		r3,0xD0(sp)
		stw		r3,0x620(r26)
		stw		r3,0x628(r26)
		lwz		r3,0xD4(sp)
		stw		r3,0x624(r26)
		stw		r3,0x62C(r26)
		lwz		r3,0xD8(sp)
		stw		r3,0x65C(r26)
		stw		r3,0x660(r26)
		stw		r3,0x664(r26)

		#Restore Collision Bubble Toggles
		lwz		r3,0xDC(sp)
		stw		r3,0x21FC(r26)

		#Remove Cached Animation Pointer (This fixes the Fall Animation Bug)
		li	r3,0x0
		stw	r3,0x5A8(r26)

    #Update ECB Position
		mr		r3,r25
		bl  UpdatePosition

    #Check For Ground
    #mr r3,r25
    #branchl r12,0x80082a68

    #Remove Respawn Platform JObj Pointer and Think Function
    li  r3,0
    stw r3,0x20A0(r26)
    stw r3,0x21B0(r26)

		/* #Removing this, causes ground issues when restoring. instead im removing the OSReport call for the error
		#If Grounded, Change Ground Variable Back
		lwz		r3,0xE0(r26)
		cmpwi		r3,0x0
		bne		Savestate_RestoreCameraFlag
		li		r3,0x1
		stw		r3,0x83C(r26)
		*/

		#Restore Camera Flag
		Savestate_RestoreCameraFlag:
		add		r3,r24,r27		#get end of block in r4
		addi		r3,r3,0x100		#static block length = 0x100
		lwz		r3,0x0(r3)		#get flag
		lwz		r4,0x890(r26)
		stw		r3,0x8(r4)

    #Update Camera Box Position
    mr  r3,r25
    bl  UpdateCameraBox

		#Remake HUD For Dead Players (Taken from Achilles' GitHub)
		cmpwi		r23,0x1		#dont run this on subcharacters
		beq		SaveState_HUD_End
		load		r3,0x804a10c8		#get base HUD info
		mulli 		r4,r22,100		#get offset
		add		r20,r4,r3		#get to this player's HUD info
		branchl		r12,0x8016b094	 #MatchInfo_StockModeCheck
		cmpwi 		r3,0		#if not stock mode
		beq- 		SaveState_RELOAD_PERCENT_HUDS_NOT_STOCK

			SaveState_RELOAD_PERCENT_HUDS_STOCK:
			mr		r3,r22		#get player number
			branchl		r12,0x80033bd8		#get stocks left
			cmpwi 		r3,0
			bne- 		SaveState_RELOAD_PERCENT_HUDS_NOT_STOCK
			li 		r5,0x80		#remove percent
			stb 		r5,0x10(r20)
			b 		SaveState_HUD_End

				SaveState_RELOAD_PERCENT_HUDS_NOT_STOCK:
				lbz		r5,0x10(r20)
				rlwinm. 		r5,r5,0,24,24	# (00000080), is player HUD percent gone?
				beq- 		SaveState_HUD_End

				SaveState_REMAKE_PERCENT:
				.set 		HUD_PlayerCreate_Prefunction, 0x802f6e1c
				mr 		r3,r22
				branchl		r4, HUD_PlayerCreate_Prefunction

		SaveState_HUD_End:

		SaveState_LoadLoopInc:
		#Check For Subchar Before Looping
		cmpwi		r23,0x1
		beq		SaveState_LoadLoopInc_ToggleSubCharOff
		li		r23,0x1
		b		SaveState_LoadLoop
		SaveState_LoadLoopInc_ToggleSubCharOff:
		li		r23,0x0
		addi		r29,r29,0x1
		cmpw		r29,r30
		blt		SaveState_LoadLoop

	restore
	blr

#########################################################################

############################
## Get PlayerData Pointer ##
############################

SaveState_GetPlayerDataPointer:
#r3 = player number (regardless of port)
#r4 = 0x0 for main char // 0x1 for subchar

#returns:
#r3 = player slot
#r4 = external player
#r5 = internal player
subi	sp,sp,0x8
mr	r11,r3			#move desired player into r11
mr	r10,r4			#move subchar status into r4
mr	r9,sp			#move bytefield into r10
li	r3,-0x1			#zero out new space
stw	r3,0x0(r9)
stw	r3,0x4(r9)

#Make Bytefield For Player Order
li	r7,0x0			#init loop
li	r6,0x0			#init player ID
load	r5,0x80453080			#first playerblock

	SaveState_GetPlayerDataPointer_LoopStart:
	lwz	r3,0x0(r5)			#an inactive player block will store "0" at offset 0x0
	cmpwi	r3,0x0
	beq	SaveState_GetPlayerDataPointer_Empty

	SaveState_GetPlayerDataPointer_PlayerPresent:
	stbx	r7,r6,r9			#store loop count to player ID offset
	addi	r6,r6,0x1			#next player ID

	SaveState_GetPlayerDataPointer_Empty:
	addi	r5,r5,0xe90			#next playerblock
	addi	r7,r7,0x1			#inc loop
	cmpwi	r7,6
	blt	SaveState_GetPlayerDataPointer_LoopStart

#Now r9 contains player bytefield
lbzx	r3,r11,r9			#get the correct player slot for the X player
cmpwi	r3,0xFF			#check if player exists
beq	SaveState_GetPlayerDataPointer_Exit			#if not exit with -1 return

load	r5,0x80453080			#first playerblock
mulli	r4,r3,0xe90			#get offset
add	r4,r4,r5			#get static block in r4

cmpwi	r10,0x0
beq	SaveState_GetPlayerDataPointer_MainChar

SaveState_GetPlayerDataPointer_SubChar:
lwz	r4,0xB4(r4)
b	SaveState_GetPlayerDataPointer_LoadInternal
SaveState_GetPlayerDataPointer_MainChar:
lwz	r4,0xB0(r4)
SaveState_GetPlayerDataPointer_LoadInternal:
#Check If Player Exists
cmpwi	r4,0x0
bne	SaveState_GetPlayerDataPointer_LoadInternalContinue
li	r3,0xFF
b	SaveState_GetPlayerDataPointer_Exit
SaveState_GetPlayerDataPointer_LoadInternalContinue:
lwz	r5,0x2c(r4)

SaveState_GetPlayerDataPointer_Exit:
addi	sp,sp,0x8
blr

#######################################################

CheckForSaveAndLoad:

backup

mr	r29,r3		#Task Data

CheckForSaveAndLoad_GetFirstPlayer:
lwz	r3, -0x3E74 (r13)
lwz	r30, 0x0020 (r3)
b	CheckForSaveAndLoad_CheckIfPlayerExists

CheckForSaveAndLoad_GetNextPlayer:
lwz	r30,0x8(r30)

CheckForSaveAndLoad_CheckIfPlayerExists:
cmpwi	r30,0x0
bne		CheckForSaveAndLoad_LoadPlayerData
li	r3,-1
b	CheckForSaveAndLoad_Exit
CheckForSaveAndLoad_LoadPlayerData:
lwz	r31,0x2C(r30)

CheckForSaveAndLoad_CheckIfHuman:
lbz	r3,0xC(r31)
branchl	r12,PlayerBlock_LoadSlotType
cmpwi	r3,0x0
bne	CheckForSaveAndLoad_GetNextPlayer

CheckForSaveAndLoad_CheckIfFollower:
lbz	r3,0x221F(r31)
rlwinm.	r0,r3,0,28,28
bne	CheckForSaveAndLoad_GetNextPlayer

CheckForSaveAndLoad_CheckInputs:

#Make Sure Nothing Else Is Held
lhz	r3,0x662(r31)
cmpwi	r3,0x0
bne	CheckForSaveAndLoad_GetNextPlayer
lwz	r3,0x668(r31)
rlwinm.	r0,r3,0,30,30
beq	CheckForSaveAndLoad_NoSave
mr	r3,r29
bl	SaveState_Save
li	r3,0x0
b	CheckForSaveAndLoad_Exit
CheckForSaveAndLoad_NoSave:
rlwinm.	r0,r3,0,31,31
beq	CheckForSaveAndLoad_GetNextPlayer
mr	r3,r29
bl	SaveState_Load
mr	r3,r29
bl	SaveState_Load
li	r3,0x1
b	CheckForSaveAndLoad_Exit


CheckForSaveAndLoad_Exit:
restore
blr

############################################

GiveFullShields:
backup

GiveFullShields_GetFirstPlayer:
lwz	r3, -0x3E74 (r13)
lwz	r20, 0x0020 (r3)
b	GiveFullShields_CheckIfPlayerExists

GiveFullShields_GetNextPlayer:
lwz	r20,0x8(r20)

GiveFullShields_CheckIfPlayerExists:
cmpwi	r20,0x0
beq	GiveFullShields_Exit
lwz	r21,0x2C(r20)

#Give Full Shield
lwz	r3, -0x514C (r13)
lfs	f0, 0x0260 (r3)
stfs	f0,0x1998(r21)
b	GiveFullShields_GetNextPlayer


GiveFullShields_Exit:

restore
blr

############################################

UpdateAllGFX:
backup

mr	r3,30
branchl	r12,GFX_UpdatePlayerGFX

#Check For Follower
mr	r3,r30
bl	CheckIfPlayerHasAFollower
cmpwi	r3,0x0
beq		UpdateAllGFX_Exit

#Apply To Follower Char
branchl	r12,GFX_UpdatePlayerGFX

UpdateAllGFX_Exit:
restore
blr

############################################

GiveInvincibility:
#r3 = ext pointer
#r4 = frames

backup

#Give To Main Char
mr	r31,r3
mr	r30,r4
branchl	r12,ApplyInvincibility

#Check For Follower
mr	r3,r31
bl	CheckIfPlayerHasAFollower
cmpwi	r3,0x0
beq		GiveInvincibility_Exit

#Apply To Follower Char
mr	r4,r30
branchl	r12,ApplyInvincibility

GiveInvincibility_Exit:
restore
blr

############################################
StoreCPUTypeAndZeroInputs:

#Set P2 AI Type to None
#li	r3,0xF
#stw	r3,0x1A94(r29)

#Clear Inputs For P2 CPU
li	r3,0x0
stw	r3,0x1A88(r29)
stw	r3,0x1A8C(r29)
sth	r3,0x1A90(r29)
blr

###########################################

ClearNanaInputs:
backup

#Clear Inputs if P1 is Ice Climbers
mr	r3,28
bl	CheckIfPlayerHasAFollower
cmpwi	r3,0x0
beq	ClearNanaInputs_P2
li	r3,0x0
stw	r3,0x1A88(r4)
stw	r3,0x1A8C(r4)

#Clear Inputs if P2 is Ice Climbers
ClearNanaInputs_P2:
mr	r3,30
bl	CheckIfPlayerHasAFollower
cmpwi	r3,0x0
beq	ClearNanaInputs_Exit
li	r3,0x0
stw	r3,0x1A88(r4)
stw	r3,0x1A8C(r4)

ClearNanaInputs_Exit:
restore
blr

###########################################

CheckIfFirstFrame:
lis	r3, 0x8047
subi	r3, r3, 18784
lwz	r3, 0x0024 (r3)
cmpwi	r3,0x1
bne	CheckIfFirstFrame_False
li	r3,0x1
b	CheckIfFirstFrame_Exit
CheckIfFirstFrame_False:
li	r3,0x0
CheckIfFirstFrame_Exit:
blr

#############################################

CurrentInputsAsLastFramesInputs:
load r3,0x804c21cc
lwz	r3,0x0(r3)
stw	r3,0x65C(r27)
stw	r3,0x664(r27)

#Check For Z Press
rlwinm.	r0, r3, 0, 27, 27
beq	CurrentInputsAsLastFramesInputs_Exit
oris	r0, r3, 0x8000
ori	r0, r0, 0x0100
stw	r0,0x65C(r27)
stw	r0,0x664(r27)

CurrentInputsAsLastFramesInputs_Exit:
blr

#############################################

/*

CPUActions_MultiShine:
backup

mr	r29,r3

#Get AS and Frame Number
lwz	r4,0x10(r3)		#Get Current AS

#Start - Check to Grounded Shine
cmpwi	r4,0xE		#Wait
beq	Multishine_StartShine
cmpwi	r4,0x169		#Shine Loop Ground
beq	Multishine_JumpCancelShine
cmpwi	r4,0x19		#JumpF
beq	Multishine_StartShine
b       CPUActions_MultiShine_Exit

Multishine_StartShine:
li	r3,-127		#Down
stb	r3,0x1A8D(r29)		#Analog Y
li	r3,0x200		#B
stw	r3,0x1A88(r29)	 #Inputs
b	CPUActions_MultiShine_Exit

Multishine_JumpCancelShine:
li	r3,0x800		#X
stw	r3,0x1A88(r29)	 #Inputs
b	CPUActions_MultiShine_Exit

Multishine_ShineAir:
b	CPUActions_MultiShine_Exit

CPUActions_MultiShine_Exit:
restore
blr

*/


###################################

RAndDPadChangesEventOption:
OptionWindow:
#in
#r3 = pointer to option byte in memory
#r4 = pointer to Window and Option Count
#r5 = pointer to ASCII struct

#out
#r3 =

.set TextCreateFunction,0x80005928
.set OptionWindowMemory,20
.set OptionTextInfo,21
.set OptionASCII,22
.set text,23
.set toggledBool,28
.set toggledOption,29


backup


#Backup Parameters
mr	OptionWindowMemory,r3		#pointer to option byte in memory
mr	OptionTextInfo,r4		#pointer to Window and Option Count
mr	OptionASCII,r5		#pointer to ASCII struct

#Initialize Toggled Bools
li	toggledBool,0
li	toggledOption,-1

#Get Number Of Options Onscreen At Once (1,2,or 3)
lbz	r24,0x0(OptionTextInfo)		#Get Number of Different Windows
cmpwi	r24,2		#Check If Over 3
ble	0x8
li	r24,2		#Make 3

#Get Pausing Player's Inputs
load r3,0x8046b6a0
lbz r3,0x1(r3)
load r4,0x804c1fac
mulli r3,r3,68
add r3,r3,r4
lwz r3,0x8(r3)

#Check For DPad Up And Down
cmpwi	r3,0x04
beq	RAndDPadChangesEventOption_CursorDown
cmpwi	r3,0x08
beq	RAndDPadChangesEventOption_CursorUp
b	RAndDPadChangesEventOption_CheckDPadLeftAndRight

RAndDPadChangesEventOption_CursorUp:
#Update Cursor Position
	lbz	r3,0x0(OptionWindowMemory)		#Get Current Cursor Position Byte
	subi	r3,r3,0x1		#Subtract by 1
	stb	r3,0x0(OptionWindowMemory)
	cmpwi	r3,0x0
	bge	RAndDPadChangesEventOption_PlayScrollSFX
#Cursor Stays at the top of the screen
	li	r3,0
	stb	r3,0x0(OptionWindowMemory)
#Check To Scroll Down
	#Get Current Window ID (cursor + scroll)
		lbz	r3,0x0(OptionWindowMemory)
		lbz	r4,0x1(OptionWindowMemory)
		add	r3,r3,r4
	#Check If This is the Beginning
		cmpwi	r3,0
		ble	RAndDPadChangesEventOption_DisplayWindow
	#Scroll Down
		lbz	r4,0x1(OptionWindowMemory)
		subi	r4,r4,1
		stb	r4,0x1(OptionWindowMemory)
    b RAndDPadChangesEventOption_PlayScrollSFX

b	RAndDPadChangesEventOption_DisplayWindow

RAndDPadChangesEventOption_CursorDown:
#Update Cursor Position
	lbz	r3,0x0(OptionWindowMemory)		#Get Current Option Byte
	addi	r3,r3,0x1		#Add 1
	stb	r3,0x0(OptionWindowMemory)
	cmpw	r3,r24
	ble	RAndDPadChangesEventOption_PlayScrollSFX
#Cursor Stays at the Bottom of the Screen
	stb	r24,0x0(OptionWindowMemory)
#Check To Scroll Down
	#Get Current Window ID (cursor + scroll)
		lbz	r3,0x0(OptionWindowMemory)
		lbz	r4,0x1(OptionWindowMemory)
		add	r3,r3,r4
	#Get Max Number Of Windows
		lbz	r4,0x0(OptionTextInfo)		#Get Number of Different Windows
	#Check If This is the End
		cmpw	r3,r4
		bge	RAndDPadChangesEventOption_DisplayWindow
	#Scroll Down
		lbz	r4,0x1(OptionWindowMemory)
		addi	r4,r4,1
		stb	r4,0x1(OptionWindowMemory)

b	RAndDPadChangesEventOption_PlayScrollSFX

#Check For DPad Left And Right
RAndDPadChangesEventOption_CheckDPadLeftAndRight:
cmpwi	r3,0x02
beq	RAndDPadChangesEventOption_Increment
cmpwi	r3,0x01
beq	RAndDPadChangesEventOption_Decrement
b	RAndDPadChangesEventOption_DisplayWindow

RAndDPadChangesEventOption_Increment:
#Get Current Window ID (cursor + scroll)
	lbz	r3,0x0(OptionWindowMemory)
	lbz	r4,0x1(OptionWindowMemory)
	add	r3,r3,r4
#Set as Toggled
	li toggledBool,1
	mr	toggledOption,r3

addi	r5,r3,2
lbzx	r3,r5,OptionWindowMemory		#Get Current Option Byte
addi	r3,r3,0x1
stbx	r3,r5,OptionWindowMemory		#Store New Option Byte Value
subi	r5,r5,1
lbzx	r4,r5,OptionTextInfo		#Get Window's Option Byte Max Value
cmpw	r3,r4
ble	RAndDPadChangesEventOption_PlayScrollSFX
li	r3,0x0
addi	r5,r5,1
stbx	r3,r5,OptionWindowMemory		#Get New Option Byte Value
b	RAndDPadChangesEventOption_PlayScrollSFX

RAndDPadChangesEventOption_Decrement:
#Get Current Window ID (cursor + scroll)
	lbz	r3,0x0(OptionWindowMemory)
	lbz	r4,0x1(OptionWindowMemory)
	add	r3,r3,r4
#Set as Toggled
	li toggledBool,1
	mr toggledOption,r3

addi	r5,r3,0x2
lbzx	r3,r5,OptionWindowMemory		#Get Current Option Byte
subi	r3,r3,0x1
stbx	r3,r5,OptionWindowMemory		#Store New Option Byte Value
cmpwi	r3,0x0
bge	RAndDPadChangesEventOption_PlayScrollSFX
subi	r5,r5,1
lbzx	r3,r5,OptionTextInfo		#Get Window's Option Byte Max Value
addi	r5,r5,1
stbx	r3,r5,OptionWindowMemory		#Store New Option Byte Value
b	RAndDPadChangesEventOption_PlayScrollSFX

RAndDPadChangesEventOption_PlayScrollSFX:
li  r3,0x2
branchl r12,SFX_MenuCommonSound

RAndDPadChangesEventOption_DisplayWindow:
#Display Text For The New Option Value
mr	r3,r27			#p1 (no offsetting window)
li	r4,1			  #text timeout
li	r5,0x2			#window instance #3
li	r6,0			  #window ID #3
branchl	r12,TextCreateFunction		#create text custom function
mr	text,r3			#backup text pointer


#########################
## Display Option Menu ##
#########################

		#Check How Many Options In The Menu
		cmpwi	r24,0
		beq	RAndDPadChangesEventOption_DisplayWindow_LoopInit

		#Change Background Size
		bl	RAndDPadChangesEventOption_Floats
		mflr	r5
		lfs	f1,0x0(r5)		#12.5
		addi	r5,r5,0x4		#Skip Window X
		subi	r6,r24,1		#Zero Index
		mulli	r6,r6,0x4		#Get Y Offset
		lfsx	f2,r6,r5
		li	r4,0
		branchl	r12,Text_UpdateSubtextSize

		#Move Window
		bl	RAndDPadChangesEventOption_Floats
		mflr	r5
		lfs	f1, -0x37B4 (rtoc)
		addi	r5,r5,0xC		#Skip Window X and Window Y's
		subi	r6,r24,1		#Zero Index
		mulli	r6,r6,0x4		#Get Y Offset
		lfsx	f2,r6,r5
		mr	r3,text
		li	r4,0
		branchl	r12,Text_UpdateSubtextPosition


	############################
	## Print Each Option Loop ##
	############################

	RAndDPadChangesEventOption_DisplayWindow_LoopInit:

		li	r27,0			#Init Loop

	RAndDPadChangesEventOption_DisplayWindow_Loop:

		#Get Window Title And Option
			mr	r3,OptionASCII			#Option ASCII Start
			lbz	r4,0x1(OptionWindowMemory)			#Get Scroll Position
			add	r4,r4,r27			#Get Loop Count's Window
			addi	r5,OptionWindowMemory,0x2			#Selection ID's
			lbzx	r5,r4,r5			#Get Current Option This Window is On
			bl	RAndDPadChangesEventOption_GetOptionASCII
			mr	r25,r3
			mr	r26,r4

		#Create Title Text
			lfs	f2, -0x37B4 (rtoc)			#default text X/Y
			li	r3,120
			mullw	r3,r3,r27
			bl	IntToFloat
			fadds	f2,f1,f2
			lfs	f1, -0x37B4 (rtoc)			#default text X/Y
			mr 	r3,text			#text pointer
			mr	r4,r25			#Title Text Pointer
			branchl r12,Text_InitializeSubtext
		#Make Text Grey
			load	r4,0xdfdfdf00
			stw	r4,0xF0(sp)
			addi	r5,sp,0xF0
			mr	r4,r3
			mr	r3,text
			branchl	r12,Text_ChangeTextColor

		#Create Selection Text
			lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
			li	r3,120
			mullw	r3,r3,r27
			bl	IntToFloat
			fadds	f2,f1,f2
			lfs	f1, -0x37B4 (rtoc)			#default text X/Y
			mr 	r3,text			#text pointer
			mr	r4,r26			#Selection Text
			branchl r12,Text_InitializeSubtext
		#Check To Outline in Yellow
			lbz	r4,0x0(OptionWindowMemory)			#Get Cursor Position
			cmpw	r4,r27			#Compare With Loop Counter
			bne	RAndDPadChangesEventOption_DisplayWindow_SkipColor
			load	r4,0xf7ff2700
			stw	r4,0xF0(sp)
			addi	r5,sp,0xF0
			mr	r4,r3
			mr	r3,text
			branchl	r12,Text_ChangeTextColor

		RAndDPadChangesEventOption_DisplayWindow_SkipColor:
			cmpw	r27,r24
			addi	r27,r27,1
			blt	RAndDPadChangesEventOption_DisplayWindow_Loop

		b RAndDPadChangesEventOption_Exit


#########################################

RAndDPadChangesEventOption_GetOptionASCII:

backup

	mr	r31,r3		#Option ASCII Start
	mr	r30,r4		#Option ID We're Looking For
	mr	r29,r5		#Option Selection We're Looking For

#Init Loop
	li	r27,0

RAndDPadChangesEventOption_GetOptionASCII_OptionIDLoop:
	cmpw	r27,r30		#Check If This is the Window We're Looking For
	beq	RAndDPadChangesEventOption_GetOptionASCII_GetOptionSelection



	########################
	## Skip Entire Option ##
	########################

		RAndDPadChangesEventOption_GetOptionASCII_GetNextOptionID:
		#Skip Past Window Title
			mr	r3,r31
			bl	RAndDPadChangesEventOption_GetNextString
			mr	r31,r3		#Backup New Pointer

		#Loop Through All The Window's Selections
			li	r26,0		#Loop Count
		RAndDPadChangesEventOption_GetOptionASCII_LoopThroughSelections:
		#Get This Options (r27) Total Number of Selections (Pointer in OptionTextInfo)
			addi	r3,OptionTextInfo,0x1		#Get to Option Selection Counts
			lbzx	r3,r3,r27		#Get This Windows Total Number of Selections
			addi	r3,r3,0x1		#Add 1 To Ensure We Are at the Start of the Next Window Title
			cmpw	r3,r26		#Check If This is the Last Selection
			bne	RAndDPadChangesEventOption_GetOptionASCII_LoopThroughSelections_NextSelection

		#End of Loop, Done With This Option
		#Increment Loop Count
			addi	r27,r27,1		#Increment Option Count
			b	RAndDPadChangesEventOption_GetOptionASCII_OptionIDLoop

		RAndDPadChangesEventOption_GetOptionASCII_LoopThroughSelections_NextSelection:
		#Get Next Selection
			mr	r3,r31
			bl	RAndDPadChangesEventOption_GetNextString
			mr	r31,r3		#Backup New Pointer
		#Increment Loop Count
			addi	r26,r26,1
			b	RAndDPadChangesEventOption_GetOptionASCII_LoopThroughSelections

	###########################
	## Find Option Selection ##
	###########################

		RAndDPadChangesEventOption_GetOptionASCII_GetOptionSelection:
		#Init Loop Count + Backup Window Title
			li	r26,0		#Init Loop Count
			mr	r25,r31		#r25 = Window Title
		#Skip Window Title
			mr	r3,r31
			bl	RAndDPadChangesEventOption_GetNextString
			mr	r31,r3		#Backup New Pointer
		RAndDPadChangesEventOption_GetOptionASCII_GetOptionSelection_Loop:
		#Check If This is the Selection We're Looking For
			cmpw	r26,r29
			beq	RAndDPadChangesEventOption_GetOptionASCII_GetOptionSelection_Done
		#Get Next Selection
		#Strlen the entry
			mr	r3,r31
			bl	RAndDPadChangesEventOption_GetNextString
			mr	r31,r3		#Backup New Pointer
		#Increment Loop Count
			addi	r26,r26,1
			b	RAndDPadChangesEventOption_GetOptionASCII_GetOptionSelection_Loop

		RAndDPadChangesEventOption_GetOptionASCII_GetOptionSelection_Done:
			mr	r3,r25		#Return Window Name
			mr	r4,r31		#Return Selection String


RAndDPadChangesEventOption_GetOptionASCII_Exit:
restore
blr

#########################################

RAndDPadChangesEventOption_GetNextString:
backup

mr	r31,r3			#Backup String Pointer
branchl	r12,strlen			#Get Length
add	r3,r3,r31			#Get End of String

#From here, mini loop to find the next non-zero value.
RAndDPadChangesEventOption_GetNextString_Loop:
lbzu	r4,0x1(r3)
cmpwi	r4,0x0
beq	RAndDPadChangesEventOption_GetNextString_Loop

restore
blr

#########################################
RAndDPadChangesEventOption_Floats:
blrl

.long 0x41480000 #12.5, X position
.long 0x427c0000 #63, 2 Window Y Scale
.long 0x42bc0000 #94, 3 Window Y Scale
.long 0xc4610000 #-900, 2 Window Y position
.long 0xc4a8c000 #-1350, 3 Window Y position


#########################################

RAndDPadChangesEventOption_Exit:
mr	r3,toggledBool
mr	r4,toggledOption
restore
blr

##################################

DPadCPUPercent:
backup

#Get P1 Block
li	r3,0x0
branchl	r12,PlayerBlock_LoadMainCharDataOffset			#get player block
lwz	r3,0x2C(r3)

#Get P2 Percent
load	r6,0x80453F10
lhz	r5,0x60(r6)

#Make Sure L Is Held
lhz	r4,0x662(r3)
cmpwi	r4,0x40
bne	DPadCPUPercent_Exit
#Poll P1 For DPad
lhz	r4,0x66A(r3)
cmpwi	r4,0x2		#rlwinm.	r0,r4,0,30,30
beq	DPadCPUPercent_IncByOne
cmpwi	r4,0x1		#rlwinm.	r0,r4,0,31,31
beq	DPadCPUPercent_DecByOne
cmpwi	r4,0x8		#rlwinm.	r0,r4,0,28,28
beq	DPadCPUPercent_IncByTen
cmpwi	r4,0x4		#rlwinm.	r0,r4,0,29,29
beq	DPadCPUPercent_DecByTen
b	DPadCPUPercent_Exit

DPadCPUPercent_IncByOne:
cmpwi	r5,999
blt	DPadCPUPercent_IncByOneReal
li	r5,999
b	DPadCPUPercent_StorePercent
DPadCPUPercent_IncByOneReal:
addi	r5,r5,0x1
b	DPadCPUPercent_StorePercent

DPadCPUPercent_DecByOne:
cmpwi	r5,0
bgt	DPadCPUPercent_DecByOneReal
li	r5,0
b	DPadCPUPercent_StorePercent
DPadCPUPercent_DecByOneReal:
subi	r5,r5,0x1
b	DPadCPUPercent_StorePercent

DPadCPUPercent_IncByTen:
cmpwi	r5,989
blt	DPadCPUPercent_IncByTenReal
li	r5,999
b	DPadCPUPercent_StorePercent
DPadCPUPercent_IncByTenReal:
addi	r5,r5,10
b	DPadCPUPercent_StorePercent

DPadCPUPercent_DecByTen:
cmpwi	r5,9
bgt	DPadCPUPercent_DecByTenReal
li	r5,0
b	DPadCPUPercent_StorePercent
DPadCPUPercent_DecByTenReal:
subi	r5,r5,10
b	DPadCPUPercent_StorePercent

DPadCPUPercent_StorePercent:
#Convert to Float
mr		r3,r5
bl		IntToFloat
#Active Static Playerblock
sth	r5,0x60(r6)
#Active PlayerData
li	r3,0x1
branchl	r12,PlayerBlock_LoadMainCharDataOffset		#get player block
lwz	r3,0x2C(r3)
stfs	f1,0x1830(r3)

#Backed Up PlayerData
lwz	r3,0x18(r31)
stfs	f1,0x1830(r3)
#Backed Up Static Playerblock
load	r4,0x80458fd0			#get player block length
lwz    	r4,0x20(r4)			#get player block length
add	r3,r3,r4			#static block start
sth	r5,0x60(r3)


DPadCPUPercent_Exit:
restore
blr

##################################

InitializePositions:
backup

#Move Float Pointer
mr	r20,r3

#P1 Static Block
load	r22,0x80453080
#P2 Static Block
addi	r23,r22,0xE90

#Move P1
mr	r3,r28
branchl	r12,0x8008a2bc		#Enter Wait
lfs	f1,0x0(r20)
stfs	f1,0xB0(r27)
lfs	f1,0x8(r20)
stfs	f1,0xB4(r27)
mr	r3,r28
bl  UpdatePosition
mr	r3,r28
bl	CheckIfPlayerHasAFollower
cmpwi	r3,0x0
beq	InitializePositions_MoveP2
#Move This Char Too
mr	r24,r3
mr	r25,r4
mr	r3,r24
branchl	r12,0x8008a2bc		#Enter Wait
lfs	f1,0x0(r20)
stfs	f1,0xB0(r25)
lfs	f1,0x8(r20)
stfs	f1,0xB4(r25)
mr	r3,r24
bl  UpdatePosition


#Move P2
InitializePositions_MoveP2:
mr	r3,r30
branchl	r12,0x8008a2bc		#Enter Wait
lfs	f1,0x4(r20)
stfs	f1,0xB0(r29)
lfs	f1,0xC(r20)
stfs	f1,0xB4(r29)
mr	r3,r30
bl  UpdatePosition
mr	r3,r30
bl	CheckIfPlayerHasAFollower
cmpwi	r3,0x0
beq	InitializePositions_Exit
#Move This Char Too
mr	r24,r3
mr	r25,r4
mr	r3,r24
branchl	r12,0x8008a2bc		#Enter Wait
lfs	f1,0x4(r20)
stfs	f1,0xB0(r25)
lfs	f1,0xC(r20)
stfs	f1,0xB4(r25)
mr	r3,r24
bl  UpdatePosition

InitializePositions_Exit:
bl	ClearNanaInputs
bl	CurrentInputsAsLastFramesInputs

restore
blr

#########################################################

CheckIfPlayerHasAFollower:
#Returns
#r3 = 0 for no follower // External Pointer
#r4 = 0 for no follower // Internal Pointer

backup

#Get Players Data
lwz	r31,0x2C(r3)

#Get Player Slot
lbz	r3,0xC(r31)
li	r4,0x1
bl	SaveState_GetPlayerDataPointer				#returns r3=Slot/-1 if subchar doesnt exist, r4= external, r5=internal
cmpwi	r3,0xFF
beq	CheckIfPlayerHasAFollower_NoFollower

#Check If Follower
mr	r24,r4
mr	r25,r5
lbz	r3,0xC(r25)			#get slot
branchl	r12,0x80032330			#get external character ID
load	r4,pdLoadCommonData			#pdLoadCommonData table
mulli	r0, r3, 3			#struct length
add	r3,r4,r0			#get characters entry
lbz	r0, 0x2 (r3)			#get subchar functionality
cmpwi	r0,0x0			#if not a follower, exit
bne	CheckIfPlayerHasAFollower_NoFollower

#Return Follower Pointers
mr	r3,r24			#External
mr	r4,r25			#Internal
b	CheckIfPlayerHasAFollower_Exit

CheckIfPlayerHasAFollower_NoFollower:
li	r3,0x0
li	r4,0x0

CheckIfPlayerHasAFollower_Exit:
restore
blr

#########################################################

Randomize_LeftorRightSide:
#r3 = 0 = Same Side of Stage // 1 = Opposing Sides of Stage

backup

mr	r20,r3		#Backup Stage Side Bool

#Get Left or Right Side
li	r3,2
branchl	r12,HSD_Randi
#Check To Negate
cmpwi	r3,0x0		#0 = Left, 1 = Right
bne	Randomize_RightSide

Randomize_LeftSide:
#P1 X Position
lwz	r3,0x10(r31)		#P1 Backup Start
lwz	r4,0x18(r31)		#P2 Backup Start
lfs	f1,0xB0(r3)		#P1 Backup X Pos
cmpwi	r20,0x0
beq	0xC
bl	Randomize_AlwaysNegative
b	0x8
bl	Randomize_AlwaysNegative
stfs	f1,0xB0(r3)		#P1 Backup X Pos
#P2 X Position
lfs	f1,0xB0(r4)		#P2 Backup X Pos
cmpwi	r20,0x0
beq	0xC
bl	Randomize_AlwaysPositive
b	0x8
bl	Randomize_AlwaysNegative
stfs	f1,0xB0(r4)		#P2 Backup X Pos
#Facing Directions
lis	r5,0x3f80		#P1 Face Right
lis	r6,0xbf80		#P2 Face Left
stw	r5,0x2C(r3)		#P1 Backup Facing
stw	r6,0x2C(r4)		#P2 Facing
b	Randomize_LeftorRightSide_CheckForFollowers

Randomize_RightSide:
#P1 X Position
lwz	r3,0x10(r31)		#P1 Backup Start
lwz	r4,0x18(r31)		#P2 Backup Start
lfs	f1,0xB0(r3)		#P1 Backup X Pos
cmpwi	r20,0x0
beq	0xC
bl	Randomize_AlwaysPositive
b	0x8
bl	Randomize_AlwaysPositive
stfs	f1,0xB0(r3)		#P1 Backup X Pos
#P2 X Position
lfs	f1,0xB0(r4)		#P2 Backup X Pos
cmpwi	r20,0x0
beq	0xC
bl	Randomize_AlwaysNegative
b	0x8
bl	Randomize_AlwaysPositive
stfs	f1,0xB0(r4)		#P2 Backup X Pos
#Facing Directions
lis	r5,0xbf80		#P1 Face Left
lis	r6,0x3f80		#P2 Face Right
stw	r5,0x2C(r3)		#P1 Backup Facing
stw	r6,0x2C(r4)		#P2 Facing


Randomize_LeftorRightSide_CheckForFollowers:
	Randomize_LeftorRightSide_GetFirstPlayer:
	lwz	r3, -0x3E74 (r13)
	lwz	r20, 0x0020 (r3)
	b	Randomize_LeftorRightSide_CheckIfPlayerExists

	Randomize_LeftorRightSide_GetNextPlayer:
	lwz	r20,0x8(r20)

	Randomize_LeftorRightSide_CheckIfPlayerExists:
	cmpwi	r20,0x0
	beq	Randomize_LeftorRightSide_Exit
	lwz	r21,0x2C(r20)

	#Check If This Fighter is a Main Char
	lbz	r3,0x221F(r21)
	rlwinm.	r0, r3, 29, 31, 31
	bne	Randomize_LeftorRightSide_GetNextPlayer

	#Check For Follower, r20 = External. r21 = Internal
		mr	r3,r20
		bl	CheckIfPlayerHasAFollower
		cmpwi	r3,0x0					#No Follower, Go To Next Player
		beq	Randomize_LeftorRightSide_GetNextPlayer

		#Transfer Info
		#Get Backups
		addi	r3,r31,0x10		#Get Backup Start
		lbz	r4,0xC(r21)		#Get Subchars Slot
		mulli	r4,r4,0x8		#Each Slot has 2 backups, so get to this slots backup
		add	r3,r3,r4		#Each Slot has 2 backups, so get to this slots backup

		#Copy Main Char's Info Into Subchars
		lwz	r4,0x0(r3)		#Main Char Backup
		lwz	r5,0x4(r3)		#Follower Backup
		lwz	r3,0xB0(r4)		#Main Char X
		stw	r3,0xB0(r5)		#Into Subchar X
		lwz	r3,0x2C(r4)		#Main Char Facing
		stw	r3,0x2C(r5)		#Into Subchar Facing
		b	Randomize_LeftorRightSide_GetNextPlayer


Randomize_LeftorRightSide_Exit:
restore
blr

#********************************************#

Randomize_AlwaysPositive:
fabs	f1,f1		#Always Positive
blr

Randomize_AlwaysNegative:
fabs	f1,f1
fneg	f1,f1		#Always Negative
blr

#********************************************#

############################################

IntToFloat:
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r20,0x8(r1)
stfs  f2,0x38(r1)

lis	r0, 0x4330
lfd	f2, -0x6758 (rtoc)
xoris	r3, r3,0x8000
stw	r0,0xF0(sp)
stw	r3,0xF4(sp)
lfd	f1,0xF0(sp)
fsubs	f1,f1,f2		#Convert To Float

lfs  f2,0x38(r1)
lmw  r20,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
blr

############################################

GetDirectionInRelationToP1:
#Get P1 Direction
lfs	f1,0xB0(r27)
lfs	f2,0xB0(r29)
fsubs	f1,f1,f2
lfs	f2, -0x6768 (rtoc)
fcmpo	cr0,f2,f1
blt	0xC
li	r3,1
b	0x8
li	r3,-1
blr

############################################

IsAnyoneDead:
backup

IsAnyoneDead_GetFirstPlayer:
lwz	r3, -0x3E74 (r13)
lwz	r20, 0x0020 (r3)
b	IsAnyoneDead_CheckIfPlayerExists

IsAnyoneDead_GetNextPlayer:
lwz	r20,0x8(r20)

IsAnyoneDead_CheckIfPlayerExists:
cmpwi	r20,0x0
bne	IsAnyoneDead_GetPlayerData
#Exit If No Other Players
li	r3,0x0
b	IsAnyoneDead_Exit

IsAnyoneDead_GetPlayerData:
lwz	r21,0x2C(r20)

#Check If Follower
lbz	r3,0x221F(r21)
rlwinm.	r0,r3,0,28,28
bne	IsAnyoneDead_GetNextPlayer

#Check If Dead
lbz	r3,0x221F(r21)
rlwinm.	r0,r3,0,25,25
beq	IsAnyoneDead_GetNextPlayer
li	r3,0x1
b	IsAnyoneDead_Exit

IsAnyoneDead_Exit:

restore
blr

############################################

ResetStaleMoves:
backup

ResetStaleMoves_GetFirstPlayer:
lwz	r3, -0x3E74 (r13)
lwz	r20, 0x0020 (r3)
b	ResetStaleMoves_CheckIfPlayerExists

ResetStaleMoves_GetNextPlayer:
lwz	r20,0x8(r20)

ResetStaleMoves_CheckIfPlayerExists:
cmpwi	r20,0x0
bne	ResetStaleMoves_GetPlayerData
#Exit If No Other Players
li	r3,0x0
b	ResetStaleMoves_Exit

ResetStaleMoves_GetPlayerData:
lwz	r21,0x2C(r20)

#Reset Stale Moves
#Get Stale Move Table
lbz	r3,0xC(r21)		#Get Slot
branchl	r12,0x80036244		#Get This Players Stale Table

#Fill With 0's
li	r4,0x2C
branchl	r12,ZeroAreaLength
b	ResetStaleMoves_GetNextPlayer


ResetStaleMoves_Exit:

restore
blr

############################################

ActOutOfLaserHitDisplay:
backup

#Check If In Run
lwz	r3,0x10(r27)
cmpwi	r3,0x14
bne	ActOutOfLaserHitDisplayExit

#Check If Frame 2
li	r3,2
bl	IntToFloat
lfs	f2,0x894(r27)
fcmpo	cr0,f2,f1
bne	ActOutOfLaserHitDisplayExit

#Search Prev AS For Laser Hit, returns r3=AS's Since Laser Hit or -1 for didnt happen
li	r3,0x0		#Number of AS's ago
addi	r4,r27,0x23F0		#First Prev AS
subi	r4,r4,0x2
ActOutOfLaserHitDisplay_SearchLoop:
addi	r3,r3,0x1
lhzu	r5,0x2(r4)
cmpwi	r5,0x4E		#Laser Hit
beq	ActOutOfLaserHitDisplay_ExitLoop
cmpwi	r5,0x4B		#Laser Hit
beq	ActOutOfLaserHitDisplay_ExitLoop
cmpwi	r3,0x3
beq	ActOutOfLaserHitDisplay_NoLaserHit
b	ActOutOfLaserHitDisplay_SearchLoop
ActOutOfLaserHitDisplay_NoLaserHit:
li	r3,-1
ActOutOfLaserHitDisplay_ExitLoop:
cmpwi	r3,-1
beq	ActOutOfLaserHitDisplayExit

ActOutOfLaserHitDisplay_CountFrameInit:
#Get Amount Of Frames Since Laser Hit Ended
	li	r5,0x23FC		#As's Frame Count offset
	li	r20,0		#Frames Since Laser Hit
ActOutOfLaserHitDisplay_CountFrameLoop:
	cmpwi	r3,0		#Check If Done Counting
	beq	ActOutOfLaserHitDisplay_CountFrameLoopFinish
	mulli	r4,r3,2		#Frame Count Offset
	subi	r4,r4,0x2		#1 AS Before
	add	r4,r4,r5		#Get Offset in Playerblock
	lhzx	r6,r4,r27		#Get Frame Count Value
	subi	r4,r4,0xC		#Get AS Associated With It
	lhzx	r4,r4,r27		#Get AS ID
#Check If This AS is Turn
	cmpwi	r4,0x12
	beq	0x8
	add	r20,r20,r6		#Add To Toal
	cmpwi	r4,0x4E
	beq	ActOutOfLaserHitDisplay_SubtractHitstun
	cmpwi	r4,0x4B
	beq	ActOutOfLaserHitDisplay_SubtractHitstun
	b	ActOutOfLaserHitDisplay_SkipSubtractHitstun
ActOutOfLaserHitDisplay_SubtractHitstun:
	subi	r20,r20,0x8
ActOutOfLaserHitDisplay_SkipSubtractHitstun:
	subi	r3,r3,1
	b	ActOutOfLaserHitDisplay_CountFrameLoop

ActOutOfLaserHitDisplay_CountFrameLoopFinish:

ActOutOfLaserHitDisplay_DisplayOSD:
mr	r3,r27			#p1 (no offsetting window)
li	r4,120			#text timeout
li	r5,0			#Area to Display (0-2)
li	r6,21			#Window ID (Unique to This Display)
branchl	r12,TextCreateFunction			#create text custom function
mr	text,r3			#backup text pointer

cmpwi	r20,0x1
beq	ActOutOfLaserHitDisplay_Perfect
ActOutOfLaserHitDisplay_Late:
load	r3,0xffa2baff			#Red
b	ActOutOfLaserHitDisplay_StoreTextColor
ActOutOfLaserHitDisplay_Perfect:
load	r3,0x8dff6eff			#green
ActOutOfLaserHitDisplay_StoreTextColor:
stw	r3,0x30(text)

	#Create Text 1
	mr 	r3,text			#text pointer
	bl	ActOutOfLaserHitDisplay_TopText
	mflr	r4
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B4 (rtoc)			#default text X/Y
	branchl r12,Text_InitializeSubtext

	#Create Text 2
	mr 	r3,text			#text pointer
	bl	ActOutOfLaserHitDisplay_BottomText
	mflr	r4
	mr	r5,r20			#Frame Count
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#default text X/Y
	branchl r12,Text_InitializeSubtext

ActOutOfLaserHitDisplayExit:
restore
blr

#####################
## Text Properties ##
#####################

ActOutOfLaserHitDisplay_TextProperties:
blrl

.long 0xC1A80000 #Whether to Use HUD Location, 0 = no
.long 0x41100000 #Y Value
.long 0x41600000 #X Difference Between Players
.long 0x3D23D70A	#Text Size

.long 0xC3CD0000 #background Y position
.long 0x4129999A #background X stretch
.long 0x41E00000 #background Y stretch

##############
## Top Text ##
##############

ActOutOfLaserHitDisplay_TopText:
blrl
.long 0x44617368
.long 0x204f6f4c
.long 0x61736572
.long 0x48697400


#################
## Bottom Text ##
#################

ActOutOfLaserHitDisplay_BottomText:
blrl
.long 0x4672616d
.long 0x65202564
.long 0x

############################################

MoveCPU:
#in
#r3 = P1 GObj
#r4 = P2 GObj
#r5 = SaveState Struct

.set P1GObj,31
.set P1Data,30
.set P2GObj,29
.set P2Data,28
.set SaveStateStruct,27
.set P2Subchar,26
.set P2SubcharData,25

backup

#Get Variables
  mr  P1GObj,r3
  lwz P1Data,0x2C(P1GObj)
  mr  P2GObj,r4
  lwz P2Data,0x2C(P2GObj)
  mr  SaveStateStruct,r5

#Make Sure Nothing Is Held
	lhz	r3,0x662(P1Data)
	cmpwi	r3,0x0
	bne	MoveCPUExit
#Check DPad Down
	lwz	r3,0x668(P1Data)
	rlwinm.	r0,r3,0,29,29
	beq	MoveCPUExit

#Get Position
  li  r3,10
  bl  IntToFloat          #Offset from P1
  lfs f3,0xB0(P1Data)     #P1 X
  lfs f2,0xB4(P1Data)     #P1 Y
  lfs f4,0x2C(P1Data)     #Facing Direction
  fmuls f1,f1,f4
  fadds f1,f1,f3
#Check If P2 Will Be Grounded
  li  r3,0
  bl  FindGroundNearPlayer
  cmpwi r3,0    #Check if ground was found
  beq MoveCPU_NoGroundFound
  stfs f1,0xB0(P2Data)
  stfs f2,0xB4(P2Data)
  stw r4,0x83C(P2Data)
  lfs f1,0x2C(P1Data)
  fneg f1,f1
  stfs f1,0x2C(P2Data)
#Enter Wait
  mr  r3,P2GObj
  branchl r12,AS_Wait
#Update Position
  mr  r3,P2GObj
  bl  UpdatePosition
#Update ECB Values for the ground ID
  mr r3,P2GObj
  branchl r12,EnvironmentCollision_WaitLanding
#Set Grounded
  mr r3,P2Data
  branchl r12,Air_SetAsGrounded

#Check For Follower
  mr  r3,P2GObj
  bl  CheckIfPlayerHasAFollower
  cmpwi r3,0
  beq MoveCPU_NoFollower
  mr P2Subchar,r3
  mr P2SubcharData,r4
#Init Player Data Values (So CPU Init is called and nana knows where popp is)
  mr r3,P2Subchar
  branchl r12,0x80068354
#Copy Positions
  lfs f1,0xB0(P2Data)
  stfs f1,0xB0(P2SubcharData)
  lfs f1,0xB4(P2Data)
  stfs f1,0xB4(P2SubcharData)
  lwz r3,0x83C(P2Data)
  stw r3,0x83C(P2SubcharData)
  lfs f1,0x2C(P2Data)
  stfs f1,0x2C(P2SubcharData)
#Enter Wait
  mr  r3,P2Subchar
  branchl r12,AS_Wait
#Update Position
  mr  r3,P2Subchar
  bl  UpdatePosition
#Update ECB Values for the ground ID
  mr r3,P2Subchar
  branchl r12,EnvironmentCollision_WaitLanding
#Set Grounded
  mr r3,P2SubcharData
  branchl r12,Air_SetAsGrounded

MoveCPU_NoFollower:
#Savestate
  mr  r3,SaveStateStruct
  bl  SaveState_Save
#Play SFX
  li r3,0xDD
  bl  PlaySFX
  b MoveCPUExit

MoveCPU_NoGroundFound:
#PLay Error SFX
  li	r3,0xAF
  bl  PlaySFX

MoveCPUNoSubchar:
MoveCPUExit:
restore
blr

############################################

AdjustResetDistance:
.set SaveStateStruct,25
.set P2Direction,3
.set PlayerX,2
.set P1X,31
.set P2X,30

backup

mr  SaveStateStruct,r3

#Make Sure Nothing is Held
  lhz	r3,0x662(r27)
  cmpwi	r3,0x0
  bne	AdjustResetDistance_NoPress


#Check For DPad Right
AdjustResetDistance_CheckRightDPad:
  lwz	r3,0x668(r27)			#Get DPad
  rlwinm.	r0,r3,0,30,30
  beq	AdjustResetDistance_CheckLeftDPad
#Move Apart
#Determine if P2 is to the left or right of P1 + Get X Pos Multiplier
  bl  GetDirectionInRelationToP1
  bl  IntToFloat
  fmr P2Direction,f1
#Load P1 Backup X Location
  lwz	r20,0x0(SaveStateStruct)
  lfs	PlayerX,0xB0(r20)
#Add One in the correct direction
  li	r3,1
  bl	IntToFloat
  fneg P2Direction,P2Direction
  fmuls f1,f1,P2Direction
  fadds	P1X,f1,PlayerX           #New P1 X
#Load P2 Backup X Location
  lwz	r21,0x8(SaveStateStruct)
  lfs	PlayerX,0xB0(r21)
#Add One in the correct direction
  li	r3,1
  bl	IntToFloat
  fneg P2Direction,P2Direction
  fmuls f1,f1,P2Direction
  fadds	P2X,f1,PlayerX            #New P2 X
#Check if already 30 Mm apart
  fsubs f2,P1X,P2X
  fabs f2,f2        #get abs distance from each other in f2
  li	r3,30
  bl	IntToFloat
  fcmpo	cr0,f2,f1
  bge	AdjustResetDistance_NoPress
#Store Back To PlayerBlock
  stfs	P1X,0xB0(r20)
  stfs	P2X,0xB0(r21)
  b	AdjustResetDistance_WasPressed


#Check For DPad Left
AdjustResetDistance_CheckLeftDPad:
  rlwinm.	r0,r3,0,31,31
  beq	AdjustResetDistance_NoPress
#Move Together
#Determine if P2 is to the left or right of P1 + Get X Pos Multiplier
  bl  GetDirectionInRelationToP1
  bl  IntToFloat
  fmr P2Direction,f1
#Load P1 Backup X Location
  lwz	r20,0x0(SaveStateStruct)
  lfs	PlayerX,0xB0(r20)
#Add One in the correct direction
  li	r3,1
  bl	IntToFloat
  #fneg P2Direction,P2Direction
  fmuls f1,f1,P2Direction
  fadds	P1X,f1,PlayerX           #New P1 X
#Load P2 Backup X Location
  lwz	r21,0x8(SaveStateStruct)
  lfs	PlayerX,0xB0(r21)
#Add One in the correct direction
  li	r3,1
  bl	IntToFloat
  fneg P2Direction,P2Direction
  fmuls f1,f1,P2Direction
  fadds	P2X,f1,PlayerX            #New P2 X
#Check if already 10 Mm apart
  fsubs f2,P1X,P2X
  fabs f2,f2        #get abs distance from each other in f2
  li	r3,10
  bl	IntToFloat
  fcmpo	cr0,f2,f1
  ble	AdjustResetDistance_NoPress
#Store Back To PlayerBlock
  stfs	P1X,0xB0(r20)
  stfs	P2X,0xB0(r21)
  b	AdjustResetDistance_WasPressed


AdjustResetDistance_NoPress:
li	r3,-1
b	AdjustResetDistance_Exit

AdjustResetDistance_WasPressed:
li	r3,1

AdjustResetDistance_Exit:
restore
blr
############################################

CheckForActiveHitboxes:
backup

lwz	r31,0x2C(r3)

CheckForActiveHitboxes_InitLoop:
li	r29,0x0

CheckForActiveHitboxes_LoopStart:
lwz	r0, 0x0914 (r31)			#Check Hitbox Active Bool
cmpwi	r0,0x0
beq	CheckForActiveHitboxes_NextHitbox
li	r3,0x1
b	CheckForActiveHitboxes_Exit

CheckForActiveHitboxes_NextHitbox:
addi	r29,r29,1
addi	r31,r31,312			#Next Hitbox Struct
cmpwi	r29,4
blt	CheckForActiveHitboxes_LoopStart

CheckForActiveHitboxes_NoHitboxesActive:
li	r3,0x0

CheckForActiveHitboxes_Exit:

restore
blr

############################################

LegalStages:
blrl
.long 0x1F200802
.long 0x031C0000

TopTiers:
blrl
.long 0x0D02070F
.long 0x10131409
.long 0x0c000000

#############################################

Event_ExitFunction:
blrl

backup

#Ensure No Contest/Retry
lwz	r3, -0x77C0 (r13)
lbz	r3, 0x053B (r3)
rlwinm.	r0, r3, 0, 25, 25
bne	Event_ExitFunction_Exit

#Update Event Score
load	r20,0x8045abf0		#Current Event Info

#Get High Score
lbz	r3,0x5(r20)		#Event ID
branchl	r12,0x8015cf5c
mr	r21,r3		#Backup High Score

#Check If Event Was Played Yet
lbz	r3,0x5(r20)		#Event ID
branchl	r12,0x8015cefc
cmpwi	r3,0x0
beq	Event_ExitFunction_SaveScore

#Check If Greater
lhz	r3,-0x4ea6(r13)		#Current Score
cmpw	r3,r21
ble	Event_ExitFunction_Exit

#Store As New High Score
Event_ExitFunction_SaveScore:
lbz	r3,0x5(r20)		#Event ID
lhz	r4,-0x4ea6(r13)
branchl	r12,0x8015cf70

#Set Event As Played
lbz	r3,0x5(r20)		#Event ID
branchl	r12,0x8015ceb4

Event_ExitFunction_Exit:
restore
blr

#############################################

InitializeHighScore:
backup


	#Create HUD KO Counter
	li	r3,0x0
	branchl	r12,0x802fa5bc

	#Init Score Count
	li	r3,0x0
	stw	r3,-0x4ea8(r13)

	#Store Exit Function
	bl	Event_ExitFunction
	mflr	r3
	load	r4,0x8046b6a0
	stw	r3,0x2518(r4)


restore
blr

#############################################

PerformAerialThink:
#in
#   r3    CPU Player Pointer
#   r4    Pointer to dedicated memory to use
#   r5    Attack to Perform (0 = Random, 1 = Fair, 2 = Nair, 3 = Dair)

.set player,31
.set playerdata,30
.set variables,29
.set frame,28
.set aerialToPerform,27
.set performAerial,0x00
.set aerialAttack,0x01
.set attackFrame,0x02

backup

#Get player pointers and frame count
  mr  player,r3                     #Get Player
  lwz playerdata,0x2C(player)       #Get Playerdata
  mr  variables,r4                  #Get Variable Memory
  lfs	f1,0x894(playerdata)          #Get Frames as Int
  fctiwz	f1,f1
  stfd	f1,0xF0(sp)
  lwz	frame,0xF4(sp)
	mr	aerialToPerform,r5						#Aerial to perform

#Check To Aerial
  lbz r3,performAerial(variables)
  cmpwi r3,0x0
  bne PerformAerialThink_Exit

#Check Which Action to Perform
  lwz r3,0x10(playerdata)   #Get Action State

#Branch To Think Functions
  #During Wait
    cmpwi r3,0xE
    beq PerformAerialThink_DuringWait
  #During Jump
    cmpwi r3,0x19
    beq PerformAerialThink_DuringJump
    cmpwi r3,0x1A
    beq PerformAerialThink_DuringJump
  #During Attack
    cmpwi r3,0x41
    blt 0x10
    cmpwi r3,0x45
    bgt 0x8
    b PerformAerialThink_DuringAttack
  #During Landing
	  cmpwi r3,0x2A
		beq	PerformAerialThink_DuringLanding
    cmpwi r3,0x46
    blt 0x10
    cmpwi r3,0x4A
    bgt 0x8
    b PerformAerialThink_DuringLanding
	#None of The Above
		b PerformAerialThink_Exit



PerformAerialThink_DuringWait:
  #Input Jump
    li	r3,0x800
    stw	r3,0x1A88(playerdata)
  #Determine Which Aerial Attack To Do
	#Check To Randomize
		cmpwi aerialToPerform,0x0
		beq PerformAerialThink_GetRandomAttack
	#Store Attack Chosen
		subi	r3,aerialToPerform,0x1
		stb r3,aerialAttack(variables)
		b	PerformAerialThink_CheckForValidAttack
	PerformAerialThink_GetRandomAttack:
    li	r3,3
  	branchl	r12,HSD_Randi
  	stb r3,aerialAttack(variables)
  #Determine Frame to Attack on
  PerformAerialThink_CheckForValidAttack:
    lwz r4,0x4(playerdata)      #get char ID
    bl  PerformAerial_FrameData
    mflr  r5
    mulli	r4,r4,0xC		#Get Characters Offset
    add	r4,r4,r5		#Get Characters Table Entry Start
    mulli	r3,r3,0x2		#Move Frame Data is 0x2 Long
    add	r27,r3,r4		#Get Moves Frame Data
    lbz	r4,0x0(r27)		#First Possible Frame
    lbz	r5,0x1(r27)		#Last Possible Frame
    cmpwi	r4,0x0
    bne	PerformAerialThink_GetRandomFrame
    cmpwi	r5,0x0
    bne	PerformAerialThink_GetRandomFrame
  #Move Disabled For Char, Get a New One
    b	PerformAerialThink_GetRandomAttack
  PerformAerialThink_GetRandomFrame:
    sub	r3,r5,r4		#Get Amount of Possibilities
    branchl	r12,HSD_Randi		#Get Random Frame
    lbz	r4,0x0(r27)		#First Possible Frame
    add	r3,r3,r4		#Adjust for First Possible Frame
    stb	r3,attackFrame(variables)		#Store Frame to Attack on
  b PerformAerialThink_Exit

PerformAerialThink_DuringJump:
  #Check To Attack
    lbz r3,attackFrame(variables)
    cmpw r3,frame
    bne PerformAerialThink_InputFastfallAndLCancel

  #Perform Attack
    lbz	r3,aerialAttack(variables)		#Get Attack ID
    cmpwi	r3,0x0
    beq	PerformAerialThink_Fair
    cmpwi	r3,0x1
    beq	PerformAerialThink_Nair
    cmpwi	r3,0x2
    beq	PerformAerialThink_Dair

    PerformAerialThink_Fair:
      li	r3,127		            #Forward
      lfs	f1,0x2C(playerdata)		#Facing Direction
      fctiwz	f1,f1
      stfd	f1,0xF0(sp)
      lwz	r4,0xF4(sp)
      mullw	r3,r3,r4		         #Forward * facing direction
      stb	r3,0x1A8E(playerdata)
      b	PerformAerialThink_InputFastfallAndLCancel

    PerformAerialThink_Nair:
      li	r3,0x100
      stw	r3,0x1A88(playerdata)
      b	PerformAerialThink_InputFastfallAndLCancel

    PerformAerialThink_Dair:
      li	r3,-127
      stb	r3,0x1A8F(playerdata)
      b	PerformAerialThink_InputFastfallAndLCancel

b PerformAerialThink_InputFastfallAndLCancel

PerformAerialThink_DuringAttack:
b PerformAerialThink_InputFastfallAndLCancel

PerformAerialThink_DuringLanding:
#Set Sequence as Over
  li  r3,1
  stb r3,performAerial(variables)
  b PerformAerialThink_Exit

PerformAerialThink_InputFastfallAndLCancel:
#Input Fastfall
	#Check If Already FastFalling
		lbz	r3,0x221A(playerdata)
		rlwinm.	r3,r3,0,28,28
		bne	PerformAerialThink_InputLCancel
  #Check If Falling
    lfs	f2,0x84(playerdata)
    lfs	f0, -0x76B0 (rtoc)
    fcmpo	cr0,f2,f0
    bge	PerformAerialThink_InputLCancel
  #Check If Inputting A Nair
    lwz	r3,0x1A88(playerdata)
    cmpwi	r3,0x100
    beq	PerformAerialThink_InputLCancel
  #Input Down to FF
    li	r3,-127
    stb	r3,0x1A8D(playerdata)		#Analog Y

  PerformAerialThink_InputLCancel:
  #Spoof Mash L
   li r3,0x1
   stb r3,0x67F(playerdata)

b PerformAerialThink_Exit

#################################

PerformAerial_FrameData:
blrl
#Mario
.long 0x00040012		#Fair and Nair
.long 0x00100005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Fox
.long 0x0009000A		#Fair and Nair
.long 0x00080005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Cptn Falcon
.long 0x0006000E		#Fair and Nair
.long 0x00040005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#DK
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Kirby
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Bowser
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#link
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Sheik
.long 0x10140018		#Fair and Nair
.long 0x00000005		#Dar (was 0-A) and UAir
.long 0x0005FFFF    #Bair and Nothing

#Ness
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Peach
.long 0x000D001A		#Fair and Nair
.long 0x000E0005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Popo
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Nana
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Pikachu
.long 0x000C000F		#Fair and Nair
.long 0x00080005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Samus
.long 0x00200020		#Fair and Nair
.long 0x080D0005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Yoshi
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Jiggs
.long 0x00100010		#Fair and Nair
.long 0x00100005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#mewtwo
.long 0x00050019		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Luigi
.long 0x0017001B		#Fair and Nair
.long 0x00110005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Marth
.long 0x00160013		#Fair and Nair
.long 0x00120005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Zelda
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#YLink
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Doc
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Falco
.long 0x070B000D		#Fair and Nair
.long 0x000C0005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Pichu
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#GaW
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Ganon
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

#Roy
.long 0x00050005		#Fair and Nair
.long 0x00050005		#Dar and UAir
.long 0x0005FFFF    #Bair and Nothing

####################################

PerformAerialThink_Exit:
  restore
  blr

#####################################
RandFloat:
#in
#r3 = Rand Float Lower Bound
#r4 = Rand Float Upper Bound

backup
stfs	f31,0x80(sp)

mr	r31,r3

#Get Random Upper Bound
	sub	r3,r4,r31
	branchl r12,HSD_Randi
#Add Lower Bound
	add	r3,r3,r31
#Convert to Float
	bl	IntToFloat
	fmr	f31,f1
#Get Random Float
	branchl r12,HSD_Randf
	fadds	f1,f1,f31

lfs	f31,0x80(sp)
restore
blr

#####################################
Custom_InterruptRebirthWait:
blrl
.set player,31
.set playdata,30

backup

#Get Pointers
	mr	player,r3
	lwz	playerdata,0x2C(player)

#Check For Aerial Jump
	mr	r3,player
	branchl r12,0x800cb870
	cmpwi r3,0x0
	bne Custom_InterruptRebirthWait_Exit

#Ensure Stick Was Just Moved
	lbz	r3, 0x0670 (playerdata)
	cmpwi r3,2
	bge	Custom_InterruptRebirthWait_CheckJoystickDown
#Check For Any X Joystick Push
	lwz	r3, -0x514C (r13)
	lfs	f0, 0x0024 (r3)
	lfs	f1, 0x0620 (playerdata)
	fabs	f1,f1
	fcmpo	cr0,f1,f0
	cror	2, 1, 2
	beq	Custom_InterruptRebirthWait_EnterFall
Custom_InterruptRebirthWait_CheckJoystickDown:
#Ensure Stick Was Just Moved
	lbz	r3, 0x0671 (playerdata)
	cmpwi r3,4
	bge	Custom_InterruptRebirthWait_Exit
#Check For Down Joystick Push
	lwz	r3, -0x514C (r13)
	lfs	f0, 0x0090 (r3)
	fneg f0,f0
	lfs	f1, 0x0624 (playerdata)
	fcmpo	cr0,f1,f0
	blt	Custom_InterruptRebirthWait_EnterFall
	b	Custom_InterruptRebirthWait_Exit

Custom_InterruptRebirthWait_EnterFall:
#Enter Fall
	mr r3,player
	branchl r12,AS_Fall

Custom_InterruptRebirthWait_Exit:
	restore
	blr

#####################################
UpdatePosition:
.set PlayerGObj,31
.set PlayerData,30

backup

#Backup Pointer
  mr  PlayerGObj,r3
  lwz PlayerData,0x2C(PlayerGObj)

#Update Position (Copy Physics XYZ into all ECB XYZ)
  lwz	r3, 0x00B0 (PlayerData)
  stw	r3, 0x06F4 (PlayerData)
  stw	r3, 0x070C (PlayerData)
  lwz	r3, 0x00B4 (PlayerData)
  stw	r3, 0x06F8 (PlayerData)
  stw	r3, 0x0710 (PlayerData)
  lwz	r3, 0x00B8 (PlayerData)
  stw	r3, 0x06FC (PlayerData)
  stw	r3, 0x0714 (PlayerData)

#Update Collision Frame ID
  lwz	r3, -0x51F4 (r13)
  stw r3, 0x728(PlayerData)

  #branchl	r12,0x80081b38     #Stopped using this because it deletes way too much ECB info
  #branchl r12,0x80082a68      #Better than the above function, but all i need is to copy current position into the ECB previous values
#Update Static Player Block Coords
  lbz r3,0xC(PlayerData)
  lbz	r4, 0x221F (PlayerData)
  rlwinm	r4, r4, 29, 31, 31
  addi  r5,PlayerData,176
  branchl r12,0x80032828

restore
blr

#####################################

GetGroundCenter:

#in
#r3 = Ground ID

#Get Corner IDs from Ground ID
mulli r0,r3,8
lwz	r5, -0x51E4 (r13)
lwzx r5,r5,r0
lhz r3,0x0(r5)
lhz r4,0x2(r5)

#Get Coordinates
lwz r5, -0x51E8 (r13)
mulli r3,r3,24
addi  r3,r3,8
add  r3,r3,r5
lfs f1,0x0(r3)    #Left X
lfs f2,0x4(r3)    #Left Y
mulli r4,r4,24
addi  r4,r4,8
add  r4,r4,r5
lfs f3,0x0(r4)    #Right X
lfs f4,0x4(r4)    #Right Y

#Get Center Value
lfs f5,-0x4df0(rtoc)    #2f
fadds f1,f1,f3
fdivs f1,f1,f5          #Center X
fadds f2,f2,f4
fdivs f2,f2,f5          #Center Y

blr

####################################

PlacePlayersCenterStage:

#in
#none

backup

#Loop through players 1 and 2
  .set count,27
  .set player,26
  .set playerdata,25
  .set subchar,24
  .set subchardata,23

  li  count,0

PlacePlayersCenterStage_Loop:
#Get Player GObj
  mr  r3,r27
  branchl r12,PlayerBlock_LoadMainCharDataOffset
#Check if exists
  cmpwi r3,0x0
  beq PlacePlayersCenterStage_IncLoop
  mr  player,r3
  lwz playerdata,0x2C(player)
#Get Subchar Bool
  bl CheckIfPlayerHasAFollower
  mr  subchar,r3
  mr  subchardata,r4
#Call function to do heavy lifting
  mr  r3,player
  bl  PlacePlayersCenterStage_DoStuff
#Check if subchar exits
  cmpwi subchar,0
  beq PlacePlayersCenterStage_IncLoop
#Call function for this character
  mr  r3,subchar
  bl  PlacePlayersCenterStage_DoStuff
#Next Player
PlacePlayersCenterStage_IncLoop:
  addi count,count,1
  cmpwi count,6
  blt PlacePlayersCenterStage_Loop
  b PlacePlayersCenterStage_Exit

#*****************************#
PlacePlayersCenterStage_DoStuff:
#in
#r3 = player

.set player,31
.set playerdata,30
.set constants,29

backup

#Get Pointers
  mr  player,r3
  lwz playerdata,0x2C(r3)

#Get Constants
  bl  PlacePlayersCenterStage_Constants
  mflr constants
  lbz r3,0xC(playerdata)
  mulli r3,r3,0x2
  add constants,constants,r3

#Initialize Player Data (Mainly for ICs so Nana knows where Popo is)
  mr  r3,player
  branchl r12,0x80068354

#Get Stage's Ground ID
  lwz		r3,-0x6CB8 (r13)			#External Stage ID
  bl		ComboTraining_StartingGroundIDs
  mflr  r4
  mulli	r3,r3,0x2
  lhzx	r3,r3,r4
  bl  GetGroundCenter
  fmr f30,f1
  fmr f31,f2

#Facing Directions
  lbz r3,0x0(constants) #This players facing direction
  extsb r3,r3
  bl  IntToFloat
  stfs f1,0x2C(playerdata)

#Move Players
  lbz r3,0x1(constants) #This players X offset
  extsb r3,r3
  bl  IntToFloat
  fadds f2,f1,f30   #Player X = X+6
  stfs f2,0xB0(playerdata)
  stfs f31,0xB4(playerdata)

#Enter into Wait
  mr  r3,player
  branchl r12,AS_Wait
#Find Ground Below Player
  mr  r3,player
  bl  FindGroundNearPlayer
  cmpwi r3,0    #Check if ground was found
  beq PlacePlayersCenterStage_DoStuff_SkipGroundCorrection
  stfs f1,0xB0(playerdata)
  stfs f2,0xB4(playerdata)
  stw r4,0x83C(playerdata)
  PlacePlayersCenterStage_DoStuff_SkipGroundCorrection:
#Update Position
  mr  r3,player
  bl  UpdatePosition
#Update ECB Values for the ground ID
  mr r3,player
  branchl r12,EnvironmentCollision_WaitLanding
#Set Grounded
  mr r3,playerdata
  branchl r12,Air_SetAsGrounded
#Update Camera
  mr r3,player
  bl  UpdateCameraBox

PlacePlayersCenterStage_DoStuff_Exit:
restore
blr

#*********#

PlacePlayersCenterStage_Constants:
blrl
.byte 1,-6,-1,6
.align 2
#*********#

PlacePlayersCenterStage_Exit:
restore
blr

#####################################

FindGroundNearPlayer:
#in
#r3 = player GObj (optional)
#f1 = X value
#f2 = Y Value


.set player,31
.set playerdata,30

backup
stfs f30,0x38(sp)
stfs f31,0x3C(sp)

#Check If Given Player GObj
  cmpwi r3,0x0
  bne FindGroundNearPlayer_GObjPassedIn

FindGroundNearPlayer_CoordinatesPassedIn:
#Backup Coords
  fmr f30,f1
  fmr f31,f2
#Get 10f
  li  r3,10
  bl  IntToFloat
#Get Bottom Coord
  fmr f3,f30       #Bottom X is same as Top X
  fsubs f4,f31,f1  #Bottom Y is Top Y - 1000
#Move Top Coords Back
  fmr f1,f30
  fmr f2,f31
  lfs	f0, -0x7188 (rtoc)
  fadds f2,f2,f0
  b FindGroundNearPlayer_Continue


FindGroundNearPlayer_GObjPassedIn:
#Init Variables
  mr  player,r3
  lwz playerdata,0x2C(player)
#Get Players X and Y+10
  lfs f1,0xB0(playerdata)
  lfs f2,0xB4(playerdata)
  lfs	f0, -0x7188 (rtoc)
  fadds f2,f2,f0
#Get Bottom Coord (X and Y-1000)
  lfs f3,0xB0(playerdata)
  lfs f4,0xB0(playerdata)
  lfs	f0,-0x71A8 (rtoc)
  fsubs f4,f4,f0

FindGroundNearPlayer_Continue:
#Get Unk f5 argument
  lfs	f5, -0x7208 (rtoc)
#Setup stack for return values
  addi r3,sp,0x54   #(Returns Ground Coordinates
  addi r4,sp,0x44   #(Returns Ground ID)
  addi r5,sp,0x40   #(Returns Ground Type)
  addi r6,sp,0x48   #(Returns Unk)
#Unk arguments
  li  r7,-1
  li  r8,-1
  li  r9,-1
#Additional function pointer
  li  r10,0
#Call function
  branchl r12,GroundRaycast

#Check if ground exists
  cmpwi r3,0
  beq FindGroundNearPlayer_Exit

#Return Coordinates of ground below player
  lfs f1,0x54(sp)
  lfs f2,0x58(sp)
  lwz r4,0x44(sp)

FindGroundNearPlayer_Exit:
lfs f30,0x38(sp)
lfs f31,0x3C(sp)
restore
blr

#####################################

FindGroundUnderCoordinate:
#in
#f1 = X value
#f2 = Y Value

backup
stfs f30,0x38(sp)
stfs f31,0x3C(sp)

FindGroundUnderCoordinate_CoordinatesPassedIn:
#Backup Coords
  fmr f30,f1
  fmr f31,f2
#Get 1000f
  li  r3,1000
  bl  IntToFloat
#Get Bottom Coord
  fmr f3,f30       #Bottom X is same as Top X
  fsubs f4,f31,f1  #Bottom Y is Top Y - 1000
#Move Top Coords Back
  fmr f1,f30
  fmr f2,f31

FindGroundUnderCoordinate_Continue:
#Get Unk f5 argument
  lfs	f5, -0x7208 (rtoc)
#Setup stack for return values
  addi r3,sp,0x54   #(Returns Ground Coordinates
  addi r4,sp,0x44   #(Returns Ground ID)
  addi r5,sp,0x40   #(Returns Ground Type)
  addi r6,sp,0x48   #(Returns Unk)
#Unk arguments
  li  r7,-1
  li  r8,-1
  li  r9,-1
  li  r10,0
#Call function
  branchl r12,GroundRaycast

#Check if ground exists
  cmpwi r3,0
  beq FindGroundUnderCoordinate_Exit

#Return Coordinates of ground below player
  lfs f1,0x54(sp)
  lfs f2,0x58(sp)
  lwz r4,0x44(sp)

FindGroundUnderCoordinate_Exit:
lfs f30,0x38(sp)
lfs f31,0x3C(sp)
restore
blr

#####################################
PlaySFX:
backup

branchl		r12,SFX_PlaySoundAtFullVolume

restore
blr
#####################################

UpdateCameraBox:
#in
#r3 = player

.set player,31
.set playerdata,30

backup

#Get Pointer
  mr  player,r3
  lwz playerdata,0x2C(player)

#Update Camera Box Position
  mr  r3,player
  branchl r12,Camera_UpdatePlayerCameraBoxPosition

#Update Camera Box Direction Tween
#  lwz r3,0x2C(player)
#  branchl r12,0x80076064

#Update Camera Box Direction Tween
  lwz r3,0x890(playerdata)
  lfs f1,0x40(r3)     #Leftmost Bound
  stfs f1,0x2C(r3)    #Current Left Box Bound
  lfs f1,0x44(r3)     #Rightmost Bound
  stfs f1,0x30(r3)    #Current Right Box Bound

#Correct Camera Position
  branchl r12,Camera_CorrectPosition

restore
blr

#####################################

GetAllPlayerPointers:

#in
#nothing

#out
#r3 = P1GObj
#r4 = P1Data
#r5 = P2GObj
#r6 = P2Data
#r7 = P3GObj
#r8 = P3Data
#r9 = P4GObj
#r10 = P4Data

backup

#Get Space to Store all Pointer to
  addi r21,sp,0x40
#Init Loop Count
  li  r20,0

GetAllPlayerPointers_Loop:
#Get GObj
  mr  r3,r20
  branchl r12,PlayerBlock_LoadMainCharDataOffset
#Check If Exists
  cmpwi r3,0x0
  li    r4,0      #Zero Data pointer just in case it doesnt exist
  beq GetAllPlayerPointers_StoreToStack
#Get Data
  lwz r4,0x2C(r3)
#Store Both to Stack
GetAllPlayerPointers_StoreToStack:
  mulli r5,r20,8
  add r5,r5,r21
  stw r3,0x0(r5)
  stw r4,0x4(r5)

GetAllPlayerPointers_IncLoop:
  addi r20,r20,1
  cmpwi r20,4
  blt GetAllPlayerPointers_Loop

GetAllPlayerPointers_LoadPointers:
  lwz r3,0x00(r21)
  lwz r4,0x04(r21)
  lwz r5,0x08(r21)
  lwz r6,0x0C(r21)
  lwz r7,0x10(r21)
  lwz r8,0x14(r21)
  lwz r9,0x18(r21)
  lwz r10,0x1C(r21)

GetAllPlayerPointers_Exit:
restore
blr

#####################################
RemoveFirstFrameInputs:

RemoveFirstFrameInputs_GetFirstPlayer:
  lwz	r3, -0x3E74 (r13)
  lwz	r12, 0x0020 (r3)
  b	RemoveFirstFrameInputs_CheckIfPlayerExists

RemoveFirstFrameInputs_GetNextPlayer:
  lwz	r12,0x8(r12)

RemoveFirstFrameInputs_CheckIfPlayerExists:
  cmpwi	r12,0x0
  beq	RemoveFirstFrameInputs_Exit
  lwz	r5,0x2C(r12)

#Remove Input Flag
  lbz	r0, 0x221D (r27)
  li	r3,0x1
  rlwimi	r0,r3,4,27,27
  stb	r0,0x221D (r27)
#Store Current Input
  lbz	r4, 0x0618 (r5)
  load r3,InputStructStart
  mulli	r0, r4, 68
  add	r3, r0, r3
  lwz	r0, 0 (r3)
  stw	r0, 0x065C (r5)
  b	RemoveFirstFrameInputs_GetNextPlayer

RemoveFirstFrameInputs_Exit:
blr

#####################################
exit:
li	r0, 3
