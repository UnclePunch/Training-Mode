#To be inserted @ 8006fe20
.include "../../../Globals.s"
.include "../../Header.s"

.set  REG_PlayerData,3

#Check if anim is coming from opponent
  lwz r0,MEX_AnimOwner(REG_PlayerData)
  cmpwi r0,0
