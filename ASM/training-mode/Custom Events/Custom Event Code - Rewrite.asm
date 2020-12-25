#To be inserted at 801bb128
.include "../Globals.s"
.include "../../m-ex/Header.s"

# Check if event is legacy (no file)
  lwz r3,MemcardData(r13)
  lbz r3,CurrentEventPage(r3)
  mr	r4,r25									#event
  mr	r5,r26									#match struct
  rtocbl	r12,TM_GetEventFile
  cmpwi r3,0
  beq LegacyEvent
	
#Branch to C function to initialize the event
  lwz r3,MemcardData(r13)
  lbz r3,CurrentEventPage(r3)
  mr	r4,r25									#event
  mr	r5,r26									#match struct
  rtocbl	r12,TM_EventInit
  branch	r12,0x801bb738

LegacyEvent:
#r25 = event ID
#r26 = final match struct
#r28 = same as r26
#r29 = event struct index (0x0 of this, then 0x8 of that to get the specifics)

#region Event and Menu GObj Data Structs
#Event GObj Data Struct
.set EventData_DataSize,0x50
.set EventData_MenuDataPointer,(EventData_DataSize-0x4)
.set EventData_SaveStateStruct,0x10

#Menu GObj Data Struct
.set MenuData_DataSize,0x50
.set MenuData_EventDataPointer,(MenuData_DataSize-0x4)
.set MenuData_WindowOptionCountPointer,0x0
.set MenuData_ASCIIStructPointer,0x4
.set MenuData_OptionMenuMemory,0x8
.set MenuData_OptionMenuToggled,0x28
#endregion

#region Init Custom Event
#################
## Custom Code ##
#################

#all registers free

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

	#P1 = Choose Char + Normal Modifiers
	bl	P1Struct
	mflr	r3
	stw	r3,0x14(r9)

	#STORE MATCH SETTINGS
	load	r3,0x0BB0027C		#HUD and timer behavior
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

  #SET FFA FLAG
  li  r3,0
  stb r3,0x8(r26)

  #Store SSS Stage
  load	r3,0x80497758
  lha	r4, 0x001E (r3)
  sth	r4,0xE(r26)

#Get Event Code
  bl  SkipPageList

##### Page List #######
	EventJumpTable
#######################
Minigames:
bl	Eggs
bl	Multishine
bl	Reaction
bl	LedgeStall
.long -1
#######################
GeneralTech:
bl	TrainingLab
bl	LCancel
bl	Ledgedash
bl	0x0	# wavedash
bl	ComboTraining
bl	AttackOnShield
bl	Reversal
bl	SDITraining
bl	Powershield
bl	Ledgetech
bl	AmsahTech
bl	ShieldDrop
bl	WaveshineSDI
bl	SlideOff
bl	GrabMashOut
.long -1
#######################
SpacieTech:
bl  LedgetechCounter
bl	ArmadaShine
bl	SideBSweetspot
bl	EscapeSheik
.long -1
#######################

SkipPageList:
#Get Page Jump Table
  mflr	r4		#Jump Table Start in r4
#Get Current Page
  lwz r3,MemcardData(r13)
  lbz r3,CurrentEventPage(r3)
  mulli	r5,r3,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r4,r4,r5		#Gets ASCII Address in r4
#Get Event Code Pointer
  mulli	r5,r25,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
	cmpwi r5,-1
	beq	EventNoExist
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r4,r4,r5		#Gets ASCII Address in r4
  mtctr	r4
  bctr

EventNoExist:
	b	exit
#endregion

###############
## Minigames ##
###############

#region Eggs-ercise
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

#1 Player
	lwz r4,0x0(r29)
	li	r3,0x20
	stb	r3,0x1(r4)

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
    #r3 = function to run each frame
    #r4 = priority
    #r5 = pointer to Window and Option Count
    #r6 = pointer to ASCII struct
	bl	EggsThink
	mflr	r3
	li	r4,9		#Priority (After Interrupt)
  bl	EggsWindowInfo
  mflr	r5
  bl	EggsWindowText
  mflr	r6
	bl	CreateEventThinkFunction

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
		.set	DamageThreshold,(MenuData_OptionMenuMemory+0x2) +0x0
		.set	DamageThresholdToggled,(MenuData_OptionMenuToggled) +0x0

		EggsThink:
		blrl
		backup

		#Get and Backup Event Data
		mr	r30,r3			#r30 = think entity
		lwz	EventData,0x2c(r3)			#backup data pointer in r31
    lwz MenuData,EventData_MenuDataPointer(EventData)

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

    .set EggSpawnGroundWidth,8
    #Check If Egg is Above Ground
      fmr f1,f21
      fmr f2,f22
      bl  FindGroundUnderCoordinate
      cmpwi r3,0x0
      beq EggsThinkSpawnLoop
    #Check Left
      li  r3,EggSpawnGroundWidth
      bl  IntToFloat
      fsubs f1,f21,f1
      fmr f2,f22
      bl  FindGroundUnderCoordinate
      cmpwi r3,0x0
      beq EggsThinkSpawnLoop
    #Check Right
      li  r3,EggSpawnGroundWidth
      bl  IntToFloat
      fadds f1,f21,f1
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
			bl	Eggs_OnCollision
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


			Eggs_OnCollision:
			blrl

      #First check if this is an event
        load r4,SceneController
        lbz r4,Scene.CurrentMajor(r4)
        cmpwi r4,Scene.EventMode
        bne Eggs_OnCollisionOriginalFunction
      #Now check if its eggs-ercise
        lwz	r4, -0x77C0 (r13)
        lbz	r4, 0x0535 (r4)         #get event ID
        cmpwi r4,Event_Eggs
        beq Eggs_OnCollisionStart

      Eggs_OnCollisionOriginalFunction:
      #Go to the original egg break function
        branch r12,ItemCollision_Egg

      Eggs_OnCollisionStart:
  			backup
  			mr	r30,r3
  			lwz	r31,0x2C(r3)			#Get Data

			#Check If Any Attack Should Break
  			lwz	r3,0xDDC(r31)			         #Get Event Data
        lwz r3,EventData_MenuDataPointer(r3)     #Get Menu Data
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

#endregion

#region Multishine
#########################
## Multishine HIJACK INFO ##
#########################

Multishine:
#COUNT DOWN TIME
	li	r3,0x6
	stb	r3,0x0(r26)

#10 Seconds On the Clock
	li	r3,10
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

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)							#Send event struct
	mr	r4,r26									#Send match struct
	li	r5,-1										#Use chosen CPU
	li	r6,FinalDestination			#Use FD
	load r7,EventOSD_Multishine
	li	r8,0										#Use Sopo Bool
	bl	InitializeMatch

#1 Player
	lwz r4,0x0(r29)
	li	r3,0x20
	stb	r3,0x1(r9)

#STORE THINK FUNCTION
	bl	MultishineLoad
	mflr	r3
	stw	r3,0x44(r26)		#on match load

b	exit


	########################
	## Multishine LOAD FUNCT ##
	########################
	MultishineLoad:
	blrl

	backup

	#Schedule Think
	bl	MultishineThink
	mflr	r3
	li	r4,17		#Priority (After Everything)
  li  r5,0    #No Option Menu
	li	r6,0
	bl	CreateEventThinkFunction

	bl	InitializeHighScore

	b	MultishineLoadExit

		#########################
		## Multishine THINK FUNCT ##
		#########################

		MultishineThink:
		blrl

    .set EventData,31
    .set Event,30
    .set P1Data,27
    .set P1GObj,28

		backup

		mr	Event,r3
		lwz	EventData,0x2c(Event)

    bl GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4

	#First Frame Actions
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	MultishineNotFirstFrame
  #Init Positions
    bl  PlacePlayersCenterStage
	MultishineNotFirstFrame:

	#Check for grounded or aerial shine, frame 1
		lwz r3,0x10(P1Data)
		cmpwi r3,0x168
		beq Multishine_IsShining
		cmpwi r3,0x16D
		beq Multishine_IsShining
		b	Multishine_SkipShineCheck
	Multishine_IsShining:
	#Check for frame 1
		lhz r3,TM_FramesinCurrentAS(P1Data)
		cmpwi r3,0
		bne Multishine_SkipShineCheck
	#Increment Score
  	li	r3,0
  	li	r4,0
  	li	r5,5
  	branchl	r12,Playerblock_StoreTimesR3KilledR4
	Multishine_SkipShineCheck:

	#Check For TimeUp
  	branchl	r12,MatchInfo_LoadSeconds		#Seconds Left
    cmpwi	r3,0x0
    bne	MultishineThinkExit
    branchl	r12,MatchInfo_LoadSubSeconds		#Sub-Seconds Left
    cmpwi	r3,59
    bne	MultishineThinkExit
  #On Event End
    mr	r3,Event
    branchl	r12,EventMatch_OnWinCondition			#EventMatch_OnWinCondition

	MultishineThinkExit:
  #Update HUD Score
  	li	r3,0
  	li	r4,5
    branchl	r12,Playerblock_LoadTimesR3KilledR4
    branchl	r12,HUD_KOCounter_UpdateKOs

	MultishineLoadExit:
	restore
	blr




################################################################################
################################################################################
#endregion

#region Reaction
#########################
## Reaction HIJACK INFO ##
#########################

Reaction:
#SET EVENT TYPE TO KOs
	load	r5,0x8045abf0		#Static Match Struct
	lbz	r3,0xB(r5)		#Get Event Score Behavior Byte
	li	r4,0x0
	rlwimi	r3,r4,1,30,30		#Zero Out Time Bit
	stb	r3,0xB(r5)		#Set Event Score Behavior Byte

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)							#Send event struct
	mr	r4,r26									#Send match struct
	li	r5,Fox.Ext							#Use chosen CPU
	li	r6,FinalDestination			#Use FD
	load r7,EventOSD_Reaction
	li	r8,0										#Use Sopo Bool
	bl	InitializeMatch

#STORE THINK FUNCTION
	bl	ReactionLoad
	mflr	r3
	stw	r3,0x44(r26)		#on match load

b	exit


	########################
	## Reaction LOAD FUNCT ##
	########################
	ReactionLoad:
	blrl

	backup

	#Schedule Think
	bl	ReactionThink
	mflr	r3
	li	r4,3		#Priority (Interrupt)
  li  r5,0    #No Option Menu
	li	r6,0
	bl	CreateEventThinkFunction

	b	ReactionLoadExit

		#########################
		## Reaction THINK FUNCT ##
		#########################

		ReactionThink:
		blrl

    .set EventData,31
    .set Event,30
    .set P1Data,27
    .set P1GObj,28
    .set P2Data,29
    .set P2GObj,30

		#Constants
		.set ShineTimerMax,7*60
		.set ShineTimerMin,3*60
		.set ResetTimer,1*60

		#GObj Data Offsets
		.set OFST_ShineTimer,0x0
		.set OFST_ResetTimer,0x2
		.set OFST_ReactionTimer,0x4


		backup

		mr	Event,r3
		lwz	EventData,0x2c(Event)

    bl	GetAllPlayerPointers
    mr	P1GObj,r3
    mr	P1Data,r4
    mr	P2GObj,r5
    mr	P2Data,r6

	#First Frame Actions
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	ReactionNotFirstFrame
  #Init Positions
    bl  PlacePlayersCenterStage
	#Savestate
		addi r3,EventData,EventData_SaveStateStruct
		li	r4,1
		bl	SaveState_Save
	#Set Initial Timer
		li	r3,ShineTimerMax - ShineTimerMin
		branchl r12,HSD_Randi
		addi r3,r3,ShineTimerMin
		sth r3,OFST_ShineTimer(EventData)
	#Initialize Reaction Timer
		li	r3,-1
		sth r3,OFST_ReactionTimer(EventData)
	#Stop Music
		li	r3,0
		li	r4,2
		branchl r12,0x80025064
	ReactionNotFirstFrame:

		bl	StoreCPUTypeAndZeroInputs

	#Give Intangibility to both chars
		mr	r3,P1GObj
		li	r4,1
		branchl r12,ApplyIntangibility
		mr	r3,P2GObj
		li	r4,1
		branchl r12,ApplyIntangibility

	#Check post countdown timer
		lhz r3,OFST_ResetTimer(EventData)
		cmpwi r3,0
		ble Reaction_SkipResetTimer
	#Dec timer, if 0 reset
		subi r3,r3,1
		sth r3,OFST_ResetTimer(EventData)
		cmpwi r3,0
		beq Reaction_Reset
		b	ReactionThinkExit
	Reaction_SkipResetTimer:

	#Check shine countdown timer
		lhz r3,OFST_ShineTimer(EventData)
		cmpwi r3,0
		ble Reaction_SkipShineTimer
	#Dec timer, if 0 perform move
		subi r3,r3,1
		sth r3,OFST_ShineTimer(EventData)
		cmpwi r3,0
		bgt ReactionThink_CheckIfActedEarly
	#Perform down b
		mr	r3,P2GObj
		branchl r12,0x800e8560
	#Start reaction timer
		li	r3,0
		sth	r3,OFST_ReactionTimer(EventData)
		b	ReactionThinkExit

ReactionThink_CheckIfActedEarly:
	#Check if P1 acted early
		lwz	r3,0x10(P1Data)
		cmpwi r3,ASID_Wait
		beq ReactionThinkExit
	#Play Error Noise
		li	r3,0xAF
		bl	PlaySFX
	#Set Timer
		li	r3,ResetTimer-40
		sth r3,OFST_ResetTimer(EventData)
		b	ReactionThinkExit

Reaction_SkipShineTimer:

	#Check reaction timer
		lhz r3,OFST_ReactionTimer(EventData)
		extsh r3,r3
		cmpwi r3,0
		blt Reaction_SkipReactionTimer
	#Poll Inputs Again
		#branchl r12,0x80377ce8
	#Check if P1 Reacted
		lbz r3,0x618(P1Data)
		load r4,InputStructStart
		mulli	r3,r3,68
		add	r3,r3,r4
		lwz r3,0x8(r3)
		cmpwi r3,0
		beq Reaction_SkipReactionTimer
	#Output reaction time
		mr	r3,P1Data			#p1 (no offsetting window)
		li	r4,120			#text timeout
		li	r5,0			#Area to Display (0-2)
		li	r6,OSD.Miscellaneous			#Window ID (Unique to This Display)
		branchl	r12,TextCreateFunction			#create text custom function
		mr	r20,r3			#backup text pointer
	#Decide Color
		lhz r3,OFST_ReactionTimer(EventData)
		cmpwi	r3,15
		ble	Reaction_Good
	Reaction_Bad:
		load	r3,0xffa2baff			#Red
		b	Reaction_StoreTextColor
	Reaction_Good:
		load	r3,0x8dff6eff			#green
	Reaction_StoreTextColor:
		stw	r3,0x30(r20)

	#Create Text 1
		mr 	r3,r20			#text pointer
		bl	Reaction_TopText
		mflr	r4
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B4 (rtoc)			#default text X/Y
		branchl r12,Text_InitializeSubtext

	#Create Text 2
		mr 	r3,r20			#text pointer
		bl	Reaction_BottomText
		mflr	r4
		lhz	r5,OFST_ReactionTimer(EventData)
		addi r5,r5,1								#0-index is scary
		lfs	f1, -0x37B4 (rtoc)			#default text X/Y
		lfs	f2, -0x37B0 (rtoc)			#default text X/Y
		branchl r12,Text_InitializeSubtext

	#Start post countdown timer
		li	r3,ResetTimer
		sth r3,OFST_ResetTimer(EventData)
		b	ReactionLoadExit
	Reaction_SkipReactionTimer:
	#Inc timer
		lhz r3,OFST_ReactionTimer(EventData)
		addi r3,r3,1
		sth r3,OFST_ReactionTimer(EventData)
		b	ReactionThinkExit

	Reaction_Reset:
	#Load State
		addi r3,EventData,EventData_SaveStateStruct
		bl	SaveState_Load
	#Reset Variables
	#Set Initial Timer
		li	r3,ShineTimerMax - ShineTimerMin
		branchl r12,HSD_Randi
		addi r3,r3,ShineTimerMin
		sth r3,OFST_ShineTimer(EventData)
	#Reset Timer
		li	r3,0
		sth	r3,OFST_ResetTimer(EventData)
	#Initialize Reaction Timer
		li	r3,-1
		sth r3,OFST_ReactionTimer(EventData)

	ReactionThinkExit:
	ReactionLoadExit:
	restore
	blr

Reaction_TopText:
blrl
.string "Reaction Time:"
.align 2

Reaction_BottomText:
blrl
.string "%d Frames"
.align 2

################################################################################
################################################################################
#endregion

#region Ledge Stall
###########################
## Ledge Stall HIJACK INFO ##
###########################

LedgeStall:
#Store Match Type to READY, GO!
	li	r3,0x80
	stb	r3,0x1(r26)

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)										#Send event struct
	mr	r4,r26												#Send match struct
	li	r5,-1
	li	r6,Brinstar										#stage
	load r7,EventOSD_LedgeStall
	li	r8,1										#Use Sopo bool
	bl	InitializeMatch

#1 Player
	lwz r4,0x0(r29)
	li	r3,0x20
	stb	r3,0x1(r4)

#STORE THINK FUNCTION
LedgeStallStoreThink:
	bl	LedgeStallLoad
	mflr	r3
	stw	r3,0x44(r26)		#on match load

b	exit

##################################
## 			Ledge Stall LOAD FUNCT 		##
##################################
LedgeStallLoad:
	blrl

	backup

#Schedule Think
	bl	LedgeStallThink
	mflr	r3
	li	r4,3		#Priority (After EnvCOllision)
  li  r5,0
	bl	CreateEventThinkFunction

#Destroy Lava map_gobj proc
	li	r3,8				#lava's map_gobj ID
	branchl r12,Stage_map_gobj_Load
	branchl r12,GObj_RemoveProc
/*
#Make Lava transparent
	li	r3,8				#lava's map_gobj ID
	branchl r12,Stage_map_gobj_Load
	li	r4,0
	branchl r12,Stage_map_gobj_LoadJObj
	li	r5,1
	lwz r4,0x14(r3)
	rlwimi r4,r5,29,2,2
	rlwimi r4,r5,28,3,3
	rlwimi r4,r5,19,12,12
	stw r4,0x14(r3)
	lwz r3,0x18(r3)
	lwz r3,0x8(r3)
	lwz r4,0x4(r3)
	rlwimi r4,r5,29,2,2
	rlwimi r4,r5,30,1,1
	stw r4,0x4(r3)
	lwz r3,0xC(r3)
	load r4,0x3f000000
	stw r4,0xC(r3)
*/
#Get map_gobj
	li	r3,6				#platform's map_gobj ID
	branchl r12,Stage_map_gobj_Load
#Get platform flesh item pointer
	lwz r3,0x2C(r3)
	lwz r3,0xE4(r3)
	lwz r3,0x2C(r3)
#Set Hurtbox as intangible
	li	r4,2
	stw r4,0xACC(r3)

#Create Camera Box
	branchl	r12,CreateCameraBox
	mr	r20,r3
#Get Stage's Ledge IDs
	lwz		r3,-0x6CB8 (r13)			#External Stage ID
	bl		LedgedashCliffIDs
	mflr  r4
	mulli	r3,r3,0x2
	lhzx	r3,r3,r4
#Get Ledge Coordinates
	rlwinm	r3,r3,24,24,31
	addi	r4,sp,0xD0
	branchl	r12,Stage_GetLeftOfLineCoordinates
#Position Base of CameraBox behind the ledge
.set CameraBoxXOffset,35
.set CameraBoxYOffset,20
	li	r3,CameraBoxXOffset
	bl	IntToFloat
	lfs f2,0xD0(sp)		#Ledge X
	fadds f1,f1,f2
	stfs f1,0x10(r20)  #Camera X Position
	li	r3,CameraBoxYOffset
	bl	IntToFloat
	lfs f2,0xD4(sp)		#Ledge Y
	fadds f1,f1,f2
	stfs f1,0x14(r20)  #Camera Y Position
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

#Set Camera To Be Zoomed Out More
	load	r4,0x8049e6c8
	load	r3,0x3FE66666
	stw	r3,0x28(r4)

	b	LedgeStallThink_Exit

###########################################
LedgeStallThink_Constants:
blrl
.set LavaRiseRate,0x0
.set LavaMaxY,0x4

.float 0.4
.float 10
###########################################

###################################
## Ledge Stall THINK FUNCT ##
###################################

LedgeStallThink:
	blrl

#Registers
	.set REG_EventConstants,25
  .set REG_MenuData,26
  .set REG_EventData,31
	.set REG_EventGObj,24
  .set REG_P1Data,27
  .set REG_P1GObj,28
	.set REG_P2Data,29
	.set REG_P2GObj,30

#Event Data Offsets
	.set EventState,0x0
		.set EventState_LavaDelay,0x0
		.set EventState_LavaRiseThink,0x1
		.set EventState_Reset,0x2
	.set Timer,0x1
	.set LavaTimer,0x2
	.set SurvivalTime,0x4
	.set LavaPosition,0x8

#Constants
	.set ResetTimer,30
	.set LavaStartY,-100
	.set LavaStartTimer,123
	.set SuvivalTime_CountInterval,5

backup

#INIT FUNCTION VARIABLES
	mr	REG_EventGObj,r3
	lwz	REG_EventData,0x2c(REG_EventGObj)			#backup data pointer in r31

#Get Player Pointers
  bl GetAllPlayerPointers
  mr REG_P1GObj,r3
  mr REG_P1Data,r4
  mr REG_P2GObj,r5
  mr REG_P2Data,r6

#Get Menu and Constants Pointers
  lwz REG_MenuData,REG_EventData_REG_MenuDataPointer(REG_EventData)
	bl	LedgeStallThink_Constants
	mflr REG_EventConstants

#ON FIRST FRAME
	bl	CheckIfFirstFrame
	cmpwi	r3,0x0
	beq	LedgeStallThink_Start
	#Init Positions
		mr	r3,REG_P1GObj
		mr	r4,REG_EventData
		bl	LedgeStall_InitializePositions
  #Clear Inputs
    bl  RemoveFirstFrameInputs
	#Save State
  	addi r3,REG_EventData,EventData_SaveStateStruct
		li	r4,1			#Override failsafe code
  	bl	SaveState_Save
LedgeStallThink_Start:

#Check if player was damaged or died
	lwz r3,0x10(REG_P1Data)
	cmpwi r3,ASID_DamageHi1
	blt LedgeStallThink_DamageCheckSkip
	cmpwi r3,ASID_DamageFlyRoll
	bgt LedgeStallThink_DamageCheckSkip
	b	LedgeStallThink_TookDamage
LedgeStallThink_DamageCheckSkip:
	lbz r3,0x221F(REG_P1Data)
	rlwinm. r0,r3,0,25,25
	beq LedgeStallThink_DeadCheckSkip
LedgeStallThink_TookDamage:
#Check if took damage already
	lbz	r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt LedgeStallThink_DeadCheckSkip
#Set Reset Timer
	li	r3,ResetTimer
	stb r3,Timer(REG_EventData)
#Play Crowd SFX
	#li	r3,0x13D
	#bl	PlaySFX
#Advance State
	li	r3,EventState_Reset
	stb r3,EventState(REG_EventData)
LedgeStallThink_DeadCheckSkip:

LedgeStallThink_SwitchCase:
#Switch Case
	lbz r3,EventState(REG_EventData)
	cmpwi r3,EventState_LavaDelay
	beq LedgeStallThink_LavaDelay
	cmpwi r3,EventState_LavaRiseThink
	beq LedgeStallThink_LavaRiseThink
	cmpwi r3,EventState_Reset
	beq LedgeStallThink_Reset
	b	LedgeStallThink_CheckTimer

#region LedgeStallThink_LavaDelay
LedgeStallThink_LavaDelay:
#Reset Timer back to 0
	li	r3,0
	load r4,0x8046b6a0
	stw r3,0x28(r4)		#seconds
	sth r3,0x2C(r4)		#subseconds

#Decrement Lava Timer
	lhz r3,LavaTimer(REG_EventData)
	subi r3,r3,1
	sth r3,LavaTimer(REG_EventData)
#Check if up
	cmpwi r3,0
	bgt LedgeStallThink_CheckTimer
#Advance State
	li	r3,EventState_LavaRiseThink
	stb r3,EventState(REG_EventData)
	b LedgeStallThink_LavaRiseThink
#endregion

#region LedgeStallThink_LavaRiseThink
LedgeStallThink_LavaRiseThink:
#Ensure player is in the lava before incrementing survival time
	lfs f1,LavaPosition(REG_EventData)
	lfs f2,0xB4(REG_P1Data)
	fcmpo cr0,f2,f1
	bge LedgeStallThink_LavaRiseThink_NotInLava
#Increment Score
	lwz r3,SurvivalTime(REG_EventData)
	addi r3,r3,1
	stw r3,SurvivalTime(REG_EventData)
LedgeStallThink_LavaRiseThink_SkipScoreIncrement:

#Play HRC SFX every X score
	li	r3,SuvivalTime_CountInterval
	bl	IntToFloat
	fmr f2,f1
	lwz r3,SurvivalTime(REG_EventData)
	subi r3,r3,1
	bl	IntToFloat
	branchl r12,fmod
	fmr f2,f1
	li	r3,0
	bl	IntToFloat
	fcmpo cr0,f2,f1
	bne LedgeStallThink_LavaRiseThink_SkipSFX
#Play SFX
	li	r3,0xBB
	bl	PlaySFX
	li	r3,0xBB
	bl	PlaySFX
LedgeStallThink_LavaRiseThink_SkipSFX:
	b	LedgeStallThink_LavaRiseThink_NotInLavaSkip

LedgeStallThink_LavaRiseThink_NotInLava:
#Reset Timer back to 0
	li	r3,0
	load r4,0x8046b6a0
	stw r3,0x28(r4)		#seconds
	sth r3,0x2C(r4)		#subseconds
#Set survival time to 0
	stw r3,SurvivalTime(REG_EventData)
LedgeStallThink_LavaRiseThink_NotInLavaSkip:

#Check if lava is at max height
	lfs f1,LavaPosition(REG_EventData)
	lfs f2,LavaMaxY(REG_EventConstants)
	fcmpo cr0,f1,f2
	bge LedgeStallThink_LavaRiseThink_SkipLavaRise
#Raise Lava
	lfs f2,LavaRiseRate(REG_EventConstants)
	fadds f1,f1,f2
	stfs f1,LavaPosition(REG_EventData)
	bl	Ledgestall_UpdateLavaPosition
LedgeStallThink_LavaRiseThink_SkipLavaRise:

	b	LedgeStallThink_CheckTimer
#endregion

#region LedgeStallThink_Reset
LedgeStallThink_Reset:
#Effectively pause timer
	load r4,0x8046b6a0
	lwz r3,0x28(r4)		#seconds
	cmpwi r3,0
	beq LedgeStallThink_NoSecondCarryover
	lhz r3,0x2C(r4)		#subseconds
	cmpwi r3,0
	bne LedgeStallThink_NoSecondCarryover
	li	r3,0x3B
	sth r3,0x2C(r4)		#subseconds
	lwz r3,0x28(r4)		#seconds
	subi r3,r3,1
	stw r3,0x28(r4)		#seconds
	b	LedgeStallThink_CheckTimer
LedgeStallThink_NoSecondCarryover:
	lhz r3,0x2C(r4)		#subseconds
	subi r3,r3,1
	sth r3,0x2C(r4)		#subseconds
	b	LedgeStallThink_CheckTimer

#endregion

LedgeStallThink_CheckTimer:
#Check if timer exists
	lbz r3,Timer(REG_EventData)
	cmpwi r3,0
	ble LedgeStallThink_Exit
#Decrement timer
	subi r3,r3,1
	stb r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt LedgeStallThink_Exit


#Pasue game
	lfs	f1, -0x4D68 (rtoc)
	branchl r12,0x8016b274				#Pause game engine
#Check if player had any score when taking damage
	lwz r3,SurvivalTime(REG_EventData)
	cmpwi r3,0
	ble LedgeStallThink_Failure
LedgeStallThink_Success:
#Get current high score
	lwz	r3,-0x77C0 (r13)
	lbz r20,0x535(r3)
	mr	r3,r20
	branchl r12,Events_GetEventSavedScore
	lwz r4,SurvivalTime(REG_EventData)
	cmpw r4,r3
	ble LedgeStallThink_Success_NoHighScore
LedgeStallThink_Success_NewHighScore:
	li	r3,2
	branchl r12,0x8016b33c				#Display Success + SFX
	load r3,0x9c40
	branchl r12,0x8016b350
	li	r3,325
	branchl r12,0x8016b364				#queue crowd cheer after Success
	branchl r12,0x8016b328				#set game as ended
	mr	r3,r20										#update score
	lwz r4,SurvivalTime(REG_EventData)
	branchl r12,Events_SetEventSavedScore
	mr	r3,r20										#set event as played
	branchl r12,0x8015ceb4
	b	LedgeStallThink_Success_DestroyGObj
LedgeStallThink_Success_NoHighScore:
	li	r3,2
	branchl r12,0x8016b33c				#Display New Record + SFX
	li	r3,324
	branchl r12,0x8016b364				#queue crowd cheer after New Record
	branchl r12,0x8016b328				#set game as ended
	b	LedgeStallThink_Success_DestroyGObj

LedgeStallThink_Failure:
	li	r3,6
	branchl r12,0x8016b33c				#Display Failure + SFX
	li	r3,328
	branchl r12,0x8016b364				#queue crowd sigh after failure
	li	r3,40
	branchl r12,0x8016b378				#frames to linger?
	branchl r12,0x8016b328				#set game as ended
	b	LedgeStallThink_Success_DestroyGObj

LedgeStallThink_Success_DestroyGObj:
	mr	r3,REG_EventGObj
	branchl r12,GObj_Destroy			#destroy event gobj
	b	LedgeStallThink_Exit

