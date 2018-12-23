#To be inserted at 8024d92c
.include "D:/Users/Vin/Documents/GitHub/Training-Mode/ASM/Globals.s"

backup

#Check For L
li	r3,4
branchl	r12,0x801a36a0
rlwinm.	r0, r4, 0, 25, 25			#CHECK FOR L
bne	OpenFDD
rlwinm.	r0, r4, 0, 27, 27			#CHECK FOR Z
bne	OpenCredits

#Check For Training Mode ISO Game ID
lis	r5,0x8000
lwz	r5,0x0(r5)
load	r6,0x47544d45			#GTME
cmpw	r5,r6
bne	exit
#Check for R
rlwinm.	r0, r4, 0, 26, 26			#CHECK FOR R
bne	PlayMovie
b	exit

#Check For DPad Left

#Check

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
			subi	r23,r23,0x3

			#Ensure Number is Bewteen 0 and 14
			cmpwi	r23,0
			blt	FileNotFound
			cmpwi	r23,14
			bgt	FileNotFound

			#Get Movie File Strings
			bl	MovieFileNames
			mflr	r4

			#Get Event's Tutorial File Name in r20
			mulli	r3,r23,0x8
			add	r20,r3,r4

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

#######################################

MovieFileNames:
blrl

#L-Cancelling (TvLC)
.long 0x54764c43
.long 0x00000000

#LedgeDash (TvLedDa)
.long 0x54764c65
.long 0x64446100

#LedgeDash (TvEgg)
.long 0x54764567
.long 0x67000000

#SDI (TvSDI)
.long 0x54765344
.long 0x49000000

#Reversal (TvRvrsl)
.long 0x54765276
.long 0x72736c00

#Powersheld (TvPowSh)
.long 0x5476506f
.long 0x77536800

#Shield Drop (TvShDrp)
.long 0x54765368
.long 0x44727000

#Spacing on Shield (TvSpaSh)
.long 0x54765370
.long 0x61536800

#Ledge Tech (TvLedTc)
.long 0x54764c65
.long 0x64546300

#Amsah Tech (TvAmsTc)
.long 0x5476416d
.long 0x73546300

#Techchase (TvTchCh)
.long 0x54765463
.long 0x68436800

#Waveshine SDI (TvWvSDI)
.long 0x54765776
.long 0x53444900

#######################################

FileSuffixes:
blrl

#.hps
.long 0x2e687073
.long 0x00000000

#.mth
.long 0x2e6d7468
.long 0x00000000

#######################################


exit:
restore
li	r0, 16
