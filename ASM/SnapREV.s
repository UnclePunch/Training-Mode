#region SnapshotCodeREV
.include "../../CommonREV.s"

SnapshotCodeREVStart:
#First thing to do is relocate ALL of the exploit code to tournament mode
	bl	MMLCodeREV_End
	mflr	r3
	bl	MMLCodeREV_Start
	mflr	r4
	sub	r5,r3,r4
	load	r3,TournamentMode
	branchl	r12,memcpy

#Flush cache to ensure these instructions are up to date
  load r3,TournamentMode
	bl	MMLCodeREV_Start
	mflr	r4
	bl	MMLCodeREV_End
	mflr	r5
	sub	r4,r5,r4
  branchl r12,TRK_flush_cache

#Now run from the tournament mode code region
	branch	r12,TournamentMode

MMLCodeREV_Start:
blrl
#Overwriting the debug CSS with a lag reduction prompt
#it crashes anyway so nothing of substance is being lost

#Parameters
.set  PromptSceneID,8 #0
.set  CodesSceneID,9
.set  ExitSceneID,2
.set  PromptCommonSceneID,10
.set  CodesCommonSceneID,10
.set  InitialSelection,0
.set  MaxCodesOnscreen,10

#region Init New Scenes
.set  REG_MinorSceneStruct,31

#Init and backup
  backup
#Init LagPrompt major struct
  li  r3,PromptSceneID
  bl  SnapREV_LagPrompt_MinorSceneStruct
  mflr  r4
  bl  SnapREV_LagPrompt_SceneLoad
  mflr  r5
  bl  SnapREV_InitializeMajorSceneStruct
#Init Codes major struct
  li  r3,CodesSceneID
  bl  SnapREV_Codes_MinorSceneStruct
  mflr  r4
  bl  SnapREV_Codes_SceneLoad
  mflr  r5
  bl  SnapREV_InitializeMajorSceneStruct

#Check if key has been generated yet
	lwz	r20,OFST_Memcard(r13)
	lwz	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
	cmpwi	r3,0
	bne	SnapREV_GenerateKeyEnd
#Generate Key
	lwz	r3, OFST_Rand (r13)
	lwz	r3,0x0(r3)
	stw	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
SnapREV_GenerateKeyEnd:
  b SnapREV_CheckProgressive

#region SnapREV_PointerConvert
SnapREV_PointerConvert:
  lwz r4,0x0(r3)          #Load bl instruction
  rlwinm r5,r4,8,25,29    #extract opcode bits
  cmpwi r5,0x48           #if not a bl instruction, exit
  bne SnapREV_PointerConvert_Exit
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
  add r4,r4,r3
  stw r4,0x0(r3)
SnapREV_PointerConvert_Exit:
  blr
#endregion
#region SnapREV_InitializeMajorSceneStruct
SnapREV_InitializeMajorSceneStruct:
.set  REG_MajorScene,31
.set  REG_MinorStruct,30
.set  REG_SceneLoad,29

#Init
  backup
  mr  REG_MajorScene,r3
  mr  REG_MinorStruct,r4
  mr  REG_SceneLoad,r5

#Get major scene struct
  branchl r12,Scene_GetMajorSceneStruct
SnapREV_GetMajorStruct_Loop:
  lbz	r4, 0x0001 (r3)
  cmpw r4,REG_MajorScene
  beq SnapREV_GetMajorStruct_Exit
  addi  r3,r3,20
  b SnapREV_GetMajorStruct_Loop
SnapREV_GetMajorStruct_Exit:

SnapREV_InitMinorSceneStruct:
.set  REG_MinorStructParse,20
  stw REG_MinorStruct,0x10(r3)
  mr  REG_MinorStructParse,REG_MinorStruct
SnapREV_InitMinorSceneStruct_Loop:
#Check if valid entry
  lbz r3,0x0(REG_MinorStructParse)
  extsb r3,r3
  cmpwi r3,-1
  beq SnapREV_InitMinorSceneStruct_Exit
#Convert Pointers
  addi  r3,REG_MinorStructParse,0x4
  bl  SnapREV_PointerConvert
  addi  r3,REG_MinorStructParse,0x8
  bl  SnapREV_PointerConvert
  addi  REG_MinorStructParse,REG_MinorStructParse,0x18
  b SnapREV_InitMinorSceneStruct_Loop
SnapREV_InitMinorSceneStruct_Exit:

  restore
  blr
#endregion
#endregion

#region Codes

#region SnapREV_Codes_SceneLoad
############################################

#region SnapREV_Codes_SceneLoad_Data
SnapREV_Codes_SceneLoad_TextProperties:
blrl
.set TitleX,0x0
.set TitleY,0x4
.set CanvasScaling,0x8
.set TitleScale,0xC
.set CodesX,0x10
.set CodesInitialY,0x14
.set CodesYDiff,0x18
.set CodesScale,0x1C
.set OptionsX,0x20
.set HighlightColor,0x24
.set NonHighlightColor,0x28
.set ModNameX,0x2C
.set ModNameY,0x30
.set ModnameScale,0x34
.set DescriptionX,0x38
.set DescriptionY,0x3C
.set DescriptionZ,0x40
.set DescriptionMaxX,0x44
.set DescriptionUnk,0x48
.float 30     			   #Title X pos
.float 30  					   #Title Y pos
.float 1   				     #Canvas Scaling
.float 1.2					    	#Text scale
.float 320              #CodesX
.float 85              #CodesInitialY
.float 28              #CodesYDiff
.float 0.7             #CodesScale
.float 335              #OptionsX
.byte 251,199,57,255		#highlighted color
.byte 170,170,170,255	  #nonhighlighted color
.float	600							#ModName X
.float	30							#ModName Y
.float	0.5							#ModName Scale
.float	30							#Desc X
.float	390							#Desc Y
.float	0.1								#Desc Z
.float	560							#Desc Max X
.float	0.1								#Desc Unk

.set CodeAmount,10
#region Code Names Order
SnapREV_CodeNames_Order:
blrl
bl  SnapREV_CodeNames_UCF
bl  SnapREV_CodeNames_Frozen
bl  SnapREV_CodeNames_Spawns
bl  SnapREV_CodeNames_Wobbling
bl  SnapREV_CodeNames_Ledgegrab
bl	SnapREV_CodeNames_TournamentQoL
bl	SnapREV_CodeNames_FriendliesQoL
bl	SnapREV_CodeNames_GameVersion
bl	SnapREV_CodeNames_StageExpansion
bl	SnapREV_CodeNames_Widescreen
.align 2
#endregion
#region Code Names
SnapREV_CodeNames_Title:
blrl
.string "Select Codes:"
.align 2
SnapREV_CodeNames_ModName:
blrl
.string "MultiMod Launcher v0.6"
.align 2
SnapREV_CodeNames_UCF:
.string "UCF:"
.align 2
SnapREV_CodeNames_Frozen:
.string "Frozen Stages:"
.align 2
SnapREV_CodeNames_Spawns:
.string "Neutral Spawns:"
.align 2
SnapREV_CodeNames_Wobbling:
.string "Disable Wobbling:"
.align 2
SnapREV_CodeNames_Ledgegrab:
.string "Ledgegrab Limit:"
.align 2
SnapREV_CodeNames_TournamentQoL:
.string "Tournament QoL:"
.align 2
SnapREV_CodeNames_FriendliesQoL:
.string "Friendlies QoL:"
.align 2
SnapREV_CodeNames_GameVersion:
.string "Game Version:"
.align 2
SnapREV_CodeNames_StageExpansion:
.string "Stage Expansion:"
.align 2
SnapREV_CodeNames_Widescreen:
.string "Widescreen:"
.align 2
#endregion
#region Code Options Order
SnapREV_CodeOptions_Order:
blrl
bl  SnapREV_CodeOptions_UCF
bl  SnapREV_CodeOptions_Frozen
bl  SnapREV_CodeOptions_Spawns
bl  SnapREV_CodeOptions_Wobbling
bl  SnapREV_CodeOptions_Ledgegrab
bl	SnapREV_CodeOptions_TournamentQoL
bl  SnapREV_CodeOptions_FriendliesQoL
bl	SnapREV_CodeOptions_GameVersion
bl	SnapREV_CodeOptions_StageExpansion
bl  SnapREV_CodeOptions_Widescreen
.align 2
#endregion
#region Code Options
.set  SnapREV_CodeOptions_OptionCount,0x0
.set	SnapREV_CodeOptions_CodeDescription,0x4
.set  SnapREV_CodeOptions_GeckoCodePointers,0x8
SnapREV_CodeOptions_Wrapper:
	blrl
	.ascii "(%s)"
	.byte 0
	.align 2
