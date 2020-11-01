#To be inserted @ 803d707C
.include "../../Globals.s"
.include "../Header.s"

.set REG_StageExtID,11
.set REG_Playlist,10

  backup

#Check if this stage has a playlist
  load r3,0x8049e6c8
  lwz   r3,0x88(r3)
  lwz r4,OFST_mexData(rtoc)
  lwz r4,Arch_Map(r4)
  lwz r4,Arch_Map_Playlists(r4)
  mulli r3,r3,Playlists_Stride
  add REG_Playlist,r3,r4

#Start of playlist
  lwz r3,0x4(REG_Playlist)
  restore
  blr