#To be inserted at 80263064
.include "../Globals.s"

.set  REG_ReadyPlayers,31

backup

#Backup players
  mr  REG_ReadyPlayers,r4
#Check if mode is set to time
  branchl r12,LoadRulesSettingsPointer1
  lbz r4,0x2(r3)
  cmpwi r4,0
  bne Check2Players
#Check if time is set to none
  lbz r4,0x3(r3)
  cmpwi r4,0
  bne Check2Players
Check1Player:
#Check for 1 players
  cmpwi REG_ReadyPlayers,1
  b Exit
Check2Players:
#Check for 2 players
  cmpwi REG_ReadyPlayers,2

Exit:
  restore
