#To be inserted at 801bab18
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

#Get Backup Location
  lwz	r9, -0x77C0 (r13)
  addi r9,r9,3344
#Backup HMN Character Choice
  lwz r3,CSS_Data(r13)      #CSS Match Info
  addi r4,r9,104            #Character Backup Location
  li  r5,0                  #Unk Backup Location
  addi r6,r9,107            #Costume Backup Location
  addi r7,r9,114            #Nametag Backup Location
  li  r8,0                  #Unk Backup Location
  branchl r12,0x801b0730

#Also copy to Event's CSS Backup Data for compatibility
#Get Backup Location
  lwz	r9, -0x77C0 (r13)
  addi	r9, r9, 1328
#Backup HMN Character Choice
  lwz r3,CSS_Data(r13)      #CSS Match Info
  addi r4,r9,2            #Character Backup Location
  li  r5,0                  #Unk Backup Location
  addi r6,r9,3            #Costume Backup Location
  addi r7,r9,4            #Nametag Backup Location
  li  r8,0                  #Unk Backup Location
  branchl r12,0x801b0730

#Get Backup Location
  lwz	r9, -0x77C0 (r13)
  addi r9,r9,3344
#Backup CPU Character Choice
  lwz r3,CSS_Data(r13)      #CSS Match Info
  addi r4,r9,140            #Character Backup Location
  li  r5,0                  #Unk Backup Location
  addi r6,r9,143            #Costume Backup Location
  addi r7,r9,150            #Nametag Backup Location
  li  r8,0                  #Unk Backup Location
  branchl r12,0x801b07e8
