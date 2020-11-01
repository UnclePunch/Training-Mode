#To be inserted @ 803d7080
.include "../../Globals.s"
.include "../Header.s"

# void KirbyStateChange(GOBJ *fighter, int state, float startFrame, float animSpeed, float animBlend)

.set  REG_GObj,31
.set  REG_State,30
.set  REG_FighterData,29
.set  REG_StateMoveLogic,28
.set  REG_FtCmd,27
.set  REG_AbilityID,26
.set  REG_Frame,31
.set  REG_Speed,30
.set  REG_Blend,29

# Init
  backup
  stfs  REG_Speed,0x80(sp)
  stfs  REG_Blend,0x84(sp)
  stfs  REG_State,0x88(sp)
  mr  REG_GObj,r3
  mr  REG_State,r4
  fmr  REG_Frame,f1
  fmr  REG_Speed,f2
  fmr  REG_Blend,f3
  lwz REG_FighterData,0x2C(REG_GObj)

# Check if Kirby
  lwz r3,0x4(REG_FighterData)
  cmpwi r3,4
  bne NotKirby

# Get current ability ID
  lwz REG_AbilityID,0x2238(REG_FighterData)  

# Get this states move logic
  lwz r3,OFST_KirbyMoveLogicRuntime(rtoc)
  mulli r4,REG_AbilityID,0x4
  lwzx  r3,r3,r4    # get this abilities move logic pointer
  cmpwi r3,0
  beq NoMoveLogic
  mulli r4,REG_State,0x20   # get this states move logic
  add REG_StateMoveLogic,r3,r4

# Get this states ftcmd
  lwz r3,OFST_KirbyFtCmdRuntime(rtoc)
  mulli r4,REG_AbilityID,0x4
  lwzx  r3,r3,r4    # get this abilities ftcmd pointer
  cmpwi r3,0
  beq NoFtCmd
  lwz r4,0x0(REG_StateMoveLogic)  # get this states animation
  mulli r4,r4,0x18   # get this states ftcmd
  add REG_FtCmd,r3,r4

# Enter Dummy State
  mr  r3,REG_GObj 
  li  r4,0XEF        # dummy state id
  lis  r5,0x2000  # no anim update
  li  r6,0        # no source gobj
  fmr f1,REG_Frame
  fmr f2,REG_Speed
  fmr f3,REG_Blend
  branchl r12,ActionStateChange

# Spoof anim ID as not -1 (so the animation is updated each frame)
  li  r3,0
  stw r3,0x14(REG_FighterData)

# Spoof state as ItemScopeFire
  li  r3,0xA0
  stw r3,0x10(REG_FighterData)

# Spoof current anim offset as -1 (will always result in a cache miss for the next anim load)
  li  r3,-1
  stw r3,0x5A4(REG_FighterData)

# Store pointer to figatree animation symbol
  lwz r3,0x4(REG_FtCmd)
  cmpwi r3,0
  beq NoAnim
  stw r3,0x590(REG_FighterData)

/*
# Load animation data from source  
  mr  r3, REG_FighterData         # anim dest
  mr  r4, REG_AbilityGObjData     # anim source
  lwz r5,0x0(REG_StateMoveLogic)  # anim ID
  branchl r12,0x80085cd8
*/

# Store subaction pointer
  lwz r3,0xC(REG_FtCmd)                    # script data
  stw r3,0x3EC(REG_FighterData)

# Enter animation 
  lwz r3,0x590(REG_FighterData)
  mr  r3,REG_GObj
  fmr f1,REG_Frame
  fmr f2,REG_Speed
  fmr f3,REG_Blend
  branchl r12,0x8006ebe8

# Unk
  li  r3,0
  stw r3,0x3E4(REG_FighterData)

# Increment state frame info
  mr  r3,REG_GObj
  branchl r12,0x8006e9b4

# Subaction update stuff
  lfs	f0, -0x778C (rtoc)
  fcmpo cr0,f0,REG_Frame
  bne SubactionSkip
SubactionStart:
  mr  r3,REG_GObj
  branchl r12,0x800c0408  # update colanims
  mr  r3,REG_GObj
  branchl r12,0x80073240  # update subaction unk
  b SubactionEnd
SubactionSkip:
  mr  r3,REG_GObj
  branchl r12,0x80073354
SubactionEnd:

# Copy callbacks from source
  lwz r3,0xC(REG_StateMoveLogic)  # unk callback
  stw r3,0x21A0(REG_FighterData)
  lwz r3,0x10(REG_StateMoveLogic) # unk callback
  stw r3,0x219C(REG_FighterData)
  lwz r3,0x14(REG_StateMoveLogic) # unk callback
  stw r3,0x21A4(REG_FighterData)
  lwz r3,0x18(REG_StateMoveLogic) # unk callback
  stw r3,0x21A8(REG_FighterData)
  lwz r3,0x1C(REG_StateMoveLogic) # unk callback
  stw r3,0x21AC(REG_FighterData)

  b Exit

#############################################
NoMoveLogic:
#OSReport
  bl  NoMoveLogicString
  mflr  r3
  lwz r4,OFST_KirbyHatFileNames(rtoc)
  mulli r5,REG_AbilityID,8
  lwzx  r4,r4,r5
  branchl r12,0x803456a8
  b Assert
NoMoveLogicString:
blrl
.string "error: kbfunction in %s missing move_logic table\n"
.align 2
###############################################

NoFtCmd:
#OSReport
  bl  NoFtCmdString
  mflr  r3
  lwz r4,OFST_KirbyHatFileNames(rtoc)
  mulli r5,REG_AbilityID,8
  lwzx  r4,r4,r5
  branchl r12,0x803456a8
  b Assert
NoFtCmdString:
blrl
.string "error: %s missing ftcmd symbol\n"
.align 2

###############################################

NoAnim:
#OSReport
  bl  NoAnimString
  mflr  r3
  lwz r4,OFST_KirbyHatFileNames(rtoc)
  mulli r5,REG_AbilityID,8
  lwzx  r4,r4,r5
  mr  r5,REG_State
  branchl r12,0x803456a8
  b Assert
NoAnimString:
blrl
.string "error: ftcmd in %s missing animation for state %d\n"
.align 2

###############################################

NotKirby:
#OSReport
  bl  NotKirbyString
  mflr  r3
  lwz r4,0x4(REG_FighterData)
  branchl r12,0x803456a8
  b Assert
NotKirbyString:
blrl
.string "error: fighter %d is not kirby\n"
.align 2
###############################################

Assert:
  bl  Assert_Name
  mflr  r3
  li  r4,0
  load  r5,0x804d3940
  branchl r12,0x80388220
Assert_Name:
blrl
.string "m-ex"
.align 2
###############################################

Error:
  b 0x0

Exit:
  lfs  REG_Speed,0x80(sp)
  lfs  REG_Blend,0x84(sp)
  lfs  REG_State,0x88(sp)
  restore
  blr
