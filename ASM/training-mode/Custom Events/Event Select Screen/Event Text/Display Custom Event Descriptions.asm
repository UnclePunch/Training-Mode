#To be inserted at 8024d80c
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set HeaderLength,0xB

.set EventID,30

#Get Event ID
  lbz	r3,0x0(r31)
  lwz	r4,0x4(r31)
  add	r4,r3,r4
#Get page number
  lwz r3,MemcardData(r13)
  lbz r3,CurrentEventPage(r3)
#Get Event Description ASCII
  rtocbl r12,TM_GetEventDesc

CustomEvent:
.set text,24
.set ascii,23

mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x200(r1)	# make space for 12 registers
stmw  r20,0x8(r1)

#Backup ASCII
  mr  ascii,r3

#Create Text
  li  r3,0
  li  r4,0
  branchl r12,0x803a6754
  mr  text,r3
#Store pointer to text so it can be removed by the game
  stw text,0x78(r31)
#Set Text Values
  lfs	f1, -0x384C (rtoc)
  lfs	f2, -0x3848 (rtoc)
  lfs	f3, -0x3874 (rtoc)
  lfs	f4, -0x386C (rtoc)
  lfs	f5, -0x3868 (rtoc)
  stfs f1,0x00(text)
  stfs f2,0x04(text)
  stfs f3,0x08(text)
  stfs f4,0x0C(text)
  stfs f5,0x10(text)
  lfs	  f0, -0x3844 (rtoc)
  stfs	f0, 0x0024 (text)
  stfs	f0, 0x0028 (text)

#Convert To Menu Text
  mr  r4,ascii               #ASCII To Store
  addi r3,sp,0x40
  branchl r12,0x803a67ec
#Backup Length
  mr r20,r3

#Get Allocation Info Pointer
  lwz r21,0x64(text)
#Check To Adjust Allocation
  lwz	r22, 0x0004 (r21)     #Get old menu text allocation
  lwz	r0, 0 (r21)
  lwz	r4, 0x0008 (r21)      #Get size of allocation
  sub	r3, r0, r22
  addi	r0, r3, 17
  add	r0, r20, r0
  cmplw	r4, r0
  bge-	 NoAdjustAllocation
  sub	r0, r0, r4
  rlwinm	r3, r0, 25, 7, 31
  addi	r0, r3, 1
  rlwinm	r0, r0, 7, 0, 24
  add	r0, r4, r0
  stw	r0, 0x0008 (r21)
  lwz	r3, 0x0008 (r21)
  branchl r12,0x803A5798
  addi	r5, r22, 0
  addi	r4, r3, 0
  li	r7, 0
  b		ReAllocateLoop_Inc
ReAllocateLoop:
  lbz	r0, 0 (r5)
  addi	r7, r7, 1
  addi	r5, r5, 1
  stb	r0, 0 (r4)
  addi	r4, r4, 1
ReAllocateLoop_Inc:
  lwz	r6, 0x0004 (r21)
  lwz	r0, 0 (r21)
  sub	r6, r0, r6
  addi	r0, r6, 1
  cmpw	r7, r0
  blt+	ReAllocateLoop
  stw	r3, 0x0004 (r21)
  stw	r3, 0x005C (text)
  lwz	r0, 0 (r21)
  sub	r0, r0, r22
  add	r0, r3, r0
  stw	r0, 0 (r21)
  mr	r3, r22
  branchl r12,0x803A594C
NoAdjustAllocation:

#Copy Header to Text Allocation
  lwz r3,0x5C(text)       #Get Pointer to Next Available Menu Text Location
  bl  DescriptionHeader
  mflr  r4
  li  r5,HeaderLength
  branchl r12,0x800031f4

#Copy Text to Text Allocation
  mr  r5,r20               #Length
  lwz r3,0x5C(text)       #Get Pointer to Next Available Menu Text Location
  addi r3,r3,HeaderLength         #Skip Past Header
  addi r4,sp,0x40
  branchl r12,0x800031f4

#Add Terminator
  li  r3,0x1900
  lwz r4,0x5C(text)
  addi r4,r4,HeaderLength   #Skip Header Length
  add r4,r4,r20             #Skip Text Length
  sth r3,0x0(r4)

Exit:
  lmw  r20,0x8(r1)
  lwz r0, 0x204(r1)
  addi	r1,r1,0x200	# release the space
  mtlr r0
  branch	r12,0x8024d84c

DescriptionHeader:
blrl
.long 0x160caaaa
.long 0xaa0e00b3
.long 0x00b31800

VanillaEvent:
  rlwinm	r3, r30, 1, 0, 30
