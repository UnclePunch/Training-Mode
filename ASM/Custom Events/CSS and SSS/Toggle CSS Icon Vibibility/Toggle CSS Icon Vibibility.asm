#To be inserted at 80264578
.include "../../../Globals.s"

#Ensure this is event mode
  load r3,SceneController
  lbz r3,Scene.CurrentMajor(r3)
  cmpwi r3,Scene.EventMode
  bne Original

#Create GObj
  li  r3,22
  li  r4,23
  li  r5,0
  branchl r12,GObj_Create

#Attach Process
  bl  ToggleCSSIcon
  mflr r4
  li  r5,2      #Priority (after CSS_BigFunctionMonitorInputsAndMore)
  branchl r12,GObj_SchedulePerFrameFunction

b Original

#######################
ToggleCSSIcon:
blrl

.set EventID,31
.set PageID,30
.set REG_Whitelist,29

backup

#Get Hovered Over Event ID in r23
	lwz	r4, -0x77C0 (r13)
	lbz	EventID, 0x0535 (r4)
#Get Current Page
  lbz PageID,CurrentEventPage(r4)

#Get pointer page's string array
	bl	ToggleCSSIcon_SkipJumpTable

##### Page List #######
	bl	GeneralTech
	bl	SpacieTech
#######################

ToggleCSSIcon_SkipJumpTable:
  mflr	r4		#Jump Table Start in r4
  mulli	r5,PageID,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r6,r4,r5		#Gets Address in r6

#Loop Through Whitelisted Events
  subi	r6,r6,0x1
ToggleCSSIcon_Loop:
  lbzu	r3,0x1(r6)
  extsb	r0,r3
  cmpwi	r0,-1
  beq	ToggleCSSIcon_Exit
  cmpw	r3,EventID
  beq	ToggleCSSIcon_Start
  b	ToggleCSSIcon_Loop

ToggleCSSIcon_Start:
#Get Whitelist
  addi REG_Whitelist,r6,1

#Get P1's Cursor Data
  load r3,0x804a0bc0      #Load CSS Cursor Pointers
  lwz r5,0x0(r3)          #Get P1's Cursor Data

#Check if holding a puck
  lbz r3,0x5(r5)          #Check hand state
  cmpwi r3,0x1
  bne ToggleCSSIcon_HoldingP1Puck
#Check if holding P1's puck
  lbz r3,0x6(r5)
  cmpwi r3,0x0
  beq ToggleCSSIcon_HoldingP1Puck
#Check if holding CPU's puck
  cmpwi r3,0x1
  beq ToggleCSSIcon_HoldingCPUPuck
  b ToggleCSSIcon_Exit

ToggleCSSIcon_HoldingP1Puck:
  li  r3,0  #Hide
  bl  ToggleCSSIcon_ToggleAllIcons
  mr  r3,REG_Whitelist
  bl ToggleCSSIcon_ToggleSelectedIcons
  b ToggleCSSIcon_Exit

ToggleCSSIcon_HoldingCPUPuck:
  li  r3,0  #Hide
  bl  ToggleCSSIcon_ToggleAllIcons
#Loop Through Whitelisted Characters
  subi	r6,REG_Whitelist,0x1
ToggleCSSIcon_HoldingCPUPuckLoop:
  lbzu	r3,0x1(r6)
  extsb	r0,r3
  cmpwi	r0,-2
  bne	ToggleCSSIcon_HoldingCPUPuckLoop
  subi r3,r6,1
  bl	ToggleCSSIcon_ToggleSelectedIcons
  b ToggleCSSIcon_Exit

ToggleCSSIcon_ShowAllCharacters:
  li  r3,1  #Show
  bl  ToggleCSSIcon_ToggleAllIcons
  b ToggleCSSIcon_Exit

ToggleCSSIcon_Exit:
  restore
  blr

#******************************#

######################
## Adjust all icons ##
######################

