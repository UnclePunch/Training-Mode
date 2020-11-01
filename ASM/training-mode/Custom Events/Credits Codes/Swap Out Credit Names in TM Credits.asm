#To be inserted at 801aac60
#80100000
.include "../../Globals.s"
.include "../../../m-ex/Header.s"

b	FunctionStart

Names:
blrl
.string "Charlotte"
.string "Hugh N"
.string "HARB"
.string "Cyrus R"
.string "ravecake"
.string "Jeremy"
.string "Dominick T"
.string "Robert P"
.string "Jonathan B"
.string "Daniel F"
.string "Marshall Z"
.string "Thomas B"
.string "Rishi"
.string "KELLZ"
.string "Turkey"
.string "Outside"
.string "Jesse"
.string "BenSW"
.string "Setchi "
.string "Jimmy M"
.string "Micah S"
.string "Avi"
.string "YungZunga"
.string "Randle J"
.string "Andreas H"
.string "Calszone"
.string "Riley D"
.string "Anthony C"
.string "Kevin T"
.string "Zane R"
.string "Gage K"
.string "Ari"
.string "Vitral"
.string "CF True"
.string "yardsale"
.string "James L"
.string "Zach N"
.string "Sir Lemon"
.string "Matt B"
.string "Max S"
.string "RealDingos "
.string "Wasif R"
.string "femboy uwu"
.string "Spencer G"
.string "Ben A"
.string "William R"
.string "KJH"
.string "Reeve"
.string "Christian A"
.string "Esteban H"
.string "Forrest G"
.string "Aiden C"
.string "Grolex"
.string "Manuel P"
.string "Methorphan"
.string "bofftarget"
.string "Mark M"
.string "Reece E"
.string "Ka Ming AC"
.string "BONSAI BOYS"
.string "Jean T"
.string "Jon"
.string "Stuart K"
.string "Mike R"
.string "James"
.string "Miller T"
.string "Darren M"
.string "ShaggyJ"
.string "Bryan K"
.string "Collin B"
.string "Lucas S"
.string "jeremiah K"
.string "Will A"
.string "Eacab"
.string "Maccrea P"
.string "Justin H"
.string "Zach J"
.string "Brandt W"
.string "Gene K"
.string "Jaycob A"
.string "Joseph R"
.string "blandeezy"
.string "Vim"
.string "roob adoob"
.string "Sami B"
.string "Blake P"
.string "Charlon"
.string "Aldrin R"
.string "Jane L"
.string "Martin R"
.string "Stephane S"
.string "Greg W"
.string "Delano W"
.string "Kyle S"
.string "K OBrien"
.string "Albert Z"
.string "Lykon"
.string "Benjamin E"
.string "Dave S"
.string "Jordan J"
.string "Gear"
.string "Fritz"
.string "Jeff J"
.string "Dalton G"
.string "Trevor C"
.string "Chad S"
.string "Brit B"
.string "Austin D"
.string "Micah W"
.string "Jonathon M"
.string "Jason V"
.string "Marvin S"
.string "Glenn T"
.string "Jordan M"
.string "Bj C"
.string "Lucio"
.string "Benno K"
.string "Bernando B"
.string "Kaveh A"
.string "Thomas R"
.string "Austin L"
.string "Brennan R"
.string "Anthony G"
.string "Ryan M"
.string "Tony K"
.string "Shane K"
.string "Andrew W"
.string "Vincent T"
.string "Ali S"
.string "Nathan H"
.string "Maxime C"
.string "Riley B"
.string "cagliostro9"
.string "Jonathan M"
.string "Rafa M"
.string "Lucuius M"
.string "Julie M"
.string "Sergio D"
.string "Andre MLO"
.string "Juan D"
.string "Andrew Y"
.string "Fabadam"
.string "Tony R"
.string "Daniel C"
.string "Derex E"
.string "Chris C"
.string "Samuel CD"
.string "Melee Stats"
.string "George G"
.string "Joey A"
.string "Stephan M"
.string "Jason S"
.string "Kris S"
.string "Mikey R"
.string "Jake M"
.string "Liam M"
.string "Andy C"
.string "Sunset"
.string "Dylan M"
.string "Will N"
.string "+"
.string "Matthew L"
.string "Matthew P"
.string "Aiden F"
.string "Michael O"
.string "Drew D"
.string "Tyler M"
.string "+"
.string "masafumsa"
.string "Nathan S"
.string "Quentin F"
.string "Bobby Scar"
.string "OuterHalo"
.string "Max R"
.string "TruckJitsu"
.string "Seth M"
.string "Jamie C"
.string "Eddie A"
.string "Cody N"
.string "Joel"
.string "Kalvar"
.string "Armando C"
.string "+"
.string "+"
.string "Special Thanks"
.string "Achilles"
.string "Dan Salvato"
.string "Punkline"
.string "DRGN"
.string "Fizzi"
.string "Minute Melee"
.string "Dolphin-Emu"
.string "Gecko OS"
.string ""
.string ""
.string ""
.string "Thanks to all my patrons
who supported this project!

www.twitter.com/UnclePunch_
www.patreon.com/UnclePunch"
.align 2

FunctionStart:
.set FirstNameToReplace,2
.set LastNameToReplace,196

.set text,30

backup

#Check For TM Credits
  load	r3,SceneController
  lbz	r3,0x0(r3)
  cmpwi	r3,0x1
  bne	Exit

#Only Display After the First 2 Names
CheckWhitelist:
  lwz	r3, -0x4eac (r13)
  cmpwi	r3,FirstNameToReplace
  blt	Exit
  cmpwi	r3,LastNameToReplace
  bgt	Exit

#Create Text
  li  r3,0
  li  r4,0
  branchl r12,0x803a6754
  mr  text,r3
#Init Some Values
  li  r0,1
  stb r0,0x4C(text)
  stb r0,0x4A(text)
  stb r0,0x49(text)
  stfs	f30, 0x0024 (text)
  stfs	f29, 0x0028 (text)
  lfs	f1, -0x4F10 (rtoc)
  lfs	f2, -0x4F0C (rtoc)
  lfs	f3, -0x4F08 (rtoc)
  stfs f1,0x00(text)
  stfs f2,0x04(text)
  stfs f1,0x08(text)
  stfs f1,0x0C(text)
  stfs f3,0x10(text)
#Store Pointer
  lwz	r3, -0x4EA8 (r13)
  stwx	text, r3, r31

ConvertToMenuText:
#Get Text As Menu Text
  lwz	r3, -0x4EAC (r13)
  bl  Names
  mflr r4
  branchl r12,SearchStringTable
  mr  r4,r3
  addi r3,sp,0x40
  branchl	r12,0x803a67ec
  mr  r20,r3              #Backup text length

#Get Text Struct Pointer
  lwz	r3, -0x4EA8 (r13)
  lwzx	text, r3, r31
#Get Allocation Info Pointer
  lwz r21,0x64(text)
#Check To Adjust Allocation
  lwz	r22, 0x0004 (r21)     #Get old menu text allocation
  lwz	r0, 0 (r21)
  lwz	r4, 0x0008 (r21)      #Get size of allocation
  sub	r3, r0, r22
  addi	r0, r3, 17
  add	r0, r20, r0
  cmplw	r4, r0
  bge-	 NoAdjustAllocation
  sub	r0, r0, r4
  rlwinm	r3, r0, 25, 7, 31
  addi	r0, r3, 1
  rlwinm	r0, r0, 7, 0, 24
  add	r0, r4, r0
  stw	r0, 0x0008 (r21)
  lwz	r3, 0x0008 (r21)
  branchl r12,0x803A5798
  addi	r5, r22, 0
  addi	r4, r3, 0
  li	r7, 0
  b		ReAllocateLoop_Inc
ReAllocateLoop:
  lbz	r0, 0 (r5)
  addi	r7, r7, 1
  addi	r5, r5, 1
  stb	r0, 0 (r4)
  addi	r4, r4, 1
ReAllocateLoop_Inc:
  lwz	r6, 0x0004 (r21)
  lwz	r0, 0 (r21)
  sub	r6, r0, r6
  addi	r0, r6, 1
  cmpw	r7, r0
  blt+	ReAllocateLoop
  stw	r3, 0x0004 (r21)
  stw	r3, 0x005C (text)
  lwz	r0, 0 (r21)
  sub	r0, r0, r22
  add	r0, r3, r0
  stw	r0, 0 (r21)
  mr	r3, r22
  branchl r12,0x803A594C
NoAdjustAllocation:
#Copy new text to text struct
  lwz r3,0x5C(text)
  addi r4,sp,0x40
  mr  r5,r20
  branchl r12,memcpy

#Add Terminator
  li r3,0x1900
  lwz r4,0x5C(text)
  sthx r3,r20,r4
  b CustomExit

CustomExit:
#Inc Name Count
lwz	r3, -0x4eac (r13)
addi	r3,r3,0x1
stw	r3, -0x4eac (r13)

restore
branch r12,0x801aadb8



Exit:
lwz	r3, -0x4eac (r13)
addi	r3,r3,0x1
stw	r3, -0x4eac (r13)
restore
lfs	f1, -0x4F10 (rtoc)
