#To be inserted at 8003820c
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

#Backup Previous Move Instance ID
  lhz r3,0x18EC(r25)
  sth r3,0x2418(r25)

#Original Line
  rlwinm.	r3, r27, 0, 16, 31
