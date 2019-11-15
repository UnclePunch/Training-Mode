.set ExpoitReturnAddr,0x80238B90

.set HeapHijack_Injection,0x80015914
.set PersistentHeapStruct,0x8042ffe0

.set Heap_MainID,-0x58A8
.set Heap_CurrentHeap, -0x5A98
.set Heap_Lo,-0x3FF0
.set Heap_Hi,-0x3FEC

.set OSDestroyHeap,0x80342824
.set OSCreateHeap,0x803427B8

.set Text_CreateTextCanvas,0x803A4258
.set Text_CreateTextStruct,0x803A4890
.set Text_InitializeSubtext,0x803A4CD4
.set Text_UpdateSubtextSize,0x803A5684
.set Text_RemoveText,0x803A3E00
.set GObj_Create,0x8038E32C
.set HSD_MemAlloc,0x8037D330
.set HSD_Free,0x8037D2FC
.set ZeroAreaLength,0x8000C160
.set strlen,0x803241A0
.set strcpy,0x803240EC
.set memset,0x80003100
.set GObj_AddUserData,0x8038ECA4
.set GObj_AddProc,0x8038DE90
.set Text_ChangeTextColor,0x803A562C
.set Text_UpdateSubtextContents,0x803A51DC
.set Inputs_GetPlayerRapidHeldInputs,0x801A2978
.set Inputs_GetPlayerInstantInputs,0x801A2958
.set Inputs_GetPlayerHeldInputs,0x801A2938
.set SFX_PlayMenuSound_CloseOpenPort,0x80173900
.set SFX_PlayMenuSound_Forward,0x801738B8
.set HSD_VISetUserPostRetraceCallback,0x80373A80
.set TRK_flush_cache,0x803275EC
.set MenuController_ChangeScreenMinor,0x801A3E18
.set Scene_GetMajorSceneStruct,0x801A4364
.set Scene_MinorIDToMinorSceneFunctionTable,0x801A3F98
.set MenuController_WriteToPendingMajor,0x801A35A0
.set MenuController_ChangeScreenMajor,0x801A358C
.set Text_AllocateTextObject,0x803A3C08
.set Memcard_AllocateSomething,0x8001C4D0
.set MemoryCard_LoadBannerIconImagesToRAM,0x8001D0E4
.set PlayerBlock_LoadDataOffsetStart,0x8003410C
.set SinglePlayerModeCheck,0x8016AB00
.set PlayerBlock_LoadSlotType,0x8003239C
.set PlayerBlock_LoadTeamID,0x800332F0
.set PlayerBlock_StoreFacingDirectionAgain,0x80033014
.set PlayerBlock_LoadDamage,0x800342B4
.set PlayerBlock_GetCliffhangerStat,0x80040A2C
.set GetSSMatchStruct,0x801A44FC
.set LoadRulesSettingsPointer4,0x8015C2A4
.set HSD_PadRumbleActiveId,0x8037657C
.set Rumble_StoreRumbleFlag,0x8015E2D0
.set MatchEnd_GetWinningTeam,0x80164C98
.set PlayerBlock_StoreInitialXYCoords,0x800326E8
.set getStageFromRandomStageSelect,0x802586dc
.set Preload_CompareGameCache,0x800181D4
.set Nametag_GetAddressForNametagID,0x8015C2E8
.set Deflicker_Toggle,0x8015ec9c
.set UnlockSram,0x80347004
.set MemoryCard_CheckToSaveData,0x8001CC04
.set MemoryCard_WaitForFileToFinishSaving,0x8001B678
.set PlayerBlock_LoadMainCharDataOffset,0x80034090
.set PlayerBlock_LoadDataOffset,0x8003410C
.set AS_218_CatchCut,0x800DA24C
.set SFX_PlaySFXAtFullVolume,0x801C441C
.set SFX_MenuCommonSound,0x80023FB0
.set LoadFile_EfData,0x80067258
.set AS_AnimationFrameUpdateMore,0x8006EA48
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
.set sprintf,0x80322390
.set ScreenDisplay_Adjust,0x8015ED24
.set Text_CopyPremadeTextDataToStruct,0x803A44A4
.set MemoryCard_WaitForFileToFinishSaving,0x8001B678
.set Snapshot_UpdateFileList,0x80252B80
.set Memcard_FreeSomething,0x8001C524
.set Memcard_AllocateSomething,0x8001C4D0
.set MemoryCard_ReadDataIntoMemory,0x8001BE84
.set MemoryCard_WaitForFileToFinishSaving,0x8001B678
.set Scene_GetMinorSceneData2,0x801A3E54
.set MemoryCard_LoadData,0x8001BEB8

#Mem Addresses
.set	TournamentMode,0x801901E0 #*
.set  OFST_Memcard,-0x77C0 #find it @ 8015ed3c in 102
.set  OFST_ModPrefs,0x1F30
.set  PostRetraceCallback,0x8001957C #*

.set  UnkPadStruct,0x80430a30 #80019A48
.set  OFST_MainMenuSceneData,0x804d473c
.set  OFST_MemcardController,0x80431358

.set  ExploitReturn,0x80238B90 #*

.set  OFST_NametagStart,0x3000
.set  Nametag_Length,0xd894
.set  HWInputs,0x804bfdf8
.set  OFST_PlCo,-0x514C # 0x800679CC
.set  OFST_ExtStageID,-0x6CB8 # 0x80223EEC
.set  HWInputArray,0x80469140
.set  InputStruct,0x804bfe2c
.set  VSModeCSSData,0x8047e858
.set  SceneController,0x80477d68
.set  CSS_SubSceneID,-0x49AA # 0x80260404
.set  CSS_WindowGObjs,0x803eeffc
.set  CSS_MinorSceneData,-0x49F0 # 0x802655A0
.set  SSS_IconData,0x803ee840
.set  SSS_Unk1,-0x4A00 # 0x80259724
.set  SSS_Unk2,-0x49F2 # 0x80259730
.set  SSS_HighlightedStage,-0x49F2 # 0x80259730
.set  SSS_MnSlMap,-0x4A0C # DONE
.set  Match_StaticMatchData,0x804696d8
.set  Match_EndStruct,0x80477ddc
.set  PreloadTable,0x804300bc #add 0x4 to r3
.set  DeflickerStruct,0x80469128
.set  ProgressiveStruct,0x80469128
.set  OFST_CommonCObj,-0x4884 #0x80300EE8
.set  MemcardFileList,0x804313c0 #use func 8001e238 to find it #*
.set  SnapshotData,0x803b8e08 #use func 8001df4c to find it #*
.set  SnapshotLoadThinkStruct,0x8049e8d8 #804a0b6c, use func 8025389c to find it #*

.set  MainSaveUnk,0x804240b8 # r30 at 8001d24c (102)
.set  MainSaveData,0x803bb0b4 # r25 at 8001ccb0 (102)
.set  MainSaveString,0x803bb244 # r4 at 8001a564 (102)
.set  OFST_Rand,-0x5714
