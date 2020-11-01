#Constants
.set  PersonalEffectStart,5000  # used for stage effects, need to rework this?
.set  EffMdlStart,5000
.set  PtclGenStart,6000
.set  CpEffMdlStart,7000
.set  CpPtclGenStart,8000
.set  MEXEffectEnd,9000

.set  CustomItemStart,237
.set  RandomIconID,30
.set  HUD_Stride,3   #im changing this from 3 because 2 seems to work with hsdraw
.set  OFST_mexMapData,--0x4A08
.set  OFST_mexSelectChr,-0x4A0C

#Derived Constants
.set  SSM_MaxID,100 * 10000

#Custom Functions
.set Audio_RequestSSMLoad,0x803d705C
.set  GetGrFunction,0x803d7068
.set itFunctionInit,0x803d7070
.set Reloc,0x803d7074
.set  SFX_PlayStageSFX,0x803d7078
.set  GetStockFrame,0x803d7060
.set  MenuThink,0x803d7090

#Custom Static Variables
.set  PersistHeapNum, 5 + 2

#mexSelectChr Offsets
.set  OFST_mexSelectChr,-0x472C
.set  OFST_mexSelectChr_IconJoint,-0x4728 #originally SceneLoad_Adventure mode static pointers (8031dea0)
.set  OFST_stc_icons,-0x4724            # TODO: THIS WILL BREAK STUFF, FIND A BETTER SPOT
.set  OFST_eblm_matanimjoint,-0x4720    # TODO: THIS WILL BREAK STUFF, FIND A BETTER SPOT 
.set  OFST_mexMenu,-0x4720 
.set  SlChr_IconModel,0x0
.set  SlChr_IconAnimJoint,0x4
.set  SlChr_IconMatAnim,0x8
.set  SlChr_CSPMatAnim,0xC
.set  SlChr_CSPStride,0x10

#mexMenu Offsets
.set  mexMenu_MenuNameFrames,0x0
.set  mexMenu_MenuDef,0x4
  .set  MenuDefStride,0x14
  .set  MenuDef_PreviewFrames, 0x0
  .set  MenuDef_Unused, 0x4
  .set  MenuDef_OptDef, 0x8
    .set  OptDefStride,8
    .set  OptDef_Kind, 0x0      # byte
    .set  OptDef_ID, 0x1        # byte
    .set  OptDef_Text,0x2       # byte
    .set  OptDef_NameFrame,0x3  # byte
    .set  OptDef_PreviewFrame,0x4  # byte
  .set  MenuDef_OptNum, 0xC # byte
  .set  MenuDef_PrevMenu, 0xD # byte
  .set  MenuDef_NameFrame, 0xE  # byte
  .set  MenuDef_HueIndex, 0xF  # byte
  .set  MenuDef_Callback, 0x10
.set  mexMenu_DescSis,0x8
  .set  OptDef_TextSisID, 1
.set  mexMenu_MnOptMatAnimJoint,0xC
.set  mexMenu_MnNameMatAnimJoint,0x10

#Stc_icon Offsets
.set  StcIcons_ReservedFrames,0x0
.set  StcIcons_Stride,0x2
.set  StcIcons_MatAnimJoint,0x4
.set  StcIcons_EggNum,0x8
.set  StcIcons_Eggs,0xC

#Eggs
.set Eggs_Stride, 0x8
.set Eggs_StockID,0x0
.set Eggs_Input,0x1
.set Eggs_Name,0x4

#BGM in IfAll
.set BGMBG_Joint,0x0
.set BMGBG_AnimJoint,0x4

#effBehaviorTable
.set effBhv_ptclGenNum,0x8
.set effBhv_ptclGenBhv,0xC
  .set effMdlBhv_Stride,0x1
.set effBhv_effMdlNum,0x0
.set effBhv_effMdlBhv,0x4
  .set effMdlBhv_Stride,0x1

#Scene Data
.set  MajorStride,0x18
.set  MinorTypeStride,0x14

