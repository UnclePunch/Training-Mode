#To be inserted at 8024d92c
.include "../../Globals.s"

backup

CustomESSThink:
#Check For L
	li	r3,4
	branchl	r12,Inputs_GetPlayerInstantInputs
	rlwinm.	r0, r4, 0, 25, 25			#CHECK FOR L
	bne	OpenFDD
	rlwinm.	r0, r4, 0, 27, 27			#CHECK FOR Z
	bne	OpenOptions

#Check for Tutotial (R)
#Check For Training Mode ISO Game ID First
	lis	r5,0x8000
	lwz	r5,0x0(r5)
	load	r6,0x47544d45			#GTME
	cmpw	r5,r6
	bne	CheckToSwitchPage
#Check for R
	rlwinm.	r0, r4, 0, 26, 26			#CHECK FOR R
	bne	PlayMovie

CheckToSwitchPage:
	li	r3,4
	branchl	r12,Inputs_GetPlayerRapidInputs
#Check For Left
	li	r5,-1
	rlwinm. r0,r3,0,25,25
	bne	SwitchPage
#Check For Right
	li	r5,1
	rlwinm. r0,r3,0,24,24
	bne	SwitchPage
	b	exit

OpenFDD:

	#PLAY SFX
	li	r3, 1
	branchl	r4,0x80024030

	#SET FLAG IN RULES STRUCT
	li	r0,3								#3 = frame data from event toggle
	load	r3,0x804a04f0
	stb	r0, 0x0011 (r3)

	#SET SOMETHING
	li	r0, 5
	sth	r0, -0x4AD8 (r13)

	#BACKUP CURRENT EVENT ID
	lwz	r3, -0x4A40 (r13)
	lwz	r5, 0x002C (r3)
	lbz	r3,0x0(r5)
	lwz	r4,0x4(r5)
	add	r3,r3,r4
	lwz	r4, -0x77C0 (r13)
	stb	r3, 0x0535 (r4)

	#LOAD RSS
	branchl	r3,0x80237410

	#REMOVE EVENT THINK FUNCTION
	lwz	r3, -0x3E84 (r13)
	branchl	r12,0x80390228

	b	exit

OpenOptions:

#Create Background + GObj
	bl	OptionMenu_CreateBackground
#Display Menus Text
	bl	MenuData_MainMenuBlrl
	mflr r4
	bl	OptionMenu_CreateText
#Play SFX
	li	r3,1
	branchl r12,0x80024030
	b	exit

#region OptionMenu_CreateBackground
BG_Constants:
blrl
.set BG_Transparency,0x0
.set BG_ScaleX,0x4
.set BG_ScaleY,0x8
.set BG_TransformX,0xC
.set BG_TransformY,0x10
.set BG_TransformZ,0x14
.set BG_Color,0x18
.float 0.85							#transparency
.float 0.1							#scale X
.float 0.15							#scale Y
.float 8								#X Position
.float 3								#Y position
.float 20								#Z Position
.byte 13, 13, 46, 255		#Color

OptionMenu_CreateBackground:
.set	REG_GObj,20
.set	REG_GObjData,21

backup

#Create Background GObj
  li  r3,6
  li  r4,7
  li  r5,0x80
  branchl r12,GObj_Create
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
#Add Process
	mr	r3,REG_GObj
	bl	OptionMenu_Think
	mflr r4
	li	r5,0
	branchl r12,GObj_AddProc
#Get JObj from archive
  lwz	r3, -0x4AE8 (r13)
  load r4,0x803efa0c
  branchl r12,0x80380358
#Load JObj
  branchl r12,HSD_JObjLoadJoint
#Get child JObj (the black background)
	mr	r22,r3
	lwz r3,0x10(r3)

#Remove parent and child (the message box)
	li	r4,0
	stw r4,0x0c(r3)
	stw r4,0x10(r3)
#Adjust transparency
	lwz r4,0x18(r3)
	lwz r4,0x8(r4)
	lwz r4,0xC(r4)
	bl	BG_Constants
	mflr r5
	lfs f1,BG_Transparency(r5)
	stfs f1,0xC(r4)
#Adjust color
	lwz r6,BG_Color(r5)
	stw r6,0x4(r4)
#Adjust Scale
	lfs f1,BG_ScaleX(r5)
	stfs f1,0x2C(r3)
	lfs f1,BG_ScaleY(r5)
	stfs f1,0x30(r3)
#Adjust Position
	lfs f1,BG_TransformX(r5)
	stfs f1,0x38(r3)
	lfs f1,BG_TransformY(r5)
	stfs f1,0x3C(r3)
	lfs f1,BG_TransformZ(r5)
	stfs f1,0x40(r3)
#Store JObj to GObj
  mr  r5,r22
  mr  r3,REG_GObj
  lbz	r4, -0x3E57 (r13)
  branchl r12,GObj_StorePointerToJObj
#Add GX Link
  mr  r3,REG_GObj
  load r4,0x80391070
  li  r5,7                    #layer id? higher = drawn later
  li  r6,127                  #priority, higher = drawn later
  branchl r12,GObj_AddGXLink

#Return the GObj
	mr	r3,REG_GObj

#Exit
	restore
	blr
#endregion

#region OptionMenu_Think
OptionMenu_Think:
blrl
.set REG_GObj,31
backup

#Backup
	mr	REG_GObj,r3
	lwz	REG_GObjData,0x2C(REG_GObj)

#Disable Event Menu
	li	r3,1
	sth	r3, -0x4AD8 (r13)

#Check for Z and close menu
	li	r3,4
	branchl r12,Inputs_GetPlayerInstantInputs
	rlwinm.	r0, r4, 0, 27, 27			#CHECK FOR Z
	bne	OptionMenu_ThinkDestroy
	rlwinm.	r0, r3, 0, 26, 26			#CHECK FOR Down
	bne OptionMenu_ThinkDown
	rlwinm.	r0, r3, 0, 27, 27			#CHECK FOR Up
	bne OptionMenu_ThinkUp
	rlwinm.	r0, r3, 0, 31, 31			#CHECK FOR A
	bne OptionMenu_ThinkSelect
	rlwinm.	r0, r3, 0, 30, 30			#CHECK FOR B
	bne OptionMenu_ThinkBack
	b	OptionMenu_ThinkExit

OptionMenu_ThinkDown:
#Down one cursor position
	lwz	r3,Cursor(REG_GObjData)
	addi r4,r3,1
#Highlight current cursor
	mr	r3,REG_GObjData
	bl	OptionMenu_AdjustCursor
#Play SFX
	li	r3,2
	branchl r12,0x80024030
	b	OptionMenu_ThinkExit

OptionMenu_ThinkUp:
#Up one cursor position
	lwz	r3,Cursor(REG_GObjData)
	subi r4,r3,1
#Highlight current cursor
	mr	r3,REG_GObjData
	bl	OptionMenu_AdjustCursor
#Play SFX
	li	r3,2
	branchl r12,0x80024030
	b	OptionMenu_ThinkExit

OptionMenu_ThinkSelect:
#Loop through current menu
.set REG_Count,20
.set REG_OptionData,22
.set REG_OptionCount,23
.set REG_MenuData,24
.set REG_Cursor,25
#Init
	li	REG_Count,0														#loop count
	li	REG_OptionCount,0											#Only incremented when an option is found
	lwz	REG_MenuData,MenuData(REG_GObjData)
	lwz	REG_Cursor,Cursor(REG_GObjData)

OptionMenu_ThinkSelect_SearchOptionsLoop:
#Get this option's text
	addi r3,REG_MenuData,MenuData_OptionsStart
	mulli	r4,REG_Count,MenuData_OptionDataLength
	add	REG_OptionData,r3,r4
#Get OnSelectType
	lwz 	r3,MenuData_OnSelectType(REG_OptionData)
	cmpwi	r3,OnSelect_None
	beq	OptionMenu_ThinkSelect_SearchOptionsIncLoop
#Check if this is the desired option
	cmpw REG_OptionCount,REG_Cursor
	beq OptionMenu_ThinkSelect_SelectOption
#Increment Option Count
	addi	REG_OptionCount,REG_OptionCount,1
	b	OptionMenu_ThinkSelect_SearchOptionsIncLoop

OptionMenu_ThinkSelect_SelectOption:
#Play SFX
	li	r3,1
	branchl r12,0x80024030
#Decide Selection Type
	lwz	r3,MenuData_OnSelectType(REG_OptionData)
	cmpwi	r3,OnSelect_Menu
	beq	OptionMenu_ThinkSelect_GetNextMenu
	cmpwi	r3,OnSelect_Function
	beq	OptionMenu_ThinkSelect_GetFunction
	b	OptionMenu_ThinkSelect_SearchOptionsEnd

OptionMenu_ThinkSelect_GetNextMenu:
#Convert bl instruction to mem address
	addi	r4,REG_OptionData,MenuData_OnSelectData
	lwz	r5,0x0(r4)
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
	extsh	r5,r5
  add	r4,r4,r5						#Gets Address in r3
#Create Text
	mr	r3,REG_GObj
	bl	OptionMenu_CreateText
	b	OptionMenu_ThinkSelect_SearchOptionsEnd

OptionMenu_ThinkSelect_GetFunction:
#Convert bl instruction to mem address
	addi	r4,REG_OptionData,MenuData_OnSelectData
	lwz	r5,0x0(r4)
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
	extsh	r5,r5
	cmpwi	r5,0
	beq	OptionMenu_ThinkSelect_NoFunction
  add	r4,r4,r5						#Gets Address in r3
	mtctr	r4
	mr	r3,REG_GObj
	bctrl
	b	OptionMenu_ThinkSelect_SearchOptionsEnd
OptionMenu_ThinkSelect_NoFunction:
#Play Error Sound
  li	r3, 3
  branchl	r12,0x80024030
  li	r3, 3
  branchl	r12,0x80024030
	b	OptionMenu_ThinkSelect_SearchOptionsEnd

OptionMenu_ThinkSelect_SearchOptionsIncLoop:
	addi REG_Count,REG_Count,1
	b	OptionMenu_ThinkSelect_SearchOptionsLoop

OptionMenu_ThinkSelect_SearchOptionsEnd:
	b	OptionMenu_ThinkExit

OptionMenu_ThinkBack:
.set REG_MenuData,24
	lwz	r4,MenuData(REG_GObjData)
#Convert bl instruction to mem address
	addi	r4,r4,MenuData_ReturnMenu
	lwz	r5,0x0(r4)
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
	extsh	r5,r5
	cmpwi	r5,0
	beq OptionMenu_ThinkDestroy
  add	r4,r4,r5						#Gets Address in r4
#Load Prev Menu
	mr	r3,REG_GObj
	bl	OptionMenu_CreateText
#Play SFX
	li	r3,0
	branchl r12,0x80024030
	b	OptionMenu_ThinkExit

OptionMenu_ThinkDestroy:
#Remove text
	lwz	r3,0x2C(REG_GObj)
	lwz	r3,TextGObj(r3)
	branchl r12,Text_RemoveText
#Remove GObj
	mr	r3,REG_GObj
	branchl r12,GObj_Destroy
#Play SFX
	li	r3,0
	branchl r12,0x80024030

OptionMenu_ThinkExit:
	restore
	blr
#endregion

#region OptionMenu_CreateText
TextProperties:
blrl
.set VersionX,0x0
.set VersionY,0x4
.set ZOffset,0x8
.set CanvasScaling,0xC
.set Scale,0x10
.set YOffset,0x14
.set YOffsetAddAfterTitle,0x18
.set HighlightColor,0x1C
.set NonHighlightColor,0x20
.float 120      			#REG_TextGObj X pos
.float -250  					#REG_TextGObj Y pos
.float 21.9     			#Z offset
.float 0.035   				#Canvas Scaling
.float 0.65						#Text scale
.float 30							#Y offset difference
.float 20							#Y Offset to Add After Title
.byte 251,199,57,255		#highlighted color
.byte 170,170,170,255	#nonhighlighted color

OptionMenu_CreateText:
.set REG_MenuData,28
.set REG_GObjData,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GObj Data Struct
.set Cursor,0x0
.set TextGObj,0x4
.set MenuData,0x8

backup

#Backup GObj and MenuData
	lwz	REG_GObjData,0x2C(r3)
	mr	REG_MenuData,r4

#Check if a text gobj already
	lwz r3,TextGObj(REG_GObjData)
	cmpwi r3,0
	beq OptionMenu_CreateText_SkipDestroyOldText
#Destroy
	branchl r12,Text_RemoveText
	li	r3,0
	stw r3,TextGObj(REG_GObjData)
OptionMenu_CreateText_SkipDestroyOldText:

#Store new menudata
	stw	REG_MenuData,MenuData(REG_GObjData)

#GET PROPERTIES TABLE
	bl TextProperties
	mflr REG_TextProp

########################
## Create Text Object ##
########################

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,1
	branchl r12,Text_CreateTextStruct
	stw r3,TextGObj(REG_GObjData)
#BACKUP STRUCT POINTER
	mr REG_TextGObj,r3
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(REG_TextGObj)
#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x0
	stb r4,0x4A(REG_TextGObj)
#Store Base Z Offset
	lfs f1,ZOffset(REG_TextProp) #Z offset
	stfs f1,0x8(REG_TextGObj)
#Scale Canvas Down
  lfs f1,CanvasScaling(REG_TextProp)
  stfs f1,0x24(REG_TextGObj)
  stfs f1,0x28(REG_TextGObj)

OptionMenu_CreateText_PrintOptions:
.set REG_Count,20
.set REG_ASCII,21
.set REG_OptionData,22
.set OFST_LastYPos,0x80
#Init
	li	REG_Count,0									#loop count
	lfs	f1,VersionY(REG_TextProp)		#Last text's Y position
	stfs	f1,OFST_LastYPos(sp)

OptionMenu_CreateText_PrintOptionsLoop:
#Get this option's text
	addi r3,REG_MenuData,MenuData_OptionsStart
	mulli	r4,REG_Count,MenuData_OptionDataLength
	add	REG_OptionData,r3,r4
#Convert bl instruction to mem address
  lwz	r4,0x0(REG_OptionData)		#Get bl Instruction
	extsb	r5,r4										#Check if none left
	cmpwi	r5,-1
	beq OptionMenu_CreateText_PrintOptionsEnd
  rlwinm	r4,r4,0,6,29							#Mask Bits 6-29 (the offset)
	extsh	r4,r4
  add	REG_ASCII,REG_OptionData,r4		#Gets ASCII Address in r3

#Get Y offset
	lfs	f2,OFST_LastYPos(sp)		 	#Y base offset of REG_TextGObj
	lfs	f3,YOffset(REG_TextProp)			#Y offset difference
	fadds	f2,f2,f3
#Check if this is the first option
	cmpwi REG_Count,0
	beq OptionMenu_CreateText_PrintOptions_SkipTitleAdjust
#Check if last option was a title
	lwz	r3,-MenuData_OptionDataLength + MenuData_OnSelectType(REG_OptionData)
	cmpwi	r3,OnSelect_None
	bne	OptionMenu_CreateText_PrintOptions_SkipTitleAdjust
#Move down further
	lfs	f1,YOffsetAddAfterTitle(REG_TextProp)
	fadds	f2,f1,f2

OptionMenu_CreateText_PrintOptions_SkipTitleAdjust:
#Store as last Y position
	stfs	f2,OFST_LastYPos(sp)
#Initialize Subtext
	mr 	r3,REG_TextGObj		#struct pointer
	mr	r4,REG_ASCII			#text
	lfs	f1,VersionX(REG_TextProp) 		#X offset of REG_TextGObj
	branchl r12,0x803a6b98

#Change Text Scale
	mr 	r3,REG_TextGObj		#struct pointer
	mr	r4,REG_Count
	lfs 	f1,Scale(REG_TextProp) 		#X offset of REG_TextGObj
	lfs 	f2,Scale(REG_TextProp)	  	#Y offset of REG_TextGObj
	branchl r12,Text_UpdateSubtextSize

OptionMenu_CreateText_PrintOptionsIncLoop:
	addi REG_Count,REG_Count,1
	b	OptionMenu_CreateText_PrintOptionsLoop

OptionMenu_CreateText_PrintOptionsEnd:

#Reset cursor position
	li	r3,0
#Highlight current cursor
	mr	r4,r3
	mr	r3,REG_GObjData
	bl	OptionMenu_AdjustCursor



#Exit
	restore
	blr
#endregion

#region OptionMenu_AdjustCursor
OptionMenu_AdjustCursor:
.set REG_GObjData,31
.set REG_TextGObj,30
.set REG_Cursor,29
.set REG_TextProp,28

backup

#Backup
	mr	REG_GObjData,r3
	lwz	REG_TextGObj,TextGObj(REG_GObjData)
	mr	REG_Cursor,r4
	bl	TextProperties
	mflr	REG_TextProp

#Change all options to white
OptionMenu_AdjustCursor_ResetColors:
.set REG_Count,20
#Init
	li	REG_Count,0									#loop count
OptionMenu_AdjustCursor_ResetColorsLoop:
#Adjust Subtext
	mr 	r3,REG_TextGObj		#struct pointer
	mr	r4,REG_Count			#subtext text
	addi	r5,REG_TextProp,NonHighlightColor
	branchl r12,Text_ChangeTextColor

OptionMenu_AdjustCursor_ResetColorsIncLoop:
	addi	REG_Count,REG_Count,1
#Get number of subtexts
	lwz	r3,0x64(REG_TextGObj)
	lwz	r3,0xC(r3)
	cmpw REG_Count,r3
	blt OptionMenu_AdjustCursor_ResetColorsLoop

#Ensure this isnt below 0
	cmpwi REG_Cursor,0
	bge OptionMenu_AdjustCursor_SearchOptions
#Adjust to be 0
	li	REG_Cursor,0

#Loop through current menu
OptionMenu_AdjustCursor_SearchOptions:
.set REG_Count,20
.set REG_ASCII,21
.set REG_OptionData,22
.set REG_OptionCount,23
.set REG_MenuData,24
#Init
	li	REG_Count,0									#loop count
	li	REG_OptionCount,0						#Only incremented when an option is found
	lwz	REG_MenuData,MenuData(REG_GObjData)

OptionMenu_AdjustCursor_SearchOptionsLoop:
#Get this option's text
	addi r3,REG_MenuData,MenuData_OptionsStart
	mulli	r4,REG_Count,MenuData_OptionDataLength
	add	REG_OptionData,r3,r4
#Convert bl instruction to mem address
  lwz	r4,0x0(REG_OptionData)		#Get bl Instruction
	extsb	r5,r4										#Check if none left
	cmpwi	r5,-1
	bne	OptionMenu_AdjustCursor_SearchOptionsNotLast
	subi REG_OptionCount,REG_OptionCount,1
OptionMenu_AdjustCursor_SearchOptionsGetLastValidOption:
	subi REG_Count,REG_Count,1
	addi r3,REG_MenuData,MenuData_OptionsStart
	mulli	r4,REG_Count,MenuData_OptionDataLength
	add	REG_OptionData,r3,r4
	lwz	r3,MenuData_OnSelectType(REG_OptionData)
	cmpwi	r3,OnSelect_None
	beq	OptionMenu_AdjustCursor_SearchOptionsGetLastValidOption
	b	OptionMenu_AdjustCursor_SearchOptionsChangeColor
#Get OnSelectType
OptionMenu_AdjustCursor_SearchOptionsNotLast:
	lwz 	r3,MenuData_OnSelectType(REG_OptionData)
	cmpwi	r3,OnSelect_None
	beq	OptionMenu_AdjustCursor_SearchOptionsIncLoop
#Check if this is the desired option
	cmpw REG_OptionCount,REG_Cursor
	beq OptionMenu_AdjustCursor_SearchOptionsChangeColor
#Increment Option Count
	addi	REG_OptionCount,REG_OptionCount,1
	b	OptionMenu_AdjustCursor_SearchOptionsIncLoop

OptionMenu_AdjustCursor_SearchOptionsChangeColor:
#Adjust Subtext
	mr 	r3,REG_TextGObj		#struct pointer
	mr	r4,REG_Count			#subtext text
	addi	r5,REG_TextProp,HighlightColor
	branchl r12,Text_ChangeTextColor

#Update Cursor Position
	stw	REG_OptionCount,Cursor(REG_GObjData)
	b	OptionMenu_AdjustCursor_SearchOptionsEnd

OptionMenu_AdjustCursor_SearchOptionsIncLoop:
	addi REG_Count,REG_Count,1
	b	OptionMenu_AdjustCursor_SearchOptionsLoop

OptionMenu_AdjustCursor_SearchOptionsEnd:
#Exit
	restore
	blr
#endregion

#region MenuData

#MenuData Structure
.set MenuData_ReturnMenu,0x0
.set MenuData_OptionsStart,0x4
	.set MenuData_OptionName,0x0
	.set MenuData_OnSelectType,0x4
	.set MenuData_OnSelectData,0x8
.set MenuData_OptionDataLength,0xC

#OnSelect Definitions
.set OnSelect_None,0
.set OnSelect_Menu,1
.set OnSelect_Function,2

#region Options
MenuData_MainMenuBlrl:
blrl
MenuData_MainMenu:
#Return menu
	.long 0
#Options
	bl	MenuData_MainMenu_OptionsTitleName
	.long	OnSelect_None
	.long 0
#Create Save File
	bl	MenuData_MainMenu_CreateSaveName
	.long	OnSelect_Menu
	bl	MenuData_CreateSave
#Play
	bl	MenuData_MainMenu_PlayCreditsName
	.long	OnSelect_Function
	bl	LoadCredits
	.long -1
.align 2

MenuData_MainMenu_OptionsTitleName:
.string "<Options>"
.align 2
MenuData_MainMenu_PlayCreditsName:
.string "Show Credits"
.align 2
MenuData_MainMenu_CreateSaveName:
.string "Create Save"
.align 2
#endregion
#region Create Save
MenuData_CreateSave:
#Return menu
	bl	MenuData_MainMenu
#Create Save
	bl	MenuData_MainMenu_CreateSaveTitleName
	.long	OnSelect_None
	.long 0
#Play
	bl	MenuData_CreateSave_SlotA
	.long	OnSelect_Function
	bl	CreateSave_SlotA
#Create Save File
	bl	MenuData_CreateSave_SlotB
	.long	OnSelect_Function
	bl	CreateSave_SlotB

#Space
	bl	MenuData_CreateSave_Empty
	.long	OnSelect_None
	.long 0
#Disabled
	bl	MenuData_MainMenu_Disabled
	.long	OnSelect_None
	.long 0

.long -1
.align 2

MenuData_MainMenu_CreateSaveTitleName:
.string "<Create Save>"
.align 2
MenuData_CreateSave_SlotA:
.string "Save to Slot A"
.align 2
MenuData_CreateSave_SlotB:
.string "Save to Slot B"
.align 2
MenuData_CreateSave_Empty:
.string ""
.align 2
MenuData_MainMenu_Disabled:
.string "(Temp Disabled)"
.align 2

CreateSave_SlotA:
	li	r3,0
	b	CreateSave

CreateSave_SlotB:
	li	r3,1
	b	CreateSave
#endregion

#endregion

#region LoadCredits
LoadCredits:
backup

#Load Minor Scene 0x1
	load	r4,SceneController
	li	r3,0x1
	stb	r3,0x4(r4)

#Change Screen
	li	r3,0x1
	stw	r3,0x34(r4)

#Make Previous Major Event CSS So It Returns to Event SS
	load	r4,SceneController
	li	r3,0x2B
	stb	r3,0x2(r4)

#BACKUP CURRENT EVENT ID
	lwz	r3, -0x4A40 (r13)
	lwz	r5, 0x002C (r3)
	lbz	r3,0x0(r5)
	lwz	r4,0x4(r5)
	add	r3,r3,r4
	lwz	r4, -0x77C0 (r13)
	stb	r3, 0x0535 (r4)

#Return To Event SS
	#load	r4,0x804d68b8
	#li	r3,0x7
	#stb	r3,0x0(r4)
	#li	r3,0x2B
	#stb	r3,0x4(r4)

#Overwrite SceneDecide Function So It Doesn't Change Majors
	bl	TempSceneDecide
	mflr	r3
	load	r4,0x803dae44		#Main Menu's Minor Table Pointer
	lwz	r4,0x0(r4)
	stw	r3,0x8(r4)		#Overwrite MainMenu's SceneDecide Temporarily

#Init Name Count Variable
	li	r3,0x0
	stw	r3, -0x4eac (r13)

#Exit
	restore
	blr
#endregion

#region PlayMovie
PlayMovie:
		#Get Events Tutorial
			branchl r12,GetEventTutorialFileName
			mr	r20,r3					#Get Event's Tutorial File Name in r20

			#Get Extension Pointer in r21
			bl	FileSuffixes
			mflr	r21

		##############################
		## Play Movie's Audio Track ##
		##############################

			#Copy To Temp Audio String Space
			load	r22,0x803bb380		#Temp Audio String Space
			addi	r3,r22,0x7		#After the /audio/
			mr	r4,r20		#Movie FileName
			branchl	r12,0x80325a50		#strcpy

			#Get Length of This String Now
			mr	r3,r22
			branchl	r12,0x80325b04

			#Copy .hps to the end of it
			add	r3,r3,r22		#Dest
			mr	r4,r21		#.hps string
			branchl	r12,0x80325a50

			#Check If File Exists
			mr	r3,r22
			branchl	r12,0x8033796c
			cmpwi	r3,-1
			beq	FileNotFound

			#Load Song File
			LoadSongFile:
			mr	r3,r22		#Full Song File Name
			li	r4,127		#Volume?
			li	r5,1		#Unk
			branchl	r12,0x80023ed4


		#####################
		## Load Movie File ##
		#####################

		StartLoadMovieFile:

			#Copy File Name To Temp Space
			load	r22,0x80432058		#Temp File Name Space
			mr	r3,r22		#Destination
			mr	r4,r20		#Movie FileName
			branchl	r12,0x80325a50		#strcpy

			#Get Length of This String Now
			mr	r3,r22		#Destination
			branchl	r12,0x80325b04

			#Copy .mth Suffix
			add	r3,r3,r22		#Dest
			addi	r4,r21,0x8		#.mth string
			branchl	r12,0x80325a50

			#Check If File Exists
			mr	r3,r22
			branchl	r12,0x8033796c
			cmpwi	r3,-1
			beq	FileNotFound

			#PLAY SFX
			li	r3, 1
			branchl	r4,0x80024030

			#Unk Set
			li	r3,0x1
			branchl	r12,0x80024e50

			#Load Movie File
			mr	r3,r22								#File Name
			bl	FramerateDefinition
			mflr r4										#0x803dbfb4 = opening movie fps define
			li	r5,0									#lwz	r5, -0x4A14 (r13)
			load	r6,0x00271000				#li	r6,0		#Frame Buffer Heap Size?
			li	r7,0
			branchl	r12,0x8001f410

		#Set Framerate
			load r3,0x804333e0
			lwz r3,0x18(r3)						#get framerate from mth header
			li	r4,60
			divw r3,r4,r3							#decide how many in game frames per movie frame
			bl	FramerateDefinition
			mflr r4
			stw r3,0x4(r4)						#update fps

			#Unk Unset
			li	r3,0x0
			branchl	r12,0x80024e50



	#Create And Schedule Custom Movie Think Functions

		#Create Camera Think Entity
			li	r3, 13
			li	r4,14
			li	r5,0
			branchl	r12,0x803901f0
		#Attach Camera Think
			mr	r31,r3
			li	r4,640
			li	r5,480
			li	r6,8
			li	r7,0
			branchl	r12,0x801a9dd0
			li	r0,0x800
			stw	r0,0x24(r31)
			li	r0,0x0
			stw	r0,0x20(r31)

		#Create Movie Display Entity
			li	r3, 14
			li	r4,15
			li	r5,0
			branchl	r12,0x803901f0
			mr	r30,r3
			stw	r3, -0x4E48 (r13)
			lbz	r4, -0x3D40 (r13)
			li	r5, 0
			branchl	r12,0x80390a70
		#Attach Display Process
			mr	r3,r30
			load	r4,0x8001f67c
			li	r5,11
			li	r6,0
			branchl	r12,0x8039069c

		#Change Screen Size to Fullscreen
			mr	r3,r30
			li	r4,640
			li	r5,480
			branchl	r12,0x8001f624
			lfs	f0, -0x3680 (rtoc)
			stfs	f0, 0x0010 (r3)
			stfs	f0, 0x0014 (r3)



		#Create Movie Think Entity
			li	r3, 6
			li	r4,7
			li	r5,128
			branchl	r12,0x803901f0
			mr	r29,r3
		#Alloc 10 Bytes
			li	r3,10
			branchl	r12,0x8037f1e4
		#Initliaze Entity
			mr	r6,r3
			mr	r3,r29
			li	r4,0x0
			load	r5,0x8037f1b0
			branchl	r12,0x80390b68
		#Schedule Think
			mr	r3,r29
			bl	MovieThink
			mflr	r4
			li	r5,0x0
			branchl	r12,0x8038fd54
		#Store Display Entity and Camera Entity to the Think Entity
			lwz	r3,0x2C(r29)		#Think's Data
			stw	r31,0x0(r3)		#Camera Entity
			stw	r30,0x4(r3)		#Display Entity

		#REMOVE EVENT THINK FUNCTION
			lwz	r3, -0x3E84 (r13)
			branchl	r12,0x80390228

	b	exit
#endregion
#######################################
FramerateDefinition:
blrl
#This structure is passed through via r4 to the MTH play function
#It contains variable framerate information

#Structure is
# 0x0 = number of frames to use the following fps for
# 0x4 = in game frames per movie frame
.long 1048576
.long 2
#######################################

FileNotFound:

	#PLAY SFX
	li	r3, 3
	branchl	r4,0x80024030

	b	exit

#######################################

TempSceneDecide:
blrl

#Store Back
load	r3,0x801b138c		#Function Address
load	r4,0x803dae44		#Main Menu's Minor Table Pointer
lwz	r4,0x0(r4)
stw	r3,0x8(r4)		#Overwrite MainMenu's SceneDecide

blr

#######################################

MovieThink:
blrl

backup

#Backup Entity Pointer
	mr	r31,r3
	lwz	r30,0x2C(r3)

#Advance Frame
	branchl	r12,0x8001f578

#Check If Movie Is Over
	branchl	r12,0x8001f604
	cmpwi	r3,0x0
	bne	EndMovie

#Check For Button Press
	li	r3, 4
	branchl	r12,0x801a36a0		#All Players Inputs
	andi.	r4,r4,0x1100
	beq	Exit
#PLAY SFX
	li	r3, 1
	branchl	r4,0x80024030
	b	EndMovie

restore
blr


EndMovie:
#Stop Music
	branchl	r12,0x800236dc
#Remove Camera Think Function
	lwz	r3,0x0(r30)		#Camera Entity
	branchl	r12,0x80390228
#Remove Display Process Function
	lwz	r3,0x4(r30)		#Display Entity
	branchl	r12,0x80390228
#Remove This Think Function
	mr	r3,r31
	branchl	r12,0x80390228
#Unload Movie
	branchl	r12,0x8001f800
#Play Menu Music
	lwz	r3, -0x77C0 (r13)
	lbz	r3, 0x1851 (r3)
	branchl	r12,0x80023f28
#Reload Event Match Think
	li	r3, 0
	li	r4, 1
	li	r5, 128
	branchl	r12,0x803901f0
	load	r4,0x8024d864
	li	r5,0
	branchl	r12,0x8038fd54

Exit:
restore
blr

FileSuffixes:
blrl

#.hps
.string ".hps"
.align 2

#.mth
.string ".mth"
.align 2

#######################################

SwitchPage:

#Change page
	lwz r4,MemcardData(r13)
	lbz r3,CurrentEventPage(r4)
	add	r3,r3,r5
	stb r3,CurrentEventPage(r4)
#Check if within page bounds
SwitchPage_CheckHigh:
	cmpwi r3,NumOfPages
	ble SwitchPage_CheckLow
#Stay on current page
	subi r3,r3,1
	stb r3,CurrentEventPage(r4)
	b	exit
SwitchPage_CheckLow:
	cmpwi r3,0
	bge SwitchPage_ChangePage
#Stay on current page
	li	r3,0
	stb r3,CurrentEventPage(r4)
	b	exit

SwitchPage_ChangePage:
#Get Page Name ASCII
	branchl r12,GetCustomEventPageName
#Update Page Name
	mr	r5,r3
	lwz r3,-0x4EB4(r13)
	li	r4,0
	branchl r12,Text_UpdateSubtextContents

#Reset cursor to 0,0
	lwz	r5, -0x4A40 (r13)
	lwz	r5, 0x002C (r5)
	li	r3,0
	stw	r3, 0x0004 (r5)		 #Selection Number
	stb	r3, 0 (r5)		  	 #Page Number

#Redraw Event Text
SwitchPage_DrawEventTextInit:
	li	r29,0							#loop count
	lwz	r3, 0x0004 (r5)		 #Selection Number
	lbz	r4, 0 (r5)		  	 #Page Number
	add r28,r3,r4
SwitchPage_DrawEventTextLoop:
	mr	r3,r29
	add	r4,r29,r28
	branchl r12,0x8024d15c
	addi r29,r29,1
	cmpwi r29,9
	blt SwitchPage_DrawEventTextLoop

#Redraw Event Description
	lwz	r3, -0x4A40 (r13)
	mr	r4,r28
	branchl r12,0x8024d7e0

#Update High Score
	lwz	r3, -0x4A40 (r13)
	li	r4,0
	branchl r12,0x8024d5b0

#Update cursor position
#Get Texture Data
	lwz	r3, -0x4A40 (r13)
	lwz	r3, 0x0028 (r3)
	addi r4,sp,0x40
	li	r5,11
	li	r6,-1
	crclr	6
	branchl r12,0x80011e24
	lwz r3,0x40(sp)
#Change Y offset?
	li	r0,0
	stw r0,0x3C(r3)
#DirtySub
	branchl r12,0x803732e8

#Play SFX
	li	r3,2
	branchl r12,SFX_MenuCommonSound

#######################################

#region CreateSave
CreateSave:
.set MemcardFileList,0x804333c8
.set REG_MemcardSlot,20
backup

#Backup slot
	mr	REG_MemcardSlot,r3

#Backup current Game ID
  addi r3,sp,0xB0
  lis r4,0x8000
  branchl r12,strcpy
#Change Game ID to Melee's
  lis r3,0x8000
  bl  MeleeGameID
  mflr r4
  branchl r12,strcpy

#Get memcard pointer
.set REG_Memcard,30
  lwz	REG_Memcard, -0x77C0 (r13)

###########################
## Create Main Save File ##
###########################

#Check if save file already exists
	mr	r3,REG_MemcardSlot
	load	r6,0x803bab60
	addi	r4, r6, 252
	addi	r5, r6, 20
	load r7,0x8043331C
  branchl r12,0x8001b7e0
  cmpwi r3,0x1
  bne CreateMainSave

DeleteMainSave:
	mr	r3,REG_MemcardSlot
	load	r4,0x803bac5c
	load	r5,0x8043331c
  branchl r12,0x8001ba44
  cmpwi r3,0
  bne SaveError

CreateMainSave:
.set REG_OldSaveBackup,31

#Mod Data Struct (this needs to be in the tournament redirect code)
.set ModOFST_ModDataStart,0x1f24
	.set ModOFST_ModDataKey,0x0
		.set ModOFST_ModDataKeyLength,0x4
	.set ModOFST_ModDataPrefs,ModOFST_ModDataKey + ModOFST_ModDataKeyLength
		.set ModOFST_ModDataPrefsLength,0x18
		.set ModOFST_ModDataLength,ModOFST_ModDataPrefs + ModOFST_ModDataPrefsLength

#Allocate mem to backup current save data to
  load  r3,68144
  branchl r12,HSD_MemAlloc
  mr  REG_OldSaveBackup,r3
#Copy old data here
  mr	r4, REG_Memcard
  load  r5,68144
  branchl r12,memcpy
#Start building exploit
  addi r3,REG_Memcard,0x3190    #destination
  load r4,0xdd064bdd            #data to write
  li  r5,0xD4                   #length to write
  subi r3,r3,4
ExploitFillLoop:
  stwu r4,0x4(r3)
  subi r5,r5,0x4
  cmpwi r5,0
  bgt ExploitFillLoop
#Place LR hijacks
  mr	r3, REG_Memcard
  load  r4,0x804eeac8
  stw r4,0x3230(r3)
  load  r4,0x8045d930
  stw r4,0x3234(r3)
  load  r4,0x804ee8f8
  stw r4,0x3264(r3)
  load  r4,0x8045d930
  stw r4,0x3268(r3)
#Place exploit code for 1.02
  addi r3,REG_Memcard,0x3270             #exploit code destination
  bl  ExploitCode102
  mflr r4
	bl	ExploitCode102_End
	mflr	r5
	sub	r5,r5,r4									#length of code
  branchl r12,memcpy
#Place exploit code for 1.00
  addi r3,REG_Memcard,0x5238             #exploit code destination
  bl  ExploitCode100
  mflr r4
	bl	ExploitCode100_End
	mflr	r5
	sub	r5,r5,r4									#length of code
  branchl r12,memcpy
#Place exploit code for 1.01
  addi r3,REG_Memcard,0x3f50            #exploit code destination
  bl  ExploitCode101
  mflr r4
	bl	ExploitCode101_End
	mflr	r5
	sub	r5,r5,r4									#length of code
  branchl r12,memcpy


#Init Mod Preferences
	addi r3,REG_Memcard,ModOFST_ModDataStart
  li  r4,0x0
  li  r5,ModOFST_ModDataLength
  branchl r12,0x80003100

#Unlock All Messages
  addi r3,REG_Memcard,0x1B4C
  li  r4,0xFF
  li  r5,0x34
  branchl r12,0x80003100
  addi r3,REG_Memcard,0x1C88
	li  r4,0xFF
	li	r5,0x24
  branchl r12,0x80003100

#Unlock All Trophies
	li	r3,0x125
	sth	r3,7376(REG_Memcard)		#unlocked count
	addi	r3,REG_Memcard,7378
	li	r4,0x63
	li	r5,0x24E
	branchl r12,0x80003100

#Only Mewtwo Unlocked
  li  r3,0x8
  stb r3,6249(REG_Memcard)

#Wipe High Scores
  addi r3,REG_Memcard,0x1A70
  li  r4,0
  li  r5,0xCC
  branchl r12,0x80003100
#Set as unplayed
  li  r3,0
  stw r3,0x1A68(REG_Memcard)
  stw r3,0x1A6C(REG_Memcard)

#Create Save
	mr	r3,REG_MemcardSlot
	load	r6,0x803bab60
	addi	r5,r6,20
	addi	r4,r6,252
	bl	MainSaveName
	mflr r7
	load	r10,0x80433318
	lwz	r9,0x5C(r10)
	lwz r8,0x8(r9)					#banner data with flames
	lwz r9,0xC(r9)					#icon data
	addi	r10,r10,4
  branchl r12,0x8001bc18
  cmpwi r3,0
  bne SaveError
#Copy original save data back
  mr	r3, REG_Memcard
  mr  r4,REG_OldSaveBackup
  load  r5,68144
  branchl r12,memcpy
#Free allocation
  mr  r3,REG_OldSaveBackup
  branchl r12,HSD_Free

##########################
## Create Snapshot File ##
##########################

#Update list of present memcard snapshots
  mr	r3,REG_MemcardSlot
  branchl r12,0x80253e90

.set REG_Count,31
.set REG_Index,30
.set REG_SnapshotStruct,29
.set REG_SnapshotID,28
#Check if file exists on card
  load  r3,MemcardFileList                            #go to pointer location
  lwz REG_SnapshotStruct,0x0(r3)                      #access pointer to snapshot file list
	mulli	r3,REG_MemcardSlot,1032
	add	REG_SnapshotStruct,REG_SnapshotStruct,r3
  lwz REG_Index,0x4(REG_SnapshotStruct)               #get number of snapshots present
  addi REG_SnapshotStruct,REG_SnapshotStruct,0x10     #get to snapshot info
  bl  SnapshotID                                      #get ID we are looking for
  mflr r3
  lwz REG_SnapshotID,0x0(r3)
  li  REG_Count,0                                     #init count
SnapshotSearchLoop:
  cmpw REG_Count,REG_Index
  bge SnapshotSearchLoop_NotFound
#Get the next snapshots ID
  mulli r3,REG_Count,0x8          #each snapshots data is 0x8 long
  add r3,r3,REG_SnapshotStruct
  lwz r4,0x0(r3)                  #get the snaps ID
  cmpw r4,REG_SnapshotID
  bne SnapshotSearchLoop_IncLoop
  b SnapshotSearchLoop_Found
SnapshotSearchLoop_IncLoop:
  addi REG_Count,REG_Count,1
  b SnapshotSearchLoop

SnapshotSearchLoop_NotFound:
  b CreateSnapshot

SnapshotSearchLoop_Found:
#Delete Snapshot
  mr	r3,REG_MemcardSlot
  mr  r4,REG_Count
  branchl r12,0x8001d5fc
WaitToDeleteLoop:
  branchl	r12,0x8001b6f8
  cmpwi	r3,0xB
  beq	WaitToDeleteLoop
#If Exists
  cmpwi	r3,0x0
  beq	CreateSnapshot
  cmpwi	r3,0x9
  bne	SaveError

CreateSnapshot:
.set REG_Codeset,31
#Get snap struct
  bl  SnapshotSaveStruct
  mflr r5
#Get codeset length
	bl	SnapshotCode_Start
	mflr	r3
	bl	SnapshotCode_End
	mflr	r4
	sub	r3,r4,r3
  stw r3,0x0(r5)		#Store file size
#Get codeset pointer
	bl	SnapshotCode_Start
	mflr	r3
  stw r3,0x8(r5)

#Load banner and image
#Convert ID to string
  addi r3,sp,0x80
  bl  SnapshotString
  mflr r4
  bl  SnapshotID
  mflr r5
  lwz r5,0x0(r5)
  branchl r12,0x80323cf4
#Create File
  mr	r3,REG_MemcardSlot
  addi r4,sp,0x80       #Snapshot ID
  bl  SnapshotSaveStruct
  mflr r5
  load r6,0x803bacc8
  bl  SnapshotSaveName
  mflr r7
	/*
  load r8,0x80433380
  lwz	r8,0x44(r8)
  lwz	r9,0x4(r8)        #icon data
  lwz	r8,0x0(r8)        #banner data
	*/
	bl	SnapshotBanner
	mflr r8
	bl	SnapshotIcon
	mflr r9
  li  r10,0
  branchl r12,0x8001bb48

WaitToLoadLoop:
  branchl	r12,0x8001b6f8
  cmpwi	r3,0xB
  beq	WaitToLoadLoop
#If Exists
  cmpwi	r3,0x0
  beq	Success
  cmpwi	r3,0x9
  beq	Success
  b	Failure

Success:
  li	r3,0xAA
  branchl	r12,0x801c53ec
  b CreateSnapshot_End

Failure:
#Play Error Sound
  li	r3, 3
  branchl	r12,0x80024030
  li	r3, 3
  branchl	r12,0x80024030
  b CreateSnapshot_End

CreateSnapshot_End:
#Change Game ID back
  lis r3,0x8000
  addi r4,sp,0xB0
  branchl r12,strcpy
  b ExitInjection

SaveError:
#Play Error Sound
  li	r3, 3
  branchl	r12,0x80024030
  li	r3, 3
  branchl	r12,0x80024030
#Change Game ID back
  lis r3,0x8000
  addi r4,sp,0xB0
  branchl r12,strcpy
  b ExitInjection

###################
MainSaveName:
blrl
.ascii "Super Smash Bros. Melee         "
.ascii "MML Launcher (1 of 2)           "
###################
SnapshotID:
blrl
.byte 0x00,0xD0
.ascii "MM"
.align 2
###################
SnapshotString:
blrl
.string "%u"
.align 2
###################
SnapshotSaveStruct:
blrl
.long 0         #File size, will dynamically change based on gct size
.long 3         #Unknown
.long 0         #Pointer to snapshot data, will be stored to during runtime
.long -1        #end of structure
.align 2
###################
SnapshotSaveName:
blrl
.ascii "MultiMod Launcher BETA          "
.ascii "Mod Data (2 of 2)               "
###################
CodeFileName:
blrl
.string "codes.gct"
.align 2
###################
TMGameID:
blrl
.string "GTME01"
.align 2
###################
MeleeGameID:
blrl
.string "GALE01"
.align 2
###################

#region ExploitCode102
ExploitCode102:
blrl
.include "../../Common102.s"
.set REG_SnapLoadResult,31

backup

#Wait for any memcard operation to finish
ExploitCode102_WaitForMemcard:
	branchl	r12,MemoryCard_WaitForFileToFinishSaving
	cmpwi	r3,11
	beq	ExploitCode102_WaitForMemcard

###################
## Load Snapshot ##
###################

#Spoof game ID as NTSC (to load the snapshot file)
#Backup current Game ID
  addi r3,sp,0xB0
  lis r4,0x8000
  branchl r12,strcpy
#Change Game ID to Melee's
  lis r3,0x8000
  bl  ExploitCode102_NTSCGameID
  mflr r4
  branchl r12,strcpy

#Update list of present memcard snapshots
  li  r3,0
  branchl r12,0x80253e90

.set MemcardFileList,0x804333c8
.set REG_Count,31
.set REG_Index,30
.set REG_SnapshotStruct,29
.set REG_SnapshotID,28
#Check if file exists on card
  load  r3,MemcardFileList                            #go to pointer location
  lwz REG_SnapshotStruct,0x0(r3)                      #access pointer to snapshot file list
  lwz REG_Index,0x4(REG_SnapshotStruct)               #get number of snapshots present
  addi REG_SnapshotStruct,REG_SnapshotStruct,0x10     #get to snapshot info
  bl  ExploitCode102_SnapshotIDInt                                      #get ID we are looking for
  mflr r3
  lwz REG_SnapshotID,0x0(r3)
  li  REG_Count,0                                     #init count
ExploitCode102_SnapshotSearchLoop:
  cmpw REG_Count,REG_Index
  bge ExploitCode102_SnapshotSearchLoop_NotFound
#Get the next snapshots ID
  mulli r3,REG_Count,0x8          #each snapshots data is 0x8 long
  add r3,r3,REG_SnapshotStruct
  lwz r4,0x0(r3)                  #get the snaps ID
  cmpw r4,REG_SnapshotID
  bne ExploitCode102_SnapshotSearchLoop_IncLoop
  b ExploitCode102_SnapshotSearchLoop_Found
ExploitCode102_SnapshotSearchLoop_IncLoop:
  addi REG_Count,REG_Count,1
  b ExploitCode102_SnapshotSearchLoop

ExploitCode102_SnapshotSearchLoop_NotFound:
	li	REG_SnapLoadResult,11
  b ExploitCode102_RestoreGameID

ExploitCode102_SnapshotSearchLoop_Found:
.set REG_CodesetSize,31
.set REG_CodesetPointer,30
#Convert blocks to bytes
  lhz r3,0x6(r3)
  mulli REG_CodesetSize,r3,0x2000
#Alloc Space For Snapshot File
  mr  r3,REG_CodesetSize
  branchl	r12,0x8037f1e4			       #HSD_Alloc
  mr  REG_CodesetPointer,r3
  load	r5,0x803bacdc			           #Snapshot Data Struct
  stw	REG_CodesetPointer,0x8(r5)     #Store Pointer to this area

#Remove Pointer To Current Memcard Stuff
  branchl	r12,0x8001c5a4
#Alloc Space For Memcard Stuff
  branchl	r12,0x8001c550

#Load File
  li	r3,0x0		#Slot A?
  bl	ExploitCode102_SnapshotID
  mflr	r4
  load	r5,0x803bacdc		#Snapshot Data Struct
  load	r6,0x80433384		#String Space?
  load	r9,0x80433380
  lwz	r9,0x44(r9)
  lwz	r7,0x0(r9)		#Weird Char Pointer, Maybe Icon Image
  lwz	r8,0x4(r9)		#Banner Image
  li	r9,0		#Unk
  branchl	r12,0x8001bf04
#Store Result
  load	r4,0x804A0B6C
  stw	r3,0x0(r4)

ExploitCode102_WaitToLoadLoop:
  branchl	r12,0x8001b6f8
  cmpwi	r3,0xB
  beq	ExploitCode102_WaitToLoadLoop
#Backup result
	mr	REG_SnapLoadResult,r3
ExploitCode102_RestoreGameID:
#Restore orig Game ID
  lis r3,0x8000
  addi r4,sp,0xB0
  branchl r12,strcpy
#If Exists
  cmpwi	REG_SnapLoadResult,0x0
  beq	ExploitCode102_Success
  b	ExploitCode102_Failure

##############################
ExploitCode102_SnapshotIDInt:
blrl
.byte 0x00,0xD0
.ascii "MM"
.align 2
ExploitCode102_SnapshotID:
blrl
.string "13651277"
.align 2
ExploitCode102_NTSCGameID:
blrl
.string "GALE01"
.align 2
##############################

#############
## Failure ##
#############

ExploitCode102_Failure:
#Play Error Sound
  li	r3, 3
  branchl	r12,0x80024030
  li	r3, 3
  branchl	r12,0x80024030
#Disable Saving
  lis     r4,0x8043
  li     r3,4
  stw    r3,0x3320(r4)    # store 4 to disable memory card saving
b	ExploitCode102_Exit

#############
## Success ##
#############
ExploitCode102_Success:
#flush cache on snapshot code
  mr r3,REG_CodesetPointer
	mr	r4,REG_CodesetSize
  branchl r12,0x80328f50

#Restore this stack frame and jump to the MML code in the snapshot file
	addi	r3,REG_CodesetPointer,0x0
	restore
	mtctr r3
	bctr

ExploitCode102_Exit:
#Store as next scene
	li	r3,0
	load	r4,0x804d68bc
	stb	r3,0x0(r4)
#request to change scenes
	branchl	r12,0x801a4b60

##########
## Exit ##
##########

#Return to the game
  restore
	branch	r12,0x80239e9c

ExploitCode102_End:
blrl
#endregion
#region ExploitCode101
ExploitCode101:
blrl
.include "../../Common101.s"
.set REG_SnapLoadResult,31

backup

#Wait for any memcard operation to finish
ExploitCode101_WaitForMemcard:
	branchl	r12,MemoryCard_WaitForFileToFinishSaving
	cmpwi	r3,11
	beq	ExploitCode101_WaitForMemcard

###################
## Load Snapshot ##
###################

#Spoof game ID as NTSC (to load the snapshot file)
#Backup current Game ID
  addi r3,sp,0xB0
  lis r4,0x8000
  branchl r12,strcpy
#Change Game ID to Melee's
  lis r3,0x8000
  bl  ExploitCode101_NTSCGameID
  mflr r4
  branchl r12,strcpy

#Update list of present memcard snapshots
  li  r3,0
  branchl r12,Snapshot_UpdateFileList

.set REG_Count,30
.set REG_Index,29
.set REG_SnapshotStruct,28
.set REG_SnapshotID,27
#Check if file exists on card
  load  r3,MemcardFileList                            #go to pointer location
  lwz REG_SnapshotStruct,0x48(r3)                      #access pointer to snapshot file list
  lwz REG_Index,0x4(REG_SnapshotStruct)               #get number of snapshots present
  addi REG_SnapshotStruct,REG_SnapshotStruct,0x10     #get to snapshot info
  bl  ExploitCode101_SnapshotIDInt                                      #get ID we are looking for
  mflr r3
  lwz REG_SnapshotID,0x0(r3)
  li  REG_Count,0                                     #init count
ExploitCode101_SnapshotSearchLoop:
  cmpw REG_Count,REG_Index
  bge ExploitCode101_SnapshotSearchLoop_NotFound
#Get the next snapshots ID
  mulli r3,REG_Count,0x8          #each snapshots data is 0x8 long
  add r3,r3,REG_SnapshotStruct
  lwz r4,0x0(r3)                  #get the snaps ID
  cmpw r4,REG_SnapshotID
  bne ExploitCode101_SnapshotSearchLoop_IncLoop
  b ExploitCode101_SnapshotSearchLoop_Found
ExploitCode101_SnapshotSearchLoop_IncLoop:
  addi REG_Count,REG_Count,1
  b ExploitCode101_SnapshotSearchLoop

ExploitCode101_SnapshotSearchLoop_NotFound:
	li	REG_SnapLoadResult,11
  b ExploitCode101_RestoreGameID

ExploitCode101_SnapshotSearchLoop_Found:
.set REG_CodesetSize,30
.set REG_CodesetPointer,29
#Convert blocks to bytes
  lhz r3,0x6(r3)
  mulli REG_CodesetSize,r3,0x2000
#Alloc Space For Snapshot File
  mr  r3,REG_CodesetSize
  branchl	r12,HSD_MemAlloc			       #HSD_Alloc
  mr  REG_CodesetPointer,r3
  load	r5,SnapshotData			           #Snapshot Data Struct
  stw	REG_CodesetPointer,0x1C(r5)     #Store Pointer to this area

#Remove Pointer To Current Memcard Stuff
  branchl	r12,Memcard_FreeSomething
#Alloc Space For Memcard Stuff
  branchl	r12,Memcard_AllocateSomething

#Load File
  li	r3,0x0		#Slot A?
  bl	ExploitCode101_SnapshotID
  mflr	r4
  load	r5,SnapshotData+0x14		#Snapshot Data Struct
  load	r9,MemcardFileList
  addi	r6,r9,0x4
  lwz	r9,0x44(r9)
  lwz	r7,0x0(r9)		#Weird Char Pointer, Maybe Icon Image
  lwz	r8,0x4(r9)		#Banner Image
  li	r9,0		#Unk
  branchl	r12,MemoryCard_ReadDataIntoMemory
#Store Result
  load	r4,SnapshotLoadThinkStruct
  stw	r3,0x15C(r4)

ExploitCode101_WaitToLoadLoop:
  branchl	r12,MemoryCard_WaitForFileToFinishSaving
  cmpwi	r3,0xB
  beq	ExploitCode101_WaitToLoadLoop
#Backup result
	mr	REG_SnapLoadResult,r3
ExploitCode101_RestoreGameID:
#Restore orig Game ID
  lis r3,0x8000
  addi r4,sp,0xB0
  branchl r12,strcpy
#If Exists
  cmpwi	REG_SnapLoadResult,0x0
  beq	ExploitCode101_Success
  b	ExploitCode101_Failure

#########################################
ExploitCode101_SnapshotIDInt:
blrl
.byte 0x00,0xD0
.ascii "MM"
.align 2
ExploitCode101_SnapshotID:
blrl
.string "13651277"
.align 2
ExploitCode101_NTSCGameID:
blrl
.string "GALE01"
.align 2
###########################################


#############
## Failure ##
#############

ExploitCode101_Failure:
#Play Error Sound
  li	r3, 3
  branchl	r12,SFX_MenuCommonSound
  li	r3, 3
  branchl	r12,SFX_MenuCommonSound
#Disable Saving
	load r4,OFST_MemcardController
  li     r3,4
  stw    r3,0x8(r4)    # store 4 to disable memory card saving
	b	ExploitCode101_Exit

#############
## Success ##
#############
ExploitCode101_Success:
#flush cache on snapshot code
  mr r3,REG_CodesetPointer
	mr	r4,REG_CodesetSize
  branchl r12,TRK_flush_cache

#Restore this stack frame and jump to the MML code in the snapshot file
	addi	r3,REG_CodesetPointer,0x4
	restore
	mtctr r3
	bctr

ExploitCode101_Exit:
#Store as next scene
	branchl	r12,Scene_GetMinorSceneData2
	li	r4,0
	stb	r4,0x0(r3)
#request to change scenes
	branchl	r12,MenuController_ChangeScreenMinor

##########
## Exit ##
##########

#Return to the game
  restore
	branch	r12,ExpoitReturnAddr

ExploitCode101_End:
blrl
#endregion
#region ExploitCode100
ExploitCode100:
blrl
.include "../../Common100.s"
.set REG_SnapLoadResult,31

backup

#Wait for any memcard operation to finish
ExploitCode100_WaitForMemcard:
	branchl	r12,MemoryCard_WaitForFileToFinishSaving
	cmpwi	r3,11
	beq	ExploitCode100_WaitForMemcard

###################
## Load Snapshot ##
###################

#Spoof game ID as NTSC (to load the snapshot file)
#Backup current Game ID
  addi r3,sp,0xB0
  lis r4,0x8000
  branchl r12,strcpy
#Change Game ID to Melee's
  lis r3,0x8000
  bl  ExploitCode100_NTSCGameID
  mflr r4
  branchl r12,strcpy

#Update list of present memcard snapshots
  li  r3,0
  branchl r12,Snapshot_UpdateFileList

.set REG_Count,30
.set REG_Index,29
.set REG_SnapshotStruct,28
.set REG_SnapshotID,27
#Check if file exists on card
  load  r3,MemcardFileList                            #go to pointer location
  lwz REG_SnapshotStruct,0x48(r3)                      #access pointer to snapshot file list
  lwz REG_Index,0x4(REG_SnapshotStruct)               #get number of snapshots present
  addi REG_SnapshotStruct,REG_SnapshotStruct,0x10     #get to snapshot info
  bl  ExploitCode100_SnapshotIDInt                                      #get ID we are looking for
  mflr r3
  lwz REG_SnapshotID,0x0(r3)
  li  REG_Count,0                                     #init count
ExploitCode100_SnapshotSearchLoop:
  cmpw REG_Count,REG_Index
  bge ExploitCode100_SnapshotSearchLoop_NotFound
#Get the next snapshots ID
  mulli r3,REG_Count,0x8          #each snapshots data is 0x8 long
  add r3,r3,REG_SnapshotStruct
  lwz r4,0x0(r3)                  #get the snaps ID
  cmpw r4,REG_SnapshotID
  bne ExploitCode100_SnapshotSearchLoop_IncLoop
  b ExploitCode100_SnapshotSearchLoop_Found
ExploitCode100_SnapshotSearchLoop_IncLoop:
  addi REG_Count,REG_Count,1
  b ExploitCode100_SnapshotSearchLoop

ExploitCode100_SnapshotSearchLoop_NotFound:
	li	REG_SnapLoadResult,11
  b ExploitCode100_RestoreGameID

ExploitCode100_SnapshotSearchLoop_Found:
.set REG_CodesetSize,30
.set REG_CodesetPointer,29
#Convert blocks to bytes
  lhz r3,0x6(r3)
  mulli REG_CodesetSize,r3,0x2000
#Alloc Space For Snapshot File
  mr  r3,REG_CodesetSize
  branchl	r12,HSD_MemAlloc			       #HSD_Alloc
  mr  REG_CodesetPointer,r3
  load	r5,SnapshotData			           #Snapshot Data Struct
  stw	REG_CodesetPointer,0x1C(r5)     #Store Pointer to this area

#Remove Pointer To Current Memcard Stuff
  branchl	r12,Memcard_FreeSomething
#Alloc Space For Memcard Stuff
  branchl	r12,Memcard_AllocateSomething

#Load File
  li	r3,0x0		#Slot A?
  bl	ExploitCode100_SnapshotID
  mflr	r4
  load	r5,SnapshotData+0x14		#Snapshot Data Struct
  load	r9,MemcardFileList
  addi	r6,r9,0x4
  lwz	r9,0x44(r9)
  lwz	r7,0x0(r9)		#Weird Char Pointer, Maybe Icon Image
  lwz	r8,0x4(r9)		#Banner Image
  li	r9,0		#Unk
  branchl	r12,MemoryCard_ReadDataIntoMemory
#Store Result
  load	r4,SnapshotLoadThinkStruct
  stw	r3,0x15C(r4)

ExploitCode100_WaitToLoadLoop:
  branchl	r12,MemoryCard_WaitForFileToFinishSaving
  cmpwi	r3,0xB
  beq	ExploitCode100_WaitToLoadLoop
#Backup result
	mr	REG_SnapLoadResult,r3
ExploitCode100_RestoreGameID:
#Restore orig Game ID
  lis r3,0x8000
  addi r4,sp,0xB0
  branchl r12,strcpy
#If Exists
  cmpwi	REG_SnapLoadResult,0x0
  beq	ExploitCode100_Success
  b	ExploitCode100_Failure

#########################################
ExploitCode100_SnapshotIDInt:
blrl
.byte 0x00,0xD0
.ascii "MM"
.align 2
ExploitCode100_SnapshotID:
blrl
.string "13651277"
.align 2
ExploitCode100_NTSCGameID:
blrl
.string "GALE01"
.align 2
###########################################


#############
## Failure ##
#############

ExploitCode100_Failure:
#Play Error Sound
  li	r3, 3
  branchl	r12,SFX_MenuCommonSound
  li	r3, 3
  branchl	r12,SFX_MenuCommonSound
#Disable Saving
	load r4,OFST_MemcardController
  li     r3,4
  stw    r3,0x8(r4)    # store 4 to disable memory card saving
	b	ExploitCode100_Exit

#############
## Success ##
#############
ExploitCode100_Success:
#flush cache on snapshot code
  mr r3,REG_CodesetPointer
	mr	r4,REG_CodesetSize
  branchl r12,TRK_flush_cache

#Restore this stack frame and jump to the MML code in the snapshot file
	addi	r3,REG_CodesetPointer,0x8
	restore
	mtctr r3
	bctr

ExploitCode100_Exit:
#Store as next scene
	branchl	r12,Scene_GetMinorSceneData2
	li	r4,0
	stb	r4,0x0(r3)
#request to change scenes
	branchl	r12,MenuController_ChangeScreenMinor

##########
## Exit ##
##########

#Return to the game
  restore
	branch	r12,ExpoitReturnAddr

ExploitCode100_End:
blrl
#endregion

SnapshotCode_Start:
blrl
b	SnapshotCode102_Start
b	SnapshotCode101_Start
b	SnapshotCode100_Start
b	SnapshotCodePAL_Start

#region SnapshotCode102
SnapshotCode102_Start:
.include "../../Common102.s"
.set	TournamentMode,0x801910E0	#PAL is 80191C24

#First thing to do is relocate ALL of the exploit code to tournament mode
	bl	MMLCode102_End
	mflr	r3
	bl	MMLCode102_Start
	mflr	r4
	sub	r5,r3,r4
	load	r3,TournamentMode
	branchl	r12,memcpy

#Flush cache to ensure these instructions are up to date
  load r3,TournamentMode
	bl	MMLCode102_Start
	mflr	r4
	bl	MMLCode102_End
	mflr	r5
	sub	r4,r5,r4
  branchl r12,0x80328f50

#Now run from the tournament mode code region
	branch	r12,TournamentMode

MMLCode102_Start:
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
#Function Addresses
.set  PostRetraceCallback,0x800195fc
.set  UnkPadStruct,0x804329f0

#region Init New Scenes
.set  REG_MinorSceneStruct,31

#Init and backup
  backup

#/*
#Init LagPrompt major struct
  li  r3,PromptSceneID
  bl  LagPrompt_MinorSceneStruct
  mflr  r4
  bl  LagPrompt_SceneLoad
  mflr  r5
  bl  InitializeMajorSceneStruct
#*/
#Init Codes major struct
  li  r3,CodesSceneID
  bl  Codes_MinorSceneStruct
  mflr  r4
  bl  Codes_SceneLoad
  mflr  r5
  bl  InitializeMajorSceneStruct

#Check if key has been generated yet
	lwz	r20,MemcardData(r13)
	lwz	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
	cmpwi	r3,0
	bne	GenerateKeyEnd
#Generate Key
	lwz	r3, -0x570C (r13)
	lwz	r3,0x0(r3)
	stw	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
GenerateKeyEnd:
  b CheckProgressive

#region PointerConvert
PointerConvert:
  lwz r4,0x0(r3)          #Load bl instruction
  rlwinm r5,r4,8,25,29    #extract opcode bits
  cmpwi r5,0x48           #if not a bl instruction, exit
  bne PointerConvert_Exit
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
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

#/*
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
#Reset some pad variables to cancel the current alarm
  load  r3,UnkPadStruct
  li  r4,0
  stw r4,0x4(r3)
  stw r4,0x44(r3)
#Set new post retrace callback
  load  r3,PostRetraceCallback
  branchl r12,0x80375934
#Enable 480p
	load	r3,ProgressiveStruct
	li	r4,1
	stw	r4,0x8(r3)
#Call VIConfigure
	li	r3,0	#disables deflicker and will enable 480p
	branchl	r12,ScreenDisplay_Adjust
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
.long 0x04019860
.long 0x4BFFFD9D
.long 0x0415FFB8
.long 0x3C808001
.long 0x0415FFBC
.long 0x608395FC
.long 0xFF000000
#endregion

#endregion
#*/
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
.set ModNameX,0x2C
.set ModNameY,0x30
.set ModnameScale,0x34
.set DescriptionX,0x38
.set DescriptionY,0x3C
.set DescriptionZ,0x40
.set DescriptionMaxX,0x44
.set DescriptionUnk,0x48
.set MagicNumber,0x4C
.set Next,0x54

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
.float	0								#Desc Z
.float	560							#Desc Max X
.float	0								#Desc Unk
.long 0x43300000,0x80000000

.set CodeAmount,10
#region Code Names Order
CodeNames_Order:
blrl
bl  CodeNames_UCF
bl  CodeNames_Frozen
bl  CodeNames_Spawns
bl  CodeNames_Wobbling
bl  CodeNames_Ledgegrab
bl	CodeNames_TournamentQoL
bl	CodeNames_FriendliesQoL
bl	CodeNames_GameVersion
bl	CodeNames_StageExpansion
bl	CodeNames_Widescreen
.align 2
#endregion
#region Code Names
CodeNames_Title:
blrl
.string "Select Codes:"
.align 2
CodeNames_ModName:
blrl
.string "MultiMod Launcher v0.6"
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
.string "Disable Wobbling:"
.align 2
CodeNames_Ledgegrab:
.string "Ledgegrab Limit:"
.align 2
CodeNames_TournamentQoL:
.string "Tournament QoL:"
.align 2
CodeNames_FriendliesQoL:
.string "Friendlies QoL:"
.align 2
CodeNames_GameVersion:
.string "Game Version:"
.align 2
CodeNames_StageExpansion:
.string "Stage Expansion:"
.align 2
CodeNames_Widescreen:
.string "Widescreen:"
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
bl	CodeOptions_TournamentQoL
bl  CodeOptions_FriendliesQoL
bl	CodeOptions_GameVersion
bl	CodeOptions_StageExpansion
bl  CodeOptions_Widescreen
.align 2
#endregion
#region Code Options
.set  CodeOptions_OptionCount,0x0
.set	CodeOptions_CodeDescription,0x4
.set  CodeOptions_GeckoCodePointers,0x8
CodeOptions_Wrapper:
	blrl
	.short 0x8183
	.ascii "%s"
	.short 0x8184
	.byte 0
	.align 2
CodeOptions_UCF:
	.long 3 -1           #number of options
	bl	UCF_Description
	bl  UCF_Off
	bl  UCF_On
	bl  UCF_Stealth
	.string "Off"
	.string "On"
	.string "Stealth"
	.align 2
CodeOptions_Frozen:
	.long 3 -1           #number of options
	bl	Frozen_Description
	bl  Frozen_Off
	bl  Frozen_Stadium
	bl  Frozen_All
	.string "Off"
	.string "Stadium Only"
	.string "All"
	.align 2
CodeOptions_Spawns:
	.long 2 -1           #number of options
	bl	Spawns_Description
	bl  Spawns_Off
	bl  Spawns_On
	.string "Off"
	.string "On"
	.align 2
CodeOptions_Wobbling:
	.long 2 -1           #number of options
	bl	DisableWobbling_Description
	bl  DisableWobbling_Off
	bl  DisableWobbling_On
	.string "Off"
	.string "On"
	.align 2
CodeOptions_Ledgegrab:
	.long 2 -1           #number of options
	bl	Ledgegrab_Description
	bl  Ledgegrab_Off
	bl  Ledgegrab_On
	.string "Off"
	.string "On"
	.align 2
CodeOptions_TournamentQoL:
	.long 2 -1           #number of options
	bl	TournamentQoL_Description
	bl  TournamentQoL_Off
	bl  TournamentQoL_On
	.string "Off"
	.string "On"
	.align 2
CodeOptions_FriendliesQoL:
	.long 2 -1           #number of options
	bl	FriendliesQoL_Description
	bl  FriendliesQoL_Off
	bl  FriendliesQoL_On
	.string "Off"
	.string "On"
	.align 2
CodeOptions_GameVersion:
	.long 3 -1           #number of options
	bl	GameVersion_Description
	bl  GameVersion_NTSC
	bl  GameVersion_PAL
	bl  GameVersion_SDR
	.string "NTSC"
	.string "PAL"
	.string "SD Remix"
	.align 2
CodeOptions_StageExpansion:
	.long 2 -1           #number of options
	bl	StageExpansion_Description
	bl  StageExpansion_Off
	bl  StageExpansion_On
	.string "Off"
	.string "On"
	.align 2
CodeOptions_Widescreen:
	.long 3 -1           #number of options
	bl	Widescreen_Description
	bl  Widescreen_Off
	bl  Widescreen_Standard
	bl	Widescreen_True
	.string "Off"
	.string "Standard"
	.string "True"
	.align 2
#endregion
#region Gecko Codes
DefaultCodes:
  blrl
	.long 0xC201AE8C
	.long 0x00000004
	.long 0x2C190002
	.long 0x41800014
	.long 0x2C190008
	.long 0x4181000C
	.long 0x38000000
	.long 0x48000008
	.long 0x801F00F4
	.long 0x00000000
	.long 0xC201C7F8
	.long 0x0000000A
	.long 0x4800000D
	.long 0x7C8802A6
	.long 0x48000040
	.long 0x4E800021
	.long 0x53757065
	.long 0x7220536D
	.long 0x61736820
	.long 0x42726F73
	.long 0x2E204D65
	.long 0x6C656520
	.long 0x20202020
	.long 0x20202020
	.long 0x4D756C74
	.long 0x694D6F64
	.long 0x204C6175
	.long 0x6E636865
	.long 0x72204245
	.long 0x54410000
	.long 0x60000000
	.long 0x00000000
	.long 0x04397878
	.long 0x4800020C
	.long 0xC222D638
	.long 0x00000023
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7D1B78
	.long 0x3C600001
	.long 0x60630000
	.long 0x3D808037
	.long 0x618CF1E4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C7F1B78
	.long 0x808D8840
	.long 0x3CA00001
	.long 0x60A50A30
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3D808001
	.long 0x618CB6F8
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03000B
	.long 0x4182FFEC
	.long 0x38600000
	.long 0x3C80803B
	.long 0x6084AC5C
	.long 0x3CA0803B
	.long 0x60A5AB74
	.long 0x3CC08043
	.long 0x60C6331C
	.long 0x3D808001
	.long 0x618CBD34
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x40820020
	.long 0x806D8840
	.long 0x80631F24
	.long 0x809F1F24
	.long 0x7C032000
	.long 0x4082000C
	.long 0x3BC00009
	.long 0x4800000C
	.long 0x3BC00002
	.long 0x48000004
	.long 0x806D8840
	.long 0x7FE4FB78
	.long 0x3CA00001
	.long 0x60A50A30
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FE3FB78
	.long 0x3D808037
	.long 0x618CF1B0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FC3F378
	.long 0x48000004
	.long 0x7FA4EB78
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x7C601B78
	.long 0x7C832378
	.long 0x00000000
	.long 0x041BFA1C
	.long 0x60000000
	.long 0x04479D40
	.long 0x00000000
	.long 0x041A4234
	.long 0x60000000
	.long 0x041A4258
	.long 0x38600000
	.long 0x0445BF18
	.long 0x08010100
	.long 0x0445BF10
	.long 0x00340102
	.long 0x0445C370
	.long 0xFF000000
	.long 0x0445C388
	.long 0xE70000B0
	.long 0x0445BF14
	.long 0x04000A00
	.long 0x0445BF18
	.long 0x08010100
	.long 0x04164B14
	.long 0x38600001
	.long 0x041648F4
	.long 0x38600001
	.long 0x04164658
	.long 0x38600001
	.long 0x041644E8
	.long 0x38600001
	.long -1

UCF_Off:
	.long 0x040C9A44
	.long 0xD01F002C
	.long 0x040998A4
	.long 0x8083002C
	.long 0x042662D0
	.long 0x38980000
  .long 0xFF000000
UCF_On:
	.long 0xC20C9A44
	.long 0x0000002B
	.long 0xD01F002C
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x48000121
	.long 0x7FC802A6
	.long 0xC03F0894
	.long 0xC05E0000
	.long 0xFC011040
	.long 0x40820118
	.long 0x808DAEB4
	.long 0xC03F0620
	.long 0xFC200A10
	.long 0xC044003C
	.long 0xFC011040
	.long 0x41800100
	.long 0x887F0670
	.long 0x2C030002
	.long 0x408000F4
	.long 0x887F221F
	.long 0x54600739
	.long 0x408200E8
	.long 0x3C60804C
	.long 0x60631F78
	.long 0x8BA30001
	.long 0x387DFFFE
	.long 0x889F0618
	.long 0x4800008D
	.long 0x7C7C1B78
	.long 0x7FA3EB78
	.long 0x889F0618
	.long 0x4800007D
	.long 0x7C7C1850
	.long 0x7C6319D6
	.long 0x2C0315F9
	.long 0x408100B0
	.long 0x38000001
	.long 0x901F2358
	.long 0x901F2340
	.long 0x809F0004
	.long 0x2C04000A
	.long 0x40A20098
	.long 0x887F000C
	.long 0x38800001
	.long 0x3D808003
	.long 0x618C418C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x41820078
	.long 0x8083002C
	.long 0x80841ECC
	.long 0xC03F002C
	.long 0xD0240018
	.long 0xC05E0004
	.long 0xFC011040
	.long 0x4181000C
	.long 0x38600080
	.long 0x48000008
	.long 0x3860007F
	.long 0x98640006
	.long 0x48000048
	.long 0x7C852378
	.long 0x3863FFFF
	.long 0x2C030000
	.long 0x40800008
	.long 0x38630005
	.long 0x3C808046
	.long 0x6084B108
	.long 0x1C630030
	.long 0x7C841A14
	.long 0x1C65000C
	.long 0x7C841A14
	.long 0x88640002
	.long 0x7C630774
	.long 0x4E800020
	.long 0x4E800021
	.long 0x40000000
	.long 0x00000000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x60000000
	.long 0x00000000
	.long 0xC20998A4
	.long 0x00000026
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7E1B78
	.long 0x83FE002C
	.long 0x480000DD
	.long 0x7FA802A6
	.long 0xC03F063C
	.long 0x806DAEB4
	.long 0xC0030314
	.long 0xFC010040
	.long 0x408100E4
	.long 0xC03F0620
	.long 0x48000071
	.long 0xD0210090
	.long 0xC03F0624
	.long 0x48000065
	.long 0xC0410090
	.long 0xEC4200B2
	.long 0xEC210072
	.long 0xEC21102A
	.long 0xC05D000C
	.long 0xFC011040
	.long 0x418000B4
	.long 0x889F0670
	.long 0x2C040003
	.long 0x408100A8
	.long 0xC01D0010
	.long 0xC03F0624
	.long 0xFC000840
	.long 0x40800098
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x8061001C
	.long 0x83E10014
	.long 0x38210018
	.long 0x38630008
	.long 0x7C6803A6
	.long 0x4E800020
	.long 0xFC000A10
	.long 0xC03D0000
	.long 0xEC000072
	.long 0xC03D0004
	.long 0xEC000828
	.long 0xFC00001E
	.long 0xD8010080
	.long 0x80610084
	.long 0x38630002
	.long 0x3C004330
	.long 0xC85D0014
	.long 0x6C638000
	.long 0x90010080
	.long 0x90610084
	.long 0xC8210080
	.long 0xEC011028
	.long 0xC03D0000
	.long 0xEC200824
	.long 0x4E800020
	.long 0x4E800021
	.long 0x42A00000
	.long 0x37270000
	.long 0x43300000
	.long 0x3F800000
	.long 0xBF4CCCCD
	.long 0x43300000
	.long 0x80000000
	.long 0x7FC3F378
	.long 0x7FE4FB78
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x00000000
	.long 0xC22662D0
	.long 0x0000001B
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x48000089
	.long 0x7FC802A6
	.long 0x38600000
	.long 0x38800000
	.long 0x3DC0803A
	.long 0x61CE6754
	.long 0x7DC903A6
	.long 0x4E800421
	.long 0x7C7F1B78
	.long 0x38800001
	.long 0x989F0049
	.long 0x38800001
	.long 0x989F004A
	.long 0xC03E000C
	.long 0xD03F0024
	.long 0xD03F0028
	.long 0x7FE3FB78
	.long 0x48000059
	.long 0x7C8802A6
	.long 0xC03E0000
	.long 0xC05E0004
	.long 0x3DC0803A
	.long 0x61CE6B98
	.long 0x7DC903A6
	.long 0x4E800421
	.long 0x7C641B78
	.long 0x7FE3FB78
	.long 0xC03E0008
	.long 0xC05E0008
	.long 0x3D80803A
	.long 0x618C7548
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000028
	.long 0x4E800021
	.long 0x42180000
	.long 0xC3898000
	.long 0x3EE66666
	.long 0x3DCCCCCD
	.long 0x4E800021
	.long 0x55434620
	.long 0x302E3734
	.long 0x00000000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x38980000
	.long 0x60000000
	.long 0x00000000
  .long 0xFF000000
UCF_Stealth:
	.long 0xC20C9A44
	.long 0x0000002B
	.long 0xD01F002C
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x48000121
	.long 0x7FC802A6
	.long 0xC03F0894
	.long 0xC05E0000
	.long 0xFC011040
	.long 0x40820118
	.long 0x808DAEB4
	.long 0xC03F0620
	.long 0xFC200A10
	.long 0xC044003C
	.long 0xFC011040
	.long 0x41800100
	.long 0x887F0670
	.long 0x2C030002
	.long 0x408000F4
	.long 0x887F221F
	.long 0x54600739
	.long 0x408200E8
	.long 0x3C60804C
	.long 0x60631F78
	.long 0x8BA30001
	.long 0x387DFFFE
	.long 0x889F0618
	.long 0x4800008D
	.long 0x7C7C1B78
	.long 0x7FA3EB78
	.long 0x889F0618
	.long 0x4800007D
	.long 0x7C7C1850
	.long 0x7C6319D6
	.long 0x2C0315F9
	.long 0x408100B0
	.long 0x38000001
	.long 0x901F2358
	.long 0x901F2340
	.long 0x809F0004
	.long 0x2C04000A
	.long 0x40A20098
	.long 0x887F000C
	.long 0x38800001
	.long 0x3D808003
	.long 0x618C418C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x41820078
	.long 0x8083002C
	.long 0x80841ECC
	.long 0xC03F002C
	.long 0xD0240018
	.long 0xC05E0004
	.long 0xFC011040
	.long 0x4181000C
	.long 0x38600080
	.long 0x48000008
	.long 0x3860007F
	.long 0x98640006
	.long 0x48000048
	.long 0x7C852378
	.long 0x3863FFFF
	.long 0x2C030000
	.long 0x40800008
	.long 0x38630005
	.long 0x3C808046
	.long 0x6084B108
	.long 0x1C630030
	.long 0x7C841A14
	.long 0x1C65000C
	.long 0x7C841A14
	.long 0x88640002
	.long 0x7C630774
	.long 0x4E800020
	.long 0x4E800021
	.long 0x40000000
	.long 0x00000000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x60000000
	.long 0x00000000
	.long 0xC20998A4
	.long 0x00000024
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7E1B78
	.long 0x83FE002C
	.long 0x480000D1
	.long 0x7FA802A6
	.long 0xC03F063C
	.long 0x806DAEB4
	.long 0xC0030314
	.long 0xFC010040
	.long 0x408100D4
	.long 0xC01F0620
	.long 0xFC000210
	.long 0xC03D0000
	.long 0xEC000072
	.long 0xC03D0004
	.long 0xEC000828
	.long 0xC03D000C
	.long 0xEC00082A
	.long 0xC03D0000
	.long 0xEC000824
	.long 0xFC600090
	.long 0xC01F0624
	.long 0xFC000210
	.long 0xC03D0000
	.long 0xEC000072
	.long 0xC03D0004
	.long 0xEC000828
	.long 0xC03D000C
	.long 0xEC00082A
	.long 0xC03D0000
	.long 0xEC000824
	.long 0xFC201890
	.long 0xEC210072
	.long 0xEC000032
	.long 0xEC00082A
	.long 0xC03D0010
	.long 0xFC000840
	.long 0x41800064
	.long 0x889F0670
	.long 0x2C040003
	.long 0x40810058
	.long 0xC01D0014
	.long 0xC03F0624
	.long 0xFC000840
	.long 0x40800048
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x8061001C
	.long 0x83E10014
	.long 0x38210018
	.long 0x38630008
	.long 0x7C6803A6
	.long 0x4E800020
	.long 0x4E800021
	.long 0x42A00000
	.long 0x37270000
	.long 0x43300000
	.long 0x40000000
	.long 0x3F800000
	.long 0xBF4CCCCD
	.long 0x7FC3F378
	.long 0x7FE4FB78
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x00000000
	.long 0xFF000000

Frozen_Off:
	.long 0x043e67e0
	.long 0x00000002
	.long 0x0421AAE4
	.long 0x48000805
	.long 0x041D1548
	.long 0x48003001
	.long 0x041E3348
	.long 0x480000D1
	.long 0xFF000000
Frozen_Stadium:
	.long 0x041D1548
	.long 0x60000000
	.long 0xFF000000
Frozen_All:
	.long 0x041D1548
	.long 0x60000000
	.long 0x043e67e0
	.long 0x00000000
	.long 0x041E3348
	.long 0x60000000
	.long 0x0421AAE4
	.long 0x60000000
	.long 0xFF000000

Spawns_Off:
  .long 0x0416E510
  .long 0x881f24d0
  .long 0xFF000000
Spawns_On:
	.long 0xC216E510
	.long 0x00000096
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x3D808016
	.long 0x618CB41C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x40820470
	.long 0x2C1C0005
	.long 0x40800468
	.long 0x887F24D0
	.long 0x2C030001
	.long 0x41820054
	.long 0x3B200000
	.long 0x3B400000
	.long 0x7F43D378
	.long 0x3D808003
	.long 0x618C241C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030003
	.long 0x41820010
	.long 0x7C1CD000
	.long 0x41820014
	.long 0x3B390001
	.long 0x3B5A0001
	.long 0x2C1A0004
	.long 0x4081FFD0
	.long 0x7F83E378
	.long 0x7F24CB78
	.long 0x88BF24D0
	.long 0x48000115
	.long 0x4800040C
	.long 0x3B400000
	.long 0x3B000000
	.long 0x3B200000
	.long 0x7F23CB78
	.long 0x3D808003
	.long 0x618C241C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030003
	.long 0x41820024
	.long 0x7F23CB78
	.long 0x3D808003
	.long 0x618C3370
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C03D000
	.long 0x40820008
	.long 0x3B180001
	.long 0x3B390001
	.long 0x2C190004
	.long 0x4180FFBC
	.long 0x2C180001
	.long 0x418203B0
	.long 0x2C180002
	.long 0x418103A8
	.long 0x3B5A0001
	.long 0x2C1A0003
	.long 0x4180FF98
	.long 0x3B200000
	.long 0x3B410080
	.long 0x3B000000
	.long 0x3AC00000
	.long 0x3AE00000
	.long 0x7EE3BB78
	.long 0x3D808003
	.long 0x618C241C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030003
	.long 0x41820028
	.long 0x7EE3BB78
	.long 0x3D808003
	.long 0x618C3370
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C03C800
	.long 0x4082000C
	.long 0x7EF8D1AE
	.long 0x3B180001
	.long 0x3AF70001
	.long 0x2C170004
	.long 0x4180FFB8
	.long 0x3B390001
	.long 0x2C190003
	.long 0x4180FFA4
	.long 0x3B200000
	.long 0x7C79D0AE
	.long 0x7C03E000
	.long 0x41820010
	.long 0x3B390001
	.long 0x2C190004
	.long 0x4180FFEC
	.long 0x7F83E378
	.long 0x7F24CB78
	.long 0x88BF24D0
	.long 0x48000009
	.long 0x48000300
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7F1B78
	.long 0x7C9E2378
	.long 0x7CBD2B78
	.long 0x48000139
	.long 0x7F8802A6
	.long 0x80CD9348
	.long 0x38A00000
	.long 0x807C0000
	.long 0x2C03FFFF
	.long 0x4182005C
	.long 0x7C033000
	.long 0x4182000C
	.long 0x3B9C0044
	.long 0x4BFFFFE8
	.long 0x3B9C0004
	.long 0x1C7D0020
	.long 0x7F9C1A14
	.long 0x1C7E0008
	.long 0x7F9C1A14
	.long 0x38810080
	.long 0xC03C0000
	.long 0xD0240000
	.long 0xC03C0004
	.long 0xD0240004
	.long 0x38600000
	.long 0x90640008
	.long 0x7FE3FB78
	.long 0x3D808003
	.long 0x618C2768
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000054
	.long 0x2C1D0001
	.long 0x4182000C
	.long 0x7FC3F378
	.long 0x48000014
	.long 0x48000255
	.long 0x7C6802A6
	.long 0x7C63F0AE
	.long 0x48000004
	.long 0x38810080
	.long 0x3D808022
	.long 0x618C4E64
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FE3FB78
	.long 0x38810080
	.long 0x3D808003
	.long 0x618C2768
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000004
	.long 0x7FE3FB78
	.long 0x38810080
	.long 0x3D808003
	.long 0x618C26CC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0xC0210080
	.long 0xC002A8E8
	.long 0xFC010040
	.long 0x4081000C
	.long 0xC022A8F8
	.long 0x48000008
	.long 0xC022A8CC
	.long 0x7FE3FB78
	.long 0x3D808003
	.long 0x618C3094
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FE3FB78
	.long 0x1C9E0005
	.long 0x3D808003
	.long 0x618C5FDC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x4E800020
	.long 0x4E800021
	.long 0x00000020
	.long 0xC2700000
	.long 0x41200000
	.long 0x42700000
	.long 0x41200000
	.long 0xC1A00000
	.long 0x41200000
	.long 0x41A00000
	.long 0x41200000
	.long 0xC1A00000
	.long 0x41200000
	.long 0xC2700000
	.long 0x41200000
	.long 0x41A00000
	.long 0x41200000
	.long 0x42700000
	.long 0x41200000
	.long 0x0000001F
	.long 0xC21B3333
	.long 0x420CCCCD
	.long 0x421B3333
	.long 0x420CCCCD
	.long 0x00000000
	.long 0x41000000
	.long 0x00000000
	.long 0x4279999A
	.long 0xC21B3333
	.long 0x420CCCCD
	.long 0xC21B3333
	.long 0x40A00000
	.long 0x421B3333
	.long 0x420CCCCD
	.long 0x421B3333
	.long 0x40A00000
	.long 0x00000008
	.long 0xC2280000
	.long 0x41D4CCCD
	.long 0x42280000
	.long 0x41E00000
	.long 0x00000000
	.long 0x423B999A
	.long 0x00000000
	.long 0x409CCCCD
	.long 0xC2280000
	.long 0x41D4CCCD
	.long 0xC2280000
	.long 0x40A00000
	.long 0x42280000
	.long 0x41E00000
	.long 0x42280000
	.long 0x40A00000
	.long 0x0000001C
	.long 0xC23A6666
	.long 0x4214CCCD
	.long 0x423D999A
	.long 0x42153333
	.long 0x00000000
	.long 0x40E00000
	.long 0x00000000
	.long 0x426A0000
	.long 0xC23A6666
	.long 0x4214CCCD
	.long 0xC23A6666
	.long 0x40A00000
	.long 0x423D999A
	.long 0x42153333
	.long 0x423D999A
	.long 0x40A00000
	.long 0x00000002
	.long 0xC2250000
	.long 0x41A80000
	.long 0x42250000
	.long 0x41D80000
	.long 0x00000000
	.long 0x40A80000
	.long 0x00000000
	.long 0x42400000
	.long 0xC2250000
	.long 0x41A80000
	.long 0xC2250000
	.long 0x40A00000
	.long 0x42250000
	.long 0x41D80000
	.long 0x42250000
	.long 0x40A00000
	.long 0x00000003
	.long 0xC2200000
	.long 0x42000000
	.long 0x42200000
	.long 0x42000000
	.long 0x428C0000
	.long 0x40E00000
	.long 0xC28C0000
	.long 0x40E00000
	.long 0xC2200000
	.long 0x42000000
	.long 0xC2200000
	.long 0x40A00000
	.long 0x42200000
	.long 0x42000000
	.long 0x42200000
	.long 0x40A00000
	.long 0xFFFFFFFF
	.long 0x4E800021
	.long 0x00030102
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x881F24D0
	.long 0x60000000
	.long 0x00000000
	.long -1

DisableWobbling_Off:
	.long 0x040DA9DC
	.long 0xC02296E8
	.long 0x0408F090
	.long 0x801B0010
  .long 0xFF000000
DisableWobbling_On:
	.long 0xC20DA9DC
	.long 0x00000003
	.long 0x38600000
	.long 0x987C2350
	.long 0x3860FFFF
	.long 0xB07C2352
	.long 0xC02296E8
	.long 0x00000000
	.long 0xC208F090
	.long 0x00000017
	.long 0x807B0010
	.long 0x2C0300DF
	.long 0x418000A4
	.long 0x2C0300E4
	.long 0x4181009C
	.long 0x807B1A58
	.long 0x2C030000
	.long 0x41820090
	.long 0x8063002C
	.long 0x88832222
	.long 0x5484077B
	.long 0x41820080
	.long 0x8863000C
	.long 0x38800001
	.long 0x3D808003
	.long 0x618C418C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x41820060
	.long 0x809B1868
	.long 0x7C032000
	.long 0x40820054
	.long 0x80A3002C
	.long 0xA0652088
	.long 0xA09B2352
	.long 0x7C032000
	.long 0x41820040
	.long 0xB07B2352
	.long 0x887B2350
	.long 0x38630001
	.long 0x987B2350
	.long 0x2C030003
	.long 0x41800028
	.long 0x807B1A58
	.long 0x3D80800D
	.long 0x618CA698
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3D808008
	.long 0x618CF0C8
	.long 0x7D8903A6
	.long 0x4E800420
	.long 0x801B0010
	.long 0x60000000
	.long 0x00000000
  .long 0xFF000000

Ledgegrab_Off:
	.long 0x0416EBD8
	.long 0x98030006
	.long 0x041B0498
	.long 0x98030000
	.long 0x041B05CC
	.long 0x3800012c
	.long 0x041B05C8
	.long 0x38c00001
  .long 0x04165c48
  .long 0x8803000f
	.long 0x041A5E90
	.long 0x7fe3fb78
  .long 0xFF000000
Ledgegrab_On:
	.long 0xC21A5E90
	.long 0x00000002
	.long 0x386000B4
	.long 0x907F0010
	.long 0x7FE3FB78
	.long 0x00000000
	.long 0x0416EBD8
	.long 0x60000000
	.long 0x041B0498
	.long 0x60000000
	.long 0x041B05CC
	.long 0x38000000
	.long 0x041B05C8
	.long 0x38C00001
	.long 0xC2165C48
	.long 0x0000005C
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBC610008
	.long 0x7C7F1B78
	.long 0x887F0004
	.long 0x2C030001
	.long 0x408202AC
	.long 0x3BC10080
	.long 0x3BA00000
	.long 0x38600000
	.long 0x907E0000
	.long 0x907E0004
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x88640058
	.long 0x2C030003
	.long 0x41820028
	.long 0x8864005D
	.long 0x2C030000
	.long 0x4082001C
	.long 0x887E0000
	.long 0x38630001
	.long 0x987E0000
	.long 0x389E0001
	.long 0x3863FFFF
	.long 0x7FA321AE
	.long 0x3BBD0001
	.long 0x2C1D0006
	.long 0x4180FFC0
	.long 0x887E0000
	.long 0x2C030001
	.long 0x40810118
	.long 0x3BA00000
	.long 0x387E0001
	.long 0x7C63E8AE
	.long 0x3D808003
	.long 0x618C42B4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C7C1B78
	.long 0x3B600000
	.long 0x7C1BE800
	.long 0x4182002C
	.long 0x387E0001
	.long 0x7C63D8AE
	.long 0x3D808003
	.long 0x618C42B4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C03E000
	.long 0x4080000C
	.long 0x7F7DDB78
	.long 0x4BFFFFB4
	.long 0x3B7B0001
	.long 0x887E0000
	.long 0x7C1B1800
	.long 0x4180FFC4
	.long 0x4800000C
	.long 0x3BBD0001
	.long 0x4BFFFF98
	.long 0x3B600000
	.long 0x387E0001
	.long 0x7C83D8AE
	.long 0x1C6400A8
	.long 0x7C63FA14
	.long 0x38BE0001
	.long 0x7CA5E8AE
	.long 0x7C042800
	.long 0x4182000C
	.long 0x38800001
	.long 0x48000008
	.long 0x38800000
	.long 0x9883005D
	.long 0x9883005E
	.long 0x3B7B0001
	.long 0x887E0000
	.long 0x7C1B1800
	.long 0x4180FFC0
	.long 0x3B600000
	.long 0x387E0001
	.long 0x7F43D8AE
	.long 0x387E0001
	.long 0x7C63E8AE
	.long 0x7C1A1800
	.long 0x41820034
	.long 0x7F43D378
	.long 0x3D808003
	.long 0x618C42B4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C03E000
	.long 0x40820018
	.long 0x1C7A00A8
	.long 0x7C63FA14
	.long 0x38800000
	.long 0x9883005D
	.long 0x9883005E
	.long 0x3B7B0001
	.long 0x887E0000
	.long 0x7C1B1800
	.long 0x4180FFAC
	.long 0x3BA00000
	.long 0x3B800000
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x88640058
	.long 0x2C030003
	.long 0x41820030
	.long 0x8864005D
	.long 0x2C030000
	.long 0x40820024
	.long 0x7FA3EB78
	.long 0x3D808004
	.long 0x618C0AF0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03003C
	.long 0x41800008
	.long 0x3B9C0001
	.long 0x3BBD0001
	.long 0x2C1D0006
	.long 0x4180FFB8
	.long 0x2C1C0001
	.long 0x418100D8
	.long 0x2C1C0000
	.long 0x418200D0
	.long 0x3BA00000
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x88640058
	.long 0x2C030003
	.long 0x4182004C
	.long 0x8864005D
	.long 0x2C030000
	.long 0x41820010
	.long 0x2C030001
	.long 0x41820008
	.long 0x48000034
	.long 0x7FA3EB78
	.long 0x3D808004
	.long 0x618C0AF0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03003C
	.long 0x40800018
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x38600000
	.long 0x9864005D
	.long 0x9864005E
	.long 0x3BBD0001
	.long 0x2C1D0006
	.long 0x4180FF9C
	.long 0x3BA00000
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x88640058
	.long 0x2C030003
	.long 0x41820040
	.long 0x8864005D
	.long 0x2C030000
	.long 0x40820034
	.long 0x7FA3EB78
	.long 0x3D808004
	.long 0x618C0AF0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03003C
	.long 0x41800018
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x38600001
	.long 0x9864005D
	.long 0x9864005E
	.long 0x3BBD0001
	.long 0x2C1D0006
	.long 0x4180FFA8
	.long 0xB8610008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x8803000F
	.long 0x00000000
  .long 0xFF000000

TournamentQoL_Off:
	.long 0x04266CE0
	.long 0x38600001
	.long 0x042FCCD8
	.long 0x281E0000
	.long 0x0425B8BC
	.long 0x38600001
	.long 0x0445C380
	.long 0x01010101
	.long 0x042608D8
	.long 0x889F0004
	.long 0x042605FC
	.long 0x38C00001
	.long 0x044DC47C
	.long 0xC1AC0000
	.long 0x04261A6C
	.long 0x1C130024
	.long 0x043775A4
	.long 0x8819000A
	.long 0x04261B1C
	.long 0x98A4007A
	.long 0x04261B30
	.long 0x98A4001B
	.long 0x04259B84
	.long 0x5460063F
	.long 0x04259C40
	.long 0x28000000
  .long 0xFF000000
TournamentQoL_On:
	.long 0xC2266CE0
	.long 0x0000000C
	.long 0x80CD8840
	.long 0x38C61CB0
	.long 0x80A60018
	.long 0x3C60E700
	.long 0x606300B0
	.long 0x7C632A79
	.long 0x41820010
	.long 0x2C030020
	.long 0x41820008
	.long 0x48000034
	.long 0x806DB610
	.long 0x88630018
	.long 0x2C030001
	.long 0x41820014
	.long 0x38600001
	.long 0x50652EB4
	.long 0x90A60018
	.long 0x48000014
	.long 0x38600000
	.long 0x50652EB4
	.long 0x90A60018
	.long 0x48000004
	.long 0x38600001
	.long 0x00000000
	.long 0xC22FCCD8
	.long 0x0000000D
	.long 0x3C608046
	.long 0x6063B6A0
	.long 0x886324D0
	.long 0x2C030001
	.long 0x41820050
	.long 0x887F0000
	.long 0x3D808003
	.long 0x618C4110
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x8083002C
	.long 0x80640004
	.long 0x2C030010
	.long 0x40820010
	.long 0x80640010
	.long 0x2C0300EC
	.long 0x41820010
	.long 0x8864221E
	.long 0x54630631
	.long 0x41820014
	.long 0x3D80802F
	.long 0x618CCCC8
	.long 0x7D8903A6
	.long 0x4E800420
	.long 0x281E0000
	.long 0x00000000
	.long 0xC225B8BC
	.long 0x00000002
	.long 0x3C608047
	.long 0x60639D30
	.long 0x88630000
	.long 0x00000000
	.long 0x0445C380
	.long 0x00000000
	.long 0xC22608D8
	.long 0x0000001D
	.long 0x887F0007
	.long 0x2C030000
	.long 0x40820090
	.long 0x889F0004
	.long 0x7C972378
	.long 0x800D8840
	.long 0x7C602214
	.long 0x88A31CC0
	.long 0x57800739
	.long 0x40820010
	.long 0x5780077B
	.long 0x4082003C
	.long 0x480000AC
	.long 0x28050001
	.long 0x418200A4
	.long 0x7EE3BB78
	.long 0x38800000
	.long 0x38A0000E
	.long 0x38C00000
	.long 0x38ED9950
	.long 0x3D808037
	.long 0x618C8430
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x38800001
	.long 0x48000010
	.long 0x28050000
	.long 0x41820070
	.long 0x38800000
	.long 0x7EE3BB78
	.long 0x3D808015
	.long 0x618CED4C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x38800001
	.long 0x989F0007
	.long 0x3C80C040
	.long 0x909F0014
	.long 0xC03F0014
	.long 0xC0428E0C
	.long 0xC01F000C
	.long 0xEC01002A
	.long 0xD01F000C
	.long 0xFC600850
	.long 0xFC030840
	.long 0x41810008
	.long 0xEC6300B2
	.long 0xD07F0014
	.long 0x4180001C
	.long 0xC0828258
	.long 0xFC032040
	.long 0x41810010
	.long 0x38800000
	.long 0x909F0014
	.long 0x989F0007
	.long 0x889F0004
	.long 0x60000000
	.long 0x00000000
	.long 0x042605FC
	.long 0x38C00003
	.long 0x044DC47C
	.long 0xC0200000
	.long 0xC2261A6C
	.long 0x00000005
	.long 0x88BF0005
	.long 0x2C050002
	.long 0x40820014
	.long 0x3D808026
	.long 0x618C1B6C
	.long 0x7D8903A6
	.long 0x4E800420
	.long 0x1C130024
	.long 0x60000000
	.long 0x00000000
	.long 0x04261B1C
	.long 0x60000000
	.long 0x04261B30
	.long 0x60000000
	.long 0xC2259B84
	.long 0x00000008
	.long 0x5460063F
	.long 0x41820038
	.long 0x1C9E001C
	.long 0x38040008
	.long 0x7C1F00AE
	.long 0x2C000000
	.long 0x40820024
	.long 0x3800001D
	.long 0x7C0903A6
	.long 0x38600000
	.long 0x389F0000
	.long 0x90640004
	.long 0x3884001C
	.long 0x4200FFF8
	.long 0x2C030000
	.long 0x00000000
	.long 0xC2259C40
	.long 0x0000001F
	.long 0x39600000
	.long 0x3D408045
	.long 0x614AC388
	.long 0x38600000
	.long 0x3C80803F
	.long 0x608406D0
	.long 0x28000013
	.long 0x4082000C
	.long 0x39600001
	.long 0x48000010
	.long 0x28000000
	.long 0x408200C0
	.long 0x48000034
	.long 0x2C03001D
	.long 0x408000B4
	.long 0x2C0B0002
	.long 0x4182004C
	.long 0x1CA3001C
	.long 0x7CA52214
	.long 0x88C5000A
	.long 0x80AA0000
	.long 0x7CA53430
	.long 0x54A507FF
	.long 0x40820088
	.long 0x4800002C
	.long 0x806DB600
	.long 0x5460056B
	.long 0x4082001C
	.long 0x546006F7
	.long 0x40820008
	.long 0x48000074
	.long 0x39600002
	.long 0x38600000
	.long 0x4BFFFFB0
	.long 0x886DB60E
	.long 0x2C03001D
	.long 0x4080005C
	.long 0x1CA3001C
	.long 0x7CA52214
	.long 0x38C00000
	.long 0x2C0B0002
	.long 0x40820008
	.long 0x38C00002
	.long 0x98C50008
	.long 0x80A50000
	.long 0x2C030016
	.long 0x41800008
	.long 0x80A50010
	.long 0x3CC04400
	.long 0x2C0B0002
	.long 0x40820008
	.long 0x38C00000
	.long 0x90C50038
	.long 0x38C0001E
	.long 0x98CDB60E
	.long 0x2C0B0000
	.long 0x4182000C
	.long 0x38630001
	.long 0x4BFFFF4C
	.long 0x28000000
	.long 0x60000000
	.long 0x00000000
  .long 0xFF000000

FriendliesQoL_Off:
	.long 0x041A5B14
	.long 0x3ba00000
	.long 0x04265220
	.long 0x880db655
	.long 0x0416EA30
	.long 0x981e0010
	.long 0xFF000000
FriendliesQoL_On:
	.long 0xC21A5B14	#Salty Runback + Skip Result
	.long 0x00000015
	.long 0x3BA00000
	.long 0x7FA3EB78
	.long 0x3D80801A
	.long 0x618C3680
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x548005EF
	.long 0x41820014
	.long 0x548005AD
	.long 0x4082001C
	.long 0x5480056B
	.long 0x4082001C
	.long 0x3BBD0001
	.long 0x2C1D0004
	.long 0x4180FFCC
	.long 0x48000060
	.long 0x3B600002
	.long 0x4800005C
	.long 0x3D808025
	.long 0x618C99EC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3C80803F
	.long 0x608406D0
	.long 0x1C63001C
	.long 0x7C841A14
	.long 0x8864000B
	.long 0x3C808045
	.long 0x6084AC64
	.long 0xB0640002
	.long 0x3C808043
	.long 0x6084207C
	.long 0x9064000C
	.long 0x3D808001
	.long 0x618C8254
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3B600002
	.long 0x48000008
	.long 0x3B600000
	.long 0x3BA00000
	.long 0x00000000
	.long 0xC2265220	#Winners names are gold
	.long 0x00000028
	.long 0x7FA3EB78
	.long 0x48000039
	.long 0x2C030000
	.long 0x4182012C
	.long 0x807B0000
	.long 0x38800000
	.long 0x3CA0FFD7
	.long 0x60A50000
	.long 0x90A10100
	.long 0x38A10100
	.long 0x3D80803A
	.long 0x618C74F0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000100
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7D1B78
	.long 0x3FE08047
	.long 0x63FF9DA4
	.long 0x1FDD00A8
	.long 0x7FDEFA14
	.long 0x887F0004
	.long 0x2C030000
	.long 0x418200B0
	.long 0x3C608046
	.long 0x6063B6A0
	.long 0x886324D0
	.long 0x889F0006
	.long 0x7C032000
	.long 0x40820098
	.long 0x887E0058
	.long 0x2C030003
	.long 0x4182008C
	.long 0x887F0004
	.long 0x2C030007
	.long 0x40820040
	.long 0x887F0006
	.long 0x2C030001
	.long 0x40820024
	.long 0x887F0000
	.long 0x1C6300A8
	.long 0x7C63FA14
	.long 0x8863005F
	.long 0x889E005F
	.long 0x7C032000
	.long 0x41820058
	.long 0x4800005C
	.long 0x887F0000
	.long 0x7C03E800
	.long 0x41820048
	.long 0x4800004C
	.long 0x887F0006
	.long 0x2C030001
	.long 0x40820028
	.long 0x7FE3FB78
	.long 0x3D808016
	.long 0x618C54A0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x889E005F
	.long 0x7C032000
	.long 0x41820020
	.long 0x48000014
	.long 0x887E005D
	.long 0x2C030000
	.long 0x41820010
	.long 0x48000004
	.long 0x38600000
	.long 0x48000008
	.long 0x38600001
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x4E800020
	.long 0x880DB655
	.long 0x00000000
	.long 0xC216EA30
	.long 0x00000004
	.long 0x981E0010
	.long 0x2C000007
	.long 0x40820014
	.long 0x3C808046
	.long 0x6084B6A0
	.long 0x88840001
	.long 0x989E000C
	.long 0x00000000
	.long 0x0416B480
	.long 0x60000000
	.long 0x0406AE90
	.long 0x38000000
	.long 0xFF000000

GameVersion_NTSC:
	.long 0x04068F30
	.long 0x3c60803c
	.long 0x040796E0
	.long 0x3a400001
	.long 0x04266978
	.long 0x387f0718
	.long 0x042F9A28
	.long 0x80160004
	.long 0x043CE4D4
	.long 0x00200000
	.long 0x0410FC48
	.long 0x900521dc
	.long 0x0410FB68
	.long 0x900521dc
	.long 0x042B7E54
	.long 0x887f2240
	.long 0x042B808C
	.long 0x2c030002
	.long 0xFF000000
GameVersion_PAL:
	.long 0xC2068F30
	.long 0x0000008C
	.long 0x9421FFBC
	.long 0xBE810008
	.long 0x7C0802A6
	.long 0x90010040
	.long 0x83FE010C
	.long 0x83FF0008
	.long 0x3BFFFFE0
	.long 0x807D0000
	.long 0x2C03001B
	.long 0x40800424
	.long 0x48000071
	.long 0x480000A9
	.long 0x480000B9
	.long 0x48000151
	.long 0x48000179
	.long 0x48000179
	.long 0x480001B1
	.long 0x480001C1
	.long 0x48000209
	.long 0x48000281
	.long 0x48000299
	.long 0x48000299
	.long 0x48000299
	.long 0x48000299
	.long 0x480002A9
	.long 0x480002A9
	.long 0x48000311
	.long 0x48000311
	.long 0x48000319
	.long 0x48000319
	.long 0x48000331
	.long 0x48000331
	.long 0x48000341
	.long 0x48000341
	.long 0x48000351
	.long 0x48000351
	.long 0x48000351
	.long 0x480003B1
	.long 0x7C8802A6
	.long 0x1C630004
	.long 0x7C841A14
	.long 0x80A40000
	.long 0x54A501BA
	.long 0x7CA42A14
	.long 0x80650000
	.long 0x80850004
	.long 0x2C0300FF
	.long 0x41820014
	.long 0x7C63FA14
	.long 0x90830000
	.long 0x38A50008
	.long 0x4BFFFFE4
	.long 0x48000378
	.long 0x00003344
	.long 0x3F547AE1
	.long 0x00003360
	.long 0x42C40000
	.long 0x000000FF
	.long 0x0000379C
	.long 0x42920000
	.long 0x00003908
	.long 0x40000000
	.long 0x0000390C
	.long 0x40866666
	.long 0x00003910
	.long 0x3DEA0EA1
	.long 0x00003928
	.long 0x41A00000
	.long 0x00003C04
	.long 0x2C01480C
	.long 0x00004720
	.long 0x1B968013
	.long 0x00004734
	.long 0x1B968013
	.long 0x0000473C
	.long 0x04000009
	.long 0x00004A40
	.long 0x2C006811
	.long 0x00004A4C
	.long 0x281B0013
	.long 0x00004A50
	.long 0x0D00010B
	.long 0x00004A54
	.long 0x2C806811
	.long 0x00004A60
	.long 0x281B0013
	.long 0x00004A64
	.long 0x0D00010B
	.long 0x00004B24
	.long 0x2C00680D
	.long 0x00004B30
	.long 0x0F104013
	.long 0x00004B38
	.long 0x2C80380D
	.long 0x00004B44
	.long 0x0F104013
	.long 0x000000FF
	.long 0x0000380C
	.long 0x00000007
	.long 0x00004EF8
	.long 0x2C003803
	.long 0x00004F08
	.long 0x0F80000B
	.long 0x00004F0C
	.long 0x2C802003
	.long 0x00004F1C
	.long 0x0F80000B
	.long 0x000000FF
	.long 0x000000FF
	.long 0x00004D10
	.long 0x3FC00000
	.long 0x00004D70
	.long 0x42940000
	.long 0x00004DD4
	.long 0x41900000
	.long 0x00004DE0
	.long 0x41900000
	.long 0x000083AC
	.long 0x2C000009
	.long 0x000083B8
	.long 0x348C8011
	.long 0x00008400
	.long 0x348C8011
	.long 0x000000FF
	.long 0x000036CC
	.long 0x42EC0000
	.long 0x000037C4
	.long 0x0C000000
	.long 0x000000FF
	.long 0x00003468
	.long 0x3F666666
	.long 0x000039D8
	.long 0x440C0000
	.long 0x00003A44
	.long 0xB4990011
	.long 0x00003A48
	.long 0x1B8C008F
	.long 0x00003A58
	.long 0xB4990011
	.long 0x00003A5C
	.long 0x1B8C008F
	.long 0x00003A6C
	.long 0xB4990011
	.long 0x00003A70
	.long 0x1B8C008F
	.long 0x00003B30
	.long 0x440C0000
	.long 0x000000FF
	.long 0x000045C8
	.long 0x2C015010
	.long 0x000045D4
	.long 0x2D198013
	.long 0x000045DC
	.long 0x2C80B010
	.long 0x000045E8
	.long 0x2D198013
	.long 0x000049C4
	.long 0x2C00680A
	.long 0x000049D0
	.long 0x281B8013
	.long 0x000049D8
	.long 0x2C80780A
	.long 0x000049E4
	.long 0x281B8013
	.long 0x000049F0
	.long 0x2C006808
	.long 0x000049FC
	.long 0x231B8013
	.long 0x00004A04
	.long 0x2C807808
	.long 0x00004A10
	.long 0x231B8013
	.long 0x00005C98
	.long 0x1E0C8080
	.long 0x00005CF4
	.long 0xB4800C90
	.long 0x00005D08
	.long 0xB4800C90
	.long 0x000000FF
	.long 0x00003A1C
	.long 0xB4940013
	.long 0x00001A64
	.long 0x2C000015
	.long 0x00003A70
	.long 0xB4928013
	.long 0x000000FF
	.long 0x000000FF
	.long 0x000000FF
	.long 0x000000FF
	.long 0x0000647C
	.long 0xB49A4017
	.long 0x00006480
	.long 0x64001097
	.long 0x000000FF
	.long 0x000000FF
	.long 0x000033E4
	.long 0x42DE0000
	.long 0x00004528
	.long 0x2C013011
	.long 0x00004534
	.long 0xB4988013
	.long 0x0000453C
	.long 0x2C813011
	.long 0x00004548
	.long 0xB4988013
	.long 0x00004550
	.long 0x2D002011
	.long 0x0000455C
	.long 0xB4988013
	.long 0x000045F8
	.long 0x2C01300F
	.long 0x00004608
	.long 0x0F00010B
	.long 0x0000460C
	.long 0x2C81280F
	.long 0x0000461C
	.long 0x0F00010B
	.long 0x00004AEC
	.long 0x2C007003
	.long 0x00004B00
	.long 0x2C803803
	.long 0x000000FF
	.long 0x000000FF
	.long 0x0000485C
	.long 0x2C00000F
	.long 0x000000FF
	.long 0x000000FF
	.long 0x000037B0
	.long 0x3F59999A
	.long 0x000037CC
	.long 0x42AA0000
	.long 0x00005520
	.long 0x87118013
	.long 0x000000FF
	.long 0x000000FF
	.long 0x00003B8C
	.long 0x440C0000
	.long 0x00003D0C
	.long 0x440C0000
	.long 0x000000FF
	.long 0x000000FF
	.long 0x000050E4
	.long 0xB4990013
	.long 0x000050F8
	.long 0xB4990013
	.long 0x000000FF
	.long 0x000000FF
	.long 0x000000FF
	.long 0x00004EB0
	.long 0x02BCFF38
	.long 0x00004EBC
	.long 0x14000123
	.long 0x00004EC4
	.long 0x038401F4
	.long 0x00004ED0
	.long 0x14000123
	.long 0x00004ED8
	.long 0x044C04B0
	.long 0x00004EE4
	.long 0x14000123
	.long 0x0000505C
	.long 0x2C006815
	.long 0x0000506C
	.long 0x14080123
	.long 0x00005070
	.long 0x2C806015
	.long 0x00005080
	.long 0x14080123
	.long 0x00005084
	.long 0x2D002015
	.long 0x00005094
	.long 0x14080123
	.long 0x000000FF
	.long 0x000000FF
	.long 0x80010040
	.long 0x7C0803A6
	.long 0xBA810008
	.long 0x38210044
	.long 0x3C60803C
	.long 0x00000000
	.long 0x040796E0
	.long 0x60000000
	.long 0xC2266978
	.long 0x00000050
	.long 0x7DC802A6
	.long 0x48000031
	.long 0x7C8802A6
	.long 0x7DC803A6
	.long 0x3DC00035
	.long 0x61CE6A60
	.long 0x7C6E1850
	.long 0x38A00238
	.long 0x3DC08000
	.long 0x61CE31F4
	.long 0x7DC903A6
	.long 0x4E800421
	.long 0x48000244
	.long 0x4E800021
	.long 0x00000000
	.long 0x00006FFF
	.long 0x00007FF1
	.long 0x00007FF0
	.long 0x00007FF0
	.long 0x00007FF0
	.long 0x00007FFF
	.long 0x00007FF1
	.long 0x00000000
	.long 0xFFC40002
	.long 0x17FF3006
	.long 0x00EF800B
	.long 0x00EF801F
	.long 0x04FF404F
	.long 0xFFF7009F
	.long 0x110000EF
	.long 0x00000000
	.long 0xFFF8000D
	.long 0xFEFD000F
	.long 0xFBFF300F
	.long 0xF6DF700F
	.long 0xF3BFC00F
	.long 0xE07FF10F
	.long 0xB14FF60F
	.long 0x00000000
	.long 0xF6000000
	.long 0xF7000000
	.long 0xF7000000
	.long 0xF7000000
	.long 0xF7000000
	.long 0xF7000000
	.long 0xF7000000
	.long 0x04FF9888
	.long 0x00CFB888
	.long 0x009FC888
	.long 0x006FD888
	.long 0x004FE888
	.long 0x002FF888
	.long 0x000FF888
	.long 0x002FF888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x8888888E
	.long 0x888888DF
	.long 0x88888CFF
	.long 0x8888AFF7
	.long 0x8889FFA0
	.long 0x888FFC00
	.long 0x8DFFB100
	.long 0xEFF60000
	.long 0xFF400000
	.long 0xF3000000
	.long 0x40000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x8888EF40
	.long 0x8888DF60
	.long 0x8888CF90
	.long 0x8888BFC0
	.long 0x88889FF4
	.long 0x88888DF9
	.long 0x88888BFE
	.long 0x888888EF
	.long 0x00007FF0
	.long 0x00007FF0
	.long 0x00006FD0
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x30000000
	.long 0x90000000
	.long 0x000003FF
	.long 0x000008FF
	.long 0x00000BFB
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0xEFFFFB0F
	.long 0x200AFF1F
	.long 0x0004FF4D
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0xF7000000
	.long 0xF7111100
	.long 0xFFFFFB00
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x004FE888
	.long 0x006FD888
	.long 0x009FC888
	.long 0x00CFB888
	.long 0x04FF9888
	.long 0x09FD8888
	.long 0x3EFB8888
	.long 0x387F0718
	.long 0x60000000
	.long 0x00000000
	.long 0xC22F9A28
	.long 0x00000004
	.long 0x3C003F59
	.long 0x6000999A
	.long 0x901D002C
	.long 0x901D0030
	.long 0x3C00C1B0
	.long 0x60000000
	.long 0x60000000
	.long 0x00000000
	.long 0x043CE4D4
	.long 0x00240464
	.long 0x0410FC48
	.long 0x60000000
	.long 0x0410FB68
	.long 0x60000000
	.long 0x042B7E54
	.long 0x48000088
	.long 0x042B808C
	.long 0x48000084
	.long 0xFF000000
GameVersion_SDR:
	.long 0xC2068F30
	.long 0x00000B0B
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x83FE010C
	.long 0x83FF0008
	.long 0x3BFFFFE0
	.long 0x807D0000
	.long 0x2C03001B
	.long 0x40805818
	.long 0x48000071
	.long 0x480000FD
	.long 0x480003F5
	.long 0x480003F5
	.long 0x480003F5
	.long 0x48000A8D
	.long 0x4800114D
	.long 0x48001895
	.long 0x48001E7D
	.long 0x48001E7D
	.long 0x480023AD
	.long 0x480023AD
	.long 0x480024A5
	.long 0x4800259D
	.long 0x480027FD
	.long 0x48002CCD
	.long 0x480030E5
	.long 0x480030E5
	.long 0x48003595
	.long 0x480037FD
	.long 0x480037FD
	.long 0x48003EB5
	.long 0x48004575
	.long 0x48004635
	.long 0x48004635
	.long 0x48004B65
	.long 0x48004E0D
	.long 0x4800510D
	.long 0x7C8802A6
	.long 0x1C630004
	.long 0x7C841A14
	.long 0x80A40000
	.long 0x54A501BA
	.long 0x7CA42A14
	.long 0x80650000
	.long 0x80850004
	.long 0x7C600774
	.long 0x2C00FFFF
	.long 0x41820064
	.long 0x5460463E
	.long 0x2C0000CC
	.long 0x41820038
	.long 0x2C0000CD
	.long 0x41820008
	.long 0x4800003C
	.long 0x5463023E
	.long 0x80E50008
	.long 0x2C040000
	.long 0x41820014
	.long 0x3884FFFC
	.long 0x7D1F1A14
	.long 0x7CE8212E
	.long 0x4BFFFFEC
	.long 0x38A5000C
	.long 0x4BFFFFB0
	.long 0x5463023E
	.long 0x7C84FA14
	.long 0x38840020
	.long 0x48000004
	.long 0x7C63FA14
	.long 0x90830000
	.long 0x38A50008
	.long 0x4BFFFF90
	.long 0x48005718
	.long 0x00003300
	.long 0x3FC9999A
	.long 0x0000333C
	.long 0x3D2E147B
	.long 0x00003344
	.long 0x3F70A3D7
	.long 0x000033D0
	.long 0x41A00000
	.long 0x0000349C
	.long 0x3F800000
	.long 0x000034B4
	.long 0x3FC00000
	.long 0x000040A8
	.long 0xB497C013
	.long 0x000040AC
	.long 0x0F00008B
	.long 0x000040BC
	.long 0xB497C013
	.long 0x000040C0
	.long 0x0F00008B
	.long 0x00004130
	.long 0x2C81B809
	.long 0x00004134
	.long 0x03200190
	.long 0x00004138
	.long 0x00000000
	.long 0x00004180
	.long 0x2C81B807
	.long 0x00004184
	.long 0x02BC0190
	.long 0x00004188
	.long 0x00000000
	.long 0x0000419C
	.long 0x08000022
	.long 0x00004298
	.long 0xB4990013
	.long 0x000042AC
	.long 0xB4990013
	.long 0x000042C0
	.long 0xB4990013
	.long 0x0000434C
	.long 0x0800001A
	.long 0x000043E0
	.long 0x08000015
	.long 0x0000445C
	.long 0x2C800010
	.long 0x00004468
	.long 0xB4990013
	.long 0x00004470
	.long 0x2D00E810
	.long 0x0000447C
	.long 0xB4990013
	.long 0x00004534
	.long 0x2C80000F
	.long 0x00004540
	.long 0xB4990013
	.long 0x00004548
	.long 0x2D00E80F
	.long 0x00004554
	.long 0xB4990013
	.long 0x0000460C
	.long 0x2C80000E
	.long 0x00004618
	.long 0xB4990013
	.long 0x00004620
	.long 0x2D00E80E
	.long 0x0000462C
	.long 0xB4990013
	.long 0x000047FC
	.long 0x2C01B80D
	.long 0x00004800
	.long 0x02EE00C8
	.long 0x0000480C
	.long 0x0C80010B
	.long 0x00004810
	.long 0x2C81880D
	.long 0x00004814
	.long 0x02EE00C8
	.long 0x00004820
	.long 0x0C80010B
	.long 0x0000483C
	.long 0x02EE00C8
	.long 0x00004850
	.long 0x02EE00C8
	.long 0x000048A8
	.long 0x2C00F80E
	.long 0x000048B4
	.long 0x8C168013
	.long 0x000048B8
	.long 0x0B000107
	.long 0x000048BC
	.long 0x2C81000E
	.long 0x000048C8
	.long 0x8C168013
	.long 0x000048CC
	.long 0x0B000107
	.long 0x000048EC
	.long 0x0800003A
	.long 0x00004918
	.long 0x11990013
	.long 0x0000491C
	.long 0x0780010B
	.long 0x0000492C
	.long 0x11990013
	.long 0x00004930
	.long 0x0780010B
	.long 0x000049E0
	.long 0x08000018
	.long 0x00004A1C
	.long 0x281903D3
	.long 0x00004A30
	.long 0x281903D3
	.long 0x00004A44
	.long 0x281903D3
	.long 0x00004A7C
	.long 0x08000021
	.long 0x00004B18
	.long 0x04000006
	.long 0x00005A84
	.long 0x03B60000
	.long 0x00005A98
	.long 0x03B60000
	.long 0x00005ADC
	.long 0x03B60000
	.long 0x00005AF0
	.long 0x03B60000
	.long 0x00005B04
	.long 0x03B60000
	.long 0x00006A00
	.long 0x08000002
	.long 0x00006A04
	.long 0x4C000001
	.long 0x00006A08
	.long 0x08000004
	.long 0x00006A0C
	.long 0x2C01B00B
	.long 0x00006A10
	.long 0x0384012C
	.long 0x00006A18
	.long 0x1B990013
	.long 0x00006A1C
	.long 0x0000008B
	.long 0x00006A20
	.long 0x2C81B80B
	.long 0x00006A24
	.long 0x04B00320
	.long 0x00006A2C
	.long 0x1B990013
	.long 0x00006A30
	.long 0x0000008B
	.long 0x00006A34
	.long 0x44040000
	.long 0x00006A38
	.long 0x000000A5
	.long 0x00006A3C
	.long 0x00007F40
	.long 0x00006A40
	.long 0xAC020000
	.long 0x00006A44
	.long 0x08000006
	.long 0x00006A48
	.long 0x2C01B00B
	.long 0x00006A4C
	.long 0x0384012C
	.long 0x00006A54
	.long 0x20990013
	.long 0x00006A58
	.long 0x0000008B
	.long 0x00006A5C
	.long 0x2C81B80B
	.long 0x00006A60
	.long 0x04B00320
	.long 0x00006A68
	.long 0x20990013
	.long 0x00006A6C
	.long 0x0000008B
	.long 0x00006A70
	.long 0x0800000A
	.long 0x00006A74
	.long 0x40000000
	.long 0x00006A78
	.long 0x08000010
	.long 0x00006A7C
	.long 0x4C000000
	.long 0x00006A80
	.long 0x08000018
	.long 0x00006A84
	.long 0x5C000000
	.long 0xCC0075F4
	.long 0x000069E0
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x00003A38
	.long 0x42E80000
	.long 0x00003A40
	.long 0x41AF0000
	.long 0x00003B6C
	.long 0x00000000
	.long 0x00003B8C
	.long 0x3FE00000
	.long 0x00003B90
	.long 0x3D4CCCCD
	.long 0x00003B94
	.long 0x3D8F5C29
	.long 0x00003C4C
	.long 0x04600000
	.long 0x00003C60
	.long 0x06900000
	.long 0x00003C78
	.long 0x04600000
	.long 0x00003C8C
	.long 0x06900000
	.long 0x00003D18
	.long 0x2C00F014
	.long 0x00003D1C
	.long 0x04600000
	.long 0x00003D2C
	.long 0x2C80F814
	.long 0x00003D30
	.long 0x06900000
	.long 0x00003D40
	.long 0x2D002014
	.long 0x00003D44
	.long 0x02940000
	.long 0x00003D60
	.long 0x04600000
	.long 0x00003D74
	.long 0x06900000
	.long 0x00003D88
	.long 0x01260000
	.long 0x00003E88
	.long 0x04600000
	.long 0x00003E9C
	.long 0x06900000
	.long 0x00003EB4
	.long 0x04600000
	.long 0x00003EC8
	.long 0x06900000
	.long 0x00003F58
	.long 0x2C00F012
	.long 0x00003F5C
	.long 0x04600000
	.long 0x00003F6C
	.long 0x2C80F812
	.long 0x00003F70
	.long 0x06900000
	.long 0x00003F80
	.long 0x2D002012
	.long 0x00003F84
	.long 0x01260000
	.long 0x00003FA0
	.long 0x04600000
	.long 0x00003FB4
	.long 0x06900000
	.long 0x00003FC8
	.long 0x02940000
	.long 0x00004074
	.long 0x2C00000D
	.long 0x00004088
	.long 0x2C80000D
	.long 0x0000409C
	.long 0x2D00000D
	.long 0x00004100
	.long 0x2C00000D
	.long 0x00004114
	.long 0x2C80000D
	.long 0x00004164
	.long 0x2C00E80A
	.long 0x00004168
	.long 0x0640FE0C
	.long 0x0000416C
	.long 0x012C0000
	.long 0x000041C4
	.long 0x19000D07
	.long 0x000041D8
	.long 0x19000D07
	.long 0x000041EC
	.long 0x19000D07
	.long 0x00004234
	.long 0x0A000807
	.long 0x00004248
	.long 0x0A000807
	.long 0x0000425C
	.long 0x0A000807
	.long 0x000042C0
	.long 0x44000000
	.long 0x000042C4
	.long 0x0000009F
	.long 0x000042C8
	.long 0x00007F40
	.long 0x000042CC
	.long 0x68000002
	.long 0x000042D0
	.long 0x2C00E80A
	.long 0x000042D4
	.long 0x064006A9
	.long 0x000042D8
	.long 0x00000000
	.long 0x000042DC
	.long 0xB4940013
	.long 0x000042E0
	.long 0x14000507
	.long 0x000042E4
	.long 0x2C81980A
	.long 0x000042E8
	.long 0x064006A9
	.long 0x000042EC
	.long 0x00000000
	.long 0x000042F0
	.long 0xB4940013
	.long 0x000042F4
	.long 0x14000507
	.long 0x000042F8
	.long 0x28000000
	.long 0x000042FC
	.long 0x04060000
	.long 0x00004300
	.long 0x00000000
	.long 0x0000430C
	.long 0x08000006
	.long 0x00004310
	.long 0x40000000
	.long 0x00004314
	.long 0x68000000
	.long 0x00004318
	.long 0x0800000B
	.long 0x0000431C
	.long 0x70B00002
	.long 0x00004348
	.long 0x0A000D07
	.long 0x0000435C
	.long 0x0A000D07
	.long 0x00004370
	.long 0x0A000D07
	.long 0x000043B8
	.long 0x00000807
	.long 0x000043CC
	.long 0x00000807
	.long 0x000043E0
	.long 0x00000807
	.long 0x00004440
	.long 0x87140010
	.long 0x00004444
	.long 0x3200050A
	.long 0x00004454
	.long 0x87140010
	.long 0x00004458
	.long 0x3200050A
	.long 0x00004468
	.long 0x87140010
	.long 0x0000446C
	.long 0x3200050A
	.long 0x0000447C
	.long 0x87140010
	.long 0x00004480
	.long 0x3200050A
	.long 0x000044CC
	.long 0x87140010
	.long 0x000044D0
	.long 0x3700050A
	.long 0x000044E0
	.long 0x87140010
	.long 0x000044E4
	.long 0x3700050A
	.long 0x000044F4
	.long 0x87140010
	.long 0x000044F8
	.long 0x3700050A
	.long 0x00004508
	.long 0x87140010
	.long 0x0000450C
	.long 0x3700050A
	.long 0x00004C54
	.long 0x04B00700
	.long 0x00004C5C
	.long 0x32190013
	.long 0x00004C84
	.long 0x32190013
	.long 0x00004CC8
	.long 0x04A80700
	.long 0x00004CD0
	.long 0x23190013
	.long 0x00004CD4
	.long 0x14000087
	.long 0x00004CE4
	.long 0x23190013
	.long 0x00004CE8
	.long 0x14000087
	.long 0x00004CF8
	.long 0x23190013
	.long 0x00004CFC
	.long 0x14000087
	.long 0x00004DB4
	.long 0x08000024
	.long 0x00004DC8
	.long 0x2C00E80D
	.long 0x00004DCC
	.long 0x04B002A9
	.long 0x00004DD8
	.long 0x07800107
	.long 0x00004DDC
	.long 0x2C80F00D
	.long 0x00004DE0
	.long 0x053C0514
	.long 0x00004DEC
	.long 0x07800107
	.long 0x00004DF0
	.long 0x2D00E80D
	.long 0x00004DF4
	.long 0x038CFF01
	.long 0x00004E00
	.long 0x07800107
	.long 0x00004E04
	.long 0x2D81580D
	.long 0x00004E08
	.long 0x04EC0000
	.long 0x00004E14
	.long 0x07800107
	.long 0x00004E58
	.long 0x2C00E80C
	.long 0x00004E5C
	.long 0x04B002A9
	.long 0x00004E6C
	.long 0x2C80F00C
	.long 0x00004E70
	.long 0x053C0514
	.long 0x00004E80
	.long 0x2D00E80C
	.long 0x00004E84
	.long 0x038CFF01
	.long 0x00004E94
	.long 0x2D81580C
	.long 0x00004E98
	.long 0x04EC0000
	.long 0x00004EE8
	.long 0x2C00E80B
	.long 0x00004EEC
	.long 0x04CF02A9
	.long 0x00004EFC
	.long 0x2C80F00B
	.long 0x00004F00
	.long 0x053C0514
	.long 0x00004F10
	.long 0x2D00E80B
	.long 0x00004F14
	.long 0x038CFF01
	.long 0x00004F24
	.long 0x2D81580B
	.long 0x00004F28
	.long 0x04EC0000
	.long 0x00004F74
	.long 0x08000005
	.long 0x00004F78
	.long 0x2C01A00A
	.long 0x00004F7C
	.long 0x03E805AA
	.long 0x00004F84
	.long 0x321B8013
	.long 0x00004FA4
	.long 0x04B00119
	.long 0x00004FC4
	.long 0x04000008
	.long 0x00004FCC
	.long 0x08000024
	.long 0x00004FF4
	.long 0x2C019808
	.long 0x00004FF8
	.long 0x045E02A9
	.long 0x00005008
	.long 0x2C81A008
	.long 0x0000500C
	.long 0x053206A4
	.long 0x00005014
	.long 0xB4940013
	.long 0x0000501C
	.long 0x2D015808
	.long 0x00005020
	.long 0x05960000
	.long 0x00005028
	.long 0xB4940013
	.long 0x000050D4
	.long 0x05DC0000
	.long 0x000050E0
	.long 0x0F004107
	.long 0x000050E8
	.long 0x06A40000
	.long 0x000050F4
	.long 0x0F004107
	.long 0x000050FC
	.long 0x04800000
	.long 0x00005108
	.long 0x09004087
	.long 0x00005110
	.long 0x03840000
	.long 0x0000511C
	.long 0x09004087
	.long 0x00005128
	.long 0x08000032
	.long 0x000051C0
	.long 0x2C01A013
	.long 0x000051C4
	.long 0x06D607F1
	.long 0x000051D0
	.long 0x14005107
	.long 0x000051D4
	.long 0x2C80F013
	.long 0x000051D8
	.long 0x06D607F1
	.long 0x000051E4
	.long 0x14005107
	.long 0x000051F4
	.long 0x04000021
	.long 0x0000524C
	.long 0x2C01A011
	.long 0x0000525C
	.long 0x11804107
	.long 0x00005260
	.long 0x2C80F011
	.long 0x00005270
	.long 0x11804107
	.long 0x00005284
	.long 0x11804107
	.long 0x00005298
	.long 0x11804107
	.long 0x00005308
	.long 0x0800002C
	.long 0x00005310
	.long 0x08000033
	.long 0x00005334
	.long 0x04FE03FE
	.long 0x00005340
	.long 0x0A000107
	.long 0x00005348
	.long 0x04FE03FE
	.long 0x00005354
	.long 0x0A000107
	.long 0x0000535C
	.long 0x06FC0000
	.long 0x00005368
	.long 0x0A000107
	.long 0x00005384
	.long 0x04FE05FD
	.long 0x00005390
	.long 0x05000107
	.long 0x00005398
	.long 0x04FE05FD
	.long 0x000053A4
	.long 0x05000107
	.long 0x000053AC
	.long 0x06FC0000
	.long 0x000053B8
	.long 0x05000107
	.long 0x0000540C
	.long 0x0F003907
	.long 0x00005420
	.long 0x0F003907
	.long 0x00005434
	.long 0x0F003907
	.long 0x00005448
	.long 0x0F003907
	.long 0x00005484
	.long 0x1900390B
	.long 0x00005498
	.long 0x1900390B
	.long 0x000054A8
	.long 0xB4940013
	.long 0x000054AC
	.long 0x1900390B
	.long 0x000054BC
	.long 0xB4940013
	.long 0x000054C0
	.long 0x1900390B
	.long 0x000054CC
	.long 0x08000037
	.long 0x000054F8
	.long 0x06A40000
	.long 0x00005504
	.long 0x0A00010B
	.long 0x0000550C
	.long 0x05DC0000
	.long 0x00005518
	.long 0x0A00010B
	.long 0x00005534
	.long 0x06400000
	.long 0x00005540
	.long 0x0500008B
	.long 0x00005548
	.long 0x05780000
	.long 0x00005554
	.long 0x0500008B
	.long 0x000055C4
	.long 0x04000004
	.long 0x00005608
	.long 0x08980352
	.long 0x0000561C
	.long 0x07D002A9
	.long 0x00005630
	.long 0x06400000
	.long 0x000060FC
	.long 0x08000014
	.long 0x000065A0
	.long 0x0400000B
	.long 0x0000672C
	.long 0x05781130
	.long 0x00006740
	.long 0x05780A8C
	.long 0x00006794
	.long 0x05780D48
	.long 0x000067A8
	.long 0x05780834
	.long 0x000067BC
	.long 0x05780320
	.long 0x00007CE8
	.long 0x00000000
	.long 0xFFFFFFFF
	.long 0x00004D00
	.long 0x3D75C28F
	.long 0x00004D10
	.long 0x3FC00000
	.long 0x00004D34
	.long 0x3FA00000
	.long 0x00004D4C
	.long 0x3DA3D70A
	.long 0x00004D50
	.long 0x3CF5C28F
	.long 0x00004D54
	.long 0x3F79999A
	.long 0x00004D70
	.long 0x42940000
	.long 0x00004DD4
	.long 0x41700000
	.long 0x00004DE0
	.long 0x41700000
	.long 0x00004EF8
	.long 0x42200000
	.long 0x00004F3C
	.long 0x49742400
	.long 0x00005028
	.long 0x00000000
	.long 0x00005030
	.long 0x0000000F
	.long 0x00005048
	.long 0x00000000
	.long 0x00005200
	.long 0x00000007
	.long 0x00005240
	.long 0x3F4CCCCD
	.long 0x00005260
	.long 0x00000001
	.long 0x00005270
	.long 0x41700000
	.long 0x000052E0
	.long 0x000004B0
	.long 0x00005308
	.long 0x0000157C
	.long 0x00005310
	.long 0x00200087
	.long 0x0000531C
	.long 0x000008FC
	.long 0x000053A0
	.long 0x05DC0000
	.long 0x000053A4
	.long 0x000005DC
	.long 0x00005494
	.long 0x8800000F
	.long 0x00005574
	.long 0x2C016017
	.long 0x00005580
	.long 0x1E130015
	.long 0x00005584
	.long 0x2080510B
	.long 0x00005588
	.long 0x2C816017
	.long 0x00005594
	.long 0x1E130015
	.long 0x00005598
	.long 0x2080510B
	.long 0x000055A0
	.long 0x04E20000
	.long 0x000055AC
	.long 0x2080510B
	.long 0x00005644
	.long 0x05460000
	.long 0x0000564C
	.long 0xB4918007
	.long 0x00005650
	.long 0x1E00010B
	.long 0x00005658
	.long 0x03200000
	.long 0x00005660
	.long 0xB4918007
	.long 0x00005664
	.long 0x1E00010B
	.long 0x0000567C
	.long 0x05460000
	.long 0x00005684
	.long 0x0F118007
	.long 0x00005688
	.long 0x1E000007
	.long 0x00005690
	.long 0x03200000
	.long 0x00005698
	.long 0x0F118007
	.long 0x0000569C
	.long 0x1E000007
	.long 0x000057CC
	.long 0x2C016004
	.long 0x000057D8
	.long 0x89990017
	.long 0x000057DC
	.long 0x280C010F
	.long 0x000057F4
	.long 0xCC000000
	.long 0xCC005894
	.long 0x0000AB90
	.long 0x0000598C
	.long 0x03520000
	.long 0x00005994
	.long 0x23168013
	.long 0x00005998
	.long 0x2080510B
	.long 0x00006158
	.long 0xCC000000
	.long 0x000061C0
	.long 0xCC000000
	.long 0x00006F78
	.long 0x44040000
	.long 0x00006F7C
	.long 0x00041F6F
	.long 0x00006F80
	.long 0x00007F40
	.long 0x00006F84
	.long 0x28000000
	.long 0x00006F88
	.long 0x04230000
	.long 0x00006F8C
	.long 0x00000000
	.long 0x00006F98
	.long 0x0C000005
	.long 0x00006F9C
	.long 0x2C000001
	.long 0x00006FA0
	.long 0x05780000
	.long 0x00006FA4
	.long 0x05DCFC18
	.long 0x00006FA8
	.long 0x5A000011
	.long 0x00006FAC
	.long 0x150C008F
	.long 0x00006FB0
	.long 0x2C800001
	.long 0x00006FB4
	.long 0x05780000
	.long 0x00006FB8
	.long 0x05DC03E8
	.long 0x00006FBC
	.long 0x5A000011
	.long 0x00006FC0
	.long 0x150C008F
	.long 0x00006FC4
	.long 0x2D000002
	.long 0x00006FC8
	.long 0x06A40000
	.long 0x00006FCC
	.long 0x05DCF448
	.long 0x00006FD0
	.long 0x5A000011
	.long 0x00006FD4
	.long 0x0B8C000F
	.long 0x00006FD8
	.long 0x2D800002
	.long 0x00006FDC
	.long 0x06A40000
	.long 0x00006FE0
	.long 0x05DC0BB8
	.long 0x00006FE4
	.long 0x5A000011
	.long 0x00006FE8
	.long 0x0B8C000F
	.long 0x00006FEC
	.long 0x04000001
	.long 0x00006FF0
	.long 0x40000000
	.long 0x00006FF4
	.long 0x68000000
	.long 0x00007004
	.long 0x08980000
	.long 0x00007010
	.long 0x1E0C0123
	.long 0x00007018
	.long 0x08980000
	.long 0x00007024
	.long 0x1E0C0123
	.long 0x0000702C
	.long 0x07080000
	.long 0x00007038
	.long 0x1E0C00A3
	.long 0x00007040
	.long 0x07080000
	.long 0x0000704C
	.long 0x1E0C00A3
	.long 0x000075A0
	.long 0x2C016007
	.long 0x000075B4
	.long 0x2C816007
	.long 0x000075C8
	.long 0x2D002807
	.long 0x000075DC
	.long 0x2D811807
	.long 0x00007960
	.long 0x8800000B
	.long 0x00007BF8
	.long 0x3F666666
	.long 0x00007FB0
	.long 0x08000019
	.long 0x000083AC
	.long 0x2C00000D
	.long 0x000083B0
	.long 0x05140000
	.long 0x000083B8
	.long 0xB4968011
	.long 0x000083BC
	.long 0x190400A3
	.long 0x000083F4
	.long 0x2C00000A
	.long 0x000083F8
	.long 0x044C0000
	.long 0x00008400
	.long 0xB4968011
	.long 0x00008404
	.long 0x0F040023
	.long 0x00008410
	.long 0x08000035
	.long 0x0000842C
	.long 0x10990013
	.long 0x00008440
	.long 0x10990013
	.long 0x000084F4
	.long 0x08000015
	.long 0x0000855C
	.long 0x08000015
	.long 0x000085B4
	.long 0x13190013
	.long 0x000085B8
	.long 0x1500010B
	.long 0x000085C0
	.long 0x03E801F4
	.long 0x000085C8
	.long 0x13190013
	.long 0x000085CC
	.long 0x1500010B
	.long 0x000085D4
	.long 0x038403E8
	.long 0x000085DC
	.long 0x13190013
	.long 0x000085E0
	.long 0x1500010B
	.long 0x0000860C
	.long 0x2C01880E
	.long 0x00008618
	.long 0x13180013
	.long 0x0000861C
	.long 0x0D00008B
	.long 0x00008620
	.long 0x2C81880E
	.long 0x00008624
	.long 0x03B601F4
	.long 0x0000862C
	.long 0x13180013
	.long 0x00008630
	.long 0x0D00008B
	.long 0x00008634
	.long 0x2D01880E
	.long 0x00008638
	.long 0x02BC0384
	.long 0x00008640
	.long 0x13180013
	.long 0x00008644
	.long 0x0D00008B
	.long 0x00008710
	.long 0x2C1D8013
	.long 0x00008714
	.long 0x0F00010F
	.long 0x00008724
	.long 0x2C1D8013
	.long 0x00008728
	.long 0x0F00010F
	.long 0x0000872C
	.long 0x2D01B80E
	.long 0x00008738
	.long 0x2C1B8013
	.long 0x0000873C
	.long 0x0F000107
	.long 0x00008740
	.long 0x04000004
	.long 0x00008750
	.long 0x19190013
	.long 0x00008754
	.long 0x0A00008B
	.long 0x00008764
	.long 0x19190013
	.long 0x00008768
	.long 0x0A00008B
	.long 0x0000876C
	.long 0x2D01B80D
	.long 0x00008778
	.long 0x19190013
	.long 0x0000877C
	.long 0x0A00008B
	.long 0x00008780
	.long 0x08000017
	.long 0x000087EC
	.long 0xB4990013
	.long 0x00008800
	.long 0xB4990013
	.long 0x00008818
	.long 0x0B00010B
	.long 0x0000882C
	.long 0x0B00010B
	.long 0x00008894
	.long 0x05780000
	.long 0x0000889C
	.long 0x14190013
	.long 0x000088A0
	.long 0x0A000087
	.long 0x000088B8
	.long 0x3000000C
	.long 0x000088C0
	.long 0x30000009
	.long 0x000088C8
	.long 0x30000008
	.long 0x000088F8
	.long 0x041A0BB8
	.long 0x000088FC
	.long 0x1683C013
	.long 0x00008900
	.long 0x1180008B
	.long 0x00008910
	.long 0x1683C013
	.long 0x00008914
	.long 0x1180008B
	.long 0x00008934
	.long 0x2C000004
	.long 0x0000893C
	.long 0x041A0BB8
	.long 0x00008940
	.long 0x2083C013
	.long 0x00008944
	.long 0x0E00008B
	.long 0x00008948
	.long 0x2C800004
	.long 0x00008954
	.long 0x2083C013
	.long 0x00008958
	.long 0x0E00008B
	.long 0x0000897C
	.long 0x06180000
	.long 0x00008980
	.long 0x041A0BB8
	.long 0x00008990
	.long 0x06180000
	.long 0x00008A58
	.long 0x08000009
	.long 0x00008A84
	.long 0x04000006
	.long 0x00008A8C
	.long 0x04000006
	.long 0x00008ACC
	.long 0x0A00008B
	.long 0x00008AE0
	.long 0x0A00008B
	.long 0x00008B28
	.long 0x2C000005
	.long 0x00008B30
	.long 0x04FE0752
	.long 0x00008B34
	.long 0x30118013
	.long 0x00008B38
	.long 0x2080008B
	.long 0x00008B3C
	.long 0x2C800005
	.long 0x00008B40
	.long 0x047E0000
	.long 0x00008B44
	.long 0x04FE0354
	.long 0x00008B48
	.long 0x30118013
	.long 0x00008B4C
	.long 0x2080008B
	.long 0x00008B68
	.long 0x2C000005
	.long 0x00008B6C
	.long 0x00000000
	.long 0x00008B74
	.long 0x30118013
	.long 0x00008B78
	.long 0x20800088
	.long 0x00008B7C
	.long 0x2C800005
	.long 0x00008B80
	.long 0x00000000
	.long 0x00008B88
	.long 0x30118013
	.long 0x00008B8C
	.long 0x20800088
	.long 0x00008C04
	.long 0x2A0C8A13
	.long 0x00008C08
	.long 0x0A00010B
	.long 0x00008C18
	.long 0x2A0C8A13
	.long 0x00008C1C
	.long 0x0A00010B
	.long 0x000092F4
	.long 0xCC000000
	.long 0x00009C44
	.long 0x208A0000
	.long 0x00009C48
	.long 0x23022000
	.long 0x00009CE4
	.long 0x2A8C8000
	.long 0x00009CE8
	.long 0x2D022000
	.long 0x00009DA0
	.long 0x2D190000
	.long 0x00009E70
	.long 0x88000002
	.long 0x00009E74
	.long 0x1C0B4000
	.long 0x00009E78
	.long 0x20822000
	.long 0x00009EA8
	.long 0x2C000001
	.long 0x00009EE0
	.long 0x5000008B
	.long 0x0000ABB0
	.long 0x2C016004
	.long 0x0000ABB4
	.long 0x05DC0000
	.long 0x0000ABB8
	.long 0x07D00000
	.long 0x0000ABBC
	.long 0x89990017
	.long 0x0000ABC0
	.long 0x280C010F
	.long 0xCC00D13C
	.long 0x0000AB90
	.long 0xFFFFFFFF
	.long 0x00003644
	.long 0x3D4CCCCD
	.long 0x00003648
	.long 0x3D8F5C29
	.long 0x0000364C
	.long 0x3F4CCCCD
	.long 0x00003660
	.long 0x3F933333
	.long 0x0000366C
	.long 0x3FC374BC
	.long 0x0000367C
	.long 0x40C00000
	.long 0x000036B0
	.long 0x3F800000
	.long 0x000036C0
	.long 0x41900000
	.long 0x000036CC
	.long 0x42EC0000
	.long 0x000036D4
	.long 0x42030000
	.long 0x00003728
	.long 0x40800000
	.long 0x00003730
	.long 0x41C00000
	.long 0x00003734
	.long 0x41D00000
	.long 0x0000373C
	.long 0x42000000
	.long 0x000037C4
	.long 0x0C000000
	.long 0x0000381C
	.long 0x40000000
	.long 0x00003834
	.long 0x3DA3D70A
	.long 0x00003910
	.long 0x08000006
	.long 0x00003928
	.long 0x2C09B805
	.long 0x0000392C
	.long 0x06400000
	.long 0x00003930
	.long 0x00000190
	.long 0x00003934
	.long 0x20990C92
	.long 0x00003938
	.long 0x000C010F
	.long 0x0000393C
	.long 0x04000003
	.long 0x00003940
	.long 0x40000000
	.long 0x00003998
	.long 0x07080000
	.long 0x000039A0
	.long 0x00190013
	.long 0x000039A4
	.long 0x00200007
	.long 0x000039B4
	.long 0x00190013
	.long 0x000039B8
	.long 0x00200007
	.long 0x000039BC
	.long 0x2D000008
	.long 0x000039C0
	.long 0x05DC0000
	.long 0x000039C8
	.long 0x00190013
	.long 0x000039CC
	.long 0x00200007
	.long 0x000039D0
	.long 0x2D80000C
	.long 0x000039D4
	.long 0x076C0000
	.long 0x000039D8
	.long 0x06A419C8
	.long 0x000039DC
	.long 0x280F0013
	.long 0x000039E0
	.long 0x280C510F
	.long 0x00003A40
	.long 0x2C09B806
	.long 0x00003AEC
	.long 0x2B850000
	.long 0x00003AF0
	.long 0x3C002000
	.long 0x00003B14
	.long 0x00000012
	.long 0x00003B18
	.long 0x000C010F
	.long 0x00003D1C
	.long 0x28154013
	.long 0x00003D30
	.long 0x28154013
	.long 0x00003D94
	.long 0x280C0D0F
	.long 0x00003DA8
	.long 0x280C0D0F
	.long 0x00003DDC
	.long 0x190C0C8F
	.long 0x00003DF0
	.long 0x190C0C8F
	.long 0x00003EC8
	.long 0x190C0C0F
	.long 0x00003EEC
	.long 0x190C0C0F
	.long 0x00003F7C
	.long 0x2C000014
	.long 0x00003F88
	.long 0x26158013
	.long 0x00003F8C
	.long 0x20808C8B
	.long 0x00003FD4
	.long 0x26170013
	.long 0x00003FD8
	.long 0x2080408B
	.long 0x00003FF0
	.long 0x3C00408A
	.long 0x000047B8
	.long 0x29990513
	.long 0x000047BC
	.long 0x000C108F
	.long 0x000047CC
	.long 0x29990513
	.long 0x000047D0
	.long 0x000C108F
	.long 0x000047E0
	.long 0x29990513
	.long 0x000047E4
	.long 0x000C108F
	.long 0x000047FC
	.long 0x08000010
	.long 0x00004830
	.long 0x0F0C108F
	.long 0x00004844
	.long 0x0F0C108F
	.long 0x00004858
	.long 0x0F0C108F
	.long 0x000048B4
	.long 0x3C00308B
	.long 0x000048C8
	.long 0x3C00308B
	.long 0x000048F4
	.long 0x2800308B
	.long 0x00004950
	.long 0x08000025
	.long 0x00004958
	.long 0x08000028
	.long 0x00004994
	.long 0x0E801C8B
	.long 0x00004998
	.long 0x2C81300F
	.long 0x000049A8
	.long 0x0E801C8B
	.long 0x000049BC
	.long 0x0E801C8B
	.long 0x000049C8
	.long 0x08000020
	.long 0x00004A14
	.long 0x0C801C8B
	.long 0x00004A18
	.long 0x2C81300E
	.long 0x00004A28
	.long 0x0C801C8B
	.long 0x00004A2C
	.long 0x2D01100E
	.long 0x00004A3C
	.long 0x0C801C8B
	.long 0x00004A50
	.long 0x08000020
	.long 0x00004AA8
	.long 0x0F801C8B
	.long 0x00004AAC
	.long 0x2C81300D
	.long 0x00004ABC
	.long 0x10001C8B
	.long 0x00004AD0
	.long 0x0F801C8B
	.long 0x00004ADC
	.long 0x08000020
	.long 0x00004B10
	.long 0x140C1C8F
	.long 0x00004B24
	.long 0x140C1C8F
	.long 0x00004B28
	.long 0x04000007
	.long 0x00004B30
	.long 0x08000025
	.long 0x00004B54
	.long 0x2C02080F
	.long 0x00004B64
	.long 0x0F0C280B
	.long 0x00004B68
	.long 0x2C81E80F
	.long 0x00004B78
	.long 0x0F0C280B
	.long 0x00004B94
	.long 0x2C01300C
	.long 0x00004BA4
	.long 0x060C200B
	.long 0x00004BA8
	.long 0x2C81100C
	.long 0x00004BB8
	.long 0x060C200B
	.long 0x00004BC4
	.long 0x0800002E
	.long 0x00004C38
	.long 0x2C017819
	.long 0x00004C3C
	.long 0x064000C8
	.long 0x00004C48
	.long 0x19007907
	.long 0x00004C4C
	.long 0x2C818019
	.long 0x00004C50
	.long 0x07D000C8
	.long 0x00004C5C
	.long 0x19007907
	.long 0x00004C74
	.long 0x04000009
	.long 0x00004C7C
	.long 0x08000030
	.long 0x00004C84
	.long 0x08000037
	.long 0x00004CF4
	.long 0x2C00E814
	.long 0x00004D00
	.long 0x2D17C013
	.long 0x00004D04
	.long 0x140C5123
	.long 0x00004D08
	.long 0x2C80E811
	.long 0x00004D14
	.long 0x2D17C013
	.long 0x00004D18
	.long 0x140C5123
	.long 0x00004D34
	.long 0x2C00000C
	.long 0x00004D38
	.long 0x06400000
	.long 0x00004D3C
	.long 0x0640F704
	.long 0x00004D40
	.long 0x7F190013
	.long 0x00004D44
	.long 0x1E00290A
	.long 0x00004D48
	.long 0x2C80000C
	.long 0x00004D4C
	.long 0x06400000
	.long 0x00004D50
	.long 0x064008FC
	.long 0x00004D54
	.long 0x7F190013
	.long 0x00004D58
	.long 0x1E00290A
	.long 0x00004D94
	.long 0x08000023
	.long 0x00004D9C
	.long 0x08000028
	.long 0x00004DA4
	.long 0x0800002B
	.long 0x00004E48
	.long 0x5A190473
	.long 0x00004E4C
	.long 0x000C110F
	.long 0x00004E5C
	.long 0x5A190473
	.long 0x00004E60
	.long 0x000C110F
	.long 0x00004E70
	.long 0x6E190473
	.long 0x00004E74
	.long 0x000C110F
	.long 0x00004E84
	.long 0x6E190473
	.long 0x00004E88
	.long 0x000C110F
	.long 0x00004EB8
	.long 0x140C2123
	.long 0x00004EEC
	.long 0x0800003F
	.long 0x00004F20
	.long 0x2C00F00F
	.long 0x00004F2C
	.long 0x13190013
	.long 0x00004F30
	.long 0x0A002907
	.long 0x00004F74
	.long 0x2C013010
	.long 0x00004F80
	.long 0xB4954013
	.long 0x00004F84
	.long 0x19002107
	.long 0x00004F88
	.long 0x2C81100F
	.long 0x00004F94
	.long 0xB4954013
	.long 0x00004F98
	.long 0x19002107
	.long 0x00004F9C
	.long 0x2D01E00E
	.long 0x00004FA8
	.long 0xB4954013
	.long 0x00004FAC
	.long 0x19002107
	.long 0x00004FF0
	.long 0x2C00E80F
	.long 0x00005000
	.long 0x0C8C290F
	.long 0x00005004
	.long 0x0800000E
	.long 0x0000505C
	.long 0x2C018012
	.long 0x0000506C
	.long 0x19003507
	.long 0x0000508C
	.long 0x08000006
	.long 0x00005090
	.long 0x4C000001
	.long 0x00005094
	.long 0x08000011
	.long 0x00005098
	.long 0x90000000
	.long 0x0000509C
	.long 0x8C000000
	.long 0x000050A0
	.long 0x44040000
	.long 0x000050A4
	.long 0x0000009D
	.long 0x000050A8
	.long 0x00007F40
	.long 0x000050AC
	.long 0x2C008810
	.long 0x000050B0
	.long 0x06400000
	.long 0x000050B4
	.long 0x000003E8
	.long 0x000050B8
	.long 0x871B0013
	.long 0x000050BC
	.long 0x11843907
	.long 0x000050C0
	.long 0x2C820810
	.long 0x000050C4
	.long 0x06400000
	.long 0x000050C8
	.long 0x00000190
	.long 0x000050CC
	.long 0x871B0013
	.long 0x000050D0
	.long 0x11843907
	.long 0x000050D4
	.long 0x04000005
	.long 0x000050D8
	.long 0x40000000
	.long 0x000050DC
	.long 0x0800001F
	.long 0x000050E8
	.long 0x4C000000
	.long 0x000050EC
	.long 0x0800002A
	.long 0x000050F0
	.long 0x5C000000
	.long 0x000051CC
	.long 0x00000000
	.long 0x000051D4
	.long 0x20878010
	.long 0x000051D8
	.long 0x1D0C010C
	.long 0x000051E0
	.long 0x00000000
	.long 0x000051E8
	.long 0x20878010
	.long 0x000051EC
	.long 0x1D0C010C
	.long 0x0000521C
	.long 0x7C000000
	.long 0x000063A0
	.long 0x09C41838
	.long 0x000063B4
	.long 0x09C41194
	.long 0x000063C8
	.long 0x09C40AF0
	.long 0x0000641C
	.long 0x0A8C1F40
	.long 0x00006430
	.long 0x09C4189C
	.long 0x00006444
	.long 0x0A8C11F8
	.long 0x0000649C
	.long 0xB4960000
	.long 0x00006524
	.long 0x169BC000
	.long 0x00006528
	.long 0x13072000
	.long 0x000074E0
	.long 0x44080000
	.long 0x000074E4
	.long 0x000249F8
	.long 0x000074E8
	.long 0x00007F40
	.long 0x000074EC
	.long 0x28000000
	.long 0x000074F0
	.long 0x04040000
	.long 0x00007500
	.long 0x0800000B
	.long 0x00007504
	.long 0x28000000
	.long 0x00007508
	.long 0x04070000
	.long 0x00007518
	.long 0x28000000
	.long 0x0000751C
	.long 0x03EF0000
	.long 0x0000752C
	.long 0x44000000
	.long 0x00007530
	.long 0x00024A2E
	.long 0x00007534
	.long 0x00007F40
	.long 0x00007538
	.long 0x4C000001
	.long 0x0000753C
	.long 0x2C000004
	.long 0x00007540
	.long 0x08340000
	.long 0x00007544
	.long 0x05001194
	.long 0x00007548
	.long 0x25990DD3
	.long 0x0000754C
	.long 0x0000008B
	.long 0x00007550
	.long 0x04000001
	.long 0x00007554
	.long 0x40000000
	.long 0x00007558
	.long 0x08000026
	.long 0x0000755C
	.long 0x4C000001
	.long 0x00007560
	.long 0x2C000015
	.long 0x00007564
	.long 0x07D00000
	.long 0x00007568
	.long 0x0514FE70
	.long 0x0000756C
	.long 0x26170013
	.long 0x00007570
	.long 0x2080408B
	.long 0x00007610
	.long 0x20808C8B
	.long 0xCC008220
	.long 0x00000C84
	.long 0x00008224
	.long 0x000B5FE0
	.long 0x00008228
	.long 0x000015C9
	.long 0xCC008298
	.long 0x000009E4
	.long 0x0000829C
	.long 0x00070100
	.long 0x000082A0
	.long 0x00001FE9
	.long 0xCC0098C4
	.long 0x000074C0
	.long 0xFFFFFFFF
	.long 0x00003334
	.long 0x11818013
	.long 0x00003414
	.long 0x3DA3D70A
	.long 0x00003418
	.long 0x3FB33333
	.long 0x00003434
	.long 0x40A00000
	.long 0x00003CBC
	.long 0x2C00D006
	.long 0x00003CD0
	.long 0x2C80D007
	.long 0x00003CE4
	.long 0x2D00B807
	.long 0x00003CF8
	.long 0x2D819807
	.long 0x00003F6C
	.long 0x40000000
	.long 0x00003F70
	.long 0x40F00000
	.long 0x00003FB8
	.long 0x02000000
	.long 0x00003FC0
	.long 0xB4940000
	.long 0x00003FC4
	.long 0x080E000F
	.long 0x00004168
	.long 0x2C000008
	.long 0x00004174
	.long 0x23078000
	.long 0x00004274
	.long 0x2C000006
	.long 0x000047B8
	.long 0x32050013
	.long 0x000047BC
	.long 0x140C000F
	.long 0x000047CC
	.long 0x27050013
	.long 0x000047D0
	.long 0x140C000F
	.long 0x000047E0
	.long 0x1E050013
	.long 0x000047E4
	.long 0x140C000F
	.long 0x000047F4
	.long 0x19050013
	.long 0x000047F8
	.long 0x140C000F
	.long 0x00004840
	.long 0x2C00D005
	.long 0x0000484C
	.long 0x0F118013
	.long 0x00004850
	.long 0x190C008F
	.long 0x00004854
	.long 0x2C80D005
	.long 0x00004860
	.long 0x0F118013
	.long 0x00004864
	.long 0x190C008F
	.long 0x00004868
	.long 0x2D00B805
	.long 0x00004874
	.long 0x0F118013
	.long 0x00004878
	.long 0x190C008F
	.long 0x0000487C
	.long 0x2D809805
	.long 0x00004888
	.long 0x0F118013
	.long 0x0000488C
	.long 0x190C008F
	.long 0x000049A4
	.long 0x2D0DC013
	.long 0x000049A8
	.long 0x208C008F
	.long 0x000049B8
	.long 0x280DC013
	.long 0x000049BC
	.long 0x208C008F
	.long 0x000049CC
	.long 0x230DC013
	.long 0x000049D0
	.long 0x208C008F
	.long 0x000049E0
	.long 0x1E0DC013
	.long 0x000049E4
	.long 0x208C008F
	.long 0x00004A1C
	.long 0x08000024
	.long 0x00004A50
	.long 0x0F148013
	.long 0x00004A54
	.long 0x0A0C008F
	.long 0x00004A58
	.long 0x2C80D00E
	.long 0x00004A64
	.long 0x0F148013
	.long 0x00004A68
	.long 0x0A0C008F
	.long 0x00004A78
	.long 0x0F148013
	.long 0x00004A7C
	.long 0x0A0C008F
	.long 0x00004A8C
	.long 0x0F168013
	.long 0x00004A90
	.long 0x0A0C008F
	.long 0x00004AE0
	.long 0x2C00D00D
	.long 0x00004AEC
	.long 0x2F970013
	.long 0x00004AF0
	.long 0x130C008F
	.long 0x00004AF4
	.long 0x2C80D00D
	.long 0x00004B00
	.long 0x2A990013
	.long 0x00004B04
	.long 0x130C008F
	.long 0x00004B08
	.long 0x2D00B80D
	.long 0x00004B14
	.long 0x2A978013
	.long 0x00004B18
	.long 0x130C008F
	.long 0x00004B1C
	.long 0x2D80980D
	.long 0x00004B28
	.long 0x2A974013
	.long 0x00004B2C
	.long 0x130C008F
	.long 0x00004B50
	.long 0x0800001E
	.long 0x00004B78
	.long 0x8C0C8013
	.long 0x00004C48
	.long 0xB4974013
	.long 0x00004C5C
	.long 0xB497C013
	.long 0x00004C70
	.long 0xB497C013
	.long 0x00004C84
	.long 0xB497C011
	.long 0x00004CCC
	.long 0x08000028
	.long 0x00004DDC
	.long 0x0800000A
	.long 0x00004DE4
	.long 0x06720384
	.long 0x00004DEC
	.long 0x2F990513
	.long 0x00004DF0
	.long 0x000C000F
	.long 0x00004DF8
	.long 0x067201C2
	.long 0x00004E00
	.long 0x31190613
	.long 0x00004E04
	.long 0x000C000F
	.long 0x00004E0C
	.long 0x04B00000
	.long 0x00004E14
	.long 0x31190513
	.long 0x00004E18
	.long 0x000C000F
	.long 0x00004E20
	.long 0x03E80000
	.long 0x00004E28
	.long 0x31190513
	.long 0x00004E2C
	.long 0x000C000F
	.long 0x00004E60
	.long 0x04000007
	.long 0x00004E68
	.long 0x04000003
	.long 0x00004E70
	.long 0x08000014
	.long 0x00004E78
	.long 0x08000016
	.long 0x00004E7C
	.long 0x2C00D003
	.long 0x00004E80
	.long 0x06720384
	.long 0x00004E88
	.long 0x2E9903D3
	.long 0x00004E90
	.long 0x2C80D003
	.long 0x00004E94
	.long 0x067201C2
	.long 0x00004EA4
	.long 0x2D00B803
	.long 0x00004EA8
	.long 0x04B00000
	.long 0x00004EB8
	.long 0x2D809803
	.long 0x00004EBC
	.long 0x03E80000
	.long 0x00004EDC
	.long 0x04000009
	.long 0x00004EE4
	.long 0x04000008
	.long 0x00004EEC
	.long 0x08000023
	.long 0x00004EF4
	.long 0x08000025
	.long 0x00004EFC
	.long 0x06720384
	.long 0x00004F04
	.long 0x2817C013
	.long 0x00004F10
	.long 0x06720190
	.long 0x00004F18
	.long 0x2D17C013
	.long 0x00004F24
	.long 0x04B00000
	.long 0x00004F2C
	.long 0x2D17C013
	.long 0x00004F38
	.long 0x03E80000
	.long 0x00004F40
	.long 0x2D17C013
	.long 0x00004F5C
	.long 0x04000008
	.long 0x00004F64
	.long 0x04000009
	.long 0x00004F6C
	.long 0x0800003C
	.long 0x00004FAC
	.long 0x2C00D00E
	.long 0x00005050
	.long 0x2C00D010
	.long 0x000050F0
	.long 0x2C00680C
	.long 0x00005104
	.long 0x2C80380C
	.long 0x00005118
	.long 0x2D00200C
	.long 0x0000513C
	.long 0x04000004
	.long 0x0000517C
	.long 0x04000014
	.long 0x00005180
	.long 0x04000002
	.long 0x000051A4
	.long 0x2C00D00E
	.long 0x000051B4
	.long 0x0C8C010F
	.long 0x000051B8
	.long 0x2C80B80E
	.long 0x000051C8
	.long 0x0C8C010F
	.long 0x000051CC
	.long 0x2D00980E
	.long 0x000051DC
	.long 0x0C8C010F
	.long 0x000051E0
	.long 0x2D80D00E
	.long 0x000051F0
	.long 0x0C8C010F
	.long 0x00005208
	.long 0x08000011
	.long 0x0000520C
	.long 0x0800001B
	.long 0x00005210
	.long 0xC4000000
	.long 0x00005214
	.long 0x0800001E
	.long 0x00005218
	.long 0x2C00D008
	.long 0x0000521C
	.long 0x038401F4
	.long 0x00005220
	.long 0x00000000
	.long 0x00005224
	.long 0x0C990013
	.long 0x00005228
	.long 0x0F0C008F
	.long 0x0000522C
	.long 0x2C80B808
	.long 0x00005230
	.long 0x02580000
	.long 0x00005234
	.long 0x00000000
	.long 0x00005238
	.long 0x0C990013
	.long 0x0000523C
	.long 0x0F0C008F
	.long 0x00005240
	.long 0x2D009808
	.long 0x00005244
	.long 0x01900000
	.long 0x00005248
	.long 0x00000000
	.long 0x0000524C
	.long 0x0C990013
	.long 0x00005250
	.long 0x0F0C008F
	.long 0x00005254
	.long 0x2D80D008
	.long 0x00005258
	.long 0x0384044C
	.long 0x0000525C
	.long 0x00000000
	.long 0x00005260
	.long 0x0C990013
	.long 0x00005264
	.long 0x0F0C008F
	.long 0x00005268
	.long 0x08000022
	.long 0x0000526C
	.long 0x40000000
	.long 0x00005270
	.long 0x04000002
	.long 0x00005274
	.long 0xC5FFFFFF
	.long 0x00005278
	.long 0x08000030
	.long 0x0000527C
	.long 0x4C000000
	.long 0x00005280
	.long 0x08000031
	.long 0x00005284
	.long 0x5C000000
	.long 0x000052A4
	.long 0x241E0013
	.long 0x000052B8
	.long 0x241E0013
	.long 0x000052CC
	.long 0x241E0013
	.long 0x000052FC
	.long 0x050C0055
	.long 0x00005310
	.long 0x050C02FE
	.long 0x00005324
	.long 0x05780000
	.long 0x0000537C
	.long 0x2817C013
	.long 0x00005390
	.long 0x2817C013
	.long 0x000053A4
	.long 0x2817C013
	.long 0x00005418
	.long 0x20968013
	.long 0x0000542C
	.long 0x20968013
	.long 0x00005440
	.long 0x20968013
	.long 0x0000673C
	.long 0x0020008B
	.long 0x00006764
	.long 0x0020008B
	.long 0x00006790
	.long 0x0020008B
	.long 0x000067C8
	.long 0x0020008B
	.long 0x000067DC
	.long 0x0020008B
	.long 0x00006808
	.long 0x0020008B
	.long 0x0000684C
	.long 0x88000006
	.long 0x00006850
	.long 0x11940000
	.long 0x00006854
	.long 0x19022000
	.long 0x000068E0
	.long 0x88000006
	.long 0x000068E4
	.long 0x41158000
	.long 0x000068E8
	.long 0x19822000
	.long 0x000069A8
	.long 0x88000003
	.long 0x000069AC
	.long 0x28168000
	.long 0x000069B0
	.long 0x19022000
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x000034FC
	.long 0x3FB66666
	.long 0x00003508
	.long 0x3FC00000
	.long 0x00003544
	.long 0x3D851EB8
	.long 0x0000354C
	.long 0x3F7573EB
	.long 0x000035C8
	.long 0x41900000
	.long 0x000035D8
	.long 0x41900000
	.long 0x00003668
	.long 0x0000000A
	.long 0x00003680
	.long 0x00000000
	.long 0x00003684
	.long 0xBF0A3D71
	.long 0x0000369C
	.long 0x40800000
	.long 0x000036A4
	.long 0x00000014
	.long 0x000036C0
	.long 0x3D83126F
	.long 0x000036D8
	.long 0x41A00000
	.long 0x00003A10
	.long 0x2C00C019
	.long 0x00003A1C
	.long 0xB4940013
	.long 0x00003A20
	.long 0x2988011F
	.long 0x00003A64
	.long 0x2C00C014
	.long 0x00003A70
	.long 0xB4918013
	.long 0x00003A74
	.long 0x1B88011F
	.long 0x00003BF8
	.long 0x00007100
	.long 0x00003CA8
	.long 0x41800000
	.long 0x00003CAC
	.long 0x3FB33333
	.long 0x00003CB0
	.long 0x3D4CCCCD
	.long 0x00003CB4
	.long 0x3D23D70A
	.long 0x00003CC0
	.long 0x41700000
	.long 0x00003CC4
	.long 0x40800000
	.long 0x00003D88
	.long 0x3FB70A3D
	.long 0x00003D98
	.long 0x10CC0000
	.long 0x00003DA0
	.long 0x230C8000
	.long 0x00003DA4
	.long 0x280800A3
	.long 0x00003E7C
	.long 0x50000000
	.long 0x00003E80
	.long 0x05060023
	.long 0x00003F38
	.long 0x003F0000
	.long 0x00003F4C
	.long 0x05040020
	.long 0x00003F54
	.long 0x04000005
	.long 0x00003F5C
	.long 0x2C000003
	.long 0x00003F68
	.long 0x2E800000
	.long 0x00003F80
	.long 0x2E800000
	.long 0x00003F94
	.long 0x04000001
	.long 0x00004054
	.long 0x41000000
	.long 0x0000408C
	.long 0x00004038
	.long 0x00004804
	.long 0x1400008B
	.long 0x00004818
	.long 0x1400008B
	.long 0x00004894
	.long 0x00190781
	.long 0x00004898
	.long 0x0008049E
	.long 0x000048A8
	.long 0xB4918001
	.long 0x000048BC
	.long 0x00190791
	.long 0x000048C0
	.long 0x00000407
	.long 0x000048DC
	.long 0x04000004
	.long 0x000048E4
	.long 0x0800000F
	.long 0x000048F4
	.long 0x00000001
	.long 0x000048F8
	.long 0x1E08049F
	.long 0x00004914
	.long 0x04000004
	.long 0x0000491C
	.long 0x08000016
	.long 0x00004924
	.long 0x05780000
	.long 0x0000492C
	.long 0x32110001
	.long 0x00004930
	.long 0x2808049F
	.long 0x0000494C
	.long 0x04000004
	.long 0x00004A7C
	.long 0x30190013
	.long 0x00004A80
	.long 0x1B800087
	.long 0x00004A90
	.long 0x30190013
	.long 0x00004A94
	.long 0x1B800087
	.long 0x00004AB8
	.long 0x08000018
	.long 0x00004B80
	.long 0x0800000E
	.long 0x00004BA4
	.long 0xB4920017
	.long 0x00004BB8
	.long 0xB4920017
	.long 0x00004BCC
	.long 0xB4920017
	.long 0x00004BE0
	.long 0xB4920017
	.long 0x00004BFC
	.long 0x08000013
	.long 0x00004C08
	.long 0x0800002A
	.long 0x00004CB8
	.long 0x0800000C
	.long 0x00004CBC
	.long 0x44040000
	.long 0x00004CC0
	.long 0x000000A0
	.long 0x00004CC4
	.long 0x00007F40
	.long 0x00004CC8
	.long 0x2C01E80C
	.long 0x00004CCC
	.long 0x03E80000
	.long 0x00004CD4
	.long 0x23198010
	.long 0x00004CD8
	.long 0x1400010B
	.long 0x00004CE4
	.long 0x2C01E80C
	.long 0x00004CE8
	.long 0x03E80000
	.long 0x00004CF0
	.long 0x28198010
	.long 0x00004CF4
	.long 0x1400010B
	.long 0x00004D04
	.long 0x2C01E807
	.long 0x00004D08
	.long 0x044C0000
	.long 0x00004D10
	.long 0x2F8C8010
	.long 0x00004D14
	.long 0x0C800D8B
	.long 0x00004D20
	.long 0x2C01E80C
	.long 0x00004D24
	.long 0x03E80000
	.long 0x00004D2C
	.long 0x2A970010
	.long 0x00004D30
	.long 0x1400010B
	.long 0x00004D8C
	.long 0x08000031
	.long 0x00004DDC
	.long 0x2C01E80C
	.long 0x00004DE0
	.long 0x03E80000
	.long 0x00004DE8
	.long 0x0C918010
	.long 0x00004DEC
	.long 0x1900010B
	.long 0x00004E04
	.long 0x2C01E80C
	.long 0x00004E08
	.long 0x03E80000
	.long 0x00004E10
	.long 0x0C918010
	.long 0x00004E14
	.long 0x1900010B
	.long 0x00004E28
	.long 0x2C01E807
	.long 0x00004E2C
	.long 0x044C0000
	.long 0x00004E34
	.long 0x3E918010
	.long 0x00004E38
	.long 0x0F00018B
	.long 0x00004E48
	.long 0x2C01E80C
	.long 0x00004E4C
	.long 0x03E80000
	.long 0x00004E54
	.long 0x0C92C010
	.long 0x00004E58
	.long 0x1400010B
	.long 0x00004E64
	.long 0x08000004
	.long 0x00004E6C
	.long 0x2C01080D
	.long 0x00004E7C
	.long 0x0A00010B
	.long 0x00004E80
	.long 0x2C80580D
	.long 0x00004E90
	.long 0x0A00010B
	.long 0x00004E94
	.long 0x2D00200D
	.long 0x00004EA4
	.long 0x0A00010B
	.long 0x00004ECC
	.long 0x0280010B
	.long 0x00004EE0
	.long 0x0280010B
	.long 0x00004EF4
	.long 0x0280010B
	.long 0x00004F08
	.long 0x0800001C
	.long 0x00004F40
	.long 0x08080C9F
	.long 0x00004F44
	.long 0x2C800003
	.long 0x00004F54
	.long 0x08080C07
	.long 0x00004F84
	.long 0xB4990013
	.long 0x00004F88
	.long 0x0C08111F
	.long 0x00004F98
	.long 0xB4990013
	.long 0x00004F9C
	.long 0x0C08111F
	.long 0x0000500C
	.long 0x10190013
	.long 0x00005020
	.long 0x10190013
	.long 0x00005038
	.long 0x04000003
	.long 0x000050BC
	.long 0x08000022
	.long 0x00005110
	.long 0x04000009
	.long 0x00005114
	.long 0x40000000
	.long 0x00005118
	.long 0x08000030
	.long 0x00006078
	.long 0x08000006
	.long 0x00006090
	.long 0x051409C4
	.long 0x000060A0
	.long 0x03200000
	.long 0x000060A4
	.long 0x05140640
	.long 0x000060BC
	.long 0x04000003
	.long 0x000060E4
	.long 0x08000008
	.long 0x000060F8
	.long 0x041A0000
	.long 0x000060FC
	.long 0x05140AF0
	.long 0x0000610C
	.long 0x03840000
	.long 0x00006110
	.long 0x05140834
	.long 0x00006120
	.long 0x03200000
	.long 0x00006124
	.long 0x05140578
	.long 0x0000613C
	.long 0x04000003
	.long 0x000061A4
	.long 0x168A0000
	.long 0x000062E0
	.long 0x2F822000
	.long 0x0000637C
	.long 0x2D0C8000
	.long 0x00006380
	.long 0x258A8000
	.long 0x00007120
	.long 0xD0000003
	.long 0x00007124
	.long 0x44000000
	.long 0x00007128
	.long 0x000334A4
	.long 0x0000712C
	.long 0x00007F40
	.long 0x00007130
	.long 0x28000000
	.long 0x00007134
	.long 0x04060000
	.long 0x00007144
	.long 0x28000000
	.long 0x00007148
	.long 0x03F40000
	.long 0x0000714C
	.long 0x00000898
	.long 0x00007150
	.long 0x07080400
	.long 0x00007154
	.long 0x04000400
	.long 0x00007158
	.long 0x2C000007
	.long 0x00007160
	.long 0x04B00000
	.long 0x00007164
	.long 0x23154012
	.long 0x00007168
	.long 0x1E080120
	.long 0x0000716C
	.long 0x68000000
	.long 0xCC009470
	.long 0x00007100
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x00003398
	.long 0x41C00000
	.long 0x000035E4
	.long 0x03840000
	.long 0x000035F8
	.long 0x03840000
	.long 0x00003608
	.long 0x04000002
	.long 0x0000361C
	.long 0x03840000
	.long 0x00003630
	.long 0x03840000
	.long 0x00003640
	.long 0x04000002
	.long 0x00004154
	.long 0x05140000
	.long 0x000041B4
	.long 0x05140000
	.long 0x00004214
	.long 0x05140000
	.long 0x00004294
	.long 0x05140000
	.long 0x00004304
	.long 0x05140000
	.long 0x0000438C
	.long 0x2C007806
	.long 0x00004394
	.long 0x05140000
	.long 0x00004398
	.long 0x0A168013
	.long 0x000043A0
	.long 0x2C805006
	.long 0x000043AC
	.long 0x0A168013
	.long 0x000043D0
	.long 0x08000018
	.long 0x00004498
	.long 0x08000010
	.long 0x000044FC
	.long 0x05140000
	.long 0x00004588
	.long 0x044C0000
	.long 0x0000460C
	.long 0x044C0000
	.long 0x00004610
	.long 0x05140000
	.long 0x00004620
	.long 0x03E80000
	.long 0x00004690
	.long 0x14000107
	.long 0x00004694
	.long 0x2C80780B
	.long 0x000046A0
	.long 0x87190013
	.long 0x000046FC
	.long 0x05140000
	.long 0x00004758
	.long 0x05140000
	.long 0x00004784
	.long 0x05140000
	.long 0x000047E0
	.long 0x05DC0000
	.long 0xFFFFFFFF
	.long 0x0000127C
	.long 0x41C00000
	.long 0x000014C8
	.long 0x03840000
	.long 0x000014DC
	.long 0x03840000
	.long 0x000014EC
	.long 0x04000002
	.long 0x00001500
	.long 0x03840000
	.long 0x00001514
	.long 0x03840000
	.long 0x00001524
	.long 0x04000002
	.long 0x00002038
	.long 0x05140000
	.long 0x00002098
	.long 0x05140000
	.long 0x000020F8
	.long 0x05140000
	.long 0x00002178
	.long 0x05140000
	.long 0x000021E8
	.long 0x05140000
	.long 0x00002270
	.long 0x2C007806
	.long 0x00002278
	.long 0x05140000
	.long 0x0000227C
	.long 0x0A168013
	.long 0x00002290
	.long 0x0A168013
	.long 0x000022B4
	.long 0x08000018
	.long 0x0000237C
	.long 0x08000010
	.long 0x000023E0
	.long 0x05140000
	.long 0x0000246C
	.long 0x044C0000
	.long 0x000024F0
	.long 0x044C0000
	.long 0x000024F4
	.long 0x05140000
	.long 0x00002504
	.long 0x03E80000
	.long 0x00002574
	.long 0x14000107
	.long 0x00002578
	.long 0x2C80780B
	.long 0x00002584
	.long 0x87190013
	.long 0x000025E0
	.long 0x05140000
	.long 0x0000263C
	.long 0x05140000
	.long 0x00002668
	.long 0x05140000
	.long 0x000026C4
	.long 0x05DC0000
	.long 0xCC005014
	.long 0x00001E64
	.long 0xFFFFFFFF
	.long 0x0000359C
	.long 0x3D8F5C29
	.long 0x00003614
	.long 0x41600000
	.long 0x00003670
	.long 0x41500000
	.long 0x00003674
	.long 0x41A00000
	.long 0x00003678
	.long 0x41B00000
	.long 0x0000367C
	.long 0x41C80000
	.long 0x00003744
	.long 0x3FC66666
	.long 0x00003E28
	.long 0x2C00000C
	.long 0x00004348
	.long 0x08000028
	.long 0x00004358
	.long 0x2C01580B
	.long 0x0000436C
	.long 0x2C81180B
	.long 0x00004380
	.long 0x2D00200B
	.long 0x000043C0
	.long 0x2C01580A
	.long 0x000043D4
	.long 0x2C81180A
	.long 0x000043E8
	.long 0x2D00200A
	.long 0x00004428
	.long 0x2C015809
	.long 0x0000443C
	.long 0x2C811809
	.long 0x00004450
	.long 0x2D002009
	.long 0x0000448C
	.long 0x2C017809
	.long 0x00004498
	.long 0x301A0013
	.long 0x000044A0
	.long 0x2C817809
	.long 0x000044AC
	.long 0x301A0013
	.long 0x000044B4
	.long 0x2D017808
	.long 0x000044C0
	.long 0x2C1A0013
	.long 0x00004508
	.long 0x2C017809
	.long 0x0000451C
	.long 0x2C817809
	.long 0x00004530
	.long 0x2D017809
	.long 0x00004618
	.long 0x05530000
	.long 0x0000461C
	.long 0x044C0CE4
	.long 0x00004694
	.long 0x04000003
	.long 0x000047A0
	.long 0x2C01780B
	.long 0x000047AC
	.long 0x14190011
	.long 0x000047B0
	.long 0x0A00000B
	.long 0x000047B4
	.long 0x2C81780B
	.long 0x000047C0
	.long 0x14190011
	.long 0x000047C4
	.long 0x0A00000B
	.long 0x000047C8
	.long 0x2D01780B
	.long 0x000047D4
	.long 0x14190011
	.long 0x000047D8
	.long 0x0A00000B
	.long 0x00004878
	.long 0x05DC0000
	.long 0x00004880
	.long 0x6E190590
	.long 0x00004884
	.long 0x0008009F
	.long 0x00004888
	.long 0x2C000002
	.long 0x0000488C
	.long 0x05DC0000
	.long 0x00004890
	.long 0x0640F830
	.long 0x00004894
	.long 0x6E078010
	.long 0x0000489C
	.long 0x2C800002
	.long 0x000048A0
	.long 0x05DC0000
	.long 0x000048A4
	.long 0x064007D0
	.long 0x000048A8
	.long 0x6E078010
	.long 0x000048AC
	.long 0x2308009F
	.long 0x00004948
	.long 0x2D00000C
	.long 0x0000494C
	.long 0x051B0000
	.long 0x00004950
	.long 0x01F40064
	.long 0x000049F4
	.long 0x26080013
	.long 0x000049F8
	.long 0x13080C9F
	.long 0x00004A08
	.long 0x26080013
	.long 0x00004A0C
	.long 0x13080C9F
	.long 0x00004A20
	.long 0x04000002
	.long 0x00004A28
	.long 0x0800001E
	.long 0x00004A4C
	.long 0x2C00700E
	.long 0x00004A5C
	.long 0x0C80010B
	.long 0x00004A60
	.long 0x2C80200E
	.long 0x00004A70
	.long 0x0C80010B
	.long 0x00004B98
	.long 0x11940013
	.long 0x00004BAC
	.long 0x11940013
	.long 0x00004C74
	.long 0x1E0DC013
	.long 0x00004C78
	.long 0x2D08011F
	.long 0x00004C88
	.long 0x1E0DC013
	.long 0x00004C8C
	.long 0x2D08011F
	.long 0x00005494
	.long 0x08000014
	.long 0x00005CB4
	.long 0x88000005
	.long 0xCC007AF4
	.long 0x00000E78
	.long 0x00007AF8
	.long 0x0009A8C0
	.long 0x00007AFC
	.long 0x00001E59
	.long 0x00007B04
	.long 0x0000000C
	.long 0xFFFFFFFF
	.long 0x000034E8
	.long 0x3CB851EC
	.long 0x00003524
	.long 0x00000000
	.long 0x00003ED4
	.long 0x2C000004
	.long 0x00003EE4
	.long 0x070A041F
	.long 0x00003EF0
	.long 0x2C000006
	.long 0x00003F00
	.long 0x080A081F
	.long 0x00003F0C
	.long 0x2C000009
	.long 0x00003F1C
	.long 0x0A0A0C1F
	.long 0x00003F28
	.long 0x2C00000C
	.long 0x00003F38
	.long 0x0C0A105F
	.long 0x00003F44
	.long 0x2C00000F
	.long 0x00003F54
	.long 0x0E0A145F
	.long 0x00003F60
	.long 0x2C000013
	.long 0x00003F70
	.long 0x100A185F
	.long 0x00003F7C
	.long 0x2C000016
	.long 0x00003F8C
	.long 0x120A1C5F
	.long 0x00003F98
	.long 0x2C00001A
	.long 0x00003FA8
	.long 0x190A229F
	.long 0x0000403C
	.long 0x43160000
	.long 0x00004050
	.long 0x3CF5C28F
	.long 0x0000417C
	.long 0x2D08C000
	.long 0x00004180
	.long 0x14060C23
	.long 0x0000475C
	.long 0x0800000F
	.long 0x0000477C
	.long 0xB4968013
	.long 0x00004780
	.long 0x0F00008B
	.long 0x00004790
	.long 0xB4968013
	.long 0x00004794
	.long 0x0F00008B
	.long 0x000047B0
	.long 0x08000019
	.long 0x000049D0
	.long 0x70380002
	.long 0x00004A58
	.long 0x08000014
	.long 0x00004A5C
	.long 0x6C000000
	.long 0x00004AF4
	.long 0x08000024
	.long 0x00004C84
	.long 0x08000002
	.long 0x00004C94
	.long 0x00000400
	.long 0x00004CA8
	.long 0x08000009
	.long 0x00004CAC
	.long 0x28000000
	.long 0x00004CB0
	.long 0x03FB0000
	.long 0x00004CB8
	.long 0x00000000
	.long 0x00004CBC
	.long 0x00000000
	.long 0x00004CC0
	.long 0x2C000002
	.long 0x00004CC4
	.long 0x03E80000
	.long 0x00004CC8
	.long 0x0000FA88
	.long 0x00004CCC
	.long 0x46190BD3
	.long 0x00004CD0
	.long 0x0000008B
	.long 0x00004CD4
	.long 0x2C800002
	.long 0x00004CD8
	.long 0x03E80000
	.long 0x00004CDC
	.long 0x00000578
	.long 0x00004CE0
	.long 0x46190BD3
	.long 0x00004CE4
	.long 0x0000008B
	.long 0x00004CE8
	.long 0x04000002
	.long 0x00004CEC
	.long 0x40000000
	.long 0x00004CF0
	.long 0x0800000D
	.long 0x00004CF4
	.long 0x28000000
	.long 0x00004CF8
	.long 0x04240000
	.long 0x00004D00
	.long 0x00000000
	.long 0x00004D04
	.long 0x00000000
	.long 0x00004D08
	.long 0x28C40000
	.long 0x00004D0C
	.long 0x03F30000
	.long 0x00004D10
	.long 0x0BC40000
	.long 0x00004D14
	.long 0x00000000
	.long 0x00004D18
	.long 0x00000000
	.long 0x00004D1C
	.long 0x28C40000
	.long 0x00004D20
	.long 0x040C0000
	.long 0x00004D24
	.long 0x0BC40000
	.long 0x00004D28
	.long 0x00000000
	.long 0x00004D2C
	.long 0x00000000
	.long 0x00004D30
	.long 0x28000000
	.long 0x00004D34
	.long 0x05150000
	.long 0x00004D38
	.long 0x00000000
	.long 0x00004D3C
	.long 0x00000000
	.long 0x00004D40
	.long 0x00000000
	.long 0x00004D44
	.long 0x2C018811
	.long 0x00004D48
	.long 0x044CFE80
	.long 0x00004D4C
	.long 0x00000000
	.long 0x00004D50
	.long 0x2D160013
	.long 0x00004D54
	.long 0x190430A3
	.long 0x00004D58
	.long 0x2C818811
	.long 0x00004D5C
	.long 0x076C0ABE
	.long 0x00004D60
	.long 0x00000000
	.long 0x00004D64
	.long 0x2D160013
	.long 0x00004D68
	.long 0x190430A3
	.long 0x00004D6C
	.long 0x2D000011
	.long 0x00004D70
	.long 0x04E20000
	.long 0x00004D74
	.long 0x09600000
	.long 0x00004D78
	.long 0x2D160013
	.long 0x00004D7C
	.long 0x190430A3
	.long 0x00004D80
	.long 0x2D800011
	.long 0x00004D84
	.long 0x04E20000
	.long 0x00004D88
	.long 0x05780000
	.long 0x00004D8C
	.long 0x2D160013
	.long 0x00004D90
	.long 0x190430A3
	.long 0x00004D94
	.long 0x44000000
	.long 0x00004D98
	.long 0x00000076
	.long 0x00004D9C
	.long 0x00007F40
	.long 0x00004DA0
	.long 0x44000000
	.long 0x00004DA4
	.long 0x00000076
	.long 0x00004DA8
	.long 0x00007F40
	.long 0x00004DAC
	.long 0x44000000
	.long 0x00004DB0
	.long 0x00000073
	.long 0x00004DB4
	.long 0x00007F40
	.long 0x00004DB8
	.long 0xB8CC0000
	.long 0x00004DBC
	.long 0xAC018000
	.long 0x00004DC0
	.long 0x04000004
	.long 0x00004DC4
	.long 0x3C000002
	.long 0x00004DC8
	.long 0x3C000003
	.long 0x00004DCC
	.long 0x2C01880A
	.long 0x00004DD0
	.long 0x0320FE80
	.long 0x00004DD4
	.long 0x00000000
	.long 0x00004DD8
	.long 0x2D154013
	.long 0x00004DDC
	.long 0x190400A3
	.long 0x00004DE0
	.long 0x2C81880A
	.long 0x00004DE4
	.long 0x06400ABE
	.long 0x00004DE8
	.long 0x00000000
	.long 0x00004DEC
	.long 0x2D154013
	.long 0x00004DF0
	.long 0x190400A3
	.long 0x00004DF4
	.long 0x08000016
	.long 0x00004DF8
	.long 0x40000000
	.long 0x00004DFC
	.long 0x0800002A
	.long 0x00004E00
	.long 0x5C000000
	.long 0x00004E08
	.long 0x00000000
	.long 0x00004E0C
	.long 0x00000000
	.long 0x00004E1C
	.long 0x00000000
	.long 0x00004E20
	.long 0x00000000
	.long 0x00004E24
	.long 0x00000000
	.long 0x00004E28
	.long 0x00000000
	.long 0x00004E2C
	.long 0x00000000
	.long 0x00004E30
	.long 0x00000000
	.long 0x00004E34
	.long 0x00000000
	.long 0x00004E38
	.long 0x00000000
	.long 0x00004E40
	.long 0x00000000
	.long 0x00004E44
	.long 0x00000000
	.long 0x00004E48
	.long 0x00000000
	.long 0x00004E4C
	.long 0x00000000
	.long 0x00004E54
	.long 0x00000000
	.long 0x00004E58
	.long 0x00000000
	.long 0x00004E5C
	.long 0x00000000
	.long 0x00004E60
	.long 0x00000000
	.long 0x00004E64
	.long 0x00000000
	.long 0x00004E68
	.long 0x00000000
	.long 0x00004E74
	.long 0x00000000
	.long 0x00004E78
	.long 0x00000000
	.long 0x00004E7C
	.long 0x00000000
	.long 0x00004E80
	.long 0x00000000
	.long 0x00004E84
	.long 0x00000000
	.long 0x00004E88
	.long 0x00000000
	.long 0x00004E8C
	.long 0x00000000
	.long 0x00004E90
	.long 0x00000000
	.long 0x00005014
	.long 0x2A9900B3
	.long 0x00005028
	.long 0x2A9900B3
	.long 0x00006274
	.long 0x0020008B
	.long 0x00006364
	.long 0x0020008B
	.long 0xCC007FF8
	.long 0x00001F8C
	.long 0x00007FFC
	.long 0x00145C80
	.long 0x00008000
	.long 0x00001F8D
	.long 0xFFFFFFFF
	.long 0x000033C0
	.long 0x3D48B439
	.long 0x000033E4
	.long 0x42DE0000
	.long 0x00003450
	.long 0x41800000
	.long 0x00003454
	.long 0x41C00000
	.long 0x000034E8
	.long 0x430C0000
	.long 0x000034F8
	.long 0x3F4CCCCD
	.long 0x00003518
	.long 0x00000001
	.long 0x0000352C
	.long 0x00000000
	.long 0x00003538
	.long 0x3F800000
	.long 0x00003550
	.long 0x4019999A
	.long 0x00003570
	.long 0x3FEB851F
	.long 0x000035C8
	.long 0x00000000
	.long 0x000037B4
	.long 0x05780000
	.long 0x00003864
	.long 0x05780000
	.long 0x00004224
	.long 0x0C80010B
	.long 0x00004228
	.long 0x2C000009
	.long 0x0000422C
	.long 0x05140000
	.long 0x00004230
	.long 0x05FD0951
	.long 0x00004238
	.long 0x0C80010B
	.long 0x00004258
	.long 0x30000007
	.long 0x0000425C
	.long 0x30800007
	.long 0x00004284
	.long 0x28154013
	.long 0x00004298
	.long 0x23154013
	.long 0x000042A0
	.long 0x2D00700C
	.long 0x000042AC
	.long 0x1E154013
	.long 0x000042F0
	.long 0x28154013
	.long 0x00004304
	.long 0x23154013
	.long 0x00004318
	.long 0x1E154013
	.long 0x0000435C
	.long 0x28154013
	.long 0x00004370
	.long 0x23154013
	.long 0x00004374
	.long 0x19000087
	.long 0x00004384
	.long 0x1E154013
	.long 0x000043D0
	.long 0x2C00A00B
	.long 0x000043D4
	.long 0x069A0000
	.long 0x000043E4
	.long 0x2C80A80B
	.long 0x000043E8
	.long 0x05140000
	.long 0x000043F8
	.long 0x2D00000B
	.long 0x000043FC
	.long 0x06180000
	.long 0x000044DC
	.long 0x08000016
	.long 0x00004528
	.long 0x2C013011
	.long 0x0000453C
	.long 0x2C813011
	.long 0x00004550
	.long 0x2D002011
	.long 0x000045F8
	.long 0x2C01300F
	.long 0x00004608
	.long 0x0F00010B
	.long 0x0000460C
	.long 0x2C81280F
	.long 0x0000461C
	.long 0x0F00010B
	.long 0x00004644
	.long 0x04000006
	.long 0x00004650
	.long 0x08000024
	.long 0x000047BC
	.long 0x0800002F
	.long 0x000047E0
	.long 0x2C00800E
	.long 0x000047E4
	.long 0x03E80055
	.long 0x000047EC
	.long 0xB499C013
	.long 0x00004800
	.long 0xB499C013
	.long 0x00004814
	.long 0xB499C013
	.long 0x00004820
	.long 0x2C00800A
	.long 0x00004824
	.long 0x03E80055
	.long 0x0000490C
	.long 0x1E078013
	.long 0x00004910
	.long 0x1400010B
	.long 0x00004920
	.long 0x1E078013
	.long 0x00004924
	.long 0x1400010B
	.long 0x00004934
	.long 0x1E078013
	.long 0x00004938
	.long 0x1400010B
	.long 0x00004964
	.long 0x1E078013
	.long 0x00004968
	.long 0x1400010B
	.long 0x00004978
	.long 0x1E078013
	.long 0x0000497C
	.long 0x1400010B
	.long 0x0000498C
	.long 0x1E078013
	.long 0x00004990
	.long 0x1400010B
	.long 0x000049BC
	.long 0x1E078013
	.long 0x000049C0
	.long 0x1400008B
	.long 0x000049D0
	.long 0x1E078013
	.long 0x000049D4
	.long 0x1400008B
	.long 0x000049E4
	.long 0x1E078013
	.long 0x000049E8
	.long 0x1400008B
	.long 0x00004A08
	.long 0x2C00A008
	.long 0x00004A14
	.long 0x23140013
	.long 0x00004A1C
	.long 0x2C80A808
	.long 0x00004A28
	.long 0x23140013
	.long 0x00004A30
	.long 0x2D00A808
	.long 0x00004A3C
	.long 0x23140013
	.long 0x00004A74
	.long 0x2C00A00E
	.long 0x00004A80
	.long 0x2D19C013
	.long 0x00004A88
	.long 0x2C80A80E
	.long 0x00004A94
	.long 0x2D19C013
	.long 0x00005C68
	.long 0x01900000
	.long 0x00005C6C
	.long 0x00000000
	.long 0x00005C74
	.long 0x0020008B
	.long 0x00005C80
	.long 0x00000000
	.long 0x00005C88
	.long 0x0020008B
	.long 0x00005CC4
	.long 0x04000004
	.long 0x00005CCC
	.long 0x04000009
	.long 0x00005D20
	.long 0x2D013000
	.long 0x00005D24
	.long 0x03E80000
	.long 0x00005D30
	.long 0x0020008B
	.long 0x00005D44
	.long 0x0020008B
	.long 0x00005D6C
	.long 0x0400000D
	.long 0x00005DE4
	.long 0x88000008
	.long 0x00005DE8
	.long 0x0F190000
	.long 0x00005DEC
	.long 0x07822000
	.long 0x00005E70
	.long 0x88000007
	.long 0x00005E74
	.long 0x11908000
	.long 0x00005E78
	.long 0x1B822000
	.long 0x00005F1C
	.long 0x2D118000
	.long 0x00005F20
	.long 0x26022000
	.long 0x00006D70
	.long 0xAC016000
	.long 0x00006D74
	.long 0x08000008
	.long 0x00006D78
	.long 0x2C000004
	.long 0x00006D7C
	.long 0x07080000
	.long 0x00006D80
	.long 0x070809C4
	.long 0x00006D84
	.long 0x28190DD3
	.long 0x00006D88
	.long 0x0000010B
	.long 0x00006D8C
	.long 0x4C000001
	.long 0x00006D90
	.long 0x44080000
	.long 0x00006D94
	.long 0x000445F7
	.long 0x00006D98
	.long 0x00007F40
	.long 0x00006D9C
	.long 0x04000001
	.long 0x00006DA0
	.long 0x40000000
	.long 0x00006DA4
	.long 0x0800001B
	.long 0x00006DA8
	.long 0x28000000
	.long 0x00006DAC
	.long 0x03F30000
	.long 0x00006DB0
	.long 0x00000708
	.long 0x00006DB4
	.long 0x00000400
	.long 0x00006DB8
	.long 0x04000400
	.long 0x00006DBC
	.long 0x2C002010
	.long 0x00006DC0
	.long 0x06000000
	.long 0x00006DC8
	.long 0x28188013
	.long 0x00006DCC
	.long 0x1900290B
	.long 0x00006DD0
	.long 0x44080000
	.long 0xCC006DD4
	.long 0x000445FA
	.long 0xCC006DD8
	.long 0x00007F40
	.long 0xCC009074
	.long 0x00006D50
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x0000376C
	.long 0x3FB9999A
	.long 0x00003788
	.long 0x40800000
	.long 0x000037D8
	.long 0x42D40000
	.long 0x000037E0
	.long 0x418F1EB8
	.long 0x0000383C
	.long 0x41B00000
	.long 0x00003840
	.long 0x41900000
	.long 0x00003844
	.long 0x41800000
	.long 0x00003848
	.long 0x41C00000
	.long 0x00003B0C
	.long 0x00000000
	.long 0x00003B50
	.long 0x00000000
	.long 0x00003B54
	.long 0x00000000
	.long 0x00003B58
	.long 0x00000000
	.long 0x00003B5C
	.long 0x00000000
	.long 0x00003B60
	.long 0x00000000
	.long 0x00003B64
	.long 0x00000000
	.long 0xCC003BA0
	.long 0x000070A0
	.long 0x00003D00
	.long 0x2C000003
	.long 0x00003D04
	.long 0x06400000
	.long 0x00003D0C
	.long 0xB48C8000
	.long 0x00003D10
	.long 0x2D30001F
	.long 0x00003EC0
	.long 0x1B280000
	.long 0x000042D4
	.long 0x2C800006
	.long 0x000042D8
	.long 0x07D00000
	.long 0x000042DC
	.long 0x0A5A0BB8
	.long 0x000042E0
	.long 0x29990292
	.long 0x000042E8
	.long 0x28000000
	.long 0x000042EC
	.long 0x04E40000
	.long 0x000042F0
	.long 0x00000A5A
	.long 0x000042F4
	.long 0x0BB80000
	.long 0x000042F8
	.long 0x00000000
	.long 0x000042FC
	.long 0x48000000
	.long 0x00004300
	.long 0x04000002
	.long 0x00004304
	.long 0x40000000
	.long 0x00004308
	.long 0x08000010
	.long 0x0000430C
	.long 0x5C000000
	.long 0x00004428
	.long 0x04B00000
	.long 0x0000443C
	.long 0x04B00000
	.long 0x00004450
	.long 0x060E0000
	.long 0x000044A0
	.long 0x04B00000
	.long 0x000044B4
	.long 0x04B00000
	.long 0x000044C8
	.long 0x060E0000
	.long 0x00004524
	.long 0x2D00C807
	.long 0x00004534
	.long 0x050C000B
	.long 0x000045A4
	.long 0x2D00C807
	.long 0x000045B4
	.long 0x050C000B
	.long 0x00004638
	.long 0x2D00C807
	.long 0x00004648
	.long 0x050C000B
	.long 0x000046A0
	.long 0x371B8013
	.long 0x000046A4
	.long 0x1400008B
	.long 0x000046A8
	.long 0x2C80A80A
	.long 0x000046B4
	.long 0x371B8013
	.long 0x000046B8
	.long 0x1400010B
	.long 0x000046BC
	.long 0x2D00B80A
	.long 0x000046C8
	.long 0x371B8013
	.long 0x000046CC
	.long 0x1400008B
	.long 0x000046D0
	.long 0x2D80C80A
	.long 0x000046DC
	.long 0x371B8013
	.long 0x000046E0
	.long 0x1400008B
	.long 0x000046F8
	.long 0x2C002809
	.long 0x00004704
	.long 0x271B8013
	.long 0x00004708
	.long 0x1400010B
	.long 0x0000470C
	.long 0x2C80A809
	.long 0x00004718
	.long 0x271B8013
	.long 0x0000471C
	.long 0x1400010B
	.long 0x00004720
	.long 0x2D00B809
	.long 0x0000472C
	.long 0x271B8013
	.long 0x00004730
	.long 0x1400010B
	.long 0x00004734
	.long 0x2D80C809
	.long 0x00004740
	.long 0x271B8013
	.long 0x00004744
	.long 0x1400010B
	.long 0x00004798
	.long 0x2D00C806
	.long 0x0000485C
	.long 0x2C00000F
	.long 0x00004860
	.long 0x05780000
	.long 0x00004868
	.long 0xB497C013
	.long 0x00004874
	.long 0x06720000
	.long 0x0000487C
	.long 0xB4968001
	.long 0x00004880
	.long 0x0F340123
	.long 0x00004988
	.long 0x04B00000
	.long 0x0000498C
	.long 0x15180000
	.long 0x000049A0
	.long 0x14B4FA88
	.long 0x000049B4
	.long 0x14B40578
	.long 0x000049D0
	.long 0x2C00000D
	.long 0x000049E4
	.long 0x2C80000D
	.long 0x000049F8
	.long 0x2D00000D
	.long 0x00004A0C
	.long 0x2D80000D
	.long 0x00004A88
	.long 0x2C000011
	.long 0x00004A9C
	.long 0x2C800011
	.long 0x00004B4C
	.long 0x2C000001
	.long 0x00004B50
	.long 0x03520000
	.long 0x00004B60
	.long 0x2C800001
	.long 0x00004B64
	.long 0x03520000
	.long 0x00004B78
	.long 0x03520000
	.long 0x00004B8C
	.long 0x03520000
	.long 0x00004BAC
	.long 0x03E90000
	.long 0x00004BB4
	.long 0x00000000
	.long 0x00004BB8
	.long 0x00000000
	.long 0x00004BE4
	.long 0x0D480000
	.long 0x00004C10
	.long 0x4C000001
	.long 0x00004C14
	.long 0x08000002
	.long 0x00004C18
	.long 0x44080000
	.long 0x00004C1C
	.long 0x00030D4D
	.long 0x00004C20
	.long 0x00007F40
	.long 0x00004C24
	.long 0xA2000805
	.long 0x00004C28
	.long 0xA2081805
	.long 0x00004C2C
	.long 0x288D0000
	.long 0x00004C30
	.long 0x04E50000
	.long 0x00004C3C
	.long 0x00000000
	.long 0x00004C78
	.long 0x0800000D
	.long 0x00004C90
	.long 0x0800001F
	.long 0x00004C98
	.long 0x08000020
	.long 0x00004CC8
	.long 0x0280008B
	.long 0x00004CCC
	.long 0x2C80B80C
	.long 0x00004CDC
	.long 0x0280008B
	.long 0x00004CE0
	.long 0x2C00C80B
	.long 0x00004CF0
	.long 0x0280008B
	.long 0x00004D34
	.long 0x08000008
	.long 0x00004D48
	.long 0x0500008B
	.long 0x00004D5C
	.long 0x0500008B
	.long 0x00004D70
	.long 0x0500008B
	.long 0x00004D84
	.long 0x04000006
	.long 0x00004DD8
	.long 0x91190013
	.long 0x00004DEC
	.long 0x91190013
	.long 0x00004E00
	.long 0x91190013
	.long 0x00004E6C
	.long 0x0E100000
	.long 0x00004E74
	.long 0x2D118013
	.long 0x00005D7C
	.long 0x05780000
	.long 0x00005D80
	.long 0x0AF00BB8
	.long 0x00005D90
	.long 0x05140000
	.long 0x00005DF8
	.long 0x05780000
	.long 0x00005E20
	.long 0x05780000
	.long 0x00005E24
	.long 0x06720A28
	.long 0x00005EF8
	.long 0x44080000
	.long 0x00005EFC
	.long 0x00030D41
	.long 0x000070C0
	.long 0x08000004
	.long 0x000070C4
	.long 0x28000000
	.long 0x000070C8
	.long 0x03F40000
	.long 0x000070CC
	.long 0x000005DC
	.long 0x000070D8
	.long 0x68000002
	.long 0x000072E0
	.long 0x00000000
	.long 0x000072E8
	.long 0x00000000
	.long 0x00007300
	.long 0x00000000
	.long 0x0000730C
	.long 0x00000000
	.long 0x00007310
	.long 0x00000000
	.long 0x00007328
	.long 0x00000000
	.long 0x00007338
	.long 0x00000000
	.long 0x00007350
	.long 0x00000000
	.long 0x0000735C
	.long 0x00000000
	.long 0x00007360
	.long 0x00000000
	.long 0xCC00927C
	.long 0x00003A94
	.long 0xCC009294
	.long 0x000070A0
	.long 0xFFFFFFFF
	.long 0x000033EC
	.long 0x3FC00000
	.long 0x00003404
	.long 0x3D0F5C29
	.long 0x0000340C
	.long 0x3F369446
	.long 0x00003568
	.long 0x40C00000
	.long 0x00003574
	.long 0x3FE66666
	.long 0x00003584
	.long 0x41A00000
	.long 0x000035A4
	.long 0x3E75C28F
	.long 0x000035B0
	.long 0x3FA66666
	.long 0x000037E0
	.long 0x03200000
	.long 0x000037E8
	.long 0x2D130013
	.long 0x00003880
	.long 0x2C00B816
	.long 0x00003884
	.long 0x03200000
	.long 0x0000388C
	.long 0x2D130013
	.long 0x00003890
	.long 0x23040117
	.long 0x00003918
	.long 0x2D00B00C
	.long 0x00003C68
	.long 0x0800000E
	.long 0x0000403C
	.long 0xB4940013
	.long 0x00004040
	.long 0x1900008B
	.long 0x000040AC
	.long 0x8E990013
	.long 0x000040C0
	.long 0x8E990013
	.long 0x00004104
	.long 0x8E990013
	.long 0x00004118
	.long 0x8E990013
	.long 0x0000415C
	.long 0x8E990013
	.long 0x00004170
	.long 0x8E990013
	.long 0x000041B4
	.long 0x8E990013
	.long 0x000041C8
	.long 0x8E990013
	.long 0x0000420C
	.long 0x8E990013
	.long 0x00004220
	.long 0x8E990013
	.long 0x00004258
	.long 0x2C000004
	.long 0x00004268
	.long 0x1E0000AB
	.long 0x0000426C
	.long 0x2C802804
	.long 0x0000427C
	.long 0x1E0000AB
	.long 0x000043C4
	.long 0xB4990013
	.long 0x000043C8
	.long 0x0100208B
	.long 0x000043D8
	.long 0xB4990013
	.long 0x000043DC
	.long 0x0100208B
	.long 0x000043EC
	.long 0xB4990013
	.long 0x000043F0
	.long 0x0100208B
	.long 0x0000449C
	.long 0x2C01B80C
	.long 0x000044AC
	.long 0x0500200B
	.long 0x000044B0
	.long 0x2C81B00C
	.long 0x000044C0
	.long 0x0500200B
	.long 0x000044C4
	.long 0x2D00200C
	.long 0x000044D4
	.long 0x0500200B
	.long 0x00004510
	.long 0x08000019
	.long 0x00004574
	.long 0x2C00000F
	.long 0x00004588
	.long 0x2C80000F
	.long 0x0000459C
	.long 0x2D00E80F
	.long 0x000045D0
	.long 0x08000026
	.long 0x0000463C
	.long 0x2C00000E
	.long 0x00004650
	.long 0x2C80000E
	.long 0x00004664
	.long 0x2D00E80E
	.long 0x000046A0
	.long 0x08000026
	.long 0x00004708
	.long 0x2C00000D
	.long 0x0000471C
	.long 0x2C80000D
	.long 0x00004730
	.long 0x2D00E80D
	.long 0x00004764
	.long 0x08000026
	.long 0x00004854
	.long 0x2D168013
	.long 0x00004868
	.long 0x2D168013
	.long 0x000048AC
	.long 0x2D168013
	.long 0x000048C0
	.long 0x2D168013
	.long 0x000049B8
	.long 0x15801907
	.long 0x000049CC
	.long 0x15801907
	.long 0x000049F4
	.long 0x08000018
	.long 0x00004A08
	.long 0x2C01B80C
	.long 0x00004A1C
	.long 0x2C81B00C
	.long 0x00004A64
	.long 0x08000004
	.long 0x00004A74
	.long 0x20990013
	.long 0x00004A88
	.long 0x20990013
	.long 0x00004AA0
	.long 0x0800000B
	.long 0x00004AD0
	.long 0x2D012010
	.long 0x00004AE0
	.long 0x0A00190B
	.long 0x00004AF4
	.long 0x0A00190B
	.long 0x00004AF8
	.long 0x2C00B010
	.long 0x00004B08
	.long 0x0A00190B
	.long 0x00005A9C
	.long 0x911914D2
	.long 0x00005DBC
	.long 0x34878000
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x0000380C
	.long 0x3D8F5C29
	.long 0x00003810
	.long 0x3FA00000
	.long 0x0000381C
	.long 0x3FA00000
	.long 0x0000382C
	.long 0x40A00000
	.long 0x00003858
	.long 0x3D83126F
	.long 0x000039AC
	.long 0x00000000
	.long 0x00003A84
	.long 0x44040000
	.long 0x00003A88
	.long 0x00041F6F
	.long 0x00003A8C
	.long 0x00007F40
	.long 0x00003A90
	.long 0x28000000
	.long 0x00003A94
	.long 0x04230000
	.long 0x00003A98
	.long 0x00000000
	.long 0x00003AA4
	.long 0x0C000005
	.long 0x00003AA8
	.long 0x2C000001
	.long 0x00003AAC
	.long 0x044C0000
	.long 0x00003AB0
	.long 0x05DCF448
	.long 0x00003AB4
	.long 0x5A000011
	.long 0x00003AB8
	.long 0x150C000F
	.long 0x00003ABC
	.long 0x2C800001
	.long 0x00003AC0
	.long 0x044C0000
	.long 0x00003AC4
	.long 0x05DC0BB8
	.long 0x00003AC8
	.long 0x5A000011
	.long 0x00003ACC
	.long 0x150C000F
	.long 0x00003AD0
	.long 0x2D000002
	.long 0x00003AD4
	.long 0x05780000
	.long 0x00003AD8
	.long 0x05DCFC18
	.long 0x00003ADC
	.long 0x5A000011
	.long 0x00003AE0
	.long 0x0B8C008F
	.long 0x00003AE4
	.long 0x2D800002
	.long 0x00003AE8
	.long 0x05780000
	.long 0x00003AEC
	.long 0x05DC03E8
	.long 0x00003AF0
	.long 0x5A000011
	.long 0x00003AF4
	.long 0x0B8C008F
	.long 0x00003AF8
	.long 0x04000001
	.long 0x00003AFC
	.long 0x40000000
	.long 0x00003B00
	.long 0x68000000
	.long 0x00003B10
	.long 0x076C0000
	.long 0x00003B1C
	.long 0x1E0C0123
	.long 0x00003B24
	.long 0x076C0000
	.long 0x00003B30
	.long 0x1E0C0123
	.long 0x00003B38
	.long 0x05DC0000
	.long 0x00003B44
	.long 0x1E0C00A3
	.long 0x00003B4C
	.long 0x05DC0000
	.long 0x00003B58
	.long 0x1E0C00A3
	.long 0x00003CB8
	.long 0x08000001
	.long 0x00003CBC
	.long 0x2C001804
	.long 0x00003CC0
	.long 0x07D00000
	.long 0x00003CC4
	.long 0x00000000
	.long 0x00003CC8
	.long 0xB4990F12
	.long 0x00003CCC
	.long 0x000400A3
	.long 0x00003CD0
	.long 0x04000002
	.long 0x00003CD4
	.long 0x40000000
	.long 0x00003CD8
	.long 0x0C00000A
	.long 0x00003CDC
	.long 0x94000001
	.long 0x00003CE0
	.long 0x8C000000
	.long 0x00003CE4
	.long 0x04000001
	.long 0x00003CE8
	.long 0x94000000
	.long 0x00003CEC
	.long 0x8C000001
	.long 0x00003D48
	.long 0x08000001
	.long 0x00003D4C
	.long 0x2C001804
	.long 0x00003D50
	.long 0x07D00000
	.long 0x00003D54
	.long 0x00000000
	.long 0x00003D58
	.long 0xB4990F12
	.long 0x00003D5C
	.long 0x000400A3
	.long 0x00003D60
	.long 0x04000002
	.long 0x00003D64
	.long 0x40000000
	.long 0x00003D68
	.long 0x0C000004
	.long 0x00003D6C
	.long 0x94000001
	.long 0x00003D70
	.long 0x8C000000
	.long 0x00003D74
	.long 0x04000001
	.long 0x00003D78
	.long 0x94000000
	.long 0x00003D7C
	.long 0x8C000001
	.long 0x00003D80
	.long 0x04000001
	.long 0x00003D84
	.long 0x10000000
	.long 0x00003D88
	.long 0x4C000001
	.long 0x00003D8C
	.long 0x0C000006
	.long 0x00003D90
	.long 0x94000001
	.long 0x00003D94
	.long 0x8C000000
	.long 0x00003D98
	.long 0x04000001
	.long 0x00003D9C
	.long 0x94000000
	.long 0x00003DA0
	.long 0x8C000001
	.long 0x00003EF0
	.long 0x41200000
	.long 0x00003F00
	.long 0x3DF5C28F
	.long 0x00003F04
	.long 0x42200000
	.long 0x00003F10
	.long 0x3FC66666
	.long 0x00003F14
	.long 0x40E00000
	.long 0x00003FC4
	.long 0x3F800000
	.long 0x00003FCC
	.long 0x41200000
	.long 0x00003FD0
	.long 0x3E0F5C29
	.long 0x00003FF0
	.long 0xB48F0000
	.long 0x000045E0
	.long 0x05080C1F
	.long 0x000045F4
	.long 0x05080C1F
	.long 0x00004608
	.long 0x05080C1F
	.long 0x0000461C
	.long 0x05080C1F
	.long 0x00004650
	.long 0x2C000003
	.long 0x0000465C
	.long 0xB49E0011
	.long 0x00004660
	.long 0x0A080C1F
	.long 0x00004664
	.long 0x2C826003
	.long 0x00004670
	.long 0xB49E0011
	.long 0x00004674
	.long 0x0A080C1F
	.long 0x00004678
	.long 0x2D024803
	.long 0x00004684
	.long 0xB49E0011
	.long 0x00004688
	.long 0x0A080C1F
	.long 0x0000468C
	.long 0x2D832003
	.long 0x00004698
	.long 0xB49E0011
	.long 0x0000469C
	.long 0x0A080C1F
	.long 0x00004718
	.long 0x23080D1F
	.long 0x0000472C
	.long 0x23080D1F
	.long 0x0000475C
	.long 0x0F080C9F
	.long 0x00004770
	.long 0x0F080C9F
	.long 0x000047E0
	.long 0x03840190
	.long 0x00004894
	.long 0x08000009
	.long 0x0000490C
	.long 0x0F000086
	.long 0x00004920
	.long 0x0F000085
	.long 0x00004934
	.long 0x0F000087
	.long 0x00004948
	.long 0x0F000087
	.long 0x00004964
	.long 0x0800000C
	.long 0x0000497C
	.long 0x0800001A
	.long 0x00004A18
	.long 0x5A190511
	.long 0x00004A2C
	.long 0x5A190471
	.long 0x00004A40
	.long 0x5A190471
	.long 0x00004A54
	.long 0x001903D1
	.long 0x00004B80
	.long 0x03840000
	.long 0x00004B94
	.long 0x044C0000
	.long 0x00004B98
	.long 0x0B54FC18
	.long 0x00004B9C
	.long 0x551903D0
	.long 0x00004BA8
	.long 0x044C0000
	.long 0x00004BAC
	.long 0x0B5403E8
	.long 0x00004BB0
	.long 0x551903D0
	.long 0x00004BBC
	.long 0x05DC0000
	.long 0x00004BC0
	.long 0x09C40000
	.long 0x00004BDC
	.long 0x08000015
	.long 0x00004BFC
	.long 0x03840000
	.long 0x00004C10
	.long 0x044C0000
	.long 0x00004C14
	.long 0x0B54FC18
	.long 0x00004C18
	.long 0x551903D0
	.long 0x00004C24
	.long 0x044C0000
	.long 0x00004C28
	.long 0x0B5403E8
	.long 0x00004C2C
	.long 0x551903D0
	.long 0x00004C38
	.long 0x05DC0000
	.long 0x00004C3C
	.long 0x09C40000
	.long 0x00004C60
	.long 0x060E0000
	.long 0x00004C64
	.long 0x0FA00000
	.long 0x00004C74
	.long 0x05780000
	.long 0x00004C78
	.long 0x0C80FBB4
	.long 0x00004C88
	.long 0x05780000
	.long 0x00004C8C
	.long 0x0C80044C
	.long 0x00004C9C
	.long 0x06400000
	.long 0x00004D04
	.long 0x2C00680C
	.long 0x00004D10
	.long 0x0F17C013
	.long 0x00004D18
	.long 0x2C80680C
	.long 0x00004D24
	.long 0x0F17C013
	.long 0x00004D78
	.long 0x0F154013
	.long 0x00004D8C
	.long 0x0F154013
	.long 0x00004DFC
	.long 0x03400000
	.long 0x00004E00
	.long 0x0940F880
	.long 0x00004E04
	.long 0x4B000011
	.long 0x00004E08
	.long 0x1B880807
	.long 0x00004E10
	.long 0x03400000
	.long 0x00004E14
	.long 0x07E005EE
	.long 0x00004E18
	.long 0x4B000011
	.long 0x00004E1C
	.long 0x1B880807
	.long 0x00004E24
	.long 0x04800000
	.long 0x00004E2C
	.long 0x37000011
	.long 0x00004E30
	.long 0x27080807
	.long 0x00004E38
	.long 0x04800000
	.long 0x00004E40
	.long 0x78000011
	.long 0x00004E44
	.long 0x16880807
	.long 0x00004E5C
	.long 0x04000000
	.long 0x00004E60
	.long 0x0940F880
	.long 0x00004E64
	.long 0xB4940011
	.long 0x00004E68
	.long 0x0F080007
	.long 0x00004E70
	.long 0x04000000
	.long 0x00004E74
	.long 0x051B0833
	.long 0x00004E78
	.long 0xB4940011
	.long 0x00004E7C
	.long 0x0F080007
	.long 0x00004E84
	.long 0x05800000
	.long 0x00004E8C
	.long 0xB4940011
	.long 0x00004E90
	.long 0x0F080007
	.long 0x00004E98
	.long 0x05800000
	.long 0x00004EA0
	.long 0xB4940011
	.long 0x00004EA4
	.long 0x0F080007
	.long 0x00005054
	.long 0x2C00000F
	.long 0x00005058
	.long 0x09600000
	.long 0x00005060
	.long 0x2D1B8011
	.long 0x00005064
	.long 0x0F040123
	.long 0x000050AC
	.long 0x2C00380F
	.long 0x000050B8
	.long 0x89968013
	.long 0x000050BC
	.long 0x1408010B
	.long 0x000050C0
	.long 0x2C80500D
	.long 0x000050D0
	.long 0x0F08010B
	.long 0x00006390
	.long 0x08000006
	.long 0x000063A8
	.long 0x09600960
	.long 0x000063BC
	.long 0x096003E8
	.long 0x000063F8
	.long 0x08000009
	.long 0x00006410
	.long 0x05780C80
	.long 0x00006424
	.long 0x05780960
	.long 0x00006438
	.long 0x057804B0
	.long 0x00006570
	.long 0x168F0000
	.long 0x00006668
	.long 0x16918000
	.long 0x0000697C
	.long 0xD0000004
	.long 0x00006980
	.long 0x2C000005
	.long 0x00006984
	.long 0x05B00000
	.long 0x00006988
	.long 0x0940FB50
	.long 0x0000698C
	.long 0x321906D1
	.long 0x00006990
	.long 0x0008001F
	.long 0x00006994
	.long 0x2C800005
	.long 0x00006998
	.long 0x05B00000
	.long 0x0000699C
	.long 0x051B04B0
	.long 0x000069A0
	.long 0x321906D1
	.long 0x000069A4
	.long 0x0008001F
	.long 0x000069A8
	.long 0x04000008
	.long 0x000069AC
	.long 0x40000000
	.long 0x000069B0
	.long 0xDC0003FA
	.long 0xCC0083CC
	.long 0x0000695C
	.long 0xFFFFFFFF
	.long 0x00003698
	.long 0x42200000
	.long 0x00003B8C
	.long 0x440C0000
	.long 0x00003BA0
	.long 0x03840000
	.long 0x00003BB4
	.long 0x03E80000
	.long 0x00003BC8
	.long 0x03E80000
	.long 0x00003BDC
	.long 0x03840000
	.long 0x00003BFC
	.long 0x05140000
	.long 0x00003C04
	.long 0x10190010
	.long 0x00003C10
	.long 0x05780000
	.long 0x00003C18
	.long 0x10190010
	.long 0x00003C24
	.long 0x05780000
	.long 0x00003C2C
	.long 0x10190010
	.long 0x00003C38
	.long 0x05140000
	.long 0x00003C40
	.long 0x10190010
	.long 0x00003D0C
	.long 0x440C0000
	.long 0x00004148
	.long 0x3FD33333
	.long 0x00004194
	.long 0x02000000
	.long 0x000041A0
	.long 0x1E060063
	.long 0x00004A1C
	.long 0x28094013
	.long 0x00004A20
	.long 0x080C0007
	.long 0x00004A30
	.long 0xB4894013
	.long 0x00004A34
	.long 0x080C0007
	.long 0x00004A44
	.long 0xB4894013
	.long 0x00004A48
	.long 0x080C0007
	.long 0x00004A58
	.long 0x28094013
	.long 0x00004A5C
	.long 0x080C0007
	.long 0x00004A8C
	.long 0x08000010
	.long 0x00004AB4
	.long 0x32050013
	.long 0x00004AB8
	.long 0x140C0007
	.long 0x00004AC8
	.long 0x29050013
	.long 0x00004ACC
	.long 0x140C0007
	.long 0x00004ADC
	.long 0x1E050013
	.long 0x00004AE0
	.long 0x140C0007
	.long 0x00004AF0
	.long 0x19050013
	.long 0x00004AF4
	.long 0x140C0007
	.long 0x00004B24
	.long 0x0800000D
	.long 0x00004B4C
	.long 0x0F0C0087
	.long 0x00004B60
	.long 0x0F0C0087
	.long 0x00004B74
	.long 0x0F0C0087
	.long 0x00004B88
	.long 0x0F0C0087
	.long 0x00004CA0
	.long 0x0F190013
	.long 0x00004CB4
	.long 0x0F190013
	.long 0x00004CC8
	.long 0x0F190013
	.long 0x00004CDC
	.long 0x0F190013
	.long 0x00004D18
	.long 0x08000024
	.long 0x00004D4C
	.long 0x11990013
	.long 0x00004D50
	.long 0x078C0087
	.long 0x00004D60
	.long 0x11990013
	.long 0x00004D64
	.long 0x078C0087
	.long 0x00004D74
	.long 0x11990013
	.long 0x00004D78
	.long 0x068C0087
	.long 0x00004D88
	.long 0x11990013
	.long 0x00004D8C
	.long 0x068C0087
	.long 0x00004DDC
	.long 0x2C00E009
	.long 0x00004DE8
	.long 0x2A990013
	.long 0x00004DEC
	.long 0x190C0087
	.long 0x00004DF0
	.long 0x2C80C809
	.long 0x00004DFC
	.long 0x2A990013
	.long 0x00004E00
	.long 0x190C0087
	.long 0x00004E04
	.long 0x2D009809
	.long 0x00004E10
	.long 0x2A990013
	.long 0x00004E14
	.long 0x190C0087
	.long 0x00004E18
	.long 0x2D80E009
	.long 0x00004E24
	.long 0x2F990013
	.long 0x00004E28
	.long 0x190C000F
	.long 0x00004E4C
	.long 0x0800001E
	.long 0x00004E74
	.long 0x230C8013
	.long 0x00004E88
	.long 0x230C8013
	.long 0x00004E9C
	.long 0x230C8013
	.long 0x00004EB0
	.long 0x8C0C8013
	.long 0x00004F44
	.long 0xB4990513
	.long 0x00004F58
	.long 0x05190513
	.long 0x00004F6C
	.long 0x11990513
	.long 0x00004F80
	.long 0xB4990513
	.long 0x00004FB8
	.long 0x08000010
	.long 0x00004FBC
	.long 0x4C000001
	.long 0x00004FC0
	.long 0x04000003
	.long 0x00004FC4
	.long 0x40000000
	.long 0x00004FC8
	.long 0x04000002
	.long 0x00004FCC
	.long 0xC5FFFFFF
	.long 0x00004FD0
	.long 0x08000028
	.long 0x00005008
	.long 0x2C00E00D
	.long 0x0000500C
	.long 0x05DC01F4
	.long 0x0000501C
	.long 0x2C80C80D
	.long 0x00005020
	.long 0x044C0000
	.long 0x00005030
	.long 0x2D00980D
	.long 0x00005034
	.long 0x03840000
	.long 0x00005044
	.long 0x2D80E00D
	.long 0x00005048
	.long 0x05DC0578
	.long 0x000050E0
	.long 0x0800000A
	.long 0x000050E8
	.long 0x06720384
	.long 0x000050F0
	.long 0x2F9B8513
	.long 0x000050F4
	.long 0x000C0007
	.long 0x000050FC
	.long 0x067201C2
	.long 0x00005104
	.long 0x311B8613
	.long 0x00005108
	.long 0x000C0007
	.long 0x00005110
	.long 0x04B00000
	.long 0x00005118
	.long 0x311B8513
	.long 0x0000511C
	.long 0x000C0007
	.long 0x00005124
	.long 0x03E80000
	.long 0x0000512C
	.long 0x311B8513
	.long 0x00005130
	.long 0x000C0007
	.long 0x00005164
	.long 0x04000007
	.long 0x0000516C
	.long 0x04000003
	.long 0x00005174
	.long 0x08000014
	.long 0x0000517C
	.long 0x08000016
	.long 0x00005184
	.long 0x06720384
	.long 0x0000518C
	.long 0x2E9B83F3
	.long 0x00005198
	.long 0x067201C2
	.long 0x000051A0
	.long 0x301B8433
	.long 0x000051AC
	.long 0x04B00000
	.long 0x000051B4
	.long 0x301B84B3
	.long 0x000051C0
	.long 0x03E80000
	.long 0x000051C8
	.long 0x301B8513
	.long 0x000051E0
	.long 0x04000009
	.long 0x000051E8
	.long 0x04000008
	.long 0x000051F0
	.long 0x08000023
	.long 0x000051F8
	.long 0x08000024
	.long 0x000051FC
	.long 0x2C00E00B
	.long 0x00005200
	.long 0x06720384
	.long 0x00005208
	.long 0x30174013
	.long 0x0000520C
	.long 0x218C0107
	.long 0x00005210
	.long 0x2C80E00C
	.long 0x00005214
	.long 0x067201C2
	.long 0x0000521C
	.long 0x30174013
	.long 0x00005220
	.long 0x218C0107
	.long 0x00005224
	.long 0x2D00C80C
	.long 0x00005228
	.long 0x04B00000
	.long 0x00005230
	.long 0x30174013
	.long 0x00005234
	.long 0x218C0107
	.long 0x00005238
	.long 0x2D809809
	.long 0x0000523C
	.long 0x03E80000
	.long 0x00005244
	.long 0x30174013
	.long 0x00005248
	.long 0x218C0107
	.long 0x00005260
	.long 0x04000007
	.long 0x00005264
	.long 0x2C00E00C
	.long 0x00005278
	.long 0x2C80E00D
	.long 0x0000528C
	.long 0x2D00C80D
	.long 0x000052A0
	.long 0x2D80980D
	.long 0x000052BC
	.long 0x04000009
	.long 0x000052C4
	.long 0x0800003C
	.long 0x00005324
	.long 0x0F168013
	.long 0x00005338
	.long 0x0F168013
	.long 0x00005340
	.long 0x2D80E00C
	.long 0x000053C8
	.long 0x0F168013
	.long 0x000053DC
	.long 0x0F168013
	.long 0x000053E4
	.long 0x2D80E00B
	.long 0x00005424
	.long 0x08000024
	.long 0x00005434
	.long 0x08000025
	.long 0x00005454
	.long 0xB49B8013
	.long 0x00005468
	.long 0xB49B8013
	.long 0x0000547C
	.long 0xB49B8013
	.long 0x00005494
	.long 0x04000004
	.long 0x000054A4
	.long 0x1E190013
	.long 0x000054B8
	.long 0x1E190013
	.long 0x000054CC
	.long 0x1E190013
	.long 0x000054D4
	.long 0x04000014
	.long 0x000054DC
	.long 0x04000002
	.long 0x00005510
	.long 0x0B0C0107
	.long 0x00005514
	.long 0x2C80C80C
	.long 0x00005524
	.long 0x0B0C0107
	.long 0x00005528
	.long 0x2D00980C
	.long 0x00005538
	.long 0x0B0C0107
	.long 0x0000553C
	.long 0x2D80E00C
	.long 0x0000554C
	.long 0x0B0C0107
	.long 0x00005560
	.long 0x04000006
	.long 0x00005570
	.long 0x26118013
	.long 0x00005574
	.long 0x160C0087
	.long 0x00005584
	.long 0x26118013
	.long 0x00005588
	.long 0x160C0087
	.long 0x00005598
	.long 0x26118013
	.long 0x0000559C
	.long 0x160C0087
	.long 0x000055A0
	.long 0x2D80E007
	.long 0x000055AC
	.long 0x26118013
	.long 0x000055B0
	.long 0x160C0087
	.long 0x000055E0
	.long 0x2C00380A
	.long 0x000055EC
	.long 0x201D4013
	.long 0x000055F0
	.long 0x0900008B
	.long 0x000055F4
	.long 0x2C80380A
	.long 0x00005600
	.long 0x201D4013
	.long 0x00005604
	.long 0x0900008B
	.long 0x00005608
	.long 0x2D00200A
	.long 0x00005614
	.long 0x201D4013
	.long 0x00005618
	.long 0x0900008B
	.long 0x00005640
	.long 0x2C00680A
	.long 0x00005644
	.long 0x04E20055
	.long 0x0000564C
	.long 0x201D4013
	.long 0x00005650
	.long 0x0900008B
	.long 0x00005654
	.long 0x2C80680A
	.long 0x00005658
	.long 0x04E202FE
	.long 0x00005660
	.long 0x201D4013
	.long 0x00005664
	.long 0x0900008B
	.long 0x00005668
	.long 0x2D00200A
	.long 0x0000566C
	.long 0x05780000
	.long 0x00005674
	.long 0x201D4013
	.long 0x00005678
	.long 0x0900008B
	.long 0x00005698
	.long 0x08000018
	.long 0x000056C4
	.long 0x28170013
	.long 0x000056D8
	.long 0x28170013
	.long 0x000056EC
	.long 0x28170013
	.long 0x00005764
	.long 0x168C0107
	.long 0x00005778
	.long 0x168C0107
	.long 0x00006B1C
	.long 0x0020008B
	.long 0x00006B44
	.long 0x0020008B
	.long 0x00006B70
	.long 0x0020008B
	.long 0x00006BA8
	.long 0x0020008B
	.long 0x00006BBC
	.long 0x0020008B
	.long 0x00006BE8
	.long 0x0020008B
	.long 0x00006C30
	.long 0x0D9B8000
	.long 0x00006C34
	.long 0x16822000
	.long 0x00006CC8
	.long 0x16022000
	.long 0x00006D8C
	.long 0x2D168000
	.long 0x00006D90
	.long 0x20022000
	.long 0x00006DC0
	.long 0x2C80E008
	.long 0x00006DCC
	.long 0x0A0B4010
	.long 0x00006DD0
	.long 0x1E0C010F
	.long 0xFFFFFFFF
	.long 0x000036E0
	.long 0x41700000
	.long 0x00003704
	.long 0x3F199999
	.long 0x00003718
	.long 0x3FA66666
	.long 0x0000371C
	.long 0x3FD9999A
	.long 0x000040FC
	.long 0x29990473
	.long 0x00004110
	.long 0x29990473
	.long 0x00004124
	.long 0x2A990473
	.long 0x0000414C
	.long 0x0800000A
	.long 0x00004270
	.long 0x2C823009
	.long 0x00004274
	.long 0x03840190
	.long 0x00004278
	.long 0x00000000
	.long 0x000042AC
	.long 0x2C023008
	.long 0x000042B0
	.long 0x03840190
	.long 0x000042B4
	.long 0x00000000
	.long 0x00004574
	.long 0x08000019
	.long 0x00004660
	.long 0x04000008
	.long 0x00004760
	.long 0x04000008
	.long 0x00004860
	.long 0x04000008
	.long 0x00004A84
	.long 0x08000007
	.long 0x00005D64
	.long 0x03B60000
	.long 0x00005D78
	.long 0x03B60000
	.long 0x00005DB8
	.long 0x03B60000
	.long 0x00005DCC
	.long 0x03B60000
	.long 0x00005DE0
	.long 0x03B60000
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x0000346C
	.long 0x3D75C28F
	.long 0x00003494
	.long 0x40200000
	.long 0x000034A0
	.long 0x3FB33333
	.long 0x000034C0
	.long 0x3F8CCCCD
	.long 0x0000354C
	.long 0x41A00000
	.long 0x00003618
	.long 0x3CA3D70A
	.long 0x000036E4
	.long 0xCC000000
	.long 0x00003734
	.long 0xCC000000
	.long 0x000037C4
	.long 0xCC000000
	.long 0x000037D4
	.long 0xB4990013
	.long 0x000037D8
	.long 0x0A08109F
	.long 0x00003858
	.long 0xCC000000
	.long 0x000038D0
	.long 0xCC000000
	.long 0x000039D8
	.long 0xCC000001
	.long 0x00003B5C
	.long 0x40000000
	.long 0x00003CEC
	.long 0x09600000
	.long 0x00003CF4
	.long 0xB4A1C000
	.long 0x0000417C
	.long 0x08000005
	.long 0x00004180
	.long 0x2C007809
	.long 0x00004184
	.long 0x047E0000
	.long 0x00004188
	.long 0x04B0007F
	.long 0x0000418C
	.long 0xB49B4013
	.long 0x00004190
	.long 0x14000107
	.long 0x00004194
	.long 0x2C802009
	.long 0x00004198
	.long 0x02FE0000
	.long 0x0000419C
	.long 0x00AA0000
	.long 0x000041A0
	.long 0xB49B4013
	.long 0x000041A4
	.long 0x14000107
	.long 0x000041A8
	.long 0x28000000
	.long 0x000041AC
	.long 0x03FD0000
	.long 0x000041B0
	.long 0x00000000
	.long 0x000041BC
	.long 0x04000005
	.long 0x000041C0
	.long 0x2C802006
	.long 0x000041C4
	.long 0x03200000
	.long 0x000041C8
	.long 0x00AA0000
	.long 0x000041CC
	.long 0x0F1EC013
	.long 0x000041D0
	.long 0x0500008B
	.long 0x000041D4
	.long 0x3C000000
	.long 0x000041D8
	.long 0x08000011
	.long 0x000041DC
	.long 0x40000000
	.long 0x000041E0
	.long 0xD0000003
	.long 0x000041E4
	.long 0x28000000
	.long 0x000041E8
	.long 0x03FF0000
	.long 0x000041EC
	.long 0x00000000
	.long 0x000041F0
	.long 0x00000000
	.long 0x000041F4
	.long 0x00000000
	.long 0x000041F8
	.long 0x44000000
	.long 0x000041FC
	.long 0x0000000B
	.long 0x00004200
	.long 0x00007F40
	.long 0x00004204
	.long 0x08000021
	.long 0x00004358
	.long 0x1900008B
	.long 0x0000436C
	.long 0x1B80008B
	.long 0x00004380
	.long 0x1B80008B
	.long 0x000043D0
	.long 0x0C990013
	.long 0x000043E4
	.long 0x0C990013
	.long 0x000043F8
	.long 0x0C990013
	.long 0x000044A8
	.long 0xCC000001
	.long 0x000044D8
	.long 0x04C60000
	.long 0x000044DC
	.long 0x070808FC
	.long 0x000044E0
	.long 0x001903D0
	.long 0x000044E4
	.long 0x0008009F
	.long 0x000044EC
	.long 0x051B0000
	.long 0x000044F0
	.long 0x07081004
	.long 0x000044F4
	.long 0x7D190510
	.long 0x000044F8
	.long 0x0008009F
	.long 0x00004500
	.long 0x061B0000
	.long 0x00004504
	.long 0x070816A8
	.long 0x00004508
	.long 0x5A190510
	.long 0x0000450C
	.long 0x0008009F
	.long 0x00004520
	.long 0x05F20000
	.long 0x00004524
	.long 0x070808FC
	.long 0x00004534
	.long 0x06470000
	.long 0x00004538
	.long 0x07081004
	.long 0x00004548
	.long 0x07470000
	.long 0x0000454C
	.long 0x070816A8
	.long 0x00004698
	.long 0x50168013
	.long 0x000046AC
	.long 0x50168013
	.long 0x000046C0
	.long 0x50168013
	.long 0x00004704
	.long 0x08000029
	.long 0x0000470C
	.long 0x0800002B
	.long 0x000047D8
	.long 0x44040000
	.long 0x000047DC
	.long 0x00000097
	.long 0x000047E0
	.long 0x00007F40
	.long 0x000047E4
	.long 0xCC000001
	.long 0x000047E8
	.long 0x2C00780B
	.long 0x000047EC
	.long 0x067D0000
	.long 0x000047F0
	.long 0x0229007F
	.long 0x000047F4
	.long 0x19168013
	.long 0x000047F8
	.long 0x0F080107
	.long 0x000047FC
	.long 0x2C80200B
	.long 0x00004800
	.long 0x05A80000
	.long 0x00004804
	.long 0x00000000
	.long 0x00004808
	.long 0x19168013
	.long 0x0000480C
	.long 0x0F080107
	.long 0x00004810
	.long 0x0400000E
	.long 0x00004814
	.long 0x40000000
	.long 0x00004818
	.long 0x0400000A
	.long 0x0000481C
	.long 0x4C000000
	.long 0x00004820
	.long 0x08000028
	.long 0x00004824
	.long 0x5C000000
	.long 0x00004828
	.long 0xCC000000
	.long 0x0000482C
	.long 0xCC000000
	.long 0x00004830
	.long 0xCC000000
	.long 0x00004850
	.long 0xCC000001
	.long 0x00004854
	.long 0x2C00780C
	.long 0x00004858
	.long 0x03840000
	.long 0x0000485C
	.long 0x00000000
	.long 0x00004860
	.long 0x101F4013
	.long 0x00004864
	.long 0x0A08010B
	.long 0x00004868
	.long 0x2C80200C
	.long 0x0000486C
	.long 0x03840000
	.long 0x00004870
	.long 0x00000000
	.long 0x00004874
	.long 0x101F4013
	.long 0x00004878
	.long 0x0A08010B
	.long 0x0000487C
	.long 0x2D00800C
	.long 0x00004880
	.long 0x03840000
	.long 0x00004884
	.long 0xFE0C0000
	.long 0x00004888
	.long 0x101F4013
	.long 0x0000488C
	.long 0x0A08010B
	.long 0x00004890
	.long 0x04000004
	.long 0x00004894
	.long 0x2C007809
	.long 0x00004898
	.long 0x03840000
	.long 0x0000489C
	.long 0x00000000
	.long 0x000048A0
	.long 0xB4990013
	.long 0x000048A4
	.long 0x0A00000B
	.long 0x000048A8
	.long 0x2C802009
	.long 0x000048AC
	.long 0x03840000
	.long 0x000048B0
	.long 0x00000000
	.long 0x000048B4
	.long 0xB4990013
	.long 0x000048B8
	.long 0x0A00000B
	.long 0x000048BC
	.long 0x2D008009
	.long 0x000048C0
	.long 0x03840000
	.long 0x000048C4
	.long 0xFE0C0000
	.long 0x000048C8
	.long 0xB4990013
	.long 0x000048CC
	.long 0x0A00000B
	.long 0x000048D0
	.long 0x08000026
	.long 0x000048D4
	.long 0x40000000
	.long 0x000048D8
	.long 0x08000032
	.long 0x000048DC
	.long 0x4C000000
	.long 0x00004910
	.long 0x2800000B
	.long 0x00004924
	.long 0x2800000B
	.long 0x00004938
	.long 0x2800000B
	.long 0x00004950
	.long 0x2800000B
	.long 0x00004964
	.long 0x2800000B
	.long 0x00004978
	.long 0x2800000B
	.long 0x00004990
	.long 0x2800000B
	.long 0x000049A4
	.long 0x2800000B
	.long 0x000049B8
	.long 0x2800000B
	.long 0x00004A04
	.long 0x87140013
	.long 0x00004A18
	.long 0x87140013
	.long 0x00004B08
	.long 0x07290000
	.long 0x00004B10
	.long 0x87078013
	.long 0x00004B14
	.long 0x1E08011E
	.long 0x00004B1C
	.long 0x062A0000
	.long 0x00004B24
	.long 0x87078013
	.long 0x00004B28
	.long 0x1E08011E
	.long 0x00004B2C
	.long 0xCC000000
	.long 0x00005334
	.long 0x08000014
	.long 0x00005B34
	.long 0xCC000000
	.long 0x00005B9C
	.long 0xCC000000
	.long 0x00005D94
	.long 0x20898000
	.long 0x00005D98
	.long 0x28122000
	.long 0xCC007AC8
	.long 0x00000B60
	.long 0x00007ACC
	.long 0x00068760
	.long 0x00007AD0
	.long 0x000017A0
	.long 0x00007AD8
	.long 0x00000017
	.long 0xFFFFFFFF
	.long 0x0000367C
	.long 0x3D3851EC
	.long 0x00003680
	.long 0x3F8A5E35
	.long 0x0000369C
	.long 0x42960000
	.long 0x000036A4
	.long 0x41810000
	.long 0x000036FC
	.long 0x41C00000
	.long 0x00003700
	.long 0x41B00000
	.long 0x00003704
	.long 0x41B00000
	.long 0x00003708
	.long 0x41A00000
	.long 0x0000370C
	.long 0x41800000
	.long 0x000037B0
	.long 0x41700000
	.long 0x00003950
	.long 0xB49E0013
	.long 0x00003954
	.long 0x16BC0007
	.long 0x00003964
	.long 0xB49E0013
	.long 0x00003968
	.long 0x16BC0007
	.long 0x00003990
	.long 0x1E00511B
	.long 0x000039A4
	.long 0x1E00511B
	.long 0x000039BC
	.long 0x2C008804
	.long 0x000039C8
	.long 0x141E0013
	.long 0x000039CC
	.long 0x3234010B
	.long 0x000039D0
	.long 0x2C808804
	.long 0x000039DC
	.long 0x141E0013
	.long 0x000039E0
	.long 0x3234010B
	.long 0x00003A08
	.long 0x25878013
	.long 0x00003A0C
	.long 0x2808009F
	.long 0x00003A1C
	.long 0x25878013
	.long 0x00003A20
	.long 0x2808009F
	.long 0x00003A8C
	.long 0xB4918013
	.long 0x00003A90
	.long 0x1E0C0123
	.long 0x00003AA0
	.long 0xB4918013
	.long 0x00003AA4
	.long 0x1E0C0123
	.long 0x00003ABC
	.long 0x2C008810
	.long 0x00003AC8
	.long 0x0F1908D3
	.long 0x00003AD0
	.long 0x2C808810
	.long 0x00003ADC
	.long 0x0F1908D3
	.long 0x00003B88
	.long 0x2C000008
	.long 0x00004590
	.long 0x0800000D
	.long 0x0000497C
	.long 0x220C8013
	.long 0x000049E4
	.long 0x12990013
	.long 0x000049E8
	.long 0x0A00008B
	.long 0x000049F8
	.long 0x12990013
	.long 0x000049FC
	.long 0x0A00008B
	.long 0x00004A0C
	.long 0x12990013
	.long 0x00004A10
	.long 0x0A00008B
	.long 0x00004A20
	.long 0x12990013
	.long 0x00004A24
	.long 0x0A00008B
	.long 0x00004A40
	.long 0x08000026
	.long 0x00004AF0
	.long 0x218E0013
	.long 0x00004AF4
	.long 0x30000089
	.long 0x00004BD0
	.long 0x2C00000C
	.long 0x00004BE4
	.long 0x2C80000C
	.long 0x00004BF8
	.long 0x2D00C00C
	.long 0x00004C64
	.long 0x2C00A015
	.long 0x00004C74
	.long 0x14003D07
	.long 0x00004CAC
	.long 0x08000026
	.long 0x00004D1C
	.long 0x2C00000C
	.long 0x00004D28
	.long 0x0A110013
	.long 0x00004D2C
	.long 0x1900008B
	.long 0x00004D30
	.long 0x2C80000C
	.long 0x00004D3C
	.long 0x0A110013
	.long 0x00004D40
	.long 0x1900008B
	.long 0x00004D50
	.long 0x28190013
	.long 0x00004D64
	.long 0x28190013
	.long 0x00004DAC
	.long 0x08000021
	.long 0x00004E2C
	.long 0xB4968013
	.long 0x00004E30
	.long 0x07800107
	.long 0x00004E40
	.long 0xB4968013
	.long 0x00004E44
	.long 0x07800107
	.long 0x00004E68
	.long 0xB4954013
	.long 0x00004E7C
	.long 0xB4954013
	.long 0x00004EBC
	.long 0x1E00088F
	.long 0x00004ED0
	.long 0x1E00088F
	.long 0x00004F00
	.long 0x2F0F0013
	.long 0x00004F04
	.long 0x0800008B
	.long 0x00004F14
	.long 0x2F0F0013
	.long 0x00004F18
	.long 0x0800008B
	.long 0x00004F2C
	.long 0x04000007
	.long 0x00004F34
	.long 0x08000010
	.long 0x00004F3C
	.long 0x079E0000
	.long 0x00004F50
	.long 0x05460000
	.long 0x00004F70
	.long 0x04000007
	.long 0x00004FC8
	.long 0x04000005
	.long 0x00005080
	.long 0x07080000
	.long 0x00005084
	.long 0x03200258
	.long 0x00005088
	.long 0x87140013
	.long 0x0000508C
	.long 0x1900010A
	.long 0xFFFFFFFF
	.long 0x00003738
	.long 0x3FAA3D71
	.long 0x00003744
	.long 0x3FB0A3D7
	.long 0x00003754
	.long 0x40A00000
	.long 0x00003800
	.long 0x40800000
	.long 0x00003814
	.long 0x42000000
	.long 0x000038DC
	.long 0x41F00000
	.long 0x000038E4
	.long 0x3F933333
	.long 0x000038EC
	.long 0x41D00000
	.long 0x00003920
	.long 0x3FE66666
	.long 0x00003E1C
	.long 0x00200087
	.long 0x00003E64
	.long 0x08000021
	.long 0x000046A0
	.long 0x68000001
	.long 0x000046A4
	.long 0x2C02100E
	.long 0x000046A8
	.long 0x05DC0000
	.long 0x000046AC
	.long 0x000000C8
	.long 0x000046B0
	.long 0x39940013
	.long 0x000046B4
	.long 0x14000507
	.long 0x000046B8
	.long 0x28000000
	.long 0x000046BC
	.long 0x03FD0000
	.long 0x000046C0
	.long 0x00000000
	.long 0x000046CC
	.long 0x04000003
	.long 0x000046D0
	.long 0x68000000
	.long 0x000046E8
	.long 0x04000009
	.long 0x00004870
	.long 0x28000000
	.long 0x00004874
	.long 0x04060000
	.long 0x00004878
	.long 0x00000000
	.long 0x0000487C
	.long 0x00000000
	.long 0x00004884
	.long 0x28000000
	.long 0x00004888
	.long 0x04070000
	.long 0x0000488C
	.long 0x00000000
	.long 0x00004890
	.long 0x00000000
	.long 0x00004894
	.long 0x00000000
	.long 0x00004898
	.long 0x28000000
	.long 0x0000489C
	.long 0x05140000
	.long 0x000048A0
	.long 0x00000000
	.long 0x000048A4
	.long 0x00000000
	.long 0x000048A8
	.long 0x00000000
	.long 0x000048AC
	.long 0x08000002
	.long 0x000048B0
	.long 0xCC000000
	.long 0x000048B4
	.long 0xCC000000
	.long 0x000048B8
	.long 0xCC000000
	.long 0x000048BC
	.long 0x08000003
	.long 0x000048C0
	.long 0x2C00C80D
	.long 0x000048C4
	.long 0x03E80000
	.long 0x000048C8
	.long 0x00000000
	.long 0x000048CC
	.long 0x2D1AC013
	.long 0x000048D0
	.long 0x14343D23
	.long 0x000048D4
	.long 0x2C80B80D
	.long 0x000048D8
	.long 0x03E80000
	.long 0x000048DC
	.long 0x00000000
	.long 0x000048E0
	.long 0x2D1AC013
	.long 0x000048E4
	.long 0x14343D23
	.long 0x000048E8
	.long 0x2D00200A
	.long 0x000048EC
	.long 0x03E80000
	.long 0x000048F0
	.long 0x00000000
	.long 0x000048F4
	.long 0xB49B8013
	.long 0x000048F8
	.long 0x0A002923
	.long 0x000048FC
	.long 0x44040000
	.long 0x00004900
	.long 0x000000A6
	.long 0x00004904
	.long 0x00007F40
	.long 0x00004908
	.long 0x44000000
	.long 0x0000490C
	.long 0x00000074
	.long 0x00004910
	.long 0x00007F40
	.long 0x00004914
	.long 0x44080000
	.long 0x00004918
	.long 0x000493F0
	.long 0x0000491C
	.long 0x00007F40
	.long 0x00004920
	.long 0x04000006
	.long 0x00004924
	.long 0x6C000000
	.long 0x00004928
	.long 0x44000000
	.long 0x0000492C
	.long 0x00000074
	.long 0x00004930
	.long 0x00007F40
	.long 0x00004934
	.long 0x04000003
	.long 0x00004938
	.long 0x40000000
	.long 0x0000493C
	.long 0x08000016
	.long 0x00004940
	.long 0xD0000000
	.long 0x00004944
	.long 0x08000017
	.long 0x00004948
	.long 0x5C000000
	.long 0x0000494C
	.long 0xD0000003
	.long 0x00004950
	.long 0xCC000000
	.long 0x00004954
	.long 0xCC000000
	.long 0x00004958
	.long 0xCC000000
	.long 0x0000495C
	.long 0xCC000000
	.long 0x00004960
	.long 0xCC000000
	.long 0x00004964
	.long 0xCC000000
	.long 0x00004968
	.long 0xCC000000
	.long 0x0000496C
	.long 0xCC000000
	.long 0x00004E1C
	.long 0x04000005
	.long 0x00004E24
	.long 0x08000010
	.long 0x00004E74
	.long 0x0400000B
	.long 0x00004E7C
	.long 0x4C000000
	.long 0x00004E80
	.long 0x04000004
	.long 0x00006038
	.long 0x0AF007D0
	.long 0x000060A0
	.long 0x0A280960
	.long 0xCC007B80
	.long 0x000022A4
	.long 0x00007B84
	.long 0x00086D80
	.long 0x00007B88
	.long 0x00001C32
	.long 0xFFFFFFFF
	.long 0x00003900
	.long 0x3D4CCCCD
	.long 0x00003908
	.long 0x3F778D50
	.long 0x00003A24
	.long 0x00000007
	.long 0x00003A3C
	.long 0x3FB33333
	.long 0x00003D8C
	.long 0x2E864013
	.long 0x00003D90
	.long 0x190C000F
	.long 0x00003DA0
	.long 0x2C064013
	.long 0x00003DA4
	.long 0x190C000F
	.long 0x00003DBC
	.long 0x2D827005
	.long 0x00003DC8
	.long 0x29864013
	.long 0x00003DCC
	.long 0x1900000F
	.long 0x00003E88
	.long 0x2D827006
	.long 0x00003E98
	.long 0x1900008F
	.long 0x00003E9C
	.long 0x0800000E
	.long 0x00003EA0
	.long 0x28000000
	.long 0x00003EA4
	.long 0x03F70000
	.long 0x00003EA8
	.long 0x00000000
	.long 0x00003EAC
	.long 0x00000000
	.long 0x00003EB4
	.long 0x4C000001
	.long 0x00003EB8
	.long 0x0800000F
	.long 0x00003EBC
	.long 0x40000000
	.long 0x00003F40
	.long 0x2C00D805
	.long 0x00003F54
	.long 0x2D827006
	.long 0x0000401C
	.long 0x2D82700A
	.long 0x00004028
	.long 0x8C0F0013
	.long 0x0000402C
	.long 0x2800050F
	.long 0x00004070
	.long 0x2D827007
	.long 0x000040FC
	.long 0x2C027009
	.long 0x0000410C
	.long 0x200C050F
	.long 0x00004110
	.long 0x2C824809
	.long 0x00004120
	.long 0x200C050F
	.long 0x00004124
	.long 0x2D00D809
	.long 0x00004134
	.long 0x200C050F
	.long 0x00004138
	.long 0x2D827009
	.long 0x00004148
	.long 0x20000507
	.long 0x000041F8
	.long 0x000414A3
	.long 0x0000420C
	.long 0x000414A3
	.long 0x00004220
	.long 0x000414A3
	.long 0x00004234
	.long 0x0F0414A3
	.long 0x00004258
	.long 0x28041923
	.long 0x0000426C
	.long 0x28041923
	.long 0x00004280
	.long 0x28041923
	.long 0x00004294
	.long 0x28041923
	.long 0x0000434C
	.long 0x2D82700D
	.long 0x00004408
	.long 0x2D82700D
	.long 0x000044B0
	.long 0x0104148F
	.long 0x000044C4
	.long 0x0104148F
	.long 0x000044D8
	.long 0x0104148F
	.long 0x000044EC
	.long 0x0104148F
	.long 0x00004534
	.long 0x0F041523
	.long 0x00004548
	.long 0x0F041523
	.long 0x0000455C
	.long 0x0F041523
	.long 0x00004570
	.long 0x0F041523
	.long 0x00004624
	.long 0x2D82700A
	.long 0x00004678
	.long 0x2D827007
	.long 0x0000480C
	.long 0x2C027003
	.long 0x00004818
	.long 0x2A348010
	.long 0x0000481C
	.long 0x0F0400A3
	.long 0x00004820
	.long 0x2C827003
	.long 0x0000482C
	.long 0x2A348010
	.long 0x00004830
	.long 0x0F0400A3
	.long 0x00004834
	.long 0x2D002003
	.long 0x00004840
	.long 0x2A348010
	.long 0x00004844
	.long 0x0F0400A3
	.long 0x00004848
	.long 0x2D827003
	.long 0x00004854
	.long 0xB4AF8010
	.long 0x00004858
	.long 0x0F04000F
	.long 0x0000485C
	.long 0x04000004
	.long 0x00004E28
	.long 0x2D827004
	.long 0x00004E38
	.long 0x0F0C0087
	.long 0x00004EC0
	.long 0x2D82700A
	.long 0x00004ECC
	.long 0x2A8DC013
	.long 0x00004ED0
	.long 0x23000087
	.long 0x00004EEC
	.long 0x04000008
	.long 0x00004F44
	.long 0x2C82480E
	.long 0x00004F54
	.long 0x1E0C010F
	.long 0x00004F58
	.long 0x2D00D80E
	.long 0x00004F68
	.long 0x1E0C010F
	.long 0x00004F6C
	.long 0x2D82700C
	.long 0x00004F7C
	.long 0x1E0C008F
	.long 0x0000502C
	.long 0x2D82700A
	.long 0x00005038
	.long 0x371D0013
	.long 0x0000503C
	.long 0x118C008F
	.long 0x00005080
	.long 0x2D82700A
	.long 0x0000508C
	.long 0x2A9D0013
	.long 0x00005090
	.long 0x118C008F
	.long 0x000050A4
	.long 0x08000020
	.long 0x0000510C
	.long 0x2D827009
	.long 0x000051F4
	.long 0xB4918013
	.long 0x000051F8
	.long 0x1E0C0107
	.long 0x0000527C
	.long 0x0800000E
	.long 0x00005280
	.long 0x28000000
	.long 0x00005284
	.long 0x03FB0000
	.long 0x00005288
	.long 0x00000000
	.long 0x0000528C
	.long 0x00000000
	.long 0x00005290
	.long 0x00000000
	.long 0x00005294
	.long 0x2D000004
	.long 0x00005298
	.long 0x044C0000
	.long 0x0000529C
	.long 0x06A40578
	.long 0x000052A0
	.long 0x46191373
	.long 0x000052A4
	.long 0x000400A3
	.long 0x000052A8
	.long 0x2D800004
	.long 0x000052AC
	.long 0x044C0000
	.long 0x000052B0
	.long 0x06A4FA88
	.long 0x000052B4
	.long 0x46191373
	.long 0x000052B8
	.long 0x000400A3
	.long 0x000052BC
	.long 0xCC000000
	.long 0x000052C0
	.long 0xCC000000
	.long 0x000052C4
	.long 0x0800000F
	.long 0x000052C8
	.long 0x40000000
	.long 0x000052CC
	.long 0x48000000
	.long 0x000052D0
	.long 0x44040000
	.long 0x000052D4
	.long 0x0000009E
	.long 0x000052D8
	.long 0x00007F40
	.long 0x000052DC
	.long 0xAC024000
	.long 0x000052E4
	.long 0x28000000
	.long 0x000052E8
	.long 0x05150000
	.long 0x000052EC
	.long 0x00000000
	.long 0x000052FC
	.long 0x040D0000
	.long 0x00005300
	.long 0x00001B58
	.long 0x00005304
	.long 0x01F40000
	.long 0x0000530C
	.long 0x2C027011
	.long 0x00005310
	.long 0x05DC03E8
	.long 0x00005314
	.long 0x00000000
	.long 0x00005318
	.long 0x2D140013
	.long 0x00005320
	.long 0x2C824811
	.long 0x00005324
	.long 0x05140000
	.long 0x0000532C
	.long 0x2D140013
	.long 0x00005334
	.long 0x2D000011
	.long 0x00005338
	.long 0x044C0000
	.long 0x0000533C
	.long 0x07D00000
	.long 0x00005340
	.long 0x2D140013
	.long 0x00005348
	.long 0x04000005
	.long 0x000053AC
	.long 0x25940013
	.long 0x000053C0
	.long 0x25940013
	.long 0x000053D4
	.long 0x25940013
	.long 0x000053DC
	.long 0x2D827010
	.long 0x00005450
	.long 0x25938013
	.long 0x00005464
	.long 0x25938013
	.long 0x00005478
	.long 0x25938013
	.long 0x00005480
	.long 0x2D82700C
	.long 0x000054E4
	.long 0x03E80000
	.long 0x000054F8
	.long 0x03E80000
	.long 0x0000550C
	.long 0x03E80578
	.long 0x00005518
	.long 0x0F00000F
	.long 0x00005548
	.long 0x2C02700B
	.long 0x00005554
	.long 0xB497C013
	.long 0x0000555C
	.long 0x2C82480B
	.long 0x00005560
	.long 0x03E80000
	.long 0x00005568
	.long 0xB497C013
	.long 0x00005570
	.long 0x2D00D80B
	.long 0x00005574
	.long 0x03E80000
	.long 0x0000557C
	.long 0xB497C013
	.long 0x00005584
	.long 0x2D82700B
	.long 0x00005588
	.long 0x03E80578
	.long 0x00005590
	.long 0xB497C013
	.long 0x00005594
	.long 0x1900010F
	.long 0x000055E4
	.long 0x2C027009
	.long 0x000055F0
	.long 0xB48F0013
	.long 0x000055F4
	.long 0x140C010F
	.long 0x000055F8
	.long 0x2C824809
	.long 0x00005604
	.long 0xB48F0013
	.long 0x00005608
	.long 0x140C010F
	.long 0x0000560C
	.long 0x2D00D809
	.long 0x00005618
	.long 0xB48F0013
	.long 0x0000561C
	.long 0x140C010F
	.long 0x00005620
	.long 0x2D827008
	.long 0x0000562C
	.long 0x218C8013
	.long 0x00005630
	.long 0x1E0C0107
	.long 0x00005638
	.long 0x08000009
	.long 0x00005678
	.long 0x2C02700E
	.long 0x00005684
	.long 0xB4990013
	.long 0x0000568C
	.long 0x2C82480E
	.long 0x00005698
	.long 0xB4990013
	.long 0x000056A0
	.long 0x2D00D80E
	.long 0x000056AC
	.long 0xB4990013
	.long 0x000056B4
	.long 0x2D82700A
	.long 0x000056C0
	.long 0xB4990013
	.long 0x000056C4
	.long 0x0F0C0107
	.long 0x000056CC
	.long 0x0800000C
	.long 0x00005710
	.long 0x2C82700A
	.long 0x0000571C
	.long 0x280DC013
	.long 0x00005720
	.long 0x140C010F
	.long 0x00005724
	.long 0x2D02480A
	.long 0x00005730
	.long 0x280DC013
	.long 0x00005734
	.long 0x140C010F
	.long 0x00005738
	.long 0x2D80D80A
	.long 0x00005744
	.long 0x280DC013
	.long 0x00005748
	.long 0x140C010F
	.long 0x0000574C
	.long 0x2C027008
	.long 0x00005758
	.long 0x280DC013
	.long 0x0000575C
	.long 0x0F0C0107
	.long 0x00005764
	.long 0x0800000C
	.long 0x000057A4
	.long 0x2C82700C
	.long 0x000057B0
	.long 0x87140013
	.long 0x000057B4
	.long 0x1E0C0107
	.long 0x000057B8
	.long 0x2D024810
	.long 0x000057C4
	.long 0x91190013
	.long 0x000057C8
	.long 0x1904010F
	.long 0x000057CC
	.long 0x2D80D810
	.long 0x000057D8
	.long 0x91190013
	.long 0x000057DC
	.long 0x1904010F
	.long 0x000057E0
	.long 0x2C02700C
	.long 0x000057EC
	.long 0x87140013
	.long 0x000057F0
	.long 0x1E0C0107
	.long 0x00006064
	.long 0x68000002
	.long 0x00006068
	.long 0x08000006
	.long 0x0000606C
	.long 0x28000000
	.long 0x00006070
	.long 0x04070000
	.long 0x0000607C
	.long 0x00000000
	.long 0x00006A2C
	.long 0x88000004
	.long 0xFFFFFFFF
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x3C60803C
	.long 0x60000000
	.long 0x00000000
	.long 0xC2073338
	.long 0x000000B6
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7F63DB78
	.long 0x8BFE000C
	.long 0x3FA08045
	.long 0x63BD3084
	.long 0x1FFF0E90
	.long 0x7FFDFA14
	.long 0x809F0000
	.long 0x8BFF0008
	.long 0x2C040013
	.long 0x4182001C
	.long 0x2C040012
	.long 0x40A20020
	.long 0x2C1F0001
	.long 0x40A20018
	.long 0x38800013
	.long 0x48000010
	.long 0x2C1F0001
	.long 0x40A20008
	.long 0x38800012
	.long 0xC03E0894
	.long 0xFC20081E
	.long 0xD8210080
	.long 0x80A10084
	.long 0x80DE0010
	.long 0x80FE0014
	.long 0x60E78000
	.long 0x83BE0004
	.long 0x1FBD0008
	.long 0x48000075
	.long 0x7FE802A6
	.long 0x87BF0008
	.long 0x2C1D0000
	.long 0x41820504
	.long 0x57BC463E
	.long 0x2C1C00FF
	.long 0x41820014
	.long 0x7C1C2000
	.long 0x4182000C
	.long 0x418104EC
	.long 0x4BFFFFDC
	.long 0x57BC863E
	.long 0x7C1C2800
	.long 0x41A1FFD0
	.long 0x57BC043E
	.long 0x7C1C3000
	.long 0x4182000C
	.long 0x7C1C3800
	.long 0x4082FFBC
	.long 0x839F0004
	.long 0x2C1CFFFF
	.long 0x418204BC
	.long 0xC03F0004
	.long 0x3D808006
	.long 0x618CF190
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x480004A4
	.long 0x4E800021
	.long 0x00090165
	.long 0x3EE66666
	.long 0x00000165
	.long 0x40000000
	.long 0x00080160
	.long 0x3FC00000
	.long 0x001400EB
	.long 0x3FC00000
	.long 0x01190042
	.long 0x3F800000
	.long 0x01000042
	.long 0x3FA00000
	.long 0x01180045
	.long 0x3FC00000
	.long 0x011800EB
	.long 0x3FD00000
	.long 0x01000181
	.long 0x40000000
	.long 0x03090038
	.long 0x3F800000
	.long 0x03000038
	.long 0x3FC00000
	.long 0x0318003F
	.long 0x3F800000
	.long 0x0301003F
	.long 0xFFFFFFFF
	.long 0x0300003F
	.long 0x3FC00000
	.long 0x030A0042
	.long 0x3F800000
	.long 0x03000042
	.long 0x3FA00000
	.long 0x031400E9
	.long 0x3FF00000
	.long 0x031400EA
	.long 0x3FF00000
	.long 0x030C00EB
	.long 0x3FE66666
	.long 0x03260177
	.long 0x41300000
	.long 0x0326017A
	.long 0x41300000
	.long 0x040A0042
	.long 0x3F800000
	.long 0x04000042
	.long 0x3FD55555
	.long 0x04120045
	.long 0x3F800000
	.long 0x04000045
	.long 0x3FE66666
	.long 0x041D00DC
	.long 0x40000000
	.long 0x043900DE
	.long 0x402AAAAB
	.long 0x0416017F
	.long 0x3F800000
	.long 0x0400017F
	.long 0x3FA5A5A6
	.long 0x042E0180
	.long 0x40000000
	.long 0x0400018C
	.long 0x40000000
	.long 0x05160044
	.long 0x3F800000
	.long 0x05000044
	.long 0x3FB00000
	.long 0x052F00DE
	.long 0x3FC00000
	.long 0x051700E9
	.long 0x40124925
	.long 0x051A00EA
	.long 0x40500000
	.long 0x051900EB
	.long 0x40080000
	.long 0x05000157
	.long 0x40000000
	.long 0x0512015B
	.long 0x3F9E1E1E
	.long 0x0510015B
	.long 0x3F800000
	.long 0x0500015B
	.long 0x3FAAAAAB
	.long 0x05120161
	.long 0x3F9E1E1E
	.long 0x05100161
	.long 0x3F800000
	.long 0x05000161
	.long 0x3FAAAAAB
	.long 0x0500016B
	.long 0x3FC00000
	.long 0x05140045
	.long 0x3ECCCCCD
	.long 0x06100035
	.long 0x3F800000
	.long 0x06000035
	.long 0x3FBA2E8C
	.long 0x060D0039
	.long 0x3F800000
	.long 0x06000039
	.long 0x3FE00000
	.long 0x061E0042
	.long 0x3F800000
	.long 0x06100042
	.long 0x3FE00000
	.long 0x061400EA
	.long 0x3FC5D174
	.long 0x061B015E
	.long 0x3F800000
	.long 0x0600015E
	.long 0x3FA2E8BA
	.long 0x061B0161
	.long 0x3F800000
	.long 0x06000161
	.long 0x3FA2E8BA
	.long 0x06000166
	.long 0x3FA66666
	.long 0x06000167
	.long 0x3FA66666
	.long 0x08160042
	.long 0x3FF33333
	.long 0x08120042
	.long 0x3F800000
	.long 0x08000042
	.long 0x3FADB6DB
	.long 0x0A13003C
	.long 0x3FC00000
	.long 0x0A020042
	.long 0x3F800000
	.long 0x0A010042
	.long 0x3E800000
	.long 0x0A0C0043
	.long 0x3F800000
	.long 0x0A000043
	.long 0x3FC00000
	.long 0x0A150045
	.long 0x3FC00000
	.long 0x0A1500EB
	.long 0x402AAAAB
	.long 0x0A000155
	.long 0x3FD9999A
	.long 0x0A00015A
	.long 0x3FD9999A
	.long 0x0A27015F
	.long 0x3FB33333
	.long 0x0A270160
	.long 0x3FB33333
	.long 0x0A0F0167
	.long 0x3F800000
	.long 0x0A000167
	.long 0x3FD55555
	.long 0x0A0F0168
	.long 0x3F800000
	.long 0x0A000168
	.long 0x3FD55555
	.long 0x0B1D0045
	.long 0x3FE00000
	.long 0x0B140045
	.long 0x3F800000
	.long 0x0B000045
	.long 0x40000000
	.long 0x0B0C0159
	.long 0x3F800000
	.long 0x0B000159
	.long 0x3FC00000
	.long 0x0B140164
	.long 0x3FC00000
	.long 0x0B000164
	.long 0x3FB6DB6E
	.long 0x0B140165
	.long 0x3FC00000
	.long 0x0B000165
	.long 0x3FB6DB6E
	.long 0x0B00016F
	.long 0x41200000
	.long 0x0B000174
	.long 0x41200000
	.long 0x0D10003C
	.long 0x3F800000
	.long 0x0D01003C
	.long 0xFFFFFFFF
	.long 0x0D00003C
	.long 0x3FAAAAAB
	.long 0x0D0E0045
	.long 0x3F800000
	.long 0x0D000045
	.long 0x3FB33333
	.long 0x0D1400DE
	.long 0x3FB8E38E
	.long 0x0D00016A
	.long 0x3FB851EC
	.long 0x0D00016E
	.long 0x3FB851EC
	.long 0x1016003F
	.long 0x3F4CCCCD
	.long 0x11130042
	.long 0x3F800000
	.long 0x11000042
	.long 0x3FAAAAAB
	.long 0x111800D4
	.long 0x3FC00000
	.long 0x111200D4
	.long 0x3F800000
	.long 0x110000D4
	.long 0x3FD1745D
	.long 0x110C00DD
	.long 0x3FCCCCCD
	.long 0x1100016F
	.long 0x3F99999A
	.long 0x11000159
	.long 0x3F400000
	.long 0x111700D6
	.long 0x3F99999A
	.long 0x11000155
	.long 0x3F400000
	.long 0x120C0033
	.long 0x3F800000
	.long 0x12000033
	.long 0x40000000
	.long 0x120C0035
	.long 0x3F800000
	.long 0x12000035
	.long 0x40000000
	.long 0x120C0037
	.long 0x3F800000
	.long 0x12000037
	.long 0x40000000
	.long 0x12080038
	.long 0x3F800000
	.long 0x12000038
	.long 0x3FEAAAAB
	.long 0x12030162
	.long 0x40000000
	.long 0x150E0039
	.long 0x3F800000
	.long 0x15000039
	.long 0x3FE00000
	.long 0x150A003F
	.long 0x3F800000
	.long 0x1501003F
	.long 0xFFFFFFFF
	.long 0x1500003F
	.long 0x40000000
	.long 0x150E0042
	.long 0x3F800000
	.long 0x15000042
	.long 0x40000000
	.long 0x151400EA
	.long 0x3FC5D174
	.long 0x1500015A
	.long 0x3FAAAAAB
	.long 0x1500015D
	.long 0x3FAAAAAB
	.long 0x151B015E
	.long 0x3F800000
	.long 0x1500015E
	.long 0x3FACCCCD
	.long 0x151B0161
	.long 0x3F800000
	.long 0x15000161
	.long 0x3FACCCCD
	.long 0x16160042
	.long 0x3FF33333
	.long 0x170D0045
	.long 0x3F9C71C7
	.long 0x1810003C
	.long 0x3F800000
	.long 0x1801003C
	.long 0xFFFFFFFF
	.long 0x1800003C
	.long 0x3FCCCCCD
	.long 0x180A0042
	.long 0x3F800000
	.long 0x18000042
	.long 0x40000000
	.long 0x180E0045
	.long 0x3F800000
	.long 0x18000045
	.long 0x3FE00000
	.long 0x1800016A
	.long 0x3FF8E38E
	.long 0x1800016E
	.long 0x3FF8E38E
	.long 0x180E00DE
	.long 0x3FA00000
	.long 0x191400EB
	.long 0x40000000
	.long 0x19080160
	.long 0x3FC00000
	.long 0x19120038
	.long 0x3ECCCCCD
	.long 0x19030038
	.long 0x3F400000
	.long 0x19010038
	.long 0x3E000000
	.long 0x00000000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0xBB610014
	.long 0x60000000
	.long 0x00000000
	.long -1

StageExpansion_Off:
	.long 0x043E52F4
	.long 0x80202C24
	.long 0x041FCFE8
	.long 0x480003E5
	.long 0x041CD638
	.long 0x48002179
	.long 0x041CD640
	.long 0x48000999
	.long 0x0445C388
	.long 0xE70000B0
	.long 0x0416E800
	.long 0x3C608047
	.long 0x042021DC
	.long 0x38A00004
	.long 0x043E7970
	.long 0x802171D4
	.long 0x04217230
	.long 0x38000000
	.long 0x043E79AC
	.long 0x802174EC
	.long 0x0421819C
	.long 0x4BFAFF9D
	.long 0x0421470C
	.long 0x4BFAC9AD
	.long 0x0421508C
	.long 0x480002CD
	.long 0x041EFE28
	.long 0x60000000
	.long 0x041F015C
	.long 0x60000000
	.long 0x041F01F8
	.long 0x60000000
	.long 0x041F2608
	.long 0x4BE3E83D
	.long 0x041E3D6C
	.long 0x4BE7435D
	.long 0x041E3D7C
	.long 0x4BE7434D
	.long 0x041E379C
	.long 0x48000059
	.long 0x041E3D24
	.long 0x4BFE42D5
	.long 0x041FF6FC
	.long 0x48001E8D
	.long 0x041FF7E0
	.long 0x4BFC8959
	.long 0x043E4E70
	.long 0x801FF924
	.long 0x041FF5E8
	.long 0x4BFC8B51
	.long 0x041FF62C
	.long 0x3C608020
	.long 0x041FFADC
	.long 0x7C0802A6
	.long -1
StageExpansion_On:
	.long 0x043E52F4
	.long 0x80202C48
	.long 0x041FCFE8
	.long 0x60000000
	.long 0x041CD638
	.long 0x60000000
	.long 0x041CD640
	.long 0x60000000
	.long 0x0445C388
	.long 0xE7E33BB5
	.long 0xC216E800
	.long 0x000003F4
	.long 0x48000089
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x4800041D
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48001C59
	.long 0x48001E1D
	.long 0x48001A6D
	.long 0x48000111
	.long 0x48000BE1
	.long 0x48000001
	.long 0x48000001
	.long 0x4800123D
	.long 0x48000E95
	.long 0x48000471
	.long 0x48001429
	.long 0x48001651
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x480017A1
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x7C6802A6
	.long 0x808D9348
	.long 0x2C040020
	.long 0x418100AC
	.long 0x1C840004
	.long 0x7C832214
	.long 0x80A40000
	.long 0x54A501BA
	.long 0x2C050000
	.long 0x41820094
	.long 0x7CA42A14
	.long 0x3CC08049
	.long 0x60C6EE10
	.long 0x80C60000
	.long 0x80C60020
	.long 0x38C6FFE0
	.long 0x80650000
	.long 0x80850004
	.long 0x7C600774
	.long 0x2C00FFFF
	.long 0x41820064
	.long 0x5460463E
	.long 0x2C0000CC
	.long 0x41820038
	.long 0x2C0000CD
	.long 0x41820008
	.long 0x4800003C
	.long 0x5463023E
	.long 0x80E50008
	.long 0x2C040000
	.long 0x41820014
	.long 0x3884FFFC
	.long 0x7D061A14
	.long 0x7CE8212E
	.long 0x4BFFFFEC
	.long 0x38A5000C
	.long 0x4BFFFFB0
	.long 0x5463023E
	.long 0x7C843214
	.long 0x38840020
	.long 0x48000004
	.long 0x7C633214
	.long 0x90830000
	.long 0x38A50008
	.long 0x4BFFFF90
	.long 0x48000004
	.long 0x48001E58
	.long 0x0001A68C
	.long 0x00000000
	.long 0x0001A6E8
	.long 0x3FC00000
	.long 0x0001A6EC
	.long 0x40000000
	.long 0x0001A70C
	.long 0x00000000
	.long 0x0001A7CC
	.long 0x00000000
	.long 0x0001A828
	.long 0x3FD9999A
	.long 0x0001A834
	.long 0x4038BFB1
	.long 0x0001AA28
	.long 0x3F170A3D
	.long 0x0002C898
	.long 0xC2960000
	.long 0x0002C89C
	.long 0x43160000
	.long 0x0002CB54
	.long 0xC1700000
	.long 0x0002D4DC
	.long 0xC1A00000
	.long 0x0002D554
	.long 0xC2BE0000
	.long 0x00034574
	.long 0x4038BFB1
	.long 0x00036F58
	.long 0xC3FA0000
	.long 0x0003A2C8
	.long 0xC27D6704
	.long 0x0003A2CC
	.long 0xC1970B44
	.long 0x0003A2D0
	.long 0xC27D6704
	.long 0x0003A2D4
	.long 0xC1970B44
	.long 0x0003A2D8
	.long 0xC286CF28
	.long 0x0003A2E0
	.long 0xC2659E4F
	.long 0x0003A2E8
	.long 0xC2710000
	.long 0x0003A2EC
	.long 0xC1C96595
	.long 0x0003A2F0
	.long 0x428D9ADB
	.long 0x0003A2F4
	.long 0xC1970B44
	.long 0x0003A2F8
	.long 0x428D9ADB
	.long 0x0003A2FC
	.long 0xC1970B44
	.long 0x0003A300
	.long 0x42876759
	.long 0x0003A304
	.long 0xC1C96595
	.long 0x0003A308
	.long 0x4211BDBF
	.long 0x0003A30C
	.long 0xC161EB85
	.long 0x0003A310
	.long 0xC1DB746E
	.long 0x0003A314
	.long 0xC161EB85
	.long 0x0003A318
	.long 0x421B6AB3
	.long 0x0003A31C
	.long 0xC1C96595
	.long 0x0003A320
	.long 0xC1E9D5EA
	.long 0x0003A324
	.long 0xC1C96595
	.long 0x0003A328
	.long 0x43FA0000
	.long 0x0003A32C
	.long 0x43FA0000
	.long 0x0003A330
	.long 0xC2659E4F
	.long 0x0003A334
	.long 0x00000000
	.long 0x0003A338
	.long 0x4281B681
	.long 0x0003A33C
	.long 0x00000000
	.long 0x0003A340
	.long 0x43FA0000
	.long 0x0003A344
	.long 0x43FA0000
	.long 0x0003A348
	.long 0x43FA0000
	.long 0x0003A34C
	.long 0x43FA0000
	.long 0x0003A350
	.long 0x4281B681
	.long 0x0003A354
	.long 0x00000000
	.long 0x0003A358
	.long 0x4295B681
	.long 0x0003A35C
	.long 0x00000000
	.long 0x0003A360
	.long 0x43FA0000
	.long 0x0003A364
	.long 0x43FA0000
	.long 0x0003A368
	.long 0xC18CD4FE
	.long 0x0003A370
	.long 0x41C872B0
	.long 0x0003A37C
	.long 0x00100001
	.long 0x0003A38C
	.long 0x00000002
	.long 0x0003A394
	.long 0x00010004
	.long 0x0003A39C
	.long 0x0001000D
	.long 0x0003A408
	.long 0x000F000F
	.long 0x0003A40C
	.long 0xFFFFFFFF
	.long 0x0003A41C
	.long 0xFFFFFFFF
	.long 0x0003A448
	.long 0x00120005
	.long 0x0003A44C
	.long 0x00020008
	.long 0x0003A458
	.long 0x000F000F
	.long 0x0003A45C
	.long 0xFFFFFFFF
	.long 0x0003A468
	.long 0x00130013
	.long 0x0003A46C
	.long 0xFFFFFFFF
	.long 0x0003A4A8
	.long 0x000C000C
	.long 0x0003A4AC
	.long 0xFFFFFFFF
	.long 0x0003A4B8
	.long 0x00100010
	.long 0x0003A4BC
	.long 0xFFFFFFFF
	.long 0x0003A4C8
	.long 0x00000003
	.long 0x0003A4DC
	.long 0xC28C0000
	.long 0x0003A4E0
	.long 0xC1F00000
	.long 0x0003A4E4
	.long 0x42980000
	.long 0x00042268
	.long 0x0000006E
	.long 0x00042270
	.long 0xFFFFFFF6
	.long 0x00042278
	.long 0x3CCCCCCD
	.long 0x000424C4
	.long 0xAEA8A2FF
	.long 0x00042690
	.long 0x42F68404
	.long 0x000426D0
	.long 0xC2700000
	.long 0x00042710
	.long 0x433C0000
	.long 0x0004274C
	.long 0x43630000
	.long 0x00042750
	.long 0xC2E40000
	.long 0x0004298C
	.long 0xC25C0000
	.long 0x00042990
	.long 0x40A00000
	.long 0x000429CC
	.long 0x4279999A
	.long 0x000429D0
	.long 0x40A00000
	.long 0x00042A0C
	.long 0x41EF999A
	.long 0x00042A4C
	.long 0xC1B40000
	.long 0x00032558
	.long 0xC3480000
	.long 0x0004233C
	.long 0xC3480000
	.long 0xFFFFFFFF
	.long 0x0002ED18
	.long 0xC485C001
	.long 0x0002ED58
	.long 0xC45819A5
	.long 0x0008B7B4
	.long 0x42632666
	.long 0x0008B7BC
	.long 0x42584F5C
	.long 0x0008B7C0
	.long 0x41000000
	.long 0x0008B7C4
	.long 0x43286D71
	.long 0x0008B7CC
	.long 0x42584F5C
	.long 0x0008B7D0
	.long 0xC1000000
	.long 0x0008B7D4
	.long 0x43286D71
	.long 0x0008B7EC
	.long 0x42632666
	.long 0x0008B7F4
	.long 0x4289799A
	.long 0x0008B7FC
	.long 0x4285C3D7
	.long 0x0008B804
	.long 0x4285C3D7
	.long 0x0008B80C
	.long 0x4289799A
	.long 0xCC024EDC
	.long 0x00025A78
	.long 0x0001AF3C
	.long 0x00000000
	.long 0xCC01F03C
	.long 0x0001FDD8
	.long 0xFFFFFFFF
	.long 0x00023BE4
	.long 0x00000000
	.long 0x00023D04
	.long 0x00000000
	.long 0x00023D64
	.long 0x00000000
	.long 0x00023F64
	.long 0x00000000
	.long 0x000241A4
	.long 0x00000000
	.long 0x0001E2E4
	.long 0x00000000
	.long 0x0001E524
	.long 0x00000000
	.long 0x0001E764
	.long 0x00000000
	.long 0x0001E944
	.long 0x00000000
	.long 0x0001FD64
	.long 0x00000000
	.long 0x0001FF24
	.long 0x00000000
	.long 0x00020104
	.long 0x00000000
	.long 0x00020244
	.long 0x00000000
	.long 0x00020404
	.long 0x00000000
	.long 0x000205E4
	.long 0x00000000
	.long 0x00020784
	.long 0x00000000
	.long 0x00020AA4
	.long 0x00000000
	.long 0x00020E24
	.long 0x00000000
	.long 0x00020FC4
	.long 0x00000000
	.long 0x000212E4
	.long 0x00000000
	.long 0x00021664
	.long 0x00000000
	.long 0x00021744
	.long 0x00000000
	.long 0x00021664
	.long 0x00000000
	.long 0x0002E6EC
	.long 0x00000000
	.long 0x0002E75C
	.long 0x43000000
	.long 0x0002E998
	.long 0x46825FBE
	.long 0x0002E9D8
	.long 0x00000000
	.long 0x0002EA54
	.long 0x00000000
	.long 0x0002EA58
	.long 0xC3000000
	.long 0x0002EA5C
	.long 0x00000000
	.long 0x0002EB58
	.long 0xC33FDCD0
	.long 0x0002EB94
	.long 0x00000000
	.long 0x0002EB98
	.long 0x00000000
	.long 0x0002EB9C
	.long 0x00000000
	.long 0x0002EBD4
	.long 0x00000000
	.long 0x0002EBD8
	.long 0x00000000
	.long 0x0002EBDC
	.long 0x00000000
	.long 0x0002EC14
	.long 0x00000000
	.long 0x0002EC18
	.long 0x00000000
	.long 0x0002EC1C
	.long 0x00000000
	.long 0x0002EC54
	.long 0xC321D0BD
	.long 0x0002EC58
	.long 0x419C17BD
	.long 0x0002EC5C
	.long 0xBFAFE771
	.long 0x0002ED5C
	.long 0xC122BB88
	.long 0x0002ED9C
	.long 0xC122BB88
	.long 0x0002EDDC
	.long 0xC122BB88
	.long 0x0002EE14
	.long 0xC60637BD
	.long 0x000306F4
	.long 0x00000000
	.long 0x000306F8
	.long 0xC3000000
	.long 0x000306FC
	.long 0x00000000
	.long 0x000307F4
	.long 0x00000000
	.long 0x000307F8
	.long 0xC3000000
	.long 0x000307FC
	.long 0x00000000
	.long 0x00030834
	.long 0x00000000
	.long 0x00030838
	.long 0xC3000000
	.long 0x0003083C
	.long 0x00000000
	.long 0x00030874
	.long 0x00000000
	.long 0x00030878
	.long 0xC3000000
	.long 0x0003087C
	.long 0x00000000
	.long 0x000308B4
	.long 0xC218A6E6
	.long 0x000308B8
	.long 0x3F9A29D0
	.long 0x000308BC
	.long 0x41398B84
	.long 0x000308F4
	.long 0xC26CF2D0
	.long 0x000308F8
	.long 0x3F9A29D0
	.long 0x000308FC
	.long 0x41398B84
	.long 0x00030934
	.long 0xC2A0E1A7
	.long 0x00030938
	.long 0x3F9A29D0
	.long 0x0003093C
	.long 0x41398B84
	.long 0x00030A34
	.long 0x00000000
	.long 0x00030A38
	.long 0xC2330000
	.long 0x00030A3C
	.long 0x00000000
	.long 0x00030A74
	.long 0xC15C0000
	.long 0x00030A78
	.long 0xC2330000
	.long 0x00030A7C
	.long 0x00000000
	.long 0x00030AB4
	.long 0xC12D0000
	.long 0x00030AB8
	.long 0xC2090000
	.long 0x00030ABC
	.long 0x00000000
	.long 0x00030AF4
	.long 0xC0B847B2
	.long 0x00030AF8
	.long 0xC2090000
	.long 0x00030AFC
	.long 0x00000000
	.long 0x00030B34
	.long 0x00000000
	.long 0x00030B38
	.long 0xC3000000
	.long 0x00030B3C
	.long 0x00000000
	.long 0x00030B74
	.long 0x00000000
	.long 0x00030B78
	.long 0xC3000000
	.long 0x00030B7C
	.long 0x00000000
	.long 0x00030BB4
	.long 0x00000000
	.long 0x00030BB8
	.long 0xC3000000
	.long 0x00030BBC
	.long 0x00000000
	.long 0x00036BB4
	.long 0xC1000000
	.long 0x00036BB8
	.long 0x416065B4
	.long 0x00036CE8
	.long 0x3F4CCCCD
	.long 0x0004AC40
	.long 0x00000000
	.long 0x0004AC44
	.long 0x00000000
	.long 0x0004AC48
	.long 0x00000000
	.long 0x0004AC4C
	.long 0x00000000
	.long 0x0004AC50
	.long 0x00000000
	.long 0x0004AC54
	.long 0x00000000
	.long 0x0004AC58
	.long 0x00000000
	.long 0x0004AC5C
	.long 0x00000000
	.long 0x0004AC60
	.long 0x00000000
	.long 0x0004AC64
	.long 0x00000000
	.long 0x0004AC68
	.long 0x00000000
	.long 0x0004AC6C
	.long 0x00000000
	.long 0x0004AC70
	.long 0x00000000
	.long 0x0004AC74
	.long 0x00000000
	.long 0x0004AC78
	.long 0x00000000
	.long 0x0004AC7C
	.long 0x00000000
	.long 0x0004AC80
	.long 0x00000000
	.long 0x0004AC84
	.long 0x00000000
	.long 0x0004AC88
	.long 0x00000000
	.long 0x0004AC8C
	.long 0x00000000
	.long 0x0004AC90
	.long 0x00000000
	.long 0x0004AC94
	.long 0x00000000
	.long 0x0004AC98
	.long 0x00000000
	.long 0x0004AC9C
	.long 0x00000000
	.long 0x0004ACA0
	.long 0x00000000
	.long 0x0004ACA4
	.long 0x00000000
	.long 0x0004ACA8
	.long 0x00000000
	.long 0x0004ACAC
	.long 0x00000000
	.long 0x0004ACB0
	.long 0x00000000
	.long 0x0004ACB4
	.long 0x00000000
	.long 0x0004ACB8
	.long 0x00000000
	.long 0x0004ACBC
	.long 0x00000000
	.long 0x0004ACC0
	.long 0x00000000
	.long 0x0004ACC4
	.long 0x00000000
	.long 0x0004ACC8
	.long 0x00000000
	.long 0x0004ACCC
	.long 0x00000000
	.long 0x0004ACD0
	.long 0x00000000
	.long 0x0004ACD4
	.long 0x00000000
	.long 0x0004ACD8
	.long 0x00000000
	.long 0x0004ACDC
	.long 0x00000000
	.long 0x0004ACE0
	.long 0x00000000
	.long 0x0004ACE4
	.long 0x00000000
	.long 0x0004ACE8
	.long 0x00000000
	.long 0x0004ACEC
	.long 0x00000000
	.long 0x0004ACF0
	.long 0x00000000
	.long 0x0004ACF4
	.long 0x00000000
	.long 0x0004ACF8
	.long 0xC2A40000
	.long 0x0004ACFC
	.long 0xC3240000
	.long 0x0004AD00
	.long 0xC2A40000
	.long 0x0004AD04
	.long 0x3F000000
	.long 0x0004AD08
	.long 0x42530000
	.long 0x0004AD0C
	.long 0x3F000000
	.long 0x0004AD10
	.long 0x42530000
	.long 0x0004AD14
	.long 0xC3240000
	.long 0x0004AD18
	.long 0xC2870000
	.long 0x0004AD1C
	.long 0x3F000000
	.long 0x0004AD20
	.long 0x42110000
	.long 0x0004AD24
	.long 0x3F000000
	.long 0x0004AD28
	.long 0xC1DD0000
	.long 0x0004AD2C
	.long 0xC1370000
	.long 0x0004AD30
	.long 0x41EC0000
	.long 0x0004AD34
	.long 0xC13B0000
	.long 0x0004AD38
	.long 0x00000000
	.long 0x0004AD3C
	.long 0x00000000
	.long 0x0004AD40
	.long 0x00000000
	.long 0x0004AD44
	.long 0x00000000
	.long 0x0004AD48
	.long 0x00000000
	.long 0x0004AD4C
	.long 0x00000000
	.long 0x0004AD50
	.long 0x00000000
	.long 0x0004AD54
	.long 0x00000000
	.long 0x0004AD58
	.long 0x00000000
	.long 0x0004AD5C
	.long 0x00000000
	.long 0x0004AD60
	.long 0x00000000
	.long 0x0004AD64
	.long 0x00000000
	.long 0x0004AD68
	.long 0x00000000
	.long 0x0004AD6C
	.long 0x00000000
	.long 0x0004AD70
	.long 0x00000000
	.long 0x0004AD74
	.long 0x00000000
	.long 0x0004AD78
	.long 0x00000000
	.long 0x0004AD7C
	.long 0x00000000
	.long 0x0004AD80
	.long 0x00000000
	.long 0x0004AD84
	.long 0x00000000
	.long 0x0004AD88
	.long 0x00000000
	.long 0x0004AD8C
	.long 0x00000000
	.long 0x0004AD90
	.long 0x00000000
	.long 0x0004AD94
	.long 0x00000000
	.long 0x0004AD98
	.long 0x00000000
	.long 0x0004AD9C
	.long 0x00000000
	.long 0x0004ADA0
	.long 0x00000000
	.long 0x0004ADA4
	.long 0x00000000
	.long 0x0004ADA8
	.long 0x00000000
	.long 0x0004ADAC
	.long 0x00000000
	.long 0x0004ADBC
	.long 0x00010000
	.long 0x0004AE0C
	.long 0x00010000
	.long 0x0004AE1C
	.long 0x00010000
	.long 0x0004AE6C
	.long 0x00010000
	.long 0x0004AFDC
	.long 0x00040600
	.long 0x0004B03C
	.long 0x00080600
	.long 0x0004B054
	.long 0xC43316A1
	.long 0x0004B05C
	.long 0x44720000
	.long 0x0004B07C
	.long 0xC40001B7
	.long 0x0004B084
	.long 0x444FB886
	.long 0x0004B0A4
	.long 0xC4900000
	.long 0x0004B0AC
	.long 0x44050000
	.long 0x0004B0B0
	.long 0x432FFEC6
	.long 0x0004B0CC
	.long 0xC40E8F42
	.long 0x0004B0D4
	.long 0x4416D26E
	.long 0x0004B0F4
	.long 0xC48087C8
	.long 0x0004B0FC
	.long 0x448087C8
	.long 0x0004B398
	.long 0x00000082
	.long 0x0004B3A8
	.long 0x3D99999A
	.long 0x0004B3B4
	.long 0x3F99999A
	.long 0x0004B3DC
	.long 0xC1400000
	.long 0x0004B3E0
	.long 0x42960000
	.long 0x0004B3E8
	.long 0x41500000
	.long 0x0004B478
	.long 0x0000003C
	.long 0x0004B47C
	.long 0x00000000
	.long 0x0004B480
	.long 0x00000000
	.long 0x0004B484
	.long 0x00000000
	.long 0x0004B488
	.long 0x00000000
	.long 0x0004B48C
	.long 0x00000000
	.long 0x0004B490
	.long 0x00000000
	.long 0x0004B494
	.long 0x00000000
	.long 0x0004B498
	.long 0x00000000
	.long 0x0004B4A0
	.long 0x7F7F012C
	.long 0x0004B73C
	.long 0xC1000000
	.long 0x0004B778
	.long 0xC16A0000
	.long 0x0004B7B8
	.long 0xC32CFFFE
	.long 0x0004B7BC
	.long 0x43020000
	.long 0x0004B7F8
	.long 0x431CFFFE
	.long 0x0004B7FC
	.long 0xC24CE2D2
	.long 0x0004B838
	.long 0xC35F999C
	.long 0x0004B878
	.long 0x434F999C
	.long 0x0004B87C
	.long 0xC2CBC2D1
	.long 0x0004BAB8
	.long 0xC28D0000
	.long 0x0004BABC
	.long 0x41500000
	.long 0x0004BAF8
	.long 0x42250000
	.long 0x0004BAFC
	.long 0x41500000
	.long 0x0004BB38
	.long 0x41800000
	.long 0x0004BB3C
	.long 0x41500000
	.long 0x0004BB78
	.long 0xC2350000
	.long 0x0004BB7C
	.long 0x41500000
	.long 0x0004BBBC
	.long 0x42600000
	.long 0xFFFFFFFF
	.long 0x000026D8
	.long 0xFE2A0191
	.long 0x00002738
	.long 0x01900191
	.long 0x000028F0
	.long 0x034CFE79
	.long 0x000028FC
	.long 0x0392FE79
	.long 0x00002908
	.long 0x034CFE79
	.long 0x0000298C
	.long 0x03520137
	.long 0x000029F8
	.long 0x04780137
	.long 0x00002A80
	.long 0x0073FFC0
	.long 0x00002A9C
	.long 0x00080073
	.long 0x00002AE4
	.long 0x00560073
	.long 0x00012514
	.long 0x41F00000
	.long 0x00012518
	.long 0xC4900000
	.long 0x0001251C
	.long 0xC0600000
	.long 0x00012558
	.long 0x40FBC9BA
	.long 0x00012598
	.long 0xC40BC9BA
	.long 0x000125D4
	.long 0x42A79997
	.long 0x000125DC
	.long 0xC1B3332B
	.long 0x00012658
	.long 0xC24A3021
	.long 0x0006B494
	.long 0xC2E889C7
	.long 0x0006B498
	.long 0xC000645A
	.long 0x0006B49C
	.long 0xC2E889C7
	.long 0x0006B4A0
	.long 0x412A6BBA
	.long 0x0006B4A4
	.long 0x420A76C9
	.long 0x0006B4A8
	.long 0x412A6BBA
	.long 0x0006B4AC
	.long 0x420A76C9
	.long 0x0006B4B0
	.long 0xC000645A
	.long 0x0006B4B4
	.long 0x00000000
	.long 0x0006B4B8
	.long 0x00000000
	.long 0x0006B4BC
	.long 0x00000000
	.long 0x0006B4C0
	.long 0x00000000
	.long 0x0006B4C4
	.long 0x00000000
	.long 0x0006B4C8
	.long 0x00000000
	.long 0x0006B4CC
	.long 0x00000000
	.long 0x0006B4D0
	.long 0x00000000
	.long 0x0006B4D4
	.long 0x00000000
	.long 0x0006B4D8
	.long 0x00000000
	.long 0x0006B4DC
	.long 0x00000000
	.long 0x0006B4E0
	.long 0x00000000
	.long 0x0006B4E4
	.long 0x00000000
	.long 0x0006B4E8
	.long 0x00000000
	.long 0x0006B4EC
	.long 0x00000000
	.long 0x0006B4F0
	.long 0x00000000
	.long 0x0006B9A8
	.long 0xC3EAB611
	.long 0x0006B9B0
	.long 0x43F0DAEE
	.long 0x0006B9B4
	.long 0x4350CE70
	.long 0x0006B9D0
	.long 0xC335B405
	.long 0x0006B9D8
	.long 0x4335B405
	.long 0x0006B9DC
	.long 0x432F084B
	.long 0x0006B9F8
	.long 0xC3C2FE9E
	.long 0x0006BA00
	.long 0x4367DBA6
	.long 0x0006BA04
	.long 0x432EE7BB
	.long 0x0006BA20
	.long 0xC3D31412
	.long 0x0006BA28
	.long 0x43D31412
	.long 0x0006BA2C
	.long 0x436CCCCD
	.long 0x0006BA48
	.long 0xC3D31412
	.long 0x0006BA50
	.long 0x43D31412
	.long 0x0006BA54
	.long 0x43580000
	.long 0x0006BA70
	.long 0xC37E7C1C
	.long 0x0006BA78
	.long 0x437E7C1C
	.long 0x0006BA7C
	.long 0x43DC0000
	.long 0x0006BA98
	.long 0xC357A162
	.long 0x0006BAA0
	.long 0x43F2F1AA
	.long 0x0006BAA4
	.long 0x435AB5DD
	.long 0x0006BAC0
	.long 0xC3F889C7
	.long 0x0006BAC8
	.long 0x439E76C9
	.long 0x0006BACC
	.long 0x4335F41F
	.long 0x000766D8
	.long 0x42CD0000
	.long 0x000766DC
	.long 0x42CD0000
	.long 0x000766E0
	.long 0x42CD0000
	.long 0x000766E4
	.long 0xC2F30000
	.long 0x000766E8
	.long 0xC2F30000
	.long 0x0008E8F0
	.long 0xC3840000
	.long 0x0008E930
	.long 0x435A0000
	.long 0x0008E970
	.long 0xC3A60000
	.long 0x0008E9B0
	.long 0x438C0000
	.long 0x0008EBF4
	.long 0x41920000
	.long 0x0008EC30
	.long 0x42BCCCCD
	.long 0x0008EC70
	.long 0xC284000F
	.long 0x0008EC74
	.long 0x41920004
	.long 0x0008ECB0
	.long 0x00000000
	.long 0x0008ECB4
	.long 0x41920000
	.long 0x0008ECF4
	.long 0x425C0004
	.long 0x00012548
	.long 0x3FD9999A
	.long 0x00012554
	.long 0x41200000
	.long 0x00012648
	.long 0x3F3AE148
	.long 0x00012654
	.long 0x40800000
	.long 0x00012618
	.long 0xC3480000
	.long 0x000125D8
	.long 0xC3480000
	.long 0xFFFFFFFF
	.long 0x00020DEC
	.long 0x00000000
	.long 0x00020E2C
	.long 0x00000000
	.long 0x00020E54
	.long 0xC2AB0000
	.long 0x00020E58
	.long 0x00200000
	.long 0x00020E6C
	.long 0x00000000
	.long 0x00020E94
	.long 0x42AB0000
	.long 0x00020E98
	.long 0x00200000
	.long 0x00020F14
	.long 0xC6820000
	.long 0x00020F18
	.long 0xC6700000
	.long 0x00020F54
	.long 0xC6AA0000
	.long 0x00020F58
	.long 0xC6700000
	.long 0x00020F94
	.long 0xC6960000
	.long 0x00020F98
	.long 0xC0700000
	.long 0x00020FD4
	.long 0xC6820000
	.long 0x00020FD8
	.long 0xC0700000
	.long 0x00021014
	.long 0xC6820000
	.long 0x00021018
	.long 0xC0C80000
	.long 0x00021054
	.long 0xC6960000
	.long 0x00021058
	.long 0xC0C80000
	.long 0x00021094
	.long 0xC6AA0000
	.long 0x00021098
	.long 0xC0C80000
	.long 0x000210D4
	.long 0x46820000
	.long 0x000210D8
	.long 0x46C80000
	.long 0x00021114
	.long 0x46960000
	.long 0x00021118
	.long 0x46C80000
	.long 0x00021154
	.long 0x40AA0000
	.long 0x00021158
	.long 0x40C80000
	.long 0x00021194
	.long 0x40AA0000
	.long 0x00021198
	.long 0x40700000
	.long 0x000211D4
	.long 0xC6960000
	.long 0x000211D8
	.long 0xC0700000
	.long 0x00021214
	.long 0x40960000
	.long 0x00021218
	.long 0x40700000
	.long 0x00021254
	.long 0x40820000
	.long 0x00021258
	.long 0x40700000
	.long 0x000216D4
	.long 0xC2740000
	.long 0x000216D8
	.long 0x00000000
	.long 0x00021714
	.long 0x42740000
	.long 0x00021718
	.long 0x00000000
	.long 0x00056434
	.long 0x00000000
	.long 0x00056438
	.long 0x46000000
	.long 0x0005643C
	.long 0x00000000
	.long 0x00056440
	.long 0x46000000
	.long 0x00056444
	.long 0x00000000
	.long 0x00056448
	.long 0x46000000
	.long 0x0005644C
	.long 0x00000000
	.long 0x00056450
	.long 0x46000000
	.long 0x00056454
	.long 0x00000000
	.long 0x00056458
	.long 0x46000000
	.long 0x0005645C
	.long 0x00000000
	.long 0x00056460
	.long 0x46000000
	.long 0x00056464
	.long 0x00000000
	.long 0x00056468
	.long 0x46000000
	.long 0x0005646C
	.long 0x00000000
	.long 0x00056470
	.long 0x46000000
	.long 0x00056474
	.long 0x00000000
	.long 0x00056478
	.long 0x46000000
	.long 0x0005647C
	.long 0x00000000
	.long 0x00056480
	.long 0x46000000
	.long 0x00056484
	.long 0x00000000
	.long 0x00056488
	.long 0x46000000
	.long 0x0005648C
	.long 0x00000000
	.long 0x00056490
	.long 0x46000000
	.long 0x00056494
	.long 0x00000000
	.long 0x00056498
	.long 0x46000000
	.long 0x0005649C
	.long 0x00000000
	.long 0x000564A0
	.long 0x46000000
	.long 0x000564A4
	.long 0x00000000
	.long 0x000564A8
	.long 0x46000000
	.long 0x000564AC
	.long 0x00000000
	.long 0x000564B0
	.long 0x46000000
	.long 0x000564B4
	.long 0x00000000
	.long 0x000564B8
	.long 0x46000000
	.long 0x000564BC
	.long 0x00000000
	.long 0x000564C0
	.long 0x46000000
	.long 0x000564C4
	.long 0x00000000
	.long 0x000564C8
	.long 0x46000000
	.long 0x000564CC
	.long 0x00000000
	.long 0x000564D0
	.long 0x46000000
	.long 0x000564D4
	.long 0x00000000
	.long 0x000564D8
	.long 0x46000000
	.long 0x000564DC
	.long 0x00000000
	.long 0x000564E0
	.long 0x46000000
	.long 0x000564E4
	.long 0xC2DB0000
	.long 0x000564EC
	.long 0xC2A00000
	.long 0x00056504
	.long 0xC2DF0000
	.long 0x00056508
	.long 0x00000000
	.long 0x0005650C
	.long 0x42DE0000
	.long 0x00056514
	.long 0x42D40000
	.long 0x0005651C
	.long 0x42DE0000
	.long 0x00056520
	.long 0x00000000
	.long 0x00056534
	.long 0x42D40000
	.long 0x0005653C
	.long 0xC2DB0000
	.long 0x00056544
	.long 0xC2DF0000
	.long 0x0005654C
	.long 0xC2CB0000
	.long 0x00056554
	.long 0x42C40000
	.long 0x0005655C
	.long 0x00000000
	.long 0x00056560
	.long 0x46000000
	.long 0x00056564
	.long 0x00000000
	.long 0x00056568
	.long 0x46000000
	.long 0x0005656C
	.long 0x42990000
	.long 0x00058FE0
	.long 0x7F7F0320
	.long 0x00058FE4
	.long 0x7F7F0708
	.long 0x00058FE8
	.long 0x0000C28F
	.long 0x00059038
	.long 0x000404A3
	.long 0x0005A5FC
	.long 0x43A58000
	.long 0x0005A63C
	.long 0xC3A50000
	.long 0x0005A640
	.long 0x437A0000
	.long 0x0005A8BC
	.long 0xC22AAAAB
	.long 0x0005A8C0
	.long 0x42200000
	.long 0x0005A8FC
	.long 0x422AAAAB
	.long 0x0005A900
	.long 0x42200000
	.long 0x0005A93C
	.long 0x42B15555
	.long 0x0005A940
	.long 0x40A00000
	.long 0x0005A97C
	.long 0xC2B15555
	.long 0x0005A980
	.long 0x40A00000
	.long 0xFFFFFFFF
	.long 0x0001458C
	.long 0x80000000
	.long 0x000147EC
	.long 0x80000000
	.long 0x000148EC
	.long 0x80000000
	.long 0x00014AAC
	.long 0x80000000
	.long 0x00014BAC
	.long 0x80000000
	.long 0x00014D4C
	.long 0x80000000
	.long 0x00014F0C
	.long 0x80000000
	.long 0x0001500C
	.long 0x80000000
	.long 0x000151AC
	.long 0x80000000
	.long 0x00025134
	.long 0x42AB999A
	.long 0x00025138
	.long 0xC2200000
	.long 0x0002513C
	.long 0xC3480000
	.long 0x00025338
	.long 0x42200000
	.long 0x0002533C
	.long 0x43480000
	.long 0x00025328
	.long 0x3FA8F5C3
	.long 0x00025174
	.long 0xC3250000
	.long 0x00025178
	.long 0x428C0000
	.long 0x0002517C
	.long 0x42F78000
	.long 0x000251B4
	.long 0xC3070000
	.long 0x000251B8
	.long 0x42AA0000
	.long 0x000251BC
	.long 0x42C80000
	.long 0x000251F4
	.long 0xC2A00000
	.long 0x000251F8
	.long 0x42960000
	.long 0x000251FC
	.long 0x42B80000
	.long 0x00014144
	.long 0x00000000
	.long 0x000140C4
	.long 0x00000000
	.long 0x00014044
	.long 0x00000000
	.long 0xCD02B888
	.long 0x000001B0
	.long 0xC47A0000
	.long 0x0002B8D8
	.long 0xC2860000
	.long 0x0002B8DC
	.long 0x38D1B717
	.long 0x0002B8F8
	.long 0xC1F00000
	.long 0x0002B8FC
	.long 0x38D1B717
	.long 0x0002B910
	.long 0xC1A00000
	.long 0x0002B914
	.long 0x38D1B717
	.long 0x0002B900
	.long 0x00000000
	.long 0x0002B904
	.long 0x38D1B717
	.long 0x0002B908
	.long 0x41A00000
	.long 0x0002B90C
	.long 0x38D1B717
	.long 0x0002B8E0
	.long 0x41F00000
	.long 0x0002B8E4
	.long 0x38D1B717
	.long 0x0002B8E8
	.long 0x42860000
	.long 0x0002B8EC
	.long 0x38D1B717
	.long 0x0002B8F0
	.long 0x42860000
	.long 0x0002B8F4
	.long 0xC3480000
	.long 0x0002B8D0
	.long 0xC2860000
	.long 0x0002B8D4
	.long 0xC3480000
	.long 0x0002C4C4
	.long 0xC30C0000
	.long 0x0002C4C8
	.long 0x43020000
	.long 0x0002C504
	.long 0x430C0000
	.long 0x0002C508
	.long 0xC2700000
	.long 0x0002C584
	.long 0xC3340000
	.long 0x0002C544
	.long 0x43340000
	.long 0x0002C548
	.long 0xC2DC0000
	.long 0x0002C588
	.long 0x43340000
	.long 0x0002C844
	.long 0xC2340000
	.long 0x0002C848
	.long 0x40E00000
	.long 0x0002C884
	.long 0x42340000
	.long 0x0002C888
	.long 0x40E00000
	.long 0x0002C8C4
	.long 0x41C80000
	.long 0x0002C8C8
	.long 0x40E00000
	.long 0x0002C904
	.long 0xC1C80000
	.long 0x0002C908
	.long 0x40E00000
	.long 0xFFFFFFFF
	.long 0x0000C0F8
	.long 0xC60C0000
	.long 0x0000C238
	.long 0xC6340000
	.long 0x0000C278
	.long 0xC6340000
	.long 0x0000C2B8
	.long 0xC6340000
	.long 0x0000C2F8
	.long 0xC6340000
	.long 0x0000C338
	.long 0xC6340000
	.long 0x0000C378
	.long 0xC6340000
	.long 0x0000C3B8
	.long 0xC60C0000
	.long 0x0000C3F8
	.long 0xC60C0000
	.long 0x0000C438
	.long 0xC60C0000
	.long 0x0000C478
	.long 0xC60C0000
	.long 0x0000C4B8
	.long 0xC60C0000
	.long 0x0000C4F8
	.long 0xC60C0000
	.long 0x0000C5B8
	.long 0xC2720000
	.long 0x0000C664
	.long 0xC2A20000
	.long 0x0000C668
	.long 0x430D0000
	.long 0x0000C6D4
	.long 0x42A20000
	.long 0x0000C6D8
	.long 0x430D0000
	.long 0x0000C744
	.long 0x42A20000
	.long 0x0000C824
	.long 0xC2A20000
	.long 0x0000ECDC
	.long 0x00000000
	.long 0x0000ECE4
	.long 0x00000000
	.long 0x0000ECE8
	.long 0x00000000
	.long 0x0000ECEC
	.long 0x00000000
	.long 0x0000ECF4
	.long 0x00000000
	.long 0x0000ECF8
	.long 0x00000000
	.long 0x0000ECFC
	.long 0x00000000
	.long 0x0000ED04
	.long 0x00000000
	.long 0x0000ED0C
	.long 0x00000000
	.long 0x0000ED10
	.long 0x00000000
	.long 0x0000ED14
	.long 0x00000000
	.long 0x0000ED1C
	.long 0x00000000
	.long 0x0000ED20
	.long 0x00000000
	.long 0x0000ED24
	.long 0x00000000
	.long 0x0000C138
	.long 0xC3960000
	.long 0x0000C538
	.long 0xC3960000
	.long 0x0000C578
	.long 0xC3960000
	.long 0x0000C178
	.long 0xC3960000
	.long 0x0000C1B8
	.long 0xC3960000
	.long 0x0000C1F8
	.long 0xC3960000
	.long 0x0000FDAC
	.long 0x41A00000
	.long 0x00010374
	.long 0xC21C0000
	.long 0x000103B4
	.long 0x421C0000
	.long 0x000083E4
	.long 0x00000000
	.long 0x00008544
	.long 0x00000000
	.long 0x000085C4
	.long 0x00000000
	.long 0x00008824
	.long 0x00000000
	.long 0x00008984
	.long 0x00000000
	.long 0x00008A04
	.long 0x00000000
	.long 0x0000C078
	.long 0xC47A0000
	.long 0x00007BE4
	.long 0x00000000
	.long 0x00007C44
	.long 0x00000000
	.long 0x00007CA4
	.long 0x00000000
	.long 0x00007C04
	.long 0x00000000
	.long 0x00007D04
	.long 0x00000000
	.long 0x00007DE4
	.long 0x00000000
	.long 0x00007F64
	.long 0x00000000
	.long 0x00008104
	.long 0x00000000
	.long 0x00008164
	.long 0x00000000
	.long 0x00008204
	.long 0x00000000
	.long 0x000082A4
	.long 0x00000000
	.long 0x00010374
	.long 0xC2100000
	.long 0x00010378
	.long 0x40E00000
	.long 0x000103B4
	.long 0x42100000
	.long 0x000103B8
	.long 0x40E00000
	.long 0x000103F4
	.long 0x41700000
	.long 0x000103F8
	.long 0x40E00000
	.long 0x00010434
	.long 0xC1700000
	.long 0x00010438
	.long 0x40E00000
	.long 0xFFFFFFFF
	.long 0x00001560
	.long 0x31E8FEFF
	.long 0x00001568
	.long 0x03050003
	.long 0x00009DB4
	.long 0xC67F0000
	.long 0x00009E34
	.long 0x467F0000
	.long 0x00012AB4
	.long 0xC2F20000
	.long 0x00013034
	.long 0x42F20000
	.long 0x00013210
	.long 0x00000000
	.long 0x00013214
	.long 0x00000000
	.long 0x00013218
	.long 0x00000000
	.long 0x0001321C
	.long 0x00000000
	.long 0x00013220
	.long 0x00000000
	.long 0x00013224
	.long 0x00000000
	.long 0x00013228
	.long 0x00000000
	.long 0x0001322C
	.long 0x00000000
	.long 0x00013230
	.long 0x00000000
	.long 0x00013234
	.long 0x00000000
	.long 0x00013238
	.long 0x42D40000
	.long 0x00013240
	.long 0x42D40000
	.long 0x00013248
	.long 0x00000000
	.long 0x0001324C
	.long 0x00000000
	.long 0x00013250
	.long 0x00000000
	.long 0x00013254
	.long 0x00000000
	.long 0x00013258
	.long 0x00000000
	.long 0x0001325C
	.long 0x00000000
	.long 0x00013260
	.long 0x00000000
	.long 0x00013264
	.long 0x00000000
	.long 0x00013268
	.long 0x00000000
	.long 0x0001326C
	.long 0x00000000
	.long 0x00013278
	.long 0xC2D40000
	.long 0x00013280
	.long 0xC2D40000
	.long 0x00015F54
	.long 0xC3460000
	.long 0x00015F94
	.long 0x43480000
	.long 0x00015FD4
	.long 0xC3960000
	.long 0x00016014
	.long 0x43960000
	.long 0x00009DE8
	.long 0x40166666
	.long 0x00009EA8
	.long 0x40200000
	.long 0x00009E68
	.long 0x40200000
	.long 0x00016214
	.long 0xC2780000
	.long 0x00016218
	.long 0x40E00000
	.long 0x00016254
	.long 0x42780000
	.long 0x00016258
	.long 0x40E00000
	.long 0x00016294
	.long 0x42000000
	.long 0x00016298
	.long 0x40E00000
	.long 0x000162D4
	.long 0xC2000000
	.long 0x000162D8
	.long 0x40E00000
	.long 0xFFFFFFFF
	.long 0x0000C328
	.long 0x3F000000
	.long 0x0000C32C
	.long 0x3F000000
	.long 0x0000C330
	.long 0x3F000000
	.long 0x0000C338
	.long 0xC2A1E666
	.long 0x0000C33C
	.long 0x40A00000
	.long 0x00046148
	.long 0x40A00000
	.long 0x0004614C
	.long 0x40A00000
	.long 0x00046150
	.long 0x40A00000
	.long 0x00046158
	.long 0xC2700000
	.long 0x0004615C
	.long 0x41200000
	.long 0x0003DD54
	.long 0x4099999A
	.long 0x000466FC
	.long 0x43960000
	.long 0x00046704
	.long 0x43960000
	.long 0x000475CC
	.long 0x0000006A
	.long 0x000475D0
	.long 0x00000068
	.long 0x000475D4
	.long 0x00000000
	.long 0x000475D8
	.long 0x00680001
	.long 0x000475DC
	.long 0x00690001
	.long 0x000000A0
	.long 0x00000000
	.long 0x000000A4
	.long 0x00000022
	.long 0x000473E0
	.long 0x00650003
	.long 0x000473E4
	.long 0x00000000
	.long 0x000473E8
	.long 0x00680001
	.long 0x000473EC
	.long 0x00690001
	.long 0x00047404
	.long 0x007F0006
	.long 0x000473F4
	.long 0xC2B40000
	.long 0x000473F8
	.long 0xC3520000
	.long 0x000473FC
	.long 0x42B40000
	.long 0x00047400
	.long 0xC1200000
	.long 0x00046578
	.long 0x42A33333
	.long 0x0004657C
	.long 0xC1EAE0AA
	.long 0x00046580
	.long 0x42A33333
	.long 0x00046584
	.long 0xC3480000
	.long 0x00046588
	.long 0x42766666
	.long 0x0004658C
	.long 0xC1EAE0AA
	.long 0x00046590
	.long 0xC2766666
	.long 0x00046594
	.long 0xC1EAE0AA
	.long 0x00046598
	.long 0xC2A33333
	.long 0x0004659C
	.long 0xC1EAE0AA
	.long 0x000465A0
	.long 0xC2A33333
	.long 0x000465A4
	.long 0xC3480000
	.long 0x00046D58
	.long 0x00830082
	.long 0x00046D5C
	.long 0x00690067
	.long 0x00046D64
	.long 0x00010210
	.long 0x00046D68
	.long 0x0081007F
	.long 0x00046D6C
	.long 0x00670068
	.long 0x00046D74
	.long 0x00010210
	.long 0x00046D78
	.long 0x00820081
	.long 0x00046D7C
	.long 0x00650066
	.long 0x00046D84
	.long 0x00010010
	.long 0x00046D88
	.long 0x007F0080
	.long 0x00046D8C
	.long 0x0066FFFF
	.long 0x00046D94
	.long 0x00040010
	.long 0x00046D98
	.long 0x00840083
	.long 0x00046D9C
	.long 0xFFFF0065
	.long 0x00046DA4
	.long 0x00080010
	.long 0x000464C4
	.long 0x43960000
	.long 0x000464CC
	.long 0x43960000
	.long 0x000464D4
	.long 0x43960000
	.long 0x00049510
	.long 0xC3250000
	.long 0x000494D0
	.long 0x43200000
	.long 0x00049514
	.long 0xC2A00000
	.long 0x000494D4
	.long 0x42F00000
	.long 0x00047850
	.long 0x000000A0
	.long 0x00047854
	.long 0x000003E8
	.long 0x00047874
	.long 0x00000028
	.long 0x00047878
	.long 0x00000064
	.long 0x0004787C
	.long 0x000000C8
	.long 0x00049550
	.long 0x43660000
	.long 0x00049590
	.long 0xC3660000
	.long 0x00049554
	.long 0x43200000
	.long 0x00049594
	.long 0xC2C80000
	.long 0x000496D0
	.long 0xC2766666
	.long 0x000496D4
	.long 0xC1B2E0AA
	.long 0x00049710
	.long 0x42766666
	.long 0x00049714
	.long 0xC1B2E0AA
	.long 0x00049750
	.long 0x41FCCCCD
	.long 0x00049754
	.long 0xC1B2E0AA
	.long 0x00049790
	.long 0xC1FCCCCD
	.long 0x00049794
	.long 0xC1B2E0AA
	.long 0x000497D4
	.long 0x41A00000
	.long 0xFFFFFFFF
	.long 0x00039068
	.long 0x3F333333
	.long 0x0003906C
	.long 0x3F333333
	.long 0x00039070
	.long 0x3F333333
	.long 0x00039074
	.long 0x442F0000
	.long 0x00039078
	.long 0xC39A0000
	.long 0x0003907C
	.long 0xC1F00000
	.long 0x00061BE4
	.long 0x3FC90FF9
	.long 0x00061BE8
	.long 0x3FD9999A
	.long 0x00061BEC
	.long 0x40200000
	.long 0x00061BF0
	.long 0x3F8CCCCD
	.long 0x00061BF4
	.long 0x3FE66666
	.long 0x00061BF8
	.long 0xC3E88000
	.long 0x00061BFC
	.long 0x80000000
	.long 0x000750D4
	.long 0x435C0000
	.long 0x00075094
	.long 0xC35C0000
	.long 0x000750D8
	.long 0x43700000
	.long 0x00075098
	.long 0xC1900000
	.long 0x00074D48
	.long 0x00000096
	.long 0x00074D4C
	.long 0x000003E8
	.long 0x00075114
	.long 0x438C0000
	.long 0x00075154
	.long 0xC38C0000
	.long 0x00075118
	.long 0x43910000
	.long 0x00075158
	.long 0xC28C0000
	.long 0x000745CC
	.long 0xC47A0000
	.long 0x000745D0
	.long 0xC47A0000
	.long 0x000745D4
	.long 0x447A0000
	.long 0x000745D8
	.long 0x447A0000
	.long 0x00073EFC
	.long 0x00010200
	.long 0x00073840
	.long 0xC2E10000
	.long 0x00073844
	.long 0xC3D60000
	.long 0x00073848
	.long 0xC2200000
	.long 0x0007384C
	.long 0xC3D60000
	.long 0x00073850
	.long 0xC1A00000
	.long 0x00073854
	.long 0xC3D60000
	.long 0x00073858
	.long 0x41A00000
	.long 0x0007385C
	.long 0xC3D60000
	.long 0x00073860
	.long 0x42200000
	.long 0x00073864
	.long 0xC3D60000
	.long 0x00073830
	.long 0x42E10000
	.long 0x00073834
	.long 0xC3D60000
	.long 0x00073808
	.long 0x42E10000
	.long 0x0007380C
	.long 0xC3FB0000
	.long 0x00073810
	.long 0x42200000
	.long 0x00073814
	.long 0xC3FB0000
	.long 0x00073818
	.long 0x41A00000
	.long 0x0007381C
	.long 0xC3FB0000
	.long 0x00073820
	.long 0xC1A00000
	.long 0x00073824
	.long 0xC3FB0000
	.long 0x00073828
	.long 0xC2200000
	.long 0x0007382C
	.long 0xC3FB0000
	.long 0x00073838
	.long 0xC2E10000
	.long 0x0007383C
	.long 0xC3FB0000
	.long 0x0000EEFC
	.long 0xC400C000
	.long 0x0000EF00
	.long 0x42900000
	.long 0x0000EF3C
	.long 0xC3BB8000
	.long 0x0000EF40
	.long 0x42900000
	.long 0x0000EF7C
	.long 0xC3D38000
	.long 0x0000EF80
	.long 0x42900000
	.long 0x0000EFBC
	.long 0xC3EA8000
	.long 0x0000EFC0
	.long 0x42900000
	.long 0xFFFFFFFF
	.long 0x0003D6D8
	.long 0xC2C80000
	.long 0x0003D6DC
	.long 0xC3C80000
	.long 0x0003D6BC
	.long 0x3E567770
	.long 0x0003D77C
	.long 0xBE567770
	.long 0x0003D788
	.long 0x40400000
	.long 0x0003D78C
	.long 0x40400000
	.long 0x0003D790
	.long 0x40800000
	.long 0x0003D794
	.long 0x80000000
	.long 0x0003D798
	.long 0xC2A80000
	.long 0x0003D79C
	.long 0x44258000
	.long 0x00046314
	.long 0xC28C0000
	.long 0x00046318
	.long 0x41F00000
	.long 0x0004631C
	.long 0xC1500000
	.long 0x00046394
	.long 0x428C0000
	.long 0x00046398
	.long 0x41F00000
	.long 0x0004639C
	.long 0xC1500000
	.long 0x00046408
	.long 0x40400000
	.long 0x0004640C
	.long 0x40400000
	.long 0x00046410
	.long 0x40400000
	.long 0x00046414
	.long 0x00000000
	.long 0x00046418
	.long 0xC1F00000
	.long 0x0004641C
	.long 0x40A00000
	.long 0xCD049A68
	.long 0x00000210
	.long 0xC3960000
	.long 0x0004A0F0
	.long 0xC3480000
	.long 0x00049BC8
	.long 0xC2A20000
	.long 0x00049BCC
	.long 0x38D1B717
	.long 0x00049BD0
	.long 0xC2700000
	.long 0x00049BD4
	.long 0x38D1B717
	.long 0x00049C58
	.long 0x42700000
	.long 0x00049C5C
	.long 0x38D1B717
	.long 0x00049BD8
	.long 0x42A20000
	.long 0x00049BDC
	.long 0x38D1B717
	.long 0x00049BC0
	.long 0xC2A20000
	.long 0x00049BC4
	.long 0xC3480000
	.long 0x00049BE0
	.long 0x42A20000
	.long 0x00049BE4
	.long 0xC3480000
	.long 0x0004DED8
	.long 0xC3160000
	.long 0x0004DEDC
	.long 0x43200000
	.long 0x0004DF18
	.long 0x43160000
	.long 0x0004DF1C
	.long 0xC28C0000
	.long 0x0004DF58
	.long 0xC3610000
	.long 0x0004DF5C
	.long 0x43520000
	.long 0x0004DF98
	.long 0x43610000
	.long 0x0004DF9C
	.long 0xC2F00000
	.long 0x0004DAEC
	.long 0x00000082
	.long 0x0004DAF0
	.long 0x000003E8
	.long 0x0004E258
	.long 0xC2700000
	.long 0x0004E25C
	.long 0x40A00000
	.long 0x0004E298
	.long 0x42700000
	.long 0x0004E29C
	.long 0x40A00000
	.long 0x0004E2D8
	.long 0x420C0000
	.long 0x0004E2DC
	.long 0x40A00000
	.long 0x0004E318
	.long 0xC20C0000
	.long 0x0004E31C
	.long 0x40A00000
	.long 0x0004E358
	.long 0x00000000
	.long 0x0004E35C
	.long 0x42480000
	.long 0xFFFFFFFF
	.long 0x0002DAC4
	.long 0x00000000
	.long 0x0002D704
	.long 0x00000000
	.long 0x0002D4E4
	.long 0x00000000
	.long 0x0002D464
	.long 0x00000000
	.long 0x0002D244
	.long 0x00000000
	.long 0x0002E358
	.long 0xC2FB0000
	.long 0x0002E35C
	.long 0xC4EEC000
	.long 0x00037BEC
	.long 0x00140010
	.long 0x00037C2C
	.long 0x00040000
	.long 0x00037C58
	.long 0x42700000
	.long 0xCD04C9FC
	.long 0x000001E0
	.long 0xC3960000
	.long 0x0004D068
	.long 0x00000000
	.long 0x0004D06C
	.long 0xC3480000
	.long 0x0004D070
	.long 0x43C80000
	.long 0x0004D074
	.long 0x43480000
	.long 0x0004CB9C
	.long 0x432F0000
	.long 0x0004CBA0
	.long 0xC18F3333
	.long 0x0004CBA4
	.long 0x43B40000
	.long 0x0004CBA8
	.long 0xC18F3333
	.long 0x0004CBAC
	.long 0x43B40000
	.long 0x0004CBB0
	.long 0xC2640000
	.long 0x0004CBB4
	.long 0x432F0000
	.long 0x0004CBB8
	.long 0xC2640000
	.long 0x0004CD38
	.long 0x00010206
	.long 0x0004D630
	.long 0x00000000
	.long 0x0004D8A4
	.long 0xC3480000
	.long 0x0004D8A8
	.long 0x43310000
	.long 0x0004D8E4
	.long 0x43480000
	.long 0x0004D8E8
	.long 0xC2920000
	.long 0x0004D924
	.long 0xC3AF0000
	.long 0x0004D928
	.long 0x43A78000
	.long 0x0004D964
	.long 0x43AF0000
	.long 0x0004D968
	.long 0xC3250000
	.long 0x0004DAE4
	.long 0xC2A00000
	.long 0x0004DAE8
	.long 0x40A00000
	.long 0x0004DB24
	.long 0x42A00000
	.long 0x0004DB28
	.long 0x40A00000
	.long 0x0004DB64
	.long 0x42200000
	.long 0x0004DB68
	.long 0x40A00000
	.long 0x0004DBA4
	.long 0xC2200000
	.long 0x0004DBA8
	.long 0x40A00000
	.long 0xFFFFFFFF
	.long 0x3C608047
	.long 0x00000000
	.long 0x042021DC
	.long 0x38A00000
	.long 0x043E7970
	.long 0x800115F4
	.long 0x04217230
	.long 0x48000118
	.long 0x043E79AC
	.long 0x00000000
	.long 0xC221819C
	.long 0x0000000C
	.long 0x38600008
	.long 0x3D808038
	.long 0x618C0580
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000011
	.long 0x7CA802A6
	.long 0x7CA328AE
	.long 0x48000010
	.long 0x4E800021
	.long 0x0001030D
	.long 0x12141516
	.long 0x7FC3F378
	.long 0x809D0014
	.long 0x3D80801C
	.long 0x618C8138
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FC3F378
	.long 0x3D80801C
	.long 0x618C2FE0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x00000000
	.long 0x0421470C
	.long 0x60000000
	.long 0x0421508C
	.long 0x60000000
	.long 0x041EFE28
	.long 0x60000000
	.long 0x041F015C
	.long 0x60000000
	.long 0x041F01F8
	.long 0x60000000
	.long 0x041F2608
	.long 0x60000000
	.long 0x041E3D6C
	.long 0x60000000
	.long 0x041E3D7C
	.long 0x60000000
	.long 0x041E379C
	.long 0x60000000
	.long 0x041E3D24
	.long 0x60000000
	.long 0x041FF6FC
	.long 0x60000000
	.long 0x041FF7E0
	.long 0x60000000
	.long 0x043E4E70
	.long 0x00000000
	.long 0x041FF5E8
	.long 0x60000000
	.long 0xC21FF62C
	.long 0x00000010
	.long 0x48000071
	.long 0x7CE802A6
	.long 0x7FC3F378
	.long 0x38800010
	.long 0x38A00002
	.long 0x38C00002
	.long 0xC0270000
	.long 0xC042BC84
	.long 0x3D80801C
	.long 0x618C7FF8
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3860000A
	.long 0x3D808005
	.long 0x618C7638
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3860000A
	.long 0x3D808005
	.long 0x618C5E9C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3860000A
	.long 0x3D808005
	.long 0x618C7424
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x4800000C
	.long 0x4E800021
	.long 0x42C80000
	.long 0x3C608020
	.long 0x00000000
	.long 0x041FFADC
	.long 0x4E800020
	.long -1

Widescreen_Off:
	.long 0x043BB05C
	.long 0x3FAAAAAA
	.long 0x0436A4A8
	.long 0xc03f0034
	.long 0x042FCFC4
	.long 0xc002e19c
	.long 0x044DDB84
	.long 0x3ecccccd
	.long 0x044DDB48
	.long 0x3dbae148
	.long 0x044DDB58
	.long 0x3e000000
	.long 0x04086B24
	.long 0x4182000c
	.long 0x04030C7C
	.long 0xa0010020
	.long 0x04030C88
	.long 0xa0010022
	.long 0x044DDB30
	.long 0x3f24d31e
	.long 0x044DDB34
	.long 0xbf24d31e
	.long 0x044DDB2C
	.long 0xc322b333
	.long 0x044DDB28
	.long 0x4322b333
	.long 0x044DDB4C
	.long 0x3dcccccd
	.long 0xFF000000
Widescreen_Standard:
	.long 0x043BB05C
	.long 0x3EB00000
	.long 0xC236A4A8
	.long 0x00000006
	.long 0xC03F0034
	.long 0x4800001D
	.long 0x7C6802A6
	.long 0xC0430000
	.long 0xC0630004
	.long 0xEC2100B2
	.long 0xEC211824
	.long 0x48000010
	.long 0x4E800021
	.long 0x40800000
	.long 0x40400000
	.long 0x00000000
	.long 0x044DDB58
	.long 0x3E4CCCCD
	.long 0x04086B24
	.long 0x60000000
	.long 0x04030C7C
	.long 0x3800004E
	.long 0x04030C88
	.long 0x38000232
	.long 0x044DDB30
	.long 0x3F666666
	.long 0x044DDB34
	.long 0xBF666666
	.long 0x044DDB2C
	.long 0xC3660000
	.long 0x044DDB28
	.long 0x43660000
	.long 0x044DDB4C
	.long 0x3D916873
	.long 0xC22FCFC4
	.long 0x00000004
	.long 0x48000011
	.long 0x7C6802A6
	.long 0xC0030000
	.long 0x4800000C
	.long 0x4E800021
	.long 0x40F00000
	.long 0x60000000
	.long 0x00000000
	.long 0x044DDB84
	.long 0x3E99999A
	.long 0xFF000000
Widescreen_True:
	.long 0x043BB05C
	.long 0x3EB00000
	.long 0xC236A4A8
	.long 0x00000006
	.long 0xC03F0034
	.long 0x4800001D
	.long 0x7C6802A6
	.long 0xC0430000
	.long 0xC0630004
	.long 0xEC2100B2
	.long 0xEC211824
	.long 0x48000010
	.long 0x4E800021
	.long 0x42B80000
	.long 0x427C0000
	.long 0x00000000
	.long 0x044DDB58
	.long 0x3E4CCCCD
	.long 0x04086B24
	.long 0x60000000
	.long 0x04030C7C
	.long 0x38000064
	.long 0x04030C88
	.long 0x3800021C
	.long 0x044DDB30
	.long 0x3F666666
	.long 0x044DDB34
	.long 0xBF666666
	.long 0x044DDB2C
	.long 0xC3660000
	.long 0x044DDB28
	.long 0x43660000
	.long 0x044DDB4C
	.long 0x3D916873
	.long 0xC22FCFC4
	.long 0x00000004
	.long 0x48000011
	.long 0x7C6802A6
	.long 0xC0030000
	.long 0x4800000C
	.long 0x4E800021
	.long 0x40F00000
	.long 0x60000000
	.long 0x00000000
	.long 0x044DDB84
	.long 0x3E99999A
	.long 0xFF000000

#endregion
#region Code Descriptions
UCF_Description:
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
Frozen_Description:
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
Spawns_Description:
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
DisableWobbling_Description:
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
Ledgegrab_Description:
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
TournamentQoL_Description:
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
FriendliesQoL_Description:
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
GameVersion_Description:
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
StageExpansion_Description:
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
Widescreen_Description:
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
#region Codes_SceneLoad
Codes_SceneLoad:
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

#Create Title
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
	bl CodeNames_ModName
  mflr  r4
	lfs	f1,ModNameX(REG_TextProp)
  lfs	f2,ModNameY(REG_TextProp)
	branchl r12,0x803a6b98
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
	load	r5,0x8037f1b0
	branchl r12,GObj_AddUserData
#Add Proc
  mr  r3,REG_GObj
  bl  Codes_SceneThink
  mflr  r4      #Function to Run
  li  r5,0      #Priority
  branchl r12, GObj_AddProc
#Copy Saved Menu Options
	addi	r3,REG_GObjData,OFST_OptionSelections
	lwz	r4, -0x77C0 (r13)
	addi r4,r4,ModOFST_ModDataStart + ModOFST_ModDataPrefs
	li	r5,ModOFST_ModDataPrefsLength
	branchl	r12,memcpy

#CREATE DESCRIPTION TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	lfs	f1,DescriptionX(REG_TextProp)
	lfs	f2,DescriptionY(REG_TextProp)
	lfs	f3,DescriptionZ(REG_TextProp)
	lfs	f4,DescriptionMaxX(REG_TextProp)
	lfs	f5,DescriptionUnk(REG_TextProp)
	branchl r12,0x803a5acc
#BACKUP STRUCT POINTER
	mr REG_TextGObj,r3
	stw	REG_TextGObj,OFST_CodeDescTextGObj(REG_GObjData)
#Init?
	mr	r3,REG_TextGObj
	li	r4,0
	branchl	r12,0x803a6368
/*
#Init?
	li	r3,16
	branchl	r12,0x803a5798
	stw	r3,0x68(REG_TextGObj)
	li	r3,16
	sth	r3,0x6E(REG_TextGObj)
*/
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
#Save Menu Options
	lwz	r3, -0x77C0 (r13)
	addi r3,r3,ModOFST_ModDataStart + ModOFST_ModDataPrefs
	addi	r4,REG_GObjData,OFST_OptionSelections
	li	r5,ModOFST_ModDataPrefsLength
	branchl	r12,memcpy
#Clear nametag region
	load  r3,0x8045d850
	li r4,0
	li r5,0
	ori r5,r5,0xd894
	branchl  r12,memset
#Request a memcard save
	branchl	r12,0x8001c550	#Allocate memory for something
	li	r3,0
	branchl	r12,0x8001d164	#load banner images
#Set memcard save flag
	load	r3,0x80433318
	li	r4,1
	stw	r4,0xC(r3)

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
  lfd    f2, MagicNumber (REG_TextProp)
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
  lfd    f2, MagicNumber (REG_TextProp)
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
#region Codes_CreateMenu_ChangeCodeDescription
#Get highlighted code ID
	lhz r3,OFST_ScrollAmount(REG_GObjData)
	lhz r4,OFST_CursorLocation(REG_GObjData)
	add	r3,r3,r4
#Get this codes options
	bl	CodeOptions_Order
	mflr	r4
	mulli	r3,r3,0x4
	add	r3,r3,r4
	bl	ConvertBlPointer
#Get this codes description
	addi	r3,r3,CodeOptions_CodeDescription
	bl	ConvertBlPointer
	lwz	r4,OFST_CodeDescTextGObj(REG_GObjData)
#Store to text gobj
	stw	r3,0x5C(r4)
#endregion

Codes_CreateMenu_Exit:
  restore
  blr

###############################################

ConvertBlPointer:
  lwz r4,0x0(r3)        #Load bl instruction
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
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
#Get this code's default gecko code pointer
  bl  CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  ConvertBlPointer
  addi  r3,r3,CodeOptions_GeckoCodePointers
  bl  ConvertBlPointer
  bl  ApplyGeckoCode
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
  b ApplyGeckoCode_Exit
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
#/*
#Check if progressive is enabled
  lis	r3,0xCC00
	lhz	r3,0x206E(r3)
	rlwinm.	r3,r3,0,0x1
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
  b SnapshotCode102_Exit
#*/
NoProgressive:
#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,0x801a4ce0
  bl  Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load Codes
  li  r3,CodesSceneID

SnapshotCode102_Exit:
#Store as next scene
	load	r4,0x804d68bc
	stb	r3,0x0(r4)
#request to change scenes
	branchl	r12,0x801a4b60

##########
## Exit ##
##########

#Return to the game
  restore
	branch	r12,0x80239e9c

MMLCode102_End:
blrl
#endregion
#region SnapshotCode101
.include "../../Common101.s"

SnapshotCode101_Start:
#First thing to do is relocate ALL of the exploit code to tournament mode
	bl	MMLCode101_End
	mflr	r3
	bl	MMLCode101_Start
	mflr	r4
	sub	r5,r3,r4
	load	r3,TournamentMode
	branchl	r12,memcpy

#Flush cache to ensure these instructions are up to date
  load r3,TournamentMode
	bl	MMLCode101_Start
	mflr	r4
	bl	MMLCode101_End
	mflr	r5
	sub	r4,r5,r4
  branchl r12,TRK_flush_cache

#Now run from the tournament mode code region
	branch	r12,TournamentMode

MMLCode101_Start:
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
  bl  Snap101_LagPrompt_MinorSceneStruct
  mflr  r4
  bl  Snap101_LagPrompt_SceneLoad
  mflr  r5
  bl  Snap101_InitializeMajorSceneStruct
#Init Codes major struct
  li  r3,CodesSceneID
  bl  Snap101_Codes_MinorSceneStruct
  mflr  r4
  bl  Snap101_Codes_SceneLoad
  mflr  r5
  bl  Snap101_InitializeMajorSceneStruct

#Check if key has been generated yet
	lwz	r20,OFST_Memcard(r13)
	lwz	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
	cmpwi	r3,0
	bne	Snap101_GenerateKeyEnd
#Generate Key
	lwz	r3, OFST_Rand (r13)
	lwz	r3,0x0(r3)
	stw	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
Snap101_GenerateKeyEnd:
  b Snap101_CheckProgressive

#region Snap101_PointerConvert
Snap101_PointerConvert:
  lwz r4,0x0(r3)          #Load bl instruction
  rlwinm r5,r4,8,25,29    #extract opcode bits
  cmpwi r5,0x48           #if not a bl instruction, exit
  bne Snap101_PointerConvert_Exit
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
  add r4,r4,r3
  stw r4,0x0(r3)
Snap101_PointerConvert_Exit:
  blr
#endregion
#region Snap101_InitializeMajorSceneStruct
Snap101_InitializeMajorSceneStruct:
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
Snap101_GetMajorStruct_Loop:
  lbz	r4, 0x0001 (r3)
  cmpw r4,REG_MajorScene
  beq Snap101_GetMajorStruct_Exit
  addi  r3,r3,20
  b Snap101_GetMajorStruct_Loop
Snap101_GetMajorStruct_Exit:

Snap101_InitMinorSceneStruct:
.set  REG_MinorStructParse,20
  stw REG_MinorStruct,0x10(r3)
  mr  REG_MinorStructParse,REG_MinorStruct
Snap101_InitMinorSceneStruct_Loop:
#Check if valid entry
  lbz r3,0x0(REG_MinorStructParse)
  extsb r3,r3
  cmpwi r3,-1
  beq Snap101_InitMinorSceneStruct_Exit
#Convert Pointers
  addi  r3,REG_MinorStructParse,0x4
  bl  Snap101_PointerConvert
  addi  r3,REG_MinorStructParse,0x8
  bl  Snap101_PointerConvert
  addi  REG_MinorStructParse,REG_MinorStructParse,0x18
  b Snap101_InitMinorSceneStruct_Loop
Snap101_InitMinorSceneStruct_Exit:

  restore
  blr
#endregion
#endregion

#region Codes

#region Snap101_Codes_SceneLoad
############################################

#region Snap101_Codes_SceneLoad_Data
Snap101_Codes_SceneLoad_TextProperties:
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
.set MagicNumber,0x4C
.set Next,0x54

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
.long 0x43300000,0x80000000

.set CodeAmount,10
#region Code Names Order
Snap101_CodeNames_Order:
blrl
bl  Snap101_CodeNames_UCF
bl  Snap101_CodeNames_Frozen
bl  Snap101_CodeNames_Spawns
bl  Snap101_CodeNames_Wobbling
bl  Snap101_CodeNames_Ledgegrab
bl	Snap101_CodeNames_TournamentQoL
bl	Snap101_CodeNames_FriendliesQoL
bl	Snap101_CodeNames_GameVersion
bl	Snap101_CodeNames_StageExpansion
bl	Snap101_CodeNames_Widescreen
.align 2
#endregion
#region Code Names
Snap101_CodeNames_Title:
blrl
.string "Select Codes:"
.align 2
Snap101_CodeNames_ModName:
blrl
.string "MultiMod Launcher v0.6"
.align 2
Snap101_CodeNames_UCF:
.string "UCF:"
.align 2
Snap101_CodeNames_Frozen:
.string "Frozen Stages:"
.align 2
Snap101_CodeNames_Spawns:
.string "Neutral Spawns:"
.align 2
Snap101_CodeNames_Wobbling:
.string "Disable Wobbling:"
.align 2
Snap101_CodeNames_Ledgegrab:
.string "Ledgegrab Limit:"
.align 2
Snap101_CodeNames_TournamentQoL:
.string "Tournament QoL:"
.align 2
Snap101_CodeNames_FriendliesQoL:
.string "Friendlies QoL:"
.align 2
Snap101_CodeNames_GameVersion:
.string "Game Version:"
.align 2
Snap101_CodeNames_StageExpansion:
.string "Stage Expansion:"
.align 2
Snap101_CodeNames_Widescreen:
.string "Widescreen:"
.align 2
#endregion
#region Code Options Order
Snap101_CodeOptions_Order:
blrl
bl  Snap101_CodeOptions_UCF
bl  Snap101_CodeOptions_Frozen
bl  Snap101_CodeOptions_Spawns
bl  Snap101_CodeOptions_Wobbling
bl  Snap101_CodeOptions_Ledgegrab
bl	Snap101_CodeOptions_TournamentQoL
bl  Snap101_CodeOptions_FriendliesQoL
bl	Snap101_CodeOptions_GameVersion
bl	Snap101_CodeOptions_StageExpansion
bl  Snap101_CodeOptions_Widescreen
.align 2
#endregion
#region Code Options
.set  Snap101_CodeOptions_OptionCount,0x0
.set	Snap101_CodeOptions_CodeDescription,0x4
.set  Snap101_CodeOptions_GeckoCodePointers,0x8
Snap101_CodeOptions_Wrapper:
	blrl
	.short 0x8183
	.ascii "%s"
	.short 0x8184
	.byte 0
	.align 2
Snap101_CodeOptions_UCF:
	.long 3 -1           #number of options
	bl	Snap101_UCF_Description
	bl  Snap101_UCF_Off
	bl  Snap101_UCF_On
	bl  Snap101_UCF_Stealth
	.string "Off"
	.string "On"
	.string "Stealth"
	.align 2
Snap101_CodeOptions_Frozen:
	.long 3 -1           #number of options
	bl	Snap101_Frozen_Description
	bl  Snap101_Frozen_Off
	bl  Snap101_Frozen_Stadium
	bl  Snap101_Frozen_All
	.string "Off"
	.string "Stadium Only"
	.string "All"
	.align 2
Snap101_CodeOptions_Spawns:
	.long 2 -1           #number of options
	bl	Snap101_Spawns_Description
	bl  Snap101_Spawns_Off
	bl  Snap101_Spawns_On
	.string "Off"
	.string "On"
	.align 2
Snap101_CodeOptions_Wobbling:
	.long 2 -1           #number of options
	bl	Snap101_DisableWobbling_Description
	bl  Snap101_DisableWobbling_Off
	bl  Snap101_DisableWobbling_On
	.string "Off"
	.string "On"
	.align 2
Snap101_CodeOptions_Ledgegrab:
	.long 2 -1           #number of options
	bl	Snap101_Ledgegrab_Description
	bl  Snap101_Ledgegrab_Off
	bl  Snap101_Ledgegrab_On
	.string "Off"
	.string "On"
	.align 2
Snap101_CodeOptions_TournamentQoL:
	.long 2 -1           #number of options
	bl	Snap101_TournamentQoL_Description
	bl  Snap101_TournamentQoL_Off
	bl  Snap101_TournamentQoL_On
	.string "Off"
	.string "On"
	.align 2
Snap101_CodeOptions_FriendliesQoL:
	.long 2 -1           #number of options
	bl	Snap101_FriendliesQoL_Description
	bl  Snap101_FriendliesQoL_Off
	bl  Snap101_FriendliesQoL_On
	.string "Off"
	.string "On"
	.align 2
Snap101_CodeOptions_GameVersion:
	.long 3 -1           #number of options
	bl	Snap101_GameVersion_Description
	bl  Snap101_GameVersion_NTSC
	bl  Snap101_GameVersion_101
	bl  Snap101_GameVersion_SDR
	.string "NTSC"
	.string "101"
	.string "SD Remix"
	.align 2
Snap101_CodeOptions_StageExpansion:
	.long 2 -1           #number of options
	bl	Snap101_StageExpansion_Description
	bl  Snap101_StageExpansion_Off
	bl  Snap101_StageExpansion_On
	.string "Off"
	.string "On"
	.align 2
Snap101_CodeOptions_Widescreen:
	.long 3 -1           #number of options
	bl	Snap101_Widescreen_Description
	bl  Snap101_Widescreen_Off
	bl  Snap101_Widescreen_Standard
	bl	Snap101_Widescreen_True
	.string "Off"
	.string "Standard"
	.string "True"
	.align 2
#endregion
#region Gecko Codes
Snap101_DefaultCodes:
  blrl
	.long 0xC201AE8C
	.long 0x00000004
	.long 0x2C190002
	.long 0x41800014
	.long 0x2C190008
	.long 0x4181000C
	.long 0x38000000
	.long 0x48000008
	.long 0x801F00F4
	.long 0x00000000
	.long 0xC201C7F8
	.long 0x0000000A
	.long 0x4800000D
	.long 0x7C8802A6
	.long 0x48000040
	.long 0x4E800021
	.long 0x53757065
	.long 0x7220536D
	.long 0x61736820
	.long 0x42726F73
	.long 0x2E204D65
	.long 0x6C656520
	.long 0x20202020
	.long 0x20202020
	.long 0x4D756C74
	.long 0x694D6F64
	.long 0x204C6175
	.long 0x6E636865
	.long 0x72204245
	.long 0x54410000
	.long 0x60000000
	.long 0x00000000
	.long 0x04396B98
	.long 0x4800020C
	.long 0xC222846C
	.long 0x00000028
	.long 0x3E808034
	.long 0x629449C8
	.long 0x480000F5
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000A9
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x4800005D
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x48000089
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000B5
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000AD
	.long 0x7C6802A6
	.long 0x3C808000
	.long 0x88A40007
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x4800008D
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000B4
	.long 0x4E800021
	.long 0x23232054
	.long 0x57454554
	.long 0x20412050
	.long 0x49435455
	.long 0x5245204F
	.long 0x46205448
	.long 0x4953204D
	.long 0x45535341
	.long 0x47452054
	.long 0x4F204055
	.long 0x6E636C65
	.long 0x50756E63
	.long 0x685F2023
	.long 0x23000000
	.long 0x4E800021
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23000000
	.long 0x4E800021
	.long 0x0A000000
	.long 0x4E800021
	.long 0x4D756C74
	.long 0x694D6F64
	.long 0x204C6175
	.long 0x6E636865
	.long 0x72207630
	.long 0x2E36200A
	.long 0x47616D65
	.long 0x20566572
	.long 0x73696F6E
	.long 0x3A202573
	.long 0x72256400
	.long 0x387D0000
	.long 0x60000000
	.long 0x00000000
	.long 0xC222CEB0
	.long 0x00000023
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7D1B78
	.long 0x3C600001
	.long 0x60630000
	.long 0x3D808037
	.long 0x618CE504
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C7F1B78
	.long 0x808D8840
	.long 0x3CA00001
	.long 0x60A50A30
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3D808001
	.long 0x618CB6F8
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03000B
	.long 0x4182FFEC
	.long 0x38600000
	.long 0x3C80803B
	.long 0x60849F7C
	.long 0x3CA0803B
	.long 0x60A59E94
	.long 0x3CC08043
	.long 0x60C6263C
	.long 0x3D808001
	.long 0x618CBD34
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x40820020
	.long 0x806D8840
	.long 0x80631F24
	.long 0x809F1F24
	.long 0x7C032000
	.long 0x4082000C
	.long 0x3BC00009
	.long 0x4800000C
	.long 0x3BC00002
	.long 0x48000004
	.long 0x806D8840
	.long 0x7FE4FB78
	.long 0x3CA00001
	.long 0x60A50A30
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FE3FB78
	.long 0x3D808037
	.long 0x618CE4D0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FC3F378
	.long 0x48000004
	.long 0x7FA4EB78
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x7C601B78
	.long 0x7C832378
	.long 0x00000000
	.long 0x041BF3C4
	.long 0x60000000
	.long 0x04479060
	.long 0x00000000
	.long 0x041A3BEC
	.long 0x60000000
	.long 0x041A3C10
	.long 0x38600000
	.long 0x0445B230
	.long 0x00340102
	.long 0x0445B690
	.long 0xFF000000
	.long 0x0445B6A8
	.long 0xE70000B0
	.long 0x0445B234
	.long 0x04000A00
	.long 0x0445B238
	.long 0x08010100
	.long 0x04164B14
	.long 0x38600001
	.long 0x041648F4
	.long 0x38600001
	.long 0x04164658
	.long 0x38600001
	.long 0x041644E8
	.long 0x38600001
	.long -1
	.long 0xC201AE8C
	.long 0x00000004
	.long 0x2C190002
	.long 0x41800014
	.long 0x2C190008
	.long 0x4181000C
	.long 0x38000000
	.long 0x48000008
	.long 0x801F00F4
	.long 0x00000000
	.long 0xC201C7F8
	.long 0x0000000A
	.long 0x4800000D
	.long 0x7C8802A6
	.long 0x48000040
	.long 0x4E800021
	.long 0x53757065
	.long 0x7220536D
	.long 0x61736820
	.long 0x42726F73
	.long 0x2E204D65
	.long 0x6C656520
	.long 0x20202020
	.long 0x20202020
	.long 0x4D756C74
	.long 0x694D6F64
	.long 0x204C6175
	.long 0x6E636865
	.long 0x72204245
	.long 0x54410000
	.long 0x60000000
	.long 0x00000000
	.long 0x04396B98
	.long 0x4800020C
	.long 0xC222846C
	.long 0x00000028
	.long 0x3E808034
	.long 0x629449C8
	.long 0x480000F5
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000A9
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x4800005D
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x48000089
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000B5
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000AD
	.long 0x7C6802A6
	.long 0x3C808000
	.long 0x88A40007
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x4800008D
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000B8
	.long 0x4E800021
	.long 0x23232054
	.long 0x57454554
	.long 0x20412050
	.long 0x49435455
	.long 0x5245204F
	.long 0x46205448
	.long 0x4953204D
	.long 0x45535341
	.long 0x47452054
	.long 0x4F204055
	.long 0x6E636C65
	.long 0x50756E63
	.long 0x685F2023
	.long 0x230A0000
	.long 0x4E800021
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x230A0000
	.long 0x4E800021
	.long 0x0A000000
	.long 0x4E800021
	.long 0x4D756C74
	.long 0x694D6F64
	.long 0x204C6175
	.long 0x6E636865
	.long 0x72207630
	.long 0x2E36200A
	.long 0x47616D65
	.long 0x20566572
	.long 0x73696F6E
	.long 0x3A202573
	.long 0x7225640A
	.long 0x00000000
	.long 0x387D0000
	.long 0x00000000
	.long 0xC222CEB0
	.long 0x00000023
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7D1B78
	.long 0x3C600001
	.long 0x60630000
	.long 0x3D808037
	.long 0x618CE504
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C7F1B78
	.long 0x808D8840
	.long 0x3CA00001
	.long 0x60A50A30
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3D808001
	.long 0x618CB6F8
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03000B
	.long 0x4182FFEC
	.long 0x38600000
	.long 0x3C80803B
	.long 0x60849F7C
	.long 0x3CA0803B
	.long 0x60A59E94
	.long 0x3CC08043
	.long 0x60C6263C
	.long 0x3D808001
	.long 0x618CBD34
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x40820020
	.long 0x806D8840
	.long 0x80631F24
	.long 0x809F1F24
	.long 0x7C032000
	.long 0x4082000C
	.long 0x3BC00009
	.long 0x4800000C
	.long 0x3BC00002
	.long 0x48000004
	.long 0x806D8840
	.long 0x7FE4FB78
	.long 0x3CA00001
	.long 0x60A50A30
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FE3FB78
	.long 0x3D808037
	.long 0x618CE4D0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FC3F378
	.long 0x48000004
	.long 0x7FA4EB78
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x7C601B78
	.long 0x7C832378
	.long 0x00000000
	.long 0x041BF3C4
	.long 0x60000000
	.long 0x04479060
	.long 0x00000000
	.long 0x041A3BEC
	.long 0x60000000
	.long 0x041A3C10
	.long 0x38600000
	.long 0x0445B230
	.long 0x00340102
	.long 0x0445B690
	.long 0xFF000000
	.long 0x0445B6A8
	.long 0xE70000B0
	.long 0x0445B234
	.long 0x04000A00
	.long 0x0445B238
	.long 0x08010100
	.long 0x041648EC
	.long 0x38600001
	.long 0x041646CC
	.long 0x38600001
	.long 0x04164430
	.long 0x38600001
	.long 0x041642C0
	.long 0x38600001
	.long -1

Snap101_UCF_Off:
	.long -1
Snap101_UCF_On:
	.long -1
Snap101_UCF_Stealth:
	.long -1

Snap101_Frozen_Off:
	.long -1
Snap101_Frozen_Stadium:
	.long -1
Snap101_Frozen_All:
	.long -1

Snap101_Spawns_Off:
	.long -1
Snap101_Spawns_On:
	.long -1

Snap101_DisableWobbling_Off:
	.long -1
Snap101_DisableWobbling_On:
	.long -1

Snap101_Ledgegrab_Off:
	.long -1
Snap101_Ledgegrab_On:
	.long -1

Snap101_TournamentQoL_Off:
	.long -1
Snap101_TournamentQoL_On:
	.long -1

Snap101_FriendliesQoL_Off:
	.long -1
Snap101_FriendliesQoL_On:
	.long -1

Snap101_GameVersion_NTSC:
	.long -1
Snap101_GameVersion_101:
	.long -1
Snap101_GameVersion_SDR:
	.long -1

Snap101_StageExpansion_Off:
	.long -1
Snap101_StageExpansion_On:
	.long -1

Snap101_Widescreen_Off:
	.long -1
Snap101_Widescreen_Standard:
	.long -1
Snap101_Widescreen_True:
	.long -1

#endregion
#region Code Descriptions
Snap101_UCF_Description:
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
Snap101_Frozen_Description:
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
Snap101_Spawns_Description:
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
Snap101_DisableWobbling_Description:
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
Snap101_Ledgegrab_Description:
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
Snap101_TournamentQoL_Description:
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
Snap101_FriendliesQoL_Description:
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
Snap101_GameVersion_Description:
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
Snap101_StageExpansion_Description:
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
Snap101_Widescreen_Description:
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
#region Snap101_Codes_SceneLoad
Snap101_Codes_SceneLoad:
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

Snap101_Codes_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl Snap101_Codes_SceneLoad_TextProperties
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
	bl Snap101_CodeNames_Title
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
	bl Snap101_CodeNames_ModName
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
  bl  Snap101_Codes_SceneThink
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
  bl  Snap101_Codes_CreateMenu

Snap101_Codes_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region Snap101_Codes_SceneThink
Snap101_Codes_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  Snap101_Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Code Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,Inputs_GetPlayerRapidHeldInputs
  mr  REG_Inputs,r3
#Check for movement up
  rlwinm. r0,REG_Inputs,0,0x10
  beq Snap101_Codes_SceneThink_SkipUp
#Adjust cursor
  lhz r3,OFST_CursorLocation(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_CursorLocation(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Snap101_Codes_SceneThink_UpdateMenu
#Cursor stays at top
  li  r3,0
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll up
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Snap101_Codes_SceneThink_UpdateMenu
#Scroll stays at top
  li  r3,0
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b Snap101_Codes_SceneThink_Exit
Snap101_Codes_SceneThink_SkipUp:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x20
  beq Snap101_Codes_SceneThink_AdjustOptionSelection
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
  b Snap101_Codes_SceneThink_Exit
#Check if exceeds max amount of codes per page
  cmpwi r3,MaxCodesOnscreen-1
  ble Snap101_Codes_SceneThink_UpdateMenu
#Cursor stays at bottom
  li  r3,MaxCodesOnscreen-1
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll down
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  addi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,CodeAmount-MaxCodesOnscreen
  ble Snap101_Codes_SceneThink_UpdateMenu
#Scroll stays at bottom
  li  r3,(CodeAmount-1)-(MaxCodesOnscreen-1)
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b Snap101_Codes_SceneThink_Exit
#endregion
#region Adjust Option Selection
Snap101_Codes_SceneThink_AdjustOptionSelection:
.set  REG_MaxOptions,20
.set  REG_OptionValuePtr,21
#Check for movement right
  rlwinm. r0,REG_Inputs,0,0x80
  beq Snap101_Codes_SceneThink_SkipRight
#Get amount of options for this code
  lhz r3,OFST_CursorLocation(REG_GObjData)
  lhz r4,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,r4                                #get which option this is
  bl  Snap101_CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add r3,r3,r4                                #get bl pointer to options info
  bl  Snap101_ConvertBlPointer
  lwz REG_MaxOptions,Snap101_CodeOptions_OptionCount(r3)     #get amount of options for this code
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
  ble Snap101_Codes_SceneThink_UpdateMenu
#Option stays maxxed out
  stb REG_MaxOptions,0x0(REG_OptionValuePtr)
  b Snap101_Codes_SceneThink_Exit
Snap101_Codes_SceneThink_SkipRight:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x40
  beq Snap101_Codes_SceneThink_CheckToExit
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
  bge Snap101_Codes_SceneThink_UpdateMenu
#Option stays at 0
  li  r3,0
  stb r3,0x0(REG_OptionValuePtr)
  b Snap101_Codes_SceneThink_Exit
#endregion
#region Check to Exit
Snap101_Codes_SceneThink_CheckToExit:
#Check for start input
  li  r3,4
  branchl r12,Inputs_GetPlayerInstantInputs
  rlwinm. r0,r4,0,0x1000
  beq Snap101_Codes_SceneThink_Exit
#Apply codes
  mr  r3,REG_GObjData
  bl  Snap101_ApplyAllGeckoCodes
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

  b Snap101_Codes_SceneThink_Exit
#endregion

Snap101_Codes_SceneThink_UpdateMenu:
#Redraw Menu
  mr  r3,REG_GObjData
  bl  Snap101_Codes_CreateMenu
#Play SFX
  branchl r12,SFX_PlayMenuSound_CloseOpenPort
  b Snap101_Codes_SceneThink_Exit

Snap101_Codes_SceneThink_Exit:
  restore
  blr
#endregion
#region Snap101_Codes_SceneDecide
Snap101_Codes_SceneDecide:
  backup

#Change Major
  li  r3,ExitSceneID
  branchl r12,MenuController_WriteToPendingMajor
#Leave Major
  branchl r12,MenuController_ChangeScreenMajor

Snap101_Codes_SceneDecide_Exit:
  restore
  blr
############################################
#endregion
#region Snap101_Codes_CreateMenu
Snap101_Codes_CreateMenu:
.set  REG_GObjData,31
.set  REG_TextGObj,30
.set  REG_TextProp,29

#Init
  backup
  mr  REG_GObjData,r3
  bl  Snap101_Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#Remove old text gobjs if they exist
  lwz r3,OFST_CodeNamesTextGObj(REG_GObjData)
  cmpwi r3,0
  beq Snap101_Codes_CreateMenu_SkipNameRemoval
  branchl r12,Text_RemoveText
Snap101_Codes_CreateMenu_SkipNameRemoval:
  lwz r3,OFST_CodeOptionsTextGObj(REG_GObjData)
  cmpwi r3,0
  beq Snap101_Codes_CreateMenu_SkipOptionRemoval
  branchl r12,Text_RemoveText
Snap101_Codes_CreateMenu_SkipOptionRemoval:

#region CreateTextGObjs
Snap101_Codes_CreateMenu_CreateTextGObjs:
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
#region Snap101_Codes_CreateMenu_CreateNames
Snap101_Codes_CreateMenu_CreateNamesInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
  li  REG_Count,0
Snap101_Codes_CreateMenu_CreateNamesLoop:
#Next name to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,REG_Count
#Get the string bl pointer
  bl  Snap101_CodeNames_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  Snap101_ConvertBlPointer
  mr  r4,r3
#Get Y Offset for this
  lis    r0, 0x4330
  lfd    f2, MagicNumber (REG_TextProp)
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
Snap101_Codes_CreateMenu_CreateNamesIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge Snap101_Codes_CreateMenu_CreateNameLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt Snap101_Codes_CreateMenu_CreateNamesLoop
Snap101_Codes_CreateMenu_CreateNameLoopEnd:
#endregion
#region Snap101_Codes_CreateMenu_CreateOptions
Snap101_Codes_CreateMenu_CreateOptionsInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
.set  REG_CurrentOptionID,22
.set  REG_CurrentOptionSelection,23
.set  REG_OptionStrings,24
.set  REG_StringLoopCount,25
  li  REG_Count,0
Snap101_Codes_CreateMenu_CreateOptionsLoop:
#Next option to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add REG_CurrentOptionID,r3,REG_Count
#Get the bl pointer
  mr  r3,REG_CurrentOptionID
  bl  Snap101_CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  Snap101_ConvertBlPointer
  lwz r4,Snap101_CodeOptions_OptionCount(r3)
  addi  r4,r4,1
  addi  REG_OptionStrings,r3,Snap101_CodeOptions_GeckoCodePointers  #Get pointer to gecko code pointers
  mulli r4,r4,0x4                                           #pointer length
  add REG_OptionStrings,REG_OptionStrings,r4
#Get this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx  REG_CurrentOptionSelection,r3,REG_CurrentOptionID

#Loop through strings and get the current one
  li  REG_StringLoopCount,0
Snap101_Codes_CreateMenu_CreateOptionsLoop_StringSearch:
  cmpw  REG_StringLoopCount,REG_CurrentOptionSelection
  beq Snap101_Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd
#Get next string
  mr  r3,REG_OptionStrings
  branchl r12,strlen
  add REG_OptionStrings,REG_OptionStrings,r3
  addi  REG_OptionStrings,REG_OptionStrings,1       #add 1 to skip past the 0 terminator
  addi  REG_StringLoopCount,REG_StringLoopCount,1
  b Snap101_Codes_CreateMenu_CreateOptionsLoop_StringSearch

Snap101_Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd:
#Get Y Offset for this
  lis    r0, 0x4330
  lfd    f2, MagicNumber (REG_TextProp)
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
  bl  Snap101_CodeOptions_Wrapper
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
Snap101_Codes_CreateMenu_CreateOptionsIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge Snap101_Codes_CreateMenu_CreateOptionsLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt Snap101_Codes_CreateMenu_CreateOptionsLoop
Snap101_Codes_CreateMenu_CreateOptionsLoopEnd:
#endregion
#region Snap101_Codes_CreateMenu_HighlightCursor
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
#region Snap101_Codes_CreateMenu_ChangeCodeDescription
#Get highlighted code ID
	lhz r3,OFST_ScrollAmount(REG_GObjData)
	lhz r4,OFST_CursorLocation(REG_GObjData)
	add	r3,r3,r4
#Get this codes options
	bl	Snap101_CodeOptions_Order
	mflr	r4
	mulli	r3,r3,0x4
	add	r3,r3,r4
	bl	Snap101_ConvertBlPointer
#Get this codes description
	addi	r3,r3,Snap101_CodeOptions_CodeDescription
	bl	Snap101_ConvertBlPointer
	lwz	r4,OFST_CodeDescTextGObj(REG_GObjData)
#Store to text gobj
	stw	r3,0x5C(r4)
#endregion

Snap101_Codes_CreateMenu_Exit:
  restore
  blr

###############################################

Snap101_ConvertBlPointer:
  lwz r4,0x0(r3)        #Load bl instruction
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
  add r3,r4,r3
  blr

#endregion
#region Snap101_ApplyAllGeckoCodes
Snap101_ApplyAllGeckoCodes:
.set  REG_GObjData,31
.set  REG_Count,30
.set  REG_OptionSelection,29
#Init
  backup
  mr  REG_GObjData,r3

#Default Codes
  bl  Snap101_DefaultCodes_On
  mflr  r3
  bl  Snap101_ApplyGeckoCode

#Init Loop
  li  REG_Count,0
ApplyAllGeckoSnap101_Codes_Loop:
#Load this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx REG_OptionSelection,r3,REG_Count
#Get this code's default gecko code pointer
  bl  Snap101_CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  Snap101_ConvertBlPointer
  addi  r3,r3,Snap101_CodeOptions_GeckoCodePointers
  bl  Snap101_ConvertBlPointer
  bl  Snap101_ApplyGeckoCode
#Get this code's gecko code pointers
  bl  Snap101_CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  Snap101_ConvertBlPointer
  addi  r3,r3,Snap101_CodeOptions_GeckoCodePointers
  mulli r4,REG_OptionSelection,0x4
  add  r3,r3,r4
  bl  Snap101_ConvertBlPointer
  bl  Snap101_ApplyGeckoCode

ApplyAllGeckoSnap101_Codes_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  blt ApplyAllGeckoSnap101_Codes_Loop

ApplyAllGeckoSnap101_Codes_Exit:
  restore
  blr

####################################

Snap101_ApplyGeckoCode:
.set  REG_GeckoCode,12
  mr  REG_GeckoCode,r3

Snap101_ApplyGeckoCode_Loop:
  lbz r3,0x0(REG_GeckoCode)
  cmpwi r3,0xC2
  beq Snap101_ApplyGeckoCode_C2
  cmpwi r3,0x4
  beq Snap101_ApplyGeckoCode_04
  cmpwi r3,0xFF
  beq Snap101_ApplyGeckoCode_Exit
  b Snap101_ApplyGeckoCode_Exit
Snap101_ApplyGeckoCode_C2:
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
  b Snap101_ApplyGeckoCode_Loop
Snap101_ApplyGeckoCode_04:
  lwz r3,0x0(REG_GeckoCode)
  rlwinm r3,r3,0,8,31
  oris  r3,r3,0x8000
  lwz r4,0x4(REG_GeckoCode)
  stw r4,0x0(r3)
  addi REG_GeckoCode,REG_GeckoCode,0x8
  b Snap101_ApplyGeckoCode_Loop
Snap101_ApplyGeckoCode_Exit:
blr

#endregion

#endregion

#region LagPrompt

#region Snap101_LagPrompt_SceneLoad
############################################

#region Snap101_LagPrompt_SceneLoad_Data
Snap101_LagPrompt_SceneLoad_TextProperties:
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

Snap101_LagPrompt_SceneLoad_TopText:
blrl
.ascii "Are you using HDMI?"
.align 2

Snap101_LagPrompt_SceneLoad_Yes:
blrl
.string "Yes"
.align 2

Snap101_LagPrompt_SceneLoad_No:
blrl
.string "No"
.align 2

#GObj Offsets
  .set OFST_TextGObj,0x0
  .set OFST_Selection,0x4

#endregion
#region Snap101_LagPrompt_SceneLoad
Snap101_LagPrompt_SceneLoad:
blrl

#Init
  backup

Snap101_LagPrompt_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl Snap101_LagPrompt_SceneLoad_TextProperties
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
	bl Snap101_LagPrompt_SceneLoad_TopText
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
	bl Snap101_LagPrompt_SceneLoad_Yes
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
	bl Snap101_LagPrompt_SceneLoad_No
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
  bl  Snap101_LagPrompt_SceneThink
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

Snap101_LagPrompt_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region Snap101_LagPrompt_SceneThink
Snap101_LagPrompt_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  Snap101_LagPrompt_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,Inputs_GetPlayerRapidHeldInputs
  mr  REG_Inputs,r3
#Check for movement to the right
  rlwinm. r0,REG_Inputs,0,0x80
  beq Snap101_LagPrompt_SceneThink_SkipRight
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  addi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,1
  ble Snap101_LagPrompt_SceneThink_HighlightSelection
  li  r3,1
  stb r3,OFST_Selection(REG_GObjData)
  b Snap101_LagPrompt_SceneThink_CheckForA
Snap101_LagPrompt_SceneThink_SkipRight:
#Check for movement to the left
  rlwinm. r0,REG_Inputs,0,0x40
  beq Snap101_LagPrompt_SceneThink_CheckForA
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  subi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Snap101_LagPrompt_SceneThink_HighlightSelection
  li  r3,0
  stb r3,OFST_Selection(REG_GObjData)
  b Snap101_LagPrompt_SceneThink_CheckForA

Snap101_LagPrompt_SceneThink_HighlightSelection:
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
Snap101_LagPrompt_SceneThink_CheckForA:
  li  r3,4
  branchl r12,Inputs_GetPlayerInstantInputs
  rlwinm. r0,r4,0,0x100
  bne Snap101_LagPrompt_SceneThink_Confirmed
  rlwinm. r0,r4,0,0x1000
  bne Snap101_LagPrompt_SceneThink_Confirmed
  b Snap101_LagPrompt_SceneThink_Exit
Snap101_LagPrompt_SceneThink_Confirmed:
#Play Menu Sound
  branchl r12,SFX_PlayMenuSound_Forward
#If yes, apply lag reduction
  lbz r3,OFST_Selection(REG_GObjData)
  cmpwi r3,0
  bne Snap101_LagPrompt_SceneThink_ExitScene
#endregion
#region Apply Code
.set  REG_GeckoCode,12
#Apply lag reduction
  bl  Snap101_LagReductionGeckoCode
  mflr  r3
  bl  Snap101_ApplyGeckoCode
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
#Enable 10160
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

Snap101_LagPrompt_SceneThink_ExitScene:
  branchl r12,MenuController_ChangeScreenMinor

Snap101_LagPrompt_SceneThink_Exit:
  restore
  blr
#endregion
#region Snap101_LagPrompt_SceneDecide
Snap101_LagPrompt_SceneDecide:

  backup

#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  Snap101_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)

#Enter Codes Scene
  li  r3,CodesSceneID
  branchl r12,MenuController_WriteToPendingMajor
#Change Major
  branchl r12,MenuController_ChangeScreenMajor

Snap101_LagPrompt_SceneDecide_Exit:
  restore
  blr
############################################
#endregion

#region Snap101_LagReductionGeckoCode
Snap101_LagReductionGeckoCode:
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
Snap101_LagPrompt_MinorSceneStruct:
blrl
#Lag Prompt
.byte 0                     #Minor Scene ID
.byte 00                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  Snap101_LagPrompt_SceneDecide   #SceneDecide
.byte PromptCommonSceneID   #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

Snap101_Codes_MinorSceneStruct:
blrl
#Codes Prompt
.byte 0                     #Minor Scene ID
.byte 00                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  Snap101_Codes_SceneDecide       #SceneDecide
.byte CodesCommonSceneID    #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

#endregion

Snap101_CheckProgressive:

#Check if progressive is enabled
  lis	r3,0xCC00
	lhz	r3,0x206E(r3)
	rlwinm.	r3,r3,0,0x1
  beq Snap101_NoProgressive

Snap101_IsProgressive:
#Override SceneLoad
  li  r3,PromptCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  Snap101_LagPrompt_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load LagPrompt
  li	r3, PromptSceneID
  b Snap101_Exit
Snap101_NoProgressive:
#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  Snap101_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load Codes
  li  r3,CodesSceneID

Snap101_Exit:
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

MMLCode101_End:
blrl
#endregion
#region SnapshotCode100
.include "../../Common100.s"

SnapshotCode100_Start:
#First thing to do is relocate ALL of the exploit code to tournament mode
	bl	MMLCode100_End
	mflr	r3
	bl	MMLCode100_Start
	mflr	r4
	sub	r5,r3,r4
	load	r3,TournamentMode
	branchl	r12,memcpy

#Flush cache to ensure these instructions are up to date
  load r3,TournamentMode
	bl	MMLCode100_Start
	mflr	r4
	bl	MMLCode100_End
	mflr	r5
	sub	r4,r5,r4
  branchl r12,TRK_flush_cache

#Now run from the tournament mode code region
	branch	r12,TournamentMode

MMLCode100_Start:
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
  bl  Snap100_LagPrompt_MinorSceneStruct
  mflr  r4
  bl  Snap100_LagPrompt_SceneLoad
  mflr  r5
  bl  Snap100_InitializeMajorSceneStruct
#Init Codes major struct
  li  r3,CodesSceneID
  bl  Snap100_Codes_MinorSceneStruct
  mflr  r4
  bl  Snap100_Codes_SceneLoad
  mflr  r5
  bl  Snap100_InitializeMajorSceneStruct

#Check if key has been generated yet
	lwz	r20,OFST_Memcard(r13)
	lwz	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
	cmpwi	r3,0
	bne	Snap100_GenerateKeyEnd
#Generate Key
	lwz	r3, OFST_Rand (r13)
	lwz	r3,0x0(r3)
	stw	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
Snap100_GenerateKeyEnd:
  b Snap100_CheckProgressive

#region Snap100_PointerConvert
Snap100_PointerConvert:
  lwz r4,0x0(r3)          #Load bl instruction
  rlwinm r5,r4,8,25,29    #extract opcode bits
  cmpwi r5,0x48           #if not a bl instruction, exit
  bne Snap100_PointerConvert_Exit
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
  add r4,r4,r3
  stw r4,0x0(r3)
Snap100_PointerConvert_Exit:
  blr
#endregion
#region Snap100_InitializeMajorSceneStruct
Snap100_InitializeMajorSceneStruct:
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
Snap100_GetMajorStruct_Loop:
  lbz	r4, 0x0001 (r3)
  cmpw r4,REG_MajorScene
  beq Snap100_GetMajorStruct_Exit
  addi  r3,r3,20
  b Snap100_GetMajorStruct_Loop
Snap100_GetMajorStruct_Exit:

Snap100_InitMinorSceneStruct:
.set  REG_MinorStructParse,20
  stw REG_MinorStruct,0x10(r3)
  mr  REG_MinorStructParse,REG_MinorStruct
Snap100_InitMinorSceneStruct_Loop:
#Check if valid entry
  lbz r3,0x0(REG_MinorStructParse)
  extsb r3,r3
  cmpwi r3,-1
  beq Snap100_InitMinorSceneStruct_Exit
#Convert Pointers
  addi  r3,REG_MinorStructParse,0x4
  bl  Snap100_PointerConvert
  addi  r3,REG_MinorStructParse,0x8
  bl  Snap100_PointerConvert
  addi  REG_MinorStructParse,REG_MinorStructParse,0x18
  b Snap100_InitMinorSceneStruct_Loop
Snap100_InitMinorSceneStruct_Exit:

  restore
  blr
#endregion
#endregion

#region Codes

#region Snap100_Codes_SceneLoad
############################################

#region Snap100_Codes_SceneLoad_Data
Snap100_Codes_SceneLoad_TextProperties:
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
.set MagicNumber,0x4C
.set Next,0x54

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
.long 0x43300000,0x80000000

.set CodeAmount,10
#region Code Names Order
Snap100_CodeNames_Order:
blrl
bl  Snap100_CodeNames_UCF
bl  Snap100_CodeNames_Frozen
bl  Snap100_CodeNames_Spawns
bl  Snap100_CodeNames_Wobbling
bl  Snap100_CodeNames_Ledgegrab
bl	Snap100_CodeNames_TournamentQoL
bl	Snap100_CodeNames_FriendliesQoL
bl	Snap100_CodeNames_GameVersion
bl	Snap100_CodeNames_StageExpansion
bl	Snap100_CodeNames_Widescreen
.align 2
#endregion
#region Code Names
Snap100_CodeNames_Title:
blrl
.string "Select Codes:"
.align 2
Snap100_CodeNames_ModName:
blrl
.string "MultiMod Launcher v0.6"
.align 2
Snap100_CodeNames_UCF:
.string "UCF:"
.align 2
Snap100_CodeNames_Frozen:
.string "Frozen Stages:"
.align 2
Snap100_CodeNames_Spawns:
.string "Neutral Spawns:"
.align 2
Snap100_CodeNames_Wobbling:
.string "Disable Wobbling:"
.align 2
Snap100_CodeNames_Ledgegrab:
.string "Ledgegrab Limit:"
.align 2
Snap100_CodeNames_TournamentQoL:
.string "Tournament QoL:"
.align 2
Snap100_CodeNames_FriendliesQoL:
.string "Friendlies QoL:"
.align 2
Snap100_CodeNames_GameVersion:
.string "Game Version:"
.align 2
Snap100_CodeNames_StageExpansion:
.string "Stage Expansion:"
.align 2
Snap100_CodeNames_Widescreen:
.string "Widescreen:"
.align 2
#endregion
#region Code Options Order
Snap100_CodeOptions_Order:
blrl
bl  Snap100_CodeOptions_UCF
bl  Snap100_CodeOptions_Frozen
bl  Snap100_CodeOptions_Spawns
bl  Snap100_CodeOptions_Wobbling
bl  Snap100_CodeOptions_Ledgegrab
bl	Snap100_CodeOptions_TournamentQoL
bl  Snap100_CodeOptions_FriendliesQoL
bl	Snap100_CodeOptions_GameVersion
bl	Snap100_CodeOptions_StageExpansion
bl  Snap100_CodeOptions_Widescreen
.align 2
#endregion
#region Code Options
.set  Snap100_CodeOptions_OptionCount,0x0
.set	Snap100_CodeOptions_CodeDescription,0x4
.set  Snap100_CodeOptions_GeckoCodePointers,0x8
Snap100_CodeOptions_Wrapper:
	blrl
	.short 0x8183
	.ascii "%s"
	.short 0x8184
	.byte 0
	.align 2
Snap100_CodeOptions_UCF:
	.long 3 -1           #number of options
	bl	Snap100_UCF_Description
	bl  Snap100_UCF_Off
	bl  Snap100_UCF_On
	bl  Snap100_UCF_Stealth
	.string "Off"
	.string "On"
	.string "Stealth"
	.align 2
Snap100_CodeOptions_Frozen:
	.long 3 -1           #number of options
	bl	Snap100_Frozen_Description
	bl  Snap100_Frozen_Off
	bl  Snap100_Frozen_Stadium
	bl  Snap100_Frozen_All
	.string "Off"
	.string "Stadium Only"
	.string "All"
	.align 2
Snap100_CodeOptions_Spawns:
	.long 2 -1           #number of options
	bl	Snap100_Spawns_Description
	bl  Snap100_Spawns_Off
	bl  Snap100_Spawns_On
	.string "Off"
	.string "On"
	.align 2
Snap100_CodeOptions_Wobbling:
	.long 2 -1           #number of options
	bl	Snap100_DisableWobbling_Description
	bl  Snap100_DisableWobbling_Off
	bl  Snap100_DisableWobbling_On
	.string "Off"
	.string "On"
	.align 2
Snap100_CodeOptions_Ledgegrab:
	.long 2 -1           #number of options
	bl	Snap100_Ledgegrab_Description
	bl  Snap100_Ledgegrab_Off
	bl  Snap100_Ledgegrab_On
	.string "Off"
	.string "On"
	.align 2
Snap100_CodeOptions_TournamentQoL:
	.long 2 -1           #number of options
	bl	Snap100_TournamentQoL_Description
	bl  Snap100_TournamentQoL_Off
	bl  Snap100_TournamentQoL_On
	.string "Off"
	.string "On"
	.align 2
Snap100_CodeOptions_FriendliesQoL:
	.long 2 -1           #number of options
	bl	Snap100_FriendliesQoL_Description
	bl  Snap100_FriendliesQoL_Off
	bl  Snap100_FriendliesQoL_On
	.string "Off"
	.string "On"
	.align 2
Snap100_CodeOptions_GameVersion:
	.long 3 -1           #number of options
	bl	Snap100_GameVersion_Description
	bl  Snap100_GameVersion_NTSC
	bl  Snap100_GameVersion_100
	bl  Snap100_GameVersion_SDR
	.string "NTSC"
	.string "100"
	.string "SD Remix"
	.align 2
Snap100_CodeOptions_StageExpansion:
	.long 2 -1           #number of options
	bl	Snap100_StageExpansion_Description
	bl  Snap100_StageExpansion_Off
	bl  Snap100_StageExpansion_On
	.string "Off"
	.string "On"
	.align 2
Snap100_CodeOptions_Widescreen:
	.long 3 -1           #number of options
	bl	Snap100_Widescreen_Description
	bl  Snap100_Widescreen_Off
	bl  Snap100_Widescreen_Standard
	bl	Snap100_Widescreen_True
	.string "Off"
	.string "Standard"
	.string "True"
	.align 2
#endregion
#region Gecko Codes
Snap100_DefaultCodes:
  blrl
	.long 0xC201AE0C
	.long 0x00000004
	.long 0x2C190002
	.long 0x41800014
	.long 0x2C190008
	.long 0x4181000C
	.long 0x38000000
	.long 0x48000008
	.long 0x801F00F4
	.long 0x00000000
	.long 0xC201C778
	.long 0x0000000A
	.long 0x4800000D
	.long 0x7C8802A6
	.long 0x48000040
	.long 0x4E800021
	.long 0x53757065
	.long 0x7220536D
	.long 0x61736820
	.long 0x42726F73
	.long 0x2E204D65
	.long 0x6C656520
	.long 0x20202020
	.long 0x20202020
	.long 0x4D756C74
	.long 0x694D6F64
	.long 0x204C6175
	.long 0x6E636865
	.long 0x72204245
	.long 0x54410000
	.long 0x60000000
	.long 0x00000000
	.long 0x043959B4
	.long 0x4800020C
	.long 0xC22278E4
	.long 0x00000028
	.long 0x3E808034
	.long 0x62943D78
	.long 0x480000F5
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000A9
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x4800005D
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x48000089
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000B5
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000AD
	.long 0x7C6802A6
	.long 0x3C808000
	.long 0x88A40007
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x4800008D
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000B8
	.long 0x4E800021
	.long 0x23232054
	.long 0x57454554
	.long 0x20412050
	.long 0x49435455
	.long 0x5245204F
	.long 0x46205448
	.long 0x4953204D
	.long 0x45535341
	.long 0x47452054
	.long 0x4F204055
	.long 0x6E636C65
	.long 0x50756E63
	.long 0x685F2023
	.long 0x230A0000
	.long 0x4E800021
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x230A0000
	.long 0x4E800021
	.long 0x0A000000
	.long 0x4E800021
	.long 0x4D756C74
	.long 0x694D6F64
	.long 0x204C6175
	.long 0x6E636865
	.long 0x72207630
	.long 0x2E36200A
	.long 0x47616D65
	.long 0x20566572
	.long 0x73696F6E
	.long 0x3A202573
	.long 0x7225640A
	.long 0x00000000
	.long 0x387D0000
	.long 0x00000000
	.long 0xC222C340
	.long 0x00000023
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7D1B78
	.long 0x3C600001
	.long 0x60630000
	.long 0x3D808037
	.long 0x618CD330
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C7F1B78
	.long 0x808D8840
	.long 0x3CA00001
	.long 0x60A50A30
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3D808001
	.long 0x618CB678
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03000B
	.long 0x4182FFEC
	.long 0x38600000
	.long 0x3C80803B
	.long 0x60848D9C
	.long 0x3CA0803B
	.long 0x60A58CB4
	.long 0x3CC08043
	.long 0x60C6135C
	.long 0x3D808001
	.long 0x618CBCB4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x40820020
	.long 0x806D8840
	.long 0x80631F24
	.long 0x809F1F24
	.long 0x7C032000
	.long 0x4082000C
	.long 0x3BC00009
	.long 0x4800000C
	.long 0x3BC00002
	.long 0x48000004
	.long 0x806D8840
	.long 0x7FE4FB78
	.long 0x3CA00001
	.long 0x60A50A30
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FE3FB78
	.long 0x3D808037
	.long 0x618CD2FC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FC3F378
	.long 0x48000004
	.long 0x7FA4EB78
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x7C601B78
	.long 0x7C832378
	.long 0x00000000
	.long 0x041BEBB0
	.long 0x60000000
	.long 0x04477D78
	.long 0x00000000
	.long 0x041A34EC
	.long 0x60000000
	.long 0x041A3510
	.long 0x38600000
	.long 0x04459F48
	.long 0x00340102
	.long 0x0445A3A8
	.long 0xFF000000
	.long 0x0445A3C0
	.long 0xE70000B0
	.long 0x04459F4C
	.long 0x04000A00
	.long 0x0416430C
	.long 0x38600001
	.long 0x041640EC
	.long 0x38600001
	.long 0x04163E50
	.long 0x38600001
	.long 0x04163CE0
	.long 0x38600001
	.long -1

Snap100_UCF_Off:
	.long -1
Snap100_UCF_On:
	.long -1
Snap100_UCF_Stealth:
	.long -1

Snap100_Frozen_Off:
	.long -1
Snap100_Frozen_Stadium:
	.long -1
Snap100_Frozen_All:
	.long -1

Snap100_Spawns_Off:
	.long -1
Snap100_Spawns_On:
	.long -1

Snap100_DisableWobbling_Off:
	.long -1
Snap100_DisableWobbling_On:
	.long -1

Snap100_Ledgegrab_Off:
	.long -1
Snap100_Ledgegrab_On:
	.long -1

Snap100_TournamentQoL_Off:
	.long -1
Snap100_TournamentQoL_On:
	.long -1

Snap100_FriendliesQoL_Off:
	.long -1
Snap100_FriendliesQoL_On:
	.long -1

Snap100_GameVersion_NTSC:
	.long -1
Snap100_GameVersion_100:
	.long -1
Snap100_GameVersion_SDR:
	.long -1

Snap100_StageExpansion_Off:
	.long -1
Snap100_StageExpansion_On:
	.long -1

Snap100_Widescreen_Off:
	.long -1
Snap100_Widescreen_Standard:
	.long -1
Snap100_Widescreen_True:
	.long -1

#endregion
#region Code Descriptions
Snap100_UCF_Description:
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
Snap100_Frozen_Description:
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
Snap100_Spawns_Description:
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
Snap100_DisableWobbling_Description:
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
Snap100_Ledgegrab_Description:
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
Snap100_TournamentQoL_Description:
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
Snap100_FriendliesQoL_Description:
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
Snap100_GameVersion_Description:
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
Snap100_StageExpansion_Description:
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
Snap100_Widescreen_Description:
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
#region Snap100_Codes_SceneLoad
Snap100_Codes_SceneLoad:
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

Snap100_Codes_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl Snap100_Codes_SceneLoad_TextProperties
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
	bl Snap100_CodeNames_Title
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
	bl Snap100_CodeNames_ModName
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
  bl  Snap100_Codes_SceneThink
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
  bl  Snap100_Codes_CreateMenu

Snap100_Codes_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region Snap100_Codes_SceneThink
Snap100_Codes_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  Snap100_Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Code Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,Inputs_GetPlayerRapidHeldInputs
  mr  REG_Inputs,r3
#Check for movement up
  rlwinm. r0,REG_Inputs,0,0x10
  beq Snap100_Codes_SceneThink_SkipUp
#Adjust cursor
  lhz r3,OFST_CursorLocation(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_CursorLocation(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Snap100_Codes_SceneThink_UpdateMenu
#Cursor stays at top
  li  r3,0
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll up
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Snap100_Codes_SceneThink_UpdateMenu
#Scroll stays at top
  li  r3,0
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b Snap100_Codes_SceneThink_Exit
Snap100_Codes_SceneThink_SkipUp:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x20
  beq Snap100_Codes_SceneThink_AdjustOptionSelection
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
  b Snap100_Codes_SceneThink_Exit
#Check if exceeds max amount of codes per page
  cmpwi r3,MaxCodesOnscreen-1
  ble Snap100_Codes_SceneThink_UpdateMenu
#Cursor stays at bottom
  li  r3,MaxCodesOnscreen-1
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll down
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  addi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,CodeAmount-MaxCodesOnscreen
  ble Snap100_Codes_SceneThink_UpdateMenu
#Scroll stays at bottom
  li  r3,(CodeAmount-1)-(MaxCodesOnscreen-1)
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b Snap100_Codes_SceneThink_Exit
#endregion
#region Adjust Option Selection
Snap100_Codes_SceneThink_AdjustOptionSelection:
.set  REG_MaxOptions,20
.set  REG_OptionValuePtr,21
#Check for movement right
  rlwinm. r0,REG_Inputs,0,0x80
  beq Snap100_Codes_SceneThink_SkipRight
#Get amount of options for this code
  lhz r3,OFST_CursorLocation(REG_GObjData)
  lhz r4,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,r4                                #get which option this is
  bl  Snap100_CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add r3,r3,r4                                #get bl pointer to options info
  bl  Snap100_ConvertBlPointer
  lwz REG_MaxOptions,Snap100_CodeOptions_OptionCount(r3)     #get amount of options for this code
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
  ble Snap100_Codes_SceneThink_UpdateMenu
#Option stays maxxed out
  stb REG_MaxOptions,0x0(REG_OptionValuePtr)
  b Snap100_Codes_SceneThink_Exit
Snap100_Codes_SceneThink_SkipRight:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x40
  beq Snap100_Codes_SceneThink_CheckToExit
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
  bge Snap100_Codes_SceneThink_UpdateMenu
#Option stays at 0
  li  r3,0
  stb r3,0x0(REG_OptionValuePtr)
  b Snap100_Codes_SceneThink_Exit
#endregion
#region Check to Exit
Snap100_Codes_SceneThink_CheckToExit:
#Check for start input
  li  r3,4
  branchl r12,Inputs_GetPlayerInstantInputs
  rlwinm. r0,r4,0,0x1000
  beq Snap100_Codes_SceneThink_Exit
#Apply codes
  mr  r3,REG_GObjData
  bl  Snap100_ApplyAllGeckoCodes
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

  b Snap100_Codes_SceneThink_Exit
#endregion

Snap100_Codes_SceneThink_UpdateMenu:
#Redraw Menu
  mr  r3,REG_GObjData
  bl  Snap100_Codes_CreateMenu
#Play SFX
  branchl r12,SFX_PlayMenuSound_CloseOpenPort
  b Snap100_Codes_SceneThink_Exit

Snap100_Codes_SceneThink_Exit:
  restore
  blr
#endregion
#region Snap100_Codes_SceneDecide
Snap100_Codes_SceneDecide:
  backup

#Change Major
  li  r3,ExitSceneID
  branchl r12,MenuController_WriteToPendingMajor
#Leave Major
  branchl r12,MenuController_ChangeScreenMajor

Snap100_Codes_SceneDecide_Exit:
  restore
  blr
############################################
#endregion
#region Snap100_Codes_CreateMenu
Snap100_Codes_CreateMenu:
.set  REG_GObjData,31
.set  REG_TextGObj,30
.set  REG_TextProp,29

#Init
  backup
  mr  REG_GObjData,r3
  bl  Snap100_Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#Remove old text gobjs if they exist
  lwz r3,OFST_CodeNamesTextGObj(REG_GObjData)
  cmpwi r3,0
  beq Snap100_Codes_CreateMenu_SkipNameRemoval
  branchl r12,Text_RemoveText
Snap100_Codes_CreateMenu_SkipNameRemoval:
  lwz r3,OFST_CodeOptionsTextGObj(REG_GObjData)
  cmpwi r3,0
  beq Snap100_Codes_CreateMenu_SkipOptionRemoval
  branchl r12,Text_RemoveText
Snap100_Codes_CreateMenu_SkipOptionRemoval:

#region CreateTextGObjs
Snap100_Codes_CreateMenu_CreateTextGObjs:
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
#region Snap100_Codes_CreateMenu_CreateNames
Snap100_Codes_CreateMenu_CreateNamesInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
  li  REG_Count,0
Snap100_Codes_CreateMenu_CreateNamesLoop:
#Next name to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,REG_Count
#Get the string bl pointer
  bl  Snap100_CodeNames_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  Snap100_ConvertBlPointer
  mr  r4,r3
#Get Y Offset for this
  lis    r0, 0x4330
  lfd    f2, MagicNumber (REG_TextProp)
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
Snap100_Codes_CreateMenu_CreateNamesIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge Snap100_Codes_CreateMenu_CreateNameLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt Snap100_Codes_CreateMenu_CreateNamesLoop
Snap100_Codes_CreateMenu_CreateNameLoopEnd:
#endregion
#region Snap100_Codes_CreateMenu_CreateOptions
Snap100_Codes_CreateMenu_CreateOptionsInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
.set  REG_CurrentOptionID,22
.set  REG_CurrentOptionSelection,23
.set  REG_OptionStrings,24
.set  REG_StringLoopCount,25
  li  REG_Count,0
Snap100_Codes_CreateMenu_CreateOptionsLoop:
#Next option to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add REG_CurrentOptionID,r3,REG_Count
#Get the bl pointer
  mr  r3,REG_CurrentOptionID
  bl  Snap100_CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  Snap100_ConvertBlPointer
  lwz r4,Snap100_CodeOptions_OptionCount(r3)
  addi  r4,r4,1
  addi  REG_OptionStrings,r3,Snap100_CodeOptions_GeckoCodePointers  #Get pointer to gecko code pointers
  mulli r4,r4,0x4                                           #pointer length
  add REG_OptionStrings,REG_OptionStrings,r4
#Get this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx  REG_CurrentOptionSelection,r3,REG_CurrentOptionID

#Loop through strings and get the current one
  li  REG_StringLoopCount,0
Snap100_Codes_CreateMenu_CreateOptionsLoop_StringSearch:
  cmpw  REG_StringLoopCount,REG_CurrentOptionSelection
  beq Snap100_Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd
#Get next string
  mr  r3,REG_OptionStrings
  branchl r12,strlen
  add REG_OptionStrings,REG_OptionStrings,r3
  addi  REG_OptionStrings,REG_OptionStrings,1       #add 1 to skip past the 0 terminator
  addi  REG_StringLoopCount,REG_StringLoopCount,1
  b Snap100_Codes_CreateMenu_CreateOptionsLoop_StringSearch

Snap100_Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd:
#Get Y Offset for this
  lis    r0, 0x4330
  lfd    f2, MagicNumber (REG_TextProp)
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
  bl  Snap100_CodeOptions_Wrapper
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
Snap100_Codes_CreateMenu_CreateOptionsIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge Snap100_Codes_CreateMenu_CreateOptionsLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt Snap100_Codes_CreateMenu_CreateOptionsLoop
Snap100_Codes_CreateMenu_CreateOptionsLoopEnd:
#endregion
#region Snap100_Codes_CreateMenu_HighlightCursor
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
#region Snap100_Codes_CreateMenu_ChangeCodeDescription
#Get highlighted code ID
	lhz r3,OFST_ScrollAmount(REG_GObjData)
	lhz r4,OFST_CursorLocation(REG_GObjData)
	add	r3,r3,r4
#Get this codes options
	bl	Snap100_CodeOptions_Order
	mflr	r4
	mulli	r3,r3,0x4
	add	r3,r3,r4
	bl	Snap100_ConvertBlPointer
#Get this codes description
	addi	r3,r3,Snap100_CodeOptions_CodeDescription
	bl	Snap100_ConvertBlPointer
	lwz	r4,OFST_CodeDescTextGObj(REG_GObjData)
#Store to text gobj
	stw	r3,0x5C(r4)
#endregion

Snap100_Codes_CreateMenu_Exit:
  restore
  blr

###############################################

Snap100_ConvertBlPointer:
  lwz r4,0x0(r3)        #Load bl instruction
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
  add r3,r4,r3
  blr

#endregion
#region Snap100_ApplyAllGeckoCodes
Snap100_ApplyAllGeckoCodes:
.set  REG_GObjData,31
.set  REG_Count,30
.set  REG_OptionSelection,29
#Init
  backup
  mr  REG_GObjData,r3

#Default Codes
  bl  Snap100_DefaultCodes_On
  mflr  r3
  bl  Snap100_ApplyGeckoCode

#Init Loop
  li  REG_Count,0
ApplyAllGeckoSnap100_Codes_Loop:
#Load this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx REG_OptionSelection,r3,REG_Count
#Get this code's default gecko code pointer
  bl  Snap100_CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  Snap100_ConvertBlPointer
  addi  r3,r3,Snap100_CodeOptions_GeckoCodePointers
  bl  Snap100_ConvertBlPointer
  bl  Snap100_ApplyGeckoCode
#Get this code's gecko code pointers
  bl  Snap100_CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  Snap100_ConvertBlPointer
  addi  r3,r3,Snap100_CodeOptions_GeckoCodePointers
  mulli r4,REG_OptionSelection,0x4
  add  r3,r3,r4
  bl  Snap100_ConvertBlPointer
  bl  Snap100_ApplyGeckoCode

ApplyAllGeckoSnap100_Codes_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  blt ApplyAllGeckoSnap100_Codes_Loop

ApplyAllGeckoSnap100_Codes_Exit:
  restore
  blr

####################################

Snap100_ApplyGeckoCode:
.set  REG_GeckoCode,12
  mr  REG_GeckoCode,r3

Snap100_ApplyGeckoCode_Loop:
  lbz r3,0x0(REG_GeckoCode)
  cmpwi r3,0xC2
  beq Snap100_ApplyGeckoCode_C2
  cmpwi r3,0x4
  beq Snap100_ApplyGeckoCode_04
  cmpwi r3,0xFF
  beq Snap100_ApplyGeckoCode_Exit
  b Snap100_ApplyGeckoCode_Exit
Snap100_ApplyGeckoCode_C2:
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
  b Snap100_ApplyGeckoCode_Loop
Snap100_ApplyGeckoCode_04:
  lwz r3,0x0(REG_GeckoCode)
  rlwinm r3,r3,0,8,31
  oris  r3,r3,0x8000
  lwz r4,0x4(REG_GeckoCode)
  stw r4,0x0(r3)
  addi REG_GeckoCode,REG_GeckoCode,0x8
  b Snap100_ApplyGeckoCode_Loop
Snap100_ApplyGeckoCode_Exit:
blr

#endregion

#endregion

#region LagPrompt

#region Snap100_LagPrompt_SceneLoad
############################################

#region Snap100_LagPrompt_SceneLoad_Data
Snap100_LagPrompt_SceneLoad_TextProperties:
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

Snap100_LagPrompt_SceneLoad_TopText:
blrl
.ascii "Are you using HDMI?"
.align 2

Snap100_LagPrompt_SceneLoad_Yes:
blrl
.string "Yes"
.align 2

Snap100_LagPrompt_SceneLoad_No:
blrl
.string "No"
.align 2

#GObj Offsets
  .set OFST_TextGObj,0x0
  .set OFST_Selection,0x4

#endregion
#region Snap100_LagPrompt_SceneLoad
Snap100_LagPrompt_SceneLoad:
blrl

#Init
  backup

Snap100_LagPrompt_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl Snap100_LagPrompt_SceneLoad_TextProperties
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
	bl Snap100_LagPrompt_SceneLoad_TopText
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
	bl Snap100_LagPrompt_SceneLoad_Yes
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
	bl Snap100_LagPrompt_SceneLoad_No
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
  bl  Snap100_LagPrompt_SceneThink
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

Snap100_LagPrompt_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region Snap100_LagPrompt_SceneThink
Snap100_LagPrompt_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  Snap100_LagPrompt_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,Inputs_GetPlayerRapidHeldInputs
  mr  REG_Inputs,r3
#Check for movement to the right
  rlwinm. r0,REG_Inputs,0,0x80
  beq Snap100_LagPrompt_SceneThink_SkipRight
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  addi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,1
  ble Snap100_LagPrompt_SceneThink_HighlightSelection
  li  r3,1
  stb r3,OFST_Selection(REG_GObjData)
  b Snap100_LagPrompt_SceneThink_CheckForA
Snap100_LagPrompt_SceneThink_SkipRight:
#Check for movement to the left
  rlwinm. r0,REG_Inputs,0,0x40
  beq Snap100_LagPrompt_SceneThink_CheckForA
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  subi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Snap100_LagPrompt_SceneThink_HighlightSelection
  li  r3,0
  stb r3,OFST_Selection(REG_GObjData)
  b Snap100_LagPrompt_SceneThink_CheckForA

Snap100_LagPrompt_SceneThink_HighlightSelection:
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
Snap100_LagPrompt_SceneThink_CheckForA:
  li  r3,4
  branchl r12,Inputs_GetPlayerInstantInputs
  rlwinm. r0,r4,0,0x100
  bne Snap100_LagPrompt_SceneThink_Confirmed
  rlwinm. r0,r4,0,0x1000
  bne Snap100_LagPrompt_SceneThink_Confirmed
  b Snap100_LagPrompt_SceneThink_Exit
Snap100_LagPrompt_SceneThink_Confirmed:
#Play Menu Sound
  branchl r12,SFX_PlayMenuSound_Forward
#If yes, apply lag reduction
  lbz r3,OFST_Selection(REG_GObjData)
  cmpwi r3,0
  bne Snap100_LagPrompt_SceneThink_ExitScene
#endregion
#region Apply Code
.set  REG_GeckoCode,12
#Apply lag reduction
  bl  Snap100_LagReductionGeckoCode
  mflr  r3
  bl  Snap100_ApplyGeckoCode
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
#Enable 10060
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

Snap100_LagPrompt_SceneThink_ExitScene:
  branchl r12,MenuController_ChangeScreenMinor

Snap100_LagPrompt_SceneThink_Exit:
  restore
  blr
#endregion
#region Snap100_LagPrompt_SceneDecide
Snap100_LagPrompt_SceneDecide:

  backup

#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  Snap100_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)

#Enter Codes Scene
  li  r3,CodesSceneID
  branchl r12,MenuController_WriteToPendingMajor
#Change Major
  branchl r12,MenuController_ChangeScreenMajor

Snap100_LagPrompt_SceneDecide_Exit:
  restore
  blr
############################################
#endregion

#region Snap100_LagReductionGeckoCode
Snap100_LagReductionGeckoCode:
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
Snap100_LagPrompt_MinorSceneStruct:
blrl
#Lag Prompt
.byte 0                     #Minor Scene ID
.byte 00                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  Snap100_LagPrompt_SceneDecide   #SceneDecide
.byte PromptCommonSceneID   #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

Snap100_Codes_MinorSceneStruct:
blrl
#Codes Prompt
.byte 0                     #Minor Scene ID
.byte 00                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  Snap100_Codes_SceneDecide       #SceneDecide
.byte CodesCommonSceneID    #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

#endregion

Snap100_CheckProgressive:

#Check if progressive is enabled
  lis	r3,0xCC00
	lhz	r3,0x206E(r3)
	rlwinm.	r3,r3,0,0x1
  beq Snap100_NoProgressive

Snap100_IsProgressive:
#Override SceneLoad
  li  r3,PromptCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  Snap100_LagPrompt_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load LagPrompt
  li	r3, PromptSceneID
  b Snap100_Exit
Snap100_NoProgressive:
#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  Snap100_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load Codes
  li  r3,CodesSceneID

Snap100_Exit:
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

MMLCode100_End:
blrl
#endregion
#region SnapshotCodePAL
.include "../../CommonPAL.s"
#Mod Data Struct (this needs to be in the tournament redirect code)
.set ModOFST_ModDataStart,0x1f2C
	.set ModOFST_ModDataKey,0x0
		.set ModOFST_ModDataKeyLength,0x4
	.set ModOFST_ModDataPrefs,ModOFST_ModDataKey + ModOFST_ModDataKeyLength
		.set ModOFST_ModDataPrefsLength,0x18
		.set ModOFST_ModDataLength,ModOFST_ModDataPrefs + ModOFST_ModDataPrefsLength

SnapshotCodePAL_Start:
#First thing to do is relocate ALL of the exploit code to tournament mode
	bl	MMLCodePAL_End
	mflr	r3
	bl	MMLCodePAL_Start
	mflr	r4
	sub	r5,r3,r4
	load	r3,TournamentMode
	branchl	r12,memcpy

#Flush cache to ensure these instructions are up to date
  load r3,TournamentMode
	bl	MMLCodePAL_Start
	mflr	r4
	bl	MMLCodePAL_End
	mflr	r5
	sub	r4,r5,r4
  branchl r12,TRK_flush_cache

#Now run from the tournament mode code region
	branch	r12,TournamentMode

MMLCodePAL_Start:
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
  bl  SnapPAL_LagPrompt_MinorSceneStruct
  mflr  r4
  bl  SnapPAL_LagPrompt_SceneLoad
  mflr  r5
  bl  SnapPAL_InitializeMajorSceneStruct
#Init Codes major struct
  li  r3,CodesSceneID
  bl  SnapPAL_Codes_MinorSceneStruct
  mflr  r4
  bl  SnapPAL_Codes_SceneLoad
  mflr  r5
  bl  SnapPAL_InitializeMajorSceneStruct

#Check if key has been generated yet
	lwz	r20,OFST_Memcard(r13)
	lwz	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
	cmpwi	r3,0
	bne	SnapPAL_GenerateKeyEnd
#Generate Key
	lwz	r3, OFST_Rand (r13)
	lwz	r3,0x0(r3)
	stw	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
SnapPAL_GenerateKeyEnd:
  b SnapPAL_CheckProgressive

#region SnapPAL_PointerConvert
SnapPAL_PointerConvert:
  lwz r4,0x0(r3)          #Load bl instruction
  rlwinm r5,r4,8,25,29    #extract opcode bits
  cmpwi r5,0x48           #if not a bl instruction, exit
  bne SnapPAL_PointerConvert_Exit
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
  add r4,r4,r3
  stw r4,0x0(r3)
SnapPAL_PointerConvert_Exit:
  blr
#endregion
#region SnapPAL_InitializeMajorSceneStruct
SnapPAL_InitializeMajorSceneStruct:
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
SnapPAL_GetMajorStruct_Loop:
  lbz	r4, 0x0001 (r3)
  cmpw r4,REG_MajorScene
  beq SnapPAL_GetMajorStruct_Exit
  addi  r3,r3,20
  b SnapPAL_GetMajorStruct_Loop
SnapPAL_GetMajorStruct_Exit:

SnapPAL_InitMinorSceneStruct:
.set  REG_MinorStructParse,20
  stw REG_MinorStruct,0x10(r3)
  mr  REG_MinorStructParse,REG_MinorStruct
SnapPAL_InitMinorSceneStruct_Loop:
#Check if valid entry
  lbz r3,0x0(REG_MinorStructParse)
  extsb r3,r3
  cmpwi r3,-1
  beq SnapPAL_InitMinorSceneStruct_Exit
#Convert Pointers
  addi  r3,REG_MinorStructParse,0x4
  bl  SnapPAL_PointerConvert
  addi  r3,REG_MinorStructParse,0x8
  bl  SnapPAL_PointerConvert
  addi  REG_MinorStructParse,REG_MinorStructParse,0x18
  b SnapPAL_InitMinorSceneStruct_Loop
SnapPAL_InitMinorSceneStruct_Exit:

  restore
  blr
#endregion
#endregion

#region Codes

#region SnapPAL_Codes_SceneLoad
############################################

#region SnapPAL_Codes_SceneLoad_Data
SnapPAL_Codes_SceneLoad_TextProperties:
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
.set MagicNumber,0x4C
.set Next,0x54

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
.long 0x43300000,0x80000000

.set CodeAmount,10
#region Code Names Order
SnapPAL_CodeNames_Order:
blrl
bl  SnapPAL_CodeNames_UCF
bl  SnapPAL_CodeNames_Frozen
bl  SnapPAL_CodeNames_Spawns
bl  SnapPAL_CodeNames_Wobbling
bl  SnapPAL_CodeNames_Ledgegrab
bl	SnapPAL_CodeNames_TournamentQoL
bl	SnapPAL_CodeNames_FriendliesQoL
bl	SnapPAL_CodeNames_GameVersion
bl	SnapPAL_CodeNames_StageExpansion
bl	SnapPAL_CodeNames_Widescreen
.align 2
#endregion
#region Code Names
SnapPAL_CodeNames_Title:
blrl
.string "Select Codes:"
.align 2
SnapPAL_CodeNames_ModName:
blrl
.string "MultiMod Launcher v0.6"
.align 2
SnapPAL_CodeNames_UCF:
.string "UCF:"
.align 2
SnapPAL_CodeNames_Frozen:
.string "Frozen Stages:"
.align 2
SnapPAL_CodeNames_Spawns:
.string "Neutral Spawns:"
.align 2
SnapPAL_CodeNames_Wobbling:
.string "Disable Wobbling:"
.align 2
SnapPAL_CodeNames_Ledgegrab:
.string "Ledgegrab Limit:"
.align 2
SnapPAL_CodeNames_TournamentQoL:
.string "Tournament QoL:"
.align 2
SnapPAL_CodeNames_FriendliesQoL:
.string "Friendlies QoL:"
.align 2
SnapPAL_CodeNames_GameVersion:
.string "Game Version:"
.align 2
SnapPAL_CodeNames_StageExpansion:
.string "Stage Expansion:"
.align 2
SnapPAL_CodeNames_Widescreen:
.string "Widescreen:"
.align 2
#endregion
#region Code Options Order
SnapPAL_CodeOptions_Order:
blrl
bl  SnapPAL_CodeOptions_UCF
bl  SnapPAL_CodeOptions_Frozen
bl  SnapPAL_CodeOptions_Spawns
bl  SnapPAL_CodeOptions_Wobbling
bl  SnapPAL_CodeOptions_Ledgegrab
bl	SnapPAL_CodeOptions_TournamentQoL
bl  SnapPAL_CodeOptions_FriendliesQoL
bl	SnapPAL_CodeOptions_GameVersion
bl	SnapPAL_CodeOptions_StageExpansion
bl  SnapPAL_CodeOptions_Widescreen
.align 2
#endregion
#region Code Options
.set  SnapPAL_CodeOptions_OptionCount,0x0
.set	SnapPAL_CodeOptions_CodeDescription,0x4
.set  SnapPAL_CodeOptions_GeckoCodePointers,0x8
SnapPAL_CodeOptions_Wrapper:
	blrl
	.ascii "(%s)"
	.byte 0
	.align 2
SnapPAL_CodeOptions_UCF:
	.long 3 -1           #number of options
	bl	SnapPAL_UCF_Description
	bl  SnapPAL_UCF_Off
	bl  SnapPAL_UCF_On
	bl  SnapPAL_UCF_Stealth
	.string "Off"
	.string "On"
	.string "Stealth"
	.align 2
SnapPAL_CodeOptions_Frozen:
	.long 3 -1           #number of options
	bl	SnapPAL_Frozen_Description
	bl  SnapPAL_Frozen_Off
	bl  SnapPAL_Frozen_Stadium
	bl  SnapPAL_Frozen_All
	.string "Off"
	.string "Stadium Only"
	.string "All"
	.align 2
SnapPAL_CodeOptions_Spawns:
	.long 2 -1           #number of options
	bl	SnapPAL_Spawns_Description
	bl  SnapPAL_Spawns_Off
	bl  SnapPAL_Spawns_On
	.string "Off"
	.string "On"
	.align 2
SnapPAL_CodeOptions_Wobbling:
	.long 2 -1           #number of options
	bl	SnapPAL_DisableWobbling_Description
	bl  SnapPAL_DisableWobbling_Off
	bl  SnapPAL_DisableWobbling_On
	.string "Off"
	.string "On"
	.align 2
SnapPAL_CodeOptions_Ledgegrab:
	.long 2 -1           #number of options
	bl	SnapPAL_Ledgegrab_Description
	bl  SnapPAL_Ledgegrab_Off
	bl  SnapPAL_Ledgegrab_On
	.string "Off"
	.string "On"
	.align 2
SnapPAL_CodeOptions_TournamentQoL:
	.long 2 -1           #number of options
	bl	SnapPAL_TournamentQoL_Description
	bl  SnapPAL_TournamentQoL_Off
	bl  SnapPAL_TournamentQoL_On
	.string "Off"
	.string "On"
	.align 2
SnapPAL_CodeOptions_FriendliesQoL:
	.long 2 -1           #number of options
	bl	SnapPAL_FriendliesQoL_Description
	bl  SnapPAL_FriendliesQoL_Off
	bl  SnapPAL_FriendliesQoL_On
	.string "Off"
	.string "On"
	.align 2
SnapPAL_CodeOptions_GameVersion:
	.long 3 -1           #number of options
	bl	SnapPAL_GameVersion_Description
	bl  SnapPAL_GameVersion_NTSC
	bl  SnapPAL_GameVersion_PAL
	bl  SnapPAL_GameVersion_SDR
	.string "NTSC"
	.string "PAL"
	.string "SD Remix"
	.align 2
SnapPAL_CodeOptions_StageExpansion:
	.long 2 -1           #number of options
	bl	SnapPAL_StageExpansion_Description
	bl  SnapPAL_StageExpansion_Off
	bl  SnapPAL_StageExpansion_On
	.string "Off"
	.string "On"
	.align 2
SnapPAL_CodeOptions_Widescreen:
	.long 3 -1           #number of options
	bl	SnapPAL_Widescreen_Description
	bl  SnapPAL_Widescreen_Off
	bl  SnapPAL_Widescreen_Standard
	bl	SnapPAL_Widescreen_True
	.string "Off"
	.string "Standard"
	.string "True"
	.align 2
#endregion
#region Gecko Codes
SnapPAL_DefaultCodes_On:
	blrl
	.long 0xC201B010
	.long 0x00000004
	.long 0x2C190002
	.long 0x41800014
	.long 0x2C190008
	.long 0x4181000C
	.long 0x38000000
	.long 0x48000008
	.long 0x801F00F4
	.long 0x00000000
	.long 0xC201CA6C
	.long 0x0000000A
	.long 0x4800000D
	.long 0x7C8802A6
	.long 0x48000040
	.long 0x4E800021
	.long 0x53757065
	.long 0x7220536D
	.long 0x61736820
	.long 0x42726F73
	.long 0x2E204D65
	.long 0x6C656520
	.long 0x20202020
	.long 0x20202020
	.long 0x4D756C74
	.long 0x694D6F64
	.long 0x204C6175
	.long 0x6E636865
	.long 0x72204245
	.long 0x54410000
	.long 0x60000000
	.long 0x00000000
	.long 0x043977A0
	.long 0x4800020C
	.long 0xC222846C
	.long 0x00000028
	.long 0x3E808034
	.long 0x62945A84
	.long 0x480000F5
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000A9
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x4800005D
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x48000089
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000B5
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000AD
	.long 0x7C6802A6
	.long 0x3C808000
	.long 0x88A40007
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x4800008D
	.long 0x7C6802A6
	.long 0x7E8903A6
	.long 0x4E800421
	.long 0x480000B8
	.long 0x4E800021
	.long 0x23232054
	.long 0x57454554
	.long 0x20412050
	.long 0x49435455
	.long 0x5245204F
	.long 0x46205448
	.long 0x4953204D
	.long 0x45535341
	.long 0x47452054
	.long 0x4F204055
	.long 0x6E636C65
	.long 0x50756E63
	.long 0x685F2023
	.long 0x230A0000
	.long 0x4E800021
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x23232323
	.long 0x230A0000
	.long 0x4E800021
	.long 0x0A000000
	.long 0x4E800021
	.long 0x4D756C74
	.long 0x694D6F64
	.long 0x204C6175
	.long 0x6E636865
	.long 0x72207630
	.long 0x2E36200A
	.long 0x47616D65
	.long 0x20566572
	.long 0x73696F6E
	.long 0x3A202573
	.long 0x7225640A
	.long 0x00000000
	.long 0x387D0000
	.long 0x00000000
	.long 0xC222F4A4
	.long 0x00000023
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7D1B78
	.long 0x3C600001
	.long 0x60630000
	.long 0x3D808037
	.long 0x618CF0E8
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C7F1B78
	.long 0x808D8858
	.long 0x3CA00001
	.long 0x60A50A30
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3D808001
	.long 0x618CB87C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03000B
	.long 0x4182FFEC
	.long 0x38600000
	.long 0x3C80803B
	.long 0x6084B244
	.long 0x3CA0803B
	.long 0x60A5B0B4
	.long 0x3CC08042
	.long 0x60C640BC
	.long 0x3D808001
	.long 0x618CBEB8
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x40820020
	.long 0x806D8858
	.long 0x80631F24
	.long 0x809F1F24
	.long 0x7C032000
	.long 0x4082000C
	.long 0x3BC00009
	.long 0x4800000C
	.long 0x3BC00002
	.long 0x48000004
	.long 0x806D8858
	.long 0x7FE4FB78
	.long 0x3CA00001
	.long 0x60A50A30
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FE3FB78
	.long 0x3D808037
	.long 0x618CF0B4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FC3F378
	.long 0x48000004
	.long 0x7FA4EB78
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x7C601B78
	.long 0x7C832378
	.long 0x00000000
	.long 0x041C157C
	.long 0x60000000
	.long 0x0446AB48
	.long 0x00000000
	.long 0x041A49F4
	.long 0x60000000
	.long 0x041A4AA4
	.long 0x38600000
	.long 0x0444CD18
	.long 0x00340102
	.long 0x0444D178
	.long 0xFF000000
	.long 0x0444D190
	.long 0xE70000B0
	.long 0x0444CD1C
	.long 0x04000A00
	.long 0x0444CD20
	.long 0x08010100
	.long 0x041654E4
	.long 0x38600001
	.long 0x041652C4
	.long 0x38600001
	.long 0x04165028
	.long 0x38600001
	.long 0x04164EB8
	.long 0x38600001
	.long -1

SnapPAL_UCF_Off:
	.long 0x040CA1E8
	.long 0xD01F002C
	.long 0x04099F5C
	.long 0x8083002C
	.long 0x042669EC
	.long 0x38980000
	.long -1
SnapPAL_UCF_On:
	.long 0xC20CA1E8
	.long 0x0000002B
	.long 0xD01F002C
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x48000121
	.long 0x7FC802A6
	.long 0xC03F0894
	.long 0xC05E0000
	.long 0xFC011040
	.long 0x40820118
	.long 0x808DB0F4
	.long 0xC03F0620
	.long 0xFC200A10
	.long 0xC044003C
	.long 0xFC011040
	.long 0x41800100
	.long 0x887F0670
	.long 0x2C030002
	.long 0x408000F4
	.long 0x887F221F
	.long 0x54600739
	.long 0x408200E8
	.long 0x3C60804B
	.long 0x60632FF8
	.long 0x8BA30001
	.long 0x387DFFFE
	.long 0x889F0618
	.long 0x4800008D
	.long 0x7C7C1B78
	.long 0x7FA3EB78
	.long 0x889F0618
	.long 0x4800007D
	.long 0x7C7C1850
	.long 0x7C6319D6
	.long 0x2C0315F9
	.long 0x408100B0
	.long 0x38000001
	.long 0x901F2358
	.long 0x901F2340
	.long 0x809F0004
	.long 0x2C04000A
	.long 0x40A20098
	.long 0x887F000C
	.long 0x38800001
	.long 0x3D808003
	.long 0x618C4780
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x41820078
	.long 0x8083002C
	.long 0x80841ECC
	.long 0xC03F002C
	.long 0xD0240018
	.long 0xC05E0004
	.long 0xFC011040
	.long 0x4181000C
	.long 0x38600080
	.long 0x48000008
	.long 0x3860007F
	.long 0x98640006
	.long 0x48000048
	.long 0x7C852378
	.long 0x3863FFFF
	.long 0x2C030000
	.long 0x40800008
	.long 0x38630005
	.long 0x3C808045
	.long 0x6084BF10
	.long 0x1C630030
	.long 0x7C841A14
	.long 0x1C65000C
	.long 0x7C841A14
	.long 0x88640002
	.long 0x7C630774
	.long 0x4E800020
	.long 0x4E800021
	.long 0x40000000
	.long 0x00000000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x60000000
	.long 0x00000000
	.long 0xC2099F5C
	.long 0x00000026
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7FFEFB78
	.long 0x83FE002C
	.long 0x480000DD
	.long 0x7FA802A6
	.long 0xC03F063C
	.long 0x806DB0F4
	.long 0xC0030314
	.long 0xFC010040
	.long 0x408100E4
	.long 0xC03F0620
	.long 0x48000071
	.long 0xD0210090
	.long 0xC03F0624
	.long 0x48000065
	.long 0xC0410090
	.long 0xEC4200B2
	.long 0xEC210072
	.long 0xEC21102A
	.long 0xC05D000C
	.long 0xFC011040
	.long 0x418000B4
	.long 0x889F0670
	.long 0x2C040003
	.long 0x408100A8
	.long 0xC01D0010
	.long 0xC03F0624
	.long 0xFC000840
	.long 0x40800098
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x8061001C
	.long 0x83E10014
	.long 0x38210018
	.long 0x38630008
	.long 0x7C6803A6
	.long 0x4E800020
	.long 0xFC000A10
	.long 0xC03D0000
	.long 0xEC000072
	.long 0xC03D0004
	.long 0xEC000828
	.long 0xFC00001E
	.long 0xD8010080
	.long 0x80610084
	.long 0x38630002
	.long 0x3C004330
	.long 0xC85D0014
	.long 0x6C638000
	.long 0x90010080
	.long 0x90610084
	.long 0xC8210080
	.long 0xEC011028
	.long 0xC03D0000
	.long 0xEC200824
	.long 0x4E800020
	.long 0x4E800021
	.long 0x42A00000
	.long 0x37270000
	.long 0x43300000
	.long 0x3F800000
	.long 0xBF4CCCCD
	.long 0x43300000
	.long 0x80000000
	.long 0x7FC3F378
	.long 0x7FE4FB78
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x00000000
	.long 0xC22669EC
	.long 0x0000001B
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x48000089
	.long 0x7FC802A6
	.long 0x38600000
	.long 0x38800000
	.long 0x3DC0803A
	.long 0x61CE6664
	.long 0x7DC903A6
	.long 0x4E800421
	.long 0x7C7F1B78
	.long 0x38800001
	.long 0x989F0049
	.long 0x38800001
	.long 0x989F004A
	.long 0xC03E000C
	.long 0xD03F0024
	.long 0xD03F0028
	.long 0x7FE3FB78
	.long 0x48000059
	.long 0x7C8802A6
	.long 0xC03E0000
	.long 0xC05E0004
	.long 0x3DC0803A
	.long 0x61CE6B54
	.long 0x7DC903A6
	.long 0x4E800421
	.long 0x7C641B78
	.long 0x7FE3FB78
	.long 0xC03E0008
	.long 0xC05E0008
	.long 0x3D80803A
	.long 0x618C74FC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000028
	.long 0x4E800021
	.long 0x42180000
	.long 0xC3898000
	.long 0x3EE66666
	.long 0x3DCCCCCD
	.long 0x4E800021
	.long 0x55434620
	.long 0x302E3734
	.long 0x00000000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x38980000
	.long 0x60000000
	.long 0x00000000
	.long -1
SnapPAL_UCF_Stealth:
	.long 0xC20CA1E8
	.long 0x0000002B
	.long 0xD01F002C
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x48000121
	.long 0x7FC802A6
	.long 0xC03F0894
	.long 0xC05E0000
	.long 0xFC011040
	.long 0x40820118
	.long 0x808DB0F4
	.long 0xC03F0620
	.long 0xFC200A10
	.long 0xC044003C
	.long 0xFC011040
	.long 0x41800100
	.long 0x887F0670
	.long 0x2C030002
	.long 0x408000F4
	.long 0x887F221F
	.long 0x54600739
	.long 0x408200E8
	.long 0x3C60804B
	.long 0x60632FF8
	.long 0x8BA30001
	.long 0x387DFFFE
	.long 0x889F0618
	.long 0x4800008D
	.long 0x7C7C1B78
	.long 0x7FA3EB78
	.long 0x889F0618
	.long 0x4800007D
	.long 0x7C7C1850
	.long 0x7C6319D6
	.long 0x2C0315F9
	.long 0x408100B0
	.long 0x38000001
	.long 0x901F2358
	.long 0x901F2340
	.long 0x809F0004
	.long 0x2C04000A
	.long 0x40A20098
	.long 0x887F000C
	.long 0x38800001
	.long 0x3D808003
	.long 0x618C4780
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x41820078
	.long 0x8083002C
	.long 0x80841ECC
	.long 0xC03F002C
	.long 0xD0240018
	.long 0xC05E0004
	.long 0xFC011040
	.long 0x4181000C
	.long 0x38600080
	.long 0x48000008
	.long 0x3860007F
	.long 0x98640006
	.long 0x48000048
	.long 0x7C852378
	.long 0x3863FFFF
	.long 0x2C030000
	.long 0x40800008
	.long 0x38630005
	.long 0x3C808045
	.long 0x6084BF10
	.long 0x1C630030
	.long 0x7C841A14
	.long 0x1C65000C
	.long 0x7C841A14
	.long 0x88640002
	.long 0x7C630774
	.long 0x4E800020
	.long 0x4E800021
	.long 0x40000000
	.long 0x00000000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x60000000
	.long 0x00000000
	.long 0xC2099F5C
	.long 0x00000026
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7FFEFB78
	.long 0x83FE002C
	.long 0x480000DD
	.long 0x7FA802A6
	.long 0xC03F063C
	.long 0x806DB0F4
	.long 0xC0030314
	.long 0xFC010040
	.long 0x408100E4
	.long 0xC03F0620
	.long 0x48000071
	.long 0xD0210090
	.long 0xC03F0624
	.long 0x48000065
	.long 0xC0410090
	.long 0xEC4200B2
	.long 0xEC210072
	.long 0xEC21102A
	.long 0xC05D000C
	.long 0xFC011040
	.long 0x418000B4
	.long 0x889F0670
	.long 0x2C040003
	.long 0x408100A8
	.long 0xC01D0010
	.long 0xC03F0624
	.long 0xFC000840
	.long 0x40800098
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x8061001C
	.long 0x83E10014
	.long 0x38210018
	.long 0x38630008
	.long 0x7C6803A6
	.long 0x4E800020
	.long 0xFC000A10
	.long 0xC03D0000
	.long 0xEC000072
	.long 0xC03D0004
	.long 0xEC000828
	.long 0xFC00001E
	.long 0xD8010080
	.long 0x80610084
	.long 0x38630002
	.long 0x3C004330
	.long 0xC85D0014
	.long 0x6C638000
	.long 0x90010080
	.long 0x90610084
	.long 0xC8210080
	.long 0xEC011028
	.long 0xC03D0000
	.long 0xEC200824
	.long 0x4E800020
	.long 0x4E800021
	.long 0x42A00000
	.long 0x37270000
	.long 0x43300000
	.long 0x3F800000
	.long 0xBF4CCCCD
	.long 0x43300000
	.long 0x80000000
	.long 0x7FC3F378
	.long 0x7FE4FB78
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x00000000
	.long -1

SnapPAL_Widescreen_Off:
	.long 0x043BB6A4
	.long 0x3FAAAAA8
	.long 0x0436A3AC
	.long 0xC03F0034
	.long 0x044CEED0
	.long 0x3E000000
	.long 0x040871A0
	.long 0x4182000C
	.long 0x040311A8
	.long 0xA0010020
	.long 0x040311B4
	.long 0xA0010022
	.long 0x044CEEA8
	.long 0x3F24D317
	.long 0x044CEEAC
	.long 0xBF24D317
	.long 0x044CEEA4
	.long 0xC322B333
	.long 0x044CEEA0
	.long 0x4322B333
	.long 0x044CEEC4
	.long 0x3DCCCCCD
	.long 0x042FD90C
	.long 0xC002E19C
	.long 0x044CEF04
	.long 0x3ECCCCCD
	.long -1
SnapPAL_Widescreen_Standard:
	.long 0x043BB6A4
	.long 0x3EB00000
	.long 0xC236A3AC
	.long 0x00000006
	.long 0xC03F0034
	.long 0x4800001D
	.long 0x7C6802A6
	.long 0xC0430000
	.long 0xC0630004
	.long 0xEC2100B2
	.long 0xEC211824
	.long 0x48000010
	.long 0x4E800021
	.long 0x40800000
	.long 0x40400000
	.long 0x00000000
	.long 0x044CEED0
	.long 0x3E4CCCCD
	.long 0x040871A0
	.long 0x60000000
	.long 0x040311A8
	.long 0x3800004E
	.long 0x040311B4
	.long 0x38000232
	.long 0x044CEEA8
	.long 0x3F666666
	.long 0x044CEEAC
	.long 0xBF666666
	.long 0x044CEEA4
	.long 0xC3660000
	.long 0x044CEEA0
	.long 0x43660000
	.long 0x044CEEC4
	.long 0x3D916873
	.long 0xC22FD90C
	.long 0x00000004
	.long 0x48000011
	.long 0x7C6802A6
	.long 0xC0030000
	.long 0x4800000C
	.long 0x4E800021
	.long 0x40F00000
	.long 0x60000000
	.long 0x00000000
	.long 0x044CEF04
	.long 0x3E99999A
	.long -1
SnapPAL_Widescreen_True:
	.long 0x043BB6A4
	.long 0x3EB00000
	.long 0xC236A3AC
	.long 0x00000006
	.long 0xC03F0034
	.long 0x4800001D
	.long 0x7C6802A6
	.long 0xC0430000
	.long 0xC0630004
	.long 0xEC2100B2
	.long 0xEC211824
	.long 0x48000010
	.long 0x4E800021
	.long 0x42B80000
	.long 0x427C0000
	.long 0x00000000
	.long 0x044CEED0
	.long 0x3E4CCCCD
	.long 0x040871A0
	.long 0x60000000
	.long 0x040311A8
	.long 0x38000064
	.long 0x040311B4
	.long 0x3800021C
	.long 0x044CEEA8
	.long 0x3F666666
	.long 0x044CEEAC
	.long 0xBF666666
	.long 0x044CEEA4
	.long 0xC3660000
	.long 0x044CEEA0
	.long 0x43660000
	.long 0x044CEEC4
	.long 0x3D916873
	.long 0xC22FD90C
	.long 0x00000004
	.long 0x48000011
	.long 0x7C6802A6
	.long 0xC0030000
	.long 0x4800000C
	.long 0x4E800021
	.long 0x40F00000
	.long 0x60000000
	.long 0x00000000
	.long 0x044CEF04
	.long 0x3E99999A
	.long -1

SnapPAL_Frozen_All:
	.long 0x043E7300
	.long 0x00000000
	.long 0x0421C998
	.long 0x60000000
	.long 0x041D316C
	.long 0x60000000
	.long 0x041E5178
	.long 0x60000000
	.long -1
SnapPAL_Frozen_Off:
	.long 0x043E7300
	.long 0x00000002
	.long 0x0421C998
	.long 0x48000805
	.long 0x041D316C
	.long 0x48003001
	.long 0x041E5178
	.long 0x480000D1
	.long -1
SnapPAL_Frozen_Stadium:
	.long 0x041D316C
	.long 0x60000000
	.long -1

SnapPAL_Spawns_Off:
	.long 0x0416EEE4
	.long 0x881F24D0
	.long -1
SnapPAL_Spawns_On:
	.long 0xC216EEE4
	.long 0x00000099
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x3D808016
	.long 0x618CBDEC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x40820488
	.long 0x2C1C0005
	.long 0x40800480
	.long 0x887F24D0
	.long 0x2C030001
	.long 0x41820054
	.long 0x3B200000
	.long 0x3B400000
	.long 0x7F43D378
	.long 0x3D808003
	.long 0x618C2A10
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030003
	.long 0x41820010
	.long 0x7C1CD000
	.long 0x41820014
	.long 0x3B390001
	.long 0x3B5A0001
	.long 0x2C1A0004
	.long 0x4081FFD0
	.long 0x7F83E378
	.long 0x7F24CB78
	.long 0x88BF24D0
	.long 0x48000115
	.long 0x48000424
	.long 0x3B400000
	.long 0x3B000000
	.long 0x3B200000
	.long 0x7F23CB78
	.long 0x3D808003
	.long 0x618C2A10
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030003
	.long 0x41820024
	.long 0x7F23CB78
	.long 0x3D808003
	.long 0x618C3964
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C03D000
	.long 0x40820008
	.long 0x3B180001
	.long 0x3B390001
	.long 0x2C190004
	.long 0x4180FFBC
	.long 0x2C180001
	.long 0x418203C8
	.long 0x2C180002
	.long 0x418103C0
	.long 0x3B5A0001
	.long 0x2C1A0003
	.long 0x4180FF98
	.long 0x3B200000
	.long 0x3B410080
	.long 0x3B000000
	.long 0x3AC00000
	.long 0x3AE00000
	.long 0x7EE3BB78
	.long 0x3D808003
	.long 0x618C2A10
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030003
	.long 0x41820028
	.long 0x7EE3BB78
	.long 0x3D808003
	.long 0x618C3964
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C03C800
	.long 0x4082000C
	.long 0x7EF8D1AE
	.long 0x3B180001
	.long 0x3AF70001
	.long 0x2C170004
	.long 0x4180FFB8
	.long 0x3B390001
	.long 0x2C190003
	.long 0x4180FFA4
	.long 0x3B200000
	.long 0x7C79D0AE
	.long 0x7C03E000
	.long 0x41820010
	.long 0x3B390001
	.long 0x2C190004
	.long 0x4180FFEC
	.long 0x7F83E378
	.long 0x7F24CB78
	.long 0x88BF24D0
	.long 0x48000009
	.long 0x48000318
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7F1B78
	.long 0x7C9E2378
	.long 0x7CBD2B78
	.long 0x48000141
	.long 0x7F8802A6
	.long 0x80CD9368
	.long 0x38A00000
	.long 0x807C0000
	.long 0x2C03FFFF
	.long 0x4182005C
	.long 0x7C033000
	.long 0x4182000C
	.long 0x3B9C0044
	.long 0x4BFFFFE8
	.long 0x3B9C0004
	.long 0x1C7D0020
	.long 0x7F9C1A14
	.long 0x1C7E0008
	.long 0x7F9C1A14
	.long 0x38810080
	.long 0xC03C0000
	.long 0xD0240000
	.long 0xC03C0004
	.long 0xD0240004
	.long 0x38600000
	.long 0x90640008
	.long 0x7FE3FB78
	.long 0x3D808003
	.long 0x618C2D5C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000054
	.long 0x2C1D0001
	.long 0x4182000C
	.long 0x7FC3F378
	.long 0x48000014
	.long 0x4800025D
	.long 0x7C6802A6
	.long 0x7C63F0AE
	.long 0x48000004
	.long 0x38810080
	.long 0x3D808022
	.long 0x618C6CD4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FE3FB78
	.long 0x38810080
	.long 0x3D808003
	.long 0x618C2D5C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000004
	.long 0x48000225
	.long 0x7F6802A6
	.long 0x7FE3FB78
	.long 0x38810080
	.long 0x3D808003
	.long 0x618C2CC0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0xC0210080
	.long 0xC01B0000
	.long 0xFC010040
	.long 0x4081000C
	.long 0xC03B0004
	.long 0x48000008
	.long 0xC03B0008
	.long 0x7FE3FB78
	.long 0x3D808003
	.long 0x618C3688
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FE3FB78
	.long 0x1C9E0005
	.long 0x3D808003
	.long 0x618C65D0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x4E800020
	.long 0x4E800021
	.long 0x00000020
	.long 0xC2700000
	.long 0x41200000
	.long 0x42700000
	.long 0x41200000
	.long 0xC1A00000
	.long 0x41200000
	.long 0x41A00000
	.long 0x41200000
	.long 0xC1A00000
	.long 0x41200000
	.long 0xC2700000
	.long 0x41200000
	.long 0x41A00000
	.long 0x41200000
	.long 0x42700000
	.long 0x41200000
	.long 0x0000001F
	.long 0xC21B3333
	.long 0x420CCCCD
	.long 0x421B3333
	.long 0x420CCCCD
	.long 0x00000000
	.long 0x41000000
	.long 0x00000000
	.long 0x4279999A
	.long 0xC21B3333
	.long 0x420CCCCD
	.long 0xC21B3333
	.long 0x40A00000
	.long 0x421B3333
	.long 0x420CCCCD
	.long 0x421B3333
	.long 0x40A00000
	.long 0x00000008
	.long 0xC2280000
	.long 0x41D4CCCD
	.long 0x42280000
	.long 0x41E00000
	.long 0x00000000
	.long 0x423B999A
	.long 0x00000000
	.long 0x409CCCCD
	.long 0xC2280000
	.long 0x41D4CCCD
	.long 0xC2280000
	.long 0x40A00000
	.long 0x42280000
	.long 0x41E00000
	.long 0x42280000
	.long 0x40A00000
	.long 0x0000001C
	.long 0xC23A6666
	.long 0x4214CCCD
	.long 0x423D999A
	.long 0x42153333
	.long 0x00000000
	.long 0x40E00000
	.long 0x00000000
	.long 0x426A0000
	.long 0xC23A6666
	.long 0x4214CCCD
	.long 0xC23A6666
	.long 0x40A00000
	.long 0x423D999A
	.long 0x42153333
	.long 0x423D999A
	.long 0x40A00000
	.long 0x00000002
	.long 0xC2250000
	.long 0x41A80000
	.long 0x42250000
	.long 0x41D80000
	.long 0x00000000
	.long 0x40A80000
	.long 0x00000000
	.long 0x42400000
	.long 0xC2250000
	.long 0x41A80000
	.long 0xC2250000
	.long 0x40A00000
	.long 0x42250000
	.long 0x41D80000
	.long 0x42250000
	.long 0x40A00000
	.long 0x00000003
	.long 0xC2200000
	.long 0x42000000
	.long 0x42200000
	.long 0x42000000
	.long 0x428C0000
	.long 0x40E00000
	.long 0xC28C0000
	.long 0x40E00000
	.long 0xC2200000
	.long 0x42000000
	.long 0xC2200000
	.long 0x40A00000
	.long 0x42200000
	.long 0x42000000
	.long 0x42200000
	.long 0x40A00000
	.long 0xFFFFFFFF
	.long 0x4E800021
	.long 0x00030102
	.long 0x4E800021
	.long 0x00000000
	.long 0xBF800000
	.long 0x3F800000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x881F24D0
	.long 0x60000000
	.long 0x00000000
	.long -1

SnapPAL_DisableWobbling_Off:
	.long 0x040DB1C0
	.long 0x7F43D378
	.long 0x0408F748
	.long 0x801B0010
	.long -1
SnapPAL_DisableWobbling_On:
	.long 0xC20DB1C0
	.long 0x00000003
	.long 0x38600000
	.long 0x987C2350
	.long 0x3860FFFF
	.long 0xB07C2352
	.long 0x7F43D378
	.long 0x00000000
	.long 0xC208F748
	.long 0x00000017
	.long 0x807B0010
	.long 0x2C0300DF
	.long 0x418000A4
	.long 0x2C0300E4
	.long 0x4181009C
	.long 0x807B1A58
	.long 0x2C030000
	.long 0x41820090
	.long 0x8063002C
	.long 0x88832222
	.long 0x548407BD
	.long 0x41820080
	.long 0x8863000C
	.long 0x38800001
	.long 0x3D808003
	.long 0x618C4780
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C030000
	.long 0x41820060
	.long 0x809B1868
	.long 0x7C032000
	.long 0x40820054
	.long 0x80A3002C
	.long 0xA0652088
	.long 0xA09B2352
	.long 0x7C032000
	.long 0x41820040
	.long 0xB07B2352
	.long 0x887B2350
	.long 0x38630001
	.long 0x987B2350
	.long 0x2C030003
	.long 0x41800028
	.long 0x807B1A58
	.long 0x3D80800D
	.long 0x618CAE4C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3D808008
	.long 0x618CF780
	.long 0x7D8903A6
	.long 0x4E800420
	.long 0x801B0010
	.long 0x60000000
	.long 0x00000000
	.long -1

SnapPAL_Ledgegrab_Off:
	.long 0x041A6994
	.long 0x7FE3FB78
	.long 0x0416F5AC
	.long 0x98030006
	.long 0x041B2004
	.long 0x98030000
	.long 0x041B2138
	.long 0x3800012C
	.long 0x041B2134
	.long 0x38C00001
	.long 0x04166618
	.long 0x8803000F
	.long -1
SnapPAL_Ledgegrab_On:
	.long 0xC21A6994
	.long 0x00000002
	.long 0x386000B4
	.long 0x907F0010
	.long 0x7FE3FB78
	.long 0x00000000
	.long 0x0416F5AC
	.long 0x60000000
	.long 0x041B2004
	.long 0x60000000
	.long 0x041B2138
	.long 0x38000000
	.long 0x041B2134
	.long 0x38C00001
	.long 0xC2166618
	.long 0x0000005C
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBC610008
	.long 0x7C7F1B78
	.long 0x887F0004
	.long 0x2C030001
	.long 0x408202AC
	.long 0x3BC10080
	.long 0x3BA00000
	.long 0x38600000
	.long 0x907E0000
	.long 0x907E0004
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x88640058
	.long 0x2C030003
	.long 0x41820028
	.long 0x8864005D
	.long 0x2C030000
	.long 0x4082001C
	.long 0x887E0000
	.long 0x38630001
	.long 0x987E0000
	.long 0x389E0001
	.long 0x3863FFFF
	.long 0x7FA321AE
	.long 0x3BBD0001
	.long 0x2C1D0006
	.long 0x4180FFC0
	.long 0x887E0000
	.long 0x2C030001
	.long 0x40810118
	.long 0x3BA00000
	.long 0x387E0001
	.long 0x7C63E8AE
	.long 0x3D808003
	.long 0x618C48A8
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C7C1B78
	.long 0x3B600000
	.long 0x7C1BE800
	.long 0x4182002C
	.long 0x387E0001
	.long 0x7C63D8AE
	.long 0x3D808003
	.long 0x618C48A8
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C03E000
	.long 0x4080000C
	.long 0x7F7DDB78
	.long 0x4BFFFFB4
	.long 0x3B7B0001
	.long 0x887E0000
	.long 0x7C1B1800
	.long 0x4180FFC4
	.long 0x4800000C
	.long 0x3BBD0001
	.long 0x4BFFFF98
	.long 0x3B600000
	.long 0x387E0001
	.long 0x7C83D8AE
	.long 0x1C6400A8
	.long 0x7C63FA14
	.long 0x38BE0001
	.long 0x7CA5E8AE
	.long 0x7C042800
	.long 0x4182000C
	.long 0x38800001
	.long 0x48000008
	.long 0x38800000
	.long 0x9883005D
	.long 0x9883005E
	.long 0x3B7B0001
	.long 0x887E0000
	.long 0x7C1B1800
	.long 0x4180FFC0
	.long 0x3B600000
	.long 0x387E0001
	.long 0x7F43D8AE
	.long 0x387E0001
	.long 0x7C63E8AE
	.long 0x7C1A1800
	.long 0x41820034
	.long 0x7F43D378
	.long 0x3D808003
	.long 0x618C48A8
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C03E000
	.long 0x40820018
	.long 0x1C7A00A8
	.long 0x7C63FA14
	.long 0x38800000
	.long 0x9883005D
	.long 0x9883005E
	.long 0x3B7B0001
	.long 0x887E0000
	.long 0x7C1B1800
	.long 0x4180FFAC
	.long 0x3BA00000
	.long 0x3B800000
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x88640058
	.long 0x2C030003
	.long 0x41820030
	.long 0x8864005D
	.long 0x2C030000
	.long 0x40820024
	.long 0x7FA3EB78
	.long 0x3D808004
	.long 0x618C11B4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03003C
	.long 0x41800008
	.long 0x3B9C0001
	.long 0x3BBD0001
	.long 0x2C1D0006
	.long 0x4180FFB8
	.long 0x2C1C0001
	.long 0x418100D8
	.long 0x2C1C0000
	.long 0x418200D0
	.long 0x3BA00000
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x88640058
	.long 0x2C030003
	.long 0x4182004C
	.long 0x8864005D
	.long 0x2C030000
	.long 0x41820010
	.long 0x2C030001
	.long 0x41820008
	.long 0x48000034
	.long 0x7FA3EB78
	.long 0x3D808004
	.long 0x618C11B4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03003C
	.long 0x40800018
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x38600000
	.long 0x9864005D
	.long 0x9864005E
	.long 0x3BBD0001
	.long 0x2C1D0006
	.long 0x4180FF9C
	.long 0x3BA00000
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x88640058
	.long 0x2C030003
	.long 0x41820040
	.long 0x8864005D
	.long 0x2C030000
	.long 0x40820034
	.long 0x7FA3EB78
	.long 0x3D808004
	.long 0x618C11B4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x2C03003C
	.long 0x41800018
	.long 0x1C7D00A8
	.long 0x7C83FA14
	.long 0x38600001
	.long 0x9864005D
	.long 0x9864005E
	.long 0x3BBD0001
	.long 0x2C1D0006
	.long 0x4180FFA8
	.long 0xB8610008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x8803000F
	.long 0x00000000
	.long -1

SnapPAL_TournamentQoL_Off:
	.long 0x042673B0
	.long 0x38600001
	.long 0x042FD620
	.long 0x281E0000
	.long 0x0425C3E8
	.long 0x38600001
	.long 0x0444D188
	.long 0x01010101
	.long 0x04261078
	.long 0x889F0004
	.long 0x04260D9C
	.long 0x38C00001
	.long 0x044CD7F4
	.long 0xC1AC0000
	.long 0x04262218
	.long 0x1C130024
	.long 0x043774A8
	.long 0x8819000A
	.long 0x042622C8
	.long 0x98A4007A
	.long 0x042622DC
	.long 0x98A4001B
	.long 0x0425A678
	.long 0x5460063F
	.long 0x0425A768
	.long 0x28000000
	.long -1
SnapPAL_TournamentQoL_On:
	.long 0xC22673B0
	.long 0x0000000E
	.long 0x3D808015
	.long 0x618CD3FC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C661B78
	.long 0x80A60018
	.long 0x3C60E700
	.long 0x606300B0
	.long 0x7C632A79
	.long 0x41820010
	.long 0x2C030020
	.long 0x41820008
	.long 0x48000034
	.long 0x806DB8A8
	.long 0x88630018
	.long 0x2C030001
	.long 0x41820014
	.long 0x38600001
	.long 0x50652EB4
	.long 0x90A60018
	.long 0x48000014
	.long 0x38600000
	.long 0x50652EB4
	.long 0x90A60018
	.long 0x48000004
	.long 0x38600001
	.long 0x60000000
	.long 0x00000000
	.long 0xC22FD620
	.long 0x0000000D
	.long 0x3C608045
	.long 0x6063C4A8
	.long 0x886324D0
	.long 0x2C030001
	.long 0x41820050
	.long 0x887F0000
	.long 0x3D808003
	.long 0x618C4704
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x8083002C
	.long 0x80640004
	.long 0x2C030010
	.long 0x40820010
	.long 0x80640010
	.long 0x2C0300EC
	.long 0x41820010
	.long 0x8864221E
	.long 0x54630673
	.long 0x41820014
	.long 0x3D80802F
	.long 0x618CD610
	.long 0x7D8903A6
	.long 0x4E800420
	.long 0x281E0000
	.long 0x00000000
	.long 0xC225C3E8
	.long 0x00000002
	.long 0x3C608046
	.long 0x6063AB38
	.long 0x88630000
	.long 0x00000000
	.long 0x0444D188
	.long 0x00000000
	.long 0xC2261078
	.long 0x00000020
	.long 0x887F0007
	.long 0x2C030000
	.long 0x40820090
	.long 0x889F0004
	.long 0x7C972378
	.long 0x800D8858
	.long 0x7C602214
	.long 0x88A31CC8
	.long 0x57800739
	.long 0x40820010
	.long 0x5780077B
	.long 0x4082003C
	.long 0x480000C4
	.long 0x28050001
	.long 0x418200BC
	.long 0x7EE3BB78
	.long 0x38800000
	.long 0x38A0000E
	.long 0x38C00000
	.long 0x38ED9B00
	.long 0x3D808037
	.long 0x618C8334
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x38800001
	.long 0x48000010
	.long 0x28050000
	.long 0x41820088
	.long 0x38800000
	.long 0x7EE3BB78
	.long 0x3D808015
	.long 0x618CF4F0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x38800001
	.long 0x989F0007
	.long 0x3C80C040
	.long 0x909F0014
	.long 0x48000051
	.long 0x7D8802A6
	.long 0xC03F0014
	.long 0xC04C0000
	.long 0xC01F000C
	.long 0xEC01002A
	.long 0xD01F000C
	.long 0xFC600850
	.long 0xFC030840
	.long 0x41810008
	.long 0xEC6300B2
	.long 0xD07F0014
	.long 0x4180002C
	.long 0xC08C0004
	.long 0xFC032040
	.long 0x41810020
	.long 0x38800000
	.long 0x909F0014
	.long 0x989F0007
	.long 0x48000010
	.long 0x4E800021
	.long 0x3F4CCCCD
	.long 0x3C800000
	.long 0x889F0004
	.long 0x60000000
	.long 0x00000000
	.long 0x04260D9C
	.long 0x38C00003
	.long 0x044CD7F4
	.long 0xC0200000
	.long 0xC2262218
	.long 0x00000005
	.long 0x88BF0005
	.long 0x2C050002
	.long 0x40820014
	.long 0x3D808026
	.long 0x618C2318
	.long 0x7D8903A6
	.long 0x4E800420
	.long 0x1C130024
	.long 0x60000000
	.long 0x00000000
	.long 0xC23774A8
	.long 0x00000018
	.long 0x8879000A
	.long 0x7C600774
	.long 0x2C00FFFF
	.long 0x408200A8
	.long 0x881A0041
	.long 0x7C030000
	.long 0x4182009C
	.long 0x3C608047
	.long 0x60631628
	.long 0x1C98000C
	.long 0x7C832214
	.long 0x38600078
	.long 0x9864000A
	.long 0x3D80801A
	.long 0x618C5D48
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x38630068
	.long 0x1CB80024
	.long 0x7C842A14
	.long 0x9864000A
	.long 0x7F03C378
	.long 0x38800000
	.long 0x3D808015
	.long 0x618CF4F0
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3C808046
	.long 0x6084AB38
	.long 0x88640000
	.long 0x2C030002
	.long 0x40820038
	.long 0x88640003
	.long 0x2C030000
	.long 0x4082002C
	.long 0x886DB8EE
	.long 0x2C030000
	.long 0x40820020
	.long 0x3C80803F
	.long 0x60841CF8
	.long 0x1C78000C
	.long 0x7C632214
	.long 0x80830000
	.long 0x38600000
	.long 0x9864001B
	.long 0x8819000A
	.long 0x60000000
	.long 0x00000000
	.long 0x042622C8
	.long 0x60000000
	.long 0x042622DC
	.long 0x60000000
	.long 0xC225A678
	.long 0x00000008
	.long 0x5460063F
	.long 0x41820038
	.long 0x1C9E001C
	.long 0x38040008
	.long 0x7C1F00AE
	.long 0x2C000000
	.long 0x40820024
	.long 0x3800001D
	.long 0x7C0903A6
	.long 0x38600000
	.long 0x389F0000
	.long 0x90640004
	.long 0x3884001C
	.long 0x4200FFF8
	.long 0x2C030000
	.long 0x00000000
	.long 0xC225A768
	.long 0x00000020
	.long 0x3D808015
	.long 0x618CD3FC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x39430018
	.long 0x39600000
	.long 0x38600000
	.long 0x3C80803F
	.long 0x60841550
	.long 0x28000013
	.long 0x4082000C
	.long 0x39600001
	.long 0x48000010
	.long 0x28000000
	.long 0x408200C0
	.long 0x48000034
	.long 0x2C03001D
	.long 0x408000B4
	.long 0x2C0B0002
	.long 0x4182004C
	.long 0x1CA3001C
	.long 0x7CA52214
	.long 0x88C5000A
	.long 0x80AA0000
	.long 0x7CA53430
	.long 0x54A507FF
	.long 0x40820088
	.long 0x4800002C
	.long 0x806DB898
	.long 0x5460056B
	.long 0x4082001C
	.long 0x546006F7
	.long 0x40820008
	.long 0x48000074
	.long 0x39600002
	.long 0x38600000
	.long 0x4BFFFFB0
	.long 0x886DB8A6
	.long 0x2C03001D
	.long 0x4080005C
	.long 0x1CA3001C
	.long 0x7CA52214
	.long 0x38C00000
	.long 0x2C0B0002
	.long 0x40820008
	.long 0x38C00002
	.long 0x98C50008
	.long 0x80A50000
	.long 0x2C030016
	.long 0x41800008
	.long 0x80A50010
	.long 0x3CC04400
	.long 0x2C0B0002
	.long 0x40820008
	.long 0x38C00000
	.long 0x90C50038
	.long 0x38C0001E
	.long 0x98CDB8A6
	.long 0x2C0B0000
	.long 0x4182000C
	.long 0x38630001
	.long 0x4BFFFF4C
	.long 0x28000000
	.long 0x00000000
	.long -1

SnapPAL_FriendliesQoL_Off:
	.long 0x041A6618
	.long 0x3BA00000
	.long 0x04265984
	.long 0x880DB8ED
	.long 0x0416F404
	.long 0x981E0010
	.long -1
SnapPAL_FriendliesQoL_On:
	.long 0xC21A6618
	.long 0x00000017
	.long 0x3BA00000
	.long 0x7FA3EB78
	.long 0x3D80801A
	.long 0x618C40C4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x548005EF
	.long 0x41820014
	.long 0x548005AD
	.long 0x4082001C
	.long 0x5480056B
	.long 0x4082001C
	.long 0x3BBD0001
	.long 0x2C1D0004
	.long 0x4180FFCC
	.long 0x4800006C
	.long 0x3B600002
	.long 0x48000068
	.long 0x3D80801A
	.long 0x618C5D48
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C741B78
	.long 0x3D808025
	.long 0x618CA4EC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3C80803F
	.long 0x60841550
	.long 0x1C63001C
	.long 0x7C841A14
	.long 0x8864000B
	.long 0xB0740016
	.long 0x3C808042
	.long 0x60842E1C
	.long 0x9064000C
	.long 0x3D808001
	.long 0x618C8498
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3B600002
	.long 0x48000008
	.long 0x3B600000
	.long 0x3BA00000
	.long 0x60000000
	.long 0x00000000
	.long 0xC2265984
	.long 0x00000028
	.long 0x7FA3EB78
	.long 0x48000031
	.long 0x2C030000
	.long 0x4182012C
	.long 0x807B0000
	.long 0x38800000
	.long 0x48000119
	.long 0x7CA802A6
	.long 0x3D80803A
	.long 0x618C74A4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000108
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7C7D1B78
	.long 0x3FE08046
	.long 0x63FFABAC
	.long 0x1FDD00A8
	.long 0x7FDEFA14
	.long 0x887F0004
	.long 0x2C030000
	.long 0x418200B0
	.long 0x3C608045
	.long 0x6063C4A8
	.long 0x886324D0
	.long 0x889F0006
	.long 0x7C032000
	.long 0x40820098
	.long 0x887E0058
	.long 0x2C030003
	.long 0x4182008C
	.long 0x887F0004
	.long 0x2C030007
	.long 0x40820040
	.long 0x887F0006
	.long 0x2C030001
	.long 0x40820024
	.long 0x887F0000
	.long 0x1C6300A8
	.long 0x7C63FA14
	.long 0x8863005F
	.long 0x889E005F
	.long 0x7C032000
	.long 0x41820058
	.long 0x4800005C
	.long 0x887F0000
	.long 0x7C03E800
	.long 0x41820048
	.long 0x4800004C
	.long 0x887F0006
	.long 0x2C030001
	.long 0x40820028
	.long 0x7FE3FB78
	.long 0x3D808016
	.long 0x618C5E70
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x889E005F
	.long 0x7C032000
	.long 0x41820020
	.long 0x48000014
	.long 0x887E005D
	.long 0x2C030000
	.long 0x41820010
	.long 0x48000004
	.long 0x38600000
	.long 0x48000008
	.long 0x38600001
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x4E800020
	.long 0x4E800021
	.long 0xFFD70000
	.long 0x880DB8ED
	.long 0x00000000
	.long 0xC216F404
	.long 0x00000004
	.long 0x981E0010
	.long 0x2C000007
	.long 0x40820014
	.long 0x3C808045
	.long 0x6084C4A8
	.long 0x88840001
	.long 0x989E000C
	.long 0x00000000
	.long -1

SnapPAL_GameVersion_NTSC:
	.long 0xC206960C
	.long 0x0000007E
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x83FE010C
	.long 0x83FF0008
	.long 0x3BFFFFE0
	.long 0x80BD0000
	.long 0x2C05001B
	.long 0x408003B0
	.long 0x48000071
	.long 0x480000AD
	.long 0x480000B9
	.long 0x48000129
	.long 0x48000145
	.long 0x48000145
	.long 0x480001C9
	.long 0x480001D5
	.long 0x48000209
	.long 0x48000261
	.long 0x48000271
	.long 0x48000271
	.long 0x48000271
	.long 0x48000271
	.long 0x4800027D
	.long 0x4800027D
	.long 0x480002C9
	.long 0x480002C9
	.long 0x480002CD
	.long 0x480002CD
	.long 0x480002DD
	.long 0x480002DD
	.long 0x480002E9
	.long 0x480002E9
	.long 0x480002F5
	.long 0x480002F5
	.long 0x480002F5
	.long 0x4800033D
	.long 0x7C8802A6
	.long 0x1CA50004
	.long 0x7C842A14
	.long 0x80A40000
	.long 0x54A501BA
	.long 0x7CA42A14
	.long 0xA0650000
	.long 0x7C600734
	.long 0x2C00FFFF
	.long 0x41820018
	.long 0x80850002
	.long 0x7C63FA14
	.long 0x90830000
	.long 0x38A50006
	.long 0x4BFFFFE0
	.long 0x48000300
	.long 0x33443F5C
	.long 0x28F63360
	.long 0x42C80000
	.long 0xFFFF0000
	.long 0x379C4296
	.long 0x00003908
	.long 0x40C00000
	.long 0x390C4073
	.long 0x33333910
	.long 0x3DCCCCCD
	.long 0x39284190
	.long 0x00003C04
	.long 0x2C01480E
	.long 0x47202416
	.long 0x80134734
	.long 0x24168013
	.long 0x473C0400
	.long 0x000A4A40
	.long 0x2C006812
	.long 0x4A4C281C
	.long 0x00134A50
	.long 0x0F00010B
	.long 0x4A542C80
	.long 0x68124A60
	.long 0x281C0013
	.long 0x4A640F00
	.long 0x010B4B24
	.long 0x2C00680F
	.long 0x4B300C90
	.long 0x40134B38
	.long 0x2C80380F
	.long 0x4B440C90
	.long 0x4013FFFF
	.long 0x380C0000
	.long 0x00044EF8
	.long 0x2C003806
	.long 0x4F081180
	.long 0x000B4F0C
	.long 0x2C802006
	.long 0x4F1C1180
	.long 0x000BFFFF
	.long 0xFFFF0000
	.long 0x4D103FB3
	.long 0x33334D70
	.long 0x428C0000
	.long 0x4DD441A0
	.long 0x00004DE0
	.long 0x41A00000
	.long 0x83A02C00
	.long 0x000883AC
	.long 0x34908011
	.long 0x83F43490
	.long 0x80118424
	.long 0x0400008B
	.long 0x842C03E8
	.long 0x044C8438
	.long 0x0400008B
	.long 0x84D00578
	.long 0x04B085AC
	.long 0x0C00010B
	.long 0x85B403E8
	.long 0x012C85C0
	.long 0x0C00010B
	.long 0x85C80384
	.long 0x032085D4
	.long 0x0C00010B
	.long 0x880C0A00
	.long 0x010B8820
	.long 0x0A00010B
	.long 0x88EC041A
	.long 0x0A8C8930
	.long 0x041A0A8C
	.long 0x8974041A
	.long 0x0A8C89D4
	.long 0x04FEF804
	.long 0xFFFF0000
	.long 0x36CC42EA
	.long 0x000037C4
	.long 0x04000000
	.long 0xFFFF0000
	.long 0x34683F80
	.long 0x000039D8
	.long 0x44000000
	.long 0x3A440019
	.long 0x00113A48
	.long 0x1E0C008F
	.long 0x3A580019
	.long 0x00113A5C
	.long 0x1E0C008F
	.long 0x3A6C0019
	.long 0x00113A70
	.long 0x1E0C008F
	.long 0x3B304400
	.long 0x0000FFFF
	.long 0x45C82C01
	.long 0x501145D4
	.long 0x2D1A4013
	.long 0x45DC2C80
	.long 0xB01145E8
	.long 0x2D1A4013
	.long 0x49C42C00
	.long 0x680C49D0
	.long 0x281E0013
	.long 0x49D82C80
	.long 0x780C49E4
	.long 0x281E0013
	.long 0x49F02C00
	.long 0x680949FC
	.long 0x231E0013
	.long 0x4A042C80
	.long 0x78094A10
	.long 0x231E0013
	.long 0x5C98280C
	.long 0x80005CF4
	.long 0xB4800B50
	.long 0x5D08B480
	.long 0x0B50FFFF
	.long 0x3A1CB491
	.long 0x80133A64
	.long 0x2C000014
	.long 0x3A70B490
	.long 0x4013FFFF
	.long 0xFFFF0000
	.long 0xFFFF0000
	.long 0xFFFF0000
	.long 0x647CB499
	.long 0x00176480
	.long 0x96001097
	.long 0xFFFF0000
	.long 0xFFFF0000
	.long 0x33E442D8
	.long 0x00004528
	.long 0x2C013010
	.long 0x4534B497
	.long 0x8013453C
	.long 0x2C813010
	.long 0x4548B497
	.long 0x80134550
	.long 0x2D002010
	.long 0x455CB497
	.long 0x801345F8
	.long 0x2C01300E
	.long 0x46080D00
	.long 0x010B460C
	.long 0x2C81280E
	.long 0x461C0D00
	.long 0x010B4AEC
	.long 0x2C007004
	.long 0x4B002C80
	.long 0x3804FFFF
	.long 0xFFFF0000
	.long 0x485C2C00
	.long 0x000CFFFF
	.long 0xFFFF0000
	.long 0x37B03F66
	.long 0x666637CC
	.long 0x42AE0000
	.long 0x55209111
	.long 0x8013FFFF
	.long 0xFFFF0000
	.long 0x3B8C4400
	.long 0x00003D0C
	.long 0x44000000
	.long 0xFFFF0000
	.long 0xFFFF0000
	.long 0x50E49119
	.long 0x001350F8
	.long 0x91190013
	.long 0xFFFF0000
	.long 0xFFFF0000
	.long 0xFFFF0000
	.long 0x4EB00320
	.long 0xFF384EBC
	.long 0x1E000123
	.long 0x4EC403E8
	.long 0x01F44ED0
	.long 0x1E000123
	.long 0x4ED80514
	.long 0x04B04EE4
	.long 0x1E000123
	.long 0x505C2C00
	.long 0x6816506C
	.long 0x19080123
	.long 0x50702C80
	.long 0x60165080
	.long 0x19080123
	.long 0x50842D00
	.long 0x20165094
	.long 0x19080123
	.long 0xFFFF0000
	.long 0xFFFF0000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x3C60803C
	.long 0x60000000
	.long 0x00000000
	.long 0xC2124158
	.long 0x00000002
	.long 0x38000000
	.long 0x901E1A5C
	.long 0x3BE00001
	.long 0x00000000
	.long 0xC22669E8
	.long 0x0000001C
	.long 0x981C0477
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x38600000
	.long 0x38800000
	.long 0x3D80803A
	.long 0x618C6664
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7C7F1B78
	.long 0x38800001
	.long 0x989F0049
	.long 0x38800001
	.long 0x989F004A
	.long 0x48000069
	.long 0x7FC802A6
	.long 0xC03E000C
	.long 0xD03F0024
	.long 0xD03F0028
	.long 0x3C60FFFF
	.long 0x6063FF00
	.long 0x907F0030
	.long 0xC03E0000
	.long 0xC05E0004
	.long 0x7FE3FB78
	.long 0x48000051
	.long 0x7C8802A6
	.long 0x3D80803A
	.long 0x618C6B54
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FE3FB78
	.long 0x38800000
	.long 0xC03E0008
	.long 0xC05E0008
	.long 0x3D80803A
	.long 0x618C74FC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000024
	.long 0x4E800021
	.long 0xC402C000
	.long 0xC43B8000
	.long 0x3FC00000
	.long 0x3D0F5C29
	.long 0x4E800021
	.long 0x76322E31
	.long 0x00000000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x60000000
	.long 0x00000000
	.long 0xC226706C
	.long 0x0000004F
	.long 0x48000031
	.long 0x7C8802A6
	.long 0x80630020
	.long 0x3CA00004
	.long 0x60A5BE00
	.long 0x7C632A14
	.long 0x38A00238
	.long 0x3D808000
	.long 0x618C31F4
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000244
	.long 0x4E800021
	.long 0x01000000
	.long 0x01000000
	.long 0x01FFC00F
	.long 0x01FFE00F
	.long 0x01FFD80F
	.long 0x01FF7D0F
	.long 0x01FF0E4F
	.long 0x01FF0BBF
	.long 0x01000000
	.long 0x01000000
	.long 0xF7FFFFFF
	.long 0xF000FF00
	.long 0xF000FF00
	.long 0xF000FF00
	.long 0xF000FF00
	.long 0xF000FF00
	.long 0x01000000
	.long 0x01000000
	.long 0x72DEFFD4
	.long 0x0DF408FE
	.long 0x0FFB00CC
	.long 0x0BFFEB00
	.long 0x01CFFFE4
	.long 0x0104DFFE
	.long 0x01000000
	.long 0x01000000
	.long 0x01AEFEC0
	.long 0x08FC08FD
	.long 0x0EF700FE
	.long 0x0FF00000
	.long 0x0FF00000
	.long 0x0FF00000
	.long 0x04FF9888
	.long 0x01CFB888
	.long 0x019FC888
	.long 0x016FD888
	.long 0x014FE888
	.long 0x012FF888
	.long 0x010FF888
	.long 0x012FF888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x8888888E
	.long 0x888888DF
	.long 0x88888CFF
	.long 0x8888AFF7
	.long 0x8889FFA0
	.long 0x888FFC00
	.long 0x8DFFB100
	.long 0xEFF60000
	.long 0xFF400000
	.long 0xF3000000
	.long 0x40000000
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01000000
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x01010101
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x88888888
	.long 0x8888EF40
	.long 0x8888DF60
	.long 0x8888CF90
	.long 0x8888BFC0
	.long 0x88889FF4
	.long 0x88888DF9
	.long 0x88888BFE
	.long 0x888888EF
	.long 0x01FF02FF
	.long 0x01FF00DF
	.long 0x01FF008F
	.long 0x01000000
	.long 0x01000000
	.long 0x01000000
	.long 0x30000000
	.long 0x90000000
	.long 0xF000FF00
	.long 0xF000FF00
	.long 0xF000FF00
	.long 0x01000000
	.long 0x01000000
	.long 0x01000000
	.long 0x01000000
	.long 0x01000000
	.long 0x0FF007FF
	.long 0x0DF804FE
	.long 0x02DEFFE5
	.long 0x01000000
	.long 0x01000000
	.long 0x01000000
	.long 0x01000000
	.long 0x01000000
	.long 0x0EF700FF
	.long 0x08FC0AFC
	.long 0x00AFFEC0
	.long 0x01000000
	.long 0x01000000
	.long 0x01000000
	.long 0x01000000
	.long 0x01000000
	.long 0x014FE888
	.long 0x016FD888
	.long 0x019FC888
	.long 0x01CFB888
	.long 0x04FF9888
	.long 0x09FD8888
	.long 0x3EFB8888
	.long 0x387E0674
	.long 0x00000000
	.long 0xC2017264
	.long 0x00000008
	.long 0x808DB954
	.long 0x80840020
	.long 0x3884FFE0
	.long 0x4800001D
	.long 0x7CC802A6
	.long 0xA0A60002
	.long 0x7C842A14
	.long 0x80A60004
	.long 0x90A40000
	.long 0x48000010
	.long 0x4E800021
	.long 0xFFFF5614
	.long 0x3F32F1AA
	.long 0x80010034
	.long 0x60000000
	.long 0x00000000
	.long 0xC2079DB4
	.long 0x00000002
	.long 0x98180DCE
	.long 0x3A400001
	.long 0x60000000
	.long 0x00000000
	.long 0xC22FA12C
	.long 0x00000003
	.long 0x3C003F93
	.long 0x60003333
	.long 0x901D002C
	.long 0x901D0030
	.long 0x3C00C1B0
	.long 0x00000000
	.long 0xC22F90E0
	.long 0x00000011
	.long 0x48000075
	.long 0x7C6802A6
	.long 0xC0030000
	.long 0xC0430004
	.long 0x80780010
	.long 0xC0380038
	.long 0xEC211028
	.long 0xD0380038
	.long 0xFC200090
	.long 0x38800005
	.long 0x48000009
	.long 0x48000054
	.long 0x3484FFFF
	.long 0x7C0802A6
	.long 0x9421FFF0
	.long 0x90010014
	.long 0x90610008
	.long 0x41800020
	.long 0x80630008
	.long 0x4BFFFFE5
	.long 0x80610008
	.long 0xC0430038
	.long 0xEC42082A
	.long 0xEC21002A
	.long 0xD0430038
	.long 0x80010014
	.long 0x38210010
	.long 0x7C0803A6
	.long 0x4E800020
	.long 0x4E800021
	.long 0x3EAA7EFA
	.long 0x3F000000
	.long 0xBAC10050
	.long 0x00000000
	.long 0x043CEB4C
	.long 0x00200000
	.long 0xC21103F8
	.long 0x00000002
	.long 0x3C008010
	.long 0x6000DF28
	.long 0x60000000
	.long 0x00000000
	.long 0xC2110318
	.long 0x00000002
	.long 0x3C008010
	.long 0x6000DF28
	.long 0x60000000
	.long 0x00000000
	.long 0xC22B8528
	.long 0x00000012
	.long 0x887F2240
	.long 0x2C030002
	.long 0x41820054
	.long 0x40800014
	.long 0x2C030000
	.long 0x41820018
	.long 0x4080002C
	.long 0x4800006C
	.long 0x2C030004
	.long 0x40800064
	.long 0x4800004C
	.long 0x801F065C
	.long 0x54000739
	.long 0x41820054
	.long 0x38030001
	.long 0x981F2240
	.long 0x48000048
	.long 0x801F065C
	.long 0x5400077B
	.long 0x4182003C
	.long 0x38030001
	.long 0x981F2240
	.long 0x48000030
	.long 0x801F065C
	.long 0x54000739
	.long 0x41820024
	.long 0x38030001
	.long 0x981F2240
	.long 0x48000018
	.long 0x801F0668
	.long 0x540005EF
	.long 0x4182000C
	.long 0x38030001
	.long 0x981F2240
	.long 0x60000000
	.long 0x00000000
	.long 0xC22B86D8
	.long 0x00000013
	.long 0x80A3002C
	.long 0x83C40004
	.long 0x88652240
	.long 0x3B850000
	.long 0x2C030002
	.long 0x41820054
	.long 0x40800014
	.long 0x2C030000
	.long 0x41820018
	.long 0x4080002C
	.long 0x4800006C
	.long 0x2C030004
	.long 0x40800064
	.long 0x4800004C
	.long 0x801C065C
	.long 0x54000739
	.long 0x41820054
	.long 0x38030001
	.long 0x981C2240
	.long 0x48000048
	.long 0x801C065C
	.long 0x5400077B
	.long 0x4182003C
	.long 0x38030001
	.long 0x981C2240
	.long 0x48000030
	.long 0x801C065C
	.long 0x54000739
	.long 0x41820024
	.long 0x38030001
	.long 0x981C2240
	.long 0x48000018
	.long 0x801C0668
	.long 0x540005EF
	.long 0x4182000C
	.long 0x38030001
	.long 0x981C2240
	.long 0x00000000
	.long -1
SnapPAL_GameVersion_PAL:
	.long 0x0406960C
	.long 0x3C60803C
	.long 0x04124158
	.long 0x3BE00001
	.long 0x042669E8
	.long 0x981C0477
	.long 0x0426706C
	.long 0x387E0674
	.long 0x04017264
	.long 0x80010034
	.long 0x04079DB4
	.long 0x98180DCE
	.long 0x042FA12C
	.long 0x80160004
	.long 0x042F90E0
	.long 0xBAC10050
	.long 0x043CEB4C
	.long 0x00240464
	.long 0x041103F0
	.long 0x38030828
	.long 0x04110310
	.long 0x38030828
	.long 0x042B8528
	.long 0x981F2240
	.long 0x042B86D8
	.long 0x981C2240
	.long -1
SnapPAL_GameVersion_SDR:
	.long 0xC206960C
	.long 0x00000B0B
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x83FE010C
	.long 0x83FF0008
	.long 0x3BFFFFE0
	.long 0x807D0000
	.long 0x2C03001B
	.long 0x40805818
	.long 0x48000071
	.long 0x480000FD
	.long 0x480003F5
	.long 0x480003F5
	.long 0x480003F5
	.long 0x48000A8D
	.long 0x4800114D
	.long 0x48001895
	.long 0x48001E7D
	.long 0x48001E7D
	.long 0x480023AD
	.long 0x480023AD
	.long 0x480024A5
	.long 0x4800259D
	.long 0x480027FD
	.long 0x48002CCD
	.long 0x480030E5
	.long 0x480030E5
	.long 0x48003595
	.long 0x480037FD
	.long 0x480037FD
	.long 0x48003EB5
	.long 0x48004575
	.long 0x48004635
	.long 0x48004635
	.long 0x48004B65
	.long 0x48004E0D
	.long 0x4800510D
	.long 0x7C8802A6
	.long 0x1C630004
	.long 0x7C841A14
	.long 0x80A40000
	.long 0x54A501BA
	.long 0x7CA42A14
	.long 0x80650000
	.long 0x80850004
	.long 0x7C600774
	.long 0x2C00FFFF
	.long 0x41820064
	.long 0x5460463E
	.long 0x2C0000CC
	.long 0x41820038
	.long 0x2C0000CD
	.long 0x41820008
	.long 0x4800003C
	.long 0x5463023E
	.long 0x80E50008
	.long 0x2C040000
	.long 0x41820014
	.long 0x3884FFFC
	.long 0x7D1F1A14
	.long 0x7CE8212E
	.long 0x4BFFFFEC
	.long 0x38A5000C
	.long 0x4BFFFFB0
	.long 0x5463023E
	.long 0x7C84FA14
	.long 0x38840020
	.long 0x48000004
	.long 0x7C63FA14
	.long 0x90830000
	.long 0x38A50008
	.long 0x4BFFFF90
	.long 0x48005718
	.long 0x00003300
	.long 0x3FC9999A
	.long 0x0000333C
	.long 0x3D2E147B
	.long 0x00003344
	.long 0x3F70A3D7
	.long 0x000033D0
	.long 0x41A00000
	.long 0x0000349C
	.long 0x3F800000
	.long 0x000034B4
	.long 0x3FC00000
	.long 0x000040A8
	.long 0xB497C013
	.long 0x000040AC
	.long 0x0F00008B
	.long 0x000040BC
	.long 0xB497C013
	.long 0x000040C0
	.long 0x0F00008B
	.long 0x00004130
	.long 0x2C81B809
	.long 0x00004134
	.long 0x03200190
	.long 0x00004138
	.long 0x00000000
	.long 0x00004180
	.long 0x2C81B807
	.long 0x00004184
	.long 0x02BC0190
	.long 0x00004188
	.long 0x00000000
	.long 0x0000419C
	.long 0x08000022
	.long 0x00004298
	.long 0xB4990013
	.long 0x000042AC
	.long 0xB4990013
	.long 0x000042C0
	.long 0xB4990013
	.long 0x0000434C
	.long 0x0800001A
	.long 0x000043E0
	.long 0x08000015
	.long 0x0000445C
	.long 0x2C800010
	.long 0x00004468
	.long 0xB4990013
	.long 0x00004470
	.long 0x2D00E810
	.long 0x0000447C
	.long 0xB4990013
	.long 0x00004534
	.long 0x2C80000F
	.long 0x00004540
	.long 0xB4990013
	.long 0x00004548
	.long 0x2D00E80F
	.long 0x00004554
	.long 0xB4990013
	.long 0x0000460C
	.long 0x2C80000E
	.long 0x00004618
	.long 0xB4990013
	.long 0x00004620
	.long 0x2D00E80E
	.long 0x0000462C
	.long 0xB4990013
	.long 0x000047FC
	.long 0x2C01B80D
	.long 0x00004800
	.long 0x02EE00C8
	.long 0x0000480C
	.long 0x0C80010B
	.long 0x00004810
	.long 0x2C81880D
	.long 0x00004814
	.long 0x02EE00C8
	.long 0x00004820
	.long 0x0C80010B
	.long 0x0000483C
	.long 0x02EE00C8
	.long 0x00004850
	.long 0x02EE00C8
	.long 0x000048A8
	.long 0x2C00F80E
	.long 0x000048B4
	.long 0x8C168013
	.long 0x000048B8
	.long 0x0B000107
	.long 0x000048BC
	.long 0x2C81000E
	.long 0x000048C8
	.long 0x8C168013
	.long 0x000048CC
	.long 0x0B000107
	.long 0x000048EC
	.long 0x0800003A
	.long 0x00004918
	.long 0x11990013
	.long 0x0000491C
	.long 0x0780010B
	.long 0x0000492C
	.long 0x11990013
	.long 0x00004930
	.long 0x0780010B
	.long 0x000049E0
	.long 0x08000018
	.long 0x00004A1C
	.long 0x281903D3
	.long 0x00004A30
	.long 0x281903D3
	.long 0x00004A44
	.long 0x281903D3
	.long 0x00004A7C
	.long 0x08000021
	.long 0x00004B18
	.long 0x04000006
	.long 0x00005A84
	.long 0x03B60000
	.long 0x00005A98
	.long 0x03B60000
	.long 0x00005ADC
	.long 0x03B60000
	.long 0x00005AF0
	.long 0x03B60000
	.long 0x00005B04
	.long 0x03B60000
	.long 0x00006A00
	.long 0x08000002
	.long 0x00006A04
	.long 0x4C000001
	.long 0x00006A08
	.long 0x08000004
	.long 0x00006A0C
	.long 0x2C01B00B
	.long 0x00006A10
	.long 0x0384012C
	.long 0x00006A18
	.long 0x1B990013
	.long 0x00006A1C
	.long 0x0000008B
	.long 0x00006A20
	.long 0x2C81B80B
	.long 0x00006A24
	.long 0x04B00320
	.long 0x00006A2C
	.long 0x1B990013
	.long 0x00006A30
	.long 0x0000008B
	.long 0x00006A34
	.long 0x44040000
	.long 0x00006A38
	.long 0x000000A5
	.long 0x00006A3C
	.long 0x00007F40
	.long 0x00006A40
	.long 0xAC020000
	.long 0x00006A44
	.long 0x08000006
	.long 0x00006A48
	.long 0x2C01B00B
	.long 0x00006A4C
	.long 0x0384012C
	.long 0x00006A54
	.long 0x20990013
	.long 0x00006A58
	.long 0x0000008B
	.long 0x00006A5C
	.long 0x2C81B80B
	.long 0x00006A60
	.long 0x04B00320
	.long 0x00006A68
	.long 0x20990013
	.long 0x00006A6C
	.long 0x0000008B
	.long 0x00006A70
	.long 0x0800000A
	.long 0x00006A74
	.long 0x40000000
	.long 0x00006A78
	.long 0x08000010
	.long 0x00006A7C
	.long 0x4C000000
	.long 0x00006A80
	.long 0x08000018
	.long 0x00006A84
	.long 0x5C000000
	.long 0xCC0075F4
	.long 0x000069E0
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x00003A38
	.long 0x42E80000
	.long 0x00003A40
	.long 0x41AF0000
	.long 0x00003B6C
	.long 0x00000000
	.long 0x00003B8C
	.long 0x3FE00000
	.long 0x00003B90
	.long 0x3D4CCCCD
	.long 0x00003B94
	.long 0x3D8F5C29
	.long 0x00003C4C
	.long 0x04600000
	.long 0x00003C60
	.long 0x06900000
	.long 0x00003C78
	.long 0x04600000
	.long 0x00003C8C
	.long 0x06900000
	.long 0x00003D18
	.long 0x2C00F014
	.long 0x00003D1C
	.long 0x04600000
	.long 0x00003D2C
	.long 0x2C80F814
	.long 0x00003D30
	.long 0x06900000
	.long 0x00003D40
	.long 0x2D002014
	.long 0x00003D44
	.long 0x02940000
	.long 0x00003D60
	.long 0x04600000
	.long 0x00003D74
	.long 0x06900000
	.long 0x00003D88
	.long 0x01260000
	.long 0x00003E88
	.long 0x04600000
	.long 0x00003E9C
	.long 0x06900000
	.long 0x00003EB4
	.long 0x04600000
	.long 0x00003EC8
	.long 0x06900000
	.long 0x00003F58
	.long 0x2C00F012
	.long 0x00003F5C
	.long 0x04600000
	.long 0x00003F6C
	.long 0x2C80F812
	.long 0x00003F70
	.long 0x06900000
	.long 0x00003F80
	.long 0x2D002012
	.long 0x00003F84
	.long 0x01260000
	.long 0x00003FA0
	.long 0x04600000
	.long 0x00003FB4
	.long 0x06900000
	.long 0x00003FC8
	.long 0x02940000
	.long 0x00004074
	.long 0x2C00000D
	.long 0x00004088
	.long 0x2C80000D
	.long 0x0000409C
	.long 0x2D00000D
	.long 0x00004100
	.long 0x2C00000D
	.long 0x00004114
	.long 0x2C80000D
	.long 0x00004164
	.long 0x2C00E80A
	.long 0x00004168
	.long 0x0640FE0C
	.long 0x0000416C
	.long 0x012C0000
	.long 0x000041C4
	.long 0x19000D07
	.long 0x000041D8
	.long 0x19000D07
	.long 0x000041EC
	.long 0x19000D07
	.long 0x00004234
	.long 0x0A000807
	.long 0x00004248
	.long 0x0A000807
	.long 0x0000425C
	.long 0x0A000807
	.long 0x000042C0
	.long 0x44000000
	.long 0x000042C4
	.long 0x0000009F
	.long 0x000042C8
	.long 0x00007F40
	.long 0x000042CC
	.long 0x68000002
	.long 0x000042D0
	.long 0x2C00E80A
	.long 0x000042D4
	.long 0x064006A9
	.long 0x000042D8
	.long 0x00000000
	.long 0x000042DC
	.long 0xB4940013
	.long 0x000042E0
	.long 0x14000507
	.long 0x000042E4
	.long 0x2C81980A
	.long 0x000042E8
	.long 0x064006A9
	.long 0x000042EC
	.long 0x00000000
	.long 0x000042F0
	.long 0xB4940013
	.long 0x000042F4
	.long 0x14000507
	.long 0x000042F8
	.long 0x28000000
	.long 0x000042FC
	.long 0x04060000
	.long 0x00004300
	.long 0x00000000
	.long 0x0000430C
	.long 0x08000006
	.long 0x00004310
	.long 0x40000000
	.long 0x00004314
	.long 0x68000000
	.long 0x00004318
	.long 0x0800000B
	.long 0x0000431C
	.long 0x70B00002
	.long 0x00004348
	.long 0x0A000D07
	.long 0x0000435C
	.long 0x0A000D07
	.long 0x00004370
	.long 0x0A000D07
	.long 0x000043B8
	.long 0x00000807
	.long 0x000043CC
	.long 0x00000807
	.long 0x000043E0
	.long 0x00000807
	.long 0x00004440
	.long 0x87140010
	.long 0x00004444
	.long 0x3200050A
	.long 0x00004454
	.long 0x87140010
	.long 0x00004458
	.long 0x3200050A
	.long 0x00004468
	.long 0x87140010
	.long 0x0000446C
	.long 0x3200050A
	.long 0x0000447C
	.long 0x87140010
	.long 0x00004480
	.long 0x3200050A
	.long 0x000044CC
	.long 0x87140010
	.long 0x000044D0
	.long 0x3700050A
	.long 0x000044E0
	.long 0x87140010
	.long 0x000044E4
	.long 0x3700050A
	.long 0x000044F4
	.long 0x87140010
	.long 0x000044F8
	.long 0x3700050A
	.long 0x00004508
	.long 0x87140010
	.long 0x0000450C
	.long 0x3700050A
	.long 0x00004C54
	.long 0x04B00700
	.long 0x00004C5C
	.long 0x32190013
	.long 0x00004C84
	.long 0x32190013
	.long 0x00004CC8
	.long 0x04A80700
	.long 0x00004CD0
	.long 0x23190013
	.long 0x00004CD4
	.long 0x14000087
	.long 0x00004CE4
	.long 0x23190013
	.long 0x00004CE8
	.long 0x14000087
	.long 0x00004CF8
	.long 0x23190013
	.long 0x00004CFC
	.long 0x14000087
	.long 0x00004DB4
	.long 0x08000024
	.long 0x00004DC8
	.long 0x2C00E80D
	.long 0x00004DCC
	.long 0x04B002A9
	.long 0x00004DD8
	.long 0x07800107
	.long 0x00004DDC
	.long 0x2C80F00D
	.long 0x00004DE0
	.long 0x053C0514
	.long 0x00004DEC
	.long 0x07800107
	.long 0x00004DF0
	.long 0x2D00E80D
	.long 0x00004DF4
	.long 0x038CFF01
	.long 0x00004E00
	.long 0x07800107
	.long 0x00004E04
	.long 0x2D81580D
	.long 0x00004E08
	.long 0x04EC0000
	.long 0x00004E14
	.long 0x07800107
	.long 0x00004E58
	.long 0x2C00E80C
	.long 0x00004E5C
	.long 0x04B002A9
	.long 0x00004E6C
	.long 0x2C80F00C
	.long 0x00004E70
	.long 0x053C0514
	.long 0x00004E80
	.long 0x2D00E80C
	.long 0x00004E84
	.long 0x038CFF01
	.long 0x00004E94
	.long 0x2D81580C
	.long 0x00004E98
	.long 0x04EC0000
	.long 0x00004EE8
	.long 0x2C00E80B
	.long 0x00004EEC
	.long 0x04CF02A9
	.long 0x00004EFC
	.long 0x2C80F00B
	.long 0x00004F00
	.long 0x053C0514
	.long 0x00004F10
	.long 0x2D00E80B
	.long 0x00004F14
	.long 0x038CFF01
	.long 0x00004F24
	.long 0x2D81580B
	.long 0x00004F28
	.long 0x04EC0000
	.long 0x00004F74
	.long 0x08000005
	.long 0x00004F78
	.long 0x2C01A00A
	.long 0x00004F7C
	.long 0x03E805AA
	.long 0x00004F84
	.long 0x321B8013
	.long 0x00004FA4
	.long 0x04B00119
	.long 0x00004FC4
	.long 0x04000008
	.long 0x00004FCC
	.long 0x08000024
	.long 0x00004FF4
	.long 0x2C019808
	.long 0x00004FF8
	.long 0x045E02A9
	.long 0x00005008
	.long 0x2C81A008
	.long 0x0000500C
	.long 0x053206A4
	.long 0x00005014
	.long 0xB4940013
	.long 0x0000501C
	.long 0x2D015808
	.long 0x00005020
	.long 0x05960000
	.long 0x00005028
	.long 0xB4940013
	.long 0x000050D4
	.long 0x05DC0000
	.long 0x000050E0
	.long 0x0F004107
	.long 0x000050E8
	.long 0x06A40000
	.long 0x000050F4
	.long 0x0F004107
	.long 0x000050FC
	.long 0x04800000
	.long 0x00005108
	.long 0x09004087
	.long 0x00005110
	.long 0x03840000
	.long 0x0000511C
	.long 0x09004087
	.long 0x00005128
	.long 0x08000032
	.long 0x000051C0
	.long 0x2C01A013
	.long 0x000051C4
	.long 0x06D607F1
	.long 0x000051D0
	.long 0x14005107
	.long 0x000051D4
	.long 0x2C80F013
	.long 0x000051D8
	.long 0x06D607F1
	.long 0x000051E4
	.long 0x14005107
	.long 0x000051F4
	.long 0x04000021
	.long 0x0000524C
	.long 0x2C01A011
	.long 0x0000525C
	.long 0x11804107
	.long 0x00005260
	.long 0x2C80F011
	.long 0x00005270
	.long 0x11804107
	.long 0x00005284
	.long 0x11804107
	.long 0x00005298
	.long 0x11804107
	.long 0x00005308
	.long 0x0800002C
	.long 0x00005310
	.long 0x08000033
	.long 0x00005334
	.long 0x04FE03FE
	.long 0x00005340
	.long 0x0A000107
	.long 0x00005348
	.long 0x04FE03FE
	.long 0x00005354
	.long 0x0A000107
	.long 0x0000535C
	.long 0x06FC0000
	.long 0x00005368
	.long 0x0A000107
	.long 0x00005384
	.long 0x04FE05FD
	.long 0x00005390
	.long 0x05000107
	.long 0x00005398
	.long 0x04FE05FD
	.long 0x000053A4
	.long 0x05000107
	.long 0x000053AC
	.long 0x06FC0000
	.long 0x000053B8
	.long 0x05000107
	.long 0x0000540C
	.long 0x0F003907
	.long 0x00005420
	.long 0x0F003907
	.long 0x00005434
	.long 0x0F003907
	.long 0x00005448
	.long 0x0F003907
	.long 0x00005484
	.long 0x1900390B
	.long 0x00005498
	.long 0x1900390B
	.long 0x000054A8
	.long 0xB4940013
	.long 0x000054AC
	.long 0x1900390B
	.long 0x000054BC
	.long 0xB4940013
	.long 0x000054C0
	.long 0x1900390B
	.long 0x000054CC
	.long 0x08000037
	.long 0x000054F8
	.long 0x06A40000
	.long 0x00005504
	.long 0x0A00010B
	.long 0x0000550C
	.long 0x05DC0000
	.long 0x00005518
	.long 0x0A00010B
	.long 0x00005534
	.long 0x06400000
	.long 0x00005540
	.long 0x0500008B
	.long 0x00005548
	.long 0x05780000
	.long 0x00005554
	.long 0x0500008B
	.long 0x000055C4
	.long 0x04000004
	.long 0x00005608
	.long 0x08980352
	.long 0x0000561C
	.long 0x07D002A9
	.long 0x00005630
	.long 0x06400000
	.long 0x000060FC
	.long 0x08000014
	.long 0x000065A0
	.long 0x0400000B
	.long 0x0000672C
	.long 0x05781130
	.long 0x00006740
	.long 0x05780A8C
	.long 0x00006794
	.long 0x05780D48
	.long 0x000067A8
	.long 0x05780834
	.long 0x000067BC
	.long 0x05780320
	.long 0x00007CE8
	.long 0x00000000
	.long 0xFFFFFFFF
	.long 0x00004D00
	.long 0x3D75C28F
	.long 0x00004D10
	.long 0x3FC00000
	.long 0x00004D34
	.long 0x3FA00000
	.long 0x00004D4C
	.long 0x3DA3D70A
	.long 0x00004D50
	.long 0x3CF5C28F
	.long 0x00004D54
	.long 0x3F79999A
	.long 0x00004D70
	.long 0x42940000
	.long 0x00004DD4
	.long 0x41700000
	.long 0x00004DE0
	.long 0x41700000
	.long 0x00004EF8
	.long 0x42200000
	.long 0x00004F3C
	.long 0x49742400
	.long 0x00005028
	.long 0x00000000
	.long 0x00005030
	.long 0x0000000F
	.long 0x00005048
	.long 0x00000000
	.long 0x00005200
	.long 0x00000007
	.long 0x00005240
	.long 0x3F4CCCCD
	.long 0x00005260
	.long 0x00000001
	.long 0x00005270
	.long 0x41700000
	.long 0x000052E0
	.long 0x000004B0
	.long 0x00005308
	.long 0x0000157C
	.long 0x00005310
	.long 0x00200087
	.long 0x0000531C
	.long 0x000008FC
	.long 0x000053A0
	.long 0x05DC0000
	.long 0x000053A4
	.long 0x000005DC
	.long 0x00005494
	.long 0x8800000F
	.long 0x00005574
	.long 0x2C016017
	.long 0x00005580
	.long 0x1E130015
	.long 0x00005584
	.long 0x2080510B
	.long 0x00005588
	.long 0x2C816017
	.long 0x00005594
	.long 0x1E130015
	.long 0x00005598
	.long 0x2080510B
	.long 0x000055A0
	.long 0x04E20000
	.long 0x000055AC
	.long 0x2080510B
	.long 0x00005644
	.long 0x05460000
	.long 0x0000564C
	.long 0xB4918007
	.long 0x00005650
	.long 0x1E00010B
	.long 0x00005658
	.long 0x03200000
	.long 0x00005660
	.long 0xB4918007
	.long 0x00005664
	.long 0x1E00010B
	.long 0x0000567C
	.long 0x05460000
	.long 0x00005684
	.long 0x0F118007
	.long 0x00005688
	.long 0x1E000007
	.long 0x00005690
	.long 0x03200000
	.long 0x00005698
	.long 0x0F118007
	.long 0x0000569C
	.long 0x1E000007
	.long 0x000057CC
	.long 0x2C016004
	.long 0x000057D8
	.long 0x89990017
	.long 0x000057DC
	.long 0x280C010F
	.long 0x000057F4
	.long 0xCC000000
	.long 0xCC005894
	.long 0x0000AB90
	.long 0x0000598C
	.long 0x03520000
	.long 0x00005994
	.long 0x23168013
	.long 0x00005998
	.long 0x2080510B
	.long 0x00006158
	.long 0xCC000000
	.long 0x000061C0
	.long 0xCC000000
	.long 0x00006F78
	.long 0x44040000
	.long 0x00006F7C
	.long 0x00041F6F
	.long 0x00006F80
	.long 0x00007F40
	.long 0x00006F84
	.long 0x28000000
	.long 0x00006F88
	.long 0x04230000
	.long 0x00006F8C
	.long 0x00000000
	.long 0x00006F98
	.long 0x0C000005
	.long 0x00006F9C
	.long 0x2C000001
	.long 0x00006FA0
	.long 0x05780000
	.long 0x00006FA4
	.long 0x05DCFC18
	.long 0x00006FA8
	.long 0x5A000011
	.long 0x00006FAC
	.long 0x150C008F
	.long 0x00006FB0
	.long 0x2C800001
	.long 0x00006FB4
	.long 0x05780000
	.long 0x00006FB8
	.long 0x05DC03E8
	.long 0x00006FBC
	.long 0x5A000011
	.long 0x00006FC0
	.long 0x150C008F
	.long 0x00006FC4
	.long 0x2D000002
	.long 0x00006FC8
	.long 0x06A40000
	.long 0x00006FCC
	.long 0x05DCF448
	.long 0x00006FD0
	.long 0x5A000011
	.long 0x00006FD4
	.long 0x0B8C000F
	.long 0x00006FD8
	.long 0x2D800002
	.long 0x00006FDC
	.long 0x06A40000
	.long 0x00006FE0
	.long 0x05DC0BB8
	.long 0x00006FE4
	.long 0x5A000011
	.long 0x00006FE8
	.long 0x0B8C000F
	.long 0x00006FEC
	.long 0x04000001
	.long 0x00006FF0
	.long 0x40000000
	.long 0x00006FF4
	.long 0x68000000
	.long 0x00007004
	.long 0x08980000
	.long 0x00007010
	.long 0x1E0C0123
	.long 0x00007018
	.long 0x08980000
	.long 0x00007024
	.long 0x1E0C0123
	.long 0x0000702C
	.long 0x07080000
	.long 0x00007038
	.long 0x1E0C00A3
	.long 0x00007040
	.long 0x07080000
	.long 0x0000704C
	.long 0x1E0C00A3
	.long 0x00007594
	.long 0x2C016007
	.long 0x000075A8
	.long 0x2C816007
	.long 0x000075BC
	.long 0x2D002807
	.long 0x000075D0
	.long 0x2D811807
	.long 0x00007954
	.long 0x8800000B
	.long 0x00007BEC
	.long 0x3F666666
	.long 0x00007FA4
	.long 0x08000019
	.long 0x000083A0
	.long 0x2C00000D
	.long 0x000083A4
	.long 0x05140000
	.long 0x000083AC
	.long 0xB4968011
	.long 0x000083B0
	.long 0x190400A3
	.long 0x000083E8
	.long 0x2C00000A
	.long 0x000083EC
	.long 0x044C0000
	.long 0x000083F4
	.long 0xB4968011
	.long 0x000083F8
	.long 0x0F040023
	.long 0x00008404
	.long 0x08000035
	.long 0x00008420
	.long 0x10990013
	.long 0x00008434
	.long 0x10990013
	.long 0x000084E8
	.long 0x08000015
	.long 0x00008550
	.long 0x08000015
	.long 0x000085A8
	.long 0x13190013
	.long 0x000085AC
	.long 0x1500010B
	.long 0x000085B4
	.long 0x03E801F4
	.long 0x000085BC
	.long 0x13190013
	.long 0x000085C0
	.long 0x1500010B
	.long 0x000085C8
	.long 0x038403E8
	.long 0x000085D0
	.long 0x13190013
	.long 0x000085D4
	.long 0x1500010B
	.long 0x00008600
	.long 0x2C01880E
	.long 0x0000860C
	.long 0x13180013
	.long 0x00008610
	.long 0x0D00008B
	.long 0x00008614
	.long 0x2C81880E
	.long 0x00008618
	.long 0x03B601F4
	.long 0x00008620
	.long 0x13180013
	.long 0x00008624
	.long 0x0D00008B
	.long 0x00008628
	.long 0x2D01880E
	.long 0x0000862C
	.long 0x02BC0384
	.long 0x00008634
	.long 0x13180013
	.long 0x00008638
	.long 0x0D00008B
	.long 0x00008704
	.long 0x2C1D8013
	.long 0x00008708
	.long 0x0F00010F
	.long 0x00008718
	.long 0x2C1D8013
	.long 0x0000871C
	.long 0x0F00010F
	.long 0x00008720
	.long 0x2D01B80E
	.long 0x0000872C
	.long 0x2C1B8013
	.long 0x00008730
	.long 0x0F000107
	.long 0x00008734
	.long 0x04000004
	.long 0x00008744
	.long 0x19190013
	.long 0x00008748
	.long 0x0A00008B
	.long 0x00008758
	.long 0x19190013
	.long 0x0000875C
	.long 0x0A00008B
	.long 0x00008760
	.long 0x2D01B80D
	.long 0x0000876C
	.long 0x19190013
	.long 0x00008770
	.long 0x0A00008B
	.long 0x00008774
	.long 0x08000017
	.long 0x000087E0
	.long 0xB4990013
	.long 0x000087F4
	.long 0xB4990013
	.long 0x0000880C
	.long 0x0B00010B
	.long 0x00008820
	.long 0x0B00010B
	.long 0x00008888
	.long 0x05780000
	.long 0x00008890
	.long 0x14190013
	.long 0x00008894
	.long 0x0A000087
	.long 0x000088AC
	.long 0x3000000C
	.long 0x000088B4
	.long 0x30000009
	.long 0x000088BC
	.long 0x30000008
	.long 0x000088EC
	.long 0x041A0BB8
	.long 0x000088F0
	.long 0x1683C013
	.long 0x000088F4
	.long 0x1180008B
	.long 0x00008904
	.long 0x1683C013
	.long 0x00008908
	.long 0x1180008B
	.long 0x00008928
	.long 0x2C000004
	.long 0x00008930
	.long 0x041A0BB8
	.long 0x00008934
	.long 0x2083C013
	.long 0x00008938
	.long 0x0E00008B
	.long 0x0000893C
	.long 0x2C800004
	.long 0x00008948
	.long 0x2083C013
	.long 0x0000894C
	.long 0x0E00008B
	.long 0x00008970
	.long 0x06180000
	.long 0x00008974
	.long 0x041A0BB8
	.long 0x00008984
	.long 0x06180000
	.long 0x00008A4C
	.long 0x08000009
	.long 0x00008A78
	.long 0x04000006
	.long 0x00008A80
	.long 0x04000006
	.long 0x00008AC0
	.long 0x0A00008B
	.long 0x00008AD4
	.long 0x0A00008B
	.long 0x00008B1C
	.long 0x2C000005
	.long 0x00008B24
	.long 0x04FE0752
	.long 0x00008B28
	.long 0x30118013
	.long 0x00008B2C
	.long 0x2080008B
	.long 0x00008B30
	.long 0x2C800005
	.long 0x00008B34
	.long 0x047E0000
	.long 0x00008B38
	.long 0x04FE0354
	.long 0x00008B3C
	.long 0x30118013
	.long 0x00008B40
	.long 0x2080008B
	.long 0x00008B5C
	.long 0x2C000005
	.long 0x00008B60
	.long 0x00000000
	.long 0x00008B68
	.long 0x30118013
	.long 0x00008B6C
	.long 0x20800088
	.long 0x00008B70
	.long 0x2C800005
	.long 0x00008B74
	.long 0x00000000
	.long 0x00008B7C
	.long 0x30118013
	.long 0x00008B80
	.long 0x20800088
	.long 0x00008BF8
	.long 0x2A0C8A13
	.long 0x00008BFC
	.long 0x0A00010B
	.long 0x00008C0C
	.long 0x2A0C8A13
	.long 0x00008C10
	.long 0x0A00010B
	.long 0x000092E8
	.long 0xCC000000
	.long 0x00009C38
	.long 0x208A0000
	.long 0x00009C3C
	.long 0x23022000
	.long 0x00009CD8
	.long 0x2A8C8000
	.long 0x00009CDC
	.long 0x2D022000
	.long 0x00009D94
	.long 0x2D190000
	.long 0x00009E64
	.long 0x88000002
	.long 0x00009E68
	.long 0x1C0B4000
	.long 0x00009E6C
	.long 0x20822000
	.long 0x00009E9C
	.long 0x2C000001
	.long 0x00009ED4
	.long 0x5000008B
	.long 0x0000ABB0
	.long 0x2C016004
	.long 0x0000ABB4
	.long 0x05DC0000
	.long 0x0000ABB8
	.long 0x07D00000
	.long 0x0000ABBC
	.long 0x89990017
	.long 0x0000ABC0
	.long 0x280C010F
	.long 0xCC00D130
	.long 0x0000AB90
	.long 0xFFFFFFFF
	.long 0x00003644
	.long 0x3D4CCCCD
	.long 0x00003648
	.long 0x3D8F5C29
	.long 0x0000364C
	.long 0x3F4CCCCD
	.long 0x00003660
	.long 0x3F933333
	.long 0x0000366C
	.long 0x3FC374BC
	.long 0x0000367C
	.long 0x40C00000
	.long 0x000036B0
	.long 0x3F800000
	.long 0x000036C0
	.long 0x41900000
	.long 0x000036CC
	.long 0x42EC0000
	.long 0x000036D4
	.long 0x42030000
	.long 0x00003728
	.long 0x40800000
	.long 0x00003730
	.long 0x41C00000
	.long 0x00003734
	.long 0x41D00000
	.long 0x0000373C
	.long 0x42000000
	.long 0x000037C4
	.long 0x0C000000
	.long 0x0000381C
	.long 0x40000000
	.long 0x00003834
	.long 0x3DA3D70A
	.long 0x00003910
	.long 0x08000006
	.long 0x00003928
	.long 0x2C09B805
	.long 0x0000392C
	.long 0x06400000
	.long 0x00003930
	.long 0x00000190
	.long 0x00003934
	.long 0x20990C92
	.long 0x00003938
	.long 0x000C010F
	.long 0x0000393C
	.long 0x04000003
	.long 0x00003940
	.long 0x40000000
	.long 0x00003998
	.long 0x07080000
	.long 0x000039A0
	.long 0x00190013
	.long 0x000039A4
	.long 0x00200007
	.long 0x000039B4
	.long 0x00190013
	.long 0x000039B8
	.long 0x00200007
	.long 0x000039BC
	.long 0x2D000008
	.long 0x000039C0
	.long 0x05DC0000
	.long 0x000039C8
	.long 0x00190013
	.long 0x000039CC
	.long 0x00200007
	.long 0x000039D0
	.long 0x2D80000C
	.long 0x000039D4
	.long 0x076C0000
	.long 0x000039D8
	.long 0x06A419C8
	.long 0x000039DC
	.long 0x280F0013
	.long 0x000039E0
	.long 0x280C510F
	.long 0x00003A40
	.long 0x2C09B806
	.long 0x00003AEC
	.long 0x2B850000
	.long 0x00003AF0
	.long 0x3C002000
	.long 0x00003B14
	.long 0x00000012
	.long 0x00003B18
	.long 0x000C010F
	.long 0x00003D1C
	.long 0x28154013
	.long 0x00003D30
	.long 0x28154013
	.long 0x00003D94
	.long 0x280C0D0F
	.long 0x00003DA8
	.long 0x280C0D0F
	.long 0x00003DDC
	.long 0x190C0C8F
	.long 0x00003DF0
	.long 0x190C0C8F
	.long 0x00003EC8
	.long 0x190C0C0F
	.long 0x00003EEC
	.long 0x190C0C0F
	.long 0x00003F7C
	.long 0x2C000014
	.long 0x00003F88
	.long 0x26158013
	.long 0x00003F8C
	.long 0x20808C8B
	.long 0x00003FD4
	.long 0x26170013
	.long 0x00003FD8
	.long 0x2080408B
	.long 0x00003FF0
	.long 0x3C00408A
	.long 0x000047B8
	.long 0x29990513
	.long 0x000047BC
	.long 0x000C108F
	.long 0x000047CC
	.long 0x29990513
	.long 0x000047D0
	.long 0x000C108F
	.long 0x000047E0
	.long 0x29990513
	.long 0x000047E4
	.long 0x000C108F
	.long 0x000047FC
	.long 0x08000010
	.long 0x00004830
	.long 0x0F0C108F
	.long 0x00004844
	.long 0x0F0C108F
	.long 0x00004858
	.long 0x0F0C108F
	.long 0x000048B4
	.long 0x3C00308B
	.long 0x000048C8
	.long 0x3C00308B
	.long 0x000048F4
	.long 0x2800308B
	.long 0x00004950
	.long 0x08000025
	.long 0x00004958
	.long 0x08000028
	.long 0x00004994
	.long 0x0E801C8B
	.long 0x00004998
	.long 0x2C81300F
	.long 0x000049A8
	.long 0x0E801C8B
	.long 0x000049BC
	.long 0x0E801C8B
	.long 0x000049C8
	.long 0x08000020
	.long 0x00004A14
	.long 0x0C801C8B
	.long 0x00004A18
	.long 0x2C81300E
	.long 0x00004A28
	.long 0x0C801C8B
	.long 0x00004A2C
	.long 0x2D01100E
	.long 0x00004A3C
	.long 0x0C801C8B
	.long 0x00004A50
	.long 0x08000020
	.long 0x00004AA8
	.long 0x0F801C8B
	.long 0x00004AAC
	.long 0x2C81300D
	.long 0x00004ABC
	.long 0x10001C8B
	.long 0x00004AD0
	.long 0x0F801C8B
	.long 0x00004ADC
	.long 0x08000020
	.long 0x00004B10
	.long 0x140C1C8F
	.long 0x00004B24
	.long 0x140C1C8F
	.long 0x00004B28
	.long 0x04000007
	.long 0x00004B30
	.long 0x08000025
	.long 0x00004B54
	.long 0x2C02080F
	.long 0x00004B64
	.long 0x0F0C280B
	.long 0x00004B68
	.long 0x2C81E80F
	.long 0x00004B78
	.long 0x0F0C280B
	.long 0x00004B94
	.long 0x2C01300C
	.long 0x00004BA4
	.long 0x060C200B
	.long 0x00004BA8
	.long 0x2C81100C
	.long 0x00004BB8
	.long 0x060C200B
	.long 0x00004BC4
	.long 0x0800002E
	.long 0x00004C38
	.long 0x2C017819
	.long 0x00004C3C
	.long 0x064000C8
	.long 0x00004C48
	.long 0x19007907
	.long 0x00004C4C
	.long 0x2C818019
	.long 0x00004C50
	.long 0x07D000C8
	.long 0x00004C5C
	.long 0x19007907
	.long 0x00004C74
	.long 0x04000009
	.long 0x00004C7C
	.long 0x08000030
	.long 0x00004C84
	.long 0x08000037
	.long 0x00004CF4
	.long 0x2C00E814
	.long 0x00004D00
	.long 0x2D17C013
	.long 0x00004D04
	.long 0x140C5123
	.long 0x00004D08
	.long 0x2C80E811
	.long 0x00004D14
	.long 0x2D17C013
	.long 0x00004D18
	.long 0x140C5123
	.long 0x00004D34
	.long 0x2C00000C
	.long 0x00004D38
	.long 0x06400000
	.long 0x00004D3C
	.long 0x0640F704
	.long 0x00004D40
	.long 0x7F190013
	.long 0x00004D44
	.long 0x1E00290A
	.long 0x00004D48
	.long 0x2C80000C
	.long 0x00004D4C
	.long 0x06400000
	.long 0x00004D50
	.long 0x064008FC
	.long 0x00004D54
	.long 0x7F190013
	.long 0x00004D58
	.long 0x1E00290A
	.long 0x00004D94
	.long 0x08000023
	.long 0x00004D9C
	.long 0x08000028
	.long 0x00004DA4
	.long 0x0800002B
	.long 0x00004E48
	.long 0x5A190473
	.long 0x00004E4C
	.long 0x000C110F
	.long 0x00004E5C
	.long 0x5A190473
	.long 0x00004E60
	.long 0x000C110F
	.long 0x00004E70
	.long 0x6E190473
	.long 0x00004E74
	.long 0x000C110F
	.long 0x00004E84
	.long 0x6E190473
	.long 0x00004E88
	.long 0x000C110F
	.long 0x00004EB8
	.long 0x140C2123
	.long 0x00004EEC
	.long 0x0800003F
	.long 0x00004F20
	.long 0x2C00F00F
	.long 0x00004F2C
	.long 0x13190013
	.long 0x00004F30
	.long 0x0A002907
	.long 0x00004F74
	.long 0x2C013010
	.long 0x00004F80
	.long 0xB4954013
	.long 0x00004F84
	.long 0x19002107
	.long 0x00004F88
	.long 0x2C81100F
	.long 0x00004F94
	.long 0xB4954013
	.long 0x00004F98
	.long 0x19002107
	.long 0x00004F9C
	.long 0x2D01E00E
	.long 0x00004FA8
	.long 0xB4954013
	.long 0x00004FAC
	.long 0x19002107
	.long 0x00004FF0
	.long 0x2C00E80F
	.long 0x00005000
	.long 0x0C8C290F
	.long 0x00005004
	.long 0x0800000E
	.long 0x0000505C
	.long 0x2C018012
	.long 0x0000506C
	.long 0x19003507
	.long 0x0000508C
	.long 0x08000006
	.long 0x00005090
	.long 0x4C000001
	.long 0x00005094
	.long 0x08000011
	.long 0x00005098
	.long 0x90000000
	.long 0x0000509C
	.long 0x8C000000
	.long 0x000050A0
	.long 0x44040000
	.long 0x000050A4
	.long 0x0000009D
	.long 0x000050A8
	.long 0x00007F40
	.long 0x000050AC
	.long 0x2C008810
	.long 0x000050B0
	.long 0x06400000
	.long 0x000050B4
	.long 0x000003E8
	.long 0x000050B8
	.long 0x871B0013
	.long 0x000050BC
	.long 0x11843907
	.long 0x000050C0
	.long 0x2C820810
	.long 0x000050C4
	.long 0x06400000
	.long 0x000050C8
	.long 0x00000190
	.long 0x000050CC
	.long 0x871B0013
	.long 0x000050D0
	.long 0x11843907
	.long 0x000050D4
	.long 0x04000005
	.long 0x000050D8
	.long 0x40000000
	.long 0x000050DC
	.long 0x0800001F
	.long 0x000050E8
	.long 0x4C000000
	.long 0x000050EC
	.long 0x0800002A
	.long 0x000050F0
	.long 0x5C000000
	.long 0x000051CC
	.long 0x00000000
	.long 0x000051D4
	.long 0x20878010
	.long 0x000051D8
	.long 0x1D0C010C
	.long 0x000051E0
	.long 0x00000000
	.long 0x000051E8
	.long 0x20878010
	.long 0x000051EC
	.long 0x1D0C010C
	.long 0x0000521C
	.long 0x7C000000
	.long 0x000063A0
	.long 0x09C41838
	.long 0x000063B4
	.long 0x09C41194
	.long 0x000063C8
	.long 0x09C40AF0
	.long 0x0000641C
	.long 0x0A8C1F40
	.long 0x00006430
	.long 0x09C4189C
	.long 0x00006444
	.long 0x0A8C11F8
	.long 0x0000649C
	.long 0xB4960000
	.long 0x00006524
	.long 0x169BC000
	.long 0x00006528
	.long 0x13072000
	.long 0x000074E0
	.long 0x44080000
	.long 0x000074E4
	.long 0x000249F8
	.long 0x000074E8
	.long 0x00007F40
	.long 0x000074EC
	.long 0x28000000
	.long 0x000074F0
	.long 0x04040000
	.long 0x00007500
	.long 0x0800000B
	.long 0x00007504
	.long 0x28000000
	.long 0x00007508
	.long 0x04070000
	.long 0x00007518
	.long 0x28000000
	.long 0x0000751C
	.long 0x03EF0000
	.long 0x0000752C
	.long 0x44000000
	.long 0x00007530
	.long 0x00024A2E
	.long 0x00007534
	.long 0x00007F40
	.long 0x00007538
	.long 0x4C000001
	.long 0x0000753C
	.long 0x2C000004
	.long 0x00007540
	.long 0x08340000
	.long 0x00007544
	.long 0x05001194
	.long 0x00007548
	.long 0x25990DD3
	.long 0x0000754C
	.long 0x0000008B
	.long 0x00007550
	.long 0x04000001
	.long 0x00007554
	.long 0x40000000
	.long 0x00007558
	.long 0x08000026
	.long 0x0000755C
	.long 0x4C000001
	.long 0x00007560
	.long 0x2C000015
	.long 0x00007564
	.long 0x07D00000
	.long 0x00007568
	.long 0x0514FE70
	.long 0x0000756C
	.long 0x26170013
	.long 0x00007570
	.long 0x2080408B
	.long 0x00007610
	.long 0x20808C8B
	.long 0xCC008220
	.long 0x00000C84
	.long 0x00008224
	.long 0x000B5FE0
	.long 0x00008228
	.long 0x000015C9
	.long 0xCC008298
	.long 0x000009E4
	.long 0x0000829C
	.long 0x00070100
	.long 0x000082A0
	.long 0x00001FE9
	.long 0xCC0098C4
	.long 0x000074C0
	.long 0xFFFFFFFF
	.long 0x00003334
	.long 0x11818013
	.long 0x00003414
	.long 0x3DA3D70A
	.long 0x00003418
	.long 0x3FB33333
	.long 0x00003434
	.long 0x40A00000
	.long 0x00003CBC
	.long 0x2C00D006
	.long 0x00003CD0
	.long 0x2C80D007
	.long 0x00003CE4
	.long 0x2D00B807
	.long 0x00003CF8
	.long 0x2D819807
	.long 0x00003F6C
	.long 0x40000000
	.long 0x00003F70
	.long 0x40F00000
	.long 0x00003FB8
	.long 0x02000000
	.long 0x00003FC0
	.long 0xB4940000
	.long 0x00003FC4
	.long 0x080E000F
	.long 0x00004168
	.long 0x2C000008
	.long 0x00004174
	.long 0x23078000
	.long 0x00004274
	.long 0x2C000006
	.long 0x000047B8
	.long 0x32050013
	.long 0x000047BC
	.long 0x140C000F
	.long 0x000047CC
	.long 0x27050013
	.long 0x000047D0
	.long 0x140C000F
	.long 0x000047E0
	.long 0x1E050013
	.long 0x000047E4
	.long 0x140C000F
	.long 0x000047F4
	.long 0x19050013
	.long 0x000047F8
	.long 0x140C000F
	.long 0x00004840
	.long 0x2C00D005
	.long 0x0000484C
	.long 0x0F118013
	.long 0x00004850
	.long 0x190C008F
	.long 0x00004854
	.long 0x2C80D005
	.long 0x00004860
	.long 0x0F118013
	.long 0x00004864
	.long 0x190C008F
	.long 0x00004868
	.long 0x2D00B805
	.long 0x00004874
	.long 0x0F118013
	.long 0x00004878
	.long 0x190C008F
	.long 0x0000487C
	.long 0x2D809805
	.long 0x00004888
	.long 0x0F118013
	.long 0x0000488C
	.long 0x190C008F
	.long 0x000049A4
	.long 0x2D0DC013
	.long 0x000049A8
	.long 0x208C008F
	.long 0x000049B8
	.long 0x280DC013
	.long 0x000049BC
	.long 0x208C008F
	.long 0x000049CC
	.long 0x230DC013
	.long 0x000049D0
	.long 0x208C008F
	.long 0x000049E0
	.long 0x1E0DC013
	.long 0x000049E4
	.long 0x208C008F
	.long 0x00004A1C
	.long 0x08000024
	.long 0x00004A50
	.long 0x0F148013
	.long 0x00004A54
	.long 0x0A0C008F
	.long 0x00004A58
	.long 0x2C80D00E
	.long 0x00004A64
	.long 0x0F148013
	.long 0x00004A68
	.long 0x0A0C008F
	.long 0x00004A78
	.long 0x0F148013
	.long 0x00004A7C
	.long 0x0A0C008F
	.long 0x00004A8C
	.long 0x0F168013
	.long 0x00004A90
	.long 0x0A0C008F
	.long 0x00004AE0
	.long 0x2C00D00D
	.long 0x00004AEC
	.long 0x2F970013
	.long 0x00004AF0
	.long 0x130C008F
	.long 0x00004AF4
	.long 0x2C80D00D
	.long 0x00004B00
	.long 0x2A990013
	.long 0x00004B04
	.long 0x130C008F
	.long 0x00004B08
	.long 0x2D00B80D
	.long 0x00004B14
	.long 0x2A978013
	.long 0x00004B18
	.long 0x130C008F
	.long 0x00004B1C
	.long 0x2D80980D
	.long 0x00004B28
	.long 0x2A974013
	.long 0x00004B2C
	.long 0x130C008F
	.long 0x00004B50
	.long 0x0800001E
	.long 0x00004B78
	.long 0x8C0C8013
	.long 0x00004C48
	.long 0xB4974013
	.long 0x00004C5C
	.long 0xB497C013
	.long 0x00004C70
	.long 0xB497C013
	.long 0x00004C84
	.long 0xB497C011
	.long 0x00004CCC
	.long 0x08000028
	.long 0x00004DDC
	.long 0x0800000A
	.long 0x00004DE4
	.long 0x06720384
	.long 0x00004DEC
	.long 0x2F990513
	.long 0x00004DF0
	.long 0x000C000F
	.long 0x00004DF8
	.long 0x067201C2
	.long 0x00004E00
	.long 0x31190613
	.long 0x00004E04
	.long 0x000C000F
	.long 0x00004E0C
	.long 0x04B00000
	.long 0x00004E14
	.long 0x31190513
	.long 0x00004E18
	.long 0x000C000F
	.long 0x00004E20
	.long 0x03E80000
	.long 0x00004E28
	.long 0x31190513
	.long 0x00004E2C
	.long 0x000C000F
	.long 0x00004E60
	.long 0x04000007
	.long 0x00004E68
	.long 0x04000003
	.long 0x00004E70
	.long 0x08000014
	.long 0x00004E78
	.long 0x08000016
	.long 0x00004E7C
	.long 0x2C00D003
	.long 0x00004E80
	.long 0x06720384
	.long 0x00004E88
	.long 0x2E9903D3
	.long 0x00004E90
	.long 0x2C80D003
	.long 0x00004E94
	.long 0x067201C2
	.long 0x00004EA4
	.long 0x2D00B803
	.long 0x00004EA8
	.long 0x04B00000
	.long 0x00004EB8
	.long 0x2D809803
	.long 0x00004EBC
	.long 0x03E80000
	.long 0x00004EDC
	.long 0x04000009
	.long 0x00004EE4
	.long 0x04000008
	.long 0x00004EEC
	.long 0x08000023
	.long 0x00004EF4
	.long 0x08000025
	.long 0x00004EFC
	.long 0x06720384
	.long 0x00004F04
	.long 0x2817C013
	.long 0x00004F10
	.long 0x06720190
	.long 0x00004F18
	.long 0x2D17C013
	.long 0x00004F24
	.long 0x04B00000
	.long 0x00004F2C
	.long 0x2D17C013
	.long 0x00004F38
	.long 0x03E80000
	.long 0x00004F40
	.long 0x2D17C013
	.long 0x00004F5C
	.long 0x04000008
	.long 0x00004F64
	.long 0x04000009
	.long 0x00004F6C
	.long 0x0800003C
	.long 0x00004FAC
	.long 0x2C00D00E
	.long 0x00005050
	.long 0x2C00D010
	.long 0x000050F0
	.long 0x2C00680C
	.long 0x00005104
	.long 0x2C80380C
	.long 0x00005118
	.long 0x2D00200C
	.long 0x0000513C
	.long 0x04000004
	.long 0x0000517C
	.long 0x04000014
	.long 0x00005180
	.long 0x04000002
	.long 0x000051A4
	.long 0x2C00D00E
	.long 0x000051B4
	.long 0x0C8C010F
	.long 0x000051B8
	.long 0x2C80B80E
	.long 0x000051C8
	.long 0x0C8C010F
	.long 0x000051CC
	.long 0x2D00980E
	.long 0x000051DC
	.long 0x0C8C010F
	.long 0x000051E0
	.long 0x2D80D00E
	.long 0x000051F0
	.long 0x0C8C010F
	.long 0x00005208
	.long 0x08000011
	.long 0x0000520C
	.long 0x0800001B
	.long 0x00005210
	.long 0xC4000000
	.long 0x00005214
	.long 0x0800001E
	.long 0x00005218
	.long 0x2C00D008
	.long 0x0000521C
	.long 0x038401F4
	.long 0x00005220
	.long 0x00000000
	.long 0x00005224
	.long 0x0C990013
	.long 0x00005228
	.long 0x0F0C008F
	.long 0x0000522C
	.long 0x2C80B808
	.long 0x00005230
	.long 0x02580000
	.long 0x00005234
	.long 0x00000000
	.long 0x00005238
	.long 0x0C990013
	.long 0x0000523C
	.long 0x0F0C008F
	.long 0x00005240
	.long 0x2D009808
	.long 0x00005244
	.long 0x01900000
	.long 0x00005248
	.long 0x00000000
	.long 0x0000524C
	.long 0x0C990013
	.long 0x00005250
	.long 0x0F0C008F
	.long 0x00005254
	.long 0x2D80D008
	.long 0x00005258
	.long 0x0384044C
	.long 0x0000525C
	.long 0x00000000
	.long 0x00005260
	.long 0x0C990013
	.long 0x00005264
	.long 0x0F0C008F
	.long 0x00005268
	.long 0x08000022
	.long 0x0000526C
	.long 0x40000000
	.long 0x00005270
	.long 0x04000002
	.long 0x00005274
	.long 0xC5FFFFFF
	.long 0x00005278
	.long 0x08000030
	.long 0x0000527C
	.long 0x4C000000
	.long 0x00005280
	.long 0x08000031
	.long 0x00005284
	.long 0x5C000000
	.long 0x000052A4
	.long 0x241E0013
	.long 0x000052B8
	.long 0x241E0013
	.long 0x000052CC
	.long 0x241E0013
	.long 0x000052FC
	.long 0x050C0055
	.long 0x00005310
	.long 0x050C02FE
	.long 0x00005324
	.long 0x05780000
	.long 0x0000537C
	.long 0x2817C013
	.long 0x00005390
	.long 0x2817C013
	.long 0x000053A4
	.long 0x2817C013
	.long 0x00005418
	.long 0x20968013
	.long 0x0000542C
	.long 0x20968013
	.long 0x00005440
	.long 0x20968013
	.long 0x0000673C
	.long 0x0020008B
	.long 0x00006764
	.long 0x0020008B
	.long 0x00006790
	.long 0x0020008B
	.long 0x000067C8
	.long 0x0020008B
	.long 0x000067DC
	.long 0x0020008B
	.long 0x00006808
	.long 0x0020008B
	.long 0x0000684C
	.long 0x88000006
	.long 0x00006850
	.long 0x11940000
	.long 0x00006854
	.long 0x19022000
	.long 0x000068E0
	.long 0x88000006
	.long 0x000068E4
	.long 0x41158000
	.long 0x000068E8
	.long 0x19822000
	.long 0x000069A8
	.long 0x88000003
	.long 0x000069AC
	.long 0x28168000
	.long 0x000069B0
	.long 0x19022000
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x000034FC
	.long 0x3FB66666
	.long 0x00003508
	.long 0x3FC00000
	.long 0x00003544
	.long 0x3D851EB8
	.long 0x0000354C
	.long 0x3F7573EB
	.long 0x000035C8
	.long 0x41900000
	.long 0x000035D8
	.long 0x41900000
	.long 0x00003668
	.long 0x0000000A
	.long 0x00003680
	.long 0x00000000
	.long 0x00003684
	.long 0xBF0A3D71
	.long 0x0000369C
	.long 0x40800000
	.long 0x000036A4
	.long 0x00000014
	.long 0x000036C0
	.long 0x3D83126F
	.long 0x000036D8
	.long 0x41A00000
	.long 0x00003A10
	.long 0x2C00C019
	.long 0x00003A1C
	.long 0xB4940013
	.long 0x00003A20
	.long 0x2988011F
	.long 0x00003A64
	.long 0x2C00C014
	.long 0x00003A70
	.long 0xB4918013
	.long 0x00003A74
	.long 0x1B88011F
	.long 0x00003BF8
	.long 0x00007100
	.long 0x00003CA8
	.long 0x41800000
	.long 0x00003CAC
	.long 0x3FB33333
	.long 0x00003CB0
	.long 0x3D4CCCCD
	.long 0x00003CB4
	.long 0x3D23D70A
	.long 0x00003CC0
	.long 0x41700000
	.long 0x00003CC4
	.long 0x40800000
	.long 0x00003D88
	.long 0x3FB70A3D
	.long 0x00003D98
	.long 0x10CC0000
	.long 0x00003DA0
	.long 0x230C8000
	.long 0x00003DA4
	.long 0x280800A3
	.long 0x00003E7C
	.long 0x50000000
	.long 0x00003E80
	.long 0x05060023
	.long 0x00003F38
	.long 0x003F0000
	.long 0x00003F4C
	.long 0x05040020
	.long 0x00003F54
	.long 0x04000005
	.long 0x00003F5C
	.long 0x2C000003
	.long 0x00003F68
	.long 0x2E800000
	.long 0x00003F80
	.long 0x2E800000
	.long 0x00003F94
	.long 0x04000001
	.long 0x00004054
	.long 0x41000000
	.long 0xCC00408C
	.long 0x00004038
	.long 0x00004804
	.long 0x1400008B
	.long 0x00004818
	.long 0x1400008B
	.long 0x00004894
	.long 0x00190781
	.long 0x00004898
	.long 0x0008049E
	.long 0x000048A8
	.long 0xB4918001
	.long 0x000048BC
	.long 0x00190791
	.long 0x000048C0
	.long 0x00000407
	.long 0x000048DC
	.long 0x04000004
	.long 0x000048E4
	.long 0x0800000F
	.long 0x000048F4
	.long 0x00000001
	.long 0x000048F8
	.long 0x1E08049F
	.long 0x00004914
	.long 0x04000004
	.long 0x0000491C
	.long 0x08000016
	.long 0x00004924
	.long 0x05780000
	.long 0x0000492C
	.long 0x32110001
	.long 0x00004930
	.long 0x2808049F
	.long 0x0000494C
	.long 0x04000004
	.long 0x00004A7C
	.long 0x30190013
	.long 0x00004A80
	.long 0x1B800087
	.long 0x00004A90
	.long 0x30190013
	.long 0x00004A94
	.long 0x1B800087
	.long 0x00004AB8
	.long 0x08000018
	.long 0x00004B80
	.long 0x0800000E
	.long 0x00004BA4
	.long 0xB4920017
	.long 0x00004BB8
	.long 0xB4920017
	.long 0x00004BCC
	.long 0xB4920017
	.long 0x00004BE0
	.long 0xB4920017
	.long 0x00004BFC
	.long 0x08000013
	.long 0x00004C08
	.long 0x0800002A
	.long 0x00004CB8
	.long 0x0800000C
	.long 0x00004CBC
	.long 0x44040000
	.long 0x00004CC0
	.long 0x000000A0
	.long 0x00004CC4
	.long 0x00007F40
	.long 0x00004CC8
	.long 0x2C01E80C
	.long 0x00004CCC
	.long 0x03E80000
	.long 0x00004CD4
	.long 0x23198010
	.long 0x00004CD8
	.long 0x1400010B
	.long 0x00004CE4
	.long 0x2C01E80C
	.long 0x00004CE8
	.long 0x03E80000
	.long 0x00004CF0
	.long 0x28198010
	.long 0x00004CF4
	.long 0x1400010B
	.long 0x00004D04
	.long 0x2C01E807
	.long 0x00004D08
	.long 0x044C0000
	.long 0x00004D10
	.long 0x2F8C8010
	.long 0x00004D14
	.long 0x0C800D8B
	.long 0x00004D20
	.long 0x2C01E80C
	.long 0x00004D24
	.long 0x03E80000
	.long 0x00004D2C
	.long 0x2A970010
	.long 0x00004D30
	.long 0x1400010B
	.long 0x00004D8C
	.long 0x08000031
	.long 0x00004DDC
	.long 0x2C01E80C
	.long 0x00004DE0
	.long 0x03E80000
	.long 0x00004DE8
	.long 0x0C918010
	.long 0x00004DEC
	.long 0x1900010B
	.long 0x00004E04
	.long 0x2C01E80C
	.long 0x00004E08
	.long 0x03E80000
	.long 0x00004E10
	.long 0x0C918010
	.long 0x00004E14
	.long 0x1900010B
	.long 0x00004E28
	.long 0x2C01E807
	.long 0x00004E2C
	.long 0x044C0000
	.long 0x00004E34
	.long 0x3E918010
	.long 0x00004E38
	.long 0x0F00018B
	.long 0x00004E48
	.long 0x2C01E80C
	.long 0x00004E4C
	.long 0x03E80000
	.long 0x00004E54
	.long 0x0C92C010
	.long 0x00004E58
	.long 0x1400010B
	.long 0x00004E64
	.long 0x08000004
	.long 0x00004E6C
	.long 0x2C01080D
	.long 0x00004E7C
	.long 0x0A00010B
	.long 0x00004E80
	.long 0x2C80580D
	.long 0x00004E90
	.long 0x0A00010B
	.long 0x00004E94
	.long 0x2D00200D
	.long 0x00004EA4
	.long 0x0A00010B
	.long 0x00004ECC
	.long 0x0280010B
	.long 0x00004EE0
	.long 0x0280010B
	.long 0x00004EF4
	.long 0x0280010B
	.long 0x00004F08
	.long 0x0800001C
	.long 0x00004F40
	.long 0x08080C9F
	.long 0x00004F44
	.long 0x2C800003
	.long 0x00004F54
	.long 0x08080C07
	.long 0x00004F84
	.long 0xB4990013
	.long 0x00004F88
	.long 0x0C08111F
	.long 0x00004F98
	.long 0xB4990013
	.long 0x00004F9C
	.long 0x0C08111F
	.long 0x0000500C
	.long 0x10190013
	.long 0x00005020
	.long 0x10190013
	.long 0x00005038
	.long 0x04000003
	.long 0x000050BC
	.long 0x08000022
	.long 0x00005110
	.long 0x04000009
	.long 0x00005114
	.long 0x40000000
	.long 0x00005118
	.long 0x08000030
	.long 0x00006078
	.long 0x08000006
	.long 0x00006090
	.long 0x051409C4
	.long 0x000060A0
	.long 0x03200000
	.long 0x000060A4
	.long 0x05140640
	.long 0x000060BC
	.long 0x04000003
	.long 0x000060E4
	.long 0x08000008
	.long 0x000060F8
	.long 0x041A0000
	.long 0x000060FC
	.long 0x05140AF0
	.long 0x0000610C
	.long 0x03840000
	.long 0x00006110
	.long 0x05140834
	.long 0x00006120
	.long 0x03200000
	.long 0x00006124
	.long 0x05140578
	.long 0x0000613C
	.long 0x04000003
	.long 0x000061A4
	.long 0x168A0000
	.long 0x000062E0
	.long 0x2F822000
	.long 0x0000637C
	.long 0x2D0C8000
	.long 0x00006380
	.long 0x258A8000
	.long 0x00007120
	.long 0xD0000003
	.long 0x00007124
	.long 0x44000000
	.long 0x00007128
	.long 0x000334A4
	.long 0x0000712C
	.long 0x00007F40
	.long 0x00007130
	.long 0x28000000
	.long 0x00007134
	.long 0x04060000
	.long 0x00007144
	.long 0x28000000
	.long 0x00007148
	.long 0x03F40000
	.long 0x0000714C
	.long 0x00000898
	.long 0x00007150
	.long 0x07080400
	.long 0x00007154
	.long 0x04000400
	.long 0x00007158
	.long 0x2C000007
	.long 0x00007160
	.long 0x04B00000
	.long 0x00007164
	.long 0x23154012
	.long 0x00007168
	.long 0x1E080120
	.long 0x0000716C
	.long 0x68000000
	.long 0xCC009470
	.long 0x00007100
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x00003398
	.long 0x41C00000
	.long 0x000035E4
	.long 0x03840000
	.long 0x000035F8
	.long 0x03840000
	.long 0x00003608
	.long 0x04000002
	.long 0x0000361C
	.long 0x03840000
	.long 0x00003630
	.long 0x03840000
	.long 0x00003640
	.long 0x04000002
	.long 0x00004154
	.long 0x05140000
	.long 0x000041B4
	.long 0x05140000
	.long 0x00004214
	.long 0x05140000
	.long 0x00004294
	.long 0x05140000
	.long 0x00004304
	.long 0x05140000
	.long 0x0000438C
	.long 0x2C007806
	.long 0x00004394
	.long 0x05140000
	.long 0x00004398
	.long 0x0A168013
	.long 0x000043A0
	.long 0x2C805006
	.long 0x000043AC
	.long 0x0A168013
	.long 0x000043D0
	.long 0x08000018
	.long 0x00004498
	.long 0x08000010
	.long 0x000044FC
	.long 0x05140000
	.long 0x00004588
	.long 0x044C0000
	.long 0x0000460C
	.long 0x044C0000
	.long 0x00004610
	.long 0x05140000
	.long 0x00004620
	.long 0x03E80000
	.long 0x00004690
	.long 0x14000107
	.long 0x00004694
	.long 0x2C80780B
	.long 0x000046A0
	.long 0x87190013
	.long 0x000046FC
	.long 0x05140000
	.long 0x00004758
	.long 0x05140000
	.long 0x00004784
	.long 0x05140000
	.long 0x000047E0
	.long 0x05DC0000
	.long 0xFFFFFFFF
	.long 0x0000127C
	.long 0x41C00000
	.long 0x000014C8
	.long 0x03840000
	.long 0x000014DC
	.long 0x03840000
	.long 0x000014EC
	.long 0x04000002
	.long 0x00001500
	.long 0x03840000
	.long 0x00001514
	.long 0x03840000
	.long 0x00001524
	.long 0x04000002
	.long 0x00002038
	.long 0x05140000
	.long 0x00002098
	.long 0x05140000
	.long 0x000020F8
	.long 0x05140000
	.long 0x00002178
	.long 0x05140000
	.long 0x000021E8
	.long 0x05140000
	.long 0x00002270
	.long 0x2C007806
	.long 0x00002278
	.long 0x05140000
	.long 0x0000227C
	.long 0x0A168013
	.long 0x00002290
	.long 0x0A168013
	.long 0x000022B4
	.long 0x08000018
	.long 0x0000237C
	.long 0x08000010
	.long 0x000023E0
	.long 0x05140000
	.long 0x0000246C
	.long 0x044C0000
	.long 0x000024F0
	.long 0x044C0000
	.long 0x000024F4
	.long 0x05140000
	.long 0x00002504
	.long 0x03E80000
	.long 0x00002574
	.long 0x14000107
	.long 0x00002578
	.long 0x2C80780B
	.long 0x00002584
	.long 0x87190013
	.long 0x000025E0
	.long 0x05140000
	.long 0x0000263C
	.long 0x05140000
	.long 0x00002668
	.long 0x05140000
	.long 0x000026C4
	.long 0x05DC0000
	.long 0xCC005014
	.long 0x00001E64
	.long 0xFFFFFFFF
	.long 0x0000359C
	.long 0x3D8F5C29
	.long 0x00003614
	.long 0x41600000
	.long 0x00003670
	.long 0x41500000
	.long 0x00003674
	.long 0x41A00000
	.long 0x00003678
	.long 0x41B00000
	.long 0x0000367C
	.long 0x41C80000
	.long 0x00003744
	.long 0x3FC66666
	.long 0x00003E28
	.long 0x2C00000C
	.long 0x00004348
	.long 0x08000028
	.long 0x00004358
	.long 0x2C01580B
	.long 0x0000436C
	.long 0x2C81180B
	.long 0x00004380
	.long 0x2D00200B
	.long 0x000043C0
	.long 0x2C01580A
	.long 0x000043D4
	.long 0x2C81180A
	.long 0x000043E8
	.long 0x2D00200A
	.long 0x00004428
	.long 0x2C015809
	.long 0x0000443C
	.long 0x2C811809
	.long 0x00004450
	.long 0x2D002009
	.long 0x0000448C
	.long 0x2C017809
	.long 0x00004498
	.long 0x301A0013
	.long 0x000044A0
	.long 0x2C817809
	.long 0x000044AC
	.long 0x301A0013
	.long 0x000044B4
	.long 0x2D017808
	.long 0x000044C0
	.long 0x2C1A0013
	.long 0x00004508
	.long 0x2C017809
	.long 0x0000451C
	.long 0x2C817809
	.long 0x00004530
	.long 0x2D017809
	.long 0x00004618
	.long 0x05530000
	.long 0x0000461C
	.long 0x044C0CE4
	.long 0x00004694
	.long 0x04000003
	.long 0x000047A0
	.long 0x2C01780B
	.long 0x000047AC
	.long 0x14190011
	.long 0x000047B0
	.long 0x0A00000B
	.long 0x000047B4
	.long 0x2C81780B
	.long 0x000047C0
	.long 0x14190011
	.long 0x000047C4
	.long 0x0A00000B
	.long 0x000047C8
	.long 0x2D01780B
	.long 0x000047D4
	.long 0x14190011
	.long 0x000047D8
	.long 0x0A00000B
	.long 0x00004878
	.long 0x05DC0000
	.long 0x00004880
	.long 0x6E190590
	.long 0x00004884
	.long 0x0008009F
	.long 0x00004888
	.long 0x2C000002
	.long 0x0000488C
	.long 0x05DC0000
	.long 0x00004890
	.long 0x0640F830
	.long 0x00004894
	.long 0x6E078010
	.long 0x0000489C
	.long 0x2C800002
	.long 0x000048A0
	.long 0x05DC0000
	.long 0x000048A4
	.long 0x064007D0
	.long 0x000048A8
	.long 0x6E078010
	.long 0x000048AC
	.long 0x2308009F
	.long 0x00004948
	.long 0x2D00000C
	.long 0x0000494C
	.long 0x051B0000
	.long 0x00004950
	.long 0x01F40064
	.long 0x000049F4
	.long 0x26080013
	.long 0x000049F8
	.long 0x13080C9F
	.long 0x00004A08
	.long 0x26080013
	.long 0x00004A0C
	.long 0x13080C9F
	.long 0x00004A20
	.long 0x04000002
	.long 0x00004A28
	.long 0x0800001E
	.long 0x00004A4C
	.long 0x2C00700E
	.long 0x00004A5C
	.long 0x0C80010B
	.long 0x00004A60
	.long 0x2C80200E
	.long 0x00004A70
	.long 0x0C80010B
	.long 0x00004B98
	.long 0x11940013
	.long 0x00004BAC
	.long 0x11940013
	.long 0x00004C74
	.long 0x1E0DC013
	.long 0x00004C78
	.long 0x2D08011F
	.long 0x00004C88
	.long 0x1E0DC013
	.long 0x00004C8C
	.long 0x2D08011F
	.long 0x00005494
	.long 0x08000014
	.long 0x00005CB4
	.long 0x88000005
	.long 0xCC007AF4
	.long 0x00000E78
	.long 0x00007AF8
	.long 0x0009A8C0
	.long 0x00007AFC
	.long 0x00001E59
	.long 0x00007B04
	.long 0x0000000C
	.long 0xFFFFFFFF
	.long 0x000034E8
	.long 0x3CB851EC
	.long 0x00003524
	.long 0x00000000
	.long 0x00003ED4
	.long 0x2C000004
	.long 0x00003EE4
	.long 0x070A041F
	.long 0x00003EF0
	.long 0x2C000006
	.long 0x00003F00
	.long 0x080A081F
	.long 0x00003F0C
	.long 0x2C000009
	.long 0x00003F1C
	.long 0x0A0A0C1F
	.long 0x00003F28
	.long 0x2C00000C
	.long 0x00003F38
	.long 0x0C0A105F
	.long 0x00003F44
	.long 0x2C00000F
	.long 0x00003F54
	.long 0x0E0A145F
	.long 0x00003F60
	.long 0x2C000013
	.long 0x00003F70
	.long 0x100A185F
	.long 0x00003F7C
	.long 0x2C000016
	.long 0x00003F8C
	.long 0x120A1C5F
	.long 0x00003F98
	.long 0x2C00001A
	.long 0x00003FA8
	.long 0x190A229F
	.long 0x0000403C
	.long 0x43160000
	.long 0x00004050
	.long 0x3CF5C28F
	.long 0x0000417C
	.long 0x2D08C000
	.long 0x00004180
	.long 0x14060C23
	.long 0x0000475C
	.long 0x0800000F
	.long 0x0000477C
	.long 0xB4968013
	.long 0x00004780
	.long 0x0F00008B
	.long 0x00004790
	.long 0xB4968013
	.long 0x00004794
	.long 0x0F00008B
	.long 0x000047B0
	.long 0x08000019
	.long 0x000049D0
	.long 0x70380002
	.long 0x00004A58
	.long 0x08000014
	.long 0x00004A5C
	.long 0x6C000000
	.long 0x00004AF4
	.long 0x08000024
	.long 0x00004C84
	.long 0x08000002
	.long 0x00004C94
	.long 0x00000400
	.long 0x00004CA8
	.long 0x08000009
	.long 0x00004CAC
	.long 0x28000000
	.long 0x00004CB0
	.long 0x03FB0000
	.long 0x00004CB8
	.long 0x00000000
	.long 0x00004CBC
	.long 0x00000000
	.long 0x00004CC0
	.long 0x2C000002
	.long 0x00004CC4
	.long 0x03E80000
	.long 0x00004CC8
	.long 0x0000FA88
	.long 0x00004CCC
	.long 0x46190BD3
	.long 0x00004CD0
	.long 0x0000008B
	.long 0x00004CD4
	.long 0x2C800002
	.long 0x00004CD8
	.long 0x03E80000
	.long 0x00004CDC
	.long 0x00000578
	.long 0x00004CE0
	.long 0x46190BD3
	.long 0x00004CE4
	.long 0x0000008B
	.long 0x00004CE8
	.long 0x04000002
	.long 0x00004CEC
	.long 0x40000000
	.long 0x00004CF0
	.long 0x0800000D
	.long 0x00004CF4
	.long 0x28000000
	.long 0x00004CF8
	.long 0x04240000
	.long 0x00004D00
	.long 0x00000000
	.long 0x00004D04
	.long 0x00000000
	.long 0x00004D08
	.long 0x28C40000
	.long 0x00004D0C
	.long 0x03F30000
	.long 0x00004D10
	.long 0x0BC40000
	.long 0x00004D14
	.long 0x00000000
	.long 0x00004D18
	.long 0x00000000
	.long 0x00004D1C
	.long 0x28C40000
	.long 0x00004D20
	.long 0x040C0000
	.long 0x00004D24
	.long 0x0BC40000
	.long 0x00004D28
	.long 0x00000000
	.long 0x00004D2C
	.long 0x00000000
	.long 0x00004D30
	.long 0x28000000
	.long 0x00004D34
	.long 0x05150000
	.long 0x00004D38
	.long 0x00000000
	.long 0x00004D3C
	.long 0x00000000
	.long 0x00004D40
	.long 0x00000000
	.long 0x00004D44
	.long 0x2C018811
	.long 0x00004D48
	.long 0x044CFE80
	.long 0x00004D4C
	.long 0x00000000
	.long 0x00004D50
	.long 0x2D160013
	.long 0x00004D54
	.long 0x190430A3
	.long 0x00004D58
	.long 0x2C818811
	.long 0x00004D5C
	.long 0x076C0ABE
	.long 0x00004D60
	.long 0x00000000
	.long 0x00004D64
	.long 0x2D160013
	.long 0x00004D68
	.long 0x190430A3
	.long 0x00004D6C
	.long 0x2D000011
	.long 0x00004D70
	.long 0x04E20000
	.long 0x00004D74
	.long 0x09600000
	.long 0x00004D78
	.long 0x2D160013
	.long 0x00004D7C
	.long 0x190430A3
	.long 0x00004D80
	.long 0x2D800011
	.long 0x00004D84
	.long 0x04E20000
	.long 0x00004D88
	.long 0x05780000
	.long 0x00004D8C
	.long 0x2D160013
	.long 0x00004D90
	.long 0x190430A3
	.long 0x00004D94
	.long 0x44000000
	.long 0x00004D98
	.long 0x00000076
	.long 0x00004D9C
	.long 0x00007F40
	.long 0x00004DA0
	.long 0x44000000
	.long 0x00004DA4
	.long 0x00000076
	.long 0x00004DA8
	.long 0x00007F40
	.long 0x00004DAC
	.long 0x44000000
	.long 0x00004DB0
	.long 0x00000073
	.long 0x00004DB4
	.long 0x00007F40
	.long 0x00004DB8
	.long 0xB8CC0000
	.long 0x00004DBC
	.long 0xAC018000
	.long 0x00004DC0
	.long 0x04000004
	.long 0x00004DC4
	.long 0x3C000002
	.long 0x00004DC8
	.long 0x3C000003
	.long 0x00004DCC
	.long 0x2C01880A
	.long 0x00004DD0
	.long 0x0320FE80
	.long 0x00004DD4
	.long 0x00000000
	.long 0x00004DD8
	.long 0x2D154013
	.long 0x00004DDC
	.long 0x190400A3
	.long 0x00004DE0
	.long 0x2C81880A
	.long 0x00004DE4
	.long 0x06400ABE
	.long 0x00004DE8
	.long 0x00000000
	.long 0x00004DEC
	.long 0x2D154013
	.long 0x00004DF0
	.long 0x190400A3
	.long 0x00004DF4
	.long 0x08000016
	.long 0x00004DF8
	.long 0x40000000
	.long 0x00004DFC
	.long 0x0800002A
	.long 0x00004E00
	.long 0x5C000000
	.long 0x00004E08
	.long 0x00000000
	.long 0x00004E0C
	.long 0x00000000
	.long 0x00004E1C
	.long 0x00000000
	.long 0x00004E20
	.long 0x00000000
	.long 0x00004E24
	.long 0x00000000
	.long 0x00004E28
	.long 0x00000000
	.long 0x00004E2C
	.long 0x00000000
	.long 0x00004E30
	.long 0x00000000
	.long 0x00004E34
	.long 0x00000000
	.long 0x00004E38
	.long 0x00000000
	.long 0x00004E40
	.long 0x00000000
	.long 0x00004E44
	.long 0x00000000
	.long 0x00004E48
	.long 0x00000000
	.long 0x00004E4C
	.long 0x00000000
	.long 0x00004E54
	.long 0x00000000
	.long 0x00004E58
	.long 0x00000000
	.long 0x00004E5C
	.long 0x00000000
	.long 0x00004E60
	.long 0x00000000
	.long 0x00004E64
	.long 0x00000000
	.long 0x00004E68
	.long 0x00000000
	.long 0x00004E74
	.long 0x00000000
	.long 0x00004E78
	.long 0x00000000
	.long 0x00004E7C
	.long 0x00000000
	.long 0x00004E80
	.long 0x00000000
	.long 0x00004E84
	.long 0x00000000
	.long 0x00004E88
	.long 0x00000000
	.long 0x00004E8C
	.long 0x00000000
	.long 0x00004E90
	.long 0x00000000
	.long 0x00005014
	.long 0x2A9900B3
	.long 0x00005028
	.long 0x2A9900B3
	.long 0x00006274
	.long 0x0020008B
	.long 0x00006364
	.long 0x0020008B
	.long 0xCC007FF8
	.long 0x00001F8C
	.long 0x00007FFC
	.long 0x00145C80
	.long 0x00008000
	.long 0x00001F8D
	.long 0xFFFFFFFF
	.long 0x000033C0
	.long 0x3D48B439
	.long 0x000033E4
	.long 0x42DE0000
	.long 0x00003450
	.long 0x41800000
	.long 0x00003454
	.long 0x41C00000
	.long 0x000034E8
	.long 0x430C0000
	.long 0x000034F8
	.long 0x3F4CCCCD
	.long 0x00003518
	.long 0x00000001
	.long 0x0000352C
	.long 0x00000000
	.long 0x00003538
	.long 0x3F800000
	.long 0x00003550
	.long 0x4019999A
	.long 0x00003570
	.long 0x3FEB851F
	.long 0x000035C8
	.long 0x00000000
	.long 0x000037B4
	.long 0x05780000
	.long 0x00003864
	.long 0x05780000
	.long 0x00004224
	.long 0x0C80010B
	.long 0x00004228
	.long 0x2C000009
	.long 0x0000422C
	.long 0x05140000
	.long 0x00004230
	.long 0x05FD0951
	.long 0x00004238
	.long 0x0C80010B
	.long 0x00004258
	.long 0x30000007
	.long 0x0000425C
	.long 0x30800007
	.long 0x00004284
	.long 0x28154013
	.long 0x00004298
	.long 0x23154013
	.long 0x000042A0
	.long 0x2D00700C
	.long 0x000042AC
	.long 0x1E154013
	.long 0x000042F0
	.long 0x28154013
	.long 0x00004304
	.long 0x23154013
	.long 0x00004318
	.long 0x1E154013
	.long 0x0000435C
	.long 0x28154013
	.long 0x00004370
	.long 0x23154013
	.long 0x00004374
	.long 0x19000087
	.long 0x00004384
	.long 0x1E154013
	.long 0x000043D0
	.long 0x2C00A00B
	.long 0x000043D4
	.long 0x069A0000
	.long 0x000043E4
	.long 0x2C80A80B
	.long 0x000043E8
	.long 0x05140000
	.long 0x000043F8
	.long 0x2D00000B
	.long 0x000043FC
	.long 0x06180000
	.long 0x000044DC
	.long 0x08000016
	.long 0x00004528
	.long 0x2C013011
	.long 0x0000453C
	.long 0x2C813011
	.long 0x00004550
	.long 0x2D002011
	.long 0x000045F8
	.long 0x2C01300F
	.long 0x00004608
	.long 0x0F00010B
	.long 0x0000460C
	.long 0x2C81280F
	.long 0x0000461C
	.long 0x0F00010B
	.long 0x00004644
	.long 0x04000006
	.long 0x00004650
	.long 0x08000024
	.long 0x000047BC
	.long 0x0800002F
	.long 0x000047E0
	.long 0x2C00800E
	.long 0x000047E4
	.long 0x03E80055
	.long 0x000047EC
	.long 0xB499C013
	.long 0x00004800
	.long 0xB499C013
	.long 0x00004814
	.long 0xB499C013
	.long 0x00004820
	.long 0x2C00800A
	.long 0x00004824
	.long 0x03E80055
	.long 0x0000490C
	.long 0x1E078013
	.long 0x00004910
	.long 0x1400010B
	.long 0x00004920
	.long 0x1E078013
	.long 0x00004924
	.long 0x1400010B
	.long 0x00004934
	.long 0x1E078013
	.long 0x00004938
	.long 0x1400010B
	.long 0x00004964
	.long 0x1E078013
	.long 0x00004968
	.long 0x1400010B
	.long 0x00004978
	.long 0x1E078013
	.long 0x0000497C
	.long 0x1400010B
	.long 0x0000498C
	.long 0x1E078013
	.long 0x00004990
	.long 0x1400010B
	.long 0x000049BC
	.long 0x1E078013
	.long 0x000049C0
	.long 0x1400008B
	.long 0x000049D0
	.long 0x1E078013
	.long 0x000049D4
	.long 0x1400008B
	.long 0x000049E4
	.long 0x1E078013
	.long 0x000049E8
	.long 0x1400008B
	.long 0x00004A08
	.long 0x2C00A008
	.long 0x00004A14
	.long 0x23140013
	.long 0x00004A1C
	.long 0x2C80A808
	.long 0x00004A28
	.long 0x23140013
	.long 0x00004A30
	.long 0x2D00A808
	.long 0x00004A3C
	.long 0x23140013
	.long 0x00004A74
	.long 0x2C00A00E
	.long 0x00004A80
	.long 0x2D19C013
	.long 0x00004A88
	.long 0x2C80A80E
	.long 0x00004A94
	.long 0x2D19C013
	.long 0x00005C68
	.long 0x01900000
	.long 0x00005C6C
	.long 0x00000000
	.long 0x00005C74
	.long 0x0020008B
	.long 0x00005C80
	.long 0x00000000
	.long 0x00005C88
	.long 0x0020008B
	.long 0x00005CC4
	.long 0x04000004
	.long 0x00005CCC
	.long 0x04000009
	.long 0x00005D20
	.long 0x2D013000
	.long 0x00005D24
	.long 0x03E80000
	.long 0x00005D30
	.long 0x0020008B
	.long 0x00005D44
	.long 0x0020008B
	.long 0x00005D6C
	.long 0x0400000D
	.long 0x00005DE4
	.long 0x88000008
	.long 0x00005DE8
	.long 0x0F190000
	.long 0x00005DEC
	.long 0x07822000
	.long 0x00005E70
	.long 0x88000007
	.long 0x00005E74
	.long 0x11908000
	.long 0x00005E78
	.long 0x1B822000
	.long 0x00005F1C
	.long 0x2D118000
	.long 0x00005F20
	.long 0x26022000
	.long 0x00006D70
	.long 0xAC016000
	.long 0x00006D74
	.long 0x08000008
	.long 0x00006D78
	.long 0x2C000004
	.long 0x00006D7C
	.long 0x07080000
	.long 0x00006D80
	.long 0x070809C4
	.long 0x00006D84
	.long 0x28190DD3
	.long 0x00006D88
	.long 0x0000010B
	.long 0x00006D8C
	.long 0x4C000001
	.long 0x00006D90
	.long 0x44080000
	.long 0x00006D94
	.long 0x000445F7
	.long 0x00006D98
	.long 0x00007F40
	.long 0x00006D9C
	.long 0x04000001
	.long 0x00006DA0
	.long 0x40000000
	.long 0x00006DA4
	.long 0x0800001B
	.long 0x00006DA8
	.long 0x28000000
	.long 0x00006DAC
	.long 0x03F30000
	.long 0x00006DB0
	.long 0x00000708
	.long 0x00006DB4
	.long 0x00000400
	.long 0x00006DB8
	.long 0x04000400
	.long 0x00006DBC
	.long 0x2C002010
	.long 0x00006DC0
	.long 0x06000000
	.long 0x00006DC8
	.long 0x28188013
	.long 0x00006DCC
	.long 0x1900290B
	.long 0x00006DD0
	.long 0x44080000
	.long 0xCC006DD4
	.long 0x000445FA
	.long 0xCC006DD8
	.long 0x00007F40
	.long 0xCC009074
	.long 0x00006D50
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x0000376C
	.long 0x3FB9999A
	.long 0x00003788
	.long 0x40800000
	.long 0x000037D8
	.long 0x42D40000
	.long 0x000037E0
	.long 0x418F1EB8
	.long 0x0000383C
	.long 0x41B00000
	.long 0x00003840
	.long 0x41900000
	.long 0x00003844
	.long 0x41800000
	.long 0x00003848
	.long 0x41C00000
	.long 0x00003B0C
	.long 0x00000000
	.long 0x00003B50
	.long 0x00000000
	.long 0x00003B54
	.long 0x00000000
	.long 0x00003B58
	.long 0x00000000
	.long 0x00003B5C
	.long 0x00000000
	.long 0x00003B60
	.long 0x00000000
	.long 0x00003B64
	.long 0x00000000
	.long 0xCC003BA0
	.long 0x000070A0
	.long 0x00003D00
	.long 0x2C000003
	.long 0x00003D04
	.long 0x06400000
	.long 0x00003D0C
	.long 0xB48C8000
	.long 0x00003D10
	.long 0x2D30001F
	.long 0x00003EC0
	.long 0x1B280000
	.long 0x000042D4
	.long 0x2C800006
	.long 0x000042D8
	.long 0x07D00000
	.long 0x000042DC
	.long 0x0A5A0BB8
	.long 0x000042E0
	.long 0x29990292
	.long 0x000042E8
	.long 0x28000000
	.long 0x000042EC
	.long 0x04E40000
	.long 0x000042F0
	.long 0x00000A5A
	.long 0x000042F4
	.long 0x0BB80000
	.long 0x000042F8
	.long 0x00000000
	.long 0x000042FC
	.long 0x48000000
	.long 0x00004300
	.long 0x04000002
	.long 0x00004304
	.long 0x40000000
	.long 0x00004308
	.long 0x08000010
	.long 0x0000430C
	.long 0x5C000000
	.long 0x00004428
	.long 0x04B00000
	.long 0x0000443C
	.long 0x04B00000
	.long 0x00004450
	.long 0x060E0000
	.long 0x000044A0
	.long 0x04B00000
	.long 0x000044B4
	.long 0x04B00000
	.long 0x000044C8
	.long 0x060E0000
	.long 0x00004524
	.long 0x2D00C807
	.long 0x00004534
	.long 0x050C000B
	.long 0x000045A4
	.long 0x2D00C807
	.long 0x000045B4
	.long 0x050C000B
	.long 0x00004638
	.long 0x2D00C807
	.long 0x00004648
	.long 0x050C000B
	.long 0x000046A0
	.long 0x371B8013
	.long 0x000046A4
	.long 0x1400008B
	.long 0x000046A8
	.long 0x2C80A80A
	.long 0x000046B4
	.long 0x371B8013
	.long 0x000046B8
	.long 0x1400010B
	.long 0x000046BC
	.long 0x2D00B80A
	.long 0x000046C8
	.long 0x371B8013
	.long 0x000046CC
	.long 0x1400008B
	.long 0x000046D0
	.long 0x2D80C80A
	.long 0x000046DC
	.long 0x371B8013
	.long 0x000046E0
	.long 0x1400008B
	.long 0x000046F8
	.long 0x2C002809
	.long 0x00004704
	.long 0x271B8013
	.long 0x00004708
	.long 0x1400010B
	.long 0x0000470C
	.long 0x2C80A809
	.long 0x00004718
	.long 0x271B8013
	.long 0x0000471C
	.long 0x1400010B
	.long 0x00004720
	.long 0x2D00B809
	.long 0x0000472C
	.long 0x271B8013
	.long 0x00004730
	.long 0x1400010B
	.long 0x00004734
	.long 0x2D80C809
	.long 0x00004740
	.long 0x271B8013
	.long 0x00004744
	.long 0x1400010B
	.long 0x00004798
	.long 0x2D00C806
	.long 0x0000485C
	.long 0x2C00000F
	.long 0x00004860
	.long 0x05780000
	.long 0x00004868
	.long 0xB497C013
	.long 0x00004874
	.long 0x06720000
	.long 0x0000487C
	.long 0xB4968001
	.long 0x00004880
	.long 0x0F340123
	.long 0x00004988
	.long 0x04B00000
	.long 0x0000498C
	.long 0x15180000
	.long 0x000049A0
	.long 0x14B4FA88
	.long 0x000049B4
	.long 0x14B40578
	.long 0x000049D0
	.long 0x2C00000D
	.long 0x000049E4
	.long 0x2C80000D
	.long 0x000049F8
	.long 0x2D00000D
	.long 0x00004A0C
	.long 0x2D80000D
	.long 0x00004A88
	.long 0x2C000011
	.long 0x00004A9C
	.long 0x2C800011
	.long 0x00004B4C
	.long 0x2C000001
	.long 0x00004B50
	.long 0x03520000
	.long 0x00004B60
	.long 0x2C800001
	.long 0x00004B64
	.long 0x03520000
	.long 0x00004B78
	.long 0x03520000
	.long 0x00004B8C
	.long 0x03520000
	.long 0x00004BAC
	.long 0x03E90000
	.long 0x00004BB4
	.long 0x00000000
	.long 0x00004BB8
	.long 0x00000000
	.long 0x00004BE4
	.long 0x0D480000
	.long 0x00004C10
	.long 0x4C000001
	.long 0x00004C14
	.long 0x08000002
	.long 0x00004C18
	.long 0x44080000
	.long 0x00004C1C
	.long 0x00030D4D
	.long 0x00004C20
	.long 0x00007F40
	.long 0x00004C24
	.long 0xA2000805
	.long 0x00004C28
	.long 0xA2081805
	.long 0x00004C2C
	.long 0x288D0000
	.long 0x00004C30
	.long 0x04E50000
	.long 0x00004C3C
	.long 0x00000000
	.long 0x00004C78
	.long 0x0800000D
	.long 0x00004C90
	.long 0x0800001F
	.long 0x00004C98
	.long 0x08000020
	.long 0x00004CC8
	.long 0x0280008B
	.long 0x00004CCC
	.long 0x2C80B80C
	.long 0x00004CDC
	.long 0x0280008B
	.long 0x00004CE0
	.long 0x2C00C80B
	.long 0x00004CF0
	.long 0x0280008B
	.long 0x00004D34
	.long 0x08000008
	.long 0x00004D48
	.long 0x0500008B
	.long 0x00004D5C
	.long 0x0500008B
	.long 0x00004D70
	.long 0x0500008B
	.long 0x00004D84
	.long 0x04000006
	.long 0x00004DD8
	.long 0x91190013
	.long 0x00004DEC
	.long 0x91190013
	.long 0x00004E00
	.long 0x91190013
	.long 0x00004E6C
	.long 0x0E100000
	.long 0x00004E74
	.long 0x2D118013
	.long 0x00005D7C
	.long 0x05780000
	.long 0x00005D80
	.long 0x0AF00BB8
	.long 0x00005D90
	.long 0x05140000
	.long 0x00005DF8
	.long 0x05780000
	.long 0x00005E20
	.long 0x05780000
	.long 0x00005E24
	.long 0x06720A28
	.long 0x00005EF8
	.long 0x44080000
	.long 0x00005EFC
	.long 0x00030D41
	.long 0x000070C0
	.long 0x08000004
	.long 0x000070C4
	.long 0x28000000
	.long 0x000070C8
	.long 0x03F40000
	.long 0x000070CC
	.long 0x000005DC
	.long 0x000070D8
	.long 0x68000002
	.long 0x000072E0
	.long 0x00000000
	.long 0x000072E8
	.long 0x00000000
	.long 0x00007300
	.long 0x00000000
	.long 0x0000730C
	.long 0x00000000
	.long 0x00007310
	.long 0x00000000
	.long 0x00007328
	.long 0x00000000
	.long 0x00007338
	.long 0x00000000
	.long 0x00007350
	.long 0x00000000
	.long 0x0000735C
	.long 0x00000000
	.long 0x00007360
	.long 0x00000000
	.long 0xCC00927C
	.long 0x00003A94
	.long 0xCC009294
	.long 0x000070A0
	.long 0xFFFFFFFF
	.long 0x000033EC
	.long 0x3FC00000
	.long 0x00003404
	.long 0x3D0F5C29
	.long 0x0000340C
	.long 0x3F369446
	.long 0x00003568
	.long 0x40C00000
	.long 0x00003574
	.long 0x3FE66666
	.long 0x00003584
	.long 0x41A00000
	.long 0x000035A4
	.long 0x3E75C28F
	.long 0x000035B0
	.long 0x3FA66666
	.long 0x000037E0
	.long 0x03200000
	.long 0x000037E8
	.long 0x2D130013
	.long 0x00003880
	.long 0x2C00B816
	.long 0x00003884
	.long 0x03200000
	.long 0x0000388C
	.long 0x2D130013
	.long 0x00003890
	.long 0x23040117
	.long 0x00003918
	.long 0x2D00B00C
	.long 0x00003C68
	.long 0x0800000E
	.long 0x0000403C
	.long 0xB4940013
	.long 0x00004040
	.long 0x1900008B
	.long 0x000040AC
	.long 0x8E990013
	.long 0x000040C0
	.long 0x8E990013
	.long 0x00004104
	.long 0x8E990013
	.long 0x00004118
	.long 0x8E990013
	.long 0x0000415C
	.long 0x8E990013
	.long 0x00004170
	.long 0x8E990013
	.long 0x000041B4
	.long 0x8E990013
	.long 0x000041C8
	.long 0x8E990013
	.long 0x0000420C
	.long 0x8E990013
	.long 0x00004220
	.long 0x8E990013
	.long 0x00004258
	.long 0x2C000004
	.long 0x00004268
	.long 0x1E0000AB
	.long 0x0000426C
	.long 0x2C802804
	.long 0x0000427C
	.long 0x1E0000AB
	.long 0x000043C4
	.long 0xB4990013
	.long 0x000043C8
	.long 0x0100208B
	.long 0x000043D8
	.long 0xB4990013
	.long 0x000043DC
	.long 0x0100208B
	.long 0x000043EC
	.long 0xB4990013
	.long 0x000043F0
	.long 0x0100208B
	.long 0x0000449C
	.long 0x2C01B80C
	.long 0x000044AC
	.long 0x0500200B
	.long 0x000044B0
	.long 0x2C81B00C
	.long 0x000044C0
	.long 0x0500200B
	.long 0x000044C4
	.long 0x2D00200C
	.long 0x000044D4
	.long 0x0500200B
	.long 0x00004510
	.long 0x08000019
	.long 0x00004574
	.long 0x2C00000F
	.long 0x00004588
	.long 0x2C80000F
	.long 0x0000459C
	.long 0x2D00E80F
	.long 0x000045D0
	.long 0x08000026
	.long 0x0000463C
	.long 0x2C00000E
	.long 0x00004650
	.long 0x2C80000E
	.long 0x00004664
	.long 0x2D00E80E
	.long 0x000046A0
	.long 0x08000026
	.long 0x00004708
	.long 0x2C00000D
	.long 0x0000471C
	.long 0x2C80000D
	.long 0x00004730
	.long 0x2D00E80D
	.long 0x00004764
	.long 0x08000026
	.long 0x00004854
	.long 0x2D168013
	.long 0x00004868
	.long 0x2D168013
	.long 0x000048AC
	.long 0x2D168013
	.long 0x000048C0
	.long 0x2D168013
	.long 0x000049B8
	.long 0x15801907
	.long 0x000049CC
	.long 0x15801907
	.long 0x000049F4
	.long 0x08000018
	.long 0x00004A08
	.long 0x2C01B80C
	.long 0x00004A1C
	.long 0x2C81B00C
	.long 0x00004A64
	.long 0x08000004
	.long 0x00004A74
	.long 0x20990013
	.long 0x00004A88
	.long 0x20990013
	.long 0x00004AA0
	.long 0x0800000B
	.long 0x00004AD0
	.long 0x2D012010
	.long 0x00004AE0
	.long 0x0A00190B
	.long 0x00004AF4
	.long 0x0A00190B
	.long 0x00004AF8
	.long 0x2C00B010
	.long 0x00004B08
	.long 0x0A00190B
	.long 0x00005A9C
	.long 0x911914D2
	.long 0x00005DBC
	.long 0x34878000
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x0000380C
	.long 0x3D8F5C29
	.long 0x00003810
	.long 0x3FA00000
	.long 0x0000381C
	.long 0x3FA00000
	.long 0x0000382C
	.long 0x40A00000
	.long 0x00003858
	.long 0x3D83126F
	.long 0x000039AC
	.long 0x00000000
	.long 0x00003A84
	.long 0x44040000
	.long 0x00003A88
	.long 0x00041F6F
	.long 0x00003A8C
	.long 0x00007F40
	.long 0x00003A90
	.long 0x28000000
	.long 0x00003A94
	.long 0x04230000
	.long 0x00003A98
	.long 0x00000000
	.long 0x00003AA4
	.long 0x0C000005
	.long 0x00003AA8
	.long 0x2C000001
	.long 0x00003AAC
	.long 0x044C0000
	.long 0x00003AB0
	.long 0x05DCF448
	.long 0x00003AB4
	.long 0x5A000011
	.long 0x00003AB8
	.long 0x150C000F
	.long 0x00003ABC
	.long 0x2C800001
	.long 0x00003AC0
	.long 0x044C0000
	.long 0x00003AC4
	.long 0x05DC0BB8
	.long 0x00003AC8
	.long 0x5A000011
	.long 0x00003ACC
	.long 0x150C000F
	.long 0x00003AD0
	.long 0x2D000002
	.long 0x00003AD4
	.long 0x05780000
	.long 0x00003AD8
	.long 0x05DCFC18
	.long 0x00003ADC
	.long 0x5A000011
	.long 0x00003AE0
	.long 0x0B8C008F
	.long 0x00003AE4
	.long 0x2D800002
	.long 0x00003AE8
	.long 0x05780000
	.long 0x00003AEC
	.long 0x05DC03E8
	.long 0x00003AF0
	.long 0x5A000011
	.long 0x00003AF4
	.long 0x0B8C008F
	.long 0x00003AF8
	.long 0x04000001
	.long 0x00003AFC
	.long 0x40000000
	.long 0x00003B00
	.long 0x68000000
	.long 0x00003B10
	.long 0x076C0000
	.long 0x00003B1C
	.long 0x1E0C0123
	.long 0x00003B24
	.long 0x076C0000
	.long 0x00003B30
	.long 0x1E0C0123
	.long 0x00003B38
	.long 0x05DC0000
	.long 0x00003B44
	.long 0x1E0C00A3
	.long 0x00003B4C
	.long 0x05DC0000
	.long 0x00003B58
	.long 0x1E0C00A3
	.long 0x00003CB8
	.long 0x08000001
	.long 0x00003CBC
	.long 0x2C001804
	.long 0x00003CC0
	.long 0x07D00000
	.long 0x00003CC4
	.long 0x00000000
	.long 0x00003CC8
	.long 0xB4990F12
	.long 0x00003CCC
	.long 0x000400A3
	.long 0x00003CD0
	.long 0x04000002
	.long 0x00003CD4
	.long 0x40000000
	.long 0x00003CD8
	.long 0x0C00000A
	.long 0x00003CDC
	.long 0x94000001
	.long 0x00003CE0
	.long 0x8C000000
	.long 0x00003CE4
	.long 0x04000001
	.long 0x00003CE8
	.long 0x94000000
	.long 0x00003CEC
	.long 0x8C000001
	.long 0x00003D48
	.long 0x08000001
	.long 0x00003D4C
	.long 0x2C001804
	.long 0x00003D50
	.long 0x07D00000
	.long 0x00003D54
	.long 0x00000000
	.long 0x00003D58
	.long 0xB4990F12
	.long 0x00003D5C
	.long 0x000400A3
	.long 0x00003D60
	.long 0x04000002
	.long 0x00003D64
	.long 0x40000000
	.long 0x00003D68
	.long 0x0C000004
	.long 0x00003D6C
	.long 0x94000001
	.long 0x00003D70
	.long 0x8C000000
	.long 0x00003D74
	.long 0x04000001
	.long 0x00003D78
	.long 0x94000000
	.long 0x00003D7C
	.long 0x8C000001
	.long 0x00003D80
	.long 0x04000001
	.long 0x00003D84
	.long 0x10000000
	.long 0x00003D88
	.long 0x4C000001
	.long 0x00003D8C
	.long 0x0C000006
	.long 0x00003D90
	.long 0x94000001
	.long 0x00003D94
	.long 0x8C000000
	.long 0x00003D98
	.long 0x04000001
	.long 0x00003D9C
	.long 0x94000000
	.long 0x00003DA0
	.long 0x8C000001
	.long 0x00003EF0
	.long 0x41200000
	.long 0x00003F00
	.long 0x3DF5C28F
	.long 0x00003F04
	.long 0x42200000
	.long 0x00003F10
	.long 0x3FC66666
	.long 0x00003F14
	.long 0x40E00000
	.long 0x00003FC4
	.long 0x3F800000
	.long 0x00003FCC
	.long 0x41200000
	.long 0x00003FD0
	.long 0x3E0F5C29
	.long 0x00003FF0
	.long 0xB48F0000
	.long 0x000045E0
	.long 0x05080C1F
	.long 0x000045F4
	.long 0x05080C1F
	.long 0x00004608
	.long 0x05080C1F
	.long 0x0000461C
	.long 0x05080C1F
	.long 0x00004650
	.long 0x2C000003
	.long 0x0000465C
	.long 0xB49E0011
	.long 0x00004660
	.long 0x0A080C1F
	.long 0x00004664
	.long 0x2C826003
	.long 0x00004670
	.long 0xB49E0011
	.long 0x00004674
	.long 0x0A080C1F
	.long 0x00004678
	.long 0x2D024803
	.long 0x00004684
	.long 0xB49E0011
	.long 0x00004688
	.long 0x0A080C1F
	.long 0x0000468C
	.long 0x2D832003
	.long 0x00004698
	.long 0xB49E0011
	.long 0x0000469C
	.long 0x0A080C1F
	.long 0x00004718
	.long 0x23080D1F
	.long 0x0000472C
	.long 0x23080D1F
	.long 0x0000475C
	.long 0x0F080C9F
	.long 0x00004770
	.long 0x0F080C9F
	.long 0x000047E0
	.long 0x03840190
	.long 0x00004894
	.long 0x08000009
	.long 0x0000490C
	.long 0x0F000086
	.long 0x00004920
	.long 0x0F000085
	.long 0x00004934
	.long 0x0F000087
	.long 0x00004948
	.long 0x0F000087
	.long 0x00004964
	.long 0x0800000C
	.long 0x0000497C
	.long 0x0800001A
	.long 0x00004A18
	.long 0x5A190511
	.long 0x00004A2C
	.long 0x5A190471
	.long 0x00004A40
	.long 0x5A190471
	.long 0x00004A54
	.long 0x001903D1
	.long 0x00004B80
	.long 0x03840000
	.long 0x00004B94
	.long 0x044C0000
	.long 0x00004B98
	.long 0x0B54FC18
	.long 0x00004B9C
	.long 0x551903D0
	.long 0x00004BA8
	.long 0x044C0000
	.long 0x00004BAC
	.long 0x0B5403E8
	.long 0x00004BB0
	.long 0x551903D0
	.long 0x00004BBC
	.long 0x05DC0000
	.long 0x00004BC0
	.long 0x09C40000
	.long 0x00004BDC
	.long 0x08000015
	.long 0x00004BFC
	.long 0x03840000
	.long 0x00004C10
	.long 0x044C0000
	.long 0x00004C14
	.long 0x0B54FC18
	.long 0x00004C18
	.long 0x551903D0
	.long 0x00004C24
	.long 0x044C0000
	.long 0x00004C28
	.long 0x0B5403E8
	.long 0x00004C2C
	.long 0x551903D0
	.long 0x00004C38
	.long 0x05DC0000
	.long 0x00004C3C
	.long 0x09C40000
	.long 0x00004C60
	.long 0x060E0000
	.long 0x00004C64
	.long 0x0FA00000
	.long 0x00004C74
	.long 0x05780000
	.long 0x00004C78
	.long 0x0C80FBB4
	.long 0x00004C88
	.long 0x05780000
	.long 0x00004C8C
	.long 0x0C80044C
	.long 0x00004C9C
	.long 0x06400000
	.long 0x00004D04
	.long 0x2C00680C
	.long 0x00004D10
	.long 0x0F17C013
	.long 0x00004D18
	.long 0x2C80680C
	.long 0x00004D24
	.long 0x0F17C013
	.long 0x00004D78
	.long 0x0F154013
	.long 0x00004D8C
	.long 0x0F154013
	.long 0x00004DFC
	.long 0x03400000
	.long 0x00004E00
	.long 0x0940F880
	.long 0x00004E04
	.long 0x4B000011
	.long 0x00004E08
	.long 0x1B880807
	.long 0x00004E10
	.long 0x03400000
	.long 0x00004E14
	.long 0x07E005EE
	.long 0x00004E18
	.long 0x4B000011
	.long 0x00004E1C
	.long 0x1B880807
	.long 0x00004E24
	.long 0x04800000
	.long 0x00004E2C
	.long 0x37000011
	.long 0x00004E30
	.long 0x27080807
	.long 0x00004E38
	.long 0x04800000
	.long 0x00004E40
	.long 0x78000011
	.long 0x00004E44
	.long 0x16880807
	.long 0x00004E5C
	.long 0x04000000
	.long 0x00004E60
	.long 0x0940F880
	.long 0x00004E64
	.long 0xB4940011
	.long 0x00004E68
	.long 0x0F080007
	.long 0x00004E70
	.long 0x04000000
	.long 0x00004E74
	.long 0x051B0833
	.long 0x00004E78
	.long 0xB4940011
	.long 0x00004E7C
	.long 0x0F080007
	.long 0x00004E84
	.long 0x05800000
	.long 0x00004E8C
	.long 0xB4940011
	.long 0x00004E90
	.long 0x0F080007
	.long 0x00004E98
	.long 0x05800000
	.long 0x00004EA0
	.long 0xB4940011
	.long 0x00004EA4
	.long 0x0F080007
	.long 0x00005054
	.long 0x2C00000F
	.long 0x00005058
	.long 0x09600000
	.long 0x00005060
	.long 0x2D1B8011
	.long 0x00005064
	.long 0x0F040123
	.long 0x000050AC
	.long 0x2C00380F
	.long 0x000050B8
	.long 0x89968013
	.long 0x000050BC
	.long 0x1408010B
	.long 0x000050C0
	.long 0x2C80500D
	.long 0x000050D0
	.long 0x0F08010B
	.long 0x00006390
	.long 0x08000006
	.long 0x000063A8
	.long 0x09600960
	.long 0x000063BC
	.long 0x096003E8
	.long 0x000063F8
	.long 0x08000009
	.long 0x00006410
	.long 0x05780C80
	.long 0x00006424
	.long 0x05780960
	.long 0x00006438
	.long 0x057804B0
	.long 0x00006570
	.long 0x168F0000
	.long 0x00006668
	.long 0x16918000
	.long 0x0000697C
	.long 0xD0000004
	.long 0x00006980
	.long 0x2C000005
	.long 0x00006984
	.long 0x05B00000
	.long 0x00006988
	.long 0x0940FB50
	.long 0x0000698C
	.long 0x321906D1
	.long 0x00006990
	.long 0x0008001F
	.long 0x00006994
	.long 0x2C800005
	.long 0x00006998
	.long 0x05B00000
	.long 0x0000699C
	.long 0x051B04B0
	.long 0x000069A0
	.long 0x321906D1
	.long 0x000069A4
	.long 0x0008001F
	.long 0x000069A8
	.long 0x04000008
	.long 0x000069AC
	.long 0x40000000
	.long 0x000069B0
	.long 0xDC0003FA
	.long 0xCC0083CC
	.long 0x0000695C
	.long 0xFFFFFFFF
	.long 0x00003698
	.long 0x42200000
	.long 0x00003B8C
	.long 0x440C0000
	.long 0x00003BA0
	.long 0x03840000
	.long 0x00003BB4
	.long 0x03E80000
	.long 0x00003BC8
	.long 0x03E80000
	.long 0x00003BDC
	.long 0x03840000
	.long 0x00003BFC
	.long 0x05140000
	.long 0x00003C04
	.long 0x10190010
	.long 0x00003C10
	.long 0x05780000
	.long 0x00003C18
	.long 0x10190010
	.long 0x00003C24
	.long 0x05780000
	.long 0x00003C2C
	.long 0x10190010
	.long 0x00003C38
	.long 0x05140000
	.long 0x00003C40
	.long 0x10190010
	.long 0x00003D0C
	.long 0x440C0000
	.long 0x00004148
	.long 0x3FD33333
	.long 0x00004194
	.long 0x02000000
	.long 0x000041A0
	.long 0x1E060063
	.long 0x00004A1C
	.long 0x28094013
	.long 0x00004A20
	.long 0x080C0007
	.long 0x00004A30
	.long 0xB4894013
	.long 0x00004A34
	.long 0x080C0007
	.long 0x00004A44
	.long 0xB4894013
	.long 0x00004A48
	.long 0x080C0007
	.long 0x00004A58
	.long 0x28094013
	.long 0x00004A5C
	.long 0x080C0007
	.long 0x00004A8C
	.long 0x08000010
	.long 0x00004AB4
	.long 0x32050013
	.long 0x00004AB8
	.long 0x140C0007
	.long 0x00004AC8
	.long 0x29050013
	.long 0x00004ACC
	.long 0x140C0007
	.long 0x00004ADC
	.long 0x1E050013
	.long 0x00004AE0
	.long 0x140C0007
	.long 0x00004AF0
	.long 0x19050013
	.long 0x00004AF4
	.long 0x140C0007
	.long 0x00004B24
	.long 0x0800000D
	.long 0x00004B4C
	.long 0x0F0C0087
	.long 0x00004B60
	.long 0x0F0C0087
	.long 0x00004B74
	.long 0x0F0C0087
	.long 0x00004B88
	.long 0x0F0C0087
	.long 0x00004CA0
	.long 0x0F190013
	.long 0x00004CB4
	.long 0x0F190013
	.long 0x00004CC8
	.long 0x0F190013
	.long 0x00004CDC
	.long 0x0F190013
	.long 0x00004D18
	.long 0x08000024
	.long 0x00004D4C
	.long 0x11990013
	.long 0x00004D50
	.long 0x078C0087
	.long 0x00004D60
	.long 0x11990013
	.long 0x00004D64
	.long 0x078C0087
	.long 0x00004D74
	.long 0x11990013
	.long 0x00004D78
	.long 0x068C0087
	.long 0x00004D88
	.long 0x11990013
	.long 0x00004D8C
	.long 0x068C0087
	.long 0x00004DDC
	.long 0x2C00E009
	.long 0x00004DE8
	.long 0x2A990013
	.long 0x00004DEC
	.long 0x190C0087
	.long 0x00004DF0
	.long 0x2C80C809
	.long 0x00004DFC
	.long 0x2A990013
	.long 0x00004E00
	.long 0x190C0087
	.long 0x00004E04
	.long 0x2D009809
	.long 0x00004E10
	.long 0x2A990013
	.long 0x00004E14
	.long 0x190C0087
	.long 0x00004E18
	.long 0x2D80E009
	.long 0x00004E24
	.long 0x2F990013
	.long 0x00004E28
	.long 0x190C000F
	.long 0x00004E4C
	.long 0x0800001E
	.long 0x00004E74
	.long 0x230C8013
	.long 0x00004E88
	.long 0x230C8013
	.long 0x00004E9C
	.long 0x230C8013
	.long 0x00004EB0
	.long 0x8C0C8013
	.long 0x00004F44
	.long 0xB4990513
	.long 0x00004F58
	.long 0x05190513
	.long 0x00004F6C
	.long 0x11990513
	.long 0x00004F80
	.long 0xB4990513
	.long 0x00004FB8
	.long 0x08000010
	.long 0x00004FBC
	.long 0x4C000001
	.long 0x00004FC0
	.long 0x04000003
	.long 0x00004FC4
	.long 0x40000000
	.long 0x00004FC8
	.long 0x04000002
	.long 0x00004FCC
	.long 0xC5FFFFFF
	.long 0x00004FD0
	.long 0x08000028
	.long 0x00005008
	.long 0x2C00E00D
	.long 0x0000500C
	.long 0x05DC01F4
	.long 0x0000501C
	.long 0x2C80C80D
	.long 0x00005020
	.long 0x044C0000
	.long 0x00005030
	.long 0x2D00980D
	.long 0x00005034
	.long 0x03840000
	.long 0x00005044
	.long 0x2D80E00D
	.long 0x00005048
	.long 0x05DC0578
	.long 0x000050E0
	.long 0x0800000A
	.long 0x000050E8
	.long 0x06720384
	.long 0x000050F0
	.long 0x2F9B8513
	.long 0x000050F4
	.long 0x000C0007
	.long 0x000050FC
	.long 0x067201C2
	.long 0x00005104
	.long 0x311B8613
	.long 0x00005108
	.long 0x000C0007
	.long 0x00005110
	.long 0x04B00000
	.long 0x00005118
	.long 0x311B8513
	.long 0x0000511C
	.long 0x000C0007
	.long 0x00005124
	.long 0x03E80000
	.long 0x0000512C
	.long 0x311B8513
	.long 0x00005130
	.long 0x000C0007
	.long 0x00005164
	.long 0x04000007
	.long 0x0000516C
	.long 0x04000003
	.long 0x00005174
	.long 0x08000014
	.long 0x0000517C
	.long 0x08000016
	.long 0x00005184
	.long 0x06720384
	.long 0x0000518C
	.long 0x2E9B83F3
	.long 0x00005198
	.long 0x067201C2
	.long 0x000051A0
	.long 0x301B8433
	.long 0x000051AC
	.long 0x04B00000
	.long 0x000051B4
	.long 0x301B84B3
	.long 0x000051C0
	.long 0x03E80000
	.long 0x000051C8
	.long 0x301B8513
	.long 0x000051E0
	.long 0x04000009
	.long 0x000051E8
	.long 0x04000008
	.long 0x000051F0
	.long 0x08000023
	.long 0x000051F8
	.long 0x08000024
	.long 0x000051FC
	.long 0x2C00E00B
	.long 0x00005200
	.long 0x06720384
	.long 0x00005208
	.long 0x30174013
	.long 0x0000520C
	.long 0x218C0107
	.long 0x00005210
	.long 0x2C80E00C
	.long 0x00005214
	.long 0x067201C2
	.long 0x0000521C
	.long 0x30174013
	.long 0x00005220
	.long 0x218C0107
	.long 0x00005224
	.long 0x2D00C80C
	.long 0x00005228
	.long 0x04B00000
	.long 0x00005230
	.long 0x30174013
	.long 0x00005234
	.long 0x218C0107
	.long 0x00005238
	.long 0x2D809809
	.long 0x0000523C
	.long 0x03E80000
	.long 0x00005244
	.long 0x30174013
	.long 0x00005248
	.long 0x218C0107
	.long 0x00005260
	.long 0x04000007
	.long 0x00005264
	.long 0x2C00E00C
	.long 0x00005278
	.long 0x2C80E00D
	.long 0x0000528C
	.long 0x2D00C80D
	.long 0x000052A0
	.long 0x2D80980D
	.long 0x000052BC
	.long 0x04000009
	.long 0x000052C4
	.long 0x0800003C
	.long 0x00005324
	.long 0x0F168013
	.long 0x00005338
	.long 0x0F168013
	.long 0x00005340
	.long 0x2D80E00C
	.long 0x000053C8
	.long 0x0F168013
	.long 0x000053DC
	.long 0x0F168013
	.long 0x000053E4
	.long 0x2D80E00B
	.long 0x00005424
	.long 0x08000024
	.long 0x00005434
	.long 0x08000025
	.long 0x00005454
	.long 0xB49B8013
	.long 0x00005468
	.long 0xB49B8013
	.long 0x0000547C
	.long 0xB49B8013
	.long 0x00005494
	.long 0x04000004
	.long 0x000054A4
	.long 0x1E190013
	.long 0x000054B8
	.long 0x1E190013
	.long 0x000054CC
	.long 0x1E190013
	.long 0x000054D4
	.long 0x04000014
	.long 0x000054DC
	.long 0x04000002
	.long 0x00005510
	.long 0x0B0C0107
	.long 0x00005514
	.long 0x2C80C80C
	.long 0x00005524
	.long 0x0B0C0107
	.long 0x00005528
	.long 0x2D00980C
	.long 0x00005538
	.long 0x0B0C0107
	.long 0x0000553C
	.long 0x2D80E00C
	.long 0x0000554C
	.long 0x0B0C0107
	.long 0x00005560
	.long 0x04000006
	.long 0x00005570
	.long 0x26118013
	.long 0x00005574
	.long 0x160C0087
	.long 0x00005584
	.long 0x26118013
	.long 0x00005588
	.long 0x160C0087
	.long 0x00005598
	.long 0x26118013
	.long 0x0000559C
	.long 0x160C0087
	.long 0x000055A0
	.long 0x2D80E007
	.long 0x000055AC
	.long 0x26118013
	.long 0x000055B0
	.long 0x160C0087
	.long 0x000055E0
	.long 0x2C00380A
	.long 0x000055EC
	.long 0x201D4013
	.long 0x000055F0
	.long 0x0900008B
	.long 0x000055F4
	.long 0x2C80380A
	.long 0x00005600
	.long 0x201D4013
	.long 0x00005604
	.long 0x0900008B
	.long 0x00005608
	.long 0x2D00200A
	.long 0x00005614
	.long 0x201D4013
	.long 0x00005618
	.long 0x0900008B
	.long 0x00005640
	.long 0x2C00680A
	.long 0x00005644
	.long 0x04E20055
	.long 0x0000564C
	.long 0x201D4013
	.long 0x00005650
	.long 0x0900008B
	.long 0x00005654
	.long 0x2C80680A
	.long 0x00005658
	.long 0x04E202FE
	.long 0x00005660
	.long 0x201D4013
	.long 0x00005664
	.long 0x0900008B
	.long 0x00005668
	.long 0x2D00200A
	.long 0x0000566C
	.long 0x05780000
	.long 0x00005674
	.long 0x201D4013
	.long 0x00005678
	.long 0x0900008B
	.long 0x00005698
	.long 0x08000018
	.long 0x000056C4
	.long 0x28170013
	.long 0x000056D8
	.long 0x28170013
	.long 0x000056EC
	.long 0x28170013
	.long 0x00005764
	.long 0x168C0107
	.long 0x00005778
	.long 0x168C0107
	.long 0x00006B1C
	.long 0x0020008B
	.long 0x00006B44
	.long 0x0020008B
	.long 0x00006B70
	.long 0x0020008B
	.long 0x00006BA8
	.long 0x0020008B
	.long 0x00006BBC
	.long 0x0020008B
	.long 0x00006BE8
	.long 0x0020008B
	.long 0x00006C30
	.long 0x0D9B8000
	.long 0x00006C34
	.long 0x16822000
	.long 0x00006CC8
	.long 0x16022000
	.long 0x00006D8C
	.long 0x2D168000
	.long 0x00006D90
	.long 0x20022000
	.long 0x00006DC0
	.long 0x2C80E008
	.long 0x00006DCC
	.long 0x0A0B4010
	.long 0x00006DD0
	.long 0x1E0C010F
	.long 0xFFFFFFFF
	.long 0x000036E0
	.long 0x41700000
	.long 0x00003704
	.long 0x3F199999
	.long 0x00003718
	.long 0x3FA66666
	.long 0x0000371C
	.long 0x3FD9999A
	.long 0x000040FC
	.long 0x29990473
	.long 0x00004110
	.long 0x29990473
	.long 0x00004124
	.long 0x2A990473
	.long 0x0000414C
	.long 0x0800000A
	.long 0x00004270
	.long 0x2C823009
	.long 0x00004274
	.long 0x03840190
	.long 0x00004278
	.long 0x00000000
	.long 0x000042AC
	.long 0x2C023008
	.long 0x000042B0
	.long 0x03840190
	.long 0x000042B4
	.long 0x00000000
	.long 0x00004574
	.long 0x08000019
	.long 0x00004660
	.long 0x04000008
	.long 0x00004760
	.long 0x04000008
	.long 0x00004860
	.long 0x04000008
	.long 0x00004A84
	.long 0x08000007
	.long 0x00005D64
	.long 0x03B60000
	.long 0x00005D78
	.long 0x03B60000
	.long 0x00005DB8
	.long 0x03B60000
	.long 0x00005DCC
	.long 0x03B60000
	.long 0x00005DE0
	.long 0x03B60000
	.long 0xFFFFFFFF
	.long 0xFFFFFFFF
	.long 0x0000346C
	.long 0x3D75C28F
	.long 0x00003494
	.long 0x40200000
	.long 0x000034A0
	.long 0x3FB33333
	.long 0x000034C0
	.long 0x3F8CCCCD
	.long 0x0000354C
	.long 0x41A00000
	.long 0x00003618
	.long 0x3CA3D70A
	.long 0x000036E4
	.long 0xCC000000
	.long 0x00003734
	.long 0xCC000000
	.long 0x000037C4
	.long 0xCC000000
	.long 0x000037D4
	.long 0xB4990013
	.long 0x000037D8
	.long 0x0A08109F
	.long 0x00003858
	.long 0xCC000000
	.long 0x000038D0
	.long 0xCC000000
	.long 0x000039D8
	.long 0xCC000001
	.long 0x00003B5C
	.long 0x40000000
	.long 0x00003CEC
	.long 0x09600000
	.long 0x00003CF4
	.long 0xB4A1C000
	.long 0x0000417C
	.long 0x08000005
	.long 0x00004180
	.long 0x2C007809
	.long 0x00004184
	.long 0x047E0000
	.long 0x00004188
	.long 0x04B0007F
	.long 0x0000418C
	.long 0xB49B4013
	.long 0x00004190
	.long 0x14000107
	.long 0x00004194
	.long 0x2C802009
	.long 0x00004198
	.long 0x02FE0000
	.long 0x0000419C
	.long 0x00AA0000
	.long 0x000041A0
	.long 0xB49B4013
	.long 0x000041A4
	.long 0x14000107
	.long 0x000041A8
	.long 0x28000000
	.long 0x000041AC
	.long 0x03FD0000
	.long 0x000041B0
	.long 0x00000000
	.long 0x000041BC
	.long 0x04000005
	.long 0x000041C0
	.long 0x2C802006
	.long 0x000041C4
	.long 0x03200000
	.long 0x000041C8
	.long 0x00AA0000
	.long 0x000041CC
	.long 0x0F1EC013
	.long 0x000041D0
	.long 0x0500008B
	.long 0x000041D4
	.long 0x3C000000
	.long 0x000041D8
	.long 0x08000011
	.long 0x000041DC
	.long 0x40000000
	.long 0x000041E0
	.long 0xD0000003
	.long 0x000041E4
	.long 0x28000000
	.long 0x000041E8
	.long 0x03FF0000
	.long 0x000041EC
	.long 0x00000000
	.long 0x000041F0
	.long 0x00000000
	.long 0x000041F4
	.long 0x00000000
	.long 0x000041F8
	.long 0x44000000
	.long 0x000041FC
	.long 0x0000000B
	.long 0x00004200
	.long 0x00007F40
	.long 0x00004204
	.long 0x08000021
	.long 0x00004358
	.long 0x1900008B
	.long 0x0000436C
	.long 0x1B80008B
	.long 0x00004380
	.long 0x1B80008B
	.long 0x000043D0
	.long 0x0C990013
	.long 0x000043E4
	.long 0x0C990013
	.long 0x000043F8
	.long 0x0C990013
	.long 0x000044A8
	.long 0xCC000001
	.long 0x000044D8
	.long 0x04C60000
	.long 0x000044DC
	.long 0x070808FC
	.long 0x000044E0
	.long 0x001903D0
	.long 0x000044E4
	.long 0x0008009F
	.long 0x000044EC
	.long 0x051B0000
	.long 0x000044F0
	.long 0x07081004
	.long 0x000044F4
	.long 0x7D190510
	.long 0x000044F8
	.long 0x0008009F
	.long 0x00004500
	.long 0x061B0000
	.long 0x00004504
	.long 0x070816A8
	.long 0x00004508
	.long 0x5A190510
	.long 0x0000450C
	.long 0x0008009F
	.long 0x00004520
	.long 0x05F20000
	.long 0x00004524
	.long 0x070808FC
	.long 0x00004534
	.long 0x06470000
	.long 0x00004538
	.long 0x07081004
	.long 0x00004548
	.long 0x07470000
	.long 0x0000454C
	.long 0x070816A8
	.long 0x00004698
	.long 0x50168013
	.long 0x000046AC
	.long 0x50168013
	.long 0x000046C0
	.long 0x50168013
	.long 0x00004704
	.long 0x08000029
	.long 0x0000470C
	.long 0x0800002B
	.long 0x000047D8
	.long 0x44040000
	.long 0x000047DC
	.long 0x00000097
	.long 0x000047E0
	.long 0x00007F40
	.long 0x000047E4
	.long 0xCC000001
	.long 0x000047E8
	.long 0x2C00780B
	.long 0x000047EC
	.long 0x067D0000
	.long 0x000047F0
	.long 0x0229007F
	.long 0x000047F4
	.long 0x19168013
	.long 0x000047F8
	.long 0x0F080107
	.long 0x000047FC
	.long 0x2C80200B
	.long 0x00004800
	.long 0x05A80000
	.long 0x00004804
	.long 0x00000000
	.long 0x00004808
	.long 0x19168013
	.long 0x0000480C
	.long 0x0F080107
	.long 0x00004810
	.long 0x0400000E
	.long 0x00004814
	.long 0x40000000
	.long 0x00004818
	.long 0x0400000A
	.long 0x0000481C
	.long 0x4C000000
	.long 0x00004820
	.long 0x08000028
	.long 0x00004824
	.long 0x5C000000
	.long 0x00004828
	.long 0xCC000000
	.long 0x0000482C
	.long 0xCC000000
	.long 0x00004830
	.long 0xCC000000
	.long 0x00004850
	.long 0xCC000001
	.long 0x00004854
	.long 0x2C00780C
	.long 0x00004858
	.long 0x03840000
	.long 0x0000485C
	.long 0x00000000
	.long 0x00004860
	.long 0x101F4013
	.long 0x00004864
	.long 0x0A08010B
	.long 0x00004868
	.long 0x2C80200C
	.long 0x0000486C
	.long 0x03840000
	.long 0x00004870
	.long 0x00000000
	.long 0x00004874
	.long 0x101F4013
	.long 0x00004878
	.long 0x0A08010B
	.long 0x0000487C
	.long 0x2D00800C
	.long 0x00004880
	.long 0x03840000
	.long 0x00004884
	.long 0xFE0C0000
	.long 0x00004888
	.long 0x101F4013
	.long 0x0000488C
	.long 0x0A08010B
	.long 0x00004890
	.long 0x04000004
	.long 0x00004894
	.long 0x2C007809
	.long 0x00004898
	.long 0x03840000
	.long 0x0000489C
	.long 0x00000000
	.long 0x000048A0
	.long 0xB4990013
	.long 0x000048A4
	.long 0x0A00000B
	.long 0x000048A8
	.long 0x2C802009
	.long 0x000048AC
	.long 0x03840000
	.long 0x000048B0
	.long 0x00000000
	.long 0x000048B4
	.long 0xB4990013
	.long 0x000048B8
	.long 0x0A00000B
	.long 0x000048BC
	.long 0x2D008009
	.long 0x000048C0
	.long 0x03840000
	.long 0x000048C4
	.long 0xFE0C0000
	.long 0x000048C8
	.long 0xB4990013
	.long 0x000048CC
	.long 0x0A00000B
	.long 0x000048D0
	.long 0x08000026
	.long 0x000048D4
	.long 0x40000000
	.long 0x000048D8
	.long 0x08000032
	.long 0x000048DC
	.long 0x4C000000
	.long 0x00004910
	.long 0x2800000B
	.long 0x00004924
	.long 0x2800000B
	.long 0x00004938
	.long 0x2800000B
	.long 0x00004950
	.long 0x2800000B
	.long 0x00004964
	.long 0x2800000B
	.long 0x00004978
	.long 0x2800000B
	.long 0x00004990
	.long 0x2800000B
	.long 0x000049A4
	.long 0x2800000B
	.long 0x000049B8
	.long 0x2800000B
	.long 0x00004A04
	.long 0x87140013
	.long 0x00004A18
	.long 0x87140013
	.long 0x00004B08
	.long 0x07290000
	.long 0x00004B10
	.long 0x87078013
	.long 0x00004B14
	.long 0x1E08011E
	.long 0x00004B1C
	.long 0x062A0000
	.long 0x00004B24
	.long 0x87078013
	.long 0x00004B28
	.long 0x1E08011E
	.long 0x00004B2C
	.long 0xCC000000
	.long 0x00005334
	.long 0x08000014
	.long 0x00005B34
	.long 0xCC000000
	.long 0x00005B9C
	.long 0xCC000000
	.long 0x00005D94
	.long 0x20898000
	.long 0x00005D98
	.long 0x28122000
	.long 0xCC007AC8
	.long 0x00000B60
	.long 0x00007ACC
	.long 0x00068760
	.long 0x00007AD0
	.long 0x000017A0
	.long 0x00007AD8
	.long 0x00000017
	.long 0xFFFFFFFF
	.long 0x0000367C
	.long 0x3D3851EC
	.long 0x00003680
	.long 0x3F8A5E35
	.long 0x0000369C
	.long 0x42960000
	.long 0x000036A4
	.long 0x41810000
	.long 0x000036FC
	.long 0x41C00000
	.long 0x00003700
	.long 0x41B00000
	.long 0x00003704
	.long 0x41B00000
	.long 0x00003708
	.long 0x41A00000
	.long 0x0000370C
	.long 0x41800000
	.long 0x000037B0
	.long 0x41700000
	.long 0x00003950
	.long 0xB49E0013
	.long 0x00003954
	.long 0x16BC0007
	.long 0x00003964
	.long 0xB49E0013
	.long 0x00003968
	.long 0x16BC0007
	.long 0x00003990
	.long 0x1E00511B
	.long 0x000039A4
	.long 0x1E00511B
	.long 0x000039BC
	.long 0x2C008804
	.long 0x000039C8
	.long 0x141E0013
	.long 0x000039CC
	.long 0x3234010B
	.long 0x000039D0
	.long 0x2C808804
	.long 0x000039DC
	.long 0x141E0013
	.long 0x000039E0
	.long 0x3234010B
	.long 0x00003A08
	.long 0x25878013
	.long 0x00003A0C
	.long 0x2808009F
	.long 0x00003A1C
	.long 0x25878013
	.long 0x00003A20
	.long 0x2808009F
	.long 0x00003A8C
	.long 0xB4918013
	.long 0x00003A90
	.long 0x1E0C0123
	.long 0x00003AA0
	.long 0xB4918013
	.long 0x00003AA4
	.long 0x1E0C0123
	.long 0x00003ABC
	.long 0x2C008810
	.long 0x00003AC8
	.long 0x0F1908D3
	.long 0x00003AD0
	.long 0x2C808810
	.long 0x00003ADC
	.long 0x0F1908D3
	.long 0x00003B88
	.long 0x2C000008
	.long 0x00004590
	.long 0x0800000D
	.long 0x0000497C
	.long 0x220C8013
	.long 0x000049E4
	.long 0x12990013
	.long 0x000049E8
	.long 0x0A00008B
	.long 0x000049F8
	.long 0x12990013
	.long 0x000049FC
	.long 0x0A00008B
	.long 0x00004A0C
	.long 0x12990013
	.long 0x00004A10
	.long 0x0A00008B
	.long 0x00004A20
	.long 0x12990013
	.long 0x00004A24
	.long 0x0A00008B
	.long 0x00004A40
	.long 0x08000026
	.long 0x00004AF0
	.long 0x218E0013
	.long 0x00004AF4
	.long 0x30000089
	.long 0x00004BD0
	.long 0x2C00000C
	.long 0x00004BE4
	.long 0x2C80000C
	.long 0x00004BF8
	.long 0x2D00C00C
	.long 0x00004C64
	.long 0x2C00A015
	.long 0x00004C74
	.long 0x14003D07
	.long 0x00004CAC
	.long 0x08000026
	.long 0x00004D1C
	.long 0x2C00000C
	.long 0x00004D28
	.long 0x0A110013
	.long 0x00004D2C
	.long 0x1900008B
	.long 0x00004D30
	.long 0x2C80000C
	.long 0x00004D3C
	.long 0x0A110013
	.long 0x00004D40
	.long 0x1900008B
	.long 0x00004D50
	.long 0x28190013
	.long 0x00004D64
	.long 0x28190013
	.long 0x00004DAC
	.long 0x08000021
	.long 0x00004E2C
	.long 0xB4968013
	.long 0x00004E30
	.long 0x07800107
	.long 0x00004E40
	.long 0xB4968013
	.long 0x00004E44
	.long 0x07800107
	.long 0x00004E68
	.long 0xB4954013
	.long 0x00004E7C
	.long 0xB4954013
	.long 0x00004EBC
	.long 0x1E00088F
	.long 0x00004ED0
	.long 0x1E00088F
	.long 0x00004F00
	.long 0x2F0F0013
	.long 0x00004F04
	.long 0x0800008B
	.long 0x00004F14
	.long 0x2F0F0013
	.long 0x00004F18
	.long 0x0800008B
	.long 0x00004F2C
	.long 0x04000007
	.long 0x00004F34
	.long 0x08000010
	.long 0x00004F3C
	.long 0x079E0000
	.long 0x00004F50
	.long 0x05460000
	.long 0x00004F70
	.long 0x04000007
	.long 0x00004FC8
	.long 0x04000005
	.long 0x00005080
	.long 0x07080000
	.long 0x00005084
	.long 0x03200258
	.long 0x00005088
	.long 0x87140013
	.long 0x0000508C
	.long 0x1900010A
	.long 0xFFFFFFFF
	.long 0x00003738
	.long 0x3FAA3D71
	.long 0x00003744
	.long 0x3FB0A3D7
	.long 0x00003754
	.long 0x40A00000
	.long 0x00003800
	.long 0x40800000
	.long 0x00003814
	.long 0x42000000
	.long 0x000038DC
	.long 0x41F00000
	.long 0x000038E4
	.long 0x3F933333
	.long 0x000038EC
	.long 0x41D00000
	.long 0x00003920
	.long 0x3FE66666
	.long 0x00003E1C
	.long 0x00200087
	.long 0x00003E64
	.long 0x08000021
	.long 0x000046A0
	.long 0x68000001
	.long 0x000046A4
	.long 0x2C02100E
	.long 0x000046A8
	.long 0x05DC0000
	.long 0x000046AC
	.long 0x000000C8
	.long 0x000046B0
	.long 0x39940013
	.long 0x000046B4
	.long 0x14000507
	.long 0x000046B8
	.long 0x28000000
	.long 0x000046BC
	.long 0x03FD0000
	.long 0x000046C0
	.long 0x00000000
	.long 0x000046CC
	.long 0x04000003
	.long 0x000046D0
	.long 0x68000000
	.long 0x000046E8
	.long 0x04000009
	.long 0x00004870
	.long 0x28000000
	.long 0x00004874
	.long 0x04060000
	.long 0x00004878
	.long 0x00000000
	.long 0x0000487C
	.long 0x00000000
	.long 0x00004884
	.long 0x28000000
	.long 0x00004888
	.long 0x04070000
	.long 0x0000488C
	.long 0x00000000
	.long 0x00004890
	.long 0x00000000
	.long 0x00004894
	.long 0x00000000
	.long 0x00004898
	.long 0x28000000
	.long 0x0000489C
	.long 0x05140000
	.long 0x000048A0
	.long 0x00000000
	.long 0x000048A4
	.long 0x00000000
	.long 0x000048A8
	.long 0x00000000
	.long 0x000048AC
	.long 0x08000002
	.long 0x000048B0
	.long 0xCC000000
	.long 0x000048B4
	.long 0xCC000000
	.long 0x000048B8
	.long 0xCC000000
	.long 0x000048BC
	.long 0x08000003
	.long 0x000048C0
	.long 0x2C00C80D
	.long 0x000048C4
	.long 0x03E80000
	.long 0x000048C8
	.long 0x00000000
	.long 0x000048CC
	.long 0x2D1AC013
	.long 0x000048D0
	.long 0x14343D23
	.long 0x000048D4
	.long 0x2C80B80D
	.long 0x000048D8
	.long 0x03E80000
	.long 0x000048DC
	.long 0x00000000
	.long 0x000048E0
	.long 0x2D1AC013
	.long 0x000048E4
	.long 0x14343D23
	.long 0x000048E8
	.long 0x2D00200A
	.long 0x000048EC
	.long 0x03E80000
	.long 0x000048F0
	.long 0x00000000
	.long 0x000048F4
	.long 0xB49B8013
	.long 0x000048F8
	.long 0x0A002923
	.long 0x000048FC
	.long 0x44040000
	.long 0x00004900
	.long 0x000000A6
	.long 0x00004904
	.long 0x00007F40
	.long 0x00004908
	.long 0x44000000
	.long 0x0000490C
	.long 0x00000074
	.long 0x00004910
	.long 0x00007F40
	.long 0x00004914
	.long 0x44080000
	.long 0x00004918
	.long 0x000493F0
	.long 0x0000491C
	.long 0x00007F40
	.long 0x00004920
	.long 0x04000006
	.long 0x00004924
	.long 0x6C000000
	.long 0x00004928
	.long 0x44000000
	.long 0x0000492C
	.long 0x00000074
	.long 0x00004930
	.long 0x00007F40
	.long 0x00004934
	.long 0x04000003
	.long 0x00004938
	.long 0x40000000
	.long 0x0000493C
	.long 0x08000016
	.long 0x00004940
	.long 0xD0000000
	.long 0x00004944
	.long 0x08000017
	.long 0x00004948
	.long 0x5C000000
	.long 0x0000494C
	.long 0xD0000003
	.long 0x00004950
	.long 0xCC000000
	.long 0x00004954
	.long 0xCC000000
	.long 0x00004958
	.long 0xCC000000
	.long 0x0000495C
	.long 0xCC000000
	.long 0x00004960
	.long 0xCC000000
	.long 0x00004964
	.long 0xCC000000
	.long 0x00004968
	.long 0xCC000000
	.long 0x0000496C
	.long 0xCC000000
	.long 0x00004E1C
	.long 0x04000005
	.long 0x00004E24
	.long 0x08000010
	.long 0x00004E74
	.long 0x0400000B
	.long 0x00004E7C
	.long 0x4C000000
	.long 0x00004E80
	.long 0x04000004
	.long 0x00006038
	.long 0x0AF007D0
	.long 0x000060A0
	.long 0x0A280960
	.long 0xCC007B80
	.long 0x000022A4
	.long 0x00007B84
	.long 0x00086D80
	.long 0x00007B88
	.long 0x00001C32
	.long 0xFFFFFFFF
	.long 0x00003900
	.long 0x3D4CCCCD
	.long 0x00003908
	.long 0x3F778D50
	.long 0x00003A24
	.long 0x00000007
	.long 0x00003A3C
	.long 0x3FB33333
	.long 0x00003D8C
	.long 0x2E864013
	.long 0x00003D90
	.long 0x190C000F
	.long 0x00003DA0
	.long 0x2C064013
	.long 0x00003DA4
	.long 0x190C000F
	.long 0x00003DBC
	.long 0x2D827005
	.long 0x00003DC8
	.long 0x29864013
	.long 0x00003DCC
	.long 0x1900000F
	.long 0x00003E88
	.long 0x2D827006
	.long 0x00003E98
	.long 0x1900008F
	.long 0x00003E9C
	.long 0x0800000E
	.long 0x00003EA0
	.long 0x28000000
	.long 0x00003EA4
	.long 0x03F70000
	.long 0x00003EA8
	.long 0x00000000
	.long 0x00003EAC
	.long 0x00000000
	.long 0x00003EB4
	.long 0x4C000001
	.long 0x00003EB8
	.long 0x0800000F
	.long 0x00003EBC
	.long 0x40000000
	.long 0x00003F40
	.long 0x2C00D805
	.long 0x00003F54
	.long 0x2D827006
	.long 0x0000401C
	.long 0x2D82700A
	.long 0x00004028
	.long 0x8C0F0013
	.long 0x0000402C
	.long 0x2800050F
	.long 0x00004070
	.long 0x2D827007
	.long 0x000040FC
	.long 0x2C027009
	.long 0x0000410C
	.long 0x200C050F
	.long 0x00004110
	.long 0x2C824809
	.long 0x00004120
	.long 0x200C050F
	.long 0x00004124
	.long 0x2D00D809
	.long 0x00004134
	.long 0x200C050F
	.long 0x00004138
	.long 0x2D827009
	.long 0x00004148
	.long 0x20000507
	.long 0x000041F8
	.long 0x000414A3
	.long 0x0000420C
	.long 0x000414A3
	.long 0x00004220
	.long 0x000414A3
	.long 0x00004234
	.long 0x0F0414A3
	.long 0x00004258
	.long 0x28041923
	.long 0x0000426C
	.long 0x28041923
	.long 0x00004280
	.long 0x28041923
	.long 0x00004294
	.long 0x28041923
	.long 0x0000434C
	.long 0x2D82700D
	.long 0x00004408
	.long 0x2D82700D
	.long 0x000044B0
	.long 0x0104148F
	.long 0x000044C4
	.long 0x0104148F
	.long 0x000044D8
	.long 0x0104148F
	.long 0x000044EC
	.long 0x0104148F
	.long 0x00004534
	.long 0x0F041523
	.long 0x00004548
	.long 0x0F041523
	.long 0x0000455C
	.long 0x0F041523
	.long 0x00004570
	.long 0x0F041523
	.long 0x00004624
	.long 0x2D82700A
	.long 0x00004678
	.long 0x2D827007
	.long 0x0000480C
	.long 0x2C027003
	.long 0x00004818
	.long 0x2A348010
	.long 0x0000481C
	.long 0x0F0400A3
	.long 0x00004820
	.long 0x2C827003
	.long 0x0000482C
	.long 0x2A348010
	.long 0x00004830
	.long 0x0F0400A3
	.long 0x00004834
	.long 0x2D002003
	.long 0x00004840
	.long 0x2A348010
	.long 0x00004844
	.long 0x0F0400A3
	.long 0x00004848
	.long 0x2D827003
	.long 0x00004854
	.long 0xB4AF8010
	.long 0x00004858
	.long 0x0F04000F
	.long 0x0000485C
	.long 0x04000004
	.long 0x00004E28
	.long 0x2D827004
	.long 0x00004E38
	.long 0x0F0C0087
	.long 0x00004EC0
	.long 0x2D82700A
	.long 0x00004ECC
	.long 0x2A8DC013
	.long 0x00004ED0
	.long 0x23000087
	.long 0x00004EEC
	.long 0x04000008
	.long 0x00004F44
	.long 0x2C82480E
	.long 0x00004F54
	.long 0x1E0C010F
	.long 0x00004F58
	.long 0x2D00D80E
	.long 0x00004F68
	.long 0x1E0C010F
	.long 0x00004F6C
	.long 0x2D82700C
	.long 0x00004F7C
	.long 0x1E0C008F
	.long 0x0000502C
	.long 0x2D82700A
	.long 0x00005038
	.long 0x371D0013
	.long 0x0000503C
	.long 0x118C008F
	.long 0x00005080
	.long 0x2D82700A
	.long 0x0000508C
	.long 0x2A9D0013
	.long 0x00005090
	.long 0x118C008F
	.long 0x000050A4
	.long 0x08000020
	.long 0x0000510C
	.long 0x2D827009
	.long 0x000051F4
	.long 0xB4918013
	.long 0x000051F8
	.long 0x1E0C0107
	.long 0x0000527C
	.long 0x0800000E
	.long 0x00005280
	.long 0x28000000
	.long 0x00005284
	.long 0x03FB0000
	.long 0x00005288
	.long 0x00000000
	.long 0x0000528C
	.long 0x00000000
	.long 0x00005290
	.long 0x00000000
	.long 0x00005294
	.long 0x2D000004
	.long 0x00005298
	.long 0x044C0000
	.long 0x0000529C
	.long 0x06A40578
	.long 0x000052A0
	.long 0x46191373
	.long 0x000052A4
	.long 0x000400A3
	.long 0x000052A8
	.long 0x2D800004
	.long 0x000052AC
	.long 0x044C0000
	.long 0x000052B0
	.long 0x06A4FA88
	.long 0x000052B4
	.long 0x46191373
	.long 0x000052B8
	.long 0x000400A3
	.long 0x000052BC
	.long 0xCC000000
	.long 0x000052C0
	.long 0xCC000000
	.long 0x000052C4
	.long 0x0800000F
	.long 0x000052C8
	.long 0x40000000
	.long 0x000052CC
	.long 0x48000000
	.long 0x000052D0
	.long 0x44040000
	.long 0x000052D4
	.long 0x0000009E
	.long 0x000052D8
	.long 0x00007F40
	.long 0x000052DC
	.long 0xAC024000
	.long 0x000052E4
	.long 0x28000000
	.long 0x000052E8
	.long 0x05150000
	.long 0x000052EC
	.long 0x00000000
	.long 0x000052FC
	.long 0x040D0000
	.long 0x00005300
	.long 0x00001B58
	.long 0x00005304
	.long 0x01F40000
	.long 0x0000530C
	.long 0x2C027011
	.long 0x00005310
	.long 0x05DC03E8
	.long 0x00005314
	.long 0x00000000
	.long 0x00005318
	.long 0x2D140013
	.long 0x00005320
	.long 0x2C824811
	.long 0x00005324
	.long 0x05140000
	.long 0x0000532C
	.long 0x2D140013
	.long 0x00005334
	.long 0x2D000011
	.long 0x00005338
	.long 0x044C0000
	.long 0x0000533C
	.long 0x07D00000
	.long 0x00005340
	.long 0x2D140013
	.long 0x00005348
	.long 0x04000005
	.long 0x000053AC
	.long 0x25940013
	.long 0x000053C0
	.long 0x25940013
	.long 0x000053D4
	.long 0x25940013
	.long 0x000053DC
	.long 0x2D827010
	.long 0x00005450
	.long 0x25938013
	.long 0x00005464
	.long 0x25938013
	.long 0x00005478
	.long 0x25938013
	.long 0x00005480
	.long 0x2D82700C
	.long 0x000054E4
	.long 0x03E80000
	.long 0x000054F8
	.long 0x03E80000
	.long 0x0000550C
	.long 0x03E80578
	.long 0x00005518
	.long 0x0F00000F
	.long 0x00005548
	.long 0x2C02700B
	.long 0x00005554
	.long 0xB497C013
	.long 0x0000555C
	.long 0x2C82480B
	.long 0x00005560
	.long 0x03E80000
	.long 0x00005568
	.long 0xB497C013
	.long 0x00005570
	.long 0x2D00D80B
	.long 0x00005574
	.long 0x03E80000
	.long 0x0000557C
	.long 0xB497C013
	.long 0x00005584
	.long 0x2D82700B
	.long 0x00005588
	.long 0x03E80578
	.long 0x00005590
	.long 0xB497C013
	.long 0x00005594
	.long 0x1900010F
	.long 0x000055E4
	.long 0x2C027009
	.long 0x000055F0
	.long 0xB48F0013
	.long 0x000055F4
	.long 0x140C010F
	.long 0x000055F8
	.long 0x2C824809
	.long 0x00005604
	.long 0xB48F0013
	.long 0x00005608
	.long 0x140C010F
	.long 0x0000560C
	.long 0x2D00D809
	.long 0x00005618
	.long 0xB48F0013
	.long 0x0000561C
	.long 0x140C010F
	.long 0x00005620
	.long 0x2D827008
	.long 0x0000562C
	.long 0x218C8013
	.long 0x00005630
	.long 0x1E0C0107
	.long 0x00005638
	.long 0x08000009
	.long 0x00005678
	.long 0x2C02700E
	.long 0x00005684
	.long 0xB4990013
	.long 0x0000568C
	.long 0x2C82480E
	.long 0x00005698
	.long 0xB4990013
	.long 0x000056A0
	.long 0x2D00D80E
	.long 0x000056AC
	.long 0xB4990013
	.long 0x000056B4
	.long 0x2D82700A
	.long 0x000056C0
	.long 0xB4990013
	.long 0x000056C4
	.long 0x0F0C0107
	.long 0x000056CC
	.long 0x0800000C
	.long 0x00005710
	.long 0x2C82700A
	.long 0x0000571C
	.long 0x280DC013
	.long 0x00005720
	.long 0x140C010F
	.long 0x00005724
	.long 0x2D02480A
	.long 0x00005730
	.long 0x280DC013
	.long 0x00005734
	.long 0x140C010F
	.long 0x00005738
	.long 0x2D80D80A
	.long 0x00005744
	.long 0x280DC013
	.long 0x00005748
	.long 0x140C010F
	.long 0x0000574C
	.long 0x2C027008
	.long 0x00005758
	.long 0x280DC013
	.long 0x0000575C
	.long 0x0F0C0107
	.long 0x00005764
	.long 0x0800000C
	.long 0x000057A4
	.long 0x2C82700C
	.long 0x000057B0
	.long 0x87140013
	.long 0x000057B4
	.long 0x1E0C0107
	.long 0x000057B8
	.long 0x2D024810
	.long 0x000057C4
	.long 0x91190013
	.long 0x000057C8
	.long 0x1904010F
	.long 0x000057CC
	.long 0x2D80D810
	.long 0x000057D8
	.long 0x91190013
	.long 0x000057DC
	.long 0x1904010F
	.long 0x000057E0
	.long 0x2C02700C
	.long 0x000057EC
	.long 0x87140013
	.long 0x000057F0
	.long 0x1E0C0107
	.long 0x00006064
	.long 0x68000002
	.long 0x00006068
	.long 0x08000006
	.long 0x0000606C
	.long 0x28000000
	.long 0x00006070
	.long 0x04070000
	.long 0x0000607C
	.long 0x00000000
	.long 0x00006A2C
	.long 0x88000004
	.long 0xFFFFFFFF
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0x3C60803C
	.long 0x60000000
	.long 0x00000000
	.long 0xC2073A10
	.long 0x000000B6
	.long 0x7C0802A6
	.long 0x90010004
	.long 0x9421FF00
	.long 0xBE810008
	.long 0x7F63DB78
	.long 0x8BFE000C
	.long 0x3FA08044
	.long 0x63BD3E20
	.long 0x1FFF0E90
	.long 0x7FFDFA14
	.long 0x809F0000
	.long 0x8BFF0008
	.long 0x2C040013
	.long 0x4182001C
	.long 0x2C040012
	.long 0x40A20020
	.long 0x2C1F0001
	.long 0x40A20018
	.long 0x38800013
	.long 0x48000010
	.long 0x2C1F0001
	.long 0x40A20008
	.long 0x38800012
	.long 0xC03E0894
	.long 0xFC20081E
	.long 0xD8210080
	.long 0x80A10084
	.long 0x80DE0010
	.long 0x80FE0014
	.long 0x60E78000
	.long 0x83BE0004
	.long 0x1FBD0008
	.long 0x48000075
	.long 0x7FE802A6
	.long 0x87BF0008
	.long 0x2C1D0000
	.long 0x41820504
	.long 0x57BC463E
	.long 0x2C1C00FF
	.long 0x41820014
	.long 0x7C1C2000
	.long 0x4182000C
	.long 0x418104EC
	.long 0x4BFFFFDC
	.long 0x57BC863E
	.long 0x7C1C2800
	.long 0x41A1FFD0
	.long 0x57BC043E
	.long 0x7C1C3000
	.long 0x4182000C
	.long 0x7C1C3800
	.long 0x4082FFBC
	.long 0x839F0004
	.long 0x2C1CFFFF
	.long 0x418204BC
	.long 0xC03F0004
	.long 0x3D808006
	.long 0x618CF868
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x480004A4
	.long 0x4E800021
	.long 0x00090165
	.long 0x3EE66666
	.long 0x00000165
	.long 0x40000000
	.long 0x00080160
	.long 0x3FC00000
	.long 0x001400EB
	.long 0x3FC00000
	.long 0x01190042
	.long 0x3F800000
	.long 0x01000042
	.long 0x3FA00000
	.long 0x01180045
	.long 0x3FC00000
	.long 0x011800EB
	.long 0x3FD00000
	.long 0x01000181
	.long 0x40000000
	.long 0x03090038
	.long 0x3F800000
	.long 0x03000038
	.long 0x3FC00000
	.long 0x0318003F
	.long 0x3F800000
	.long 0x0301003F
	.long 0xFFFFFFFF
	.long 0x0300003F
	.long 0x3FC00000
	.long 0x030A0042
	.long 0x3F800000
	.long 0x03000042
	.long 0x3FA00000
	.long 0x031400E9
	.long 0x3FF00000
	.long 0x031400EA
	.long 0x3FF00000
	.long 0x030C00EB
	.long 0x3FE66666
	.long 0x03260177
	.long 0x41300000
	.long 0x0326017A
	.long 0x41300000
	.long 0x040A0042
	.long 0x3F800000
	.long 0x04000042
	.long 0x3FD55555
	.long 0x04120045
	.long 0x3F800000
	.long 0x04000045
	.long 0x3FE66666
	.long 0x041D00DC
	.long 0x40000000
	.long 0x043900DE
	.long 0x402AAAAB
	.long 0x0416017F
	.long 0x3F800000
	.long 0x0400017F
	.long 0x3FA5A5A6
	.long 0x042E0180
	.long 0x40000000
	.long 0x0400018C
	.long 0x40000000
	.long 0x05160044
	.long 0x3F800000
	.long 0x05000044
	.long 0x3FB00000
	.long 0x052F00DE
	.long 0x3FC00000
	.long 0x051700E9
	.long 0x40124925
	.long 0x051A00EA
	.long 0x40500000
	.long 0x051900EB
	.long 0x40080000
	.long 0x05000157
	.long 0x40000000
	.long 0x0512015B
	.long 0x3F9E1E1E
	.long 0x0510015B
	.long 0x3F800000
	.long 0x0500015B
	.long 0x3FAAAAAB
	.long 0x05120161
	.long 0x3F9E1E1E
	.long 0x05100161
	.long 0x3F800000
	.long 0x05000161
	.long 0x3FAAAAAB
	.long 0x0500016B
	.long 0x3FC00000
	.long 0x05140045
	.long 0x3ECCCCCD
	.long 0x06100035
	.long 0x3F800000
	.long 0x06000035
	.long 0x3FBA2E8C
	.long 0x060D0039
	.long 0x3F800000
	.long 0x06000039
	.long 0x3FE00000
	.long 0x061E0042
	.long 0x3F800000
	.long 0x06100042
	.long 0x3FE00000
	.long 0x061400EA
	.long 0x3FC5D174
	.long 0x061B015E
	.long 0x3F800000
	.long 0x0600015E
	.long 0x3FA2E8BA
	.long 0x061B0161
	.long 0x3F800000
	.long 0x06000161
	.long 0x3FA2E8BA
	.long 0x06000166
	.long 0x3FA66666
	.long 0x06000167
	.long 0x3FA66666
	.long 0x08160042
	.long 0x3FF33333
	.long 0x08120042
	.long 0x3F800000
	.long 0x08000042
	.long 0x3FADB6DB
	.long 0x0A13003C
	.long 0x3FC00000
	.long 0x0A020042
	.long 0x3F800000
	.long 0x0A010042
	.long 0x3E800000
	.long 0x0A0C0043
	.long 0x3F800000
	.long 0x0A000043
	.long 0x3FC00000
	.long 0x0A150045
	.long 0x3FC00000
	.long 0x0A1500EB
	.long 0x402AAAAB
	.long 0x0A000155
	.long 0x3FD9999A
	.long 0x0A00015A
	.long 0x3FD9999A
	.long 0x0A27015F
	.long 0x3FB33333
	.long 0x0A270160
	.long 0x3FB33333
	.long 0x0A0F0167
	.long 0x3F800000
	.long 0x0A000167
	.long 0x3FD55555
	.long 0x0A0F0168
	.long 0x3F800000
	.long 0x0A000168
	.long 0x3FD55555
	.long 0x0B1D0045
	.long 0x3FE00000
	.long 0x0B140045
	.long 0x3F800000
	.long 0x0B000045
	.long 0x40000000
	.long 0x0B0C0159
	.long 0x3F800000
	.long 0x0B000159
	.long 0x3FC00000
	.long 0x0B140164
	.long 0x3FC00000
	.long 0x0B000164
	.long 0x3FB6DB6E
	.long 0x0B140165
	.long 0x3FC00000
	.long 0x0B000165
	.long 0x3FB6DB6E
	.long 0x0B00016F
	.long 0x41200000
	.long 0x0B000174
	.long 0x41200000
	.long 0x0D10003C
	.long 0x3F800000
	.long 0x0D01003C
	.long 0xFFFFFFFF
	.long 0x0D00003C
	.long 0x3FAAAAAB
	.long 0x0D0E0045
	.long 0x3F800000
	.long 0x0D000045
	.long 0x3FB33333
	.long 0x0D1400DE
	.long 0x3FB8E38E
	.long 0x0D00016A
	.long 0x3FB851EC
	.long 0x0D00016E
	.long 0x3FB851EC
	.long 0x1016003F
	.long 0x3F4CCCCD
	.long 0x11130042
	.long 0x3F800000
	.long 0x11000042
	.long 0x3FAAAAAB
	.long 0x111800D4
	.long 0x3FC00000
	.long 0x111200D4
	.long 0x3F800000
	.long 0x110000D4
	.long 0x3FD1745D
	.long 0x110C00DD
	.long 0x3FCCCCCD
	.long 0x1100016F
	.long 0x3F99999A
	.long 0x11000159
	.long 0x3F400000
	.long 0x111700D6
	.long 0x3F99999A
	.long 0x11000155
	.long 0x3F400000
	.long 0x120C0033
	.long 0x3F800000
	.long 0x12000033
	.long 0x40000000
	.long 0x120C0035
	.long 0x3F800000
	.long 0x12000035
	.long 0x40000000
	.long 0x120C0037
	.long 0x3F800000
	.long 0x12000037
	.long 0x40000000
	.long 0x12080038
	.long 0x3F800000
	.long 0x12000038
	.long 0x3FEAAAAB
	.long 0x12030162
	.long 0x40000000
	.long 0x150E0039
	.long 0x3F800000
	.long 0x15000039
	.long 0x3FE00000
	.long 0x150A003F
	.long 0x3F800000
	.long 0x1501003F
	.long 0xFFFFFFFF
	.long 0x1500003F
	.long 0x40000000
	.long 0x150E0042
	.long 0x3F800000
	.long 0x15000042
	.long 0x40000000
	.long 0x151400EA
	.long 0x3FC5D174
	.long 0x1500015A
	.long 0x3FAAAAAB
	.long 0x1500015D
	.long 0x3FAAAAAB
	.long 0x151B015E
	.long 0x3F800000
	.long 0x1500015E
	.long 0x3FACCCCD
	.long 0x151B0161
	.long 0x3F800000
	.long 0x15000161
	.long 0x3FACCCCD
	.long 0x16160042
	.long 0x3FF33333
	.long 0x170D0045
	.long 0x3F9C71C7
	.long 0x1810003C
	.long 0x3F800000
	.long 0x1801003C
	.long 0xFFFFFFFF
	.long 0x1800003C
	.long 0x3FCCCCCD
	.long 0x180A0042
	.long 0x3F800000
	.long 0x18000042
	.long 0x40000000
	.long 0x180E0045
	.long 0x3F800000
	.long 0x18000045
	.long 0x3FE00000
	.long 0x1800016A
	.long 0x3FF8E38E
	.long 0x1800016E
	.long 0x3FF8E38E
	.long 0x180E00DE
	.long 0x3FA00000
	.long 0x191400EB
	.long 0x40000000
	.long 0x19080160
	.long 0x3FC00000
	.long 0x19120038
	.long 0x3ECCCCCD
	.long 0x19030038
	.long 0x3F400000
	.long 0x19010038
	.long 0x3E000000
	.long 0x00000000
	.long 0xBA810008
	.long 0x80010104
	.long 0x38210100
	.long 0x7C0803A6
	.long 0xBB610014
	.long 0x60000000
	.long 0x00000000
	.long -1

SnapPAL_StageExpansion_Off:
	.long 0x043E5E14
	.long 0x04C7D64C
	.long 0x041FEE10
	.long 0x480003E5
	.long 0x041CF25C
	.long 0x48002179
	.long 0x041CF264
	.long 0x48000999
	.long 0x0444D190
	.long 0xE70000B0
	.long 0x0416F1D4
	.long 0x3C608047
	.long 0x043E8490
	.long 0x8021903C
	.long 0x04219098
	.long 0x38000000
	.long 0x043E84CC
	.long 0x80219354
	.long 0x0421A004
	.long 0x4BFAFD59
	.long 0x04216574
	.long 0x4BFAC769
	.long 0x04216EF4
	.long 0x480002CD
	.long 0x041F1C50
	.long 0x4BFD810D
	.long 0x041F1F84
	.long 0x4800035D
	.long 0x041F2020
	.long 0x4BFD7D3D
	.long 0x041F4430
	.long 0x4BE3CF41
	.long 0x041E5B9C
	.long 0x4BE72BF1
	.long 0x041E5BAC
	.long 0x4BE72BE1
	.long 0x041E55CC
	.long 0x48000059
	.long 0x041E5B54
	.long 0x4BFE40C9
	.long 0x04201524
	.long 0x48001E8D
	.long 0x04201608
	.long 0x4BFC8755
	.long 0x043E5990
	.long 0x8020174C
	.long 0x04201410
	.long 0x4BFC894D
	.long 0x04201454
	.long 0x3C608020
	.long 0x04201904
	.long 0x7C0802A6
	.long -1
SnapPAL_StageExpansion_On:
	.long 0x043E5E14
	.long 0x802053EC
	.long 0x041FEE10
	.long 0x60000000
	.long 0x041CF25C
	.long 0x60000000
	.long 0x041CF264
	.long 0x60000000
	.long 0x0444D190
	.long 0xE7E33BB5
	.long 0xC216F1D4
	.long 0x000003F9
	.long 0x48000089
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x4800041D
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48001C71
	.long 0x48001E35
	.long 0x48001A7D
	.long 0x48000111
	.long 0x48000BE1
	.long 0x48000001
	.long 0x48000001
	.long 0x48001245
	.long 0x48000E95
	.long 0x48000471
	.long 0x48001439
	.long 0x48001661
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x480017B1
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x48000001
	.long 0x7C6802A6
	.long 0x808D9368
	.long 0x2C040020
	.long 0x418100AC
	.long 0x1C840004
	.long 0x7C832214
	.long 0x80A40000
	.long 0x54A501BA
	.long 0x2C050000
	.long 0x41820094
	.long 0x7CA42A14
	.long 0x3CC08048
	.long 0x60C6FE98
	.long 0x80C60000
	.long 0x80C60020
	.long 0x38C6FFE0
	.long 0x80650000
	.long 0x80850004
	.long 0x7C600774
	.long 0x2C00FFFF
	.long 0x41820064
	.long 0x5460463E
	.long 0x2C0000CC
	.long 0x41820038
	.long 0x2C0000CD
	.long 0x41820008
	.long 0x4800003C
	.long 0x5463023E
	.long 0x80E50008
	.long 0x2C040000
	.long 0x41820014
	.long 0x3884FFFC
	.long 0x7D061A14
	.long 0x7CE8212E
	.long 0x4BFFFFEC
	.long 0x38A5000C
	.long 0x4BFFFFB0
	.long 0x5463023E
	.long 0x7C843214
	.long 0x38840020
	.long 0x48000004
	.long 0x7C633214
	.long 0x90830000
	.long 0x38A50008
	.long 0x4BFFFF90
	.long 0x48000004
	.long 0x48001E80
	.long 0x0001A68C
	.long 0x00000000
	.long 0x0001A6E8
	.long 0x3FC00000
	.long 0x0001A6EC
	.long 0x40000000
	.long 0x0001A70C
	.long 0x00000000
	.long 0x0001A7CC
	.long 0x00000000
	.long 0x0001A828
	.long 0x3FD9999A
	.long 0x0001A834
	.long 0x4038BFB1
	.long 0x0001AA28
	.long 0x3F170A3D
	.long 0x0002C898
	.long 0xC2960000
	.long 0x0002C89C
	.long 0x43160000
	.long 0x0002CB54
	.long 0xC1700000
	.long 0x0002D4DC
	.long 0xC1A00000
	.long 0x0002D554
	.long 0xC2BE0000
	.long 0x00034574
	.long 0x4038BFB1
	.long 0x00036F58
	.long 0xC3FA0000
	.long 0x0003A2C8
	.long 0xC27D6704
	.long 0x0003A2CC
	.long 0xC1970B44
	.long 0x0003A2D0
	.long 0xC27D6704
	.long 0x0003A2D4
	.long 0xC1970B44
	.long 0x0003A2D8
	.long 0xC286CF28
	.long 0x0003A2E0
	.long 0xC2659E4F
	.long 0x0003A2E8
	.long 0xC2710000
	.long 0x0003A2EC
	.long 0xC1C96595
	.long 0x0003A2F0
	.long 0x428D9ADB
	.long 0x0003A2F4
	.long 0xC1970B44
	.long 0x0003A2F8
	.long 0x428D9ADB
	.long 0x0003A2FC
	.long 0xC1970B44
	.long 0x0003A300
	.long 0x42876759
	.long 0x0003A304
	.long 0xC1C96595
	.long 0x0003A308
	.long 0x4211BDBF
	.long 0x0003A30C
	.long 0xC161EB85
	.long 0x0003A310
	.long 0xC1DB746E
	.long 0x0003A314
	.long 0xC161EB85
	.long 0x0003A318
	.long 0x421B6AB3
	.long 0x0003A31C
	.long 0xC1C96595
	.long 0x0003A320
	.long 0xC1E9D5EA
	.long 0x0003A324
	.long 0xC1C96595
	.long 0x0003A328
	.long 0x43FA0000
	.long 0x0003A32C
	.long 0x43FA0000
	.long 0x0003A330
	.long 0xC2659E4F
	.long 0x0003A334
	.long 0x00000000
	.long 0x0003A338
	.long 0x4281B681
	.long 0x0003A33C
	.long 0x00000000
	.long 0x0003A340
	.long 0x43FA0000
	.long 0x0003A344
	.long 0x43FA0000
	.long 0x0003A348
	.long 0x43FA0000
	.long 0x0003A34C
	.long 0x43FA0000
	.long 0x0003A350
	.long 0x4281B681
	.long 0x0003A354
	.long 0x00000000
	.long 0x0003A358
	.long 0x4295B681
	.long 0x0003A35C
	.long 0x00000000
	.long 0x0003A360
	.long 0x43FA0000
	.long 0x0003A364
	.long 0x43FA0000
	.long 0x0003A368
	.long 0xC18CD4FE
	.long 0x0003A370
	.long 0x41C872B0
	.long 0x0003A37C
	.long 0x00100001
	.long 0x0003A38C
	.long 0x00000002
	.long 0x0003A394
	.long 0x00010004
	.long 0x0003A39C
	.long 0x0001000D
	.long 0x0003A408
	.long 0x000F000F
	.long 0x0003A40C
	.long 0xFFFFFFFF
	.long 0x0003A41C
	.long 0xFFFFFFFF
	.long 0x0003A448
	.long 0x00120005
	.long 0x0003A44C
	.long 0x00020008
	.long 0x0003A458
	.long 0x000F000F
	.long 0x0003A45C
	.long 0xFFFFFFFF
	.long 0x0003A468
	.long 0x00130013
	.long 0x0003A46C
	.long 0xFFFFFFFF
	.long 0x0003A4A8
	.long 0x000C000C
	.long 0x0003A4AC
	.long 0xFFFFFFFF
	.long 0x0003A4B8
	.long 0x00100010
	.long 0x0003A4BC
	.long 0xFFFFFFFF
	.long 0x0003A4C8
	.long 0x00000003
	.long 0x0003A4DC
	.long 0xC28C0000
	.long 0x0003A4E0
	.long 0xC1F00000
	.long 0x0003A4E4
	.long 0x42980000
	.long 0x00042268
	.long 0x0000006E
	.long 0x00042270
	.long 0xFFFFFFF6
	.long 0x00042278
	.long 0x3CCCCCCD
	.long 0x000424C4
	.long 0xAEA8A2FF
	.long 0x00042690
	.long 0x42F68404
	.long 0x000426D0
	.long 0xC2700000
	.long 0x00042710
	.long 0x433C0000
	.long 0x0004274C
	.long 0x43630000
	.long 0x00042750
	.long 0xC2E40000
	.long 0x0004298C
	.long 0xC25C0000
	.long 0x00042990
	.long 0x40A00000
	.long 0x000429CC
	.long 0x4279999A
	.long 0x000429D0
	.long 0x40A00000
	.long 0x00042A0C
	.long 0x41EF999A
	.long 0x00042A4C
	.long 0xC1B40000
	.long 0x00032558
	.long 0xC3480000
	.long 0x0004233C
	.long 0xC3480000
	.long 0xFFFFFFFF
	.long 0x0002ED18
	.long 0xC485C001
	.long 0x0002ED58
	.long 0xC45819A5
	.long 0x0008B7B4
	.long 0x42632666
	.long 0x0008B7BC
	.long 0x42584F5C
	.long 0x0008B7C0
	.long 0x41000000
	.long 0x0008B7C4
	.long 0x43286D71
	.long 0x0008B7CC
	.long 0x42584F5C
	.long 0x0008B7D0
	.long 0xC1000000
	.long 0x0008B7D4
	.long 0x43286D71
	.long 0x0008B7EC
	.long 0x42632666
	.long 0x0008B7F4
	.long 0x4289799A
	.long 0x0008B7FC
	.long 0x4285C3D7
	.long 0x0008B804
	.long 0x4285C3D7
	.long 0x0008B80C
	.long 0x4289799A
	.long 0xCC024EDC
	.long 0x00025A78
	.long 0x0001AF3C
	.long 0x00000000
	.long 0xCC01F03C
	.long 0x0001FDD8
	.long 0xFFFFFFFF
	.long 0x00023BE4
	.long 0x00000000
	.long 0x00023D04
	.long 0x00000000
	.long 0x00023D64
	.long 0x00000000
	.long 0x00023F64
	.long 0x00000000
	.long 0x000241A4
	.long 0x00000000
	.long 0x0001E2E4
	.long 0x00000000
	.long 0x0001E524
	.long 0x00000000
	.long 0x0001E764
	.long 0x00000000
	.long 0x0001E944
	.long 0x00000000
	.long 0x0001FD64
	.long 0x00000000
	.long 0x0001FF24
	.long 0x00000000
	.long 0x00020104
	.long 0x00000000
	.long 0x00020244
	.long 0x00000000
	.long 0x00020404
	.long 0x00000000
	.long 0x000205E4
	.long 0x00000000
	.long 0x00020784
	.long 0x00000000
	.long 0x00020AA4
	.long 0x00000000
	.long 0x00020E24
	.long 0x00000000
	.long 0x00020FC4
	.long 0x00000000
	.long 0x000212E4
	.long 0x00000000
	.long 0x00021664
	.long 0x00000000
	.long 0x00021744
	.long 0x00000000
	.long 0x00021664
	.long 0x00000000
	.long 0x0002E6EC
	.long 0x00000000
	.long 0x0002E75C
	.long 0x43000000
	.long 0x0002E998
	.long 0x46825FBE
	.long 0x0002E9D8
	.long 0x00000000
	.long 0x0002EA54
	.long 0x00000000
	.long 0x0002EA58
	.long 0xC3000000
	.long 0x0002EA5C
	.long 0x00000000
	.long 0x0002EB58
	.long 0xC33FDCD0
	.long 0x0002EB94
	.long 0x00000000
	.long 0x0002EB98
	.long 0x00000000
	.long 0x0002EB9C
	.long 0x00000000
	.long 0x0002EBD4
	.long 0x00000000
	.long 0x0002EBD8
	.long 0x00000000
	.long 0x0002EBDC
	.long 0x00000000
	.long 0x0002EC14
	.long 0x00000000
	.long 0x0002EC18
	.long 0x00000000
	.long 0x0002EC1C
	.long 0x00000000
	.long 0x0002EC54
	.long 0xC321D0BD
	.long 0x0002EC58
	.long 0x419C17BD
	.long 0x0002EC5C
	.long 0xBFAFE771
	.long 0x0002ED5C
	.long 0xC122BB88
	.long 0x0002ED9C
	.long 0xC122BB88
	.long 0x0002EDDC
	.long 0xC122BB88
	.long 0x0002EE14
	.long 0xC60637BD
	.long 0x000306F4
	.long 0x00000000
	.long 0x000306F8
	.long 0xC3000000
	.long 0x000306FC
	.long 0x00000000
	.long 0x000307F4
	.long 0x00000000
	.long 0x000307F8
	.long 0xC3000000
	.long 0x000307FC
	.long 0x00000000
	.long 0x00030834
	.long 0x00000000
	.long 0x00030838
	.long 0xC3000000
	.long 0x0003083C
	.long 0x00000000
	.long 0x00030874
	.long 0x00000000
	.long 0x00030878
	.long 0xC3000000
	.long 0x0003087C
	.long 0x00000000
	.long 0x000308B4
	.long 0xC218A6E6
	.long 0x000308B8
	.long 0x3F9A29D0
	.long 0x000308BC
	.long 0x41398B84
	.long 0x000308F4
	.long 0xC26CF2D0
	.long 0x000308F8
	.long 0x3F9A29D0
	.long 0x000308FC
	.long 0x41398B84
	.long 0x00030934
	.long 0xC2A0E1A7
	.long 0x00030938
	.long 0x3F9A29D0
	.long 0x0003093C
	.long 0x41398B84
	.long 0x00030A34
	.long 0x00000000
	.long 0x00030A38
	.long 0xC2330000
	.long 0x00030A3C
	.long 0x00000000
	.long 0x00030A74
	.long 0xC15C0000
	.long 0x00030A78
	.long 0xC2330000
	.long 0x00030A7C
	.long 0x00000000
	.long 0x00030AB4
	.long 0xC12D0000
	.long 0x00030AB8
	.long 0xC2090000
	.long 0x00030ABC
	.long 0x00000000
	.long 0x00030AF4
	.long 0xC0B847B2
	.long 0x00030AF8
	.long 0xC2090000
	.long 0x00030AFC
	.long 0x00000000
	.long 0x00030B34
	.long 0x00000000
	.long 0x00030B38
	.long 0xC3000000
	.long 0x00030B3C
	.long 0x00000000
	.long 0x00030B74
	.long 0x00000000
	.long 0x00030B78
	.long 0xC3000000
	.long 0x00030B7C
	.long 0x00000000
	.long 0x00030BB4
	.long 0x00000000
	.long 0x00030BB8
	.long 0xC3000000
	.long 0x00030BBC
	.long 0x00000000
	.long 0x00036BB4
	.long 0xC1000000
	.long 0x00036BB8
	.long 0x416065B4
	.long 0x00036CE8
	.long 0x3F4CCCCD
	.long 0x0004AC40
	.long 0x00000000
	.long 0x0004AC44
	.long 0x00000000
	.long 0x0004AC48
	.long 0x00000000
	.long 0x0004AC4C
	.long 0x00000000
	.long 0x0004AC50
	.long 0x00000000
	.long 0x0004AC54
	.long 0x00000000
	.long 0x0004AC58
	.long 0x00000000
	.long 0x0004AC5C
	.long 0x00000000
	.long 0x0004AC60
	.long 0x00000000
	.long 0x0004AC64
	.long 0x00000000
	.long 0x0004AC68
	.long 0x00000000
	.long 0x0004AC6C
	.long 0x00000000
	.long 0x0004AC70
	.long 0x00000000
	.long 0x0004AC74
	.long 0x00000000
	.long 0x0004AC78
	.long 0x00000000
	.long 0x0004AC7C
	.long 0x00000000
	.long 0x0004AC80
	.long 0x00000000
	.long 0x0004AC84
	.long 0x00000000
	.long 0x0004AC88
	.long 0x00000000
	.long 0x0004AC8C
	.long 0x00000000
	.long 0x0004AC90
	.long 0x00000000
	.long 0x0004AC94
	.long 0x00000000
	.long 0x0004AC98
	.long 0x00000000
	.long 0x0004AC9C
	.long 0x00000000
	.long 0x0004ACA0
	.long 0x00000000
	.long 0x0004ACA4
	.long 0x00000000
	.long 0x0004ACA8
	.long 0x00000000
	.long 0x0004ACAC
	.long 0x00000000
	.long 0x0004ACB0
	.long 0x00000000
	.long 0x0004ACB4
	.long 0x00000000
	.long 0x0004ACB8
	.long 0x00000000
	.long 0x0004ACBC
	.long 0x00000000
	.long 0x0004ACC0
	.long 0x00000000
	.long 0x0004ACC4
	.long 0x00000000
	.long 0x0004ACC8
	.long 0x00000000
	.long 0x0004ACCC
	.long 0x00000000
	.long 0x0004ACD0
	.long 0x00000000
	.long 0x0004ACD4
	.long 0x00000000
	.long 0x0004ACD8
	.long 0x00000000
	.long 0x0004ACDC
	.long 0x00000000
	.long 0x0004ACE0
	.long 0x00000000
	.long 0x0004ACE4
	.long 0x00000000
	.long 0x0004ACE8
	.long 0x00000000
	.long 0x0004ACEC
	.long 0x00000000
	.long 0x0004ACF0
	.long 0x00000000
	.long 0x0004ACF4
	.long 0x00000000
	.long 0x0004ACF8
	.long 0xC2A40000
	.long 0x0004ACFC
	.long 0xC3240000
	.long 0x0004AD00
	.long 0xC2A40000
	.long 0x0004AD04
	.long 0x3F000000
	.long 0x0004AD08
	.long 0x42530000
	.long 0x0004AD0C
	.long 0x3F000000
	.long 0x0004AD10
	.long 0x42530000
	.long 0x0004AD14
	.long 0xC3240000
	.long 0x0004AD18
	.long 0xC2870000
	.long 0x0004AD1C
	.long 0x3F000000
	.long 0x0004AD20
	.long 0x42110000
	.long 0x0004AD24
	.long 0x3F000000
	.long 0x0004AD28
	.long 0xC1DD0000
	.long 0x0004AD2C
	.long 0xC1370000
	.long 0x0004AD30
	.long 0x41EC0000
	.long 0x0004AD34
	.long 0xC13B0000
	.long 0x0004AD38
	.long 0x00000000
	.long 0x0004AD3C
	.long 0x00000000
	.long 0x0004AD40
	.long 0x00000000
	.long 0x0004AD44
	.long 0x00000000
	.long 0x0004AD48
	.long 0x00000000
	.long 0x0004AD4C
	.long 0x00000000
	.long 0x0004AD50
	.long 0x00000000
	.long 0x0004AD54
	.long 0x00000000
	.long 0x0004AD58
	.long 0x00000000
	.long 0x0004AD5C
	.long 0x00000000
	.long 0x0004AD60
	.long 0x00000000
	.long 0x0004AD64
	.long 0x00000000
	.long 0x0004AD68
	.long 0x00000000
	.long 0x0004AD6C
	.long 0x00000000
	.long 0x0004AD70
	.long 0x00000000
	.long 0x0004AD74
	.long 0x00000000
	.long 0x0004AD78
	.long 0x00000000
	.long 0x0004AD7C
	.long 0x00000000
	.long 0x0004AD80
	.long 0x00000000
	.long 0x0004AD84
	.long 0x00000000
	.long 0x0004AD88
	.long 0x00000000
	.long 0x0004AD8C
	.long 0x00000000
	.long 0x0004AD90
	.long 0x00000000
	.long 0x0004AD94
	.long 0x00000000
	.long 0x0004AD98
	.long 0x00000000
	.long 0x0004AD9C
	.long 0x00000000
	.long 0x0004ADA0
	.long 0x00000000
	.long 0x0004ADA4
	.long 0x00000000
	.long 0x0004ADA8
	.long 0x00000000
	.long 0x0004ADAC
	.long 0x00000000
	.long 0x0004ADBC
	.long 0x00010000
	.long 0x0004AE0C
	.long 0x00010000
	.long 0x0004AE1C
	.long 0x00010000
	.long 0x0004AE6C
	.long 0x00010000
	.long 0x0004AFDC
	.long 0x00040600
	.long 0x0004B03C
	.long 0x00080600
	.long 0x0004B054
	.long 0xC43316A1
	.long 0x0004B05C
	.long 0x44720000
	.long 0x0004B07C
	.long 0xC40001B7
	.long 0x0004B084
	.long 0x444FB886
	.long 0x0004B0A4
	.long 0xC4900000
	.long 0x0004B0AC
	.long 0x44050000
	.long 0x0004B0B0
	.long 0x432FFEC6
	.long 0x0004B0CC
	.long 0xC40E8F42
	.long 0x0004B0D4
	.long 0x4416D26E
	.long 0x0004B0F4
	.long 0xC48087C8
	.long 0x0004B0FC
	.long 0x448087C8
	.long 0x0004B398
	.long 0x00000082
	.long 0x0004B3A8
	.long 0x3D99999A
	.long 0x0004B3B4
	.long 0x3F99999A
	.long 0x0004B3DC
	.long 0xC1400000
	.long 0x0004B3E0
	.long 0x42960000
	.long 0x0004B3E8
	.long 0x41500000
	.long 0x0004B478
	.long 0x0000003C
	.long 0x0004B47C
	.long 0x00000000
	.long 0x0004B480
	.long 0x00000000
	.long 0x0004B484
	.long 0x00000000
	.long 0x0004B488
	.long 0x00000000
	.long 0x0004B48C
	.long 0x00000000
	.long 0x0004B490
	.long 0x00000000
	.long 0x0004B494
	.long 0x00000000
	.long 0x0004B498
	.long 0x00000000
	.long 0x0004B4A0
	.long 0x7F7F012C
	.long 0x0004B73C
	.long 0xC1000000
	.long 0x0004B778
	.long 0xC16A0000
	.long 0x0004B7B8
	.long 0xC32CFFFE
	.long 0x0004B7BC
	.long 0x43020000
	.long 0x0004B7F8
	.long 0x431CFFFE
	.long 0x0004B7FC
	.long 0xC24CE2D2
	.long 0x0004B838
	.long 0xC35F999C
	.long 0x0004B878
	.long 0x434F999C
	.long 0x0004B87C
	.long 0xC2CBC2D1
	.long 0x0004BAB8
	.long 0xC28D0000
	.long 0x0004BABC
	.long 0x41500000
	.long 0x0004BAF8
	.long 0x42250000
	.long 0x0004BAFC
	.long 0x41500000
	.long 0x0004BB38
	.long 0x41800000
	.long 0x0004BB3C
	.long 0x41500000
	.long 0x0004BB78
	.long 0xC2350000
	.long 0x0004BB7C
	.long 0x41500000
	.long 0x0004BBBC
	.long 0x42600000
	.long 0xFFFFFFFF
	.long 0x000026D8
	.long 0xFE2A0191
	.long 0x00002738
	.long 0x01900191
	.long 0x000028F0
	.long 0x034CFE79
	.long 0x000028FC
	.long 0x0392FE79
	.long 0x00002908
	.long 0x034CFE79
	.long 0x0000298C
	.long 0x03520137
	.long 0x000029F8
	.long 0x04780137
	.long 0x00002A80
	.long 0x0073FFC0
	.long 0x00002A9C
	.long 0x00080073
	.long 0x00002AE4
	.long 0x00560073
	.long 0x00012514
	.long 0x41F00000
	.long 0x00012518
	.long 0xC4900000
	.long 0x0001251C
	.long 0xC0600000
	.long 0x00012558
	.long 0x40FBC9BA
	.long 0x00012598
	.long 0xC40BC9BA
	.long 0x000125D4
	.long 0x42A79997
	.long 0x000125DC
	.long 0xC1B3332B
	.long 0x00012658
	.long 0xC24A3021
	.long 0x0006B494
	.long 0xC2E889C7
	.long 0x0006B498
	.long 0xC000645A
	.long 0x0006B49C
	.long 0xC2E889C7
	.long 0x0006B4A0
	.long 0x412A6BBA
	.long 0x0006B4A4
	.long 0x420A76C9
	.long 0x0006B4A8
	.long 0x412A6BBA
	.long 0x0006B4AC
	.long 0x420A76C9
	.long 0x0006B4B0
	.long 0xC000645A
	.long 0x0006B4B4
	.long 0x00000000
	.long 0x0006B4B8
	.long 0x00000000
	.long 0x0006B4BC
	.long 0x00000000
	.long 0x0006B4C0
	.long 0x00000000
	.long 0x0006B4C4
	.long 0x00000000
	.long 0x0006B4C8
	.long 0x00000000
	.long 0x0006B4CC
	.long 0x00000000
	.long 0x0006B4D0
	.long 0x00000000
	.long 0x0006B4D4
	.long 0x00000000
	.long 0x0006B4D8
	.long 0x00000000
	.long 0x0006B4DC
	.long 0x00000000
	.long 0x0006B4E0
	.long 0x00000000
	.long 0x0006B4E4
	.long 0x00000000
	.long 0x0006B4E8
	.long 0x00000000
	.long 0x0006B4EC
	.long 0x00000000
	.long 0x0006B4F0
	.long 0x00000000
	.long 0x0006B9A8
	.long 0xC3EAB611
	.long 0x0006B9B0
	.long 0x43F0DAEE
	.long 0x0006B9B4
	.long 0x4350CE70
	.long 0x0006B9D0
	.long 0xC335B405
	.long 0x0006B9D8
	.long 0x4335B405
	.long 0x0006B9DC
	.long 0x432F084B
	.long 0x0006B9F8
	.long 0xC3C2FE9E
	.long 0x0006BA00
	.long 0x4367DBA6
	.long 0x0006BA04
	.long 0x432EE7BB
	.long 0x0006BA20
	.long 0xC3D31412
	.long 0x0006BA28
	.long 0x43D31412
	.long 0x0006BA2C
	.long 0x436CCCCD
	.long 0x0006BA48
	.long 0xC3D31412
	.long 0x0006BA50
	.long 0x43D31412
	.long 0x0006BA54
	.long 0x43580000
	.long 0x0006BA70
	.long 0xC37E7C1C
	.long 0x0006BA78
	.long 0x437E7C1C
	.long 0x0006BA7C
	.long 0x43DC0000
	.long 0x0006BA98
	.long 0xC357A162
	.long 0x0006BAA0
	.long 0x43F2F1AA
	.long 0x0006BAA4
	.long 0x435AB5DD
	.long 0x0006BAC0
	.long 0xC3F889C7
	.long 0x0006BAC8
	.long 0x439E76C9
	.long 0x0006BACC
	.long 0x4335F41F
	.long 0x000766D8
	.long 0x42CD0000
	.long 0x000766DC
	.long 0x42CD0000
	.long 0x000766E0
	.long 0x42CD0000
	.long 0x000766E4
	.long 0xC2F30000
	.long 0x000766E8
	.long 0xC2F30000
	.long 0x0008E8F0
	.long 0xC3840000
	.long 0x0008E930
	.long 0x435A0000
	.long 0x0008E970
	.long 0xC3A60000
	.long 0x0008E9B0
	.long 0x438C0000
	.long 0x0008EBF4
	.long 0x41920000
	.long 0x0008EC30
	.long 0x42BCCCCD
	.long 0x0008EC70
	.long 0xC284000F
	.long 0x0008EC74
	.long 0x41920004
	.long 0x0008ECB0
	.long 0x00000000
	.long 0x0008ECB4
	.long 0x41920000
	.long 0x0008ECF4
	.long 0x425C0004
	.long 0x00012548
	.long 0x3FD9999A
	.long 0x00012554
	.long 0x41200000
	.long 0x00012648
	.long 0x3F3AE148
	.long 0x00012654
	.long 0x40800000
	.long 0x00012618
	.long 0xC3480000
	.long 0x000125D8
	.long 0xC3480000
	.long 0xFFFFFFFF
	.long 0x00020DEC
	.long 0x00000000
	.long 0x00020E2C
	.long 0x00000000
	.long 0x00020E54
	.long 0xC2AB0000
	.long 0x00020E58
	.long 0x00200000
	.long 0x00020E6C
	.long 0x00000000
	.long 0x00020E94
	.long 0x42AB0000
	.long 0x00020E98
	.long 0x00200000
	.long 0x00020F14
	.long 0xC6820000
	.long 0x00020F18
	.long 0xC6700000
	.long 0x00020F54
	.long 0xC6AA0000
	.long 0x00020F58
	.long 0xC6700000
	.long 0x00020F94
	.long 0xC6960000
	.long 0x00020F98
	.long 0xC0700000
	.long 0x00020FD4
	.long 0xC6820000
	.long 0x00020FD8
	.long 0xC0700000
	.long 0x00021014
	.long 0xC6820000
	.long 0x00021018
	.long 0xC0C80000
	.long 0x00021054
	.long 0xC6960000
	.long 0x00021058
	.long 0xC0C80000
	.long 0x00021094
	.long 0xC6AA0000
	.long 0x00021098
	.long 0xC0C80000
	.long 0x000210D4
	.long 0x46820000
	.long 0x000210D8
	.long 0x46C80000
	.long 0x00021114
	.long 0x46960000
	.long 0x00021118
	.long 0x46C80000
	.long 0x00021154
	.long 0x40AA0000
	.long 0x00021158
	.long 0x40C80000
	.long 0x00021194
	.long 0x40AA0000
	.long 0x00021198
	.long 0x40700000
	.long 0x000211D4
	.long 0xC6960000
	.long 0x000211D8
	.long 0xC0700000
	.long 0x00021214
	.long 0x40960000
	.long 0x00021218
	.long 0x40700000
	.long 0x00021254
	.long 0x40820000
	.long 0x00021258
	.long 0x40700000
	.long 0x000216D4
	.long 0xC2740000
	.long 0x000216D8
	.long 0x00000000
	.long 0x00021714
	.long 0x42740000
	.long 0x00021718
	.long 0x00000000
	.long 0x00056434
	.long 0x00000000
	.long 0x00056438
	.long 0x46000000
	.long 0x0005643C
	.long 0x00000000
	.long 0x00056440
	.long 0x46000000
	.long 0x00056444
	.long 0x00000000
	.long 0x00056448
	.long 0x46000000
	.long 0x0005644C
	.long 0x00000000
	.long 0x00056450
	.long 0x46000000
	.long 0x00056454
	.long 0x00000000
	.long 0x00056458
	.long 0x46000000
	.long 0x0005645C
	.long 0x00000000
	.long 0x00056460
	.long 0x46000000
	.long 0x00056464
	.long 0x00000000
	.long 0x00056468
	.long 0x46000000
	.long 0x0005646C
	.long 0x00000000
	.long 0x00056470
	.long 0x46000000
	.long 0x00056474
	.long 0x00000000
	.long 0x00056478
	.long 0x46000000
	.long 0x0005647C
	.long 0x00000000
	.long 0x00056480
	.long 0x46000000
	.long 0x00056484
	.long 0x00000000
	.long 0x00056488
	.long 0x46000000
	.long 0x0005648C
	.long 0x00000000
	.long 0x00056490
	.long 0x46000000
	.long 0x00056494
	.long 0x00000000
	.long 0x00056498
	.long 0x46000000
	.long 0x0005649C
	.long 0x00000000
	.long 0x000564A0
	.long 0x46000000
	.long 0x000564A4
	.long 0x00000000
	.long 0x000564A8
	.long 0x46000000
	.long 0x000564AC
	.long 0x00000000
	.long 0x000564B0
	.long 0x46000000
	.long 0x000564B4
	.long 0x00000000
	.long 0x000564B8
	.long 0x46000000
	.long 0x000564BC
	.long 0x00000000
	.long 0x000564C0
	.long 0x46000000
	.long 0x000564C4
	.long 0x00000000
	.long 0x000564C8
	.long 0x46000000
	.long 0x000564CC
	.long 0x00000000
	.long 0x000564D0
	.long 0x46000000
	.long 0x000564D4
	.long 0x00000000
	.long 0x000564D8
	.long 0x46000000
	.long 0x000564DC
	.long 0x00000000
	.long 0x000564E0
	.long 0x46000000
	.long 0x000564E4
	.long 0xC2DB0000
	.long 0x000564EC
	.long 0xC2A00000
	.long 0x00056504
	.long 0xC2DF0000
	.long 0x00056508
	.long 0x00000000
	.long 0x0005650C
	.long 0x42DE0000
	.long 0x00056514
	.long 0x42D40000
	.long 0x0005651C
	.long 0x42DE0000
	.long 0x00056520
	.long 0x00000000
	.long 0x00056534
	.long 0x42D40000
	.long 0x0005653C
	.long 0xC2DB0000
	.long 0x00056544
	.long 0xC2DF0000
	.long 0x0005654C
	.long 0xC2CB0000
	.long 0x00056554
	.long 0x42C40000
	.long 0x0005655C
	.long 0x00000000
	.long 0x00056560
	.long 0x46000000
	.long 0x00056564
	.long 0x00000000
	.long 0x00056568
	.long 0x46000000
	.long 0x0005656C
	.long 0x42990000
	.long 0x00058FE0
	.long 0x7F7F0320
	.long 0x00058FE4
	.long 0x7F7F0708
	.long 0x00058FE8
	.long 0x0000C28F
	.long 0x00059038
	.long 0x000404A3
	.long 0x0005A5FC
	.long 0x43A58000
	.long 0x0005A63C
	.long 0xC3A50000
	.long 0x0005A640
	.long 0x437A0000
	.long 0x0005A8BC
	.long 0xC22AAAAB
	.long 0x0005A8C0
	.long 0x42200000
	.long 0x0005A8FC
	.long 0x422AAAAB
	.long 0x0005A900
	.long 0x42200000
	.long 0x0005A93C
	.long 0x42B15555
	.long 0x0005A940
	.long 0x40A00000
	.long 0x0005A97C
	.long 0xC2B15555
	.long 0x0005A980
	.long 0x40A00000
	.long 0x00058ED0
	.long 0x00000087
	.long 0xFFFFFFFF
	.long 0x0001458C
	.long 0x80000000
	.long 0x000147EC
	.long 0x80000000
	.long 0x000148EC
	.long 0x80000000
	.long 0x00014AAC
	.long 0x80000000
	.long 0x00014BAC
	.long 0x80000000
	.long 0x00014D4C
	.long 0x80000000
	.long 0x00014F0C
	.long 0x80000000
	.long 0x0001500C
	.long 0x80000000
	.long 0x000151AC
	.long 0x80000000
	.long 0x00025134
	.long 0x42AB999A
	.long 0x00025138
	.long 0xC2200000
	.long 0x0002513C
	.long 0xC3480000
	.long 0x00025338
	.long 0x42200000
	.long 0x0002533C
	.long 0x43480000
	.long 0x00025328
	.long 0x3FA8F5C3
	.long 0x00025174
	.long 0xC3250000
	.long 0x00025178
	.long 0x428C0000
	.long 0x0002517C
	.long 0x42F78000
	.long 0x000251B4
	.long 0xC3070000
	.long 0x000251B8
	.long 0x42AA0000
	.long 0x000251BC
	.long 0x42C80000
	.long 0x000251F4
	.long 0xC2A00000
	.long 0x000251F8
	.long 0x42960000
	.long 0x000251FC
	.long 0x42B80000
	.long 0x00014144
	.long 0x00000000
	.long 0x000140C4
	.long 0x00000000
	.long 0x00014044
	.long 0x00000000
	.long 0xCD02B888
	.long 0x000001B0
	.long 0xC47A0000
	.long 0x0002B8D8
	.long 0xC2860000
	.long 0x0002B8DC
	.long 0x38D1B717
	.long 0x0002B8F8
	.long 0xC1F00000
	.long 0x0002B8FC
	.long 0x38D1B717
	.long 0x0002B910
	.long 0xC1A00000
	.long 0x0002B914
	.long 0x38D1B717
	.long 0x0002B900
	.long 0x00000000
	.long 0x0002B904
	.long 0x38D1B717
	.long 0x0002B908
	.long 0x41A00000
	.long 0x0002B90C
	.long 0x38D1B717
	.long 0x0002B8E0
	.long 0x41F00000
	.long 0x0002B8E4
	.long 0x38D1B717
	.long 0x0002B8E8
	.long 0x42860000
	.long 0x0002B8EC
	.long 0x38D1B717
	.long 0x0002B8F0
	.long 0x42860000
	.long 0x0002B8F4
	.long 0xC3480000
	.long 0x0002B8D0
	.long 0xC2860000
	.long 0x0002B8D4
	.long 0xC3480000
	.long 0x0002C1B8
	.long 0x00000087
	.long 0x0002C4C4
	.long 0xC30C0000
	.long 0x0002C4C8
	.long 0x43020000
	.long 0x0002C504
	.long 0x430C0000
	.long 0x0002C508
	.long 0xC2700000
	.long 0x0002C584
	.long 0xC3340000
	.long 0x0002C544
	.long 0x43340000
	.long 0x0002C548
	.long 0xC2DC0000
	.long 0x0002C588
	.long 0x43340000
	.long 0x0002C844
	.long 0xC2340000
	.long 0x0002C848
	.long 0x40E00000
	.long 0x0002C884
	.long 0x42340000
	.long 0x0002C888
	.long 0x40E00000
	.long 0x0002C8C4
	.long 0x41C80000
	.long 0x0002C8C8
	.long 0x40E00000
	.long 0x0002C904
	.long 0xC1C80000
	.long 0x0002C908
	.long 0x40E00000
	.long 0xFFFFFFFF
	.long 0x0000C0F8
	.long 0xC60C0000
	.long 0x0000C238
	.long 0xC6340000
	.long 0x0000C278
	.long 0xC6340000
	.long 0x0000C2B8
	.long 0xC6340000
	.long 0x0000C2F8
	.long 0xC6340000
	.long 0x0000C338
	.long 0xC6340000
	.long 0x0000C378
	.long 0xC6340000
	.long 0x0000C3B8
	.long 0xC60C0000
	.long 0x0000C3F8
	.long 0xC60C0000
	.long 0x0000C438
	.long 0xC60C0000
	.long 0x0000C478
	.long 0xC60C0000
	.long 0x0000C4B8
	.long 0xC60C0000
	.long 0x0000C4F8
	.long 0xC60C0000
	.long 0x0000C5B8
	.long 0xC2720000
	.long 0x0000C664
	.long 0xC2A20000
	.long 0x0000C668
	.long 0x430D0000
	.long 0x0000C6D4
	.long 0x42A20000
	.long 0x0000C6D8
	.long 0x430D0000
	.long 0x0000C744
	.long 0x42A20000
	.long 0x0000C824
	.long 0xC2A20000
	.long 0x0000ECDC
	.long 0x00000000
	.long 0x0000ECE4
	.long 0x00000000
	.long 0x0000ECE8
	.long 0x00000000
	.long 0x0000ECEC
	.long 0x00000000
	.long 0x0000ECF4
	.long 0x00000000
	.long 0x0000ECF8
	.long 0x00000000
	.long 0x0000ECFC
	.long 0x00000000
	.long 0x0000ED04
	.long 0x00000000
	.long 0x0000ED0C
	.long 0x00000000
	.long 0x0000ED10
	.long 0x00000000
	.long 0x0000ED14
	.long 0x00000000
	.long 0x0000ED1C
	.long 0x00000000
	.long 0x0000ED20
	.long 0x00000000
	.long 0x0000ED24
	.long 0x00000000
	.long 0x0000C138
	.long 0xC3960000
	.long 0x0000C538
	.long 0xC3960000
	.long 0x0000C578
	.long 0xC3960000
	.long 0x0000C178
	.long 0xC3960000
	.long 0x0000C1B8
	.long 0xC3960000
	.long 0x0000C1F8
	.long 0xC3960000
	.long 0x0000FDAC
	.long 0x41A00000
	.long 0x00010374
	.long 0xC21C0000
	.long 0x000103B4
	.long 0x421C0000
	.long 0x000083E4
	.long 0x00000000
	.long 0x00008544
	.long 0x00000000
	.long 0x000085C4
	.long 0x00000000
	.long 0x00008824
	.long 0x00000000
	.long 0x00008984
	.long 0x00000000
	.long 0x00008A04
	.long 0x00000000
	.long 0x0000C078
	.long 0xC47A0000
	.long 0x00007BE4
	.long 0x00000000
	.long 0x00007C44
	.long 0x00000000
	.long 0x00007CA4
	.long 0x00000000
	.long 0x00007C04
	.long 0x00000000
	.long 0x00007D04
	.long 0x00000000
	.long 0x00007DE4
	.long 0x00000000
	.long 0x00007F64
	.long 0x00000000
	.long 0x00008104
	.long 0x00000000
	.long 0x00008164
	.long 0x00000000
	.long 0x00008204
	.long 0x00000000
	.long 0x000082A4
	.long 0x00000000
	.long 0x00010374
	.long 0xC2100000
	.long 0x00010378
	.long 0x40E00000
	.long 0x000103B4
	.long 0x42100000
	.long 0x000103B8
	.long 0x40E00000
	.long 0x000103F4
	.long 0x41700000
	.long 0x000103F8
	.long 0x40E00000
	.long 0x00010434
	.long 0xC1700000
	.long 0x00010438
	.long 0x40E00000
	.long 0xFFFFFFFF
	.long 0x00001560
	.long 0x31E8FEFF
	.long 0x00001568
	.long 0x03050003
	.long 0x00009DB4
	.long 0xC67F0000
	.long 0x00009E34
	.long 0x467F0000
	.long 0x00012AB4
	.long 0xC2F20000
	.long 0x00013034
	.long 0x42F20000
	.long 0x00013210
	.long 0x00000000
	.long 0x00013214
	.long 0x00000000
	.long 0x00013218
	.long 0x00000000
	.long 0x0001321C
	.long 0x00000000
	.long 0x00013220
	.long 0x00000000
	.long 0x00013224
	.long 0x00000000
	.long 0x00013228
	.long 0x00000000
	.long 0x0001322C
	.long 0x00000000
	.long 0x00013230
	.long 0x00000000
	.long 0x00013234
	.long 0x00000000
	.long 0x00013238
	.long 0x42D40000
	.long 0x00013240
	.long 0x42D40000
	.long 0x00013248
	.long 0x00000000
	.long 0x0001324C
	.long 0x00000000
	.long 0x00013250
	.long 0x00000000
	.long 0x00013254
	.long 0x00000000
	.long 0x00013258
	.long 0x00000000
	.long 0x0001325C
	.long 0x00000000
	.long 0x00013260
	.long 0x00000000
	.long 0x00013264
	.long 0x00000000
	.long 0x00013268
	.long 0x00000000
	.long 0x0001326C
	.long 0x00000000
	.long 0x00013278
	.long 0xC2D40000
	.long 0x00013280
	.long 0xC2D40000
	.long 0x00015F54
	.long 0xC3460000
	.long 0x00015F94
	.long 0x43480000
	.long 0x00015FD4
	.long 0xC3960000
	.long 0x00016014
	.long 0x43960000
	.long 0x00009DE8
	.long 0x40166666
	.long 0x00009EA8
	.long 0x40200000
	.long 0x00009E68
	.long 0x40200000
	.long 0x00016214
	.long 0xC2780000
	.long 0x00016218
	.long 0x40E00000
	.long 0x00016254
	.long 0x42780000
	.long 0x00016258
	.long 0x40E00000
	.long 0x00016294
	.long 0x42000000
	.long 0x00016298
	.long 0x40E00000
	.long 0x000162D4
	.long 0xC2000000
	.long 0x000162D8
	.long 0x40E00000
	.long 0xFFFFFFFF
	.long 0x0000C328
	.long 0x3F000000
	.long 0x0000C32C
	.long 0x3F000000
	.long 0x0000C330
	.long 0x3F000000
	.long 0x0000C338
	.long 0xC2A1E666
	.long 0x0000C33C
	.long 0x40A00000
	.long 0x00046148
	.long 0x40A00000
	.long 0x0004614C
	.long 0x40A00000
	.long 0x00046150
	.long 0x40A00000
	.long 0x00046158
	.long 0xC2700000
	.long 0x0004615C
	.long 0x41200000
	.long 0x0003DD54
	.long 0x4099999A
	.long 0x000466FC
	.long 0x43960000
	.long 0x00046704
	.long 0x43960000
	.long 0x000475CC
	.long 0x0000006A
	.long 0x000475D0
	.long 0x00000068
	.long 0x000475D4
	.long 0x00000000
	.long 0x000475D8
	.long 0x00680001
	.long 0x000475DC
	.long 0x00690001
	.long 0x000000A0
	.long 0x00000000
	.long 0x000000A4
	.long 0x00000022
	.long 0x000473E0
	.long 0x00650003
	.long 0x000473E4
	.long 0x00000000
	.long 0x000473E8
	.long 0x00680001
	.long 0x000473EC
	.long 0x00690001
	.long 0x00047404
	.long 0x007F0006
	.long 0x000473F4
	.long 0xC2B40000
	.long 0x000473F8
	.long 0xC3520000
	.long 0x000473FC
	.long 0x42B40000
	.long 0x00047400
	.long 0xC1200000
	.long 0x00046578
	.long 0x42A33333
	.long 0x0004657C
	.long 0xC1EAE0AA
	.long 0x00046580
	.long 0x42A33333
	.long 0x00046584
	.long 0xC3480000
	.long 0x00046588
	.long 0x42766666
	.long 0x0004658C
	.long 0xC1EAE0AA
	.long 0x00046590
	.long 0xC2766666
	.long 0x00046594
	.long 0xC1EAE0AA
	.long 0x00046598
	.long 0xC2A33333
	.long 0x0004659C
	.long 0xC1EAE0AA
	.long 0x000465A0
	.long 0xC2A33333
	.long 0x000465A4
	.long 0xC3480000
	.long 0x00046D58
	.long 0x00830082
	.long 0x00046D5C
	.long 0x00690067
	.long 0x00046D64
	.long 0x00010210
	.long 0x00046D68
	.long 0x0081007F
	.long 0x00046D6C
	.long 0x00670068
	.long 0x00046D74
	.long 0x00010210
	.long 0x00046D78
	.long 0x00820081
	.long 0x00046D7C
	.long 0x00650066
	.long 0x00046D84
	.long 0x00010010
	.long 0x00046D88
	.long 0x007F0080
	.long 0x00046D8C
	.long 0x0066FFFF
	.long 0x00046D94
	.long 0x00040010
	.long 0x00046D98
	.long 0x00840083
	.long 0x00046D9C
	.long 0xFFFF0065
	.long 0x00046DA4
	.long 0x00080010
	.long 0x000464C4
	.long 0x43960000
	.long 0x000464CC
	.long 0x43960000
	.long 0x000464D4
	.long 0x43960000
	.long 0x00049510
	.long 0xC3250000
	.long 0x000494D0
	.long 0x43200000
	.long 0x00049514
	.long 0xC2A00000
	.long 0x000494D4
	.long 0x42F00000
	.long 0x00047850
	.long 0x000000A0
	.long 0x00047854
	.long 0x000003E8
	.long 0x00047874
	.long 0x00000028
	.long 0x00047878
	.long 0x00000064
	.long 0x0004787C
	.long 0x000000C8
	.long 0x00049550
	.long 0x43660000
	.long 0x00049590
	.long 0xC3660000
	.long 0x00049554
	.long 0x43200000
	.long 0x00049594
	.long 0xC2C80000
	.long 0x000496D0
	.long 0xC2766666
	.long 0x000496D4
	.long 0xC1B2E0AA
	.long 0x00049710
	.long 0x42766666
	.long 0x00049714
	.long 0xC1B2E0AA
	.long 0x00049750
	.long 0x41FCCCCD
	.long 0x00049754
	.long 0xC1B2E0AA
	.long 0x00049790
	.long 0xC1FCCCCD
	.long 0x00049794
	.long 0xC1B2E0AA
	.long 0x000497D4
	.long 0x41A00000
	.long 0xFFFFFFFF
	.long 0x00039068
	.long 0x3F333333
	.long 0x0003906C
	.long 0x3F333333
	.long 0x00039070
	.long 0x3F333333
	.long 0x00039074
	.long 0x442F0000
	.long 0x00039078
	.long 0xC3BB8000
	.long 0x0003907C
	.long 0xC1F00000
	.long 0x00061BE4
	.long 0x3FC90FF9
	.long 0x00061BE8
	.long 0x3FD9999A
	.long 0x00061BEC
	.long 0x40200000
	.long 0x00061BF0
	.long 0x3F8CCCCD
	.long 0x00061BF4
	.long 0x3FE66666
	.long 0x00061BF8
	.long 0xC4048000
	.long 0x00061BFC
	.long 0x80000000
	.long 0x00074D48
	.long 0x00000096
	.long 0x00074D4C
	.long 0x000003E8
	.long 0x000750D4
	.long 0x437A0000
	.long 0x00075094
	.long 0xC37A0000
	.long 0x000750D8
	.long 0x435C0000
	.long 0x00075098
	.long 0xC2C80000
	.long 0x00075114
	.long 0x439B0000
	.long 0x00075154
	.long 0xC39B0000
	.long 0x00075118
	.long 0x43870000
	.long 0x00075158
	.long 0xC3200000
	.long 0x000745CC
	.long 0xC47A0000
	.long 0x000745D0
	.long 0xC47A0000
	.long 0x000745D4
	.long 0x447A0000
	.long 0x000745D8
	.long 0x447A0000
	.long 0x00073EFC
	.long 0x00010200
	.long 0x00073840
	.long 0xC2E10000
	.long 0x00073844
	.long 0xC3F68000
	.long 0x00073848
	.long 0xC2200000
	.long 0x0007384C
	.long 0xC3F68000
	.long 0x00073850
	.long 0xC1A00000
	.long 0x00073854
	.long 0xC3F68000
	.long 0x00073858
	.long 0x41A00000
	.long 0x0007385C
	.long 0xC3F68000
	.long 0x00073860
	.long 0x42200000
	.long 0x00073864
	.long 0xC3F68000
	.long 0x00073830
	.long 0x42E10000
	.long 0x00073834
	.long 0xC3F68000
	.long 0x00073808
	.long 0x42E10000
	.long 0x0007380C
	.long 0xC40DC000
	.long 0x00073810
	.long 0x42200000
	.long 0x00073814
	.long 0xC40DC000
	.long 0x00073818
	.long 0x41A00000
	.long 0x0007381C
	.long 0xC40DC000
	.long 0x00073820
	.long 0xC1A00000
	.long 0x00073824
	.long 0xC40DC000
	.long 0x00073828
	.long 0xC2200000
	.long 0x0007382C
	.long 0xC40DC000
	.long 0x00073838
	.long 0xC2E10000
	.long 0x0007383C
	.long 0xC40DC000
	.long 0x0000EEFC
	.long 0xC400C000
	.long 0x0000EF00
	.long 0x40E00000
	.long 0x0000EF3C
	.long 0xC3BB8000
	.long 0x0000EF40
	.long 0x40E00000
	.long 0x0000EF7C
	.long 0xC3D38000
	.long 0x0000EF80
	.long 0x40E00000
	.long 0x0000EFBC
	.long 0xC3EA8000
	.long 0x0000EFC0
	.long 0x40E00000
	.long 0x00075518
	.long 0x42C80000
	.long 0xFFFFFFFF
	.long 0x0003D6D8
	.long 0xC2C80000
	.long 0x0003D6DC
	.long 0xC3C80000
	.long 0x0003D6BC
	.long 0x3E567770
	.long 0x0003D77C
	.long 0xBE567770
	.long 0x0003D788
	.long 0x40400000
	.long 0x0003D78C
	.long 0x40400000
	.long 0x0003D790
	.long 0x40800000
	.long 0x0003D794
	.long 0x80000000
	.long 0x0003D798
	.long 0xC2A80000
	.long 0x0003D79C
	.long 0x44258000
	.long 0x00046314
	.long 0xC28C0000
	.long 0x00046318
	.long 0x41F00000
	.long 0x0004631C
	.long 0xC1500000
	.long 0x00046394
	.long 0x428C0000
	.long 0x00046398
	.long 0x41F00000
	.long 0x0004639C
	.long 0xC1500000
	.long 0x00046408
	.long 0x40400000
	.long 0x0004640C
	.long 0x40400000
	.long 0x00046410
	.long 0x40400000
	.long 0x00046414
	.long 0x00000000
	.long 0x00046418
	.long 0xC1F00000
	.long 0x0004641C
	.long 0x40A00000
	.long 0xCD049A68
	.long 0x00000210
	.long 0xC3960000
	.long 0x0004A0F0
	.long 0xC3480000
	.long 0x00049BC8
	.long 0xC2A20000
	.long 0x00049BCC
	.long 0x38D1B717
	.long 0x00049BD0
	.long 0xC2700000
	.long 0x00049BD4
	.long 0x38D1B717
	.long 0x00049C58
	.long 0x42700000
	.long 0x00049C5C
	.long 0x38D1B717
	.long 0x00049BD8
	.long 0x42A20000
	.long 0x00049BDC
	.long 0x38D1B717
	.long 0x00049BC0
	.long 0xC2A20000
	.long 0x00049BC4
	.long 0xC3480000
	.long 0x00049BE0
	.long 0x42A20000
	.long 0x00049BE4
	.long 0xC3480000
	.long 0x0004DED8
	.long 0xC3160000
	.long 0x0004DEDC
	.long 0x43200000
	.long 0x0004DF18
	.long 0x43160000
	.long 0x0004DF1C
	.long 0xC28C0000
	.long 0x0004DF58
	.long 0xC3610000
	.long 0x0004DF5C
	.long 0x43520000
	.long 0x0004DF98
	.long 0x43610000
	.long 0x0004DF9C
	.long 0xC2F00000
	.long 0x0004DAEC
	.long 0x00000082
	.long 0x0004DAF0
	.long 0x000003E8
	.long 0x0004E258
	.long 0xC2700000
	.long 0x0004E25C
	.long 0x40A00000
	.long 0x0004E298
	.long 0x42700000
	.long 0x0004E29C
	.long 0x40A00000
	.long 0x0004E2D8
	.long 0x420C0000
	.long 0x0004E2DC
	.long 0x40A00000
	.long 0x0004E318
	.long 0xC20C0000
	.long 0x0004E31C
	.long 0x40A00000
	.long 0x0004E358
	.long 0x00000000
	.long 0x0004E35C
	.long 0x42480000
	.long 0xFFFFFFFF
	.long 0x0002DAC4
	.long 0x00000000
	.long 0x0002D704
	.long 0x00000000
	.long 0x0002D4E4
	.long 0x00000000
	.long 0x0002D464
	.long 0x00000000
	.long 0x0002D244
	.long 0x00000000
	.long 0x0002E358
	.long 0xC2FB0000
	.long 0x0002E35C
	.long 0xC4EEC000
	.long 0x00037BEC
	.long 0x00140010
	.long 0x00037C2C
	.long 0x00040000
	.long 0x00037C58
	.long 0x42700000
	.long 0xCD04C9FC
	.long 0x000001E0
	.long 0xC3960000
	.long 0x0004D068
	.long 0x00000000
	.long 0x0004D06C
	.long 0xC3480000
	.long 0x0004D070
	.long 0x43C80000
	.long 0x0004D074
	.long 0x43480000
	.long 0x0004CB9C
	.long 0x432F0000
	.long 0x0004CBA0
	.long 0xC18F3333
	.long 0x0004CBA4
	.long 0x43B40000
	.long 0x0004CBA8
	.long 0xC18F3333
	.long 0x0004CBAC
	.long 0x43B40000
	.long 0x0004CBB0
	.long 0xC2640000
	.long 0x0004CBB4
	.long 0x432F0000
	.long 0x0004CBB8
	.long 0xC2640000
	.long 0x0004CD38
	.long 0x00010206
	.long 0x0004D630
	.long 0x00000000
	.long 0x0004D460
	.long 0x00000087
	.long 0x0004D8A4
	.long 0xC38C0000
	.long 0x0004D8A8
	.long 0x437A0000
	.long 0x0004D8E4
	.long 0x438C0000
	.long 0x0004D8E8
	.long 0xC2920000
	.long 0x0004D924
	.long 0xC3B40000
	.long 0x0004D928
	.long 0x43A78000
	.long 0x0004D964
	.long 0x43B40000
	.long 0x0004D968
	.long 0xC3250000
	.long 0x0004DAE4
	.long 0xC2A00000
	.long 0x0004DAE8
	.long 0x40A00000
	.long 0x0004DB24
	.long 0x42A00000
	.long 0x0004DB28
	.long 0x40A00000
	.long 0x0004DB64
	.long 0x42200000
	.long 0x0004DB68
	.long 0x40A00000
	.long 0x0004DBA4
	.long 0xC2200000
	.long 0x0004DBA8
	.long 0x40A00000
	.long 0x0004DBE8
	.long 0x42C80000
	.long 0xFFFFFFFF
	.long 0x3C608047
	.long 0x00000000
	.long 0x043E8490
	.long 0x80011754
	.long 0x04219098
	.long 0x48000118
	.long 0x043E84CC
	.long 0x00000000
	.long 0xC221A004
	.long 0x0000000C
	.long 0x38600008
	.long 0x3D808038
	.long 0x618C0484
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x48000011
	.long 0x7CA802A6
	.long 0x7CA328AE
	.long 0x48000010
	.long 0x4E800021
	.long 0x0001030D
	.long 0x12141516
	.long 0x7FC3F378
	.long 0x809D0014
	.long 0x3D80801C
	.long 0x618C9D5C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x7FC3F378
	.long 0x3D80801C
	.long 0x618C4C04
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x00000000
	.long 0x04216574
	.long 0x60000000
	.long 0x04216EF4
	.long 0x60000000
	.long 0x041F1C50
	.long 0x60000000
	.long 0x041F1F84
	.long 0x60000000
	.long 0x041F2020
	.long 0x60000000
	.long 0x041F4430
	.long 0x60000000
	.long 0x041E5B9C
	.long 0x60000000
	.long 0x041E5BAC
	.long 0x60000000
	.long 0x041E55CC
	.long 0x60000000
	.long 0x041E5B54
	.long 0x60000000
	.long 0x04201524
	.long 0x60000000
	.long 0x04201608
	.long 0x60000000
	.long 0x043E5990
	.long 0x00000000
	.long 0x04201410
	.long 0x60000000
	.long 0xC2201454
	.long 0x00000011
	.long 0x48000071
	.long 0x7CE802A6
	.long 0x7FC3F378
	.long 0x38800010
	.long 0x38A00002
	.long 0x38C00002
	.long 0xC0270000
	.long 0xC042BC84
	.long 0x3D80801C
	.long 0x618C9C1C
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3860000A
	.long 0x3D808005
	.long 0x618C7CFC
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3860000A
	.long 0x3D808005
	.long 0x618C6560
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x3860000A
	.long 0x3D808005
	.long 0x618C7AE8
	.long 0x7D8903A6
	.long 0x4E800421
	.long 0x4800000C
	.long 0x4E800021
	.long 0x42C80000
	.long 0x3C608020
	.long 0x3C608020
	.long 0x60000000
	.long 0x00000000
	.long 0x04201904
	.long 0x4E800020
	.long -1


#endregion
#region Code Descriptions
SnapPAL_UCF_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0xac,0x00,0xb3,0x12
  .ascii "Fixes controller disparities with dashback and "
  .byte 0x03
  .ascii "shield drop. Current version is 0.74."
  .byte 0x00
	.align 2
SnapPAL_Frozen_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0xac,0x00,0xb3,0x12
  .ascii "Disables hazards on tournament stages."
  .byte 0x00
	.align 2
SnapPAL_Spawns_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0xac,0x00,0xb3,0x12
  .ascii "Players spawn in neutral positions regardless "
  .byte 0x03
  .ascii "of port."
  .byte 0x00
	.align 2
SnapPAL_DisableWobbling_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0x90,0x00,0xb3,0x12
  .ascii "Disable Ice Climbers' grab infinite."
  .byte 0x03
  .ascii "Opponent breaks out after being hit by Nana 3 times."
  .byte 0x00
	.align 2
SnapPAL_Ledgegrab_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0xac,0x00,0xb3,0x12
  .ascii "Time-out victories are awarded to the player "
  .byte 0x03
  .ascii "with under 60 ledgegrabs."
  .byte 0x00
	.align 2
SnapPAL_TournamentQoL_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0x75,0x00,0xb3,0x12
  .ascii "Stage striking, hide nametags while invisible during singles, "
  .byte 0x03
  .ascii "toggle rumble from CSS, close port on unplug, disable FoD in doubles."
  .byte 0x00
	.align 2
SnapPAL_FriendliesQoL_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0x75,0x00,0xb3,0x12
    .ascii "Skip result screen, A+B for salty runback, A+X for random stage,"
    .byte 0x03
    .ascii "highlight winner's name."
    .byte 0x00
  	.align 2
SnapPAL_GameVersion_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0xac,0x00,0xb3,0x12
  .ascii "Toggle between multiple game versions."
  .byte 0x00
	.align 2
SnapPAL_StageExpansion_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0x74,0x00,0xb3,0x12
  .ascii "Modify banned stages to be competively viable. Adjusts Jungle"
  .byte 0x03
  .ascii "Japes, Peach's Castle, Onett, Green Greens, Mute City, Flat Zone"
  .byte 0x03
  .ascii "Fourside, Rainbow Cruise, Yoshi's Island, and Mushroom Kingdom 1+2."
  .byte 0x00
	.align 2
SnapPAL_Widescreen_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0x70,0x00,0xb3,0x12
  .ascii "Enable widescreen. Players take damage when outside of the 4:3 region."
  .byte 0x03
  .ascii "Use Standard if thin black bars are present."
  .byte 0x03
  .ascii "Use True if the image occupies the entire screen."
  .byte 0x00
	.align 2


#endregion

#endregion
#region SnapPAL_Codes_SceneLoad
SnapPAL_Codes_SceneLoad:
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

SnapPAL_Codes_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl SnapPAL_Codes_SceneLoad_TextProperties
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
	bl SnapPAL_CodeNames_Title
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
	bl SnapPAL_CodeNames_ModName
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
  bl  SnapPAL_Codes_SceneThink
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
  bl  SnapPAL_Codes_CreateMenu

SnapPAL_Codes_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region SnapPAL_Codes_SceneThink
SnapPAL_Codes_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  SnapPAL_Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Code Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,Inputs_GetPlayerRapidHeldInputs
  mr  REG_Inputs,r3
#Check for movement up
  rlwinm. r0,REG_Inputs,0,0x10
  beq SnapPAL_Codes_SceneThink_SkipUp
#Adjust cursor
  lhz r3,OFST_CursorLocation(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_CursorLocation(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge SnapPAL_Codes_SceneThink_UpdateMenu
#Cursor stays at top
  li  r3,0
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll up
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge SnapPAL_Codes_SceneThink_UpdateMenu
#Scroll stays at top
  li  r3,0
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b SnapPAL_Codes_SceneThink_Exit
SnapPAL_Codes_SceneThink_SkipUp:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x20
  beq SnapPAL_Codes_SceneThink_AdjustOptionSelection
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
  b SnapPAL_Codes_SceneThink_Exit
#Check if exceeds max amount of codes per page
  cmpwi r3,MaxCodesOnscreen-1
  ble SnapPAL_Codes_SceneThink_UpdateMenu
#Cursor stays at bottom
  li  r3,MaxCodesOnscreen-1
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll down
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  addi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,CodeAmount-MaxCodesOnscreen
  ble SnapPAL_Codes_SceneThink_UpdateMenu
#Scroll stays at bottom
  li  r3,(CodeAmount-1)-(MaxCodesOnscreen-1)
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b SnapPAL_Codes_SceneThink_Exit
#endregion
#region Adjust Option Selection
SnapPAL_Codes_SceneThink_AdjustOptionSelection:
.set  REG_MaxOptions,20
.set  REG_OptionValuePtr,21
#Check for movement right
  rlwinm. r0,REG_Inputs,0,0x80
  beq SnapPAL_Codes_SceneThink_SkipRight
#Get amount of options for this code
  lhz r3,OFST_CursorLocation(REG_GObjData)
  lhz r4,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,r4                                #get which option this is
  bl  SnapPAL_CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add r3,r3,r4                                #get bl pointer to options info
  bl  SnapPAL_ConvertBlPointer
  lwz REG_MaxOptions,SnapPAL_CodeOptions_OptionCount(r3)     #get amount of options for this code
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
  ble SnapPAL_Codes_SceneThink_UpdateMenu
#Option stays maxxed out
  stb REG_MaxOptions,0x0(REG_OptionValuePtr)
  b SnapPAL_Codes_SceneThink_Exit
SnapPAL_Codes_SceneThink_SkipRight:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x40
  beq SnapPAL_Codes_SceneThink_CheckToExit
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
  bge SnapPAL_Codes_SceneThink_UpdateMenu
#Option stays at 0
  li  r3,0
  stb r3,0x0(REG_OptionValuePtr)
  b SnapPAL_Codes_SceneThink_Exit
#endregion
#region Check to Exit
SnapPAL_Codes_SceneThink_CheckToExit:
#Check for start input
  li  r3,4
  branchl r12,Inputs_GetPlayerInstantInputs
  rlwinm. r0,r4,0,0x1000
  beq SnapPAL_Codes_SceneThink_Exit
#Apply codes
  mr  r3,REG_GObjData
  bl  SnapPAL_ApplyAllGeckoCodes
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

  b SnapPAL_Codes_SceneThink_Exit
#endregion

SnapPAL_Codes_SceneThink_UpdateMenu:
#Redraw Menu
  mr  r3,REG_GObjData
  bl  SnapPAL_Codes_CreateMenu
#Play SFX
  branchl r12,SFX_PlayMenuSound_CloseOpenPort
  b SnapPAL_Codes_SceneThink_Exit

SnapPAL_Codes_SceneThink_Exit:
  restore
  blr
#endregion
#region SnapPAL_Codes_SceneDecide
SnapPAL_Codes_SceneDecide:
  backup

#Change Major
  li  r3,ExitSceneID
  branchl r12,MenuController_WriteToPendingMajor
#Leave Major
  branchl r12,MenuController_ChangeScreenMajor

SnapPAL_Codes_SceneDecide_Exit:
  restore
  blr
############################################
#endregion
#region SnapPAL_Codes_CreateMenu
SnapPAL_Codes_CreateMenu:
.set  REG_GObjData,31
.set  REG_TextGObj,30
.set  REG_TextProp,29

#Init
  backup
  mr  REG_GObjData,r3
  bl  SnapPAL_Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#Remove old text gobjs if they exist
  lwz r3,OFST_CodeNamesTextGObj(REG_GObjData)
  cmpwi r3,0
  beq SnapPAL_Codes_CreateMenu_SkipNameRemoval
  branchl r12,Text_RemoveText
SnapPAL_Codes_CreateMenu_SkipNameRemoval:
  lwz r3,OFST_CodeOptionsTextGObj(REG_GObjData)
  cmpwi r3,0
  beq SnapPAL_Codes_CreateMenu_SkipOptionRemoval
  branchl r12,Text_RemoveText
SnapPAL_Codes_CreateMenu_SkipOptionRemoval:

#region CreateTextGObjs
SnapPAL_Codes_CreateMenu_CreateTextGObjs:
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
#region SnapPAL_Codes_CreateMenu_CreateNames
SnapPAL_Codes_CreateMenu_CreateNamesInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
  li  REG_Count,0
SnapPAL_Codes_CreateMenu_CreateNamesLoop:
#Next name to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,REG_Count
#Get the string bl pointer
  bl  SnapPAL_CodeNames_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  SnapPAL_ConvertBlPointer
  mr  r4,r3
#Get Y Offset for this
  lis    r0, 0x4330
  lfd    f2, MagicNumber (REG_TextProp)
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
SnapPAL_Codes_CreateMenu_CreateNamesIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge SnapPAL_Codes_CreateMenu_CreateNameLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt SnapPAL_Codes_CreateMenu_CreateNamesLoop
SnapPAL_Codes_CreateMenu_CreateNameLoopEnd:
#endregion
#region SnapPAL_Codes_CreateMenu_CreateOptions
SnapPAL_Codes_CreateMenu_CreateOptionsInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
.set  REG_CurrentOptionID,22
.set  REG_CurrentOptionSelection,23
.set  REG_OptionStrings,24
.set  REG_StringLoopCount,25
  li  REG_Count,0
SnapPAL_Codes_CreateMenu_CreateOptionsLoop:
#Next option to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add REG_CurrentOptionID,r3,REG_Count
#Get the bl pointer
  mr  r3,REG_CurrentOptionID
  bl  SnapPAL_CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  SnapPAL_ConvertBlPointer
  lwz r4,SnapPAL_CodeOptions_OptionCount(r3)
  addi  r4,r4,1
  addi  REG_OptionStrings,r3,SnapPAL_CodeOptions_GeckoCodePointers  #Get pointer to gecko code pointers
  mulli r4,r4,0x4                                           #pointer length
  add REG_OptionStrings,REG_OptionStrings,r4
#Get this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx  REG_CurrentOptionSelection,r3,REG_CurrentOptionID

#Loop through strings and get the current one
  li  REG_StringLoopCount,0
SnapPAL_Codes_CreateMenu_CreateOptionsLoop_StringSearch:
  cmpw  REG_StringLoopCount,REG_CurrentOptionSelection
  beq SnapPAL_Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd
#Get next string
  mr  r3,REG_OptionStrings
  branchl r12,strlen
  add REG_OptionStrings,REG_OptionStrings,r3
  addi  REG_OptionStrings,REG_OptionStrings,1       #add 1 to skip past the 0 terminator
  addi  REG_StringLoopCount,REG_StringLoopCount,1
  b SnapPAL_Codes_CreateMenu_CreateOptionsLoop_StringSearch

SnapPAL_Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd:
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
  bl  SnapPAL_CodeOptions_Wrapper
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
SnapPAL_Codes_CreateMenu_CreateOptionsIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge SnapPAL_Codes_CreateMenu_CreateOptionsLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt SnapPAL_Codes_CreateMenu_CreateOptionsLoop
SnapPAL_Codes_CreateMenu_CreateOptionsLoopEnd:
#endregion
#region SnapPAL_Codes_CreateMenu_HighlightCursor
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
#region SnapPAL_Codes_CreateMenu_ChangeCodeDescription
#Get highlighted code ID
	lhz r3,OFST_ScrollAmount(REG_GObjData)
	lhz r4,OFST_CursorLocation(REG_GObjData)
	add	r3,r3,r4
#Get this codes options
	bl	SnapPAL_CodeOptions_Order
	mflr	r4
	mulli	r3,r3,0x4
	add	r3,r3,r4
	bl	SnapPAL_ConvertBlPointer
#Get this codes description
	addi	r3,r3,SnapPAL_CodeOptions_CodeDescription
	bl	SnapPAL_ConvertBlPointer
	lwz	r4,OFST_CodeDescTextGObj(REG_GObjData)
#Store to text gobj
	stw	r3,0x5C(r4)
#endregion

SnapPAL_Codes_CreateMenu_Exit:
  restore
  blr

###############################################

SnapPAL_ConvertBlPointer:
  lwz r4,0x0(r3)        #Load bl instruction
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
  add r3,r4,r3
  blr

#endregion
#region SnapPAL_ApplyAllGeckoCodes
SnapPAL_ApplyAllGeckoCodes:
.set  REG_GObjData,31
.set  REG_Count,30
.set  REG_OptionSelection,29
#Init
  backup
  mr  REG_GObjData,r3

#Default Codes
  bl  SnapPAL_DefaultCodes_On
  mflr  r3
  bl  SnapPAL_ApplyGeckoCode

#Init Loop
  li  REG_Count,0
ApplyAllGeckoSnapPAL_Codes_Loop:
#Load this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx REG_OptionSelection,r3,REG_Count
#Get this code's default gecko code pointer
  bl  SnapPAL_CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  SnapPAL_ConvertBlPointer
  addi  r3,r3,SnapPAL_CodeOptions_GeckoCodePointers
  bl  SnapPAL_ConvertBlPointer
  bl  SnapPAL_ApplyGeckoCode
#Get this code's gecko code pointers
  bl  SnapPAL_CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  SnapPAL_ConvertBlPointer
  addi  r3,r3,SnapPAL_CodeOptions_GeckoCodePointers
  mulli r4,REG_OptionSelection,0x4
  add  r3,r3,r4
  bl  SnapPAL_ConvertBlPointer
  bl  SnapPAL_ApplyGeckoCode

ApplyAllGeckoSnapPAL_Codes_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  blt ApplyAllGeckoSnapPAL_Codes_Loop

ApplyAllGeckoSnapPAL_Codes_Exit:
  restore
  blr

####################################

SnapPAL_ApplyGeckoCode:
.set  REG_GeckoCode,12
  mr  REG_GeckoCode,r3

SnapPAL_ApplyGeckoCode_Loop:
  lbz r3,0x0(REG_GeckoCode)
  cmpwi r3,0xC2
  beq SnapPAL_ApplyGeckoCode_C2
  cmpwi r3,0x4
  beq SnapPAL_ApplyGeckoCode_04
  cmpwi r3,0xFF
  beq SnapPAL_ApplyGeckoCode_Exit
  b SnapPAL_ApplyGeckoCode_Exit
SnapPAL_ApplyGeckoCode_C2:
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
  b SnapPAL_ApplyGeckoCode_Loop
SnapPAL_ApplyGeckoCode_04:
  lwz r3,0x0(REG_GeckoCode)
  rlwinm r3,r3,0,8,31
  oris  r3,r3,0x8000
  lwz r4,0x4(REG_GeckoCode)
  stw r4,0x0(r3)
  addi REG_GeckoCode,REG_GeckoCode,0x8
  b SnapPAL_ApplyGeckoCode_Loop
SnapPAL_ApplyGeckoCode_Exit:
blr

#endregion

#endregion

#region LagPrompt

#region SnapPAL_LagPrompt_SceneLoad
############################################

#region SnapPAL_LagPrompt_SceneLoad_Data
SnapPAL_LagPrompt_SceneLoad_TextProperties:
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

SnapPAL_LagPrompt_SceneLoad_TopText:
blrl
.ascii "Are you using HDMI?"
.align 2

SnapPAL_LagPrompt_SceneLoad_Yes:
blrl
.string "Yes"
.align 2

SnapPAL_LagPrompt_SceneLoad_No:
blrl
.string "No"
.align 2

#GObj Offsets
  .set OFST_TextGObj,0x0
  .set OFST_Selection,0x4

#endregion
#region SnapPAL_LagPrompt_SceneLoad
SnapPAL_LagPrompt_SceneLoad:
blrl

#Init
  backup

SnapPAL_LagPrompt_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl SnapPAL_LagPrompt_SceneLoad_TextProperties
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
	bl SnapPAL_LagPrompt_SceneLoad_TopText
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
	bl SnapPAL_LagPrompt_SceneLoad_Yes
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
	bl SnapPAL_LagPrompt_SceneLoad_No
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
  bl  SnapPAL_LagPrompt_SceneThink
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

SnapPAL_LagPrompt_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region SnapPAL_LagPrompt_SceneThink
SnapPAL_LagPrompt_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  SnapPAL_LagPrompt_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,Inputs_GetPlayerRapidHeldInputs
  mr  REG_Inputs,r3
#Check for movement to the right
  rlwinm. r0,REG_Inputs,0,0x80
  beq SnapPAL_LagPrompt_SceneThink_SkipRight
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  addi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,1
  ble SnapPAL_LagPrompt_SceneThink_HighlightSelection
  li  r3,1
  stb r3,OFST_Selection(REG_GObjData)
  b SnapPAL_LagPrompt_SceneThink_CheckForA
SnapPAL_LagPrompt_SceneThink_SkipRight:
#Check for movement to the left
  rlwinm. r0,REG_Inputs,0,0x40
  beq SnapPAL_LagPrompt_SceneThink_CheckForA
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  subi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge SnapPAL_LagPrompt_SceneThink_HighlightSelection
  li  r3,0
  stb r3,OFST_Selection(REG_GObjData)
  b SnapPAL_LagPrompt_SceneThink_CheckForA

SnapPAL_LagPrompt_SceneThink_HighlightSelection:
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
SnapPAL_LagPrompt_SceneThink_CheckForA:
  li  r3,4
  branchl r12,Inputs_GetPlayerInstantInputs
  rlwinm. r0,r4,0,0x100
  bne SnapPAL_LagPrompt_SceneThink_Confirmed
  rlwinm. r0,r4,0,0x1000
  bne SnapPAL_LagPrompt_SceneThink_Confirmed
  b SnapPAL_LagPrompt_SceneThink_Exit
SnapPAL_LagPrompt_SceneThink_Confirmed:
#Play Menu Sound
  branchl r12,SFX_PlayMenuSound_Forward
#If yes, apply lag reduction
  lbz r3,OFST_Selection(REG_GObjData)
  cmpwi r3,0
  bne SnapPAL_LagPrompt_SceneThink_ExitScene
#endregion
#region Apply Code
.set  REG_GeckoCode,12
#Apply lag reduction
  bl  SnapPAL_LagReductionGeckoCode
  mflr  r3
  bl  SnapPAL_ApplyGeckoCode
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
#Enable PAL60
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

SnapPAL_LagPrompt_SceneThink_ExitScene:
  branchl r12,MenuController_ChangeScreenMinor

SnapPAL_LagPrompt_SceneThink_Exit:
  restore
  blr
#endregion
#region SnapPAL_LagPrompt_SceneDecide
SnapPAL_LagPrompt_SceneDecide:

  backup

#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  SnapPAL_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)

#Enter Codes Scene
  li  r3,CodesSceneID
  branchl r12,MenuController_WriteToPendingMajor
#Change Major
  branchl r12,MenuController_ChangeScreenMajor

SnapPAL_LagPrompt_SceneDecide_Exit:
  restore
  blr
############################################
#endregion

#region SnapPAL_LagReductionGeckoCode
SnapPAL_LagReductionGeckoCode:
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
SnapPAL_LagPrompt_MinorSceneStruct:
blrl
#Lag Prompt
.byte 0                     #Minor Scene ID
.byte 00                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  SnapPAL_LagPrompt_SceneDecide   #SceneDecide
.byte PromptCommonSceneID   #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

SnapPAL_Codes_MinorSceneStruct:
blrl
#Codes Prompt
.byte 0                     #Minor Scene ID
.byte 00                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  SnapPAL_Codes_SceneDecide       #SceneDecide
.byte CodesCommonSceneID    #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

#endregion

SnapPAL_CheckProgressive:

#Check if progressive is enabled
  lis	r3,0xCC00
	lhz	r3,0x206E(r3)
	rlwinm.	r3,r3,0,0x1
  beq SnapPAL_NoProgressive

SnapPAL_IsProgressive:
#Override SceneLoad
  li  r3,PromptCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  SnapPAL_LagPrompt_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load LagPrompt
  li	r3, PromptSceneID
  b ExploitCodePAL_Exit
SnapPAL_NoProgressive:
#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  SnapPAL_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Load Codes
  li  r3,CodesSceneID

ExploitCodePAL_Exit:
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

MMLCodePAL_End:
blrl
#endregion

SnapshotCode_End:
blrl

ExitInjection:
#Exit
  restore
  blr

#region SnapshotBanner:
SnapshotBanner:
blrl
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x80,0x05,0x84,0x25,0x88,0x46,0x84,0x26,0x98,0xa6
.byte 0x84,0x25,0x84,0x46,0x88,0x46,0xc5,0xc6,0x84,0x25,0x84,0x25,0x9c,0xc6,0xb1,0x26
.byte 0x88,0x45,0xa0,0xe6,0xa5,0x06,0xa4,0xe6,0xc5,0xa6,0xb1,0x46,0xad,0x26,0xad,0x26
.byte 0x9c,0xc6,0x9c,0xc6,0x9c,0xc6,0x9c,0xc6,0xad,0x26,0xff,0x67,0xff,0x47,0xff,0x27
.byte 0xa4,0xe6,0xa9,0x06,0xa9,0x06,0xa9,0x06,0xad,0x26,0xad,0x26,0xad,0x26,0xad,0x26
.byte 0x9c,0xc6,0x9c,0xc6,0x9c,0xc6,0x90,0x85,0xff,0x27,0xff,0x47,0xff,0x67,0xd6,0x26
.byte 0xa5,0x06,0xa9,0x06,0xa4,0xe6,0xa4,0xe6,0xb1,0x46,0xb1,0x46,0xb1,0x46,0xb1,0x46
.byte 0x80,0x05,0x80,0x06,0x80,0x05,0x80,0x05,0x80,0x05,0x88,0x46,0x84,0x25,0x80,0x25
.byte 0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xa4,0xe6,0xb1,0x46,0xad,0x26,0xad,0x26,0xad,0x26
.byte 0x84,0x25,0x9c,0xc6,0x9c,0xc6,0x9c,0xc6,0x94,0x85,0xff,0x07,0xff,0x47,0xff,0x47
.byte 0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xa4,0xe6,0xad,0x26,0xad,0x26,0xb1,0x26,0xb1,0x46
.byte 0x9c,0xc6,0x9c,0xc6,0x88,0x45,0x80,0x05,0xff,0x47,0xff,0x47,0xf6,0xe7,0xa9,0x06
.byte 0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xa4,0xe6,0xb1,0x46,0xb5,0x46,0xb1,0x46,0xb1,0x46
.byte 0x80,0x05,0x80,0x26,0x80,0x05,0x80,0x05,0x80,0x05,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xa4,0xe6,0xb1,0x46,0xb5,0x46,0xb1,0x46,0xb1,0x46
.byte 0x80,0x05,0x80,0x26,0x80,0x05,0x80,0x05,0x84,0x25,0x88,0x46,0x84,0x26,0x8c,0x66
.byte 0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xa4,0xe6,0xad,0x26,0xad,0x26,0xb1,0x26,0xb1,0x46
.byte 0x94,0x85,0xa0,0xe6,0x8c,0x45,0x80,0x05,0xf2,0xc7,0xff,0x67,0xd6,0x06,0x80,0x05
.byte 0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xa4,0xe6,0xb1,0x46,0xb5,0x46,0xb1,0x46,0xb1,0x46
.byte 0x80,0x05,0x80,0x26,0x80,0x05,0x80,0x05,0x84,0x25,0x88,0x46,0x88,0x46,0x88,0x46
.byte 0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xa4,0xe6,0xb1,0x46,0xb5,0x46,0xb1,0x46,0xad,0x26
.byte 0x80,0x05,0x80,0x06,0x88,0x45,0x9c,0xc6,0x84,0x25,0x80,0x26,0xb1,0x46,0xff,0x87
.byte 0xa4,0xe6,0xa5,0x06,0xa5,0x06,0xa4,0xe6,0xb1,0x26,0xb5,0x46,0xb1,0x46,0xb1,0x46
.byte 0x8c,0x65,0x80,0x06,0x80,0x05,0x80,0x05,0xbd,0x86,0x80,0x06,0x88,0x46,0x88,0x46
.byte 0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xa4,0xe6,0xb1,0x46,0xb5,0x46,0xad,0x26,0xad,0x26
.byte 0x80,0x05,0x80,0x06,0x98,0xa6,0x9c,0xc6,0x84,0x26,0x88,0x46,0xea,0x87,0xff,0x67
.byte 0xa4,0xe6,0xa5,0x06,0xa5,0x06,0xa4,0xe6,0xb1,0x46,0xb5,0x46,0xb5,0x46,0xb1,0x26
.byte 0x84,0x25,0x80,0x05,0x80,0x05,0x8c,0x65,0xc1,0xa6,0x80,0x06,0x80,0x06,0xc1,0xa6
.byte 0xa4,0xe6,0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xad,0x26,0xb1,0x46,0xb5,0x46,0xb1,0x46
.byte 0x9c,0xc6,0x88,0x46,0x80,0x05,0x80,0x05,0xff,0x67,0xa4,0xe6,0x84,0x26,0x88,0x46
.byte 0xa4,0xe6,0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xb1,0x46,0xb1,0x46,0xb1,0x46,0xad,0x26
.byte 0x80,0x05,0x80,0x05,0x80,0x26,0x98,0xa6,0x84,0x26,0x84,0x26,0x8c,0x66,0xf6,0xe7
.byte 0xa4,0xe6,0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xad,0x26,0xb1,0x46,0xb5,0x46,0xb1,0x46
.byte 0x98,0xa6,0x80,0x05,0x80,0x06,0x80,0x05,0xee,0xc6,0x88,0x46,0x88,0x46,0x84,0x26
.byte 0xa4,0xe6,0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xb1,0x46,0xb1,0x46,0xb1,0x46,0xad,0x26
.byte 0x80,0x05,0x80,0x05,0x8c,0x66,0x9c,0xc6,0x84,0x25,0x80,0x05,0xbd,0x86,0xff,0x67
.byte 0xa4,0xe6,0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xad,0x26,0xb1,0x46,0xb5,0x46,0xb1,0x46
.byte 0x90,0x65,0x80,0x05,0x80,0x06,0x84,0x25,0xee,0xa7,0x88,0x45,0x80,0x26,0x94,0x85
.byte 0xa4,0xe6,0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xad,0x26,0xad,0x26,0xb5,0x46,0xb1,0x46
.byte 0x9c,0xc6,0x90,0x85,0x80,0x06,0x80,0x05,0xff,0x47,0xd2,0x06,0x80,0x06,0x84,0x25
.byte 0xa4,0xe6,0xa4,0xe6,0xa5,0x06,0xa4,0xe6,0xb1,0x46,0xb1,0x46,0xb1,0x46,0xb1,0x46
.byte 0x80,0x05,0x80,0x05,0x80,0x26,0x80,0x05,0x84,0x25,0x84,0x25,0x88,0x46,0x80,0x05
.byte 0xa4,0xe6,0xa4,0xe6,0xa9,0x06,0xa9,0x06,0xb1,0x46,0xad,0x26,0xad,0x26,0xa9,0x06
.byte 0x80,0x05,0x8c,0x65,0xb1,0x46,0xbd,0x86,0xb1,0x46,0xfb,0x07,0xff,0x47,0xfb,0x07
.byte 0xa9,0x06,0xa9,0x06,0xa5,0x06,0x90,0x66,0xad,0x26,0xb1,0x26,0xb5,0x46,0xc5,0xc6
.byte 0xad,0x26,0x88,0x45,0x80,0x05,0x84,0x25,0xff,0x47,0xf2,0xe7,0xa0,0xe6,0x80,0x05
.byte 0x80,0x05,0x84,0x26,0x88,0x46,0x84,0x25,0xa4,0xe6,0x80,0x26,0x88,0x46,0x88,0x46
.byte 0xc5,0xc6,0x94,0x86,0x84,0x25,0x84,0x25,0xa4,0xe6,0xb1,0x46,0x80,0x05,0x84,0x25
.byte 0x84,0x25,0x84,0x26,0xa0,0xe6,0xb1,0x26,0x84,0x25,0x84,0x26,0xa0,0xc6,0xb1,0x46
.byte 0x84,0x25,0x84,0x26,0xa0,0xe6,0xb1,0x46,0x84,0x25,0x84,0x26,0xa0,0xe6,0xb1,0x46
.byte 0x88,0x45,0xa0,0xe6,0xa0,0xc6,0xea,0x86,0x80,0x05,0x80,0x26,0x80,0x05,0xe2,0x66
.byte 0x80,0x05,0x88,0x46,0x84,0x26,0xe2,0x66,0x80,0x05,0x84,0x26,0x80,0x25,0xe2,0x66
.byte 0xff,0x07,0xa9,0x06,0xa0,0xc6,0x98,0xa6,0xff,0x07,0x90,0x66,0x80,0x06,0x84,0x26
.byte 0xff,0x07,0x90,0x86,0x84,0x25,0x84,0x25,0xff,0x07,0x90,0x86,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x88,0x46,0x88,0x46,0x88,0x46,0x84,0x26
.byte 0x84,0x25,0x84,0x26,0x84,0x25,0x80,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x80,0x25
.byte 0x94,0x86,0xff,0x27,0xe6,0x87,0x9c,0xc6,0x94,0x86,0xff,0x27,0xda,0x26,0x80,0x05
.byte 0x94,0x85,0xff,0x27,0xea,0xa6,0xb1,0x46,0x94,0x85,0xfb,0x07,0xff,0x27,0xff,0x27
.byte 0x9c,0xc6,0xb5,0x66,0xff,0x27,0xee,0xc7,0x80,0x05,0x80,0x05,0xee,0xa7,0xfb,0x07
.byte 0xb1,0x46,0xc5,0xc6,0xfb,0x27,0xcd,0xe6,0xff,0x27,0xff,0x47,0xf7,0x07,0x9c,0xc6
.byte 0x88,0x46,0x88,0x46,0x88,0x46,0x88,0x46,0x8c,0x65,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0x80,0x05,0x84,0x26,0x84,0x25,0x84,0x25,0x80,0x05,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x88,0x46,0x80,0x06,0xad,0x26,0x84,0x25,0x84,0x26,0x80,0x05,0xda,0x26
.byte 0x84,0x25,0x84,0x26,0x90,0x65,0xfb,0x07,0x84,0x25,0x80,0x06,0xb5,0x46,0xff,0x67
.byte 0xff,0x47,0xff,0x27,0xf6,0xe7,0x90,0x66,0xf6,0xe7,0xcd,0xe6,0xff,0x47,0xb1,0x26
.byte 0xda,0x26,0x94,0x86,0xff,0x27,0xda,0x46,0xb5,0x66,0x84,0x26,0xea,0x86,0xfb,0x07
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x80,0x05,0x84,0x26,0x84,0x25,0x84,0x25
.byte 0x80,0x05,0x84,0x26,0x84,0x25,0x84,0x25,0x94,0x85,0x84,0x26,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x80,0x05,0xb1,0x26,0xff,0x67,0x84,0x25,0x80,0x05,0xad,0x26,0xff,0x67
.byte 0x84,0x25,0x80,0x06,0xb1,0x26,0xff,0x67,0x84,0x25,0x80,0x06,0xb1,0x26,0xff,0x67
.byte 0xbd,0x86,0x80,0x05,0x84,0x25,0x84,0x25,0xbd,0x86,0x80,0x05,0x84,0x25,0x84,0x25
.byte 0xbd,0x86,0x80,0x06,0x84,0x25,0x84,0x25,0xbd,0x86,0x80,0x06,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0xe6,0x86,0xff,0x47,0x84,0x25,0x84,0x25,0xe6,0x87,0xf6,0xe7
.byte 0x84,0x25,0x84,0x26,0xea,0x87,0xea,0xa6,0x84,0x25,0x84,0x26,0xea,0x87,0xee,0xc7
.byte 0xfb,0x07,0x94,0x86,0x80,0x05,0xbd,0x86,0xfb,0x07,0xd6,0x26,0x80,0x05,0xbd,0x86
.byte 0xbd,0x86,0xff,0x47,0x9c,0xa6,0xb9,0x66,0x88,0x45,0xea,0xa6,0xe2,0x66,0xbd,0x86
.byte 0xff,0x47,0xa0,0xe6,0x80,0x05,0x84,0x25,0xff,0x47,0xa0,0xe6,0x80,0x05,0x84,0x25
.byte 0xff,0x47,0xa0,0xe6,0x80,0x25,0x84,0x25,0xff,0x47,0xa0,0xe6,0x80,0x26,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x8c,0x66,0xf6,0xe7,0x84,0x25,0x84,0x25,0x8c,0x46,0xf2,0xc7
.byte 0x84,0x25,0x84,0x25,0x8c,0x46,0xf2,0xc7,0x84,0x25,0x84,0x25,0x8c,0x66,0xf2,0xc7
.byte 0xee,0xa6,0x88,0x46,0x84,0x26,0x84,0x26,0xea,0xa6,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0xea,0xa6,0x84,0x25,0x84,0x26,0x84,0x25,0xea,0xa6,0x88,0x25,0x84,0x26,0x84,0x25
.byte 0x84,0x26,0x80,0x05,0xb9,0x66,0xff,0x47,0x84,0x25,0x80,0x05,0xb9,0x66,0xff,0x27
.byte 0x84,0x25,0x80,0x05,0xb9,0x66,0xff,0x47,0x84,0x25,0x80,0x05,0xb9,0x66,0xff,0x67
.byte 0xff,0x47,0xc1,0xa6,0x80,0x06,0x94,0x86,0xee,0xc7,0xfb,0x07,0x90,0x66,0x90,0x65
.byte 0xb5,0x46,0xf6,0xe7,0xd2,0x06,0x8c,0x65,0xa0,0xe6,0xb5,0x46,0xff,0x47,0xb1,0x26
.byte 0xff,0x27,0xd2,0x06,0x80,0x26,0x88,0x46,0xff,0x27,0xd2,0x06,0x80,0x05,0x84,0x25
.byte 0xff,0x27,0xd2,0x06,0x80,0x05,0x84,0x25,0xfb,0x07,0xd2,0x06,0x80,0x06,0x84,0x25
.byte 0x88,0x46,0x84,0x26,0x84,0x26,0x9c,0xc6,0x84,0x25,0x84,0x25,0x80,0x06,0xcd,0xe6
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0xe6,0x66,0x84,0x25,0x84,0x25,0x84,0x26,0xe6,0x86
.byte 0xff,0x27,0xee,0xc7,0xa0,0xc6,0x88,0x45,0xff,0x67,0xad,0x06,0x80,0x06,0x84,0x26
.byte 0xff,0x07,0x90,0x85,0x80,0x25,0x8c,0x65,0xfb,0x07,0x90,0x65,0x80,0x05,0xb5,0x66
.byte 0xa9,0x06,0xff,0x27,0xf6,0xe7,0x88,0x45,0x80,0x05,0xa4,0xe6,0xb9,0x66,0x8c,0x46
.byte 0x98,0xa6,0x94,0x86,0x94,0x86,0x84,0x26,0xff,0x67,0xff,0x27,0xff,0x27,0x9c,0xa6
.byte 0x9c,0xc6,0xb1,0x46,0x80,0x26,0x84,0x25,0xa0,0xc6,0xb1,0x46,0x80,0x26,0x84,0x25
.byte 0xa0,0xc6,0xb1,0x46,0x84,0x26,0x88,0x46,0x9c,0xa6,0xb1,0x46,0x80,0x05,0x84,0x25
.byte 0x84,0x25,0x80,0x25,0xa0,0xc6,0xb1,0x46,0x84,0x25,0x84,0x26,0xa0,0xc6,0xb1,0x46
.byte 0x84,0x25,0x84,0x26,0xa0,0xc6,0xb1,0x46,0x84,0x25,0x84,0x26,0xa0,0xe6,0xb1,0x46
.byte 0x80,0x05,0x84,0x26,0x84,0x25,0xe2,0x66,0x80,0x05,0x88,0x46,0x84,0x25,0xe2,0x66
.byte 0x80,0x05,0x88,0x46,0x84,0x26,0xea,0x86,0x80,0x05,0x84,0x26,0x84,0x26,0xad,0x26
.byte 0xff,0x07,0x90,0x86,0x84,0x25,0x84,0x25,0xff,0x07,0x90,0x86,0x84,0x25,0x84,0x25
.byte 0xff,0x47,0x94,0x86,0x84,0x26,0x84,0x26,0xb9,0x66,0x8c,0x66,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x80,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x80,0x25
.byte 0x84,0x26,0x88,0x46,0x88,0x46,0x84,0x26,0x84,0x25,0x84,0x26,0x84,0x25,0x84,0x25
.byte 0x94,0x85,0xff,0x27,0xde,0x66,0x8c,0x65,0x94,0x85,0xff,0x27,0xda,0x46,0x80,0x05
.byte 0x94,0x86,0xff,0x47,0xe2,0x66,0x80,0x26,0x8c,0x45,0xb9,0x86,0xa9,0x06,0x80,0x05
.byte 0x8c,0x65,0xb9,0x66,0xff,0x47,0xd6,0x26,0x80,0x05,0x94,0xa6,0xff,0x27,0xe2,0x66
.byte 0x80,0x25,0x94,0xa6,0xff,0x47,0xee,0xa7,0x80,0x05,0x84,0x26,0xb5,0x46,0xb9,0x66
.byte 0x80,0x05,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x88,0x46,0x84,0x26
.byte 0x84,0x25,0x84,0x26,0x84,0x25,0x84,0x25,0x8c,0x45,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x84,0x26,0xde,0x46,0xff,0x47,0x80,0x25,0x98,0xa6,0xfb,0x27,0xea,0xa7
.byte 0x80,0x05,0xc5,0xa6,0xff,0xa7,0xb5,0x66,0x84,0x25,0xa9,0x06,0xb9,0x86,0x8c,0x65
.byte 0xfb,0x07,0xf6,0xe7,0xff,0x27,0xff,0x47,0xc1,0xa6,0xc5,0xc6,0xcd,0xe6,0xff,0x27
.byte 0x80,0x05,0x80,0x05,0x80,0x05,0xee,0xc7,0x80,0x25,0x84,0x26,0x80,0x25,0xa4,0xe6
.byte 0xb5,0x66,0x80,0x06,0x84,0x25,0x84,0x25,0xe2,0x66,0x84,0x26,0x88,0x46,0x88,0x46
.byte 0xff,0x47,0x9c,0xc6,0x80,0x05,0x84,0x25,0xb9,0x86,0x98,0xa6,0x80,0x25,0x84,0x25
.byte 0x84,0x25,0x80,0x06,0xb1,0x26,0xff,0x67,0x84,0x26,0x80,0x26,0xb1,0x46,0xff,0x67
.byte 0x84,0x25,0x80,0x05,0xb1,0x46,0xff,0x87,0x84,0x25,0x80,0x25,0x94,0x86,0xb9,0x86
.byte 0xbd,0x86,0x80,0x06,0x84,0x25,0x84,0x25,0xbd,0x86,0x80,0x06,0x88,0x46,0x88,0x46
.byte 0xc1,0x86,0x80,0x05,0x84,0x25,0x84,0x25,0x9c,0xc6,0x80,0x25,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x84,0x26,0xea,0x87,0xf2,0xc7,0x84,0x25,0x88,0x46,0xea,0xa7,0xf2,0xc7
.byte 0x84,0x25,0x84,0x25,0xee,0xc7,0xf6,0xe7,0x84,0x25,0x84,0x25,0xa9,0x06,0xb1,0x26
.byte 0x80,0x25,0xa5,0x06,0xff,0x27,0xea,0xa6,0x88,0x46,0x80,0x06,0xda,0x26,0xff,0x47
.byte 0x88,0x45,0x80,0x05,0x98,0xa6,0xff,0x27,0x84,0x25,0x84,0x25,0x80,0x05,0xa9,0x06
.byte 0xff,0x27,0xa0,0xe6,0x80,0x26,0x84,0x25,0xff,0x27,0xa0,0xe6,0x84,0x26,0x88,0x46
.byte 0xff,0x67,0xa0,0xe6,0x80,0x05,0x84,0x25,0xb9,0x66,0x90,0x66,0x80,0x25,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x8c,0x66,0xf2,0xc7,0x84,0x26,0x84,0x26,0x8c,0x66,0xf6,0xe7
.byte 0x84,0x25,0x84,0x25,0x8c,0x66,0xfb,0x07,0x84,0x25,0x80,0x25,0x84,0x25,0xb1,0x46
.byte 0xea,0xa6,0x88,0x25,0x84,0x26,0x84,0x25,0xea,0xa6,0x88,0x46,0x88,0x46,0x88,0x46
.byte 0xf2,0xc7,0x84,0x25,0x84,0x25,0x84,0x25,0xad,0x26,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x80,0x05,0xb9,0x66,0xff,0x67,0x88,0x46,0x80,0x06,0xb9,0x86,0xff,0x67
.byte 0x84,0x25,0x80,0x05,0xbd,0x86,0xff,0x87,0x84,0x25,0x80,0x05,0x98,0xa6,0xb9,0x86
.byte 0xa9,0x06,0x80,0x05,0xee,0xa7,0xf2,0xc7,0xad,0x26,0x80,0x05,0xad,0x26,0xff,0x47
.byte 0xad,0x26,0x80,0x05,0x80,0x26,0xda,0x46,0x90,0x85,0x80,0x05,0x80,0x05,0x90,0x85
.byte 0xff,0x27,0xcd,0xe6,0x80,0x06,0x84,0x25,0xff,0x47,0xcd,0xe6,0x80,0x06,0x84,0x26
.byte 0xff,0x87,0xd2,0x06,0x80,0x06,0x88,0x46,0xb9,0x86,0xa0,0xe6,0x80,0x05,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x80,0x26,0xda,0x26,0x84,0x25,0x84,0x25,0x80,0x26,0xad,0x26
.byte 0x84,0x26,0x84,0x25,0x88,0x46,0x84,0x26,0x84,0x25,0x84,0x25,0x84,0x26,0x80,0x05
.byte 0xff,0x47,0x9c,0xc6,0x80,0x06,0x94,0x85,0xff,0x67,0xde,0x46,0x8c,0x66,0x80,0x05
.byte 0xcd,0xe6,0xff,0x67,0xfb,0x07,0xe6,0x86,0x80,0x05,0xa9,0x06,0xd2,0x06,0xda,0x26
.byte 0xa4,0xe6,0xd6,0x06,0xff,0x47,0x9c,0xa6,0x90,0x65,0xee,0xa7,0xff,0x27,0x98,0xa6
.byte 0xff,0x07,0xe6,0x87,0xff,0x27,0x98,0xa6,0xb5,0x46,0x88,0x45,0xb1,0x46,0xb1,0x46
.byte 0x98,0xa6,0xb1,0x46,0x80,0x05,0x84,0x25,0x9c,0xc6,0xb1,0x46,0x80,0x26,0x84,0x25
.byte 0xb5,0x46,0xa0,0xe6,0x84,0x26,0x84,0x25,0xc1,0xa6,0x84,0x25,0x88,0x46,0x88,0x46
.byte 0x84,0x25,0x80,0x25,0xa0,0xc6,0xb1,0x46,0x84,0x25,0x80,0x25,0xa0,0xc6,0xad,0x26
.byte 0x84,0x25,0x84,0x26,0xa0,0xc6,0xad,0x26,0x84,0x25,0x84,0x26,0xa0,0xc6,0xad,0x26
.byte 0x80,0x05,0x88,0x46,0x84,0x25,0x80,0x05,0xc1,0x86,0xee,0xc7,0xea,0x86,0x94,0x85
.byte 0xcd,0xe6,0xff,0x47,0xff,0x47,0xa9,0x06,0xcd,0xe6,0xfb,0x07,0xf2,0xc7,0xc9,0xc6
.byte 0x80,0x05,0x84,0x26,0x84,0x25,0x88,0x45,0x80,0x05,0x8c,0x66,0xe2,0x66,0xee,0xe7
.byte 0x80,0x05,0xa0,0xe6,0xff,0x27,0xff,0x47,0x80,0x05,0xbd,0x86,0xf6,0xe7,0xf6,0xe7
.byte 0x84,0x25,0x84,0x26,0x84,0x25,0x84,0x25,0xcd,0xe6,0x84,0x26,0x84,0x25,0x84,0x25
.byte 0xda,0x46,0x84,0x26,0x84,0x25,0x84,0x25,0xda,0x46,0x84,0x26,0x84,0x26,0x80,0x05
.byte 0x84,0x25,0x80,0x05,0x80,0x05,0x90,0x85,0x80,0x05,0x94,0x86,0xda,0x46,0xff,0x27
.byte 0x8c,0x45,0xea,0xa6,0xff,0x47,0xc9,0xc6,0xb5,0x66,0xff,0x67,0xc9,0xc6,0x80,0x05
.byte 0x98,0xa6,0x90,0x86,0x80,0x05,0x80,0x05,0xff,0x47,0xff,0x27,0xd6,0x26,0x8c,0x65
.byte 0xa9,0x06,0xd2,0x06,0xff,0x67,0xe2,0x66,0x80,0x05,0x80,0x06,0xd6,0x06,0xff,0x67
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x80,0x25,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x84,0x26,0x84,0x25,0x84,0x25,0xad,0x06,0x80,0x26,0x88,0x46,0x88,0x46
.byte 0x84,0x25,0x84,0x26,0x80,0x05,0x84,0x25,0x80,0x05,0xc9,0xc6,0xee,0xc7,0xf2,0xc7
.byte 0x80,0x05,0xda,0x26,0xff,0x47,0xd6,0x06,0x80,0x05,0xd6,0x26,0xff,0x27,0x90,0x86
.byte 0x88,0x45,0x88,0x46,0x80,0x05,0x80,0x05,0xf6,0xe7,0xf2,0xc7,0xd6,0x26,0x94,0x86
.byte 0xc9,0xc6,0xda,0x26,0xff,0x47,0xee,0xa6,0x80,0x05,0x80,0x06,0xc5,0xa6,0xff,0x67
.byte 0x80,0x05,0x84,0x26,0x84,0x25,0x84,0x25,0x80,0x05,0x88,0x46,0x84,0x25,0x80,0x05
.byte 0x8c,0x45,0x84,0x26,0x84,0x25,0x80,0x05,0xb9,0x66,0x80,0x06,0x88,0x46,0x80,0x06
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x80,0x05,0xa5,0x06,0xee,0xc7,0xf2,0xc7,0xf6,0xe7
.byte 0xad,0x26,0xff,0x67,0xe6,0x86,0xc9,0xc6,0xad,0x26,0xff,0x67,0xb5,0x46,0x80,0x05
.byte 0x84,0x25,0x88,0x46,0x88,0x45,0x84,0x25,0xf2,0xc7,0xf6,0xe7,0xea,0xa6,0x8c,0x65
.byte 0xcd,0xe6,0xcd,0xe6,0xc9,0xc6,0x88,0x45,0x80,0x05,0x80,0x06,0x80,0x06,0x80,0x26
.byte 0x84,0x25,0x88,0x46,0xad,0x26,0xb9,0x66,0x84,0x25,0xc1,0xa6,0xa9,0x06,0x8c,0x65
.byte 0x9c,0xa6,0xb9,0x86,0x80,0x06,0x84,0x25,0xa0,0xe6,0xb5,0x46,0x80,0x26,0x88,0x46
.byte 0xbd,0x86,0xc1,0x86,0xc1,0x86,0xb9,0x66,0x8c,0x65,0x8c,0x66,0x8c,0x66,0x8c,0x65
.byte 0x84,0x25,0x84,0x26,0x84,0x26,0x84,0x25,0x84,0x25,0x88,0x46,0x88,0x46,0x88,0x46
.byte 0xb9,0x66,0xbd,0x86,0xc1,0xa6,0xbd,0x86,0x8c,0x65,0x8c,0x66,0x8c,0x66,0x8c,0x65
.byte 0x84,0x25,0x84,0x25,0x84,0x46,0x84,0x25,0x88,0x46,0x88,0x46,0x88,0x46,0x88,0x46
.byte 0xbd,0x86,0xc1,0x86,0xc1,0x86,0xb9,0x66,0x8c,0x65,0x8c,0x66,0x8c,0x66,0x8c,0x65
.byte 0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x8c,0x67,0x88,0x46,0x88,0x46,0x88,0x46
.byte 0xb9,0x66,0xbd,0x86,0xc1,0x86,0xbd,0x86,0x8c,0x65,0x8c,0x66,0x8c,0x66,0x8c,0x65
.byte 0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x88,0x46,0x88,0x46,0x88,0x46,0x88,0x46
.byte 0xbd,0x86,0xc1,0x86,0xbd,0x86,0xb9,0x66,0x8c,0x65,0x8c,0x66,0x90,0x66,0x8c,0x65
.byte 0x84,0x25,0x84,0x25,0x84,0x46,0x84,0x25,0x88,0x46,0x84,0x26,0x88,0x46,0x8c,0x66
.byte 0xbd,0x86,0xc1,0x86,0xc1,0xa6,0xbd,0x86,0x8c,0x65,0x8c,0x65,0x90,0x66,0x8c,0x65
.byte 0x84,0x25,0x84,0x25,0x84,0x46,0x84,0x25,0x88,0x46,0x84,0x25,0x88,0x46,0x88,0x46
.byte 0xb9,0x66,0xb9,0x66,0xc1,0xa6,0xbd,0x86,0x8c,0x65,0x8c,0x65,0x90,0x66,0x8c,0x65
.byte 0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x88,0x46,0x84,0x25,0x88,0x46,0x88,0x46
.byte 0xbd,0x86,0xbd,0x86,0xc1,0x86,0xbd,0x86,0x8c,0x65,0x8c,0x65,0x90,0x66,0x8c,0x65
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x8c,0x67,0x8c,0x67
.byte 0xbd,0x86,0xb9,0x66,0xb9,0x66,0xb9,0x66,0x8c,0x65,0x8c,0x65,0x8c,0x66,0x8c,0x65
.byte 0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x8c,0x67,0x88,0x46,0x88,0x46,0x88,0x46
.byte 0xb9,0x66,0xbd,0x86,0xb9,0x86,0xbd,0x86,0x8c,0x65,0x8c,0x65,0x8c,0x66,0x80,0x05
.byte 0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x84,0x26,0x84,0x25,0x88,0x46,0x88,0x46
.byte 0x88,0x45,0x84,0x25,0x84,0x26,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x26,0x88,0x46,0x84,0x25
.byte 0x84,0x26,0x84,0x26,0xa0,0xe6,0xad,0x26,0x84,0x25,0x84,0x25,0xa0,0xc6,0xad,0x26
.byte 0x84,0x25,0x84,0x26,0xa0,0xc6,0xad,0x26,0x84,0x25,0x84,0x26,0xa0,0xc6,0xa9,0x06
.byte 0xcd,0xe6,0xf6,0xe7,0xd6,0x26,0xe6,0x86,0xcd,0xe6,0xf6,0xe7,0xb9,0x66,0xf6,0xe7
.byte 0xcd,0xe6,0xfb,0x07,0xa0,0xe6,0xf6,0xe7,0xcd,0xe6,0xfb,0x07,0x90,0x65,0xe6,0x86
.byte 0x80,0x05,0xda,0x26,0xda,0x46,0xee,0xc7,0x90,0x65,0xee,0xa6,0xbd,0x86,0xee,0xc7
.byte 0xb9,0x66,0xf6,0xe7,0xa0,0xe6,0xf2,0xc7,0xee,0xc7,0xea,0xa6,0x90,0x65,0xf6,0xe7
.byte 0xda,0x46,0x80,0x26,0x84,0x25,0x80,0x05,0xda,0x46,0x80,0x25,0x84,0x25,0x80,0x05
.byte 0xda,0x46,0x80,0x26,0x84,0x25,0x80,0x05,0xda,0x46,0x84,0x26,0x84,0x25,0x80,0x05
.byte 0xd2,0x06,0xff,0x47,0x9c,0xc6,0x80,0x05,0xda,0x26,0xff,0x27,0x94,0x86,0x80,0x05
.byte 0xd2,0x06,0xff,0x47,0xa0,0xc6,0x80,0x05,0xb1,0x26,0xff,0x67,0xcd,0xe6,0x80,0x05
.byte 0x84,0x25,0x80,0x05,0xa9,0x06,0xff,0x67,0x84,0x25,0x80,0x05,0xa0,0xe6,0xff,0x47
.byte 0x84,0x25,0x80,0x06,0xad,0x26,0xff,0x67,0x80,0x05,0x80,0x26,0xda,0x46,0xff,0x67
.byte 0xc5,0xc6,0x80,0x05,0x84,0x25,0x84,0x25,0xcd,0xe6,0x80,0x05,0x84,0x25,0x84,0x25
.byte 0xc5,0xa6,0x80,0x06,0x84,0x25,0x84,0x25,0xa4,0xe6,0x80,0x26,0x84,0x25,0x84,0x25
.byte 0x80,0x05,0xd6,0x26,0xff,0x27,0x98,0xa6,0x80,0x05,0xd6,0x26,0xff,0x27,0x98,0xa6
.byte 0x80,0x05,0xd6,0x26,0xff,0x27,0x98,0xa6,0x80,0x05,0xd6,0x26,0xff,0x27,0x90,0x86
.byte 0x80,0x05,0x80,0x05,0xa0,0xc6,0xff,0x47,0x80,0x05,0x80,0x25,0x9c,0xc6,0xff,0x47
.byte 0x80,0x05,0x80,0x06,0xa9,0x06,0xff,0x67,0x80,0x05,0x84,0x26,0xda,0x46,0xff,0x67
.byte 0xd2,0x06,0x80,0x05,0x84,0x25,0x80,0x05,0xd6,0x26,0x80,0x05,0x84,0x25,0x80,0x05
.byte 0xc9,0xc6,0x80,0x06,0x84,0x25,0x80,0x05,0xa5,0x06,0x80,0x26,0x84,0x25,0x80,0x05
.byte 0xad,0x26,0xff,0x47,0xe2,0x66,0xc5,0xa6,0xad,0x26,0xff,0x47,0xfb,0x07,0xf6,0xe7
.byte 0xad,0x26,0xff,0x67,0xbd,0x86,0x84,0x25,0xad,0x26,0xff,0x67,0xb9,0x66,0x80,0x05
.byte 0xc5,0xc6,0xc9,0xe6,0xb1,0x26,0x80,0x05,0xf6,0xe7,0xfb,0x07,0xcd,0xe6,0x80,0x05
.byte 0x88,0x45,0x88,0x46,0x88,0x45,0x80,0x05,0x80,0x05,0x80,0x05,0x80,0x05,0x80,0x05
.byte 0xa0,0xc6,0xb5,0x46,0x80,0x05,0x84,0x25,0xa0,0xc6,0xb5,0x46,0x80,0x05,0x84,0x25
.byte 0xa0,0xc6,0xb5,0x46,0x80,0x05,0x84,0x25,0xa0,0xc6,0xb5,0x66,0x80,0x05,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x90,0x88,0x84,0x25,0x84,0x25,0x80,0x05,0x9c,0xea
.byte 0x84,0x25,0x84,0x26,0x84,0x25,0xa9,0x4d,0x84,0x25,0x84,0x25,0x84,0x25,0xb5,0xaf
.byte 0xc2,0x11,0xa9,0x4d,0x80,0x04,0xa1,0x0b,0xc2,0x11,0xad,0x6d,0x88,0x46,0xb5,0xaf
.byte 0xb5,0xae,0xa9,0x4c,0x9c,0xea,0xb1,0x8e,0xa5,0x2c,0xad,0x6d,0xad,0x6d,0xa9,0x4c
.byte 0xc2,0x11,0x98,0xc9,0x84,0x25,0x80,0x05,0xbd,0xf1,0x90,0x87,0x84,0x25,0x98,0xc9
.byte 0xb5,0xaf,0x84,0x25,0x94,0xa8,0xb1,0x8e,0xb1,0x8e,0x80,0x05,0x98,0xc9,0xa9,0x4c
.byte 0x80,0x05,0x84,0x25,0x84,0x25,0x84,0x25,0xad,0x6d,0x9c,0xea,0x88,0x46,0x80,0x05
.byte 0xa9,0x4c,0xc2,0x11,0x90,0x87,0x90,0x88,0xa9,0x4c,0xbd,0xf0,0x88,0x46,0xb1,0x8e
.byte 0x84,0x25,0x80,0x04,0x8c,0x67,0xb9,0xcf,0x94,0xa8,0xa9,0x4c,0xa5,0x2b,0xb9,0xcf
.byte 0xc2,0x11,0xb1,0x8e,0xc2,0x11,0xad,0x6d,0xa5,0x2c,0x80,0x03,0xb1,0x8e,0xa1,0x0a
.byte 0x8c,0x67,0x84,0x25,0x84,0x25,0x80,0x05,0x84,0x25,0x88,0x46,0xa5,0x2b,0xa9,0x4c
.byte 0x80,0x05,0xb1,0x8e,0xb1,0x8e,0xb5,0xaf,0x90,0x88,0xbd,0xf0,0x9c,0xea,0x9c,0xea
.byte 0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x90,0x87,0x84,0x25,0x84,0x26,0x84,0x25
.byte 0xb5,0xaf,0x84,0x25,0x88,0x46,0x84,0x25,0xa1,0x0b,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x84,0x25,0x88,0x46,0xb9,0xcf,0xc2,0x11,0x84,0x25,0x94,0xa8,0xbd,0xf0,0x90,0x88
.byte 0x80,0x05,0x9c,0xea,0xc2,0x11,0xa9,0x4c,0x80,0x05,0xad,0x6d,0xb9,0xcf,0xa5,0x2c
.byte 0xc2,0x11,0xb9,0xcf,0x90,0x88,0x84,0x25,0x90,0x88,0xc2,0x11,0x98,0xc9,0x8c,0x66
.byte 0xad,0x6d,0xb5,0xae,0x88,0x46,0x90,0x87,0xb5,0xae,0xb9,0xcf,0x88,0x46,0x88,0x46
.byte 0x80,0x05,0x84,0x25,0x84,0x25,0x84,0x25,0xa5,0x2b,0x84,0x25,0x94,0xa8,0xa1,0x0b
.byte 0xc2,0x11,0x8c,0x66,0xb5,0xae,0xa1,0x0b,0xb9,0xcf,0xa1,0x0b,0xb5,0xae,0x84,0x25
.byte 0x88,0x46,0x84,0x25,0x88,0x46,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25
.byte 0x80,0x05,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x84,0x25,0x84,0x26,0xa0,0xc6,0xad,0x26,0x84,0x25,0x84,0x26,0x8c,0x66,0xc1,0xa6
.byte 0x84,0x25,0x84,0x26,0x80,0x05,0xa4,0xe6,0x84,0x25,0x88,0x46,0x84,0x25,0x80,0x05
.byte 0xcd,0xe6,0xff,0x27,0x8c,0x66,0xd2,0x06,0xc1,0xa6,0xda,0x46,0x84,0x25,0xa9,0x06
.byte 0xc5,0xa6,0xa0,0xe6,0xa0,0xc6,0x9c,0xc6,0x94,0x86,0xb1,0x26,0xb5,0x46,0xb1,0x46
.byte 0xff,0x87,0xda,0x26,0x88,0x46,0xfb,0x07,0xde,0x86,0xad,0x26,0x80,0x25,0xda,0x26
.byte 0x9c,0xc6,0x9c,0xc6,0xa0,0xc6,0x9c,0xc6,0xb1,0x46,0xb1,0x46,0xb1,0x46,0xb1,0x46
.byte 0xde,0x66,0x84,0x26,0x84,0x26,0x84,0x25,0xc1,0xa6,0x80,0x06,0x80,0x25,0x80,0x25
.byte 0x9c,0xc6,0xa0,0xe6,0xa0,0xc6,0xa0,0xe6,0xb1,0x46,0xb5,0x46,0xb1,0x46,0xb1,0x46
.byte 0x88,0x25,0xe2,0x67,0xff,0x67,0xd6,0x26,0x80,0x05,0x8c,0x46,0xc9,0xe6,0xf2,0xc7
.byte 0xa0,0xe6,0xa0,0xc6,0x9c,0xa6,0xa5,0x06,0xb1,0x46,0xb5,0x46,0xb1,0x46,0xb1,0x46
.byte 0xb9,0x66,0xde,0x46,0xff,0x67,0xda,0x26,0xfb,0x07,0xf2,0xc7,0xc5,0xa6,0x84,0x25
.byte 0xa9,0x26,0xa5,0x06,0x9c,0xa6,0xa0,0xc6,0xb1,0x46,0xb1,0x46,0xb1,0x46,0xb1,0x46
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x80,0x05,0x84,0x26,0x84,0x26,0x80,0x25
.byte 0xa0,0xe6,0xa0,0xe6,0xa0,0xc6,0xa0,0xc6,0xb1,0x46,0xb5,0x46,0xb1,0x46,0xb1,0x46
.byte 0x80,0x05,0xda,0x26,0xff,0x67,0xe2,0x66,0x80,0x05,0xbd,0x86,0xde,0x66,0xe2,0x66
.byte 0xa0,0xe6,0xa0,0xc6,0x9c,0xc6,0x9c,0xc6,0xb1,0x46,0xb5,0x46,0xb1,0x46,0xb1,0x46
.byte 0xda,0x26,0xea,0xa7,0xff,0x67,0xda,0x26,0xe6,0x86,0xe2,0x66,0xbd,0x86,0x84,0x26
.byte 0x9c,0xc6,0x9c,0xc6,0x98,0xa5,0xa0,0xc6,0xb1,0x46,0xb1,0x46,0xb1,0x46,0xb1,0x46
.byte 0x84,0x25,0x88,0x46,0x84,0x26,0x80,0x05,0x80,0x05,0x84,0x26,0x84,0x26,0x80,0x05
.byte 0xa0,0xe6,0xa0,0xe6,0xa0,0xc6,0xa0,0xe6,0xb1,0x46,0xb5,0x46,0xb1,0x46,0xb1,0x46
.byte 0xad,0x26,0xff,0x67,0xee,0xa7,0xda,0x26,0xa0,0xc6,0xde,0x66,0xe2,0x66,0xe6,0x86
.byte 0xa0,0xc6,0x9c,0xc6,0x9c,0xc6,0x9c,0xc6,0xb1,0x46,0xb5,0x46,0xb1,0x46,0xb1,0x46
.byte 0xda,0x46,0xde,0x46,0xde,0x46,0x94,0x86,0xe6,0x66,0xe6,0x86,0xe6,0x86,0x94,0xa6
.byte 0x9c,0xc6,0x9c,0xc6,0x9c,0xc6,0xbd,0x86,0xb1,0x46,0xb5,0x46,0xb1,0x46,0x9c,0xc6
.byte 0x9c,0xc6,0xb5,0x46,0x80,0x06,0x84,0x25,0xbd,0x86,0xa0,0xc6,0x84,0x26,0x88,0x46
.byte 0xb5,0x66,0x80,0x25,0x84,0x25,0x84,0x25,0x80,0x05,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x8c,0x67,0xbd,0xf0,0x84,0x26,0x84,0x25,0x94,0xa8,0xad,0x6d
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0x98,0xc9,0xc2,0x11,0xa5,0x2c,0xad,0x6d,0x8c,0x67,0xb1,0x8e,0x90,0x88,0xa9,0x4c
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0xa5,0x2c,0x84,0x25,0xbd,0xf0,0x9c,0xea,0x94,0xa8,0x84,0x25,0xa9,0x4c,0xa9,0x4c
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0xa9,0x4c,0xb5,0xaf,0x84,0x25,0xb5,0xaf,0xa9,0x4c,0xa5,0x2c,0x84,0x25,0x98,0xc9
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0xa9,0x4d,0x98,0xc9,0xc2,0x11,0x90,0x88,0xb5,0xaf,0xa9,0x4c,0xad,0x6d,0x88,0x46
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25
.byte 0x98,0xc9,0xbd,0xf0,0x94,0xa9,0x9c,0xea,0x88,0x46,0xa9,0x4c,0xb5,0xaf,0xa5,0x2c
.byte 0x84,0x25,0x80,0x05,0x84,0x25,0x80,0x05,0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25
.byte 0x8c,0x67,0x84,0x25,0x88,0x46,0x84,0x25,0x88,0x46,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x84,0x25,0xb9,0xd0,0xb1,0x8e,0x98,0xc9,0x88,0x46,0xb1,0x8e,0xb5,0xaf,0xb9,0xcf
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25
.byte 0xb1,0x8e,0xb9,0xcf,0x88,0x46,0x88,0x46,0xad,0x6d,0x8c,0x67,0x84,0x25,0x80,0x05
.byte 0x80,0x05,0x84,0x25,0x84,0x25,0x9c,0xea,0x84,0x25,0x84,0x25,0x88,0x46,0xa1,0x0a
.byte 0xb5,0xaf,0xc2,0x11,0x98,0xc9,0x84,0x25,0xb1,0x8e,0xb1,0x8e,0x84,0x25,0x84,0x25
.byte 0xb9,0xcf,0x90,0x87,0x84,0x25,0x84,0x25,0x94,0xa8,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x84,0x26,0x84,0x25,0x88,0x46,0x88,0x46,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x26
.byte 0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x26,0x88,0x46,0x88,0x46,0x84,0x25
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x80,0x04
.byte 0x80,0x05,0xb5,0xaf,0xa9,0x6e,0x80,0x04,0x88,0x46,0xd2,0x95,0xad,0x6d,0x80,0x04
.byte 0x98,0xc9,0xd6,0xb5,0x98,0xc9,0x80,0x04,0xa9,0x4c,0xd2,0x94,0x88,0x46,0x80,0x04
.byte 0x80,0x05,0xb9,0xd1,0xa1,0x2c,0x80,0x05,0x90,0x87,0xda,0xd6,0xa1,0x0b,0x80,0x05
.byte 0xa1,0x0b,0xd6,0xb5,0x90,0x88,0x84,0x25,0xb1,0x8e,0xce,0x73,0x84,0x25,0x84,0x25
.byte 0x80,0x05,0x80,0x26,0x80,0x05,0x80,0x05,0x84,0x25,0x88,0x46,0x84,0x25,0x8c,0x67
.byte 0x88,0x46,0x88,0x46,0x84,0x25,0xbd,0xf0,0x84,0x25,0x84,0x25,0x88,0x46,0xce,0x74
.byte 0x80,0x05,0x80,0x05,0x80,0x05,0x80,0x05,0x8c,0x67,0x90,0x88,0x90,0x88,0x84,0x25
.byte 0xce,0x73,0xc2,0x11,0xd6,0xb5,0xa5,0x2c,0xb1,0x8e,0x84,0x25,0xce,0x74,0xb1,0x8e
.byte 0x80,0x05,0x80,0x26,0x80,0x05,0x80,0x05,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x88,0x46,0x88,0x46,0x84,0x25,0x80,0x04,0x84,0x26,0x84,0x25,0x84,0x25
.byte 0x80,0x05,0x80,0x06,0x80,0x05,0x80,0x05,0x84,0x25,0x88,0x46,0x90,0x88,0x8c,0x67
.byte 0x90,0x87,0xc6,0x32,0xd6,0xb5,0xd6,0xb5,0xc2,0x11,0xc6,0x31,0x8c,0x67,0xb5,0xaf
.byte 0x80,0x05,0x80,0x26,0x80,0x05,0x80,0x05,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0xa5,0x2b,0x84,0x25,0x88,0x46,0x88,0x46,0xad,0x6d,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0x80,0x05,0x80,0x05,0xb5,0xb0,0xa1,0x0c,0x84,0x25,0x8c,0x67,0xd6,0xb5,0xa1,0x0a
.byte 0x84,0x25,0x98,0xca,0xd2,0x95,0x90,0x87,0x80,0x04,0xa9,0x4c,0xca,0x53,0x84,0x26
.byte 0x80,0x04,0x80,0x26,0x80,0x05,0x80,0x05,0x80,0x04,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x88,0x46,0x88,0x46,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x98,0xca
.byte 0x80,0x05,0x80,0x05,0x80,0x05,0x80,0x05,0x80,0x05,0x8c,0x67,0x94,0xa8,0x84,0x26
.byte 0xa9,0x4c,0xce,0x73,0xd2,0x94,0xc2,0x11,0xda,0xd6,0xb1,0x8e,0xb1,0x8e,0xde,0xf6
.byte 0x80,0x05,0x80,0x05,0x80,0x05,0x80,0x05,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0x88,0x46,0x84,0x26,0x88,0x46,0x84,0x25,0x94,0xa9,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x80,0x05,0x98,0xc9,0xca,0x53,0xca,0x53,0x80,0x04,0xb1,0x8e,0xd2,0x94,0xa5,0x2b
.byte 0x84,0x25,0xc6,0x32,0xb9,0xcf,0x80,0x03,0x88,0x46,0xce,0x74,0xce,0x74,0xc2,0x11
.byte 0xca,0x53,0xb9,0xcf,0x8c,0x67,0x84,0x25,0xad,0x6d,0xda,0xd6,0xa5,0x2c,0x80,0x04
.byte 0x8c,0x67,0xd6,0xb5,0xa1,0x0b,0x84,0x25,0xd2,0x94,0xc6,0x32,0x88,0x46,0x84,0x25
.byte 0x84,0x25,0x84,0x26,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x8c,0x67
.byte 0x84,0x25,0x84,0x26,0x88,0x46,0xca,0x53,0x84,0x25,0x84,0x25,0x90,0x87,0xd2,0x95
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x8c,0x67,0x84,0x25,0x90,0x87,0x90,0x87
.byte 0xad,0x6d,0x80,0x04,0xc6,0x32,0xb5,0xaf,0x98,0xc9,0x88,0x46,0xd2,0x94,0xa5,0x2b
.byte 0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x80,0x05,0x88,0x46,0x88,0x46,0x84,0x25,0x80,0x05,0x84,0x25,0x88,0x46,0x80,0x04
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x26,0x90,0x88,0x8c,0x67,0x94,0xa8
.byte 0x94,0xa9,0xd6,0xb5,0xbd,0xf1,0xce,0x73,0xa9,0x4c,0xd2,0x94,0x8c,0x67,0xa1,0x0b
.byte 0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x88,0x46,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0xca,0x52,0x88,0x46,0x88,0x46,0x88,0x46,0xd6,0xb5,0x8c,0x67,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x8c,0x67
.byte 0x84,0x26,0x84,0x25,0xa9,0x4d,0xd2,0x94,0x80,0x05,0x98,0xc9,0xd6,0xb5,0xa1,0x0b
.byte 0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x94,0xa8,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0xd6,0xb5,0xc6,0x32,0x8c,0x67,0x84,0x26,0x98,0xc9,0xc2,0x11,0x90,0x88,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x98,0xc9,0x84,0x25,0x84,0x25,0x84,0x25,0xb1,0x8e
.byte 0x88,0x46,0x84,0x25,0x84,0x25,0xbd,0xf1,0x84,0x25,0x84,0x25,0x88,0x46,0xce,0x74
.byte 0xc2,0x11,0x88,0x46,0x84,0x25,0x84,0x25,0xca,0x52,0x8c,0x67,0x90,0x88,0x84,0x25
.byte 0xce,0x74,0xca,0x53,0xd6,0xb5,0xa5,0x2b,0xb9,0xd0,0x90,0x87,0xd2,0x94,0xad,0x6d
.byte 0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x88,0x46
.byte 0x80,0x05,0x84,0x25,0x88,0x46,0x84,0x26,0x80,0x04,0x84,0x25,0x84,0x26,0x84,0x25
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x80,0x04,0x84,0x25,0x88,0x46,0x84,0x25,0x80,0x04
.byte 0x84,0x26,0x88,0x46,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25,0x84,0x25
.byte 0xb9,0xd0,0xca,0x52,0x80,0x04,0x80,0x05,0xb5,0xae,0xda,0xd6,0xb5,0xaf,0xc2,0x11
.byte 0x8c,0x67,0xb1,0x8e,0xc2,0x11,0xb9,0xcf,0x84,0x25,0x80,0x05,0x80,0x05,0x80,0x05
.byte 0xca,0x53,0xb9,0xd0,0x80,0x04,0x84,0x25,0xd6,0xb5,0x94,0xa9,0x80,0x05,0x84,0x25
.byte 0x94,0xa8,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x88,0x46,0x84,0x26
.byte 0x84,0x25,0x84,0x25,0x94,0xa8,0xd6,0xb5,0x84,0x25,0x80,0x05,0xa5,0x2c,0xd2,0x94
.byte 0x84,0x25,0x84,0x25,0xa5,0x2b,0xb1,0x8d,0x88,0x46,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0x90,0x88,0x8c,0x66,0xd2,0x94,0x9c,0xea,0x84,0x25,0xa1,0x0a,0xd6,0xb5,0x8c,0x67
.byte 0x80,0x04,0xa1,0x0b,0xb5,0xae,0x84,0x25,0x88,0x46,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0x80,0x05,0x84,0x26,0x84,0x25,0x90,0x87,0x84,0x25,0x88,0x46,0x84,0x25,0x8c,0x67
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x88,0x46,0x84,0x25
.byte 0xd6,0xb5,0x98,0xc9,0x80,0x04,0x98,0xc9,0xd6,0xb5,0xc2,0x11,0xc2,0x11,0xca,0x53
.byte 0xa1,0x0b,0xc2,0x11,0xb5,0xaf,0x8c,0x67,0x80,0x05,0x84,0x25,0x80,0x04,0x84,0x25
.byte 0x8c,0x66,0x84,0x25,0x84,0x25,0x84,0x25,0x8c,0x66,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0x80,0x04,0xbd,0xf0,0xbd,0xf0,0x80,0x04,0x84,0x26,0xce,0x74,0xa9,0x4d,0x80,0x04
.byte 0x8c,0x66,0xb9,0xd0,0x94,0xa8,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x80,0x04,0xb5,0xaf,0x84,0x25,0x88,0x46,0x80,0x05,0xb1,0x8e
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x88,0x46,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0xce,0x73,0xa5,0x2c,0xad,0x6d,0xad,0x6d,0xd6,0xb5,0xb1,0x8e,0xbd,0xf0,0xa1,0x0b
.byte 0xb1,0x8e,0xc2,0x11,0xa9,0x4d,0x88,0x46,0x80,0x04,0x84,0x25,0x80,0x05,0x84,0x25
.byte 0x88,0x46,0x84,0x25,0x84,0x25,0x80,0x05,0x80,0x05,0x84,0x26,0x84,0x25,0x80,0x04
.byte 0x84,0x25,0x88,0x46,0x84,0x25,0x80,0x05,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25
.byte 0x94,0xa8,0xd6,0xb5,0xb9,0xcf,0xb1,0x8e,0xa9,0x4c,0xd6,0xb5,0x88,0x46,0x80,0x04
.byte 0xa5,0x2c,0xb5,0xae,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x25
.byte 0xa9,0x4c,0x88,0x46,0x84,0x25,0x84,0x25,0x80,0x04,0x84,0x25,0x84,0x26,0x84,0x25
.byte 0x84,0x25,0x84,0x26,0x84,0x26,0x84,0x25,0x84,0x25,0x84,0x26,0x84,0x26,0x84,0x25
.byte 0x84,0x25,0x80,0x05,0x9c,0xea,0xd2,0x94,0x84,0x25,0x80,0x05,0xa9,0x4c,0xda,0xd6
.byte 0x84,0x25,0x84,0x25,0x90,0x87,0xb9,0xcf,0x84,0x25,0x84,0x26,0x84,0x25,0x80,0x04
.byte 0x84,0x25,0x98,0xc9,0xd6,0xb5,0x90,0x88,0xb5,0xaf,0xce,0x73,0xce,0x74,0x88,0x46
.byte 0xb5,0xaf,0xad,0x6d,0xad,0x6d,0x84,0x25,0x80,0x04,0x80,0x05,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x80,0x04,0x84,0x25,0x84,0x25,0x84,0x25,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0xb9,0xd0,0xbd,0xf0,0x80,0x03,0xb1,0x8e,0xce,0x74,0xad,0x6d,0x80,0x04,0xca,0x52
.byte 0xb9,0xcf,0x94,0xa8,0x88,0x46,0xb5,0xaf,0x80,0x05,0x84,0x25,0x88,0x46,0x80,0x05
.byte 0xca,0x52,0x84,0x25,0x84,0x25,0x84,0x25,0xb9,0xcf,0x80,0x04,0x88,0x46,0x84,0x25
.byte 0x9c,0xea,0x80,0x05,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x80,0x04,0xb5,0xaf,0xca,0x52,0x80,0x03,0x80,0x04,0xb1,0x8e,0xd6,0xb5,0xb5,0xaf
.byte 0x84,0x25,0x8c,0x67,0xb5,0xaf,0xc2,0x11,0x84,0x25,0x84,0x25,0x84,0x25,0x80,0x05
.byte 0x8c,0x67,0x94,0xa9,0x84,0x25,0x84,0x25,0xd2,0x94,0xad,0x6d,0x84,0x25,0x84,0x25
.byte 0xa1,0x0b,0x84,0x25,0x88,0x46,0x84,0x25,0x80,0x05,0x84,0x25,0x88,0x46,0x88,0x46
.byte 0x84,0x25,0x84,0x25,0x94,0xa8,0xd6,0xb5,0x84,0x25,0x80,0x04,0xa9,0x4c,0xd2,0x94
.byte 0x84,0x25,0x80,0x05,0xa5,0x2b,0xb1,0x8e,0x88,0x46,0x84,0x26,0x84,0x26,0x84,0x25
.byte 0x90,0x88,0x84,0x26,0xd2,0x94,0x9c,0xea,0x84,0x25,0x9c,0xea,0xd6,0xb5,0x8c,0x67
.byte 0x80,0x04,0x9c,0xea,0xb5,0xaf,0x84,0x26,0x88,0x46,0x84,0x25,0x84,0x25,0x88,0x46
.byte 0x80,0x05,0x84,0x25,0x88,0x46,0x84,0x25,0x84,0x25,0x84,0x25,0x88,0x46,0x84,0x25
.byte 0x84,0x25,0x84,0x25,0x88,0x46,0x88,0x46,0x84,0x26,0x84,0x25,0x88,0x46,0x84,0x25
#endregion

#region SnapshotIcon
SnapshotIcon:
blrl
.byte 0x00,0x00,0x0c,0x1c,0x13,0x17,0x06,0x06,0x00,0x06,0x54,0xbe,0x52,0x54,0x0f,0x0f
.byte 0x00,0x0e,0x4c,0x53,0xc4,0x1a,0x4a,0x35,0x00,0x17,0x49,0xc1,0x09,0x09,0x6a,0xc5
.byte 0x06,0x06,0x06,0x06,0x06,0x06,0x06,0x0e,0x0f,0x0f,0x0f,0x0f,0x0f,0x0f,0x0f,0x49
.byte 0x4a,0x1a,0x1a,0x1a,0x35,0x35,0x1a,0x4e,0x6a,0x09,0x09,0x09,0x1a,0x4e,0x09,0x09
.byte 0x1c,0x25,0x0c,0x00,0x00,0x00,0x00,0x00,0x6e,0x30,0x06,0x00,0x00,0x00,0x00,0x00
.byte 0xc9,0x52,0x00,0x00,0x00,0x00,0x00,0x00,0x09,0x4f,0x38,0x0c,0x00,0x00,0x00,0x00
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.byte 0x00,0x17,0xbc,0xc3,0x09,0xc2,0x30,0x67,0x00,0x06,0x30,0x7a,0x4e,0x32,0x1e,0x44
.byte 0x00,0x12,0x1b,0x47,0x6b,0x13,0x17,0x23,0x00,0x00,0xa5,0x45,0x19,0x05,0x06,0x23
.byte 0x4a,0x09,0x09,0x6c,0x80,0x88,0x6b,0x6c,0x73,0x09,0x27,0x4d,0x32,0x1e,0x0f,0x82
.byte 0x63,0x27,0x1f,0x4d,0x1b,0x14,0x05,0x68,0x63,0x1f,0x4b,0x47,0x1b,0x06,0x12,0x1c
.byte 0x09,0x4f,0x1c,0x01,0x00,0x00,0x00,0x00,0x27,0x78,0x7f,0x12,0x00,0x00,0x00,0x00
.byte 0xb3,0xad,0x34,0x14,0x00,0x00,0x00,0x00,0xa5,0x71,0x44,0x06,0x00,0x00,0x00,0x00
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.byte 0x0c,0x12,0x32,0x48,0x1c,0x12,0x06,0x23,0x00,0x00,0x12,0x38,0x0c,0x00,0x06,0x23
.byte 0x00,0x00,0x0c,0x01,0x00,0x00,0x06,0x23,0x00,0x00,0x00,0x00,0x00,0x00,0x06,0x43
.byte 0x45,0x4b,0x76,0x47,0x1b,0x06,0x00,0x17,0x45,0x39,0x39,0xab,0x1b,0x06,0x00,0x0c
.byte 0xa6,0x3a,0x3a,0xae,0x1b,0x1e,0x17,0x17,0xa9,0x3b,0x3b,0x81,0x6e,0x51,0x69,0x19
.byte 0x30,0x48,0xa2,0x14,0x00,0x00,0x00,0x00,0x25,0x25,0x12,0x00,0x00,0x00,0x00,0x00
.byte 0x05,0x05,0x05,0x14,0x13,0x00,0x00,0x0e,0x19,0x4c,0x49,0x34,0x14,0x0c,0x13,0x51
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
.byte 0x17,0x17,0x17,0x17,0x17,0x0e,0x00,0x00,0xbb,0x4c,0x19,0x19,0x69,0xa3,0x00,0x00
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x06,0x43,0x00,0x00,0x00,0x00,0x00,0x00,0x0e,0x43
.byte 0x00,0x00,0x00,0x00,0x00,0x00,0x0e,0xb1,0x00,0x00,0x00,0x00,0x0c,0x14,0x1e,0x68
.byte 0xac,0x65,0x65,0xc8,0xcd,0x84,0x73,0x53,0xb0,0x55,0x55,0xce,0x56,0x34,0xd7,0xdb
.byte 0x5b,0x9a,0x70,0xd4,0x56,0x1d,0x51,0x58,0xc0,0xcc,0xd1,0x8c,0x87,0x28,0x72,0xdc
.byte 0x75,0x53,0xc6,0x67,0x05,0x0c,0x25,0xca,0x09,0x09,0x50,0x19,0x17,0x0c,0x25,0x4f
.byte 0x7d,0x09,0x4d,0x32,0x0e,0xd3,0x34,0x58,0x48,0x09,0x1f,0x58,0x38,0xd8,0xe2,0x79
.byte 0x7d,0x50,0x75,0x50,0x79,0xa7,0x13,0x04,0x09,0x09,0x09,0x35,0xbd,0x1c,0x0a,0x00
.byte 0x1a,0x09,0x09,0xcf,0x0b,0x2f,0x42,0x10,0x84,0x27,0x27,0x7e,0x5a,0x0d,0x0d,0x2d
.byte 0x00,0x00,0x00,0x00,0x00,0x83,0xb7,0xb9,0x00,0x00,0x00,0x17,0x19,0xb5,0xb8,0xb6
.byte 0x00,0x00,0x00,0x0e,0x72,0xb4,0x29,0x36,0x00,0x00,0x00,0x13,0x14,0x28,0x28,0x28
.byte 0xbf,0x74,0x74,0xd6,0xda,0x52,0x7b,0x5d,0x37,0x37,0x37,0x37,0xd9,0xde,0x8f,0x78
.byte 0x86,0xba,0x3c,0x89,0x3c,0x36,0x6d,0x95,0x85,0x6f,0xc7,0x6f,0xdd,0x28,0x7c,0x5f
.byte 0xe0,0x7a,0x27,0x71,0xe1,0xe3,0x5e,0x82,0x80,0xe6,0x1f,0xe7,0x96,0x8b,0x5d,0x3f
.byte 0x88,0x95,0x39,0x98,0x5e,0xa0,0xf6,0x9f,0xef,0x3f,0x9c,0x3a,0x5f,0x94,0x86,0x97
.byte 0x94,0x1f,0x1f,0x7e,0xd2,0x02,0x0b,0x22,0x3f,0x76,0x4b,0x56,0x8b,0x02,0x0b,0xa8
.byte 0x9b,0x98,0x39,0x8d,0x59,0x26,0x2e,0x15,0x5e,0x9c,0x3a,0x8d,0x59,0x0d,0x16,0x61
.byte 0x00,0x00,0x00,0x00,0x00,0x0c,0x2d,0x2b,0x00,0x00,0x00,0x00,0x04,0x21,0x31,0x24
.byte 0x00,0x00,0x0c,0x01,0x0c,0x0c,0x04,0x10,0x00,0x0c,0x0c,0x33,0x2b,0x2f,0x16,0x01
.byte 0x41,0x0b,0x24,0x15,0x0a,0x38,0x5f,0x60,0x24,0x42,0x10,0x01,0x10,0x7f,0x60,0x60
.byte 0x0a,0x10,0x04,0x10,0x1e,0x8e,0x5b,0x91,0x00,0x00,0x0a,0x64,0x33,0x3f,0xe9,0xec
.byte 0x57,0x9f,0xfb,0x3b,0xfc,0xfe,0xf5,0x5a,0xa1,0xa1,0x99,0x9e,0x55,0xf9,0x9b,0x33
.byte 0x83,0x1e,0xfd,0xfa,0x9a,0x5b,0x54,0x1d,0xee,0x85,0xf8,0x90,0x93,0x9d,0x31,0xf2
.byte 0xf0,0x81,0x3b,0x29,0x57,0x22,0x2a,0x11,0xf4,0xf1,0x9e,0x99,0xe4,0x46,0x03,0x11
.byte 0x5d,0xeb,0x9a,0x91,0x8e,0x1e,0x03,0x03,0x9d,0x8c,0x93,0x90,0x52,0xb2,0x46,0x03
.byte 0x00,0x01,0x33,0x41,0x2c,0x16,0x04,0x00,0x0a,0x42,0x41,0x3e,0x21,0x0a,0x00,0x01
.byte 0x21,0x2b,0x22,0x01,0x01,0x00,0x0a,0x15,0x2d,0x2d,0x0a,0x04,0x00,0x0a,0x64,0x2b
.byte 0x04,0x0a,0xaf,0xcb,0xd0,0x77,0x92,0x92,0x01,0x31,0x26,0x57,0x5c,0x8a,0x3c,0x3c
.byte 0x3e,0x0b,0x02,0x02,0x20,0x20,0x20,0x20,0x0b,0x02,0x02,0x02,0x02,0x02,0x02,0x02
.byte 0xed,0x5c,0xf3,0xf7,0x3d,0x96,0xa0,0xea,0x8a,0x5c,0x59,0x89,0x8f,0x97,0xe5,0x87
.byte 0x20,0x20,0x26,0x5a,0xdf,0x16,0xd5,0x18,0x0b,0x0d,0x2f,0x16,0x03,0x66,0x07,0x07
.byte 0xe8,0x3d,0x3d,0x3d,0x77,0xaa,0xa4,0x1e,0x29,0x36,0x36,0x36,0x29,0x6d,0xa4,0x1e
.byte 0x18,0x18,0x18,0x18,0x18,0x18,0x46,0x08,0x07,0x07,0x07,0x07,0x07,0x07,0x08,0x08
.byte 0x04,0x01,0x00,0x04,0x0a,0x42,0x02,0x0b,0x00,0x00,0x04,0x13,0x31,0x0b,0x0d,0x0d
.byte 0x00,0x00,0x04,0x22,0x2c,0x2c,0x2e,0x2e,0x00,0x00,0x00,0x13,0x15,0x21,0x21,0x15
.byte 0x02,0x02,0x02,0x02,0x0d,0x0b,0x0b,0x2c,0x0d,0x0b,0x0b,0x0d,0x2e,0x3e,0x42,0x15
.byte 0x2f,0x24,0x22,0x62,0x15,0x2a,0x40,0x08,0x01,0x11,0x61,0x2a,0x03,0x11,0x11,0x03
.byte 0x24,0x62,0x03,0x40,0x07,0x08,0x07,0x07,0x40,0x40,0x07,0x08,0x08,0x07,0x07,0x07
.byte 0x03,0x08,0x08,0x08,0x07,0x07,0x07,0x07,0x08,0x08,0x08,0x08,0x07,0x07,0x07,0x07
.byte 0x07,0x07,0x07,0x07,0x07,0x08,0x08,0x08,0x07,0x07,0x07,0x07,0x08,0x08,0x08,0x03
.byte 0x07,0x07,0x07,0x07,0x08,0x08,0x03,0x11,0x07,0x08,0x08,0x08,0x03,0x03,0x11,0x11
.byte 0x84,0x25,0x84,0x25,0xa8,0x0f,0x84,0x24,0x84,0x25,0x80,0x04,0x80,0x05,0x84,0x24
.byte 0x84,0x24,0x80,0x00,0x84,0x24,0xa8,0x30,0x84,0x25,0xa8,0x10,0x80,0x04,0x98,0xca
.byte 0x84,0x25,0x84,0x24,0x84,0x25,0x84,0x25,0x80,0x05,0x88,0x26,0x90,0x28,0x80,0x04
.byte 0x80,0x04,0xad,0x6e,0xb1,0x8c,0xbd,0xd0,0x8c,0x67,0x80,0x03,0x80,0x03,0x84,0x00
.byte 0xa4,0x10,0x88,0x26,0x94,0x2a,0xa1,0x0c,0x9c,0x2c,0x88,0x46,0xa8,0x10,0x80,0x00
.byte 0x80,0x05,0xcd,0xcf,0x84,0x24,0xa0,0x2e,0xa4,0x2f,0x8c,0x28,0xa4,0x2e,0xa0,0x0d
.byte 0xb9,0xd0,0x98,0x2b,0xb9,0xd0,0x98,0x0c,0x98,0xc9,0xa9,0x4a,0xd1,0xd0,0xf4,0x41
.byte 0x88,0x46,0x90,0x00,0x98,0x00,0xa4,0x00,0xd9,0xd4,0xec,0x21,0x9c,0x2c,0xc9,0xf3
.byte 0x80,0x24,0xac,0x11,0x90,0x29,0xa1,0x0c,0xa1,0x0b,0xb9,0x6a,0x80,0x04,0x98,0x63
.byte 0xd2,0x74,0xb1,0x8e,0xad,0x6b,0x88,0x00,0xad,0x6e,0x90,0x63,0xa5,0x29,0xbd,0xf0
.byte 0x9c,0xe7,0xa5,0x4c,0xbd,0xf1,0x9c,0xe7,0x9c,0xea,0xb4,0x00,0xc5,0xf1,0xb4,0x92
.byte 0xc1,0xf0,0xb0,0x72,0xac,0x31,0xd9,0x4a,0xe2,0x36,0xc5,0xf0,0xc9,0xd3,0xc5,0xae
.byte 0xcd,0x8d,0x80,0x24,0x8c,0x27,0xb1,0x4a,0x8c,0x27,0xac,0x00,0x80,0x23,0xb5,0xaf
.byte 0xb1,0x8f,0xa9,0x4d,0x94,0x84,0xc6,0x31,0x8c,0x42,0xda,0x32,0xca,0x53,0xa0,0x0e
.byte 0xc4,0x00,0xb5,0x8c,0xa5,0x2c,0xad,0x6a,0xe0,0x00,0xa1,0x07,0x90,0x00,0xf5,0x4a
.byte 0xb9,0xce,0xc2,0x0f,0x8c,0x41,0xbd,0xf1,0xbd,0xcf,0xa1,0x08,0xc5,0xf2,0x90,0x88
.byte 0xc6,0x33,0xac,0x41,0xc6,0x11,0x8c,0xa8,0xd6,0xb5,0x8c,0x09,0xcd,0xef,0xd6,0x11
.byte 0xa9,0x4d,0xdd,0xf5,0xdd,0xd2,0xac,0x51,0xd4,0x00,0xc9,0xd0,0x98,0xea,0xf2,0x53
.byte 0xe0,0xc6,0xd5,0x8c,0xe8,0x20,0xd4,0x00,0xd6,0x76,0xc1,0xad,0xcd,0xb5,0xb8,0xd3
.byte 0x98,0x20,0xd1,0xae,0xc0,0x00,0xc5,0xb3,0xa4,0x21,0xdd,0xf1,0xb0,0x00,0xc5,0x75
.byte 0xc1,0x35,0xa8,0xaf,0x94,0xa9,0xa5,0x2c,0x9d,0x0a,0xbd,0xf0,0xbd,0x4a,0xd2,0x95
.byte 0x94,0x29,0xc5,0x4a,0xea,0x73,0xa0,0x62,0xc9,0x4a,0xb1,0x6c,0xa8,0x63,0x90,0x08
.byte 0xd1,0x4a,0xa1,0x2c,0x80,0x25,0xa5,0x07,0xd6,0x11,0xfa,0x72,0xf8,0x42,0xad,0x8f
.byte 0xfd,0x6a,0xe1,0xf0,0xd1,0xf1,0xad,0x6e,0xb5,0xaf,0xb9,0xb1,0xca,0x53,0xe0,0x00
.byte 0xdc,0xe7,0x9c,0xc6,0xb1,0x8c,0x94,0xa4,0x94,0xa5,0xb5,0xad,0xbd,0xee,0xa4,0x10
.byte 0xb4,0x21,0x84,0x21,0xce,0x74,0xb0,0xb1,0xd0,0x00,0xe2,0xf7,0xc0,0x42,0xc5,0xf2
.byte 0xea,0x77,0xd0,0x00,0xac,0x51,0x80,0x04,0xcc,0x42,0x84,0x04,0xdc,0x00,0xc2,0x11
.byte 0x84,0x06,0xf4,0x20,0xe9,0x29,0x88,0x42,0xce,0x52,0x88,0x08,0xfc,0xe7,0xa4,0x70
.byte 0xda,0xd7,0xa8,0xee,0xbd,0x52,0xa0,0x0e,0xa0,0xad,0xb9,0x31,0xad,0x08,0xa4,0xc5
.byte 0xf0,0xa5,0xdc,0x83,0xf6,0x74,0xc8,0x21,0xe1,0x28,0xf5,0xce,0xb5,0x92,0x9c,0xcc
.byte 0xd1,0xd4,0xbc,0x21,0x98,0xad,0xb9,0x35,0xcd,0xd3,0xd1,0xd2,0xca,0x0f,0xed,0x8c
.byte 0xc1,0x92,0xc9,0x07,0xc8,0x21,0xc1,0x07,0xbd,0x08,0xce,0x10,0xe2,0xb4,0xcd,0xae
#endregion

#endregion

exit:
restore
li	r0, 16
