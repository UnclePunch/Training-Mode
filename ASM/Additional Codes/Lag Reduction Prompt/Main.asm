#To be inserted at 801bf930
.include "../../Globals.s"

#Overwriting the debug CSS with a lag reduction prompt
#it crashes anyway so nothing of substance is being lost

#Parameters
.set  PromptSceneID,8 #0
.set  CodesSceneID,9
.set  ExitSceneID,2
.set  PromptCommonSceneID,10
.set  CodesCommonSceneID,10
.set  InitialSelection,0
.set  MaxCodesOnscreen,9
#Function Addresses
.set  PostRetraceCallback,0x800195fc
.set  UnkPadStruct,0x804329f0


#region Init New Scenes
.set  REG_MinorSceneStruct,31

#Init and backup
  backup

#Init LagPrompt major struct
  li  r3,PromptSceneID
  bl  LagPrompt_MinorSceneStruct
  mflr  r4
  bl  LagPrompt_SceneLoad
  mflr  r5
  bl  InitializeMajorSceneStruct
#Init Codes major struct
  li  r3,CodesSceneID
  bl  Codes_MinorSceneStruct
  mflr  r4
  bl  Codes_SceneLoad
  mflr  r5
  bl  InitializeMajorSceneStruct

  b CheckProgressive

#region PointerConvert
PointerConvert:
  lwz r4,0x0(r3)          #Load bl instruction
  rlwinm r5,r4,8,25,29    #extract opcode bits
  cmpwi r5,0x48           #if not a bl instruction, exit
  bne PointerConvert_Exit
  rlwinm  r4,r4,0,6,29  #extract offset bits
  extsh r4,r4
  add r4,r4,r3
  stw r4,0x0(r3)
PointerConvert_Exit:
  blr
#endregion
#region InitializeMajorSceneStruct
InitializeMajorSceneStruct:
.set  REG_MajorScene,31
.set  REG_MinorStruct,30
.set  REG_SceneLoad,29

#Init
  backup
  mr  REG_MajorScene,r3
  mr  REG_MinorStruct,r4
  mr  REG_SceneLoad,r5

#Get major scene struct
  branchl r12,0x801a50ac
GetMajorStruct_Loop:
  lbz	r4, 0x0001 (r3)
  cmpw r4,REG_MajorScene
  beq GetMajorStruct_Exit
  addi  r3,r3,20
  b GetMajorStruct_Loop
GetMajorStruct_Exit:

InitMinorSceneStruct:
.set  REG_MinorStructParse,20
  stw REG_MinorStruct,0x10(r3)
  mr  REG_MinorStructParse,REG_MinorStruct
InitMinorSceneStruct_Loop:
#Check if valid entry
  lbz r3,0x0(REG_MinorStructParse)
  extsb r3,r3
  cmpwi r3,-1
  beq InitMinorSceneStruct_Exit
#Convert Pointers
  addi  r3,REG_MinorStructParse,0x4
  bl  PointerConvert
  addi  r3,REG_MinorStructParse,0x8
  bl  PointerConvert
  addi  REG_MinorStructParse,REG_MinorStructParse,0x18
  b InitMinorSceneStruct_Loop
InitMinorSceneStruct_Exit:

  restore
  blr
#endregion
#endregion

#region LagPrompt

#region LagPrompt_SceneLoad
############################################

#region LagPrompt_SceneLoad_Data
LagPrompt_SceneLoad_TextProperties:
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
.float 0     		     	 #Z offset
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

LagPrompt_SceneLoad_TopText:
blrl
.ascii "Are you using HDMI"
.short 0x8148
.byte 0
.align 2

LagPrompt_SceneLoad_Yes:
blrl
.string "Yes"
.align 2

LagPrompt_SceneLoad_No:
blrl
.string "No"
.align 2

#GObj Offsets
  .set OFST_TextGObj,0x0
  .set OFST_Selection,0x4

#endregion
#region LagPrompt_SceneLoad
LagPrompt_SceneLoad:
blrl

#Init
  backup

LagPrompt_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl LagPrompt_SceneLoad_TextProperties
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
  branchl r12,0x803a611c

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
	bl LagPrompt_SceneLoad_TopText
  mflr  r4
	lfs	f1,PromptX(REG_TextProp)
  lfs	f2,PromptY(REG_TextProp)
	branchl r12,0x803a6b98
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
	bl LagPrompt_SceneLoad_Yes
  mflr  r4
	lfs	f1,YesX(REG_TextProp)
  lfs	f2,YesY(REG_TextProp)
	branchl r12,0x803a6b98
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
	bl LagPrompt_SceneLoad_No
  mflr  r4
	lfs	f1,NoX(REG_TextProp)
  lfs	f2,NoY(REG_TextProp)
	branchl r12,0x803a6b98
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
	load	r5,0x8037f1b0
	branchl r12,GObj_AddUserData
#Add Proc
  mr  r3,REG_GObj
  bl  LagPrompt_SceneThink
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

