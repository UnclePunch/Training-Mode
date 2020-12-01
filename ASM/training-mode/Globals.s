#Debug Flag
.set debug,0

#PAL Flag, compiles with PAL codes when enabled
.set PAL,0

#######################
## Codeset Variables ##
#######################
#Number of Pages
.set NumOfPages,3 -1

#Score Types
.set KO,0x0
.set Time,0x1

##################################
#region Minigame Page Data
#Number of Events
.set Minigames.NumOfEvents,4 -1

#region Eggs-ercise
  .set Event_Eggs,0
  #Event Name
    .macro Event_Eggs_Name
      .string "Eggs-ercise"
    .endm

    .macro Event_Eggs_Description
      .string "Break the eggs! Only strong hits will
break them. DPad down = free practice."
    .endm

    .macro Event_Eggs_Tutorial
      .string "TvEgg"
    .endm

    .macro Event_Eggs_ChooseCPU
    .endm

    .macro Event_Eggs_PreloadData
    .endm

    .macro Event_Eggs_LoadSSS
      .byte Event_Eggs
    .endm

    .macro Event_Eggs_PlayableCharacters
    .endm

    .macro Event_Eggs_AvailableCPUs
    .endm

    .macro Event_Eggs_ScoreType
      .byte KO
    .endm

#endregion
#region Multishine
  .set Event_Multishine,1
  #Event Name
    .macro Event_Multishine_Name
      .string "Shined Blind"
    .endm

    .macro Event_Multishine_Description
      .string "How many shines can you
perform in 10 seconds?"
    .endm

    .macro Event_Multishine_Tutorial
      .string "TvMulShine"
    .endm

    .macro Event_Multishine_ChooseCPU
    .endm

    .macro Event_Multishine_PreloadData
    .byte Event_Multishine, -1, FinalDestination
    .endm

    .macro Event_Multishine_LoadSSS
    .endm

    .macro Event_Multishine_PlayableCharacters
      .byte Event_Multishine
      .long Falco_CSSID | Fox_CSSID
      .long -1
    .endm

    .macro Event_Multishine_AvailableCPUs
    .endm

    .macro Event_Multishine_ScoreType
      .byte KO
    .endm

#endregion
#region Reaction
  .set Event_Reaction,2
  #Event Name
    .macro Event_Reaction_Name
      .string "Reaction Test"
    .endm

    .macro Event_Reaction_Description
      .string "Test your reaction time by pressing
any button when you see/hear Fox shine!"
    .endm

    .macro Event_Reaction_Tutorial
      .string "TvReaction"
    .endm

    .macro Event_Reaction_ChooseCPU
    .endm

    .macro Event_Reaction_PreloadData
      .byte Event_Reaction, Fox.Ext, FinalDestination
    .endm

    .macro Event_Reaction_LoadSSS
    .endm

    .macro Event_Reaction_PlayableCharacters
    .endm

    .macro Event_Reaction_AvailableCPUs
    .endm

    .macro Event_Reaction_ScoreType
      .byte KO
    .endm

#endregion
#region Ledgestall
  .set Event_Ledgestall,3
  #Event Name
    .macro Event_Ledgestall_Name
      .string "Under Fire"
    .endm

    .macro Event_Ledgestall_Description
      .string "Use ledgestalling to remain
invincible while the lava rises!"
    .endm

    .macro Event_Ledgestall_Tutorial
      .string "TvMulShine"
    .endm

    .macro Event_Ledgestall_ChooseCPU
    .endm

    .macro Event_Ledgestall_PreloadData
    .byte Event_Ledgestall, -1, Brinstar
    .endm

    .macro Event_Ledgestall_LoadSSS
    .endm

    .macro Event_Ledgestall_PlayableCharacters
      .byte #Event_Ledgestall
      .long #Falco_CSSID | Fox_CSSID | Zelda_CSSID | Mewtwo_CSSID | Pikachu_CSSID | CaptainFalcon_CSSID | Ganondorf_CSSID | Link_CSSID | Roy_CSSID | Bowser_CSSID | Marth_CSSID | Yoshi_CSSID
      .long #-1
    .endm

    .macro Event_Ledgestall_AvailableCPUs
    .endm

    .macro Event_Ledgestall_ScoreType
      .byte Time
    .endm

    .set EventOSD_LedgeStall,0x00000000

#endregion

#endregion
#region Universal Tech Page Data
#Number of Events
  .set GeneralTech.NumOfEvents, 13 -1

#Event List
#region LCancel
  .set Event_LCancel,0
  #Event Name
    .macro Event_LCancel_Name
      .string "L-Cancel Training"
    .endm

    .macro Event_LCancel_Description
      .string "Practice L-Cancelling on
a stationary CPU."
    .endm

    .macro Event_LCancel_Tutorial
      .string "TvLC"
    .endm

    .macro Event_LCancel_ChooseCPU
      .byte Event_LCancel
    .endm

    .macro Event_LCancel_PreloadData
    .endm

    .macro Event_LCancel_LoadSSS
      .byte Event_LCancel
    .endm

    .macro Event_LCancel_PlayableCharacters
    .endm

    .macro Event_LCancel_ScoreType
      .byte KO
    .endm

#endregion
#region Ledgedash
  .set Event_Ledgedash,1
  #Event Name
    .macro Event_Ledgedash_Name
      .string "Ledgedash Training"
    .endm

    .macro Event_Ledgedash_Description
      .string "Practice Ledgedashes!
Use D-Pad to change ledge."
    .endm

    .macro Event_Ledgedash_Tutorial
      .string "TvLedDa"
    .endm

    .macro Event_Ledgedash_ChooseCPU
    .endm

    .macro Event_Ledgedash_PreloadData
    .endm

    .macro Event_Ledgedash_LoadSSS
      .byte Event_Ledgedash
    .endm

    .macro Event_Ledgedash_PlayableCharacters
    .endm

    .macro Event_Ledgedash_ScoreType
      .byte KO
    .endm

#endregion
#region Combo
  .set Event_Combo,2
  #Event Name
    .macro Event_Combo_Name
      .string "Combo Training"
    .endm

    .macro Event_Combo_Description
      .string "L+DPad adjusts percent | DPadDown moves CPU
DPad right/left saves and loads positions."
    .endm

    .macro Event_Combo_Tutorial
      .string "TvCombo"
    .endm

    .macro Event_Combo_ChooseCPU
      .byte Event_Combo
    .endm

    .macro Event_Combo_PreloadData
    .endm

    .macro Event_Combo_LoadSSS
      .byte Event_Combo
    .endm

    .macro Event_Combo_PlayableCharacters
    .endm

    .macro Event_Combo_ScoreType
      .byte KO
    .endm

#endregion
#region AttackOnShield
  .set Event_AttackOnShield,3
  #Event Name
    .macro Event_AttackOnShield_Name
      .string "Attack On Shield"
    .endm

    .macro Event_AttackOnShield_Description
      .string "Practice attacks on a shielding opponent!
Pause to change their OoS option."
    .endm

    .macro Event_AttackOnShield_Tutorial
      .string "TvAttOnSh"
    .endm

    .macro Event_AttackOnShield_ChooseCPU
      .byte Event_AttackOnShield
    .endm

    .macro Event_AttackOnShield_PreloadData
      .byte Event_AttackOnShield,-1,FinalDestination
    .endm

    .macro Event_AttackOnShield_LoadSSS
    .endm

    .macro Event_AttackOnShield_PlayableCharacters
    .endm

    .macro Event_AttackOnShield_ScoreType
      .byte KO
    .endm

#endregion
#region Reversal
  .set Event_Reversal,4
  #Event Name
    .macro Event_Reversal_Name
      .string "Reversal Training"
    .endm

    .macro Event_Reversal_Description
      .string "Practice OoS punishes! DPad left/right
moves characters closer and further apart."
    .endm

    .macro Event_Reversal_Tutorial
      .string "TvRvrsl"
    .endm

    .macro Event_Reversal_ChooseCPU
      .byte Event_Reversal
    .endm

    .macro Event_Reversal_PreloadData
    .endm

    .macro Event_Reversal_LoadSSS
      .byte Event_Reversal
    .endm

    .macro Event_Reversal_PlayableCharacters
    .endm

    .macro Event_Reversal_ScoreType
      .byte KO
    .endm

#endregion
#region SDI
  .set Event_SDI,5
  #Event Name
    .macro Event_SDI_Name
      .string "SDI Training"
    .endm

    .macro Event_SDI_Description
      .string "Practice Smash DI'ing
Fox's up-air!"
    .endm

    .macro Event_SDI_Tutorial
      .string "TvSDI"
    .endm

    .macro Event_SDI_ChooseCPU
    .endm

    .macro Event_SDI_PreloadData
      .byte Event_SDI, Fox.Ext, FinalDestination
    .endm

    .macro Event_SDI_LoadSSS
    .endm

    .macro Event_SDI_PlayableCharacters
    .endm

    .macro Event_SDI_ScoreType
      .byte KO
    .endm