#Archive Offsets
.set  Arch_Metadata,0x0
  .set  Arch_Metadata_VersionMajor,0x0
  .set  Arch_Metadata_VersionMinor,0x1
  .set  Arch_Metadata_FtIntNum,0x4
  .set  Arch_Metadata_FtExtNum,0x8
  .set  Arch_Metadata_CSSIconCount,0xC
  .set  Arch_Metadata_GrIntNum,0x10
  .set  Arch_Metadata_GrExtNum,0x14
  .set  Arch_Metadata_SSSIconCount,0x18
  .set  Arch_Metadata_SSMCount,0x1C
  .set  Arch_Metadata_BGMCount,0x20
  .set  Arch_Metadata_EffectCount,0x24
  .set  Arch_Metadata_BootScene,0x28
  .set  Arch_Metadata_TermMajor,0x2C
  .set  Arch_Metadata_TermMinor,0x30
.set  Arch_Menu,0x4
  .set  Arch_Menu_MenuParam,0x0
    .set  MenuParam_HandScale,0x0
  .set  Arch_Menu_CSS,0x4
  .set  Arch_Menu_SSS,0x8
    .set  SSS_Stride,0x20
.set  Arch_Fighter,0x8
  .set  Arch_Fighter_NameText,0x0
  .set  Arch_Fighter_CharFiles,0x4
  .set  Arch_Fighter_InsigniaIDs,0x8
  .set  Arch_Fighter_DefineIDs,0xC
  .set  Arch_Fighter_CostumeIDs,0x10
  .set  Arch_Fighter_CostumeFileSymbols,0x14
  .set  Arch_Fighter_FtDemo_SymbolNames,0x18
  .set  Arch_Fighter_AnimFiles,0x1C
  .set  Arch_Fighter_AnimCounts,0x20
  .set  Arch_Fighter_EffectFileIDs,0x24
  .set  Arch_Fighter_GmRst_AnimFiles,0x28
  .set  Arch_Fighter_GmRst_Scale,0x2C
  .set  Arch_Fighter_GmRst_VictoryTheme,0x30
  .set  Arch_Fighter_AnnouncerCall,0x34
  .set  Arch_Fighter_SSMFileIDs,0x38
  .set  Arch_Fighter_RuntimeCostumePointers,0x3C
  .set  Arch_Fighter_ftDataPointers,0x40
    .set  ftDataPointers_Stride,8
  .set  Arch_Fighter_onWallJump,0x44
  .set  Arch_Fighter_GmRstPointers,0x48
    .set  GmRstPointers_Stride,8
  .set  Arch_Fighter_MEXItemLookup,0x4C
    .set  MEXItemLookup_Stride,8
  .set  Arch_Fighter_TargetStage, 0x50
  .set  Arch_Fighter_BGM, 0x54
    .set BGM_Stride, 0x4
  .set  Arch_Fighter_ViWaitFileNames, 0x58
  .set  Arch_Fighter_EndClassic, 0x5C
  .set  Arch_Fighter_EndAdventure, 0x60
  .set  Arch_Fighter_EndAllStar, 0x64
  .set  Arch_Fighter_EndMovie, 0x68
  .set  Arch_Fighter_RaceTimes, 0x6C
    .set RaceTimes_Stride,0x4
.set  Arch_FighterFunc,0xC
  .set  Arch_FighterFunc_onLoad,0x0
  .set  Arch_FighterFunc_onDeath,0x4
  .set  Arch_FighterFunc_onUnknown,0x8
  .set  Arch_FighterFunc_MoveLogic,0xC
  .set  Arch_FighterFunc_SpecialN,0x10
  .set  Arch_FighterFunc_SpecialNAir,0x14
  .set  Arch_FighterFunc_SpecialS,0x18
  .set  Arch_FighterFunc_SpecialSAir,0x1C
  .set  Arch_FighterFunc_SpecialHi,0x20
  .set  Arch_FighterFunc_SpecialHiAir,0x24
  .set  Arch_FighterFunc_SpecialLw,0x28
  .set  Arch_FighterFunc_SpecialLwAir,0x2C
  .set  Arch_FighterFunc_onAbsorb,0x30
  .set  Arch_FighterFunc_OnItemPickup,0x34
  .set  Arch_FighterFunc_onMakeItemInvisible,0x38
  .set  Arch_FighterFunc_onMakeItemVisible,0x3C
  .set  Arch_FighterFunc_OnItemRelease,0x40
  .set  Arch_FighterFunc_OnItemPickup2,0x44
  .set  Arch_FighterFunc_onUnknownItemRelated,0x48
  .set  Arch_FighterFunc_onUnknownCharacterModelFlags1,0x4C
  .set  Arch_FighterFunc_onUnknownCharacterModelFlags2,0x50
  .set  Arch_FighterFunc_onKnockbackEnter,0x54
  .set  Arch_FighterFunc_onKnockbackExit,0x58
  .set  Arch_FighterFunc_onFrame,0x5C
  .set  Arch_FighterFunc_onActionStateChange,0x60
  .set  Arch_FighterFunc_onReapplyAttr,0x64
  .set  Arch_FighterFunc_onModelRender,0x68
  .set  Arch_FighterFunc_onShadowRender,0x6C
  .set  Arch_FighterFunc_onUnknownMultijump,0x70
  .set  Arch_FighterFunc_onActionStateChangeWhileEyeTextureIsChanged,0x74
  .set  Arch_FighterFunc_onTwoEntryTable,0x78
  .set  Arch_FighterFunc_onFloat,0x7C
  .set  Arch_FighterFunc_onDoubleJump,0x80
  .set  Arch_FighterFunc_onZair,0x84
  .set  Arch_FighterFunc_onLanding,0x88
  .set  Arch_FighterFunc_onFSmash,0x8C
  .set  Arch_FighterFunc_onUSmash,0x90
  .set  Arch_FighterFunc_onDSmash,0x94
  .set  Arch_FighterFunc_onGetExtResultAnim,0x98
  .set  Arch_FighterFunc_onIndexExtResultAnim,0x9C
  .set  Arch_FighterFunc_MoveLogicDemo,0xA0
.set  Arch_FGM,0x10
  .set  Arch_FGM_Files,0x0
  .set  Arch_FGM_Flags,0x4
  .set  Arch_FGM_LookupTable,0x8
  .set  Arch_FGM_RuntimeStruct,0xC
    .set  Arch_SSMRuntimeStruct_Header,0x0
    .set  Arch_SSMRuntimeStruct_ToLoadOrig,0x4
    .set  Arch_SSMRuntimeStruct_ToLoadCopy,0x8
    .set  Arch_SSMRuntimeStruct_IsLoadedOrig,0xC
    .set  Arch_SSMRuntimeStruct_IsLoadedCopy,0x10
    .set  Arch_SSMRuntimeStruct_Footer,0x14
.set  Arch_BGM,0x14
  .set  Arch_BGM_Files,0x0
  .set  Arch_BGM_MenuPlaylist,0x4
  .set  Arch_BGM_MenuPlaylistNum,0x8
  .set  Arch_BGM_Labels,0xC
.set  Arch_Effect,0x18
  .set  Effect_Files,0x0
  .set  Effect_RuntimeUnk1,0x4
  .set  Effect_RuntimeUnk3,0x8
  .set  Effect_RuntimeTexGrNum,0xC
  .set  Effect_RuntimeTexGrData,0x10
  .set  Effect_RuntimeUnk4,0x14
  .set  Effect_RuntimePtclLast,0x18
  .set  Effect_RuntimePtclData,0x1C
  .set  Effect_effBehaviorTable,0x20    #indexed by fighter ID, points to their effBehaviorTable symbol
.set  Arch_ItemsAdded,0x1C
  .set  Arch_ItemsAdded_Common,0x0
  .set  Arch_ItemsAdded_Fighter,0x4
  .set  Arch_ItemsAdded_Pokemon,0x8
  .set  Arch_ItemsAdded_Stages,0xC
  .set  Arch_ItemsAdded_Custom,0x10
  #.set  Arch_ItemsAdded_Unk,0x14
  .set  Arch_ItemsAdded_RuntimeIndex,0x14
.set  Arch_Kirby,0x20
  .set  Arch_Kirby_AbilityFileNames,0x0
  .set  Arch_Kirby_AbilityRuntimeStruct,0x4
  .set  Arch_Kirby_AbilityCostumeFileNames,0x8
  .set  Arch_Kirby_AbilityCostumeRuntimeStruct,0xC
  .set  Arch_Kirby_EffectIDs,0x10
  .set  Arch_Kirby_FtCmdRuntime,0x14
