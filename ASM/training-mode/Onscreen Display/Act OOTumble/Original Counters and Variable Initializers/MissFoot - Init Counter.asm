#To be inserted at 8009f3ec
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set playerdata,31
.set player,30
.set text,29
.set textprop,28
.set hitbool,27

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

#Initialize Counter at 0x2354
li	r0,0
sth	r0,TM_PostHitstunFrameCount(playerdata)

lwz	r0, 0x001C (sp)


