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

#Get Current Page
	lwz r3,MemcardData(r13)
	lbz r3,CurrentEventPage(r3)
	branchl r12,GetCustomEventPageName

#Initialize Subtext
	mr	r4,r3
	lfs 	f1,VersionX(textproperties) 		#X offset of text
	lfs 	f2,VersionY(textproperties)	  	#Y offset of text
	mr 	r3,text		#struct pointer
	branchl r12,0x803a6b98

###############################
## Left Page Arrow Indicator ##
###############################

#Initialize Subtext
	lfs 	f1,LeftArrowX(textproperties) 		#X offset of text
	lfs 	f2,ArrowY(textproperties)	  			#Y offset of text
	mr 	r3,text		#struct pointer
	bl	PageArrowLeft
	mflr r4
	branchl r12,0x803a6b98

#Change scale
	mr	r4,r3
	mr	r3,text
	lfs	f1,ArrowScale(textproperties)
	lfs	f2,ArrowScale(textproperties)
	branchl r12,Text_UpdateSubtextSize

###############################
## Right Page Arrow Indicator ##
###############################

#Initialize Subtext
	lfs 	f1,RightArrowX(textproperties) 		#X offset of text
	lfs 	f2,ArrowY(textproperties)	  			#Y offset of text
	mr 	r3,text		#struct pointer
	bl	PageArrowRight
	mflr r4
	branchl r12,0x803a6b98

#Change scale
	mr	r4,r3
	mr	r3,text
	lfs	f1,ArrowScale(textproperties)
	lfs	f2,ArrowScale(textproperties)
	branchl r12,Text_UpdateSubtextSize

##################
## R = Tutorial ##
##################

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

#Change scale
	mr	r4,r3
	mr	r3,text
	lfs	f1,RScale(textproperties)
	lfs	f2,RScale(textproperties)
	branchl r12,Text_UpdateSubtextSize

#############
## L = OSD ##
#############

SpawnLText:

#Initialize Subtext
	lfs 	f1,LX(textproperties) #X offset of text
	lfs 	f2,LY(textproperties) #Y offset of text
	mr 	r3,text       #struct pointer
	bl 	LText
	mflr 	r4		#pointer to ASCII
	branchl r12,0x803a6b98

#Change scale
	mr	r4,r3
	mr	r3,text
	lfs	f1,RScale(textproperties)
	lfs	f2,RScale(textproperties)
	branchl r12,Text_UpdateSubtextSize

##################
## R = Tutorial ##
##################

SpawnZText:

#Initialize Subtext
	lfs 	f1,ZX(textproperties) #X offset of text
	lfs 	f2,ZY(textproperties) #Y offset of text
	mr 	r3,text       #struct pointer
	bl 	ZText
	mflr 	r4		#pointer to ASCII
	load r5,VersionString
	branchl r12,0x803a6b98

#Temp remember subtext ID
	mr	r20,r3

#Change scale
	mr	r4,r20
	mr	r3,text
	lfs	f1,ZScale(textproperties)
	lfs	f2,ZScale(textproperties)
	branchl r12,Text_UpdateSubtextSize

#Change Color
	mr	r4,r20				#subtext id
	mr 	r3,text			#text pointer
	load	r5,0x8dff6eff
	stw	r5,0xF0(sp)
	addi r5,sp,0xF0
	branchl r12,Text_ChangeTextColor

b end



#**************************************************#
TEXTPROPERTIES:
blrl
.set VersionX,0x0
.set VersionY,0x4
.set ZOffset,0x8
.set RX,0xC
.set RY,0x10
.set RScale,0x14
.set LX,0x18
.set LY,0x1C
.set ZX,0x20
.set ZY,0x24
.set ZScale,0x28
.set CanvasScaling,0x2C
.set ArrowY,0x30
.set LeftArrowX,0x34
.set RightArrowX,0x38
.set ArrowScale,0x3C

#Version
.float 0      #text X pos
.float -236   #text Y pos
.float 17     #Z offset

#Press R
.float 310    #text X pos
.float -230   #text Y pos
.float 0.8		#scale

#Press L
.float -310   #text X pos
.float -230   #text Y pos

#Press Z
.float 300    #text X pos
.float -280   #text Y pos
.float 0.85		#text scale

.float 0.035   #Canvas Scaling

#Arrows
.float	-215		#Y coordinate
.float	-210		#left X
.float   210    #Right X
.float	 0.7		#Scale

NullString:
blrl
.string "General Tech"
.align 2

PageArrowLeft:
blrl
.string "<"
.align 2

PageArrowRight:
blrl
.string ">"
.align 2

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
.string "TM %s Beta"
.align 2

#**************************************************#
end:

restore

lmw	r26, 0x0038 (sp)
