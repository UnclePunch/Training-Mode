#To be inserted at 801ba410
.include "../../../Globals.s"

.set  REG_MatchData,31
.set  REG_IronManData,30
.set  IronManData,0x8040a5e0

backup

#Get Match Data
  lwz REG_MatchData,-0x20(r3)
  load  REG_IronManData,IronManData

#Check if LRAStarted
  lwz r3,0x14(r3)
  lbz r3,0x10(r3)
  cmpwi r3,7
  beq ReturnToCSS

#Set the first character as the current character
  addi  r5,REG_IronManData,0x0
  lbz r6,0x0(r5)               #Get the next iron man character
  extsb r0,r6
  cmpwi r0,-1
  beq ReturnToCSS
#Now do p2
  addi  r5,REG_IronManData,0x1C
  lbz r6,0x0(r5)               #Get the next iron man character
  extsb r0,r6
  cmpwi r0,-1
  beq ReturnToCSS

#Load match scene again
  li  r3,2
  branchl r12,0x801a42a0
  b InjectionExit

ReturnToCSS:
  li  r3,0
  branchl r12,0x801a42a0
  b InjectionExit

InjectionExit:
  restore