ToggleCSSIcon_ToggleAllIcons:
.set REG_LoopCount,31
.set REG_IconDataStart,30
.set REG_Whitelist,29
.set REG_IconData,28
.set REG_VisibilityBool,27

backup

ToggleCSSIcon_AdjustAllIconsInit:
#Init Stuff
  mr  REG_VisibilityBool,r3
  li  REG_LoopCount,25
  load REG_IconDataStart,0x803f0b24
  b ToggleCSSIcon_AdjustAllIconsIncLoop
ToggleCSSIcon_AdjustAllIconsLoop:
#Get Icons Data
  mulli r3,REG_LoopCount,0x1C
  add REG_IconData,r3,REG_IconDataStart
#Set Invisible
  #Get JObj
    lwz	r3, -0x49E0 (r13)
    addi r4,sp,0x80
    lbz r5,0x5(REG_IconData)
    crclr 6
    li  r6,-1
    branchl r12,0x80011e24
  #Toggle invisibility flag
    lwz r3,0x80(sp)
    li  r5,1
    cmpwi REG_VisibilityBool,0
    beq 0x8
    li  r5,0
    lwz r4,0x14(r3)
    rlwimi r4,r5,4,27,27
    stw r4,0x14(r3)
#Set interactable
  li  r3,0
  cmpwi REG_VisibilityBool,0
  beq 0x8
  li  r3,2
  stb r3,0x2(REG_IconData)
ToggleCSSIcon_AdjustAllIconsIncLoop:
  subi REG_LoopCount,REG_LoopCount,1
  cmpwi REG_LoopCount,0
  bge ToggleCSSIcon_AdjustAllIconsLoop

ToggleCSSIcon_AdjustAllIconsExit:
  restore
  blr

############################
## Show Whitelisted Chars ##
############################
ToggleCSSIcon_ToggleSelectedIcons:

.set REG_IconDataStart,31
.set REG_Whitelist,30
.set REG_IconData,29

backup

ToggleCSSIcon_ToggleSelectedIconsInit:
#Init Stuff
  subi  REG_Whitelist,r3,1
  load REG_IconDataStart,0x803f0b24
ToggleCSSIcon_ToggleSelectedIconsLoop:
  lbzu	r3,0x1(REG_Whitelist)
  extsb	r0,r3
  cmpwi	r0,-2
  beq	ToggleCSSIcon_ToggleSelectedIconsExit
#Toggle Character Icon On
  #Get Icons Data
    mulli r3,r3,0x1C
    add REG_IconData,r3,REG_IconDataStart
  #Set Invisible
    #Get JObj
      lwz	r3, -0x49E0 (r13)
      addi r4,sp,0x80
      lbz r5,0x5(REG_IconData)
      crclr 6
      li  r6,-1
      branchl r12,0x80011e24
    #Toggle invisibility flag off
      lwz r3,0x80(sp)
      li  r5,0
      lwz r4,0x14(r3)
      rlwimi r4,r5,4,27,27
      stw r4,0x14(r3)
  #Set interactable
    li  r3,2
    stb r3,0x2(REG_IconData)
ToggleCSSIcon_ToggleSelectedIconsIncLoop:
  b ToggleCSSIcon_ToggleSelectedIconsLoop

ToggleCSSIcon_ToggleSelectedIconsExit:
  restore
  blr

#******************************#

GeneralTech:
#Waveshine SDI
  .byte Event.WaveshineSDI
  .byte Fox_CSSID,Falco_CSSID,-2      #Player Characters
  .byte -2                            #CPU Characters
#End
  .byte 0xFF
  .align 2

SpacieTech:
#Ledgetech Counter
  .byte Event.LedgetechCounter
  .byte Fox_CSSID,Falco_CSSID,-2      #Player Characters
  .byte -2                            #CPU Characters
#Armada-Shine
  .byte Event.ArmadaShine
  .byte Fox_CSSID,-2                  #Player Characters
  .byte -2                            #CPU Characters
#End
  .byte 0xFF
  .align 2

#******************************#

Original:
  lwz	r0, 0x0024 (sp)
