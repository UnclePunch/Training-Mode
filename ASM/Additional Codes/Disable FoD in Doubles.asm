#To be inserted at 80266ce0
.include "../Globals.s"

#######################################
## Runs During CSS -> SSS Transition ##
#######################################

.set REG_RandomStageField,5
.set REG_RulesPointer,6

#Ensure only all other legal stages are enabled
#Get Random Stage Select Bitflags
  lwz	REG_RulesPointer, -0x77C0 (r13)
  addi	REG_RulesPointer, REG_RulesPointer, 7344
  lwz	REG_RandomStageField,0x18(REG_RulesPointer)
#Check if only all legal stages are on
  load r3,0xE70000B0
  xor. r3,r3,REG_RandomStageField
  beq CheckForTeams
#Check if the only other stage off is FoD
  cmpwi r3,0x20
  beq CheckForTeams
  b Exit

CheckForTeams:
#Get Teams On/Off Bool
  lwz	r3, -0x49F0 (r13)
  lbz	r3,0x18(r3)
#Check If Teams is On or Off
  cmpwi	r3,0x1
  beq	Doubles

Singles:
#Flip FoD Bit On in Random Stage Bitflag (FoD is bit #26)
  li	r3,0x1
  rlwimi	REG_RandomStageField,r3,5,26,26
  stw	REG_RandomStageField,0x18(REG_RulesPointer)
  b	Exit

Doubles:
#Flip FoD Bit Off in Random Stage Bitflag (FoD is bit #26)
  li	r3,0x0
  rlwimi	REG_RandomStageField,r3,5,26,26
  stw	REG_RandomStageField,0x18(REG_RulesPointer)
  b	Exit

Exit:
li	r3, 1
