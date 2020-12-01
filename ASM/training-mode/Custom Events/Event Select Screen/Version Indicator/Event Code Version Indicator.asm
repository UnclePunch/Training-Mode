#To be inserted at 8024e568
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set text,31
.set textproperties,30

.set VersionString,0x8040a58c

.set MainTextOffset,-0x4EB4
.set LeftArrowTextOffset,-0x4EB0
.set RightArrowTextOffset,-0x4EAC
.set TutTextOffset,-0x4EA8
.set MenuBackgroundPointer,-0x4EA4
.set MenuTextPointer,-0x4EA0

backup

#GET PROPERTIES TABLE
	bl TEXTPROPERTIES
	mflr textproperties

#Init background pointer
	li	r3,0
	stw r3,MenuBackgroundPointer(r13)

########################
## Create Text Object ##
########################

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r12,0x803a6754
#BACKUP STRUCT POINTER
	mr text,r3
#STORE POINTER
	stw	text,MainTextOffset(r13)
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(text)
#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(text)
#Store Base Z Offset
	lfs f1,ZOffset(textproperties) #Z offset
	stfs f1,0x8(text)
#Scale Canvas Down
  lfs f1,CanvasScaling(textproperties)
  stfs f1,0x24(text)
  stfs f1,0x28(text)

###############
## Page Name ##
###############

#Get Current Page
	lwz r3,MemcardData(r13)
	lbz r3,CurrentEventPage(r3)
	rtocbl r12,TM_GetPageName
#Initialize Subtext
	mr	r4,r3
	lfs 	f1,PageX(textproperties) 		#X offset of text
	lfs 	f2,PageY(textproperties)	  	#Y offset of text
	mr 	r3,text		#struct pointer
	branchl r12,0x803a6b98

#############
## L = OSD ##
#############

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
## Version Text ##
##################

#Get version string
	rtocbl r12,TM_GetTMVersLong
	mr	r4,r3
#Initialize Subtext
	lfs 	f1,VersionX(textproperties) #X offset of text
	lfs 	f2,VersionY(textproperties) #Y offset of text
	mr 	r3,text       #struct pointer
	branchl r12,0x803a6b98
#Temp remember subtext ID
	mr	r20,r3
#Change scale
	mr	r4,r20
	mr	r3,text
	lfs	f1,VersionScale(textproperties)
	lfs	f2,VersionScale(textproperties)
	branchl r12,Text_UpdateSubtextSize

#Change Color
	mr	r4,r20			#subtext id
	mr 	r3,text			#text pointer
	load	r5,0x8dff6eff
	stw	r5,0xF0(sp)
	addi r5,sp,0xF0
	branchl r12,Text_ChangeTextColor

/*
#################
## Z = Options ##
#################

#Initialize Subtext
	lfs 	f1,OptionsX(textproperties) #X offset of text
	lfs 	f2,OptionsY(textproperties) #Y offset of text
	mr 	r3,text       #struct pointer
	bl 	OptionsText
	mflr 	r4		#pointer to ASCII
	branchl r12,0x803a6b98
#Change scale
	mr	r4,r3
	mr	r3,text
	lfs	f1,OptionsScale(textproperties)
	lfs	f2,OptionsScale(textproperties)
	branchl r12,Text_UpdateSubtextSize
*/

###############################
## Left Page Arrow Indicator ##
###############################

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r12,0x803a6754
#BACKUP STRUCT POINTER
	mr text,r3
#STORE POINTER
	stw	text,LeftArrowTextOffset(r13)
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(text)
#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(text)
#Store Base Z Offset
	lfs f1,ZOffset(textproperties) #Z offset
	stfs f1,0x8(text)
#Scale Canvas Down
  lfs f1,CanvasScaling(textproperties)
  stfs f1,0x24(text)
  stfs f1,0x28(text)

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

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r12,0x803a6754
#BACKUP STRUCT POINTER
	mr text,r3
#STORE POINTER
	stw	text,RightArrowTextOffset(r13)
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(text)
#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(text)
#Store Base Z Offset
	lfs f1,ZOffset(textproperties) #Z offset
	stfs f1,0x8(text)
#Scale Canvas Down
  lfs f1,CanvasScaling(textproperties)
  stfs f1,0x24(text)
  stfs f1,0x28(text)

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
	bne	IsMemcard

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r12,0x803a6754
#BACKUP STRUCT POINTER
	mr text,r3
#STORE POINTER
	stw	text,TutTextOffset(r13)
#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(text)
#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(text)
#Store Base Z Offset
	lfs f1,ZOffset(textproperties) #Z offset
	stfs f1,0x8(text)
#Scale Canvas Down
  lfs f1,CanvasScaling(textproperties)
  stfs f1,0x24(text)
  stfs f1,0x28(text)

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

	b	TutorialSkip

IsMemcard:
	li	r3,0
	stw	r3,TutTextOffset(r13)

TutorialSkip:


b end



#**************************************************#
TEXTPROPERTIES:
blrl
.set PageX,0x0
.set PageY,0x4
.set ZOffset,0x8
.set RX,0xC
.set RY,0x10
.set RScale,0x14
.set LX,0x18
.set LY,0x1C
.set VersionX,0x20
.set VersionY,0x24
.set VersionScale,0x28
.set CanvasScaling,0x2C
.set ArrowY,0x30
.set LeftArrowX,0x34
.set RightArrowX,0x38
.set ArrowScale,0x3C
.set OptionsX,0x40
.set OptionsY,0x44
.set OptionsScale,0x48

#Page
.float 0      #text X pos
.float -240   #text Y pos
.float 17     #Z offset

#Press R
.float 310    #text X pos
.float -230   #text Y pos
.float 0.8		#scale

#Press L
.float -310   #text X pos
.float -230   #text Y pos

#Version
.float 0    #text X pos
.float -212   #text Y pos
.float 0.6		#text scale

.float 0.035   #Canvas Scaling

#Arrows
.float	-215		#Y coordinate
.float	-210		#left X
.float   210    #Right X
.float	 0.7		#Scale

#Options
.float 299    #text X pos
.float -282   #text Y pos
.float 0.8		#text scale

NullString:
blrl
.string "Null"
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

VersionText:
blrl
.string "Training Mode %s"
.align 2

OptionsText:
blrl
.string "Z = Options"
.align 2

#**************************************************#
end:

restore
lwz	r3, 0 (r30)
