#To be inserted at 8024d84c
.include "../../../Globals.s"
.include "../../../../m-ex/Header.s"

.set MainTextOffset,-0x4EB4
.set LeftArrowTextOffset,-0x4EB0
.set RightArrowTextOffset,-0x4EAC
.set TutTextOffset,-0x4EA8

backup

.set  REG_PageNum,22
.set  EventID,23
.set  PageID,24

#Get number of pages
  rtocbl	r12,TM_GetPageNum
  mr  REG_PageNum,r3
#Get Event ID
  lbz	r3,0x0(r31)
  lwz	r4,0x4(r31)
  add	EventID,r3,r4
#Check if first page
  lwz r3,MemcardData(r13)
  lbz PageID,CurrentEventPage(r3)
	cmpwi PageID,0
	bne ShowFirstPage
#Hide left arrow
	li	r4,1
	b	FirstPageVisibility
ShowFirstPage:
#Show left arrow
	li	r4,0
	b	FirstPageVisibility
FirstPageVisibility:
	lwz	r3, LeftArrowTextOffset (r13)
	stb r4,0x4D(r3)

#Check if last page
	cmpw PageID,REG_PageNum
	bne ShowLastPage
#Hide right arrow
	li	r4,1
	b	LastPageVisibility
ShowLastPage:
#Show right arrow
	li	r4,0
	b	LastPageVisibility
LastPageVisibility:
	lwz	r3, RightArrowTextOffset (r13)
	stb r4,0x4D(r3)


#Check For Training Mode ISO Game ID
	lis	r5,0x8000
	lwz	r5,0x0(r5)
	load	r6,0x47544d45			#GTME
	cmpw	r5,r6
	bne	end
#Get Events Tutorial
	lwz r3,MemcardData(r13)
	lbz r3,CurrentEventPage(r3)
  mr  r4,EventID
	rtocbl r12,TM_GetEventTut
	mr	r20,r3
#Copy File Name To Temp Space
	addi	r21,sp,0x80
	mr	r3,r21								#Destination
	mr	r4,r20								#Movie FileName
	branchl	r12,0x80325a50		#strcpy
#Get Length of This String Now
	mr	r3,r21								#Destination
	branchl	r12,0x80325b04
#Copy .mth Suffix
	add	r3,r3,r21							#Dest
	bl	FileSuffix
	mflr r4
	branchl	r12,0x80325a50

#Check if exists
	mr	r3,r21								#Destination
	branchl r12,0x8033796c
	cmpwi r3,-1
	beq HideTutorial
ShowTutorial:
	li	r4,0
	b	DisplayTutorial
HideTutorial:
	li	r4,1
DisplayTutorial:
	lwz	r3, TutTextOffset (r13)
	stb r4,0x4D(r3)

	b	end

FileSuffix:
blrl
.string ".mth"
.align 2


end:
restore
lwz	r0, 0x0024 (sp)