SnapREV_CodeOptions_UCF:
	.long 3 -1           #number of options
	bl	SnapREV_UCF_Description
	bl  SnapREV_UCF_Off
	bl  SnapREV_UCF_On
	bl  SnapREV_UCF_Stealth
	.string "Off"
	.string "On"
	.string "Stealth"
	.align 2
SnapREV_CodeOptions_Frozen:
	.long 3 -1           #number of options
	bl	SnapREV_Frozen_Description
	bl  SnapREV_Frozen_Off
	bl  SnapREV_Frozen_Stadium
	bl  SnapREV_Frozen_All
	.string "Off"
	.string "Stadium Only"
	.string "All"
	.align 2
SnapREV_CodeOptions_Spawns:
	.long 2 -1           #number of options
	bl	SnapREV_Spawns_Description
	bl  SnapREV_Spawns_Off
	bl  SnapREV_Spawns_On
	.string "Off"
	.string "On"
	.align 2
SnapREV_CodeOptions_Wobbling:
	.long 2 -1           #number of options
	bl	SnapREV_DisableWobbling_Description
	bl  SnapREV_DisableWobbling_Off
	bl  SnapREV_DisableWobbling_On
	.string "Off"
	.string "On"
	.align 2
SnapREV_CodeOptions_Ledgegrab:
	.long 2 -1           #number of options
	bl	SnapREV_Ledgegrab_Description
	bl  SnapREV_Ledgegrab_Off
	bl  SnapREV_Ledgegrab_On
	.string "Off"
	.string "On"
	.align 2
SnapREV_CodeOptions_TournamentQoL:
	.long 2 -1           #number of options
	bl	SnapREV_TournamentQoL_Description
	bl  SnapREV_TournamentQoL_Off
	bl  SnapREV_TournamentQoL_On
	.string "Off"
	.string "On"
	.align 2
SnapREV_CodeOptions_FriendliesQoL:
	.long 2 -1           #number of options
	bl	SnapREV_FriendliesQoL_Description
	bl  SnapREV_FriendliesQoL_Off
	bl  SnapREV_FriendliesQoL_On
	.string "Off"
	.string "On"
	.align 2
SnapREV_CodeOptions_GameVersion:
	.long 3 -1           #number of options
	bl	SnapREV_GameVersion_Description
	bl  SnapREV_GameVersion_NTSC
	bl  SnapREV_GameVersion_REV
	bl  SnapREV_GameVersion_SDR
	.string "NTSC"
	.string "REV"
	.string "SD Remix"
	.align 2
SnapREV_CodeOptions_StageExpansion:
	.long 2 -1           #number of options
	bl	SnapREV_StageExpansion_Description
	bl  SnapREV_StageExpansion_Off
	bl  SnapREV_StageExpansion_On
	.string "Off"
	.string "On"
	.align 2
SnapREV_CodeOptions_Widescreen:
	.long 3 -1           #number of options
	bl	SnapREV_Widescreen_Description
	bl  SnapREV_Widescreen_Off
	bl  SnapREV_Widescreen_Standard
	bl	SnapREV_Widescreen_True
	.string "Off"
	.string "Standard"
	.string "True"
	.align 2
#endregion
#region Gecko Codes
SnapREV_DefaultCodes:
  blrl
	.long -1

SnapREV_UCF_Off:
	.long -1
SnapREV_UCF_On:
	.long -1
SnapREV_UCF_Stealth:
	.long -1

SnapREV_Frozen_Off:
	.long -1
SnapREV_Frozen_Stadium:
	.long -1
SnapREV_Frozen_All:
	.long -1

SnapREV_Spawns_Off:
	.long -1
SnapREV_Spawns_On:
	.long -1

SnapREV_DisableWobbling_Off:
	.long -1
SnapREV_DisableWobbling_On:
	.long -1

SnapREV_Ledgegrab_Off:
	.long -1
SnapREV_Ledgegrab_On:
	.long -1

SnapREV_TournamentQoL_Off:
	.long -1
SnapREV_TournamentQoL_On:
	.long -1

SnapREV_FriendliesQoL_Off:
	.long -1
SnapREV_FriendliesQoL_On:
	.long -1

SnapREV_GameVersion_NTSC:
	.long -1
SnapREV_GameVersion_REV:
	.long -1
SnapREV_GameVersion_SDR:
	.long -1

SnapREV_StageExpansion_Off:
	.long -1
SnapREV_StageExpansion_On:
	.long -1

SnapREV_Widescreen_Off:
	.long -1
SnapREV_Widescreen_Standard:
	.long -1
SnapREV_Widescreen_True:
	.long -1

#endregion
#region Code Descriptions
SnapREV_UCF_Description:
	.long 0x160cffff
	.long 0xff0e00ac
	.long 0x00b31220
	.long 0x0f202c20
	.long 0x3b202820
	.long 0x361a2026
	.long 0x20322031
	.long 0x20372035
	.long 0x2032202f
	.long 0x202f2028
	.long 0x20351a20
	.long 0x27202c20
	.long 0x36203320
	.long 0x24203520
	.long 0x2c203720
	.long 0x2c202820
	.long 0x361a203a
	.long 0x202c2037
	.long 0x202b1a20
	.long 0x27202420
	.long 0x36202b20
	.long 0x25202420
	.long 0x26202e1a
	.long 0x20242031
	.long 0x20271a03
	.long 0x2036202b
	.long 0x202c2028
	.long 0x202f2027
	.long 0x1a202720
	.long 0x35203220
	.long 0x3320e71a
	.long 0x200c2038
	.long 0x20352035
	.long 0x20282031
	.long 0x20371a20
	.long 0x39202820
	.long 0x35203620
	.long 0x2c203220
	.long 0x311a202c
	.long 0x20361a20
	.long 0x0020e720
	.long 0x07200420
	.long 0xe7190F0D
	.long 0x00000000
SnapREV_Frozen_Description:
	.long 0x160cffff
	.long 0xff0e00ac
	.long 0x00b31220
	.long 0x0d202c20
	.long 0x36202420
	.long 0x25202f20
	.long 0x2820361a
	.long 0x202b2024
	.long 0x203d2024
	.long 0x20352027
	.long 0x20361a20
	.long 0x3220311a
	.long 0x20372032
	.long 0x20382035
	.long 0x20312024
	.long 0x20302028
	.long 0x20312037
	.long 0x1a203620
	.long 0x37202420
	.long 0x2a202820
	.long 0x3620e719
	.long 0x0F0D0000
SnapREV_Spawns_Description:
	.long 0x160cffff
	.long 0xff0e00ac
	.long 0x00b31220
	.long 0x19202f20
	.long 0x24203c20
	.long 0x28203520
	.long 0x361a2036
	.long 0x20332024
	.long 0x203a2031
	.long 0x1a202c20
	.long 0x311a2031
	.long 0x20282038
	.long 0x20372035
	.long 0x2024202f
	.long 0x1a203320
	.long 0x32203620
	.long 0x2c203720
	.long 0x2c203220
	.long 0x3120361a
	.long 0x20352028
	.long 0x202a2024
	.long 0x20352027
	.long 0x202f2028
	.long 0x20362036
	.long 0x1a032032
	.long 0x20291a20
	.long 0x33203220
	.long 0x35203720
	.long 0xe7190F0D
	.long 0x00000000
