#To be inserted at 80264504
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

.set text,31
.set textProperties,30
.set EventName,29

#r24 = text struct
#r27 = Event ID

#Ensure this is event mode
  load r3,SceneController
  lbz r3,Scene.CurrentMajor(r3)
  cmpwi r3,Scene.EventMode
  bne Original

#Check For Custom Event
  lwz r3,MemcardData(r13)
  lbz r3,CurrentEventPage(r3)
  lwz	r4, -0x77C0 (r13)
  lbz	r4, 0x0535 (r4)         #get event ID
  rtocbl r12,TM_GetEventName

#Save Text
  mr  EventName,r3

#GET PROPERTIES TABLE
	bl TEXTPROPERTIES
	mflr textProperties

########################
## Create Text Object ##
########################

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r12,0x803a6754

#BACKUP STRUCT POINTER
	mr text,r3

#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(text)

#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(text)

#Scale Canvas Down
	lfs f1,0xC(textProperties)
	stfs f1,0x24(text)
	stfs f1,0x28(text)

####################################
## INITIALIZE PROPERTIES AND TEXT ##
####################################

#Initialize Line of Text
	mr r3,text       #struct pointer
	mr 	r4,EventName		#pointer to ASCII
	lfs f1,0x0(textProperties) #X offset of text
	lfs f2,0x4(textProperties) #Y offset of text
	branchl r12,0x803a6b98

#Set Size/Scaling
  mr  r4,r3
  mr	r3,text
	lfs   f1,0x8(textProperties) #get text scaling value from table
	lfs   f2,0x8(textProperties) #get text scaling value from table
  branchl	r12,0x803a7548

b Original


#**************************************************#
TEXTPROPERTIES:
blrl

.float 38      #x offset
.float -245    #y offset
.float 0.65    #text scaling
.float 0.1     #canvas scaling

#**************************************************#

VanillaEvent:
Original:
  li	r3, 4
