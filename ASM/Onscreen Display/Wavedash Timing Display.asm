#To be inserted at 80099d7c
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
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw	r3,8(r1)	# push r20-r31 onto the stack
mflr r0
stw r0,0xFC(sp)
.endm

.macro restore
lwz r0,0xFC(sp)
mtlr r0
lmw	r3,8(r1)	# pop r20-r31 off the stack
addi	r1,r1,0x100	# release the space
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

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set TextCreateFunction,0x80005928


##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backup

	mr	player,r3
	lwz	playerdata,0x2c(player)

	#CHECK IF ENABLED
	li	r0,0			#wavedash ID
	#lwz	r4,-0xdbc(rtoc)			#get frame data toggle bits
	lwz	r4,-0x77C0(r13)
	lwz	r4,0x1F24(r4)
	li	r3, 1
	slw	r0, r3, r0
	and.	r0, r0, r4
	beq	Moonwalk_Exit

	CheckForFollower:
	mr	r3,playerdata
	branchl	r12,0x80005510
	cmpwi	r3,0x1
	beq	Moonwalk_Exit

	#CHECK IF IT WAS A WAVEDASH (compare with 20)
	lfs	f1,0x894(playerdata)
	lfs	f2,-0x7fac(rtoc)			#get fp 20
	fcmpo	cr0,f1,f2
	bgt	Moonwalk_Exit

	mr	r3,playerdata			#backup playerdata pointer
	li	r4,60			#display for 60 frames
	li	r5,0			#Area to Display (0-2)
	li	r6,0			#Window ID (Unique to This Display)
	branchl	r12,TextCreateFunction			#create text custom function
	
	mr	text,r3			#backup text pointer


	#CHECK FOR PERFECT
	lbz	r3,0x680(playerdata)
	cmpwi	r3,0x0
	bne 	NotFramePerfect
	#SET TEXT COLOR TO GREEN
	load	r3,0x8dff6eff
	stw	r3, 0x0030 (text)	
	NotFramePerfect:


	#INITALIZE TEXT 1
	mr 	r3,r29			#text pointer
	bl	TextASCII
	mflr 	r4			#get ASCII to print
	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B4 (rtoc)			#default text X/Y
	branchl r12,0x803a6b98


	#INITALIZE TEXT 2
	mr 	r3,r29			#text pointer
	bl	TextASCII2
	mflr 	r4			#get ASCII to print

	lfs	f1,0x894(playerdata)
	fctiwz	f1,f1
	stfd	f1,0xF0(sp)
	lwz	r5,0xF4(sp)

	lfs	f1, -0x37B4 (rtoc)			#default text X/Y
	lfs	f2, -0x37B0 (rtoc)			#shift down on Y axis
	branchl r12,0x803a6b98
	


b Moonwalk_Exit

TextASCII:
blrl
.long 0x57617665
.long 0x64617368
.long 0x00000000



TextASCII2:
blrl
.long 0x4672616d
.long 0x653a2025
.long 0x64000000

##############################

Moonwalk_Exit:
restore

lwz	r4, -0x514C (r13)