LagPrompt_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region LagPrompt_SceneThink
LagPrompt_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  LagPrompt_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,0x801a36c0
  mr  REG_Inputs,r3
#Check for movement to the right
  rlwinm. r0,REG_Inputs,0,0x80
  beq LagPrompt_SceneThink_SkipRight
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  addi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,1
  ble LagPrompt_SceneThink_HighlightSelection
  li  r3,1
  stb r3,OFST_Selection(REG_GObjData)
  b LagPrompt_SceneThink_CheckForA
LagPrompt_SceneThink_SkipRight:
#Check for movement to the left
  rlwinm. r0,REG_Inputs,0,0x40
  beq LagPrompt_SceneThink_CheckForA
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  subi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge LagPrompt_SceneThink_HighlightSelection
  li  r3,0
  stb r3,OFST_Selection(REG_GObjData)
  b LagPrompt_SceneThink_CheckForA

LagPrompt_SceneThink_HighlightSelection:
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
  branchl r12,0x80174380
#endregion
#region Check for Confirmation
LagPrompt_SceneThink_CheckForA:
  li  r3,4
  branchl r12,0x801a36a0
  rlwinm. r0,r4,0,0x100
  bne LagPrompt_SceneThink_Confirmed
  rlwinm. r0,r4,0,0x1000
  bne LagPrompt_SceneThink_Confirmed
  b LagPrompt_SceneThink_Exit
LagPrompt_SceneThink_Confirmed:
#Play Menu Sound
  branchl r12,0x80174338
#If yes, apply lag reduction
  lbz r3,OFST_Selection(REG_GObjData)
  cmpwi r3,0
  bne LagPrompt_SceneThink_ExitScene
#endregion
#region Apply Code
.set  REG_GeckoCode,12
#Apply lag reduction
  bl  LagReductionGeckoCode
  mflr  r3
  bl  ApplyGeckoCode
#Reset some pad variables
  load  r3,UnkPadStruct
  li  r4,0
  stw r4,0x4(r3)
  stw r4,0x44(r3)
#Set new post retrace callback
  load  r3,PostRetraceCallback
  branchl r12,0x80375934
#Now flush the instruction cache
  lis r3,0x8000
  load r4,0x3b722c    #might be overkill but flush the entire dol file
  branchl r12,0x80328f50
#endregion

LagPrompt_SceneThink_ExitScene:
  branchl r12,0x801a4b60

LagPrompt_SceneThink_Exit:
  restore
  blr
#endregion
#region LagPrompt_SceneDecide
LagPrompt_SceneDecide:

  backup

#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,0x801a4ce0
  bl  Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)

#Enter Codes Scene
  li  r3,CodesSceneID
  branchl r12,0x801a42e8
#Change Major
  branchl r12,0x801a42d4

LagPrompt_SceneDecide_Exit:
  restore
  blr
############################################
#endregion
#region LagReductionGeckoCode
LagReductionGeckoCode:
blrl
.long 0x041A4D98
.long 0x481AA57D
.long 0x04019860
.long 0x4BFFFD9D
.long 0x0415FFB8
.long 0x3C808001
.long 0x0415FFBC
.long 0x608395FC
.long 0xFF000000
#endregion

#endregion

#region Codes

#region Codes_SceneLoad
############################################

#region Codes_SceneLoad_Data
Codes_SceneLoad_TextProperties:
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
.float 30     			   #REG_TextGObj X pos
.float 30  					   #REG_TextGObj Y pos
.float 1   				     #Canvas Scaling
.float 1.2					    	#Text scale
.float 320              #CodesX
.float 100              #CodesInitialY
.float 30              #CodesYDiff
.float 0.8             #CodesScale
.float 335              #OptionsX
.byte 251,199,57,255		#highlighted color
.byte 170,170,170,255	  #nonhighlighted color


