#include "lab.h"
static char nullString[] = " ";

// CPU Action Definitions
static CPUAction EvFree_CPUActionShield[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_TRIGGER_R,         // button to input
        1,                     // is the last input
        0,                     // specify stick direction
    },
    {
        ASID_GUARDREFLECT, // state to perform this action. -1 for last
        0,                 // first possible frame to perform this action
        0,                 // last possible frame to perfrom this action
        0,                 // left stick X value
        0,                 // left stick Y value
        0,                 // c stick X value
        0,                 // c stick Y value
        PAD_TRIGGER_R,     // button to input
        1,                 // is the last input
        0,                 // specify stick direction
    },
    {
        ASID_GUARD,    // state to perform this action. -1 for last
        0,             // first possible frame to perform this action
        0,             // last possible frame to perfrom this action
        0,             // left stick X value
        0,             // left stick Y value
        0,             // c stick X value
        0,             // c stick Y value
        PAD_TRIGGER_R, // button to input
        1,             // is the last input
        0,             // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionGrab[] = {
    {
        ASID_GUARD,                   // state to perform this action. -1 for last
        0,                            // first possible frame to perform this action
        0,                            // last possible frame to perfrom this action
        0,                            // left stick X value
        0,                            // left stick Y value
        0,                            // c stick X value
        0,                            // c stick Y value
        PAD_BUTTON_A | PAD_TRIGGER_R, // button to input
        1,                            // is the last input
        0,                            // specify stick direction
    },
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_TRIGGER_Z,         // button to input
        1,                     // is the last input
        0,                     // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionUpB[] = {
    {
        ASID_GUARD,                   // state to perform this action. -1 for last
        0,                            // first possible frame to perform this action
        0,                            // last possible frame to perfrom this action
        0,                            // left stick X value
        0,                            // left stick Y value
        0,                            // c stick X value
        0,                            // c stick Y value
        PAD_TRIGGER_R | PAD_BUTTON_X, // button to input
        0,                            // is the last input
        0,                            // specify stick direction
    },
    {
        ASID_GUARD,   // state to perform this action. -1 for last
        0,            // first possible frame to perform this action
        0,            // last possible frame to perfrom this action
        0,            // left stick X value
        0,            // left stick Y value
        0,            // c stick X value
        0,            // c stick Y value
        PAD_BUTTON_X, // button to input
        0,            // is the last input
        0,            // specify stick direction
    },
    {
        ASID_KNEEBEND, // state to perform this action. -1 for last
        0,             // first possible frame to perform this action
        0,             // last possible frame to perfrom this action
        0,             // left stick X value
        127,           // left stick Y value
        0,             // c stick X value
        0,             // c stick Y value
        PAD_BUTTON_B,  // button to input
        1,             // is the last input
        0,             // specify stick direction
    },
    {
        ASID_ACTIONABLE, // state to perform this action. -1 for last
        0,               // first possible frame to perform this action
        0,               // last possible frame to perfrom this action
        0,               // left stick X value
        127,             // left stick Y value
        0,               // c stick X value
        0,               // c stick Y value
        PAD_BUTTON_B,    // button to input
        1,               // is the last input
        0,               // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionDownB[] = {
    {
        ASID_GUARD,                   // state to perform this action. -1 for last
        0,                            // first possible frame to perform this action
        0,                            // last possible frame to perfrom this action
        0,                            // left stick X value
        0,                            // left stick Y value
        0,                            // c stick X value
        0,                            // c stick Y value
        PAD_TRIGGER_R | PAD_BUTTON_X, // button to input
        0,                            // is the last input
        0,                            // specify stick direction
    },
    {
        ASID_GUARD,   // state to perform this action. -1 for last
        0,            // first possible frame to perform this action
        0,            // last possible frame to perfrom this action
        0,            // left stick X value
        0,            // left stick Y value
        0,            // c stick X value
        0,            // c stick Y value
        PAD_BUTTON_X, // button to input
        1,            // is the last input
        0,            // specify stick direction
    },
    {
        ASID_ACTIONABLE, // state to perform this action. -1 for last
        0,               // first possible frame to perform this action
        0,               // last possible frame to perfrom this action
        0,               // left stick X value
        -127,            // left stick Y value
        0,               // c stick X value
        0,               // c stick Y value
        PAD_BUTTON_B,    // button to input
        1,               // is the last input
        0,               // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionSpotdodge[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        -127,                  // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_TRIGGER_R,         // button to input
        1,                     // is the last input
        0,                     // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionRollAway[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_TRIGGER_R,         // button to input
        0,                     // is the last input
        0,                     // specify stick direction
    },
    {
        ASID_GUARDREFLECT, // state to perform this action. -1 for last
        0,                 // first possible frame to perform this action
        0,                 // last possible frame to perfrom this action
        127,               // left stick X value
        0,                 // left stick Y value
        0,                 // c stick X value
        0,                 // c stick Y value
        PAD_TRIGGER_R,     // button to input
        1,                 // is the last input
        2,                 // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionRollTowards[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_TRIGGER_R,         // button to input
        0,                     // is the last input
        0,                     // specify stick direction
    },
    {
        ASID_GUARDREFLECT, // state to perform this action. -1 for last
        0,                 // first possible frame to perform this action
        0,                 // last possible frame to perfrom this action
        127,               // left stick X value
        0,                 // left stick Y value
        0,                 // c stick X value
        0,                 // c stick Y value
        PAD_TRIGGER_R,     // button to input
        1,                 // is the last input
        1,                 // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionNair[] = {
    {
        ASID_GUARD,                   // state to perform this action. -1 for last
        0,                            // first possible frame to perform this action
        0,                            // last possible frame to perfrom this action
        0,                            // left stick X value
        0,                            // left stick Y value
        0,                            // c stick X value
        0,                            // c stick Y value
        PAD_TRIGGER_R | PAD_BUTTON_X, // button to input
        0,                            // is the last input
        0,                            // specify stick direction
    },
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_BUTTON_X,          // button to input
        0,                     // is the last input
        0,                     // specify stick direction
    },
    {
        ASID_ACTIONABLEAIR, // state to perform this action. -1 for last
        0,                  // first possible frame to perform this action
        0,                  // last possible frame to perfrom this action
        0,                  // left stick X value
        0,                  // left stick Y value
        0,                  // c stick X value
        0,                  // c stick Y value
        PAD_BUTTON_A,       // button to input
        1,                  // is the last input
        0,                  // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionFair[] = {
    {
        ASID_GUARD,                   // state to perform this action. -1 for last
        0,                            // first possible frame to perform this action
        0,                            // last possible frame to perfrom this action
        0,                            // left stick X value
        0,                            // left stick Y value
        0,                            // c stick X value
        0,                            // c stick Y value
        PAD_TRIGGER_R | PAD_BUTTON_X, // button to input
        0,                            // is the last input
        0,                            // specify stick direction
    },
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_BUTTON_X,          // button to input
        0,                     // is the last input
        0,                     // specify stick direction
    },
    {
        ASID_ACTIONABLEAIR, // state to perform this action. -1 for last
        0,                  // first possible frame to perform this action
        0,                  // last possible frame to perfrom this action
        0,                  // left stick X value
        0,                  // left stick Y value
        127,                // c stick X value
        0,                  // c stick Y value
        0,                  // button to input
        1,                  // is the last input
        3,                  // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionDair[] = {
    {
        ASID_GUARD,                   // state to perform this action. -1 for last
        0,                            // first possible frame to perform this action
        0,                            // last possible frame to perfrom this action
        0,                            // left stick X value
        0,                            // left stick Y value
        0,                            // c stick X value
        0,                            // c stick Y value
        PAD_TRIGGER_R | PAD_BUTTON_X, // button to input
        0,                            // is the last input
        0,                            // specify stick direction
    },
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_BUTTON_X,          // button to input
        0,                     // is the last input
        0,                     // specify stick direction
    },
    {
        ASID_ACTIONABLEAIR, // state to perform this action. -1 for last
        0,                  // first possible frame to perform this action
        0,                  // last possible frame to perfrom this action
        0,                  // left stick X value
        0,                  // left stick Y value
        0,                  // c stick X value
        -127,               // c stick Y value
        0,                  // button to input
        1,                  // is the last input
        0,                  // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionBair[] = {
    {
        ASID_GUARD,                   // state to perform this action. -1 for last
        0,                            // first possible frame to perform this action
        0,                            // last possible frame to perfrom this action
        0,                            // left stick X value
        0,                            // left stick Y value
        0,                            // c stick X value
        0,                            // c stick Y value
        PAD_TRIGGER_R | PAD_BUTTON_X, // button to input
        0,                            // is the last input
        0,                            // specify stick direction
    },
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_BUTTON_X,          // button to input
        0,                     // is the last input
        0,                     // specify stick direction
    },
    {
        ASID_ACTIONABLEAIR, // state to perform this action. -1 for last
        0,                  // first possible frame to perform this action
        0,                  // last possible frame to perfrom this action
        0,                  // left stick X value
        0,                  // left stick Y value
        127,                // c stick X value
        0,                  // c stick Y value
        0,                  // button to input
        1,                  // is the last input
        4,                  // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionUair[] = {
    {
        ASID_GUARD,                   // state to perform this action. -1 for last
        0,                            // first possible frame to perform this action
        0,                            // last possible frame to perfrom this action
        0,                            // left stick X value
        0,                            // left stick Y value
        0,                            // c stick X value
        0,                            // c stick Y value
        PAD_TRIGGER_R | PAD_BUTTON_X, // button to input
        0,                            // is the last input
        0,                            // specify stick direction
    },
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_BUTTON_X,          // button to input
        0,                     // is the last input
        0,                     // specify stick direction
    },
    {
        ASID_ACTIONABLEAIR, // state to perform this action. -1 for last
        0,                  // first possible frame to perform this action
        0,                  // last possible frame to perfrom this action
        0,                  // left stick X value
        0,                  // left stick Y value
        0,                  // c stick X value
        127,                // c stick Y value
        0,                  // button to input
        1,                  // is the last input
        0,                  // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionJump[] = {
    {
        ASID_GUARD,                   // state to perform this action. -1 for last
        0,                            // first possible frame to perform this action
        0,                            // last possible frame to perfrom this action
        0,                            // left stick X value
        0,                            // left stick Y value
        0,                            // c stick X value
        0,                            // c stick Y value
        PAD_TRIGGER_R | PAD_BUTTON_X, // button to input
        0,                            // is the last input
        0,                            // specify stick direction
    },
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_BUTTON_X,          // button to input
        1,                     // is the last input
        0,                     // specify stick direction
    },
    {
        ASID_ACTIONABLEAIR, // state to perform this action. -1 for last
        0,                  // first possible frame to perform this action
        0,                  // last possible frame to perfrom this action
        0,                  // left stick X value
        0,                  // left stick Y value
        0,                  // c stick X value
        0,                  // c stick Y value
        0,                  // button to input
        1,                  // is the last input
        0,                  // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionJumpAway[] = {
    {
        ASID_ACTIONABLE, // state to perform this action. -1 for last
        0,               // first possible frame to perform this action
        0,               // last possible frame to perfrom this action
        0,               // left stick X value
        0,               // left stick Y value
        0,               // c stick X value
        0,               // c stick Y value
        PAD_BUTTON_X,    // button to input
        0,               // is the last input
        0,               // specify stick direction
    },
    {
        ASID_ACTIONABLEAIR, // state to perform this action. -1 for last
        0,                  // first possible frame to perform this action
        0,                  // last possible frame to perfrom this action
        -127,               // left stick X value
        0,                  // left stick Y value
        0,                  // c stick X value
        0,                  // c stick Y value
        0,                  // button to input
        1,                  // is the last input
        2,                  // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionJumpTowards[] = {
    {
        ASID_ACTIONABLE, // state to perform this action. -1 for last
        0,               // first possible frame to perform this action
        0,               // last possible frame to perfrom this action
        0,               // left stick X value
        0,               // left stick Y value
        0,               // c stick X value
        0,               // c stick Y value
        PAD_BUTTON_X,    // button to input
        0,               // is the last input
        0,               // specify stick direction
    },
    {
        ASID_ACTIONABLEAIR, // state to perform this action. -1 for last
        0,                  // first possible frame to perform this action
        0,                  // last possible frame to perfrom this action
        127,                // left stick X value
        0,                  // left stick Y value
        0,                  // c stick X value
        0,                  // c stick Y value
        0,                  // button to input
        1,                  // is the last input
        1,                  // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionAirdodge[] = {
    {
        ASID_DAMAGEAIR, // state to perform this action. -1 for last
        0,              // first possible frame to perform this action
        0,              // last possible frame to perfrom this action
        127,            // left stick X value
        0,              // left stick Y value
        0,              // c stick X value
        0,              // c stick Y value
        0,              // button to input
        0,              // is the last input
        0,              // specify stick direction
    },
    {
        ASID_ACTIONABLEAIR, // state to perform this action. -1 for last
        0,                  // first possible frame to perform this action
        0,                  // last possible frame to perfrom this action
        0,                  // left stick X value
        0,                  // left stick Y value
        0,                  // c stick X value
        0,                  // c stick Y value
        PAD_TRIGGER_R,      // button to input
        1,                  // is the last input
        0,                  // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionFFTumble[] = {
    {
        ASID_ACTIONABLE, // state to perform this action. -1 for last
        0,               // first possible frame to perform this action
        0,               // last possible frame to perfrom this action
        0,               // left stick X value
        -127,            // left stick Y value
        0,               // c stick X value
        0,               // c stick Y value
        0,               // button to input
        1,               // is the last input
        0,               // specify stick direction
    },
    -1,
};
static CPUAction EvFree_CPUActionFFWiggle[] = {
    {
        ASID_DAMAGEFALL, // state to perform this action. -1 for last
        0,               // first possible frame to perform this action
        0,               // last possible frame to perfrom this action
        127,             // left stick X value
        0,               // left stick Y value
        0,               // c stick X value
        0,               // c stick Y value
        0,               // button to input
        0,               // is the last input
        0,               // specify stick direction
    },
    {
        ASID_ACTIONABLEAIR, // state to perform this action. -1 for last
        0,                  // first possible frame to perform this action
        0,                  // last possible frame to perfrom this action
        0,                  // left stick X value
        -127,               // left stick Y value
        0,                  // c stick X value
        0,                  // c stick Y value
        0,                  // button to input
        1,                  // is the last input
        0,                  // specify stick direction
    },
    -1,
};

static CPUAction *EvFree_CPUActions[] = {
    // none 0
    0,
    // shield 1
    &EvFree_CPUActionShield,
    // grab 2
    &EvFree_CPUActionGrab,
    // up b 3
    &EvFree_CPUActionUpB,
    // down b 4
    &EvFree_CPUActionDownB,
    // spotdodge 5
    &EvFree_CPUActionSpotdodge,
    // roll away 6
    &EvFree_CPUActionRollAway,
    // roll towards 7
    &EvFree_CPUActionRollTowards,
    // nair 8
    &EvFree_CPUActionNair,
    // fair 9
    &EvFree_CPUActionFair,
    // dair 10
    &EvFree_CPUActionDair,
    // bair 11
    &EvFree_CPUActionBair,
    // uair 12
    &EvFree_CPUActionUair,
    // jump 13
    &EvFree_CPUActionJump,
    // jump away 14
    &EvFree_CPUActionJumpAway,
    // jump towards 15
    &EvFree_CPUActionJumpTowards,
    // airdodge 16
    &EvFree_CPUActionAirdodge,
    // fastfall 17
    &EvFree_CPUActionFFTumble,
    // wiggle fastfall 18
    &EvFree_CPUActionFFWiggle,
};
static u8 GrAcLookup[] = {0, 5, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13};
static u8 AirAcLookup[] = {0, 16, 14, 15, 3, 4, 8, 9, 10, 11, 12, 17, 18};
static u8 ShieldAcLookup[] = {0, 2, 13, 5, 3, 4, 8, 9, 10, 11, 12};

// Main Menu
static char **EvFreeOptions_OffOn[] = {"Off", "On"};
static EventOption EvFreeOptions_Main[] = {
    {
        .option_kind = OPTKIND_MENU,                           // the type of option this is; menu, string list, integer list, etc
        .value_num = 0,                                        // number of values for this option
        .option_val = 0,                                       // value of this option
        .menu = &EvFreeMenu_General,                           // pointer to the menu that pressing A opens
        .option_name = {"General"},                            // pointer to a string
        .desc = "Toggle percents, overlays, and information.", // string describing what this option does
        .option_values = 0,                                    // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_MENU,       // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                    // number of values for this option
        .option_val = 0,                   // value of this option
        .menu = &EvFreeMenu_CPU,           // pointer to the menu that pressing A opens
        .option_name = {"CPU Options"},    // pointer to a string
        .desc = "Configure CPU behavior.", // string describing what this option does
        .option_values = 0,                // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_MENU,           // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                        // number of values for this option
        .option_val = 0,                       // value of this option
        .menu = &EvFreeMenu_Record,            // pointer to the menu that pressing A opens
        .option_name = "Recording",            // pointer to a string
        .desc = "Record and playback inputs.", // string describing what this option does
        .option_values = 0,                    // pointer to an array of strings
        .onOptionChange = 0,
    },
    // info display
    {
        .option_kind = OPTKIND_MENU,                          // the type of option this is; menu, string list, integer list, etc
        .value_num = 0,                                       // number of values for this option
        .option_val = 0,                                      // value of this option
        .menu = &EvFreeMenu_InfoDisplay,                      // pointer to the menu that pressing A opens
        .option_name = "Info Display",                        // pointer to a string
        .desc = "Display various game information onscreen.", // string describing what this option does
        .option_values = 0,                                   // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_FUNC,                         // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                                      // number of values for this option
        .option_val = 0,                                     // value of this option
        .menu = 0,                                           // pointer to the menu that pressing A opens
        .option_name = "Help",                               // pointer to a string
        .desc = "Put info here on savestates or something.", // string describing what this option does
        .option_values = 0,                                  // pointer to an array of strings
        .onOptionChange = EvFree_Exit,
    },
    {
        .option_kind = OPTKIND_FUNC,                  // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                               // number of values for this option
        .option_val = 0,                              // value of this option
        .menu = 0,                                    // pointer to the menu that pressing A opens
        .option_name = "Exit",                        // pointer to a string
        .desc = "Return to the Event Select Screen.", // string describing what this option does
        .option_values = 0,                           // pointer to an array of strings
        .onOptionChange = 0,
        .onOptionSelect = EvFree_Exit,
    },
};
static EventMenu EvFreeMenu_Main = {
    .name = "Main Menu",                                            // the name of this menu
    .option_num = sizeof(EvFreeOptions_Main) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                    // runtime variable used for how far down in the menu to start
    .state = 0,                                                     // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                    // index of the option currently selected, used at runtime
    .options = &EvFreeOptions_Main,                                 // pointer to all of this menu's options
    .prev = 0,                                                      // pointer to previous menu, used at runtime
};
// General
static char **EvFreeOptions_CamMode[] = {"Normal", "Zoom", "Fixed", "Advanced"};
static EventOption EvFreeOptions_General[] = {
    // frame advance
    {
        .option_kind = OPTKIND_STRING,                                     // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                                    // number of values for this option
        .option_val = 0,                                                   // value of this option
        .menu = 0,                                                         // pointer to the menu that pressing A opens
        .option_name = "Frame Advance",                                    // pointer to a string
        .desc = "Enable frame advance. Press/hold L to advance \nframes.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,                              // pointer to an array of strings
        .onOptionChange = 0,
    },
    // p1 percent
    {
        .option_kind = OPTKIND_INT,             // the type of option this is; menu, string list, integer list, etc
        .value_num = 999,                       // number of values for this option
        .option_val = 0,                        // value of this option
        .menu = 0,                              // pointer to the menu that pressing A opens
        .option_name = "Player Percent",        // pointer to a string
        .desc = "Adjust the player's percent.", // string describing what this option does
        .option_values = 0,                     // pointer to an array of strings
        .onOptionChange = EvFree_ChangePlayerPercent,
    },
    // model display
    {
        .option_kind = OPTKIND_STRING,                      // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                     // number of values for this option
        .option_val = 1,                                    // value of this option
        .menu = 0,                                          // pointer to the menu that pressing A opens
        .option_name = "Model Display",                     // pointer to a string
        .desc = "Toggle player and item model visibility.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,               // pointer to an array of strings
        .onOptionChange = EvFree_ChangeModelDisplay,
    },
    // fighter collision
    {
        .option_kind = OPTKIND_STRING,                                                                                                                            // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                                                                                                                           // number of values for this option
        .option_val = 0,                                                                                                                                          // value of this option
        .menu = 0,                                                                                                                                                // pointer to the menu that pressing A opens
        .option_name = "Fighter Collision",                                                                                                                       // pointer to a string
        .desc = "Toggle hitbox and hurtbox visualization.\nYellow = hurt, red = hit, purple = grab, \nwhite = trigger, green = reflect, blue = shield/\nabsorb.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,                                                                                                                     // pointer to an array of strings
        .onOptionChange = EvFree_ChangeHitDisplay,
    },
    // environment collision
    {
        .option_kind = OPTKIND_STRING,                                                                                     // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                                                                                    // number of values for this option
        .option_val = 0,                                                                                                   // value of this option
        .menu = 0,                                                                                                         // pointer to the menu that pressing A opens
        .option_name = "Environment Collision",                                                                            // pointer to a string
        .desc = "Toggle environment collision visualization.\nDisplays the players' ECB (environmental \ncollision box).", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,                                                                              // pointer to an array of strings
        .onOptionChange = EvFree_ChangeEnvCollDisplay,
    },
    // camera mode
    {
        .option_kind = OPTKIND_STRING,                                                                                       // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeOptions_CamMode) / 4,                                                                      // number of values for this option
        .option_val = 0,                                                                                                     // value of this option
        .menu = 0,                                                                                                           // pointer to the menu that pressing A opens
        .option_name = "Camera Mode",                                                                                        // pointer to a string
        .desc = "Change the camera's behavior.\nIn advanced mode, use CStick while holding\nA/B/Y to pan, rotate and zoom.", // string describing what this option does
        .option_values = EvFreeOptions_CamMode,                                                                              // pointer to an array of strings
        .onOptionChange = EvFree_ChangeCamMode,
    },
    // hud
    {
        .option_kind = OPTKIND_STRING,                          // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                         // number of values for this option
        .option_val = 1,                                        // value of this option
        .menu = 0,                                              // pointer to the menu that pressing A opens
        .option_name = "HUD",                                   // pointer to a string
        .desc = "Toggle player percents and timer visibility.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,                   // pointer to an array of strings
        .onOptionChange = EvFree_ChangeHUD,
    },
    // di display
    {
        .option_kind = OPTKIND_STRING,                                                                                     // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                                                                                    // number of values for this option
        .option_val = 0,                                                                                                   // value of this option
        .menu = 0,                                                                                                         // pointer to the menu that pressing A opens
        .option_name = "DI Display",                                                                                       // pointer to a string
        .desc = "Display knockback trajectories during hitlag.\nUse frame advance to see the effects of DI\nin realtime.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,                                                                              // pointer to an array of strings
        .onOptionChange = 0,
    },
    // input display
    {
        .option_kind = OPTKIND_STRING,             // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                            // number of values for this option
        .option_val = 0,                           // value of this option
        .menu = 0,                                 // pointer to the menu that pressing A opens
        .option_name = "Input Display",            // pointer to a string
        .desc = "Display player inputs onscreen.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,      // pointer to an array of strings
        .onOptionChange = 0,
    },
    // move staling
    {
        .option_kind = OPTKIND_STRING,                                                          // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                                                         // number of values for this option
        .option_val = 1,                                                                        // value of this option
        .menu = 0,                                                                              // pointer to the menu that pressing A opens
        .option_name = "Move Staling",                                                          // pointer to a string
        .desc = "Toggle the staling of moves. Attacks become \nweaker the more they are used.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,                                                   // pointer to an array of strings
        .onOptionChange = 0,
    },

};
static EventMenu EvFreeMenu_General = {
    .name = "General",                                                 // the name of this menu
    .option_num = sizeof(EvFreeOptions_General) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                       // runtime variable used for how far down in the menu to start
    .state = 0,                                                        // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                       // index of the option currently selected, used at runtime
    .options = &EvFreeOptions_General,                                 // pointer to all of this menu's options
    .prev = 0,                                                         // pointer to previous menu, used at runtime
};
// Info Display
static char **EvFreeValues_InfoDisplay[] = {"None", "Position", "State Name", "State Frame", "Velocity - Self", "Velocity - KB", "Velocity - Total", "Engine LStick", "System LStick", "Engine CStick", "System CStick", "Engine Trigger", "System Trigger", "Ledgegrab Timer", "Intangibility Timer", "Hitlag", "Hitstun", "Shield Health", "Shield Stun", "Grip Strength", "ECB Lock", "ECB Bottom", "Jumps", "Walljumps", "Jab Counter", "Line Info", "Blastzone Left/Right", "Blastzone Up/Down"};
static char **EvFreeValues_InfoPresets[] = {"None", "Custom", "Ledge", "Damage"};
static EventOption EvFreeOptions_InfoDisplay[] = {
    {
        .option_kind = OPTKIND_STRING,             // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                            // number of values for this option
        .option_val = 1,                           // value of this option
        .menu = 0,                                 // pointer to the menu that pressing A opens
        .option_name = "Toggle",                   // pointer to a string
        .desc = "Enable the info display window.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,      // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_INT,                              // the type of option this is; menu, string list, integer list, etc
        .value_num = 4,                                          // number of values for this option
        .option_val = 0,                                         // value of this option
        .menu = 0,                                               // pointer to the menu that pressing A opens
        .option_name = "Player",                                 // pointer to a string
        .desc = "Toggle which player's information to display.", // string describing what this option does
        .option_values = 0,                                      // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_InfoPresets) / 4, // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Preset",                           // pointer to a string
        .desc = nullString,                                // string describing what this option does
        .option_values = EvFreeValues_InfoPresets,         // pointer to an array of strings
        .onOptionChange = EvFree_ChangeInfoPreset,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_InfoDisplay) / 4, // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Row 1",                            // pointer to a string
        .desc = nullString,                                // string describing what this option does
        .option_values = EvFreeValues_InfoDisplay,         // pointer to an array of strings
        .onOptionChange = EvFree_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_InfoDisplay) / 4, // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Row 2",                            // pointer to a string
        .desc = nullString,                                // string describing what this option does
        .option_values = EvFreeValues_InfoDisplay,         // pointer to an array of strings
        .onOptionChange = EvFree_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_InfoDisplay) / 4, // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Row 3",                            // pointer to a string
        .desc = nullString,                                // string describing what this option does
        .option_values = EvFreeValues_InfoDisplay,         // pointer to an array of strings
        .onOptionChange = EvFree_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_InfoDisplay) / 4, // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Row 4",                            // pointer to a string
        .desc = nullString,                                // string describing what this option does
        .option_values = EvFreeValues_InfoDisplay,         // pointer to an array of strings
        .onOptionChange = EvFree_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_InfoDisplay) / 4, // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Row 5",                            // pointer to a string
        .desc = nullString,                                // string describing what this option does
        .option_values = EvFreeValues_InfoDisplay,         // pointer to an array of strings
        .onOptionChange = EvFree_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_InfoDisplay) / 4, // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Row 6",                            // pointer to a string
        .desc = nullString,                                // string describing what this option does
        .option_values = EvFreeValues_InfoDisplay,         // pointer to an array of strings
        .onOptionChange = EvFree_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_InfoDisplay) / 4, // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Row 7",                            // pointer to a string
        .desc = nullString,                                // string describing what this option does
        .option_values = EvFreeValues_InfoDisplay,         // pointer to an array of strings
        .onOptionChange = EvFree_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_InfoDisplay) / 4, // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Row 8",                            // pointer to a string
        .desc = nullString,                                // string describing what this option does
        .option_values = EvFreeValues_InfoDisplay,         // pointer to an array of strings
        .onOptionChange = EvFree_ChangeInfoRow,
    },
};
static EventMenu EvFreeMenu_InfoDisplay = {
    .name = "Info Display",                // the name of this menu
    .option_num = 11,                      // number of options this menu contains
    .scroll = 0,                           // runtime variable used for how far down in the menu to start
    .state = 0,                            // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                           // index of the option currently selected, used at runtime
    .options = &EvFreeOptions_InfoDisplay, // pointer to all of this menu's options
    .prev = 0,                             // pointer to previous menu, used at runtime
};
// CPU
static char **EvFreeValues_Shield[] = {"Off", "On Until Hit", "On"};
static char **EvFreeValues_CPUBehave[] = {"Stand", "Shield", "Crouch", "Jump"};
static char **EvFreeValues_TDI[] = {"Random", "Inwards", "Outwards", "Floorhug", "Custom", "None"};
static char **EvFreeValues_SDI[] = {"Random", "None"};
static char **EvFreeValues_Tech[] = {"Random", "Neutral", "Away", "Towards", "None"};
static char **EvFreeValues_Getup[] = {"Random", "Stand", "Away", "Towards", "Attack"};
static char **EvFreeValues_CounterGround[] = {"None", "Spotdodge", "Shield", "Grab", "Up B", "Down B", "Roll Away", "Roll Towards", "Neutral Air", "Forward Air", "Down Air", "Back Air", "Up Air", "Jump"};
static char **EvFreeValues_CounterAir[] = {"None", "Airdodge", "Jump Away", "Jump Towards", "Up B", "Down B", "Neutral Air", "Forward Air", "Down Air", "Back Air", "Up Air", "Tumble Fastfall", "Wiggle Fastfall"};
static char **EvFreeValues_CounterShield[] = {"None", "Grab", "Jump", "Spotdodge", "Up B", "Down B", "Neutral Air", "Forward Air", "Down Air", "Back Air", "Up Air"};
static EventOption EvFreeOptions_CPU[] = {
    // cpu percent
    {
        .option_kind = OPTKIND_INT,          // the type of option this is; menu, string list, integer list, etc
        .value_num = 999,                    // number of values for this option
        .option_val = 0,                     // value of this option
        .menu = 0,                           // pointer to the menu that pressing A opens
        .option_name = "CPU Percent",        // pointer to a string
        .desc = "Adjust the CPU's percent.", // string describing what this option does
        .option_values = 0,                  // pointer to an array of strings
        .onOptionChange = EvFree_ChangeCPUPercent,
    },
    {
        .option_kind = OPTKIND_STRING,                      // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                     // number of values for this option
        .option_val = 0,                                    // value of this option
        .menu = 0,                                          // pointer to the menu that pressing A opens
        .option_name = {"Intangibility"},                   // pointer to a string
        .desc = "Toggle the CPU's ability to take damage.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,               // pointer to an array of strings
        .onOptionChange = EvFree_ChangeCPUIntang,
    },
    {
        .option_kind = OPTKIND_STRING,                    // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_Shield) / 4,     // number of values for this option
        .option_val = 1,                                  // value of this option
        .menu = 0,                                        // pointer to the menu that pressing A opens
        .option_name = {"Infinite Shields"},              // pointer to a string
        .desc = "Adjust how shield health deteriorates.", // string describing what this option does
        .option_values = EvFreeValues_Shield,             // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                    // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_CPUBehave) / 4,  // number of values for this option
        .option_val = 0,                                  // value of this option
        .menu = 0,                                        // pointer to the menu that pressing A opens
        .option_name = "Behavior",                        // pointer to a string
        .desc = "Adjust how the CPU behaves by default.", // string describing what this option does
        .option_values = EvFreeValues_CPUBehave,          // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                           // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_SDI) / 4,                               // number of values for this option
        .option_val = 0,                                                         // value of this option
        .menu = 0,                                                               // pointer to the menu that pressing A opens
        .option_name = "Smash DI",                                               // pointer to a string
        .desc = "Adjust how the CPU will alter their position\nduring hitstop.", // string describing what this option does
        .option_values = EvFreeValues_SDI,                                       // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                        // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_TDI) / 4,                            // number of values for this option
        .option_val = 0,                                                      // value of this option
        .menu = 0,                                                            // pointer to the menu that pressing A opens
        .option_name = "Trajectory DI",                                       // pointer to a string
        .desc = "Adjust how the CPU will alter their knockback\ntrajectory.", // string describing what this option does
        .option_values = EvFreeValues_TDI,                                    // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_FUNC,                                           // the type of option this is; menu, string list, integer list, etc
        .value_num = 0,                                                        // number of values for this option
        .option_val = 0,                                                       // value of this option
        .menu = 0,                                                             // pointer to the menu that pressing A opens
        .option_name = "Custom TDI",                                           // pointer to a string
        .desc = "Create custom trajectory DI values for the\nCPU to perform.", // string describing what this option does
        .option_values = 0,                                                    // pointer to an array of strings
        .onOptionChange = 0,
        .onOptionSelect = EvFree_SelectCustomTDI,
    },
    {
        .option_kind = OPTKIND_STRING,                                         // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_Tech) / 4,                            // number of values for this option
        .option_val = 0,                                                       // value of this option
        .menu = 0,                                                             // pointer to the menu that pressing A opens
        .option_name = "Tech Option",                                          // pointer to a string
        .desc = "Adjust what the CPU will do upon colliding with\nthe stage.", // string describing what this option does
        .option_values = EvFreeValues_Tech,                                    // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_Getup) / 4,                       // number of values for this option
        .option_val = 0,                                                   // value of this option
        .menu = 0,                                                         // pointer to the menu that pressing A opens
        .option_name = "Get Up Option",                                    // pointer to a string
        .desc = "Adjust what the CPU will do after missing\na tech input", // string describing what this option does
        .option_values = EvFreeValues_Getup,                               // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                              // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeOptions_OffOn) / 4,               // number of values for this option
        .option_val = 0,                                            // value of this option
        .menu = 0,                                                  // pointer to the menu that pressing A opens
        .option_name = "Auto Reset",                                // pointer to a string
        .desc = "Automatically reset after the CPU is actionable.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,                       // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_CounterGround) / 4,                               // number of values for this option
        .option_val = 1,                                                                   // value of this option
        .menu = 0,                                                                         // pointer to the menu that pressing A opens
        .option_name = "Counter Action (Ground)",                                          // pointer to a string
        .desc = "Select the action to be performed after a\ngrounded CPU's hitstun ends.", // string describing what this option does
        .option_values = EvFreeValues_CounterGround,                                       // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                                      // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_CounterAir) / 4,                                   // number of values for this option
        .option_val = 1,                                                                    // value of this option
        .menu = 0,                                                                          // pointer to the menu that pressing A opens
        .option_name = "Counter Action (Air)",                                              // pointer to a string
        .desc = "Select the action to be performed after an\nairborne CPU's hitstun ends.", // string describing what this option does
        .option_values = EvFreeValues_CounterAir,                                           // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                              // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_CounterShield) / 4,                        // number of values for this option
        .option_val = 1,                                                            // value of this option
        .menu = 0,                                                                  // pointer to the menu that pressing A opens
        .option_name = "Counter Action (Shield)",                                   // pointer to a string
        .desc = "Select the action to be performed after the\nCPU's shield is hit", // string describing what this option does
        .option_values = EvFreeValues_CounterShield,                                // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_INT,                                                  // the type of option this is; menu, string list, integer list, etc
        .value_num = 100,                                                            // number of values for this option
        .option_val = 0,                                                             // value of this option
        .menu = 0,                                                                   // pointer to the menu that pressing A opens
        .option_name = "Counter After Frames",                                       // pointer to a string
        .desc = "Adjust the amount of actionable frames before \nthe CPU counters.", // string describing what this option does
        .option_values = 0,                                                          // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_INT,                                           // the type of option this is; menu, string list, integer list, etc
        .value_num = 100,                                                     // number of values for this option
        .option_val = 1,                                                      // value of this option
        .menu = 0,                                                            // pointer to the menu that pressing A opens
        .option_name = "Counter After Hits",                                  // pointer to a string
        .desc = "Adjust the amount of hits taken before the \nCPU counters.", // string describing what this option does
        .option_values = 0,                                                   // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_INT,                                                           // the type of option this is; menu, string list, integer list, etc
        .value_num = 100,                                                                     // number of values for this option
        .option_val = 1,                                                                      // value of this option
        .menu = 0,                                                                            // pointer to the menu that pressing A opens
        .option_name = "Counter After Shield Hits",                                           // pointer to a string
        .desc = "Adjust the amount of hits the CPU's shield\nwill take before they counter.", // string describing what this option does
        .option_values = 0,                                                                   // pointer to an array of strings
        .onOptionChange = 0,
    },
};
static EventMenu EvFreeMenu_CPU = {
    .name = "CPU Options",                                         // the name of this menu
    .option_num = sizeof(EvFreeOptions_CPU) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                   // runtime variable used for how far down in the menu to start
    .state = 0,                                                    // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                   // index of the option currently selected, used at runtime
    .options = &EvFreeOptions_CPU,                                 // pointer to all of this menu's options
    .prev = 0,                                                     // pointer to previous menu, used at runtime
};
// Recording
static char **EvFreeValues_RecordSlot[] = {"Random", "Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5", "Slot 6"};
static char **EvFreeValues_HMNRecordMode[] = {"Off", "Record", "Playback"};
static char **EvFreeValues_CPURecordMode[] = {"Off", "Control", "Record", "Playback"};
static EventOption EvFreeOptions_Record[] = {
    {
        .option_kind = OPTKIND_FUNC,                                             // the type of option this is; menu, string list, integer list, etc
        .value_num = 0,                                                          // number of values for this option
        .option_val = 0,                                                         // value of this option
        .menu = 0,                                                               // pointer to the menu that pressing A opens
        .option_name = "Save Positions",                                         // pointer to a string
        .desc = "Save the current fighter positions\nas the initial positions.", // string describing what this option does
        .option_values = 0,                                                      // pointer to an array of strings
        .onOptionSelect = Record_InitState,
    },
    {
        .option_kind = OPTKIND_FUNC,                                                                    // the type of option this is; menu, string list, integer list, etc
        .value_num = 0,                                                                                 // number of values for this option
        .option_val = 0,                                                                                // value of this option
        .menu = 0,                                                                                      // pointer to the menu that pressing A opens
        .option_name = "Restore Positions",                                                             // pointer to a string
        .desc = "Load the original fighter positions. This\ncan also be done in-game by pressing ???.", // string describing what this option does
        .option_values = 0,                                                                             // pointer to an array of strings
        .onOptionSelect = Record_RestoreState,
    },
    {
        .option_kind = OPTKIND_STRING,                               // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_HMNRecordMode) / 4,         // number of values for this option
        .option_val = 0,                                             // value of this option
        .menu = 0,                                                   // pointer to the menu that pressing A opens
        .option_name = "HMN Mode",                                   // pointer to a string
        .desc = "Toggle between recording and playback of\ninputs.", // string describing what this option does
        .option_values = EvFreeValues_HMNRecordMode,                 // pointer to an array of strings
        .onOptionChange = Record_ChangeHMNMode,
    },
    {
        .option_kind = OPTKIND_STRING,                    // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_RecordSlot) / 4, // number of values for this option
        .option_val = 1,                                  // value of this option
        .menu = 0,                                        // pointer to the menu that pressing A opens
        .option_name = "HMN Record Slot",                 // pointer to a string
        .desc = "Toggle which slot to record to.",        // string describing what this option does
        .option_values = EvFreeValues_RecordSlot,         // pointer to an array of strings
        .onOptionChange = Record_ChangeHMNSlot,
    },
    {
        .option_kind = OPTKIND_STRING,                               // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_CPURecordMode) / 4,         // number of values for this option
        .option_val = 0,                                             // value of this option
        .menu = 0,                                                   // pointer to the menu that pressing A opens
        .option_name = "CPU Mode",                                   // pointer to a string
        .desc = "Toggle between recording and playback of\ninputs.", // string describing what this option does
        .option_values = EvFreeValues_CPURecordMode,                 // pointer to an array of strings
        .onOptionChange = Record_ChangeCPUMode,
    },
    {
        .option_kind = OPTKIND_STRING,                    // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_RecordSlot) / 4, // number of values for this option
        .option_val = 1,                                  // value of this option
        .menu = 0,                                        // pointer to the menu that pressing A opens
        .option_name = "CPU Record Slot",                 // pointer to a string
        .desc = "Toggle which slot to record to.",        // string describing what this option does
        .option_values = EvFreeValues_RecordSlot,         // pointer to an array of strings
        .onOptionChange = Record_ChangeCPUSlot,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeOptions_OffOn) / 4,      // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Loop Recording",                   // pointer to a string
        .desc = "Loop the recorded inputs when they end.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,              // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                       // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeOptions_OffOn) / 4,                        // number of values for this option
        .option_val = 0,                                                     // value of this option
        .menu = 0,                                                           // pointer to the menu that pressing A opens
        .option_name = "Auto Restore",                                       // pointer to a string
        .desc = "Automatically restore positions after the\nplayback ends.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,                                // pointer to an array of strings
        .onOptionChange = 0,
    },
};
static EventMenu EvFreeMenu_Record = {
    .name = "Recording",                                              // the name of this menu
    .option_num = sizeof(EvFreeOptions_Record) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                      // runtime variable used for how far down in the menu to start
    .state = 0,                                                       // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                      // index of the option currently selected, used at runtime
    .options = &EvFreeOptions_Record,                                 // pointer to all of this menu's options
    .prev = 0,                                                        // pointer to previous menu, used at runtime
};

