#To be inserted at 80225554
.include "../../Globals.s"

.set GObj_Create,0x803901f0
.set GObj_AddUserData,0x80390b68
.set GObj_AddProc,0x8038fd54
.set HSD_MemAlloc,0x8037f1e4
.set DevelopText_CreateDataTable,0x80302834
.set DevelopText_Activate,0x80302810
.set DevelopText_AddString,0x80302be4
.set DevelopText_FormatAndPrint,0x80302d4c
.set DevelopText_EraseAllText,0x80302bb0
.set DevelopMode_Text_ResetCursorXY,0x80302a3c
.set DevelopText_StoreBGColor,0x80302b90
.set DevelopText_HideText,0x80302b00
.set DevelopText_HideBG,0x80302ae0
.set DevelopText_ShowText,0x80302af0
.set DevelopText_ShowBG,0x80302ad0
.set DevelopText_StoreTextScale,0x80302b10
.set DevelopText_ResetCursorX,0x80302a88
.set sprintf,0x80323cf4

.set  WindowData_Text,0x0
.set  WindowData_State,0x4

.set  REG_DevelopText,31
.set  REG_GObjData,30
.set  REG_GObj,29

stw	r0, -0x4B7C (r13)

backup

#Create Rectangle
  li  r3,0x1000
  branchl r12,HSD_MemAlloc
  mr  r8,r3
  li  r3,12
  li  r4,0
  li  r5,0
  li  r6,39
  li  r7,10
  branchl r12,DevelopText_CreateDataTable
  mr  REG_DevelopText,r3
#Activate Text
  lwz	r3, -0x4884 (r13)
  mr  r4,REG_DevelopText
  branchl r12,DevelopText_Activate
#Hide blinking cursor
  li  r3,0
  stb r3,0x26(REG_DevelopText)
#Change BG Color
  mr  r3,REG_DevelopText
  bl  BGColor
  mflr  r4
  branchl r12,DevelopText_StoreBGColor
#Hide by default
  mr  r3,REG_DevelopText
  branchl r12,DevelopText_HideText
  mr  r3,REG_DevelopText
  branchl r12,DevelopText_HideBG
#Change Text Size
  mr  r3,REG_DevelopText
  bl  TextFloats
  mflr  r4
  lfs f1,0x0(r4)
  lfs f2,0x4(r4)
  branchl r12,DevelopText_StoreTextScale
#Create Background GObj
  li  r3,0
  li  r4,0
  li  r5,0
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
	load	r5,HSD_Free
	branchl r12,GObj_AddUserData
#Add Process
	mr	r3,REG_GObj
	bl	DebugLogThink
	mflr r4
	li	r5,7
  li  r6,0
  branchl r12,GObj_AddGXLink
	#branchl r12,GObj_AddProc
#Store pointer to dev text
  stw REG_DevelopText,WindowData_Text(REG_GObjData)
#Initialize State
  li  r3,0
  stw r3,WindowData_State(REG_GObjData)
  b Exit










########################################
TextFloats:
blrl
.float 7.5
.float 10
########################################










DebugLogThink:
blrl
.set  REG_GObjData,31
.set  REG_PlayerData,30
backup

#Only run during pass 0
  cmpwi r4,0
  bne DebugLogThink_Exit

lwz REG_GObjData,0x2C(r3)

#Check for state change
  bl GetInputs
  rlwinm. r0,r3,0,0x200
  beq DebugLogThink_StateChangeEnd
  bl GetInputs
  rlwinm. r0,r4,0,0x2
  beq DebugLogThink_StateChangeEnd
#Inc state
  lwz r3,WindowData_State(REG_GObjData)
  addi  r3,r3,1
  stw r3,WindowData_State(REG_GObjData)
  cmpwi r3,4
  ble DebugLogThink_ShowWindow
#Loop back to hidden
  li  r3,0
  stw r3,WindowData_State(REG_GObjData)
#Hide
  lwz r3,WindowData_Text(REG_GObjData)
  branchl r12,DevelopText_HideText
  lwz r3,WindowData_Text(REG_GObjData)
  branchl r12,DevelopText_HideBG
  b DebugLogThink_StateChangeEnd
DebugLogThink_ShowWindow:
#Show
  lwz r3,WindowData_Text(REG_GObjData)
  branchl r12,DevelopText_ShowText
  lwz r3,WindowData_Text(REG_GObjData)
  branchl r12,DevelopText_ShowBG
