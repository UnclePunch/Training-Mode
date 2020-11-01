#To be inserted at 80068f30
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set entity,31
.set player,31

.if PAL==1

backup

lwz r31,0x10C(r30)
lwz r31,0x8(r31)
subi r31,r31,0x20
lwz r3,0x0(r29)			#get character internal ID
cmpwi r3,0x1b			#check if master hand, crazy hand, wireframes, giga or sandbag
bge exit			#exit if so

bl SkipTable
bl diffMario
bl diffFox
bl diffCaptain
bl diffDK
bl diffKirby
bl diffBowser
bl diffLink
bl diffSheik
bl diffNess
bl diffPeach
bl diffPopo
bl diffNana
bl diffPikachu
bl diffSamus
bl diffYoshi
bl diffJigglypuff
bl diffMewtwo
bl diffLuigi
bl diffMarth
bl diffZelda
bl diffYLink
bl diffDoc
bl diffFalco
bl diffPichu
bl diffGaW
bl diffGanon
bl diffRoy

SkipTable:
mflr	r4		#Jump Table Start in r4
mulli	r3,r3,0x4		#Each Pointer is 0x4 Long
add	r4,r4,r3		#Get Event's Pointer Address
lwz	r5,0x0(r4)		#Get bl Instruction
rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
add	r5,r4,r5		#Gets Address in r4

################
## Patch Loop ##
################

continue:
patchLoop:
lwz r3,0x0(r5)
lwz r4,0x4(r5)

cmpwi r3,0xFF
beq endPatchLoop

add r3,r3,r31
stw r4,0x0(r3)
addi r5,r5,0x8
b patchLoop

endPatchLoop:
b exit


#################
## DIFF TABLES ##
#################
diffMario:

.long 0x00003344
.long 0x3f547ae1
.long 0x00003360
.long 0x42c40000
.long 0x000000FF

diffFox:

.long 0x0000379c
.long 0x42920000
.long 0x00003908
.long 0x40000000
.long 0x0000390c
.long 0x40866666
.long 0x00003910
.long 0x3dea0ea1
.long 0x00003928
.long 0x41a00000
.long 0x00003c04
.long 0x2c01480c
.long 0x00004720
.long 0x1b968013
.long 0x00004734
.long 0x1b968013
.long 0x0000473C
.long 0x04000009
.long 0x00004A40
.long 0x2C006811
.long 0x00004A4C
.long 0x281B0013
.long 0x00004A50
.long 0x0D00010B
.long 0x00004A54
.long 0x2C806811
.long 0x00004A60
.long 0x281B0013
.long 0x00004A64
.long 0x0D00010B
.long 0x00004B24
.long 0x2C00680D
.long 0x00004B30
.long 0x0F104013
.long 0x00004B38
.long 0x2C80380D
.long 0x00004B44
.long 0x0F104013
.long 0x000000FF

diffCaptain:

.long 0x0000380c
.long 0x00000007
.long 0x00004ef8
.long 0x2c003803
.long 0x00004f08
.long 0x0f80000b
.long 0x00004f0c
.long 0x2c802003
.long 0x00004f1C
.long 0x0f80000b
.long 0x000000FF

diffDK:

.long 0x000000FF

diffKirby:

.long 0x00004d10
.long 0x3fc00000
.long 0x00004d70
.long 0x42940000
.long 0x00004dd4
.long 0x41900000
.long 0x00004de0
.long 0x41900000
.long 0x000083ac
.long 0x2c000009
.long 0x000083b8
.long 0x348c8011
.long 0x00008400
.long 0x348C8011
.long 0x00008430
.long 0x0500008b
.long 0x00008438
.long 0x041a0500
.long 0x00008444
.long 0x0500008b
.long 0x000084dc
.long 0x05780578
.long 0x000085b8
.long 0x1000010b
.long 0x000085c0
.long 0x03e801f4
.long 0x000085cc
.long 0x1000010b
.long 0x000085d4
.long 0x038403e8
.long 0x000085e0
.long 0x1000010b
.long 0x00008818
.long 0x0b00010b
.long 0x0000882c
.long 0x0b00010b
.long 0x000088f8
.long 0x041a0bb8
.long 0x0000893c
.long 0x041a0bb8
.long 0x00008980
.long 0x041a0bb8
.long 0x000089E0
.long 0x04fef704
.long 0x000000FF

