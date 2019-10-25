.set ExpoitReturnAddr,0x80239700

.set Text_CreateTextCanvas,0x803A543C
.set Text_CreateTextStruct,0x803A5A74
.set Text_InitializeSubtext,0x803a5eb8
.set Text_UpdateSubtextSize,0x803A6868
.set Text_RemoveText,0x803A4FE4
.set GObj_Create,0x8038F510
.set HSD_MemAlloc,0x8037E504
.set HSD_Free,0x8037E4D0
.set ZeroAreaLength,0x8000C160
.set strlen,0x80324E2C
.set strcpy,0x80324D78
.set memset,0x80003100
.set GObj_AddUserData,0x8038FE88
.set GObj_AddProc,0x8038F074
.set Text_ChangeTextColor,0x803A6810
.set Text_UpdateSubtextContents,0x803A63C0
.set Inputs_GetPlayerRapidHeldInputs,0x801A3078
.set Inputs_GetPlayerInstantInputs,0x801A3058
.set Inputs_GetPlayerHeldInputs,0x801A3038
.set SFX_PlayMenuSound_CloseOpenPort,0x8017403C
.set SFX_PlayMenuSound_Forward,0x80173FF4
.set HSD_VISetUserPostRetraceCallback,0x80374C54
.set TRK_flush_cache,0x80328278
.set MenuController_ChangeScreenMinor,0x801A4518
.set Scene_GetMajorSceneStruct,0x801A4A64
.set Scene_MinorIDToMinorSceneFunctionTable,0x801A4698
.set MenuController_WriteToPendingMajor,0x801A3CA0
.set MenuController_ChangeScreenMajor,0x801A3C8C
.set Text_AllocateTextObject,0x803A4DEC
.set Memcard_AllocateSomething,0x8001C550
.set MemoryCard_LoadBannerIconImagesToRAM,0x8001D164
.set PlayerBlock_LoadDataOffsetStart,0x8003418C
.set SinglePlayerModeCheck,0x8016B128
.set PlayerBlock_LoadSlotType,0x8003241C
.set PlayerBlock_LoadTeamID,0x80033370
.set PlayerBlock_StoreFacingDirectionAgain,0x80033094
.set PlayerBlock_LoadDamage,0x800342B4
.set PlayerBlock_GetCliffhangerStat,0x80040ADC
.set GetSSMatchStruct,0x801A4BFC
.set LoadRulesSettingsPointer4,0x8015C830
.set HSD_PadRumbleActiveId,0x80377750
.set Rumble_StoreRumbleFlag,0x8015E8B0
.set MatchEnd_GetWinningTeam,0x80165278
.set PlayerBlock_StoreInitialXYCoords,0x80032768
.set getStageFromRandomStageSelect,0x8025924c
.set Preload_CompareGameCache,0x80018254
.set Nametag_GetAddressForNametagID,0x8015C874
.set Deflicker_Toggle,0x8015f27c
.set UnlockSram,0x80348114
.set MemoryCard_CheckToSaveData,0x8001CC84
.set MemoryCard_WaitForFileToFinishSaving,0x8001B6F8
.set PlayerBlock_LoadMainCharDataOffset,0x80034110
.set PlayerBlock_LoadDataOffset,0x8003418C
.set AS_218_CatchCut,0x800DA424
.set SFX_PlaySFXAtFullVolume,0x801C4D80
.set SFX_MenuCommonSound,0x80024030
.set LoadFile_EfData,0x80067368
.set AS_AnimationFrameUpdateMore,0x8006EB58
/*
.set GFX_Shine,0x800E8C10
.set ApplyIntangibility,0x8007BE34
.set ActionStateChange,0x80069a88
.set Camera_UpdatePlayerCameraBoxPosition,0x800768A0
.set Interrupt_Jump_Grounded,0x800CB674
.set Interrupt_PlatformPass,0x8009A5D4
.set Interrupt_AerialJumpGoTo,0x800CC014
.set Physics_FoxShineStart,0x800E9038
.set Physics_FoxShineLoopGround,0x800E93E8
.set Physics_FoxShineLoopAir,0x800E941C
.set EnvironmentCollision_AllowGroundToAir,0x80082D84
.set Air_StoreBool_LoseGroundJump_NoECBfor10Frames,0x8007DCA8
.set Subaction_FastForward,0x80073A2C
.set EnvironmentCollision_CheckForGroundOnly,0x80082388
.set Air_SetAsGrounded2,0x8007DED0
.set FrameTimerCheck,0x8006F910
.set AS_FallorWait_CheckAirStateFlag,0x8007E000
.set Interrupt_JoystickPushedBackwards,0x800C9F4C
.set GFX_ShineLoop,0x800E8B94
.set FuncBlr,0x8006E120
.set Reflect_CreateBubble,0x8007B910
.set GFX_RemoveAllPrefunction,0x8007E1F8
.set GFX_RemoveAll,0x8005BF44
.set DevelopText_CreateDataTable,0x80303240
.set DevelopText_Activate,0x8030321C
.set DevelopText_AddString,0x803035F0
.set DevelopText_EraseAllText,0x803035BC
.set DevelopMode_Text_ResetCursorXY,0x80303448
*/
.set sprintf,0x8032301C
.set ScreenDisplay_Adjust,0x8015F304
.set Text_CopyPremadeTextDataToStruct,0x803A5688
.set MemoryCard_WaitForFileToFinishSaving,0x8001B6F8
.set Snapshot_UpdateFileList,0x802536F0
.set Memcard_FreeSomething,0x8001C5A4
.set Memcard_AllocateSomething,0x8001C550
.set MemoryCard_ReadDataIntoMemory,0x8001BF04
.set MemoryCard_WaitForFileToFinishSaving,0x8001B6F8
.set Scene_GetMinorSceneData2,0x801A4554

