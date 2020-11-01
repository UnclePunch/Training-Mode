#To be inserted at 80076eac
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

#################################
## On Hitbox->Shield Collision ##
#################################

#Store Pointer to Player Whose Shield Was Hit
stw	r31,TM_PlayerWhoShieldedAttack(r29)

InjectionExit:
lfs	f1, 0x19B4 (r31)
