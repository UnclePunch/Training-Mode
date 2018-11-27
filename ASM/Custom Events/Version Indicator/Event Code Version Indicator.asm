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
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r20,0x8(r1)
.endm

.macro restore
lmw  r20,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
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

.set text,31
.set textproperties,30

backup

########################
## Create Text Object ##
########################

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,1
	branchl r14,0x803a6754

#BACKUP STRUCT POINTER
	mr text,r3

#STORE POINTER
	stw	text,-0x4EB4(r13)

#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(text)

#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(text)

#GET PROPERTIES TABLE
	bl TEXTPROPERTIES
	mflr textproperties

#Store Base Z Offset
	lfs f1,ZOffset(textproperties) #Z offset
	stfs f1,0x8(text)

#Scale Canvas Down
  lfs f1,CanvasScaling(textproperties)
  stfs f1,0x24(text)
  stfs f1,0x28(text)

#######################
## Version Indicator ##
#######################

#SET COLOR TO GREEN
	load	r3,0x8dff6eff			#green
	stw	r3,0x30(text)

#Initialize Subtext
	lfs 	f1,VersionX(textproperties) 		#X offset of text
	lfs 	f2,VersionY(textproperties)	  	#Y offset of text
	mr 	r3,text		#struct pointer
	load	r4,0x80228a28		#pointer to ASCII
	branchl r14,0x803a6b98

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
	stw	r3,0x30(text)

#Initialize Subtext
	lfs 	f1,RX(textproperties) #X offset of text
	lfs 	f2,RY(textproperties) #Y offset of text
	mr 	r3,text       #struct pointer
	bl 	RText
	mflr 	r4		#pointer to ASCII
	branchl r14,0x803a6b98

##################
## R = Tutorial ##
##################

SpawnLText:

#SET COLOR TO White
	load	r3,0xFFFFFFFF		#white
	stw	r3,0x30(text)

#Initialize Subtext
	lfs 	f1,LX(textproperties) #X offset of text
	lfs 	f2,LY(textproperties) #Y offset of text
	mr 	r3,text       #struct pointer
	bl 	LText
	mflr 	r4		#pointer to ASCII
	branchl r14,0x803a6b98

b end


#**************************************************#
TEXTPROPERTIES:
blrl
.set VersionX,0x0
.set VersionY,0x4
.set ZOffset,0x8
.set RX,0xC
.set RY,0x10
.set LX,0x14
.set LY,0x18
.set CanvasScaling,0x1C

#Version
.float 0      #text X pos
.float -230   #text Y pos
.float 17     #Z offset

#Press R
.float 310    #text X pos
.float -230   #text Y pos

#Press L
.float -310   #text X pos
.float -230   #text Y pos

.float 0.035   #Canvas Scaling

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

restore

lmw	r26, 0x0038 (sp)