#Mem Addresses
.set	TournamentMode,0x80190A94 #*
.set  OFST_Memcard,-0x77C0 #find it @ 8015ed3c in 102
.set  OFST_ModPrefs,0x1F30
.set  PostRetraceCallback,0x800195FC #*

.set  UnkPadStruct,0x80431d10
.set  OFST_MainMenuSceneData,0x804d5b9c
.set  OFST_MemcardController,0x80432638

.set  ExploitReturn,0x80239700 #*

.set  OFST_NametagStart,0x3000
.set  HWInputs,0x804c1258
.set  OFST_PlCo,-0x514C #0x80067ADC
.set  OFST_ExtStageID,-0x6CB8 #0x80224A74
.set  HWInputArray,0x8046a428
.set  InputStruct,0x804c128c
.set  VSModeCSSData,0x8047fb40
.set  SceneController,0x80479050
.set  CSS_SubSceneID,-0x49AA #0x80260F74
.set  CSS_WindowGObjs,0x803f01ac
.set  CSS_MinorSceneData,-0x49F0 #0x8026611C
.set  SSS_IconData,0x3ef9f0
.set  SSS_Unk1,-0x4A00 #0x8025A294
.set  SSS_Unk2,-0x49F2 #0x8025A2A0
.set  SSS_HighlightedStage,-0x49F2 #0x8025A2A0
.set  SSS_MnSlMap,-0x4A0C #
.set  Match_StaticMatchData,0x8046a9c0
.set  Match_EndStruct,0x804790c4
.set  PreloadTable,0x8043139C
.set  DeflickerStruct,0x8046a410
.set  ProgressiveStruct,0x8046a410
.set  OFST_CommonCObj,-0x4884 #0x80301B3C
.set  MemcardFileList,0x804326a0 #use func 8001e238 to find it #*
.set  SnapshotData,0x803bacc8 #use func 8001df4c to find it #*
.set  SnapshotLoadThinkStruct,0x8049fd30 #804a0b6c, use func 8025389c to find it #*

.set  MainSaveUnk,0x804240b8 # r30 at 8001d24c (102)
.set  MainSaveData,0x803bb0b4 # r25 at 8001ccb0 (102)
.set  MainSaveString,0x803bb244 # r4 at 8001a564 (102)
.set  OFST_Rand,-0x570C
