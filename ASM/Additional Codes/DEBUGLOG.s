#To be inserted at 801a4cb4
.include "../Globals.s"

.set GObj_Create,0x803901f0
.set GObj_AddUserData,0x80390b68
.set GObj_AddProc,0x8038fd54
.set HSD_MemAlloc,0x8037f1e4
.set DevelopText_CreateDataTable,0x80302834
.set DevelopText_Activate,0x80302810
.set DevelopText_AddString,0x80302be4
.set DevelopText_EraseAllText,0x80302bb0
.set DevelopMode_Text_ResetCursorXY,0x80302a3c
.set sprintf,0x80323cf4

.set  REG_DevelopText,31
.set  REG_GObjData,30
.set  REG_GObj,29

backup

#Create Rectangle
  li  r3,0x348
  branchl r12,HSD_MemAlloc
  mr  r8,r3
  li  r3,6
  li  r4,0
  li  r5,0
  li  r6,20
  li  r7,7
  branchl r12,DevelopText_CreateDataTable
  mr  REG_DevelopText,r3
#Activate Text
  lwz	r3, -0x4884 (r13)
  mr  r4,REG_DevelopText
  branchl r12,DevelopText_Activate
#Hide blinking cursor
  li  r3,0
  stb r3,0x26(REG_DevelopText)
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
	li	r5,0
	branchl r12,GObj_AddProc
#Store pointer to dev text
  stw REG_DevelopText,0x0(REG_GObjData)
  b Exit

########################################
DebugLogThink:
blrl
.set  REG_GObjData,31
backup

lwz REG_GObjData,0x2C(r3)

#/*
#Erase all text
  lwz  r3,0x0(REG_GObjData)
  branchl r12,DevelopText_EraseAllText
  lwz  r3,0x0(REG_GObjData)
  li  r4,0
  li  r5,0
  branchl r12,DevelopMode_Text_ResetCursorXY
#*/

#Check heap
  lwz	r3, -0x58A0 (r13)
  branchl r12,0x80344168
  mr  r5,r3
#Display
  lwz  r3,0x0(REG_GObjData)
  bl  String
  mflr  r4
  branchl r12,0x80302d4c#DevelopText_AddString

DebugLogThink_Exit:
restore
blr

#########################################
String:
blrl
.string "%d\n bytes free" #08X\n
.align 2

Exit:
restore
li	r0, 0

/*
load  r4,0xCC002002
lhz r3,0x0(r4)
ori r3,r3,0x4
sth r3,0x0(r4)

li	r3, 1
*/