.set CodeAmount,5
#region Code Names Order
CodeNames_Order:
blrl
bl  CodeNames_UCF
bl  CodeNames_Frozen
bl  CodeNames_Spawns
bl  CodeNames_Wobbling
bl  CodeNames_Ledgegrab
.align 2
#endregion
#region Code Names
CodeNames_Title:
blrl
.string "Select Codes:"
.align 2
CodeNames_UCF:
.string "UCF:"
.align 2
CodeNames_Frozen:
.string "Frozen Stages:"
.align 2
CodeNames_Spawns:
.string "Neutral Spawns:"
.align 2
CodeNames_Wobbling:
.string "Wobbling:"
.align 2
CodeNames_Ledgegrab:
.string "Ledge Grab Limit:"
.align 2
#endregion
#region Code Options Order
CodeOptions_Order:
blrl
bl  CodeOptions_UCF
bl  CodeOptions_Frozen
bl  CodeOptions_Spawns
bl  CodeOptions_Wobbling
bl  CodeOptions_Ledgegrab
.align 2
#endregion
#region Code Options
.set  CodeOptions_OptionCount,0x0
.set  CodeOptions_GeckoCodePointers,0x4
CodeOptions_Wrapper:
blrl
.short 0x8183
.ascii "%s"
.short 0x8184
.byte 0
.align 2
CodeOptions_UCF:
.long 3 -1           #number of options
bl  UCF_Off
bl  UCF_On
bl  UCF_Stealth
.string "Off"
.string "On"
.string "Stealth"
.align 2
CodeOptions_Frozen:
.long 3 -1           #number of options
bl  Frozen_Off
bl  Frozen_Stadium
bl  Frozen_All
.string "Off"
.string "Stadium Only"
.string "All"
.align 2
CodeOptions_Spawns:
.long 2 -1           #number of options
bl  Spawns_Off
bl  Spawns_On
.string "Off"
.string "On"
.align 2
CodeOptions_Wobbling:
.long 2 -1           #number of options
bl  Wobbling_On
bl  Wobbling_Off
.string "On"
.string "Off"
.align 2
CodeOptions_Ledgegrab:
.long 2 -1           #number of options
bl  Ledgegrab_Off
bl  Ledgegrab_On
.string "Off"
.string "On"
.align 2
#endregion
#region Gecko Codes
DefaultCodes:
  blrl
  .long 0x0445BF28  #Chars
  .long 0xFFFFFFFF
  .long 0x0445BF2C  #Stages
  .long 0xFFFFFFFF
  .long 0x0445bf10  #Game Mode
  .long 0x00340102
  .long 0x0445bf14  #Stock count
  .long 0x04000a00
  .long 0x0445bf18  #Timer
  .long 0x08010100
  .long 0x0445c388  #Random Stages
  .long 0xe70000b0
  .long 0x0445c370  #Item Switch
  .long 0xff000000
  .long 0x0445C394  #Unlock Trophies
  .long 0x01266363
  .long 0x0415D94C  #Disable Special Messages
  .long 0x4E800020
  .long 0x0415D984  #Disable Trophy Messages
  .long 0x4E800020
  .long 0xFF000000

UCF_Off:
  .long 0x040c9a44
  .long 0xd01f002c
  .long 0x040998A4
  .long 0x8083002c
  .long 0x042662D0
  .long 0x38980000
  .long 0xFF000000
UCF_On:
  .long 0xC20C9A44
  .long 0x00000022
  .long 0xA09F03E8
  .long 0x2C044000
  .long 0x40820100
  .long 0x808DAEB4
  .long 0xC03F0620
  .long 0xC05F2344
  .long 0xEC2100B2
  .long 0xC044003C
  .long 0xFC011040
  .long 0x4C411382
  .long 0x408200E0
  .long 0x88BF0670
  .long 0x2C050002
  .long 0x408000D4
  .long 0x889F221F
  .long 0x54840739
  .long 0x41A20008
  .long 0x480000C4
  .long 0x3C80804C
  .long 0x60841F78
  .long 0x88A40001
  .long 0x98A1FFF8
  .long 0x4800003C
  .long 0x38A5FFFF
  .long 0x2C050000
  .long 0x40800008
  .long 0x38A50005
  .long 0x3C808046
  .long 0x6084B108
  .long 0x1CA50030
  .long 0x7C842A14
  .long 0x88BF000C
  .long 0x1CA5000C
  .long 0x7C842A14
  .long 0x88A40002
  .long 0x7CA50774
  .long 0x4E800020
  .long 0x38A5FFFE
  .long 0x4BFFFFC5
  .long 0x90A1FFF4
  .long 0x88A1FFF8
  .long 0x4BFFFFB9
  .long 0x8081FFF4
  .long 0x7CA42850
  .long 0x7CA529D6
  .long 0x2C0515F9
  .long 0x40810050
  .long 0x38000001
  .long 0x901F2358
  .long 0x901F2340
  .long 0x889F0007
  .long 0x2C04000A
  .long 0x40A20038
  .long 0x80830010
  .long 0x8084002C
  .long 0x80841ECC
  .long 0xD0040018
  .long 0x80A40018
  .long 0x3D803F80
  .long 0x7C056000
  .long 0x41820010
  .long 0x38A00080
  .long 0x98A40006
  .long 0x4800000C
  .long 0x38A0007F
  .long 0x98A40006
  .long 0xD01F002C
  .long 0x00000000
  .long 0xC20998A4
  .long 0x0000001E
  .long 0x8063002C
  .long 0xC023063C
  .long 0xC0050314
  .long 0xFC010040
  .long 0x408100D4
  .long 0x3C8042A0
  .long 0x9081FFF4
  .long 0x3C803727
  .long 0x9081FFF8
  .long 0x3C804330
  .long 0x9081FFE4
  .long 0xC0030620
  .long 0x38000000
  .long 0xFC000210
  .long 0xC021FFF4
  .long 0xEC000072
  .long 0xC021FFF8
  .long 0xEC000828
  .long 0xFC00001E
  .long 0xD801FFEC
  .long 0x8081FFF0
  .long 0x38840002
  .long 0x6C848000
  .long 0x9081FFE8
  .long 0xC801FFE4
  .long 0xC8228B90
  .long 0xEC000828
  .long 0xC021FFF4
  .long 0xEC000824
  .long 0x2C000000
  .long 0x40820014
  .long 0x38000001
  .long 0xD001FFE0
  .long 0xC0030624
  .long 0x4BFFFFAC
  .long 0xC021FFE0
  .long 0xEC210072
  .long 0xEC000032
  .long 0xEC00082A
  .long 0xC0228954
  .long 0xFC000840
  .long 0x4C411382
  .long 0x4082003C
  .long 0x88830670
  .long 0x2C040003
  .long 0x40810030
  .long 0xC005002C
  .long 0xFC000050
  .long 0xC0230624
  .long 0xFC000840
  .long 0x4080001C
  .long 0x8061001C
  .long 0x38630008
  .long 0x83E10014
  .long 0x38210018
  .long 0x7C6803A6
  .long 0x4E800020
  .long 0x7FC3F378
  .long 0x8083002C
  .long 0x00000000
  .long 0xC22662D0
  .long 0x00000018
  .long 0x9421FFBC
  .long 0xBE810008
  .long 0x7C0802A6
  .long 0x90010040
  .long 0x38600000
  .long 0x38800000
  .long 0x3DC0803A
  .long 0x61CE6754
  .long 0x7DC903A6
  .long 0x4E800421
  .long 0x7C7F1B78
  .long 0x4800005D
  .long 0x7FC802A6
  .long 0x7FE3FB78
  .long 0xC03E0000
  .long 0xC05E0004
  .long 0x48000059
  .long 0x7C8802A6
  .long 0x3DC0803A
  .long 0x61CE6B98
  .long 0x7DC903A6
  .long 0x4E800421
  .long 0x807F005C
  .long 0x3C80FFFF
  .long 0x6084FF0E
  .long 0x90830006
  .long 0x38800001
  .long 0x989F0049
  .long 0x38800001
  .long 0x989F004A
  .long 0xC03E0008
  .long 0xD03F0024
  .long 0xD03F0028
  .long 0x48000024
  .long 0x4E800021
  .long 0x42820000
  .long 0xC40F4000
  .long 0x3D3851EC
  .long 0x4E800021
  .long 0x55434620
  .long 0x76302E37
  .long 0x33000000
  .long 0x80010040
  .long 0x7C0803A6
  .long 0xBA810008
  .long 0x38210044
  .long 0x38980000
  .long 0x00000000
  .long 0xFF000000
