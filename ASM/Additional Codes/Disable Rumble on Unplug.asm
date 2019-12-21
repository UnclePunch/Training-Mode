#To be inserted at 803775a4
.include "../Globals.s"

#Check if unplugged
  lbz	r3, 0x000A (r25)  #current read
  extsb  r3,r3
  cmpwi r3,-1
  bne Original
  lbz r3, 0x0041 (r26)  #prev read
  extsb.  r3,r3
  bne Original
#Disable rumble
  mr  r3,r24
  li  r4,0
  branchl r12,Rumble_StoreRumbleFlag

Original:
  lbz	r0, 0x000A (r25)
