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

#Store snapshot codeset sizes
	bl	MMLCode102_Start
	mflr	r4
	bl	MMLCode102_End
	mflr	r5
	sub	r4,r5,r4
	stw	r4,0x4(r3)
	bl	MMLCode101_Start
	mflr	r4
	bl	MMLCode101_End
	mflr	r5
	sub	r4,r5,r4
	stw	r4,0xC(r3)
	bl	MMLCode100_Start
	mflr	r4
	bl	MMLCode100_End
	mflr	r5
	sub	r4,r5,r4
	stw	r4,0x14(r3)
	bl	MMLCodePAL_Start
	mflr	r4
	bl	MMLCodePAL_End
	mflr	r5
	sub	r4,r5,r4
	stw	r4,0x1C(r3)

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
.set  CodesSceneID,9

#Place bl to heap hijack code
	bl	ExploitCode102_HeapHijack
	mflr	r3
	load	r4,HeapHijack_Injection
	sub r3,r3,r4           #Difference relative to branch addr
	rlwinm  r3,r3,0,6,29                  #extract bits for offset
	oris  r3,r3,0x4800                    #Create branch instruction from it
	ori	r3,r3,0x1													#Create bl instruction
	stw	r3,0x0(r4)												#Place instruction
#Flush cache
	mr	r3,r4
	li	r4,32
	branchl	r12,TRK_flush_cache

#Store as next scene
	branchl	r12,Scene_GetMinorSceneData2
	li	r4,0
	stb	r4,0x0(r3)
#request to change scenes
	branchl	r12,MenuController_ChangeScreenMinor
#Return to the game
	branch	r12,ExpoitReturnAddr


ExploitCode102_HeapHijack:
blrl
backup

#Restore original codeline
	load	r3,0x38000002
	load	r4,HeapHijack_Injection
	stw	r3,0x0(r4)
#Flush cache
	mr	r3,r4
	li	r4,32
	branchl	r12,TRK_flush_cache

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
.set REG_SnapshotPointer,30
#Convert blocks to bytes
  lhz r3,0x6(r3)
  mulli REG_CodesetSize,r3,0x2000
#Alloc Space For Snapshot File
  mr  r3,REG_CodesetSize
  branchl	r12,HSD_MemAlloc			       #HSD_Alloc
  mr  REG_SnapshotPointer,r3
  load	r5,SnapshotData			           #Snapshot Data Struct
  stw	REG_SnapshotPointer,0x1C(r5)     #Store Pointer to this area

#Remove Pointer To Current Memcard Stuff
  branchl	r12,Memcard_FreeSomething
#Alloc Space For Memcard Stuff
  branchl	r12,Memcard_AllocateSomething

#Load File
  li	r3,0x0		#Slot A?
  bl	ExploitCode102_SnapshotID
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

ExploitCode102_WaitToLoadLoop:
  branchl	r12,MemoryCard_WaitForFileToFinishSaving
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

#########################################
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
###########################################


#############
## Failure ##
#############

ExploitCode102_Failure:
#Play Error Sound
  li	r3, 3
  branchl	r12,SFX_MenuCommonSound
  li	r3, 3
  branchl	r12,SFX_MenuCommonSound
#Disable Saving
	load r4,OFST_MemcardController
  li     r3,4
  stw    r3,0x8(r4)    # store 4 to disable memory card saving
	b	ExploitCode102_Exit

#############
## Success ##
#############
ExploitCode102_Success:
.set REG_PersistentHeapStruct,29
.set REG_CodesetPointer,28

#Get this revisions code size
	lwz	REG_CodesetSize,(0*8)+0x4(REG_SnapshotPointer)

#Destroy original heap
	lwz	r3, Heap_MainID (r13) #-0x58A0
	branchl	r12,OSDestroyHeap #80344154
#Create new heap
	load REG_PersistentHeapStruct,PersistentHeapStruct
	lwz	r3, Heap_Lo (r13)
	lwz	r4, Heap_Hi (r13)
	branchl	r12,OSCreateHeap #803440e8
#Adjust main heap offset from here on out
	lwz	r3,0x70(REG_PersistentHeapStruct)
	add	r3,r3,REG_CodesetSize
	addi	r3,r3,32
	stw	r3,0x70(REG_PersistentHeapStruct)

#Alloc Space For Snapshot File
  mr  r3,REG_CodesetSize
  branchl	r12,HSD_MemAlloc			       #80343ef0
  mr  REG_CodesetPointer,r3

#Get address of codeset
  lwz r4,(0*8)(REG_SnapshotPointer)       #Load b instruction
  rlwinm  r4,r4,0,6,29  									#extract offset bits
	rlwinm	r5,r4,7,31,31										#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5														#extend signed bit
	addi r3,REG_SnapshotPointer,0*8		      #Load b instruction
  add r4,r4,r3

#Copy this revisions code to the new heap
	addi r3,REG_CodesetPointer,0
	addi r4,r4,0
	mr	r5,REG_CodesetSize
	branchl	r12,memcpy

#flush cache on snapshot code
  addi r3,REG_CodesetPointer,0
	mr	r4,REG_CodesetSize
  branchl r12,TRK_flush_cache

#Restore this stack frame and jump to the MML code in the snapshot file
	mtctr REG_CodesetPointer
	bctr

ExploitCode102_Exit:
#exit
	restore
	li	r0,2
	blr

ExploitCode102_End:
blrl
#endregion
#region ExploitCode101
ExploitCode101:
blrl
.include "../../Common101.s"
.set REG_SnapLoadResult,31
.set  CodesSceneID,9

#Place bl to heap hijack code
	bl	ExploitCode101_HeapHijack
	mflr	r3
	load	r4,HeapHijack_Injection
	sub r3,r3,r4           #Difference relative to branch addr
	rlwinm  r3,r3,0,6,29                  #extract bits for offset
	oris  r3,r3,0x4800                    #Create branch instruction from it
	ori	r3,r3,0x1													#Create bl instruction
	stw	r3,0x0(r4)												#Place instruction
#Flush cache
	mr	r3,r4
	li	r4,32
	branchl	r12,TRK_flush_cache

#Store as next scene
	branchl	r12,Scene_GetMinorSceneData2
	li	r4,0
	stb	r4,0x0(r3)
#request to change scenes
	branchl	r12,MenuController_ChangeScreenMinor
#Return to the game
	branch	r12,ExpoitReturnAddr


ExploitCode101_HeapHijack:
blrl
backup

#Restore original codeline
	load	r3,0x38000002
	load	r4,HeapHijack_Injection
	stw	r3,0x0(r4)
#Flush cache
	mr	r3,r4
	li	r4,32
	branchl	r12,TRK_flush_cache

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
.set REG_CodesetSize,31
.set REG_SnapshotPointer,30
#Convert blocks to bytes
  lhz r3,0x6(r3)
  mulli REG_CodesetSize,r3,0x2000
#Alloc Space For Snapshot File
  mr  r3,REG_CodesetSize
  branchl	r12,HSD_MemAlloc			       #HSD_Alloc
  mr  REG_SnapshotPointer,r3
  load	r5,SnapshotData			           #Snapshot Data Struct
  stw	REG_SnapshotPointer,0x1C(r5)     #Store Pointer to this area

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
.set REG_PersistentHeapStruct,29
.set REG_CodesetPointer,28

#Get this revisions code size
	lwz	REG_CodesetSize,(1*8)+0x4(REG_SnapshotPointer)

#Destroy original heap
	lwz	r3, Heap_MainID (r13) #-0x58A0
	branchl	r12,OSDestroyHeap #80344154
#Create new heap
	load REG_PersistentHeapStruct,PersistentHeapStruct
	lwz	r3, Heap_Lo (r13)
	lwz	r4, Heap_Hi (r13)
	branchl	r12,OSCreateHeap #803440e8
#Adjust main heap offset from here on out
	lwz	r3,0x70(REG_PersistentHeapStruct)
	add	r3,r3,REG_CodesetSize
	addi	r3,r3,32
	stw	r3,0x70(REG_PersistentHeapStruct)

#Alloc Space For Snapshot File
  mr  r3,REG_CodesetSize
  branchl	r12,HSD_MemAlloc			       #80343ef0
  mr  REG_CodesetPointer,r3

#Get address of codeset
  lwz r4,(1*8)(REG_SnapshotPointer)       #Load b instruction
  rlwinm  r4,r4,0,6,29  									#extract offset bits
	rlwinm	r5,r4,7,31,31										#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5														#extend signed bit
	addi r3,REG_SnapshotPointer,1*8		      #Load b instruction
  add r4,r4,r3

#Copy this revisions code to the new heap
	addi r3,REG_CodesetPointer,0
	addi r4,r4,0
	mr	r5,REG_CodesetSize
	branchl	r12,memcpy

