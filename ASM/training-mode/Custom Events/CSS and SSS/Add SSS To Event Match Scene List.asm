#To be inserted at 801a44bc
.include "../../Globals.s"
.include "../../../m-ex/Header.s"
##################################################

#Overwrite Event Scene List
bl	EventSceneList
mflr	r3
load	r4,0x803db010
stw	r3,0x0(r4)

#Overwrite SSS_SceneDecide
bl	SSS_SceneDecide
mflr	r4
stw	r4,0x38(r3)



#Overwrite MainMenu Scene List
bl	MainMenuSceneList
mflr	r3
load	r4,0x803dae44
stw	r3,0x0(r4)

#Overwrite Credits_SceneDecide
bl	Credits_SceneDecide
mflr	r4
stw	r4,0x20(r3)
b	exit

###############################################

#Event Scene List Pointer @ 0x803db010
EventSceneList:
blrl

#CSS
.long 0x00030000
.long 0x801baa60
.long 0x801baad0
.long 0x08000000
.long 0x80497758
.long 0x80497758

#In-Match
.long 0x01030000
.long 0x801bad70
.long 0x801bb758
.long 0x02000000
.long 0x804978a0
.long 0x804979d8

#SSS
.long 0x02030000
.long 0x801b1eb8
.long 0x801b1eec
.long 0x09000000
.long 0x80497758
.long 0x80497758

.long 0xFF000000

################################

SSS_SceneDecide:
blrl
backup

#Get Minor Scenes Data Pointer
lwz	r3, 0x0014 (r3)

#Get Method of Leaving SSS
lbz	r0, 0x0004 (r3)
cmpwi	r0,0x0
beq	SSS_SceneDecide_BackToCSS

SSS_SceneDecide_AdvanceToMatch:
#Match Minor ID
li	r3,0x2
b	SSS_SceneDecide_Exit

SSS_SceneDecide_BackToCSS:
li	r3,0x1

SSS_SceneDecide_Exit:
#Store Next Minor
load	r4,SceneController
stb	r3,0x5(r4)

restore
blr

################################







################################
MainMenuSceneList:
blrl

#MainMenu
.long 0x00020000
.long 0x801b0ff8
.long 0x801b138c
.long 0x01000000
.long 0x804d68b8
.long 0x804d68bc

#Credits
.long 0x01030000
.long 0x00000000
.long 0xFFFFFFFF
.long 0x2B000000
.long 0x00000000
.long 0x00000000

.long 0xFF000000

################################
Credits_SceneDecide:
blrl

#Store Next Minor
load	r4,SceneController
li	r3,0x0
stb	r3,0x5(r4)

blr

#################################

exit:
mr	r3, r30