SnapREV_DisableWobbling_Description:
	.long 0x160cffff
	.long 0xff0e0090
	.long 0x00b31220
	.long 0x0d202c20
	.long 0x36202420
	.long 0x25202f20
	.long 0x281a2012
	.long 0x20262028
	.long 0x1a200c20
	.long 0x2f202c20
	.long 0x30202520
	.long 0x28203520
	.long 0x3620f31a
	.long 0x202a2035
	.long 0x20242025
	.long 0x1a202c20
	.long 0x31202920
	.long 0x2c203120
	.long 0x2c203720
	.long 0x2820e703
	.long 0x20182033
	.long 0x20332032
	.long 0x20312028
	.long 0x20312037
	.long 0x1a202520
	.long 0x35202820
	.long 0x24202e20
	.long 0x361a2032
	.long 0x20382037
	.long 0x1a202420
	.long 0x29203720
	.long 0x2820351a
	.long 0x20252028
	.long 0x202c2031
	.long 0x202a1a20
	.long 0x2b202c20
	.long 0x371a2025
	.long 0x203c1a20
	.long 0x17202420
	.long 0x3120241a
	.long 0x20031a20
	.long 0x37202c20
	.long 0x30202820
	.long 0x3620e719
	.long 0x0F0D0000
SnapREV_Ledgegrab_Description:
	.long 0x160cffff
	.long 0xff0e00ac
	.long 0x00b31220
	.long 0x1d202c20
	.long 0x30202820
	.long 0xfc203220
	.long 0x3820371a
	.long 0x2039202c
	.long 0x20262037
	.long 0x20322035
	.long 0x202c2028
	.long 0x20361a20
	.long 0x24203520
	.long 0x281a2024
	.long 0x203a2024
	.long 0x20352027
	.long 0x20282027
	.long 0x1a203720
	.long 0x321a2037
	.long 0x202b2028
	.long 0x1a203320
	.long 0x2f202420
	.long 0x3c202820
	.long 0x351a0320
	.long 0x3a202c20
	.long 0x37202b1a
	.long 0x20382031
	.long 0x20272028
	.long 0x20351a20
	.long 0x0620001a
	.long 0x202f2028
	.long 0x2027202a
	.long 0x2028202a
	.long 0x20352024
	.long 0x20252036
	.long 0x20e7190F
	.long 0x0D000000
SnapREV_TournamentQoL_Description:
	.long 0x160cffff
	.long 0xff0e0075
	.long 0x00b31220
	.long 0x1c203720
	.long 0x24202a20
	.long 0x281a2036
	.long 0x20372035
	.long 0x202c202e
	.long 0x202c2031
	.long 0x202a20e6
	.long 0x1a202b20
	.long 0x2c202720
	.long 0x281a2031
	.long 0x20242030
	.long 0x20282037
	.long 0x2024202a
	.long 0x20361a20
	.long 0x3a202b20
	.long 0x2c202f20
	.long 0x281a202c
	.long 0x20312039
	.long 0x202c2036
	.long 0x202c2025
	.long 0x202f2028
	.long 0x1a202720
	.long 0x38203520
	.long 0x2c203120
	.long 0x2a1a2036
	.long 0x202c2031
	.long 0x202a202f
	.long 0x20282036
	.long 0x20e61a03
	.long 0x20372032
	.long 0x202a202a
	.long 0x202f2028
	.long 0x1a203520
	.long 0x38203020
	.long 0x25202f20
	.long 0x281a2029
	.long 0x20352032
	.long 0x20301a20
	.long 0x0c201c20
	.long 0x1c20e61a
	.long 0x2026202f
	.long 0x20322036
	.long 0x20281a20
	.long 0x33203220
	.long 0x3520371a
	.long 0x20322031
	.long 0x1a203820
	.long 0x31203320
	.long 0x2f203820
	.long 0x2a20e61a
	.long 0x2027202c
	.long 0x20362024
	.long 0x2025202f
	.long 0x20281a20
	.long 0x0f203220
	.long 0x0d1a202c
	.long 0x20311a20
	.long 0x27203220
	.long 0x38202520
	.long 0x2f202820
	.long 0x3620e719
	.long 0x0F0D0000
SnapREV_FriendliesQoL_Description:
	.long 0x160cffff
	.long 0xff0e0075
	.long 0x00b31220
	.long 0x1c202e20
	.long 0x2c20331a
	.long 0x20352028
	.long 0x20362038
	.long 0x202f2037
	.long 0x1a203620
	.long 0x26203520
	.long 0x28202820
	.long 0x3120e61a
	.long 0x200a20fb
	.long 0x200b1a20
	.long 0x29203220
	.long 0x351a2036
	.long 0x2024202f
	.long 0x2037203c
	.long 0x1a203520
	.long 0x38203120
	.long 0x25202420
	.long 0x26202e20
	.long 0xe61a200a
	.long 0x20fb2021
	.long 0x1a202920
	.long 0x3220351a
	.long 0x20352024
	.long 0x20312027
	.long 0x20322030
	.long 0x1a203620
	.long 0x37202420
	.long 0x2a202820
	.long 0xe603202b
	.long 0x202c202a
	.long 0x202b202f
	.long 0x202c202a
	.long 0x202b2037
	.long 0x1a203a20
	.long 0x2c203120
	.long 0x31202820
	.long 0x3520f320
	.long 0x361a2031
	.long 0x20242030
	.long 0x202820e7
	.long 0x190F0D00
	.long 0x00000000
SnapREV_GameVersion_Description:
	.long 0x160cffff
	.long 0xff0e00ac
	.long 0x00b31220
	.long 0x1d203220
	.long 0x2a202a20
	.long 0x2f20281a
	.long 0x20252028
	.long 0x2037203a
	.long 0x20282028
	.long 0x20311a20
	.long 0x30203820
	.long 0x2f203720
	.long 0x2c203320
	.long 0x2f20281a
	.long 0x202a2024
	.long 0x20302028
	.long 0x1a203920
	.long 0x28203520
	.long 0x36202c20
	.long 0x32203120
	.long 0x3620e719
	.long 0x0F0D0000
SnapREV_StageExpansion_Description:
	.long 0x160cffff
	.long 0xff0e0074
	.long 0x00b31220
	.long 0x16203220
	.long 0x27202c20
	.long 0x29203c1a
	.long 0x20252024
	.long 0x20312031
	.long 0x20282027
	.long 0x1a203620
	.long 0x37202420
	.long 0x2a202820
	.long 0x361a2037
	.long 0x20321a20
	.long 0x2520281a
	.long 0x20262032
	.long 0x20302033
	.long 0x20282037
	.long 0x202c2039
	.long 0x2028202f
	.long 0x203c1a20
	.long 0x39202c20
	.long 0x24202520
	.long 0x2f202820
	.long 0xe71a200a
	.long 0x2027202d
	.long 0x20382036
	.long 0x20372036
	.long 0x1a201320
	.long 0x38203120
	.long 0x2a202f20
	.long 0x28032013
	.long 0x20242033
	.long 0x20282036
	.long 0x20e61a20
	.long 0x19202820
	.long 0x24202620
	.long 0x2b20f320
	.long 0x361a200c
	.long 0x20242036
	.long 0x2037202f
	.long 0x202820e6
	.long 0x1a201820
	.long 0x31202820
	.long 0x37203720
	.long 0xe61a2010
	.long 0x20352028
	.long 0x20282031
	.long 0x1a201020
	.long 0x35202820
	.long 0x28203120
	.long 0x3620e61a
	.long 0x20162038
	.long 0x20372028
	.long 0x1a200c20
	.long 0x2c203720
	.long 0x3c20e61a
	.long 0x200f202f
	.long 0x20242037
	.long 0x1a202320
	.long 0x32203120
	.long 0x2803200f
	.long 0x20322038
	.long 0x20352036
	.long 0x202c2027
	.long 0x202820e6
	.long 0x1a201b20
	.long 0x24202c20
	.long 0x31202520
	.long 0x32203a1a
	.long 0x200c2035
	.long 0x2038202c
	.long 0x20362028
	.long 0x20e61a20
	.long 0x22203220
	.long 0x36202b20
	.long 0x2c20f320
	.long 0x361a2012
	.long 0x2036202f
	.long 0x20242031
	.long 0x202720e6
	.long 0x1a202420
	.long 0x3120271a
	.long 0x20162038
	.long 0x2036202b
	.long 0x20352032
	.long 0x20322030
	.long 0x1a201420
	.long 0x2c203120
	.long 0x2a202720
	.long 0x3220301a
	.long 0x200120fb
	.long 0x200220e7
	.long 0x190F0D00
