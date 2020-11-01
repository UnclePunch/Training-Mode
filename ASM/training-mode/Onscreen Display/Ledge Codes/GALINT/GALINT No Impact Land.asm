#To be inserted at 80082b4c
.include "../../../Globals.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

.set PrevASStart,0x23F0
.set CurrentAS,0x10
.set OneASAgo,PrevASStart+0x0
.set TwoASAgo,PrevASStart+0x2
.set ThreeASAgo,PrevASStart+0x4
.set FourASAgo,PrevASStart+0x6
.set FiveASAgo,PrevASStart+0x8
.set SixASAgo,PrevASStart+0xA


##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

backupall

lwz	r5,0x2C(r30)

#Check For CliffWait
lhz	r3, TwoASAgo (r5)
cmpwi	r3,0xFD
bne	Moonwalk_Exit

mr	r3,r30
li  r4,0
branchl	r12,0x80005514





Moonwalk_Exit:
restoreall
mr	r3, r30
