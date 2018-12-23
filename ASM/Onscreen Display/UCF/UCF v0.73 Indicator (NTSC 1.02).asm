#To be inserted at 802662d0
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
.set TextCreateFunction,0x80005928

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
	li	r0,0x1B			#PowerShield ID
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