// Static Variables
static DIDraw didraws[6];
static GOBJ *infodisp_gobj;
static RecData rec_data;
static SaveState rec_state;

// Menu Callbacks
void EvFree_ChangePlayerPercent(GOBJ *menu_gobj, int value)
{
    GOBJ *fighter = Fighter_GetGObj(0);
    FighterData *fighter_data = fighter->userdata;

    fighter_data->damage_Percent = value;
    Fighter_SetHUDDamage(0, value);

    return;
}
void EvFree_ChangeCPUPercent(GOBJ *menu_gobj, int value)
{
    GOBJ *fighter = Fighter_GetGObj(1);
    FighterData *fighter_data = fighter->userdata;

    fighter_data->damage_Percent = value;
    Fighter_SetHUDDamage(1, value);

    return;
}
void EvFree_ChangeCPUIntang(GOBJ *menu_gobj, int value)
{
    // remove blink GFX if toggling off
    if (value == 0)
    {
        GOBJ *fighter = Fighter_GetGObj(1);
        Fighter_GFXRemoveAll(fighter);
    }
    return;
}
void EvFree_ChangeModelDisplay(GOBJ *menu_gobj, int value)
{

    // loop through all fighters
    GOBJ **GOBJList = R13_PTR(-0x3E74);
    GOBJ *this_fighter = GOBJList[8];
    while (this_fighter != 0)
    {
        // get data
        FighterData *thisFighterData = this_fighter->userdata;

        // toggle
        thisFighterData->show_model = value;

        // get next fighter
        this_fighter = this_fighter->next;
    }

    GOBJ *fighter = Fighter_GetGObj(0);
    FighterData *fighter_data = fighter->userdata;

    return;
}
void EvFree_ChangeHitDisplay(GOBJ *menu_gobj, int value)
{

    // loop through all fighters
    GOBJ **GOBJList = R13_PTR(-0x3E74);
    GOBJ *this_fighter = GOBJList[8];
    while (this_fighter != 0)
    {
        // get data
        FighterData *thisFighterData = this_fighter->userdata;

        // toggle
        thisFighterData->show_hit = value;

        // get next fighter
        this_fighter = this_fighter->next;
    }

    GOBJ *fighter = Fighter_GetGObj(0);
    FighterData *fighter_data = fighter->userdata;

    return;
}
void EvFree_ChangeEnvCollDisplay(GOBJ *menu_gobj, int value)
{
    MatchCamera *matchCam = MATCH_CAM;
    matchCam->show_coll = value;

    OSReport("%d", matchCam->show_coll);
    return;
}
void EvFree_ChangeCamMode(GOBJ *menu_gobj, int value)
{

    MatchCamera *cam = MATCH_CAM;

    // normal cam
    if (value == 0)
    {
        Match_SetNormalCamera();
    }
    // zoom cam
    else if (value == 1)
    {
        Match_SetFreeCamera(0, 3);
        cam->freecam_fov.X = 140;
        cam->freecam_rotate.Y = 10;
    }
    // fixed
    else if (value == 2)
    {
        Match_SetFixedCamera();
    }
    else if (value == 3)
    {
        Match_SetDevelopCamera();
    }
    Match_CorrectCamera();

    return;
}
void EvFree_ChangeInfoRow(GOBJ *menu_gobj, int value)
{
    EventOption *idOptions = &EvFreeOptions_InfoDisplay;

    // changed option, set preset to custom
    idOptions[OPTINF_PRESET].option_val = 1;
}
void EvFree_ChangeInfoPreset(GOBJ *menu_gobj, int value)
{
    static int idPresets[][8] =
        {
            // None
            {
                0,
                0,
                0,
                0,
                0,
                0,
                0,
                0,
            },
            // Ledge
            {
                2,
                3,
                8,
                7,
                14,
                20,
                21,
                0,
            },
            // Damage
            {
                2,
                3,
                4,
                5,
                6,
                15,
                16,
                18,
            },
        };

    EventOption *idOptions = &EvFreeOptions_InfoDisplay;
    int *currPreset = 0;

    // check for NONE
    if (value == 0)
        currPreset = idPresets[0];

    // check for preset
    value -= 2;
    if (value >= 0)
    {
        currPreset = idPresets[value + 1];
    }

    // copy values
    if (currPreset != 0)
    {
        for (int i = 0; i < 8; i++)
        {
            idOptions[i + OPTINF_ROW1].option_val = currPreset[i];
        }
    }
}
void EvFree_ChangeHUD(GOBJ *menu_gobj, int value)
{
    // toggle HUD
    u8 *hideHUD = (u8 *)(R13 + -0x4948);
    if (value == 0)
    {
        *hideHUD = 1;
    }
    else
    {
        *hideHUD = 0;
    }
    return;
}
void Record_InitState(GOBJ *menu_gobj)
{
    if (event_vars->Savestate_Save(&rec_state))
    {

        // enable other options
        for (int i = 1; i < sizeof(EvFreeOptions_Record) / sizeof(EventOption); i++)
        {
            EvFreeOptions_Record[i].disable = 0;
        }

        // clear slots
        for (int i = 0; i < REC_SLOTS; i++)
        {
            // clear data
            memset(rec_data.hmn_inputs[i], 0, sizeof(RecInputData));
            memset(rec_data.cpu_inputs[i], 0, sizeof(RecInputData));

            // init frame this recording starts on
            rec_data.hmn_inputs[i]->start_frame = -1;
            rec_data.cpu_inputs[i]->start_frame = -1;
        }

        // init settings
        EvFreeOptions_Record[OPTREC_HMNMODE].option_val = 0; // set hmn to off
        EvFreeOptions_Record[OPTREC_HMNSLOT].option_val = 1; // set hmn to slot 1
        EvFreeOptions_Record[OPTREC_CPUMODE].option_val = 0; // set cpu to off
        EvFreeOptions_Record[OPTREC_CPUSLOT].option_val = 1; // set cpu to slot 1

        // copy state to personal savestate
        //memcpy(&stc_savestate, &rec_state, sizeof(SaveState));
    }
    return;
}
void Record_RestoreState(GOBJ *menu_gobj)
{
    event_vars->Savestate_Load(&rec_state);
    return;
}
void Record_ChangeHMNSlot(GOBJ *menu_gobj, int value)
{
    // upon changing to random
    if (value == 0)
    {
        // if set to record
        if (EvFreeOptions_Record[OPTREC_HMNMODE].option_val == 1)
        {
            // change to slot 1
            EvFreeOptions_Record[OPTREC_HMNSLOT].option_val = 1;
        }

        // update random slot
        else
        {
            rec_data.hmn_rndm_slot = Record_GetRandomSlot(&rec_data.hmn_inputs);
        }
    }

    // reload save
    event_vars->Savestate_Load(&rec_state);

    return;
}
void Record_ChangeCPUSlot(GOBJ *menu_gobj, int value)
{
    // upon changing to random
    if (value == 0)
    {
        // if set to record
        if (EvFreeOptions_Record[OPTREC_CPUMODE].option_val == 2)
        {
            // change to slot 1
            EvFreeOptions_Record[OPTREC_CPUSLOT].option_val = 1;
        }

        // update random slot
        else
        {
            rec_data.cpu_rndm_slot = Record_GetRandomSlot(&rec_data.cpu_inputs);
        }
    }

    // reload save
    event_vars->Savestate_Load(&rec_state);

    return;
}
void Record_ChangeHMNMode(GOBJ *menu_gobj, int value)
{

    // upon changing to record
    if (value == 1)
    {
        // if set to random
        if (EvFreeOptions_Record[OPTREC_HMNSLOT].option_val == 0)
        {
            EvFreeOptions_Record[OPTREC_HMNSLOT].option_val = 1;
        }
    }

    // upon changing to playback
    if (value == 2)
    {
        event_vars->Savestate_Load(&rec_state);
    }
    return;
}
void Record_ChangeCPUMode(GOBJ *menu_gobj, int value)
{

    // upon changing to record
    if (value == 2)
    {
        // if set to random
        if (EvFreeOptions_Record[OPTREC_CPUSLOT].option_val == 0)
        {
            // change to slot 1
            EvFreeOptions_Record[OPTREC_CPUSLOT].option_val = 1;
        }
    }

    // upon toggling playback
    if (value == 3)
    {
        event_vars->Savestate_Load(&rec_state);
    }
    return;
}
void EvFree_Exit(int value)
{
    Match *match = MATCH;

    // end game
    match->state = 3;

    // Unfreeze
    EvFreeOptions_General[OPTGEN_FRAME].option_val = 0;
    //HSD_Update *update = HSD_UPDATE;
    //update->pause_develop = 0;
    return;
}

