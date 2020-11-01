#To be inserted @ 80069ce0
.include "../../../Globals.s"
.include "../../Header.s"

.set  REG_OpponentGObj,23
.set  REG_PlayerData,26

#Check if anim is coming from opponent
  cmpwi REG_OpponentGObj,0
  beq OwnsAnim

NoOwnsAnim:
  li  r3,1
  stw r3,MEX_AnimOwner(REG_PlayerData)
  b Exit
OwnsAnim:
  li  r3,0
  stw r3,MEX_AnimOwner(REG_PlayerData)

Exit:
  cmplwi	r23, 0