UCF_Stealth:
  .long 0xC20C9A44
  .long 0x00000022
  .long 0xA09F03E8
  .long 0x2C044000
  .long 0x40820100
  .long 0x808DAEB4
  .long 0xC03F0620
  .long 0xC05F2344
  .long 0xEC2100B2
  .long 0xC044003C
  .long 0xFC011040
  .long 0x4C411382
  .long 0x408200E0
  .long 0x88BF0670
  .long 0x2C050002
  .long 0x408000D4
  .long 0x889F221F
  .long 0x54840739
  .long 0x41A20008
  .long 0x480000C4
  .long 0x3C80804C
  .long 0x60841F78
  .long 0x88A40001
  .long 0x98A1FFF8
  .long 0x4800003C
  .long 0x38A5FFFF
  .long 0x2C050000
  .long 0x40800008
  .long 0x38A50005
  .long 0x3C808046
  .long 0x6084B108
  .long 0x1CA50030
  .long 0x7C842A14
  .long 0x88BF000C
  .long 0x1CA5000C
  .long 0x7C842A14
  .long 0x88A40002
  .long 0x7CA50774
  .long 0x4E800020
  .long 0x38A5FFFE
  .long 0x4BFFFFC5
  .long 0x90A1FFF4
  .long 0x88A1FFF8
  .long 0x4BFFFFB9
  .long 0x8081FFF4
  .long 0x7CA42850
  .long 0x7CA529D6
  .long 0x2C0515F9
  .long 0x40810050
  .long 0x38000001
  .long 0x901F2358
  .long 0x901F2340
  .long 0x889F0007
  .long 0x2C04000A
  .long 0x40A20038
  .long 0x80830010
  .long 0x8084002C
  .long 0x80841ECC
  .long 0xD0040018
  .long 0x80A40018
  .long 0x3D803F80
  .long 0x7C056000
  .long 0x41820010
  .long 0x38A00080
  .long 0x98A40006
  .long 0x4800000C
  .long 0x38A0007F
  .long 0x98A40006
  .long 0xD01F002C
  .long 0x00000000
  .long 0xC20998A4
  .long 0x0000001E
  .long 0x8063002C
  .long 0xC023063C
  .long 0xC0050314
  .long 0xFC010040
  .long 0x408100D4
  .long 0x3C8042A0
  .long 0x9081FFF4
  .long 0x3C803727
  .long 0x9081FFF8
  .long 0x3C804330
  .long 0x9081FFE4
  .long 0xC0030620
  .long 0x38000000
  .long 0xFC000210
  .long 0xC021FFF4
  .long 0xEC000072
  .long 0xC021FFF8
  .long 0xEC000828
  .long 0xFC00001E
  .long 0xD801FFEC
  .long 0x8081FFF0
  .long 0x38840002
  .long 0x6C848000
  .long 0x9081FFE8
  .long 0xC801FFE4
  .long 0xC8228B90
  .long 0xEC000828
  .long 0xC021FFF4
  .long 0xEC000824
  .long 0x2C000000
  .long 0x40820014
  .long 0x38000001
  .long 0xD001FFE0
  .long 0xC0030624
  .long 0x4BFFFFAC
  .long 0xC021FFE0
  .long 0xEC210072
  .long 0xEC000032
  .long 0xEC00082A
  .long 0xC0228954
  .long 0xFC000840
  .long 0x4C411382
  .long 0x4082003C
  .long 0x88830670
  .long 0x2C040003
  .long 0x40810030
  .long 0xC005002C
  .long 0xFC000050
  .long 0xC0230624
  .long 0xFC000840
  .long 0x4080001C
  .long 0x8061001C
  .long 0x38630008
  .long 0x83E10014
  .long 0x38210018
  .long 0x7C6803A6
  .long 0x4E800020
  .long 0x7FC3F378
  .long 0x8083002C
  .long 0x00000000
  .long 0x042662D0
  .long 0x38980000
  .long 0xFF000000
