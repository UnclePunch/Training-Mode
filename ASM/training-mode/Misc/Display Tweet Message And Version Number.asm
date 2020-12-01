#To be inserted at 80394a6c
.include "../Globals.s"

.set VersionString,0x8040a58c

# Remove all previous OSReports
  #load r3,0x804cf7e8
  #li  r4,0
  #stw r4,0xC(r3)

# Play SFX?
  li r3, 317 #188 = warning #317 = gasp
  branchl r12,0x801c53ec

#############################
## OS Report Tweet Message ##
#############################

load	r20,0x803456a8			#OSReport

#OSReport Blank Line
  bl	NewLine
  mflr	r3
  mtctr	r20
  bctrl

#OSReport # Line
  bl	PoundLine
  mflr	r3
  mtctr	r20
  bctrl

#OSReport Error Message
  bl	ResetCombo    #StackDumpMessage1
  mflr	r3
  mtctr	r20
  bctrl

#OSReport # Line
  bl	PoundLine
  mflr	r3
  mtctr	r20
  bctrl

#OSReport Blank Line
  bl	NewLine
  mflr	r3
  mtctr	r20
  bctrl

#OSReport Mod Version
	rtocbl r12,TM_GetTMVersLong
	mr	r4,r3
  bl	Version
  mflr	r3
  mtctr	r20
  bctrl

#OSReport Compile Date
  rtocbl r12,TM_GetTMCompile
  mtctr	r20
  bctrl

#OSReport Blank Line
  bl	NewLine
  mflr	r3
  mtctr	r20
  bctrl

b	Exit

#########################################################

PoundLine:
blrl
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x23232323
.long 0x230A0000

NewLine:
blrl
.long 0x0A000000

Version:
blrl
.string "%s\n"
.align 2

ResetCombo:
blrl
.string "## TWEET A PICTURE OF THIS MESSAGE TO @UnclePunch_ ##\n##   After submitting, PRESS LRA-START to reboot   ##\n"
.align 2

#########################################################

Exit:
addi	r3, r30, 2252
