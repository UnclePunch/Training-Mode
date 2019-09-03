#To be inserted at 801bf930
.include "../../Globals.s"

#Overwriting the debug CSS with a lag reduction prompt
#it crashes anyway so nothing of substance is being lost

.set  REG_MinorSceneStruct,31
.set  PromptSceneID,8 #0
.set  NoPromptSceneID,2
.set  SceneType,10
.set  InitialSelection,0

.set  PostRetraceCallback,0x800195fc
.set  UnkPadStruct,0x804329f0

#region Init New Scene
#Init and backup
  backup

#Check if progressive is enabled
  branchl r12,0x80349278
  cmpwi r3,0
  beq NoProgressive

#Get major scene struct
  branchl r12,0x801a50ac
OverrideMajor_Loop:
  lbz	r4, 0x0001 (r3)
  cmpwi r4,PromptSceneID
  beq OverrideMajor_ExitLoop
  addi  r3,r3,20
  b OverrideMajor_Loop
OverrideMajor_ExitLoop:

#Access Minor Scene Struct Pointer
  lwz REG_MinorSceneStruct,0x10(r3)
#Change scenetype to Unused
  li  r3,SceneType
  stb r3,0xC(REG_MinorSceneStruct)
#Override SceneDecide
  bl  LagPrompt_SceneDecide
  mflr  r3
  stw r3,0x8(REG_MinorSceneStruct)
#Override SceneLoad
  li  r3,SceneType
  branchl r12,0x801a4ce0
  bl  LagPrompt_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
  b IsProgressive
#endregion

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
  mflr  REG_GeckoCode
LagPrompt_SceneThink_GeckoCodeApply:
  lbz r3,0x0(REG_GeckoCode)
/*
  cmpwi r3,0xC2
  beq LagPrompt_SceneThink_GeckoCodeApply_C2
*/
  cmpwi r3,0x4
  beq LagPrompt_SceneThink_GeckoCodeApply_04
  cmpwi r3,0xFF
  beq LagPrompt_SceneThink_GeckoCodeApply_Exit
  b LagPrompt_SceneThink_ExitScene
/*
LagPrompt_SceneThink_GeckoCodeApply_C2:
.set  REG_InjectionSite,11
#Branch overwrite
  lwz r5,0x0(REG_GeckoCode)
  rlwinm r3,r5,0,8,31                   #get offset for branch calc
  rlwinm r5,r5,0,8,31
  oris  REG_InjectionSite,r5,0x8000     #get mem address to write to
  addi  r4,REG_GeckoCode,0x8            #get branch destination
  sub r3,r4,REG_InjectionSite           #Difference relative to branch addr
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
  b LagPrompt_SceneThink_GeckoCodeApply
*/
LagPrompt_SceneThink_GeckoCodeApply_04:
  lwz r3,0x0(REG_GeckoCode)
  rlwinm r3,r3,0,8,31
  oris  r3,r3,0x8000
  lwz r4,0x4(REG_GeckoCode)
  stw r4,0x0(r3)
  addi REG_GeckoCode,REG_GeckoCode,0x8
  b LagPrompt_SceneThink_GeckoCodeApply

LagPrompt_SceneThink_GeckoCodeApply_Exit:
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
blrl

  backup

#Leave Major
  branchl r12,0x801a42d4
  li  r3,NoPromptSceneID
  branchl r12,0x801a42e8

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
.long 0x00000000
#endregion

NoProgressive:
  li  r3,NoPromptSceneID
  b Exit
IsProgressive:
  li	r3, PromptSceneID    #load debug CSS scene ID
Exit:
  restore
