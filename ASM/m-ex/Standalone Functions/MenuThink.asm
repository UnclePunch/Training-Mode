#To be inserted @ 803d7090
.include "../../Globals.s"
.include "../Header.s"

# slippi hack
.set OFST_R13_SWITCH_TO_ONLINE_SUBMENU,-0x49ec # Function used to switch

.set  REG_GObj,31
.set  REG_MenuData,30
.set  REG_Inputs,29
.set  REG_MenuDef,28
.set  REG_OptDef,27
.set  REG_ThisOpt,26
.set  REG_ThisMenu,25

# init
  backup
  mr  REG_GObj,r3
  load  REG_MenuData,0x804a04f0
# Get menu def
  lwz r3,OFST_mexMenu(r13)
  lwz r3,mexMenu_MenuDef(r3)
  lbz	r0, 0 (REG_MenuData)
  mulli	r0, r0, MenuDefStride
  add REG_MenuDef,r3,r0
# Get opt def
  lwz REG_OptDef,MenuDef_OptDef(REG_MenuDef)

# Decrement lockout
  lhz r3,-0x4AD8(r13)
  cmpwi r3,0
  ble SkipLockoutDec
  subi  r3,r3,1
  sth r3,-0x4AD8(r13)
  b Exit
SkipLockoutDec:

# Get inputs
  li  r3,4
  branchl r12,0x80229624
  mr  REG_Inputs,r3
  stw	REG_Inputs, 0x000C (REG_MenuData)
  li  r3,0
  stw	r3, 0x0008 (REG_MenuData)

# Check for A
  rlwinm. r0,REG_Inputs,0,0x10
  beq NoA
# SFX
  li	r3, 1
  branchl r12,0x80024030
# Store Input Lockout
  li  r3,5
  sth r3,-0x4AD8(r13)
# Store menu leave animation direction
  li  r3,1
  stb	r3, 0x0011 (REG_MenuData)
# Get this option
  lhz	r3, 0x2 (REG_MenuData)  # current cursor
  mulli r3,r3,OptDefStride
  add REG_ThisOpt,r3,REG_OptDef
# Get option kind
  lbz r3,OptDef_Kind(REG_ThisOpt)
  cmpwi r3,0
  beq Enter_Menu
  cmpwi r3,1
  beq Enter_Scene
  b Exit

Enter_Menu:
# Get this menu
  lwz r3,OFST_mexMenu(r13)
  lwz r3,mexMenu_MenuDef(r3)
  lbz	r0, OptDef_ID (REG_ThisOpt)
  mulli	r0, r0, MenuDefStride
  add REG_ThisMenu,r3,r0

# Check if event mode...
  lbz r3,OptDef_ID(REG_ThisOpt)
  cmpwi r3,7
  bne Enter_MenuNoEvent
# Handle event mode
  lwz r12,MenuDef_Callback(REG_ThisMenu)
  cmpwi r12,0
  beq Enter_MenuNoCB
  mtctr r12
  li  r3,0
  li  r4,1
  bctrl
# Delete this menu gobj
  mr  r3,REG_GObj
  branchl r12,0x80390228
  b Exit
Enter_MenuNoEvent:

# Check if slippi menu...
  lbz r3,OptDef_ID(REG_ThisOpt)
  cmpwi r3,8
  bne Enter_MenuNoSlippi
# Handle slippi menu init
  lwz r12,OFST_R13_SWITCH_TO_ONLINE_SUBMENU(r13)
  mtctr r12
  bctrl
  b Exit
Enter_MenuNoSlippi:

# Check if multiman menu...
  lbz r3,OptDef_ID(REG_ThisOpt)
  cmpwi r3,33
  bne Enter_MenuNoMultiman
# Handle multiman menu init
  li r3,0
  branchl r12,0x8024cd64
# Delete this menu gobj
  mr  r3,REG_GObj
  branchl r12,0x80390228
  b Exit
Enter_MenuNoMultiman:

Enter_MenuNoSpecial:
# check for custom callback
  lwz r3,MenuDef_Callback(REG_ThisMenu)
  cmpwi r3,0
  beq Enter_MenuNoCB
  mtctr r3
  bctrl
# Delete this menu gobj
  mr  r3,REG_GObj
  branchl r12,0x80390228
  b Exit
Enter_MenuNoCB:

# set prev menu
  lbz	r3, 0x0 (REG_MenuData)
  stb	r3, 0x1 (REG_MenuData)
# new curr menu
  lbz r3,OptDef_ID(REG_ThisOpt)
  stb	r3, 0x0 (REG_MenuData)

# determine cursor value for next menu
  .set  REG_Count,20
  .set  REG_OptNum,11
  li  REG_Count,0
  lwz r3,OFST_mexMenu(r13)
  lwz r3,mexMenu_MenuDef(r3)
  lbz	r0, 0 (REG_MenuData)
  mulli	r0, r0, MenuDefStride
  add r3,r3,r0
  lbz REG_OptNum,MenuDef_OptNum(r3)
SearchNextCursor__Loop:
# check if unlocked
  lbz	r3, 0 (REG_MenuData)
  mr r4,REG_Count  # option ID
  branchl r12,0x80229938
  cmpwi r3,0
  beq SearchNextCursor__IncLoop
# set cursor
  sth	REG_Count, 0x2 (REG_MenuData)  # current cursor
  b SearchNextCursor__Exit
SearchNextCursor__IncLoop:
  addi  REG_Count,REG_Count,1
  cmpw  REG_Count,REG_OptNum
  blt SearchNextCursor__Loop
SearchNextCursor__Exit:

# Switch menu 
  li  r3,1    # forward
  branchl r12,0x8022b3a0
# Some proc thing
  branchl r12,0x80390cd4
# Delete this menu gobj
  mr  r3,REG_GObj
  branchl r12,0x80390228
# Get next menu
  lwz r3,OFST_mexMenu(r13)
  lwz r3,mexMenu_MenuDef(r3)
  lbz	r0, 0x0 (REG_MenuData)
  mulli	r0, r0, MenuDefStride
  add REG_MenuDef,r3,r0
# Create next menu gobj
  li  r3,0
  li  r4,1
  li  r5,128
  branchl r12,0x803901f0
# Set this proc
  load  r4,MenuThink
  li  r5,0
  branchl r12,0x8038fd54
# Adjust this proc?
  lwz	r4, -0x3E64 (r13)
  lbz	r0, 0x000D (r3)
  rlwimi	r0, r4, 4, 26, 27
  stb	r0, 0x000D (r3)
  b Exit

Enter_Scene:
# Get scene data
  branchl r12,0x801a4b9c
# Store scene ID
  lbz r0,OptDef_ID(REG_ThisOpt)
  stb r0,0x0(r3)
# Change minor
  branchl r12,0x801a4b60
  b Exit
NoA:

# Check for B
  rlwinm. r0,REG_Inputs,0,0x20
  beq NoB
# SFX
  li	r3, 0
  branchl r12,0x80024030

# Check for title screen
  lbz r3,MenuDef_PrevMenu(REG_MenuDef)
  extsb r3,r3
  cmpwi r3,-1
  bne Return_NoTitle
# Get scene data
  branchl r12,0x801a4b9c
# Store scene ID
  li  r0,0
  stb r0,0x0(r3)
# Change minor
  branchl r12,0x801a4b60
  b Exit
Return_NoTitle:

# Store menu leave animation direction
  li  r3,0
  stb	r3, 0x0011 (REG_MenuData)

# set prev menu
  lbz	r3, 0x0 (REG_MenuData)
  stb	r3, 0x1 (REG_MenuData)
# new curr menu
  lbz r3,MenuDef_PrevMenu(REG_MenuDef)
  stb	r3, 0x0 (REG_MenuData)

# determine cursor value for prev menu
  .set  REG_Count,12
  .set  REG_OptNum,11
  .set  REG_OptDef,10
  .set  REG_PrevMenuID,9
  li  REG_Count,0
  lbz REG_PrevMenuID, 0x1 (REG_MenuData)