#endregion
#region Powershield
  .set Event_Powershield,6
  #Event Name
    .macro Event_Powershield_Name
      .string "Powershield Training"
    .endm

    .macro Event_Powershield_Description
      .string "Powershield Falco's laser!
Pause to change fire-rate."
    .endm

    .macro Event_Powershield_Tutorial
      .string "TvPowSh"
    .endm

    .macro Event_Powershield_ChooseCPU
    .endm

    .macro Event_Powershield_PreloadData
      .byte Event_Powershield, Falco.Ext, FinalDestination
    .endm

    .macro Event_Powershield_LoadSSS
    .endm

    .macro Event_Powershield_PlayableCharacters
    .endm

    .macro Event_Powershield_ScoreType
      .byte KO
    .endm

#endregion
#region LedgeTech
  .set Event_LedgeTech,7
  #Event Name
    .macro Event_LedgeTech_Name
      .string "Ledge-Tech Training"
    .endm

    .macro Event_LedgeTech_Description
      #Ledge-Tech Training
      .string "Practice ledge-teching
Falco's down-smash!"
    .endm

    .macro Event_LedgeTech_Tutorial
      .string "TvLedTc"
    .endm

    .macro Event_LedgeTech_ChooseCPU
    .endm

    .macro Event_LedgeTech_PreloadData
      .byte Event_LedgeTech, Falco.Ext, -1
    .endm

    .macro Event_LedgeTech_LoadSSS
      .byte Event_LedgeTech
    .endm

    .macro Event_LedgeTech_PlayableCharacters
    .endm

    .macro Event_LedgeTech_ScoreType
      .byte KO
    .endm

#endregion
#region AmsahTech
  .set Event_AmsahTech,8
  #Event Name
    .macro Event_AmsahTech_Name
      .string "Amsah-Tech Training"
    .endm

    .macro Event_AmsahTech_Description
      .string "Taunt to have Marth Up-B,
then ASDI down and tech!"
    .endm

    .macro Event_AmsahTech_Tutorial
      .string "TvAmsTc"
    .endm

    .macro Event_AmsahTech_ChooseCPU
    .endm

    .macro Event_AmsahTech_PreloadData
      .byte Event_AmsahTech, Marth.Ext, -1
    .endm

    .macro Event_AmsahTech_LoadSSS
      .byte Event_AmsahTech
    .endm

    .macro Event_AmsahTech_PlayableCharacters
    .endm

    .macro Event_AmsahTech_ScoreType
      .byte KO
    .endm

#endregion
#region ShieldDrop
  .set Event_ShieldDrop,9
  #Event Name
    .macro Event_ShieldDrop_Name
      .string "Shield Drop Training"
    .endm

    .macro Event_ShieldDrop_Description
      .string "Counter with a shield-drop aerial!
DPad left/right moves players apart."
    .endm

    .macro Event_ShieldDrop_Tutorial
      .string "TvShDrp"
    .endm

    .macro Event_ShieldDrop_ChooseCPU
      .byte Event_ShieldDrop
    .endm

    .macro Event_ShieldDrop_PreloadData
      .byte Event_ShieldDrop, -1, Battlefield
    .endm

    .macro Event_ShieldDrop_LoadSSS
    .endm

    .macro Event_ShieldDrop_PlayableCharacters
    .endm

    .macro Event_ShieldDrop_ScoreType
      .byte KO
    .endm

#endregion
#region WaveshineSDI
  .set Event_WaveshineSDI,10
  #Event Name
    .macro Event_WaveshineSDI_Name
      .string "Waveshine SDI"
    .endm

    .macro Event_WaveshineSDI_Description
      .string "Use Smash DI to get out
of Fox's waveshine!"
    .endm

    .macro Event_WaveshineSDI_Tutorial
      .string "TvWvSDI"
    .endm

    .macro Event_WaveshineSDI_ChooseCPU
    .endm

    .macro Event_WaveshineSDI_PreloadData
      .byte Event_WaveshineSDI, Fox.Ext, FinalDestination
    .endm

    .macro Event_WaveshineSDI_LoadSSS
    .endm

    .macro Event_WaveshineSDI_PlayableCharacters
    .byte Event_WaveshineSDI
    .if PAL==0
      .long Doc_CSSID | Mario_CSSID | Bowser_CSSID | Peach_CSSID | Yoshi_CSSID | DK_CSSID | CaptainFalcon_CSSID | Ganondorf_CSSID | Ness_CSSID | Samus_CSSID | Zelda_CSSID | Link_CSSID | Marth_CSSID
    .endif
    .if PAL==1
      .long Doc_CSSID | Mario_CSSID | Bowser_CSSID | Peach_CSSID | Yoshi_CSSID | DK_CSSID | CaptainFalcon_CSSID | Ganondorf_CSSID | Ness_CSSID | Samus_CSSID | Zelda_CSSID | Link_CSSID
    .endif
    .long -1
    .endm

    .macro Event_WaveshineSDI_ScoreType
      .byte KO
    .endm

#endregion
#region SlideOff
  .set Event_SlideOff,11
  #Event Name
    .macro Event_SlideOff_Name
      .string "Slide-Off Training"
    .endm

    .macro Event_SlideOff_Description
      .string "Use Slide-Off DI to slide off
the platform and counter attack!"
    .endm

    .macro Event_SlideOff_Tutorial
      .string "TvSlOff"
    .endm

    .macro Event_SlideOff_ChooseCPU
    .endm

    .macro Event_SlideOff_PreloadData
      .byte Event_SlideOff, Marth.Ext, PokemonStadium
    .endm

    .macro Event_SlideOff_LoadSSS
    .endm

    .macro Event_SlideOff_PlayableCharacters
    .endm

    .macro Event_SlideOff_ScoreType
    .endm

    .set EventOSD_SlideOff,0x00000000

#endregion
#region GrabMashOut
  .set Event_GrabMashOut,12
  #Event Name
    .macro Event_GrabMashOut_Name
      .string "Grab Mash Training"
    .endm

    .macro Event_GrabMashOut_Description
      .string "Mash buttons to escape the grab
as quickly as possible!"
    .endm

    .macro Event_GrabMashOut_Tutorial
      .string "TvGrabMash"
    .endm

    .macro Event_GrabMashOut_ChooseCPU
    .endm

    .macro Event_GrabMashOut_PreloadData
      .byte Event_GrabMashOut, Marth.Ext, FinalDestination
    .endm

    .macro Event_GrabMashOut_LoadSSS
    .endm

    .macro Event_GrabMashOut_PlayableCharacters
    .endm

    .macro Event_GrabMashOut_ScoreType
      .byte KO
    .endm

    .set EventOSD_GrabMashOut,0x01000000

#endregion

#endregion
#region Spacie Tech Page Data
#Number of Events
  .set SpacieTech.NumOfEvents,4 -1

#Event List
#region LedgetechCounter
  .set Event_LedgetechCounter,0
  #Event Name
    .macro Event_LedgetechCounter_Name
      .string "Ledgetech Marth Counter"
    .endm

    .macro Event_LedgetechCounter_Description
      .string "Practice ledge-teching
Marth's counter!"
    .endm

    .macro Event_LedgetechCounter_Tutorial
      .string "TvLdTcCntr"
    .endm

    .macro Event_LedgetechCounter_ChooseCPU
    .endm

    .macro Event_LedgetechCounter_PreloadData
      .byte Event_LedgetechCounter, Marth.Ext, -1
    .endm

    .macro Event_LedgetechCounter_LoadSSS
      .byte Event_LedgetechCounter
    .endm

    .macro Event_LedgetechCounter_PlayableCharacters
      .byte Event_LedgetechCounter
      .long Fox_CSSID | Falco_CSSID      #Player Characters
			.long -1
    .endm

    .macro Event_LedgetechCounter_ScoreType
      .byte KO
    .endm

#endregion
#region ArmadaShine
  .set Event_ArmadaShine,1
  #Event Name
    .macro Event_ArmadaShine_Name
      .string "Armada-Shine Training"
    .endm

    .macro Event_ArmadaShine_Description
      .string "Finish off the enemy Fox
with an Armada-Shine!"
    .endm

    .macro Event_ArmadaShine_Tutorial
      .string "TvArmShine"
    .endm

    .macro Event_ArmadaShine_ChooseCPU
    .endm

    .macro Event_ArmadaShine_PreloadData
      .byte Event_ArmadaShine, Fox.Ext, -1
    .endm

    .macro Event_ArmadaShine_LoadSSS
      .byte Event_ArmadaShine
    .endm

    .macro Event_ArmadaShine_PlayableCharacters
      .byte Event_ArmadaShine
      .long -1  #Fox_CSSID         #Player Characters
			.long -1
    .endm

    .macro Event_ArmadaShine_ScoreType
      .byte KO
    .endm

  .set EventOSD_ArmadaShine,0x00000000

#endregion
#region SideBSweetspot
  .set Event_SideBSweetspot,2
  #Event Name
    .macro Event_SideBSweetspot_Name
      .string "Side-B Sweetspot"
    .endm

    .macro Event_SideBSweetspot_Description
      .string "Use a sweetspot side-B to avoid Marth's
down-tilt and grab the ledge!"
    .endm

    .macro Event_SideBSweetspot_Tutorial
      .string "TvSideBSweet"
    .endm

    .macro Event_SideBSweetspot_ChooseCPU
    .endm

    .macro Event_SideBSweetspot_PreloadData
      .byte Event_SideBSweetspot, Marth.Ext, -1
    .endm

    .macro Event_SideBSweetspot_LoadSSS
      .byte Event_SideBSweetspot
    .endm

    .macro Event_SideBSweetspot_PlayableCharacters
      .byte Event_SideBSweetspot
      .long Fox_CSSID | Falco_CSSID         #Player Characters
			.long -1
    .endm

    .macro Event_SideBSweetspot_ScoreType
      .byte KO
    .endm

#endregion
#region EscapeSheik
  .set Event_EscapeSheik,3
  #Event Name
    .macro Event_EscapeSheik_Name
      .string "Escape Sheik Techchase"
    .endm

    .macro Event_EscapeSheik_Description
      .string "Practice escaping the techchase with a
frame perfect shine or jab SDI!"
    .endm

    .macro Event_EscapeSheik_Tutorial
      .string "TvEscSheik"
    .endm

    .macro Event_EscapeSheik_ChooseCPU
    .endm

    .macro Event_EscapeSheik_PreloadData
      .byte Event_EscapeSheik, Sheik.Ext, FinalDestination
    .endm

    .macro Event_EscapeSheik_LoadSSS
    .endm

    .macro Event_EscapeSheik_PlayableCharacters
      .byte Event_EscapeSheik
      .long Fox_CSSID | Falco_CSSID | CaptainFalcon_CSSID         #Player Characters
			.long -1
    .endm

    .macro Event_EscapeSheik_ScoreType
      .byte KO
    .endm

#endregion

#endregion
##################################

#region Event Table Macros

#region Event Page Order
#This macro will change the order of the pages
#Only thing this macro doesn't affect is Load CSS + Preload CPU + high scores. Must change this manually.
.macro EventJumpTable
	bl	Minigames
  bl  GeneralTech
  bl  SpacieTech
.endm
#endregion
#region EventAmountPerPage
.macro EventAmountPerPage

Minigames:
.long Minigames.NumOfEvents
.align 2
GeneralTech:
.long GeneralTech.NumOfEvents
.align 2
SpacieTech:
.long SpacieTech.NumOfEvents
.align 2

.endm
#endregion

#region EventNameStrings
.macro EventNameStrings
Minigames:
  Event_Eggs_Name
  Event_Multishine_Name
  Event_Reaction_Name
  Event_Ledgestall_Name
.align 2

GeneralTech:
  Event_LCancel_Name
  Event_Ledgedash_Name
  Event_Combo_Name
  Event_AttackOnShield_Name
  Event_Reversal_Name
  Event_SDI_Name
  Event_Powershield_Name
  Event_LedgeTech_Name
  Event_AmsahTech_Name
  Event_ShieldDrop_Name
  Event_WaveshineSDI_Name
  Event_SlideOff_Name
  Event_GrabMashOut_Name
.align 2

#######################

SpacieTech:
#Ledgetech Marth Counter
  Event_LedgetechCounter_Name
#Armada-Shine Practice
  Event_ArmadaShine_Name
  Event_SideBSweetspot_Name
  Event_EscapeSheik_Name
.align 2
.endm
#endregion
#region EventDescriptionStrings
.macro EventDescriptionStrings

################
Minigames:
  Event_Eggs_Description
  Event_Multishine_Description
  Event_Reaction_Description
  Event_Ledgestall_Description
.align 2
################
GeneralTech:
  Event_LCancel_Description
  Event_Ledgedash_Description
  Event_Combo_Description
  Event_AttackOnShield_Description
  Event_Reversal_Description
  Event_SDI_Description
  Event_Powershield_Description
  Event_LedgeTech_Description
  Event_AmsahTech_Description
  Event_ShieldDrop_Description
  Event_WaveshineSDI_Description
  Event_SlideOff_Description
  Event_GrabMashOut_Description
.align 2
#######################
SpacieTech:
#Ledgetech Marths Counter
  Event_LedgetechCounter_Description
#Armada-Shine Practice
  Event_ArmadaShine_Description
  Event_SideBSweetspot_Description
  Event_EscapeSheik_Description
.align 2
########################
.endm
#endregion
#region EventChooseCPU
.macro EventChooseCPU

############################
ChooseCPU_Minigames:
  Event_Eggs_ChooseCPU
  Event_Multishine_ChooseCPU
  Event_Reaction_ChooseCPU
  Event_Ledgestall_ChooseCPU
  .byte -1
.align 2
############################
ChooseCPU_GeneralTech:
  Event_LCancel_ChooseCPU
  Event_Ledgedash_ChooseCPU
  Event_SDI_ChooseCPU
  Event_Reversal_ChooseCPU
  Event_Powershield_ChooseCPU
  Event_ShieldDrop_ChooseCPU
  Event_AttackOnShield_ChooseCPU
  Event_LedgeTech_ChooseCPU
  Event_AmsahTech_ChooseCPU
  Event_Combo_ChooseCPU
  Event_WaveshineSDI_ChooseCPU
  Event_SlideOff_ChooseCPU
  Event_GrabMashOut_ChooseCPU
  .byte -1
.align 2
############################
ChooseCPU_SpacieTech:
  Event_LedgetechCounter_ChooseCPU
  Event_ArmadaShine_ChooseCPU
  Event_SideBSweetspot_ChooseCPU
  Event_EscapeSheik_ChooseCPU
  .byte -1
.align 2
############################

.endm
#endregion
#region EventPreloadData
.macro EventPreloadData

############################
PreloadEvents_Minigames:
  Event_Eggs_PreloadData
  Event_Multishine_PreloadData
  Event_Reaction_PreloadData
  Event_Ledgestall_PreloadData
  .byte -1
.align 2
############################
PreloadEvents_GeneralTech:
  Event_LCancel_PreloadData
  Event_Ledgedash_PreloadData
  Event_SDI_PreloadData
  Event_Reversal_PreloadData
  Event_Powershield_PreloadData
  Event_ShieldDrop_PreloadData
  Event_AttackOnShield_PreloadData
  Event_LedgeTech_PreloadData
  Event_AmsahTech_PreloadData
  Event_Combo_PreloadData
  Event_WaveshineSDI_PreloadData
  Event_SlideOff_PreloadData
  Event_GrabMashOut_PreloadData
  .byte -1
.align 2
############################
PreloadEvents_SpacieTech:
  Event_LedgetechCounter_PreloadData
  Event_ArmadaShine_PreloadData
  Event_SideBSweetspot_PreloadData
  Event_EscapeSheik_PreloadData
  .byte -1
.align 2
############################

.endm
#endregion
#region EventLoadSSS
.macro EventLoadSSS

############################
Minigames:
  Event_Eggs_LoadSSS
  Event_Multishine_LoadSSS
  Event_Reaction_LoadSSS
  Event_Ledgestall_LoadSSS
  .byte -1
.align 2
############################
GeneralTech:
  Event_LCancel_LoadSSS
  Event_Ledgedash_LoadSSS
  Event_SDI_LoadSSS
  Event_Reversal_LoadSSS
  Event_Powershield_LoadSSS
  Event_ShieldDrop_LoadSSS
  Event_AttackOnShield_LoadSSS
  Event_LedgeTech_LoadSSS
  Event_AmsahTech_LoadSSS
  Event_Combo_LoadSSS
  Event_WaveshineSDI_LoadSSS
  Event_SlideOff_LoadSSS
  Event_GrabMashOut_LoadSSS
  .byte -1
.align 2
############################
SpacieTech:
  Event_LedgetechCounter_LoadSSS
  Event_ArmadaShine_LoadSSS
  Event_SideBSweetspot_LoadSSS
  Event_EscapeSheik_LoadSSS
  .byte -1
.align 2
############################

.endm
#endregion
#region EventPlayableCharacters
.macro EventPlayableCharacters

############################
Minigames:
  Event_Eggs_PlayableCharacters
  Event_Multishine_PlayableCharacters
  Event_Reaction_PlayableCharacters
  Event_Ledgestall_PlayableCharacters
  .byte -1
.align 2
############################
GeneralTech:
  Event_LCancel_PlayableCharacters
  Event_Ledgedash_PlayableCharacters
  Event_SDI_PlayableCharacters
  Event_Reversal_PlayableCharacters
  Event_Powershield_PlayableCharacters
  Event_ShieldDrop_PlayableCharacters
  Event_AttackOnShield_PlayableCharacters
  Event_LedgeTech_PlayableCharacters
  Event_AmsahTech_PlayableCharacters
  Event_Combo_PlayableCharacters
  Event_WaveshineSDI_PlayableCharacters
  Event_SlideOff_PlayableCharacters
  Event_GrabMashOut_PlayableCharacters
  .byte -1