diffBowser:

.long 0x000036cc
.long 0x42EC0000
.long 0x000037c4
.long 0x0C000000
.long 0x000000FF

diffLink:

.long 0x00003468
.long 0x3f666666
.long 0x000039d8
.long 0x440C0000
.long 0x00003a44
.long 0xb4990011
.long 0x00003a48
.long 0x1b8c008f
.long 0x00003a58
.long 0xb4990011
.long 0x00003a5c
.long 0x1b8c008f
.long 0x00003a6c
.long 0xb4990011
.long 0x00003a70
.long 0x1b8c008f
.long 0x00003b30
.long 0x440C0000
.long 0x000000FF

diffSheik:

.long 0x000045c8
.long 0x2c015010
.long 0x000045d4
.long 0x2d198013
.long 0x000045dc
.long 0x2c80b010
.long 0x000045e8
.long 0x2d198013
.long 0x000049c4
.long 0x2c00680a
.long 0x000049d0
.long 0x281b8013
.long 0x000049d8
.long 0x2c80780a
.long 0x000049e4
.long 0x281b8013
.long 0x000049f0
.long 0x2c006808
.long 0x000049fc
.long 0x231b8013
.long 0x00004a04
.long 0x2c807808
.long 0x00004a10
.long 0x231b8013
.long 0x00005c98
.long 0x1e0c8080
.long 0x00005cf4
.long 0xb4800c90
.long 0x00005d08
.long 0xb4800c90
.long 0x000000FF

diffNess:

.long 0x00003a1c
.long 0xb4940013
.long 0x00003a64
.long 0x2c000015
.long 0x00003a70
.long 0xb4928013
.long 0x000000FF

diffPeach:

.long 0x000000FF

diffPopo:

.long 0x000000FF

diffNana:

.long 0x000000FF


diffPikachu:

.long 0x0000647C
.long 0xb49a4017
.long 0x00006480
.long 0x64001097
.long 0x000000FF

diffSamus:

.long 0x000000FF

diffYoshi:

.long 0x000033e4
.long 0x42de0000
.long 0x00004528
.long 0x2c013011
.long 0x00004534
.long 0xb4988013
.long 0x0000453c
.long 0x2c813011
.long 0x00004548
.long 0xb4988013
.long 0x00004550
.long 0x2d002011
.long 0x0000455c
.long 0xb4988013
.long 0x000045f8
.long 0x2c01300f
.long 0x00004608
.long 0x0f00010b
.long 0x0000460c
.long 0x2c81280f
.long 0x0000461c
.long 0x0f00010b
.long 0x00004aec
.long 0x2c007003
.long 0x00004b00
.long 0x2c803803
.long 0x000000FF

diffJigglypuff:

.long 0x000000FF

diffMewtwo:

.long 0x0000485c
.long 0x2c00000f
.long 0x000000FF

diffLuigi:

.long 0x000000FF

diffMarth:

.long 0x000037b0
.long 0x3f59999a
.long 0x000037cc
.long 0x42aa0000
.long 0x00005520
.long 0x87118013
.long 0x000000FF

diffZelda:

.long 0x000000FF

diffYLink:

.long 0x00003b8c
.long 0x440c0000
.long 0x00003d0c
.long 0x440c0000
.long 0x000000FF

diffDoc:

.long 0x000000FF

diffFalco:

.long 0x000050e4
.long 0xb4990013
.long 0x000050f8
.long 0xb4990013
.long 0x000000FF

diffPichu:

.long 0x000000FF

diffGaW:

.long 0x000000FF

diffGanon:

.long 0x00004eb0
.long 0x02bcff38
.long 0x00004ebc
.long 0x14000123
.long 0x00004ec4
.long 0x038401f4
.long 0x00004ed0
.long 0x14000123
.long 0x00004ed8
.long 0x044c04b0
.long 0x00004ee4
.long 0x14000123
.long 0x0000505c
.long 0x2c006815
.long 0x0000506c
.long 0x14080123
.long 0x00005070
.long 0x2c806015
.long 0x00005080
.long 0x14080123
.long 0x00005084
.long 0x2d002015
.long 0x00005094
.long 0x14080123
.long 0x000000FF

diffRoy:

.long 0x000000FF

exit:
restore
.endif

lis	r3, 0x803C
