#To be inserted at 8016ebac
.include "../../Globals.s"

#Check if VS Mode
  load r3,SceneController
  lbz r3,Scene.CurrentMajor(r3)
  cmpwi r3,Scene.VSMode
  bne Exit

#Init Struct?
  load	r3,0x803dda00		#Get Some Scene Struct
  branchl	r12,0x801a5f00		#Wipe and Copy Match Info

#Update KO Star Count
  load	r3,0x803dda00		#Get Some Scene Struct
  lwz	r4, -0x77C0 (r13) #Get SSS Struct
  addi	r4, r4, 1424
  li  r5,0              #Next Minor Scene
  branchl	r12,0x801a5f64		#Update KO Stars

#Update VS Records
  load	r3,0x8047c028		#Get Match Info
  branchl	r12,0x801623a4		#Update VS Records

Exit:
  lwz	r0, 0x001C (sp)
  lwz	r31, 0x0014 (sp)