.align 2
############################
SpacieTech:
  Event_LedgetechCounter_PlayableCharacters
  Event_ArmadaShine_PlayableCharacters
  Event_SideBSweetspot_PlayableCharacters
  Event_EscapeSheik_PlayableCharacters
  .byte -1
.align 2
############################

.endm
#endregion
#region EventHighScores
.macro EventHighScores

EventHighScores:
blrl
.byte 0
.byte Minigames.NumOfEvents +1
.byte Minigames.NumOfEvents + GeneralTech.NumOfEvents +1
.align 2

.endm
#endregion
#region EventTutorials

.macro EventTutorials

Minigames:
Event_Eggs_Tutorial
Event_Multishine_Tutorial
Event_Reaction_Tutorial
Event_Ledgestall_Tutorial
.align 2

GeneralTech:
Event_LCancel_Tutorial
Event_Ledgedash_Tutorial
Event_Combo_Tutorial
Event_AttackOnShield_Tutorial
Event_Reversal_Tutorial
Event_SDI_Tutorial
Event_Powershield_Tutorial
Event_LedgeTech_Tutorial
Event_AmsahTech_Tutorial
Event_ShieldDrop_Tutorial
Event_WaveshineSDI_Tutorial
Event_SlideOff_Tutorial
Event_GrabMashOut_Tutorial
.align 2

SpacieTech:
Event_LedgetechCounter_Tutorial
Event_ArmadaShine_Tutorial
Event_SideBSweetspot_Tutorial
Event_EscapeSheik_Tutorial
.align 2

.endm

#endregion

#endregion

#region OnSaveCreate
.macro OnSaveCreate
#Get trophy data
  lwz	r3, -0x77C0 (r13)
  addi	r3, r3, 7376
#Set trophy count
  li  r4,293
  sth r4,0x0(r3)
#Set individual trophies as unlocked
  addi r3,r3,4
  li  r4,99
  li  r5,0x24f
  branchl r12,memset

InitSettings:
#Set Max OSD on No Memcard
  li	r3,1
  lwz	r4, -0x77C0 (r13)
  stb	r3,0x1F28(r4)
#Set Initial Page Number
  li  r3,0x1
  stb r3,CurrentEventPage(r4)
#Enable Recommended OSDs
  li  r3,0
  stb r3,OSDRecommended(r4)
#Enable UCF by default
  load r3,0x08000000
  stw r3,OSDBitfield(r4)
.endm
#endregion
#region OnBootup
.macro OnBootup
#Set First Boot Flag (used for OSD backup/restore)
  li	r3,0x1
  stb	r3,FirstBootFlag(rtoc)
#Set CPU Info
  li  r3,0x21
  stb r3,EventCPUBackup_CharID(rtoc)   #Set CPU Character ID
.endm
#endregion

#Custom Memcard Data Bitfield
.set OSDBitfield,0x1F24
.set OSDMaxWindows,0x1F28
.set CurrentEventPage,0x1F29
.set OSDRecommended,0x1F2A

#Custom rtoc offsets
.set EventCPUBackup_CharID,-0xDA5     #byte
.set FirstBootFlag,-0xDA4 						#byte
.set CodesetPointer,-0xDA0            #word
.set CodesetLength,-0xD9C            	#word

#OSD IDs
.set OSD.Wavedash,0
.set OSD.LCancel,1
.set OSD.MissedTech,2
.set OSD.ActOoS,3
.set OSD.MeteorCancel,4
.set OSD.Dashback,5
.set OSD.ShieldDrop,6
.set OSD.APM,7
.set OSD.SpacieTech,8
.set OSD.SDI,10
.set OSD.Powershield,9
.set OSD.ShieldPoke,11
.set OSD.HitstunLeft,12
.set OSD.ShieldStun,13
.set OSD.ASFramesLeft,14
.set OSD.Miscellaneous,15
.set OSD.ActOoWait,16
.set OSD.CrouchCancel,17
.set OSD.ActOoJump,18
.set OSD.ActOoJumpSquat,19
.set OSD.Fastfall,20
.set OSD.FrameAdvantage,21
.set OSD.ComboCounter,22
.set OSD_23,23
.set OSD.GrabBreakout,24
.set OSD_25,25
.set OSD.Ledge,26
.set OSD.UCF,27
.set OSD.ActOoHitstun,28
.set OSD.DIDraw,0x800000

#Event OSDs
.set EventOSD_Eggs,0x00000000
.set EventOSD_Multishine,0x00000000
.set EventOSD_Reaction,0x00000000

.set EventOSD_LCancel,0x00000003
.set EventOSD_Ledgedash,0x04000000
.set EventOSD_Eggs,0x00000000
.set EventOSD_SDI,0x10000400
.set EventOSD_Reversal,0x002C0009
.set EventOSD_Powershield,0x00000200
.set EventOSD_ShieldDrop,0x00200048
.set EventOSD_AttackOnShield,0x00210000
.set EventOSD_LedgeTech,0x00000404
.set EventOSD_AmsahTech,0x00000004
.set EventOSD_ComboTraining,0x01010020
.set EventOSD_WaveshineSDI,0x10000400

.set EventOSD_LedgetechCounter,0x00000604
.set EventOSD_EscapeSheik,0x00000400

#####################
## Melee Variables ##
#####################
#Static Memory Locations
.set pdLoadCommonData,0x803bcde0
.set InputStructStart,0x804c21cc
  .set InputStruct_HeldButtons,0x0
  .set InputStruct_HeldButtonsPrevFrame,0x4
  .set InputStruct_InstantButtons,0x8
  .set InputStruct_RapidFireButtons,0xC
  .set InputStruct_InstantReleasedButtons,0x10
  .set InputStruct_RapidFireCounter,0x14
  .set InputStruct_LeftAnalogX,0x18
  .set InputStruct_LeftAnalogY,0x19
  .set InputStruct_RightAnalogX,0x1A
  .set InputStruct_RightAnalogY,0x1B
  .set InputStruct_LeftTrigger,0x1C
  .set InputStruct_RightTrigger,0x1D
  .set InputStruct_LeftAnalogXFloat,0x20
  .set InputStruct_LeftAnalogYFloat,0x24
  .set InputStruct_RightAnalogXFloat,0x28
  .set InputStruct_RightAnalogYFloat,0x2C
  .set InputStruct_IsPlugged,0x41
  .set InputStruct_Length,68
.set HSD_InputStructStart,0x804c1fac
.set PreloadTable,0x80432078
  .set Preload_Stage,0x10
.set CSS_CursorPointers,0x804a0bc0
.set HSD_Pad,0x804c1f78
.set CSS_DoorStructs,0x803f0dfc
  .set  CSSDoor_State,0xB

#r13 Offsets
.set MemcardData,-0x77C0
.set DEBUGLV,-0x6C98
.set CSS_Data,-0x49F0
.set CSS_UnkGObj,-0x49E4
.set CSS_UnkJObj,-0x49E0
.set CSS_PointerToDatNodes,-0x49C8    #these are initialized to at 80266970
.set CSS_MainPlayerPort,-0x49B0
.set CSS_CPUPlayerPort,-0x49AF
.set CSS_StartCountdown,-0x49AE
.set CSS_Unk,-0x49AC
.set CSS_MaxPlayers,-0x49AB
.set CSS_Unk,-0x49AA
.set CSS_SinglePlayerPortNumber,-0x4DE0
.set HPS_Unk,-0x3F44
.set HPS_CurrentSongEntryNum,-0x3F3C
.set HPS_Unk,-0x3F14
.set GObj_CurrentProc,-0x3E68
.set HSDPerf_,0x0
.set Hitbox_DamageLog,-0x5148     #Num of solid hits dealt by the player this check
.set Hitbox_TipLog,-0x5144        #Num of phantom hits dealt by the player this check
.set StageID_External,-0x6CB8
.set Stage_LedgeInfo,-0x51E8
.set Stage_LineInfo,-0x51EC       #ctrl f "stage line counts" in melee notes.txt for detailed info
.set Stage_PositionHazardCount,-0x5128
.set Stage_GrabHazardCount,-0x512C
.set Stage_DamageHazardCount,-0x5130
.set Audio_NextAreaInSSMHeap,-0x5258
.set Audio_UnkConstant,-0x5250
.set Audio_TotalSSMMemory,-0x5268
.set GObj_Lists,-0x3E74

.set TM_FrozenToggle,-0x4F8C
.set TM_GameFrameCounter,-0x49a8

