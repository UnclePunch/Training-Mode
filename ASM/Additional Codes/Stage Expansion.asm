#To be inserted at 8016e800
.include "../Globals.s"

#Get list start
	bl	StageMod_SkipList
########################
bl	StageMod_Dummy
bl	StageMod_TEST
bl	StageMod_Izumi
bl	StageMod_Pstadium
bl	StageMod_Castle
bl	StageMod_Kongo
bl	StageMod_Zebes
bl	StageMod_Corneria
bl	StageMod_Story
bl	StageMod_Onett
bl	StageMod_MuteCity
bl	StageMod_RCruise
bl	StageMod_Garden
bl	StageMod_GreatBay
bl	StageMod_Shrine
bl	StageMod_Kraid
bl	StageMod_Yoster
bl	StageMod_Greens
bl	StageMod_Fourside
bl	StageMod_MK1
bl	StageMod_MK2
bl	StageMod_Akaneia
bl	StageMod_Venom
bl	StageMod_Pura
bl	StageMod_BigBlue
bl	StageMod_Icemt
bl	StageMod_Icetop
bl	StageMod_FlatZone
bl	StageMod_OldDL
bl	StageMod_OldYS
bl	StageMod_OldKongo
bl	StageMod_Battlefield
bl	StageMod_FinalDestination

########################
StageMod_SkipList:
	mflr r3
	lwz r4,StageID_External(r13)
  cmpwi r4,FinalDestination
  bgt GoToExit
	mulli	r4,r4,4
	add r4,r3,r4
	lwz r5,0x0(r4)				#Get bl Instruction
  rlwinm	r5,r5,0,6,29	#Mask Bits 6-29 (the offset)
	cmpwi r5,0						#If pointer is null, exit
	beq	GoToExit
  add	r5,r4,r5					#Pointer to code now in r5

################
## Patch Loop ##
################

#Get stage file
  load  r6,0x8049ee10
  lwz r6,0x0(r6)
  lwz r6,0x20(r6)
  subi  r6,r6,0x20

patchLoop:
#Get offset and replacement data
  lwz r3,0x0(r5)
  lwz r4,0x4(r5)
#Check if end of data
  extsb r0,r3
  cmpwi r0,-1
  beq endPatchLoop
#Check if contains a pointer (replacement data begins with 0xCC)
	rlwinm	r0,r3,8,0x000000FF
	cmpwi	r0,0xCC
	beq	ConvertPointer
	cmpwi	r0,0xCD
	beq	memfill
	b	patchData
memfill:
	rlwinm	r3,r3,0,0x00FFFFFF	#get offset
	lwz	r7,0x8(r5)	#get replacement data
	#length in r4
memfillLoop:
	cmpwi	r4,0
	beq	memfillExit
	subi	r4,r4,0x4
	add	r8,r6,r3
	stwx	r7,r8,r4
	b	memfillLoop
memfillExit:
  addi r5,r5,0xC
	b	patchLoop
ConvertPointer:
#Convert pointer
	rlwinm	r3,r3,0,0x00FFFFFF	#get actual pointer
	add	r4,r4,r6								#add to start of dat
	addi	r4,r4,0x20						#disregard header
	b	patchData
patchData:
#Replace data
  add r3,r3,r6
  stw r4,0x0(r3)
  addi r5,r5,0x8
  b patchLoop
endPatchLoop:
  b GoToExit

GoToExit:
b	Exit

StageMod_Garden:
  .long 0x0001A68C
  .long 0x00000000
  .long 0x0001A6E8
  .long 0x3FC00000
  .long 0x0001A6EC
  .long 0x40000000
  .long 0x0001A70C
  .long 0x00000000
  .long 0x0001A7CC
  .long 0x00000000
  .long 0x0001A828
  .long 0x3FD9999A
  .long 0x0001A834
  .long 0x4038BFB1
  .long 0x0001AA28
  .long 0x3F170A3D
  .long 0x0002C898
  .long 0xC2960000
  .long 0x0002C89C
  .long 0x43160000
  .long 0x0002CB54
  .long 0xC1700000
  .long 0x0002D4DC
  .long 0xC1A00000
  .long 0x0002D554
  .long 0xC2BE0000
  .long 0x00034574
  .long 0x4038BFB1
  .long 0x00036F58
  .long 0xC3FA0000
  .long 0x0003A2C8
  .long 0xC27D6704
  .long 0x0003A2CC
  .long 0xC1970B44
  .long 0x0003A2D0
  .long 0xC27D6704
  .long 0x0003A2D4
  .long 0xC1970B44
  .long 0x0003A2D8
  .long 0xC286CF28
  .long 0x0003A2E0
  .long 0xC2659E4F
  .long 0x0003A2E8
  .long 0xC2710000
  .long 0x0003A2EC
  .long 0xC1C96595
  .long 0x0003A2F0
  .long 0x428D9ADB
  .long 0x0003A2F4
  .long 0xC1970B44
  .long 0x0003A2F8
  .long 0x428D9ADB
  .long 0x0003A2FC
  .long 0xC1970B44
  .long 0x0003A300
  .long 0x42876759
  .long 0x0003A304
  .long 0xC1C96595
  .long 0x0003A308
  .long 0x4211BDBF
  .long 0x0003A30C
  .long 0xC161EB85
  .long 0x0003A310
  .long 0xC1DB746E
  .long 0x0003A314
  .long 0xC161EB85
  .long 0x0003A318
  .long 0x421B6AB3
  .long 0x0003A31C
  .long 0xC1C96595
  .long 0x0003A320
  .long 0xC1E9D5EA
  .long 0x0003A324
  .long 0xC1C96595
  .long 0x0003A328
  .long 0x43FA0000
  .long 0x0003A32C
  .long 0x43FA0000
  .long 0x0003A330
  .long 0xC2659E4F
  .long 0x0003A334
  .long 0x00000000
  .long 0x0003A338
  .long 0x4281B681
  .long 0x0003A33C
  .long 0x00000000
  .long 0x0003A340
  .long 0x43FA0000
  .long 0x0003A344
  .long 0x43FA0000
  .long 0x0003A348
  .long 0x43FA0000
  .long 0x0003A34C
  .long 0x43FA0000
  .long 0x0003A350
  .long 0x4281B681
  .long 0x0003A354
  .long 0x00000000
  .long 0x0003A358
  .long 0x4295B681
  .long 0x0003A35C
  .long 0x00000000
  .long 0x0003A360
  .long 0x43FA0000
  .long 0x0003A364
  .long 0x43FA0000
  .long 0x0003A368
  .long 0xC18CD4FE
  .long 0x0003A370
  .long 0x41C872B0
  .long 0x0003A37C
  .long 0x00100001
  .long 0x0003A38C
  .long 0x00000002
  .long 0x0003A394
  .long 0x00010004
  .long 0x0003A39C
  .long 0x0001000D
  .long 0x0003A408
  .long 0x000F000F
  .long 0x0003A40C
  .long 0xFFFFFFFF
  .long 0x0003A41C
  .long 0xFFFFFFFF
  .long 0x0003A448
  .long 0x00120005
  .long 0x0003A44C
  .long 0x00020008
  .long 0x0003A458
  .long 0x000F000F
  .long 0x0003A45C
  .long 0xFFFFFFFF
  .long 0x0003A468
  .long 0x00130013
  .long 0x0003A46C
  .long 0xFFFFFFFF
  .long 0x0003A4A8
  .long 0x000C000C
  .long 0x0003A4AC
  .long 0xFFFFFFFF
  .long 0x0003A4B8
  .long 0x00100010
  .long 0x0003A4BC
  .long 0xFFFFFFFF
  .long 0x0003A4C8
  .long 0x00000003
  .long 0x0003A4DC
  .long 0xC28C0000
  .long 0x0003A4E0
  .long 0xC1F00000
  .long 0x0003A4E4
  .long 0x42980000
  .long 0x00042268
  .long 0x0000006E
  .long 0x00042270
  .long 0xFFFFFFF6
  .long 0x00042278
  .long 0x3CCCCCCD
  .long 0x000424C4
  .long 0xAEA8A2FF
  .long 0x00042690
  .long 0x42F68404
  .long 0x000426D0
  .long 0xC2700000
  .long 0x00042710
  .long 0x433C0000
  .long 0x0004274C
  .long 0x43630000
  .long 0x00042750
  .long 0xC2E40000
  .long 0x0004298C
  .long 0xC25C0000
  .long 0x00042990
  .long 0x40A00000
  .long 0x000429CC
  .long 0x4279999A
  .long 0x000429D0
  .long 0x40A00000
  .long 0x00042A0C
  .long 0x41EF999A
  .long 0x00042A4C
  .long 0xC1B40000
	#Move water down
		.long 0x32558
		.float -200
	#Move water hitbox down
		.long 0x4233c
		.float -200
  .long -1

StageMod_Castle:
  .long 0x0002ED18
  .long 0xC485C001
  .long 0x0002ED58
  .long 0xC45819A5
  .long 0x0008B7B4
  .long 0x42632666
  .long 0x0008B7BC
  .long 0x42584F5C
  .long 0x0008B7C0
  .long 0x41000000
  .long 0x0008B7C4
  .long 0x43286D71
  .long 0x0008B7CC
  .long 0x42584F5C
  .long 0x0008B7D0
  .long 0xC1000000
  .long 0x0008B7D4
  .long 0x43286D71
  .long 0x0008B7EC
  .long 0x42632666
  .long 0x0008B7F4
  .long 0x4289799A
  .long 0x0008B7FC
  .long 0x4285C3D7
  .long 0x0008B804
  .long 0x4285C3D7
  .long 0x0008B80C
  .long 0x4289799A
	.long 0xCC024EDC
	.long 0x25A78
	.long 0x0001AF3C
	.long 0x00000000
	.long 0xCC01F03C
	.long 0x01FDD8
  .long -1

StageMod_Fourside:
	#Remove building top
	.long 0x23BD8 + 0xC
	.long 0
	.long 0x23CF8 + 0xC
	.long 0
	.long 0x23D58 + 0xC
	.long 0
	.long 0x23F58 + 0xC
	.long 0
	.long 0x24198 + 0xC
	.long 0
	#top of building metal thing
	.long 0x1E2D8 + 0xC
	.long 0
	.long 0x1E518 + 0xC
	.long 0
	.long 0x1E758 + 0xC
	.long 0
	.long 0x1E938 + 0xC
	.long 0

	#right building lights
	#.long 0x1EB98 + 0xC
	#.long 0
	#.long 0x1F018 + 0xC
	#.long 0
	#.long 0x1F538 + 0xC
	#.long 0
	#.long 0x1F6F8 + 0xC
	#.long 0
	#.long 0x1F958 + 0xC
	#.long 0
	#.long 0x1FC18 + 0xC
	#.long 0

	#top of building lights
	.long 0x1FD58 + 0xC
	.long 0
	.long 0x1FF18 + 0xC
	.long 0
	.long 0x200F8 + 0xC
	.long 0
	.long 0x20238 + 0xC
	.long 0
	.long 0x203F8 + 0xC
	.long 0
	.long 0x205D8 + 0xC
	.long 0
	.long 0x20778 + 0xC
	.long 0
	.long 0x20A98 + 0xC
	.long 0
	.long 0x20E18 + 0xC
	.long 0
	.long 0x20FB8 + 0xC
	.long 0
	.long 0x212D8 + 0xC
	.long 0
	.long 0x21658 + 0xC
	.long 0
	.long 0x21738 + 0xC
	.long 0
	.long 0x21658 + 0xC
	.long 0

	#collision edits?
  .long 0x0002E6EC
  .long 0x00000000
  .long 0x0002E75C
  .long 0x43000000
  .long 0x0002E998
  .long 0x46825FBE
  .long 0x0002E9D8
  .long 0x00000000
  .long 0x0002EA54
  .long 0x00000000
  .long 0x0002EA58
  .long 0xC3000000
  .long 0x0002EA5C
  .long 0x00000000
  .long 0x0002EB58
  .long 0xC33FDCD0
  .long 0x0002EB94
  .long 0x00000000
  .long 0x0002EB98
  .long 0x00000000
  .long 0x0002EB9C
  .long 0x00000000
  .long 0x0002EBD4
  .long 0x00000000
  .long 0x0002EBD8
  .long 0x00000000
  .long 0x0002EBDC
  .long 0x00000000
  .long 0x0002EC14
  .long 0x00000000
  .long 0x0002EC18
  .long 0x00000000
  .long 0x0002EC1C
  .long 0x00000000
  .long 0x0002EC54
  .long 0xC321D0BD
  .long 0x0002EC58
  .long 0x419C17BD
  .long 0x0002EC5C
  .long 0xBFAFE771
  .long 0x0002ED5C
  .long 0xC122BB88
  .long 0x0002ED9C
  .long 0xC122BB88
  .long 0x0002EDDC
  .long 0xC122BB88
  .long 0x0002EE14
  .long 0xC60637BD
  .long 0x000306F4
  .long 0x00000000
  .long 0x000306F8
  .long 0xC3000000
  .long 0x000306FC
  .long 0x00000000
  .long 0x000307F4
  .long 0x00000000
  .long 0x000307F8
  .long 0xC3000000
  .long 0x000307FC
  .long 0x00000000
  .long 0x00030834
  .long 0x00000000
  .long 0x00030838
  .long 0xC3000000
  .long 0x0003083C
  .long 0x00000000
  .long 0x00030874
  .long 0x00000000
  .long 0x00030878
  .long 0xC3000000
  .long 0x0003087C
  .long 0x00000000
  .long 0x000308B4
  .long 0xC218A6E6
  .long 0x000308B8
  .long 0x3F9A29D0
  .long 0x000308BC
  .long 0x41398B84
  .long 0x000308F4
  .long 0xC26CF2D0
  .long 0x000308F8
  .long 0x3F9A29D0
  .long 0x000308FC
  .long 0x41398B84
  .long 0x00030934
  .long 0xC2A0E1A7
  .long 0x00030938
  .long 0x3F9A29D0
  .long 0x0003093C
  .long 0x41398B84
  .long 0x00030A34
  .long 0x00000000
  .long 0x00030A38
  .long 0xC2330000
  .long 0x00030A3C
  .long 0x00000000
  .long 0x00030A74
  .long 0xC15C0000
  .long 0x00030A78
  .long 0xC2330000
  .long 0x00030A7C
  .long 0x00000000
  .long 0x00030AB4
  .long 0xC12D0000
  .long 0x00030AB8
  .long 0xC2090000
  .long 0x00030ABC
  .long 0x00000000
  .long 0x00030AF4
  .long 0xC0B847B2
  .long 0x00030AF8
  .long 0xC2090000
  .long 0x00030AFC
  .long 0x00000000
  .long 0x00030B34
  .long 0x00000000
  .long 0x00030B38
  .long 0xC3000000
  .long 0x00030B3C
  .long 0x00000000
  .long 0x00030B74
  .long 0x00000000
  .long 0x00030B78
  .long 0xC3000000
  .long 0x00030B7C
  .long 0x00000000
  .long 0x00030BB4
  .long 0x00000000
  .long 0x00030BB8
  .long 0xC3000000
  .long 0x00030BBC
  .long 0x00000000
  .long 0x00036BB4
  .long 0xC1000000
  .long 0x00036BB8
  .long 0x416065B4
  .long 0x00036CE8
  .long 0x3F4CCCCD
  .long 0x0004AC40
  .long 0x00000000
  .long 0x0004AC44
  .long 0x00000000
  .long 0x0004AC48
  .long 0x00000000
  .long 0x0004AC4C
  .long 0x00000000
  .long 0x0004AC50
  .long 0x00000000
  .long 0x0004AC54
  .long 0x00000000
  .long 0x0004AC58
  .long 0x00000000
  .long 0x0004AC5C
  .long 0x00000000
  .long 0x0004AC60
  .long 0x00000000
  .long 0x0004AC64
  .long 0x00000000
  .long 0x0004AC68
  .long 0x00000000
  .long 0x0004AC6C
  .long 0x00000000
  .long 0x0004AC70
  .long 0x00000000
  .long 0x0004AC74
  .long 0x00000000
  .long 0x0004AC78
  .long 0x00000000
  .long 0x0004AC7C
  .long 0x00000000
  .long 0x0004AC80
  .long 0x00000000
  .long 0x0004AC84
  .long 0x00000000
  .long 0x0004AC88
  .long 0x00000000
  .long 0x0004AC8C
  .long 0x00000000
  .long 0x0004AC90
  .long 0x00000000
  .long 0x0004AC94
  .long 0x00000000
  .long 0x0004AC98
  .long 0x00000000
  .long 0x0004AC9C
  .long 0x00000000
  .long 0x0004ACA0
  .long 0x00000000
  .long 0x0004ACA4
  .long 0x00000000
  .long 0x0004ACA8
  .long 0x00000000
  .long 0x0004ACAC
  .long 0x00000000
  .long 0x0004ACB0
  .long 0x00000000
  .long 0x0004ACB4
  .long 0x00000000
  .long 0x0004ACB8
  .long 0x00000000
  .long 0x0004ACBC
  .long 0x00000000
  .long 0x0004ACC0
  .long 0x00000000
  .long 0x0004ACC4
  .long 0x00000000
  .long 0x0004ACC8
  .long 0x00000000
  .long 0x0004ACCC
  .long 0x00000000
  .long 0x0004ACD0
  .long 0x00000000
  .long 0x0004ACD4
  .long 0x00000000
  .long 0x0004ACD8
  .long 0x00000000
  .long 0x0004ACDC
  .long 0x00000000
  .long 0x0004ACE0
  .long 0x00000000
  .long 0x0004ACE4
  .long 0x00000000
  .long 0x0004ACE8
  .long 0x00000000
  .long 0x0004ACEC
  .long 0x00000000
  .long 0x0004ACF0
  .long 0x00000000
  .long 0x0004ACF4
  .long 0x00000000
  .long 0x0004ACF8
  .long 0xC2A40000
  .long 0x0004ACFC
  .long 0xC3240000
  .long 0x0004AD00
  .long 0xC2A40000
  .long 0x0004AD04
  .long 0x3F000000
  .long 0x0004AD08
  .long 0x42530000
  .long 0x0004AD0C
  .long 0x3F000000
  .long 0x0004AD10
  .long 0x42530000
  .long 0x0004AD14
  .long 0xC3240000
  .long 0x0004AD18
  .long 0xC2870000
  .long 0x0004AD1C
  .long 0x3F000000
  .long 0x0004AD20
  .long 0x42110000
  .long 0x0004AD24
  .long 0x3F000000
  .long 0x0004AD28
  .long 0xC1DD0000
  .long 0x0004AD2C
  .long 0xC1370000
  .long 0x0004AD30
  .long 0x41EC0000
  .long 0x0004AD34
  .long 0xC13B0000
  .long 0x0004AD38
  .long 0x00000000
  .long 0x0004AD3C
  .long 0x00000000
  .long 0x0004AD40
  .long 0x00000000
  .long 0x0004AD44
  .long 0x00000000
  .long 0x0004AD48
  .long 0x00000000
  .long 0x0004AD4C
  .long 0x00000000
  .long 0x0004AD50
  .long 0x00000000
  .long 0x0004AD54
  .long 0x00000000
  .long 0x0004AD58
  .long 0x00000000
  .long 0x0004AD5C
  .long 0x00000000
  .long 0x0004AD60
  .long 0x00000000
  .long 0x0004AD64
  .long 0x00000000
  .long 0x0004AD68
  .long 0x00000000
  .long 0x0004AD6C
  .long 0x00000000
  .long 0x0004AD70
  .long 0x00000000
  .long 0x0004AD74
  .long 0x00000000
  .long 0x0004AD78
  .long 0x00000000
  .long 0x0004AD7C
  .long 0x00000000
  .long 0x0004AD80
  .long 0x00000000
  .long 0x0004AD84
  .long 0x00000000
  .long 0x0004AD88
  .long 0x00000000
  .long 0x0004AD8C
  .long 0x00000000
  .long 0x0004AD90
  .long 0x00000000
  .long 0x0004AD94
  .long 0x00000000
  .long 0x0004AD98
  .long 0x00000000
  .long 0x0004AD9C
  .long 0x00000000
  .long 0x0004ADA0
  .long 0x00000000
  .long 0x0004ADA4
  .long 0x00000000
  .long 0x0004ADA8
  .long 0x00000000
  .long 0x0004ADAC
  .long 0x00000000
  .long 0x0004ADBC
  .long 0x00010000
  .long 0x0004AE0C
  .long 0x00010000
  .long 0x0004AE1C
  .long 0x00010000
  .long 0x0004AE6C
  .long 0x00010000
  .long 0x0004AFDC
  .long 0x00040600
  .long 0x0004B03C
  .long 0x00080600
  .long 0x0004B054
  .long 0xC43316A1
  .long 0x0004B05C
  .long 0x44720000
  .long 0x0004B07C
  .long 0xC40001B7
  .long 0x0004B084
  .long 0x444FB886
  .long 0x0004B0A4
  .long 0xC4900000
  .long 0x0004B0AC
  .long 0x44050000
  .long 0x0004B0B0
  .long 0x432FFEC6
  .long 0x0004B0CC
  .long 0xC40E8F42
  .long 0x0004B0D4
  .long 0x4416D26E
  .long 0x0004B0F4
  .long 0xC48087C8
  .long 0x0004B0FC
  .long 0x448087C8
  .long 0x0004B398
  .long 0x00000082
  .long 0x0004B3A8
  .long 0x3D99999A
  .long 0x0004B3B4
  .long 0x3F99999A
  .long 0x0004B3DC
  .long 0xC1400000
  .long 0x0004B3E0
  .long 0x42960000
  .long 0x0004B3E8
  .long 0x41500000
  .long 0x0004B478
  .long 0x0000003C
  .long 0x0004B47C
  .long 0x00000000
  .long 0x0004B480
  .long 0x00000000
  .long 0x0004B484
  .long 0x00000000
  .long 0x0004B488
  .long 0x00000000
  .long 0x0004B48C
  .long 0x00000000
  .long 0x0004B490
  .long 0x00000000
  .long 0x0004B494
  .long 0x00000000
  .long 0x0004B498
  .long 0x00000000
  .long 0x0004B4A0
  .long 0x7F7F012C
  .long 0x0004B73C
  .long 0xC1000000
  .long 0x0004B778
  .long 0xC16A0000
  .long 0x0004B7B8
  .long 0xC32CFFFE
  .long 0x0004B7BC
  .long 0x43020000
  .long 0x0004B7F8
  .long 0x431CFFFE
  .long 0x0004B7FC
  .long 0xC24CE2D2
  .long 0x0004B838
  .long 0xC35F999C
  .long 0x0004B878
  .long 0x434F999C
  .long 0x0004B87C
  .long 0xC2CBC2D1
  .long 0x0004BAB8
  .long 0xC28D0000
  .long 0x0004BABC
  .long 0x41500000
  .long 0x0004BAF8
  .long 0x42250000
  .long 0x0004BAFC
  .long 0x41500000
  .long 0x0004BB38
  .long 0x41800000
  .long 0x0004BB3C
  .long 0x41500000
  .long 0x0004BB78
  .long 0xC2350000
  .long 0x0004BB7C
  .long 0x41500000
  .long 0x0004BBBC
  .long 0x42600000
  .long -1

