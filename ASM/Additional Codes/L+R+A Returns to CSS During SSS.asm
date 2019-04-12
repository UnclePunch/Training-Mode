#To be inserted at 8025B8BC
.include "../Globals.s"

#Load first minor of current major
  load r3,SceneController
  lbz r3,0x0(r3)