#TM Function
.set TM_tmFunction,-(50*4)         #offset of rtoc where function pointers are kept, probably temp solution
.set TM_EventPages, TM_tmFunction + 0x0
.set TM_GetEventName, TM_EventPages + 0x4
.set TM_GetEventDesc, TM_GetEventName + 0x4
.set TM_GetEventTut, TM_GetEventDesc + 0x4
.set TM_GetPageName, TM_GetEventTut + 0x4
.set TM_GetPageEventNum, TM_GetPageName + 0x4
.set TM_GetTMVersShort, TM_GetPageEventNum + 0x4
.set TM_GetTMVersLong, TM_GetTMVersShort + 0x4
.set TM_GetTMCompile, TM_GetTMVersLong + 0x4
.set TM_GetPageNum, TM_GetTMCompile + 0x4
.set TM_GetIsChooseCPU, TM_GetPageNum + 0x4
.set TM_GetIsSelectStage, TM_GetIsChooseCPU + 0x4
.set TM_GetFighter, TM_GetIsSelectStage + 0x4
.set TM_GetCPUFighter, TM_GetFighter + 0x4
.set TM_GetStage, TM_GetCPUFighter + 0x4
.set TM_GetEventFile, TM_GetStage + 0x4
.set TM_GetCSSFile, TM_GetEventFile + 0x4
.set TM_EventInit, TM_GetCSSFile + 0x4
.set TM_OnSceneChange, TM_EventInit + 0x4 
.set TM_OnBoot, TM_OnSceneChange + 0x4 
.set TM_OnStartMelee, TM_OnBoot + 0x4  
.set TM_OnFileLoad, TM_OnStartMelee + 0x4 
.set TM_MessageDisplay, TM_OnFileLoad + 0x4

#TmDt Data Pointers
.set TM_Data,TM_tmFunction - 0x4

#Scene Struct
.set SceneController,0x80479D30
  .set Scene.CurrentMajor,0x0
  .set Scene.PendingMajor,0x1
  .set Scene.PreviousMajor,0x2
  .set Scene.CurrentMinor,0x3
  .set Scene.PendingMinor,0x4
  .set Scene.PreviousMinor,0x5
#Scene ID's
.set Scene.TitleScreen,0x00
.set Scene.MainMenu,0x01
.set Scene.VSMode,0x02
.set Scene.ClassicMode,0x03
.set Scene.AdventureMode,0x04
.set Scene.AllStarMode,0x05
.set Scene.MainDebugMenu,0x06
.set Scene.SoundTestDebugMenu,0x07
.set Scene.HanyuTestCSS,0x08
.set Scene.HanyuTestSSS,0x09
.set Scene.CameraModeMemcardPrompt,0x0A
.set Scene.TrophyGallery,0x0B
.set Scene.TrophyLottery,0x0C
.set Scene.TrophyCollection,0x0D
.set Scene.DebugDiarantou,0x0E
.set Scene.TargetTest,0x0F
.set Scene.SuperSuddenDeath,0x10
.set Scene.InvisibleMelee,0x11
.set Scene.SloMoMelee,0x12
.set Scene.LightningMelee,0x13
.set Scene.ChallengerApproaching,0x14
.set Scene.ClassicModeEnding,0x15
.set Scene.AdventureModeEnding,0x16
.set Scene.AllStarModeEnding,0x17
.set Scene.OpeningMovie,0x18
.set Scene.VisualSceneDebug,0x19
.set Scene.1PEndingDebug,0x1A
.set Scene.TournamentMode,0x1B
.set Scene.TrainingMode,0x1C
.set Scene.TinyMelee,0x1D
.set Scene.GiantMelee,0x1E
.set Scene.StaminaMode,0x1F
.set Scene.HomeRunContest,0x20
.set Scene.10ManMelee,0x21
.set Scene.100ManMelee,0x22
.set Scene.3MinuteMelee,0x23
.set Scene.15MinuteMelee,0x24
.set Scene.EndlessMelee,0x25
.set Scene.CruelMelee,0x26
.set Scene.ProgressiveScanPrompt,0x27
.set Scene.BootUp,0x28
.set Scene.MemcardPropmt,0x29
.set Scene.FixedCamera,0x2A
.set Scene.EventMode,0x2B
.set Scene.SingleButton,0x2C

####################
## Function Names ##
####################

.set ActionStateChange,0x800693ac
.set OSReport,0x803456a8
.set HSD_Randi,0x80380580
.set HSD_Randf,0x80380528
.set AS_Wait,0x8008a2bc
.set AS_Fall,0x800cc730
.set AS_Catch,0x800d8c54
.set AS_Guard,0x800939b4
.set HSD_MemAlloc,0x8037f1e4
.set HSD_JObjLoadJoint,0x80370e44
.set memcpy,0x800031f4
.set strcpy,0x80325a50
.set ZeroAreaLength,0x8000c160
.set CreateCameraBox,0x80029020
.set FrameSpeedChange,0x8006f190
.set HUD_KOCounter_UpdateKOs,0x802fa2d0
.set Playerblock_StoreTimesR3KilledR4,0x80034fa8
.set Playerblock_LoadTimesR3KilledR4,0x80034f24
.set SFX_PlaySoundAtFullVolume,0x801c53ec
.set SFX_MenuCommonSound,0x80024030
.set AS_Rebirth,0x800d4ff4
.set Stage_GetLeftOfLineCoordinates,0x80053ecc
.set Stage_GetRightOfLineCoordinates,0x80053da4
.set AS_RebirthWait,0x800d5600
.set RebirthPlatform_UpdatePosition,0x800d54a4
.set AS_CliffWait,0x8009a804
.set Air_StoreBool_LoseGroundJump_NoECBfor10Frames,0x8007d5d4
.set DataOffset_ECBBottomUpdateEnable,0x8007d5bc
.set MovePlayerToLedge,0x80081544
.set ApplyIntangibility,0x8007b760
.set ApplyInvincibility,0x8007b7a4
.set GFX_RemoveAll,0x8007db24
.set PlayerBlock_LoadMainCharDataOffset,0x80034110
.set PlayerBlock_SetDamage,0x80034330
.set PlayerBlock_LoadDamage,0x800342b4
.set StageInfo_CameraLimitLeft_Load,0x80224a54
.set StageInfo_CameraLimitRight_Load,0x80224a68
.set StageInfo_CameraLimitTop_Load,0x80224a80
.set StageInfo_CameraLimitBottom_Load,0x80224a98
.set Stage_map_gobj_Load,0x801c2ba4
.set Stage_map_gobj_LoadJObj,0x801c3fa4
.set Stage_Destroy_map_gobj,0x801c4a08
.set EntityItemSpawn,0x80268b18
.set MatchInfo_LoadSeconds,0x8016aeec
.set MatchInfo_LoadSubSeconds,0x8016aefc
.set EventMatch_OnWinCondition,0x801bc4f4
.set Events_GetEventSavedScore,0x8015cf5c
.set Events_SetEventSavedScore,0x8015cf70
.set Textures_DisplayEffectTextures,0x8005fddc
.set AS_GrabOpponent,0x800d9ce8
.set AS_Grabbed,0x800daadc
.set AS_CatchWait,0x800da1d8
.set AS_SquatWait,0x800d62c4
.set AS_Sleep,0x800d4f24
.set SetAsGrounded,0x8007d7fc
.set FrameSpeedChange,0x8006f190
.set EnvironmentCollision_WaitLanding,0x80084280
.set Air_SetAsGrounded,0x8007d6a4
.set CPU_JoystickXAxis_Convert,0x800a17e4
.set CPU_JoystickYAxis_Convert,0x800a1874
.set Joystick_Angle_Retrieve,0x8007d9d4
.set GFX_UpdatePlayerGFX,0x800c0408
.set cos,0x80326240
.set sin,0x803263d4
.set fmod,0x80364340
.set sqrt,0x8000d5bc
.set HSD_Free,0x8037f1b0
.set GObj_Create,0x803901f0
.set GObj_AddUserData,0x80390b68
.set GObj_Destroy,0x80390228
.set GObj_AddProc,0x8038fd54
.set GObj_RemoveProc,0x8038fed4
.set GObj_StorePointerToJObj,0x80390a70
.set GObj_AddGXLink,0x8039069c
.set HSD_JObjSetMtxDirtySub,0x803732e8
.set DevelopMode_FrameAdvanceCheck,0x801a45e8
.set MatchInfo_StockModeCheck,0x8016b094
.set PlayerBlock_LoadStocksLeft,0x80033bd8
.set PlayerBlock_LoadSlotType,0x8003241c
.set Playerblock_LoadStaticBlock,0x80031724
.set Text_CreateTextStruct,0x803a6754
.set Text_InitializeSubtext,0x803a6b98
.set Text_UpdateSubtextSize,0x803a7548
.set Text_UpdateSubtextPosition,0x803a746c
.set Text_UpdateSubtextContents,0x803a70a0
.set Text_ChangeTextColor,0x803a74f0
.set Text_RemoveText,0x803a5cc4
.set strlen,0x80325b04
.set PlayerBlock_LoadExternalCharID,0x80032330
.set PlayerBlock_GotoStaleMoveEntry_0xBC,0x80036244
.set InitializePlayerDataValues,0x80068354
.set Event_GetEventSavedScore,0x8015cf5c
.set Events_CheckIfEventWasPlayedYet,0x8015cefc
.set Events_SetEventAsPlayed,0x8015ceb4
.set Events_StoreEventScore,0x8015cf70
.set Interrupt_AerialJumpGoTo,0x800cb870
.set PlayerBlock_UpdateXYCoords,0x80032828
.set Raycast_GroundLine,0x8004f008
.set Camera_UpdatePlayerCameraBoxPosition,0x800761c8
.set Camera_CorrectPosition,0x8002f3ac
.set ItemCollision_Egg,0x802895a8
.set SFX_StopAllCharacterSFX,0x80088a50
.set SFXManager_StopSFXIfPlaying,0x80321ce8
.set memset,0x80003100
.set Ragdoll_WindDecayThink,0x800115f4
.set Inputs_GetPlayerHeldInputs,0x801a3680
.set Inputs_GetPlayerInstantInputs,0x801a36a0
.set Inputs_GetPlayerRapidInputs,0x801a36c0
.set DevelopText_CreateDataTable,0x80302834
.set DevelopText_Activate,0x80302810
.set DevelopText_AddString,0x80302be4
.set DevelopText_EraseAllText,0x80302bb0
.set DevelopMode_Text_ResetCursorXY,0x80302a3c
.set DevelopText_StoreBGColor,0x80302b90
.set DevelopText_HideBG,0x80302ae0
.set DevelopText_ShowBG,0x80302ad0
.set cvt_sll_flt,0x80322da0
.set cvt_fp2unsigned,0x803228c0
.set sprintf,0x80323cf4
.set PlayerBlock_LoadNameTagSlot,0x8003556c
.set Nametag_LoadNametagSlotText,0x8023754c
.set LoadRulesSettingsPointer1,0x8015cc34
.set CSS_UpdateCSPInfo,0x8025db34
.set Rumble_StoreRumbleFlag,0x8015ed4c