StageMod_GreatBay:
	.long 0x000026D8
	.long 0xFE2A0191
	.long 0x00002738
	.long 0x01900191
	.long 0x000028F0
	.long 0x034CFE79
	.long 0x000028FC
	.long 0x0392FE79
	.long 0x00002908
	.long 0x034CFE79
	.long 0x0000298C
	.long 0x03520137
	.long 0x000029F8
	.long 0x04780137
	.long 0x00002A80
	.long 0x0073FFC0
	.long 0x00002A9C
	.long 0x00080073
	.long 0x00002AE4
	.long 0x00560073
	.long 0x00012514
	.long 0x41F00000
	.long 0x00012518
	.long 0xC4900000
	.long 0x0001251C
	.long 0xC0600000
	.long 0x00012558
	.long 0x40FBC9BA
	.long 0x00012598
	.long 0xC40BC9BA
	.long 0x000125D4
	.long 0x42A79997
	.long 0x000125DC
	.long 0xC1B3332B
	.long 0x00012658
	.long 0xC24A3021
	.long 0x0006B494
	.long 0xC2E889C7
	.long 0x0006B498
	.long 0xC000645A
	.long 0x0006B49C
	.long 0xC2E889C7
	.long 0x0006B4A0
	.long 0x412A6BBA
	.long 0x0006B4A4
	.long 0x420A76C9
	.long 0x0006B4A8
	.long 0x412A6BBA
	.long 0x0006B4AC
	.long 0x420A76C9
	.long 0x0006B4B0
	.long 0xC000645A
	.long 0x0006B4B4
	.long 0x00000000
	.long 0x0006B4B8
	.long 0x00000000
	.long 0x0006B4BC
	.long 0x00000000
	.long 0x0006B4C0
	.long 0x00000000
	.long 0x0006B4C4
	.long 0x00000000
	.long 0x0006B4C8
	.long 0x00000000
	.long 0x0006B4CC
	.long 0x00000000
	.long 0x0006B4D0
	.long 0x00000000
	.long 0x0006B4D4
	.long 0x00000000
	.long 0x0006B4D8
	.long 0x00000000
	.long 0x0006B4DC
	.long 0x00000000
	.long 0x0006B4E0
	.long 0x00000000
	.long 0x0006B4E4
	.long 0x00000000
	.long 0x0006B4E8
	.long 0x00000000
	.long 0x0006B4EC
	.long 0x00000000
	.long 0x0006B4F0
	.long 0x00000000
	.long 0x0006B9A8
	.long 0xC3EAB611
	.long 0x0006B9B0
	.long 0x43F0DAEE
	.long 0x0006B9B4
	.long 0x4350CE70
	.long 0x0006B9D0
	.long 0xC335B405
	.long 0x0006B9D8
	.long 0x4335B405
	.long 0x0006B9DC
	.long 0x432F084B
	.long 0x0006B9F8
	.long 0xC3C2FE9E
	.long 0x0006BA00
	.long 0x4367DBA6
	.long 0x0006BA04
	.long 0x432EE7BB
	.long 0x0006BA20
	.long 0xC3D31412
	.long 0x0006BA28
	.long 0x43D31412
	.long 0x0006BA2C
	.long 0x436CCCCD
	.long 0x0006BA48
	.long 0xC3D31412
	.long 0x0006BA50
	.long 0x43D31412
	.long 0x0006BA54
	.long 0x43580000
	.long 0x0006BA70
	.long 0xC37E7C1C
	.long 0x0006BA78
	.long 0x437E7C1C
	.long 0x0006BA7C
	.long 0x43DC0000
	.long 0x0006BA98
	.long 0xC357A162
	.long 0x0006BAA0
	.long 0x43F2F1AA
	.long 0x0006BAA4
	.long 0x435AB5DD
	.long 0x0006BAC0
	.long 0xC3F889C7
	.long 0x0006BAC8
	.long 0x439E76C9
	.long 0x0006BACC
	.long 0x4335F41F
	.long 0x000766D8
	.long 0x42CD0000
	.long 0x000766DC
	.long 0x42CD0000
	.long 0x000766E0
	.long 0x42CD0000
	.long 0x000766E4
	.long 0xC2F30000
	.long 0x000766E8
	.long 0xC2F30000
	.long 0x0008E8F0
	.long 0xC3840000
	.long 0x0008E930
	.long 0x435A0000
	.long 0x0008E970
	.long 0xC3A60000
	.long 0x0008E9B0
	.long 0x438C0000
	.long 0x0008EBF4
	.long 0x41920000
	.long 0x0008EC30
	.long 0x42BCCCCD
	.long 0x0008EC70
	.long 0xC284000F
	.long 0x0008EC74
	.long 0x41920004
	.long 0x0008ECB0
	.long 0x00000000
	.long 0x0008ECB4
	.long 0x41920000
	.long 0x0008ECF4
	.long 0x425C0004
	#Scale Plat
		.long 0x12548
		.float 1.7
	#Stretch Plat
		.long 0x12554
		.float 10
	#Unscale House
		.long 0x12648
		.float	0.73
	#Move House
		.long 0x12654
		.float	4
	#Remove pots
		#.long 0x12654
		#.float	4
	#Remove sign
		.long 0x12618
		.float	-200
	#Remove owl
		.long 0x125d8
		.float	-200
	.long 0xFFFFFFFF

