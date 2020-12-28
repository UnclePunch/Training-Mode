#To be inserted at 80359750
.include "../Globals.s"

  load r5,0x80479d48

# If game unpaused, play sound
  lbz r3,0x20(r5)
  rlwinm. r0,r3,0,0x1
  beq Original

# Game is paused, check if advancing this frame
  lbz r3,0x22(r5)
  rlwinm. r0,r3,0,0x1
  bne Original

# Skip audio update
  branch r12,0x80359830

Original:
  mr	r3, r30