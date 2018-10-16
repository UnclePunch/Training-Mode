#To be inserted at 801a44bc
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
stmw	r20,8(r1)	# push r20-r31 onto the stack
mflr r0
stw r0,0xFC(sp)
.endm

.macro restore
lwz r0,0xFC(sp)
mtlr r0
lmw	r20,8(r1)	# pop r20-r31 off the stack
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
.set player,31
.set playerdata,31

##################################################

#Overwrite Event Scene List
bl	EventSceneList
mflr	r3
load	r4,0x803db010
stw	r3,0x0(r4)

#Overwrite SSS_SceneDecide
bl	SSS_SceneDecide
mflr	r4
stw	r4,0x38(r3)



#Overwrite MainMenu Scene List
bl	MainMenuSceneList
mflr	r3
load	r4,0x803dae44
stw	r3,0x0(r4)

#Overwrite Credits_SceneDecide
bl	Credits_SceneDecide
mflr	r4
stw	r4,0x20(r3)
b	exit

###############################################

#Event Scene List Pointer @ 0x803db010
EventSceneList:
blrl

#CSS
.long 0x00030000
.long 0x801baa60
.long 0x801baad0
.long 0x08000000
.long 0x80497758
.long 0x80497758

#In-Match
.long 0x01030000
.long 0x801bad70
.long 0x801bb758
.long 0x02000000
.long 0x804978a0
.long 0x804979d8

#SSS
.long 0x02030000
.long 0x801b1eb8
.long 0x801b1eec
.long 0x09000000
.long 0x80497758
.long 0x80497758

.long 0xFF000000

################################

SSS_SceneDecide:
blrl
backup

#Get Minor Scenes Data Pointer
lwz	r3, 0x0014 (r3)

#Get Method of Leaving SSS
lbz	r0, 0x0004 (r3)
cmpwi	r0,0x0
beq	SSS_SceneDecide_BackToCSS

SSS_SceneDecide_AdvanceToMatch:
#Match Minor ID
li	r3,0x2
b	SSS_SceneDecide_Exit

SSS_SceneDecide_BackToCSS:
li	r3,0x1

SSS_SceneDecide_Exit:
#Store Next Minor
load	r4,0x80479d30
stb	r3,0x5(r4)

restore
blr

################################







################################
MainMenuSceneList:
blrl

#MainMenu
.long 0x00020000
.long 0x801b0ff8
.long 0x801b138c
.long 0x01000000
.long 0x804d68b8
.long 0x804d68bc

#Credits
.long 0x01030000
.long 0x00000000
.long 0xFFFFFFFF
.long 0x2B000000
.long 0x00000000
.long 0x00000000

.long 0xFF000000

################################
Credits_SceneDecide:
blrl

#Store Next Minor
load	r4,0x80479d30
li	r3,0x0
stb	r3,0x5(r4)

blr

#################################

exit:
mr	r3, r30