StageMod_Greens:
	.long 0x00020DEC
	.long 0x00000000
	.long 0x00020E2C
	.long 0x00000000
	.long 0x00020E54
	.long 0xC2AB0000
	.long 0x00020E58
	.long 0x00200000
	.long 0x00020E6C
	.long 0x00000000
	.long 0x00020E94
	.long 0x42AB0000
	.long 0x00020E98
	.long 0x00200000
	.long 0x00020F14
	.long 0xC6820000
	.long 0x00020F18
	.long 0xC6700000
	.long 0x00020F54
	.long 0xC6AA0000
	.long 0x00020F58
	.long 0xC6700000
	.long 0x00020F94
	.long 0xC6960000
	.long 0x00020F98
	.long 0xC0700000
	.long 0x00020FD4
	.long 0xC6820000
	.long 0x00020FD8
	.long 0xC0700000
	.long 0x00021014
	.long 0xC6820000
	.long 0x00021018
	.long 0xC0C80000
	.long 0x00021054
	.long 0xC6960000
	.long 0x00021058
	.long 0xC0C80000
	.long 0x00021094
	.long 0xC6AA0000
	.long 0x00021098
	.long 0xC0C80000
	.long 0x000210D4
	.long 0x46820000
	.long 0x000210D8
	.long 0x46C80000
	.long 0x00021114
	.long 0x46960000
	.long 0x00021118
	.long 0x46C80000
	.long 0x00021154
	.long 0x40AA0000
	.long 0x00021158
	.long 0x40C80000
	.long 0x00021194
	.long 0x40AA0000
	.long 0x00021198
	.long 0x40700000
	.long 0x000211D4
	.long 0xC6960000
	.long 0x000211D8
	.long 0xC0700000
	.long 0x00021214
	.long 0x40960000
	.long 0x00021218
	.long 0x40700000
	.long 0x00021254
	.long 0x40820000
	.long 0x00021258
	.long 0x40700000
	.long 0x000216D4
	.long 0xC2740000
	.long 0x000216D8
	.long 0x00000000
	.long 0x00021714
	.long 0x42740000
	.long 0x00021718
	.long 0x00000000
	.long 0x00056434
	.long 0x00000000
	.long 0x00056438
	.long 0x46000000
	.long 0x0005643C
	.long 0x00000000
	.long 0x00056440
	.long 0x46000000
	.long 0x00056444
	.long 0x00000000
	.long 0x00056448
	.long 0x46000000
	.long 0x0005644C
	.long 0x00000000
	.long 0x00056450
	.long 0x46000000
	.long 0x00056454
	.long 0x00000000
	.long 0x00056458
	.long 0x46000000
	.long 0x0005645C
	.long 0x00000000
	.long 0x00056460
	.long 0x46000000
	.long 0x00056464
	.long 0x00000000
	.long 0x00056468
	.long 0x46000000
	.long 0x0005646C
	.long 0x00000000
	.long 0x00056470
	.long 0x46000000
	.long 0x00056474
	.long 0x00000000
	.long 0x00056478
	.long 0x46000000
	.long 0x0005647C
	.long 0x00000000
	.long 0x00056480
	.long 0x46000000
	.long 0x00056484
	.long 0x00000000
	.long 0x00056488
	.long 0x46000000
	.long 0x0005648C
	.long 0x00000000
	.long 0x00056490
	.long 0x46000000
	.long 0x00056494
	.long 0x00000000
	.long 0x00056498
	.long 0x46000000
	.long 0x0005649C
	.long 0x00000000
	.long 0x000564A0
	.long 0x46000000
	.long 0x000564A4
	.long 0x00000000
	.long 0x000564A8
	.long 0x46000000
	.long 0x000564AC
	.long 0x00000000
	.long 0x000564B0
	.long 0x46000000
	.long 0x000564B4
	.long 0x00000000
	.long 0x000564B8
	.long 0x46000000
	.long 0x000564BC
	.long 0x00000000
	.long 0x000564C0
	.long 0x46000000
	.long 0x000564C4
	.long 0x00000000
	.long 0x000564C8
	.long 0x46000000
	.long 0x000564CC
	.long 0x00000000
	.long 0x000564D0
	.long 0x46000000
	.long 0x000564D4
	.long 0x00000000
	.long 0x000564D8
	.long 0x46000000
	.long 0x000564DC
	.long 0x00000000
	.long 0x000564E0
	.long 0x46000000
	.long 0x000564E4
	.long 0xC2DB0000
	.long 0x000564EC
	.long 0xC2A00000
	.long 0x00056504
	.long 0xC2DF0000
	.long 0x00056508
	.long 0x00000000
	.long 0x0005650C
	.long 0x42DE0000
	.long 0x00056514
	.long 0x42D40000
	.long 0x0005651C
	.long 0x42DE0000
	.long 0x00056520
	.long 0x00000000
	.long 0x00056534
	.long 0x42D40000
	.long 0x0005653C
	.long 0xC2DB0000
	.long 0x00056544
	.long 0xC2DF0000
	.long 0x0005654C
	.long 0xC2CB0000
	.long 0x00056554
	.long 0x42C40000
	.long 0x0005655C
	.long 0x00000000
	.long 0x00056560
	.long 0x46000000
	.long 0x00056564
	.long 0x00000000
	.long 0x00056568
	.long 0x46000000
	.long 0x0005656C
	.long 0x42990000
	.long 0x00058FE0
	.long 0x7F7F0320
	.long 0x00058FE4
	.long 0x7F7F0708
	.long 0x00058FE8
	.long 0x0000C28F
	.long 0x00059038
	.long 0x000404A3
	.long 0x0005A5FC
	.long 0x43A58000
	.long 0x0005A63C
	.long 0xC3A50000
	.long 0x0005A640
	.long 0x437A0000
	.long 0x0005A8BC
	.long 0xC22AAAAB
	.long 0x0005A8C0
	.long 0x42200000
	.long 0x0005A8FC
	.long 0x422AAAAB
	.long 0x0005A900
	.long 0x42200000
	.long 0x0005A93C
	.long 0x42B15555
	.long 0x0005A940
	.long 0x40A00000
	.long 0x0005A97C
	.long 0xC2B15555
	.long 0x0005A980
	.long 0x40A00000

	#Adjust camera zoom
	.long 0x58ed0
	.long 135

	.long -1

