#To be inserted at 801bab18
.include "../../Globals.s"

#Get Backup Location
  lwz	r9, -0x77C0 (r13)
  addi r9,r9,3344
#Backup HMN Character Choice
  load r3,0x80497758        #CSS Match Info
  addi r4,r9,104            #Character Backup Location
  li  r5,0                  #Unk Backup Location
  addi r6,r9,107            #Costume Backup Location
  addi r7,r9,114            #Nametag Backup Location
  li  r8,0                  #Unk Backup Location
  branchl r12,0x801b0730

#Get Backup Location
  lwz	r9, -0x77C0 (r13)
  addi r9,r9,3344
#Backup CPU Character Choice
  load r3,0x80497758        #CSS Match Info
  addi r4,r9,140            #Character Backup Location
  li  r5,0                  #Unk Backup Location
  addi r6,r9,143            #Costume Backup Location
  addi r7,r9,150            #Nametag Backup Location
  li  r8,0                  #Unk Backup Location
  branchl r12,0x801b07e8