Frozen_Off:
  .long 0x041D1548
  .long 0x48003001
  .long 0x04211444
  .long 0x4800059c
  .long 0x041E3348
  .long 0x480000d1
  .long 0x0421AAE4
  .long 0x48000805
  .long 0xFF000000
Frozen_Stadium:
  .long 0x041D1548
  .long 0x60000000
  .long 0x04211444
  .long 0x4800059c
  .long 0x041E3348
  .long 0x480000d1
  .long 0x0421AAE4
  .long 0x48000805
  .long 0xFF000000
Frozen_All:
  .long 0x041D1548
  .long 0x60000000
  .long 0x04211444
  .long 0x60000000
  .long 0x041E3348
  .long 0x60000000
  .long 0x0421AAE4
  .long 0x60000000
  .long 0xFF000000

Spawns_Off:
  .long 0x04263058
  .long 0x38840001
  .long 0x041c0a48
  .long 0x7d8803a6
  .long 0xFF000000
Spawns_On:
  .long 0xC2263058
  .long 0x00000030
  .long 0x39E00000
  .long 0x3A000000
  .long 0x3E408048
  .long 0x625307FD
  .long 0x91F206D8
  .long 0x91F206DC
  .long 0x8A3207C8
  .long 0x625206D7
  .long 0x2C110001
  .long 0x4182004C
  .long 0x39EF0001
  .long 0x8E930024
  .long 0x2C140003
  .long 0x4182000C
  .long 0x9A130004
  .long 0x3A100001
  .long 0x2C0F0004
  .long 0x41A0FFE4
  .long 0x48000130
  .long 0x39E00000
  .long 0x3A0000FF
  .long 0x3E408048
  .long 0x62520801
  .long 0x39EF0001
  .long 0x9E120024
  .long 0x2C0F0004
  .long 0x41A0FFF4
  .long 0x4800010C
  .long 0x3E208048
  .long 0x623106DC
  .long 0x39EF0001
  .long 0x3A520001
  .long 0x8E930024
  .long 0x89D30008
  .long 0x2C140003
  .long 0x41A2FFC0
  .long 0x2C0E0000
  .long 0x40820010
  .long 0x3A000000
  .long 0x8A910000
  .long 0x48000024
  .long 0x2C0E0001
  .long 0x40820010
  .long 0x3A000001
  .long 0x8E910001
  .long 0x48000010
  .long 0x3A000002
  .long 0x8E910002
  .long 0x48000004
  .long 0x3A940001
  .long 0x2C140003
  .long 0x40A0FF80
  .long 0x9A910000
  .long 0x9A120000
  .long 0x2C0F0004
  .long 0x41A0FF94
  .long 0x39E00000
  .long 0x3E208048
  .long 0x623106DB
  .long 0x3AA00000
  .long 0x39EF0001
  .long 0x8E910001
  .long 0x2C140001
  .long 0x40800008
  .long 0x48000010
  .long 0x3AB50001
  .long 0x2C150003
  .long 0x40A0FF40
  .long 0x2C0F0003
  .long 0x41A0FFDC
  .long 0x39E00000
  .long 0x3A310127
  .long 0x39C000FF
  .long 0x3A8000FF
  .long 0x39EF0001
  .long 0x8E110024
  .long 0x2C0E00FF
  .long 0x40820010
  .long 0x7E128378
  .long 0x39C00000
  .long 0x4800002C
  .long 0x7C109000
  .long 0x4082000C
  .long 0x39C00003
  .long 0x4800001C
  .long 0x2C1400FF
  .long 0x40820010
  .long 0x39C00001
  .long 0x3A800000
  .long 0x48000008
  .long 0x39C00002
  .long 0x99D1FFFC
  .long 0x2C0F0004
  .long 0x41A0FFB4
  .long 0x38840001
  .long 0x00000000
  .long 0xC21C0A48
  .long 0x0000001A
  .long 0x3DE0801B
  .long 0x61EFFFA8
  .long 0x7C0F6000
  .long 0x418200BC
  .long 0x3DC08048
  .long 0xA1CE0686
  .long 0x3DE08049
  .long 0x61EFED70
  .long 0x81EF0000
  .long 0x2C0E001F
  .long 0x4082001C
  .long 0x3E00C242
  .long 0x3E204242
  .long 0x3E404230
  .long 0x3A600000
  .long 0x960F0598
  .long 0x4800002C
  .long 0x2C0E001C
  .long 0x40820040
  .long 0x3E00C23A
  .long 0x62106666
  .long 0x3E20423D
  .long 0x62318E70
  .long 0x3E404214
  .long 0x3A600000
  .long 0x960F0854
  .long 0x48000004
  .long 0x924F0004
  .long 0x962F0040
  .long 0x924F0004
  .long 0x962F0040
  .long 0x926F0004
  .long 0x960F0040
  .long 0x926F0004
  .long 0x2C0E0020
  .long 0x40820014
  .long 0x3A000041
  .long 0x9E0F0650
  .long 0x3A0000C1
  .long 0x9A0F0040
  .long 0x2C0E0008
  .long 0x40820024
  .long 0x3E004270
  .long 0x3E20C270
  .long 0x3A400000
  .long 0x39EF4748
  .long 0x960F4748
  .long 0x924F0004
  .long 0x962F0040
  .long 0x924F0004
  .long 0x7D8803A6
  .long 0x00000000
  .long 0xFF000000

