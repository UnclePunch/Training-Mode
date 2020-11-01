#To be inserted at 802ff4e8
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

.set MessageStructTotalSize,0x300
.set MessageAreaLength,0x100
.set PerPlayerMessageStructLength,0x28

########################################################
## Allocate 0x300 Bytes and Store Pointer at 804a1f5c ##
########################################################

 li	r3,MessageStructTotalSize
 branchl	r12,0x8037f1e4
 stw	r3,0x4(r31)

#Zero Space
li	r4,MessageStructTotalSize
branchl	r12,0x8000c160

##############################################
## Create Message Management Think Function ##
##############################################

#Create GObj
 li	r3,0xE
 li	r4,0x7
 li	r5,0x0
 branchl r12,0x803901f0

#Attach Think Function
 bl 	MessageThink
 mflr 	r4			#Get Function Address
 li 	r5,0x0
 branchl r12,0x8038fd54

b	exit

#################################################################

################
## MessageThink ##
################

MessageThink:
blrl

backup

###############################################
## Update Message Area 1 (Above Player HUDs) ##
###############################################

#Init Loop
 li	r31,0x0 		#Loop Count

MessageThink_UpdateArea1Loop:

 li	r3,0x0				#Area 1
 mr	r4,r31				#Player
 bl	MessageThink_Updater

MessageThink_UpdateArea1IncLoop:
 addi	r31,r31,0x1
 cmpwi	r31,0x4
 blt	MessageThink_UpdateArea1Loop

###########################################
## Update Message Area 2 (Top of Screen) ##
###########################################

#Init Loop
 li	r31,0x0 		#Loop Count

MessageThink_UpdateArea2Loop:

 li	r3,1				#Area 2
 mr	r4,r31				#Player
 bl	MessageThink_Updater

MessageThink_UpdateArea2IncLoop:
 addi	r31,r31,0x1
 cmpwi	r31,0x4
 blt	MessageThink_UpdateArea2Loop

#################################################
## Update Message Area 3 (Right Side of Screen ##
#################################################

 li	r3,2				#Area 3
 bl	MessageThink_Updater

MessageThink_Exit:
restore
blr

##################################################################

##########################
## MessageThink_Updater ##
##########################

MessageThink_Updater:

 backup

 mr	r31,r3		#Area ID
 mr	r30,r4		#Player ID

#Get Area's Message Struct in r29
 load	r3,0x804a1f58
 lwz	r3,0x4(r3)
 mulli	r4,r31,MessageAreaLength
 add	r29,r3,r4

#Check For Area 3, No Player Dependent Stuff If So
 cmpwi	r31,0x2
 bge	MessageThink_Updater_NonPlayerArea

######################################################################################

MessageThink_Updater_PlayerAreaLoopInit:
 mulli	r4,r30,PerPlayerMessageStructLength
 add	r29,r29,r4
 li	r28,0x0			#Offset In Player's Area

MessageThink_Updater_PlayerAreaLoop:
 add	r27,r28,r29
 lwz	r3,0x0(r27)				#Get Text Pointer
 cmpwi	r3,0				#If There's No Text Here, Skip
 beq	MessageThink_Updater_PlayerAreaIncLoop

#Check If No Timer (-1)
 lhz	r3,0x4(r27)				#Get Timer
 cmpwi	r3,-1
 beq	MessageThink_Updater_PlayerAreaIncLoop

#Decrement Timer
 #lhz	r3,0x4(r27)				#Get Timer
 subi	r3,r3,0x1
 sth	r3,0x4(r27)

#Check If Expired
 cmpwi	r3,0x0
 bgt	MessageThink_Updater_PlayerAreaIncLoop

#Remove Text
 lwz	r3,0x0(r27)				#Get Text Pointer
 branchl	r12,0x803a5cc4

#Zero Out Entry
 li	r3,0x0
 stw	r3,0x0(r27)
 stw	r3,0x4(r27)

#Check To Shift Upwards
 addi	r26,r28,0x8								#Next Offset
 cmpwi	r26,PerPlayerMessageStructLength								#Check If There's Nothing Left to Shift
 bge	MessageThink_Updater_PlayerAreaIncLoop								#Skip Shift Code

#Shift Everything Below it Upwards
MessageThink_Updater_PlayerAreaShiftMessagesLoop:
 add	r5,r26,r29				#Get Next Individual Message Struct
 lwz	r3,0x0(r5)				#Get Messages Text Pointer
 lwz	r4,0x4(r5)				#Get Messages Timer and ID
 stw	r3,-0x8(r5)				#Push Up
 stw	r4,-0x4(r5)				#Push Up

#Check If This Entry Is Live
 cmpwi	r3,0x0
 beq	MessageThink_Updater_PlayerAreaShiftMessagesIncLoop

#Move Message Downwards/Upwards Depending On The Area
 bl	MessageThink_Floats
 mflr	r4
 mulli	r5,r31,0x4				#Area ID into offset
 lfsx	f1,r4,r5
 lfs	f2,0x4(r3)				#Get Text's Y Value
 fadds	f1,f1,f2
 stfs	f1,0x4(r3)				#Store Text's Y Value

#Go To Next Message's Offset
MessageThink_Updater_PlayerAreaShiftMessagesIncLoop:
 addi	r26,r26,0x8											#Next Offset
 cmpwi	r26,PerPlayerMessageStructLength					#Check If There's Nothing Left to Shift
 blt	MessageThink_Updater_PlayerAreaShiftMessagesLoop	#Run Code if There Is


MessageThink_Updater_PlayerAreaIncLoop:
 addi	r28,r28,0x8			#Length of Each Message Data
 cmpwi	r28,PerPlayerMessageStructLength
 blt	MessageThink_Updater_PlayerAreaLoop

 b	MessageThink_Updater_Exit

######################################################################################

MessageThink_Updater_NonPlayerArea:
 lwz	r3,0x0(r29)				#Get Text Pointer
 cmpwi	r3,0				#If There's No Text Here, Skip
 beq	MessageThink_Updater_Exit

#Check If No Timer (-1)
 lhz	r3,0x4(r29)				#Get Timer
 cmpwi	r3,-1
 beq	MessageThink_Updater_Exit

#Decrement Timer
 #lhz	r3,0x4(r29)				#Get Timer
 subi	r3,r3,0x1
 sth	r3,0x4(r29)

#Check If Expired
 cmpwi	r3,0x0
 bgt	MessageThink_Updater_Exit

#Remove Text
 lwz	r3,0x0(r29)				#Get Text Pointer
 branchl	r12,0x803a5cc4

#Zero Out Entry
 li	r3,0x0
 stw	r3,0x0(r29)
 stw	r3,0x4(r29)

 b	MessageThink_Updater_Exit


######################################################################################

#******************#
MessageThink_Floats:
blrl
.long 0x40900000			#Area 1
.long 0xC0900000			#Area 2
#******************#

MessageThink_Updater_Exit:
restore
blr

#################################################################


exit:
lwz	r0, 0x001C (sp)
