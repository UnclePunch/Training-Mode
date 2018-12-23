#Debug Flag
.set debug,1

#Codeset Variables
.set FirstCustomEvent, (4)    -1
.set LastCustomEvent, (15)    -1

#Static Memory Locations
.set pdLoadCommonData,0x803bcde0
.set InputStructStart,0x804c21cc
.set PreloadTableQueue,0x8043207c
.set PreloadTableUpdated,0x804320d0

#Playerdata offsets
.set PrevASStart,0x23F0
.set CurrentAS,0x10
.set OneASAgo,PrevASStart+0x0
.set TwoASAgo,PrevASStart+0x2
.set ThreeASAgo,PrevASStart+0x4
.set FourASAgo,PrevASStart+0x6
.set FiveASAgo,PrevASStart+0x8
.set SixASAgo,PrevASStart+0xA

#Function Names
.set ActionStateChange,0x800693ac
.set OSReport,0x803456a8
.set HSD_Randi,0x80380580
.set HSD_Randf,0x80380528
.set AS_Wait,0x8008a348
.set AS_Fall,0x800cc730
.set HSD_MemAlloc,0x8037f1e4
.set memcpy,0x800031f4
.set ZeroAreaLength,0x8000c160
.set CreateCameraBox,0x80029020
.set HUD_KOCounter_UpdateKOs,0x802fa2d0
.set Playerblock_StoreTimesR3KilledR4,0x80034fa8
.set Playerblock_LoadTimesR3KilledR4,0x80034f24
.set SFX_PlaySoundAtFullVolume,0x801c53ec
.set SFX_MenuCommonSound,0x80024030
.set AS_Rebirth,0x800d4ff4
.set Stage_GetLeftOfLineCoordinates,0x80053ecc
.set Stage_GetRightOfLineCoordinates,0x80053da4
.set AS_RebirthWait,0x800d5600
.set RebirthPlatform_UpdatePosition,0x800d54a4
.set AS_CliffWait,0x8009a804
.set Air_StoreBool_LoseGroundJump_NoECBfor10Frames,0x8007d5d4
.set DataOffset_ECBBottomUpdateEnable,0x8007d5bc
.set MovePlayerToLedge,0x80081544
.set ApplyIntangibility,0x8007b760
.set ApplyInvincibility,0x8007b7a4
.set GFX_RemoveAll,0x8007db24
.set PlayerBlock_LoadMainCharDataOffset,0x80034110
.set StageInfo_CameraLimitLeft_Load,0x80224a54
.set StageInfo_CameraLimitRight_Load,0x80224a68
.set StageInfo_CameraLimitTop_Load,0x80224a80
.set StageInfo_CameraLimitBottom_Load,0x80224a98
.set EntityItemSpawn,0x80268b18
.set MatchInfo_LoadSeconds,0x8016aeec
.set MatchInfo_LoadSubSeconds,0x8016aefc
.set EventMatch_OnWinCondition,0x801bc4f4
.set Textures_DisplayEffectTextures,0x8005fddc
.set AS_GrabOpponent,0x800d9ce8
.set AS_Grabbed,0x800daadc
.set AS_CatchWait,0x800da1d8
.set AS_SquatWait,0x800d62c4
.set AS_Sleep,0x800d4f24
.set SetAsGrounded,0x8007d7fc
.set FrameSpeedChange,0x8006f190
.set EnvironmentCollision_WaitLanding,0x80084280
.set Air_SetAsGrounded,0x8007d6a4
.set CPU_JoystickXAxis_Convert,0x800a17e4
.set CPU_JoystickYAxis_Convert,0x800a1874
.set GFX_UpdatePlayerGFX,0x800c0408
.set cos,0x80326240
.set sin,0x803263d4
.set HSD_Free,0x8037f1b0
.set GObj_Create,0x803901f0
.set GObj_Initialize,0x80390b68
.set GObj_Destroy,0x80390228
.set SchedulePerFrameProcess,0x8038fd54
.set DevelopMode_FrameAdvanceCheck,0x801a45e8
.set MatchInfo_StockModeCheck,0x8016b094
.set PlayerBlock_LoadStocksLeft,0x80033bd8
.set PlayerBlock_LoadSlotType,0x8003241c
.set Playerblock_LoadStaticBlock,0x80031724
.set Text_CreateTextStruct,0x803a6754
.set Text_InitializeSubtext,0x803a6b98
.set Text_UpdateSubtextSize,0x803a7548
.set Text_UpdateSubtextPosition,0x803a746c
.set Text_ChangeTextColor,0x803a74f0
.set strlen,0x80325b04
.set PlayerBlock_LoadExternalCharID,0x80032330
.set PlayerBlock_GotoStaleMoveEntry_0xBC,0x80036244
.set InitializePlayerDataValues,0x80068354
.set Event_GetEventSavedScore,0x8015cf5c
.set Events_CheckIfEventWasPlayedYet,0x8015cefc
.set Events_SetEventAsPlayed,0x8015ceb4
.set Events_StoreEventScore,0x8015cf70
.set Interrupt_AerialJumpGoTo,0x800cb870
.set PlayerBlock_UpdateXYCoords,0x80032828
.set GroundRaycast,0x8004f008
.set Camera_UpdatePlayerCameraBoxPosition,0x800761c8
.set Camera_CorrectPosition,0x8002f3ac

#Custom Functions
.set CheckIfCustomEvent,0x80005520

.macro branchl reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctrl
.endm

.macro branch reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctr
.endm

.macro load reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
.endm

.macro backup
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r20,0x8(r1)
.endm

 .macro restore
lmw  r20,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
.endm

.macro backupall
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r3,0x8(r1)
.endm

.macro restoreall
lmw  r3,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
.endm
