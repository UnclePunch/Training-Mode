.set isPAL,1

.set ExpoitReturnAddr,0x8023BDB0

.set HeapHijack_Injection,0x80015994
.set PersistentHeapStruct,0x80431fa0

.set Heap_MainID,-0x58A0
.set Heap_CurrentHeap,-0x5A98
.set Heap_Lo,-0x3FE8
.set Heap_Hi,-0x3FE4

.set OSDestroyHeap,0x80344154
.set OSCreateHeap,0x803440e8
.set OSAllocFromHeap,0x80343ef0

.set Text_CreateTextCanvas,0x803A6044
.set Text_CreateTextStruct,0x803A6664
.set Text_InitializeSubtext,0x803a6b54
.set Text_UpdateSubtextSize,0x803A74FC
.set Text_RemoveText,0x803A5BEC
.set GObj_Create,0x80390118
.set HSD_MemAlloc,0x8037F0E8
.set HSD_Free,0x8037F0B4
.set ZeroAreaLength,0x8000C2C0
.set strlen,0x80325DE0
.set strcpy,0x80325D2C
.set memset,0x80003100
.set GObj_AddUserData,0x80390A90
.set GObj_AddProc,0x8038FC7C
.set Text_ChangeTextColor,0x803A74A4
.set Text_UpdateSubtextContents,0x803A7054
.set Inputs_GetPlayerRapidHeldInputs,0x801A4104
.set Inputs_GetPlayerInstantInputs,0x801A40E4
.set Inputs_GetPlayerHeldInputs,0x801A40C4
.set SFX_PlayMenuSound_CloseOpenPort,0x80174D34
.set SFX_PlayMenuSound_Forward,0x80174CEC
.set HSD_VISetUserPostRetraceCallback,0x80375838
.set TRK_flush_cache,0x8032922C
.set MenuController_ChangeScreenMinor,0x801A5664
.set Scene_GetMajorSceneStruct,0x801A5BB0
.set Scene_MinorIDToMinorSceneFunctionTable,0x801A57E4
.set MenuController_WriteToPendingMajor,0x801A4DF8
.set MenuController_ChangeScreenMajor,0x801A4DE4
.set Text_AllocateTextObject,0x803A59F4
.set Memcard_AllocateSomething,0x8001C65C
.set MemoryCard_LoadBannerIconImagesToRAM,0x8001D464
.set OSGetProgressiveMode,0x80347ec8
.set PlayerBlock_LoadDataOffsetStart,0x80034780
.set SinglePlayerModeCheck,0x8016BDEC
.set PlayerBlock_LoadSlotType,0x80032A10
.set PlayerBlock_LoadTeamID,0x80033964
.set PlayerBlock_StoreFacingDirectionAgain,0x80033688
.set PlayerBlock_LoadDamage,0x800348A8
.set PlayerBlock_GetCliffhangerStat,0x800411B4
.set GetSSMatchStruct,0x801A5D48
.set LoadRulesSettingsPointer4,0x8015D3FC
.set HSD_PadRumbleActiveId,0x80378334
.set Rumble_StoreRumbleFlag,0x8015F4F0
.set MatchEnd_GetWinningTeam,0x80165E70
.set PlayerBlock_StoreInitialXYCoords,0x80032D5C
.set getStageFromRandomStageSelect,0x8025a4ec
.set Preload_CompareGameCache,0x80018498
.set Nametag_GetAddressForNametagID,0x8015d440
.set Deflicker_Toggle,0x8015fca4
.set UnlockSram,0x80347934
.set MemoryCard_CheckToSaveData,0x8001CF84
.set MemoryCard_WaitForFileToFinishSaving,0x8001B87C
.set PlayerBlock_LoadMainCharDataOffset,0x80034704
.set PlayerBlock_LoadDataOffset,0x80034780
.set AS_218_CatchCut,0x800DAE4C
.set SFX_PlaySFXAtFullVolume,0x801C7010
.set SFX_MenuCommonSound,0x800242F0
.set LoadFile_EfData,0x80067A40
.set AS_AnimationFrameUpdateMore,0x8006F27C
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
.set sprintf,0x80323FA4
.set ScreenDisplay_Adjust,0x8015fddc
.set Text_CopyPremadeTextDataToStruct,0x803A6290
.set MemoryCard_WaitForFileToFinishSaving,0x8001B87C
.set Snapshot_UpdateFileList,0x80254F3C
.set Memcard_FreeSomething,0x8001C6B0
.set Memcard_AllocateSomething,0x8001C65C
.set MemoryCard_ReadDataIntoMemory,0x8001C088
.set MemoryCard_WaitForFileToFinishSaving,0x8001B87C
.set Scene_GetMinorSceneData2,0x801A56A0
.set MemoryCard_LoadData,0x8001BEB8

#Mem Addresses
.set	TournamentMode,0x80191C24
.set  OFST_Memcard,-0x77A8
.set  OFST_ModPrefs,0x1F30
.set  PostRetraceCallback,0x80019AB4
.set  UnkPadStruct,0x80423790
.set  OFST_MainMenuSceneData,0x804c7bc4
.set  OFST_MemcardController,0x804240b8
.set  ExploitReturn,0x8023BDB0
.set  OFST_NametagStart,0x3000
.set  Nametag_Length,0xda38
.set  HWInputs,0x804b2ff8
.set  OFST_PlCo,-0x4F0C
.set  OFST_ExtStageID,-0x6C98 #-0x6CB8
.set  HWInputArray,0x8045bf10
.set  InputStruct,0x804b302c
.set  VSModeCSSData,0x80471628
.set  SceneController,0x8046ab38
.set  CSS_SubSceneID,-0x4712
.set  CSS_WindowGObjs,0x803F1CF8
.set  CSS_MinorSceneData,-0x4758
.set  SSS_IconData,0x803f1550
.set  SSS_Unk1,-0x4768
.set  SSS_Unk2,-0x475A
.set  SSS_HighlightedStage,-0x475A
.set  SSS_MnSlMap,-0x4774
.set  Match_StaticMatchData,0x8045c4a8
.set  Match_EndStruct,0x8046abac
.set  PreloadTable,0x80422e1c
.set  DeflickerStruct,0x8045bef8
.set  ProgressiveStruct,0x8045bef8
.set  OFST_CommonCObj,-0x45EC
.set  MemcardFileList,0x80424120 #80433380
.set  SnapshotData,0x803bb2c0 #0x803bacdc
.set  SnapshotLoadThinkStruct,0x80491a98
.set  VI_Struct,0x804b2e00 #0x804c1d80
.set  RenewInputs_Prefunction,0x80019AB4


.set  MainSaveUnk,0x804240b8 # r30 at 8001d24c (102)
.set  MainSaveData,0x803bb0b4 # r25 at 8001ccb0 (102)
.set  MainSaveString,0x803bb244 # r4 at 8001a564 (102)
.set  OFST_Rand,-0x5564