// Event Functions
GOBJ *InfoDisplay_Init()
{
    // Create Info Display GOBJ
    GOBJ *idGOBJ = GObj_Create(0, 0, 0);
    InfoDisplayData *idData = calloc(sizeof(InfoDisplayData));
    GObj_AddUserData(idGOBJ, 4, HSD_Free, idData);
    // Load jobj
    evMenu *menuAssets = event_vars->menu_assets;
    JOBJ *menu = JOBJ_LoadJoint(menuAssets->popup);
    idData->menuModel = menu;
    // Add to gobj
    GObj_AddObject(idGOBJ, 3, menu);
    // Add gxlink
    GObj_AddGXLink(idGOBJ, InfoDisplay_GX, GXLINK_INFDISP, GXPRI_INFDISP);
    // Save pointers to corners
    JOBJ *corners[4];
    JOBJ_GetChild(menu, &corners, 2, 3, 4, 5, -1);
    idData->botLeftEdge = corners[0];
    idData->botRightEdge = corners[1];
    // move into position
    menu->scale.X = INFDISP_SCALE;
    menu->scale.Y = INFDISP_SCALE;
    menu->scale.Z = INFDISP_SCALE;
    menu->trans.Y = INFDISP_Y;
    corners[0]->trans.X = -(INFDISP_WIDTH / 2) + INFDISP_X;
    corners[1]->trans.X = (INFDISP_WIDTH / 2) + INFDISP_X;
    corners[2]->trans.X = -(INFDISP_WIDTH / 2) + INFDISP_X;
    corners[3]->trans.X = (INFDISP_WIDTH / 2) + INFDISP_X;
    //JOBJ_SetFlags(menu, JOBJ_HIDDEN);
    menu->dobj->next->mobj->mat->alpha = 0.6;

    // Create text object
    int canvas_index = Text_CreateCanvas(2, idGOBJ, 14, 15, 0, GXLINK_INFDISPTEXT, GXPRI_INFDISPTEXT, 19);
    Text *text = Text_CreateText(2, canvas_index);
    text->kerning = 1;
    text->scale.X = INFDISPTEXT_SCALE;
    text->scale.Y = INFDISPTEXT_SCALE;
    text->trans.X = INFDISPTEXT_X;
    text->trans.Y = INFDISPTEXT_Y;
    // Create subtexts for each row
    for (int i = 0; i < 8; i++)
    {
        Text_AddSubtext(text, 0, i * INFDISPTEXT_YOFFSET, &nullString);
    }
    idData->text = text;

    // update to show/hide
    InfoDisplay_Think(idGOBJ);

    return idGOBJ;
}
void InfoDisplay_GX(GOBJ *gobj, int pass)
{
    GXLink_Common(gobj, pass);
    return;
}
void InfoDisplay_Think(GOBJ *gobj)
{

    InfoDisplayData *idData = gobj->userdata;
    Text *text = idData->text;
    EventOption *idOptions = &EvFreeOptions_InfoDisplay;
    if ((Pause_CheckStatus(1) != 2) && (idOptions[OPTINF_TOGGLE].option_val == 1))
    {
        // get the last row enabled
        int rowsEnabled = 8;
        while (rowsEnabled > 0)
        {
            if (idOptions[rowsEnabled - 1 + OPTINF_ROW1].option_val != 0)
                break;
            rowsEnabled--;
        }

        // if a row is enabled, display
        if (rowsEnabled != 0)
        {
            // show model and text
            JOBJ_ClearFlags(idData->menuModel, JOBJ_HIDDEN);
            idData->text->hidden = 0;

            // scale window Y based on rows enabled
            JOBJ *leftCorner = idData->botLeftEdge;
            JOBJ *rightCorner = idData->botRightEdge;
            float yPos = (rowsEnabled * INFDISP_BOTYOFFSET) + INFDISP_BOTY;
            leftCorner->trans.Y = yPos;
            rightCorner->trans.Y = yPos;
            JOBJ_SetMtxDirtySub(idData->menuModel);

            // update info display strings
            int ply = idOptions[OPTINF_PLAYER].option_val;
            GOBJ *fighter = Fighter_GetGObj(ply);
            FighterData *fighter_data;
            if (fighter != 0)
                fighter_data = fighter->userdata;
            for (int i = 0; i < 8; i++)
            {

                int value = idOptions[i + OPTINF_ROW1].option_val;

                // hide text if set to 0 or fighter DNE
                if ((idOptions[i + OPTINF_ROW1].option_val == 0) || fighter == 0)
                {
                    Text_SetText(text, i, "");
                }

                // display info
                else
                {
                    switch (value - 1)
                    {
                    case (0):
                    {
                        Text_SetText(text, i, "Pos: (%+.2f , %+.2f)", fighter_data->pos.X, fighter_data->pos.Y);
                        break;
                    }
                    case (1):
                    {
                        if (fighter_data->anim_id != -1)
                        {
                            SubactionHeader *subHeader = Fighter_GetSubactionHeader(fighter_data, fighter_data->anim_id);
                            // extract state name from symbol
                            int pos = 0;
                            int posStart;
                            int nameSize = 0;
                            char *symbol = subHeader->symbol;
                            for (int i = 0; pos < 50; pos++)
                            {
                                // search for "N_"
                                if ((symbol[pos] == 'N') && (symbol[pos + 1] == '_'))
                                {
                                    // posStart = beginning of state name
                                    pos++;
                                    posStart = pos + 1;

                                    // search for "_"
                                    for (int i = 0; pos < 50; pos++)
                                    {
                                        if (symbol[pos] == '_')
                                        {
                                            nameSize = pos - posStart;
                                        }
                                    }
                                }
                            }
                            if (nameSize != 0)
                            {
                                // copy string
                                char stateNameBuffer[50];
                                memcpy(&stateNameBuffer, &symbol[posStart], nameSize);
                                stateNameBuffer[nameSize] = 0;
                                Text_SetText(text, i, "State: %s", &stateNameBuffer);
                            }
                        }

                        else
                            Text_SetText(text, i, "State: %s", "Unknown");
                        break;
                    }
                    case (2):
                    {
                        float *animStruct = fighter_data->anim_curr_flags_ptr;

                        // determine how many frames shield stun is
                        float animFrameTotal = animStruct[2];
                        float animFrameCurr = fighter_data->stateFrame;
                        float animSpeed = fighter_data->stateSpeed;
                        int frameTotal = (animFrameTotal / animSpeed);
                        int frameCurr = (animFrameCurr / animSpeed);
                        // 1 index
                        frameTotal;
                        frameCurr;

                        Text_SetText(text, i, "State Frame: %d/%d", frameCurr, frameTotal);
                        break;
                    }
                    case (3):
                    {
                        Text_SetText(text, i, "SelfVel: (%+.3f , %+.3f)", fighter_data->selfVel.X, fighter_data->selfVel.Y);
                        break;
                    }
                    case (4):
                    {
                        Text_SetText(text, i, "KBVel: (%+.3f , %+.3f)", fighter_data->kbVel.X, fighter_data->kbVel.Y);
                        break;
                    }
                    case (5):
                    {
                        Text_SetText(text, i, "TotalVel: (%+.3f , %+.3f)", fighter_data->selfVel.X + fighter_data->kbVel.X, fighter_data->selfVel.Y + fighter_data->kbVel.Y);
                        break;
                    }
                    case (6):
                    {
                        Text_SetText(text, i, "LStick:      (%+.4f , %+.4f)", fighter_data->input_lstick_x, fighter_data->input_lstick_y);
                        break;
                    }
                    case (7):
                    {
                        HSD_Pad *pad = PadGet(ply, PADGET_MASTER);
                        Text_SetText(text, i, "LStick Sys: (%+.4f , %+.4f)", pad->fstickX, pad->fstickY);
                        break;
                    }
                    case (8):
                    {
                        Text_SetText(text, i, "CStick:     (%+.4f , %+.4f)", fighter_data->input_cstick_x, fighter_data->input_cstick_y);
                        break;
                    }
                    case (9):
                    {
                        HSD_Pad *pad = PadGet(ply, PADGET_MASTER);
                        Text_SetText(text, i, "CStick Sys: (%+.4f , %+.4f)", pad->fsubstickX, pad->fsubstickY);
                        break;
                    }
                    case (10):
                    {
                        Text_SetText(text, i, "Trigger:     (%+.3f)", fighter_data->input_trigger);
                        break;
                    }
                    case (11):
                    {
                        HSD_Pad *pad = PadGet(ply, PADGET_MASTER);
                        Text_SetText(text, i, "Trigger Sys: (%+.3f , %+.3f)", pad->ftriggerLeft, pad->ftriggerRight);
                        break;
                    }
                    case (12):
                    {
                        Text_SetText(text, i, "Ledgegrab Timer: %d", fighter_data->ledge_cooldown);
                        break;
                    }
                    case (13):
                    {
                        int intang = fighter_data->respawn_intang_left;
                        if (fighter_data->ledge_intang_left > fighter_data->respawn_intang_left)
                            intang = fighter_data->ledge_intang_left;

                        Text_SetText(text, i, "Intangibility Timer: %d", intang);
                        break;
                    }
                    case (14):
                    {
                        Text_SetText(text, i, "Hitlag: %.0f", fighter_data->hitlag_frames);
                        break;
                    }
                    case (15):
                    {
                        // get hitstun
                        float hitstun = 0;
                        if (fighter_data->hitstun == 1)
                            hitstun = AS_FLOAT(fighter_data->stateVar1);

                        Text_SetText(text, i, "Hitstun: %.0f", hitstun);
                        break;
                    }
                    case (16):
                    {
                        Text_SetText(text, i, "Shield Health: %.3f", fighter_data->shield_health);
                        break;
                    }
                    case (17):
                    {
                        int stunTotal = 0;
                        int stunLeft = 0;

                        // check if taking shield stun
                        if (fighter_data->state_id == ASID_GUARDSETOFF)
                        {
                            // determine how many frames shield stun is
                            float frameTotal = JOBJ_GetJointAnimFrameTotal(fighter->hsd_object);
                            float frameCurr = fighter_data->stateFrame;
                            float animSpeed = fighter_data->stateSpeed;
                            stunTotal = (frameTotal / animSpeed);
                            stunLeft = stunTotal - (frameCurr / animSpeed);
                            // 0 index
                            stunTotal++;
                            stunLeft++;
                        }

                        Text_SetText(text, i, "Shield Stun: %d/%d", stunLeft, stunTotal);
                        break;
                    }
                    case (18):
                    {
                        float grip = 0;
                        if (fighter_data->grab_victim != 0)
                        {
                            GOBJ *victim = fighter_data->grab_victim;
                            FighterData *victim_data = victim->userdata;
                            grip = victim_data->grab_timer;
                        }

                        Text_SetText(text, i, "Grip Strength: %.0f", grip);
                        break;
                    }
                    case (19):
                    {
                        Text_SetText(text, i, "ECB Lock: %d", fighter_data->collData.ecb_lock);
                        break;
                    }
                    case (20):
                    {
                        Text_SetText(text, i, "ECB Bottom: %.3f", fighter_data->collData.ecbCurr_bot.Y);
                        break;
                    }
                    case (21):
                    {
                        Text_SetText(text, i, "Jumps: %d/%d", fighter_data->jumps_used, fighter_data->max_jumps);
                        break;
                    }
                    case (22):
                    {
                        Text_SetText(text, i, "Walljumps: %d", fighter_data->walljumps_used);
                        break;
                    }
                    case (23):
                    {
                        Text_SetText(text, i, "Jab Counter: IDK");
                        break;
                    }
                    case (24):
                    {
                        CollData *colldata = &fighter_data->collData;
                        int ground = -1;
                        int ceil = -1;
                        int left = -1;
                        int right = -1;

                        if ((colldata->envFlags & ECB_GROUND) != 0)
                            ground = colldata->ground_index;
                        if ((colldata->envFlags & ECB_CEIL) != 0)
                            ceil = colldata->ceil_index;
                        if ((colldata->envFlags & ECB_WALLLEFT) != 0)
                            left = colldata->leftwall_index;
                        if ((colldata->envFlags & ECB_WALLRIGHT) != 0)
                            right = colldata->rightwall_index;

                        Text_SetText(text, i, "Lines: G:%d, C:%d, L:%d, R:%d,", ground, ceil, left, right);
                        break;
                    }
                    case (25):
                    {
                        Stage *stage = STAGE;
                        Text_SetText(text, i, "Blastzone L/R: (%+.3f,%+.3f)", stage->blastzoneLeft, stage->blastzoneRight);
                        break;
                    }
                    case (26):
                    {
                        Stage *stage = STAGE;
                        Text_SetText(text, i, "Blastzone U/D: (%.2f,%.2f)", stage->blastzoneTop, stage->blastzoneBottom);
                        break;
                    }
                    }
                }
            }
        }
        else
        {
            // hide model and text
            JOBJ_SetFlags(idData->menuModel, JOBJ_HIDDEN);
            idData->text->hidden = 1;
        }
    }
    else
    {
        // hide model and text
        JOBJ_SetFlags(idData->menuModel, JOBJ_HIDDEN);
        idData->text->hidden = 1;
    }

    return;
}
float Fighter_GetOpponentDir(FighterData *from, FighterData *to)
{
    float dir = -1;
    Vec3 *from_pos = &from->pos;
    Vec3 *to_pos = &to->pos;

    if (from_pos->X <= to_pos->X)
        dir = 1;

    return dir;
}
int CPUAction_CheckActionable(GOBJ *cpu, int actionable_kind)
{

    static u8 grActionable[] = {ASID_WAIT, ASID_WALKSLOW, ASID_WALKMIDDLE, ASID_WALKFAST, ASID_RUN, ASID_SQUATWAIT, ASID_OTTOTTOWAIT, ASID_GUARD};
    static u8 airActionable[] = {ASID_JUMPF, ASID_JUMPB, ASID_JUMPAERIALF, ASID_JUMPAERIALB, ASID_FALL, ASID_FALLAERIALF, ASID_FALLAERIALB, ASID_DAMAGEFALL, ASID_DAMAGEFLYROLL, ASID_DAMAGEFLYTOP};
    static u8 airDamage[] = {ASID_DAMAGEFLYHI, ASID_DAMAGEFLYN, ASID_DAMAGEFLYLW, ASID_DAMAGEFLYTOP, ASID_DAMAGEFLYROLL, ASID_DAMAGEFALL};

    FighterData *cpu_data = cpu->userdata;
    int isActionable = 0;
    int cpu_state = cpu_data->state_id;

    // if 0, check the one that corresponds with ground state
    if (actionable_kind == 0)
    {
        actionable_kind = cpu_data->air_state + 1;
    }

    // ground
    if (actionable_kind == 1)
    {
        // check ground actionable
        for (int i = 0; i < sizeof(grActionable); i++)
        {
            if (cpu_state == grActionable[i])
            {
                isActionable = 1;
                break;
            }
        }
        // landing
        if ((cpu_data->state_id == ASID_LANDING) && (cpu_data->stateFrame >= cpu_data->normal_landing_lag))
            isActionable = 1;
    }
    // air
    else if (actionable_kind == 2)
    {
        // check air actionable
        for (int i = 0; i < sizeof(airActionable); i++)
        {
            if (cpu_state == airActionable[i])
            {
                isActionable = 1;
                break;
            }
        }
    }
    // damage state that requires wiggling
    else if (actionable_kind == 3)
    {
        // check air actionable
        for (int i = 0; i < sizeof(airDamage); i++)
        {
            if (cpu_state == airDamage[i])
            {
                isActionable = 1;
                break;
            }
        }
    }

    return isActionable;
}
int LCancel_CPUPerformAction(GOBJ *cpu, int action_id, GOBJ *hmn)
{

    FighterData *cpu_data = cpu->userdata;
    FighterData *hmn_data = hmn->userdata;

    // get CPU action
    int action_done = 0;
    CPUAction *action_list = EvFree_CPUActions[action_id];
    int cpu_state = cpu_data->state_id;
    s16 cpu_frame = cpu_data->stateFrame;
    if (cpu_frame == -1)
        cpu_frame = 0;

    // clear inputs
    Fighter_ZeroCPUInputs(cpu_data);

    // if no action, report command as done
    if (action_id == 0)
        action_done = 1;

    // perform command
    else
    {
        // loop through all inputs
        int action_parse = 0;
        CPUAction *action_input = &action_list[action_parse];
        while ((action_input != 0) && (action_input->state != 0xFFFF))
        {

            int isState = 0;
            if ((action_input->state >= ASID_ACTIONABLE) && (action_input->state <= ASID_DAMAGEAIR))
            {

                isState = CPUAction_CheckActionable(cpu, (action_input->state - ASID_ACTIONABLE));
            }
            else if (action_input->state == cpu_state)
            {
                isState = 1;
            }

            // check if this is the current state
            if (isState == 1)
            {

                blr();

                // check if im on the right frame
                if (cpu_frame >= action_input->frameLow)
                {

                    // perform this action
                    s8 dir;
                    int held = action_input->input;
                    s8 lstickX = action_input->stickX;
                    s8 lstickY = action_input->stickY;
                    s8 cstickX = action_input->cstickX;
                    s8 cstickY = action_input->cstickY;

                    // stick direction
                    switch (action_input->stickDir)
                    {
                    case (STCKDIR_NONE):
                    {
                        break;
                    }
                    case (STCKDIR_TOWARD):
                    {
                        dir = Fighter_GetOpponentDir(cpu_data, hmn_data);
                        lstickX *= dir;
                        break;
                    }
                    case (STCKDIR_AWAY):
                    {
                        dir = Fighter_GetOpponentDir(cpu_data, hmn_data) * -1;
                        lstickX *= dir;
                        break;
                    }
                    case (STCKDIR_FRONT):
                    {
                        dir = cpu_data->facing_direction;
                        lstickX *= dir;
                        cstickX *= dir;
                        break;
                    }
                    case (STCKDIR_BACK):
                    {
                        dir = cpu_data->facing_direction;
                        lstickX *= (dir * -1);
                        cstickX *= (dir * -1);
                        break;
                    }
                    }

                    // perform this action
                    cpu_data->cpu.held = held;
                    cpu_data->cpu.lstickX = lstickX;
                    cpu_data->cpu.lstickY = lstickY;
                    cpu_data->cpu.cstickX = cstickX;
                    cpu_data->cpu.cstickY = cstickY;

                    // check if this was the last action
                    if (action_input->isLast == 1)
                        action_done = 1;

                    break;
                }
            }

            // get next input
            action_parse++;
            action_input = &action_list[action_parse];
        }
    }

    return action_done;
}
void LCancel_CPUThink(GOBJ *event, GOBJ *hmn, GOBJ *cpu)
{
    // get gobjs data
    LCancelData *eventData = event->userdata;
    FighterData *hmn_data = hmn->userdata;
    FighterData *cpu_data = cpu->userdata;
    GOBJ **gobjlist = R13_PTR(GOBJLIST);

    // noact
    cpu_data->cpu.ai = 15;

    // ALWAYS CHECK FOR X AND OVERRIDE STATE
    // check if damaged
    if (cpu_data->hitstun == 1)
    {
        eventData->cpu_hitkind = HITKIND_DAMAGE;
        // go to SDI state
        eventData->cpu_state = CPUSTATE_SDI;
        Fighter_ZeroCPUInputs(cpu_data);
    }
    if ((cpu_data->state_id == ASID_GUARDSETOFF) || ((cpu_data->kind == 0xE) && (cpu_data->state_id == 344)))
    {
        Fighter_ZeroCPUInputs(cpu_data);

        // check if new shield hit
        if (eventData->cpu_lastshieldstun != cpu_data->moveID)
        {
            eventData->cpu_lastshieldstun = cpu_data->moveID;
            eventData->cpu_hitshieldnum++;
        }

        eventData->cpu_hitkind = HITKIND_SHIELD;
        eventData->cpu_state = CPUSTATE_SDI;
        // go to Shield state
        //eventData->cpu_state = CPUSTATE_SHIELD;
    }
    if ((cpu_data->state_id == ASID_DOWNBOUNDD) || (cpu_data->state_id == ASID_DOWNBOUNDU) || (cpu_data->state_id == ASID_DOWNWAITU) || (cpu_data->state_id == ASID_DOWNWAITD) || (cpu_data->state_id == ASID_PASSIVE) || (cpu_data->state_id == ASID_PASSIVESTANDB) || (cpu_data->state_id == ASID_PASSIVESTANDF))
        eventData->cpu_state = CPUSTATE_GETUP;
    if ((cpu_data->state_id == ASID_CLIFFWAIT))
        eventData->cpu_state = CPUSTATE_RECOVER;
    if (cpu_data->dead == 1)
        goto CPUSTATE_ENTERSTART;

    // run CPU state logic
    static char **CPUStates[] = {"CPUSTATE_START", "CPUSTATE_SDI", "CPUSTATE_TDI", "CPUSTATE_TECH", "CPUSTATE_GETUP", "CPUSTATE_COUNTER", "CPUSTATE_RECOVER"};
    //OSReport(CPUStates[eventData->cpu_state]);
    switch (eventData->cpu_state)
    {
    // Initial State, hasn't been hit yet
    case (CPUSTATE_START):
    CPULOGIC_START:
    {

        // if in the air somehow, enter recovery
        if (cpu_data->air_state == 1)
        {
            eventData->cpu_state = CPUSTATE_RECOVER;
            goto CPULOGIC_RECOVER;
        }

        // clear held inputs
        Fighter_ZeroCPUInputs(cpu_data);

        // perform default behavior
        int behavior = EvFreeOptions_CPU[OPTCPU_BEHAVE].option_val;
        switch (behavior)
        {
        case (CPUBEHAVE_STAND):
        {
            break;
        }

        case (CPUBEHAVE_SHIELD):
        {
            // hold R
            cpu_data->cpu.held = PAD_TRIGGER_R;
            break;
        }

        case (CPUBEHAVE_CROUCH):
        {
            // hold down
            cpu_data->cpu.lstickY = -127;
            break;
        }

        case (CPUBEHAVE_JUMP):
        {
            // run jump command
            LCancel_CPUPerformAction(cpu, 12, hmn);
            break;
        }
        }

        break;
    }

    case (CPUSTATE_SDI):
    CPULOGIC_SDI:
    {

        // update move instance
        if (eventData->cpu_lasthit != cpu_data->damage_instancehitby)
        {
            eventData->cpu_sincehit = 0;
            eventData->cpu_hitnum++;
            eventData->cpu_lasthit = cpu_data->damage_instancehitby;
            //OSReport("hit count %d/%d", eventData->cpu_hitnum, EvFreeOptions_CPU[OPTCPU_CTRHITS].option_val);
        }

        // if no more hitlag, enter tech state
        if (cpu_data->hitlag == 0)
        {
            eventData->cpu_state = CPUSTATE_TECH;
            goto CPULOGIC_TECH;
        }

        // if final frame of hitlag, enter TDI state
        else if (cpu_data->hitlag_frames == 1)
        {
            eventData->cpu_state = CPUSTATE_TDI;
            goto CPULOGIC_TDI;
        }

        // perform SDI behavior

        break;
    }

    case (CPUSTATE_TDI):
    CPULOGIC_TDI:
    {

        // if no more hitlag, enter tech state. this might never be hit, just being safe
        if (cpu_data->hitlag == 0)
        {
            eventData->cpu_state = CPUSTATE_TECH;
            goto CPULOGIC_TECH;
        }

        // perform TDI behavior
        int tdi_kind = EvFreeOptions_CPU[OPTCPU_TDI].option_val;
    TDI_SWITCH:
        switch (tdi_kind)
        {
        case (CPUTDI_RANDOM):
        {
            tdi_kind = HSD_Randi(CPUTDI_NUM - 1) + 1;
            goto TDI_SWITCH;
        }

        case (CPUTDI_IN):
        {
            // survival tdi = kb_angle + (XOriginDirection * -1 * pi/2)

            float kb_angle = atan2(cpu_data->kbVel.Y, cpu_data->kbVel.X);
            float orig_dir;
            if ((kb_angle > -M_PI / 2) && (kb_angle <= M_PI / 2))
                orig_dir = -1;
            else
                orig_dir = 1;

            // get optimal tdi
            float tdi_angle = kb_angle + (orig_dir * -1 * M_PI / 2);

            // convert to analog input
            cpu_data->cpu.lstickX = cos(tdi_angle) * 127;
            cpu_data->cpu.lstickY = sin(tdi_angle) * 127;

            break;
        }

        case (CPUTDI_OUT):
        TDI_OUT:
        {

            // combo tdi = kb_angle + (XOriginDirection * pi/2)

            float kb_angle = atan2(cpu_data->kbVel.Y, cpu_data->kbVel.X);
            float orig_dir;
            if ((kb_angle > -M_PI / 2) && (kb_angle <= M_PI / 2))
                orig_dir = -1;
            else
                orig_dir = 1;

            // get optimal tdi
            float tdi_angle = kb_angle + (orig_dir * M_PI / 2);

            // convert to analog input
            cpu_data->cpu.lstickX = cos(tdi_angle) * 127;
            cpu_data->cpu.lstickY = sin(tdi_angle) * 127;

            break;
        }

        case (CPUTDI_FLOORHUG):
        {

            // floothug = full ASDI down + outward DI
            cpu_data->cpu.cstickY = -127;
            goto TDI_OUT;

            break;
        }

        case (CPUTDI_CUSTOM):
        {

            int cpu_hitnum = eventData->cpu_hitnum;

            // ensure we have a DI input for this hitnum
            if (eventData->tdi_val_num >= cpu_hitnum)
            {

                cpu_hitnum--;

                // get the stick values for this hit num
                s8 lstickX = eventData->tdi_vals[cpu_hitnum][0][0];
                s8 lstickY = eventData->tdi_vals[cpu_hitnum][0][1];
                s8 cstickX = eventData->tdi_vals[cpu_hitnum][1][0];
                s8 cstickY = eventData->tdi_vals[cpu_hitnum][1][1];

                cpu_data->cpu.lstickX = ((float)lstickX / 80) / (0.0078125);
                cpu_data->cpu.lstickY = ((float)lstickY / 80) / (0.0078125);
                cpu_data->cpu.cstickX = ((float)cstickX / 80) / (0.0078125);
                cpu_data->cpu.cstickY = ((float)cstickY / 80) / (0.0078125);
            }

            break;
        }

        case (CPUTDI_NONE):
        {
            Fighter_ZeroCPUInputs(cpu_data);
            break;
        }
        }

        break;
    }

    case (CPUSTATE_TECH):
    CPULOGIC_TECH:
    {

        // if no more hitstun, go to counter
        if (cpu_data->hitstun == 0)
        {
            // also reset stick timer (messes with airdodge wiggle)
            cpu_data->input_lstick_x = 0;
            cpu_data->inputtimer_lstick_tilt_x = 254;
            eventData->cpu_state = CPUSTATE_COUNTER;
            goto CPULOGIC_COUNTER;
        }

        // perform tech behavior
        int tech_kind = EvFreeOptions_CPU[OPTCPU_TECH].option_val;
        s8 dir;
        s8 stickX = 0;
        s8 sincePress = 0;
        s8 since2Press = -1;
        s8 sinceXSmash = -1;
    TECH_SWITCH:
        switch (tech_kind)
        {
        case (CPUTECH_RANDOM):
        {
            tech_kind = (HSD_Randi((sizeof(EvFreeValues_Tech) / 4) - 1) + 1);
            goto TECH_SWITCH;
            break;
        }
        case (CPUTECH_NEUTRAL):
        {
            break;
        }
        case (CPUTECH_AWAY):
        {
            dir = Fighter_GetOpponentDir(cpu_data, hmn_data);
            stickX = 127 * (dir * -1);
            break;
        }
        case (CPUTECH_TOWARDS):
        {
            dir = Fighter_GetOpponentDir(cpu_data, hmn_data);
            stickX = 127 * (dir);
            break;
        }
        case (CPUTECH_NONE):
        {
            sincePress = -1;
            break;
        }
        }

        // input tech
        cpu_data->input_sinceLR = sincePress;
        cpu_data->input_sinceRapidLR = since2Press;
        cpu_data->cpu.lstickX = stickX;
        cpu_data->inputtimer_lstick_smash_x = sinceXSmash;

        break;
    }

    case (CPUSTATE_GETUP):
    CPULOGIC_GETUP:
    {

        // if im in downwait, perform getup logic
        if ((cpu_data->state_id == ASID_DOWNWAITD) || (cpu_data->state_id == ASID_DOWNWAITU))
        {
            // perform getup behavior
            int getup = EvFreeOptions_CPU[OPTCPU_GETUP].option_val;
            s8 dir;
            int inputs = 0;
            s8 stickX = 0;
            s8 stickY = 0;

        GETUP_SWITCH:
            switch (getup)
            {
            case (CPUGETUP_RANDOM):
            {
                getup = (HSD_Randi((sizeof(EvFreeValues_Tech) / 4) - 1) + 1);
                goto GETUP_SWITCH;
                break;
            }
            case (CPUGETUP_STAND):
            {
                stickY = 127;
                break;
            }
            case (CPUGETUP_TOWARD):
            {
                dir = Fighter_GetOpponentDir(cpu_data, hmn_data);
                stickX = 127 * (dir);
                break;
            }
            case (CPUGETUP_AWAY):
            {
                dir = Fighter_GetOpponentDir(cpu_data, hmn_data);
                stickX = 127 * (dir * -1);
                break;
            }
            case (CPUGETUP_ATTACK):
            {
                inputs = PAD_BUTTON_A;
                break;
            }
            }

            // input getup option
            cpu_data->cpu.held = inputs;
            cpu_data->cpu.lstickX = stickX;
            cpu_data->cpu.lstickY = stickY;
        }

        // if cpu is in any other down state, do nothing
        else if ((cpu_data->state_id >= ASID_DOWNBOUNDU) && (cpu_data->state_id <= ASID_DOWNSPOTD))
        {
            break;
        }

        // if cpu is not in a down state, enter COUNTER
        else
        {
            eventData->cpu_state = CPUSTATE_COUNTER;
            goto CPULOGIC_COUNTER;
            break;
        }

        break;
    }

    case (CPUSTATE_COUNTER):
    CPULOGIC_COUNTER:
    {

        // check if the CPU has been actionable yet
        if (eventData->cpu_isactionable == 0)
        {
            // check if actionable
            if (CPUAction_CheckActionable(cpu, 0) == 0)
            {
                break;
            }
            else
            {
                eventData->cpu_isactionable = 1;                  // set actionable flag to begin running code
                eventData->cpu_groundstate = cpu_data->air_state; // remember initial ground state
            }
        }

        // if started in the air, didnt finish action, but now grounded, perform ground action
        if ((eventData->cpu_groundstate == 1) && (cpu_data->air_state == 0))
        {
            eventData->cpu_groundstate = 0;
        }

        // increment frames since actionable
        eventData->cpu_sincehit++;

        // ensure hit count and frame count criteria are met
        int action_id;
        if (eventData->cpu_hitkind == HITKIND_DAMAGE)
        {
            if ((eventData->cpu_hitnum < EvFreeOptions_CPU[OPTCPU_CTRHITS].option_val) || (eventData->cpu_sincehit < EvFreeOptions_CPU[OPTCPU_CTRFRAMES].option_val))
            {
                break;
            }

            // get counter action
            if (cpu_data->air_state == 0 || (eventData->cpu_groundstate == 0)) // if am grounded or started grounded
            {
                int grndCtr = EvFreeOptions_CPU[OPTCPU_CTRGRND].option_val;
                action_id = GrAcLookup[grndCtr];
            }
            else if (cpu_data->air_state == 1) // only if in the air at the time of hitstun ending
            {
                int airCtr = EvFreeOptions_CPU[OPTCPU_CTRAIR].option_val;
                action_id = AirAcLookup[airCtr];
            }
        }
        else if (eventData->cpu_hitkind == HITKIND_SHIELD)
        {

            // if the shield wasnt hit enough times, return to start
            if (eventData->cpu_hitshieldnum < EvFreeOptions_CPU[OPTCPU_SHIELDHITS].option_val)
            {
                eventData->cpu_state = CPUSTATE_START;
                goto CPULOGIC_START;
                break;
            }

            // if this isnt the frame to counter, do nothing
            if (eventData->cpu_sincehit < EvFreeOptions_CPU[OPTCPU_CTRFRAMES].option_val)
            {
                break;
            }

            // get action to perform
            int shieldCtr = EvFreeOptions_CPU[OPTCPU_CTRSHIELD].option_val;
            action_id = ShieldAcLookup[shieldCtr];
        }
        else
        {
            // wasnt hit, fell or something idk. enter start again
            goto CPUSTATE_ENTERSTART;
        }

        // if none, enter recover
        if (action_id == 0)
        {
            eventData->cpu_state = CPUSTATE_RECOVER;
            goto CPULOGIC_RECOVER;
        }

        // perform counter behavior
        //OSReport("executing input");
        if (LCancel_CPUPerformAction(cpu, action_id, hmn) == 1)
        {
            eventData->cpu_state = CPUSTATE_RECOVER;
            //goto CPULOGIC_RECOVER;
        }

        break;
    }

    case (CPUSTATE_RECOVER):
    CPULOGIC_RECOVER:
    {

        // if onstage, go back to start
        if (cpu_data->air_state == 0)
        {

        CPUSTATE_ENTERSTART:
            // clear inputs

            // go to start
            eventData->cpu_state = CPUSTATE_START;
            eventData->cpu_hitshield = 0;
            eventData->cpu_hitnum = 0;
            eventData->cpu_sincehit = 0;
            eventData->cpu_hitshield = 0;
            eventData->cpu_lasthit = -1;
            eventData->cpu_lastshieldstun = -1;
            eventData->cpu_hitkind = -1;
            eventData->cpu_hitshieldnum = 0;
            eventData->cpu_isactionable = 0;
            goto CPULOGIC_START;
        }

        // recover with CPU AI
        cpu_data->cpu.ai = 0;

        break;
    }
    }

    // update cpu_hitshield
    if (eventData->cpu_hitshield == 0)
    {
        GOBJ *fighter = gobjlist[8];
        while (fighter != 0)
        {
            FighterData *fighter_data = fighter->userdata;

            // check if in guard off
            if (fighter_data->state_id == ASID_GUARDSETOFF)
            {
                eventData->cpu_hitshield = 1;
                break;
            }

            fighter = fighter->next;
        }
    }

    // update shield deterioration
    int infShield = EvFreeOptions_CPU[OPTCPU_SHIELD].option_val;
    if (infShield == 1)
    {
        if (eventData->cpu_hitshield == 0)
        {
            // inf shield
            GOBJ *fighter = gobjlist[8];
            while (fighter != 0)
            {
                FighterData *fighter_data = fighter->userdata;
                fighter_data->shield_health = 60;
                fighter = fighter->next;
            }
        }
    }
    else if (infShield == 2)
    {
        // inf shield
        GOBJ *fighter = gobjlist[8];
        while (fighter != 0)
        {
            FighterData *fighter_data = fighter->userdata;
            fighter_data->shield_health = 60;

            fighter = fighter->next;
        }
    }

    return;
}
int Update_CheckPause()
{

    HSD_Update *update = HSD_UPDATE;
    int isChange = 0;

    // check if enabled
    if (EvFreeOptions_General[OPTGEN_FRAME].option_val == 1)
    {
        // check if unpaused
        if (update->pause_develop != 1)
        {
            // pause
            isChange = 1;
        }
    }
    else
    {
        // check if paused
        if (update->pause_develop == 1)
        {
            // unpause
            isChange = 1;
        }
    }

    return isChange;
}
int Update_CheckAdvance()
{

    static int timer = 0;

    HSD_Update *update = HSD_UPDATE;
    int isAdvance = 0;

    int controller = Fighter_GetControllerPort(0);

    // get their pad
    HSD_Pad *pad = PadGet(controller, PADGET_MASTER);

    // check if holding L
    if ((pad->held & HSD_TRIGGER_L) != 0)
    {
        timer++;

        // advance if first press or holding more than 10 frames
        if (timer == 1 || timer > 30)
        {
            isAdvance = 1;

            // remove L input
            pad->down &= ~HSD_TRIGGER_L;
            pad->held &= ~HSD_TRIGGER_L;
            pad->triggerLeft = 0;
            pad->ftriggerLeft = 0;
        }
    }

    else
    {
        update->advance = 0;
        timer = 0;
    }

    return isAdvance;
}
void DIDraw_Init()
{

    // Create DIDraw GOBJ
    GOBJ *didraw_gobj = GObj_Create(0, 0, 0);
    // Add gxlink
    GObj_AddGXLink(didraw_gobj, DIDraw_GX, 6, 0);
    // init didraw pointers
    for (int i = 0; i < 6; i++)
    {
        // for each subchar
        for (int j = 0; j < 2; j++)
        {
            didraws[i].num[j] = 0;
            didraws[i].vertices[j] = 0;
        }
    }

    return;
}
void DIDraw_Update()
{

    static ECBBones ecb_bones_def = {
        .topY = 9,
        .botY = 2.5,
        .left = {-3.3, 5.7},
        .right = {3.3, 5.7},
    };

    // if enabled and pause menu isnt shown, update di draw
    if ((EvFreeOptions_General[OPTGEN_DI].option_val == 1)) //  && (Pause_CheckStatus(1) != 2)
    {
        // loop through all fighters
        GOBJList *gobj_list = R13_PTR(GOBJLIST);
        GOBJ *fighter = gobj_list->fighter;
        while (fighter != 0)
        {

            FighterData *fighter_data = fighter->userdata;
            int ply = fighter_data->ply;
            DIDraw *didraw = &didraws[ply];

            // if in hitlag and hitstun simulate and update trajectory
            if ((fighter_data->hitlag == 1) && (fighter_data->hitstun == 1))
            {
                // free old
                if (didraw->vertices[ply] != 0)
                {
                    HSD_Free(didraw->vertices[ply]);
                    didraw->num[ply] = 0;
                    didraw->vertices[ply] = 0;
                }

                //OSReport("######### BEGIN ##########\n");

                // get player's inputs
                float lstickX;
                float lstickY;
                float cstickX;
                float cstickY;
                // for HMN players
                if (Fighter_GetSlotType(fighter_data->ply) == 0)
                {
                    int input_kind;
                    if (Pause_CheckStatus(0) == 1) // if frame advance enabled, use master inputs
                        input_kind = PADGET_MASTER;
                    else
                        input_kind = PADGET_ENGINE; // no frame advance, use engine inputs
                    HSD_Pad *pad = PadGet(fighter_data->player_controller_number, input_kind);
                    lstickX = pad->fstickX;
                    lstickY = pad->fstickY;
                    cstickX = pad->fsubstickX;
                    cstickY = pad->fsubstickY;
                }
                // for CPUs
                else
                {
                    lstickX = fighter_data->input_lstick_x;
                    lstickY = fighter_data->input_lstick_y;
                    cstickX = fighter_data->input_cstick_x;
                    cstickY = fighter_data->input_cstick_y;
                }

                // get kb vector
                Vec3 kb = fighter_data->kbVel;
                float kb_angle = atan2(kb.Y, kb.X);
                // init ASDI vector
                Vec3 asdi_orig;
                Vec3 asdi = {0, 0, 0};
                // get fighter constants
                ftCommonData *ftCmDt = R13_PTR(PLCO_FTCOMMON);

                // Calculate ASDI
                float asdi_mag = pow(ftCmDt->asdi_mag, 2);
                float asdi_units = ftCmDt->asdi_units;
                // CStick has priority, check if mag > 0.7
                if (pow(cstickX, 2) + (pow(cstickY, 2)) >= asdi_mag)
                {
                    asdi.X = cstickX * asdi_units;
                    asdi.Y = cstickY * asdi_units;
                }
                // now check if lstick mag > 0.7
                else if (pow(lstickX, 2) + (pow(lstickY, 2)) >= asdi_mag)
                {
                    asdi.X = lstickX * asdi_units;
                    asdi.Y = lstickY * asdi_units;
                }
                // Remember original ASDI
                asdi_orig = asdi;
                //OSReport("ASDI:  %f , %f\n", asdi.X, asdi.Y);

                // Calculate TDI
                //OSReport("KB Pre TDI:  %f , %f\n", kb.X, kb.Y);
                if ((lstickX != 0) || (lstickY != 0)) // exclude input vector 0,0
                {
                    // kb vector must exceed 0.00001
                    float kb_mult = (kb.Y * kb.Y) + (kb.X * kb.X);
                    if (kb_mult >= 0.00001)
                    {

                        // get values
                        float tdi_input = pow((-1 * kb.X * lstickY) + (lstickX * kb.Y), 2) / kb_mult;
                        float max_angle = ftCmDt->tdi_maxAngle * M_1DEGREE;
                        float kb_mag = sqrtf(kb_mult);

                        // check to negate
                        Vec3 inputs = {lstickX, lstickY, 0};
                        Vec3 result;
                        VECCrossProduct(&kb, &inputs, &result);
                        if (result.Z < 0)
                            tdi_input *= -1;

                        // apply TDI
                        kb_angle = (max_angle * tdi_input) + kb_angle;

                        // New X KB
                        kb.X = cos(kb_angle) * kb_mag;
                        // New Y KB
                        kb.Y = sin(kb_angle) * kb_mag;
                    }
                }
                //OSReport("KB Post TDI:  %f , %f\n", kb.X, kb.Y);

                //simulation variables
                int air_state = fighter_data->air_state;
                float gravity = 0;
                Vec3 pos = fighter_data->pos;
                ftCommonData *ftCommon = R13_PTR(-0x514C);
                float decay = ftCommon->kb_frameDecay;
                int hitstun_frames = AS_FLOAT(fighter_data->stateVar1);
                int vertices_num = 0;    // used to track how many vertices will be needed
                int override_frames = 0; // used as an alternate countdown
                DIDrawCalculate *DICollData = calloc(sizeof(DIDrawCalculate) * hitstun_frames);
                CollData ecb;
                ECBBones ecb_bones;

                // init ecb struct
                Coll_InitECB(&ecb);
                if (fighter_data->air_state == 0) // copy ecb struct if grounded
                {
                    memcpy(&ecb.envFlags, &fighter_data->collData.envFlags, 0x28);
                }

                // simulate each frame of knockback
                for (int i = 0; i < hitstun_frames; i++)
                {

                    // update bone positions.  If loop count < noECBUpdate-remaining hitlag fraes, use current ECB bottom Y offset
                    if (vertices_num < (fighter_data->collData.ecb_lock - fighter_data->hitlag_frames))
                    {

                        ecb_bones.topY = fighter_data->collData.ecbCurr_top.Y;
                        ecb_bones.botY = fighter_data->collData.ecbCurr_bot.Y;
                        ecb_bones.left = fighter_data->collData.ecbCurr_left;
                        ecb_bones.right = fighter_data->collData.ecbCurr_right;

                        // if grounded, ECB bottom is 0
                        if (air_state == 0)
                        {
                            ecb_bones.botY = 0;
                        }
                    }
                    else
                    {
                        // use default ecb size
                        memcpy(&ecb_bones, &ecb_bones_def, sizeof(ECBBones));
                    }
                    // update ecb topN position
                    ecb.topN_Curr = pos;
                    ecb.topN_CurrCorrect = pos;

                    // apply ASDI
                    pos.X += asdi.X;
                    if (air_state != 0) // only apply Y asdi in the air
                    {
                        pos.Y += asdi.Y;
                    }
                    asdi.X = 0; // zero out ASDI
                    asdi.Y = 0; // zero out ASDI

                    // update gravity
                    gravity -= fighter_data->gravity;
                    float terminal_velocity = fighter_data->terminal_velocity * -1;
                    if (gravity < terminal_velocity)
                        gravity = terminal_velocity;
                    // decay KB vector
                    float angle = atan2(kb.Y, kb.X);
                    kb.X = kb.X - (cos(angle) * decay);
                    kb.Y = kb.Y - (sin(angle) * decay);

                    // add knockback
                    VECAdd(&pos, &kb, &pos);
                    // apply gravity
                    pos.Y += gravity;

                    // ecb prev = ecb curr
                    ecb.topN_Prev = ecb.topN_Curr;
                    // ecb curr = new position
                    ecb.topN_Curr = pos;

                    // only run X collision checks because theyre expensive
                    if (vertices_num >= DI_MaxColl)
                    {
                        DICollData[i].envFlags = 0; // spoof as not touching
                        pos = ecb.topN_Curr;        // position = projected
                    }

                    // update collision
                    else
                    {
                        // ground coll
                        if (air_state == 0)
                        {
                            int result = ECB_CollGround_PassLedge(&ecb, &ecb_bones);
                            if (result == 0)
                            {
                                air_state = 1;
                            }
                        }
                        // air coll
                        else
                        {
                            ECB_CollAir(&ecb, &ecb_bones);
                        }

                        // get corrected position
                        pos = ecb.topN_Curr;

                        // increment collision ID
                        ecb.coll_test += 1;

                        // perform stage collision code
                        if ((ecb.envFlags & ECB_GROUND) != 0)
                        {
                            // check if air->ground just occurred
                            if (air_state == 1)
                            {
                                // set grounded
                                air_state = 0;

                                // check if over max horizontal velocity
                                if (kb.X > ftCmDt->kb_maxVelX)
                                    kb.X = ftCmDt->kb_maxVelX;
                                if (kb.X < -ftCmDt->kb_maxVelX)
                                    kb.X = -ftCmDt->kb_maxVelX;

                                // adjust KB direction from slope
                                kb.X *= ecb.ground_slope.Y;
                                kb.Y *= ecb.ground_slope.X;

                                // zero out gravity
                                gravity = 0;

                                // zero out Y KB
                                kb.Y = 0;
                            }
                        }
                        else if ((ecb.envFlags & ECB_CEIL) != 0)
                        {
                            // only run this code when in the air
                            if (air_state == 1)
                            {
                                // combine KB and Gravity
                                Vec3 kb_temp = kb;
                                Vec3 vel_temp = {0, gravity, 0};
                                VECAdd(&vel_temp, &kb_temp, &vel_temp);

                                // apply slope
                                VECMultAndAdd(&vel_temp, &ecb.ceil_slope);

                                // decay kb
                                kb.X = vel_temp.X * ftCmDt->kb_bounceDecay;
                                kb.Y = vel_temp.Y * ftCmDt->kb_bounceDecay;
                            }
                        }
                        else if ((ecb.envFlags & (ECB_WALLLEFT | ECB_WALLRIGHT)) != 0)
                        {
                            // only run this code when in the air
                            if (air_state == 1)
                            {

                                // get slope
                                Vec3 *slope;
                                if ((ecb.envFlags & ECB_WALLLEFT) != 0)
                                {
                                    slope = &ecb.leftwall_slope;
                                }
                                else
                                {
                                    slope = &ecb.rightwall_slope;
                                }

                                // combine KB and Gravity
                                Vec3 kb_temp = kb;
                                Vec3 vel_temp = {0, gravity, 0};
                                VECAdd(&vel_temp, &kb_temp, &vel_temp);

                                // apply slope
                                VECMultAndAdd(&vel_temp, slope);

                                // decay kb
                                kb.X = vel_temp.X * ftCmDt->kb_bounceDecay;
                                kb.Y = vel_temp.Y * ftCmDt->kb_bounceDecay;

                                // zero gravity
                                gravity = 0;
                            }
                        }

                        // check for slide off
                        if (((ecb.envFlags & ECB_GROUND) == 0) && ((ecb.envFlags_prev & ECB_GROUND) != 0)) // not touching ground this frame, was touching last frame
                        {
                            if (override_frames == 0)
                                override_frames = 5; // terminate in 5 frames
                        }
                    }

                    //OSReport("Frame %d:\nPos: %f, %f\nKB: %f , %f\nVel: 0 , %f\n AirState: %d\n", vertices_num, pos.X, pos.Y, kb.X, kb.Y, gravity, air_state);

                    // save this position
                    DICollData[i].pos.X = pos.X;
                    DICollData[i].pos.Y = pos.Y;
                    DICollData[i].kb_Y = kb.Y;
                    DICollData[i].ECBLeftY = ecb_bones.left.Y;
                    DICollData[i].ECBTopY = ecb_bones.topY;

                    // inc vertices count
                    vertices_num++;

                    // if override frames are set, decrement and exit
                    if (override_frames > 0)
                    {
                        override_frames--;
                        if (override_frames == 0)
                            break;
                    }
                }

                // alloc draw struct
                didraw->num[ply] = vertices_num + 2; // +2 for ASDI vertices
                // alloc vertices
                didraw->vertices[ply] = calloc(sizeof(Vec2) * (vertices_num + 2));

                // save ASDI first
                didraw->vertices[ply][0].X = fighter_data->collData.topN_Curr.X;
                didraw->vertices[ply][0].Y = fighter_data->collData.topN_Curr.Y + fighter_data->collData.ecbCurr_left.Y;
                didraw->vertices[ply][1].X = fighter_data->collData.topN_Curr.X + asdi_orig.X;
                didraw->vertices[ply][1].Y = fighter_data->collData.topN_Curr.Y + fighter_data->collData.ecbCurr_left.Y + asdi_orig.Y;

                // save this info to the draw struct
                for (int i = 0; i < vertices_num; i++)
                {
                    didraw->vertices[ply][i + 2].X = DICollData[i].pos.X;
                    didraw->vertices[ply][i + 2].Y = DICollData[i].pos.Y + ((DICollData[i].ECBLeftY + DICollData[i].ECBTopY) / 2);

                    // get vertex color
                    static GXColor airColor = {0, 138, 255, 255};
                    static GXColor groundColor = {255, 255, 255, 255};
                    static GXColor ceilColor = {255, 0, 0, 255};
                    static GXColor wallColor = {0, 255, 0, 255};
                    GXColor *color;
                    if ((ecb.envFlags & ECB_GROUND) != 0)
                        color = &groundColor;
                    else if ((ecb.envFlags & ECB_CEIL) != 0)
                        color = &ceilColor;
                    else if ((ecb.envFlags & ECB_WALLLEFT | ECB_WALLRIGHT) != 0)
                        color = &wallColor;
                    else
                        color = &airColor;
                    // set vertex color
                    didraw->color.r = color->r;
                    didraw->color.g = color->g;
                    didraw->color.b = color->b;
                    didraw->color.a = color->a;
                }

                // free the collision info
                HSD_Free(DICollData);
            }
            // if not in hitstun, zero out didraw
            else if (fighter_data->hitstun == 0)
            {
                if (didraw->vertices[ply] != 0)
                {
                    HSD_Free(didraw->vertices[ply]);
                    didraw->num[ply] = 0;
                    didraw->vertices[ply] = 0;
                }
            }

            fighter = fighter->next;
        }
    }

    // is off, remove all di draw
    else
    {
        // all slots
        for (int i = 0; i < 6; i++)
        {
            DIDraw *didraw = &didraws[i];

            // all subchars
            for (int j = 0; j < 2; j++)
            {
                if (didraw->vertices[j] != 0)
                {
                    HSD_Free(didraw->vertices[j]);
                    didraw->num[j] = 0;
                    didraw->vertices[j] = 0;
                }
            }
        }
    }

    return;
}
void DIDraw_GX()
{

    // if toggle enabled
    if (EvFreeOptions_General[OPTGEN_DI].option_val == 1)
    {

        // draw each
        for (int i = 0; i < 6; i++)
        {
            // for each subchar
            for (int j = 0; j < 2; j++)
            {
                DIDraw *didraw = &didraws[i];
                // if it exists
                if (didraw->num != 0)
                {
                    int vertex_num = didraw->num[j];
                    Vec2 *vertices = didraw->vertices[j];

                    // alloc prim
                    PRIM *gx = PRIM_NEW(vertex_num, 0x001F1306, 0x00000C55);

                    // draw each
                    for (int k = 0; k < vertex_num; k++)
                    {
                        PRIM_DRAW(gx, vertices[k].X, vertices[k].Y, 0, 0x008affff);
                    }

                    // close
                    PRIM_CLOSE();
                }
            }
        }
    }
    return;
}
void Update_Camera()
{

    // if camera is set to advanced
    if (EvFreeOptions_General[OPTGEN_CAM].option_val == 3)
    {

        // Get player gobj
        GOBJ *fighter = Fighter_GetGObj(0);
        if (fighter != 0)
        {

            // get players inputs
            FighterData *fighter_data = fighter->userdata;
            HSD_Pad *pad = PadGet(fighter_data->player_controller_number, PADGET_MASTER);
            int held = pad->held;
            float stickX = pad->fsubstickX;
            float stickY = pad->fsubstickY;
            float deadzone = 0.2;

            if (fabs(stickX) < deadzone)
                stickX = 0;
            if (fabs(stickY) < deadzone)
                stickY = 0;

            // ensure stick exceeds deadzone
            if ((stickX != 0) || (stickY != 0))
            {
                COBJ *cobj = COBJ_GetMatchCamera();

                // adjust pan
                if ((held & HSD_BUTTON_A) != 0)
                {
                    DevCam_AdjustPan(cobj, stickX * -1, stickY * -1);
                }
                // adjust zoom
                else if ((held & HSD_BUTTON_Y) != 0)
                {
                    DevCam_AdjustZoom(cobj, stickY);
                }
                // adjust rotate
                else if ((held & HSD_BUTTON_B) != 0)
                {
                    MatchCamera *matchCam = MATCH_CAM;
                    DevCam_AdjustRotate(cobj, &matchCam->devcam_rot, &matchCam->devcam_pos, stickX, stickY);
                }
            }
        }
    }

    return;
}
void EvFree_SelectCustomTDI(GOBJ *menu_gobj)
{
    MenuData *menu_data = menu_gobj->userdata;
    EventMenu *curr_menu = menu_data->currMenu;
    evMenu *menuAssets = event_vars->menu_assets;
    GOBJ *event_gobj = event_vars->event_gobj;
    LCancelData *event_data = event_gobj->userdata;
    evLcAssets *evFreeAssets = event_data->assets;

    // set menu state to wait
    //curr_menu->state = EMSTATE_WAIT;

    // create bg gobj
    GOBJ *tdi_gobj = GObj_Create(0, 0, 0);
    TDIData *userdata = calloc(sizeof(TDIData));
    GObj_AddUserData(tdi_gobj, 4, HSD_Free, userdata);

    // load menu joint
    JOBJ *tdi_joint = JOBJ_LoadJoint(menuAssets->menu);
    GObj_AddObject(tdi_gobj, 3, tdi_joint);                                     // add to gobj
    GObj_AddGXLink(tdi_gobj, GXLink_Common, GXLINK_MENUMODEL, GXPRI_MENUMODEL); // add gx link
    menu_data->custom_gobj_think = CustomTDI_Update;                            // set callback

    // load current stick joints
    JOBJ *stick_joint = JOBJ_LoadJoint(event_data->assets->stick);
    stick_joint->scale.X = 2;
    stick_joint->scale.Y = 2;
    stick_joint->scale.Z = 2;
    stick_joint->trans.X = -6;
    stick_joint->trans.Y = -6;
    userdata->stick_curr[0] = stick_joint;
    JOBJ_AddChild(tdi_gobj->hsd_object, stick_joint);
    // current c stick
    stick_joint = JOBJ_LoadJoint(event_data->assets->cstick);
    stick_joint->scale.X = 2;
    stick_joint->scale.Y = 2;
    stick_joint->scale.Z = 2;
    stick_joint->trans.X = 6;
    stick_joint->trans.Y = -6;
    userdata->stick_curr[1] = stick_joint;
    JOBJ_AddChild(tdi_gobj->hsd_object, stick_joint);

    // create stick curr text
    Text *text_curr = Text_CreateText(2, menu_data->canvas_menu);
    userdata->text_curr = text_curr;
    // enable align and kerning
    text_curr->align = 0;
    text_curr->kerning = 1;
    // scale canvas
    text_curr->scale.X = MENU_CANVASSCALE;
    text_curr->scale.Y = MENU_CANVASSCALE;
    text_curr->trans.Z = MENU_TEXTZ;
    // create hit num
    Text_AddSubtext(text_curr, -50, 200, &nullString);
    // create lstick coords
    for (int i = 0; i < 2; i++)
    {
        Text_AddSubtext(text_curr, -400, (80 + i * 40), &nullString);
    }
    // create cstick coords
    for (int i = 0; i < 2; i++)
    {
        Text_AddSubtext(text_curr, 250, (80 + i * 40), &nullString);
    }

    // create prev sticks
    for (int i = 0; i < TDI_DISPNUM; i++)
    {
        // left stick
        JOBJ *prevstick_joint = JOBJ_LoadJoint(event_data->assets->stick);
        prevstick_joint->scale.X = 1;
        prevstick_joint->scale.Y = 1;
        prevstick_joint->scale.Z = 1;
        prevstick_joint->rot.X = 0.4;
        prevstick_joint->trans.X = -22 + (i * (55 / TDI_DISPNUM));
        prevstick_joint->trans.Y = 10;
        JOBJ_SetFlags(prevstick_joint, JOBJ_HIDDEN);
        userdata->stick_prev[i][0] = prevstick_joint;
        JOBJ_AddChild(tdi_gobj->hsd_object, prevstick_joint);

        // cstick
        prevstick_joint = JOBJ_LoadJoint(event_data->assets->cstick);
        prevstick_joint->scale.X = 1;
        prevstick_joint->scale.Y = 1;
        prevstick_joint->scale.Z = 1;
        prevstick_joint->rot.X = 0.4;
        prevstick_joint->trans.X = -18 + (i * (55 / TDI_DISPNUM));
        prevstick_joint->trans.Y = 8;
        JOBJ_SetFlags(prevstick_joint, JOBJ_HIDDEN);
        userdata->stick_prev[i][1] = prevstick_joint;
        JOBJ_AddChild(tdi_gobj->hsd_object, prevstick_joint);

        // create text
        Text_AddSubtext(text_curr, (-460 + (i * ((55 * 19.6) / TDI_DISPNUM))), -100, &nullString);
    }

    // create description text
    Text_AddSubtext(text_curr, -500, 270, "Input TDI angles for the CPU to use.");
    Text_AddSubtext(text_curr, -500, 315, "A = Save Input  X = Delete Input  B = Return");

    // hide original menu
    event_vars->hide_menu = 1;

    // set pointers to custom gobj
    menu_data->custom_gobj = tdi_gobj;
    menu_data->custom_gobj_destroy = CustomTDI_Destroy;

    return;

    /*
    // Change color
    GXColor gx_color = TEXT_BGCOLOR;
    popup_joint->dobj->mobj->mat->diffuse = gx_color;
*/
}
GOBJ *Record_Init()
{
    // Create GOBJ
    GOBJ *rec_gobj = GObj_Create(0, 7, 0);
    // Add per frame process
    GObj_AddProc(rec_gobj, Record_Think, 3);

    // create cobj
    GOBJ *cam_gobj = GObj_Create(19, 20, 0);
    COBJDesc ***dmgScnMdls = File_GetSymbol(ACCESS_PTR(0x804d6d5c), 0x803f94d0);
    COBJDesc *cam_desc = dmgScnMdls[1][0];
    COBJ *rec_cobj = COBJ_LoadDesc(cam_desc);
    // init camera
    GObj_AddObject(cam_gobj, R13_U8(-0x3E55), rec_cobj);
    GOBJ_InitCamera(cam_gobj, Record_CObjThink, RECCAM_GXPRI);
    cam_gobj->cobj_id = RECCAM_COBJGXLINK;

    evMenu *menuAssets = event_vars->menu_assets;
    JOBJ *playback = JOBJ_LoadJoint(menuAssets->playback);

    // save seek jobj
    JOBJ *seek;
    JOBJ_GetChild(playback, &seek, REC_SEEKJOINT, -1);
    rec_data.seek_jobj = seek;

    // save left and right seek bounds
    JOBJ *seek_bound[2];
    JOBJ_GetChild(playback, &seek_bound, REC_LEFTBOUNDJOINT, REC_RIGHTBOUNDJOINT, -1);
    Vec3 seek_bound_pos;
    JOBJ_GetWorldPosition(seek_bound[0], 0, &seek_bound_pos);
    rec_data.seek_left = seek_bound_pos.X;
    JOBJ_GetWorldPosition(seek_bound[1], 0, &seek_bound_pos);
    rec_data.seek_right = seek_bound_pos.X;

    // Add to gobj
    GObj_AddObject(rec_gobj, 3, playback);
    // Add gxlink
    GObj_AddGXLink(rec_gobj, Record_GX, GXLINK_RECJOINT, GXPRI_RECJOINT);

    // Create text
    int canvas_index = Text_CreateCanvas(2, rec_gobj, 14, 15, 0, GXLINK_RECTEXT, GXPRI_RECTEXT, 19);
    Text *text = Text_CreateText(2, canvas_index);
    text->align = 1;
    text->kerning = 1;
    text->scale.X = INFDISPTEXT_SCALE;
    text->scale.Y = INFDISPTEXT_SCALE;

    // Get text positions
    JOBJ *text_joint[2];
    JOBJ_GetChild(playback, &text_joint, REC_LEFTTEXTJOINT, REC_RIGHTTEXTJOINT, -1);
    Vec3 text_left, text_right;
    JOBJ_GetWorldPosition(text_joint[0], 0, &text_left);
    JOBJ_GetWorldPosition(text_joint[1], 0, &text_right);

    // Create subtexts for each side
    Text_AddSubtext(text, (text_left.X * 25), -(text_left.Y * 25), &nullString);
    Text_AddSubtext(text, (text_right.X * 25), -(text_right.Y) * 25, &nullString);
    rec_data.text = text;

    // set as not exist
    rec_state.is_exist = 0;

    // disable menu options
    for (int i = 1; i < sizeof(EvFreeOptions_Record) / sizeof(EventOption); i++)
    {
        EvFreeOptions_Record[i].disable = 1;
    }

    // init savestate struct
    for (int i = 0; i < sizeof(rec_state.ft_state) / 4; i++)
    {
        rec_state.ft_state[i] = 0;
    }

    // allocate input arrays
    for (int i = 0; i < REC_SLOTS; i++)
    {
        rec_data.hmn_inputs[i] = calloc(sizeof(RecInputData));
        rec_data.cpu_inputs[i] = calloc(sizeof(RecInputData));

        // init frame this recording starts on
        rec_data.hmn_inputs[i]->start_frame = -1;
        rec_data.cpu_inputs[i]->start_frame = -1;
    }

    return rec_gobj;
}
void Record_CObjThink(GOBJ *gobj)
{

    // hide UI if set to off
    if ((rec_state.is_exist == 1) && ((EvFreeOptions_Record[OPTREC_CPUMODE].option_val != 0) || (EvFreeOptions_Record[OPTREC_HMNMODE].option_val != 0)))
    {
        CObjThink_Common(gobj);
    }

    return;
}
void Record_GX(GOBJ *gobj, int pass)
{

    blr();

    // update UI position
    // the reason im doing this here is because i want it to update in the menu
    if (pass == 0)
    {
        // get hmn slot
        int hmn_slot = EvFreeOptions_Record[OPTREC_HMNSLOT].option_val;
        if (hmn_slot == 0) // use random slot
            hmn_slot = rec_data.hmn_rndm_slot;
        else
            hmn_slot--;

        // get cpu slot
        int cpu_slot = EvFreeOptions_Record[OPTREC_CPUSLOT].option_val;
        if (cpu_slot == 0) // use random slot
            cpu_slot = rec_data.cpu_rndm_slot;
        else
            cpu_slot--;

        RecInputData *hmn_inputs = rec_data.hmn_inputs[hmn_slot];
        RecInputData *cpu_inputs = rec_data.cpu_inputs[cpu_slot];
        JOBJ *seek = rec_data.seek_jobj;
        Text *text = rec_data.text;

        // get curr frame (the current position in the recording)
        int curr_frame = (event_vars->game_timer - 1) - rec_state.frame;

        // get what frame the longest recording ends on (savestate frame + recording start frame + recording time)
        int hmn_end_frame = 0;
        int cpu_end_frame = 0;
        if (hmn_inputs->start_frame != -1) // ensure a recording exists
        {
            hmn_end_frame = (hmn_inputs->start_frame + hmn_inputs->num);
        }
        if (cpu_inputs->start_frame != -1) // ensure a recording exists
        {
            cpu_end_frame = (cpu_inputs->start_frame + cpu_inputs->num);
        }

        // find the larger recording
        RecInputData *input_data = hmn_inputs;
        if (cpu_end_frame > hmn_end_frame)
            input_data = cpu_inputs;

        // get the frame the recording starts on. i actually hate this code and need to change how this works
        int rec_start;
        if (input_data->start_frame == -1) // case 1: recording didnt start, use current frame
        {
            rec_start = curr_frame - 1;
        }
        else // case 2: recording has started, use the frame saved
        {
            rec_start = input_data->start_frame - rec_state.frame;
        }

        // get end frame
        int end_frame = rec_start + input_data->num;

        // hide seek bar during recording
        if ((EvFreeOptions_Record[OPTREC_CPUMODE].option_val == 2) || (EvFreeOptions_Record[OPTREC_HMNMODE].option_val == 1))
        {
            JOBJ_SetFlags(seek, JOBJ_HIDDEN);

            // correct record frame
            if (curr_frame >= REC_LENGTH)
                curr_frame = REC_LENGTH;

            // update seek bar frames
            Text_SetText(text, 0, "%d", curr_frame + 1);
            Text_SetText(text, 1, &nullString);

            // update color
            GXColor text_color;
            if (curr_frame == REC_LENGTH)
            {
                text_color.r = 255;
                text_color.g = 57;
                text_color.b = 62;
            }
            else if (((float)curr_frame / (float)REC_LENGTH) >= 0.75)
            {
                text_color.r = 255;
                text_color.g = 124;
                text_color.b = 36;
            }
            else
            {
                text_color.r = 255;
                text_color.g = 255;
                text_color.b = 255;
            }
            Text_SetColor(text, 0, &text_color);
        }
        // during playback
        else
        {
            JOBJ_ClearFlags(seek, JOBJ_HIDDEN);

            // update seek bar position
            float range = rec_data.seek_right - rec_data.seek_left;
            float curr_pos;
            int local_frame_seek = curr_frame + 1;
            if (curr_frame >= end_frame)
                local_frame_seek = end_frame;
            curr_pos = (float)local_frame_seek / (float)end_frame;
            seek->trans.X = rec_data.seek_left + (curr_pos * range);
            JOBJ_SetMtxDirtySub(seek);

            // update seek bar frames
            Text_SetText(text, 0, "%d", local_frame_seek);
            Text_SetText(text, 1, "%d", end_frame);

            // update color
            GXColor text_color;
            text_color.r = 255;
            text_color.g = 255;
            text_color.b = 255;
            Text_SetColor(text, 0, &text_color);
        }
    }

    GXLink_Common(gobj, pass);

    return;
}
void Record_Think(GOBJ *rec_gobj)
{

    // get hmn slot
    int hmn_slot = EvFreeOptions_Record[OPTREC_HMNSLOT].option_val;
    if (hmn_slot == 0) // use random slot
        hmn_slot = rec_data.hmn_rndm_slot;
    else
        hmn_slot--;

    // get cpu slot
    int cpu_slot = EvFreeOptions_Record[OPTREC_CPUSLOT].option_val;
    if (cpu_slot == 0) // use random slot
        cpu_slot = rec_data.cpu_rndm_slot;
    else
        cpu_slot--;

    RecInputData *hmn_inputs = rec_data.hmn_inputs[hmn_slot];
    RecInputData *cpu_inputs = rec_data.cpu_inputs[cpu_slot];

    // ensure the state exists
    if (rec_state.is_exist == 1)
    {
        // get local frame
        int local_frame = (event_vars->game_timer - 1) - rec_state.frame;
        int input_num = hmn_inputs->num; // get longest recording
        if (cpu_inputs->num > hmn_inputs->num)
            input_num = cpu_inputs->num;

        // if at the end of the recording
        if ((input_num != 0) && (local_frame >= input_num))
        {
            // only if in playback
            if ((EvFreeOptions_Record[OPTREC_HMNMODE].option_val == 2) || (EvFreeOptions_Record[OPTREC_CPUMODE].option_val == 3))
            {

                // init flag
                int is_loop = 0;

                // check to auto reset
                if ((EvFreeOptions_Record[OPTREC_AUTOLOAD].option_val == 1))
                {
                    event_vars->Savestate_Load(&rec_state);
                    event_vars->game_timer = rec_state.frame + 1;
                    is_loop = 1;
                }

                // check to loop inputs
                else if ((EvFreeOptions_Record[OPTREC_LOOP].option_val == 1))
                {
                    event_vars->game_timer = rec_state.frame + 1;
                    is_loop = 1;
                }

                // if recording looped, check to re-roll random slot
                if (is_loop == 1)
                {
                    // re-roll random slot
                    if (EvFreeOptions_Record[OPTREC_HMNSLOT].option_val == 0)
                    {
                        rec_data.hmn_rndm_slot = Record_GetRandomSlot(&rec_data.hmn_inputs);
                    }
                    if (EvFreeOptions_Record[OPTREC_CPUSLOT].option_val == 0)
                    {
                        rec_data.cpu_rndm_slot = Record_GetRandomSlot(&rec_data.cpu_inputs);
                    }
                }
            }
        }

        // check record mode for HMN
        int hmn_mode = EvFreeOptions_Record[OPTREC_HMNMODE].option_val;
        if (hmn_mode > 0) // adjust mode
            hmn_mode++;
        Record_Update(0, hmn_inputs, hmn_mode);
        // check record mode for CPU
        int cpu_mode = EvFreeOptions_Record[OPTREC_CPUMODE].option_val;
        Record_Update(1, cpu_inputs, cpu_mode);
    }

    return;
}
void Record_Update(int ply, RecInputData *input_data, int rec_mode)
{

    GOBJ *fighter = Fighter_GetGObj(ply);
    FighterData *fighter_data = fighter->userdata;

    // get curr frame (the time since saving positions)
    int curr_frame = (event_vars->game_timer - rec_state.frame);

    // get the frame the recording starts on. i actually hate this code and need to change how this works
    int rec_start;
    if (input_data->start_frame == -1) // case 1: recording didnt start, use current frame
    {
        rec_start = curr_frame - 1;
    }
    else // case 2: recording has started, use the frame saved
    {
        rec_start = input_data->start_frame - rec_state.frame;
    }
    int end_frame = rec_start + input_data->num;

    // Get HSD Pad
    HSD_Pad *pad = PadGet(fighter_data->player_controller_number, PADGET_ENGINE);

    // if the current frame before the recording ends
    if ((curr_frame) < (rec_start + REC_LENGTH))
    {

        switch (rec_mode)
        {
        case RECMODE_OFF:
        {
            break;
        }
        case RECMODE_CTRL:
        {
            break;
        }
        case RECMODE_REC:
        {

            // recording has started BUT the player has jumped back behind it, move the start frame back
            if ((input_data->start_frame == -1) || (curr_frame < rec_start))
            {
                input_data->start_frame = (event_vars->game_timer - 1);
                rec_start = curr_frame - 1;
            }

            // store inputs
            int held = pad->held;
            RecInputs *inputs = &input_data->inputs[curr_frame - 1];
            inputs->btn_a = !!((held)&HSD_BUTTON_A);
            inputs->btn_b = !!((held)&HSD_BUTTON_B);
            inputs->btn_x = !!((held)&HSD_BUTTON_X);
            inputs->btn_y = !!((held)&HSD_BUTTON_Y);
            inputs->btn_L = !!((held)&HSD_TRIGGER_L);
            inputs->btn_R = !!((held)&HSD_TRIGGER_R);
            inputs->btn_Z = !!((held)&HSD_TRIGGER_Z);
            inputs->btn_dpadup = !!((held)&HSD_BUTTON_DPAD_UP);

            inputs->stickX = pad->stickX;
            inputs->stickY = pad->stickY;
            inputs->substickX = pad->substickX;
            inputs->substickY = pad->substickY;

            // trigger - find the one pressed down more
            u8 trigger = pad->triggerLeft;
            if (pad->triggerRight > trigger)
                trigger = pad->triggerRight;
            inputs->trigger = trigger;

            // update input_num
            input_data->num = (curr_frame - rec_start);

            // clear inputs henceforth
            //memset(&input_data->inputs[curr_frame + 1], 0, (REC_LENGTH - curr_frame) * sizeof(RecInputs));

            break;
        }
        case RECMODE_PLAY:
        {
            // ensure we have an input for this frame
            if ((curr_frame >= rec_start) && ((curr_frame - rec_start) <= (input_data->num)))
            {
                int held = 0;
                RecInputs *inputs = &input_data->inputs[curr_frame - 1];
                // read inputs
                held |= inputs->btn_a << 8;
                held |= inputs->btn_b << 9;
                held |= inputs->btn_x << 10;
                held |= inputs->btn_y << 11;
                held |= inputs->btn_L << 6;
                held |= inputs->btn_R << 5;
                held |= inputs->btn_Z << 4;
                held |= inputs->btn_dpadup << 3;
                pad->held = held;

                // stick signed bytes
                pad->stickX = inputs->stickX;
                pad->stickY = inputs->stickY;
                pad->substickX = inputs->substickX;
                pad->substickY = inputs->substickY;

                // stick floats
                pad->fstickX = ((float)inputs->stickX / 80);
                pad->fstickY = ((float)inputs->stickY / 80);
                pad->fsubstickX = ((float)inputs->substickX / 80);
                pad->fsubstickY = ((float)inputs->substickY / 80);

                // trigger byte
                pad->triggerRight = inputs->trigger;
                pad->triggerLeft = 0;

                // trigger float
                pad->ftriggerRight = ((float)inputs->trigger / 255);
                pad->ftriggerLeft = 0;
            }
            break;
        }
        }
    }

    return;
}
int Record_GetRandomSlot(RecInputData **input_data)
{

    // create array of slots in use
    u8 slot_num = 0;
    u8 arr[REC_SLOTS];
    for (int i = 0; i < REC_SLOTS; i++)
    {
        // if this recording slot is in use
        if (input_data[i]->num != 0)
        {
            arr[slot_num] = i;
            slot_num++;
        }
    }

    // ensure at least one slot found
    if (slot_num == 0)
    {
        return 0;
    }

    // get random slot in use
    return arr[(HSD_Randi(slot_num))];
}
void CustomTDI_Update(GOBJ *gobj)
{
    // get data
    TDIData *tdi_data = gobj->userdata;
    MenuData *menu_data = event_vars->menu_gobj->userdata;
    LCancelData *event_data = event_vars->event_gobj->userdata;

    // get player who paused
    u8 *pauseData = (u8 *)0x8046b6a0;
    u8 pauser = pauseData[1];
    // get their  inputs
    HSD_Pad *pad = PadGet(pauser, PADGET_MASTER);
    int inputs = pad->down;

    // if press A, save stick
    if ((inputs & HSD_BUTTON_A) != 0)
    {
        if (event_data->tdi_val_num < TDI_HITNUM)
        {
            event_data->tdi_vals[event_data->tdi_val_num][0][0] = (pad->fstickX * 80);
            event_data->tdi_vals[event_data->tdi_val_num][0][1] = (pad->fstickY * 80);
            event_data->tdi_vals[event_data->tdi_val_num][1][0] = (pad->fsubstickX * 80);
            event_data->tdi_vals[event_data->tdi_val_num][1][1] = (pad->fsubstickY * 80);
            event_data->tdi_val_num++;
            SFX_PlayCommon(1);
        }
    }

    // if press X, go back a hit
    if ((inputs & HSD_BUTTON_X) != 0)
    {
        if (event_data->tdi_val_num > 0)
        {
            event_data->tdi_val_num--;
            SFX_PlayCommon(0);
        }
    }

    // if press START, exit
    if ((inputs & HSD_BUTTON_B) != 0)
    {
        CustomTDI_Destroy(gobj);
        return;
    }

    // update curr lstick
    JOBJ *stick_curr = tdi_data->stick_curr[0];
    stick_curr->rot.Y = pad->fstickX * 0.75;
    stick_curr->rot.X = pad->fstickY * 0.75 * -1;
    // update curr cstick
    stick_curr = tdi_data->stick_curr[1];
    stick_curr->rot.Y = pad->fsubstickX * 0.75;
    stick_curr->rot.X = pad->fsubstickY * 0.75 * -1;

    // Update curr stick coordinates
    Text *text_curr = tdi_data->text_curr;
    Text_SetText(text_curr, 0, "Hit: %d", event_data->tdi_val_num + 1);
    Text_SetText(text_curr, 1, "X: %+.4f", pad->fstickX);
    Text_SetText(text_curr, 2, "Y: %+.4f", pad->fstickY);
    Text_SetText(text_curr, 3, "X: %+.4f", pad->fsubstickX);
    Text_SetText(text_curr, 4, "Y: %+.4f", pad->fsubstickY);

    // display previous sticks
    for (int i = 0; i < TDI_DISPNUM; i++)
    {
        JOBJ *lstick_prev = tdi_data->stick_prev[i][0];
        JOBJ *cstick_prev = tdi_data->stick_prev[i][1];
        int this_hit = i;
        if (event_data->tdi_val_num > TDI_DISPNUM)
            this_hit = (event_data->tdi_val_num - TDI_DISPNUM + i);

        // show stick
        if (i < event_data->tdi_val_num)
        {
            // remove hidden flag
            JOBJ_ClearFlags(lstick_prev, JOBJ_HIDDEN);
            JOBJ_ClearFlags(cstick_prev, JOBJ_HIDDEN);

            // update rotation
            lstick_prev->rot.Y = ((float)(event_data->tdi_vals[this_hit][0][0]) * 1 / 80) * 0.75;
            lstick_prev->rot.X = ((float)(event_data->tdi_vals[this_hit][0][1]) * 1 / 80) * 0.75 * -1;
            cstick_prev->rot.Y = ((float)(event_data->tdi_vals[this_hit][1][0]) * 1 / 80) * 0.75;
            cstick_prev->rot.X = ((float)(event_data->tdi_vals[this_hit][1][1]) * 1 / 80) * 0.75 * -1;

            // update text
            Text_SetText(text_curr, i + 5, "Hit %d", this_hit + 1);
        }
        // hide stick
        else
        {
            // set hidden flag
            JOBJ_SetFlags(lstick_prev, JOBJ_HIDDEN);
            JOBJ_SetFlags(cstick_prev, JOBJ_HIDDEN);

            Text_SetText(text_curr, i + 5, nullString);
        }
    }

    // update jobj
    JOBJ_SetMtxDirtySub(gobj->hsd_object);

    return;
}
void CustomTDI_Destroy(GOBJ *gobj)
{
    // get data
    TDIData *tdi_data = gobj->userdata;
    MenuData *menu_data = event_vars->menu_gobj->userdata;

    // set TDI to custom
    EvFreeOptions_CPU[OPTCPU_TDI].option_val = CPUTDI_CUSTOM;

    // free text
    Text_FreeText(tdi_data->text_curr);

    // destroy
    GObj_Destroy(gobj);

    // null pointers
    menu_data->custom_gobj = 0;
    menu_data->custom_gobj_destroy = 0;

    // show original menu
    event_vars->hide_menu = 0;

    return;
}

