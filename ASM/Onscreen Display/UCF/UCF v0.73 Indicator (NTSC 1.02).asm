#To be inserted at 802662d0
.include "../../Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################



stwu	r1,-68(r1)	# make space for 12 registers
stmw	r20,8(r1)	# push r20-r31 onto the stack
mflr r0
stw r0,64(sp)

	#CHECK IF ENABLED
	li	r0,OSD.UCF			#PowerShield ID
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	end


#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r12,0x803a6754

#BACKUP STRUCT POINTER
	mr r31,r3

#INITIALIZE PROPERTIES AND TEXT

	#GET PROPERTIES TABLE
		bl TEXTPROPERTIES
		mflr r30

		mr r3,r31       #struct pointer
		lfs f1,0x0(r30) #X offset of text
		lfs f2,0x4(r30) #Y offset of text
		bl 	TEXT
		mflr 	r4		#pointer to ASCII

		InitializeText:
		branchl r12,0x803a6b98


#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(r31)

#SET TEXT TO CENTER AROUND X LOCATION
	li r4,0x1
	stb r4,0x4A(r31)

#set size/scaling
lfs   f1,0x8(r30) #get text scaling value from table
stfs f1,0x24(r31) #store text scale X
stfs f1,0x28(r31) #store text scale Y

b end


#**************************************************#
TEXTPROPERTIES:
blrl

.long 0x42820000 #x offset (65)
.long 0xC40F4000 #y offset (-570)
.long 0x3D3851EC #text scaling

TEXT:
blrl
.long 0x55434620
.long 0x76302e37
.long 0x33000000




#**************************************************#
end:

lwz r0,64(sp)
mtlr r0
lmw	r20,8(r1)	# pop r20-r31 off the stack
addi	r1,r1,68	# release the space

addi	r4, r24, 0