#Custom Functions
.set TextCreateFunction,0x80005928
.set GetCustomEventPageName,0x8000552c
.set SearchStringTable,0x80005530
.set GetNumOfEventsOnCurrentPage,0x80005534
.set GetEventTutorialFileName,0x80005538
.set prim.new,0x804DD84C
.set prim.close,0x804DD848

#Character External IDs
.set CaptainFalcon.Ext,0x0
.set DK.Ext,0x1
.set Fox.Ext,0x2
.set GaW.Ext,0x3
.set Kirby.Ext,0x4
.set Bowser.Ext,0x5
.set Link.Ext,0x6
.set Luigi.Ext,0x7
.set Mario.Ext,0x8
.set Marth.Ext,0x9
.set Mewtwo.Ext,0xA
.set Ness.Ext,0xB
.set Peach.Ext,0xC
.set Pikachu.Ext,0xD
.set IceClimbers.Ext,0xE
.set Jigglypuff.Ext,0xF
.set Samus.Ext,0x10
.set Yoshi.Ext,0x11
.set Zelda.Ext,0x12
.set Sheik.Ext,0x13
.set Falco.Ext,0x14
.set YLink.Ext,0x15
.set Doc.Ext,0x16
.set Roy.Ext,0x17
.set Pichu.Ext,0x18
.set Ganondorf.Ext,0x19

#Character Internal IDs
.set Mario.Int,0x0
.set Fox.Int,0x1
.set CaptainFalcon.Int,0x2
.set DK.Int,0x3
.set Kirby.Int,0x4
.set Bowser.Int,0x5
.set Link.Int,0x6
.set Sheik.Int,0x7
.set Ness.Int,0x8
.set Peach.Int,0x9
.set Popo.Int,0xA
.set Nana.Int,0xB
.set Pikachu.Int,0xC
.set Samus.Int,0xD
.set Yoshi.Int,0xE
.set Jigglypuff.Int,0xF
.set Mewtwo.Int,0x10
.set Luigi.Int,0x11
.set Marth.Int,0x12
.set Zelda.Int,0x13
.set YLink.Int,0x14
.set Doc.Int,0x15
.set Falco.Int,0x16
.set Pichu.Int,0x17
.set GaW.Int,0x18
.set Ganondorf.Int,0x19
.set Roy.Int,0x1A

/*
#Character CSS ID
.set Doc_CSSID,0x0
.set Mario_CSSID,0x1
.set Luigi_CSSID,0x2
.set Bowser_CSSID,0x3
.set Peach_CSSID,0x4
.set Yoshi_CSSID,0x5
.set DK_CSSID,0x6
.set CaptainFalcon_CSSID,0x7
.set Ganondorf_CSSID,0x8
.set Falco_CSSID,0x9
.set Fox_CSSID,0xA
.set Ness_CSSID,0xB
.set IceClimbers_CSSID,0xC
.set Kirby_CSSID,0xD
.set Samus_CSSID,0xE
.set Zelda_CSSID,0xF
.set Link_CSSID,0x10
.set YLink_CSSID,0x11
.set Pichu_CSSID,0x12
.set Pikachu_CSSID,0x13
.set Jigglypuff_CSSID,0x14
.set Mewtwo_CSSID,0x15
.set GaW_CSSID,0x16
.set Marth_CSSID,0x17
.set Roy_CSSID,0x18
*/

#Character CSS Bitflag IDs
#(used for TM's lookup tables for displaying CSS icons)
.set Doc_CSSID,0x1
.set Mario_CSSID,0x2
.set Luigi_CSSID,0x4
.set Bowser_CSSID,0x8
.set Peach_CSSID,0x10
.set Yoshi_CSSID,0x20
.set DK_CSSID,0x40
.set CaptainFalcon_CSSID,0x80
.set Ganondorf_CSSID,0x100
.set Falco_CSSID,0x200
.set Fox_CSSID,0x400
.set Ness_CSSID,0x800
.set IceClimbers_CSSID,0x1000
.set Kirby_CSSID,0x2000
.set Samus_CSSID,0x4000
.set Zelda_CSSID,0x8000
.set Link_CSSID,0x10000
.set YLink_CSSID,0x20000
.set Pichu_CSSID,0x40000
.set Pikachu_CSSID,0x80000
.set Jigglypuff_CSSID,0x100000
.set Mewtwo_CSSID,0x200000
.set GaW_CSSID,0x400000
.set Marth_CSSID,0x800000
.set Roy_CSSID,0x1000000

#Stage External IDs
.set FoD,0x2
.set PokemonStadium,0x3
.set PeachsCastle,0x4
.set KongoJungle,0x5
.set Brinstar,0x6
.set Corneria,0x7
.set YoshiStory,0x8
.set Onett,0x9
.set MuteCity,0xA
.set RainbowCruise,0xB
.set JungleJapes,0xC
.set GreatBay,0xD
.set HyruleTemple,0xE
.set BrinstarDepths,0xF
.set YoshiIsland,0x10
.set GreenGreens,0x11
.set Fourside,0x12
.set MushroomKingdomI,0x13
.set MushroomKingdomII,0x14
.set Akaneia,0x15
.set Venom,0x16
.set PokeFloats,0x17
.set BigBlue,0x18
.set IcicleMountain,0x19
.set IceTop,0x1A
.set FlatZone,0x1B
.set DreamLand,0x1C
.set YoshiIsland64,0x1D
.set KongoJungle64,0x1E
.set Battlefield,0x1F
.set FinalDestination,0x20

#Button Definitions
.set PAD_BUTTON_LEFT,0x40000
.set PAD_BUTTON_RIGHT,0x80000
.set PAD_BUTTON_DOWN,0x20000
.set PAD_BUTTON_UP,0x10000
.set PAD_BUTTON_DPAD_LEFT,0x0001
.set PAD_BUTTON_DPAD_RIGHT,0x0002
.set PAD_BUTTON_DPAD_DOWN,0x0004
.set PAD_BUTTON_DPAD_UP,0x0008
.set PAD_TRIGGER_Z,0x0010
.set PAD_TRIGGER_R,0x0020
.set PAD_TRIGGER_L,0x0040
.set PAD_BUTTON_A,0x0100
.set PAD_BUTTON_B,0x0200
.set PAD_BUTTON_X,0x0400
.set PAD_BUTTON_Y,0x0800
.set PAD_BUTTON_START,0x1000

#SFX Definitions
.set SFX_cs_cancel,0xac
.set SFX_cs_decide,0xad
.set SFX_cs_mv,0xae
.set SFX_cs_beep1,0xaf

#########################
## Playerblock Offsets ##
#########################

#Misc
  .set ControllerPort,0x618
  .set CostumeID,0x619
#Input Data
  .set HeldButtons,0x65C
  .set InstantButtons,0x668
  .set AnalogX,0x620
  .set AnalogY,0x624
#Animation Data
  .set CurrentFrame,0x894
#CPU AI Data
  .set CPU_HeldButtons,0x1A88
  .set CPU_AnalogX,0x1A8C
  .set CPU_AnalogY,0x1A8D
  .set CPU_CStickX,0x1A8E
  .set CPU_CStickY,0x1A8F
  .set CPU_LAnalog,0x1A90
  .set CPU_RAnalog,0x1A91

