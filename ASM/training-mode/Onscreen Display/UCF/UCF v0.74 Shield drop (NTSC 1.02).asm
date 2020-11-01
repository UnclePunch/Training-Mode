#To be inserted at 800998a4
.include "../../Globals.s"

.set  REG_PlayerData,31
.set  REG_PlayerGObj,30
.set  REG_Floats,29

backup

#Init
  mr  REG_PlayerGObj,r3
  lwz REG_PlayerData,0x2C(REG_PlayerGObj)
  bl  Floats
  mflr  REG_Floats

#CHECK IF ENABLED
	li	r0,OSD.UCF			#PowerShield ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r5, 1
	slw	r0, r5, r0
	and.	r0, r0, r4
	beq	EnterSpotdodge

#Check if cstick is
  lfs f1, 0x63C (REG_PlayerData)
  lwz	r3, -0x514C (r13)
  lfs f0, 0x314 (r3)
  fcmpo cr0, f1, f0
  ble- EnterSpotdodge

#Check if left stick is ?
  lfs f0, 0x620(REG_PlayerData)
  fabs f0, f0
#Multiply by 80
  lfs f1,OFST_Unk1(REG_Floats)
  fmuls f0, f0, f1
#Subtract 0.0001
  lfs f1,OFST_Unk2(REG_Floats)
  fsubs f0, f0, f1
#Add 2
  lfs f1,OFST_2fp(REG_Floats)
  fadds f0,f0,f1
  lfs f1,OFST_Unk1(REG_Floats)
  fdivs f0, f0, f1
#Remember this value
  fmr f3,f0
#Check if left stick is ?
  lfs f0, 0x624(REG_PlayerData)
  fabs f0, f0
#Multiply by 80
  lfs f1,OFST_Unk1(REG_Floats)
  fmuls f0, f0, f1
#Subtract 0.0001
  lfs f1,OFST_Unk2(REG_Floats)
  fsubs f0, f0, f1
#Add 2
  lfs f1,OFST_2fp(REG_Floats)
  fadds f0,f0,f1
  lfs f1,OFST_Unk1(REG_Floats)
  fdivs f0, f0, f1

#Check if stick was pushed slow enough?
  fmr f1,f3
  fmuls f1, f1, f1
  fmuls f0, f0, f0
  fadds f0, f0, f1
  lfs f1,OFST_1fp(REG_Floats)
  fcmpo cr0, f0, f1
  blt EnterSpotdodge
#Check if stick has been pushed horizontally for over 3 frames
  lbz r4, 0x670(REG_PlayerData)
  cmpwi r4, 3
  ble- EnterSpotdodge
#Check if stick Y is below -0.8
  lfs f0,OFST_Unk4(REG_Floats)
  lfs f1, 0x624(REG_PlayerData)
  fcmpo cr0, f0, f1
  bge- EnterSpotdodge

#Exit spotdodge function without entering the state
# this is very hacky and is how UCF 0.73 functions.
# the reason this is in place is because the spotdodge function is called
# from 2 different places, so instead of making 2 injections, this is done.
	restore
  lwz	r3, 0x001C (sp)
	lwz	r31, 0x0014 (sp)
	addi	sp, sp, 24
	addi	r3,r3,0x8			#skip to the end of the function we are coming from
	mtlr	r3
	blr

Floats:
blrl
.set  OFST_Unk1,0x0
.set  OFST_Unk2,0x4
.set  OFST_Unk3,0x8
.set  OFST_2fp,0xC
.set  OFST_1fp,0x10
.set  OFST_Unk4,0x14
.float 80
.long 0x37270000
.float 176
.float 2
.float 1
.float -0.8

EnterSpotdodge:
  mr	r3, REG_PlayerGObj
	mr	r4,	REG_PlayerData
  restore