DebugLogThink_StateChangeEnd:

#Check to update text
  lwz r3,WindowData_State(REG_GObjData)
  cmpwi r3,0
  beq DebugLogThink_Exit

#Erase all text
  lwz  r3,WindowData_Text(REG_GObjData)
  branchl r12,DevelopText_EraseAllText
  lwz  r3,WindowData_Text(REG_GObjData)
  li  r4,0
  li  r5,0
  branchl r12,DevelopMode_Text_ResetCursorXY

#Output player number
  lwz  r3,WindowData_Text(REG_GObjData)
  bl  String_Player
  mflr r4
  lwz r5,WindowData_State(REG_GObjData)
  branchl r12,DevelopText_FormatAndPrint

#Get current player data
  lwz r3,WindowData_State(REG_GObjData)
  subi  r3,r3,1
  branchl r12,PlayerBlock_LoadMainCharDataOffset
  cmpwi r3,0
  beq DebugLogThink_Exit
#Backup data
  lwz  REG_PlayerData,0x2C(r3)

#vprintf string
  lwz  r3,WindowData_Text(REG_GObjData)
  bl  String_LStick
  mflr r4
  lfs f1,0x620(REG_PlayerData)
  lfs f2,0x624(REG_PlayerData)
  crset 6
  branchl r12,DevelopText_FormatAndPrint

#vprintf string
  lwz  r3,WindowData_Text(REG_GObjData)
  bl  String_RStick
  mflr r4
  lfs f1,0x638(REG_PlayerData)
  lfs f2,0x63C(REG_PlayerData)
  crset 6
  branchl r12,DevelopText_FormatAndPrint

#vprintf string
  lwz  r3,WindowData_Text(REG_GObjData)
  bl  String_CVel
  mflr r4
  lfs f1,0x80(REG_PlayerData)
  lfs f2,0x84(REG_PlayerData)
  crset 6
  branchl r12,DevelopText_FormatAndPrint
#vprintf string
  lwz  r3,WindowData_Text(REG_GObjData)
  bl  String_KBVel
  mflr r4
  lfs f1,0x8C(REG_PlayerData)
  lfs f2,0x90(REG_PlayerData)
  crset 6
  branchl r12,DevelopText_FormatAndPrint
#vprintf string
  lwz  r3,WindowData_Text(REG_GObjData)
  bl  String_Pos
  mflr r4
  lfs f1,0xB0(REG_PlayerData)
  lfs f2,0xB4(REG_PlayerData)
  crset 6
  branchl r12,DevelopText_FormatAndPrint

#Output ECB Lock info
  lwz  r3,WindowData_Text(REG_GObjData)
  bl  String_ECBLock
  mflr  r4
  lwz r5,0x88C(REG_PlayerData)
  crset 6
  branchl r12,DevelopText_FormatAndPrint
#Output ECB Bottom info
  lwz  r3,WindowData_Text(REG_GObjData)
  li  r4,18
  branchl r12,DevelopText_ResetCursorX
  lwz  r3,WindowData_Text(REG_GObjData)
  bl  String_ECBBottom
  mflr  r4
  lfs f1,0x780(REG_PlayerData)
  crset 6
  branchl r12,DevelopText_FormatAndPrint

#Output State info
  mr  r3,REG_PlayerData
  addi  r4,sp,0x88
  bl  GetStateInfo
  stfs  f1,0x80(sp)
  stfs  f2,0x84(sp)
  mr  r5,r3
  lwz  r3,WindowData_Text(REG_GObjData)
  bl  String_State
  mflr  r4
  crset 6
  branchl r12,DevelopText_FormatAndPrint
#Move cursor
  lwz  r3,WindowData_Text(REG_GObjData)
  li  r4,25
  branchl r12,DevelopText_ResetCursorX
#Output frames
  lwz  r3,WindowData_Text(REG_GObjData)
  bl  String_StateFrame
  mflr  r4
  lfs  f1,0x80(sp)
  lfs  f2,0x84(sp)
  crset 6
  branchl r12,DevelopText_FormatAndPrint

DebugLogThink_Exit:
restore
blr

