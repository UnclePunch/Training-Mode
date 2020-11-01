#To be inserted at 803a684c
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

.set LoopCount,31
.set Dictionary,30
.set CurrentDictOffset,12


#Runs When the ASCII Value is 0x85 or Greater
#Katagana Starts at Dictionary Offset 0xB0

backup

#Search custom symbol table
  bl  CustomSymbolDictionary
  mflr Dictionary
  li LoopCount,0

Loop:
  mulli CurrentDictOffset,LoopCount,0x3
  add CurrentDictOffset,CurrentDictOffset,Dictionary
  lbz r11,0x0(CurrentDictOffset)
  cmpwi r11,0xFF
  beq Exit
  cmpw r10,r11
  beq CharacterFound
IncLoop:
  addi LoopCount,LoopCount,1
  b Loop

CharacterFound:
#If overriding 0xA
  lbz r10,0x0(CurrentDictOffset)    #Check Matched Character
  cmpwi r10,0x0A
  bne CharacterFound_Resume
#Store 0x3 to the menu text string
  li  r10,0x03
  stbx r10,r3,r9
#increment r9 by 1 to get next offset in menu text string
  addi r9,r9,1
#branch to 803a6b70, will increment r5 and r6 by 1 to get next offset in ASCII string and loop
  restore
  branch r12,0x803a6b70
CharacterFound_Resume:
  lbz r10,0x1(CurrentDictOffset)    #Load Override Character
  lbz r12,0x2(CurrentDictOffset)    #Load Override Character
  restore
  mr  r31,r12
  load r0,0x8040c8c0
  branch	r12,0x803a6b08

CustomSymbolDictionary:
blrl
.byte 0x21,0x81,0x49   #Exclamation Point
.byte 0x2f,0x81,0x5E   #Slash
.byte 0x2e,0x81,0x44   #Period
.byte 0x3d,0x81,0x81   #Equals Sign
.byte 0x2b,0x81,0x7B   #Plus Sign
.byte 0x25,0x81,0x93   #Percent Sign
.byte 0x0A,0x03,0x00   #New Line
.byte 0x27,0x81,0x66   #Apostrophe
.byte 0x3e,0x81,0x84   #Greater than
.byte 0x3c,0x81,0x83   #Less than
.byte 0x5F,0x81,0x51   #Underscore
.byte 0x5E,0x81,0x4F   #Carrot
.byte 0x3F,0x81,0x48   #Question mark
.byte 0x7c,0x81,0x62   # | symbol
.byte 0x28,0x81,0x69   #Open Parenthesis
.byte 0x29,0x81,0x6A   #Close Parenthesis
.byte 0xFF
.align 2


Exit:
restore
load r0,0x8040c8c0
cmplwi	r10, 32

/*
#Katagana code
cmpwi	r10,0x85
blt	original

addi	r31,r10,0x2b
branch	r12,0x803a6b38

original:
lbzu	r31, 0x0001 (r6)
*/