.set  Arch_KirbyFunction,0x24
  .set  Arch_KirbyFunction_OnAbilityGain,0x0
  .set  Arch_KirbyFunction_OnAbilityLose,0x4
  .set  Arch_Kirby_SpecialN,0x8
  .set  Arch_Kirby_SpecialNAir,0xC
  .set  Arch_Kirby_OnHit,0x10
  .set  Arch_Kirby_InitItem,0x14
  .set  Arch_Kirby_MoveLogicRuntime,0x18
.set  Arch_Map,0x28
  .set  Arch_Map_StageIDs,0x0
  .set  Arch_Map_Audio,0x4
  .set  Arch_Map_LineTypeData,0x8
  .set  Arch_Map_StageItemLookup,0xC
    .set  StageItemLookup_Stride,0x8
  .set  Arch_Map_StageEffectLookup,0x10
  .set  Arch_Map_Playlists,0x14
    .set  Playlists_Stride,0x8
.set  Arch_grFunction,0x2C
.set  Arch_Scene,0x30
  .set  Scene_Major,0x0
  .set  Scene_Minor,0x4

#Offsets
.set  OFST_MnSlChrIconData,0x0
.set  OFST_MnSlChrNames,0x4
.set  OFST_MnSlChrDefineIDs,0x8
.set  OFST_MnSlChrCostumeFileSymbols,0xC
.set  OFST_MnSlChrCharFileNames,0x10
.set  OFST_MnSlChrAnimFileNames,0x14
.set  OFST_MnSlChrEffectFileIDs,0x18
.set  OFST_MnSlChrEffectFilesSymbols,0x1C
.set  OFST_MnSlChrSSMFileIDs,0x20
.set  OFST_MnSlChrSSMFileNames,0x24
.set  OFST_MnSlChrAnimCount,0x28
.set  OFST_FighterMoveLogic,0x2C
.set  OFST_FighterOnLoad,0x30
.set  OFST_FighterOnDeath,0x34
.set  OFST_FighterSpecialLw,0x38
.set  OFST_FighterSpecialLwAir,0x3C
.set  OFST_FighterSpecialS,0x40
.set  OFST_FighterSpecialSAir,0x44
.set  OFST_FighterSpecialN,0x48
.set  OFST_FighterSpecialNAir,0x4C
.set  OFST_FighterSpecialHi,0x50
.set  OFST_FighterSpecialHiAir,0x54
.set  OFST_MnSlChrCostumeIDs,0x58
.set  OFST_Char_CostumeRuntimePointers,0x5C
.set  OFST_SSMStruct,0x60
.set  OFST_SSMIDDef,0x64
.set  OFST_SSMBankSizes,0x68
.set  OFST_GmRstAnimFileNames,0x6C
.set  OFST_GmRstInsigniaIDs,0x70
.set  OFST_GmRstScale,0x74
.set  OFST_FtDemoSymbols,0x78
.set  OFST_SFXNameDef,0x7C
.set  OFST_GmRstVictoryTheme,0x80
.set  OFST_effBehaviorTable,0x84
.set  OFST_ItemsAdded,0x88
.set  OFST_ItemIndex,0x8C #unused
.set  OFST_AudioGroups,0x90
.set  OFST_BGMFileNames,0x94
.set  OFST_ftDataPointers,0x98
.set  OFST_onFloat,0x9C
.set  OFST_onDoubleJump,0xA0
.set  OFST_onZair,0xA4
.set  OFST_onLanding,0xA8
.set  OFST_onWallJump,0xAC
.set  OFST_GmRstPointers,0xB0
.set  OFST_onFSmash,0xB4
.set  OFST_onUSmash,0xB8
.set  OFST_onDSmash,0xBC
.set  OFST_FighterOnItemPickup,0xC0
.set  OFST_FighterOnItemPickup2,0xC4
.set  OFST_FighterOnItemRelease,0xC8
.set  OFST_FighterBGM, OFST_FighterOnItemRelease + 0x4
.set  OFST_FighterViWaitFileNames, OFST_FighterBGM + 0x4
.set  OFST_MajorScenes, OFST_FighterViWaitFileNames + 0x4
.set  OFST_MinorScenes, OFST_MajorScenes + 0x4
.set  OFST_PtclRuntime1, OFST_MinorScenes + 0x4
.set  OFST_PtclRuntime3, OFST_PtclRuntime1 + 0x4
.set  OFST_PtclRuntimeTexGrNum, OFST_PtclRuntime3 + 0x4
.set  OFST_PtclRuntimeTexGrData, OFST_PtclRuntimeTexGrNum + 0x4
.set  OFST_PtclRuntime4, OFST_PtclRuntimeTexGrData + 0x4
.set  OFST_PtclRuntimePtclLast, OFST_PtclRuntime4 + 0x4
.set  OFST_PtclRuntimePtclData, OFST_PtclRuntimePtclLast + 0x4
#Chr
.set  OFST_Menu_Param,OFST_PtclRuntimePtclData+0x4
#Map
.set  OFST_Menu_SSS,OFST_Menu_Param+0x4
.set  OFST_Map_StageIDs,OFST_Menu_SSS+0x4
.set  OFST_Map_Audio,OFST_Map_StageIDs+0x4
.set  OFST_grFunction,OFST_Map_Audio+0x4
.set  OFST_LineTypeData,OFST_grFunction+0x4
#Kirby
.set  OFST_KirbyHatFileNames,OFST_LineTypeData+0x4
.set  OFST_KirbyHatCostumeFileNames,OFST_KirbyHatFileNames+0x4
.set  OFST_KirbyHatEffectFileIDs,OFST_KirbyHatCostumeFileNames+0x4
.set  OFST_KirbyAbilityCostumeRuntimeStruct,OFST_KirbyHatEffectFileIDs+0x4
.set  OFST_KirbyAbilityRuntimeStruct,OFST_KirbyAbilityCostumeRuntimeStruct+0x4
.set  OFST_KirbyFtCmdRuntime, OFST_KirbyAbilityRuntimeStruct + 0x4
.set  OFST_KirbyOnAbilityGain,OFST_KirbyFtCmdRuntime+0x4
.set  OFST_KirbyOnAbilityLose,OFST_KirbyOnAbilityGain+0x4
.set  OFST_KirbySpecialN,OFST_KirbyOnAbilityLose+0x4
.set  OFST_KirbySpecialNAir,OFST_KirbySpecialN+0x4
.set  OFST_KirbyOnHit,OFST_KirbySpecialNAir+0x4
.set  OFST_KirbyInitItem,OFST_KirbyOnHit+0x4
.set  OFST_KirbyMoveLogicRuntime, OFST_KirbyInitItem + 0x4
#Metadata
.set  OFST_Metadata_FtIntNum,OFST_KirbyMoveLogicRuntime+0x4
.set  OFST_Metadata_FtExtNum,OFST_Metadata_FtIntNum+0x4
.set  OFST_Metadata_CSSIconCount,OFST_Metadata_FtExtNum+0x4
.set  OFST_Metadata_SSSIconCount,OFST_Metadata_CSSIconCount+0x4
.set  OFST_Metadata_SSMCount,OFST_Metadata_SSSIconCount+0x4
.set  OFST_Metadata_BGMCount,OFST_Metadata_SSMCount+0x4
.set  OFST_Metadata_EffectCount,OFST_Metadata_BGMCount+0x4
.set  OFST_MetaData_TermMajor,OFST_Metadata_EffectCount + 0x4
.set  OFST_MetaData_TermMinor,OFST_MetaData_TermMajor + 0x4
.set  OFST_MetaData_GrIntNum,OFST_MetaData_TermMinor+0x4
.set  OFST_MetaData_GrExtNum,OFST_MetaData_GrIntNum+0x4
.set  OFST_Metadata,OFST_MetaData_GrExtNum+0x4
.set  OFST_mexData,OFST_Metadata+0x4

