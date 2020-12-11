#To be inserted at 8002cb30
.include "../../Globals.s"

.set Player,5
.set FloatPointer,6

#Float regs
.set Deadzone,5
.set DeadzoneNeg,6
.set PlayerY,7
.set PlayerX,8

#Get Float Pointer
  bl  Floats
  mflr FloatPointer
#Get Player Input Struct
  load r3,0x804C1FAC
  lbz	r4, 0x02C5 (r31)
  mulli Player, r4, 0x44
  add Player, r3, Player
#Get Deadzone Value from PlCo
  lwz	r3, -0x514C (r13)
  lfs Deadzone, 0(r3)
  fneg DeadzoneNeg, Deadzone

CheckYDeadzone:
#Check Y Value
  lfs PlayerY, 0x2C(Player)
  fcmpo cr0, PlayerY, DeadzoneNeg
  ble- StoreY
  fcmpo cr0, PlayerY, Deadzone
  blt- CheckXDeadzone

StoreY:
  lfs f1, 0x318(r31) #Get X
  lfs f2, 0x330(r31) #Get zoom level
  lfs f3, 0x0(FloatPointer)    #Get multiplier
  fdivs f3,f2,f3   #Zoom * var
  fmuls PlayerY,PlayerY,f3   #Stick axis * zoomed
  fadds f1,f1,PlayerY   #Add to X
  stfs f1, 0x318(r31)  #Store

CheckXDeadzone:
  lfs PlayerY, 0x28(Player)
  fcmpo cr0, PlayerY, DeadzoneNeg
  ble- StoreX
  fcmpo cr0, PlayerY, Deadzone
  blt- Exit

StoreX:
  lfs f1, 0x314(r31)
  lfs f2, 0x330(r31) #Get zoom level
  lfs f3, 0x0(FloatPointer)    #Get multiplier
  fdivs f3,f2,f3   #Zoom * var
  fmuls PlayerY,PlayerY,f3   #Stick axis * zoomed
  fadds f1,f1,PlayerY   #Add to Y
  stfs f1, 0x314(r31)
  b Exit

Floats:
blrl
.float 125

Exit:
lbz	r0, 0x02C5 (r31)