/*
StageMod_WIPYoster:
	.long 0x0001458C
	.long 0x80000000
	.long 0x000147EC
	.long 0x80000000
	.long 0x000148EC
	.long 0x80000000
	.long 0x00014AAC
	.long 0x80000000
	.long 0x00014BAC
	.long 0x80000000
	.long 0x00014D4C
	.long 0x80000000
	.long 0x00014F0C
	.long 0x80000000
	.long 0x0001500C
	.long 0x80000000
	.long 0x000151AC
	.long 0x80000000

	#Move right side of stage back
	.long 0x25108 + 0x30
	.float -40
	.long 0x25108 + 0x34
	.float -200
	#Move left side forward
	.long 0x25308 + 0x30
	.float 40
	.long 0x25308 + 0x34
	.float 200
	#Move trees forward
	.long 0x25148 + 0x30
	.float 70
	.long 0x25148 + 0x34
	.float 123.75
	.long 0x25188 + 0x30
	.float 85
	.long 0x25188 + 0x34
	.float 100
	.long 0x251C8 + 0x30
	.float 75
	.long 0x251C8 + 0x34
	.float 92

	#remove all vertices
	.long 0xCD02b888
	.long 54*2 *4
	.long -1000

	#vert 10
	.long 0x2b888 + 10 * 8
	.float -132.25
	.long 0x2b888 + 10 * 8 + 4
	.float 0.0001
	#vert 14
	.long 0x2b888 + 14 * 8
	.float -115
	.long 0x2b888 + 14 * 8 + 4
	.float 0.0001
	#vert 17
	.long 0x2b888 + 17 * 8
	.float -50
	.long 0x2b888 + 17 * 8 + 4
	.float 0.0001
	#vert 15
	.long 0x2b888 + 15 * 8
	.float -50
	.long 0x2b888 + 15 * 8 + 4
	.float 0.0001
	#vert 16
	.long 0x2b888 + 16 * 8
	.float -50
	.long 0x2b888 + 16 * 8 + 4
	.float 0.0001
	#vert 11
	.long 0x2b888 + 11 * 8
	.float 0
	.long 0x2b888 + 11 * 8 + 4
	.float 0.0001
	#vert 12
	.long 0x2b888 + 12 * 8
	.float -17.25
	.long 0x2b888 + 12 * 8 + 4
	.float 0.0001
	#vert 13
	.long 0x2b888 + 13 * 8
	.float -17.25
	.long 0x2b888 + 12 * 8 + 4
	.float -200
	#vert 9
	.long 0x2b888 + 9 * 8
	.float -132.25
	.long 0x2b888 + 12 * 8 + 4
	.float -200

	#remove plants in foreground
	.long 0x14138 + 0xC
	.long 0
	.long 0x140B8 + 0xC
	.long 0
	.long 0x14038 + 0xC
	.long 0
	.long -1
*/

StageMod_Yoster:
	#.long 0x00013FBC
	#.long 0x00014198
	#Remove Pipe
	.long 0x0001458C
	.long 0x80000000
	.long 0x000147EC
	.long 0x80000000
	.long 0x000148EC
	.long 0x80000000
	.long 0x00014AAC
	.long 0x80000000
	.long 0x00014BAC
	.long 0x80000000
	.long 0x00014D4C
	.long 0x80000000
	.long 0x00014F0C
	.long 0x80000000
	.long 0x0001500C
	.long 0x80000000
	.long 0x000151AC
	.long 0x80000000

	#Move right side of stage back
	.long 0x25108 + 0x2C
	.float 85.8
	.long 0x25108 + 0x30
	.float -40
	.long 0x25108 + 0x34
	.float -200
	#Move left side forward
	.long 0x25308 + 0x30
	.float 40
	.long 0x25308 + 0x34
	.float 200
	#Stretch left side
	.long 0x25308 + 0x20
	.float 1.32
	#Move trees forward
	.long 0x25148 + 0x2C
	.float -165
	.long 0x25148 + 0x30
	.float 70
	.long 0x25148 + 0x34
	.float 123.75

	.long 0x25188 + 0x2C
	.float -135
	.long 0x25188 + 0x30
	.float 85
	.long 0x25188 + 0x34
	.float 100

	.long 0x251C8 + 0x2C
	.float -80
	.long 0x251C8 + 0x30
	.float 75
	.long 0x251C8 + 0x34
	.float 92
	#remove plants in foreground
	.long 0x14138 + 0xC
	.long 0
	.long 0x140B8 + 0xC
	.long 0
	.long 0x14038 + 0xC
	.long 0

	#/*
	#remove all vertices
	.long 0xCD02b888
	.long 0x1B0
	.float -1000

	#vert 10
	.long 0x2B8D8
	.float -67
	.long 0x2B8DC
	.float 0.0001
	#vert 14
	.long 0x2B8F8
	.float -30
	.long 0x2B8FC
	.float 0.0001
	#vert 17
	.long 0x2B910
	.float -20
	.long 0x2B914
	.float 0.0001
	#vert 15
	.long 0x2B900
	.float 0
	.long 0x2B904
	.float 0.0001
	#vert 16
	.long 0x2B908
	.float 20
	.long 0x2B90C
	.float 0.0001
	#vert 11
	.long 0x2B8E0
	.float 30
	.long 0x2B8E4
	.float 0.0001
	#vert 12
	.long 0x2B8E8
	.float 67
	.long 0x2B8EC
	.float 0.0001
	#vert 13
	.long 0x2B8F0
	.float 67
	.long 0x2B8F4
	.float -200
	#vert 9
	.long 0x2B8D0
	.float -67
	.long 0x2B8D4
	.float -200

	#Adjust camera zoom
	.long 0x2c1b8
	.long 135

	#Adjust camera
	.long 0x2c4c4
	.float -140			#left
	.long 0x2c4c8
	.float 130.0		#top
	.long 0x2c504
	.float 140.0		#right
	.long 0x2c508
	.float -60.0		#bottom

	#Adjust blastzone
	.long 0x2c584
	.float -180			#left
	.long 0x2c544
	.float 180			#right
	.long 0x2c548
	.float -110			#bottom
	.long 0x2c588
	.float 180			#top

	#p1 spawn
	.long 0x2c844
	.float -45
	.long 0x2c848
	.float 7
	#p2 spawn
	.long 0x2c884
	.float 45
	.long 0x2c888
	.float 7
	#p3 spawn
	.long 0x2c8c4
	.float 25
	.long 0x2c8c8
	.float 7
	#p4 spawn
	.long 0x2c904
	.float -25
	.long 0x2c908
	.float 7

	.long -1