Wobbling_On:
  .long 0x0408EE48
  .long 0x2c000000
  .long 0xFF000000
Wobbling_Off:
  .long 0xC208EE48
  .long 0x0000000C
  .long 0x807B0010
  .long 0x2C0300D9
  .long 0x4182004C
  .long 0x2C030163
  .long 0x40A20018
  .long 0x807B0004
  .long 0x2C030002
  .long 0x2C830019
  .long 0x4C423382
  .long 0x41820030
  .long 0x887D2226
  .long 0x70630020
  .long 0x40820024
  .long 0xC01D1A4C
  .long 0x38600000
  .long 0x9061FFF0
  .long 0xC021FFF0
  .long 0xFC000840
  .long 0x4C401382
  .long 0x40820008
  .long 0x38000000
  .long 0x2C000000
  .long 0x60000000
  .long 0x00000000
  .long 0xFF000000
Ledgegrab_Off:
  .long 0x0408ee54
  .long 0xc0028af4
  .long 0xFF000000
Ledgegrab_On:
  .long 0x0408ee54
  .long 0xc0028af4
  .long 0xFF000000

#endregion

#endregion
#region Codes_SceneLoad
Codes_SceneLoad:
#GObj Offsets
  .set OFST_CodeNamesTextGObj,0x0
  .set OFST_CodeOptionsTextGObj,0x4
  .set OFST_CursorLocation,0x8
  .set OFST_ScrollAmount,0xA
  .set OFST_OptionSelections,0xC
blrl

#Init
  backup

Codes_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl Codes_SceneLoad_TextProperties
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
  branchl r12,0x803a611c

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

#Create Prompt
#Initialize Subtext
	mr 	r3,REG_TextGObj		#struct pointer
	bl CodeNames_Title
  mflr  r4
	lfs	f1,TitleX(REG_TextProp)
  lfs	f2,TitleY(REG_TextProp)
	branchl r12,0x803a6b98
  mr  REG_SubtextID,r3
#Change Text Scale
	mr 	r3,REG_TextGObj		#struct pointer
	mr	r4,REG_SubtextID
	lfs 	f1,TitleScale(REG_TextProp) 		#X offset of REG_TextGObj
	lfs 	f2,TitleScale(REG_TextProp)	  	#Y offset of REG_TextGObj
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
	load	r5,0x8037f1b0
	branchl r12,GObj_AddUserData
#Add Proc
  mr  r3,REG_GObj
  bl  Codes_SceneThink
  mflr  r4      #Function to Run
  li  r5,0      #Priority
  branchl r12, GObj_AddProc
#Create Menu
  mr  r3,REG_GObjData
  bl  Codes_CreateMenu

Codes_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region Codes_SceneThink
Codes_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Code Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,0x801a36c0
  mr  REG_Inputs,r3
#Check for movement up
  rlwinm. r0,REG_Inputs,0,0x10
  beq Codes_SceneThink_SkipUp
