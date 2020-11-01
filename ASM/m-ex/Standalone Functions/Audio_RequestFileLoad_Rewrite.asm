#To be inserted @ 803d705c
.include "../../Globals.s"
.include "../Header.s"

.set  REG_SSMID,3
.set  REG_ToLoadOrig,12

#Check if null ssm ID
  cmpwi  REG_SSMID,55
  beq Exit

#Get Disposable Orig
  lwz REG_ToLoadOrig,OFST_SSMStruct(rtoc)
  lwz REG_ToLoadOrig,Arch_SSMRuntimeStruct_ToLoadOrig(REG_ToLoadOrig)
#Queue up ssm load
  li  r4,1
  mulli REG_SSMID,REG_SSMID,4
  stwx  r4,REG_SSMID,REG_ToLoadOrig

Exit:
  blr
