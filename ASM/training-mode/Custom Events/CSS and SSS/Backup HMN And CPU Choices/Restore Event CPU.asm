#To be inserted at 801baa98
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

#Get Backup Location
  lwz	r9, -0x77C0 (r13)
  addi r9,r9,3344
#Restore HMN Character Choice
  load r3,0x80497758        #CSS Match Info
  #mr  r4,r4                 #CSS Type
  lbz r5,104(r9)            #Character Backup
  li  r6,0                  #Unk
  lbz r7,107(r9)           #Costume Backup
  lbz r8,114(r9)           #Nametag Backup Location
  li  r9,0                  #Unk Backup Location
  lbz	r10, 0x0006 (r31)     #Player who accessed CSS
  branchl r12,0x801b06b0

#Get Backup Location
  lwz	r9, -0x77C0 (r13)
  addi r9,r9,3344
#Backup CPU Character Choice
  load r3,0x80497758        #CSS Match Info
  lbz r4,140(r9)           #Character Backup
  li  r5,1                 #Unk
  lbz r6,143(r9)           #Costume Backup
  lbz r7,150(r9)           #Nametag Backup
  li  r8,0
  lbz	r9, 0x0006 (r31)     #Player who accessed CSS
  branchl r12,0x801b07b4