LedgeStallThink_Restore:
#Restore State
	addi r3,REG_EventData,EventData_SaveStateStruct
	li	r4,1
	bl	SaveState_Load
#Init Positions Again
	mr	r3,REG_P1GObj
	mr	r4,REG_EventData
	bl	LedgeStall_InitializePositions
#Enable Inputs
	lbz r3,0x221D(REG_P1Data)
	li	r4,0
	rlwimi r3,r4,3,28,28
	stb r3,0x221D(REG_P1Data)
#Shorten Timer
	li	r3,0
	sth r3,LavaTimer(REG_EventData)
LedgeStallThink_Exit:
	restore
	blr

################################

LedgeStall_InitializePositions:
backup

.set REG_P1GObj,30
.set REG_P1Data,29
.set REG_EventData,28
.set REG_map_gobj,27
.set REG_map_gobj_JObj,26

#Init Registers
  mr	REG_P1GObj,r3
  lwz REG_P1Data,0x2C(REG_P1GObj)
	mr	REG_EventData,r4

#Place on left ledge
	mr	r3,REG_P1GObj
	li	r4,0
	bl	PlaceOnLedge

#Update Camera
	mr	r3,REG_P1GObj
	bl	UpdateCameraBox

#Init Lava Y
	li	r3,LavaStartY
	bl	IntToFloat
	stfs f1,LavaPosition(REG_EventData)
	bl	Ledgestall_UpdateLavaPosition

#Reset Variables
	li	r3,EventState_LavaDelay
	stb r3,EventState(REG_EventData)
	li	r3,0
	stb r3,Timer(REG_EventData)
	stw r3,SurvivalTime(REG_EventData)

#Init Lava Start Timer
	li	r3,LavaStartTimer
	sth r3,LavaTimer(REG_EventData)

LedgeStall_InitializePositions_Exit:
	restore
	blr

#####################################
Ledgestall_UpdateLavaPosition:
backup

.set REG_LavaY,31
.set REG_map_gobj_JObj,30

#Backup args
	stfs f1,0x80(sp)

#Get Lava map_gobj
	li	r3,8				#lava's map_gobj ID
	branchl r12,Stage_map_gobj_Load
#Get JObj
	li	r4,0
	branchl r12,Stage_map_gobj_LoadJObj
	mr	REG_map_gobj_JObj,r3

#Get 55f (jobj doesnt line up with actual position)
	li	r3,55
	bl	IntToFloat
#Update JObj Y position
	lfs f2,0x80(sp)
	fadds f1,f1,f2
	stfs f1,0x3C(REG_map_gobj_JObj)
#DirtySub
	mr	r3,REG_map_gobj_JObj
	branchl r12,HSD_JObjSetMtxDirtySub

#Adjust hitbox position
	lfs f1,0x80(sp)
	branchl r12,0x801c438c

Ledgestall_UpdateLavaPosition_Exit:
restore
blr

#endregion

##################
## General Tech ##
##################

#region L-Cancel Training
#########################
## L Cancel HIJACK INFO ##
#########################

LCancel:
#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)							#Send event struct
	mr	r4,r26									#Send match struct
	li	r5,-1										#Use chosen CPU
	li	r6,-1										#Use SSS Stage
	load r7,EventOSD_LCancel
	li	r8,0										#Use Sopo Bool
	bl	InitializeMatch

#Make P2 a human
	lwz r3,0x0(r29)
	lwz r3,0x18(r3)
	li	r4,0
	stb r4,0x1(r3)

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

    bl GetAllPlayerPointers
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
			li	r4,0x1		#Make CPU Controlled by P2
			lbz	r3, -0x5108 (r13)
			cmpwi	r3,0x0
			beq	LCancelIsP1
			li	r4,0x0
    LCancelIsP1:
			stb	r4,0x618(r29)
    #Clear Inputs
      bl  RemoveFirstFrameInputs
    #Save State
      addi r3,EventData,EventData_SaveStateStruct
			li	r4,1									#Override failsafe code
      bl  SaveState_Save
		LCancelNotFirstFrame:

		#Check For P2 Dpad Down Press
			lwz	r3,0x668(r29)					#Inputs
			rlwinm.	r0,r3,0,29,29
			beq	LCancelThink_CheckForInvinc
		#Toggle Invinc Bit
			lbz	r3,0x0(r31)
			nand 	3,3,3
			stb	r3,0x0(r31)



		LCancelThink_CheckForInvinc:
			lbz	r3,0x0(r31)
			cmpwi	r3,0x0
			bne	LCancelThink_RemoveInvincibility
		#Give No Knockback To P2
			lbz r3,0x2220(P2Data)
			li	r4,1
			rlwimi r3,r4,4,27,27
			stb r3,0x2220(P2Data)
		#Ignore Grabs
			li	r3,0x1FF
			sth r3,0x1A6A(P2Data)
		#Ignore Percent
			li	r3,0
			bl	IntToFloat
			stfs f1,0x1830(P2Data)
			lbz r3,0xC(P2Data)
			li	r4,0
			li	r5,0
			branchl r12,0x80034418
		#Un-nudgeable
			li	r3,0x1
			lbz	r0, 0x221D (P2Data)
			rlwimi	r0,r3,2,29,29
			stb	r0, 0x221D (P2Data)
		#Apply Overlay
			mr	r3,P2Data
			li	r4,9
			li	r5,0
			branchl r12,0x800bffd0
			b	LCancelThink_SkipInvincibility
		LCancelThink_RemoveInvincibility:
		#Give Invincibility To P2
			lbz r3,0x2220(P2Data)
			li	r4,0
			rlwimi r3,r4,4,27,27
			stb r3,0x2220(P2Data)
		#Allow Grabs
			#li	r3,0x0
			#sth r3,0x1A6A(P2Data)
		#Allow Percent
			#li	r3,1
			#bl	IntToFloat
			#stfs f1,0x182C(P2Data)
		#Nudgeable
			li	r3,0x0
			lbz	r0, 0x221D (P2Data)
			rlwimi	r0,r3,2,29,29
			stb	r0, 0x221D (P2Data)
		#Remove Overlay
			mr	r3,P2Data
			li	r4,9
			branchl r12,0x800c0200
		LCancelThink_SkipInvincibility:

		LCancelThink_CheckForSaveState:
		#Check For Savestates
		addi r3,EventData,EventData_SaveStateStruct
		bl	CheckForSaveAndLoad

    mr  r3,P1GObj
    mr  r4,P2GObj
    addi r5,EventData,EventData_SaveStateStruct
		bl	MoveCPU
		bl	GiveFullShields
		addi r3,EventData,EventData_SaveStateStruct+(1*0x8)
		bl	DPadCPUPercent
		bl	UpdateAllGFX

	LCancelLoadExit:
	restore
	blr




################################################################################
################################################################################
#endregion

#region Ledgedash Training

###########################
## Ledgedash HIJACK INFO ##
###########################

Ledgedash:

#SET EVENT TYPE TO KOs
	load	r5,0x8045abf0		#Static Match Struct
	lbz	r3,0xB(r5)		#Get Event Score Behavior Byte
	li	r4,0x0
	rlwimi	r3,r4,1,30,30		#Zero Out Time Bit
	stb	r3,0xB(r5)		#Set Event Score Behavior Byte

#Make HUD Centered For 1P and No Timer
	li	r3,0x0430
	sth	r3,0x0(r26)

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)							#Send event struct
	mr	r4,r26									#Send match struct
	li	r5,-1										#Use chosen CPU
	li	r6,-1										#Use SSS Stage
	load r7,EventOSD_Ledgedash
	li	r8,1										#Use Sopo Bool
	bl	InitializeMatch

#1 Player
	lwz r4,0x0(r29)
	li	r3,0x20
	stb	r3,0x1(r9)

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

#Remove randall
	lwz	r3,StageID_External(r13)
	cmpwi	r3,YoshiStory
	bne	LedgedashLoad_SkipRemoveRandall
#Get randall's map_gobj
	li	r3,2				#randalls map_gobj is 2
	branchl r12,Stage_map_gobj_Load
	branchl r12,Stage_Destroy_map_gobj
LedgedashLoad_SkipRemoveRandall:

	b	LedgedashLoadExit


		#########################
		## Ledgedash THINK FUNCT ##
		#########################

    #Registers
    .set REG_EventData,31
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
		.set StartingLocation,(MenuData_OptionMenuMemory+0x2+0x0)
		.set AutoRestore,(MenuData_OptionMenuMemory+0x2+0x1)
    .set StartingLocationToggled,(MenuData_OptionMenuToggled+0x0)
		.set AutoRestoreToggled,(MenuData_OptionMenuToggled+0x1)

		LedgedashThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		REG_EventData,0x2c(r3)			#backup data pointer in r31
		lwz   MenuData,EventData_MenuDataPointer(REG_EventData)

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
				mr r3,REG_EventData
				li	r4,0
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
				addi r3,REG_EventData,EventData_SaveStateStruct
				li	r4,1			#Override failsafe code
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

		#Make sure nothing else besides Z is held
			lhz	r3,0x662(P1Data)
			rlwinm.  r0,r3,0,27,27
      bne 0xC
      cmpwi r3,0x0
			bne GetProgressAndAS
		#CHECK FOR DPAD TO CHANGE LEDGE
			lwz	r3,0x668(P1Data)			#Get DPad
			rlwinm.	r0,r3,0,30,30
			beq	Ledgedash_CheckLeft
		#Load Most Recent State
			addi r3,REG_EventData,EventData_SaveStateStruct
			bl		SaveState_Load
		#Place on Right Ledge
			mr r3,REG_EventData
			li	r4,1
			bl	Ledgedash_PlaceOnLedge
		#Save State
			addi r3,REG_EventData,EventData_SaveStateStruct
			li	r4,1			#Override failsafe code
			bl		SaveState_Save
			b	Ledgedash_LoadState
		Ledgedash_CheckLeft:
			rlwinm.	r0,r3,0,31,31
			beq	GetProgressAndAS
		#Load Most Recent State
			addi r3,REG_EventData,EventData_SaveStateStruct
			bl		SaveState_Load
		#Place on Left Ledge
			mr r3,REG_EventData
			li	r4,0
			bl	Ledgedash_PlaceOnLedge
		#Save State
			addi r3,REG_EventData,EventData_SaveStateStruct
			li	r4,1			#Override failsafe code
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
			li	r3,9
			bl	IntToFloat
			lfs	f2,0x894(r29)		#Frames in State
			fcmpo	cr0,f2,f1
			blt	LedgedashThinkEnd

		Ledgedash_Reset:
		#Play Success or Failure Noise
			lhz	r3,TM_OneASAgo(r29)			#Check Prev AS
			cmpwi	r3,ASID_LandingFallSpecial			#If Landing, Success
			beq	Ledgedash_PlaySuccess
			cmpwi	r3,ASID_Wait			#If Wait, Success (Frame Perfect Action)
			beq	Ledgedash_PlaySuccess

			lwz	r3,CurrentAS(r29)
			cmpwi	r3,ASID_Landing			#If Aerial Interrupt, Check If Can IASA Yet
			beq	Ledgedash_AerialInterruptCheck
			cmpwi	r3,ASID_Wait			#If No Impact Land, Success
			beq	Ledgedash_PlaySuccess

		b	Ledgedash_PlayFailure

		Ledgedash_AerialInterruptCheck:
		#Check If Coming From an Aerial Attack
		lhz	r3,TM_OneASAgo(r29)			#Check Prev AS
		cmpwi	r3,ASID_AttackAirN
		blt	Ledgedash_PlayFailure
		cmpwi	r3,ASID_AttackAirLw
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
		#Place on Ledge
			mr r3,REG_EventData
			lbz	r4,currentLedge(REG_EventData)
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
    #Load State (to cleanup volatile entities)
      addi r3,REG_EventData,EventData_SaveStateStruct
      bl		SaveState_Load
		#Place on Ledge
			mr r3,REG_EventData
			lbz	r4,currentLedge(REG_EventData)
      bl	Ledgedash_PlaceOnLedge
    #Save State
      addi r3,REG_EventData,EventData_SaveStateStruct
			li	r4,1							#Override failsafe code
      bl		SaveState_Save

		Ledgedash_LoadState:
		#Reset all event variables
			li		r3,0x0
			stb		r3,eventState(r31)				#Progress Byte
			stb		r3,hitboxFoundFlag(r31)		#Invincible Move Bool
			stb		r3,timer(r31)							#Timer
			addi r3,REG_EventData,EventData_SaveStateStruct
			bl		SaveState_Load
		#Create Respawn Platform If Enabled
			lbz		r3,StartingLocation(MenuData)
			cmpwi	r3,0x0
			beq	Ledgedash_LoadState_SkipRespawnPlatform
		#Remember Facing Direction (Rebirth changes this)
			lfs	f31,0x2C(r29)
		#Enter P1 Into Rebirth Again
			mr	r3,r30
			branchl	r12,AS_Rebirth
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

		.set	REG_EventData,31
		.set	REG_P1GObj,30
		.set	REG_P1Data,29
		.set	REG_LedgeID,28
		.set	REG_CameraBox,28

		#Init
			mr	REG_EventData,r3
			mr	REG_LedgeID,r4
			stb	REG_LedgeID,currentLedge(REG_EventData)
		#Get P1 data
			li	r3,0
			branchl	r12,PlayerBlock_LoadMainCharDataOffset
			mr	REG_P1GObj,r3
			lwz	REG_P1Data,0x2C(REG_P1GObj)

		#Place on ledge
			mr	r3,REG_P1GObj
			mr	r4,REG_LedgeID
			bl	PlaceOnLedge

		#RESET PROGRESS
			li		r3,0x0
			stb		r3,eventState(REG_EventData)

		#Get Stage's Ledge IDs
			lwz		r3,-0x6CB8 (r13)			#External Stage ID
			bl		LedgedashCliffIDs
			mflr  r4
			mulli	r3,r3,0x2
			lhzx	r3,r3,r4
		#Get Requested Ledge
			cmpwi REG_LedgeID,0x0
			beq	Ledgedash_PlaceOnLedge_GetLeftLedgeID
		Ledgedash_PlaceOnLedge_GetRightLedgeID:
			rlwinm	r21,r3,0,24,31
			b	Ledgedash_PlaceOnLedge_SkipLedgeID
		Ledgedash_PlaceOnLedge_GetLeftLedgeID:
			rlwinm	r21,r3,24,24,31
		Ledgedash_PlaceOnLedge_SkipLedgeID:

		#Adjust Ledge Camera Box Accordingly
		#Get Ledge Coordinates
			mr	r3,r21
			addi	r4,sp,0xD0
			lfs	f1, 0x002C (REG_P1Data)
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
			lwz REG_CameraBox,CameraBox(REG_EventData)
		#Position Base of CameraBox behind the ledge
		.set CameraBoxXOffset,35
		.set CameraBoxYOffset,20
			li	r3,CameraBoxXOffset
			bl	IntToFloat
			lfs f2,0xD0(sp)		#Ledge X
			lfs f3,0x2C(REG_P1Data)
			fmadds f1,f1,f3,f2
			stfs f1,0x10(REG_CameraBox)  #Camera X Position
			li	r3,CameraBoxYOffset
			bl	IntToFloat
			lfs f2,0xD4(sp)		#Ledge Y
			fadds f1,f1,f2
			stfs f1,0x14(REG_CameraBox)  #Camera Y Position
		#Make Boundaries around ledge position
		#Left Bound
			li	r3,-10
			bl	IntToFloat
			stfs	f1,0x40(REG_CameraBox)
		#Right Bound
			li	r3,10
			bl	IntToFloat
			stfs	f1,0x44(REG_CameraBox)
		#Top Bound
			li	r3,10
			bl	IntToFloat
			stfs	f1,0x48(REG_CameraBox)
		#Lower Bound
			li	r3,-10
			bl	IntToFloat
			stfs	f1,0x4C(REG_CameraBox)

    #Update Camera Box
      mr  r3,REG_P1GObj
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
#CliffWait -> Fall
LedgedashProg0:
#*********************#
.hword 0x7F00
.hword ASID_CliffCatch,ASID_CliffWait
.hword ASID_RebirthWait
#*********************#
.hword 0x7F01
.hword ASID_Fall
#*********************#
.hword 0x7F02
.hword ASID_JumpAerialF,ASID_JumpAerialB
#*********************#
.hword -1
.align 2

#Fall -> JumpAerial
LedgedashProg1:
.hword 0x7F00
.hword ASID_CliffCatch,ASID_CliffWait
#*********************#
.hword 0x7F01
.hword ASID_Fall,ASID_PassiveWallJump
#*********************#
.hword 0x7F02
.hword ASID_JumpAerialF,ASID_JumpAerialB
.hword ASID_FallSpecial,ASID_CliffJumpSlow2
.hword ASID_FallAerial,0x17E
.hword 0x166,0x167
.hword 0x170,0x164
.hword 0x155,0x15e
.hword 0x15f,0x160
.hword 0x16B,0x171
.hword 0x15C,0x16D
.hword 0x165,0x16E
.hword 0x168,0x161
.hword 0x176,0x15D
.hword 0x169,0x162
#*********************#
.hword -1
.align 2


#JumpAerial -> Airdodge
LedgedashProg2:
#*********************#
.hword 0x7F02
.hword ASID_JumpAerialF,ASID_PassiveWallJump
.hword ASID_JumpAerialB,ASID_Fall
.hword ASID_FallSpecial,ASID_CliffJumpSlow2
.hword ASID_FallAerial,0x17E
.hword 0x167,0x170
.hword 0x164,0x162
.hword 0x15e,0x15f
.hword 0x160,0x16B
.hword 0x171,0x15C
.hword 0x16D,0x16E
.hword 0x165,0x168
.hword 0x161,0x176
.hword 0x15D,0x155
.hword 0x169,0x166
#*********************#
.hword 0x7F03
.hword ASID_EscapeAir,ASID_AttackAirB
.hword ASID_AttackAirB,ASID_AttackAirU
.hword ASID_AttackAirD,ASID_AttackAirF
.hword ASID_AttackAirN,ASID_LandingFallSpecial
#*********************#
.hword 0x7F00
.hword ASID_CliffCatch
#*********************#
.hword -1
.align 2

#Airdodge -> Landing
LedgedashProg3:
#*********************#
.hword 0x7F03
.hword 0xAA		#i think this is just a placeholder, could prob remove but w/e
#*********************#
.hword 0x7F04
.hword ASID_LandingFallSpecial,ASID_Landing
#*********************#
.hword -1
.align 2


#Landing -> Wait
LedgedashProg4:
#*********************#
.hword 0x7F04
.hword ASID_LandingFallSpecial
#*********************#
.hword 0x7F02
.hword ASID_Fall
#*********************#
.hword -1
.align 2


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

#endregion

#region SDI Training
##############################
## SDI Training HIJACK INFO ##
##############################

SDITraining:
#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)							#Send event struct
	mr	r4,r26									#Send match struct
	li	r5,Fox.Ext							#Use chosen CPU
	li	r6,FinalDestination			#Use SSS Stage
	load r7,EventOSD_SDI
	li	r8,1										#Use Sopo bool
	bl	InitializeMatch

#Make default color
	lwz	r3,0x0(r29)
	lwz	r3,0x18(r3)		#p2 pointer
	li  r4,0x0
	stb r4,0x3(r3)    #Default color

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
  			addi r3,EventData,EventData_SaveStateStruct
				li	r4,1			#Override failsafe code
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
			addi r3,EventData,EventData_SaveStateStruct
			bl	SaveState_Load
			addi r3,EventData,EventData_SaveStateStruct
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
#endregion

#region Reversal Training
#########################
## Reversal HIJACK INFO ##
#########################

Reversal:

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)							#Send event struct
	mr	r4,r26									#Send match struct
	li	r5,-1										#Use chosen CPU
	li	r6,-1										#Use SSS Stage
	load r7,EventOSD_Reversal
	li	r8,0										#Use Sopo bool
	bl	InitializeMatch

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
		.set CPUAttack,(MenuData_OptionMenuMemory+0x2)+(0x0)
		.set P1FacingDirection,(MenuData_OptionMenuMemory+0x2)+(0x1)
		.set CPUFacingDirection,(MenuData_OptionMenuMemory+0x2)+(0x2)
    .set CPUAttackToggled,MenuData_OptionMenuToggled+(0x0)
    .set P1FacingDirectionToggled,MenuData_OptionMenuToggled+(0x1)
    .set CPUFacingDirectionToggled,MenuData_OptionMenuToggled+(0x2)
		.set AerialThinkStruct,0x20

		ReversalThink:
		blrl

    .set EventData,31

		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31
    lwz MenuData,EventData_MenuDataPointer(EventData)

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
				li	r4,1			#Override failsafe code
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
    ReversalSwap:
    #I fucking hate this code, i need to clean this up at some point.
    #Get leftmost player pointer in r20, rightmost in r21
      addi r5,EventData,0x10
      lwz r3,0x0(r5)
      lfs f1,0xB0(r3)
      lwz r4,0x8(r5)
      lfs f2,0xB0(r4)
      fcmpo cr0,f1,f2
      bgt 0x10
      mr r20,r3
      mr r21,r4
      b 0xC
      mr r20,r4
      mr r21,r3
    #Get which side to start on
      li	r3,2        #0 = p1 on left, 1 = p1 on right
      branchl r12,HSD_Randi
      cmpwi r3,0x0
      bne ReversalReset_RightSide
    ReversalReset_LeftSide:
    #Swap Position
      addi r5,EventData,0x10
      #Get Leftmost Chars Position
        li  r3,1
        bl  IntToFloat
        fmr f2,f1
        lfs f3,0xB0(r20)
        lfs f4,0xB4(r20)
      #Get Rightmost Chars Position
        li  r3,-1
        bl  IntToFloat
        fmr f5,f1
        lfs f6,0xB0(r21)
        lfs f7,0xB4(r21)
      #Store to P1 Data
        lwz r3,0x0(r5)
        stfs f2,0x2C(r3)
        stfs f3,0xB0(r3)
        stfs f4,0xB4(r3)
      #Store to P2 Data
        lwz r3,0x8(r5)
        stfs f5,0x2C(r3)
        stfs f6,0xB0(r3)
        stfs f7,0xB4(r3)
        b ReversalReset_SwapEnd
    ReversalReset_RightSide:
      addi r5,EventData,0x10
      #Get Leftmost Chars Position
        li  r3,1
        bl  IntToFloat
        fmr f2,f1
        lfs f3,0xB0(r20)
        lfs f4,0xB4(r20)
      #Get Rightmost Chars Position
        li  r3,-1
        bl  IntToFloat
        fmr f5,f1
        lfs f6,0xB0(r21)
        lfs f7,0xB4(r21)
      #Store to P2 Data
        lwz r3,0x8(r5)
        stfs f2,0x2C(r3)
        stfs f3,0xB0(r3)
        stfs f4,0xB4(r3)
      #Store to P1 Data
        lwz r3,0x0(r5)
        stfs f5,0x2C(r3)
        stfs f6,0xB0(r3)
        stfs f7,0xB4(r3)
    ReversalReset_SwapEnd:
    ReversalAdjustP1Direction:
		#Adjust P1 Facing Direction Based on Preference
      addi r5,EventData,0x10
			lbz	r3,P1FacingDirection(MenuData)
			cmpwi	r3,0x1
			bne	ReversalAdjustP1Direction_Skip
		#Invert P1 Facing Direction
			lwz	r3,0x0(r5)
			lfs	f1,0x2C(r3)
			fneg	f1,f1
			stfs	f1,0x2C(r3)
    ReversalAdjustP1Direction_Skip:
		#Adjust CPU Facing Direction Based on Preference
		ReversalAdjustCPUDirection:
			lbz	r3,CPUFacingDirection(MenuData)
			cmpwi	r3,0x1
			bne	ReversalAdjustCPUDirection_Skip
		#Invert P2 Facing Direction
			lwz	r3,0x8(r5)
			lfs	f1,0x2C(r3)
			fneg	f1,f1
			stfs	f1,0x2C(r3)
    ReversalAdjustCPUDirection_Skip:
		#Restore
		ReversalLoadState:
			addi r3,EventData,EventData_SaveStateStruct
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
#endregion

#region Powershield Training
#########################
## Powershield HIJACK INFO ##
#########################

Powershield:
#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)							#Send event struct
	mr	r4,r26									#Send match struct
	li	r5,Falco.Ext						#Use chosen CPU
	li	r6,FinalDestination			#Use SSS Stage
	load r7,EventOSD_Powershield
	li	r8,0										#Use Sopo bool
	bl	InitializeMatch

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
		.set FireSpeed,(MenuData_OptionMenuMemory+0x2)+0x0

		PowershieldThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31
    lwz   MenuData,EventData_MenuDataPointer(EventData)

    bl  GetAllPlayerPointers
    mr P1GObj,r3
    mr P1Data,r4
    mr P2GObj,r5
    mr P2Data,r6

		bl	StoreCPUTypeAndZeroInputs

		#Make P2 A Follower (No Nudge)
		#li	r3,0x8
		#stb	r3,0x221F(r29)
		li	r3,0x1
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
		rlwinm.  r0,r3,0,27,27
    bne 0xC
    cmpwi r3,0x0
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
		addi r3,EventData,EventData_SaveStateStruct
		li	r4,1			#Override failsafe code
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
addi r3,EventData,EventData_SaveStateStruct
bl	SaveState_Load
addi r3,EventData,EventData_SaveStateStruct
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
#endregion

#region Shield Drop Training
#########################
## Shield Drop HIJACK INFO ##
#########################

ShieldDrop:

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)						#Send event struct
	mr	r4,r26								#Send match struct
	li	r5,-1									#Use chosen CPU
	li	r6,Battlefield				#Use SSS Stage
	load r7,EventOSD_ShieldDrop
	li	r8,0										#Use Sopo bool
	bl	InitializeMatch

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
		.set FacingDirection,(MenuData_OptionMenuMemory+0x2)+0x0
    .set FacingDirectionToggled,(MenuData_OptionMenuToggled)+0x0

		ShieldDropThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31
    lwz   MenuData,EventData_MenuDataPointer(EventData)

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
  			addi r3,EventData,EventData_SaveStateStruct
				li	r4,1			#Override failsafe code
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
		addi r3,EventData,EventData_SaveStateStruct
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
#endregion

#region Attack on Shield
#########################
## Attack On Shield HIJACK INFO ##
#########################

AttackOnShield:

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)						#Send event struct
	mr	r4,r26								#Send match struct
	li	r5,-1									#Use chosen CPU
	li	r6,FinalDestination		#Use SSS Stage
	load r7,EventOSD_AttackOnShield
	li	r8,0										#Use Sopo bool
	bl	InitializeMatch

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
		.set OoSOption,MenuData_OptionMenuMemory+0x2 + 0x0
  	.set OoSOptionToggled,MenuData_OptionMenuToggled + 0x0

		AttackOnShieldThink:
		blrl
		backup

		#INIT FUNCTION VARIABLES
		lwz		EventData,0x2c(r3)			#backup data pointer in r31
    lwz MenuData,EventData_MenuDataPointer(EventData)

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
  			addi r3,EventData,EventData_SaveStateStruct
				li	r4,1			#Override failsafe code
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
			sth	r3,TM_OneASAgo(r29)
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
		lhz	r3,TM_OneASAgo(r29)
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
		addi r3,EventData,EventData_SaveStateStruct
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
.long 0x14460000    #P1 X Rand Pos Range

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
#endregion

#region Ledgetech Training
#########################
## Ledgetech HIJACK INFO ##
#########################

Ledgetech:

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)						#Send event struct
	mr	r4,r26								#Send match struct
	li	r5,Falco.Ext					#Use chosen CPU
	li	r6,-1									#Use chosen Stage
	load r7,EventOSD_LedgeTech
	li	r8,1										#Use Sopo bool
	bl	InitializeMatch

#BUFF DEFENSE RATIO
lis	r3,0x3f00
stw	r3,0x14(r20)

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
		#Enter SquatWait
		  mr r3,P2GObj
		  branchl r12,AS_SquatWait
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
			addi r3,EventData,EventData_SaveStateStruct
			li	r4,1			#Override failsafe
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
		addi r3,r29,0xB0 #P2 Positon
		addi r4,r27,0xB0 #P1 Position
		bl	GetDistance
		lfs	f2,0x0(r21)
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
    	addi r3,EventData,EventData_SaveStateStruct
    	bl	SaveState_Load
    #Random Side of Stage
      li  r3,2
      branchl r12,HSD_Randi
      bl  Ledgetech_InitializePositions
		#Enter SquatWait
		  mr r3,P2GObj
		  branchl r12,AS_SquatWait

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
.float 35.0		#Distance to Initiate DSmash

#################################

BlrFunctionPointer:
blrl
blr

#################################

Ledgetech_InitializePositions:
backup

.set LedgeSide,20

#Backup Ledge Side
	mr	LedgeSide,r3

#Change Facing Directions
  cmpwi LedgeSide,0x0
  beq	Ledgetech_InitializePositions_GetLeftLedgeID
Ledgetech_InitializePositions_GetRightLedgeID:
 #Change Facing Direction
	li	r3,-1
	bl	IntToFloat
	stfs	f1,0x2C(P1Data)
  li	r3,1
  bl	IntToFloat
  stfs	f1,0x2C(P2Data)
	b	Ledgetech_InitializePositions_DirectionChangeEnd
Ledgetech_InitializePositions_GetLeftLedgeID:
#Change Facing Direction
	li	r3,1
  bl	IntToFloat
  stfs	f1,0x2C(P1Data)
  li	r3,-1
  bl	IntToFloat
  stfs	f1,0x2C(P2Data)
Ledgetech_InitializePositions_DirectionChangeEnd:

#Get Ledge Coordinates
	mr	r3,LedgeSide
	addi r4,sp,0x80
	bl	GetLedgeCoordinates

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
#Enter into Wait
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
#endregion

#region Amsah Tech
#########################
## Amsah Tech HIJACK INFO ##
#########################

