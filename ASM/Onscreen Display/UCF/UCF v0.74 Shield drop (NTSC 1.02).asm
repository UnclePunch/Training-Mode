#To be inserted at 8009986c
.include "../../Globals.s"

.set  REG_PlayerData,31
.set  REG_PlayerGObj,30
.set  REG_Floats,29

backup

	#CHECK IF ENABLED
	li	r0,OSD.UCF			#PowerShield ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r5, 1
	slw	r0, r5, r0
	and.	r0, r0, r4
	beq	EnterSpotdodge

#Init
  mr  REG_PlayerGObj,r31
  lwz REG_PlayerData,0x2C(REG_PlayerGObj)
  bl  Floats
  mflr  REG_Floats

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
	restore
  branch  r12,0x8009987c

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
  restore
