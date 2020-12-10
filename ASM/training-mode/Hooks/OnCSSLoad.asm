#To be inserted at 80266810
.include "../Globals.s"
.include "../../m-ex/Header.s"

backup

# Check if event scene
  load r3,SceneController
  lbz r3,Scene.CurrentMajor(r3)
  cmpwi r3,Scene.EventMode
  bne Exit


# Init pointer as 0
  li  r3,0
  stw  r3,0x80(sp)

# Get file string 
  lwz r3,MemcardData(r13)
  lbz r3,CurrentEventPage(r3)
	lwz	r4, -0x77C0 (r13)
	lbz	r4, 0x0535 (r4)
  rtocbl r12,TM_GetCSSFile
  cmpwi r3,0
  beq Exit

# Load this file
  addi  r4,sp,0x80
  bl  SymbolName
  mflr  r5
  branchl r12,0x803d7080

# Execute the function
  lwz  r12,0x80(sp)
  cmpwi r12,0
  beq Exit
  mtctr r12
  bctrl  
  
  b Exit

SymbolName:
blrl
.string "cssFunction"
.align 2

Exit:
# Original Line
  restore
  lwz	r3, -0x49F0 (r13)
  