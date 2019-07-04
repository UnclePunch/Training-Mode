#To be inserted at 80030288
.include "../../Globals.s"

branchl r12,0x80030A78
cmpwi r3, 0
beq- _return
# checks for collision link display flag

  _if_drawing_stage_collisions:
  branchl r12, 0x80059e60
  # moves post-process drawing call to before player draw
  # causes geometry to be drawn on black/white screen, if enabled simultaneously

_return:
lbz    r0, 0 (r31)
