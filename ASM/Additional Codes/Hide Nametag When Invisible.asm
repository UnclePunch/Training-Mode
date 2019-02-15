#To be inserted at 802fccd8
.include "../Globals.s"

#Check if Doubles
  load r3,0x8046b6a0
  lbz r3,0x24D0(r3)
  cmpwi r3, 0x1
  beq Original
#Get PLayer
  lbz r3, 0(r31)
  branchl r12,0x80034110
#Get Player Data
  lwz r4,0x2C(r3)
#Check if Mewtwo
  lwz r3,0x4(r4)
  cmpwi r3,0x10
  bne NotMewtwoAridodge
#Check if Airdodging
  lwz r3,0x10(r4)
  cmpwi r3,0xEC
  beq HideNametag
NotMewtwoAridodge:
#Get Invis Bit
  lbz r3,0x221E(r4)
  rlwinm. r3, r3, 0, 24, 24
  beq- Original
HideNametag:
#Is Invisible, Hide Tag
  lis r12, 0x802F
  ori r12, r12, 0xCCC8
  mtctr r12
  bctr

Original:
  cmplwi	r30, 0
