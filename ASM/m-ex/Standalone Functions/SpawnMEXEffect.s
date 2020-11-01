#To be inserted @ 803d7060
.include "../../Globals.s"
.include "../Header.s"

.set  REG_EffectID,31
.set  REG_PlayerGObj,30
.set  REG_Arg1,29
.set  REG_Arg2,28
.set  REG_Arg3,27
.set  REG_Arg4,26
.set  REG_Arg5,26

.set  REG_PlayerData,21
.set  REG_MEXEffectLookup,20

backup

#effect id = 5000 + charEffectID
  addi  r3,r3,PersonalEffectStart
  branchl r12,0x8005fddc

Exit:
  restore
  blr