SnapREV_Widescreen_Description:
	.long 0x160cffff
	.long 0xff0e0088
	.long 0x00b31220
	.long 0x0e203120
	.long 0x24202520
	.long 0x2f20281a
	.long 0x203a202c
	.long 0x20272028
	.long 0x20362026
	.long 0x20352028
	.long 0x20282031
	.long 0x20e71a20
	.long 0x19202f20
	.long 0x24203c20
	.long 0x28203520
	.long 0x361a2037
	.long 0x2024202e
	.long 0x20281a20
	.long 0x27202420
	.long 0x30202420
	.long 0x2a20281a
	.long 0x203a202b
	.long 0x20282031
	.long 0x1a203220
	.long 0x38203720
	.long 0x36202c20
	.long 0x2720281a
	.long 0x20322029
	.long 0x1a032037
	.long 0x202b2028
	.long 0x1a200420
	.long 0xe920031a
	.long 0x20352028
	.long 0x202a202c
	.long 0x20322031
	.long 0x20e71a20
	.long 0x1e203620
	.long 0x281a201c
	.long 0x20372024
	.long 0x20312027
	.long 0x20242035
	.long 0x20271a20
	.long 0x2c20291a
	.long 0x2037202b
	.long 0x202c2031
	.long 0x1a202520
	.long 0x2f202420
	.long 0x26202e1a
	.long 0x20252024
	.long 0x20352036
	.long 0x1a202420
	.long 0x3520281a
	.long 0x20332035
	.long 0x20282036
	.long 0x20282031
	.long 0x203720e7
	.long 0x03201e20
	.long 0x3620281a
	.long 0x201d2035
	.long 0x20382028
	.long 0x1a202c20
	.long 0x291a2037
	.long 0x202b2028
	.long 0x1a202c20
	.long 0x30202420
	.long 0x2a20281a
	.long 0x20322026
	.long 0x20262038
	.long 0x2033202c
	.long 0x20282036
	.long 0x1a203720
	.long 0x2b20281a
	.long 0x20282031
	.long 0x2037202c
	.long 0x20352028
	.long 0x1a203620
	.long 0x26203520
	.long 0x28202820
	.long 0x3120e719
	.long 0x0F0D0000

#endregion

#endregion
#region SnapREV_Codes_SceneLoad
SnapREV_Codes_SceneLoad:
#GObj Offsets
  .set OFST_CodeNamesTextGObj,0x0
  .set OFST_CodeOptionsTextGObj,0x4
	.set OFST_CodeDescTextGObj,0x8
  .set OFST_CursorLocation,0xC
  .set OFST_ScrollAmount,0xE
  .set OFST_OptionSelections,0x10
blrl

#Init
  backup

SnapREV_Codes_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl SnapREV_Codes_SceneLoad_TextProperties
	mflr REG_TextProp

#Create canvas
  li  r3,0
  li  r4,0
  li  r5,9
  li  r6,13
  li  r7,0
  li  r8,14
  li  r9,0
  li  r10,19
  branchl r12,Text_CreateTextCanvas

########################
## Create Text Object ##
########################

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r12,Text_CreateTextStruct
#BACKUP STRUCT POINTER
	mr REG_TextGObj,r3
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(REG_TextGObj)
#SET TEXT TO align left
	li r4,0
	stb r4,0x4A(REG_TextGObj)
#Scale Canvas Down
  lfs f1,CanvasScaling(REG_TextProp)
  stfs f1,0x24(REG_TextGObj)
  stfs f1,0x28(REG_TextGObj)

#Create Title
#Initialize Subtext
	mr 	r3,REG_TextGObj		#struct pointer
	bl SnapREV_CodeNames_Title
  mflr  r4
	lfs	f1,TitleX(REG_TextProp)
  lfs	f2,TitleY(REG_TextProp)
	branchl r12,Text_InitializeSubtext
  mr  REG_SubtextID,r3
#Change Text Scale
	mr 	r3,REG_TextGObj		#struct pointer
	mr	r4,REG_SubtextID
	lfs 	f1,TitleScale(REG_TextProp) 		#X offset of REG_TextGObj
	lfs 	f2,TitleScale(REG_TextProp)	  	#Y offset of REG_TextGObj
	branchl r12,Text_UpdateSubtextSize

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r12,Text_CreateTextStruct
#BACKUP STRUCT POINTER
	mr REG_TextGObj,r3
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(REG_TextGObj)
#SET TEXT TO align right
	li r4,2
	stb r4,0x4A(REG_TextGObj)
#Scale Canvas Down
  lfs f1,CanvasScaling(REG_TextProp)
  stfs f1,0x24(REG_TextGObj)
  stfs f1,0x28(REG_TextGObj)

#Create Modname + version
#Initialize Subtext
	mr 	r3,REG_TextGObj		#struct pointer
	bl SnapREV_CodeNames_ModName
  mflr  r4
	lfs	f1,ModNameX(REG_TextProp)
  lfs	f2,ModNameY(REG_TextProp)
	branchl r12,Text_InitializeSubtext
  mr  REG_SubtextID,r3
#Change Text Scale
	mr 	r3,REG_TextGObj		#struct pointer
	mr	r4,REG_SubtextID
	lfs 	f1,ModnameScale(REG_TextProp) 		#X offset of REG_TextGObj
	lfs 	f2,ModnameScale(REG_TextProp)	  	#Y offset of REG_TextGObj
	branchl r12,Text_UpdateSubtextSize

#Init Menu
#Create GObj
  li  r3, 13
  li  r4,14
  li  r5,0
  branchl r12, GObj_Create
  mr  REG_GObj,r3
#Allocate Space
	li	r3,64
	branchl r12,HSD_MemAlloc
	mr	REG_GObjData,r3
#Zero
	li	r4,64
	branchl r12,ZeroAreaLength
#Initialize
	mr	r6,REG_GObjData
	mr	r3,REG_GObj
	li	r4,4
	load	r5,HSD_Free
	branchl r12,GObj_AddUserData
#Add Proc
  mr  r3,REG_GObj
  bl  SnapREV_Codes_SceneThink
  mflr  r4      #Function to Run
  li  r5,0      #Priority
  branchl r12, GObj_AddProc
#Copy Saved Menu Options
	addi	r3,REG_GObjData,OFST_OptionSelections
	lwz	r4, OFST_Memcard (r13)
	addi r4,r4,OFST_ModPrefs
	li	r5,0x18
	branchl	r12,memcpy

#CREATE DESCRIPTION TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	lfs	f1,DescriptionX(REG_TextProp)
	lfs	f2,DescriptionY(REG_TextProp)
	lfs	f3,DescriptionZ(REG_TextProp)
	lfs	f4,DescriptionMaxX(REG_TextProp)
	lfs	f5,DescriptionUnk(REG_TextProp)
	branchl r12,Text_AllocateTextObject
#BACKUP STRUCT POINTER
	mr REG_TextGObj,r3
	stw	REG_TextGObj,OFST_CodeDescTextGObj(REG_GObjData)
#Init
	mr	r3,REG_TextGObj
	li	r4,0
	branchl	r12,Text_CopyPremadeTextDataToStruct
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(REG_TextGObj)
#SET TEXT TO align left
	li r4,0
	stb r4,0x4A(REG_TextGObj)
#Scale Canvas Down
  lfs f1,CanvasScaling(REG_TextProp)
  stfs f1,0x24(REG_TextGObj)
  stfs f1,0x28(REG_TextGObj)

#Create Menu
  mr  r3,REG_GObjData
  bl  SnapREV_Codes_CreateMenu

SnapREV_Codes_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region SnapREV_Codes_SceneThink
SnapREV_Codes_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  SnapREV_Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Code Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,Inputs_GetPlayerRapidHeldInputs
  mr  REG_Inputs,r3
