#To be inserted @ 803d7060
.include "../../Globals.s"
.include "../Header.s"

.set  REG_InternalID,31
.set  REG_CostumeID,30
.set  REG_StcIcons,29
.set  REG_InternalIDCount,28

.set  masterHand,6
.set  crazyHand,5
.set  wireMale,4
.set  wireFemale,3
.set  gigabowser,2
.set  sandbag,1


# init
  backup
  mr  REG_InternalID,r3
  mr  REG_CostumeID,r4

# Check if custom symbol exists
  lwz REG_StcIcons,OFST_stc_icons(r13)
  cmpwi REG_StcIcons,0
  beq Exit

#Check if a special character
  lwz REG_InternalIDCount,OFST_Metadata_FtIntNum(rtoc)
  subi  r3,REG_InternalIDCount,masterHand
  cmpw REG_InternalID,r3
  blt NormalCharacter
  subi  r3,REG_InternalIDCount,sandbag
  cmpw REG_InternalID,r3
  bgt NormalCharacter
# get special fighter frame
  subi  r3,REG_InternalIDCount,masterHand
  sub r3,REG_InternalID,r3
  bl  SpecialCharacterFrames
  mflr  r4
  lbzx  r3,r3,r4
  b  CastToFloat

# stock frame = reserved + costume * stride + extID
NormalCharacter:
  lhz r3,StcIcons_ReservedFrames(REG_StcIcons)
  lhz r4,StcIcons_Stride(REG_StcIcons)
  mullw r4,r4,REG_CostumeID
  add r3,r3,r4
  add r3,r3,REG_InternalID

# cast to float
CastToFloat:
  xoris r3,r3,0x8000
  lfd	f1, -0x35F8 (rtoc)
  stw r3,0x84(sp)
  lis r3,0x4330
  stw r3,0x80(sp)
  lfd f2,0x80(sp)
  fsubs f1,f2,f1
  b Exit

SpecialCharacterFrames:
blrl
.byte 3  #master hand
.byte 2  #crazy hand
.byte 1  #wire male male
.byte 1  #wire female
.byte 5  #giga bowser
.byte 6  #sandbag
.align 2

Exit:
  restore
  blr