AmsahTech:

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)			#Send event struct
	mr	r4,r26					#Send match struct
	li	r5,9						#Use chosen CPU
	li	r6,-1						#Use chosen Stage
	load r7,EventOSD_AmsahTech
	li	r8,0										#Use Sopo bool
	bl	InitializeMatch

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
  			addi r3,EventData,EventData_SaveStateStruct
				li	r4,1			#Override failsafe code
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
    lhz r3,TM_FramesinCurrentAS(P1Data)
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
		addi r3,EventData,EventData_SaveStateStruct
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
#endregion

#region Combo Training
################################
## Combo Training HIJACK INFO ##
################################

ComboTraining:

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)			#Send event struct
	mr	r4,r26					#Send match struct
	li	r5,-1						#Use chosen CPU
	li	r6,-1						#Use chosen Stage
	load r7,EventOSD_ComboTraining
	li	r8,0										#Use Sopo bool
	bl	InitializeMatch

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
	li	r4,3												#Priority (After Interrupt)
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
		.set DIBehavior,(MenuData_OptionMenuMemory+0x2)+0x0
		.set SDIBehavior,(MenuData_OptionMenuMemory+0x2)+0x1
		.set TechOption,(MenuData_OptionMenuMemory+0x2)+0x2
		.set PostHitstunAction,(MenuData_OptionMenuMemory+0x2)+0x3
		.set GrabMashout,(MenuData_OptionMenuMemory+0x2)+0x4
    .set DIBehaviorToggled,(MenuData_OptionMenuToggled)+0x0
		.set SDIBehaviorToggled,(MenuData_OptionMenuToggled)+0x1
		.set TechOptionToggled,(MenuData_OptionMenuToggled)+0x2
		.set PostHitstunActionToggled,(MenuData_OptionMenuToggled)+0x3
		.set GrabMashoutToggled,(MenuData_OptionMenuToggled)+0x4

		#Definitions
		#DIBehavior
			.set DI_Random,0x0
			.set DI_Survival,0x1
			.set DI_ComboDI,0x2
			.set DI_SlightDIRandom,0x3
			.set DI_SlightDIInwards,0x4
			.set DI_DownAndAway,0x5
			.set DI_None,0x6
		#SDIBehavior
			.set SDI_33Percent,0x0
			.set SDI_66Percent,0x1
			.set SDI_Always,0x2
			.set SDI_None,0x3

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

    lwz MenuData,EventData_MenuDataPointer(EventData)

		bl	StoreCPUTypeAndZeroInputs

		#ON FIRST FRAME
		bl	CheckIfFirstFrame
		cmpwi	r3,0x0
		beq	ComboTrainingThinkMain

        bl  PlacePlayersCenterStage
      #Clear Inputs
        bl  RemoveFirstFrameInputs
			#Save State
  			addi r3,EventData,EventData_SaveStateStruct
				li	r4,1			#Override failsafe code
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
		addi r3,EventData,EventData_SaveStateStruct+(1*0x8)
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
		cmpwi	r3,ASID_DamageHi1
		blt	ComboTrainingCheckState
		cmpwi	r3,ASID_DamageFlyRoll
		bgt	ComboTrainingCheckState
		ComboTrainingChangeToRandomDIandTech:
	#Change To DI and Tech
		li	r3,0x1
		stb	r3,EventState(r31)
		b	ComboTrainingInputDIAndTech

#Get Which State
ComboTrainingCheckState:
	lbz	r3,EventState(r31)
	cmpwi	r3,0x0
	beq	ComboTrainingStart
	cmpwi	r3,0x1
	beq	ComboTrainingInputDIAndTech
	cmpwi	r3,0x2
	beq	ComboTrainingPostHitstun


ComboTrainingStart:
	b	ComboTrainingCheckToReset

ComboTrainingInputDIAndTech:
	bl	ComboTrainingCheckExitStates
	cmpwi	r3,0x0
	beq	ComboTrainingInputDIAndTechNoJiggs
	b	ComboTrainingChangeStateToPostHitstun


ComboTrainingInputDIAndTechNoJiggs:
	lwz	r3,0x10(r29)
	cmpwi	r3,0xB8		#Missed Tech, Needs to Input a Roll or Attack
	beq	ComboTrainingMissedTechThink
	cmpwi	r3,0xC0		#Missed Tech, Needs to Input a Roll or Attack
	beq	ComboTrainingMissedTechThink
#Check If Still Grabbed
	cmpwi r3,ASID_ShoulderedWait
	blt ComboTraining_GrabCheckSkipShoulder
	cmpwi r3,ASID_ShoulderedTurn
	ble ComboTrainingMashOutOfGrab
ComboTraining_GrabCheckSkipShoulder:
	cmpwi	r3,ASID_CaptureKoopa
	blt	ComboTraining_GrabCheckSkipKoopaLw
	cmpwi	r3,ASID_CaptureWaitKoopa
	ble	ComboTrainingMashOutOfGrab
ComboTraining_GrabCheckSkipKoopaLw:
	cmpwi	r3,ASID_CaptureKoopaAir
	blt	ComboTraining_GrabCheckSkipKoopaAir
	cmpwi	r3,ASID_CaptureWaitKoopaAir
	ble	ComboTrainingMashOutOfGrab
ComboTraining_GrabCheckSkipKoopaAir:
	cmpwi	r3,ASID_CapturePulledHi		#CapturePulledLow
	blt	ComboTraining_GrabCheckSkipGrabbed
	cmpwi	r3,ASID_CaptureFoot 		#CapturePulledHi
	ble	ComboTrainingMashOutOfGrab
ComboTraining_GrabCheckSkipGrabbed:
	b	ComboTrainingDecideInputs

#When Grabbed
#Check Mash Out Behavior
ComboTrainingMashOutOfGrab:
	lbz	r3,GrabMashout(MenuData)
	cmpwi	r3,0x0
	beq	ComboTrainingInputDIAndTech_RandomMash
	cmpwi	r3,0x1
	beq	ComboTrainingInputDIAndTech_RandomMash_AnalogInput
	cmpwi	r3,0x2								#No Mash
	beq	ComboTrainingCheckToReset


	#Random Mash Out
	ComboTrainingInputDIAndTech_RandomMash:
	#Only start randomly mashing after a few frames (to simulate human reaction)
		lwz r3,0x10(r29)
		cmpwi	r3,ASID_CapturePulledHi		#CapturePulledLow
		blt	ComboTrainingInputDIAndTech_RandomMashStart
		cmpwi	r3,ASID_CaptureFoot 		#CapturePulledHi
		bgt	ComboTrainingInputDIAndTech_RandomMashStart
	#In a normal grab state, should wait a few frames before starting to mash

	ComboTrainingInputDIAndTech_RandomMashStart:
		li	r3,10										#1- Numbers
		branchl	r12,HSD_Randi
		cmpwi	r3,7									#7 and below are no input
		ble	ComboTrainingCheckToReset
		cmpwi	r3,8									#8 = Button Only, 9 = Both Analog and Button
		beq	ComboTrainingInputDIAndTech_RandomMash_ButtonPress

	ComboTrainingInputDIAndTech_RandomMash_AnalogInput:
		li	r3,127
		stb	r3,0x1A8C(r29)			#Push Analog Stick Forward
		li	r3,-1
		stb	r3,0x1A50(r29)			#Spoof Analog Stick as First Frame Pushed

	ComboTrainingInputDIAndTech_RandomMash_ButtonPress:
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
			cmpwi	r3,DI_SlightDIInwards		#Check If Slight In
			bne	0x8
			li	r3,0x0		#Override To Never Slight DI In Attacks
			b	0x8
			li	r3,0x2
			bl	ComboTrainingDecideStickAngle
		#SDI Attack
			lbz	r3,SDIBehavior(MenuData)		#Get SDI Behavior
			cmpwi	r3,SDI_None		#No SDI
			beq	ComboTrainingNoSDI
			cmpwi	r3,SDI_Always		#Always SDI
			beq	ComboTrainingCheckToReset

			li	r3,0x3
			branchl	r12,HSD_Randi
			lbz	r4,SDIBehavior(MenuData)		#Get SDI Behavior
			cmpwi	r4,SDI_33Percent
			beq	ComboTraining33PercentSDI
			cmpwi	r4,SDI_66Percent
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
		li	r3,4									#Decide between left right and center and none
		branchl	r12,HSD_Randi
		cmpwi r3,0x0
		beq ComboTrainingRandomTech_TechInPlace
		cmpwi r3,0x1
		beq ComboTrainingRandomTech_TechLeft
		cmpwi r3,0x2
		beq ComboTrainingRandomTech_TechRight
		cmpwi r3,0x3
		beq ComboTrainingMissTech

	ComboTrainingRandomTech_TechInPlace:
		li	r3,0
		stb r3,0x1A8C(r29)
		stb r3,0x1A8D(r29)
		b	ComboTrainingCheckToReset
	ComboTrainingRandomTech_TechLeft:
		li	r3,-127
		stb r3,0x1A8C(r29)
		b	ComboTrainingCheckToReset
	ComboTrainingRandomTech_TechRight:
		li	r3,127
		stb r3,0x1A8C(r29)
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
		addi r3,EventData,EventData_SaveStateStruct
		bl	SaveState_Load
		addi r3,EventData,EventData_SaveStateStruct
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
cmpwi	r3,DI_Random
beq	ComboTrainingDecideStickAngle_RandomDI
cmpwi	r3,DI_Survival
beq	ComboTrainingDecideStickAngle_SurvivalDI
cmpwi	r3,DI_ComboDI
beq	ComboTrainingDecideStickAngle_ComboDI
cmpwi	r3,DI_SlightDIRandom
beq	ComboTrainingDecideStickAngle_RandomDI_SlightDI
cmpwi	r3,DI_SlightDIInwards
beq	ComboTrainingDecideStickAngle_SlightDIInwards
cmpwi	r3,DI_DownAndAway
beq	ComboTrainingDecideStickAngle_DownAwayDI
cmpwi	r3,DI_None
beq	ComboTrainingDecideStickAngle_NoDI

###############
## Random DI ##
###############

#Roll RNG
ComboTrainingDecideStickAngle_RandomDI:
	li	r3,6
	branchl	r12,HSD_Randi
	cmpwi	r3,0x0
	beq	ComboTrainingDecideStickAngle_RandomDI_TrulyRandom
	cmpwi	r3,0x1
	beq	ComboTrainingDecideStickAngle_ComboDI
	cmpwi	r3,0x2
	beq	ComboTrainingDecideStickAngle_SurvivalDI
	cmpwi r3,0x3
	beq ComboTrainingDecideStickAngle_RandomDI_SlightDI
	cmpwi r3,0x4
	beq	ComboTrainingDecideStickAngle_DownAwayDI
	cmpwi	r3,0x5
	beq	ComboTrainingDecideStickAngle_NoDI

ComboTrainingDecideStickAngle_RandomDI_TrulyRandom:
.set Combo_RandomAnalogMin, 36
.set Combo_RandomAnalogMax, 127

#Get X magnitude
	li	r3,Combo_RandomAnalogMax - Combo_RandomAnalogMin
	branchl r12,HSD_Randi
	addi r3,r3,Combo_RandomAnalogMin
	stb r3,0x1A8C(r29)
#Chance to negate
	li	r3,2
	branchl r12,HSD_Randi
	cmpwi r3,0x0
	beq 0x10
	lbz r3,0x1A8C(r29)
	neg r3,r3
	stb r3,0x1A8C(r29)
#Get Y magnitude
	li	r3,Combo_RandomAnalogMax - Combo_RandomAnalogMin
	branchl r12,HSD_Randi
	addi r3,r3,Combo_RandomAnalogMin
	stb r3,0x1A8D(r29)
#Chance to negate
	li	r3,2
	branchl r12,HSD_Randi
	cmpwi r3,0x0
	beq 0x10
	lbz r3,0x1A8D(r29)
	neg r3,r3
	stb r3,0x1A8D(r29)
	b	ComboTrainingDecideStickAngleExit

ComboTrainingDecideStickAngle_RandomDI_SlightDI:
.set Combo_SlightAnalogMin, 36
.set Combo_SlightAnalogMax, 66

#Get X magnitude
	li	r3,Combo_SlightAnalogMax - Combo_SlightAnalogMin
	branchl r12,HSD_Randi
	addi r3,r3,Combo_RandomAnalogMin
	stb r3,0x1A8C(r29)
#Chance to negate
	li	r3,2
	branchl r12,HSD_Randi
	cmpwi r3,0x0
	beq 0x10
	lbz r3,0x1A8C(r29)
	neg r3,r3
	stb r3,0x1A8C(r29)
#Get Y magnitude
	li	r3,Combo_SlightAnalogMax - Combo_SlightAnalogMin
	branchl r12,HSD_Randi
	addi r3,r3,Combo_SlightAnalogMin
	stb r3,0x1A8D(r29)
#Chance to negate
	li	r3,2
	branchl r12,HSD_Randi
	cmpwi r3,0x0
	beq 0x10
	lbz r3,0x1A8D(r29)
	neg r3,r3
	stb r3,0x1A8D(r29)
	b	ComboTrainingDecideStickAngleExit

#######################
## Slight DI Towards ##
#######################

ComboTrainingDecideStickAngle_SlightDIInwards:

#Get Random Stick X Input 86-105, 86-95 go in front, 96-105 go behind shiek
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
#C-Stick Down
	li	r3,-127
	stb	r3, 0x1A8F (r29)

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

.long 0x04060304  #5 windows, DI has 7 options, SDI has 4 Options, Tech Has 5 Options
.long 0x02020000  #PostHitstun has 3 options, Mash has 3 options

####################################################

ComboTrainingWindowText:
blrl

########
## DI ##
########

#Window Title = DI Behavior
.string "DI Behavior"
.align 2

#Option 1 = Random DI
.string "Random DI"
.align 2

#Option 2 = Survival DI
.string "Survival DI"
.align 2

#Option 3 = Combo DI
.string "Combo DI"
.align 2

#Option 4 = Slight DI Random
.string "Slight DI Random"
.align 2

#Option 5 = Slight DI Towards
.string "Slight DI Towards"
.align 2

#Option 6 = Down and Away DI
.string "Down and Away DI"
.align 2

#Option 6 = No DI
.string "No DI"
.align 2

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
#endregion

#region Waveshine SDI
#########################
## Waveshine SDI HIJACK INFO ##
#########################

WaveshineSDI:

#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)										#Send event struct
	mr	r4,r26												#Send match struct
	li	r5,Fox.Ext										#Use chosen CPU
	li	r6,FinalDestination						#Use chosen Stage
	load r7,EventOSD_WaveshineSDI
	li	r8,1										#Use Sopo bool
	bl	InitializeMatch

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
					addi r3,EventData,EventData_SaveStateStruct
					li	r4,1			#Override failsafe code
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
			addi r3,EventData,EventData_SaveStateStruct
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
#endregion

#region Slide Off
###########################
## Slide Off HIJACK INFO ##
###########################

SlideOff:
#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)										#Send event struct
	mr	r4,r26												#Send match struct
	li	r5,Marth.Ext
	li	r6,PokemonStadium							#Use chosen Stage
	load r7,EventOSD_SlideOff
	li	r8,1										#Use Sopo bool
	bl	InitializeMatch

#STORE THINK FUNCTION
SlideOffStoreThink:
	bl	SlideOffLoad
	mflr	r3
	stw	r3,0x44(r26)		#on match load

b	exit

##################################
## 			Slide Off LOAD FUNCT 		##
##################################
SlideOffLoad:
	blrl

	backup

#Schedule Think
	bl	SlideOffThink
	mflr	r3
	li	r4,3		#Priority (After EnvCOllision)
  li  r5,0
	bl	CreateEventThinkFunction
	b	SlideOffThink_Exit

###################################
## Slide Off THINK FUNCT ##
###################################

SlideOffThink:
	blrl

#Registers
	.set REG_EventConstants,25
  .set REG_MenuData,26
  .set REG_EventData,31
  .set REG_P1Data,27
  .set REG_P1GObj,28
	.set REG_P2Data,29
	.set REG_P2GObj,30

#Event Data Offsets
	.set EventState,0x0
		.set EventState_Hitstun,0x0
		.set EventState_DetermineAttack,0x1
		.set EventState_AttackThink,0x2
		.set EventState_Shield,0x3
	.set Timer,0x1
	.set P1State,0x2
		.set P1State_Wait,0x0
		.set P1State_Attacking,0x1
	.set AttackTimer,0x3

#Constants
	.set ResetTimer,40
	.set AngleLo,83
	.set AngleHi,100
	.set MagLo,65
	.set MagHi,75
	.set HitlagFrames,12
	.set PercentLo,40
	.set PercentHi,40
	.set FramesBeforeHitbox,7

backup

#INIT FUNCTION VARIABLES
	lwz	REG_EventData,0x2c(r3)			#backup data pointer in r31

#Get Player Pointers
  bl GetAllPlayerPointers
  mr REG_P1GObj,r3
  mr REG_P1Data,r4
  mr REG_P2GObj,r5
  mr REG_P2Data,r6

#Get Menu and Constants Pointers
  lwz REG_MenuData,REG_EventData_REG_MenuDataPointer(REG_EventData)
	bl	SlideOffThink_Constants
	mflr REG_EventConstants

	bl	StoreCPUTypeAndZeroInputs

#ON FIRST FRAME
	bl	CheckIfFirstFrame
	cmpwi	r3,0x0
	beq	SlideOffThink_Start
	#Init Positions
		mr	r3,REG_P1GObj
		mr	r4,REG_P2GObj
		bl	SlideOff_InitializePositions
  #Clear Inputs
    bl  RemoveFirstFrameInputs
	#Save State
  	addi r3,REG_EventData,EventData_SaveStateStruct
		li	r4,1			#Override failsafe code
  	bl	SaveState_Save
	#Init State
		li	r3,EventState_Hitstun
		stb	r3,EventState(REG_EventData)
SlideOffThink_Start:

#Reset if anyone died
	bl	IsAnyoneDead
	cmpwi r3,0
	bne SlideOffThink_Restore

SlideOffThink_CheckIfFailed:
#Check if failed the slide off (in non-hitlag damage state)
#EventState > EventState_Hitstun
	lbz r3,EventState(REG_EventData)
	cmpwi r3,EventState_Hitstun
	ble SlideOffThink_CheckIfFailed_End
#Check for hitlag
	lbz r3,0x221A(REG_P1Data)
	rlwinm. r3,r3,0,26,26
	bne SlideOffThink_CheckIfFailed_End
#Check if in hitstun
	lbz r3,0x221C(REG_P1Data)
	rlwinm. r3,r3,0,30,30
	beq SlideOffThink_CheckIfFailed_End
#Check if player has been in this state for over 5 frames
	lhz r3,TM_FramesinCurrentAS(REG_P1Data)
	cmpwi r3,5
	blt SlideOffThink_CheckIfFailed_End
#Check if timer has started
	lbz r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt SlideOffThink_CheckTimer
#Start Timer
	li	r3,10
	stb r3,Timer(REG_EventData)
SlideOffThink_CheckIfFailed_End:

SlideOffThink_CheckIfCPUDamaged:
	lwz	r3,0x10(REG_P2Data)
	cmpwi r3,ASID_DamageHi1
	blt	SlideOffThink_CheckIfCPUDamaged_End
	cmpwi r3,ASID_DamageFlyRoll
	bgt	SlideOffThink_CheckIfCPUDamaged_End
#Check if timer has started
	lbz r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt SlideOffThink_CheckIfCPUDamaged_End
#Start Timer
	li	r3,ResetTimer
	stb r3,Timer(REG_EventData)
SlideOffThink_CheckIfCPUDamaged_End:

SlideOffThink_SwitchCase:
#Switch Case
	lbz r3,EventState(REG_EventData)
	cmpwi r3,EventState_Hitstun
	beq SlideOffThink_Hitstun
	cmpwi r3,EventState_DetermineAttack
	beq SlideOffThink_DetermineAttackorShield
	cmpwi r3,EventState_AttackThink
	beq SlideOffThink_AttackThink
	cmpwi r3,EventState_Shield
	beq SlideOffThink_Shield
	b	SlideOffThink_CheckTimer

#region SlideOffThink_Hitstun
SlideOffThink_Hitstun:
#Check if still in ThrowHi
	lwz r3,0x10(REG_P2Data)
	cmpwi r3,ASID_ThrowHi
	beq SlideOffThink_CheckTimer

#Check if P1 is in a tech/mistech state
	lwz r3,0x10(REG_P1Data)
	cmpwi r3,ASID_DownBoundU
	blt SlideOffThink_CheckTimer
	cmpwi r3,ASID_PassiveStandB
	bgt SlideOffThink_CheckTimer

#Change state to attack
	li	r3,EventState_DetermineAttack
	stb	r3,EventState(EventData)
	b	SlideOffThink_CheckTimer

#endregion

#region SlideOffThink_DetermineAttackorShield
SlideOffThink_DetermineAttackorShield:
/*
#Ensure facing correct direction
#Get Values
	lfs f1,0xB0(REG_P2Data)				#p2 position
	lfs f2,0x2C(REG_P2Data)				#p2 direction
	lfs f4,TriggerBoxXMin(REG_EventConstants)
	lfs f5,TriggerBoxXMax(REG_EventConstants)
	lfs f6,0xB0(REG_P1Data)
#Check X
	fmadds f3,f2,f4,f1				#XMin
	fmadds f4,f2,f5,f1				#XMax
#Make sure player is not behind marths range
	lfs f1,-0x68E0 (rtoc)			#fp 0
	fcmpo cr0,f2,f1
	bge SlideOffThink_Attck_FacingRight
SlideOffThink_Attck_FacingLeft:
	li	r3,1
	fcmpo cr0,f6,f3
	bge SlideOffThink_Attck_InputTurn
	b	SlideOffThink_Attck_SkipDirectionChange
SlideOffThink_Attck_FacingRight:
	li	r3,-1
	fcmpo cr0,f6,f3
	ble SlideOffThink_Attck_InputTurn
	b	SlideOffThink_Attck_SkipDirectionChange
SlideOffThink_Attck_InputTurn:
#Check if already turning
	lwz r4,0x10(REG_P2Data)
	cmpwi r4,ASID_Turn
	beq SlideOffThink_Attck_SkipDirectionChange
#Input turn
	mulli r3,r3,36
	stb r3,CPU_AnalogX(REG_P2Data)
SlideOffThink_Attck_SkipDirectionChange:
*/

SlideOffThink_DetermineAttackorShield_SkipFailCheck:

#Decide to shield or attack
	lfs f1,0xB4(REG_P2Data)				#p2 position
	lfs f2,TriggerBoxYMin(REG_EventConstants)
	lfs f3,TriggerBoxYMax(REG_EventConstants)
	lfs f4,0xB4(REG_P1Data)				#p1 position
	fadds f2,f1,f2						#YMin
	fadds f3,f1,f3						#YMax
#Check if P1 is above YMax
	fcmpo cr0,f4,f3
	bge SlideOffThink_DetermineAttackorShield_AboveTriggerBox
#Check if P1 is below YMin
	fcmpo cr0,f4,f2
	bge SlideOffThink_DetermineAttackorShield_CheckToAttack_CanAttack
SlideOffThink_DetermineAttackorShield_EnterShield:
#Change Event State
	li	r3,EventState_Shield
	stb	r3,EventState(REG_EventData)
#Start Timer
	li	r3,ResetTimer
	stb r3,Timer(REG_EventData)
	b	SlideOffThink_Shield

SlideOffThink_DetermineAttackorShield_AboveTriggerBox:
#Check if timer has started
	lbz r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt SlideOffThink_CheckTimer
#Start Timer
	li	r3,10
	stb r3,Timer(REG_EventData)
	b	SlideOffThink_CheckTimer

SlideOffThink_DetermineAttackorShield_CheckToAttack_CanAttack:
#Get P1's State
	lwz r3,0x10(REG_P1Data)
#Ensure we have the frame data for this state
	cmpwi r3,ASID_DownBoundU
	blt SlideOffThink_DetermineAttackorShield_CheckToAttack_StartAttack
	cmpwi r3,ASID_PassiveStandB
	bgt SlideOffThink_DetermineAttackorShield_CheckToAttack_StartAttack
#If DownWait or Bound, dont do anything
	cmpwi r3,ASID_DownWaitD
	beq SlideOffThink_DetermineAttackorShield_CheckToAttackEnd
	cmpwi r3,ASID_DownWaitU
	beq SlideOffThink_DetermineAttackorShield_CheckToAttackEnd
	cmpwi r3,ASID_DownBoundD
	beq SlideOffThink_DetermineAttackorShield_CheckToAttackEnd
	cmpwi r3,ASID_DownBoundU
	beq SlideOffThink_DetermineAttackorShield_CheckToAttackEnd
#Get the frame data to use
	subi r3,r3,ASID_DownBoundU
	addi r4,REG_EventConstants,VulnFrameData
	lbzx r3,r3,r4
#Marth takes 8 frames for his utilt hitbox to appear, so subtract 8
	subi r3,r3,FramesBeforeHitbox
#Use the custom playerblock offset to check P1's frame count
	lhz r4,TM_FramesinCurrentAS(REG_P1Data)
	cmpw r4,r3
	blt SlideOffThink_DetermineAttackorShield_CheckToAttackEnd
#Time to attack
SlideOffThink_DetermineAttackorShield_CheckToAttack_StartAttack:
	li	r3,EventState_AttackThink
	stb r3,EventState(REG_EventData)
	b	SlideOffThink_DetermineAttackorShield_CheckToAttackEnd
SlideOffThink_DetermineAttackorShield_CheckToAttackEnd:
	b	SlideOffThink_CheckTimer

#endregion

#region SlideOffThink_AttackThink
SlideOffThink_AttackThink:
#Get Inputs for this frame
	mr	r3,REG_P2Data
	bl	SlideOffThink_AttackInputs
	mflr r4
	lbz r5,AttackTimer(REG_EventData)
	bl	PlaybackInputSequence

#Always succeed LCancel
	li	r3,0
	stb r3,0x67F(REG_P2Data)

#Remove Hitbox ID 1,2 and 3 (problematic for getting slideoff)
	mr	r3,REG_P2GObj
	li	r4,1
	branchl r12,0x8007afc8
	mr	r3,REG_P2GObj
	li	r4,2
	branchl r12,0x8007afc8
	mr	r3,REG_P2GObj
	li	r4,3
	branchl r12,0x8007afc8

#Exit AttackThink when returning to Wait
	lbz r3,AttackTimer(REG_EventData)
	cmpwi r3,0
	ble SlideOffThink_AttackThink_Exit
	lwz r3,0x10(REG_P2Data)
	cmpwi r3,ASID_Wait
	beq SlideOffThink_AttackThink_Reset
	cmpwi r3,ASID_Landing
	bne SlideOffThink_AttackThink_Exit
#Now check if interruptable
	lwz	r3, 0x2340 (REG_P2Data)
	cmpwi r3,0
	beq SlideOffThink_AttackThink_Exit