#Check for movement up
  rlwinm. r0,REG_Inputs,0,0x10
  beq SnapREV_Codes_SceneThink_SkipUp
#Adjust cursor
  lhz r3,OFST_CursorLocation(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_CursorLocation(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge SnapREV_Codes_SceneThink_UpdateMenu
#Cursor stays at top
  li  r3,0
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll up
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge SnapREV_Codes_SceneThink_UpdateMenu
#Scroll stays at top
  li  r3,0
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b SnapREV_Codes_SceneThink_Exit
SnapREV_Codes_SceneThink_SkipUp:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x20
  beq SnapREV_Codes_SceneThink_AdjustOptionSelection
#Adjust cursor
  lhz r3,OFST_CursorLocation(REG_GObjData)
  addi  r3,r3,1
  sth r3,OFST_CursorLocation(REG_GObjData)
#Check if exceeds total amount of codes
  extsb r3,r3
  cmpwi r3,CodeAmount-1
  ble 0x10
#Cursor stays at the last code
  li  r3,CodeAmount-1
  sth r3,OFST_CursorLocation(REG_GObjData)
  b SnapREV_Codes_SceneThink_Exit
#Check if exceeds max amount of codes per page
  cmpwi r3,MaxCodesOnscreen-1
  ble SnapREV_Codes_SceneThink_UpdateMenu
#Cursor stays at bottom
  li  r3,MaxCodesOnscreen-1
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll down
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  addi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,CodeAmount-MaxCodesOnscreen
  ble SnapREV_Codes_SceneThink_UpdateMenu
#Scroll stays at bottom
  li  r3,(CodeAmount-1)-(MaxCodesOnscreen-1)
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b SnapREV_Codes_SceneThink_Exit
#endregion
#region Adjust Option Selection
SnapREV_Codes_SceneThink_AdjustOptionSelection:
.set  REG_MaxOptions,20
.set  REG_OptionValuePtr,21
#Check for movement right
  rlwinm. r0,REG_Inputs,0,0x80
  beq SnapREV_Codes_SceneThink_SkipRight
#Get amount of options for this code
  lhz r3,OFST_CursorLocation(REG_GObjData)
  lhz r4,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,r4                                #get which option this is
  bl  SnapREV_CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add r3,r3,r4                                #get bl pointer to options info
  bl  SnapREV_ConvertBlPointer
  lwz REG_MaxOptions,SnapREV_CodeOptions_OptionCount(r3)     #get amount of options for this code
#Get options value
  lhz r3,OFST_CursorLocation(REG_GObjData)
  lhz r4,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,r4                                #get which option this is
  addi  r4,REG_GObjData,OFST_OptionSelections
  add REG_OptionValuePtr,r3,r4
#Increment value
  lbz r3,0x0(REG_OptionValuePtr)
  addi  r3,r3,1
  stb r3,0x0(REG_OptionValuePtr)
  extsb r3,r3
  cmpw r3,REG_MaxOptions
  ble SnapREV_Codes_SceneThink_UpdateMenu
#Option stays maxxed out
  stb REG_MaxOptions,0x0(REG_OptionValuePtr)
  b SnapREV_Codes_SceneThink_Exit
SnapREV_Codes_SceneThink_SkipRight:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x40
  beq SnapREV_Codes_SceneThink_CheckToExit
#Get options value
  lhz r3,OFST_CursorLocation(REG_GObjData)
  lhz r4,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,r4                                #get which option this is
  addi  r4,REG_GObjData,OFST_OptionSelections
  add REG_OptionValuePtr,r3,r4
#Decrement value
  lbz r3,0x0(REG_OptionValuePtr)
  subi  r3,r3,1
  stb r3,0x0(REG_OptionValuePtr)
  extsb r3,r3
  cmpwi r3,0
  bge SnapREV_Codes_SceneThink_UpdateMenu
#Option stays at 0
  li  r3,0
  stb r3,0x0(REG_OptionValuePtr)
  b SnapREV_Codes_SceneThink_Exit
#endregion
#region Check to Exit
SnapREV_Codes_SceneThink_CheckToExit:
#Check for start input
  li  r3,4
  branchl r12,Inputs_GetPlayerInstantInputs
  rlwinm. r0,r4,0,0x1000
  beq SnapREV_Codes_SceneThink_Exit
#Apply codes
  mr  r3,REG_GObjData
  bl  SnapREV_ApplyAllGeckoCodes
#Now flush the instruction cache
  lis r3,0x8000
  load r4,0x3b722c    #might be overkill but flush the entire dol file
  branchl r12,TRK_flush_cache
#Play SFX
  branchl r12,SFX_PlayMenuSound_Forward
#Exit Scene
  branchl r12,MenuController_ChangeScreenMinor
#Save Menu Options
	lwz	r3, OFST_Memcard (r13)
	addi r3,r3,OFST_ModPrefs
	addi	r4,REG_GObjData,OFST_OptionSelections
	li	r5,0x18
	branchl	r12,memcpy
#Clear nametag region
	lwz	r3,OFST_Memcard(r13)
	addi	r3,r3,OFST_NametagStart
	li r4,0
	li r5,0
	ori r5,r5,0xda38
	branchl  r12,memset
#Request a memcard save
	branchl	r12,Memcard_AllocateSomething		#Allocate memory for something
	li	r3,0
	branchl	r12,MemoryCard_LoadBannerIconImagesToRAM	#load banner images
#Set memcard save flag
	load	r3,OFST_MemcardController
	li	r4,1
	stw	r4,0xC(r3)

  b SnapREV_Codes_SceneThink_Exit
#endregion

SnapREV_Codes_SceneThink_UpdateMenu:
#Redraw Menu
  mr  r3,REG_GObjData
  bl  SnapREV_Codes_CreateMenu
#Play SFX
  branchl r12,SFX_PlayMenuSound_CloseOpenPort
  b SnapREV_Codes_SceneThink_Exit

SnapREV_Codes_SceneThink_Exit:
  restore
  blr
#endregion
#region SnapREV_Codes_SceneDecide
SnapREV_Codes_SceneDecide:
  backup

#Change Major
  li  r3,ExitSceneID
  branchl r12,MenuController_WriteToPendingMajor
#Leave Major
  branchl r12,MenuController_ChangeScreenMajor

SnapREV_Codes_SceneDecide_Exit:
  restore
  blr
############################################
#endregion
#region SnapREV_Codes_CreateMenu
SnapREV_Codes_CreateMenu:
.set  REG_GObjData,31
.set  REG_TextGObj,30
.set  REG_TextProp,29

#Init
  backup
  mr  REG_GObjData,r3
  bl  SnapREV_Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#Remove old text gobjs if they exist
  lwz r3,OFST_CodeNamesTextGObj(REG_GObjData)
  cmpwi r3,0
  beq SnapREV_Codes_CreateMenu_SkipNameRemoval
  branchl r12,Text_RemoveText
SnapREV_Codes_CreateMenu_SkipNameRemoval:
  lwz r3,OFST_CodeOptionsTextGObj(REG_GObjData)
  cmpwi r3,0
  beq SnapREV_Codes_CreateMenu_SkipOptionRemoval
  branchl r12,Text_RemoveText
SnapREV_Codes_CreateMenu_SkipOptionRemoval:

#region CreateTextGObjs
SnapREV_Codes_CreateMenu_CreateTextGObjs:
#Create Code Mames Text GObj
	li r3,0
	li r4,0
	branchl r12,Text_CreateTextStruct
#BACKUP STRUCT POINTER
	mr REG_TextGObj,r3
  stw REG_TextGObj,OFST_CodeNamesTextGObj(REG_GObjData)
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(REG_TextGObj)
#SET TEXT TO align right
	li r4,2
	stb r4,0x4A(REG_TextGObj)
#Scale Canvas Down
  lfs f1,CanvasScaling(REG_TextProp)
  stfs f1,0x24(REG_TextGObj)
  stfs f1,0x28(REG_TextGObj)
#Create Code Options Text GObj
	li r3,0
	li r4,0
	branchl r12,Text_CreateTextStruct
#BACKUP STRUCT POINTER
	mr REG_TextGObj,r3
  stw REG_TextGObj,OFST_CodeOptionsTextGObj(REG_GObjData)
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(REG_TextGObj)
#SET TEXT TO align left
	li r4,0
	stb r4,0x4A(REG_TextGObj)
#Scale Canvas Down
  lfs f1,CanvasScaling(REG_TextProp)
  stfs f1,0x24(REG_TextGObj)
  stfs f1,0x28(REG_TextGObj)
#endregion
#region SnapREV_Codes_CreateMenu_CreateNames
SnapREV_Codes_CreateMenu_CreateNamesInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
  li  REG_Count,0
SnapREV_Codes_CreateMenu_CreateNamesLoop:
#Next name to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,REG_Count
#Get the string bl pointer
  bl  SnapREV_CodeNames_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  SnapREV_ConvertBlPointer
  mr  r4,r3
#Get Y Offset for this
  lis    r0, 0x4330
  lfd    f2, -0x6758 (rtoc)
  xoris    r3,REG_Count,0x8000
  stw    r0,0x80(sp)
  stw    r3,0x84(sp)
  lfd    f1,0x80(sp)
  fsubs    f1,f1,f2                   #REG_Count as a float
  lfs f2,CodesYDiff(REG_TextProp)     #YDifference
  fmuls f1,f1,f2
  lfs f2,CodesInitialY(REG_TextProp)  #Initial Y Value
  fadds f2,f1,f2
#Create Text
  lwz r3,OFST_CodeNamesTextGObj(REG_GObjData)
  lfs f1,CodesX(REG_TextProp)
  crset 6
  branchl r12,Text_InitializeSubtext
  mr  REG_SubtextID,r3
#Unhighlight this name
  mr  r4,REG_SubtextID
  addi  r5,REG_TextProp,NonHighlightColor
  lwz r3,OFST_CodeNamesTextGObj(REG_GObjData)
  branchl r12,Text_ChangeTextColor
#Scale this name
  lwz r3,OFST_CodeNamesTextGObj(REG_GObjData)
  mr  r4,REG_SubtextID
  lfs f1,CodesScale(REG_TextProp)
  lfs f2,CodesScale(REG_TextProp)
  branchl r12,Text_UpdateSubtextSize
SnapREV_Codes_CreateMenu_CreateNamesIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge SnapREV_Codes_CreateMenu_CreateNameLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt SnapREV_Codes_CreateMenu_CreateNamesLoop
SnapREV_Codes_CreateMenu_CreateNameLoopEnd:
#endregion
#region SnapREV_Codes_CreateMenu_CreateOptions
SnapREV_Codes_CreateMenu_CreateOptionsInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
.set  REG_CurrentOptionID,22
.set  REG_CurrentOptionSelection,23
.set  REG_OptionStrings,24
.set  REG_StringLoopCount,25
  li  REG_Count,0
SnapREV_Codes_CreateMenu_CreateOptionsLoop:
#Next option to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add REG_CurrentOptionID,r3,REG_Count
#Get the bl pointer
  mr  r3,REG_CurrentOptionID
  bl  SnapREV_CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  SnapREV_ConvertBlPointer
  lwz r4,SnapREV_CodeOptions_OptionCount(r3)
  addi  r4,r4,1
  addi  REG_OptionStrings,r3,SnapREV_CodeOptions_GeckoCodePointers  #Get pointer to gecko code pointers
  mulli r4,r4,0x4                                           #pointer length
  add REG_OptionStrings,REG_OptionStrings,r4
#Get this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx  REG_CurrentOptionSelection,r3,REG_CurrentOptionID

#Loop through strings and get the current one
  li  REG_StringLoopCount,0
SnapREV_Codes_CreateMenu_CreateOptionsLoop_StringSearch:
  cmpw  REG_StringLoopCount,REG_CurrentOptionSelection
  beq SnapREV_Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd
#Get next string
  mr  r3,REG_OptionStrings
  branchl r12,strlen
  add REG_OptionStrings,REG_OptionStrings,r3
  addi  REG_OptionStrings,REG_OptionStrings,1       #add 1 to skip past the 0 terminator
  addi  REG_StringLoopCount,REG_StringLoopCount,1
  b SnapREV_Codes_CreateMenu_CreateOptionsLoop_StringSearch

SnapREV_Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd:
#Get Y Offset for this
  lis    r0, 0x4330
  lfd    f2, -0x6758 (rtoc)
  xoris    r3,REG_Count,0x8000
  stw    r0,0x80(sp)
  stw    r3,0x84(sp)
  lfd    f1,0x80(sp)
  fsubs    f1,f1,f2                   #REG_Count as a float
  lfs f2,CodesYDiff(REG_TextProp)     #YDifference
  fmuls f1,f1,f2
  lfs f2,CodesInitialY(REG_TextProp)  #Initial Y Value
  fadds f2,f1,f2
#Create Text
  lwz r3,OFST_CodeOptionsTextGObj(REG_GObjData)
  bl  SnapREV_CodeOptions_Wrapper
  mflr  r4
  mr  r5,REG_OptionStrings
  lfs f1,OptionsX(REG_TextProp)
  crset 6
  branchl r12,Text_InitializeSubtext
  mr  REG_SubtextID,r3
#Unhighlight this name
  mr  r4,REG_SubtextID
  addi  r5,REG_TextProp,NonHighlightColor
  lwz r3,OFST_CodeOptionsTextGObj(REG_GObjData)
  branchl r12,Text_ChangeTextColor
#Scale this name
  lwz r3,OFST_CodeOptionsTextGObj(REG_GObjData)
  mr  r4,REG_SubtextID
  lfs f1,CodesScale(REG_TextProp)
  lfs f2,CodesScale(REG_TextProp)
  branchl r12,Text_UpdateSubtextSize
SnapREV_Codes_CreateMenu_CreateOptionsIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge SnapREV_Codes_CreateMenu_CreateOptionsLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt SnapREV_Codes_CreateMenu_CreateOptionsLoop
SnapREV_Codes_CreateMenu_CreateOptionsLoopEnd:
#endregion
#region SnapREV_Codes_CreateMenu_HighlightCursor
#Name
  lwz r3,OFST_CodeNamesTextGObj(REG_GObjData)
  lhz r4,OFST_CursorLocation(REG_GObjData)
  addi  r5,REG_TextProp,HighlightColor
  branchl r12,Text_ChangeTextColor
#Option
  lwz r3,OFST_CodeOptionsTextGObj(REG_GObjData)
  lhz r4,OFST_CursorLocation(REG_GObjData)
  addi  r5,REG_TextProp,HighlightColor
  branchl r12,Text_ChangeTextColor
#endregion
#region SnapREV_Codes_CreateMenu_ChangeCodeDescription
#Get highlighted code ID
	lhz r3,OFST_ScrollAmount(REG_GObjData)
	lhz r4,OFST_CursorLocation(REG_GObjData)
	add	r3,r3,r4
#Get this codes options
	bl	SnapREV_CodeOptions_Order
	mflr	r4
	mulli	r3,r3,0x4
	add	r3,r3,r4
	bl	SnapREV_ConvertBlPointer
#Get this codes description
	addi	r3,r3,SnapREV_CodeOptions_CodeDescription
	bl	SnapREV_ConvertBlPointer
	lwz	r4,OFST_CodeDescTextGObj(REG_GObjData)
#Store to text gobj
	stw	r3,0x5C(r4)
#endregion

SnapREV_Codes_CreateMenu_Exit:
  restore
  blr

###############################################

SnapREV_ConvertBlPointer:
  lwz r4,0x0(r3)        #Load bl instruction
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
  add r3,r4,r3
  blr

#endregion
#region SnapREV_ApplyAllGeckoCodes
SnapREV_ApplyAllGeckoCodes:
.set  REG_GObjData,31
.set  REG_Count,30
.set  REG_OptionSelection,29
#Init
  backup
  mr  REG_GObjData,r3

#Default Codes
  bl  SnapREV_DefaultCodes
  mflr  r3
  bl  SnapREV_ApplyGeckoCode

#Init Loop
  li  REG_Count,0
ApplyAllGeckoSnapREV_Codes_Loop:
#Load this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx REG_OptionSelection,r3,REG_Count
#Get this code's default gecko code pointer
  bl  SnapREV_CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  SnapREV_ConvertBlPointer
  addi  r3,r3,SnapREV_CodeOptions_GeckoCodePointers
  bl  SnapREV_ConvertBlPointer
  bl  SnapREV_ApplyGeckoCode
#Get this code's gecko code pointers
  bl  SnapREV_CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  SnapREV_ConvertBlPointer
  addi  r3,r3,SnapREV_CodeOptions_GeckoCodePointers
  mulli r4,REG_OptionSelection,0x4
  add  r3,r3,r4
  bl  SnapREV_ConvertBlPointer
  bl  SnapREV_ApplyGeckoCode

ApplyAllGeckoSnapREV_Codes_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  blt ApplyAllGeckoSnapREV_Codes_Loop

ApplyAllGeckoSnapREV_Codes_Exit:
  restore
  blr

####################################

SnapREV_ApplyGeckoCode:
.set  REG_GeckoCode,12
  mr  REG_GeckoCode,r3

SnapREV_ApplyGeckoCode_Loop:
  lbz r3,0x0(REG_GeckoCode)
  cmpwi r3,0xC2
  beq SnapREV_ApplyGeckoCode_C2
  cmpwi r3,0x4
  beq SnapREV_ApplyGeckoCode_04
  cmpwi r3,0xFF
  beq SnapREV_ApplyGeckoCode_Exit
  b SnapREV_ApplyGeckoCode_Exit
SnapREV_ApplyGeckoCode_C2:
.set  REG_InjectionSite,11
#Branch overwrite
  lwz r5,0x0(REG_GeckoCode)
  rlwinm r3,r5,0,8,31                   #get offset for branch calc
  rlwinm r5,r5,0,8,31
  oris  REG_InjectionSite,r5,0x8000     #get mem address to write to
  addi  r4,REG_GeckoCode,0x8            #get branch destination
  sub r3,r4,REG_InjectionSite           #Difference relative to branch addr
  rlwinm  r3,r3,0,6,29                  #extract bits for offset
  oris  r3,r3,0x4800                    #Create branch instruction from it
  stw r3,0x0(REG_InjectionSite)         #place branch instruction
#Place branch back
  lwz r3,0x4(REG_GeckoCode)
  mulli r3,r3,0x8
  add r4,r3,REG_GeckoCode               #get branch back site
  addi  r3,REG_InjectionSite,0x4        #get branch back destination
  sub r3,r3,r4
  rlwinm  r3,r3,0,6,29                  #extract bits for offset
  oris  r3,r3,0x4800                    #Create branch instruction from it
  subi  r3,r3,0x4                       #subtract 4 i guess
  stw r3,0x4(r4)                        #place branch instruction
#Get next gecko code
  lwz r3,0x4(REG_GeckoCode)
  addi  r3,r3,1
  mulli r3,r3,0x8
  add REG_GeckoCode,REG_GeckoCode,r3
  b SnapREV_ApplyGeckoCode_Loop
SnapREV_ApplyGeckoCode_04:
  lwz r3,0x0(REG_GeckoCode)
  rlwinm r3,r3,0,8,31
  oris  r3,r3,0x8000
  lwz r4,0x4(REG_GeckoCode)
  stw r4,0x0(r3)
  addi REG_GeckoCode,REG_GeckoCode,0x8
  b SnapREV_ApplyGeckoCode_Loop
SnapREV_ApplyGeckoCode_Exit:
blr

#endregion

#endregion

#region LagPrompt

#region SnapREV_LagPrompt_SceneLoad
############################################

#region SnapREV_LagPrompt_SceneLoad_Data
SnapREV_LagPrompt_SceneLoad_TextProperties:
blrl
.set PromptX,0x0
.set PromptY,0x4
.set ZOffset,0x8
.set CanvasScaling,0xC
.set Scale,0x10
.set YesX,0x14
.set YesY,0x18
.set YesScale,0x1C
.set NoX,0x20
.set NoY,0x24
.set NoScale,0x28
.set HighlightColor,0x2C
.set NonHighlightColor,0x30
.float 315     			   #REG_TextGObj X pos
.float 200  					   #REG_TextGObj Y pos
.float 0.1     		     	 #Z offset
.float 1   				     #Canvas Scaling
.float 1					    	#Text scale
.float 265              #Yes X pos
.float 300              #Yes Y pos
.float 1              #Yes scale
.float 365              #No X pos
.float 300              #No Y pos
.float 1              #No scale
.byte 251,199,57,255		#highlighted color
.byte 170,170,170,255	  #nonhighlighted color

SnapREV_LagPrompt_SceneLoad_TopText:
blrl
.ascii "Are you using HDMI?"
.align 2

SnapREV_LagPrompt_SceneLoad_Yes:
blrl
.string "Yes"
.align 2

SnapREV_LagPrompt_SceneLoad_No:
blrl
.string "No"
.align 2

#GObj Offsets
  .set OFST_TextGObj,0x0
  .set OFST_Selection,0x4

#endregion
#region SnapREV_LagPrompt_SceneLoad
SnapREV_LagPrompt_SceneLoad:
blrl

#Init
  backup

SnapREV_LagPrompt_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl SnapREV_LagPrompt_SceneLoad_TextProperties
	mflr REG_TextProp

#Create canvas
  li  r3,0
  li  r4,0
  li  r5,9
  li  r6,13
  li  r7,0
  li  r8,14
  li  r9,0
  li  r10,19
  branchl r12,Text_CreateTextCanvas

########################
## Create Text Object ##
########################

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r12,Text_CreateTextStruct
#BACKUP STRUCT POINTER
	mr REG_TextGObj,r3
  stw REG_TextGObj,0x0(REG_GObjData)
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(REG_TextGObj)
#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(REG_TextGObj)
#Store Base Z Offset
	lfs f1,ZOffset(REG_TextProp) #Z offset
	stfs f1,0x8(REG_TextGObj)
#Scale Canvas Down
  lfs f1,CanvasScaling(REG_TextProp)
  stfs f1,0x24(REG_TextGObj)
  stfs f1,0x28(REG_TextGObj)

#Create Prompt
#Initialize Subtext
	mr 	r3,REG_TextGObj		#struct pointer
	bl SnapREV_LagPrompt_SceneLoad_TopText
  mflr  r4
	lfs	f1,PromptX(REG_TextProp)
  lfs	f2,PromptY(REG_TextProp)
	branchl r12,Text_InitializeSubtext
  mr  REG_SubtextID,r3
#Change Text Scale
	mr 	r3,REG_TextGObj		#struct pointer
	mr	r4,REG_SubtextID
	lfs 	f1,Scale(REG_TextProp) 		#X offset of REG_TextGObj
	lfs 	f2,Scale(REG_TextProp)	  	#Y offset of REG_TextGObj
	branchl r12,Text_UpdateSubtextSize

#Create Yes
#Initialize Subtext
	mr 	r3,REG_TextGObj		#struct pointer
	bl SnapREV_LagPrompt_SceneLoad_Yes
  mflr  r4
	lfs	f1,YesX(REG_TextProp)
  lfs	f2,YesY(REG_TextProp)
	branchl r12,Text_InitializeSubtext
  mr  REG_SubtextID,r3
#Change Text Scale
	mr 	r3,REG_TextGObj		#struct pointer
	mr	r4,REG_SubtextID
	lfs 	f1,YesScale(REG_TextProp) 		#X offset of REG_TextGObj
	lfs 	f2,YesScale(REG_TextProp)	  	#Y offset of REG_TextGObj
	branchl r12,Text_UpdateSubtextSize

#Create No
#Initialize Subtext
	mr 	r3,REG_TextGObj		#struct pointer
	bl SnapREV_LagPrompt_SceneLoad_No
  mflr  r4
	lfs	f1,NoX(REG_TextProp)
  lfs	f2,NoY(REG_TextProp)
	branchl r12,Text_InitializeSubtext
  mr  REG_SubtextID,r3
#Change Text Scale
	mr 	r3,REG_TextGObj		#struct pointer
	mr	r4,REG_SubtextID
	lfs 	f1,NoScale(REG_TextProp) 		#X offset of REG_TextGObj
	lfs 	f2,NoScale(REG_TextProp)	  	#Y offset of REG_TextGObj
	branchl r12,Text_UpdateSubtextSize

#Create GObj
  li  r3, 13
  li  r4,14
  li  r5,0
  branchl r12, GObj_Create
  mr  REG_GObj,r3
#Allocate Space
	li	r3,64
	branchl r12,HSD_MemAlloc
	mr	REG_GObjData,r3
#Zero
	li	r4,64
	branchl r12,ZeroAreaLength
#Initialize
	mr	r6,REG_GObjData
	mr	r3,REG_GObj
	li	r4,4
	load	r5,HSD_Free
	branchl r12,GObj_AddUserData
#Add Proc
  mr  r3,REG_GObj
  bl  SnapREV_LagPrompt_SceneThink
  mflr  r4      #Function to Run
  li  r5,0      #Priority
  branchl r12, GObj_AddProc

#Store text gobj pointer
  stw REG_TextGObj,OFST_TextGObj(REG_GObjData)
#Init Selection value
  li  r3,InitialSelection
  stb r3,OFST_Selection(REG_GObjData)

#Highlight selection
  mr  r3,REG_TextGObj
  li  r4,InitialSelection+1
  addi  r5,REG_TextProp,HighlightColor
  branchl r12,Text_ChangeTextColor

SnapREV_LagPrompt_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region SnapREV_LagPrompt_SceneThink
SnapREV_LagPrompt_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  SnapREV_LagPrompt_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,Inputs_GetPlayerRapidHeldInputs
  mr  REG_Inputs,r3
#Check for movement to the right
  rlwinm. r0,REG_Inputs,0,0x80
  beq SnapREV_LagPrompt_SceneThink_SkipRight
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  addi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,1
  ble SnapREV_LagPrompt_SceneThink_HighlightSelection
  li  r3,1
  stb r3,OFST_Selection(REG_GObjData)
  b SnapREV_LagPrompt_SceneThink_CheckForA
SnapREV_LagPrompt_SceneThink_SkipRight:
#Check for movement to the left
  rlwinm. r0,REG_Inputs,0,0x40
  beq SnapREV_LagPrompt_SceneThink_CheckForA
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  subi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge SnapREV_LagPrompt_SceneThink_HighlightSelection
  li  r3,0
  stb r3,OFST_Selection(REG_GObjData)
  b SnapREV_LagPrompt_SceneThink_CheckForA

SnapREV_LagPrompt_SceneThink_HighlightSelection:
#Unhighlight both options
  lwz r3,OFST_TextGObj(REG_GObjData)
  li  r4,1
  addi  r5,REG_TextProp,NonHighlightColor
  branchl r12,Text_ChangeTextColor
  lwz r3,OFST_TextGObj(REG_GObjData)
  li  r4,2
  addi  r5,REG_TextProp,NonHighlightColor
  branchl r12,Text_ChangeTextColor
#Highlight selection
  lwz r3,OFST_TextGObj(REG_GObjData)
  lbz r4,OFST_Selection(REG_GObjData)
  addi  r4,r4,1
  addi  r5,REG_TextProp,HighlightColor
  branchl r12,Text_ChangeTextColor
#Play SFX
  branchl r12,SFX_PlayMenuSound_CloseOpenPort
#endregion
#region Check for Confirmation
SnapREV_LagPrompt_SceneThink_CheckForA:
  li  r3,4
  branchl r12,Inputs_GetPlayerInstantInputs
  rlwinm. r0,r4,0,0x100
  bne SnapREV_LagPrompt_SceneThink_Confirmed
  rlwinm. r0,r4,0,0x1000
  bne SnapREV_LagPrompt_SceneThink_Confirmed
  b SnapREV_LagPrompt_SceneThink_Exit
SnapREV_LagPrompt_SceneThink_Confirmed:
#Play Menu Sound
  branchl r12,SFX_PlayMenuSound_Forward
#If yes, apply lag reduction
  lbz r3,OFST_Selection(REG_GObjData)
  cmpwi r3,0
  bne SnapREV_LagPrompt_SceneThink_ExitScene
#endregion
#region Apply Code
.set  REG_GeckoCode,12
#Apply lag reduction
  bl  SnapREV_LagReductionGeckoCode
  mflr  r3
  bl  SnapREV_ApplyGeckoCode
#Reset some pad variables to cancel the current alarm
  load  r3,UnkPadStruct
  li  r4,0
  stw r4,0x4(r3)
  stw r4,0x44(r3)
#Set new post retrace callback
  load  r3,PostRetraceCallback
  branchl r12,HSD_VISetUserPostRetraceCallback
#Do some shit to enable 480p
#Disable Deflicker
  load  r3,DeflickerStruct
  li  r0,1
  stw r0,0x8(r3)
  branchl r12,Deflicker_Toggle
#Enable REV60
	load	r3,ProgressiveStruct
	li	r4,1
	stw	r4,0xC(r3)
#Call VIConfigure
	li	r3,0	#disables deflicker and will enable 480p because of the gecko code
	branchl	r12,ScreenDisplay_Adjust
#Now flush the instruction cache
  lis r3,0x8000
  load r4,0x3b722c    #might be overkill but flush the entire dol file
  branchl r12,TRK_flush_cache
#endregion

SnapREV_LagPrompt_SceneThink_ExitScene:
  branchl r12,MenuController_ChangeScreenMinor

SnapREV_LagPrompt_SceneThink_Exit:
  restore
  blr
#endregion
#region SnapREV_LagPrompt_SceneDecide
SnapREV_LagPrompt_SceneDecide:

  backup

#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  SnapREV_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)

#Enter Codes Scene
  li  r3,CodesSceneID
  branchl r12,MenuController_WriteToPendingMajor
#Change Major
  branchl r12,MenuController_ChangeScreenMajor

SnapREV_LagPrompt_SceneDecide_Exit:
  restore
  blr
############################################
#endregion

#region SnapREV_LagReductionGeckoCode
SnapREV_LagReductionGeckoCode:
blrl
.long 0x04019D18
.long 0x4BFFFD9D
#Required for 480p
.long 0x043D5170
.long 0x00000002
.long 0x043D5184
.long 0x00000000
.long 0x043D51AC
.long 0x00000002
.long 0x043D51C0
.long 0x00000000
.long 0x040000CC
.long 0x00000000
.long 0xFF000000
#endregion

#endregion

#region MinorSceneStruct
SnapREV_LagPrompt_MinorSceneStruct:
blrl
#Lag Prompt
.byte 0                     #Minor Scene ID
.byte 00                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  SnapREV_LagPrompt_SceneDecide   #SceneDecide
.byte PromptCommonSceneID   #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

SnapREV_Codes_MinorSceneStruct:
blrl
#Codes Prompt
.byte 0                     #Minor Scene ID
.byte 00                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  SnapREV_Codes_SceneDecide       #SceneDecide
.byte CodesCommonSceneID    #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

#endregion

SnapREV_CheckProgressive:

#Check if progressive is enabled
  lis	r3,0xCC00
	lhz	r3,0x206E(r3)
	rlwinm.	r3,r3,0,0x1
  beq SnapREV_NoProgressive

SnapREV_IsProgressive:
#Override SceneLoad
  li  r3,PromptCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  SnapREV_LagPrompt_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load LagPrompt
  li	r3, PromptSceneID
  b ExploitCodeREV_Exit
SnapREV_NoProgressive:
#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  SnapREV_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load Codes
  li  r3,CodesSceneID

ExploitCodeREV_Exit:
#Store as next scene
	load	r4,OFST_MainMenuSceneData
	stb	r3,0x0(r4)
#request to change scenes
	branchl	r12,MenuController_ChangeScreenMinor

##########
## Exit ##
##########

#Exit exploit code
  restore
	branch	r12,ExploitReturn

MMLCodeREV_End:
blrl
#endregion
