#To be inserted at 8016721c
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
addi sp,sp,-0x4
mflr r0
stw r0,0(sp)
.endm

.macro restore
lwz r0,0(sp)
mtlr r0
addi sp,sp,0x4
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

.macro getPlayerBlock reg1,reg2
lwz \reg1,0x2c(\reg2)
.endm

.macro getCharID reg
lbz \reg,0x7(player)
.endm

.macro getCostumeID reg
lbz \reg,0x619(player)
.endm

.macro getAS reg
lwz \reg,0x10(player)
.endm

.macro getASFrame reg
lwz \reg,0x894(player)
.endm

.macro getFacing reg
lwz \reg,0x2c(player)
.endm

.macro setFacing reg
stw \reg,0x2c(player)
.endm

.macro invertFacing reg
lfs \reg,0x2c(player)
fneg \reg,\reg
stfs \reg,0x2c(player)
.endm

.macro fsetGroundVelocityX reg
stfs \reg,0xec(player)
.endm

.macro fsetAirVelocityX reg
stfs \reg,0x80(player)
.endm

.macro fsetAirVelocityY reg
stfs \reg,0x84(player)
.endm

.macro fgetGroundVelocityX reg
lfs \reg,0xec(player)
.endm

.macro fgetAirVelocityX reg
lfs \reg,0x80(player)
.endm

.macro fgetAirVelocityY reg
lfs \reg,0x84(player)
.endm

.macro setGroundVelocityX reg
stw \reg,0xec(player)
.endm

.macro setAirVelocityX reg
stw \reg,0x80(player)
.endm

.macro setAirVelocityY reg
stw \reg,0x84(player)
.endm

.macro getGroundVelocityX reg
lwz \reg,0xec(player)
.endm

.macro getAirVelocityX reg
lwz \reg,0x80(player)
.endm

.macro getAirVelocityY reg
lwz \reg,0x84(player)
.endm

.macro getGroundAirState reg
lwz \reg,0xe0(player)
.endm

.macro getPlayerDatAddress reg
lwz \reg,0x108(player)
.endm

.macro getPlayerBlockFromEntity reg
lwz \reg,0x518(entity)
lwz \reg,0x2c(\reg)
.endm

.macro getStaticBlock reg, reg2
lbz \reg,0xc(player)			#get player slot (0-3)
li \reg2,0xe90			#static player block length
mullw \reg2,\reg,\reg2			#multiply block length by player number
lis \reg,0x8045			#load in static player block base address
ori \reg,\reg,0x3080			#load in static player block base address
add \reg,\reg,\reg2			#add length to base address to get current player's block
#playerblock address in \reg
.endm

.macro checkForAPress reg
lwz \reg,0x65c(player)
rlwinm.	\reg, \reg, 0, 23, 23
.endm

.macro checkForBPress reg
lwz \reg,0x65c(player)
rlwinm.	\reg, \reg, 0, 22, 22
.endm

.macro checkForXPress reg
lwz \reg,0x65c(player)
rlwinm.	\reg, \reg, 0, 21, 21
.endm

.macro checkForYPress reg
lwz \reg,0x65c(player)
rlwinm.	\reg, \reg, 0, 20, 20
.endm

.macro getDpad reg
lbz \reg,0x66b(player)
.endm

.macro getPlayerSlot reg
lbz \reg,0xC(player)
.endm

.macro get reg offset
lwz \reg,\offset(player)
.endm

.set ActionStateChange,0x800693ac
.set HSD_Randi,0x80380580
.set HSD_Randf,0x80380528
.set Wait,0x8008a348
.set Fall,0x800cc730

.set entity,31
.set player,16
.set stageID,r29
.set port,r14

#get table address into r15
mflr r14
bl table
mflr r15
mtlr r14

#get bytefield offset in r17
addi r17,r15,0x34

################################
#playerblock check init
li r16, 0x0				#r16 = player slot currently assessing
lis r14, 0x8045
ori r14, r14, 0x3080              #r18 = player block BA

#create bytefield for active players
playerBlockCheck:
lwz r0, 0x40(r14)
cmpwi r0,0x0                     #an inactive player block will store "0" at offset 0x0
beq empty
b plugged

empty:
li r0,0
b continue

plugged:
li r0,1
b continue

continue:
stbx r0,r16,r17

nextPlayerBlock:
addi r16,r16,0x1
addi r14, r14, 0xe90              #blocks are 0xe90 in length
cmpwi r16,0x4
blt playerBlockCheck
################################

####################################
#returns current player's spawn order in r16
li r16,0			#r16 = spawned order
mr r14,r27			#r14 = copy of player slot number

checkSpawnNumberLoop:
cmpwi r14,0x0			#check if player slot is 0
beq finishedLoop			#if so exit loop
subi r14,r14,0x1			#move back a slot
lbzx r0,r14,r17			#check slot contents
cmpwi r0,0x1			#if 1, a player spawned before
bne checkSpawnNumberLoop
addi r16,r16,1			#increment current player spawn order
b checkSpawnNumberLoop

finishedLoop:
#get stageID in r3
lis	r14, 0x8047
subi	r14, r14, 18784
lhz	r3, 0x24D6 (r14)

mr r14,r16			#put spawn order into r14
####################################
li r17,0

stageCheckLoop:
lwzx r16,r17,r15
cmpwi r16,-1			#check if end of table
beq exit			#branch to end
cmpw r16,r29			#check if stage is on table
addi r17,r17,0x8			#increment table offset
bne stageCheckLoop			#loop back

stageIDMatch:
subi r17,r17,0x4			#go back to matching address
add r17,r17,r15
lbzx r3,r14,r17			#get port's nuetral respawn

b skip

######################
table:
blrl
.long 0x00000020 #FD
.long 0x00010203 #FD neutral ports

.long 0x0000001F #BF
.long 0x02030001 #BF neutral ports

.long 0x00000008 #YS
.long 0x00010302 #YS neutral ports

.long 0x0000001C #DL
.long 0x01030002 #DL neutral ports

.long 0x00000002 #FOD
.long 0x00010203 #FOD neutral ports

.long 0x00000003 #PS
.long 0x00010203 #PS neutral ports

.long 0xFFFFFFFF #terminator

.long 0x00000000 #active players (0x34)
######################

exit:
addi	r3, r27, 0

skip:




