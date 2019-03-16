#To be inserted at 8024d92c
.include "../Globals.s"

backup

#Check For L
	li	r3,4
	branchl	r12,0x801a36c0
	rlwinm.	r0, r4, 0, 25, 25			#CHECK FOR L
	bne	OpenFDD
	rlwinm.	r0, r4, 0, 27, 27			#CHECK FOR Z
	bne	OpenCredits

#Check for Tutotial (R)
#Check For Training Mode ISO Game ID First
	lis	r5,0x8000
	lwz	r5,0x0(r5)
	load	r6,0x47544d45			#GTME
	cmpw	r5,r6
	bne	CheckToSwitchPage
#Check for R
	rlwinm.	r0, r4, 0, 26, 26			#CHECK FOR R
	bne	PlayMovie

CheckToSwitchPage:
#Check For Left
	li	r5,-1
	rlwinm. r0,r3,0,25,25
	bne	SwitchPage
#Check For Right
	li	r5,1
	rlwinm. r0,r3,0,24,24
	bne	SwitchPage
	b	exit

OpenFDD:

	#PLAY SFX
	li	r3, 1
	branchl	r4,0x80024030

	#SET FLAG IN RULES STRUCT
	li	r0,3		#3 = frame data from event toggle
	load	r3,0x804a04f0
	stb	r0, 0x0011 (r3)

	#SET SOMETHING
	li	r0, 5
	sth	r0, -0x4AD8 (r13)

	#BACKUP CURRENT EVENT ID
	lwz	r3, -0x4A40 (r13)
	lwz	r5, 0x002C (r3)
	lbz	r3,0x0(r5)
	lwz	r4,0x4(r5)
	add	r3,r3,r4
	lwz	r4, -0x77C0 (r13)
	stb	r3, 0x0535 (r4)

	#LOAD RSS
	branchl	r3,0x80237410

	#REMOVE EVENT THINK FUNCTION
	lwz	r3, -0x3E84 (r13)
	branchl	r12,0x80390228

	b	exit

OpenCredits:

	#Load Minor Scene 0x1
	load	r4,SceneController
	li	r3,0x1
	stb	r3,0x4(r4)

	#Change Screen
	li	r3,0x1
	stw	r3,0x34(r4)

	#Make Previous Major Event CSS So It Returns to Event SS
	load	r4,SceneController
	li	r3,0x2B
	stb	r3,0x2(r4)

	#BACKUP CURRENT EVENT ID
	lwz	r3, -0x4A40 (r13)
	lwz	r5, 0x002C (r3)
	lbz	r3,0x0(r5)
	lwz	r4,0x4(r5)
	add	r3,r3,r4
	lwz	r4, -0x77C0 (r13)
	stb	r3, 0x0535 (r4)

	#Return To Event SS
	#load	r4,0x804d68b8
	#li	r3,0x7
	#stb	r3,0x0(r4)
	#li	r3,0x2B
	#stb	r3,0x4(r4)

	#Overwrite SceneDecide Function So It Doesn't Change Majors
	bl	TempSceneDecide
	mflr	r3
	load	r4,0x803dae44		#Main Menu's Minor Table Pointer
	lwz	r4,0x0(r4)
	stw	r3,0x8(r4)		#Overwrite MainMenu's SceneDecide Temporarily

	#PLAY SFX
	li	r3, 1
	branchl	r4,0x80024030

	#Init Name Count Variable
	li	r3,0x0
	stw	r3, -0x4eac (r13)

	b	exit

