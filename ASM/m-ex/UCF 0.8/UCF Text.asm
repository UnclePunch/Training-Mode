#To be inserted @ 802662D0
.include "../../Globals.s"
.include "../Header.s"

.set REG_TextGObj,31
.set REG_TextProperties,30


NTSC102:
	.set	Injection,0x802662D0
	.set	Text_CreateTextGObj,0x803a6754
	.set	Text_InitializeSubtext,0x803a6b98
	.set	Text_UpdateSubtextSize,0x803a7548
/*
NTSC101:
	.set	Injection,0x80265B34
	.set	Text_CreateTextGObj,0x803A5A74
	.set	Text_InitializeSubtext,0x803A5EB8
	.set	Text_UpdateSubtextSize,0x803A6868
NTSC100:
	.set	Injection,0x80264FB8
	.set	Text_CreateTextGObj,0x803A4890
	.set	Text_InitializeSubtext,0x803A4CD4
	.set	Text_UpdateSubtextSize,0x803A5684

PAL100:
	.set	Injection,0x802669EC
	.set	Text_CreateTextGObj,0x803A6664
	.set	Text_InitializeSubtext,0x803a6b54
	.set	Text_UpdateSubtextSize,0x803A74FC
*/
backup

#GET PROPERTIES TABLE
	bl TEXTPROPERTIES
	mflr REG_TextProperties

########################
## Create Text Object ##
########################

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r14,Text_CreateTextGObj

#BACKUP STRUCT POINTER
	mr REG_TextGObj,r3

#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(REG_TextGObj)

#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(REG_TextGObj)

#Scale Canvas Down
	lfs f1,0xC(REG_TextProperties)
	stfs f1,0x24(REG_TextGObj)
	stfs f1,0x28(REG_TextGObj)

####################################
## INITIALIZE PROPERTIES AND TEXT ##
####################################

#Initialize Line of Text
	mr r3,REG_TextGObj       #struct pointer
	bl 	TEXT
	mflr 	r4		#pointer to ASCII
	lfs f1,0x0(REG_TextProperties) #X offset of REG_TextGObj
	lfs f2,0x4(REG_TextProperties) #Y offset of REG_TextGObj
	branchl r14,Text_InitializeSubtext

#Set Size/Scaling
  mr  r4,r3
  mr	r3,REG_TextGObj
	lfs   f1,0x8(REG_TextProperties) #get REG_TextGObj scaling value from table
	lfs   f2,0x8(REG_TextProperties) #get REG_TextGObj scaling value from table
  branchl	r12,Text_UpdateSubtextSize

b end


#**************************************************#
TEXTPROPERTIES:
blrl
.float 38			#x offset
.float -275		#y offset
.float 0.45		#REG_TextGObj scaling
.float 0.1		#canvas scaling


TEXT:
blrl
.string "UCF 0.8"
.align 2

#**************************************************#
end:
restore

addi	r4, r24, 0