#############################
## Player Action State IDs ##
#############################
.set ASID_DeadDown, 0x00
.set ASID_DeadLeft, 0x01
.set ASID_DeadRight, 0x02
.set ASID_DeadUp, 0x03
.set ASID_DeadUpStar, 0x04
.set ASID_DeadUpStarIce, 0x05
.set ASID_DeadUpFall, 0x06
.set ASID_DeadUpFallHitCamera, 0x07
.set ASID_DeadUpFallHitCameraFlat, 0x08
.set ASID_DeadUpFallIce, 0x09
.set ASID_DeadUpFallHitCameraIce, 0x0A
.set ASID_Sleep, 0x0B
.set ASID_Rebirth, 0x0C
.set ASID_RebirthWait, 0x0D
.set ASID_Wait, 0x0E
.set ASID_WalkSlow, 0x0F
.set ASID_WalkMiddle, 0x10
.set ASID_WalkFast, 0x11
.set ASID_Turn, 0x12
.set ASID_TurnRun, 0x13
.set ASID_Dash, 0x14
.set ASID_Run, 0x15
.set ASID_RunDirect, 0x16
.set ASID_RunBrake, 0x17
.set ASID_KneeBend, 0x18
.set ASID_JumpF, 0x19
.set ASID_JumpB, 0x1A
.set ASID_JumpAerialF, 0x1B
.set ASID_JumpAerialB, 0x1C
.set ASID_Fall, 0x1D
.set ASID_FallF, 0x1E
.set ASID_FallB, 0x1F
.set ASID_FallAerial, 0x20
.set ASID_FallAerialF, 0x21
.set ASID_FallAerialB, 0x22
.set ASID_FallSpecial, 0x23
.set ASID_FallSpecialF, 0x24
.set ASID_FallSpecialB, 0x25
.set ASID_DamageFall, 0x26
.set ASID_Squat, 0x27
.set ASID_SquatWait, 0x28
.set ASID_SquatRv, 0x29
.set ASID_Landing, 0x2A
.set ASID_LandingFallSpecial, 0x2B
.set ASID_Attack11, 0x2C
.set ASID_Attack12, 0x2D
.set ASID_Attack13, 0x2E
.set ASID_Attack100Start, 0x2F
.set ASID_Attack100Loop, 0x30
.set ASID_Attack100End, 0x31
.set ASID_AttackDash, 0x32
.set ASID_AttackS3Hi, 0x33
.set ASID_AttackS3HiS, 0x34
.set ASID_AttackS3S, 0x35
.set ASID_AttackS3LwS, 0x36
.set ASID_AttackS3Lw, 0x37
.set ASID_AttackHi3, 0x38
.set ASID_AttackLw3, 0x39
.set ASID_AttackS4Hi, 0x3A
.set ASID_AttackS4HiS, 0x3B
.set ASID_AttackS4S, 0x3C
.set ASID_AttackS4LwS, 0x3D
.set ASID_AttackS4Lw, 0x3E
.set ASID_AttackHi4, 0x3F
.set ASID_AttackLw4, 0x40
.set ASID_AttackAirN, 0x41
.set ASID_AttackAirF, 0x42
.set ASID_AttackAirB, 0x43
.set ASID_AttackAirHi, 0x44
.set ASID_AttackAirLw, 0x45
.set ASID_LandingAirN, 0x46
.set ASID_LandingAirF, 0x47
.set ASID_LandingAirB, 0x48
.set ASID_LandingAirHi, 0x49
.set ASID_LandingAirLw, 0x4A
.set ASID_DamageHi1, 0x4B
.set ASID_DamageHi2, 0x4C
.set ASID_DamageHi3, 0x4D
.set ASID_DamageN1, 0x4E
.set ASID_DamageN2, 0x4F
.set ASID_DamageN3, 0x50
.set ASID_DamageLw1, 0x51
.set ASID_DamageLw2, 0x52
.set ASID_DamageLw3, 0x53
.set ASID_DamageAir1, 0x54
.set ASID_DamageAir2, 0x55
.set ASID_DamageAir3, 0x56
.set ASID_DamageFlyHi, 0x57
.set ASID_DamageFlyN, 0x58
.set ASID_DamageFlyLw, 0x59
.set ASID_DamageFlyTop, 0x5A
.set ASID_DamageFlyRoll, 0x5B
.set ASID_LightGet, 0x5C
.set ASID_HeavyGet, 0x5D
.set ASID_LightThrowF, 0x5E
.set ASID_LightThrowB, 0x5F
.set ASID_LightThrowHi, 0x60
.set ASID_LightThrowLw, 0x61
.set ASID_LightThrowDash, 0x62
.set ASID_LightThrowDrop, 0x63
.set ASID_LightThrowAirF, 0x64
.set ASID_LightThrowAirB, 0x65
.set ASID_LightThrowAirHi, 0x66
.set ASID_LightThrowAirLw, 0x67
.set ASID_HeavyThrowF, 0x68
.set ASID_HeavyThrowB, 0x69
.set ASID_HeavyThrowHi, 0x6A
.set ASID_HeavyThrowLw, 0x6B
.set ASID_LightThrowF4, 0x6C
.set ASID_LightThrowB4, 0x6D
.set ASID_LightThrowHi4, 0x6E
.set ASID_LightThrowLw4, 0x6F
.set ASID_LightThrowAirF4, 0x70
.set ASID_LightThrowAirB4, 0x71
.set ASID_LightThrowAirHi4, 0x72
.set ASID_LightThrowAirLw4, 0x73
.set ASID_HeavyThrowF4, 0x74
.set ASID_HeavyThrowB4, 0x75
.set ASID_HeavyThrowHi4, 0x76
.set ASID_HeavyThrowLw4, 0x77
.set ASID_SwordSwing1, 0x78
.set ASID_SwordSwing3, 0x79
.set ASID_SwordSwing4, 0x7A
.set ASID_SwordSwingDash, 0x7B
.set ASID_BatSwing1, 0x7C
.set ASID_BatSwing3, 0x7D
.set ASID_BatSwing4, 0x7E
.set ASID_BatSwingDash, 0x7F
.set ASID_ParasolSwing1, 0x80
.set ASID_ParasolSwing3, 0x81
.set ASID_ParasolSwing4, 0x82
.set ASID_ParasolSwingDash, 0x83
.set ASID_HarisenSwing1, 0x84
.set ASID_HarisenSwing3, 0x85
.set ASID_HarisenSwing4, 0x86
.set ASID_HarisenSwingDash, 0x87
.set ASID_StarRodSwing1, 0x88
.set ASID_StarRodSwing3, 0x89
.set ASID_StarRodSwing4, 0x8A
.set ASID_StarRodSwingDash, 0x8B
.set ASID_LipStickSwing1, 0x8C
.set ASID_LipStickSwing3, 0x8D
.set ASID_LipStickSwing4, 0x8E
.set ASID_LipStickSwingDash, 0x8F
.set ASID_ItemParasolOpen, 0x90
.set ASID_ItemParasolFall, 0x91
.set ASID_ItemParasolFallSpecial, 0x92
.set ASID_ItemParasolDamageFall, 0x93
.set ASID_LGunShoot, 0x94
.set ASID_LGunShootAir, 0x95
.set ASID_LGunShootEmpty, 0x96
.set ASID_LGunShootAirEmpty, 0x97
.set ASID_FireFlowerShoot, 0x98
.set ASID_FireFlowerShootAir, 0x99
.set ASID_ItemScrew, 0x9A
.set ASID_ItemScrewAir, 0x9B
.set ASID_DamageScrew, 0x9C
.set ASID_DamageScrewAir, 0x9D
.set ASID_ItemScopeStart, 0x9E
.set ASID_ItemScopeRapid, 0x9F
.set ASID_ItemScopeFire, 0xA0
.set ASID_ItemScopeEnd, 0xA1
.set ASID_ItemScopeAirStart, 0xA2
.set ASID_ItemScopeAirRapid, 0xA3
.set ASID_ItemScopeAirFire, 0xA4
.set ASID_ItemScopeAirEnd, 0xA5
.set ASID_ItemScopeStartEmpty, 0xA6
.set ASID_ItemScopeRapidEmpty, 0xA7
.set ASID_ItemScopeFireEmpty, 0xA8
.set ASID_ItemScopeEndEmpty, 0xA9
.set ASID_ItemScopeAirStartEmpty, 0xAA
.set ASID_ItemScopeAirRapidEmpty, 0xAB
.set ASID_ItemScopeAirFireEmpty, 0xAC
.set ASID_ItemScopeAirEndEmpty, 0xAD
.set ASID_LiftWait, 0xAE
.set ASID_LiftWalk1, 0xAF
.set ASID_LiftWalk2, 0xB0
.set ASID_LiftTurn, 0xB1
.set ASID_GuardOn, 0xB2
.set ASID_Guard, 0xB3
.set ASID_GuardOff, 0xB4
.set ASID_GuardSetOff, 0xB5
.set ASID_GuardReflect, 0xB6
.set ASID_DownBoundU, 0xB7
.set ASID_DownWaitU, 0xB8
.set ASID_DownDamageU, 0xB9
.set ASID_DownStandU, 0xBA
.set ASID_DownAttackU, 0xBB
.set ASID_DownFowardU, 0xBC
.set ASID_DownBackU, 0xBD
.set ASID_DownSpotU, 0xBE
.set ASID_DownBoundD, 0xBF
.set ASID_DownWaitD, 0xC0
.set ASID_DownDamageD, 0xC1
.set ASID_DownStandD, 0xC2
.set ASID_DownAttackD, 0xC3
.set ASID_DownFowardD, 0xC4
.set ASID_DownBackD, 0xC5
.set ASID_DownSpotD, 0xC6
.set ASID_Passive, 0xC7
.set ASID_PassiveStandF, 0xC8
.set ASID_PassiveStandB, 0xC9
.set ASID_PassiveWall, 0xCA
.set ASID_PassiveWallJump, 0xCB
.set ASID_PassiveCeil, 0xCC
.set ASID_ShieldBreakFly, 0xCD
.set ASID_ShieldBreakFall, 0xCE
.set ASID_ShieldBreakDownU, 0xCF
.set ASID_ShieldBreakDownD, 0xD0
.set ASID_ShieldBreakStandU, 0xD1
.set ASID_ShieldBreakStandD, 0xD2
.set ASID_FuraFura, 0xD3
.set ASID_Catch, 0xD4
.set ASID_CatchPull, 0xD5
.set ASID_CatchDash, 0xD6
.set ASID_CatchDashPull, 0xD7
.set ASID_CatchWait, 0xD8
.set ASID_CatchAttack, 0xD9
.set ASID_CatchCut, 0xDA
.set ASID_ThrowF, 0xDB
.set ASID_ThrowB, 0xDC
.set ASID_ThrowHi, 0xDD
.set ASID_ThrowLw, 0xDE
.set ASID_CapturePulledHi, 0xDF
.set ASID_CaptureWaitHi, 0xE0
.set ASID_CaptureDamageHi, 0xE1
.set ASID_CapturePulledLw, 0xE2
.set ASID_CaptureWaitLw, 0xE3
.set ASID_CaptureDamageLw, 0xE4
.set ASID_CaptureCut, 0xE5
.set ASID_CaptureJump, 0xE6
.set ASID_CaptureNeck, 0xE7
.set ASID_CaptureFoot, 0xE8
.set ASID_EscapeF, 0xE9
.set ASID_EscapeB, 0xEA
.set ASID_Escape, 0xEB
.set ASID_EscapeAir, 0xEC
.set ASID_ReboundStop, 0xED
.set ASID_Rebound, 0xEE
.set ASID_ThrownF, 0xEF
.set ASID_ThrownB, 0xF0
.set ASID_ThrownHi, 0xF1
.set ASID_ThrownLw, 0xF2
.set ASID_ThrownLwWomen, 0xF3
.set ASID_Pass, 0xF4
.set ASID_Ottotto, 0xF5
.set ASID_OttottoWait, 0xF6
.set ASID_FlyReflectWall, 0xF7
.set ASID_FlyReflectCeil, 0xF8
.set ASID_StopWall, 0xF9
.set ASID_StopCeil, 0xFA
.set ASID_MissFoot, 0xFB
.set ASID_CliffCatch, 0xFC
.set ASID_CliffWait, 0xFD
.set ASID_CliffClimbSlow, 0xFE
.set ASID_CliffClimbQuick, 0xFF
.set ASID_CliffAttackSlow, 0x100
.set ASID_CliffAttackQuick, 0x101
.set ASID_CliffEscapeSlow, 0x102
.set ASID_CliffEscapeQuick, 0x103
.set ASID_CliffJumpSlow1, 0x104
.set ASID_CliffJumpSlow2, 0x105
.set ASID_CliffJumpQuick1, 0x106
.set ASID_CliffJumpQuick2, 0x107
.set ASID_AppealR, 0x108
.set ASID_AppealL, 0x109
.set ASID_ShoulderedWait, 0x10A
.set ASID_ShoulderedWalkSlow, 0x10B
.set ASID_ShoulderedWalkMiddle, 0x10C
.set ASID_ShoulderedWalkFast, 0x10D
.set ASID_ShoulderedTurn, 0x10E
.set ASID_ThrownFF, 0x10F
.set ASID_ThrownFB, 0x110
.set ASID_ThrownFHi, 0x111
.set ASID_ThrownFLw, 0x112
.set ASID_CaptureCaptain, 0x113
.set ASID_CaptureYoshi, 0x114
.set ASID_YoshiEgg, 0x115
.set ASID_CaptureKoopa, 0x116
.set ASID_CaptureDamageKoopa, 0x117
.set ASID_CaptureWaitKoopa, 0x118
.set ASID_ThrownKoopaF, 0x119
.set ASID_ThrownKoopaB, 0x11A
.set ASID_CaptureKoopaAir, 0x11B
.set ASID_CaptureDamageKoopaAir, 0x11C
.set ASID_CaptureWaitKoopaAir, 0x11D
.set ASID_ThrownKoopaAirF, 0x11E
.set ASID_ThrownKoopaAirB, 0x11F
.set ASID_CaptureKirby, 0x120
.set ASID_CaptureWaitKirby, 0x121
.set ASID_ThrownKirbyStar, 0x122
.set ASID_ThrownCopyStar, 0x123
.set ASID_ThrownKirby, 0x124
.set ASID_BarrelWait, 0x125
.set ASID_Bury, 0x126
.set ASID_BuryWait, 0x127
.set ASID_BuryJump, 0x128
.set ASID_DamageSong, 0x129
.set ASID_DamageSongWait, 0x12A
.set ASID_DamageSongRv, 0x12B
.set ASID_DamageBind, 0x12C
.set ASID_CaptureMewtwo, 0x12D
.set ASID_CaptureMewtwoAir, 0x12E
.set ASID_ThrownMewtwo, 0x12F
.set ASID_ThrownMewtwoAir, 0x130
.set ASID_WarpStarJump, 0x131
.set ASID_WarpStarFall, 0x132
.set ASID_HammerWait, 0x133
.set ASID_HammerWalk, 0x134
.set ASID_HammerTurn, 0x135
.set ASID_HammerKneeBend, 0x136
.set ASID_HammerFall, 0x137
.set ASID_HammerJump, 0x138
.set ASID_HammerLanding, 0x139
.set ASID_KinokoGiantStart, 0x13A
.set ASID_KinokoGiantStartAir, 0x13B
.set ASID_KinokoGiantEnd, 0x13C
.set ASID_KinokoGiantEndAir, 0x13D
.set ASID_KinokoSmallStart, 0x13E
.set ASID_KinokoSmallStartAir, 0x13F
.set ASID_KinokoSmallEnd, 0x140
.set ASID_KinokoSmallEndAir, 0x141
.set ASID_Entry, 0x142
.set ASID_EntryStart, 0x143
.set ASID_EntryEnd, 0x144
.set ASID_DamageIce, 0x145
.set ASID_DamageIceJump, 0x146
.set ASID_CaptureMasterhand, 0x147
.set ASID_CapturedamageMasterhand, 0x148
.set ASID_CapturewaitMasterhand, 0x149
.set ASID_ThrownMasterhand, 0x14A
.set ASID_CaptureKirbyYoshi, 0x14B
.set ASID_KirbyYoshiEgg, 0x14C
.set ASID_CaptureLeadead, 0x14D
.set ASID_CaptureLikelike, 0x14E
.set ASID_DownReflect, 0x14F
.set ASID_CaptureCrazyhand, 0x150
.set ASID_CapturedamageCrazyhand, 0x151
.set ASID_CapturewaitCrazyhand, 0x152
.set ASID_ThrownCrazyhand, 0x153
.set ASID_BarrelCannonWait, 0x154


