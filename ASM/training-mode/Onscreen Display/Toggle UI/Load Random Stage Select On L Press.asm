#To be inserted at 8022f578
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

rlwinm.	r0, r3, 0, 25, 25			#CHECK FOR L
beq	exit

#PLAY SFX
li	r3, 1
branchl	r4,0x80024030

#SET FLAG IN RULES STRUCT
li	r0,2		#2 = frame data toggle
load	r3,0x804a04f0
stb	r0, 0x0011 (r3)

#SET SOMETHING
li	r0, 5
sth	r0, -0x4AD8 (r13)

#LOAD RSS
branchl	r3,0x80237410

#REMOVE CURRENT THINK FUNCTION
mr	r3,r29
branchl	r4,0x80390228

branch	r3,0x8022fb68
#branch	r3,0x8022f5f4

exit:
rlwinm.	r0, r3, 0, 22, 22