# Get menu def for prev menu
  lwz r3,OFST_mexMenu(r13)
  lwz r3,mexMenu_MenuDef(r3)
  lbz	r0, 0 (REG_MenuData)
  mulli	r0, r0, MenuDefStride
  add r3,r3,r0
  lbz REG_OptNum,MenuDef_OptNum(r3)
  lwz REG_OptDef,MenuDef_OptDef(r3)
SearchPrevCursor_Loop:
# Get this optdef
  mulli r0,REG_Count,OptDefStride
  add r3,REG_OptDef,r0
# check if menu
  lbz r0,OptDef_Kind(r3)
  cmpwi r0,0
  bne SearchPrevCursor_IncLoop
# get menu ID
  lbz r0,OptDef_ID(r3)
  cmpw r0,REG_PrevMenuID
  bne SearchPrevCursor_IncLoop
# set cursor
  sth	REG_Count, 0x2 (REG_MenuData)  # current cursor
  b SearchPrevCursor_Exit
SearchPrevCursor_IncLoop:
  addi  REG_Count,REG_Count,1
  cmpw  REG_Count,REG_OptNum
  blt SearchPrevCursor_Loop
SearchPrevCursor_Exit:

# Switch menu 
  li  r3,3    # backward
  branchl r12,0x8022b3a0
# Some proc thing
  branchl r12,0x80390cd4
# Delete this menu gobj
  mr  r3,REG_GObj
  branchl r12,0x80390228
# Create next menu gobj
  li  r3,0
  li  r4,1
  li  r5,128
  branchl r12,0x803901f0
# Set this proc
  load  r4,MenuThink
  li  r5,0
  branchl r12,0x8038fd54
# Adjust this proc?
  lwz	r4, -0x3E64 (r13)
  lbz	r0, 0x000D (r3)
  rlwimi	r0, r4, 4, 26, 27
  stb	r0, 0x000D (r3)



  b Exit
NoB:

# Check for Up
  rlwinm. r0,REG_Inputs,0,0x1
  beq NoUp
# SFX
  li	r3, 2
  branchl r12,0x80024030
CursorUpInitLoop:
.set  REG_TempCursor, 20
  lhz	REG_TempCursor, 0x2 (REG_MenuData)  # current cursor
CursorUpLoop:
# Move cursor
  subi  REG_TempCursor,REG_TempCursor,1
  extsh r0,REG_TempCursor
  cmpwi r0,-1
  bgt CursorUp_NoAdjust
# Get last option
  lbz r3,MenuDef_OptNum(REG_MenuDef)
  subi  REG_TempCursor,r3,1
CursorUp_NoAdjust:
# Check if option exists
  lbz	r3, 0x0 (REG_MenuData)
  mr  r4,REG_TempCursor
  branchl r12,0x80229938
  cmpwi r3,0
  beq CursorUpLoop
CursorUp_Store:
  sth	REG_TempCursor, 0x2 (REG_MenuData)  # current cursor
  b Exit
NoUp:

# Check for Down
  rlwinm. r0,REG_Inputs,0,0x2
  beq NoDown
# SFX
  li	r3, 2
  branchl r12,0x80024030
CursorDownInitLoop:
.set  REG_TempCursor, 20
  lhz	REG_TempCursor, 0x2 (REG_MenuData)  # current cursor
CursorDownLoop:
# Move cursor
  addi  REG_TempCursor,REG_TempCursor,1
  lbz r4,MenuDef_OptNum(REG_MenuDef)
  cmpw REG_TempCursor,r4
  blt CursorDown_NoAdjust
# Get first option
  li  REG_TempCursor,0  
CursorDown_NoAdjust:
# Check if option exists
  lbz	r3, 0x0 (REG_MenuData)
  mr  r4,REG_TempCursor
  branchl r12,0x80229938
  cmpwi r3,0
  beq CursorDownLoop
CursorDown_Store:
  sth	REG_TempCursor, 0x2 (REG_MenuData)  # current cursor
  b Exit
NoDown:

Exit:
  restore
  blr