.macro branchl reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctrl
.endm

.macro rtocbl reg, offset
lwz \reg,\offset(rtoc)
mtctr \reg
bctrl
.endm

/*
.macro branchl reg, address
.long \address ^ 0x80<<24 | 0xC8<<24
.endm
*/

.macro branch reg, address
lis \reg, \address @h
ori \reg,\reg,\address @l
mtctr \reg
bctr
.endm

.macro load reg, address
lis \reg, \address @h
ori \reg, \reg, \address @l
.endm

.macro backup
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r20,0x8(r1)
.endm

 .macro restore
lmw  r20,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
.endm

.macro backupall
mflr r0
stw r0, 0x4(r1)
stwu	r1,-0x100(r1)	# make space for 12 registers
stmw  r3,0x8(r1)
.endm

.macro restoreall
lmw  r3,0x8(r1)
lwz r0, 0x104(r1)
addi	r1,r1,0x100	# release the space
mtlr r0
.endm

.set R13_EventVars, -0x4A0C
.set EventVars_MessageDisplay, (8 * 4)

#Message Display
.macro Message_Display
crset 6
rtocbl r12,TM_MessageDisplay
.endm

.set MsgData_Text,0x0

.set MSGCOLOR_WHITE, 0
.set MSGCOLOR_GREEN, 1
.set MSGCOLOR_RED, 2
.set MSGCOLOR_YELLOW, 3
