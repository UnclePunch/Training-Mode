#To be inserted at 8024d470
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

#r24 = text struct
#r27 = Event ID

CustomEvent:
.set text,24

#Create Text
  li  r3,0
  li  r4,0
  branchl r12,0x803a6754
  mr  text,r3

#Store pointer to text so it can be removed by the game
  stw text,0x0(r23)

#Set Text Values
  lfs	f1, 0x0030 (r31)
  lfs	f4, 0x007C (sp)
  fadds	f1,f4,f1
  lfs	f0, 0x0034 (r31)
  fadds	f2,f31,f0
  lfs	f3, -0x3874 (rtoc)
  lfs	f4, -0x386C (rtoc)
  lfs	f5, -0x3868 (rtoc)
  stfs f1,0x00(text)
  stfs f2,0x04(text)
  stfs f3,0x08(text)
  stfs f4,0x0C(text)
  stfs f5,0x10(text)
  lfs	f0, -0x3878 (rtoc)
  stfs	f0, 0x0024 (text)
  stfs	f0, 0x0028 (text)
  li r3,1
  stb r3,0x48(text)
  li r3,1
  stb r3,0x49(text)

backup

#Get Event Name
  lwz r3,MemcardData(r13)
  lbz r3,CurrentEventPage(r3)
  mr r4,r27
  rtocbl r12,TM_GetEventName

# Add subtext
  mr r4,r3
  mr r3,text
  lfs	f1, -0x3870 (rtoc)
  lfs	f2, -0x3870 (rtoc)
  branchl r12,0x803a6b98

# Get event file
  lwz r3,MemcardData(r13)
  lbz r3,CurrentEventPage(r3)
  mr r4,r27
  rtocbl r12,TM_GetEventFile
  cmpwi r3,0
  bne HasFile
NoFile:
# Change color
  mr r3,text
  li r4,0
  bl Color
  mflr r5
  branchl r12,0x803a74f0

HasFile:

#Exit
  restore
  branch r12,0x8024d4c8

Color:
blrl
.byte 180, 180, 180, 255


VanillaEvent:
Original:
  lfs	f0, 0x0034 (r31)