PlayMovie:



		################################################
		## Get Movie's FileName and Extension Pointer ##
		################################################

			#Get Hovered Over Event ID in r23
			lwz	r5, -0x4A40 (r13)
			lwz	r5, 0x002C (r5)
			lwz	r3, 0x0004 (r5)		 #Selection Number
			lbz	r0, 0 (r5)		  #Page Number
			add	r23,r3,r0

			#Get Movie File String
			mr	r3,r23
			bl	MovieFileNames
			mflr	r4
			branchl r12,SearchStringTable
			mr	r20,r3							#Get Event's Tutorial File Name in r20

			#Get Extension Pointer in r21
			bl	FileSuffixes
			mflr	r21

		##############################
		## Play Movie's Audio Track ##
		##############################

			#Copy To Temp Audio String Space
			load	r22,0x803bb380		#Temp Audio String Space
			addi	r3,r22,0x7		#After the /audio/
			mr	r4,r20		#Movie FileName
			branchl	r12,0x80325a50		#strcpy

			#Get Length of This String Now
			mr	r3,r22
			branchl	r12,0x80325b04

			#Copy .hps to the end of it
			add	r3,r3,r22		#Dest
			mr	r4,r21		#.hps string
			branchl	r12,0x80325a50

			#Check If File Exists
			mr	r3,r22
			branchl	r12,0x8033796c
			cmpwi	r3,-1
			beq	FileNotFound

			#Load Song File
			LoadSongFile:
			mr	r3,r22		#Full Song File Name
			li	r4,127		#Volume?
			li	r5,1		#Unk
			branchl	r12,0x80023ed4


		#####################
		## Load Movie File ##
		#####################

		StartLoadMovieFile:

			#Copy File Name To Temp Space
			load	r22,0x80432058		#Temp File Name Space
			mr	r3,r22		#Destination
			mr	r4,r20		#Movie FileName
			branchl	r12,0x80325a50		#strcpy

			#Get Length of This String Now
			mr	r3,r22		#Destination
			branchl	r12,0x80325b04

			#Copy .mth Suffix
			add	r3,r3,r22		#Dest
			addi	r4,r21,0x8		#.mth string
			branchl	r12,0x80325a50

			#Check If File Exists
			mr	r3,r22
			branchl	r12,0x8033796c
			cmpwi	r3,-1
			beq	FileNotFound

			#PLAY SFX
			li	r3, 1
			branchl	r4,0x80024030

			#Unk Set
			li	r3,0x1
			branchl	r12,0x80024e50

			#Load Movie File
			mr	r3,r22		#File Name
			li	r4,0
			lwz	r5, -0x4A14 (r13)
			li	r5,0
			load	r6,0x00271000
			#li	r6,0		#Frame Buffer Heap Size?
			li	r7,0
			branchl	r12,0x8001f410

			#Unk Unset
			li	r3,0x0
			branchl	r12,0x80024e50



	#Create And Schedule Custom Movie Think Functions

		#Create Camera Think Entity
			li	r3, 13
			li	r4,14
			li	r5,0
			branchl	r12,0x803901f0
		#Attach Camera Think
			mr	r31,r3
			li	r4,640
			li	r5,480
			li	r6,8
			li	r7,0
			branchl	r12,0x801a9dd0
			li	r0,0x800
			stw	r0,0x24(r31)
			li	r0,0x0
			stw	r0,0x20(r31)

		#Create Movie Display Entity
			li	r3, 14
			li	r4,15
			li	r5,0
			branchl	r12,0x803901f0
			mr	r30,r3
			stw	r3, -0x4E48 (r13)
			lbz	r4, -0x3D40 (r13)
			li	r5, 0
			branchl	r12,0x80390a70
		#Attach Display Process
			mr	r3,r30
			load	r4,0x8001f67c
			li	r5,11
			li	r6,0
			branchl	r12,0x8039069c

		#Change Screen Size to Fullscreen
			mr	r3,r30
			li	r4,640
			li	r5,480
			branchl	r12,0x8001f624
			lfs	f0, -0x3680 (rtoc)
			stfs	f0, 0x0010 (r3)
			stfs	f0, 0x0014 (r3)



		#Create Movie Think Entity
			li	r3, 6
			li	r4,7
			li	r5,128
			branchl	r12,0x803901f0
			mr	r29,r3
		#Alloc 10 Bytes
			li	r3,10
			branchl	r12,0x8037f1e4
		#Initliaze Entity
			mr	r6,r3
			mr	r3,r29
			li	r4,0x0
			load	r5,0x8037f1b0
			branchl	r12,0x80390b68
		#Schedule Think
			mr	r3,r29
			bl	MovieThink
			mflr	r4
			li	r5,0x0
			branchl	r12,0x8038fd54
		#Store Display Entity and Camera Entity to the Think Entity
			lwz	r3,0x2C(r29)		#Think's Data
			stw	r31,0x0(r3)		#Camera Entity
			stw	r30,0x4(r3)		#Display Entity

		#REMOVE EVENT THINK FUNCTION
			lwz	r3, -0x3E84 (r13)
			branchl	r12,0x80390228

	b	exit


#######################################

FileNotFound:

	#PLAY SFX
	li	r3, 3
	branchl	r4,0x80024030

	b	exit

#######################################

TempSceneDecide:
blrl

#Store Back
load	r3,0x801b138c		#Function Address
load	r4,0x803dae44		#Main Menu's Minor Table Pointer
lwz	r4,0x0(r4)
stw	r3,0x8(r4)		#Overwrite MainMenu's SceneDecide

blr

#######################################

MovieThink:
blrl

backup

#Backup Entity Pointer
	mr	r31,r3
	lwz	r30,0x2C(r3)

#Advance Frame
	branchl	r12,0x8001f578

#Check If Movie Is Over
	branchl	r12,0x8001f604
	cmpwi	r3,0x0
	bne	EndMovie