StageMod_MK1:
	.long 0x0000C0F8
	.long 0xC60C0000
	.long 0x0000C238
	.long 0xC6340000
	.long 0x0000C278
	.long 0xC6340000
	.long 0x0000C2B8
	.long 0xC6340000
	.long 0x0000C2F8
	.long 0xC6340000
	.long 0x0000C338
	.long 0xC6340000
	.long 0x0000C378
	.long 0xC6340000
	.long 0x0000C3B8
	.long 0xC60C0000
	.long 0x0000C3F8
	.long 0xC60C0000
	.long 0x0000C438
	.long 0xC60C0000
	.long 0x0000C478
	.long 0xC60C0000
	.long 0x0000C4B8
	.long 0xC60C0000
	.long 0x0000C4F8
	.long 0xC60C0000

	#Scale Platforms
	.long 0x0000C5B8
	.long 0xC2720000
	.long 0x0000C664
	.long 0xC2A20000
	.long 0x0000C668
	.long 0x430D0000
	.long 0x0000C6D4
	.long 0x42A20000
	.long 0x0000C6D8
	.long 0x430D0000
	.long 0x0000C744
	.long 0x42A20000
	.long 0x0000C824
	.long 0xC2A20000

	.long 0x0000ECDC
	.long 0x00000000
	.long 0x0000ECE4
	.long 0x00000000
	.long 0x0000ECE8
	.long 0x00000000
	.long 0x0000ECEC
	.long 0x00000000
	.long 0x0000ECF4
	.long 0x00000000
	.long 0x0000ECF8
	.long 0x00000000
	.long 0x0000ECFC
	.long 0x00000000
	.long 0x0000ED04
	.long 0x00000000
	.long 0x0000ED0C
	.long 0x00000000
	.long 0x0000ED10
	.long 0x00000000
	.long 0x0000ED14
	.long 0x00000000
	.long 0x0000ED1C
	.long 0x00000000
	.long 0x0000ED20
	.long 0x00000000
	.long 0x0000ED24
	.long 0x00000000

	#remove top bricks
	.long 0xC108 + 0x30
	.float -300
	.long 0xC508 + 0x30
	.float -300
	.long 0xC548 + 0x30
	.float -300
	.long 0xC148 + 0x30
	.float -300
	.long 0xC188 + 0x30
	.float -300
	.long 0xC1C8 + 0x30
	.float -300

	#scale weight limit?
	.long 0x0000FDAC
	.long 0x41A00000
	.long 0x00010374
	.long 0xC21C0000
	.long 0x000103B4
	.long 0x421C0000

	#remove left side of stage
	.long 0x83D8 + 0xC
	.long 0
	.long 0x8538 + 0xC
	.long 0
	.long 0x85B8 + 0xC
	.long 0
	#remove right side of stage
	.long 0x8818 + 0xC
	.long 0
	.long 0x8978 + 0xC
	.long 0
	.long 0x89F8 + 0xC
	.long 0

	#Remove pipes
	.long 0xC048 + 0x30
	.float -1000
	#Remove misc foreground objects
	.long 0x7BD8 + 0xC
	.long 0
	.long 0x7C38 + 0xC
	.long 0
	.long 0x7C98 + 0xC
	.long 0
	.long 0x7BF8 + 0xC
	.long 0
	.long 0x7CF8 + 0xC
	.long 0
	.long 0x7DD8 + 0xC
	.long 0
	.long 0x7F58 + 0xC
	.long 0
	#.long 0x7FF8 + 0xC
	#.long 0
	#.long 0x8098 + 0xC
	#.long 0
	.long 0x80F8 + 0xC
	.long 0
	.long 0x8158 + 0xC
	.long 0
	.long 0x81F8 + 0xC
	.long 0
	.long 0x8298 + 0xC
	.long 0

	#p1 spawn
	.long 0x10374
	.float -36
	.long 0x10378
	.float 7
	#p2 spawn
	.long 0x103b4
	.float 36
	.long 0x103b8
	.float 7
	#p3 spawn
	.long 0x103f4
	.float 15
	.long 0x103f8
	.float 7
	#p4 spawn
	.long 0x10434
	.float -15
	.long 0x10438
	.float 7

	.long -1

StageMod_MK2:
	.long 0x00001560
	.long 0x31E8FEFF
	.long 0x00001568
	.long 0x03050003
	.long 0x00009DB4
	.long 0xC67F0000
	.long 0x00009E34
	.long 0x467F0000
	.long 0x00012AB4
	.long 0xC2F20000
	.long 0x00013034
	.long 0x42F20000
	.long 0x00013210
	.long 0x00000000
	.long 0x00013214
	.long 0x00000000
	.long 0x00013218
	.long 0x00000000
	.long 0x0001321C
	.long 0x00000000
	.long 0x00013220
	.long 0x00000000
	.long 0x00013224
	.long 0x00000000
	.long 0x00013228
	.long 0x00000000
	.long 0x0001322C
	.long 0x00000000
	.long 0x00013230
	.long 0x00000000
	.long 0x00013234
	.long 0x00000000
	.long 0x00013238
	.long 0x42D40000
	.long 0x00013240
	.long 0x42D40000
	.long 0x00013248
	.long 0x00000000
	.long 0x0001324C
	.long 0x00000000
	.long 0x00013250
	.long 0x00000000
	.long 0x00013254
	.long 0x00000000
	.long 0x00013258
	.long 0x00000000
	.long 0x0001325C
	.long 0x00000000
	.long 0x00013260
	.long 0x00000000
	.long 0x00013264
	.long 0x00000000
	.long 0x00013268
	.long 0x00000000
	.long 0x0001326C
	.long 0x00000000
	.long 0x00013278
	.long 0xC2D40000
	.long 0x00013280
	.long 0xC2D40000
	.long 0x00015F54
	.long 0xC3460000
	.long 0x00015F94
	.long 0x43480000
	.long 0x00015FD4
	.long 0xC3960000
	.long 0x00016014
	.long 0x43960000
	#Stretch main plat
		.long	0x9DE8
		.float	2.35
	#Stretch waterfall
		.long 0x9ea8
		.float 2.5
	#Stretch waterfall glisten
		.long 0x9e68
		.float 2.5

	#p1 spawn
	.long 0x16214
	.float -62
	.long 0x16218
	.float 7
	#p2 spawn
	.long 0x16254
	.float 62
	.long 0x16258
	.float 7
	#p3 spawn
	.long 0x16294
	.float 32
	.long 0x16298
	.float 7
	#p4 spawn
	.long 0x162d4
	.float -32
	.long 0x162d8
	.float 7

		.long -1