// Init Function
void Event_Init(GOBJ *gobj)
{
    LCancelData *eventData = gobj->userdata;
    EventInfo *eventInfo = eventData->eventInfo;
    GOBJ *hmn = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn->userdata;
    GOBJ *cpu = Fighter_GetGObj(1);
    FighterData *cpu_data = cpu->userdata;

    event_vars = *event_vars_ptr;

    // Init Info Display
    infodisp_gobj = InfoDisplay_Init(); // static pointer for update function

    // Init DIDraw
    DIDraw_Init();

    // Init Recording
    Record_Init();

    // store hsd_update functions
    HSD_Update *hsd_update = HSD_UPDATE;
    hsd_update->checkPause = Update_CheckPause;
    hsd_update->checkAdvance = Update_CheckAdvance;

    // determine cpu controller
    eventData->hmn_controller = Fighter_GetControllerPort(hmn_data->ply);
    u8 cpu_controller = 1;
    if (eventData->hmn_controller == 1)
        cpu_controller = 0;
    eventData->cpu_controller = cpu_controller;

    // set CPU AI to no_act 15
    cpu_data->cpu.ai = 0;

    // Load this events assets (EvMnLc.dat)
    int *symbols;
    File_LoadInitReturnSymbol("EvMnLc.dat", &symbols, "evMenu", 0);
    eventData->assets = &symbols[0];

    return;
}
// Update Function
void Event_Update()
{

    // update DI draw
    DIDraw_Update();

    // update info display
    InfoDisplay_Think(infodisp_gobj);

    // update advanced cam
    Update_Camera();
}
// Think Function
void Event_Think(GOBJ *event)
{
    LCancelData *eventData = event->userdata;

    // get fighter data
    GOBJ *hmn = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn->userdata;
    GOBJ *cpu = Fighter_GetGObj(1);
    FighterData *cpu_data = cpu->userdata;
    HSD_Pad *pad = PadGet(hmn_data->player_controller_number, PADGET_ENGINE);

    // update menu's percent
    EvFreeOptions_General[OPTGEN_HMNPCNT].option_val = hmn_data->damage_Percent;
    EvFreeOptions_CPU[OPTCPU_PCNT].option_val = cpu_data->damage_Percent;

    // reset stale moves
    if (EvFreeOptions_General[OPTGEN_STALE].option_val == 0)
    {
        for (int i = 0; i < 6; i++)
        {
            // check if fighter exists
            GOBJ *fighter = Fighter_GetGObj(i);
            if (fighter != 0)
            {
                // reset stale move table
                int *staleMoveTable = Fighter_GetStaleMoveTable(i);
                memset(staleMoveTable, 0, 0x2C);
            }
        }
    }

    // apply intangibility
    if (EvFreeOptions_CPU[OPTCPU_INTANG].option_val == 1)
    {
        cpu_data->no_reaction_always = 1;
        cpu_data->nudge_disable = 1;
        Fighter_ApplyOverlay(cpu_data, 9, 0);
        Fighter_UpdateOverlay(cpu);
        cpu_data->damage_Percent = 0;
        Fighter_SetHUDDamage(cpu_data->ply, 0);
    }
    else
    {
        cpu_data->no_reaction_always = 0;
        cpu_data->nudge_disable = 0;
    }

    // Move CPU
    if (pad->down == PAD_BUTTON_DPAD_DOWN)
    {
        // ensure player is grounded
        int isGround = 0;
        if (hmn_data->air_state == 0)
        {

            // check for ground in front of player
            Vec3 coll_pos;
            int line_index;
            int line_kind;
            Vec3 line_unk;
            float fromX = (hmn_data->pos.X) + (hmn_data->facing_direction * 10);
            float toX = fromX;
            float fromY = (hmn_data->pos.Y + 5);
            float toY = fromY - 10;
            isGround = Stage_RaycastGround(&coll_pos, &line_index, &line_kind, &line_unk, -1, -1, -1, 0, fromX, fromY, toX, toY, 0);
            if (isGround == 1)
            {
                // place CPU here
                cpu_data->pos = coll_pos;
                cpu_data->collData.ground_index = line_index;

                // facing player
                cpu_data->facing_direction = hmn_data->facing_direction * -1;

                // set grounded
                cpu_data->air_state = 0;
                //Fighter_SetGrounded(cpu);

                // enter wait
                Fighter_EnterWait(cpu);

                // update ECB
                cpu_data->collData.topN_Curr = cpu_data->pos; // move current ECB location to new position
                Coll_ECBCurrToPrev(&cpu_data->collData);
                cpu_data->cb_Coll(cpu);
            }
        }

        // play SFX
        if (isGround == 0)
        {
            SFX_PlayCommon(3);
        }
        else
        {
            SFX_Play(221);
        }
    }

    // Adjust control of fighters
    switch (EvFreeOptions_Record[OPTREC_CPUMODE].option_val)
    {
    case RECMODE_OFF:
    {
        // human is human
        hmn_data->player_controller_number = eventData->hmn_controller;

        // cpu is cpu
        Fighter_SetSlotType(cpu_data->ply, 1);
        cpu_data->player_controller_number = eventData->cpu_controller;

        break;
    }
    case RECMODE_PLAY:
    {

        // human is human
        hmn_data->player_controller_number = eventData->hmn_controller;

        // cpu is hmn
        Fighter_SetSlotType(cpu_data->ply, 0);
        cpu_data->player_controller_number = eventData->cpu_controller;

        break;
    }
    case RECMODE_CTRL:
    case RECMODE_REC:
    {
        // human is human
        hmn_data->player_controller_number = eventData->cpu_controller;

        // cpu is hmn
        Fighter_SetSlotType(cpu_data->ply, 0);
        cpu_data->player_controller_number = eventData->hmn_controller;

        break;
    }
    }

    // CPU Think if not using recording
    if (EvFreeOptions_Record[OPTREC_CPUMODE].option_val == 0)
        LCancel_CPUThink(event, hmn, cpu);

    return;
}
// Initial Menu
static EventMenu *Event_Menu = &EvFreeMenu_Main;