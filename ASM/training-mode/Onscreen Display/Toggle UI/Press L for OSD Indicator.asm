#To be inserted at 80231618
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set text,31
.set textproperties,30
.set originalRegister,29

.set VersionString,0x8040a58c

backup

########################
## Create Text Object ##
########################

#Backup r3
	mr	originalRegister,r3

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
	lfs f1,ZPos(textproperties) #Z offset
	stfs f1,0x8(text)

#Scale Canvas Down
  lfs f1,CanvasScaling(textproperties)
  stfs f1,0x24(text)
  stfs f1,0x28(text)

#######################
## Version Indicator ##
#######################

#Initialize Subtext
	lfs 	f1,XPos(textproperties) 		#X offset of text
	lfs 	f2,YPos(textproperties)	  	#Y offset of text
	mr 	r3,text		#struct pointer
	bl	Text
	mflr r4
	branchl r12,0x803a6b98
#Change scale
	mr	r4,r3
	mr	r3,text
	lfs	f1,TextScale(textproperties)
	lfs	f2,TextScale(textproperties)
	branchl r12,Text_UpdateSubtextSize

b end



#**************************************************#
TEXTPROPERTIES:
blrl
.set XPos,0x0
.set YPos,0x4
.set ZPos,0x8
.set TextScale,0xC
.set CanvasScaling,0x10

#Version
.float -250    #text X pos
.float -241   #text Y pos
.float 17     #Z offset
.float 0.8		#text scale

.float 0.035   #Canvas Scaling

Text:
blrl
.string "L = OSD"
.align 2

#**************************************************#
end:

mr	r3,originalRegister
restore
lmw	r14, 0x00E0 (sp)