StageMod_FlatZone:
	#Scale Handheld down
	.long 0xC328
	.float 0.5
	.long 0xC32C
	.float 0.5
	.long 0xC330
	.float 0.5
	#Move handheld down
	.long	0xC338
	.float -80.95
	#Move handheld forward
	.long	0xC33C
	.float 5
	#Scale background up
	.long 0x46148
	.float 5
	.long 0x4614C
	.float 5
	.long 0x46150
	.float 5
	#Move bg down
	.long 0x46158
	.float -60
	#Move bg forward
	.long 0x4615C
	.float 10

	#Move platforms to the right slightly
	.long 0x3dd54
	.float 4.8

	#Ground Left Point
	.long 0x466fC
	.float 300
	#Ground Right Point
	.long 0x46704
	.float 300

	.set	FloorTotal,101+3
	.set	CeilingTotal,0
	.set	Wall1Total,1
	.set	Wall2Total,1
	#Increment total line count
	.long 0x475CC
	.long 0x6A
	#Increment global floor counter
	.long 0x475d0
	.hword 0,FloorTotal
	#Remove global ceiling counter
	.long 0x475d4
	.hword 0,0
	#Increment global wall counter
	.long 0x475d8
	.hword 104,Wall1Total
	#Increment global wall counter
	.long 0x475dC
	.hword 105,Wall2Total

	#Null Areas jobj center
	.long 0xa0
	.long 0x00000000
	.long 0xa4
	.long 0x00000022
	#Adjust areas link types
	.long 0x473e0
	.hword 101,3		#ground
	.long 0x473e4
	.long 0x00000000	#no ceilings
	.long 0x473e8
	.hword 104,1		#wall1
	.long 0x473eC
	.hword 105,1		#wall2
	.long 0x47404
	.hword 0x7F,6		#vert count
	.long 0x473f4		#X Min
	.float -90
	.long 0x473f8		#Y Min
	.float -210
	.long 0x473fC		#X Max
	.float 90
	.long 0x47400		#Y Max
	.float -10

	#EDIT VERTS
	#vert 127
	.long 0x46578
	.float 81.6
	.long 0x4657C
	.float -29.3597
	#vert 128
	.long 0x46580
	.float 81.6
	.long 0x46584
	.float -200
	#vert 129
	.long 0x46588
	.float 61.6
	.long 0x4658C
	.float -29.3597
	#vert 130
	.long 0x46590
	.float -61.6
	.long 0x46594
	.float -29.3597
	#vert 131
	.long 0x46598
	.float -81.6
	.long 0x4659C
	.float -29.3597
	#vert 132
	.long 0x465A0
	.float -81.6
	.long 0x465A4
	.float -200

	#change link 101
	.long 0x46d58
	.hword 131,130 		#vertex index
	.long 0x46d5C
	.hword 105,103			#next and prev link
	.long 0x46d64
	.long 0x00010210 		#bottom w/ ledgegrab
	#change link 102
	.long 0x46d68
	.hword 129,127 		#vertex index
	.long 0x46d6C
	.hword 103,104			#next and prev link
	.long 0x46d74
	.long 0x00010210 		#bottom w/ ledgegrab
	#change link 103
	.long 0x46d78
	.hword 130,129 		#vertex index
	.long 0x46d7C
	.hword 101,102			#next and prev link
	.long 0x46d84
	.long 0x00010010 		#bottom
	#change link 104
	.long 0x46d88
	.hword 127,128 		#vertex index
	.long 0x46d8C
	.hword 102,-1			#next and prev link
	.long 0x46d94
	.long 0x00040010		#right
	#change link 105
	.long 0x46d98
	.hword 132,131 		#vertex index
	.long 0x46d9C
	.hword -1,101			#next and prev link
	.long 0x46dA4
	.long 0x00080010 		#left

	#Remove 2 right platforms (vertex 156,157,158)
	.long 0x464c4
	.float 300
	.long 0x464cc
	.float 300
	.long 0x464d4
	.float 300
	#.long 0x46664
	#.long 0x00000000

	#adjust camera bounds
	.long 0x49510
	.float -165
	.long 0x494d0
	.float 160
	.long 0x49514
	.float -80
	.long 0x494d4
	.float 120
	#adjust camera zoom
	.long 0x47850
	.long 160
	.long 0x47854
	.long 1000
	#adjust pause camera zoom
	.long 0x47874
	.long 40
	.long 0x47878
	.long 100
	.long 0x4787C
	.long 200
	#adjust blastzone bounds
	#X
	.long 0x49550
	.float 230
	.long 0x49590
	.float -230
	#Y
	.long 0x49554
	.float 160
	.long 0x49594
	.float -100

	#p1 spawn
	.long 0x496d0
	.float -61.6
	.long 0x496d4
	.float -22.3597
	#p2 spawn
	.long 0x49710
	.float 61.6
	.long 0x49714
	.float -22.3597
	#p3 spawn
	.long 0x49750
	.float 31.6
	.long 0x49754
	.float -22.3597
	#p4 spawn
	.long 0x49790
	.float -31.6
	.long 0x49794
	.float -22.3597

	#p1 respawn
	.long 0x497d4
	.float 20

	.long -1

StageMod_RCruise:

	/*
	#Move plat
	.long 0x39068
	.float	0.7		#scale X
	.long 0x3906C
	.float	0.7		#scale Y
	.long 0x39070
	.float	0.7		#Scale Z
	.long 0x39074		#ticktock X
	.float 700
	.long 0x39078		#ticktock Y
	.float -375
	.long 0x3907C		#ticktock Z
	.float -30
	*/

	#side plats should be 150 apart
	# top plat should be 75 above sides
	#Move left plat
	.long 0x39274
	.float -75
	.long 0x39278
	.float -455
	#Move top plat
	.long 0x392b4
	.float 0
	.long 0x392b8
	.float -430
	#Move right plat
	.long 0x392f4
	.float 75
	.long 0x392f8
	.float -455

	#Move stage
	.long 0x61be4
	.float	1.5708		#Rotate Z
	.long 0x61be8
	.float	1.7		#scale X
	.long 0x61beC
	.float	2.5		#scale Y
	.long 0x61bf0
	.float	1.1		#Scale Z
	.long 0x61bf4		# X
	.float 1.8
	.long 0x61bf8		# Y
	.float -530
	.long 0x61bfC		# Z
	.float -0

	#adjust camera zoom
	.long 0x74d48			#max zoom
	.long 150
	.long 0x74d4C			#unk
	.long 1000
	#adjust camera boundaries
	.long 0x750d4		#X max
	.float 250
	.long 0x75094		#X min
	.float -250
	.long 0x750d8		#Y max
	.float 220
	.long 0x75098		#Y min
	.float -100

	#adjust blastzones
	.long 0x75114
	.float 310
	.long 0x75154
	.float -310
	.long 0x75118
	.float	270
	.long 0x75158
	.float -160

	#Change area region (area 13)
	.long 0x745cc		#X min
	.float -1000
	.long 0x745d0		#Y min
	.float -1000
	.long 0x745d4		#X max
	.float 1000
	.long 0x745d8		#Y max
	.float 1000

	#Change line 53 to a ledge
	.long 0x73efc
	.long 0x00010200

	#ground
	#link 49 (vertices 67 and 68)
	#link 50 (vertices 68 and 69)
	#link 51 (vertices 69 and 70)
	#link 52 (vertices 70 and 71)
	#link 53 (vertices 71 and 65)
	#ceiling
	#link 83 (vertices 63 and 66)
	#link 84 (vertices 62 and 63)
	#link 85 (vertices 64 and 62)
	#link 86 (vertices 61 and 64)
	#link 87 (vertices 60 and 61)
	#left
	#link 110 (vertices 66 and 67)
	#right
	#link 98 (vertices 65 and 60)

	#74 Y diff

	#Move vertices
	#vert 67
	.long 0x73840
	.float	-112.5
	.long 0x73844
	.float -493
	#vert 68
	.long 0x73848
	.float -40
	.long 0x7384C
	.float -493
	#vert 69
	.long 0x73850
	.float	-20
	.long 0x73854
	.float -493
	#vert 70
	.long 0x73858
	.float	20
	.long 0x7385C
	.float -493
	#vert 71
	.long 0x73860
	.float	40
	.long 0x73864
	.float -493
	#vert 65
	.long 0x73830
	.float	112.5
	.long 0x73834
	.float -493

	#vert 60
	.long 0x73808
	.float	112.5
	.long 0x7380C
	.float -567
	#vert 61
	.long 0x73810
	.float	40
	.long 0x73814
	.float -567
	#vert 62
	.long 0x73818
	.float	20
	.long 0x7381C
	.float -567
	#vert 63
	.long 0x73820
	.float	-20
	.long 0x73824
	.float	-567
	#vert 64
	.long 0x73828
	.float	-40
	.long 0x7382C
	.float	-567
	#vert 66
	.long 0x73838
	.float	-112.5
	.long 0x7383C
	.float	-567

	#plat lines
	#left plat left point
	.long 0x738a8
	.float -105
	.long 0x738ac
	.float -455
	#left plat right point
	.long 0x738b0
	.float -45
	.long 0x738b4
	.float -455
	#top plat left point
	.long 0x738b8
	.float -30
	.long 0x738bc
	.float -430
	#top plat right point
	.long 0x738c0
	.float 30
	.long 0x738c4
	.float -430
	#right plat left point
	.long 0x738c8
	.float 45
	.long 0x738cc
	.float -455
	#right plat right point
	.long 0x738d0
	.float 105
	.long 0x738d4
	.float -455

	#Platform collision ranges
	#left
	.long 0x74694
	.float -500
	.long 0x74698
	.float -500
	.long 0x7469C
	.float 500
	.long 0x746A0
	.float 500
	#top
	.long 0x746bc
	.float -500
	.long 0x746c0
	.float -500
	.long 0x746c4
	.float 500
	.long 0x746c8
	.float 500
	#right
	.long 0x746e4
	.float -500
	.long 0x746e8
	.float -500
	.long 0x746ec
	.float 500
	.long 0x746f0
	.float 500

	#Change spawn points
	#p1
	.long 0xeefc
	.float -520
	.long 0xef00
	.float 40
	#p2
	.long 0xef3c
	.float -370
	.long 0xef40
	.float 40
	#p3
	.long 0xef7c
	.float -370
  .long 0xef80
  .float 7
	#p4
	.long 0xefbc
	.float -520
	.long 0xefc0
	.float 7

	#Change Respawn points
	.long 0x75518
	.float 100

	/*
	.long 0x39328
	.float	0.7		#scale X
	.long 0x3932C
	.float	0.7		#scale Y
	.long 0x39330
	.float	0.7		#Scale Z
	.long 0x39334		#ticktock X
	.float 0
	.long 0x39338		#ticktock Y
	.float -0
	.long 0x3933C		#ticktock Z
	.float -0
	*/
	.long -1

