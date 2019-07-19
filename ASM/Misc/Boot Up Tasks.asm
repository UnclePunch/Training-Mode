#To be inserted at 801b02ec
.include "../Globals.s"

.set entity,31
.set player,31
.set playerdata,31

OnBootup

Original:
  lwz	r0, 0x001C (sp)