#Adjust cursor
  lhz r3,OFST_CursorLocation(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_CursorLocation(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Codes_SceneThink_UpdateMenu
#Cursor stays at top
  li  r3,0
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll up
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Codes_SceneThink_UpdateMenu
#Scroll stays at top
  li  r3,0
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b Codes_SceneThink_Exit
Codes_SceneThink_SkipUp:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x20
  beq Codes_SceneThink_AdjustOptionSelection
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
  b Codes_SceneThink_Exit
#Check if exceeds max amount of codes per page
  cmpwi r3,MaxCodesOnscreen-1
  ble Codes_SceneThink_UpdateMenu
#Cursor stays at bottom
  li  r3,MaxCodesOnscreen-1
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll down
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  addi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,CodeAmount-MaxCodesOnscreen
  ble Codes_SceneThink_UpdateMenu
#Scroll stays at bottom
  li  r3,(CodeAmount-1)-(MaxCodesOnscreen-1)
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b Codes_SceneThink_Exit
#endregion
#region Adjust Option Selection
Codes_SceneThink_AdjustOptionSelection:
.set  REG_MaxOptions,20
.set  REG_OptionValuePtr,21
#Check for movement right
  rlwinm. r0,REG_Inputs,0,0x80
  beq Codes_SceneThink_SkipRight
#Get amount of options for this code
  lhz r3,OFST_CursorLocation(REG_GObjData)
  lhz r4,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,r4                                #get which option this is
  bl  CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add r3,r3,r4                                #get bl pointer to options info
  bl  ConvertBlPointer
  lwz REG_MaxOptions,CodeOptions_OptionCount(r3)     #get amount of options for this code
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
  ble Codes_SceneThink_UpdateMenu
#Option stays maxxed out
  stb REG_MaxOptions,0x0(REG_OptionValuePtr)
  b Codes_SceneThink_Exit
Codes_SceneThink_SkipRight:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x40
  beq Codes_SceneThink_CheckToExit
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
  bge Codes_SceneThink_UpdateMenu
#Option stays at 0
  li  r3,0
  stb r3,0x0(REG_OptionValuePtr)
  b Codes_SceneThink_Exit
#endregion
#region Check to Exit
Codes_SceneThink_CheckToExit:
#Check for start input
  li  r3,4
  branchl r12,0x801a36a0
  rlwinm. r0,r4,0,0x1000
  beq Codes_SceneThink_Exit
#Apply codes
  mr  r3,REG_GObjData
  bl  ApplyAllGeckoCodes
#Now flush the instruction cache
  lis r3,0x8000
  load r4,0x3b722c    #might be overkill but flush the entire dol file
  branchl r12,0x80328f50
#Play SFX
  branchl r12,0x80174338
#Exit Scene
  branchl r12,0x801a4b60
  b Codes_SceneThink_Exit
#endregion

Codes_SceneThink_UpdateMenu:
#Redraw Menu
  mr  r3,REG_GObjData
  bl  Codes_CreateMenu
#Play SFX
  branchl r12,0x80174380
  b Codes_SceneThink_Exit

Codes_SceneThink_Exit:
  restore
  blr
#endregion
#region Codes_SceneDecide
Codes_SceneDecide:
  backup

#Change Major
  li  r3,ExitSceneID
  branchl r12,0x801a42e8
#Leave Major
  branchl r12,0x801a42d4

Codes_SceneDecide_Exit:
  restore
  blr
############################################
#endregion
#region Codes_CreateMenu
Codes_CreateMenu:
.set  REG_GObjData,31
.set  REG_TextGObj,30
.set  REG_TextProp,29

#Init
  backup
  mr  REG_GObjData,r3
  bl  Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#Remove old text gobjs if they exist
  lwz r3,OFST_CodeNamesTextGObj(REG_GObjData)
  cmpwi r3,0
  beq Codes_CreateMenu_SkipNameRemoval
  branchl r12,Text_RemoveText
Codes_CreateMenu_SkipNameRemoval:
  lwz r3,OFST_CodeOptionsTextGObj(REG_GObjData)
  cmpwi r3,0
  beq Codes_CreateMenu_SkipOptionRemoval
  branchl r12,Text_RemoveText
Codes_CreateMenu_SkipOptionRemoval:

#region CreateTextGObjs
Codes_CreateMenu_CreateTextGObjs:
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
#region Codes_CreateMenu_CreateNames
Codes_CreateMenu_CreateNamesInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
  li  REG_Count,0
Codes_CreateMenu_CreateNamesLoop:
#Next name to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,REG_Count
#Get the string bl pointer
  bl  CodeNames_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  ConvertBlPointer
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
Codes_CreateMenu_CreateNamesIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge Codes_CreateMenu_CreateNameLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt Codes_CreateMenu_CreateNamesLoop
Codes_CreateMenu_CreateNameLoopEnd:
#endregion
#region Codes_CreateMenu_CreateOptions
Codes_CreateMenu_CreateOptionsInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
.set  REG_CurrentOptionID,22
.set  REG_CurrentOptionSelection,23
.set  REG_OptionStrings,24
.set  REG_StringLoopCount,25
  li  REG_Count,0
Codes_CreateMenu_CreateOptionsLoop:
#Next option to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add REG_CurrentOptionID,r3,REG_Count
#Get the bl pointer
  mr  r3,REG_CurrentOptionID
  bl  CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  ConvertBlPointer
  lwz r4,CodeOptions_OptionCount(r3)
  addi  r4,r4,1
  addi  REG_OptionStrings,r3,CodeOptions_GeckoCodePointers  #Get pointer to gecko code pointers
  mulli r4,r4,0x4                                           #pointer length
  add REG_OptionStrings,REG_OptionStrings,r4
#Get this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx  REG_CurrentOptionSelection,r3,REG_CurrentOptionID

#Loop through strings and get the current one
  li  REG_StringLoopCount,0
Codes_CreateMenu_CreateOptionsLoop_StringSearch:
  cmpw  REG_StringLoopCount,REG_CurrentOptionSelection
  beq Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd
#Get next string
  mr  r3,REG_OptionStrings
  branchl r12,strlen
  add REG_OptionStrings,REG_OptionStrings,r3
  addi  REG_OptionStrings,REG_OptionStrings,1       #add 1 to skip past the 0 terminator
  addi  REG_StringLoopCount,REG_StringLoopCount,1
  b Codes_CreateMenu_CreateOptionsLoop_StringSearch

Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd:
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
  bl  CodeOptions_Wrapper
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
Codes_CreateMenu_CreateOptionsIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge Codes_CreateMenu_CreateOptionsLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt Codes_CreateMenu_CreateOptionsLoop
Codes_CreateMenu_CreateOptionsLoopEnd:
#endregion
#region Codes_CreateMenu_HighlightCursor
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

Codes_CreateMenu_Exit:
  restore
  blr

###############################################

ConvertBlPointer:
  lwz r4,0x0(r3)        #Load bl instruction
  rlwinm  r4,r4,0,6,29  #extract offset bits
  extsh r4,r4
  add r3,r4,r3
  blr

#endregion
#region ApplyAllGeckoCodes
ApplyAllGeckoCodes:
.set  REG_GObjData,31
.set  REG_Count,30
.set  REG_OptionSelection,29
#Init
  backup
  mr  REG_GObjData,r3

#Default Codes
  bl  DefaultCodes
  mflr  r3
  bl  ApplyGeckoCode

#Init Loop
  li  REG_Count,0
ApplyAllGeckoCodes_Loop:
#Load this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx REG_OptionSelection,r3,REG_Count
#Get this code's gecko code pointers
  bl  CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  ConvertBlPointer
  addi  r3,r3,CodeOptions_GeckoCodePointers
  mulli r4,REG_OptionSelection,0x4
  add  r3,r3,r4
  bl  ConvertBlPointer
  bl  ApplyGeckoCode

ApplyAllGeckoCodes_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  blt ApplyAllGeckoCodes_Loop

ApplyAllGeckoCodes_Exit:
  restore
  blr

####################################

ApplyGeckoCode:
.set  REG_GeckoCode,12
  mr  REG_GeckoCode,r3

ApplyGeckoCode_Loop:
  lbz r3,0x0(REG_GeckoCode)
  cmpwi r3,0xC2
  beq ApplyGeckoCode_C2
  cmpwi r3,0x4
  beq ApplyGeckoCode_04
  cmpwi r3,0xFF
  beq ApplyGeckoCode_Exit
  b ApplyGeckoCode_ExitScene
ApplyGeckoCode_C2:
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
  b ApplyGeckoCode_Loop
ApplyGeckoCode_04:
  lwz r3,0x0(REG_GeckoCode)
  rlwinm r3,r3,0,8,31
  oris  r3,r3,0x8000
  lwz r4,0x4(REG_GeckoCode)
  stw r4,0x0(r3)
  addi REG_GeckoCode,REG_GeckoCode,0x8
  b ApplyGeckoCode_Loop
ApplyGeckoCode_Exit:
blr

#endregion

#endregion

#region MinorSceneStruct
LagPrompt_MinorSceneStruct:
blrl
#Lag Prompt
.byte 0                     #Minor Scene ID
.byte 00                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  LagPrompt_SceneDecide   #SceneDecide
.byte PromptCommonSceneID   #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

Codes_MinorSceneStruct:
blrl
#Codes Prompt
.byte 0                     #Minor Scene ID
.byte 00                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  Codes_SceneDecide       #SceneDecide
.byte CodesCommonSceneID    #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

#endregion

CheckProgressive:
#Check if progressive is enabled
  branchl r12,0x80349278
  cmpwi r3,0
  beq NoProgressive
IsProgressive:
#Override SceneLoad
  li  r3,PromptCommonSceneID
  branchl r12,0x801a4ce0
  bl  LagPrompt_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load LagPrompt
  li	r3, PromptSceneID
  b Exit
NoProgressive:
#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,0x801a4ce0
  bl  Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load Codes
  li  r3,CodesSceneID

Exit:
  restore
