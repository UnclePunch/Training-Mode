#To be inserted at 8016e94c
.include "../Globals.s"

#Check if event mode
  load r3,SceneController
  lbz r3,Scene.CurrentMajor(r3)
  cmpwi r3,Scene.EventMode
  bne exit

#Disable OnGo Functions
  load r3,0x8049e6c8
  li  r4,0
  stw r4,0x6A4(r3)

exit:
  lbz	r0, 0x0001 (r31)
