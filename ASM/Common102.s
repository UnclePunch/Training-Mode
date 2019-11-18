.set isPAL,0
.set HeapHijack_Injection,0x80015994

#####################
## Melee Variables ##
#####################
#Static Memory Locations
.set PersistentHeapStruct,0x80431fa0

.set Heap_MainID,-0x58A0
.set Heap_CurrentHeap,-0x5A98
.set Heap_Lo,-0x3FE8
.set Heap_Hi,-0x3FE4
.set PersistentHeapStruct,0x80431fa0


.set OSDestroyHeap,0x80344154
.set OSCreateHeap,0x803440e8
.set OSAllocFromHeap,0x80343ef0

.set isPAL,0
.set is100,0

.set ExpoitReturnAddr,0x80239E9C

#Funtions
.set Text_CreateTextCanvas,0x803a611c
.set Text_CreateTextStruct,0x803a6754
.set Text_InitializeSubtext,0x803a6b98
.set Text_UpdateSubtextSize,0x803a7548
.set Text_RemoveText,0x803a5cc4
.set GObj_Create,0x803901f0
.set HSD_MemAlloc,0x8037f1e4
.set HSD_Free,0x8037f1b0
.set HSD_Randi,0x80380580
.set ZeroAreaLength,0x8000c160
.set strlen,0x80325b04
.set strcpy,0x80325a50
.set memset,0x80003100
.set memcpy,0x800031f4
.set GObj_AddUserData,0x80390b68
.set GObj_AddProc,0x8038fd54
.set Text_ChangeTextColor,0x803a74f0
.set Text_UpdateSubtextContents,0x803a70a0
.set Inputs_GetPlayerRapidHeldInputs,0x801a36c0
.set Inputs_GetPlayerInstantInputs,0x801a36a0
.set Inputs_GetPlayerHeldInputs,0x801a3680
.set SFX_PlayMenuSound_CloseOpenPort,0x80174380
.set SFX_PlayMenuSound_Forward,0x80174338
.set HSD_VISetUserPostRetraceCallback,0x80375934
.set TRK_flush_cache,0x80328f50
.set MenuController_ChangeScreenMinor,0x801a4b60
.set Scene_GetMajorSceneStruct,0x801a50ac
.set Scene_MinorIDToMinorSceneFunctionTable,0x801a4ce0
.set MenuController_WriteToPendingMajor,0x801a42e8
.set MenuController_ChangeScreenMajor,0x801a42d4
.set Text_AllocateTextObject,0x803a5acc
.set MemoryCard_LoadBannerIconImagesToRAM,0x8001d164
.set Deflicker_Toggle,0x8015F500
.set MemoryCard_WaitForFileToFinishSaving,0x8001b6f8
.set SFX_PlaySFXAtFullVolume,0x801C53EC
.set SFX_MenuCommonSound,0x80024030
.set ScreenDisplay_Adjust,0x8015F588
.set Text_CopyPremadeTextDataToStruct,0x803a6368
.set Snapshot_UpdateFileList,0x80253e90
.set Memcard_FreeSomething,0x8001C5A4
.set Memcard_AllocateSomething,0x8001c550
.set MemoryCard_ReadDataIntoMemory,0x8001bf04
.set Scene_GetMinorSceneData2,0x801a4b9c
.set MemoryCard_LoadData,0x8001bd34
.set OSReport,0x803456a8
.set SpawnPoint_GetXYZFromInputID,0x80224e64

#r13 offsets
.set  OFST_Memcard,-0x77C0 #find it @ 8015ed3c in 102
.set  OFST_PlCo,-0x514C # 0x800679CC
.set  OFST_ExtStageID,-0x6CB8 # 0x80223EEC
.set  CSS_SubSceneID,-0x49AA # 0x80260404
.set  CSS_MinorSceneData,-0x49F0 # 0x802655A0

#Mem Addresses
.set  OFST_ModPrefs,0x1F30
.set  PostRetraceCallback,0x800195fc #*
.set  UnkPadStruct,0x804329f0 #80019A48
.set  OFST_MemcardController,0x80431358 #r31 at 0x8001D244
.set  ExploitReturn,0x80239E9C #*
.set  OFST_NametagStart,0x3000
.set  OFST_Rand,-0x570C
.set  Nametag_Length,0xd894
.set  DeflickerStruct,0x8046b0f0 #r31 @ 0x8015FCF4
.set  ProgressiveStruct,0x8046b0f0 #r31 @ 0x8015FCF4
.set  VI_Struct,0x804c1d80
.set  RenewInputs_Prefunction,0x800195fc

.set  MemcardFileList,0x80433380 #use func 8001e238 to find it #*
.set  SnapshotData,0x803bacc8 #use func 8001df4c to find it #*
.set  SnapshotLoadThinkStruct,0x804a0a10 #804a0b6c, use func 8025389c to find it #*
.set  MainSaveUnk,0x80433318 # r30 at 8001d24c (102)
.set  MainSaveData,0x803bab74 # r25 at 8001ccb0 (102)
.set  MainSaveString,0x803bac5c # r4 at 8001a564 (102)
