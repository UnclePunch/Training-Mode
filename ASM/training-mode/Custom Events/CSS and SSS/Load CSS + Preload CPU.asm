#To be inserted at 801baa80
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set  REG_Stage,26
.set  REG_CPU,27
.set  REG_CSSType,28
.set  EventID,29
.set  PageID,30
.set  REG_SceneData,31

backup

#Save scene data
  mr  REG_SceneData,r3
#Get Current Event Number
  lwz	r4, -0x77C0 (r13)
  lbz	EventID, 0x0535 (r4)
#Get Current Page in
  lwz r4,MemcardData(r13)
  lbz PageID,CurrentEventPage(r4)

#Get this events CSS Type
  mr  r3,PageID
  mr  r4,EventID
  rtocbl  r12,TM_GetIsChooseCPU
  cmpwi r3,0x0
  beq EventCSS
TrainingCSS:
  li  REG_CSSType,0x17
  b CheckToPreloadCPU
EventCSS:
  li  REG_CSSType,14
  b CheckToPreloadCPU


CheckToPreloadCPU:
#Check if this event has a pre-determined CPU
  mr  r3,PageID
  mr  r4,EventID
  rtocbl  r12,TM_GetCPUFighter
  extsb REG_CPU,r3
CheckToPreloadStage:
#Check if this event has a pre-determined stage
  mr  r3,PageID
  mr  r4,EventID
  rtocbl  r12,TM_GetStage
  extsb REG_Stage,r3

UpdatePreloadTable:
#Store Preload
  load r3,PreloadTable
  cmpwi REG_CPU,-1
  beq UpdatePreloadTable_CheckStage
  stw REG_CPU,0x1C(r3)   #p2 character
UpdatePreloadTable_CheckStage:
  cmpwi REG_Stage,-1
  beq Exit
  stw REG_Stage,0x10(r3)   #stage
  b Exit

Exit:
  mr  r4,REG_CSSType       #Return CSS Choice
  mr  r3,REG_SceneData     #Restore scene data
  restore
  lbz	r5, 0x0002 (r31)     #get r5 again since we clobbered it
