#To be inserted at 8008114c
.include "../Globals.s"

.set REG_ReflectCallback,31

#Save reflection callback
  mr  r3,r0
  backup
  mr  REG_ReflectCallback,r3
#Count player gobjs
  branchl r12,0x800860c4 #CountPlayers

#Check if 4 or more
  cmpwi r3,4
  blt ShowReflect
#Dont draw reflection
  li  r3,0
  b Exit

ShowReflect:
  mr  r3,REG_ReflectCallback
  b Exit

Exit:
  restore
  mr  r0,r3
  lwz r4,GObj_Lists(r13)
  lwz	r3, 0x0020 (r4)
