#To be inserted at 801baa80
.include "../../Globals.s"

.set EventID,7
.set PageID,9

#Get Current Event Number
  lwz	r4, -0x77C0 (r13)
  lbz	EventID, 0x0535 (r4)

#Get Hovered Over Event ID in r23
	lwz	r4, -0x77C0 (r13)
	lbz	EventID, 0x0535 (r4)

#Get Current Page in
  lwz r4,MemcardData(r13)
  lbz PageID,CurrentEventPage(r4)

#Get pointer page's array
	bl	ChooseCPU_SkipJumpTable

##### Page List #######
	bl	ChooseCPU_GeneralTech
	bl	ChooseCPU_SpacieTech
#######################

ChooseCPU_SkipJumpTable:
  mflr	r4		#Jump Table Start in r4
  mulli	r5,PageID,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r5,r4,r5		#Gets Address in r4

#########################################
## Search for Training Mode CSS Events ##
#########################################
#Init Loop
  subi	r5,r5,0x1
CSSLoop:
  lbzu	r6,0x1(r5)
  extsb	r0,r6
  cmpwi	r0,-1
  beq	EventCSS
  cmpw	r6,EventID
  bne	CSSLoop
TrainingCSS:
  li  r8,0x17
  b CheckToPreloadCPUAndStage
EventCSS:
  li  r8,14
  b CheckToPreloadCPUAndStage

#########################################
## Search for Events with Preloading   ##
#########################################
CheckToPreloadCPUAndStage:

#Get pointer page's array
	bl	PreloadEvents_SkipJumpTable

##### Page List #######
	bl	PreloadEvents_GeneralTech
	bl	PreloadEvents_SpacieTech
#######################

PreloadEvents_SkipJumpTable:
  mflr	r4		#Jump Table Start in r4
  mulli	r5,PageID,0x4		#Each Pointer is 0x4 Long
  add	r4,r4,r5		#Get Event's Pointer Address
  lwz	r5,0x0(r4)		#Get bl Instruction
  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
  add	r5,r4,r5		#Gets Address in r4

CheckToPreloadCPUAndStage_Loop:
  lbz r6,0x0(r5)
  extsb r0,r6
  cmpwi r0,-1
  beq Exit
  cmpw r6,EventID
  bne CheckToPreloadCPUAndStage_IncLoop
#Store Preload
  load r4,PreloadTable
  lbz r6,0x1(r5)
  extsb r0,r6
  cmpwi r0,-1
  beq 0x8
  stw r6,0x1C(r4)   #p2 character
  lbz r6,0x2(r5)
  extsb r0,r6
  cmpwi r0,-1
  beq 0x8
  stw r6,0x10(r4)   #stage
  b Exit
CheckToPreloadCPUAndStage_IncLoop:
  addi r5,r5,0x3
  b CheckToPreloadCPUAndStage_Loop

##########################################

ChooseCPU_GeneralTech:
.byte Event.LCancel
.byte Event.Reversal
.byte Event.ShieldDrop
.byte Event.AttackOnShield
.byte Event.Combo
.byte -1
.align 2

ChooseCPU_SpacieTech:
.byte -1
.align 2
##########################################

PreloadEvents_GeneralTech:
#Format is:
#Event, CPU char to preload, Stage to preload
.byte Event.SDI, Fox.Ext, FinalDestination
.byte Event.Powershield, Falco.Ext, FinalDestination
.byte Event.ShieldDrop, -1, Battlefield
.byte Event.AttackOnShield,-1,FinalDestination
.byte Event.LedgeTech, Falco.Ext, -1
.byte Event.AmsahTech, Marth.Ext, -1
.byte Event.WaveshineSDI, Fox.Ext, FinalDestination
.byte -1
.align 2

PreloadEvents_SpacieTech:
.byte Event.LedgetechCounter, Marth.Ext, -1
.byte -1
.align 2

##########################################


Exit:
  mr  r4,r8       #Return CSS Choice
  lbz	r5, 0x0002 (r31)