#Check For Button Press
	li	r3, 4
	branchl	r12,0x801a36a0		#All Players Inputs
	andi.	r4,r4,0x1100
	beq	Exit
#PLAY SFX
	li	r3, 1
	branchl	r4,0x80024030
	b	EndMovie

restore
blr


EndMovie:
#Stop Music
	branchl	r12,0x800236dc
#Remove Camera Think Function
	lwz	r3,0x0(r30)		#Camera Entity
	branchl	r12,0x80390228
#Remove Display Process Function
	lwz	r3,0x4(r30)		#Display Entity
	branchl	r12,0x80390228
#Remove This Think Function
	mr	r3,r31
	branchl	r12,0x80390228
#Unload Movie
	branchl	r12,0x8001f800
#Play Menu Music
	lwz	r3, -0x77C0 (r13)
	lbz	r3, 0x1851 (r3)
	branchl	r12,0x80023f28
#Reload Event Match Think
	li	r3, 0
	li	r4, 1
	li	r5, 128
	branchl	r12,0x803901f0
	load	r4,0x8024d864
	li	r5,0
	branchl	r12,0x8038fd54

Exit:
restore
blr

MovieFileNames:
blrl

#L-Cancelling (TvLC)
.string "TvLC"

#LedgeDash (TvLedDa)
.string "TvLedDa"

#LedgeDash (TvEgg)
.string "TvEgg"

#SDI (TvSDI)
.string "TvSDI"

#Reversal (TvRvrsl)
.string "TvRvrsl"

#Powersheld (TvPowSh)
.string "TvPowSh"

#Shield Drop (TvShDrp)
.string "TvShDrp"

#Spacing on Shield (TvSpaSh)
.string "TvSpaSh"

#Ledge Tech (TvLedTc)
.string "TvLedTc"

#Amsah Tech (TvAmsTc)
.string "TvAmsTc"

#Techchase (TvTchCh)
.string "TvTchCh"

#Waveshine SDI (TvWvSDI)
.string "TvWvSDI"
.align 2

#######################################

FileSuffixes:
blrl

#.hps
.string ".hps"
.align 2

#.mth
.string ".mth"
.align 2

#######################################

SwitchPage:

#Change page
	lwz r4,MemcardData(r13)
	lbz r3,CurrentEventPage(r4)
	add	r3,r3,r5
	stb r3,CurrentEventPage(r4)
#Check if within page bounds
SwitchPage_CheckHigh:
	cmpwi r3,NumOfPages
	ble SwitchPage_CheckLow
#Stay on current page
	subi r3,r3,1
	stb r3,CurrentEventPage(r4)
	b	exit
SwitchPage_CheckLow:
	cmpwi r3,0
	bge SwitchPage_ChangePage
#Stay on current page
	li	r3,0
	stb r3,CurrentEventPage(r4)
	b	exit

SwitchPage_ChangePage:
#Get Page Name ASCII
	branchl r12,GetCustomEventPageName
#Update Page Name
	mr	r5,r3
	lwz r3,-0x4EB4(r13)
	li	r4,0
	branchl r12,Text_UpdateSubtextContents

#Reset cursor to 0,0
	lwz	r5, -0x4A40 (r13)
	lwz	r5, 0x002C (r5)
	li	r3,0
	stw	r3, 0x0004 (r5)		 #Selection Number
	stb	r3, 0 (r5)		  	 #Page Number

#Redraw Event Text
SwitchPage_DrawEventTextInit:
	li	r29,0							#loop count
	lwz	r3, 0x0004 (r5)		 #Selection Number
	lbz	r4, 0 (r5)		  	 #Page Number
	add r28,r3,r4
SwitchPage_DrawEventTextLoop:
	mr	r3,r29
	add	r4,r29,r28
	branchl r12,0x8024d15c
	addi r29,r29,1
	cmpwi r29,9
	blt SwitchPage_DrawEventTextLoop

#Redraw Event Description
	lwz	r3, -0x4A40 (r13)
	mr	r4,r28
	branchl r12,0x8024d7e0

#Update cursor position
#Get Texture Data
	lwz	r3, -0x4A40 (r13)
	lwz	r3, 0x0028 (r3)
	addi r4,sp,0x40
	li	r5,11
	li	r6,-1
	crclr	6
	branchl r12,0x80011e24
	lwz r3,0x40(sp)
#Change Y offset?
	li	r0,0
	stw r0,0x3C(r3)
#DirtySub
	branchl r12,0x803732e8

#Play SFX
	li	r3,2
	branchl r12,SFX_MenuCommonSound

#######################################

exit:
restore
li	r0, 16