#Gross bullshit I don't want here
.set  OFST_EasterEgg,OFST_mexData + 0x4
.set  OFST_HeapRuntime,OFST_EasterEgg + 0x8


# Fighter Data Sizes
.set  FighterDataOrigSize, 0x23ec
.set  MEX_FighterDataSize, 0xC       # mex needs additional 0x4 bytes
.set  TM_FighterDataSize, 0x34       # TM needs additional 0x34 bytes
.set  FighterDataTotalSize, FighterDataOrigSize + MEX_FighterDataSize + TM_FighterDataSize

# Fighter Data Start
.set FighterDataStart, 0x0
.set MEX_FighterDataStart, FighterDataStart + FighterDataOrigSize
.set TM_FighterDataStart, MEX_FighterDataStart + MEX_FighterDataSize

# Fighter Data Vairables

#MEX
.set  MEX_AnimOwner,MEX_FighterDataStart + 0x0  #4 bytes
.set  MEX_UCFCurrX, MEX_AnimOwner + 0x4   #1 byte
.set  MEX_UCFPrevX, MEX_UCFCurrX + 0x1   #1 byte
.set  MEX_UCF2fX, MEX_UCFPrevX + 0x1   #1 byte
.set  MEX_align, MEX_UCF2fX + 0x1   #1 byte

