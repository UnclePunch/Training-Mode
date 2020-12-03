#To be inserted at 800908f4
.include "../../Globals.s"
.include "../Header.s"

  .set REG_PlayerData,31
  .set REG_InputIndex,30
  .set REG_PrevInput,29
  .set REG_HSDPad,28

.set  OFST_PlCo,-0x514C
.set  HSD_Pad,0x804c1f78 #r31 @ 0x80377DC0

  backup

  #Cardinal direction held check:
  # 0 = successful vanilla wiggle (branch out with cr0 less than bit true)
  # 1 = continue to check additional conditions
  # 2+ = wiggle fail due to input held, (branch out with cr0 less than bit false)

    cmpwi r3, 1
    bne- END

  #Ensure last frame < 0.8
    lfs f1,0x628(REG_PlayerData)
    fabs f1,f1
    lwz r3,OFST_PlCo(r13)
    lfs f2,0x210(r3)
    fcmpo cr0,f1,f2
    bge END

  BEGIN_HW_INPUTS:
  
  LOAD_2_FRAMES_PAST_INPUTS:
    lbz	REG_PrevInput, MEX_UCF2fX (REG_PlayerData)
    extsb	REG_PrevInput,REG_PrevInput

  LOAD_CURRENT_FRAME_INPUT:
    lbz r3, MEX_UCFCurrX (REG_PlayerData)
    extsb r3,r3

  CALCULATE_DIFFERENCE:
      sub	  r3,REG_PrevInput,r3
      mullw r3, r3, r3  # Take square to get positive value for comparison
  THRESHOLD_TEST:
      li r4, 3600   # compare square of input difference between current frame and 2 frames ago to square of 60 (formerly 75 because different units)
      cmpw r4, r3
      b END

  END:
    restore