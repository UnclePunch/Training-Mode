#To be inserted at 8024e81c
.include "../../Globals.s"

.set text,31
.set textproperties,30

.set VersionString,0x8040a58c

backup

########################
## Create Text Object ##
########################

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,1
	branchl r12,0x803a6754

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
	load	r4,VersionString		#pointer to ASCII
	branchl r12,0x803a6b98

##################
## R = Tutorial ##
##################

#SET COLOR TO White
	load	r3,0xFFFFFFFF		#white
	stw	r3,0x30(text)

#Check For Training Mode ISO Game ID
	lis	r5,0x8000
	lwz	r5,0x0(r5)
	load	r6,0x47544d45			#GTME
	cmpw	r5,r6
	bne	SpawnLText

#Initialize Subtext
	lfs 	f1,RX(textproperties) #X offset of text
	lfs 	f2,RY(textproperties) #Y offset of text
	mr 	r3,text       #struct pointer
	bl 	RText
	mflr 	r4		#pointer to ASCII
	branchl r12,0x803a6b98

##################
## R = Tutorial ##
##################

SpawnLText:

#SET COLOR TO White
	#load	r3,0xFFFFFFFF		#white
	#stw	r3,0x30(text)

#Initialize Subtext
	lfs 	f1,LX(textproperties) #X offset of text
	lfs 	f2,LY(textproperties) #Y offset of text
	mr 	r3,text       #struct pointer
	bl 	LText
	mflr 	r4		#pointer to ASCII
	branchl r12,0x803a6b98

##################
## R = Tutorial ##
##################

SpawnZText:

#SET COLOR TO White
	#load	r3,0xFFFFFFFF		#white
	#stw	r3,0x30(text)

#Initialize Subtext
	lfs 	f1,ZX(textproperties) #X offset of text
	lfs 	f2,ZY(textproperties) #Y offset of text
	mr 	r3,text       #struct pointer
	bl 	ZText
	mflr 	r4		#pointer to ASCII
	branchl r12,0x803a6b98

#Change scale
	mr	r4,r3
	mr	r3,text
	lfs	f1,ZScale(textproperties)
	lfs	f2,ZScale(textproperties)
	branchl r12,Text_UpdateSubtextSize

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
.set ZX,0x1C
.set ZY,0x20
.set ZScale,0x24
.set CanvasScaling,0x28

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

#Press Z
.float 300    #text X pos
.float -280   #text Y pos
.float 0.8		#text scale

.float 0.035   #Canvas Scaling

RText:
blrl
.string "R = Tut"
.align 2

LText:
blrl
.string "L = OSD"
.align 2

ZText:
blrl
.string "Z = Credits"
.align 2

#**************************************************#
end:

restore

lmw	r26, 0x0038 (sp)