#flush cache on snapshot code
  addi r3,REG_CodesetPointer,0
	mr	r4,REG_CodesetSize
  branchl r12,TRK_flush_cache

#Restore this stack frame and jump to the MML code in the snapshot file
	mtctr REG_CodesetPointer
	bctr

ExploitCode101_Exit:
#exit
	restore
	li	r0,2
	blr

ExploitCode101_End:
blrl
#endregion
#region ExploitCode100
ExploitCode100:
blrl
.include "../../Common100.s"
.set REG_SnapLoadResult,31
.set  CodesSceneID,9

#Place bl to heap hijack code
	bl	ExploitCode100_HeapHijack
	mflr	r3
	load	r4,HeapHijack_Injection
	sub r3,r3,r4           #Difference relative to branch addr
	rlwinm  r3,r3,0,6,29                  #extract bits for offset
	oris  r3,r3,0x4800                    #Create branch instruction from it
	ori	r3,r3,0x1													#Create bl instruction
	stw	r3,0x0(r4)												#Place instruction
#Flush cache
	mr	r3,r4
	li	r4,32
	branchl	r12,TRK_flush_cache

#Store as next scene
	branchl	r12,Scene_GetMinorSceneData2
	li	r4,0
	stb	r4,0x0(r3)
#request to change scenes
	branchl	r12,MenuController_ChangeScreenMinor
#Return to the game
	branch	r12,ExpoitReturnAddr


ExploitCode100_HeapHijack:
blrl
backup

#Restore original codeline
	load	r3,0x38000002
	load	r4,HeapHijack_Injection
	stw	r3,0x0(r4)
#Flush cache
	mr	r3,r4
	li	r4,32
	branchl	r12,TRK_flush_cache

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
.set REG_CodesetSize,31
.set REG_SnapshotPointer,30
#Convert blocks to bytes
  lhz r3,0x6(r3)
  mulli REG_CodesetSize,r3,0x2000
#Alloc Space For Snapshot File
  mr  r3,REG_CodesetSize
  branchl	r12,HSD_MemAlloc			       #HSD_Alloc
  mr  REG_SnapshotPointer,r3
  load	r5,SnapshotData			           #Snapshot Data Struct
  stw	REG_SnapshotPointer,0x1C(r5)     #Store Pointer to this area

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
.set REG_PersistentHeapStruct,29
.set REG_CodesetPointer,28

#Get this revisions code size
	lwz	REG_CodesetSize,(2*8)+0x4(REG_SnapshotPointer)

#Destroy original heap
	lwz	r3, Heap_MainID (r13) #-0x58A0
	branchl	r12,OSDestroyHeap #80344154
#Create new heap
	load REG_PersistentHeapStruct,PersistentHeapStruct
	lwz	r3, Heap_Lo (r13)
	lwz	r4, Heap_Hi (r13)
	branchl	r12,OSCreateHeap #803440e8
#Adjust main heap offset from here on out
	lwz	r3,0x70(REG_PersistentHeapStruct)
	add	r3,r3,REG_CodesetSize
	addi	r3,r3,32
	stw	r3,0x70(REG_PersistentHeapStruct)

#Alloc Space For Snapshot File
  mr  r3,REG_CodesetSize
  branchl	r12,HSD_MemAlloc			       #80343ef0
  mr  REG_CodesetPointer,r3

#Get address of codeset
  lwz r4,(2*8)(REG_SnapshotPointer)       #Load b instruction
  rlwinm  r4,r4,0,6,29  									#extract offset bits
	rlwinm	r5,r4,7,31,31										#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5														#extend signed bit
	addi r3,REG_SnapshotPointer,2*8		      #Load b instruction
  add r4,r4,r3

#Copy this revisions code to the new heap
	addi r3,REG_CodesetPointer,0
	addi r4,r4,0
	mr	r5,REG_CodesetSize
	branchl	r12,memcpy

#flush cache on snapshot code
  addi r3,REG_CodesetPointer,0
	mr	r4,REG_CodesetSize
  branchl r12,TRK_flush_cache

#Restore this stack frame and jump to the MML code in the snapshot file
	mtctr REG_CodesetPointer
	bctr

ExploitCode100_Exit:
#exit
	restore
	li	r0,2
	blr

ExploitCode100_End:
blrl
#endregion

SnapshotCode_Start:
blrl
b	SnapshotCode102_Start
.long 0										#revision's code length (stored to during creation of the snapshot)
b	SnapshotCode101_Start
.long 0										#revision's code length (stored to during creation of the snapshot)
b	SnapshotCode100_Start
.long 0										#revision's code length (stored to during creation of the snapshot)
b	SnapshotCodePAL_Start
.long 0										#revision's code length (stored to during creation of the snapshot)

#region SnapshotCode102
.include "../../Common102.s"

MMLCode102_Start:
blrl

SnapshotCode102_Start:

#Clear nametag region
	lwz	r3,OFST_Memcard(r13)
	addi	r3,r3,OFST_NametagStart
	li r4,0
	load r5,Nametag_Length
	branchl  r12,memset

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

#Init LagPrompt major struct
  li  r3,PromptSceneID
  bl  Snap102_LagPrompt_MinorSceneStruct
  mflr  r4
  bl  Snap102_LagPrompt_SceneLoad
  mflr  r5
  bl  Snap102_InitializeMajorSceneStruct
#Init Codes major struct
  li  r3,CodesSceneID
  bl  Snap102_Codes_MinorSceneStruct
  mflr  r4
  bl  Snap102_Codes_SceneLoad
  mflr  r5
  bl  Snap102_InitializeMajorSceneStruct

#Check if key has been generated yet
	lwz	r20,OFST_Memcard(r13)
	lwz	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
	cmpwi	r3,0
	bne	Snap102_GenerateKeyEnd
#Generate Key
	lwz	r3, OFST_Rand (r13)
	lwz	r3,0x0(r3)
	stw	r3,ModOFST_ModDataStart+ModOFST_ModDataKey(r20)
Snap102_GenerateKeyEnd:
  b Snap102_CheckProgressive

#region Snap102_PointerConvert
Snap102_PointerConvert:
  lwz r4,0x0(r3)          #Load bl instruction
  rlwinm r5,r4,8,25,29    #extract opcode bits
  cmpwi r5,0x48           #if not a bl instruction, exit
  bne Snap102_PointerConvert_Exit
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
  add r4,r4,r3
  stw r4,0x0(r3)
Snap102_PointerConvert_Exit:
  blr
#endregion
#region Snap102_InitializeMajorSceneStruct
Snap102_InitializeMajorSceneStruct:
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
Snap102_GetMajorStruct_Loop:
  lbz	r4, 0x0001 (r3)
  cmpw r4,REG_MajorScene
  beq Snap102_GetMajorStruct_Exit
  addi  r3,r3,20
  b Snap102_GetMajorStruct_Loop
Snap102_GetMajorStruct_Exit:

Snap102_InitMinorSceneStruct:
.set  REG_MinorStructParse,20
  stw REG_MinorStruct,0x10(r3)
  mr  REG_MinorStructParse,REG_MinorStruct
Snap102_InitMinorSceneStruct_Loop:
#Check if valid entry
  lbz r3,0x0(REG_MinorStructParse)
  extsb r3,r3
  cmpwi r3,-1
  beq Snap102_InitMinorSceneStruct_Exit
#Convert Pointers
  addi  r3,REG_MinorStructParse,0x4
  bl  Snap102_PointerConvert
  addi  r3,REG_MinorStructParse,0x8
  bl  Snap102_PointerConvert
  addi  REG_MinorStructParse,REG_MinorStructParse,0x18
  b Snap102_InitMinorSceneStruct_Loop
Snap102_InitMinorSceneStruct_Exit:

  restore
  blr
#endregion
#endregion

#region Codes

#region Snap102_Codes_SceneLoad
############################################

