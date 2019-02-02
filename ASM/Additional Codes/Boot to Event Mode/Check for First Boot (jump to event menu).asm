#To be inserted at 801b02dc
.include "../../Globals.s"

.set entity,31
.set player,31
.set playerdata,31

#Spoof current (soon to be previous) screen
  li	r3,Scene.EventMode
  load	r4,SceneController
  stb	r3,Scene.CurrentMajor(r4)

  li	r3,0x00