StageMod_Onett:
	#Move scenery down
	.long 0x3d6d8
	.float -100
	#Move scenery back
	.long 0x3d6dc
	.float -400
	#Rotate scenery
	.long 0x3d6bc
	.float 0.20944

	#Rotate building
	.long 0x3d77C
	.float -0.20944
	#Scale building up
	.long 0x3d788
	.float 3
	.long 0x3d78C
	.float 3
	.long 0x3d790
	.float 4
	#Move building X
	.long 0x3d794
	.float -0
	#Move building down
	.long 0x3d798
	.float -84
	#Move building forward
	.long 0x3d79c
	.float 662

	#Move top awning
	.long 0x46314
	.float -70
	.long 0x46318
	.float 30
	.long 0x4631C
	.float -13
	#move bottom awning
	.long 0x46394
	.float 70
	.long 0x46398
	.float 30
	.long 0x4639C
	.float -13

	#Scale sign
	.long 0x46408
	.float 3
	.long 0x4640C
	.float 3
	.long 0x46410
	.float 3
	#Move sign
	.long 0x46414
	.float 0
	.long 0x46418
	.float -30
	.long 0x4641C
	.float 5

	# remove all vertices except 66,67,68,69
	.long 0xCD049a68
	.long 0x210
	.float -300

	/*
	#break off from line 58
	.long 0x4a038
	.hword 42,42
	.long 0x4a03C
	.hword 59,-1
	#break off from line 50
	.long	0x49fb8
	.hword 48,48
	.long	0x49fb8
	.hword -1,48
	*/

	#adjust area hitbox
	.long 0x4a0f0
	.float -200

	#vertex 44
	.long 0x49BC8
	.float	-81
	.long 0x49BCC
	.float 0.0001
	#vertex 45
	.long 0x49BD0
	.float	-60
	.long 0x49BD4
	.float 0.0001
	#vertex 62
	.long 0x49C58
	.float	60
	.long 0x49C5C
	.float 0.0001
	#vertex 46
	.long 0x49BD8
	.float	81
	.long 0x49BDC
	.float 0.0001
	#vertex 43
	.long 0x49BC0
	.float	-81
	.long 0x49BC4
	.float -200
	#vertex 47
	.long 0x49BE0
	.float	81
	.long 0x49BE4
	.float -200

	#Adjust camera
	.long 0x4ded8
	.float -150		#left
	.long 0x4dedC
	.float 160		#top
	.long 0x4df18
	.float 150		#right
	.long 0x4df1C
	.float -70		#bottom

	#Adjust blastzone
	.long 0x4df58
	.float -225		#left
	.long 0x4df5C
	.float 210		#top
	.long 0x4df98
	.float 225		#right
	.long 0x4df9C
	.float -120		#bottom


	#Camera Zoom
	.long 0x4daec
	.long 130
	.long 0x4daf0
	.long 1000

	#p1 spawn
	.long 0x4e258
	.float -60
	.long 0x4e25C
	.float 5
	#p2 spawn
	.long 0x4e298
	.float 60
	.long 0x4e29C
	.float 5
	#p3 spawn
	.long 0x4e2d8
	.float 35
	.long 0x4e2dC
	.float 5
	#p4 spawn
	.long 0x4e318
	.float -35
	.long 0x4e31C
	.float 5

	#p1 respawn
	.long 0x4e358
	.float 0
	.long 0x4e35C
	.float 50

	.long -1

StageMod_MuteCity:
	#0x20 = scale
	#0x2C = position

	#Remove pipes
	.long 0x2dac4
	.long 0
	#Remove right side of GO
	.long 0x2D704
	.long 0
	.long 0x2D4D8 + 0xC
	.long 0
	#Remove left side of GO
	.long 0x2D458 + 0xC
	.long 0
	.long 0x2D238 + 0xC
	.long 0
	#Move entire stage
	.long 0x2E328 + 0x30
	.float -125.5
	.long 0x2E328 + 0x34
	.float -1910
	#Hide main plat
	.long 0x37BE8 + 0x4
	.long 0x00140010
	#Show quad plat
	.long 0x37C28 + 0x4
	.long 0x00040000
	.long 0x37C28 + 0x30
	.float 60
	#Enable shadows on main floor
	#.long 0x19590
	#.long 0x00000000
	# remove all vertices except 1,2,3,4
	.long 0xCD04c9bc + 8*8
	.long 0x220 - 8*8
	.float -300

	#edit main grounds line group hitbox
	.long 0x4d068		#X min
	.float 0
	.long 0x4d06C		#Y min
	.float -200
	.long 0x4d070		#X max
	.float 400
	.long 0x4d074		#Y max
	.float 200

	#move main ground collision
	#vert 60
	.long 0x04c9bc + 60*8
	.float 175
	.long 0x04c9bc + 60*8 + 4
	.float -17.9
	#vert 61
	.long 0x04c9bc + 61*8
	.float 360
	.long 0x04c9bc + 61*8 + 4
	.float -17.9
	#vert 62
	.long 0x04c9bc + 62*8
	.float 360
	.long 0x04c9bc + 62*8 + 4
	.float -57
	#vert 63
	.long 0x04c9bc + 63*8
	.float 175
	.long 0x04c9bc + 63*8 + 4
	.float -57

	#main ground link = ledge grab
	.long 0x4cd38
	.long 0x00010206

	#Remove fzero car hitboxes
	.long 0x4d630
	.long 0

	#Adjust camera zoom
	.long 0x4d460
	.long 135

	#Adjust camera
	.long 0x4d8a4
	.float -280
	.long 0x4d8a8
	.float 250
	.long 0x4d8e4
	.float 280
	.long 0x4d8e8
	.float -73

	#Adjust blastzone
	.long 0x4d924
	.float -360
	.long 0x4d928
	.float 335
	.long 0x4d964
	.float 360
	.long 0x4d968
	.float -165

	#p1 spawn
	.long 0x4dae4
	.float -80
	.long 0x4dae8
	.float 5
	#p2 spawn
	.long 0x4db24
	.float 80
	.long 0x4db28
	.float 5
	#p3 spawn
	.long 0x4db64
	.float 40
	.long 0x4db68
	.float 5
	#p4 spawn
	.long 0x4dba4
	.float -40
	.long 0x4dba8
	.float 5

	#respawn plat
	.long 0x4dbe8
	.float 100

	#look into 80030788 for cam panning

	.long -1
/*
StageMod_Corneria:

	#Rotate City
	.long 0x36668 + 0x18
	.float	-0.802
	#Scale City
	.long 0x36668 + 0x20
	.float	4
	.long 0x36668 + 0x24
	.float	4
	.long 0x36668 + 0x28
	.float	4
	#Move City
	.long 0x36668 + 0x2C
	.float	-2200
	.long 0x36668 + 0x30
	.float	-400
	.long 0x36668 + 0x34
	.float	-2550

	.long -1
*/

Exit:
  lis	r3, 0x8047