#region Snap102_Codes_SceneLoad_Data
Snap102_Codes_SceneLoad_TextProperties:
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
Snap102_CodeNames_Order:
blrl
bl  Snap102_CodeNames_UCF
bl  Snap102_CodeNames_Frozen
bl  Snap102_CodeNames_Spawns
bl  Snap102_CodeNames_Wobbling
bl  Snap102_CodeNames_Ledgegrab
bl	Snap102_CodeNames_TournamentQoL
bl	Snap102_CodeNames_FriendliesQoL
bl	Snap102_CodeNames_GameVersion
bl	Snap102_CodeNames_StageExpansion
bl	Snap102_CodeNames_Widescreen
.align 2
#endregion
#region Code Names
Snap102_CodeNames_Title:
blrl
.string "Select Codes:"
.align 2
Snap102_CodeNames_ModName:
blrl
.string "MultiMod Launcher v0.76"
.align 2
Snap102_CodeNames_UCF:
.string "UCF:"
.align 2
Snap102_CodeNames_Frozen:
.string "Frozen Stages:"
.align 2
Snap102_CodeNames_Spawns:
.string "Neutral Spawns:"
.align 2
Snap102_CodeNames_Wobbling:
.string "Disable Wobbling:"
.align 2
Snap102_CodeNames_Ledgegrab:
.string "Ledgegrab Limit:"
.align 2
Snap102_CodeNames_TournamentQoL:
.string "Tournament QoL:"
.align 2
Snap102_CodeNames_FriendliesQoL:
.string "Friendlies QoL:"
.align 2
Snap102_CodeNames_GameVersion:
.string "Game Version:"
.align 2
Snap102_CodeNames_StageExpansion:
.string "Stage Expansion:"
.align 2
Snap102_CodeNames_Widescreen:
.string "Widescreen:"
.align 2
#endregion
#region Code Options Order
Snap102_CodeOptions_Order:
blrl
bl  Snap102_CodeOptions_UCF
bl  Snap102_CodeOptions_Frozen
bl  Snap102_CodeOptions_Spawns
bl  Snap102_CodeOptions_Wobbling
bl  Snap102_CodeOptions_Ledgegrab
bl	Snap102_CodeOptions_TournamentQoL
bl  Snap102_CodeOptions_FriendliesQoL
bl	Snap102_CodeOptions_GameVersion
bl	Snap102_CodeOptions_StageExpansion
bl  Snap102_CodeOptions_Widescreen
.align 2
#endregion
#region Code Options
.set  Snap102_CodeOptions_OptionCount,0x0
.set	Snap102_CodeOptions_CodeDescription,0x4
.set  Snap102_CodeOptions_GeckoCodePointers,0x8
Snap102_CodeOptions_Wrapper:
	blrl
	.short 0x8183
	.ascii "%s"
	.short 0x8184
	.byte 0
	.align 2
Snap102_CodeOptions_UCF:
	.long 3 -1           #number of options
	bl	Snap102_UCF_Description
	bl  Snap102_UCF_Off
	bl  Snap102_UCF_On
	bl  Snap102_UCF_Stealth
	.string "Off"
	.string "On"
	.string "Stealth"
	.align 2
Snap102_CodeOptions_Frozen:
	.long 3 -1           #number of options
	bl	Snap102_Frozen_Description
	bl  Snap102_Frozen_Off
	bl  Snap102_Frozen_Stadium
	bl  Snap102_Frozen_All
	.string "Off"
	.string "Stadium Only"
	.string "All"
	.align 2
Snap102_CodeOptions_Spawns:
	.long 2 -1           #number of options
	bl	Snap102_Spawns_Description
	bl  Snap102_Spawns_Off
	bl  Snap102_Spawns_On
	.string "Off"
	.string "On"
	.align 2
Snap102_CodeOptions_Wobbling:
	.long 2 -1           #number of options
	bl	Snap102_DisableWobbling_Description
	bl  Snap102_DisableWobbling_Off
	bl  Snap102_DisableWobbling_On
	.string "Off"
	.string "On"
	.align 2
Snap102_CodeOptions_Ledgegrab:
	.long 2 -1           #number of options
	bl	Snap102_Ledgegrab_Description
	bl  Snap102_Ledgegrab_Off
	bl  Snap102_Ledgegrab_On
	.string "Off"
	.string "On"
	.align 2
Snap102_CodeOptions_TournamentQoL:
	.long 2 -1           #number of options
	bl	Snap102_TournamentQoL_Description
	bl  Snap102_TournamentQoL_Off
	bl  Snap102_TournamentQoL_On
	.string "Off"
	.string "On"
	.align 2
Snap102_CodeOptions_FriendliesQoL:
	.long 2 -1           #number of options
	bl	Snap102_FriendliesQoL_Description
	bl  Snap102_FriendliesQoL_Off
	bl  Snap102_FriendliesQoL_On
	.string "Off"
	.string "On"
	.align 2
Snap102_CodeOptions_GameVersion:
	.long 3 -1           #number of options
	bl	Snap102_GameVersion_Description
	bl  Snap102_GameVersion_NTSC
	bl  Snap102_GameVersion_PAL
	bl  Snap102_GameVersion_SDR
	.string "NTSC"
	.string "PAL"
	.string "SD Remix"
	.align 2
Snap102_CodeOptions_StageExpansion:
	.long 2 -1           #number of options
	bl	Snap102_StageExpansion_Description
	bl  Snap102_StageExpansion_Off
	bl  Snap102_StageExpansion_On
	.string "Off"
	.string "On"
	.align 2
Snap102_CodeOptions_Widescreen:
	.long 3 -1           #number of options
	bl	Snap102_Widescreen_Description
	bl  Snap102_Widescreen_Off
	bl  Snap102_Widescreen_Standard
	bl	Snap102_Widescreen_True
	.string "Off"
	.string "Standard"
	.string "True"
	.align 2
#endregion

#endregion
#region Snap102_Codes_SceneLoad
Snap102_Codes_SceneLoad:
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

Snap102_Codes_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl Snap102_Codes_SceneLoad_TextProperties
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
	bl Snap102_CodeNames_Title
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
	bl Snap102_CodeNames_ModName
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
  bl  Snap102_Codes_SceneThink
  mflr  r4      #Function to Run
  li  r5,0      #Priority
  branchl r12, GObj_AddProc
#Copy Saved Menu Options
	addi	r3,REG_GObjData,OFST_OptionSelections
	lwz	r4, OFST_Memcard (r13)
	addi r4,r4,ModOFST_ModDataStart + ModOFST_ModDataPrefs
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
  bl  Snap102_Codes_CreateMenu

Snap102_Codes_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region Snap102_Codes_SceneThink
Snap102_Codes_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  Snap102_Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Code Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,Inputs_GetPlayerRapidHeldInputs
  mr  REG_Inputs,r3
#Check for movement up
  rlwinm. r0,REG_Inputs,0,0x10
  beq Snap102_Codes_SceneThink_SkipUp
