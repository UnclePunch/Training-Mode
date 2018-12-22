#To be inserted at 80264524
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

.set ActionStateChange,0x800693ac
.set HSD_Randi,0x80380580
.set HSD_Randf,0x80380528
.set Wait,0x8008a348
.set Fall,0x800cc730

.set text,31
.set textProperties,30
.set EventName,29

#r24 = text struct
#r27 = Event ID

#Check For Custom Event
  lwz	r3, -0x77C0 (r13)
  lbz	r3, 0x0535 (r3)         #get event ID
  branchl r12,0x80005524      #get event name
  cmpwi r3,0x0
  beq VanillaEvent

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
	branchl r14,0x803a6754

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
	branchl r14,0x803a6b98

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
  lwz	r3, -0x49C8 (r13)
