#To be inserted at 801a1124
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set FFVar,0x240C

#Only in Event Mode
  load r3,SceneController
  lbz r3,Scene.CurrentMajor(r3)
  cmpwi r3,Scene.EventMode
  bne Exit

#Get Text Struct
  load r3,0x804a1f58
  lwz r3,0x8(r3)
#Remove Text Struct
  branchl r12,0x803a5cc4

#Get GObj
  load r5,0x804a1f58
  lwz r3,0xC(r5)
#Zero Out Data
  li  r4,0
  stw r4,0x8(r5)
  stw r4,0xC(r5)
#Remove GObj
  branchl r12,0x80390228

Exit:
#Original Codeline
  lwz	r0, 0x000C (sp)