#Adjust cursor
  lhz r3,OFST_CursorLocation(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_CursorLocation(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Snap102_Codes_SceneThink_UpdateMenu
#Cursor stays at top
  li  r3,0
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll up
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  subi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Snap102_Codes_SceneThink_UpdateMenu
#Scroll stays at top
  li  r3,0
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b Snap102_Codes_SceneThink_Exit
Snap102_Codes_SceneThink_SkipUp:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x20
  beq Snap102_Codes_SceneThink_AdjustOptionSelection
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
  b Snap102_Codes_SceneThink_Exit
#Check if exceeds max amount of codes per page
  cmpwi r3,MaxCodesOnscreen-1
  ble Snap102_Codes_SceneThink_UpdateMenu
#Cursor stays at bottom
  li  r3,MaxCodesOnscreen-1
  sth r3,OFST_CursorLocation(REG_GObjData)
#Attempt to scroll down
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  addi  r3,r3,1
  sth r3,OFST_ScrollAmount(REG_GObjData)
  extsb r3,r3
  cmpwi r3,CodeAmount-MaxCodesOnscreen
  ble Snap102_Codes_SceneThink_UpdateMenu
#Scroll stays at bottom
  li  r3,(CodeAmount-1)-(MaxCodesOnscreen-1)
  sth r3,OFST_ScrollAmount(REG_GObjData)
  b Snap102_Codes_SceneThink_Exit
#endregion
#region Adjust Option Selection
Snap102_Codes_SceneThink_AdjustOptionSelection:
.set  REG_MaxOptions,20
.set  REG_OptionValuePtr,21
#Check for movement right
  rlwinm. r0,REG_Inputs,0,0x80
  beq Snap102_Codes_SceneThink_SkipRight
#Get amount of options for this code
  lhz r3,OFST_CursorLocation(REG_GObjData)
  lhz r4,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,r4                                #get which option this is
  bl  Snap102_CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add r3,r3,r4                                #get bl pointer to options info
  bl  Snap102_ConvertBlPointer
  lwz REG_MaxOptions,Snap102_CodeOptions_OptionCount(r3)     #get amount of options for this code
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
  ble Snap102_Codes_SceneThink_UpdateMenu
#Option stays maxxed out
  stb REG_MaxOptions,0x0(REG_OptionValuePtr)
  b Snap102_Codes_SceneThink_Exit
Snap102_Codes_SceneThink_SkipRight:
#Check for movement down
  rlwinm. r0,REG_Inputs,0,0x40
  beq Snap102_Codes_SceneThink_CheckToExit
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
  bge Snap102_Codes_SceneThink_UpdateMenu
#Option stays at 0
  li  r3,0
  stb r3,0x0(REG_OptionValuePtr)
  b Snap102_Codes_SceneThink_Exit
#endregion
#region Check to Exit
Snap102_Codes_SceneThink_CheckToExit:
#Check for start input
  li  r3,4
  branchl r12,Inputs_GetPlayerInstantInputs
  rlwinm. r0,r4,0,0x1000
  beq Snap102_Codes_SceneThink_Exit
#Apply codes
  mr  r3,REG_GObjData
  bl  Snap102_ApplyAllGeckoCodes
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
	addi r3,r3,ModOFST_ModDataStart + ModOFST_ModDataPrefs
	addi	r4,REG_GObjData,OFST_OptionSelections
	li	r5,0x18
	branchl	r12,memcpy
#Request a memcard save
	branchl	r12,Memcard_AllocateSomething		#Allocate memory for something
	li	r3,0
	branchl	r12,MemoryCard_LoadBannerIconImagesToRAM	#load banner images
#Set memcard save flag
	load	r3,OFST_MemcardController
	li	r4,1
	stw	r4,0xC(r3)

  b Snap102_Codes_SceneThink_Exit
#endregion

Snap102_Codes_SceneThink_UpdateMenu:
#Redraw Menu
  mr  r3,REG_GObjData
  bl  Snap102_Codes_CreateMenu
#Play SFX
  branchl r12,SFX_PlayMenuSound_CloseOpenPort
  b Snap102_Codes_SceneThink_Exit

Snap102_Codes_SceneThink_Exit:
  restore
  blr
#endregion
#region Snap102_Codes_SceneDecide
Snap102_Codes_SceneDecide:
  backup

#Change Major
  li  r3,ExitSceneID
  branchl r12,MenuController_WriteToPendingMajor
#Leave Major
  branchl r12,MenuController_ChangeScreenMajor

Snap102_Codes_SceneDecide_Exit:
  restore
  blr
############################################
#endregion
#region Snap102_Codes_CreateMenu
Snap102_Codes_CreateMenu:
.set  REG_GObjData,31
.set  REG_TextGObj,30
.set  REG_TextProp,29

#Init
  backup
  mr  REG_GObjData,r3
  bl  Snap102_Codes_SceneLoad_TextProperties
  mflr  REG_TextProp

#Remove old text gobjs if they exist
  lwz r3,OFST_CodeNamesTextGObj(REG_GObjData)
  cmpwi r3,0
  beq Snap102_Codes_CreateMenu_SkipNameRemoval
  branchl r12,Text_RemoveText
Snap102_Codes_CreateMenu_SkipNameRemoval:
  lwz r3,OFST_CodeOptionsTextGObj(REG_GObjData)
  cmpwi r3,0
  beq Snap102_Codes_CreateMenu_SkipOptionRemoval
  branchl r12,Text_RemoveText
Snap102_Codes_CreateMenu_SkipOptionRemoval:

#region CreateTextGObjs
Snap102_Codes_CreateMenu_CreateTextGObjs:
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
#region Snap102_Codes_CreateMenu_CreateNames
Snap102_Codes_CreateMenu_CreateNamesInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
  li  REG_Count,0
Snap102_Codes_CreateMenu_CreateNamesLoop:
#Next name to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add r3,r3,REG_Count
#Get the string bl pointer
  bl  Snap102_CodeNames_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  Snap102_ConvertBlPointer
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
Snap102_Codes_CreateMenu_CreateNamesIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge Snap102_Codes_CreateMenu_CreateNameLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt Snap102_Codes_CreateMenu_CreateNamesLoop
Snap102_Codes_CreateMenu_CreateNameLoopEnd:
#endregion
#region Snap102_Codes_CreateMenu_CreateOptions
Snap102_Codes_CreateMenu_CreateOptionsInit:
#Loop through and draw code names
.set  REG_Count,20
.set  REG_SubtextID,21
.set  REG_CurrentOptionID,22
.set  REG_CurrentOptionSelection,23
.set  REG_OptionStrings,24
.set  REG_StringLoopCount,25
  li  REG_Count,0
Snap102_Codes_CreateMenu_CreateOptionsLoop:
#Next option to draw is scroll + Count
  lhz r3,OFST_ScrollAmount(REG_GObjData)
  add REG_CurrentOptionID,r3,REG_Count
#Get the bl pointer
  mr  r3,REG_CurrentOptionID
  bl  Snap102_CodeOptions_Order
  mflr  r4
  mulli r3,r3,0x4
  add  r3,r3,r4
#Convert bl pointer to mem address
  bl  Snap102_ConvertBlPointer
  lwz r4,Snap102_CodeOptions_OptionCount(r3)
  addi  r4,r4,1
  addi  REG_OptionStrings,r3,Snap102_CodeOptions_GeckoCodePointers  #Get pointer to gecko code pointers
  mulli r4,r4,0x4                                           #pointer length
  add REG_OptionStrings,REG_OptionStrings,r4
#Get this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx  REG_CurrentOptionSelection,r3,REG_CurrentOptionID

#Loop through strings and get the current one
  li  REG_StringLoopCount,0
Snap102_Codes_CreateMenu_CreateOptionsLoop_StringSearch:
  cmpw  REG_StringLoopCount,REG_CurrentOptionSelection
  beq Snap102_Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd
#Get next string
  mr  r3,REG_OptionStrings
  branchl r12,strlen
  add REG_OptionStrings,REG_OptionStrings,r3
  addi  REG_OptionStrings,REG_OptionStrings,1       #add 1 to skip past the 0 terminator
  addi  REG_StringLoopCount,REG_StringLoopCount,1
  b Snap102_Codes_CreateMenu_CreateOptionsLoop_StringSearch

Snap102_Codes_CreateMenu_CreateOptionsLoop_StringSearchEnd:
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
  bl  Snap102_CodeOptions_Wrapper
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
Snap102_Codes_CreateMenu_CreateOptionsIncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  bge Snap102_Codes_CreateMenu_CreateOptionsLoopEnd
  cmpwi REG_Count,MaxCodesOnscreen
  blt Snap102_Codes_CreateMenu_CreateOptionsLoop
Snap102_Codes_CreateMenu_CreateOptionsLoopEnd:
#endregion
#region Snap102_Codes_CreateMenu_HighlightCursor
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
#region Snap102_Codes_CreateMenu_ChangeCodeDescription
#Get highlighted code ID
	lhz r3,OFST_ScrollAmount(REG_GObjData)
	lhz r4,OFST_CursorLocation(REG_GObjData)
	add	r3,r3,r4
#Get this codes options
	bl	Snap102_CodeOptions_Order
	mflr	r4
	mulli	r3,r3,0x4
	add	r3,r3,r4
	bl	Snap102_ConvertBlPointer
#Get this codes description
	addi	r3,r3,Snap102_CodeOptions_CodeDescription
	bl	Snap102_ConvertBlPointer
	lwz	r4,OFST_CodeDescTextGObj(REG_GObjData)
#Store to text gobj
	stw	r3,0x5C(r4)
#endregion

Snap102_Codes_CreateMenu_Exit:
  restore
  blr

###############################################

Snap102_ConvertBlPointer:
  lwz r4,0x0(r3)        #Load bl instruction
  rlwinm  r4,r4,0,6,29  #extract offset bits
	rlwinm	r5,r4,7,31,31		#Get signed bit
	lis	r6,0xFC00
	mullw	r5,r5,r6
	or	r4,r4,r5
  add r3,r4,r3
  blr

#endregion
#region Snap102_ApplyAllGeckoCodes
Snap102_ApplyAllGeckoCodes:
.set  REG_GObjData,31
.set  REG_Count,30
.set  REG_OptionSelection,29
#Init
  backup
  mr  REG_GObjData,r3

#Check if LCD reduction was enabled
	load	r3,VI_Struct
	lwz	r3,0x1DC(r3)
	load	r4,RenewInputs_Prefunction
	cmpw	r3,r4
	beq	Snap102_ApplyAllGeckoCodes_DefaultCodes
#Polling Drift Fix
  bl  Snap102_LagReduction_PD
  mflr  r3
  bl  Snap102_ApplyGeckoCode
#Reset some pad variables to cancel the current alarm
  load  r3,UnkPadStruct
  li  r4,0
  stw r4,0x4(r3)
  stw r4,0x44(r3)

Snap102_ApplyAllGeckoCodes_DefaultCodes:
#Default Codes
  bl  Snap102_DefaultCodes_On
  mflr  r3
  bl  Snap102_ApplyGeckoCode

#Default Codes
  bl  Snap102_DefaultCodes_On
  mflr  r3
  bl  Snap102_ApplyGeckoCode

#Init Loop
  li  REG_Count,0
ApplyAllGeckoSnap102_Codes_Loop:
#Load this options value
  addi  r3,REG_GObjData,OFST_OptionSelections
  lbzx REG_OptionSelection,r3,REG_Count
#Get this code's default gecko code pointer
  bl  Snap102_CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  Snap102_ConvertBlPointer
  addi  r3,r3,Snap102_CodeOptions_GeckoCodePointers
  bl  Snap102_ConvertBlPointer
  bl  Snap102_ApplyGeckoCode
#Get this code's gecko code pointers
  bl  Snap102_CodeOptions_Order
  mflr  r3
  mulli r4,REG_Count,0x4
  add r3,r3,r4
  bl  Snap102_ConvertBlPointer
  addi  r3,r3,Snap102_CodeOptions_GeckoCodePointers
  mulli r4,REG_OptionSelection,0x4
  add  r3,r3,r4
  bl  Snap102_ConvertBlPointer
  bl  Snap102_ApplyGeckoCode

ApplyAllGeckoSnap102_Codes_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,CodeAmount
  blt ApplyAllGeckoSnap102_Codes_Loop

ApplyAllGeckoSnap102_Codes_Exit:
  restore
  blr

####################################

Snap102_ApplyGeckoCode:
.set  REG_GeckoCode,12
  mr  REG_GeckoCode,r3

Snap102_ApplyGeckoCode_Loop:
  lbz r3,0x0(REG_GeckoCode)
  cmpwi r3,0xC2
  beq Snap102_ApplyGeckoCode_C2
  cmpwi r3,0x4
  beq Snap102_ApplyGeckoCode_04
  cmpwi r3,0xFF
  beq Snap102_ApplyGeckoCode_Exit
  b Snap102_ApplyGeckoCode_Exit
Snap102_ApplyGeckoCode_C2:
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
  b Snap102_ApplyGeckoCode_Loop
Snap102_ApplyGeckoCode_04:
  lwz r3,0x0(REG_GeckoCode)
  rlwinm r3,r3,0,8,31
  oris  r3,r3,0x8000
  lwz r4,0x4(REG_GeckoCode)
  stw r4,0x0(r3)
  addi REG_GeckoCode,REG_GeckoCode,0x8
  b Snap102_ApplyGeckoCode_Loop
Snap102_ApplyGeckoCode_Exit:
blr

#endregion

#endregion

#region LagPrompt

#region Snap102_LagPrompt_SceneLoad
############################################

#region Snap102_LagPrompt_SceneLoad_Data
Snap102_LagPrompt_SceneLoad_TextProperties:
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

Snap102_LagPrompt_SceneLoad_TopText:
blrl
.if isPAL==1
.ascii "Are you using HDMI?"
.align 2
.endif
.if isPAL==0
.ascii "Are you using HDMI"
.hword 0x8148
.byte 0x00
.align 2
.endif

Snap102_LagPrompt_SceneLoad_Yes:
blrl
.string "Yes"
.align 2

Snap102_LagPrompt_SceneLoad_No:
blrl
.string "No"
.align 2

#GObj Offsets
  .set OFST_TextGObj,0x0
  .set OFST_Selection,0x4

#endregion
#region Snap102_LagPrompt_SceneLoad
Snap102_LagPrompt_SceneLoad:
blrl

#Init
  backup

Snap102_LagPrompt_SceneLoad_CreateText:
.set REG_GObjData,27
.set REG_GObj,28
.set REG_SubtextID,29
.set REG_TextProp,30
.set REG_TextGObj,31

#GET PROPERTIES TABLE
	bl Snap102_LagPrompt_SceneLoad_TextProperties
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
	bl Snap102_LagPrompt_SceneLoad_TopText
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
	bl Snap102_LagPrompt_SceneLoad_Yes
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
	bl Snap102_LagPrompt_SceneLoad_No
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
  bl  Snap102_LagPrompt_SceneThink
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

Snap102_LagPrompt_SceneLoad_Exit:
  restore
  blr
#endregion

############################################
#endregion
#region Snap102_LagPrompt_SceneThink
Snap102_LagPrompt_SceneThink:
blrl

.set REG_TextProp,28
.set REG_Inputs,29
.set REG_GObjData,30
.set REG_GObj,31

#Init
  backup
  mr  REG_GObj,r3
  lwz REG_GObjData,0x2C(REG_GObj)
  bl  Snap102_LagPrompt_SceneLoad_TextProperties
  mflr  REG_TextProp

#region Adjust Selection
#Adjust Menu Choice
#Get all player inputs
  li  r3,4
  branchl r12,Inputs_GetPlayerRapidHeldInputs
  mr  REG_Inputs,r3
#Check for movement to the right
  rlwinm. r0,REG_Inputs,0,0x80
  beq Snap102_LagPrompt_SceneThink_SkipRight
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  addi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,1
  ble Snap102_LagPrompt_SceneThink_HighlightSelection
  li  r3,1
  stb r3,OFST_Selection(REG_GObjData)
  b Snap102_LagPrompt_SceneThink_CheckForA
Snap102_LagPrompt_SceneThink_SkipRight:
#Check for movement to the left
  rlwinm. r0,REG_Inputs,0,0x40
  beq Snap102_LagPrompt_SceneThink_CheckForA
#Adjust cursor
  lbz r3,OFST_Selection(REG_GObjData)
  subi  r3,r3,1
  stb r3,OFST_Selection(REG_GObjData)
  extsb r3,r3
  cmpwi r3,0
  bge Snap102_LagPrompt_SceneThink_HighlightSelection
  li  r3,0
  stb r3,OFST_Selection(REG_GObjData)
  b Snap102_LagPrompt_SceneThink_CheckForA

Snap102_LagPrompt_SceneThink_HighlightSelection:
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
Snap102_LagPrompt_SceneThink_CheckForA:
  li  r3,4
  branchl r12,Inputs_GetPlayerInstantInputs
  rlwinm. r0,r4,0,0x100
  bne Snap102_LagPrompt_SceneThink_Confirmed
  rlwinm. r0,r4,0,0x1000
  bne Snap102_LagPrompt_SceneThink_Confirmed
  b Snap102_LagPrompt_SceneThink_Exit
Snap102_LagPrompt_SceneThink_Confirmed:
#Play Menu Sound
  branchl r12,SFX_PlayMenuSound_Forward
#If yes, apply lag reduction
  lbz r3,OFST_Selection(REG_GObjData)
  cmpwi r3,0
  bne Snap102_LagPrompt_SceneThink_ExitScene
#endregion
#region Apply Code
.set  REG_GeckoCode,12
#Apply lag reduction
  bl  Snap102_LagReduction_LCD
  mflr  r3
  bl  Snap102_ApplyGeckoCode
#Reset some pad variables to cancel the current alarm
  load  r3,UnkPadStruct
  li  r4,0
  stw r4,0x4(r3)
  stw r4,0x44(r3)
#Set new post retrace callback
  load  r3,PostRetraceCallback
  branchl r12,HSD_VISetUserPostRetraceCallback
#Enable progressive
  load  r3,ProgressiveStruct
  li  r0,1
  stw r0,0x8(r3)
  branchl r12,Deflicker_Toggle
.if isPAL==1
#Enable PAL60
	load	r3,ProgressiveStruct
	li	r4,1
	stw	r4,0xC(r3)
.endif
#Call VIConfigure
	li	r3,0	#disables deflicker and will enable 480p because of the gecko code
	branchl	r12,ScreenDisplay_Adjust
#Now flush the instruction cache
  lis r3,0x8000
  load r4,0x3b722c    #might be overkill but flush the entire dol file
  branchl r12,TRK_flush_cache
#endregion

Snap102_LagPrompt_SceneThink_ExitScene:
  branchl r12,MenuController_ChangeScreenMinor

Snap102_LagPrompt_SceneThink_Exit:
  restore
  blr
#endregion
#region Snap102_LagPrompt_SceneDecide
Snap102_LagPrompt_SceneDecide:

  backup

#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  Snap102_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)

#Enter Codes Scene
  li  r3,CodesSceneID
  branchl r12,MenuController_WriteToPendingMajor
#Change Major
  branchl r12,MenuController_ChangeScreenMajor

Snap102_LagPrompt_SceneDecide_Exit:
  restore
  blr
############################################
#endregion

#endregion

#region MinorSceneStruct
Snap102_LagPrompt_MinorSceneStruct:
blrl
#Lag Prompt
.byte 0                     #Minor Scene ID
.byte 2                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  Snap102_LagPrompt_SceneDecide   #SceneDecide
.byte PromptCommonSceneID   #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

Snap102_Codes_MinorSceneStruct:
blrl
#Codes Prompt
.byte 0                     #Minor Scene ID
.byte 2                    #Amount of persistent heaps
.align 2
.long 0x00000000            #ScenePrep
bl  Snap102_Codes_SceneDecide       #SceneDecide
.byte CodesCommonSceneID    #Common Minor ID
.align 2
.long 0x00000000            #Minor Data 1
.long 0x00000000            #Minor Data 2
#End
.byte -1
.align 2

#endregion

Snap102_CheckProgressive:

#Check if progressive is enabled
  lis	r3,0xCC00
	lhz	r3,0x206E(r3)
	rlwinm.	r3,r3,0,0x1
  beq Snap102_NoProgressive

Snap102_IsProgressive:
#Override SceneLoad
  li  r3,PromptCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  Snap102_LagPrompt_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Hijack the MajorScene load functions register (VERY HACKY)
	bl	Snap102_LagPrompt_MinorSceneStruct
	mflr	r3
	stw	r3,0x114(sp)
#Load LagPrompt
  li	r3, PromptSceneID
  b Snap102_Exit
Snap102_NoProgressive:
#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  Snap102_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Hijack the MajorScene load functions register (VERY HACKY)
	bl	Snap102_Codes_MinorSceneStruct
	mflr	r3
	stw	r3,0x114(sp)
#Load Codes
  li  r3,CodesSceneID

Snap102_Exit:
#Store as next scene
	branchl r12,MenuController_WriteToPendingMajor
#request to change scenes
	branchl	r12,MenuController_ChangeScreenMinor

##########
## Exit ##
##########

#Return to the game
  restore
	li	r0,2
	blr

#region Gecko Codes

#endregion
#region Code Descriptions
Snap102_UCF_Description:
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
	.long 0x0820e719
	.long 0x0F0D0000
Snap102_Frozen_Description:
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
Snap102_Spawns_Description:
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
Snap102_DisableWobbling_Description:
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
Snap102_Ledgegrab_Description:
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
	.long 0x0420051a
	.long 0x202f2028
	.long 0x2027202a
	.long 0x2028202a
	.long 0x20352024
	.long 0x20252036
	.long 0x20e7190F
	.long 0x0D000000
Snap102_TournamentQoL_Description:
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
Snap102_FriendliesQoL_Description:
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
Snap102_GameVersion_Description:
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
Snap102_StageExpansion_Description:
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
Snap102_Widescreen_Description:
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

MMLCode102_End:
blrl
#endregion
#region SnapshotCode101
.include "../../Common101.s"

MMLCode101_Start:
blrl

SnapshotCode101_Start:

#Clear nametag region
	lwz	r3,OFST_Memcard(r13)
	addi	r3,r3,OFST_NametagStart
	li r4,0
	load r5,Nametag_Length
	branchl  r12,memset

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
.string "MultiMod Launcher v0.76"
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
	bl  Snap101_GameVersion_PAL
	bl  Snap101_GameVersion_SDR
	.string "NTSC"
	.string "PAL"
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
	addi r4,r4,ModOFST_ModDataStart + ModOFST_ModDataPrefs
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
	addi r3,r3,ModOFST_ModDataStart + ModOFST_ModDataPrefs
	addi	r4,REG_GObjData,OFST_OptionSelections
	li	r5,0x18
	branchl	r12,memcpy
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

#Check if LCD reduction was enabled
	load	r3,VI_Struct
	lwz	r3,0x1DC(r3)
	load	r4,RenewInputs_Prefunction
	cmpw	r3,r4
	beq	Snap101_ApplyAllGeckoCodes_DefaultCodes
#Polling Drift Fix
  bl  Snap101_LagReduction_PD
  mflr  r3
  bl  Snap101_ApplyGeckoCode
#Reset some pad variables to cancel the current alarm
  load  r3,UnkPadStruct
  li  r4,0
  stw r4,0x4(r3)
  stw r4,0x44(r3)

Snap101_ApplyAllGeckoCodes_DefaultCodes:
#Default Codes
  bl  Snap101_DefaultCodes_On
  mflr  r3
  bl  Snap101_ApplyGeckoCode

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
.if isPAL==1
.ascii "Are you using HDMI?"
.align 2
.endif
.if isPAL==0
.ascii "Are you using HDMI"
.hword 0x8148
.byte 0x00
.align 2
.endif

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
  bl  Snap101_LagReduction_LCD
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
#Enable progressive
  load  r3,ProgressiveStruct
  li  r0,1
  stw r0,0x8(r3)
  branchl r12,Deflicker_Toggle
.if isPAL==1
#Enable PAL60
	load	r3,ProgressiveStruct
	li	r4,1
	stw	r4,0xC(r3)
.endif
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

#endregion

#region MinorSceneStruct
Snap101_LagPrompt_MinorSceneStruct:
blrl
#Lag Prompt
.byte 0                     #Minor Scene ID
.byte 2                    #Amount of persistent heaps
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
.byte 2                    #Amount of persistent heaps
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
#Hijack the MajorScene load functions register (VERY HACKY)
	bl	Snap101_LagPrompt_MinorSceneStruct
	mflr	r3
	stw	r3,0x114(sp)
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
#Hijack the MajorScene load functions register (VERY HACKY)
	bl	Snap101_Codes_MinorSceneStruct
	mflr	r3
	stw	r3,0x114(sp)
#Load Codes
  li  r3,CodesSceneID

Snap101_Exit:
#Store as next scene
	branchl r12,MenuController_WriteToPendingMajor
#request to change scenes
	branchl	r12,MenuController_ChangeScreenMinor

##########
## Exit ##
##########

#Return to the game
  restore
	li	r0,2
	blr

#region Gecko Codes
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
	.long 0x0820e719
	.long 0x0F0D0000
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
	.long 0x0420051a
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

MMLCode101_End:
blrl
#endregion
#region SnapshotCode100
.include "../../Common100.s"

MMLCode100_Start:
blrl

SnapshotCode100_Start:

#Clear nametag region
	lwz	r3,OFST_Memcard(r13)
	addi	r3,r3,OFST_NametagStart
	li r4,0
	load r5,Nametag_Length
	branchl  r12,memset

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
.string "MultiMod Launcher v0.76"
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
	bl  Snap100_GameVersion_PAL
	bl  Snap100_GameVersion_SDR
	.string "NTSC"
	.string "PAL"
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
	addi r4,r4,ModOFST_ModDataStart + ModOFST_ModDataPrefs
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
	addi r3,r3,ModOFST_ModDataStart + ModOFST_ModDataPrefs
	addi	r4,REG_GObjData,OFST_OptionSelections
	li	r5,0x18
	branchl	r12,memcpy
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

#Check if LCD reduction was enabled
	load	r3,VI_Struct
	lwz	r3,0x1DC(r3)
	load	r4,RenewInputs_Prefunction
	cmpw	r3,r4
	beq	Snap100_ApplyAllGeckoCodes_DefaultCodes
#Polling Drift Fix
  bl  Snap100_LagReduction_PD
  mflr  r3
  bl  Snap100_ApplyGeckoCode
#Reset some pad variables to cancel the current alarm
  load  r3,UnkPadStruct
  li  r4,0
  stw r4,0x4(r3)
  stw r4,0x44(r3)

Snap100_ApplyAllGeckoCodes_DefaultCodes:
#Default Codes
  bl  Snap100_DefaultCodes_On
  mflr  r3
  bl  Snap100_ApplyGeckoCode

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
.if isPAL==1
.ascii "Are you using HDMI?"
.align 2
.endif
.if isPAL==0
.ascii "Are you using HDMI"
.hword 0x8148
.byte 0x00
.align 2
.endif

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
  bl  Snap100_LagReduction_LCD
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
#Enable progressive
  load  r3,ProgressiveStruct
  li  r0,1
  stw r0,0x8(r3)
  branchl r12,Deflicker_Toggle
.if isPAL==1
#Enable PAL60
	load	r3,ProgressiveStruct
	li	r4,1
	stw	r4,0xC(r3)
.endif
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

#endregion

#region MinorSceneStruct
Snap100_LagPrompt_MinorSceneStruct:
blrl
#Lag Prompt
.byte 0                     #Minor Scene ID
.byte 2                    #Amount of persistent heaps
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
.byte 2                    #Amount of persistent heaps
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
#Hijack the MajorScene load functions register (VERY HACKY)
	bl	Snap100_LagPrompt_MinorSceneStruct
	mflr	r3
	stw	r3,0x114(sp)
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
#Hijack the MajorScene load functions register (VERY HACKY)
	bl	Snap100_Codes_MinorSceneStruct
	mflr	r3
	stw	r3,0x114(sp)
#Load Codes
  li  r3,CodesSceneID

Snap100_Exit:
#Store as next scene
	branchl r12,MenuController_WriteToPendingMajor
#request to change scenes
	branchl	r12,MenuController_ChangeScreenMinor

##########
## Exit ##
##########

#Return to the game
  restore
	li	r0,2
	blr

#region Gecko Codes
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
	.long 0x0820e719
	.long 0x0F0D0000
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
	.long 0x0420051a
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

MMLCode100_End:
blrl
#endregion
#region SnapshotCodePAL
.include "../../CommonPAL.s"

MMLCodePAL_Start:
blrl

SnapshotCodePAL_Start:

#Clear nametag region
	lwz	r3,OFST_Memcard(r13)
	addi	r3,r3,OFST_NametagStart
	li r4,0
	load r5,Nametag_Length
	branchl  r12,memset

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
.string "MultiMod Launcher v0.76"
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
.if isPAL==0
	.short 0x8183
	.ascii "%s"
	.short 0x8184
	.byte 0
	.align 2
.endif
.if isPAL==1
	.string "(%s)"
	.align 2
.endif
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
	addi r4,r4,ModOFST_ModDataStart + ModOFST_ModDataPrefs
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
	addi r3,r3,ModOFST_ModDataStart + ModOFST_ModDataPrefs
	addi	r4,REG_GObjData,OFST_OptionSelections
	li	r5,0x18
	branchl	r12,memcpy
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

#Check if LCD reduction was enabled
	load	r3,VI_Struct
	lwz	r3,0x1DC(r3)
	load	r4,RenewInputs_Prefunction
	cmpw	r3,r4
	beq	SnapPAL_ApplyAllGeckoCodes_DefaultCodes
#Polling Drift Fix
  bl  SnapPAL_LagReduction_PD
  mflr  r3
  bl  SnapPAL_ApplyGeckoCode
#Reset some pad variables to cancel the current alarm
  load  r3,UnkPadStruct
  li  r4,0
  stw r4,0x4(r3)
  stw r4,0x44(r3)

SnapPAL_ApplyAllGeckoCodes_DefaultCodes:
#Default Codes
  bl  SnapPAL_DefaultCodes_On
  mflr  r3
  bl  SnapPAL_ApplyGeckoCode

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
.if isPAL==1
.ascii "Are you using HDMI?"
.align 2
.endif
.if isPAL==0
.ascii "Are you using HDMI"
.hword 0x8148
.byte 0x00
.align 2
.endif

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
  bl  SnapPAL_LagReduction_LCD
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
#Enable progressive
  load  r3,ProgressiveStruct
  li  r0,1
  stw r0,0x8(r3)
  branchl r12,Deflicker_Toggle
.if isPAL==1
#Enable PAL60
	load	r3,ProgressiveStruct
	li	r4,1
	stw	r4,0xC(r3)
.endif
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

#endregion

#region MinorSceneStruct
SnapPAL_LagPrompt_MinorSceneStruct:
blrl
#Lag Prompt
.byte 0                     #Minor Scene ID
.byte 2                    #Amount of persistent heaps
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
.byte 2                    #Amount of persistent heaps
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
#Hijack the MajorScene load functions register (VERY HACKY)
	bl	SnapPAL_LagPrompt_MinorSceneStruct
	mflr	r3
	stw	r3,0x114(sp)
#Load LagPrompt
  li	r3, PromptSceneID
  b SnapPAL_Exit
SnapPAL_NoProgressive:
#Override SceneLoad
  li  r3,CodesCommonSceneID
  branchl r12,Scene_MinorIDToMinorSceneFunctionTable
  bl  SnapPAL_Codes_SceneLoad
  mflr  r4
  stw r4,0x8(r3)
#Hijack the MajorScene load functions register (VERY HACKY)
	bl	SnapPAL_Codes_MinorSceneStruct
	mflr	r3
	stw	r3,0x114(sp)
#Load Codes
  li  r3,CodesSceneID

SnapPAL_Exit:
#Store as next scene
	branchl r12,MenuController_WriteToPendingMajor
#request to change scenes
	branchl	r12,MenuController_ChangeScreenMinor

##########
## Exit ##
##########

#Return to the game
  restore
	li	r0,2
	blr

#region Gecko Codes
#endregion
#region Code Descriptions
SnapPAL_UCF_Description:
  .byte 0x16,0x0c,0xff,0xff,0xff,0x0e,0x00,0xac,0x00,0xb3,0x12
  .ascii "Fixes controller disparities with dashback and "
  .byte 0x03
  .ascii "shield drop. Current version is 0.8."
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
  .ascii "with under 45 ledgegrabs."
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

MMLCodePAL_End:
blrl

#endregion

SnapshotCode_End:
blrl

ExitInjection:
#Exit
  restore
  blr

SnapshotBanner:
	blrl
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x89, 0xd6, 0x80, 0x00, 0x80, 0x00, 0x85, 0x50, 0x8e, 0x18
	.byte 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x85, 0x0e, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0xec, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x80, 0x00, 0x89, 0xf7, 0x8e, 0x18, 0x8e, 0x18, 0x89, 0xd5, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0xa8, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x89, 0x72, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x66, 0x8e, 0x18
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x89, 0x93, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x80, 0x00, 0x85, 0x2f, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x85, 0x0e, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x85, 0x71, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0xec
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x89, 0xb4, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0xa8
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x80, 0xca, 0x80, 0x00, 0x8e, 0x18, 0x89, 0xd6, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x43, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x2f, 0x8e, 0x18, 0x8e, 0x18, 0x89, 0x93, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x86, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x89, 0xd6, 0x85, 0x2f, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x23
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x85, 0x0d, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xd6, 0xb5
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xca, 0x52, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xca, 0x52, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xf7, 0xbd
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x98, 0xc6, 0xd6, 0xb5, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8d, 0xf7, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x0d, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x89, 0xd6
	.byte 0x85, 0x2e, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x89, 0x93, 0x85, 0x71, 0x85, 0x50, 0xff, 0xff
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0xff, 0xff, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0x80, 0x87, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x85, 0x72, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0xf3, 0x9c, 0xef, 0x7b, 0x80, 0x00, 0xd6, 0xb5, 0xff, 0xff, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0xc6, 0x31, 0xb1, 0x8c, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xad, 0x6b, 0xd6, 0xb5
	.byte 0x80, 0x00, 0x80, 0x00, 0xc6, 0x31, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xc6, 0x31, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xf3, 0x9c, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xd6, 0xb5, 0xca, 0x52, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xef, 0x7b, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xef, 0x7b, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x89, 0xb4, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x4f, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff
	.byte 0xff, 0xff, 0xff, 0xff, 0xca, 0x52, 0x80, 0x00, 0xff, 0xff, 0xfb, 0xde, 0xff, 0xff, 0x80, 0x00
	.byte 0xff, 0xff, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0xfb, 0xde, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xf3, 0x9c, 0xff, 0xff
	.byte 0x80, 0x00, 0xe3, 0x18, 0xff, 0xff, 0x80, 0x00, 0xde, 0xf7, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xe7, 0x39, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0xe7, 0x39, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xe7, 0x39, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0xa5, 0x29, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0xa5, 0x29, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00
	.byte 0xa5, 0x29, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0xa5, 0x29, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00
	.byte 0x80, 0x00, 0x85, 0x71, 0xba, 0x9a, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xba, 0x9a, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0xba, 0x9a, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xba, 0x9a, 0xff, 0xff
	.byte 0xc6, 0xba, 0x8e, 0x18, 0x8e, 0x18, 0xff, 0xff, 0xc6, 0xba, 0x8e, 0x18, 0x8e, 0x18, 0xff, 0xff
	.byte 0xc6, 0xba, 0x8e, 0x18, 0x8e, 0x18, 0xff, 0xff, 0xc6, 0xba, 0x8e, 0x18, 0x8e, 0x18, 0xff, 0xff
	.byte 0xff, 0xff, 0x8e, 0x18, 0xd6, 0xb5, 0xff, 0xff, 0xff, 0xff, 0x8e, 0x18, 0xa5, 0x29, 0xbd, 0xef
	.byte 0xff, 0xff, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x89, 0x72, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xbd, 0xef, 0xbd, 0xef
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0xc6, 0x31, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xc6, 0x31, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0xc6, 0x31, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xc6, 0x31, 0xff, 0xff
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xc2, 0x10, 0xff, 0xff, 0xd6, 0xb5, 0x80, 0x00
	.byte 0xa9, 0x4a, 0xff, 0xff, 0xff, 0xff, 0xbd, 0xef, 0xa9, 0x4a, 0xad, 0x6b, 0xff, 0xff, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0xef, 0x7b, 0xff, 0xff, 0x80, 0x00, 0x94, 0xa5, 0xff, 0xff, 0xda, 0xd6
	.byte 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0xf7, 0xbd, 0xff, 0xff, 0xda, 0xd6, 0x80, 0x00
	.byte 0xff, 0xff, 0xef, 0x7b, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xef, 0x7b, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xef, 0x7b, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xf3, 0x9c, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0xfb, 0xde, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xa9, 0x4a
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xf7, 0xbd, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0xfb, 0xde, 0x80, 0x00, 0xb1, 0x8c, 0xff, 0xff, 0xff, 0xff, 0xf7, 0xbd
	.byte 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0xeb, 0x5a, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff
	.byte 0x80, 0x00, 0xe7, 0x39, 0xff, 0xff, 0xa1, 0x08, 0x80, 0x00, 0xf3, 0x9c, 0xff, 0xff, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xeb, 0x5a, 0x80, 0x00, 0xde, 0xf7, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8d, 0xf8, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x89, 0x93
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x80, 0xcb, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x44, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0xec, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0xd2, 0x94
	.byte 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x9c, 0xe7
	.byte 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xd2, 0x94, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0xce, 0x73, 0x80, 0x00, 0xff, 0xff, 0xe3, 0x18, 0x80, 0x00, 0x80, 0x00
	.byte 0xd6, 0xb5, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xe7, 0x39, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xe3, 0x18, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0xe3, 0x18, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xbd, 0xef, 0xd2, 0x94, 0x80, 0x00, 0x80, 0x00
	.byte 0xa1, 0x08, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00
	.byte 0x80, 0x00, 0xef, 0x7b, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xda, 0xd6
	.byte 0x80, 0x00, 0x80, 0x00, 0xc6, 0xba, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xe7, 0x39, 0xc2, 0x10, 0x8e, 0x18, 0xd2, 0xfb
	.byte 0xc6, 0xba, 0x8e, 0x18, 0x8e, 0x18, 0xff, 0xff, 0xc6, 0xba, 0x80, 0x87, 0x80, 0x00, 0xff, 0xff
	.byte 0xc6, 0x76, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xa9, 0xd2, 0x80, 0x00, 0x80, 0x00, 0xd2, 0x94
	.byte 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xd2, 0x94, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0xb5, 0xad, 0xe3, 0x18, 0xca, 0x52
	.byte 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xd2, 0x94, 0xd2, 0x94
	.byte 0x80, 0x00, 0x80, 0x00, 0xc6, 0x31, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xc6, 0x31, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0xc6, 0x31, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xa9, 0x4a, 0xd2, 0x94
	.byte 0xa9, 0x4a, 0x80, 0x00, 0xf7, 0xbd, 0xff, 0xff, 0xa9, 0x4a, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff
	.byte 0xa9, 0x4a, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x98, 0xc6, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xbd, 0xef, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xf3, 0x9c, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xf3, 0x9c, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xf3, 0x9c, 0x80, 0x00, 0x80, 0x00, 0xd2, 0x94, 0xca, 0x52, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0xf3, 0x9c, 0x80, 0x00
	.byte 0xb9, 0xce, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xe3, 0x18
	.byte 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0xf3, 0x9c, 0xff, 0xff, 0xff, 0xff
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xad, 0x6b, 0xe3, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0xf3, 0x9c, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8c, 0x63, 0x80, 0x00, 0x80, 0x00, 0xfb, 0xde
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xd2, 0x94, 0xe3, 0x18, 0xb5, 0xad, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xd2, 0x94, 0xd2, 0x94, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8d, 0xf7, 0x89, 0xd6, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x89, 0x72, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8d, 0xf8, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xd6, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x89, 0xf7, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xd6, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xd6, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xd6, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xd6, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xd6, 0x89, 0xf7, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x89, 0xf7, 0x89, 0xf7, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x89, 0xf7, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x8e, 0x18, 0x80, 0x43, 0x80, 0x00
	.byte 0xff, 0xff, 0x8e, 0x18, 0x8e, 0x18, 0x89, 0x93, 0xff, 0xff, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xf3, 0x9c
	.byte 0x80, 0x00, 0x80, 0x00, 0xa9, 0x4a, 0xff, 0xff, 0x8d, 0xf8, 0x80, 0x00, 0xff, 0xff, 0xe3, 0x18
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xd2, 0x94, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xe7, 0x39, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xd6, 0xb5, 0x80, 0x00, 0xff, 0xff
	.byte 0xff, 0xff, 0xd6, 0xb5, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0xd6, 0xb5, 0x80, 0x00, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xeb, 0x5a, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xb5, 0xad, 0x80, 0x00, 0x80, 0x00, 0xe7, 0x39, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xf3, 0x9c, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xf3, 0x9c, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xf3, 0x9c, 0x80, 0x00, 0xca, 0x52, 0xda, 0xd6
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xf3, 0x9c, 0xff, 0xff, 0xfb, 0xde, 0xa5, 0x29
	.byte 0x98, 0xc6, 0x80, 0x00, 0x80, 0x00, 0xd6, 0xb5, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xeb, 0x5a, 0xff, 0xff, 0x80, 0x00
	.byte 0x80, 0x00, 0xeb, 0x5a, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xeb, 0x5a, 0xff, 0xff, 0xbd, 0xef
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xe7, 0x39, 0xff, 0xff, 0x80, 0x00
	.byte 0x80, 0x00, 0xe7, 0x39, 0xff, 0xff, 0x80, 0x00, 0xbd, 0xef, 0xef, 0x7b, 0xff, 0xff, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xbd, 0xef, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
	.byte 0xbd, 0xef, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xbd, 0xef, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0xd6, 0xb5, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0xef, 0x7b, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xd2, 0x94, 0xff, 0xff
	.byte 0x80, 0x00, 0x80, 0x00, 0x85, 0x50, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x80, 0x23, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0xec, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8d, 0xf8
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0xca, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x80, 0x65, 0x80, 0x00, 0x80, 0x00
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18
	.byte 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x89, 0xb4, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0xff, 0xff, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0xff, 0xff, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x85, 0x2f, 0xff, 0xff, 0xb5, 0xad, 0x8e, 0x18, 0xc2, 0x10, 0xff, 0xff, 0xff, 0xff
	.byte 0x89, 0xf7, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xb5, 0xad, 0xff, 0xff, 0x98, 0xc6, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0xf7, 0xbd, 0x80, 0x00
	.byte 0x80, 0x00, 0xa1, 0x08, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xf3, 0x9c, 0xa9, 0x4a, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0xff, 0xff, 0xfb, 0xde, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xd2, 0x94, 0x80, 0x00, 0xff, 0xff, 0xff, 0xff, 0x9c, 0xe7, 0x80, 0x00, 0xff, 0xff
	.byte 0xfb, 0xde, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xe7, 0x39, 0xbd, 0xef, 0xff, 0xff, 0xbd, 0xef, 0xe7, 0x39, 0x80, 0x00, 0xe3, 0x18, 0xff, 0xff
	.byte 0xe7, 0x39, 0x80, 0x00, 0x80, 0x00, 0xf7, 0xbd, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xf3, 0x9c, 0x80, 0x00, 0xd2, 0x94, 0xd2, 0x94, 0xf3, 0x9c, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff
	.byte 0xf3, 0x9c, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xc2, 0x10
	.byte 0xff, 0xff, 0xf7, 0xbd, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0xeb, 0x5a, 0xff, 0xff, 0xb9, 0xce, 0x80, 0x00, 0xeb, 0x5a, 0xff, 0xff, 0x80, 0x00
	.byte 0x80, 0x00, 0xeb, 0x5a, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xb9, 0xce, 0xef, 0x7b, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xe7, 0x39, 0xff, 0xff, 0x80, 0x00
	.byte 0x80, 0x00, 0xe7, 0x39, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xbd, 0xef, 0xff, 0xff, 0xb5, 0xad, 0xb5, 0xad, 0xbd, 0xef, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00
	.byte 0xbd, 0xef, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xb5, 0xad, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff
	.byte 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xb1, 0x8c, 0xad, 0x6b, 0xad, 0x6b, 0xfb, 0xde, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0xff, 0xff, 0xd2, 0x94, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0xeb, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x89, 0x94, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8d, 0xf8, 0x89, 0xb5, 0x80, 0x66, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x89, 0xb5, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x89, 0x93, 0x80, 0x00, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x85, 0x50, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8d, 0xf8, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x44, 0x8e, 0x18, 0x80, 0x00, 0x85, 0x2e, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x85, 0x0d, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x65, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x8e, 0x18, 0x8e, 0x18, 0x8e, 0x18, 0x8d, 0xf8, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00
	.byte 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00, 0x80, 0x00

SnapshotIcon:
	blrl
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01
	.byte 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x01, 0x01, 0x01
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x02, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00
	.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00
	.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x03, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x07, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01
	.byte 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00
	.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00
	.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x01
	.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x06
	.byte 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00
	.byte 0x05, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x01, 0x01
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x01
	.byte 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x01
	.byte 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
	.byte 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

#endregion

exit:
restore
li	r0, 16