#TM
## Dedicated ##
.set TM_FramesinCurrentAS, TM_FighterDataStart + 0x0    #half
.set TM_ShieldFrames, TM_FramesinCurrentAS + 0x2    #half
.set TM_PrevASSlots, 6
.set TM_PrevASStart, TM_ShieldFrames + 0x2       #halves
  .set CurrentAS,0x10
  .set TM_OneASAgo,TM_PrevASStart+0x0
  .set TM_TwoASAgo,TM_OneASAgo+0x2
  .set TM_ThreeASAgo,TM_TwoASAgo+0x2
  .set TM_FourASAgo,TM_ThreeASAgo+0x2
  .set TM_FiveASAgo,TM_FourASAgo+0x2
  .set TM_SixASAgo,TM_FiveASAgo+0x2
.set TM_FramesInPrevASStart,TM_SixASAgo + 0x2    #halves
  .set TM_FramesinOneASAgo,TM_FramesInPrevASStart+0x0
  .set TM_FramesinTwoASAgo,TM_FramesinOneASAgo+0x2
  .set TM_FramesinThreeASAgo,TM_FramesinTwoASAgo+0x2
  .set TM_FramesinFourASAgo,TM_FramesinThreeASAgo+0x2
  .set TM_FramesinFiveASAgo,TM_FramesinFourASAgo+0x2
  .set TM_FramesinSixASAgo,TM_FramesinFiveASAgo+0x2
.set TM_PreviousMoveInstanceHitBy,TM_FramesinSixASAgo + 0x2  #half
.set TM_TangibleFrameCount, TM_PreviousMoveInstanceHitBy + 0x2        #half
.set TM_CanFastfallFrameCount, TM_TangibleFrameCount + 0x2        #half
.set TM_align, TM_CanFastfallFrameCount + 0x2        #half
.set TM_PostHitstunFrameCount, TM_align + 0x2     #word
.set TM_PlayerWhoShieldedAttack, TM_PostHitstunFrameCount + 0x4   #word
.set  TM_AnimCallback, TM_PlayerWhoShieldedAttack + 0x4
## Volatile ##
.set  TM_VolatileStart, TM_AnimCallback + 0x4
#Airdodge
  .set TM_AirdodgeAngle,TM_VolatileStart + 0x0
#Damage
  .set TM_SuccessfulSDIInputs,TM_VolatileStart + 0x0
  .set TM_TotalSDIInputs,TM_SuccessfulSDIInputs + 0x2

/*
#SSM Struct Offsets
#Header
.set  SSM_Header_OFST,0x0
  .set  SSM_Header_Length,45*4
#Disposable Orig
.set  SSM_ToLoadOrig_OFST, SSM_Header_OFST + SSM_Header_Length
  .set  SSM_ToLoadOrig_Length, (56 + NumOfAddedChars) * 4
#Disposable Copy
.set  SSM_ToLoadCopy_OFST, SSM_ToLoadOrig_OFST + SSM_ToLoadOrig_Length
  .set  SSM_ToLoadCopy_Length, (56 + NumOfAddedChars) * 4
#Persist Orig
.set  SSM_IsLoadedOrig_OFST, SSM_ToLoadCopy_OFST + SSM_ToLoadCopy_Length
  .set  SSM_IsLoadedOrig_Length, (56 + NumOfAddedChars) * 4
#Persist Copy
.set  SSM_IsLoadedCopy_OFST, SSM_IsLoadedOrig_OFST + SSM_IsLoadedOrig_Length
  .set  SSM_IsLoadedCopy_Length, (56 + NumOfAddedChars) * 4
#Unk
.set  SSM_Footer_OFST, SSM_IsLoadedCopy_OFST + SSM_IsLoadedCopy_Length
  .set  SSM_Footer_Length, (56 + NumOfAddedChars) * 4
*/
