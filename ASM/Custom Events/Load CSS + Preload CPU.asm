#To be inserted at 801baa80
.include "../Globals.s"

.set entity,31
.set player,31
.set playerdata,31

#Get Current Event Number
  lwz	r4, -0x77C0 (r13)
  lbz	r7, 0x0535 (r4)

#########################################
## Search for Training Mode CSS Events ##
#########################################
#Init Loop
  bl	ChooseCPUEvents
  mflr	r5
  subi	r5,r5,0x1
CSSLoop:
  lbzu	r6,0x1(r5)
  extsb	r0,r6
  cmpwi	r0,-1
  beq	EventCSS
  cmpw	r6,r7
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
#Init Loop
  bl	Preload
  mflr	r5
CheckToPreloadCPUAndStage_Loop:
  lbz r6,0x0(r5)
  extsb r0,r6
  cmpwi r0,-1
  beq Exit
  cmpw r6,r7
  bne CheckToPreloadCPUAndStage_IncLoop
#Store Preload
  load r4,PreloadTableQueue
  lbz r6,0x1(r5)
  extsb r0,r6
  cmpwi r0,-1
  beq 0x8
  stw r6,0x18(r4)   #p2 character
  lbz r6,0x2(r5)
  extsb r0,r6
  cmpwi r0,-1
  beq 0x8
  stw r6,0xC(r4)   #stage
  b Exit
CheckToPreloadCPUAndStage_IncLoop:
  addi r5,r5,0x3
  b CheckToPreloadCPUAndStage_Loop

##########################################
ChooseCPUEvents:
blrl
.byte LCancel.ID
.byte Reversal.ID
.byte ShieldDrop.ID
.byte AttackOnShield.ID
.byte Combo.ID
.byte -1
.align 2

Preload:
blrl
#Format is:
#Event, CPU char to preload, Stage to preload
.byte SDI.ID, Fox.Ext, FinalDestination
.byte Powershield.ID, Falco.Ext, FinalDestination
.byte ShieldDrop.ID, -1, Battlefield
.byte AttackOnShield.ID,-1,FinalDestination
.byte LedgeTech.ID, Falco.Ext, -1
.byte AmsahTech.ID, Marth.Ext, -1
.byte WaveshineSDI.ID, Fox.Ext, FinalDestination
.byte -1
.align 2
##########################################


Exit:
  mr  r4,r8       #Return CSS Choice
  lbz	r5, 0x0002 (r31)
