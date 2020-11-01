#To be inserted at 8008fe8c
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set entity,31
.set playerdata,29
.set player,30

##########################################################
## 804a1f5c -> 804a1fd4 = Static Stock Icon Text Struct ##
## Is 0x80 long and is zero'd at the start              ##
##  of every VS Match				                        ##
## Store Text Info here                                 ##
##########################################################

stb	r3, 0x221C (r29)

#Initialize Counter at 0x2354
sth	r0, TM_PostHitstunFrameCount(playerdata)

