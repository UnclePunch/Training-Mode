#To be inserted at 801B15E4
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

.set entity,31
.set player,31

addi	r30, r3, 0
backup
mr r28,r5

#START INPUT LOOP CHECK
  load r5,0x8046B108
  li r4,0x0

loop:
lwz r3,0x0(r5) #get inputs

  rlwinm. r0, r3, 0, 6, 6 #check A
  beq- checkZ
  rlwinm. r0, r3, 0, 7, 7 #check B
  beq- checkZ

runback:
  li r4,0x2 #reload match scene
  b exit

checkZ:
  rlwinm. r0, r3, 0, 5, 5 #check X
  beq increment

randomStage:
  branchl r12,0x802599EC #get random stage ID

  #convert SSS ID to internal stage ID
    load r4,0x803f06D0   #load stage ID table
    mulli	r3, r3, 28     #stage ID to offset
    add r4,r4,r3         #add to start of table
    lbz r3,0xB(r4)       #get internal stage ID

  load r4,0x8045AC64     #load VS match struct
#  lhz r5,0x2(r4)			 #get current stage
#  cmpw r3,r5            #check if same stage
#  beq randomStage

  sth r3,0x2(r4)         #store stage half to struct
  li r4,0x2              #reload match scene
  b exit

increment:
  addi r4,r4,1
  addi r5,r5,0xC
  cmpwi r4,0x4
  blt loop

  li r4,0x0  #load CSS

exit:
mr r3,r30
mr r5,r28
restore
