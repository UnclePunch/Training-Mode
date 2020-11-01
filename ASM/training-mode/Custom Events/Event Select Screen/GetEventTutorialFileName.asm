#To be inserted at 80005538
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

backup

		################################################
		## Get Movie's FileName and Extension Pointer ##
		################################################

		.set EventID,23
		.set PageID,24
		.set ReturnString,25

		#Backup return string
			mr	ReturnString,r3

		#Get Hovered Over Event ID in r23
			lwz	r5, -0x4A40 (r13)
			lwz	r5, 0x002C (r5)
			lwz	r3, 0x0004 (r5)		 #Selection Number
			lbz	r0, 0 (r5)		  #Page Number
			add	EventID,r3,r0

		#Get Current Page in
		  lwz r3,MemcardData(r13)
		  lbz PageID,CurrentEventPage(r3)

		#Get pointer page's string array
			bl	SkipJumpTable

		##### Page List #######
			EventJumpTable
		#######################

		SkipJumpTable:
		  mflr	r4		#Jump Table Start in r4
		  mulli	r5,PageID,0x4		#Each Pointer is 0x4 Long
		  add	r4,r4,r5		#Get Event's Pointer Address
		  lwz	r5,0x0(r4)		#Get bl Instruction
		  rlwinm	r5,r5,0,6,29		#Mask Bits 6-29 (the offset)
		#Get Movie File String
			mr	r3,EventID
			add	r4,r4,r5		#Gets ASCII Address in r4
			branchl r12,SearchStringTable

			restore
			blr

#######################################

EventTutorials

#######################################