#############################
String_Player:
blrl
.string "Player %d    X        Y\n"
.align 2
String_LStick:
blrl
.string "LStick:  %1.4f   %1.4f\n"
.align 2
String_RStick:
blrl
.string "RStick:  %1.4f   %1.4f\n"
.align 2
String_CVel:
blrl
.string "SelfVel: %3.4f   %3.4f\n"
.align 2
String_KBVel:
blrl
.string "KBVel:   %3.4f   %3.4f\n"
.align 2
String_XVel:
blrl
.string "XVel:    %3.4f   %3.4f\n"
.align 2
String_Pos:
blrl
.string "Pos:     %3.4f   %3.4f\n\n"
.align 2
String_State:
blrl
.string "State: %s"
.align 2
String_StateFrame:
blrl
.string "f: %03.2f/%1.0f"
.align 2
String_ECBBottom:
blrl
.string "ECB_Bot: %03.2f\n\n"
.align 2
String_ECBLock:
blrl
.string "ECB_Lock: %d"
.align 2


BGColor:
blrl
.byte 21,20,59,135
###############################














GetInputs:
.set  REG_InputStruct,11
.set  REG_Count,10
.set  REG_HeldInputs,9
.set  REG_InstantInputs,8

#Load Input Struct
  load  REG_InputStruct,0x804c1fac

#Init loop
  li  REG_Count,0
  li  REG_HeldInputs,0
  li  REG_InstantInputs,0
GetInputs_Loop:
#Get to inputs
  mulli r3,REG_Count,68
  add r5,r3,REG_InputStruct
#Grab Inputs
  lwz r3,0x0(r5)
  lwz r4,0xC(r5)
#OR all inputs
  or  REG_HeldInputs,REG_HeldInputs,r3
  or  REG_InstantInputs,REG_InstantInputs,r4
#Inc
  addi  REG_Count,REG_Count,1
  cmpwi REG_Count,4
  blt GetInputs_Loop
GetInputs_Exit:
  mr  r3,REG_HeldInputs
  mr  r4,REG_InstantInputs
  blr
######################################
GetStateInfo:
.set REG_PlayerData,31
.set REG_StateString,30

backup

  mr  REG_PlayerData,r3
  mr  REG_StateString,r4

#Check if common move
  lwz r3,0x10(REG_PlayerData)
  cmpwi r3,341
  bge GetStateInfo_SpecialMove

GetStateInfo_SharedMove:
  mulli r3,r3,4
  lwz	r4, -0x4B78 (r13)
  lwzx  r4,r3,r4
  mr  r3,REG_StateString
  branchl r12,strcpy
  b GetStateInfo_GetRemainingFrames

GetStateInfo_SpecialMove:
#Get Animation Data Pointer
  mr	r3,REG_PlayerData
  lwz	r4,0x14(REG_PlayerData)
  branchl	r12,0x80085fd4

#Get Move Name String
  lwz	r3,0x0(r3)
  cmpwi r3,0
  beq GetStateInfo_Unknown
#Get Start of Move Name
GetStateInfo_StringSearchLoop:
  lbzu	r4,0x1(r3)
  cmpwi	r4,0x4E		#Check For "N"
  bne	GetStateInfo_StringSearchLoop
  lbzu	r4,0x1(r3)
  cmpwi	r4,0x5F		#Check for Underscore
  bne	GetStateInfo_StringSearchLoop
  addi	r3,r3,0x1		#Start of Move Name in r3
#Copy Move Name To Cut Off "fiagtree" Text
  subi	r4,REG_StateString,0x1
  subi	r3,r3,0x1
  GetStateInfo_StringCopyLoop:
  lbzu	r6,0x1(r3)
  cmpwi	r6,0x5F		#Check for Underscore
  beq	GetStateInfo_ExitCopyLoop
  stbu	r6,0x1(r4)
  b	GetStateInfo_StringCopyLoop
GetStateInfo_ExitCopyLoop:
  li	r3,0x0
  stbu	r3,0x1(r4)
  b GetStateInfo_GetRemainingFrames
GetStateInfo_Unknown:
  bl  GetStateInfo_UnkString
  mflr  r4
  mr  r3,REG_StateString
  branchl r12,strcpy

GetStateInfo_GetRemainingFrames:
#Get Remaining Frames
	lwz  r3,0x590(REG_PlayerData)			#get anim data
	lfs  f2,0x008(r3)			#get anim length (float)

GetStateInfo_Exit:
  mr  r3,REG_StateString
  lfs f1,0x894(REG_PlayerData)
  restore
  blr
##########################################
GetStateInfo_UnkString:
blrl
.string "UnkState"
.align 2
##########################################

Exit:
restore
