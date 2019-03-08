#To be inserted at 8016ea30
.include "../../Globals.s"

#Original Codeline
  stb	r0, 0x0010 (r30)

#Check If LRA Start
  cmpwi r0,0x7
  bne Exit
#Find Who LRA Started
  load r4,0x8046b6a0
  lbz r4,0x1(r4)
  stb r4,0xC(r30)

Exit:
