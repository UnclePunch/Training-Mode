#To be inserted at 8022e630
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

#Check If First Boot
CheckIfFirstBoot:
  lbz	r5,FirstBootFlag(rtoc)
  cmpwi	r5,0x0
  beq	RestoreBackup
#On First Boot
#Backup Instead of Restoring
  lwz	r6,-0x77C0(r13)
  lwz	r5,0x1F24(r6)
  stw	r5,-0xDA8(rtoc)
#Remove Boot Flag
  li	r5,0x0
  stb	r5,FirstBootFlag(rtoc)

b	Exit

RestoreBackup:
  lwz	r5,-0xDA8(rtoc)
  lwz	r6,-0x77C0(r13)
  stw	r5,0x1F24(r6)

Exit:
#Original Line
  li	r3, 3