#Check if this frame is interruptable
	lfs f1,0x1f4 (REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	lhz r4,TM_FramesinCurrentAS(REG_P2Data)
	cmpw r4,r3
	blt SlideOffThink_AttackThink_Exit

SlideOffThink_AttackThink_Reset:
	li	r3,EventState_DetermineAttack			#event state
	stb r3,EventState(REG_EventData)
	li	r3,0															#reset timer
	stb r3,AttackTimer(REG_EventData)
	b	SlideOffThink_CheckTimer

SlideOffThink_AttackThink_Exit:
#Check if in Hitlag
	lbz r3,0x221A(REG_P2Data)
	rlwinm. r3,r3,0,26,26
	bne SlideOffThink_CheckTimer
#Increment Attack Timer
	lbz r3,AttackTimer(REG_EventData)
	addi r3,r3,1
	stb r3,AttackTimer(REG_EventData)
	b	SlideOffThink_CheckTimer
#endregion

#region SlideOffThink_Shield
SlideOffThink_Shield:
#Hold Shield
	li	r3,PAD_TRIGGER_R
	stw	r3,CPU_HeldButtons(REG_P2Data)
	b	SlideOffThink_CheckTimer
#endregion

SlideOffThink_CheckTimer:
#Check if timer exists
	lbz r3,Timer(REG_EventData)
	cmpwi r3,0
	ble SlideOffThink_Exit
#Decrement timer
	subi r3,r3,1
	stb r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt SlideOffThink_Exit

SlideOffThink_Restore:
#Restore State
	addi r3,REG_EventData,EventData_SaveStateStruct
	li	r4,1
	bl	SaveState_Load
#Init Positions Again
	mr	r3,REG_P1GObj
	mr	r4,REG_P2GObj
	bl	SlideOff_InitializePositions
#Reset Variables
	li	r3,0
	stb r3,EventState(REG_EventData)
	stb r3,Timer(REG_EventData)
	stb r3,P1State(REG_EventData)
	stb r3,AttackTimer(REG_EventData)

SlideOffThink_Exit:
	restore
	blr

################################

SlideOffThink_Constants:
blrl
.set MarthUTiltFrame,8
.set P1X,0x0
.set P1Y,0x4
.set P2X,0x8
.set P2Y,0xC
.set UThrowStartFrame,0x10
.set DamageFlyTopStartFrame,0x14
.set MagnitudeScalar,0x18
.set MagnitudeScalar2,0x1C
.set MagnitudeScalar3,0x20
.set TriggerBoxXMin,0x24
.set TriggerBoxXMax,0x28
.set TriggerBoxYMin,0x2C
.set TriggerBoxYMax,0x30
.set VulnFrameData,0x34
.set Unk,0x48

.float -37.7		#p1 x
.float 21.2			#p1 y
.float -41.1		#p2 x
.float 0				#p2 y
.float 13				#marth upthrow starting frame
.float 2				#p1 damageflytop starting frame
.float 0.1			#baseline for mag scaling
.float 1				#mag scaling constant
.float 0.4			#mag scaling constant
.float -8				#xmin
.float 20				#xmax
.float 18				#ymin
.float 30				#ymax
##########################################
.set TechVuln,24-4
.set TechRollVuln,23
.set KnockdownVuln,23
.set GetupVuln,23
.set GetupRollForwardVuln,20-1
.set GetupRollBackwardVuln,30-3
.set GetupAttackVuln,27

.byte KnockdownVuln					#DownBoundU
.byte 0											#DownWaitU
.byte 0											#DownDamageU
.byte GetupVuln							#DownStandU
.byte GetupAttackVuln				#DownAttackU
.byte GetupRollForwardVuln	#DownForwardU
.byte GetupRollBackwardVuln	#DownBackU
.byte -1										#DownSpotU (unused state)
.byte KnockdownVuln					#DownBoundD
.byte 0											#DownWaitD
.byte 0											#DownDamageD
.byte GetupVuln							#DownStandD
.byte GetupAttackVuln				#DownAttackD
.byte GetupRollForwardVuln	#DownForwardD
.byte GetupRollBackwardVuln	#DownBackD
.byte -1										#DownSpotD (unused state)
.byte TechVuln							#Passive
.byte TechRollVuln					#PassiveStandF
.byte TechRollVuln					#PassiveStandB
.align 2
###########################################
SlideOffThink_AttackInputs:
blrl
.byte 0
.long PAD_BUTTON_X
.byte 0,0,0,0

.byte 4
.long 0
.byte 0,0,0,127

.byte 26
.long PAD_TRIGGER_L
.byte 0,-127,0,0

.byte -1
.align 2

#################################

SlideOff_InitializePositions:
backup

 #Change Facing Direction
	li	r3,-1
	bl	IntToFloat
	stfs	f1,0x2C(REG_P1Data)
  li	r3,1
  bl	IntToFloat
  stfs	f1,0x2C(REG_P2Data)

#Get Starting Coordinates
	lfs f1,P1X(REG_EventConstants)
	stfs f1,0xB0(REG_P1Data)
	lfs f1,P1Y(REG_EventConstants)
	stfs f1,0xB4(REG_P1Data)
	mr	r3,REG_P1GObj
	bl	UpdatePosition
	mr	r3,REG_P1GObj
	bl	UpdateCameraBox

	lfs f1,P2X(REG_EventConstants)
	stfs f1,0xB0(REG_P2Data)
	lfs f1,P2Y(REG_EventConstants)
	stfs f1,0xB4(REG_P2Data)
	mr	r3,REG_P2GObj
	bl	PlacePlayerOnGround
	mr	r3,REG_P2GObj
	bl	UpdateCameraBox

#P2 enters UpThrow
	mr	r3,REG_P2GObj
	li	r4,ASID_ThrowHi
	li	r5,0
	li	r6,0
	lwz r7,0x10C(REG_P1Data)		#determine speed from weight
	lwz r7,0x0(r7)
	lfs f1,0x88(r7)
	lfs	f2, -0x68DC (rtoc)
	lwz	r7, -0x514C (r13)
	lfs	f0, 0x037C (r7)
	fmuls	f0,f1,f0
	fdivs	f2,f2,f0															#anim speed
	lfs	f3, -0x68E0 (rtoc)											#frame blend
	lfs f1,UThrowStartFrame(REG_EventConstants)	#starting frame
	branchl r12,ActionStateChange

#P1 enters DamageFlyTop
	mr	r3,REG_P1GObj
	li	r4,ASID_DamageFlyTop
	li	r5,0x40
	li	r6,0
	lfs	f1,DamageFlyTopStartFrame (REG_EventConstants)
	lfs	f2, -0x73D0 (rtoc)
	lfs	f3, -0x750C (rtoc)
	branchl r12,ActionStateChange

#Scale KB Magnitude based on characters weight
	li	r3,MagLo
	bl	IntToFloat
	lfs f2,MagnitudeScalar(REG_EventConstants)
	lfs f3,0x16C(REG_P1Data)
	lfs f4,MagnitudeScalar2(REG_EventConstants)
	lfs f5,MagnitudeScalar3(REG_EventConstants)
	fdivs f2,f3,f2
	fsubs f2,f2,f4
	fmuls f2,f2,f5
	fmuls f2,f2,f1
	fadds f1,f1,f2
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r20,0x84(sp)

	li	r3,MagHi
	bl	IntToFloat
	lfs f2,MagnitudeScalar(REG_EventConstants)
	lfs f3,0x16C(REG_P1Data)
	lfs f4,MagnitudeScalar2(REG_EventConstants)
	lfs f5,MagnitudeScalar3(REG_EventConstants)
	fdivs f2,f3,f2
	fsubs f2,f2,f4
	fmuls f2,f2,f5
	fmuls f2,f2,f1
	fadds f1,f1,f2
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r21,0x84(sp)

#Enter into knockback
	mr	r3,REG_P1GObj
	li	r4,AngleLo
	li	r5,AngleHi
	mr	r6,r20
	mr	r7,r21
	bl	EnterKnockback

#Override hitstun amount
	li	r3,50
	bl	IntToFloat
	stfs f1,0x2340(REG_P1Data)

#Give 7 Frames of Hitlag to Each
	li	r3,HitlagFrames
	bl	IntToFloat
	stfs f1,0x195C(REG_P1Data)
	lbz r0,0x221A(REG_P1Data)
	li	r3,1
	rlwimi r0,r3,5,26,26
	stb r0,0x221A(REG_P1Data)
	lbz r0,0x2219(REG_P1Data)
	li	r3,1
	rlwimi r0,r3,2,29,29
	stb r0,0x2219(REG_P1Data)
	li	r3,HitlagFrames
	bl	IntToFloat
	stfs f1,0x195C(REG_P2Data)
	lbz r0,0x221A(REG_P2Data)
	li	r3,1
	rlwimi r0,r3,5,26,26
	stb r0,0x221A(REG_P2Data)
	lbz r0,0x2219(REG_P2Data)
	li	r3,1
	rlwimi r0,r3,2,29,29
	stb r0,0x2219(REG_P2Data)

#Random percent between 10-25
	li	r3,PercentHi-PercentLo
	branchl r12,HSD_Randi
	addi r4,r3,PercentLo
	lbz r3,0xC(REG_P1Data)
	branchl r12,PlayerBlock_SetDamage

SlideOff_InitializePositions_Exit:
	restore
	blr

#endregion

#region Grab Mash Out
###########################
## Grab Mash Out HIJACK INFO ##
###########################

GrabMashOut:
#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)										#Send event struct
	mr	r4,r26												#Send match struct
	li	r5,Marth.Ext
	li	r6,FinalDestination						#Use chosen Stage
	load r7,EventOSD_GrabMashOut
	li	r8,1										#Use Sopo bool
	bl	InitializeMatch

#STORE THINK FUNCTION
GrabMashOutStoreThink:
	bl	GrabMashOutLoad
	mflr	r3
	stw	r3,0x44(r26)		#on match load

b	exit

##################################
## 			Grab Mash Out LOAD FUNCT 		##
##################################
GrabMashOutLoad:
	blrl

	backup

#Schedule Think
	bl	GrabMashOutThink
	mflr	r3
	li	r4,3		#Priority (After EnvCOllision)
  li  r5,0
	bl	CreateEventThinkFunction
	b	GrabMashOutThink_Exit

###################################
## Grab Mash Out THINK FUNCT ##
###################################

GrabMashOutThink:
	blrl

#Registers
	.set REG_EventConstants,25
  .set REG_MenuData,26
  .set REG_EventData,31
  .set REG_P1Data,27
  .set REG_P1GObj,28
	.set REG_P2Data,29
	.set REG_P2GObj,30

#Event Data Offsets
	.set EventState,0x0
		.set EventState_ThrowDelay,0x0
		.set EventState_MashOutThink,0x1
		.set EventState_Reset,0x2
	.set Timer,0x1
	.set ThrowTimer,0x2
	.set GrabBreakout,0x4

#Constants
	.set ResetTimer,80
	.set PercentLo,0
	.set PercentHi,80
	.set ThrowTimerLo,40
	.set ThrowTimerHi,100

backup

#INIT FUNCTION VARIABLES
	lwz	REG_EventData,0x2c(r3)			#backup data pointer in r31

#Get Player Pointers
  bl GetAllPlayerPointers
  mr REG_P1GObj,r3
  mr REG_P1Data,r4
  mr REG_P2GObj,r5
  mr REG_P2Data,r6

#Get Menu and Constants Pointers
  lwz REG_MenuData,REG_EventData_REG_MenuDataPointer(REG_EventData)
	bl	GrabMashOutThink_Constants
	mflr REG_EventConstants

	bl	StoreCPUTypeAndZeroInputs

#ON FIRST FRAME
	bl	CheckIfFirstFrame
	cmpwi	r3,0x0
	beq	GrabMashOutThink_Start
	#Init Positions
		mr	r3,REG_P1GObj
		mr	r4,REG_P2GObj
		mr	r5,REG_EventData
		bl	GrabMashOut_InitializePositions
  #Clear Inputs
    bl  RemoveFirstFrameInputs
	#Save State
  	addi r3,REG_EventData,EventData_SaveStateStruct
		li	r4,1			#Override failsafe code
  	bl	SaveState_Save
GrabMashOutThink_Start:

#Reset if anyone died
	bl	IsAnyoneDead
	cmpwi r3,0
	bne GrabMashOutThink_Restore

GrabMashOutThink_SwitchCase:
#Switch Case
	lbz r3,EventState(REG_EventData)
	cmpwi r3,EventState_ThrowDelay
	beq GrabMashOutThink_ThrowDelay
	cmpwi r3,EventState_MashOutThink
	beq GrabMashOutThink_MashOutThink
	cmpwi r3,EventState_Reset
	beq GrabMashOutThink_Reset
	b	GrabMashOutThink_CheckTimer

#region GrabMashOutThink_ThrowDelay
GrabMashOutThink_ThrowDelay:
#Check to grab
	lhz r3,ThrowTimer(REG_EventData)
	subi r3,r3,1
	sth r3,ThrowTimer(REG_EventData)
	cmpwi r3,0
	bne GrabMashOutThink_ThrowDelay_TimerSkip
#Input grab
	li	r3,PAD_BUTTON_A | PAD_TRIGGER_R
	stw r3,CPU_HeldButtons(REG_P2Data)
GrabMashOutThink_ThrowDelay_TimerSkip:

#Check if P1 was grabbed
	lwz r3,0x10(REG_P1Data)
	cmpwi r3,ASID_CaptureWaitLw
	beq GrabMashOutThink_ThrowDelay_Grabbed
	cmpwi r3,ASID_CaptureWaitHi
	beq GrabMashOutThink_ThrowDelay_Grabbed
#If just grabbed, skip
	cmpwi r3,ASID_CapturePulledLw
	beq GrabMashOutThink_CheckTimer
	cmpwi r3,ASID_CapturePulledHi
	beq GrabMashOutThink_CheckTimer
#Check if P1 acted early
	cmpwi r3,ASID_Wait
	bne GrabMashOutThink_ThrowDelay_ActedEarly
	b	GrabMashOutThink_CheckTimer

GrabMashOutThink_ThrowDelay_Grabbed:
#Get breakout timer
	lfs f1,0x2354(REG_P1Data)
	stfs f1,GrabBreakout(REG_EventData)
#Change state to attack
	li	r3,EventState_MashOutThink
	stb	r3,EventState(EventData)
	b	GrabMashOutThink_CheckTimer
GrabMashOutThink_ThrowDelay_ActedEarly:
#Play Error Noise
	li	r3,0xAF
	bl	PlaySFX
#Set Timer
	li	r3,ResetTimer-40
	stb r3,Timer(REG_EventData)
#Change state to reset
	li	r3,EventState_Reset
	stb	r3,EventState(EventData)
	b	GrabMashOutThink_CheckTimer

#endregion

#region GrabMashOutThink_MashOutThink
GrabMashOutThink_MashOutThink:
#Wait for P1 to be in CaptureCut
	lwz r3,0x10(REG_P1Data)
	cmpwi r3,ASID_CaptureJump
	beq GrabMashOutThink_BrokeOut
	cmpwi r3,ASID_CaptureCut
	beq GrabMashOutThink_BrokeOut
	b GrabMashOutThink_CheckTimer

GrabMashOutThink_BrokeOut:
#Set reset timer
	li	r3,ResetTimer
	stb r3,Timer(REG_EventData)
#Advance State
	li	r3,EventState_Reset
	stb r3,EventState(REG_EventData)
	b	GrabMashOutThink_CheckTimer

#endregion

#region GrabMashOutThink_Reset
GrabMashOutThink_Reset:
	b	GrabMashOutThink_CheckTimer
#endregion

GrabMashOutThink_CheckTimer:
#Check if timer exists
	lbz r3,Timer(REG_EventData)
	cmpwi r3,0
	ble GrabMashOutThink_Exit
#Decrement timer
	subi r3,r3,1
	stb r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt GrabMashOutThink_Exit

GrabMashOutThink_Restore:
#Restore State
	addi r3,REG_EventData,EventData_SaveStateStruct
	li	r4,1
	bl	SaveState_Load
#Init Positions Again
	mr	r3,REG_P1GObj
	mr	r4,REG_P2GObj
	mr	r5,REG_EventData
	bl	GrabMashOut_InitializePositions

GrabMashOutThink_Exit:
	restore
	blr

################################

GrabMashOutThink_Constants:
blrl
.set P1X,0x0
.set P1Y,0x4
.set P2X,0x8
.set P2Y,0xC

.float -8		#p1 x
.float  0		#p1 y
.float  8		#p2 x
.float  0		#p2 y
###########################################

GrabMashOut_TopText:
blrl
.string "Escaped Grab"
.align 2

GrabMashOut_BottomText:
blrl
.string "Frame %d/%d"
.align 2
###########################################

GrabMashOut_InitializePositions:
backup

.set REG_FacingDirection,31		#1 = p1 facing right, -1 = p1 facing left
.set REG_P1GObj,30
.set REG_P1Data,29
.set REG_P2GObj,28
.set REG_P2Data,27
.set REG_EventData,26

#Init Registers
  mr	REG_P1GObj,r3
  lwz REG_P1Data,0x2C(REG_P1GObj)
  mr	REG_P2GObj,r4
  lwz REG_P2Data,0x2C(REG_P2GObj)
	mr	REG_EventData,r5

GrabMashOut_InitializePositions_DetermineFacingDirection:
#Determine Facing Direction
	li	REG_FacingDirection,1
	li	r3,2
	branchl r12,HSD_Randi
	cmpwi r3,0
	beq GrabMashOut_InitializePositions_DetermineFacingDirection_End
	li	REG_FacingDirection,-1
GrabMashOut_InitializePositions_DetermineFacingDirection_End:

 #Apply Facing Directions
	mr	r3,REG_FacingDirection
	bl	IntToFloat
	stfs	f1,0x2C(REG_P1Data)
  mulli	r3,REG_FacingDirection,-1
  bl	IntToFloat
  stfs	f1,0x2C(REG_P2Data)

#Get Starting Coordinates
	lfs f1,P1X(REG_EventConstants)
	lfs f2,P1Y(REG_EventConstants)
	cmpwi REG_FacingDirection,0
	blt GrabMashOut_InitializePositions_P1FacingLeft
	stfs f1,0xB0(REG_P1Data)
	stfs f2,0xB4(REG_P1Data)
	b	GrabMashOut_InitializePositions_RightPosition
GrabMashOut_InitializePositions_P1FacingLeft:
	stfs f1,0xB0(REG_P2Data)
	stfs f2,0xB4(REG_P2Data)
GrabMashOut_InitializePositions_RightPosition:
	lfs f1,P2X(REG_EventConstants)
	lfs f2,P2Y(REG_EventConstants)
	cmpwi REG_FacingDirection,0
	blt GrabMashOut_InitializePositions_P2FacingRight
	stfs f1,0xB0(REG_P2Data)
	stfs f2,0xB4(REG_P2Data)
	b	GrabMashOut_InitializePositions_FacingEnd
GrabMashOut_InitializePositions_P2FacingRight:
	stfs f1,0xB0(REG_P1Data)
	stfs f2,0xB4(REG_P1Data)
GrabMashOut_InitializePositions_FacingEnd:

#Update Positions
	mr	r3,REG_P1GObj
	bl	PlacePlayerOnGround
	mr	r3,REG_P1GObj
	bl	UpdateCameraBox
	mr	r3,REG_P2GObj
	bl	PlacePlayerOnGround
	mr	r3,REG_P2GObj
	bl	UpdateCameraBox

#Enter P1 Into Wait
	mr	r3,REG_P1GObj
	branchl	r12,AS_Wait
#Enter P2 Into Wait
	mr	r3,REG_P2GObj
	branchl	r12,AS_Wait

#Random percent
	li	r3,PercentHi-PercentLo
	branchl r12,HSD_Randi
	addi r4,r3,PercentLo
	lbz r3,0xC(REG_P1Data)
	branchl r12,PlayerBlock_SetDamage

#Reset Variables
	li	r3,EventState_ThrowDelay
	stb r3,EventState(REG_EventData)
	li	r3,0
	stb r3,Timer(REG_EventData)
#Init Throw Timer
	li	r3,ThrowTimerHi-ThrowTimerLo
	branchl r12,HSD_Randi
	addi r3,r3,ThrowTimerLo
	sth r3,ThrowTimer(REG_EventData)

GrabMashOut_InitializePositions_Exit:
	restore
	blr

#endregion

#region SDI IC DThrow Dair
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
					addi r3,EventData,EventData_SaveStateStruct
					li	r4,1			#Override failsafe code
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
#endregion

##############
## Fox Tech ##
##############

#region Ledgetech Counter
###################################
## Ledgetech Counter HIJACK INFO ##
###################################

LedgetechCounter:
#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)										#Send event struct
	mr	r4,r26												#Send match struct
	li	r5,Marth.Ext									#Use marth
	li	r6,-1													#Use chosen Stage
	load r7,EventOSD_LedgetechCounter
	li	r8,0													#Use Sopo bool
	bl	InitializeMatch

#STORE THINK FUNCTION
LedgetechCounterStoreThink:
	bl	LedgetechCounterLoad
	mflr	r3
	stw	r3,0x44(r26)		#on match load

b	exit

##################################
## Ledgetech Counter LOAD FUNCT ##
##################################
LedgetechCounterLoad:
	blrl

	backup

#Schedule Think
	bl	LedgetechCounterThink
	mflr	r3
	li	r4,3		#Priority (After EnvCOllision)
  li  r5,0
	bl	CreateEventThinkFunction
	b	LedgetechCounterThink_Exit

###################################
## Ledgetech Counter THINK FUNCT ##
###################################

LedgetechCounterThink:
	blrl

#Registers
	.set EventConstants,25
  .set MenuData,26
  .set EventData,31
  .set P1Data,27
  .set P1GObj,28
	.set P2Data,29
	.set P2GObj,30

#Event Data Offsets
	.set EventState,0x0
		.set EventState_OnRebirthPlat,0x0
		.set EventState_Recovering,0x1
	.set MarthState,0x1
		.set MarthState_Wait,0x0
		.set MarthState_Attacked,0x1
	.set Timer,0x2

backup

#INIT FUNCTION VARIABLES
	lwz		EventData,0x2c(r3)			#backup data pointer in r31

  bl  GetAllPlayerPointers
  mr P1GObj,r3
  mr P1Data,r4
  mr P2GObj,r5
  mr P2Data,r6

  lwz MenuData,EventData_MenuDataPointer(EventData)

	bl	LedgetechCounter_Constants
	mflr EventConstants

	bl	StoreCPUTypeAndZeroInputs

#ON FIRST FRAME
	bl	CheckIfFirstFrame
	cmpwi	r3,0x0
	beq	LedgetechCounterThink_Start
	#Random Side of Stage
		li  r3,2
		branchl r12,HSD_Randi
		bl  Ledgetech_InitializePositions
	#Move Marth forward a bit
		lfs f1,0x2C(P2Data)
		lfs f2,0x4(EventConstants)
		fmuls f1,f1,f2
		lfs f2,0xB0(P2Data)
		fadds f1,f1,f2
		stfs f1,0xB0(P2Data)
	#Move Falco down a bit
		lfs f1,0x8(EventConstants)
		lfs f2,0xB4(P1Data)
		fadds f1,f1,f2
		stfs f1,0xB4(P1Data)
  #Clear Inputs
    bl  RemoveFirstFrameInputs
	#Save State
  	addi r3,EventData,EventData_SaveStateStruct
		li	r4,1			#Override failsafe code
  	bl	SaveState_Save
	#Init Score Count
  	lhz	r3,-0x4ea8(r13)
  	branchl	r12,HUD_KOCounter_UpdateKOs

LedgetechCounterThink_Start:

#Reset if anyone died
	bl	IsAnyoneDead
	cmpwi r3,0
	bne LedgetechCounterThink_Restore

#Switch case for state of event
	lbz r3,EventState(EventData)
	cmpwi r3,EventState_OnRebirthPlat
	beq LedgetechCounterThink_OnRebirthPlat
	cmpwi r3,EventState_Recovering
	beq LedgetechCounterThink_Recovering
	b	LedgetechCounterThink_CheckForTimer

###########################################
LedgetechCounterThink_OnRebirthPlat:
#Check if exited RebirthWait
	lwz r3,0x10(P1Data)
	cmpwi r3,ASID_RebirthWait
	beq LedgetechCounterThink_OnRebirthPlat_ExtendTimer
#Change Event State
	li	r3,EventState_Recovering
	stb r3,EventState(EventData)
	b	LedgetechCounterThink_CheckForTimer
LedgetechCounterThink_OnRebirthPlat_ExtendTimer:
#Extend RebithWait Timer
	li	r3,2
	stw r3,0x2340(P1Data)
	b	LedgetechCounterThink_CheckForTimer
###########################################

###########################################
LedgetechCounterThink_Recovering:
#Check if marth acted already
	lbz r3,MarthState(EventData)
	cmpwi r3,MarthState_Wait
	bne LedgetechCounterThink_CheckForTimer

#Check P1s Distance from Marth
	addi r3,P1Data,0xB0
	addi r4,P2Data,0xB0
	bl	GetDistance
	lfs f2,0x0(EventConstants)
	fcmpo cr0,f1,f2
	bgt LedgetechCounterThink_CheckForTimer
#P1 is in range, use down B
	li	r3,0x200
	stw r3,CPU_HeldButtons(P2Data)
	li	r3,-127
	stb r3,CPU_AnalogY(P2Data)
#Set as attacking
	li	r3,MarthState_Attacked
	stb r3,MarthState(EventData)
#Start Timer
	li	r3,70
	stb r3,Timer(EventData)

	b	LedgetechCounterThink_CheckForTimer
############################################

LedgetechCounterThink_CheckForTimer:
#Check Timer
	lbz r3,Timer(EventData)
	cmpwi r3,0
	beq LedgetechCounterThink_Exit
#Decrement
	subi r3,r3,1
	stb r3,Timer(EventData)
	cmpwi r3,0
	bne LedgetechCounterThink_Exit

LedgetechCounterThink_Restore:
#Load State
  addi r3,EventData,EventData_SaveStateStruct
  bl	SaveState_Load
#Random Side of Stage
	li  r3,2
	branchl r12,HSD_Randi
	bl  Ledgetech_InitializePositions
#Move Marth forward a bit
	lfs f1,0x2C(P2Data)
	lfs f2,0x4(EventConstants)
	fmuls f1,f1,f2
	lfs f2,0xB0(P2Data)
	fadds f1,f1,f2
	stfs f1,0xB0(P2Data)
#Move Falco down a bit
	lfs f1,0x8(EventConstants)
	lfs f2,0xB4(P1Data)
	fadds f1,f1,f2
	stfs f1,0xB4(P1Data)

#Reset Variables
	li	r3,EventState_OnRebirthPlat
	stb r3,EventState(EventData)
	li	r3,MarthState_Wait
	stb r3,MarthState(EventData)
	li	r3,0
	stb r3,Timer(EventData)

LedgetechCounterThink_Exit:
	restore
	blr


######
LedgetechCounter_Constants:
blrl
.float 33		#Mm away from fox to init counter
.float 5		#Mm to move marth forward after placing on ledge
.float -15		#Mm to move spacies down after placing in the air
######

#endregion

#region Armada Shine
###################################
## Armada Shine HIJACK INFO ##
###################################

ArmadaShine:
#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)										#Send event struct
	mr	r4,r26												#Send match struct
	li	r5,Fox.Ext										#Use fox
	li	r6,-1													#Use chosen Stage
	load r7,EventOSD_ArmadaShine
	li	r8,0													#Use Sopo bool
	bl	InitializeMatch

#STORE THINK FUNCTION
ArmadaShineStoreThink:
	bl	ArmadaShineLoad
	mflr	r3
	stw	r3,0x44(r26)		#on match load

b	exit

##################################
## Armada Shine LOAD FUNCT ##
##################################
ArmadaShineLoad:
	blrl

	backup

#Schedule Think
	bl	ArmadaShineThink
	mflr	r3
	li	r4,3		#Priority (After EnvCOllision)
  li  r5,0
	bl	CreateEventThinkFunction

#Remove randall
	lwz	r3,StageID_External(r13)
	cmpwi	r3,YoshiStory
	bne	LedgedashLoad_SkipRemoveRandall
#Get randall's map_gobj
	li	r3,2				#randalls map_gobj is 2
	branchl r12,Stage_map_gobj_Load
	branchl r12,Stage_Destroy_map_gobj

	b	ArmadaShineThink_Exit

###################################
## Armada Shine THINK FUNCT ##
###################################

ArmadaShineThink:
	blrl

#Registers
	.set REG_EventConstants,25
  .set REG_MenuData,26
  .set REG_EventData,31
  .set REG_P1Data,27
  .set REG_P1GObj,28
	.set REG_P2Data,29
	.set REG_P2GObj,30

#Event Data Offsets
	.set EventState,0x0
		.set	EventState_Hitstun,0x0
		.set	EventState_Falling,0x1
		.set	EventState_RecoverStart,0x2
		.set	EventState_RecoverEnd,0x3
		.set	EventState_Reset,0x4
	.set Timer,0x1

#Constants
.set ResetTimer,80
.set	QuickResetTimer,30
.set PercentLo,0
.set PercentHi,60

backup

#INIT FUNCTION VARIABLES
	lwz	REG_EventData,0x2c(r3)			#backup data pointer in r31

#Get Player Pointers
  bl GetAllPlayerPointers
  mr REG_P1GObj,r3
  mr REG_P1Data,r4
  mr REG_P2GObj,r5
  mr REG_P2Data,r6

#Get Menu and Constants Pointers
  lwz REG_MenuData,REG_EventData_REG_MenuDataPointer(REG_EventData)
	bl	ArmadaShineThink_Constants
	mflr REG_EventConstants

	bl	StoreCPUTypeAndZeroInputs

#ON FIRST FRAME
	bl	CheckIfFirstFrame
	cmpwi	r3,0x0
	beq	ArmadaShineThink_Start
	#Init Positions
		mr	r3,REG_P1GObj
		mr	r4,REG_P2GObj
		bl	ArmadaShine_InitializePositions
  #Clear Inputs
    bl  RemoveFirstFrameInputs
	#Save State
  	addi r3,REG_EventData,EventData_SaveStateStruct
		li	r4,1			#Override failsafe code
  	bl	SaveState_Save
	#Init State
		li	r3,EventState_Hitstun
		stb	r3,EventState(REG_EventData)
ArmadaShineThink_Start:

#Reset if anyone died
	bl	IsAnyoneDead
	cmpwi r3,0
	bne ArmadaShineThink_Restore

#DPad left to instant reset
  lbz	r3, 0x0618 (REG_P1Data)
  bl	GetInputStruct
	lwz	r4,InputStruct_InstantButtons(r3)
	rlwinm. r0,r4,0,31,31
	bne	ArmadaShineThink_Restore

ArmadaShineThink_GroundCheck:
#If P2 is grounded, reset quick
	lwz	r3,0xE0(REG_P2Data)
	cmpwi	r3,0
	beq	ArmadaShineThink_GroundCheck_OnGround
#If P2 is grabbing a cliff, reset quick
	lwz	r3,0x10(REG_P2Data)
	cmpwi	r3,ASID_CliffCatch
	beq	ArmadaShineThink_GroundCheck_OnGround
	b	ArmadaShineThink_GroundCheckSkip
ArmadaShineThink_GroundCheck_OnGround:
#Check if timer was set
	lbz r3,Timer(REG_EventData)
	cmpwi	r3,QuickResetTimer
	ble	ArmadaShineThink_GroundCheckSkip
#Set timer
	li	r3,QuickResetTimer
	stb r3,Timer(REG_EventData)
#Change State
	li	r3,EventState_Reset
	stb	r3,EventState(REG_EventData)
ArmadaShineThink_GroundCheckSkip:

#Switch Case
	lbz r3,EventState(REG_EventData)
	cmpwi r3,EventState_Hitstun
	beq ArmadaShineThink_Hitstun
	cmpwi r3,EventState_Falling
	beq ArmadaShineThink_Falling
	cmpwi r3,EventState_RecoverStart
	beq ArmadaShineThink_RecoverStart
	cmpwi r3,EventState_RecoverEnd
	beq ArmadaShineThink_RecoverEnd
	cmpwi	r3,EventState_Reset
	beq	ArmadaShineThink_Reset
	b	ArmadaShineThink_Exit

#region ArmadaShineThink_Hitstun
ArmadaShineThink_Hitstun:
#Check if still in hitstun
	lbz	r3,0x221C(REG_P2Data)
	rlwinm. r3,r3,0,30,30
	bne	ArmadaShineThink_Hitstun_Exit
#Change Event State
	li	r3,EventState_Falling
	stb	r3,EventState(REG_EventData)
#Run Next State Code
	b	ArmadaShineThink_Falling

ArmadaShineThink_Hitstun_Exit:
#Always L-Cancel
	li	r3,0
	stb r3,0x67F(REG_P1Data)
	b	ArmadaShineThink_Exit
#endregion

#region ArmadaShineThink_Falling
ArmadaShineThink_Falling:
.set FirefoxRadius,80
.set FirefoxChance,8
#Get distance from ledge
	addi r3,REG_P2Data,0xB0
	addi r4,REG_P2Data,0x1ADC
	bl	GetDistance
	stfs	f1,0x80(sp)
#Fox travels approx 82 Mm during firefox, so ensure he is at least this far
	li	r3,FirefoxRadius
	bl	IntToFloat
	lfs f2,0x80(sp)
	fcmpo cr0,f2,f1
	bge ArmadaShineThink_Falling_EnterFirefox
#Random chance to firefox
	li	r3,FirefoxChance
	branchl r12,HSD_Randi
	cmpwi r3,0
	beq ArmadaShineThink_Falling_EnterFirefox
	b	ArmadaShineThink_Exit

ArmadaShineThink_Falling_EnterFirefox:
#Enter Firefox
	li	r3,127
	stb r3,CPU_AnalogY(REG_P2Data)
	li	r3,PAD_BUTTON_B
	stw r3,CPU_HeldButtons(REG_P2Data)
#Change Event State
	li	r3,EventState_RecoverStart
	stb	r3,EventState(REG_EventData)
#Exit
	b	ArmadaShineThink_Exit
#endregion

#region ArmadaShineThink_RecoverStart
ArmadaShineThink_RecoverStart:
.set RestartTimer,30
.set FirefoxHoldFrames,43

ArmadaShineThink_RecoverStart_CheckIfDone:
#Check if no longer in SpecialHiStart
	lwz r3,0x10(REG_P2Data)
	cmpwi r3,354
	beq ArmadaShineThink_RecoverStart_CheckIfDoneSkip
#Start restart timer
	lwz	r3,0x4(REG_P1Data)
	cmpwi	r3,Fox.Int
	bne	ArmadaShineThink_RecoverStart_NotFox
	li	r3,RestartTimer
	b	ArmadaShineThink_RecoverStart_StoreRestartTimer
ArmadaShineThink_RecoverStart_NotFox:
	li	r3,RestartTimer+60
ArmadaShineThink_RecoverStart_StoreRestartTimer:
	stb r3,Timer(REG_EventData)
#Change Event State
	li	r3,EventState_RecoverEnd
	stb	r3,EventState(REG_EventData)
#Run Next State Code
	b	ArmadaShineThink_RecoverEnd
ArmadaShineThink_RecoverStart_CheckIfDoneSkip:

/*
#Wait until last frame of firefox
	lhz	r3,TM_FramesinCurrentAS(REG_P2Data)
	cmpwi	r3,FirefoxHoldFrames-2
	beq	ArmadaShineThink_RecoverStart_InputAngle
#Input Up
	li	r3,127
	stb	r3,CPU_AnalogY(REG_P2Data)
	b	ArmadaShineThink_RecoverStart_Exit
*/

ArmadaShineThink_RecoverStart_InputAngle:
#Backup f28-f31
	stfs f29,0xB0(sp)
	stfs f30,0xB4(sp)
	stfs f31,0xB8(sp)
	stfs f28,0xBC(sp)
	stfs f27,0xC0(sp)

#Hold towards ledge
#Get Angle Between Fox and Ledge
	addi r3,REG_P2Data,0xB0
	addi r4,REG_P2Data,0x1ADC
	bl	GetAngleBetweenPoints

#Convert this to an input
.set REG_arctan,31
.set REG_XComp,30
.set REG_YComp,31
.set REG_127,29
#Backup arctan
	fmr REG_arctan,f1
#Get 127 as a float
	li	r3,127
	bl	IntToFloat
	fmr REG_127,f1
#Get X Component
	fmr f1,REG_arctan		#angle in radians
	branchl r12,cos
	fmr REG_XComp,f1
#Get Y Component
	fmr f1,REG_arctan		#angle in radians
	branchl r12,sin
	fmr REG_YComp,f1
#Get X input
	fmuls f1,REG_XComp,REG_127
	fctiwz f1,f1,
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	stb r3,0x1A8C(REG_P2Data)
#Get Y input
	fmuls f1,REG_YComp,REG_127
	fctiwz f1,f1,
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	stb r3,0x1A8D(REG_P2Data)

#region ecb test code
.set REG_XPerFrame,29
.set REG_YPerFrame,28
.set REG_CurrXPos,27
.set REG_CurrYPos,26
.set REG_ECBStruct,20
.set REG_ECBBoneStruct,21
.set REG_LoopCount,22
.set FirefoxFrames,30
.set RandomAngleRange,20

#Get Per Frame Velocity
	mr	r3,REG_P2Data
	branchl	r12,0x800a17e4
	fmr	REG_XComp,f1
	mr	r3,REG_P2Data
	branchl	r12,0x800a1874
	fmr	REG_YComp,f1
#Get atan2
	fmr	f1,REG_YComp
	lfs	f2,0x2C(REG_P2Data)
	fmuls	f2,f2,REG_XComp
	branchl	r12,0x80022c30
	fmr	REG_arctan,f1
#Get XComp
	fmr	f1,REG_arctan
	branchl	r12,0x80326240
	fmr	REG_XComp,f1
	fmr	f1,REG_arctan
	branchl	r12,0x803263d4
	fmr	REG_YComp,f1
#Get Firefox distance per frame
	lwz	r3, 0x02D4 (REG_P2Data)
	lfs	f1, 0x0074 (r3)
	lfs	f0, 0x002C (REG_P2Data)
	fmuls	f1,f1,REG_XComp
	fmuls	REG_XPerFrame,f1,f0
	lfs	f1, 0x0074 (r3)
	fmuls	REG_YPerFrame,f1,REG_YComp
#Create an ECB struct on the stack
	subi	sp,sp,0x1d0
	addi	REG_ECBBoneStruct,sp,0xC
	addi	REG_ECBStruct,sp,0x24
	mr	r3,REG_ECBStruct
	branchl	r12,0x80041ee4
#Create ECB Bone struct
/*
0x00 = ECB Current Top Y Offset scale * value
0x04 = ECB Current Bottom Y Offset neg(scale * vlaue)
0x08 = ECB Current Left X Offset neg(scale * vlaue)
0x0C = ECB Current Left Y Offset 0
0x10 = ECB Current Right X Offset scale * value
0x14 = ECB Current Right Y Offset 0
*/
#Copy Struct
	mr	r3,REG_ECBBoneStruct
	addi	r4,REG_EventConstants,ECB_TopY
	li	r5,0x18
	branchl	r12,memcpy
#Place Current XY into struct
	lfs	REG_CurrXPos,0xB0(REG_P2Data)
	lfs	REG_CurrYPos,0xB4(REG_P2Data)
#Subtract 0.4 to account for the frame of animation left in this state
	lfs	f1,FinalAnimYDifference(REG_EventConstants)
	fsubs	REG_CurrYPos,REG_CurrYPos,f1
	lfs	f1,0xB8(REG_P2Data)
	stfs	f1,0x24(REG_ECBStruct)
#Init Loop
	li	REG_LoopCount,0
ArmadaShineThink_RecoverStart_CollisionLoop:
#Store current position
	stfs	REG_CurrXPos,0x1C(REG_ECBStruct)
	stfs	REG_CurrYPos,0x20(REG_ECBStruct)
#Check if frame X or greater
  lwz	r5, 0x02D4 (REG_P2Data)
  lfs f1,0x70(r5)
  fctiwz  f1,f1
  stfd  f1,-0x10(sp)
  lwz r3,-0x0C(sp)
	cmpw	REG_LoopCount,r3
	blt	ArmadaShineThink_RecoverStart_CollisionLoop_SkipDecay
ArmadaShineThink_RecoverStart_CollisionLoop_Decay:
	lfs	f1,0x78(r5)
	fmuls	f1,f1,REG_XComp
	lfs	f2, 0x002C (REG_P2Data)
	fmuls	f1,f1,f2
	fsubs	REG_XPerFrame,REG_XPerFrame,f1
	lfs	f1,0x78(r5)
	fmuls	f1,f1,REG_YComp
	fsubs	REG_YPerFrame,REG_YPerFrame,f1
ArmadaShineThink_RecoverStart_CollisionLoop_SkipDecay:
#Store next position
	fadds	f1,REG_CurrXPos,REG_XPerFrame
	stfs	f1,0x4(REG_ECBStruct)
	fadds	f1,REG_CurrYPos,REG_YPerFrame
	stfs	f1,0x8(REG_ECBStruct)
	lfs	f1,0x24(REG_ECBStruct)
	stfs	f1,0xC(REG_ECBStruct)
	mr	r3,REG_ECBStruct
	mr	r4,REG_ECBBoneStruct
	branchl	r12,0x8004730c
	lfs	REG_CurrXPos,0x4(REG_ECBStruct)
	lfs	REG_CurrYPos,0x8(REG_ECBStruct)
#Inc Loop
	addi	REG_LoopCount,REG_LoopCount,1
  lwz	r5, 0x02D4 (REG_P2Data)
  lfs	f1, 0x0068 (r5)
  fctiwz  f1,f1
  stfd  f1,-0x10(sp)
  lwz r3,-0x0C(sp)
	cmpw	REG_LoopCount,r3
	blt	ArmadaShineThink_RecoverStart_CollisionLoop
#End Loop
	addi	sp,sp,0x1d0
#endregion

#Restore f28-f31
	lfs f29,0xB0(sp)
	lfs f30,0xB4(sp)
	lfs f31,0xB8(sp)
	lfs f28,0xBC(sp)
	lfs f27,0xC0(sp)

ArmadaShineThink_RecoverStart_Exit:
	b	ArmadaShineThink_Exit
#endregion

#region ArmadaShineThink_RecoverEnd
ArmadaShineThink_RecoverEnd:
#If CPU got hit, recover again
	lbz	r3,0x221C(REG_P2Data)
	rlwinm. r3,r3,0,30,30
	beq	ArmadaShineThink_Reset
#Enter Hitstun state
	li	r3,EventState_Hitstun
	stb	r3,EventState(REG_EventData)
	b	ArmadaShineThink_Exit
#endregion

#region ArmadaShineThink_Reset
ArmadaShineThink_Reset:
#Get timer
	lbz r3,Timer(REG_EventData)
	subi r3,r3,1
	stb r3,Timer(REG_EventData)
	cmpwi r3,0
	ble ArmadaShineThink_Restore
	b	ArmadaShineThink_Exit

#endregion

ArmadaShineThink_Restore:
#Restore State
	addi r3,REG_EventData,EventData_SaveStateStruct
	li	r4,1
	bl	SaveState_Load
#Init Positions Again
	mr	r3,REG_P1GObj
	mr	r4,REG_P2GObj
	bl	ArmadaShine_InitializePositions
#Reset Variables
	li	r3,0
	stb r3,EventState(REG_EventData)
	stb r3,Timer(REG_EventData)

ArmadaShineThink_Exit:
	restore
	blr

ArmadaShineThink_Constants:
blrl

.set	ECB_TopY,0x0 #scale * value
.set	ECB_BottomY,0x4 #neg(scale * vlaue)
.set	ECB_LeftX,0x8 #neg(scale * vlaue)
.set	ECB_LeftY,0xC #0
.set	ECB_RightX,0x10 #scale * value
.set	ECB_RightY,0x14 #0
.set	FinalAnimYDifference,0x18
.float 9
.float 2.5
.float -3.3
.float 5.7
.float 3.3
.float 5.7
.float 0.4

ArmadaShine_InitializePositions:
backup

.set LedgeSide,20

#Constants
.set ArmadaShine_P1X,15
.set ArmadaShine_P1Y,6
.set ArmadaShine_P2X,12
.set ArmadaShine_P2Y,6
.set HitlagFrames,12

#Get random side
	li	r3,2
	branchl r12,HSD_Randi
#Backup Ledge Side
	mr	LedgeSide,r3

#Change Facing Directions
  cmpwi LedgeSide,0x0
  beq	ArmadaShine_InitializePositions_GetLeftLedgeID
ArmadaShine_InitializePositions_GetRightLedgeID:
 #Change Facing Direction
	li	r3,-1
	bl	IntToFloat
	stfs	f1,0x2C(REG_P1Data)
  li	r3,-1
  bl	IntToFloat
  stfs	f1,0x2C(REG_P2Data)
	b	ArmadaShine_InitializePositions_DirectionChangeEnd
ArmadaShine_InitializePositions_GetLeftLedgeID:
#Change Facing Direction
	li	r3,1
  bl	IntToFloat
  stfs	f1,0x2C(REG_P1Data)
  li	r3,1
  bl	IntToFloat
  stfs	f1,0x2C(REG_P2Data)
ArmadaShine_InitializePositions_DirectionChangeEnd:

#Get Ledge Coordinates
	mr	r3,LedgeSide
	addi r4,sp,0x80
	bl	GetLedgeCoordinates

#Move P1
	li r3,ArmadaShine_P1X
	bl	IntToFloat
	lfs f2,0x80(sp)
	lfs f3,0x2C(REG_P1Data)
	fmadds f1,f1,f3,f2
	stfs f1,0xB0(REG_P1Data)
	li r3,ArmadaShine_P1Y
	bl	IntToFloat
	lfs f2,0x84(sp)
	fadds f1,f1,f2
	stfs f1,0xB4(REG_P1Data)
	mr	r3,REG_P1GObj
	bl	UpdatePosition
#Move P2
	li r3,ArmadaShine_P2X
	bl	IntToFloat
	lfs f2,0x80(sp)
	lfs f3,0x2C(REG_P2Data)
	fmadds f1,f1,f3,f2
	stfs f1,0xB0(REG_P2Data)
	li r3,ArmadaShine_P2Y
	bl	IntToFloat
	lfs f2,0x84(sp)
	fadds f1,f1,f2
	stfs f1,0xB4(REG_P2Data)
	mr	r3,REG_P2GObj
	bl	UpdatePosition
#P1 enters Bair
	mr	r3,REG_P1GObj
	li	r4,ASID_AttackAirB
	branchl r12,0x8008cfac
#Fastforward to frame 7
	li	r3,7
	bl	IntToFloat
	mr	r3,REG_P1GObj
	lfs	f2, -0x67D8 (rtoc)
	lfs	f3, -0x67E4 (rtoc)
	branchl r12,0x8006ebe8
	li	r3,7
	bl	IntToFloat
	stfs f1,0x894(REG_P1Data)
	li	r3,0
	stw r3,0x3E4(REG_P1Data)
	mr	r3,REG_P1GObj
	branchl r12,0x80073354
#Update Animation
	mr	r3,REG_P1GObj
	branchl r12,0x8006e9b4
#Remove all hitboxes
	mr	r3,REG_P1GObj
	branchl r12,0x8007aff8
#Stop subaction script from being updated
	li	r3,0
	stw r3,0x3EC(REG_P1Data)
#Update Camera
	mr	r3,REG_P1GObj
	bl	UpdateCameraBox

#P2 enters DamageFlyN
	mr	r3,REG_P2GObj
	li	r4,ASID_DamageFlyN
	li	r5,0x40
	li	r6,0
	lfs	f1, -0x750C (rtoc)
	lfs	f2, -0x7508 (rtoc)
	lfs	f3, -0x750C (rtoc)
	branchl r12,ActionStateChange
#Update Animation
	mr	r3,REG_P2GObj
	branchl r12,0x8006e9b4
#Remove Jump
	lwz r3,0x168(REG_P2Data)
	stb r3,0x1968(REG_P2Data)
#Update Camera
	mr	r3,REG_P2GObj
	bl	UpdateCameraBox

.set AngleLo,45
.set AngleHi,60
.set MagLo,106
.set MagHi,120
#Enter into knockback
	mr	r3,REG_P2GObj
	li	r4,AngleLo
	li	r5,AngleHi
	li	r6,MagLo
	li	r7,MagHi
	bl	EnterKnockback

#Give 7 Frames of Hitlag to Each
	li	r3,HitlagFrames
	bl	IntToFloat
	stfs f1,0x195C(REG_P1Data)
	lbz r0,0x221A(REG_P1Data)
	li	r3,1
	rlwimi r0,r3,5,26,26
	stb r0,0x221A(REG_P1Data)
	lbz r0,0x2219(REG_P1Data)
	li	r3,1
	rlwimi r0,r3,2,29,29
	stb r0,0x2219(REG_P1Data)
	li	r3,HitlagFrames
	bl	IntToFloat
	stfs f1,0x195C(REG_P2Data)
	lbz r0,0x221A(REG_P2Data)
	li	r3,1
	rlwimi r0,r3,5,26,26
	stb r0,0x221A(REG_P2Data)
	lbz r0,0x2219(REG_P2Data)
	li	r3,1
	rlwimi r0,r3,2,29,29
	stb r0,0x2219(REG_P2Data)

#Random percent
	li	r3,PercentHi-PercentLo
	branchl r12,HSD_Randi
	addi r4,r3,PercentLo
	lbz r3,0xC(REG_P2Data)
	branchl r12,PlayerBlock_SetDamage

ArmadaShine_InitializePositions_Exit:
	restore
	blr

#endregion

#region SideB Sweetspot
###########################
## SideB Sweetspot HIJACK INFO ##
###########################

SideBSweetspot:
#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)										#Send event struct
	mr	r4,r26												#Send match struct
	li	r5,Marth.Ext
	li	r6,-1													#Use chosen Stage
	load r7,EventOSD_SideBSweetspot
	li	r8,0										#Use Sopo bool
	bl	InitializeMatch

#STORE THINK FUNCTION
SideBSweetspotStoreThink:
	bl	SideBSweetspotLoad
	mflr	r3
	stw	r3,0x44(r26)		#on match load

b	exit

##################################
## 			SideB Sweetspot LOAD FUNCT 		##
##################################
SideBSweetspotLoad:
	blrl

	backup

#Schedule Think
	bl	SideBSweetspotThink
	mflr	r3
	li	r4,3		#Priority (After EnvCOllision)
  li  r5,0
	bl	CreateEventThinkFunction
	b	SideBSweetspotThink_Exit

###################################
## SideB Sweetspot THINK FUNCT ##
###################################

SideBSweetspotThink:
	blrl

#Registers
	.set REG_EventConstants,25
  .set REG_MenuData,26
  .set REG_EventData,31
  .set REG_P1Data,27
  .set REG_P1GObj,28
	.set REG_P2Data,29
	.set REG_P2GObj,30

#Event Data Offsets
	.set EventState,0x0
		.set EventState_Endlag,0x0
		.set EventState_WaitToAttack,0x1
		.set EventState_AttackThink,0x2
		.set EventState_Reset,0x3
	.set Timer,0x1
	.set ThrowTimer,0x2
	.set JabFrame,0x4

#Constants
	.set ResetTimer,30
	.set AngleLo,45
	.set AngleHi,60
	.set MagLo,106#106
	.set MagHi,135#120
	.set PercentHi,100
	.set PercentLo,50


backup

#INIT FUNCTION VARIABLES
	lwz	REG_EventData,0x2c(r3)			#backup data pointer in r31

#Get Player Pointers
  bl GetAllPlayerPointers
  mr REG_P1GObj,r3
  mr REG_P1Data,r4
  mr REG_P2GObj,r5
  mr REG_P2Data,r6

#Get Menu and Constants Pointers
  lwz REG_MenuData,REG_EventData_REG_MenuDataPointer(REG_EventData)
	bl	SideBSweetspotThink_Constants
	mflr REG_EventConstants

	bl	StoreCPUTypeAndZeroInputs

#ON FIRST FRAME
	bl	CheckIfFirstFrame
	cmpwi	r3,0x0
	beq	SideBSweetspotThink_Start
	#Init Positions
		mr	r3,REG_P1GObj
		mr	r4,REG_P2GObj
		mr	r5,REG_EventData
		bl	SideBSweetspot_InitializePositions
  #Clear Inputs
    bl  RemoveFirstFrameInputs
	#Save State
  	addi r3,REG_EventData,EventData_SaveStateStruct
		li	r4,1			#Override failsafe code
  	bl	SaveState_Save
SideBSweetspotThink_Start:

#P2 intangible
	mr	r3,P2GObj
	li	r4,1
	branchl r12,ApplyIntangibility

#Reset if anyone died
	bl	IsAnyoneDead
	cmpwi r3,0
	bne SideBSweetspotThink_Restore

SideBSweetspotThink_Crouch:
#Always hold crouch when state is higher than EventState_Endlag
	lbz r3,EventState(REG_EventData)
	cmpwi r3,EventState_Endlag
	ble SideBSweetspotThink_CrouchSkip
#Input crouch
	li	r3,-127
	stb r3,CPU_AnalogY(REG_P2Data)
SideBSweetspotThink_CrouchSkip:

SideBSweetspotThink_SwitchCase:
#Switch Case
	lbz r3,EventState(REG_EventData)
	cmpwi r3,EventState_Endlag
	beq SideBSweetspotThink_Endlag
	cmpwi r3,EventState_WaitToAttack
	beq SideBSweetspotThink_WaitToAttack
	cmpwi r3,EventState_AttackThink
	beq SideBSweetspotThink_AttackThink
	cmpwi r3,EventState_Reset
	beq SideBSweetspotThink_Reset
	b	SideBSweetspotThink_CheckTimer

#region SideBSweetspotThink_Endlag
SideBSweetspotThink_Endlag:
#Check if in Wait
	lwz r3,0x10(P2Data)
	cmpwi r3,ASID_Wait
	bne SideBSweetspotThink_CheckTimer
#Input Crouch
	li	r3,-127
	stb r3,CPU_AnalogY(REG_P2Data)
#Change state to attack
	li	r3,EventState_WaitToAttack
	stb	r3,EventState(EventData)
	b	SideBSweetspotThink_CheckTimer

#endregion

#region SideBSweetspotThink_WaitToAttack
SideBSweetspotThink_WaitToAttack:
#Wait for Fox to be in SpecialAirS
	lwz r3,0x10(REG_P1Data)
	cmpwi r3,0x15F
	bne SideBSweetspotThink_WaitToAttackSkip
#Input Dtilt
	li	r3,PAD_BUTTON_A
	stw r3,CPU_HeldButtons(REG_P2Data)
	li	r3,-38
	stb r3,CPU_AnalogY(REG_P2Data)
#Advance State
	li	r3,EventState_AttackThink
	stb r3,EventState(REG_EventData)
	b	SideBSweetspotThink_CheckTimer
SideBSweetspotThink_WaitToAttackSkip:

#Check if fox up-b'd
	cmpwi r3,0x162
	beq SideBSweetspotThink_WaitToAttack_BlacklistMove
	cmpwi r3,ASID_EscapeAir
	beq SideBSweetspotThink_WaitToAttack_BlacklistMove
	b	SideBSweetspotThink_WaitToAttack_CheckForBlacklistMovesSkip
SideBSweetspotThink_WaitToAttack_BlacklistMove:
#PLay Error SFX
  li	r3,0xAF
  bl  PlaySFX
#Start Timer
	li	r3,ResetTimer
	stb r3,Timer(REG_EventData)
#Advance State
	li	r3,EventState_Reset
	stb r3,EventState(REG_EventData)
	b	SideBSweetspotThink_CheckTimer
SideBSweetspotThink_WaitToAttack_CheckForBlacklistMovesSkip:
#endregion

#region SideBSweetspotThink_AttackThink
SideBSweetspotThink_AttackThink:
#Check if d-tilting
	lwz r3,0x10(REG_P2Data)
	cmpwi r3,ASID_AttackLw3
	bne SideBSweetspotThink_CheckTimer
#Check if frame 7
	li	r3,7
	bl	IntToFloat
	lfs f2,0x894(REG_P2Data)
	fcmpo cr0,f1,f2
	bne SideBSweetspotThink_AttackThink_FreezeSkip
#Check if already frozen
	li	r3,0
	bl	IntToFloat
	lfs f2,0x89C(REG_P2Data)
	fcmpo cr0,f1,f2
	beq SideBSweetspotThink_AttackThink_FreezeCheckToUnfreeze
#Freeze
	mr	r3,REG_P2GObj
	branchl r12,FrameSpeedChange
	b	SideBSweetspotThink_AttackThink_FreezeSkip
SideBSweetspotThink_AttackThink_FreezeCheckToUnfreeze:
#Check if player was hit
	lwz r3,0x2094(REG_P2Data)
	cmpwi r3,0
	beq SideBSweetspotThink_AttackThink_FreezeSkip
#Unfreeze
	li	r3,1
	bl	IntToFloat
	mr	r3,REG_P2GObj
	branchl r12,FrameSpeedChange
#Start Timer
	li	r3,ResetTimer
	stb r3,Timer(REG_EventData)
#Advance State
	li	r3,EventState_Reset
	stb r3,EventState(REG_EventData)
	b	SideBSweetspotThink_CheckTimer
SideBSweetspotThink_AttackThink_FreezeSkip:

#Check if P1 grabbed ledge successfully
	lwz r3,0x10(REG_P1Data)
	cmpwi r3,ASID_CliffCatch
	bne SideBSweetspotThink_AttackThink_CliffCatchSkip
#Play Success SFX
	li	r3,0xAD
	bl	PlaySFX
#Unfreeze P2
	li	r3,1
	bl	IntToFloat
	mr	r3,REG_P2GObj
	branchl r12,FrameSpeedChange
#Start Timer
	li	r3,ResetTimer+30
	stb r3,Timer(REG_EventData)
#Advance State
	li	r3,EventState_Reset
	stb r3,EventState(REG_EventData)
	b	SideBSweetspotThink_CheckTimer
SideBSweetspotThink_AttackThink_CliffCatchSkip:

#endregion

#region SideBSweetspotThink_Reset
SideBSweetspotThink_Reset:
	b	SideBSweetspotThink_CheckTimer
#endregion

SideBSweetspotThink_CheckTimer:
#Check if timer exists
	lbz r3,Timer(REG_EventData)
	cmpwi r3,0
	ble SideBSweetspotThink_Exit
#Decrement timer
	subi r3,r3,1
	stb r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt SideBSweetspotThink_Exit

SideBSweetspotThink_Restore:
#Restore State
	addi r3,REG_EventData,EventData_SaveStateStruct
	li	r4,1
	bl	SaveState_Load
#Init Positions Again
	mr	r3,REG_P1GObj
	mr	r4,REG_P2GObj
	mr	r5,REG_EventData
	bl	SideBSweetspot_InitializePositions

SideBSweetspotThink_Exit:
	restore
	blr

################################

SideBSweetspotThink_Constants:
blrl
.set P1X,0x0
.set P1Y,0x4
.set P2X,0x8
.set P2Y,0xC
.set GrabDistance,0x10
.set HoldShieldVelocity,0x14
.set RunDistance,0x18

.float -8		#p1 x
.float  0		#p1 y
.float  8		#p2 x
.float  0		#p2 y
.float 14		#16
.float 1.1
.float 23
###########################################

SideBSweetspot_InitializePositions:
backup

.set REG_P1GObj,30
.set REG_P1Data,29
.set REG_P2GObj,28
.set REG_P2Data,27
.set REG_EventData,26
.set LedgeSide,20

#Constants
.set SideBSweet_P1X,-12
.set SideBSweet_P1Y,6
.set SideBSweet_P2X,15
.set SideBSweet_P2Y,0
.set HitlagFrames,12

#Init Registers
  mr	REG_P1GObj,r3
  lwz REG_P1Data,0x2C(REG_P1GObj)
  mr	REG_P2GObj,r4
  lwz REG_P2Data,0x2C(REG_P2GObj)
	mr	REG_EventData,r5

#Get random side
	li	r3,2
	branchl r12,HSD_Randi
#Backup Ledge Side
	mr	LedgeSide,r3

#Change Facing Directions
  cmpwi LedgeSide,0x0
  beq	SideBSweet_InitializePositions_GetLeftLedgeID
SideBSweet_InitializePositions_GetRightLedgeID:
 #Change Facing Direction
	li	r3,-1
	bl	IntToFloat
	stfs	f1,0x2C(REG_P1Data)
  li	r3,1
  bl	IntToFloat
  stfs	f1,0x2C(REG_P2Data)
	b	SideBSweet_InitializePositions_DirectionChangeEnd
SideBSweet_InitializePositions_GetLeftLedgeID:
#Change Facing Direction
	li	r3,1
  bl	IntToFloat
  stfs	f1,0x2C(REG_P1Data)
  li	r3,-1
  bl	IntToFloat
  stfs	f1,0x2C(REG_P2Data)
SideBSweet_InitializePositions_DirectionChangeEnd:

#Get Ledge Coordinates
	mr	r3,LedgeSide
	addi r4,sp,0x80
	bl	GetLedgeCoordinates

#Move P1
	li r3,SideBSweet_P1X
	bl	IntToFloat
	lfs f2,0x80(sp)
	lfs f3,0x2C(REG_P1Data)
	fmadds f1,f1,f3,f2
	stfs f1,0xB0(REG_P1Data)
	li r3,SideBSweet_P1Y
	bl	IntToFloat
	lfs f2,0x84(sp)
	fadds f1,f1,f2
	stfs f1,0xB4(REG_P1Data)
	mr	r3,REG_P1GObj
	bl	UpdatePosition
#Move P2
	li r3,SideBSweet_P2X
	bl	IntToFloat
	lfs f2,0x80(sp)
	lfs f3,0x2C(REG_P2Data)
	fneg f3,f3
	fmadds f1,f1,f3,f2
	stfs f1,0xB0(REG_P2Data)
	li r3,SideBSweet_P2Y
	bl	IntToFloat
	lfs f2,0x84(sp)
	fadds f1,f1,f2
	stfs f1,0xB4(REG_P2Data)
	mr	r3,REG_P2GObj
	bl	PlacePlayerOnGround
#Clear P2's GFX Pointer
	li	r3,0
	stw r3,0x60C(REG_P2Data)
#P2 enters FSmash
	li	r3,0
	bl	IntToFloat
	mr	r3,REG_P2GObj
	branchl r12,0x8008c3e0
#Fastforward to frame 11
	li	r3,11
	bl	IntToFloat
	mr	r3,REG_P2GObj
	lfs	f2, -0x67D8 (rtoc)
	lfs	f3, -0x67E4 (rtoc)
	branchl r12,0x8006ebe8
	li	r3,7
	bl	IntToFloat
	stfs f1,0x894(REG_P2Data)
	li	r3,0
	stw r3,0x3E4(REG_P2Data)
	mr	r3,REG_P2GObj
	branchl r12,0x80073354
#Update Animation
	mr	r3,REG_P2GObj
	branchl r12,0x8006e9b4
#Remove all hitboxes
	mr	r3,REG_P2GObj
	branchl r12,0x8007aff8
#Stop subaction script from being updated
	li	r3,0
	stw r3,0x3EC(REG_P2Data)
#Update Camera
	mr	r3,REG_P2GObj
	bl	UpdateCameraBox

#P1 enters DamageFlyN
	mr	r3,REG_P1GObj
	li	r4,ASID_DamageFlyN
	li	r5,0x40
	li	r6,0
	lfs	f1, -0x750C (rtoc)
	lfs	f2, -0x7508 (rtoc)
	lfs	f3, -0x750C (rtoc)
	branchl r12,ActionStateChange
#Update Animation
	mr	r3,REG_P1GObj
	branchl r12,0x8006e9b4
#Remove Jump
	#lwz r3,0x168(REG_P1Data)
	#stb r3,0x1968(REG_P1Data)
#Update Camera
	mr	r3,REG_P1GObj
	bl	UpdateCameraBox

#Enter into knockback
	mr	r3,REG_P1GObj
	li	r4,AngleLo
	li	r5,AngleHi
	li	r6,MagLo
	li	r7,MagHi
	bl	EnterKnockback

#Give 7 Frames of Hitlag to Each
	li	r3,HitlagFrames
	bl	IntToFloat
	stfs f1,0x195C(REG_P1Data)
	lbz r0,0x221A(REG_P1Data)
	li	r3,1
	rlwimi r0,r3,5,26,26
	stb r0,0x221A(REG_P1Data)
	lbz r0,0x2219(REG_P1Data)
	li	r3,1
	rlwimi r0,r3,2,29,29
	stb r0,0x2219(REG_P1Data)
	li	r3,HitlagFrames
	bl	IntToFloat
	stfs f1,0x195C(REG_P2Data)
	lbz r0,0x221A(REG_P2Data)
	li	r3,1
	rlwimi r0,r3,5,26,26
	stb r0,0x221A(REG_P2Data)
	lbz r0,0x2219(REG_P2Data)
	li	r3,1
	rlwimi r0,r3,2,29,29
	stb r0,0x2219(REG_P2Data)

#Random percent
	li	r3,PercentHi-PercentLo
	branchl r12,HSD_Randi
	addi r4,r3,PercentLo
	lbz r3,0xC(REG_P1Data)
	branchl r12,PlayerBlock_SetDamage

#Reset Variables
	li	r3,EventState_ThrowDelay
	stb r3,EventState(REG_EventData)
	li	r3,0
	stb r3,Timer(REG_EventData)
SideBSweetspot_InitializePositions_Exit:
	restore
	blr

#endregion

#region Escape Sheik
###########################
## Escape Sheik HIJACK INFO ##
###########################

EscapeSheik:
#Store Stage, CPU, and FDD Toggles
	lwz r3,0x0(r29)										#Send event struct
	mr	r4,r26												#Send match struct
	li	r5,Sheik.Ext
	li	r6,FinalDestination						#Use chosen Stage
	load r7,EventOSD_EscapeSheik
	li	r8,1										#Use Sopo bool
	bl	InitializeMatch

#STORE THINK FUNCTION
EscapeSheikStoreThink:
	bl	EscapeSheikLoad
	mflr	r3
	stw	r3,0x44(r26)		#on match load

b	exit

##################################
## 			Escape Sheik LOAD FUNCT 		##
##################################
EscapeSheikLoad:
	blrl

	backup

#Schedule Think
	bl	EscapeSheikThink
	mflr	r3
	li	r4,3		#Priority (After EnvCOllision)
  li  r5,0
	bl	CreateEventThinkFunction
	b	EscapeSheikThink_Exit

###################################
## Escape Sheik THINK FUNCT ##
###################################

EscapeSheikThink:
	blrl

#Registers
	.set REG_EventConstants,25
  .set REG_MenuData,26
  .set REG_EventData,31
  .set REG_P1Data,27
  .set REG_P1GObj,28
	.set REG_P2Data,29
	.set REG_P2GObj,30

#Event Data Offsets
	.set EventState,0x0
		.set EventState_ThrowDelay,0x0
		.set EventState_ThrowEndlag,0x1
		.set EventState_Chase,0x2
		.set EventState_Jab2,0x3
		.set EventState_Reset,0x4
	.set	Timer,0x1
	.set	ThrowTimer,0x2
	.set	JabFrame,0x4
	.set	isJabTwice,0x5
	.set	Jab2Frame,0x6
	.set	Jab2Timer,0x7
	.set	isDisplayedTiming,0x8

#Constants
	.set ResetTimer,40
	.set PercentLo,0
	.set PercentHi,40
	.set ThrowTimerLo,30
	.set ThrowTimerHi,60
	.set ReactFrame,12
	.set JabFrameLo,15
	.set JabFrameHi,20
	.set Jab2FrameLo,6
	.set Jab2FrameHi,18

backup

#INIT FUNCTION VARIABLES
	lwz	REG_EventData,0x2c(r3)			#backup data pointer in r31

#Get Player Pointers
  bl GetAllPlayerPointers
  mr REG_P1GObj,r3
  mr REG_P1Data,r4
  mr REG_P2GObj,r5
  mr REG_P2Data,r6

#Get Menu and Constants Pointers
  lwz REG_MenuData,REG_EventData_REG_MenuDataPointer(REG_EventData)
	bl	EscapeSheikThink_Constants
	mflr REG_EventConstants

	bl	StoreCPUTypeAndZeroInputs

#ON FIRST FRAME
	bl	CheckIfFirstFrame
	cmpwi	r3,0x0
	beq	EscapeSheikThink_Start
	#Init Positions
		mr	r3,REG_P1GObj
		mr	r4,REG_P2GObj
		mr	r5,REG_EventData
		bl	EscapeSheik_InitializePositions
  #Clear Inputs
    bl  RemoveFirstFrameInputs
	#Save State
  	addi r3,REG_EventData,EventData_SaveStateStruct
		li	r4,1			#Override failsafe code
  	bl	SaveState_Save
EscapeSheikThink_Start:

#Reset if anyone died
	bl	IsAnyoneDead
	cmpwi r3,0
	bne EscapeSheikThink_Restore

EscapeSheikThink_CheckIfFailed:
#Check if failed the Escape Sheik (grabbed))
#EventState > EventState_Hitstun
	lbz r3,EventState(REG_EventData)
	cmpwi r3,EventState_Chase
	blt EscapeSheikThink_CheckIfFailed_End
#Check if grabbed
	lwz r3,0x10(P1Data)
	cmpwi r3,ASID_CapturePulledHi
	blt EscapeSheikThink_CheckIfFailed_End
	cmpwi r3,ASID_CaptureFoot
	bgt EscapeSheikThink_CheckIfFailed_End
#Check if timer has started
	lbz r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt EscapeSheikThink_CheckIfFailed_End
#Start Timer
	li	r3,ResetTimer
	stb r3,Timer(REG_EventData)
EscapeSheikThink_CheckIfFailed_End:

EscapeSheikThink_CheckIfCPUDamaged:
	lwz	r3,0x10(REG_P2Data)
	cmpwi r3,ASID_DamageHi1
	blt	EscapeSheikThink_CheckIfCPUDamaged_End
	cmpwi r3,ASID_DamageFlyRoll
	bgt	EscapeSheikThink_CheckIfCPUDamaged_End
#Check if timer has started
	lbz r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt EscapeSheikThink_CheckIfCPUDamaged_End
#Start Timer
	li	r3,ResetTimer
	stb r3,Timer(REG_EventData)
#Play Success Sound?
#Maybe increment a high score or something idk
EscapeSheikThink_CheckIfCPUDamaged_End:

EscapeSheikThink_CheckForMistimedShine:
#Check if event state is in chase
	lbz	r3,EventState(REG_EventData)
	cmpwi	r3,EventState_Chase
	blt	EscapeSheikThink_CheckForMistimedShine_End
#Check if displayed already
	lbz	r3,isDisplayedTiming(REG_EventData)
	cmpwi	r3,0
	bne	EscapeSheikThink_CheckForMistimedShine_End
#Get this frames inputs
  lbz	r4, 0x0618 (REG_P1Data)
  bl	GetInputStruct
	mr	r5,r3
#Check B Button
	lwz	r3,InputStruct_InstantButtons(r5)
	rlwinm.	r0,r3,0,22,22
	beq	EscapeSheikThink_CheckForMistimedShine_End
#Check if pushing down
	lbz	r3,InputStruct_LeftAnalogY(r5)
	extsb	r3,r3
	cmpwi	r3,-44
	bgt	EscapeSheikThink_CheckForMistimedShine_End
#Check if in any missed tech state
	lwz	r3,0x10(REG_P1Data)
	cmpwi	r3,ASID_Passive
	beq	EscapeSheikThink_CheckForMistimedShine_Early
	cmpwi	r3,ASID_PassiveStandB
	beq	EscapeSheikThink_CheckForMistimedShine_Early
	cmpwi	r3,ASID_PassiveStandF
	beq	EscapeSheikThink_CheckForMistimedShine_Early
#Check if being grabbed
	cmpwi	r3,ASID_CapturePulledLw
	beq	EscapeSheikThink_CheckForMistimedShine_Late
	cmpwi	r3,ASID_CapturePulledHi
	beq	EscapeSheikThink_CheckForMistimedShine_Late
	cmpwi	r3,ASID_CaptureWaitLw
	beq	EscapeSheikThink_CheckForMistimedShine_Late
	cmpwi	r3,ASID_CaptureWaitHi
	beq	EscapeSheikThink_CheckForMistimedShine_Late
	b	EscapeSheikThink_CheckForMistimedShine_End
.set	REG_String,20
.set	REG_Frames,21
EscapeSheikThink_CheckForMistimedShine_Early:
#Get early string
	bl	EscapeSheikThink_EarlyText
	mflr	REG_String
#Get frames early
	mr	r3,REG_P1Data
	lwz	r4,0x14(REG_P1Data)
	branchl	r12,0x80085e50
	lfs	f1,0x8(r3)
	fctiwz	f1,f1
	stfd	f1,0x80(sp)
	lwz	r3,0x84(sp)
	lhz	r4,TM_FramesinCurrentAS(REG_P1Data)
	sub	REG_Frames,r3,r4
	b	EscapeSheikThink_CheckForMistimedShine_Display
EscapeSheikThink_CheckForMistimedShine_Late:
#Get late string
	bl	EscapeSheikThink_LateText
	mflr	REG_String
#Get frames late
EscapeSheikThink_CheckForMistimedShine_LateSearchInitLoop:
.set	REG_Count,22
	li	REG_Count,0
	lhz	REG_Frames,TM_FramesinCurrentAS(REG_P1Data)
EscapeSheikThink_CheckForMistimedShine_LateSearchLoop:
#Get previous action state
	addi	r3,REG_P1Data,TM_PrevASStart
	mulli	r4,REG_Count,0x2
	add	r5,r3,r4
#Check if wait
	lhz	r3,0x0(r5)
	cmpwi	r3,ASID_Wait
	beq	EscapeSheikThink_CheckForMistimedShine_LateSearchFoundWait
#Add frames spent in this state
	lhz	r3,0xC(r5)
	add	REG_Frames,REG_Frames,r3
EscapeSheikThink_CheckForMistimedShine_LateSearchIncLoop:
	addi	REG_Count,REG_Count,1
	cmpwi	REG_Count,6
	blt	EscapeSheikThink_CheckForMistimedShine_LateSearchLoop
	b	EscapeSheikThink_CheckForMistimedShine_End

EscapeSheikThink_CheckForMistimedShine_LateSearchFoundWait:

EscapeSheikThink_CheckForMistimedShine_Display:
#Output reaction time
	mr	r3,REG_P1Data		#p1 (no offsetting window)
	li	r4,120					#text timeout
	li	r5,0						#Area to Display (0-2)
	li	r6,OSD.Miscellaneous			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function
	mr	r22,r3			#backup text pointer

#Create Text 1
	mr 	r3,r22			#text pointer
	bl	EscapeSheikThink_TopText
	mflr	r4
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B4 (rtoc)			#default text X/Y
	branchl r12,Text_InitializeSubtext
#Create Text 2
	mr 	r3,r22			#text pointer
	bl	EscapeSheikThink_BottomText
	mflr	r4
	mr	r5,REG_Frames
	mr	r6,REG_String
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#default text X/Y
	branchl r12,Text_InitializeSubtext
#Set as displayed
	li	r3,1
	stb	r3,isDisplayedTiming(REG_EventData)
EscapeSheikThink_CheckForMistimedShine_End:

EscapeSheikThink_SwitchCase:
#Switch Case
	lbz r3,EventState(REG_EventData)
	cmpwi r3,EventState_ThrowDelay
	beq EscapeSheikThink_ThrowDelay
	cmpwi r3,EventState_ThrowEndlag
	beq EscapeSheikThink_ThrowEndlag
	cmpwi r3,EventState_Chase
	beq EscapeSheikThink_Chase
	cmpwi r3,EventState_Reset
	beq EscapeSheikThink_Reset
	cmpwi	r3,EventState_Jab2
	beq	EscapeSheikThink_Jab2
	b	EscapeSheikThink_CheckTimer

#region EscapeSheikThink_ThrowDelay
EscapeSheikThink_ThrowDelay:
#Check to throw
	lhz r3,ThrowTimer(REG_EventData)
	subi r3,r3,1
	sth r3,ThrowTimer(REG_EventData)
	cmpwi r3,0
	bgt EscapeSheikThink_CheckTimer
#Input DThrow
	li	r3,-127
	stb r3,CPU_AnalogY(REG_P2Data)
#Change state to attack
	li	r3,EventState_ThrowEndlag
	stb	r3,EventState(EventData)
	b	EscapeSheikThink_CheckTimer

#endregion

#region EscapeSheikThink_ThrowEndlag
EscapeSheikThink_ThrowEndlag:
#Wait for Sheik to be out of ThrowLw
	lwz r3,0x10(REG_P2Data)
	cmpwi r3,ASID_Wait
	bne EscapeSheikThink_CheckTimer
#Wait for P1 to be in their tech option
	lwz r3,0x10(REG_P1Data)
	cmpwi r3,ASID_Passive
	blt EscapeSheikThink_ThrowEndlag_CheckMissTech
	cmpwi r3,ASID_PassiveStandB
	ble EscapeSheikThink_ThrowEndlag_End
EscapeSheikThink_ThrowEndlag_CheckMissTech:
	cmpwi r3,ASID_DownBoundD
	beq EscapeSheikThink_ThrowEndlag_End
	cmpwi r3,ASID_DownBoundU
	beq EscapeSheikThink_ThrowEndlag_End
	b	EscapeSheikThink_CheckTimer
EscapeSheikThink_ThrowEndlag_End:
#Advance State
	li	r3,EventState_Chase
	stb r3,EventState(REG_EventData)
	b	EscapeSheikThink_Chase

#endregion

#region EscapeSheikThink_Chase
EscapeSheikThink_Chase:
.set Distance,0xB0
.set REG_Direction,20
#Get Distance
	lfs f1,0xB0(REG_P2Data)
	lfs f2,0xB0(REG_P1Data)
	fsubs f1,f2,f1
	lfs f2,0x2C(REG_P2Data)
	fmuls f1,f1,f2
	stfs f1,Distance(sp)
#Get Direction
	li	r3,0
	bl	IntToFloat
	lfs f2,Distance(sp)
	fcmpo cr0,f2,f1
	blt 0xC
	li	REG_Direction,1
	b	0x8
	li	REG_Direction,-1

#Determine Tech Option
	lwz r3,0x10(REG_P1Data)
	cmpwi r3,ASID_DownBoundD
	beq EscapeSheikThink_Chase_DownBoundThink
	cmpwi r3,ASID_DownBoundU
	beq EscapeSheikThink_Chase_DownBoundThink
#Now only run these when over frame 12
	lhz r4,TM_FramesinCurrentAS(REG_P1Data)
	cmpwi r4,ReactFrame
	blt EscapeSheikThink_CheckTimer
	cmpwi r3,ASID_Passive
	beq EscapeSheikThink_Chase_PassiveThink
	cmpwi r3,ASID_PassiveStandB
	beq EscapeSheikThink_Chase_PassiveStandThink
	cmpwi r3,ASID_PassiveStandF
	beq EscapeSheikThink_Chase_PassiveStandThink
	b	EscapeSheikThink_CheckTimer

EscapeSheikThink_Chase_PassiveThink:
#Check if facing P1
	cmpwi REG_Direction,0
	bgt EscapeSheikThink_Chase_PassiveThink_FacingSkip
#Input slightly towards
	lfs f1,0x2C(REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	mullw r3,r3,REG_Direction
	mulli r3,r3,100
	stb r3,CPU_AnalogX(REG_P2Data)
EscapeSheikThink_Chase_PassiveThink_FacingSkip:
#Check distance (if over 16 units, walk towards)
	lfs f1,GrabDistance(REG_EventConstants)
	lfs f2,Distance(sp)
	fabs f2,f2
	fcmpo cr0,f2,f1
	ble EscapeSheikThink_Chase_PassiveThink_RunTowardsSkip
#If over 24 units, run towards
	lfs f1,RunDistance(REG_EventConstants)
	fcmpo cr0,f2,f1
	bgt	EscapeSheikThink_Chase_PassiveThink_RunTowards
EscapeSheikThink_Chase_PassiveThink_WalkTowards:
#Walk Towards
	lfs f1,0x2C(REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	mullw r3,r3,REG_Direction
	mulli r3,r3,100
	stb r3,CPU_AnalogX(REG_P2Data)
	b	EscapeSheikThink_Chase_PassiveThink_RunTowardsSkip
EscapeSheikThink_Chase_PassiveThink_RunTowards:
#Run Towards
	lfs f1,0x2C(REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	mullw r3,r3,REG_Direction
	mulli r3,r3,127
	stb r3,CPU_AnalogX(REG_P2Data)
EscapeSheikThink_Chase_PassiveThink_RunTowardsSkip:
#Check distance
	lfs f1,GrabDistance(REG_EventConstants)
	lfs f2,Distance(sp)
	fabs f2,f2
	fcmpo cr0,f2,f1
	bgt EscapeSheikThink_Chase_PassiveThink_HoldShieldSkip
#Check State
	lwz r3,0x10(REG_P2Data)
	cmpwi r3,ASID_Dash
	beq EscapeSheikThink_Chase_PassiveThink_HoldShield
	cmpwi r3,ASID_Run
	beq EscapeSheikThink_Chase_PassiveThink_HoldShield
	b	EscapeSheikThink_Chase_PassiveThink_HoldShieldSkip
EscapeSheikThink_Chase_PassiveThink_HoldShield:
#Enter shield
	mr	r3,REG_P2GObj
	branchl r12,AS_Guard
#And hold
	li	r3,PAD_TRIGGER_R
	stw r3,CPU_HeldButtons(REG_P2Data)
	b	EscapeSheikThink_Chase_PassiveThink_HoldShieldSkip
EscapeSheikThink_Chase_PassiveThink_HoldShieldSkip:
#Now grab when P1 is on frame 20
	lhz r3,TM_FramesinCurrentAS(REG_P1Data)
	cmpwi r3,20
	blt EscapeSheikThink_CheckTimer
#Enter grab
	mr	r3,REG_P2GObj
	li	r4,0xD4
	branchl r12,AS_Catch
#Advance state
	li	r3,EventState_Reset
	stb r3,EventState(REG_EventData)
#Start timer
	li	r3,ResetTimer
	stb r3,Timer(REG_EventData)
	b	EscapeSheikThink_CheckTimer

EscapeSheikThink_Chase_PassiveStandThink:
#Check if facing P1
	cmpwi REG_Direction,0
	bgt EscapeSheikThink_Chase_PassiveStandThink_FacingSkip
#BUT is he coming to me?
	lfs f2,0xC8(REG_P1Data)
	li	r3,0
	bl	IntToFloat
	li	r3,1		#Moving Right
	fcmpo cr0,f2,f1
	bgt 0x8
	li	r3,-1		#Moving Left
	lfs f1,0x2C(REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r4,0x84(sp)
	mullw r4,r4,REG_Direction
	cmpw r3,r4
	bne  EscapeSheikThink_Chase_PassiveStandThink_FacingSkip
#If under frame 20, run instead
	li	r5,127
	lhz r3,TM_FramesinCurrentAS(REG_P1Data)
	cmpwi r3,20
	blt 0x8
	li	r5,100
#Input slightly towards
	lfs f1,0x2C(REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	mullw r3,r3,REG_Direction
	mullw r3,r3,r5
	stb r3,CPU_AnalogX(REG_P2Data)
EscapeSheikThink_Chase_PassiveStandThink_FacingSkip:
#Check distance (if over 16 units, run towards)
	lfs f1,GrabDistance(REG_EventConstants)
	lfs f2,Distance(sp)
	fabs f2,f2
	fcmpo cr0,f2,f1
	ble EscapeSheikThink_Chase_PassiveStandThink_RunTowardsSkip
#Wait until no longer turning
	lwz r3,0x10(REG_P2Data)
	cmpwi r3,ASID_Turn
	bne  EscapeSheikThink_Chase_PassiveStandThink_RunTowardCheckMovementDirection
#If turning, wait til frame 2 to make a decision
	lhz r3,TM_FramesinCurrentAS(REG_P2Data)
	cmpwi r3,2
	bge EscapeSheikThink_Chase_PassiveStandThink_RunTowardsSkip
EscapeSheikThink_Chase_PassiveStandThink_RunTowardCheckMovementDirection:
#BUT is he coming to me?
	lfs f2,0xC8(REG_P1Data)
	li	r3,0
	bl	IntToFloat
	li	r3,1		#Moving Right
	fcmpo cr0,f2,f1
	bgt 0x8
	li	r3,-1		#Moving Left
	lfs f1,0x2C(REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r4,0x84(sp)
	mullw r4,r4,REG_Direction
	cmpw r3,r4
	bne  EscapeSheikThink_Chase_PassiveStandThink_RunTowardsSkip
EscapeSheikThink_Chase_PassiveStandThink_RunTowards:
#Run Towards
	lfs f1,0x2C(REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	mullw r3,r3,REG_Direction
	mulli r3,r3,127
	stb r3,CPU_AnalogX(REG_P2Data)
EscapeSheikThink_Chase_PassiveStandThink_RunTowardsSkip:
#If and within range and running, hold shield
#Check distance
	lfs f1,GrabDistance(REG_EventConstants)
	lfs f2,Distance(sp)
	fabs f2,f2
	fcmpo cr0,f2,f1
	bgt EscapeSheikThink_Chase_PassiveStandThink_HoldShieldSkip
	lwz r3,0x10(REG_P2Data)
	cmpwi r3,ASID_Dash
	beq EscapeSheikThink_Chase_PassiveStandThink_HoldShieldCheckFrame
	cmpwi r3,ASID_Run
	beq EscapeSheikThink_Chase_PassiveStandThink_HoldShieldCheckFrame
	b	EscapeSheikThink_Chase_PassiveStandThink_HoldShieldSkip
EscapeSheikThink_Chase_PassiveStandThink_HoldShieldCheckFrame:
	lhz r3,TM_FramesinCurrentAS(REG_P1Data)
	cmpwi r3,28
	bge EscapeSheikThink_Chase_PassiveStandThink_HoldShield
EscapeSheikThink_Chase_PassiveStandThink_HoldShieldCheckVelocity:
#Allow to hold shield earlier than usual if the character isnt moving very far
	lfs f1,0xC8(REG_P1Data)
	fabs f1,f1,
	lfs f2,HoldShieldVelocity(REG_EventConstants)
	fcmpo cr0,f1,f2
	bgt EscapeSheikThink_Chase_PassiveStandThink_HoldShieldRunInstead
EscapeSheikThink_Chase_PassiveStandThink_HoldShield:
#Enter shield
	mr	r3,REG_P2GObj
	branchl r12,AS_Guard
#And hold
	li	r3,PAD_TRIGGER_R
	stw r3,CPU_HeldButtons(REG_P2Data)
	b	EscapeSheikThink_Chase_PassiveStandThink_HoldShieldSkip
EscapeSheikThink_Chase_PassiveStandThink_HoldShieldRunInstead:
#Run Towards
	lfs f1,0x2C(REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	mullw r3,r3,REG_Direction
	mulli r3,r3,127
	stb r3,CPU_AnalogX(REG_P2Data)
EscapeSheikThink_Chase_PassiveStandThink_HoldShieldSkip:
#Now grab when P1 is on frame 34
	lhz r3,TM_FramesinCurrentAS(REG_P1Data)
	cmpwi r3,34
	blt EscapeSheikThink_CheckTimer
#Enter grab
	mr	r3,REG_P2GObj
	li	r4,0xD4
	branchl r12,AS_Catch
#Advance state
	li	r3,EventState_Reset
	stb r3,EventState(REG_EventData)
#Start timer
	li	r3,ResetTimer
	stb r3,Timer(REG_EventData)
	b	EscapeSheikThink_CheckTimer


EscapeSheikThink_Chase_DownBoundThink:
#Determine jab frame
	lbz r3,JabFrame(REG_EventData)
	cmpwi r3,0
	bne EscapeSheikThink_Chase_DownBoundThink_JabFrameInitSkip
#Init Jab Frame
	li	r3,JabFrameHi-JabFrameLo
	branchl r12,HSD_Randi
	addi r3,r3,JabFrameLo
	stb r3,JabFrame(REG_EventData)
#Get chance to jab again
	li	r3,2
	branchl r12,HSD_Randi
	stb r3,isJabTwice(REG_EventData)
#Get frame to jab again
	li	r3,Jab2FrameHi-Jab2FrameLo
	branchl r12,HSD_Randi
	addi r3,r3,Jab2FrameLo
	stb r3,Jab2Frame(REG_EventData)
#Init Jab 2 Timer
	li	r3,0
	stb	r3,Jab2Timer(REG_EventData)
EscapeSheikThink_Chase_DownBoundThink_JabFrameInitSkip:
#Check if facing P1
	cmpwi REG_Direction,0
	bgt EscapeSheikThink_Chase_DownBoundThink_FacingSkip
#Input slightly towards
	lfs f1,0x2C(REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	mullw r3,r3,REG_Direction
	mulli r3,r3,100
	stb r3,CPU_AnalogX(REG_P2Data)
EscapeSheikThink_Chase_DownBoundThink_FacingSkip:
#Check distance (if over 16 units, walk towards)
	lfs f1,GrabDistance(REG_EventConstants)
	lfs f2,Distance(sp)
	fabs f2,f2
	fcmpo cr0,f2,f1
	ble EscapeSheikThink_Chase_DownBoundThink_RunTowardsSkip
EscapeSheikThink_Chase_DownBoundThink_WalkTowards:
#Walk Towards
	lfs f1,0x2C(REG_P2Data)
	fctiwz f1,f1
	stfd f1,0x80(sp)
	lwz r3,0x84(sp)
	mullw r3,r3,REG_Direction
	mulli r3,r3,100
	stb r3,CPU_AnalogX(REG_P2Data)
EscapeSheikThink_Chase_DownBoundThink_RunTowardsSkip:
#Check distance
	lfs f1,GrabDistance(REG_EventConstants)
	lfs f2,Distance(sp)
	fabs f2,f2
	fcmpo cr0,f2,f1
	bgt EscapeSheikThink_Chase_DownBoundThink_HaltSkip
#Ensure Facing
	cmpwi REG_Direction,1
	bne EscapeSheikThink_Chase_DownBoundThink_HaltSkip
EscapeSheikThink_Chase_DownBoundThink_Halt:
#Stop Moving
	li	r3,0
	stw r3,CPU_HeldButtons(REG_P2Data)
	stb r3,CPU_AnalogX(REG_P2Data)
EscapeSheikThink_Chase_DownBoundThink_HaltSkip:
#Now jab when P1 is on the jab frame
	lhz r3,TM_FramesinCurrentAS(REG_P1Data)
	lbz r4,JabFrame(REG_EventData)
	cmpw r3,r4
	blt EscapeSheikThink_CheckTimer
#Enter jab
	li	r3,PAD_BUTTON_A
	stw r3,CPU_HeldButtons(REG_P2Data)
	li	r3,0
	stb r3,CPU_AnalogX(REG_P2Data)
#Check if sheik will double jab
	lbz	r3,isJabTwice(REG_EventData)
	cmpwi	r3,0
	beq	EscapeSheikThink_Chase_DownBoundThink_SingleJab
#Start Double Jab timer
	lbz	r3,Jab2Frame(REG_EventData)
	stb	r3,Jab2Timer(REG_EventData)
#Change Event State
	li	r3,EventState_Jab2
	stb	r3,EventState(REG_EventData)
	b	EscapeSheikThink_CheckTimer
EscapeSheikThink_Chase_DownBoundThink_SingleJab:
#Advance state
	li	r3,EventState_Reset
	stb r3,EventState(REG_EventData)
#Start timer
	li	r3,ResetTimer+30
	stb r3,Timer(REG_EventData)
	b	EscapeSheikThink_CheckTimer
#endregion

#region EscapeSheikThink_Jab2
EscapeSheikThink_Jab2:
#Check if waiting on jab 2
	lbz	r3,Jab2Timer(REG_EventData)
	cmpwi	r3,0
	beq	EscapeSheikThink_Chase_DownBoundThink_Jab2Skip
#But not during hitlag
	lbz	r3,0x221A(REG_P2Data)
	rlwinm.	r3,r3,0,26,26
	bne	EscapeSheikThink_Chase_DownBoundThink_Jab2Skip
#Decrement timer
	lbz	r3,Jab2Timer(REG_EventData)
	subi	r3,r3,1
	stb	r3,Jab2Timer(REG_EventData)
#Check if up
	cmpwi	r3,0
	bgt	EscapeSheikThink_CheckTimer
#Enter jab
	li	r3,PAD_BUTTON_A
	stw r3,CPU_HeldButtons(REG_P2Data)
	li	r3,0
	stb r3,CPU_AnalogX(REG_P2Data)
#Advance state
	li	r3,EventState_Reset
	stb r3,EventState(REG_EventData)
#Start timer
	li	r3,ResetTimer+30
	stb r3,Timer(REG_EventData)
	b	EscapeSheikThink_CheckTimer
EscapeSheikThink_Chase_DownBoundThink_Jab2Skip:
	b	EscapeSheikThink_CheckTimer
#endregion

#region EscapeSheikThink_Reset
EscapeSheikThink_Reset:
#Hold Shield
	li	r3,PAD_TRIGGER_R
	stw	r3,CPU_HeldButtons(REG_P2Data)
	b	EscapeSheikThink_CheckTimer
#endregion

EscapeSheikThink_CheckTimer:
#Check if timer exists
	lbz r3,Timer(REG_EventData)
	cmpwi r3,0
	ble EscapeSheikThink_Exit
#Decrement timer
	subi r3,r3,1
	stb r3,Timer(REG_EventData)
	cmpwi r3,0
	bgt EscapeSheikThink_Exit

EscapeSheikThink_Restore:
#Restore State
	addi r3,REG_EventData,EventData_SaveStateStruct
	li	r4,1
	bl	SaveState_Load
#Init Positions Again
	mr	r3,REG_P1GObj
	mr	r4,REG_P2GObj
	mr	r5,REG_EventData
	bl	EscapeSheik_InitializePositions

EscapeSheikThink_Exit:
	restore
	blr

################################

EscapeSheikThink_Constants:
blrl
.set P1X,0x0
.set P1Y,0x4
.set P2X,0x8
.set P2Y,0xC
.set GrabDistance,0x10
.set HoldShieldVelocity,0x14
.set RunDistance,0x18

.float -8		#p1 x
.float  0		#p1 y
.float  8		#p2 x
.float  0		#p2 y
.float 14		#16
.float 1.1
.float 23

###########################################

EscapeSheikThink_TopText:
blrl
.string "Down B Input"
.align 2

EscapeSheikThink_BottomText:
blrl
.string "%df %s"
.align 2

EscapeSheikThink_EarlyText:
blrl
.string "Early"
.align 2

EscapeSheikThink_LateText:
blrl
.string "Late"
.align 2

###########################################

EscapeSheik_InitializePositions:
backup

.set REG_FacingDirection,31		#1 = p1 facing right, -1 = p1 facing left
.set REG_P1GObj,30
.set REG_P1Data,29
.set REG_P2GObj,28
.set REG_P2Data,27
.set REG_EventData,26

#Init Registers
  mr	REG_P1GObj,r3
  lwz REG_P1Data,0x2C(REG_P1GObj)
  mr	REG_P2GObj,r4
  lwz REG_P2Data,0x2C(REG_P2GObj)
	mr	REG_EventData,r5

EscapeSheik_InitializePositions_DetermineFacingDirection:
#Determine Facing Direction
	li	REG_FacingDirection,1
	li	r3,2
	branchl r12,HSD_Randi
	cmpwi r3,0
	beq EscapeSheik_InitializePositions_DetermineFacingDirection_End
	li	REG_FacingDirection,-1
EscapeSheik_InitializePositions_DetermineFacingDirection_End:

 #Apply Facing Directions
	mr	r3,REG_FacingDirection
	bl	IntToFloat
	stfs	f1,0x2C(REG_P1Data)
  mulli	r3,REG_FacingDirection,-1
  bl	IntToFloat
  stfs	f1,0x2C(REG_P2Data)

#Get Starting Coordinates
	lfs f1,P1X(REG_EventConstants)
	lfs f2,P1Y(REG_EventConstants)
	cmpwi REG_FacingDirection,0
	blt EscapeSheik_InitializePositions_P1FacingLeft
	stfs f1,0xB0(REG_P1Data)
	stfs f2,0xB4(REG_P1Data)
	b	EscapeSheik_InitializePositions_RightPosition
EscapeSheik_InitializePositions_P1FacingLeft:
	stfs f1,0xB0(REG_P2Data)
	stfs f2,0xB4(REG_P2Data)
EscapeSheik_InitializePositions_RightPosition:
	lfs f1,P1X(REG_EventConstants)
	lfs f2,P1Y(REG_EventConstants)
	cmpwi REG_FacingDirection,0
	blt EscapeSheik_InitializePositions_P2FacingRight
	stfs f1,0xB0(REG_P2Data)
	stfs f2,0xB4(REG_P2Data)
EscapeSheik_InitializePositions_P2FacingRight:
	stfs f1,0xB0(REG_P1Data)
	stfs f2,0xB4(REG_P1Data)
#Update Positions
	mr	r3,REG_P1GObj
	bl	PlacePlayerOnGround
	mr	r3,REG_P1GObj
	bl	UpdateCameraBox
	mr	r3,REG_P2GObj
	bl	PlacePlayerOnGround
	mr	r3,REG_P2GObj
	bl	UpdateCameraBox

#Store P1 into P2 Grab Pointer
	stw	REG_P1GObj,0x1A58(REG_P2Data)
	stw	REG_P1GObj,0x1A5C(REG_P2Data)
#Clear P1's Grabbed Player Pointer
	li	r3,0
	stw	r3,0x1A58(REG_P1Data)
	stw	r3,0x1A5C(REG_P1Data)
#Clear P2's GFX Pointer
	stw r3,0x60C(REG_P2Data)
#Enter P2 Into Grab
	mr	r3,REG_P2GObj			#P2 Enters Grab
	branchl	r12,AS_GrabOpponent
#Enter P1 Into Grabbed
	mr	r3,REG_P1GObj			#P1 Grabbed
	mr	r4,REG_P2GObj			#P2 = Grabber
	branchl	r12,AS_Grabbed
#Enter P2 Into GrabWait
	mr	r3,REG_P2GObj			#P2 Enters GrabWait
	branchl	r12,AS_CatchWait
#Give a bunch of grabstun
	li	r3,999
	bl	IntToFloat
	stfs f1,0x1A4C(REG_P1Data)

#Random percent
	li	r3,PercentHi-PercentLo
	branchl r12,HSD_Randi
	addi r4,r3,PercentLo
	lbz r3,0xC(REG_P1Data)
	branchl r12,PlayerBlock_SetDamage

#Reset Variables
	li	r3,EventState_ThrowDelay
	stb r3,EventState(REG_EventData)
	li	r3,0
	stb r3,Timer(REG_EventData)
	stb r3,JabFrame(REG_EventData)
#Init Throw Timer
	li	r3,ThrowTimerHi-ThrowTimerLo
	branchl r12,HSD_Randi
	addi r3,r3,ThrowTimerLo
	sth r3,ThrowTimer(REG_EventData)
#Init isDisplayedTiming
	li	r3,0
	stb	r3,isDisplayedTiming(REG_EventData)

EscapeSheik_InitializePositions_Exit:
	restore
	blr

#endregion

#region Scrapped Edgeguard Event
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
#endregion

#region Scrapped Dash Dance Code
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
#endregion

#region Event Template
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
#endregion

###############
## P1 STRUCT ##
###############
P1Struct:
blrl

.long 0x01000200 #external char, player type, stocks, costume
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

.long 0x01010200 #external char, player type, stocks, costume
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

#Registers
.set WindowOptionCount,31
.set ASCIIStruct,30
.set EventGObj,29
.set EventData,28
.set MenuGObj,27
.set MenuData,26
.set Priority,25
.set Function,24

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
  branchl	r12,GObj_AddProc

#Give Task Some Data Space
  li	r3,EventData_DataSize		#50 bytes of space
  branchl	r12,HSD_MemAlloc		#HSD_MemAlloc
  mr	EventData,r3

#Initalize GObj
  mr	r6,r3
  mr	r3,EventGObj		#task space
  li	r4,0x0		#typedef
  load	r5,HSD_Free		#destructor (HSD_Free)
  branchl	r12,GObj_AddUserData		#Create Data Block

#Zero Dataspace
  mr	r3,EventData
  li	r4,EventData_DataSize
  branchl	r12,ZeroAreaLength		#zero length

##############################
## Create Option Menu Think ##
##############################

#Check if Option Menu is enabled for this event
  cmpwi WindowOptionCount,0
  beq CreateEventThinkFunction_NoOptionMenu

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
  branchl	r12,GObj_AddProc

#Give Task Some Data Space
  li	r3,MenuData_DataSize		#50 bytes of space
  branchl	r12,HSD_MemAlloc		#HSD_MemAlloc
  mr	MenuData,r3

#Initalize GObj
  mr	r6,MenuData
  mr	r3,MenuGObj		#task space
  li	r4,0x0	    	#typedef
  load	r5,HSD_Free		#destructor (HSD_Free)
  branchl	r12,GObj_AddUserData		#Create Data Block

#Zero Dataspace
  mr	r3,MenuData
  li	r4,MenuData_DataSize
  branchl	r12,ZeroAreaLength		#zero length

#Store Option Menu info to Dataspace
  stw WindowOptionCount,MenuData_WindowOptionCountPointer(MenuData)
  stw ASCIIStruct,MenuData_ASCIIStructPointer(MenuData)

#Store Pointers to Each Other
  stw MenuData,EventData_MenuDataPointer(EventData)
  stw EventData,MenuData_EventDataPointer(MenuData)
CreateEventThinkFunction_NoOptionMenu:

#Disable Hazards
	bl	DisableHazards

CreateEventThinkFunction_Exit:
restore
blr

####################################
## Create Option Menu When Paused ##
####################################

OptionMenuThink:
blrl

.set MenuData,31

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
  addi r3,MenuData,MenuData_OptionMenuMemory
  lwz r4,MenuData_WindowOptionCountPointer(MenuData)
  lwz r5,MenuData_ASCIIStructPointer(MenuData)
  bl	OptionWindow

#Store Modified Option Bool
  cmpwi r3,0
  beq OptionMenuThink_Exit
  addi r5,MenuData,MenuData_OptionMenuToggled
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
  lwz r4,MenuData_WindowOptionCountPointer(r3)
  lbz r4,0x0(r4)

#Loop Through All Data
  addi r3,r3,MenuData_OptionMenuToggled
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
.set REG_SaveStruct,31
.set REG_PlayerTotal,30
.set REG_LoopCount,29
.set REG_isSubchar,23
.set REG_Backup,28
.set REG_SpawnedOrder,22
.set REG_PlayerGObj,25
.set REG_PlayerData,26
.set REG_PlayerDataSize,24
.set REG_PlayerData_Backup,27

	backup

#Backup Task Data
	mr	REG_SaveStruct,r3
#Backup "skip failsafe" bool
	mr	r20,r4

#Count Players in Match
	branchl	r3,0x8016b558

#Move Player Number to REG_PlayerTotal
	mr	REG_PlayerTotal,r3

#Check to run failsafe code
	cmpwi r20,0x0
	bne SaveState_SaveLoopInit

SaveState_OnDeathCheck:
#Mini loop to make sure no players have on-death functions
	li	REG_LoopCount,0x0		#player ID
	li	REG_isSubchar,0x0		#main/sub char bool
SaveState_OnDeathCheckLoop:
#Get Proper Player Data
	mr		r3,REG_LoopCount
	mr		r4,REG_isSubchar
	bl		SaveState_GetPlayerDataPointer  #returns player slot,player pointer and player data
	cmpwi		r3,0xFF				                #check if player didnt exist
	beq		SaveState_OnDeathCheckInc				#move on with loop
#Check for on-death function
	lwz		r3,0x21E0(r5)
  cmpwi r3,0x0
  bne SaveState_OnDeathCheckExit
	lwz		r3,0x21E4(r5)
  cmpwi r3,0x0
  bne SaveState_OnDeathCheckExit
	lwz		r3,0x21E8(r5)
  cmpwi r3,0x0
  bne SaveState_OnDeathCheckExit
#Check if holding an item
	lwz		r3,0x1974(r5)
  cmpwi r3,0x0
  bne SaveState_OnDeathCheckExit
	lwz		r3,0x1978(r5)
  cmpwi r3,0x0
  bne SaveState_OnDeathCheckExit
#Check for fighter accessory
	lwz		r3,0x20A0(r5)
  cmpwi r3,0x0
  bne SaveState_OnDeathCheckExit
  b SaveState_OnDeathCheckInc

SaveState_OnDeathCheckExit:
#PLay Error SFX
  li	r3,0xAF
  bl  PlaySFX
  li	r3,0xAF
  bl  PlaySFX
  b SaveState_SaveExit

SaveState_OnDeathCheckInc:
#Check For Subchar Before Looping
	cmpwi		REG_isSubchar,0x1
	beq		SaveState_OnDeathCheck_ToggleSubCharOff
	li		REG_isSubchar,0x1
	b		SaveState_OnDeathCheckLoop
SaveState_OnDeathCheck_ToggleSubCharOff:
	li		REG_isSubchar,0x0
	addi		REG_LoopCount,REG_LoopCount,0x1
	cmpw		REG_LoopCount,REG_PlayerTotal
	blt		SaveState_OnDeathCheckLoop

SaveState_SaveLoopInit:
	#Init Save Loop
	li	REG_LoopCount,0x0		#player ID
	li	REG_isSubchar,0x0		#main/sub char bool

		SaveState_SaveLoop:
		#Get This Player's Backup Pointer in REG_Backup
		mulli		r4,REG_LoopCount,0x8		#8 bytes per player pointer
		add		REG_Backup,r4,REG_SaveStruct		#REG_Backup contains this players block backup

		#Check If Backup Exists
		cmpwi		REG_isSubchar,0x0
		beq		SaveState_Save_MainChar
		SaveState_Save_SubChar:
		lwz 		r3,0x4(REG_Backup)		#get pointer to backup if it exists
		b		SaveState_Save_CheckIfExists
		SaveState_Save_MainChar:
		lwz 		r3,0x0(REG_Backup)		#get pointer to backup if it exists
		SaveState_Save_CheckIfExists:
		cmpwi		r3,0x0
		beq		SaveState_SaveStart

		#Remove Old Backup (HSD_Free)
		branchl		r12,HSD_Free



		SaveState_SaveStart:

		#Get Proper Player Data
		mr		r3,REG_LoopCount
		mr		r4,REG_isSubchar
		bl		SaveState_GetPlayerDataPointer		#returns player slot,player pointer and player data
		cmpwi		r3,0xFF				#check if player didnt exist
		beq		SaveState_SaveLoopInc				#move on with loop
		mr		REG_SpawnedOrder,r3				#REG_SpawnedOrder contains actual player slot
		mr		REG_PlayerData,r5				#REG_PlayerData contains real player block

		#Get Player Data Length
		SaveState_Save_GetPlayerBlockLength:
		load		r3,0x80458fd0
		lwz    	REG_PlayerDataSize,0x20(r3)			#get player block length in REG_PlayerDataSize
		addi		r3,REG_PlayerDataSize,0x100			#add static block length
		addi		r3,r3,0x10			#add additional storage
		branchl		r12,HSD_MemAlloc			#HSD_MemAlloc

		#Store Pointer To Task Struct
		cmpwi		REG_isSubchar,0x0
		bne		Savestate_Save_StoreBackupSubChar
		stw		r3,0x0(REG_Backup)
		b		Savestate_Save_StoreBackupEnd
		Savestate_Save_StoreBackupSubChar:
		stw		r3,0x4(REG_Backup)
		Savestate_Save_StoreBackupEnd:
		mr		REG_PlayerData_Backup,r3				#REG_PlayerData_Backup contains playerblock backup

		#Copy Player Block to Backup
		mr		r3,REG_PlayerData_Backup			#r3 = destination to copy to
		mr		r4,REG_PlayerData			#r4 = source
		mr 		r5,REG_PlayerDataSize			#r5 = playerblock length
		branchl		r12,memcpy			#mempcy


		#Copy Static Block to Backup
			cmpwi REG_isSubchar,0x0					#unless this is a subcharacter
			bne	Savestate_Save_SkipStaticBlockBackup
			add		r3,REG_PlayerDataSize,REG_PlayerData_Backup			#get end of playerblock in r4
			load		r4,0x80453080			#get static block in r4
			li		r5,0xE90
			mullw		r5,r5,REG_SpawnedOrder
			add		r4,r4,r5
			li		r5,0x100			#only copying the first 100 bytes
			branchl		r12,memcpy			#mempcy
		Savestate_Save_SkipStaticBlockBackup:

		#Save Camera Flag
		lwz		r3,0x890(REG_PlayerData)
		lwz		r3,0x8(r3)
		add		r4,REG_PlayerDataSize,REG_PlayerData_Backup		#get end of player block in r4
		addi		r4,r4,0x100		#get end of static block
		stw		r3,0x0(r4)		#store to end of block

		SaveState_SaveLoopInc:
		#Check For Subchar Before Looping
		cmpwi		REG_isSubchar,0x1
		beq		SaveState_SaveLoopInc_ToggleSubCharOff
		li		REG_isSubchar,0x1
		b		SaveState_SaveLoop

		SaveState_SaveLoopInc_ToggleSubCharOff:
		li		REG_isSubchar,0x0
		addi		REG_LoopCount,REG_LoopCount,0x1
		cmpw		REG_LoopCount,REG_PlayerTotal
		blt		SaveState_SaveLoop

SaveState_SaveExit:
	restore
	blr

SaveState_Load:
.set REG_SaveStruct,31
.set REG_PlayerTotal,30
.set REG_LoopCount,29
.set REG_isSubchar,23
.set REG_Backup,28
.set REG_SpawnedOrder,22
.set REG_PlayerGObj,25
.set REG_PlayerData,26
.set REG_PlayerDataSize,24
.set REG_PlayerData_Backup,27


	backup

	mr	REG_SaveStruct,r3

	#Count Players in Match
	branchl	r3,0x8016b558

	#Move Player Number to REG_PlayerTotal
	mr	REG_PlayerTotal,r3

	#Restore Camera Info Here


	#Init Load Loop
	li	REG_LoopCount,0x0		#player count
	li	REG_isSubchar,0x0		#main/subchar bool

		SaveState_LoadLoop:
		#Get This Player's Backup Pointer in REG_Backup
		mulli		r4,REG_LoopCount,0x8		#8 bytes per player pointer
		add		REG_Backup,r4,REG_SaveStruct		#REG_Backup contains this players block backup

		#Check If Backup Exists
		cmpwi		REG_isSubchar,0x0
		beq		SaveState_Load_MainChar
		SaveState_Load_SubChar:
		lwz 		r3,0x4(REG_Backup)		#get pointer to backup if it exists
		b		SaveState_Load_CheckIfExists
		SaveState_Load_MainChar:
		lwz 		r3,0x0(REG_Backup)		#get pointer to backup if it exists
		SaveState_Load_CheckIfExists:
		cmpwi		r3,0x0
		beq		SaveState_LoadLoopInc


		SaveState_LoadStart:

		#Get Proper Player Data
		mr		r3,REG_LoopCount
		mr		r4,REG_isSubchar
		bl		SaveState_GetPlayerDataPointer		#returns player slot,player pointer and player data
		cmpwi		r3,0xFF				#check if player didnt exist
		beq		SaveState_LoadLoopInc				#move on with loop
		mr		REG_SpawnedOrder,r3				#REG_SpawnedOrder contains actual player slot
		mr		REG_PlayerGObj,r4				#REG_PlayerGObj contains external player
		mr		REG_PlayerData,r5				#REG_PlayerData contains real player block

		#Get Player Block Length in REG_PlayerDataSize
		SaveState_Load_GetPlayerBlockLength:
		load		REG_PlayerDataSize,0x80458fd0
		lwz    		REG_PlayerDataSize,0x20(REG_PlayerDataSize)		#REG_PlayerDataSize = length

		#Get Pointer From Task Struct
		cmpwi		REG_isSubchar,0x0		#check if subcharacter
		beq		Savestate_Load_GetBackupMainChar
		Savestate_Load_GetBackupSubChar:
		lwz		REG_PlayerData_Backup,0x4(REG_Backup)		#REG_PlayerData_Backup contains playerblock backup
		b		Savestate_Load_RestoreFacingDirection
		Savestate_Load_GetBackupMainChar:
		lwz		REG_PlayerData_Backup,0x0(REG_Backup)		#REG_PlayerData_Backup contains playerblock backup

		#Restore Facing Direction
		Savestate_Load_RestoreFacingDirection:
		lwz		r3,0x2C(REG_PlayerData_Backup)		#backed up Facing Direction
		stw		r3,0x2C(REG_PlayerData)

		#Enter Into Sleep
		mr		r3,REG_PlayerGObj
		li		r4,0x0
		branchl		r12,AS_Sleep

		#Remove On Death Function Pointer
		li		r3,0x0
		stw		r3,0x21E4(REG_PlayerData)
		stw		r3,0x21E8(REG_PlayerData)

		#Enter Into Backed Up State
		mr		r3,REG_PlayerGObj
		lwz		r4,0x10(REG_PlayerData_Backup)		#backed up AS
		li		r5,0x0
		li		r6,0x0
		lfs		f1,0x894(REG_PlayerData_Backup)		#backed up Frame Number
		lfs		f2,0x89C(REG_PlayerData_Backup)		#backed up Frame Speed
		lfs		f3,-0x7548 (rtoc)
		#lfs		f3,0x8A4(REG_PlayerData_Backup)		#backup up Blend Amount
		branchl		r12,ActionStateChange					#ASC

		#Keep Previous Frame Buttons From Current Block
		lwz		r3,0x620(REG_PlayerData)
		stw		r3,0xD0(sp)
		lwz		r3,0x624(REG_PlayerData)
		stw		r3,0xD4(sp)
		lwz		r3,0x65C(REG_PlayerData)
		stw		r3,0xD8(sp)

		#Keep Collision Bubble Toggles
		lwz		r3,0x21FC(REG_PlayerData)
		stw		r3,0xDC(sp)

		#Copy PlayerBlock Backup to Current
		mr		r3,REG_PlayerData
		mr		r4,REG_PlayerData_Backup
		mr		r5,REG_PlayerDataSize
		branchl		r12,memcpy	#mempcy

		#Zero Blend
		#lfs	 f1,-0x7548 (rtoc)
		#stfs f1,0x8A4(REG_PlayerData)

		#Copy Static Block Backup to Current
			cmpwi REG_isSubchar,0									#but not if subcharacter
			bne Savestate_Load_SkipStaticBlockRestore
			load		r3,0x80453080			#get static block in r3
			li		r4,0xE90
			mullw		r4,r4,REG_SpawnedOrder
			add		r3,r3,r4
			add		r4,REG_PlayerDataSize,REG_PlayerData_Backup			#get end of block in r4
			li		r5,0x100			#length is 0x100
			branchl		r12,memcpy			#mempcy
			Savestate_Load_SkipStaticBlockRestore:

		#Restore Previous Frame Buttons From Current Block
		lwz		r3,0xD0(sp)
		stw		r3,0x620(REG_PlayerData)
		stw		r3,0x628(REG_PlayerData)
		lwz		r3,0xD4(sp)
		stw		r3,0x624(REG_PlayerData)
		stw		r3,0x62C(REG_PlayerData)
		lwz		r3,0xD8(sp)
		stw		r3,0x65C(REG_PlayerData)
		stw		r3,0x660(REG_PlayerData)
		stw		r3,0x664(REG_PlayerData)

		#Restore Collision Bubble Toggles
		lwz		r3,0xDC(sp)
		stw		r3,0x21FC(REG_PlayerData)

		#Remove Cached Animation Pointer (This fixes the Fall Animation Bug)
		li	r3,0x0
		stw	r3,0x5A8(REG_PlayerData)

    #Remove Respawn Platform JObj Pointer and Think Function
    stw r3,0x20A0(REG_PlayerData)
    stw r3,0x21B0(REG_PlayerData)

    #Remove Held Item Pointer
    stw r3,0x1974(REG_PlayerData)

    #Update ECB Position
		mr		r3,REG_PlayerGObj
		bl  UpdatePosition

    #Stop Player's SFX
    mr  r3,REG_PlayerData
    branchl r12,SFX_StopAllCharacterSFX

    #Stop Crowd SFX
    branchl r12,SFXManager_StopSFXIfPlaying

    #Remove GFX
    mr  r3,REG_PlayerGObj
    branchl	r12,GFX_RemoveAll

		/* #Removing this, causes ground issues when restoring. instead im removing the OSReport call for the error
		#If Grounded, Change Ground Variable Back
		lwz		r3,0xE0(REG_PlayerData)
		cmpwi		r3,0x0
		bne		Savestate_RestoreCameraFlag
		li		r3,0x1
		stw		r3,0x83C(REG_PlayerData)
		*/

		#Restore Camera Flag
		Savestate_RestoreCameraFlag:
		add		r3,REG_PlayerDataSize,REG_PlayerData_Backup		#get end of block in r4
		addi		r3,r3,0x100		#static block length = 0x100
		lwz		r3,0x0(r3)		#get flag
		lwz		r4,0x890(REG_PlayerData)
		stw		r3,0x8(r4)

    #Update Camera Box Position
    mr  r3,REG_PlayerGObj
    bl  UpdateCameraBox

		#Remake HUD For Dead Players (Taken from Achilles' GitHub)
		cmpwi		REG_isSubchar,0x1		#dont run this on subcharacters
		beq		SaveState_HUD_End
		load		r3,0x804a10c8		#get base HUD info
		mulli 		r4,REG_SpawnedOrder,100		#get offset
		add		r20,r4,r3		#get to this player's HUD info
		branchl		r12,0x8016b094	 #MatchInfo_StockModeCheck
		cmpwi 		r3,0		#if not stock mode
		beq- 		SaveState_RELOAD_PERCENT_HUDS_NOT_STOCK

			SaveState_RELOAD_PERCENT_HUDS_STOCK:
			mr		r3,REG_SpawnedOrder		#get player number
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
				mr 		r3,REG_SpawnedOrder
				branchl		r4, HUD_PlayerCreate_Prefunction

		SaveState_HUD_End:

		SaveState_LoadLoopInc:
		#Check For Subchar Before Looping
		cmpwi		REG_isSubchar,0x1
		beq		SaveState_LoadLoopInc_ToggleSubCharOff
		li		REG_isSubchar,0x1
		b		SaveState_LoadLoop
		SaveState_LoadLoopInc_ToggleSubCharOff:
		li		REG_isSubchar,0x0
		addi		REG_LoopCount,REG_LoopCount,0x1
		cmpw		REG_LoopCount,REG_PlayerTotal
		blt		SaveState_LoadLoop

    SaveState_LoadEnd:

    /*
    SaveState_Load_RemoveAllGFX:
    #Get First GFX
      lwz  r3,-0x3E74 (r13)
      lwz  r20,0x30(r3)
    #Check if exists
    SaveState_Load_CheckIfGFXExists:
      cmpwi r20,0
      beq SaveState_Load_RemoveAllGFXEnd
    #Check if this is a particle GObj?
      lbz r3,0x4(r20)
      cmpwi r3,1
      beq SaveState_Load_GetNextGFX
    #Remove this GFX
      mr  r3,r20
      branchl r12,0x80390228
    #Get next GFX
    SaveState_Load_GetNextGFX:
      lwz r20,0x8(r20)
      b SaveState_Load_CheckIfGFXExists
    SaveState_Load_RemoveAllGFXEnd:
    */

  SaveState_LoadExit:
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

.set LoopCount,31

backup

mr	r29,r3		#Task Data

#Init Loop
  li  LoopCount,0
#Loop
CheckForSaveAndLoad_Loop:
  mr  r3,LoopCount
  branchl r12,PlayerBlock_LoadMainCharDataOffset
  cmpwi r3,0x0
  beq CheckForSaveAndLoad_Inc
CheckForSaveAndLoad_CheckInputs:
  load r3,0x804c21cc
  #load r3,0x804c1fac
  mulli r0,LoopCount,68
  add r4,r3,r0
#Make Sure Nothing Else Is Held
  lhz	r3,0x2(r4)
  rlwinm.  r0,r3,0,0,26
  bne	CheckForSaveAndLoad_Inc
  lwz	r3,0x8(r4)
  rlwinm.	r0,r3,0,30,30
  beq	CheckForSaveAndLoad_NoSave
  mr	r3,r29
	li	r4,0			#run failsafe code
  bl	SaveState_Save
  li	r3,0x0
  b	CheckForSaveAndLoad_Exit
CheckForSaveAndLoad_NoSave:
  rlwinm.	r0,r3,0,31,31
  beq	CheckForSaveAndLoad_Inc
  mr	r3,r29
  bl	SaveState_Load
  mr	r3,r29
  bl	SaveState_Load
  li	r3,0x1
  b	CheckForSaveAndLoad_Exit

CheckForSaveAndLoad_Inc:
  addi LoopCount,LoopCount,1
  cmpwi LoopCount,4
  blt CheckForSaveAndLoad_Loop

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
lwz r3,TM_GameFrameCounter(r13)
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
## Display Up/Down Arrows ##
############################

#Check if at the top of the screen
  lbz r3,0x1(r20)
  cmpwi r3,0x0
  beq RAndDPadChangesEventOption_DisplayDownArrow
#Create Title Text
	li r3,-20        #Y
  bl  IntToFloat
  fmr f2,f1
  li  r3,-210      #X
  bl  IntToFloat
	mr 	r3,text			#text pointer
	bl  RAndDPadChangesEventOption_UpArrowText
  mflr r4
	branchl r12,Text_InitializeSubtext

RAndDPadChangesEventOption_DisplayDownArrow:
#Check if at the bottom of the screen
  lbz r3,0x0(r21)
  cmpwi r3,2
  blt RAndDPadChangesEventOption_DisplayArrowExit
  lbz r4,0x1(r20)
  sub r3,r3,r4
  cmpwi r3,2
  ble RAndDPadChangesEventOption_DisplayArrowExit
#Create Title Text
  li  r3,320      #Y value
  bl  IntToFloat
  fmr f2,f1
  li  r3,-210     #X Value
  bl  IntToFloat
	mr 	r3,text			#text pointer
	bl  RAndDPadChangesEventOption_DownArrowText
  mflr r4
	branchl r12,Text_InitializeSubtext

RAndDPadChangesEventOption_DisplayArrowExit:

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
			lfs	f2, -0x37B4 (rtoc)			#default text Y
			li	r3,120
			mullw	r3,r3,r27
			bl	IntToFloat
			fadds	f2,f1,f2
			lfs	f1, -0x37B4 (rtoc)			#default text X
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

.float 16 #12.5, X position
.long 0x427c0000 #63, 2 Window Y Scale
.long 0x42bc0000 #94, 3 Window Y Scale
.long 0xc4610000 #-900, 2 Window Y position
.long 0xc4a8c000 #-1350, 3 Window Y position

#########################################
RAndDPadChangesEventOption_UpArrowText:
blrl

.string "^"
.align 2

RAndDPadChangesEventOption_DownArrowText:
blrl

.string "v"
.align 2

#########################################

RAndDPadChangesEventOption_Exit:
mr	r3,toggledBool
mr	r4,toggledOption
restore
blr

##################################

DPadCPUPercent:
backup

.set REG_SaveStruct,31
.set REG_PercentInt,30
.set REG_isSubcharBool,29

#Backup savestate struct
	mr	REG_SaveStruct,r3

#Get P1 Block
	li	r3,0x0
	branchl	r12,PlayerBlock_LoadMainCharDataOffset			#get player block
	lwz	r3,0x2C(r3)

#Get P2 Percent
	load	r6,0x80453F10
	lhz	REG_PercentInt,0x60(r6)

#Get Subchar Bool
	lbz REG_isSubcharBool,0xC(r6)

#Get inputs
  load r4,0x804c21cc
	lbz r3,0x618(r3)
  mulli r0,r3,68
  add r5,r4,r0
#Make Sure L Is Held
	lwz r3,0x0(r5)		#get held inputs
	rlwinm. r0,r3,0,25,25
	beq	DPadCPUPercent_Exit
#Check DPad
	lwz r3,0xC(r5)		#get rapid inputs
	rlwinm.	r0,r3,0,30,30
	bne	DPadCPUPercent_IncByOne
	rlwinm.	r0,r3,0,31,31
	bne	DPadCPUPercent_DecByOne
	rlwinm.	r0,r3,0,28,28
	bne	DPadCPUPercent_IncByTen
	rlwinm.	r0,r3,0,29,29
	bne	DPadCPUPercent_DecByTen
	b	DPadCPUPercent_Exit

DPadCPUPercent_IncByOne:
	cmpwi	REG_PercentInt,999
	blt	DPadCPUPercent_IncByOneReal
	li	REG_PercentInt,999
	b	DPadCPUPercent_StorePercent
	DPadCPUPercent_IncByOneReal:
	addi	REG_PercentInt,REG_PercentInt,0x1
	b	DPadCPUPercent_StorePercent

DPadCPUPercent_DecByOne:
	cmpwi	REG_PercentInt,0
	bgt	DPadCPUPercent_DecByOneReal
	li	REG_PercentInt,0
	b	DPadCPUPercent_StorePercent
	DPadCPUPercent_DecByOneReal:
	subi	REG_PercentInt,REG_PercentInt,0x1
	b	DPadCPUPercent_StorePercent

DPadCPUPercent_IncByTen:
	cmpwi	REG_PercentInt,989
	blt	DPadCPUPercent_IncByTenReal
	li	REG_PercentInt,999
	b	DPadCPUPercent_StorePercent
	DPadCPUPercent_IncByTenReal:
	addi	REG_PercentInt,REG_PercentInt,10
	b	DPadCPUPercent_StorePercent

DPadCPUPercent_DecByTen:
	cmpwi	REG_PercentInt,9
	bgt	DPadCPUPercent_DecByTenReal
	li	REG_PercentInt,0
	b	DPadCPUPercent_StorePercent
	DPadCPUPercent_DecByTenReal:
	subi	REG_PercentInt,REG_PercentInt,10
	b	DPadCPUPercent_StorePercent

DPadCPUPercent_StorePercent:
#Store to Active Static Playerblock
	sth	REG_PercentInt,0x60(r6)
#Convert to Float
	mr		r3,REG_PercentInt
	bl		IntToFloat
#Active PlayerData
	li	r3,0x1
	branchl	r12,PlayerBlock_LoadMainCharDataOffset		#get player block
	lwz	r3,0x2C(r3)
	stfs	f1,0x1830(r3)

#Backed Up PlayerData
	mulli	r4,REG_isSubcharBool,0x4
	lwzx r3,r4,REG_SaveStruct
	stfs	f1,0x1830(r3)
#Backed Up Static Playerblock
	load	r4,0x80458fd0					#get player block length
	lwz   r4,0x20(r4)						#get player block length
	lwz r3,0x0(REG_SaveStruct)	#only the main character has a static block backup
	add	r3,r3,r4								#static block start
	sth	REG_PercentInt,0x60(r3)
	sth	REG_PercentInt,0x62(r3)


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
bl	UpdateCameraBox
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
mr	r3,r24
bl	UpdateCameraBox

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
bl	UpdateCameraBox
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
mr	r3,r24
bl	UpdateCameraBox

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
li	r6,OSD.Miscellaneous			#Window ID (Unique to This Display)
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

#Get Input
  lbz	r4, 0x0618 (P1Data)
  load r3,InputStructStart
  mulli	r0, r4, 68
  add	r5, r0, r3

#Check DPad Down
	lwz	r3,0xC(r5)
	rlwinm.	r0,r3,0,29,29
	beq	MoveCPUExit
#Make Sure Nothing Is Held
	lwz	r3,0x0(r5)
	li	r4,0
	rlwimi r3,r4,0,29,29		#except dpad down
	rlwimi r3,r4,0,27,27		#except Z (cause frame advance)
	cmpwi r3,0
	bne	MoveCPUExit

#Make Sure Player is Grounded
  lwz r3,0xE0(P1Data)
  cmpwi r3,0x0
  bne MoveCPU_NoGroundFound

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
	li	r4,1			#Override failsafe code
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
  rlwinm.  r0,r3,0,27,27
  bne 0xC
  cmpwi r3,0x0
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
#X
  lwz	r3, 0x00B0 (PlayerData)
  stw	r3, 0x06F4 (PlayerData)
  stw	r3, 0x0700 (PlayerData)
	stw	r3, 0x070C (PlayerData)
	stw	r3, 0x0718 (PlayerData)
#Y
  lwz	r3, 0x00B4 (PlayerData)
  stw	r3, 0x06F8 (PlayerData)
  stw	r3, 0x0704 (PlayerData)
	stw	r3, 0x0710 (PlayerData)
	stw	r3, 0x071C (PlayerData)
#Z
  lwz	r3, 0x00B8 (PlayerData)
  stw	r3, 0x06FC (PlayerData)
  stw	r3, 0x0708 (PlayerData)
	stw	r3, 0x0714 (PlayerData)
	stw	r3, 0x0720 (PlayerData)
#Update Collision Frame ID
  lwz	r3, -0x51F4 (r13)
  stw r3, 0x728(PlayerData)

  #branchl	r12,0x80081b38     #Stopped using this because it deletes way too much ECB info
  #branchl r12,0x80082a68      #Better than the above function, but all i need is to copy current position into the ECB previous values

#Adjust JObj position (code copied from 8006c324)
	lwz r3,0x28(PlayerGObj)			#get character model JObj
	lwz	r4,0xB0(PlayerData)			#get X
	stw r4,0x38(r3)							#store X
	lwz	r4,0xB4(PlayerData)			#get Y
	stw r4,0x3C(r3)							#store Y
	lwz	r4,0xB8(PlayerData)			#get Z
	stw r4,0x40(r3)							#store Z
#Dirty Sub
	#branchl r12,0x803732e8

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
  branchl r12,Raycast_GroundLine

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
  branchl r12,Raycast_GroundLine

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
PlacePlayerOnGround:
backup

.set REG_GObj,31
.set REG_GObjData,30

#Get Pointers
	mr	REG_GObj,r3
	lwz REG_GObjData,0x2C(REG_GObj)

#Find Ground Below Player
  mr  r3,REG_GObj
  bl  FindGroundNearPlayer
  cmpwi r3,0    #Check if ground was found
  beq PlacePlayerOnGround_SkipGroundCorrection
  stfs f1,0xB0(REG_GObjData)
  stfs f2,0xB4(REG_GObjData)
  stw r4,0x83C(REG_GObjData)
  PlacePlayerOnGround_SkipGroundCorrection:
#Update Position
  mr  r3,REG_GObj
  bl  UpdatePosition
#Update ECB Values for the ground ID
  mr r3,REG_GObj
  branchl r12,EnvironmentCollision_WaitLanding
#Set Grounded
  mr r3,REG_GObjData
  branchl r12,Air_SetAsGrounded

PlacePlayerOnGround_Exit:
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
  lbz	r0, 0x221D (r5)
  li	r3,0x1
  rlwimi	r0,r3,4,27,27
  stb	r0,0x221D (r5)
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

InitializeMatch:

.set REG_EventStruct,31
.set REG_MatchStruct,30
.set REG_CPUChoice,29
.set REG_StageChoice,28
.set REG_EventOSDs,27
.set REG_PlayerStruct,26
.set REG_UseSopo,25

#Init
	backup
	mr REG_EventStruct,r3
	mr REG_MatchStruct,r4
	mr REG_CPUChoice,r5
	mr REG_StageChoice,r6
	mr REG_EventOSDs,r7
	mr REG_UseSopo,r8

#Check to override OSD Toggles
	lwz	r4,-0x77C0(r13)
	lbz	r3,0x1f2A(r4)
	cmpwi r3,1
	beq InitializeMatch_SkipOSDOverride
#Store Events FDD Toggles
	lwz	r3,0x1F24(r4)
	or	r3,r3,REG_EventOSDs
	stw	r3,0x1F24(r4)
InitializeMatch_SkipOSDOverride:

#SPAWN 2 PLAYERS
	li	r3,0x40
	stb	r3,0x1(REG_EventStruct)

#Make Copy of Struct
	li	r3,32
	branchl r12,HSD_MemAlloc
	mr REG_PlayerStruct,r3
	bl	P2Struct
	mflr r4
	li	r5,0x1C
	branchl r12,memcpy
#Store to P2 pointer in event struct
	stw REG_PlayerStruct,0x18(REG_EventStruct)

#Store CPU
	cmpwi REG_CPUChoice,-1
	beq InitializeMatch_StoreCSSCPU
#Store this CPU
	stb	REG_CPUChoice,0x0(REG_PlayerStruct)
	b	InitializeMatch_StoreStage
InitializeMatch_StoreCSSCPU:
	load	r3,0x8043207c							#get preload table
	lwz	r4,0x18(r3)									#get p2 character ID
	cmpwi	r4,0x12										#check if zelda
	bne	0x8
	li	r4,0x13											#make zelda sheik
	stb	r4,0x0(REG_PlayerStruct)		#store chosen char
	lbz	r6,0x1C(r3)									#get p2 costume ID
	stb	r6,0x3(REG_PlayerStruct)		#store p2 costume ID
	li	r5,0x1											#make CPU controlled
	stb	r5,0x1(REG_PlayerStruct)

InitializeMatch_StoreStage:
#Store Stage
	cmpwi REG_StageChoice,-1
	beq InitializeMatch_StoreSSSStage
#Store this Stage
	sth	REG_StageChoice,0xE(REG_MatchStruct)
	b	InitializeMatch_StoreStage_End
InitializeMatch_StoreSSSStage:
	load	r3,0x8043207c							#get preload table
	lwz	r3, 0x00C (r3)
	sth	r3,0xE(REG_MatchStruct)			#store chosen stage
InitializeMatch_StoreStage_End:

InitializeMatch_SwapInSopo:
	cmpwi REG_UseSopo,0
	beq	InitializeMatch_SwapInSopo_End
#Swap P1 Character to Sopo
	lwz	r4, -0x77C0 (r13)
	addi	r4, r4, 1328		#event mode match backup struct?
	lbz	r3,0x2(r4)		#P1 External ID
	cmpwi	r3,0xE
	bne	InitializeMatch_SwapInSopo_End
	li	r3,0x20
	stb	r3,0x2(r4)		#Make SoPo
InitializeMatch_SwapInSopo_End:

InitializeMatch_Exit:
	restore
	blr

#####################################

GetDistance:
	lfs	f3,0x0(r3)	#X
	lfs	f4,0x4(r3)  #Y
	lfs	f5,0x0(r4)  #X
	lfs	f6,0x4(r4)  #Y
	fsubs	f1,f5,f3
	fsubs	f2,f4,f6
	fmuls	f1,f1,f1
	fmuls	f2,f2,f2
	fadds	f2,f1,f2
	frsqrte	f1,f2
	fmuls	f1,f1,f2
	blr

#####################################

GetLedgeCoordinates:

.set LedgeSide,20
.set LedgeID,21
.set Return,22

backup

#Backup Ledge Choice (0 = Left, 1 = Right)
  mr	LedgeSide,r3
  mr  Return,r4

#Get Stage's Ledge IDs
  lwz		r3,-0x6CB8 (r13)			#External Stage ID
  bl		LedgedashCliffIDs
  mflr  r4
  mulli	r3,r3,0x2
  lhzx	r3,r3,r4
#Get Requested Ledge
	cmpwi LedgeSide,0x0
	beq	GetLedgeCoordinates_GetLeftLedgeID

GetLedgeCoordinates_GetRightLedgeID:
  rlwinm	LedgeID,r3,0,24,31
#Get Ledge Coords (0x80 = X, 0x84 = Y)
  mr  r3,LedgeID
  mr 	r4,Return
  branchl	r12,Stage_GetRightOfLineCoordinates
  b	GetLedgeCoordinates_Exit

GetLedgeCoordinates_GetLeftLedgeID:
	rlwinm	LedgeID,r3,24,24,31
#Get Ledge Coords (0x80 = X, 0x84 = Y)
  mr  r3,LedgeID
  mr 	r4,Return
  branchl	r12,Stage_GetLeftOfLineCoordinates
	b	GetLedgeCoordinates_Exit

GetLedgeCoordinates_Exit:
  restore
  blr

##########################################
GetAngleBetweenPoints:
.set REG_arctan,2
.set REG_Constants,31

backup

#Get Constants
	bl	GetAngleBetweenPoints_Constants
	mflr REG_Constants

#Get Values
	lfs f1,0x0(r3)
	lfs f2,0x4(r3)
	lfs f3,0x0(r4)
	lfs f4,0x4(r4)
#Get slope ydelta / xdelta
	fsubs f5,f4,f2
	fsubs f6,f3,f1
	fdivs f1,f5,f6
#atan
	branchl r12,0x80022e68
	fmr REG_arctan,f1

#Ensure above 0 and below 6.28319
GetAngleBetweenPoints_CheckIfOver0:
	lfs f1,0x0(REG_Constants)
	fcmpo cr0,REG_arctan,f1
	bge GetAngleBetweenPoints_CheckIfUnder360
#Add 180
	lfs f1,0x8(REG_Constants)
	fadds REG_arctan,REG_arctan,f1
	b	GetAngleBetweenPoints_CheckIfOver0
GetAngleBetweenPoints_CheckIfUnder360:
	lfs f1,0x4(REG_Constants)
	fcmpo cr0,REG_arctan,f1
	ble GetAngleBetweenPoints_Under360
#Add 180
	lfs f1,0x8(REG_Constants)
	fsubs REG_arctan,REG_arctan,f1
	b	GetAngleBetweenPoints_CheckIfUnder360
GetAngleBetweenPoints_Under360:
	fmr	f1,REG_arctan

GetAngleBetweenPoints_Exit:
restore
blr

GetAngleBetweenPoints_Constants:
blrl
.float 0
.float 6.28319
.float 3.14159

##########################################
EnterKnockback:
backup

.set REG_GObj,31
.set REG_GObjData,30
.set REG_AngleLo,29
.set REG_AngleHi,28
.set REG_MagLo,27
.set REG_MagHi,26
.set REG_Angle,29
.set REG_Magnitude,28

#Backup Data
	mr	REG_GObj,r3
	lwz REG_GObjData,0x2C(REG_GObj)
	mr	REG_AngleLo,r4
	mr	REG_AngleHi,r5
	mr	REG_MagLo,r6
	mr	REG_MagHi,r7

#Random angle between
	sub	r3,REG_AngleHi,REG_AngleLo
	branchl r12,HSD_Randi
	add REG_Angle,r3,REG_AngleLo
#Cast to float
	mr	r3,REG_Angle
	bl	IntToFloat
#Now in radians
	lfs	f2, -0x7510 (rtoc)
	fmuls f1,f1,f2
	stfs f1,0x80(sp)

#Random magnitude between X and Y
	mr	r3,REG_MagLo
	mr	r4,REG_MagHi
	bl	RandFloat
	stfs f1,0x7C(sp)		#will be used later for
	lwz	r3, -0x514C (r13)
	lfs	f0, 0x0100 (r3)
	fmuls f1,f1,f0
	stfs f1,0x84(sp)

#Get X Component
	lfs f1,0x80(sp)		#KB angle in radians
	branchl r12,cos
	lfs f2,0x84(sp)		#KB magnitude
	fmuls f1,f1,f2
	lfs f2,0x2C(REG_GObjData)
	fneg f2,f2
	fmuls f1,f1,f2
	stfs f1,0x8C(REG_GObjData)
#Get Y Component
	lfs f1,0x80(sp)		#KB angle in radians
	branchl r12,sin
	lfs f2,0x84(sp)		#KB magnitude
	fmuls f1,f1,f2
	stfs f1,0x90(REG_GObjData)

#Calculate Hitstun
	lwz	r3, -0x514C (r13)
	lfs	f0, 0x0154 (r3)
	lfs f1,0x7C(sp)
	fmuls f1,f1,f0			#hitstun frames is 0.4 * magnitude
	fctiwz f1,f1				#Round down
	stfd f1,0x88(sp)
	lwz r3,0x8C(sp)
	bl	IntToFloat
	stfs f1,0x2340(REG_GObjData)
#Enable Hitstun Bit
	lbz r0,0x221C(REG_GObjData)
	li	r3,1
	rlwimi r0,r3,1,30,30
	stb r0,0x221C(REG_GObjData)

#Enable ECB Update
	mr	r3,REG_GObjData
	branchl r12,0x8007d5bc

EnterKnockback_Exit:
	restore
	blr

##########################################
DisableHazards:

#Get list start
	bl	DisableHazards_SkipList
########################
bl	DisableHazards_Dummy
bl	DisableHazards_TEST
bl	DisableHazards_Izumi
bl	DisableHazards_Pstadium
bl	DisableHazards_Castle
bl	DisableHazards_Kongo
bl	DisableHazards_Zebes
bl	DisableHazards_Corneria
bl	DisableHazards_Story
bl	DisableHazards_Onett
bl	DisableHazards_MuteCity
bl	DisableHazards_RCruise
bl	DisableHazards_Garden
bl	DisableHazards_GreatBay
bl	DisableHazards_Shrine
bl	DisableHazards_Kraid
bl	DisableHazards_Yoster
bl	DisableHazards_Greens
bl	DisableHazards_Fourside
bl	DisableHazards_MK1
bl	DisableHazards_MK2
bl	DisableHazards_Akaneia
bl	DisableHazards_Venom
bl	DisableHazards_Pura
bl	DisableHazards_BigBlue
bl	DisableHazards_Icemt
bl	DisableHazards_Icetop
bl	DisableHazards_FlatZone
bl	DisableHazards_OldDL
bl	DisableHazards_OldYS
bl	DisableHazards_OldKongo
bl	DisableHazards_Battlefield
bl	DisableHazards_FinalDestination
########################
DisableHazards_SkipList:
	mflr r3
	lwz r4,StageID_External(r13)
	mulli	r4,r4,4
	add r4,r3,r4
	lwz r5,0x0(r4)				#Get bl Instruction
  rlwinm	r5,r5,0,6,29	#Mask Bits 6-29 (the offset)
	cmpwi r5,0						#If pointer is null, exit
	beq	DisableHazards_SkipList_Exit
  add	r4,r4,r5					#Pointer to code now in r4
	mtctr r4
	bctr

########################

DisableHazards_Story:
/*
#Get randall's line ID
	mr	r3,REG_map_gobj
	branchl r12,0x801c6330
	lwz	r3,0x4(r3)						#get map_head
	lwz r3,0x8(r3)						#get map_gobj info
	mulli	r4,REG_map_gobj,52	#get randall's info
	add r3,r3,r4
	lwz r3,0x20(r3)						#pointer to the collision data
	lhz r3,0x0(r3)						#i believe this is randalls line ID
#Get randalls corner IDs
	mulli r3,r3,8							#0x8 in length
	lwz	r4, -0x51E4 (r13)			#line to corner ID table
	lwzx r5,r3,r4							#now have the corner ID struct
	lhz r3,0x0(r5)						#left corner id
	lhz r4,0x2(r5)						#right corner id
#Get corner IDs info
	lwz	r5, -0x51E8 (r13)
	mulli r3,r3,24
	mulli r4,r4,24
	add r3,r3,r5
	add r4,r4,r5
#Zero current X and Y positions, effectively removing these lines
	li	r5,0
	stw r5,0x8(r3)
	stw r5,0xC(r3)
	stw r5,0x8(r4)
	stw r5,0xC(r4)
*/

/*
#Get randall's map_gobj
	li	r3,2				#randalls map_gobj is 2
	branchl r12,Stage_map_gobj_Load
	branchl r12,Stage_Destroy_map_gobj
*/

#Get shyguy's map_gobj
	li	r3,3				#shyguys map_gobj is
	branchl r12,Stage_map_gobj_Load
#Remove Proc
	branchl r12,GObj_RemoveProc

#Fix ragdoll issue
	bl	DisableHazards_RagdollFix

b	DisableHazards_SkipList_Exit

########################

DisableHazards_Pstadium:
#Get transformation's map_gobj
	li	r3,2				#transformation's map_gobj ID
	branchl r12,Stage_map_gobj_Load
#Remove Proc
	branchl r12,GObj_RemoveProc
#Fix ragdoll issue
	bl	DisableHazards_RagdollFix

b	DisableHazards_SkipList_Exit

########################

DisableHazards_OldDL:
#Destroy whispy's map_gobj
	li	r3,7				#transformation's map_gobj ID
	branchl r12,Stage_map_gobj_Load
	branchl r12,Stage_Destroy_map_gobj

#Destroy whispy's blink map_gobj proc
	li	r3,6				#transformation's map_gobj ID
	branchl r12,Stage_map_gobj_Load
	branchl r12,GObj_RemoveProc

#set wind hazard count to 0
	li	r3,0
	stw	r3,Stage_PositionHazardCount(r13)

b	DisableHazards_SkipList_Exit

########################

DisableHazards_OldYS:
#Destroy cloud's map_gobj
	li	r3,2				#map_gobj ID
	branchl r12,Stage_map_gobj_Load
	branchl r12,Stage_Destroy_map_gobj

b	DisableHazards_SkipList_Exit

########################

DisableHazards_OldKongo:
#Destroy barrel's map_gobj
	li	r3,1				#map_gobj ID
	branchl r12,Stage_map_gobj_Load
	branchl r12,Stage_Destroy_map_gobj

b	DisableHazards_SkipList_Exit

########################
DisableHazards_RagdollFix:
#Certain stages have an essential ragdoll function
#in their map_gobj think function. If the think function is removed,
#the ragdoll function must be re-scheduled to function properly.

backup

#Create GObj
  li	r3,3		#GObj Type
  li	r4,5		#On-Pause Function
  li	r5,0
  branchl	r12,GObj_Create
#Schedule Task
	bl	DisableHazards_RagdollFix_Think
	mflr r4
  li	r5,4		#Priority
  branchl	r12,GObj_AddProc
	b	DisableHazards_RagdollFix_Exit

#********************************#
DisableHazards_RagdollFix_Think:
blrl

backup

branchl r12,Ragdoll_WindDecayThink

restore
blr
#********************************#

DisableHazards_RagdollFix_Exit:
restore
blr
#########################

DisableHazards_SkipList_Exit:
	restore
	blr
###########################################

PlaybackInputSequence:
.set REG_PlayerData,31
.set REG_InputSequence,30
.set REG_AttackTimer,29

#Input Sequence Struct
.set InputSequence_Length,0x9
.set InputSequence_Frame,0x0
.set InputSequence_Buttons,0x1
.set InputSequence_AnalogX,0x5
.set InputSequence_AnalogY,0x6
.set InputSequence_CStickX,0x7
.set InputSequence_CStickY,0x8

backup

#Backup args
	mr	REG_PlayerData,r3
	mr	REG_InputSequence,r4
	mr	REG_AttackTimer,r5

PlaybackInputSequence_Loop:
#Search for this frames input in the sequence
	lbz r3,InputSequence_Frame(REG_InputSequence)
#Check if end of sequence
	extsb r0,r3
	cmpwi r0,-1
	beq PlaybackInputSequenceExit
#Check if this frame's input
	cmpw r5,r3
	beq PlaybackInputSequence_PlayInput
	blt PlaybackInputSequenceExit						#Check if the current frame is less than the parsed frame
#If greater, continue parsing
	addi REG_InputSequence,REG_InputSequence,InputSequence_Length
	b PlaybackInputSequence_Loop						#If greater, continue parsing

PlaybackInputSequence_PlayInput:
	lwz r3,InputSequence_Buttons(REG_InputSequence)
	stw r3,CPU_HeldButtons(REG_PlayerData)
	lbz r3,InputSequence_AnalogX(REG_InputSequence)
	stb r3,CPU_AnalogX(REG_PlayerData)
	lbz r3,InputSequence_AnalogY(REG_InputSequence)
	stb r3,CPU_AnalogY(REG_PlayerData)
	lbz r3,InputSequence_CStickX(REG_InputSequence)
	stb r3,CPU_CStickX(REG_PlayerData)
	lbz r3,InputSequence_CStickY(REG_InputSequence)
	stb r3,CPU_CStickY(REG_PlayerData)

PlaybackInputSequenceExit:
	restore
	blr

###########################################
PlaceOnLedge:
backup

.set REG_LedgeID,31
.set REG_P1GObj,30
.set REG_P1Data,29

#Backup pointers
mr	REG_P1GObj,r3
lwz REG_P1Data,0x2C(REG_P1GObj)
mr	REG_LedgeID,r4

#Get Stage's Ledge IDs
	lwz		r3,-0x6CB8 (r13)			#External Stage ID
	bl		LedgedashCliffIDs
	mflr  r4
	mulli	r3,r3,0x2
	lhzx	r3,r3,r4
#Get Requested Ledge
	cmpwi REG_LedgeID,0x0
	beq	PlaceOnLedge_GetLeftLedgeID

PlaceOnLedge_GetRightLedgeID:
	rlwinm	r20,r3,0,24,31
#Change Facing Direction
	li	r3,-1
	bl	IntToFloat
	stfs	f1,0x2C(REG_P1Data)
	b	PlaceOnLedge_StoreLedgeIDAndPosition

PlaceOnLedge_GetLeftLedgeID:
	rlwinm	r20,r3,24,24,31
#Change Facing Direction
	li	r3,1
	bl	IntToFloat
	stfs	f1,0x2C(REG_P1Data)
	b	PlaceOnLedge_StoreLedgeIDAndPosition

PlaceOnLedge_StoreLedgeIDAndPosition:
#Store Ledge to Player Block
	stw r20,0x2340(REG_P1Data)
#Enter CliffWait
	mr	r3,REG_P1GObj
	branchl r12,AS_CliffWait
#Init state variable (would be 1 at the start of the next frame if it ocurred naturally)
	li	r3,1
	stw	r3,0x2348(REG_P1Data)
#Spoof in state for 1 frame
	li	r3,1
	sth	r3,TM_FramesinCurrentAS(REG_P1Data)
#Get Jump Back
	mr r3,REG_P1Data
	branchl r12,Air_StoreBool_LoseGroundJump_NoECBfor10Frames
#Set ECB Update Flag
	mr  r3,REG_P1Data
	branchl r12,DataOffset_ECBBottomUpdateEnable
#Update ECB Corner Positions
	addi	r3,REG_P1Data,0x6F0
	branchl	r12,0x80048160
#Move Player To Ledge
	mr	r3,REG_P1GObj
	branchl r12,MovePlayerToLedge
#Update Position
	mr	r3,REG_P1GObj
	bl UpdatePosition
#Kill Velocity
	li		r3,0x0
	stw		r3,0x80(REG_P1Data)			#X Velocity
	stw		r3,0x84(REG_P1Data)			#Y Velocity

#Give Intangibility (30)
	mr	r3,REG_P1GObj
	lwz	r4, -0x514C (r13)
	lwz	r4, 0x049C (r4)
	branchl	r12,ApplyIntangibility

	restore
	blr
###########################################
GetInputStruct:
  load r4,InputStructStart
  mulli	r0, r3, 68
  add	r3, r0, r4
	blr

###########################################
exit:
li	r0, 3
