#To be inserted at 8024e81c
.macro branchl reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctrl
.endm

.macro branch reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctr
.endm

.macro load reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
.endm

.macro loadf regf,reg,address
lis \reg, \address @h
ori \reg, \reg, \address @l
stw \reg,-0x4(sp)
lfs \regf,-0x4(sp)
.endm

.macro backup
addi sp,sp,-0x4
mflr r0
stw r0,0(sp)
.endm

.macro restore
lwz r0,0(sp)
mtlr r0
addi sp,sp,0x4
.endm

.macro intToFloat reg,reg2
xoris    \reg,\reg,0x8000
lis    r18,0x4330
lfd    f16,-0x7470(rtoc)    # load magic number
stw    r18,0(r2)
stw    \reg,4(r2)
lfd    \reg2,0(r2)
fsubs    \reg2,\reg2,f16
.endm

.set entity,31
.set player,31

stwu	r1,-68(r1)	# make space for 12 registers
stmw	r20,8(r1)	# push r20-r31 onto the stack
mflr r0
stw r0,64(sp)

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,1
	branchl r14,0x803a6754

#BACKUP STRUCT POINTER
	mr r31,r3 

#STORE POINTER
	stw	r31,-0x4EB4(r13)

#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(r31)

#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(r31)

#GET PROPERTIES TABLE
	bl TEXTPROPERTIES
	mflr r30

#Store Base Z Offset
	lfs f1,0xC(r30) #Z offset
	stfs f1,0x8(r31)

#######################
## Version Indicator ##
#######################

#SET COLOR TO GREEN
	load	r3,0x8dff6eff			#green
	stw	r3,0x30(r31)

#Initialize Subtext
	lfs 	f1,0x0(r30) 		#X offset of text
	lfs 	f2,0x4(r30)		#Y offset of text
	mr 	r3,r31		#struct pointer
	load	r4,0x80228a28		#pointer to ASCII
	branchl r14,0x803a6b98

#Set Text Size
	mr	r4,r3
	mr	r3,r31
	lfs	f1,0x08(r30) #get text scaling value from table
	lfs	f2,0x10(r30)
	branchl	r12,0x803a7548



##################
## R = Tutorial ##
##################


#Check For Training Mode ISO Game ID
	lis	r5,0x8000
	lwz	r5,0x0(r5)
	load	r6,0x47544d45			#GTME
	cmpw	r5,r6
	bne	SpawnLText

#SET COLOR TO White
	load	r3,0xFFFFFFFF		#white
	stw	r3,0x30(r31)

#Initialize Subtext
	lfs 	f1,0x14(r30) #X offset of text
	lfs 	f2,0x18(r30) #Y offset of text
	mr 	r3,r31       #struct pointer
	bl 	RText
	mflr 	r4		#pointer to ASCII
	branchl r14,0x803a6b98

#Set Text Size
	mr	r4,r3
	mr	r3,r31
	lfs	f1,0x1C(r30) #get text scaling value from table
	lfs	f2,0x20(r30)
	branchl	r12,0x803a7548


##################
## R = Tutorial ##
##################

SpawnLText:

#SET COLOR TO White
	load	r3,0xFFFFFFFF		#white
	stw	r3,0x30(r31)

#Initialize Subtext
	lfs 	f1,0x24(r30) #X offset of text
	lfs 	f2,0x28(r30) #Y offset of text
	mr 	r3,r31       #struct pointer
	bl 	LText
	mflr 	r4		#pointer to ASCII
	branchl r14,0x803a6b98

#Set Text Size
	mr	r4,r3
	mr	r3,r31
	lfs	f1,0x2C(r30) #get text scaling value from table
	lfs	f2,0x30(r30)
	branchl	r12,0x803a7548

b end


#**************************************************#
TEXTPROPERTIES:
blrl

#Version
.long 0x00000000 #text X pos (0)
.long 0xC21C0000 #text Y pos (-39)
.long 0x3D23D70A #text scaling X (0.04)
.long 0x41880000 #Z offset
.long 0x3D23D70A #text scaling Y (0.04)

#Press R
.long 0x41200000 #text X pos
.long 0xC21C0000 #text Y pos
.long 0x3D0F5C29 #text scaling X
.long 0x3D0F5C29 #text scaling Y

#Press L
.long 0xC1200000 #text X pos
.long 0xC21C0000 #text Y pos
.long 0x3D0F5C29 #text scaling X
.long 0x3D0F5C29 #text scaling Y



/*
#THIS HAS BEEN MOVED TO 0x80228a28
VersionText:
blrl
.long 0x54726169
.long 0x6e696e67
.long 0x204d6f64
.long 0x65207631
.long 0x2e303100
*/

RText:
blrl
.long 0x52208181
.long 0x20547574
.long 0x00000000

LText:
blrl
.long 0x4c208181
.long 0x204f5344
.long 0x00000000



#**************************************************#
end:

lwz r0,64(sp)
mtlr r0
lmw	r20,8(r1)	# pop r20-r31 off the stack
addi	r1,r1,68	# release the space

lmw	r26, 0x0038 (sp)


