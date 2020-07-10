#include "events.h"

void Event_Init(GOBJ *gobj)
{
    int *EventData = gobj->userdata;
    EventInfo *eventInfo = EventData[0];
    OSReport("this is %s\n", eventInfo->eventName);
    //OSReport("%s", EvFreeOptions_Main[1].option_values[1]);
    return;
}

/////////////////////
// Mod Information //
/////////////////////

static char TM_Vers[] = {"Training Mode v3.0\n"};
static char TM_Compile[] = "COMPILED: " __DATE__ " " __TIME__;
static char Event_Controls[] = {"D-Pad Left = Load State\nD-Pad Right = Save State\n"};
static char nullString[] = " ";

////////////////////////
/// Event Defintions ///
////////////////////////

// L-Cancel Training

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
        0,                     // is the last input
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
        0,                 // is the last input
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
        127,                   // left stick X value
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
        -127,                  // left stick X value
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
        .onOptionChange = 0,
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
static char **EvFreeValues_InfoDisplay[] = {"None", "Position", "State Name", "State Frame", "Velocity - Self", "Velocity - KB", "Velocity - Total", "Engine LStick", "System LStick", "Engine CStick", "System CStick", "Engine Trigger", "System Trigger", "Ledgegrab Timer", "Intangibility Timer", "Hitlag", "Hitstun", "Shield Health", "Shield Stun", "Grip Strength", "ECB Lock", "ECB Bottom", "Jumps", "Walljumps", "Jab Counter", "Blastzone Left/Right", "Blastzone Up/Down"};
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
        .onOptionChange = 0,
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
static char **EvFreeValues_RecordSlot[] = {"Random", "Slot 1", "Slot 2", "Slot 3"};
static char **EvFreeValues_RecordMode[] = {"Record", "Playback"};
static EventOption EvFreeOptions_Record[] = {
    {
        .option_kind = OPTKIND_STRING,                    // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_RecordSlot) / 4, // number of values for this option
        .option_val = 1,                                  // value of this option
        .menu = 0,                                        // pointer to the menu that pressing A opens
        .option_name = "Record Slot",                     // pointer to a string
        .desc = "Toggle which slot to record to.",        // string describing what this option does
        .option_values = EvFreeValues_RecordSlot,         // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                               // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeValues_RecordMode) / 4,            // number of values for this option
        .option_val = 0,                                             // value of this option
        .menu = 0,                                                   // pointer to the menu that pressing A opens
        .option_name = "Mode",                                       // pointer to a string
        .desc = "Toggle between recording and playback of\ninputs.", // string describing what this option does
        .option_values = EvFreeValues_RecordMode,                    // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                          // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(EvFreeOptions_OffOn) / 4,           // number of values for this option
        .option_val = 0,                                        // value of this option
        .menu = 0,                                              // pointer to the menu that pressing A opens
        .option_name = "Reset After Playback",                  // pointer to a string
        .desc = "Automatically reset after the playback ends.", // string describing what this option does
        .option_values = EvFreeOptions_OffOn,                   // pointer to an array of strings
        .onOptionChange = 0,
    },
};
static EventMenu EvFreeMenu_Record = {
    .name = "Recording",              // the name of this menu
    .option_num = 3,                  // number of options this menu contains
    .scroll = 0,                      // runtime variable used for how far down in the menu to start
    .state = 0,                       // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                      // index of the option currently selected, used at runtime
    .options = &EvFreeOptions_Record, // pointer to all of this menu's options
    .prev = 0,                        // pointer to previous menu, used at runtime
};

// Static Variables
static DIDraw didraws[6];
static GOBJ *infodisp_gobj;

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
                        Text_SetText(text, i, "LStick:     (%+.4f , %+.4f)", fighter_data->input_lstick_x, fighter_data->input_lstick_y);
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
                        Stage *stage = STAGE;
                        Text_SetText(text, i, "Blastzone L/R: (%+.3f,%+.3f)", stage->blastzoneLeft, stage->blastzoneRight);
                        break;
                    }
                    case (25):
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
    u16 cpu_frame = cpu_data->stateFrame;

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

            OSReport("kb angle: %f\nsurvival tdi: %f\n", kb_angle, tdi_angle);

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

            OSReport("kb angle: %f\ncombo tdi: %f\n", kb_angle, tdi_angle);

            break;
        }

        case (CPUTDI_FLOORHUG):
        {

            // floothug = full ASDI down + outward DI
            cpu_data->cpu.cstickY = -127;
            goto TDI_OUT;

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

            OSReport("CPUSTATE_GETUP");
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

        // check if actionable
        if (CPUAction_CheckActionable(cpu, 0) != 1)
        {
            break;
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
            if (cpu_data->air_state == 0)
            {
                int grndCtr = EvFreeOptions_CPU[OPTCPU_CTRGRND].option_val;
                action_id = GrAcLookup[grndCtr];
            }
            else
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

    GOBJ *fighter = Fighter_GetGObj(0);
    if (fighter != 0)
    {
        FighterData *fighter_data = fighter->userdata;
        int controller = fighter_data->player_controller_number;

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
    }

    return isAdvance;
}
void Update_Savestates()
{

    // not when pause menu is showing
    if (Pause_CheckStatus(1) != 2)
    {
        // loop through all humans
        for (int i = 0; i < 6; i++)
        {
            // check if fighter exists
            GOBJ *fighter = Fighter_GetGObj(i);
            if (fighter != 0)
            {
                // get fighter data
                FighterData *fighter_data = fighter->userdata;
                HSD_Pad *pad = PadGet(fighter_data->ply, PADGET_MASTER);

                // check for savestate
                int blacklist = (HSD_BUTTON_DPAD_DOWN | HSD_BUTTON_DPAD_UP | HSD_TRIGGER_Z | HSD_TRIGGER_R | HSD_BUTTON_A | HSD_BUTTON_B | HSD_BUTTON_X | HSD_BUTTON_Y | HSD_BUTTON_START);
                if (((pad->down & HSD_BUTTON_DPAD_RIGHT) != 0) && ((pad->held & (blacklist)) == 0))
                {
                    // save state
                    Savestate_Save();
                }
                else if (((pad->down & HSD_BUTTON_DPAD_LEFT) != 0) && ((pad->held & (blacklist)) == 0))
                {
                    // load state
                    Savestate_Load();
                }
            }
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

                        blr();

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
GOBJ *EvFree_SelectCustomTDI(GOBJ *menu_gobj)
{
    MenuData *menu_data = menu_gobj->userdata;
    GOBJ *event_gobj = event_vars.event_gobj;
    LCancelData *event_data = event_gobj->userdata;
    evMenu *menuAssets = menu_data->menu_assets;
    evLcAssets *evFreeAssets = event_data->assets;
    EventMenu *curr_menu = menu_data->currMenu;

    // set menu state to wait
    curr_menu->state = EMSTATE_WAIT;

    /*
    // create gobj
    GOBJ *tdi_gobj = GObj_Create(0, 0, 0);
    TDIData *userdata = calloc(sizeof(TDIData));
    GObj_AddUserData(tdi_gobj, 4, HSD_Free, userdata);
    GObj_AddGXLink(tdi_gobj, CustomTDIThink_GX, GXLINK_MENUMODEL, GXPRI_POPUPMODEL);

    // save menu gobj
    userdata->menu_gobj = menu_gobj;

    // load bg joint
    JOBJ *bg_joint = JOBJ_LoadJoint(menuAssets->menu); //JOBJ_LoadJoint(evFreeAssets->stick);
    // add to gobj
    GObj_AddObject(tdi_gobj, 3, bg_joint);

    // Get each corner's joints
    JOBJ *corners[4];
    JOBJ_GetChild(bg_joint, &corners, 2, 3, 4, 5, -1);
    // Modify scale and position
    bg_joint->scale.X = POPUP_SCALE;
    bg_joint->scale.Y = POPUP_SCALE;
    bg_joint->scale.Z = POPUP_SCALE;
    bg_joint->trans.Z = POPUP_Z;
    corners[0]->trans.X = -(POPUP_WIDTH / 2);
    corners[0]->trans.Y = (POPUP_HEIGHT / 2);
    corners[1]->trans.X = (POPUP_WIDTH / 2);
    corners[1]->trans.Y = (POPUP_HEIGHT / 2);
    corners[2]->trans.X = -(POPUP_WIDTH / 2);
    corners[2]->trans.Y = -(POPUP_HEIGHT / 2);
    corners[3]->trans.X = (POPUP_WIDTH / 2);
    corners[3]->trans.Y = -(POPUP_HEIGHT / 2);
*/

    // create popup gobj
    GOBJ *popup_gobj = GObj_Create(0, 0, 0);

    // load popup joint
    JOBJ *popup_joint = JOBJ_LoadJoint(menuAssets->menu);

    // Get each corner's joints
    JOBJ *corners[4];
    JOBJ_GetChild(popup_joint, &corners, 2, 3, 4, 5, -1);

    // Modify scale and position
    popup_joint->scale.X = POPUP_SCALE;
    popup_joint->scale.Y = POPUP_SCALE;
    popup_joint->scale.Z = POPUP_SCALE;
    popup_joint->trans.Z = POPUP_Z;
    corners[0]->trans.X = -(POPUP_WIDTH / 2);
    corners[0]->trans.Y = (POPUP_HEIGHT / 2);
    corners[1]->trans.X = (POPUP_WIDTH / 2);
    corners[1]->trans.Y = (POPUP_HEIGHT / 2);
    corners[2]->trans.X = -(POPUP_WIDTH / 2);
    corners[2]->trans.Y = -(POPUP_HEIGHT / 2);
    corners[3]->trans.X = (POPUP_WIDTH / 2);
    corners[3]->trans.Y = -(POPUP_HEIGHT / 2);

    /*
    // Change color
    GXColor gx_color = TEXT_BGCOLOR;
    popup_joint->dobj->mobj->mat->diffuse = gx_color;
*/

    // add to gobj
    GObj_AddObject(popup_gobj, 3, popup_joint);
    // add gx link
    GObj_AddGXLink(popup_gobj, GXLink_Common, GXLINK_MENUMODEL, GXPRI_POPUPMODEL);

    return popup_gobj;

    /*
    // Change color
    GXColor gx_color = TEXT_BGCOLOR;
    popup_joint->dobj->mobj->mat->diffuse = gx_color;
*/
}
void CustomTDIThink_GX(GOBJ *gobj, int pass)
{
    if (pass == 0)
    {
        // get data
        TDIData *tdi_data = gobj->userdata;
        MenuData *menu_data = tdi_data->menu_gobj->userdata;

        // get player who paused
        u8 *pauseData = (u8 *)0x8046b6a0;
        u8 pauser = pauseData[1];
        // get their  inputs
        HSD_Pad *pad = PadGet(pauser, PADGET_MASTER);
        int inputs_rapid = pad->rapidFire;
        int inputs_held = pad->held;
        int inputs = inputs_rapid;
        if ((inputs_held & HSD_TRIGGER_R) != 0)
            inputs = inputs_held;

        // if press B, exit
        if ((inputs & HSD_BUTTON_B) != 0)
        {
            // set menu state to focus
            menu_data->currMenu->state = EMSTATE_FOCUS;

            // null pointer
            menu_data->custom_gobj = 0;

            // destroy
            GObj_Destroy(gobj);
        }
    }

    GXLink_Common(gobj, pass);

    return;
}

// Init Function
void LCancel_Init(GOBJ *gobj)
{
    LCancelData *eventData = gobj->userdata;
    EventInfo *eventInfo = eventData->eventInfo;
    GOBJ *hmn = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn->userdata;
    GOBJ *cpu = Fighter_GetGObj(1);
    FighterData *cpu_data = cpu->userdata;
    OSReport("this is %s\n", eventInfo->eventName);

    // Create Info Display GOBJ
    GOBJ *idGOBJ = GObj_Create(0, 0, 0);
    InfoDisplayData *idData = calloc(sizeof(InfoDisplayData));
    GObj_AddUserData(idGOBJ, 4, HSD_Free, idData);
    // Add per frame process
    //GObj_AddProc(idGOBJ, InfoDisplay_Think, 22);
    // Load jobj
    evMenu *menuAssets = R13_PTR(EVMENU_ASSETS);
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
    // static pointer for update function
    infodisp_gobj = idGOBJ;

    // Create text object
    int canvas_index = Text_CreateCanvas(2, gobj, 14, 15, 0, GXLINK_INFDISPTEXT, GXPRI_INFDISPTEXT, 19);
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

    // store hsd_update functions
    HSD_Update *hsd_update = HSD_UPDATE;
    hsd_update->checkPause = Update_CheckPause;
    hsd_update->checkAdvance = Update_CheckAdvance;

    // set CPU AI to no_act 15
    cpu_data->cpu.ai = 0;

    return;
}
// Update Function
void LCancel_Update()
{

    // update DI draw
    DIDraw_Update();

    // update info display
    InfoDisplay_Think(infodisp_gobj);

    // update advanced cam
    Update_Camera();

    // toggle hud
    if (Pause_CheckStatus(1) != 2)
    {
        // toggle HUD
        if (EvFreeOptions_General[OPTGEN_HUD].option_val == 0)
        {
            Match_HideHUD();
        }
        else
        {
            Match_ShowHUD();
        }
    }
}
// Think Function
void LCancel_Think(GOBJ *event)
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

    // CPU Think
    LCancel_CPUThink(event, hmn, cpu);

    return;
}

// Match Data
static EventMatchData LCancel_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .playMusic = false,
    .hideGo = true,
    .hideReady = true,
    .isCreateHUD = true,
    .isDisablePause = true,
    // byte 0x3
    .timerRunOnPause = false,   // 0x01
    .isHidePauseHUD = true,     // 0x02
    .isShowLRAStart = true,     // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true,       // 0x10
    .isCheckForZRetry = true,   // 0x20
    .isShowAnalogStick = true,  // 0x40
    .isShowScore = false,       // 0x80

    .isRunStockLogic = false, // 0x20
    .isDisableHit = false,    // 0x20
    .useKOCounter = false,
    .playerKind = -1,
    .cpuKind = -1,        // 0xFF=
    .stage = -1,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventInfo LCancel = {
    // Event Name
    .eventName = "L-Cancel Training\n",
    .eventDescription = "Practice L-Cancelling on\na stationary CPU.\n",
    .eventControls = "D-Pad Left = Load State\nD-Pad Right = Save State\n",
    .eventTutorial = "TvLC",
    .isChooseCPU = true,
    .isSelectStage = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .eventOnFrame = LCancel_Think,
    .eventOnInit = LCancel_Init,
    .eventUpdate = LCancel_Update,
    .matchData = &LCancel_MatchData,
    .startMenu = &EvFreeMenu_Main,
    .menuOptionNum = 0,
    .defaultOSD = 0xFFFFFFFF,
};

// Ledgedash Training
// Event Name
static char Ledgedash_Name[] = {"Ledgedash Training\n"};
// Event Description
static char Ledgedash_Desc[] = {"Practice Ledgedashes!\nUse D-Pad to change ledge.\n"};
// Event Tutorial Filename
static char Ledgedash_Tut[] = {"TvLedDa"};
// Event Menu Data
static char **Ledgedash_Stale[] = {"Off", "On"};
static char **Ledgedash_Intang[] = {"On", "Off"};
static MenuInfo Ledgedash_Menu[] =
    {
        {
            "Stale Attacks",
            Ledgedash_Stale,
            sizeof(Ledgedash_Stale) / 4,
        },
        {
            "Option2",
            Ledgedash_Intang,
            sizeof(Ledgedash_Intang) / 4,
        },
};
// Match Data
static EventMatchData Ledgedash_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = 2,         // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void Ledgedash_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo Ledgedash =
    {
        // Event Name
        &Ledgedash_Name,
        // Event Description
        &Ledgedash_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &Ledgedash_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        Ledgedash_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &Ledgedash_MatchData,
        // Menu Data
        &Ledgedash_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Combo_Name[] = {"Combo Training\n"};
// Event Description
static char Combo_Desc[] = {"L+DPad adjusts percent | DPadDown moves CPU\nDPad right/left saves and loads positions."};
// Event Tutorial Filename
static char Combo_Tut[] = {"TvLC"};
// Event Menu Data
static char **Combo_Stale[] = {"Off", "On"};
static char **Combo_Intang[] = {"On", "Off"};
static MenuInfo Combo_Menu[] =
    {
        {
            "Stale Attacks",
            Combo_Stale,
            sizeof(Combo_Stale) / 4,
        },
        {
            "Option2",
            Combo_Intang,
            sizeof(Combo_Intang) / 4,
        },
};
// Match Data
static EventMatchData Combo_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void Combo_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo Combo =
    {
        // Event Name
        &Combo_Name,
        // Event Description
        &Combo_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &Combo_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        Combo_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &Combo_MatchData,
        // Menu Data
        &Combo_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char AttackOnShield_Name[] = {"Attack on Shield\n"};
// Event Description
static char AttackOnShield_Desc[] = {"Practice attacks on a shielding opponent\nPause to change their OoS option\n"};
// Event Tutorial Filename
static char AttackOnShield_Tut[] = {"TvLC"};
// Event Menu Data
static char **AttackOnShield_Stale[] = {"Off", "On"};
static char **AttackOnShield_Intang[] = {"On", "Off"};
static MenuInfo AttackOnShield_Menu[] =
    {
        {
            "Stale Attacks",
            AttackOnShield_Stale,
            sizeof(AttackOnShield_Stale) / 4,
        },
        {
            "Option2",
            AttackOnShield_Intang,
            sizeof(AttackOnShield_Intang) / 4,
        },
};
// Match Data
static EventMatchData AttackOnShield_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void AttackOnShield_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo AttackOnShield =
    {
        // Event Name
        &AttackOnShield_Name,
        // Event Description
        &AttackOnShield_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &AttackOnShield_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        AttackOnShield_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &AttackOnShield_MatchData,
        // Menu Data
        &AttackOnShield_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Reversal_Name[] = {"Reversal Training\n"};
// Event Description
static char Reversal_Desc[] = {"Practice OoS punishes! DPad left/right\nmoves characters close and further apart."};
// Event Tutorial Filename
static char Reversal_Tut[] = {"TvLC"};
// Event Menu Data
static char **Reversal_Stale[] = {"Off", "On"};
static char **Reversal_Intang[] = {"On", "Off"};
static MenuInfo Reversal_Menu[] =
    {
        {
            "Stale Attacks",
            Reversal_Stale,
            sizeof(Reversal_Stale) / 4,
        },
        {
            "Option2",
            Reversal_Intang,
            sizeof(Reversal_Intang) / 4,
        },
};
// Match Data
static EventMatchData Reversal_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void Reversal_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo Reversal =
    {
        // Event Name
        &Reversal_Name,
        // Event Description
        &Reversal_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &Reversal_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        Reversal_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &Reversal_MatchData,
        // Menu Data
        &Reversal_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char SDI_Name[] = {"SDI Training\n"};
// Event Description
static char SDI_Desc[] = {"Use Smash DI to escape\nFox's up-air attack!"};
// Event Tutorial Filename
static char SDI_Tut[] = {"TvLC"};
// Event Menu Data
static char **SDI_Stale[] = {"Off", "On"};
static char **SDI_Intang[] = {"On", "Off"};
static MenuInfo SDI_Menu[] =
    {
        {
            "Stale Attacks",
            SDI_Stale,
            sizeof(SDI_Stale) / 4,
        },
        {
            "Option2",
            SDI_Intang,
            sizeof(SDI_Intang) / 4,
        },
};
// Match Data
static EventMatchData SDI_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void SDI_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo SDI =
    {
        // Event Name
        &SDI_Name,
        // Event Description
        &SDI_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &SDI_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        SDI_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &SDI_MatchData,
        // Menu Data
        &SDI_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Powershield_Name[] = {"Powershield Training\n"};
// Event Description
static char Powershield_Desc[] = {"Powershield Falco's laser!\nPause to change to fire-rate."};
// Event Tutorial Filename
static char Powershield_Tut[] = {"TvLC"};
// Event Menu Data
static char **Powershield_Stale[] = {"Off", "On"};
static char **Powershield_Intang[] = {"On", "Off"};
static MenuInfo Powershield_Menu[] =
    {
        {
            "Stale Attacks",
            Powershield_Stale,
            sizeof(Powershield_Stale) / 4,
        },
        {
            "Option2",
            Powershield_Intang,
            sizeof(Powershield_Intang) / 4,
        },
};
// Match Data
static EventMatchData Powershield_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void Powershield_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo Powershield =
    {
        // Event Name
        &Powershield_Name,
        // Event Description
        &Powershield_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &Powershield_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        Powershield_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &Powershield_MatchData,
        // Menu Data
        &Powershield_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Ledgetech_Name[] = {"Ledge-Tech Training\n"};
// Event Description
static char Ledgetech_Desc[] = {"Practice ledge-teching\nFalco's down-smash"};
// Event Tutorial Filename
static char Ledgetech_Tut[] = {"TvLC"};
// Event Menu Data
static char **Ledgetech_Stale[] = {"Off", "On"};
static char **Ledgetech_Intang[] = {"On", "Off"};
static MenuInfo Ledgetech_Menu[] =
    {
        {
            "Stale Attacks",
            Ledgetech_Stale,
            sizeof(Ledgetech_Stale) / 4,
        },
        {
            "Option2",
            Ledgetech_Intang,
            sizeof(Ledgetech_Intang) / 4,
        },
};
// Match Data
static EventMatchData Ledgetech_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void Ledgetech_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo Ledgetech =
    {
        // Event Name
        &Ledgetech_Name,
        // Event Description
        &Ledgetech_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &Ledgetech_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        Ledgetech_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &Ledgetech_MatchData,
        // Menu Data
        &Ledgetech_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char AmsahTech_Name[] = {"Amsah-Tech Training\n"};
// Event Description
static char AmsahTech_Desc[] = {"Taunt to have Marth Up-B,\nthen ASDI down and tech!\n"};
// Event Tutorial Filename
static char AmsahTech_Tut[] = {"TvLC"};
// Event Menu Data
static char **AmsahTech_Stale[] = {"Off", "On"};
static char **AmsahTech_Intang[] = {"On", "Off"};
static MenuInfo AmsahTech_Menu[] =
    {
        {
            "Stale Attacks",
            AmsahTech_Stale,
            sizeof(AmsahTech_Stale) / 4,
        },
        {
            "Option2",
            AmsahTech_Intang,
            sizeof(AmsahTech_Intang) / 4,
        },
};
// Match Data
static EventMatchData AmsahTech_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void AmsahTech_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo AmsahTech =
    {
        // Event Name
        &AmsahTech_Name,
        // Event Description
        &AmsahTech_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &AmsahTech_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        AmsahTech_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &AmsahTech_MatchData,
        // Menu Data
        &AmsahTech_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char ShieldDrop_Name[] = {"Shield Drop Training\n"};
// Event Description
static char ShieldDrop_Desc[] = {"Counter with a shield-drop aerial!\nDPad left/right moves players apart."};
// Event Tutorial Filename
static char ShieldDrop_Tut[] = {"TvLC"};
// Event Menu Data
static char **ShieldDrop_Stale[] = {"Off", "On"};
static char **ShieldDrop_Intang[] = {"On", "Off"};
static MenuInfo ShieldDrop_Menu[] =
    {
        {
            "Stale Attacks",
            ShieldDrop_Stale,
            sizeof(ShieldDrop_Stale) / 4,
        },
        {
            "Option2",
            ShieldDrop_Intang,
            sizeof(ShieldDrop_Intang) / 4,
        },
};
// Match Data
static EventMatchData ShieldDrop_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void ShieldDrop_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo ShieldDrop =
    {
        // Event Name
        &ShieldDrop_Name,
        // Event Description
        &ShieldDrop_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &ShieldDrop_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        ShieldDrop_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &ShieldDrop_MatchData,
        // Menu Data
        &ShieldDrop_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char WaveshineSDI_Name[] = {"Waveshine SDI\n"};
// Event Description
static char WaveshineSDI_Desc[] = {"Use Smash DI to get out\nof Fox's waveshine!"};
// Event Tutorial Filename
static char WaveshineSDI_Tut[] = {"TvLC"};
// Event Menu Data
static char **WaveshineSDI_Stale[] = {"Off", "On"};
static char **WaveshineSDI_Intang[] = {"On", "Off"};
static MenuInfo WaveshineSDI_Menu[] =
    {
        {
            "Stale Attacks",
            WaveshineSDI_Stale,
            sizeof(WaveshineSDI_Stale) / 4,
        },
        {
            "Option2",
            WaveshineSDI_Intang,
            sizeof(WaveshineSDI_Intang) / 4,
        },
};
// Match Data
static EventMatchData WaveshineSDI_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void WaveshineSDI_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo WaveshineSDI =
    {
        // Event Name
        &WaveshineSDI_Name,
        // Event Description
        &WaveshineSDI_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &WaveshineSDI_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        WaveshineSDI_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &WaveshineSDI_MatchData,
        // Menu Data
        &WaveshineSDI_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char SlideOff_Name[] = {"Slide-Off Training\n"};
// Event Description
static char SlideOff_Desc[] = {"Use Slide-Off DI to slide off\nthe platform and counter attack!\n"};
// Event Tutorial Filename
static char SlideOff_Tut[] = {"TvLC"};
// Event Menu Data
static char **SlideOff_Stale[] = {"Off", "On"};
static char **SlideOff_Intang[] = {"On", "Off"};
static MenuInfo SlideOff_Menu[] =
    {
        {
            "Stale Attacks",
            SlideOff_Stale,
            sizeof(SlideOff_Stale) / 4,
        },
        {
            "Option2",
            SlideOff_Intang,
            sizeof(SlideOff_Intang) / 4,
        },
};
// Match Data
static EventMatchData SlideOff_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void SlideOff_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo SlideOff =
    {
        // Event Name
        &SlideOff_Name,
        // Event Description
        &SlideOff_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &SlideOff_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        SlideOff_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &SlideOff_MatchData,
        // Menu Data
        &SlideOff_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char GrabMash_Name[] = {"Grab Mash Training\n"};
// Event Description
static char GrabMash_Desc[] = {"Mash buttons to escape the grab\nas quickly as possible!\n"};
// Event Tutorial Filename
static char GrabMash_Tut[] = {"TvLC"};
// Event Menu Data
static char **GrabMash_Stale[] = {"Off", "On"};
static char **GrabMash_Intang[] = {"On", "Off"};
static MenuInfo GrabMash_Menu[] =
    {
        {
            "Stale Attacks",
            GrabMash_Stale,
            sizeof(GrabMash_Stale) / 4,
        },
        {
            "Option2",
            GrabMash_Intang,
            sizeof(GrabMash_Intang) / 4,
        },
};
// Match Data
static EventMatchData GrabMash_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void GrabMash_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo GrabMash =
    {
        // Event Name
        &GrabMash_Name,
        // Event Description
        &GrabMash_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &GrabMash_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        GrabMash_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &GrabMash_MatchData,
        // Menu Data
        &GrabMash_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char TechCounter_Name[] = {"Ledgetech Marth Counter\n"};
// Event Description
static char TechCounter_Desc[] = {"Practice ledge-teching\nMarth's counter!\n"};
// Event Tutorial Filename
static char TechCounter_Tut[] = {"TvLC"};
// Event Menu Data
static char **TechCounter_Stale[] = {"Off", "On"};
static char **TechCounter_Intang[] = {"On", "Off"};
static MenuInfo TechCounter_Menu[] =
    {
        {
            "Stale Attacks",
            TechCounter_Stale,
            sizeof(TechCounter_Stale) / 4,
        },
        {
            "Option2",
            TechCounter_Intang,
            sizeof(TechCounter_Intang) / 4,
        },
};
// Match Data
static EventMatchData TechCounter_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void TechCounter_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo TechCounter =
    {
        // Event Name
        &TechCounter_Name,
        // Event Description
        &TechCounter_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &TechCounter_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        TechCounter_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &TechCounter_MatchData,
        // Menu Data
        &TechCounter_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char ArmadaShine_Name[] = {"Armada-Shine Training\n"};
// Event Description
static char ArmadaShine_Desc[] = {"Finish the enemy Fox\nwith an Armada Shine!"};
// Event Tutorial Filename
static char ArmadaShine_Tut[] = {"TvLC"};
// Event Menu Data
static char **ArmadaShine_Stale[] = {"Off", "On"};
static char **ArmadaShine_Intang[] = {"On", "Off"};
static MenuInfo ArmadaShine_Menu[] =
    {
        {
            "Stale Attacks",
            ArmadaShine_Stale,
            sizeof(ArmadaShine_Stale) / 4,
        },
        {
            "Option2",
            ArmadaShine_Intang,
            sizeof(ArmadaShine_Intang) / 4,
        },
};
// Match Data
static EventMatchData ArmadaShine_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void ArmadaShine_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo ArmadaShine =
    {
        // Event Name
        &ArmadaShine_Name,
        // Event Description
        &ArmadaShine_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &ArmadaShine_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        ArmadaShine_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &ArmadaShine_MatchData,
        // Menu Data
        &ArmadaShine_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char SideBSweet_Name[] = {"Side-B Sweetspot\n"};
// Event Description
static char SideBSweet_Desc[] = {"Use a sweetspot Side-B to avoid Marth's\ndown-tilt and grab the ledge!"};
// Event Tutorial Filename
static char SideBSweet_Tut[] = {"TvLC"};
// Event Menu Data
static char **SideBSweet_Stale[] = {"Off", "On"};
static char **SideBSweet_Intang[] = {"On", "Off"};
static MenuInfo SideBSweet_Menu[] =
    {
        {
            "Stale Attacks",
            SideBSweet_Stale,
            sizeof(SideBSweet_Stale) / 4,
        },
        {
            "Option2",
            SideBSweet_Intang,
            sizeof(SideBSweet_Intang) / 4,
        },
};
// Match Data
static EventMatchData SideBSweet_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void SideBSweet_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo SideBSweet =
    {
        // Event Name
        &SideBSweet_Name,
        // Event Description
        &SideBSweet_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &SideBSweet_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        SideBSweet_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &SideBSweet_MatchData,
        // Menu Data
        &SideBSweet_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char EscapeSheik_Name[] = {"Escape Sheik Techchase\n"};
// Event Description
static char EscapeSheik_Desc[] = {"Practice escaping the tech chase with a\nframe perfect shine or jab SDI!\n"};
// Event Tutorial Filename
static char EscapeSheik_Tut[] = {"TvLC"};
// Event Menu Data
static char **EscapeSheik_Stale[] = {"Off", "On"};
static char **EscapeSheik_Intang[] = {"On", "Off"};
static MenuInfo EscapeSheik_Menu[] =
    {
        {
            "Stale Attacks",
            EscapeSheik_Stale,
            sizeof(EscapeSheik_Stale) / 4,
        },
        {
            "Option2",
            EscapeSheik_Intang,
            sizeof(EscapeSheik_Intang) / 4,
        },
};
// Match Data
static EventMatchData EscapeSheik_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void EscapeSheik_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo EscapeSheik =
    {
        // Event Name
        &EscapeSheik_Name,
        // Event Description
        &EscapeSheik_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &EscapeSheik_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        EscapeSheik_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &EscapeSheik_MatchData,
        // Menu Data
        &EscapeSheik_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Eggs_Name[] = {"Eggs-ercise\n"};
// Event Description
static char Eggs_Desc[] = {"Break the eggs! Only strong hits will\nbreak them. DPad down = free practice."};
// Event Tutorial Filename
static char Eggs_Tut[] = {"TvLC"};
// Event Menu Data
static char **Eggs_Stale[] = {"Off", "On"};
static char **Eggs_Intang[] = {"On", "Off"};
static MenuInfo Eggs_Menu[] =
    {
        {
            "Stale Attacks",
            Eggs_Stale,
            sizeof(Eggs_Stale) / 4,
        },
        {
            "Option2",
            Eggs_Intang,
            sizeof(Eggs_Intang) / 4,
        },
};
// Match Data
static EventMatchData Eggs_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void Eggs_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo Eggs =
    {
        // Event Name
        &Eggs_Name,
        // Event Description
        &Eggs_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &Eggs_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        Eggs_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &Eggs_MatchData,
        // Menu Data
        &Eggs_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Multishine_Name[] = {"Shined Blind\n"};
// Event Description
static char Multishine_Desc[] = {"How many shines can you\nperform in 10 seconds?"};
// Event Tutorial Filename
static char Multishine_Tut[] = {"TvLC"};
// Event Menu Data
static char **Multishine_Stale[] = {"Off", "On"};
static char **Multishine_Intang[] = {"On", "Off"};
static MenuInfo Multishine_Menu[] =
    {
        {
            "Stale Attacks",
            Multishine_Stale,
            sizeof(Multishine_Stale) / 4,
        },
        {
            "Option2",
            Multishine_Intang,
            sizeof(Multishine_Intang) / 4,
        },
};
// Match Data
static EventMatchData Multishine_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void Multishine_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo Multishine =
    {
        // Event Name
        &Multishine_Name,
        // Event Description
        &Multishine_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &Multishine_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        Multishine_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &Multishine_MatchData,
        // Menu Data
        &Multishine_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Reaction_Name[] = {"Reaction Test\n"};
// Event Description
static char Reaction_Desc[] = {"Test your reaction time by pressing\nany button when you see/hear Fox shine!"};
// Event Tutorial Filename
static char Reaction_Tut[] = {"TvLC"};
// Event Menu Data
static char **Reaction_Stale[] = {"Off", "On"};
static char **Reaction_Intang[] = {"On", "Off"};
static MenuInfo Reaction_Menu[] =
    {
        {
            "Stale Attacks",
            Reaction_Stale,
            sizeof(Reaction_Stale) / 4,
        },
        {
            "Option2",
            Reaction_Intang,
            sizeof(Reaction_Intang) / 4,
        },
};
// Match Data
static EventMatchData Reaction_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void Reaction_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo Reaction =
    {
        // Event Name
        &Reaction_Name,
        // Event Description
        &Reaction_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &Reaction_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        Reaction_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &Reaction_MatchData,
        // Menu Data
        &Reaction_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Ledgestall_Name[] = {"Under Fire\n"};
// Event Description
static char Ledgestall_Desc[] = {"Ledgestall to remain\ninvincible while the lava rises!\n"};
// Event Tutorial Filename
static char Ledgestall_Tut[] = {"TvLC"};
// Event Menu Data
static char **Ledgestall_Stale[] = {"Off", "On"};
static char **Ledgestall_Intang[] = {"On", "Off"};
static MenuInfo Ledgestall_Menu[] =
    {
        {
            "Stale Attacks",
            Ledgestall_Stale,
            sizeof(Ledgestall_Stale) / 4,
        },
        {
            "Option2",
            Ledgestall_Intang,
            sizeof(Ledgestall_Intang) / 4,
        },
};
// Match Data
static EventMatchData Ledgestall_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = true,
        .hideGo = true,
        .hideReady = true,
        .isCreateHUD = true,
        .isDisablePause = false,
        // byte 0x3
        .timerRunOnPause = false,   // 0x01
        .isHidePauseHUD = true,     // 0x02
        .isShowLRAStart = true,     // 0x04
        .isCheckForLRAStart = true, // 0x08
        .isShowZRetry = true,       // 0x10
        .isCheckForZRetry = true,   // 0x20
        .isShowAnalogStick = true,  // 0x40
        .isShowScore = false,       // 0x80

        .isRunStockLogic = false, // 0x20
        .isDisableHit = false,    // 0x20
        .useKOCounter = false,
        .playerKind = -1,
        .cpuKind = -1,        // 0xFF=
        .stage = -1,          // 0xFFFF
        .timerSeconds = 0,    // 0xFFFFFFFF
        .timerSubSeconds = 0, // 0xFF
        .onCheckPause = 0,
        .onMatchEnd = 0,
};
// Think Function
void Ledgestall_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo Ledgestall =
    {
        // Event Name
        &Ledgestall_Name,
        // Event Description
        &Ledgestall_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        &Ledgestall_Tut,
        // isChooseCPU
        true,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        Ledgestall_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &Ledgestall_MatchData,
        // Menu Data
        &Ledgestall_Menu,
        // Menu Option Amount
        0,
        // Default OSDs
        0xFFFFFFFF,
};

///////////////////////
/// Page Defintions ///
///////////////////////

// Minigames
static EventInfo *Minigames_Events[] = {
    &Eggs,
    &Multishine,
    &Reaction,
    &Ledgestall,
};
static EventPage Minigames_Page = {
    .name = "Minigames",
    (sizeof(Minigames_Events) / 4) - 1,
    Minigames_Events,
};

// Page 2 Events
static EventInfo *General_Events[] = {
    // Event 1 - L-Cancel Training
    &LCancel,
    &Ledgedash,
    &Combo,
    &AttackOnShield,
    &Reversal,
    &SDI,
    &Powershield,
    &Ledgetech,
    &AmsahTech,
    &ShieldDrop,
    &WaveshineSDI,
    &SlideOff,
    &GrabMash,
};
static EventPage General_Page = {
    .name = "General Tech",
    (sizeof(General_Events) / 4) - 1,
    General_Events,
};

// Page 3 Events
static EventInfo *Spacie_Events[] = {
    &TechCounter,
    &ArmadaShine,
    &SideBSweet,
    &EscapeSheik,
};
static EventPage Spacie_Page = {
    .name = "Spacie Tech",
    (sizeof(Spacie_Events) / 4) - 1,
    Spacie_Events,
};

//////////////////
/// Page Order ///
//////////////////

static EventPage **EventPages[] = {
    &Minigames_Page,
    &General_Page,
    &Spacie_Page,
};

////////////////////////
/// Static Variables ///
////////////////////////

static Savestate *savestates[6];
static EventInfo *static_eventInfo;
static MenuData *static_menuData;
static EventVars event_vars;
static int *eventDataBackup;

///////////////////////
/// Event Functions ///
///////////////////////

void EventInit(int page, int eventID, MatchData *matchData)
{

    // get event pointer
    EventInfo *event = GetEvent(page, eventID);

    //Init default match info
    matchData->timer_unk2 = 0;
    matchData->unk2 = 1;
    matchData->unk7 = 1;
    matchData->isCheckStockSteal = 1;
    matchData->unk10 = 3;
    matchData->isSkipEndCheck = 1;
    matchData->itemFreq = MATCH_ITEMFREQ_OFF;
    matchData->onStartMelee = EventLoad;

    //Copy event's match info struct
    EventMatchData *eventMatchData = event->matchData;
    matchData->timer = eventMatchData->timer;
    matchData->matchType = eventMatchData->matchType;
    matchData->playMusic = eventMatchData->playMusic;
    matchData->hideGo = eventMatchData->hideGo;
    matchData->hideReady = eventMatchData->hideReady;
    matchData->isCreateHUD = eventMatchData->isCreateHUD;
    matchData->isDisablePause = eventMatchData->isDisablePause;
    matchData->timerRunOnPause = eventMatchData->timerRunOnPause;
    matchData->isHidePauseHUD = eventMatchData->isHidePauseHUD;
    matchData->isShowLRAStart = eventMatchData->isShowLRAStart;
    matchData->isCheckForLRAStart = eventMatchData->isCheckForLRAStart;
    matchData->isShowZRetry = eventMatchData->isShowZRetry;
    matchData->isCheckForZRetry = eventMatchData->isCheckForZRetry;
    matchData->isShowAnalogStick = eventMatchData->isShowAnalogStick;
    matchData->isShowScore = eventMatchData->isShowScore;
    matchData->isRunStockLogic = eventMatchData->isRunStockLogic;
    matchData->isDisableHit = eventMatchData->isDisableHit;
    matchData->timerSeconds = eventMatchData->timerSeconds;
    matchData->timerSubSeconds = eventMatchData->timerSubSeconds;
    matchData->onCheckPause = eventMatchData->onCheckPause;
    matchData->onMatchEnd = eventMatchData->onMatchEnd;

    // Initialize all player data
    Memcard *memcard = R13_PTR(MEMCARD);
    CSSBackup eventBackup = memcard->EventBackup;
    for (int i = 0; i < 6; i++)
    {
        // initialize data
        CSS_InitPlayerData(&matchData->playerData[i]);

        // set to enter fall on match start
        matchData->playerData[i].isEntry = false;

        // copy nametag id for the player
        if (i == 0)
        {
            // Update the player's nametag ID
            matchData->playerData[i].nametag = eventBackup.nametag;

            // Update the player's rumble setting
            int tagRumble = CSS_GetNametagRumble(0, matchData->playerData[0].nametag);
            matchData->playerData[0].isRumble = tagRumble;
        }
    }

    // Determine the Player
    s32 playerKind;
    s32 playerCostume;
    Preload *preload = 0x80432078;
    // If fighter is -1, copy the player from event data
    if (eventMatchData->playerKind != -1)
    {
        playerKind = eventMatchData->playerKind;
        playerCostume = 0;
    }
    // use the fighter chosen on the CSS
    else
    {
        playerKind = preload->fighters[0].kind;
        playerCostume = preload->fighters[0].costume;
    }

    // Determine the CPU
    s32 cpuKind;
    s32 cpuCostume;
    // If isChooseCPU is true, use the selected CPU
    if (event->isChooseCPU == true)
    {
        cpuKind = preload->fighters[1].kind;
        cpuCostume = preload->fighters[1].costume;
    }
    // If isChooseCPU is false, copy the CPU from event data
    else
    {
        cpuKind = eventMatchData->cpuKind;
        cpuCostume = 0;
        cpuCostume = 0;
    }

    // Check if CPU is using the same character and color as P1
    if ((playerKind == cpuKind) && (playerCostume == cpuCostume))
    {
        // this doesnt account for if theyre both using the last costume
        cpuCostume += 1;
    }

    // Copy player data to match info struct (update their rumble setting 801bb1ec)
    matchData->playerData[0].kind = playerKind;
    matchData->playerData[0].costume = playerCostume;
    matchData->playerData[0].status = 0;
    // Copy CPU if they exist for this event
    if (cpuKind != -1)
    {
        matchData->playerData[1].kind = cpuKind;
        matchData->playerData[1].costume = cpuCostume;
        matchData->playerData[1].status = 1;
    }

    // Determine the correct HUD position for this amount of players
    int hudPos = 0;
    for (int i = 0; i < 6; i++)
    {
        if (matchData->playerData[i].status != 3)
            hudPos++;
    }
    matchData->hudPos = hudPos;

    // Determine the Stage
    int stage;
    // If isSelectStage is true, use the selected stage
    if (event->isSelectStage == true)
    {
        stage = preload->stage;
    }
    // If isSelectStage is false, copy the stage from event data
    else
    {
        stage = eventMatchData->stage;
    }
    // Update match struct with this stage
    matchData->stage = stage;

    //Update preload table? (801bb63c)

    return;
};

void EventLoad()
{
    // get this event
    Memcard *memcard = R13_PTR(MEMCARD);
    int page = memcard->TM_EventPage;
    int eventID = memcard->EventBackup.event;
    EventInfo *eventInfo = GetEvent(page, eventID);

    // Create this event's gobj
    int pri = eventInfo->callbackPriority;
    void *cb = eventInfo->eventOnFrame;
    GOBJ *gobj = GObj_Create(0, 7, 0);
    int *userdata = calloc(EVENT_DATASIZE);
    GObj_AddUserData(gobj, 4, HSD_Free, userdata);
    GObj_AddProc(gobj, cb, pri);

    // store pointer to the event's data
    userdata[0] = eventInfo;

    // init the pause menu
    GOBJ *menu_gobj = EventMenu_Init(eventInfo);

    // init savestate struct
    eventDataBackup = calloc(EVENT_DATASIZE);
    for (int i = 0; i < sizeof(savestates) / 4; i++)
    {
        savestates[i] = 0;
    }

    // Run this event's init function
    if (eventInfo->eventOnInit != 0)
    {
        eventInfo->eventOnInit(gobj);
    }

    // Store update function
    HSD_Update *update = HSD_UPDATE;
    update->onFrame = EventUpdate;

    // Init static structure containing event variables
    event_vars.event_info = eventInfo;
    event_vars.event_gobj = gobj;
    event_vars.menu_gobj = menu_gobj;
    R13_PTR(EVENT_VAR) = &event_vars;

    return;
};

void EventUpdate()
{

    // get event info
    EventInfo *event_info = event_vars.event_info;
    GOBJ *menu_gobj = event_vars.menu_gobj;

    // run savestate logic if enabled
    if (1 == 1)
    {
        Update_Savestates();
    }

    // run menu logic if exists
    if (menu_gobj != 0)
    {
        // update menu
        EventMenu_Update(menu_gobj);
    }

    // run custom event update function
    if (event_info->eventUpdate != 0)
    {
        event_info->eventUpdate();
    }
    else
        Develop_UpdateMatchHotkeys();

    return;
}

//////////////////////
/// Hook Functions ///
//////////////////////

void MatchThink(GOBJ *gobj)
{
    int *userdata = gobj->userdata;
    int heldInputs = (PAD_TRIGGER_R | PAD_TRIGGER_L);
    int pressedInputs = PAD_BUTTON_B;

    // loop through all players
    for (int i = 0; i < 6; i++)
    {
        // if they exist
        if (Fighter_GetSlotType(i) != 3)
        {
            // if theyre pressing the buttons
            GOBJ *fighter = Fighter_GetGObj(i);
            FighterData *fighter_data = fighter->userdata;
            if (((fighter_data->input_held & heldInputs) == heldInputs) && (fighter_data->input_pressed & pressedInputs))
            {
                // spawn mr saturn
                SpawnItem spawnItem;
                spawnItem.parent_gobj = 0;
                spawnItem.parent_gobj2 = 0;
                spawnItem.item_id = ITEM_MRSATURN;
                spawnItem.unk1 = 0;
                spawnItem.unk2 = 0;
                spawnItem.pos.X = fighter_data->pos.X;
                spawnItem.pos.Y = fighter_data->pos.Y;
                spawnItem.pos.Z = 0;
                spawnItem.pos2.X = fighter_data->pos.X;
                spawnItem.pos2.Y = fighter_data->pos.Y;
                spawnItem.pos2.Z = 0;
                spawnItem.vel.X = 0;
                spawnItem.vel.Y = 0;
                spawnItem.vel.Z = 0;
                spawnItem.facing_direction = fighter_data->facing_direction;
                spawnItem.damage = 0;
                spawnItem.unk5 = 0;
                spawnItem.unk6 = 0;
                spawnItem.unk7 = 0x80;
                GOBJ *item = CreateItem(&spawnItem);
            }
        }
    }

    return;
}

void DebugLogThink(GOBJ *gobj)
{
    int *userdata = gobj->userdata;
    DevText *text = userdata[0];
    MatchData *matchData = 0x804978a0; //0x80480530;

    // clear text
    DevelopText_EraseAllText(text);
    DevelopMode_ResetCursorXY(text, 0, 0);

    // update text
    DevelopText_AddString(text, "matchType: %d\n", matchData->matchType);
    DevelopText_AddString(text, "hudPos: %d\n", matchData->hudPos);
    DevelopText_AddString(text, "timer: %d\n", matchData->timer);
    DevelopText_AddString(text, "timer_unk2: %d\n", matchData->timer_unk2);
    DevelopText_AddString(text, "unk4: %d\n", matchData->unk4);
    DevelopText_AddString(text, "hideReady: %d\n", matchData->hideReady);
    DevelopText_AddString(text, "hideGo: %d\n", matchData->hideGo);
    DevelopText_AddString(text, "playMusic: %d\n", matchData->playMusic);
    DevelopText_AddString(text, "unk3: %d\n", matchData->unk3);
    DevelopText_AddString(text, "timer_unk: %d\n", matchData->timer_unk);
    DevelopText_AddString(text, "unk2: %d\n", matchData->unk2);
    DevelopText_AddString(text, "unk9: %d\n", matchData->unk9);
    DevelopText_AddString(text, "disableOffscreenDamage: %d\n", matchData->disableOffscreenDamage);
    DevelopText_AddString(text, "unk8: %d\n", matchData->unk8);
    DevelopText_AddString(text, "isSingleButtonMode: %d\n", matchData->isSingleButtonMode);
    DevelopText_AddString(text, "isDisablePause: %d\n", matchData->isDisablePause);
    DevelopText_AddString(text, "unk7: %d\n", matchData->unk7);
    DevelopText_AddString(text, "isCreateHUD: %d\n", matchData->isCreateHUD);
    DevelopText_AddString(text, "unk5: %d\n", matchData->unk5);
    DevelopText_AddString(text, "isShowScore: %d\n", matchData->isShowScore);
    DevelopText_AddString(text, "isShowAnalogStick: %d\n", matchData->isShowAnalogStick);
    DevelopText_AddString(text, "isCheckForZRetry: %d\n", matchData->isCheckForZRetry);
    DevelopText_AddString(text, "isShowZRetry: %d\n", matchData->isShowZRetry);
    DevelopText_AddString(text, "isCheckForLRAStart: %d\n", matchData->isCheckForLRAStart);
    DevelopText_AddString(text, "isShowLRAStart: %d\n", matchData->isShowLRAStart);
    DevelopText_AddString(text, "isHidePauseHUD: %d\n", matchData->isHidePauseHUD);
    DevelopText_AddString(text, "timerRunOnPause: %d\n", matchData->timerRunOnPause);
    DevelopText_AddString(text, "unk11: %d\n", matchData->unk11);
    DevelopText_AddString(text, "isCheckStockSteal: %d\n", matchData->isCheckStockSteal);
    DevelopText_AddString(text, "isRunStockLogic: %d\n", matchData->isRunStockLogic);
    DevelopText_AddString(text, "unk10: %d\n", matchData->unk10);
    DevelopText_AddString(text, "isSkipEndCheck: %d\n", matchData->isSkipEndCheck);
    DevelopText_AddString(text, "isSkipUnkStockCheck: %d\n", matchData->isSkipUnkStockCheck);
    DevelopText_AddString(text, "isDisableHit: %d\n", matchData->isDisableHit);
    DevelopText_AddString(text, "unk12: %d\n", matchData->unk12);

    return;
}

void OnSceneChange()
{
    // Hook exists at 801a4c94

    return;
};

void OnBoot()
{
    // OSReport("hi this is boot\n");
    return;
};

void OnStartMelee()
{
    // Create a gobj
    GOBJ *gobj = GObj_Create(0, 0, 0);
    int *userdata = HSD_MemAlloc(64);
    GObj_AddUserData(gobj, 4, HSD_Free, userdata);
    GObj_AddProc(gobj, MatchThink, 4);
    return;
}

///////////////////////////////
/// Miscellaneous Functions ///
///////////////////////////////

void Savestate_Save()
{

    typedef struct BackupQueue
    {
        GOBJ *fighter;
        FighterData *fighter_data;
    } BackupQueue;

    // ensure no players are in problematic states
    int canSave = 1;
    GOBJ **gobj_list = R13_PTR(GOBJLIST);
    GOBJ *fighter = gobj_list[8];
    GOBJ *event_gobj = event_vars.event_gobj;
    while (fighter != 0)
    {

        FighterData *fighter_data = fighter->userdata;

        if ((fighter_data->cb_OnDeath != 0) ||
            (fighter_data->cb_OnDeath2 != 0) ||
            (fighter_data->cb_OnDeath3 != 0) ||
            (fighter_data->heldItem != 0) ||
            (fighter_data->x1978 != 0) ||
            (fighter_data->accessory != 0))
        {
            // cannot save
            canSave = 0;
            break;
        }

        fighter = fighter->next;
    }

    // loop through all players
    int isSaved = 0;
    if (canSave == 1)
    {

        // backup event data
        memcpy(eventDataBackup, event_gobj->userdata, EVENT_DATASIZE);

        // free all savestates
        for (int i = 0; i < sizeof(savestates) / 4; i++)
        {
            if (savestates[i] != 0)
                HSD_Free(savestates[i]);
        }

        // backup all players
        for (int i = 0; i < 6; i++)
        {
            // get fighter gobjs
            BackupQueue queue[2];
            for (int j = 0; j < 2; j++)
            {
                queue[j].fighter = Fighter_GetSubcharGObj(i, j);
                if (queue[j].fighter != 0)
                    queue[j].fighter_data = queue[j].fighter->userdata;
            }

            // if the fighter exists
            if (queue[0].fighter != 0)
            {

                isSaved = 1;

                // allocate new savestate
                Savestate *savestate = calloc(sizeof(Savestate));

                // backup playerblock
                Playerblock *playerblock = Fighter_GetPlayerblock(queue[0].fighter_data->ply);
                memcpy(&savestate->player_block, playerblock, sizeof(Playerblock));

                // backup stale moves
                int *staleMoves = Fighter_GetStaleMoveTable(queue[0].fighter_data->ply);
                memcpy(&savestate->stale_queue, staleMoves, 0x2C);

                // backup fighter data
                for (int j = 0; j < 2; j++)
                {
                    // if exists
                    if (queue[j].fighter != 0)
                    {
                        GOBJ *fighter = queue[j].fighter;
                        FighterData *fighter_data = queue[j].fighter_data;

                        // backup fighter data
                        memcpy(&savestate->fighter_data[j], fighter_data, sizeof(FighterData));

                        // backup camerabox
                        memcpy(&savestate->camera[j], fighter_data->cameraBox, sizeof(CameraBox));
                    }
                }

                // store pointer
                savestates[i] = savestate;
            }
        }
    }

    // Play SFX
    if (isSaved == 0)
    {
        SFX_PlayCommon(3);
    }
    if (isSaved == 1)
    {
        // play sfx
        SFX_PlayCommon(1);

        // if not in frame advance, flash screen
        if (Pause_CheckStatus(0) != 1)
            ScreenFlash_Create(2, 0);
    }

    return;
}
void Savestate_Load()
{
    typedef struct BackupQueue
    {
        GOBJ *fighter;
        FighterData *fighter_data;
    } BackupQueue;

    GOBJ *event_gobj = event_vars.event_gobj;

    // loop through all players
    int isLoaded = 0;
    for (int i = 0; i < 6; i++)
    {
        // get fighter gobjs
        BackupQueue queue[2];
        for (int j = 0; j < 2; j++)
        {
            queue[j].fighter = Fighter_GetSubcharGObj(i, j);
            if (queue[j].fighter != 0)
                queue[j].fighter_data = queue[j].fighter->userdata;
        }

        // if the fighter and backup exists
        if ((queue[0].fighter != 0) && (savestates[i] != 0))
        {

            isLoaded = 1;

            // get savestate
            Savestate *savestate = savestates[i];

            // restore playerblock
            Playerblock *playerblock = Fighter_GetPlayerblock(queue[0].fighter_data->ply);
            memcpy(playerblock, &savestate->player_block, sizeof(Playerblock));

            // restore stale moves
            int *staleMoves = Fighter_GetStaleMoveTable(queue[0].fighter_data->ply);
            memcpy(staleMoves, &savestate->stale_queue, 0x2C);

            // restore fighter data
            for (int j = 0; j < 2; j++)
            {
                // if exists
                if (queue[j].fighter != 0)
                {
                    GOBJ *fighter = queue[j].fighter;
                    FighterData *fighter_data = queue[j].fighter_data;
                    FighterData *backup_data = &savestate->fighter_data[j];

                    // backup buttons and collision bubble toggle
                    int input_lstick_x = fighter_data->input_lstick_x;
                    int input_lstick_y = fighter_data->input_lstick_y;
                    int dpad_held = (fighter_data->input_held & PAD_BUTTON_DPAD_LEFT) & (fighter_data->input_held & PAD_BUTTON_DPAD_RIGHT);
                    u8 show_model = fighter_data->show_model;
                    u8 show_hit = fighter_data->show_hit;

                    // restore facing direction
                    fighter_data->facing_direction = savestate->fighter_data[j].facing_direction;
                    // sleep
                    Fighter_EnterSleep(fighter, 0);
                    // enter backed up state
                    ActionStateChange(backup_data->stateFrame, backup_data->stateSpeed, -0, fighter, backup_data->state_id, 0, 0);
                    fighter_data->stateBlend = 0;

                    // snap dynamic bones in place
                    /*
                    if (fighter_data->state_id == ASID_WAIT)
                    {
                        Fighter_DisableBlend(fighter, 6);
                    }
                    */

                    // restore fighter data
                    memcpy(fighter_data, &savestate->fighter_data[j], sizeof(FighterData));

                    // restore buttons and collision bubble toggle
                    fighter_data->input_lstick_x = input_lstick_x;
                    fighter_data->input_lstick_y = input_lstick_y;
                    fighter_data->input_held &= dpad_held;
                    fighter_data->show_model = show_model;
                    fighter_data->show_hit = show_hit;

                    // zero pointer to cached animation (fixes fall crash)
                    fighter_data->anim_persist_ARAM = 0;

                    // update colltest frame
                    fighter_data->collData.coll_test = R13_INT(COLL_TEST);

                    // restore camerabox
                    memcpy(fighter_data->cameraBox, &savestate->camera[j], sizeof(CameraBox));

                    // stop player SFX
                    SFX_StopAllFighterSFX(fighter_data);

                    /*
                    // create shield GFX
                    if (fighter_data->shield == 1)
                    {
                        // get gfx ID
                        int shieldGFX;
                        static u16 ShieldGFXLookup[] = {1047, 1048, -1, 1049, -1}; // covers GUARDON -> GUARDREFLECT
                        shieldGFX = ShieldGFXLookup[fighter_data->state_id - ASID_GUARDON];

                        // create GFX
                        int color_index = Fighter_GetShieldColorIndex(fighter_data->ply);
                        GXColor *shieldColors = R13_PTR(-0x5194);
                        GXColor *shieldColor = &shieldColors[color_index];
                        JOBJ *shieldBone = fighter_data->bones[fighter_data->ftData->modelLookup[0x11]].joint;
                        int shieldColorParam = (shieldColor->r << 16) | (shieldColor->b << 8) | (shieldColor->g);
                        Effect_SpawnSync(shieldGFX, fighter, shieldBone, shieldColorParam);

                        // update
                        Fighter_UpdateShieldGFX(fighter, 1);
                    }
                    */

                    // update jobj position
                    JOBJ *fighter_jobj = fighter->hsd_object;
                    fighter_jobj->trans = fighter_data->pos;
                    /*
                    // animate it
                    Fighter_UpdateBonePos(fighter_data, 0);
                    JOBJ_AnimAll(fighter->hsd_object);
                    */
                    // dirtysub their jobj
                    JOBJ_SetMtxDirtySub(fighter_jobj);
                }
            }

            // check to recreate HUD
            MatchHUD *huds = MATCH_HUD;
            MatchHUD *hud = &huds[i];
            if (Match_CheckIfStock() == 1)
            {
                // remove HUD if no stocks left
                if (Fighter_GetStocks(i) <= 0)
                {
                    hud->is_exist = 0;
                }
            }
            else
            {
                // check to create it
                if (hud->is_exist == 1)
                {
                    Match_CreateHUD(i);
                }
            }

            // snap camera to the new positions
            Match_CorrectCamera();

            // stop crowd cheer
            SFX_StopCrowd();
        }
    }

    // Restore event data and Play SFX
    if (isLoaded == 0)
    {
        SFX_PlayCommon(3);
    }
    if (isLoaded == 1)
    {
        memcpy(event_gobj->userdata, eventDataBackup, EVENT_DATASIZE);

        SFX_PlayCommon(0);
    }

    return;
}

////////////////////////////
/// Event Menu Functions ///
////////////////////////////

GOBJ *EventMenu_Init(EventInfo *eventInfo)
{
    // Ensure this event has a menu
    if (eventInfo->startMenu == 0)
        return 0;

    // Create a cobj for the event menu
    COBJDesc ***dmgScnMdls = File_GetSymbol(ACCESS_PTR(0x804d6d5c), 0x803f94d0);
    COBJDesc *cam_desc = dmgScnMdls[1][0];
    COBJ *cam_cobj = COBJ_LoadDesc(cam_desc);
    GOBJ *cam_gobj = GObj_Create(19, 20, 0);
    MenuCamData *menuCamData = calloc(sizeof(MenuCamData));
    GObj_AddUserData(cam_gobj, 4, HSD_Free, menuCamData);
    GObj_AddObject(cam_gobj, R13_U8(-0x3E55), cam_cobj);
    GOBJ_InitCamera(cam_gobj, EventMenu_COBJThink, MENUCAM_GXPRI);
    cam_gobj->cobj_id = MENUCAM_COBJGXLINK;

    // Create menu gobj
    GOBJ *gobj = GObj_Create(0, 0, 0);
    MenuData *menuData = calloc(sizeof(MenuData));
    GObj_AddUserData(gobj, 4, HSD_Free, menuData);

    // store pointer to the gobj's data
    menuData->eventInfo = eventInfo;

    // Add gx_link
    GObj_AddGXLink(gobj, GXLink_Common, GXLINK_MENUMODEL, GXPRI_MENUMODEL);

    // save pointer to menu to camera gobj
    menuCamData->menu = gobj;

    // Create 2 text canvases (menu and popup)
    menuData->canvas_menu = Text_CreateCanvas(2, cam_gobj, 9, 13, 0, GXLINK_MENUTEXT, GXPRI_MENUTEXT, MENUCAM_GXPRI);
    menuData->canvas_popup = Text_CreateCanvas(2, cam_gobj, 9, 13, 0, GXLINK_MENUTEXT, GXPRI_POPUPTEXT, MENUCAM_GXPRI);

    // Init currMenu
    menuData->currMenu = eventInfo->startMenu;

    // Load EvMn.dat
    int *symbols;
    File_LoadInitReturnSymbol("EvMn.dat", &symbols, "evMenu", 0);
    menuData->menu_assets = &symbols[0];
    // also store to r13 in case any code needs to access these assets
    R13_PTR(EVMENU_ASSETS) = &symbols[0];

    return gobj;
};

void EventMenu_Update(GOBJ *gobj)
{

    //MenuCamData *camData = gobj->userdata;
    MenuData *menuData = gobj->userdata;
    EventInfo *eventInfo = menuData->eventInfo;

    // Update Pause Status
    int isPress = 0;
    for (int i = 0; i < 6; i++)
    {

        // humans only
        if (Fighter_GetSlotType(i) == 0)
        {
            GOBJ *fighter = Fighter_GetGObj(i);
            FighterData *fighter_data = fighter->userdata;

            HSD_Pad *pad = PadGet(fighter_data->player_controller_number, PADGET_MASTER);

            if ((pad->down & HSD_BUTTON_START) != 0)
            {
                isPress = 1;
                break;
            }
        }
    }
    // change pause state
    if (isPress != 0)
    {

        EventMenu *currMenu = menuData->currMenu;
        // pause game
        if (menuData->isPaused == 0)
        {

            // set state
            menuData->isPaused = 1;

            // Create menu
            EventMenu_CreateModel(gobj, currMenu);
            EventMenu_CreateText(gobj, currMenu);
            EventMenu_UpdateText(gobj, currMenu);
            if (currMenu->state == EMSTATE_OPENPOP)
            {
                EventOption *currOption = &currMenu->options[currMenu->cursor];
                EventMenu_CreatePopupModel(gobj, currMenu);
                EventMenu_CreatePopupText(gobj, currMenu);
                EventMenu_UpdatePopupText(gobj, currOption);
            }

            // Freeze the game
            Match_FreezeGame(1);
            SFX_PlayCommon(5);
            Match_HideHUD();
        }
        // unpause game
        else
        {

            menuData->isPaused = 0;

            // destroy menu
            EventMenu_DestroyMenu(gobj);

            // Unfreeze the game
            Match_UnfreezeGame(1);
            Match_ShowHUD();
        }
    }

    // Run Menu Logic
    if (menuData->isPaused == 1)
    {
        // Get the current menu
        EventMenu *currMenu = menuData->currMenu;

        // menu think
        if (currMenu->state == EMSTATE_FOCUS)
            EventMenu_MenuThink(gobj, currMenu);

        // popup think
        else if (currMenu->state == EMSTATE_OPENPOP)
            EventMenu_PopupThink(gobj, currMenu);

        // custom gobj think
        else if (currMenu->state == EMSTATE_WAIT)
        {
            // iterate through gobj proc's here
        }
    }

    return;
}

void EventMenu_COBJThink(GOBJ *gobj)
{

    // do not display menu if a custom gobj is active
    CObjThink_Common(gobj);
    return;
}

void EventMenu_Think(GOBJ *gobj, int pass)
{

    MenuData *menuData = gobj->userdata;

    GXLink_Common(gobj, pass);

    return;
}

void EventMenu_MenuThink(GOBJ *gobj, EventMenu *currMenu)
{

    MenuData *menuData = gobj->userdata;
    EventInfo *eventInfo = menuData->eventInfo;

    // get player who paused
    u8 *pauseData = (u8 *)0x8046b6a0;
    u8 pauser = pauseData[1];
    // get their  inputs
    HSD_Pad *pad = PadGet(pauser, PADGET_MASTER);
    int inputs_rapid = pad->rapidFire;
    int inputs_held = pad->held;
    int inputs = inputs_rapid;
    if ((inputs_held & HSD_TRIGGER_R) != 0)
        inputs = inputs_held;

    // get menu variables
    int isChanged = 0;
    s32 cursor = currMenu->cursor;
    s32 scroll = currMenu->scroll;
    EventOption *currOption = &currMenu->options[cursor + scroll];
    s32 cursor_min = 0;
    s32 option_num = currMenu->option_num;
    s32 cursor_max = option_num;
    if (cursor_max > MENU_MAXOPTION)
        cursor_max = MENU_MAXOPTION;

    // get option variables
    s16 option_val = currOption->option_val;
    s16 value_min = 0;
    s16 value_max = currOption->value_num;

    // check for dpad down
    if (((inputs & HSD_BUTTON_DOWN) != 0) || ((inputs & HSD_BUTTON_DPAD_DOWN) != 0))
    {
        cursor += 1;

        // cursor is in bounds, move down
        if (cursor < cursor_max)
        {
            isChanged = 1;

            // update cursor
            currMenu->cursor = cursor;

            // also play sfx
            SFX_PlayCommon(2);
        }

        // cursor overflowed, check to scroll
        else
        {
            // cursor+scroll is in bounds, increment scroll
            if ((cursor + scroll) < option_num)
            {
                // adjust
                scroll++;
                cursor--;

                // update cursor
                currMenu->cursor = cursor;
                currMenu->scroll = scroll;

                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);
            }
        }
    }
    // check for dpad up
    else if (((inputs & HSD_BUTTON_UP) != 0) || ((inputs & HSD_BUTTON_DPAD_UP) != 0))
    {
        cursor -= 1;

        // cursor is in bounds, move up
        if (cursor >= 0)
        {
            isChanged = 1;

            // update cursor
            currMenu->cursor = cursor;

            // also play sfx
            SFX_PlayCommon(2);
        }

        // cursor overflowed, check to scroll
        else
        {
            // scroll is in bounds, decrement scroll
            if (scroll > 0)
            {
                // adjust
                scroll--;
                cursor++;

                // update cursor
                currMenu->cursor = cursor;
                currMenu->scroll = scroll;

                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);
            }
        }
    }

    // check for left
    else if (((inputs & HSD_BUTTON_LEFT) != 0) || ((inputs & HSD_BUTTON_DPAD_LEFT) != 0))
    {
        if ((currOption->option_kind == OPTKIND_STRING) || (currOption->option_kind == OPTKIND_INT) || (currOption->option_kind == OPTKIND_FLOAT))
        {

            option_val -= 1;
            if (option_val >= value_min)
            {
                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);

                // update val
                currOption->option_val = option_val;

                // run on change function if it exists
                if (currOption->onOptionChange != 0)
                    currOption->onOptionChange(gobj, currOption->option_val);
            }
        }
    }
    // check for right
    else if (((inputs & HSD_BUTTON_RIGHT) != 0) || ((inputs & HSD_BUTTON_DPAD_RIGHT) != 0))
    {
        // check for valid option kind
        if ((currOption->option_kind == OPTKIND_STRING) || (currOption->option_kind == OPTKIND_INT) || (currOption->option_kind == OPTKIND_FLOAT))
        {
            option_val += 1;
            if (option_val < value_max)
            {
                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);

                // update val
                currOption->option_val = option_val;

                // run on change function if it exists
                if (currOption->onOptionChange != 0)
                    currOption->onOptionChange(gobj, currOption->option_val);
            }
        }
    }

    // check for A
    else if ((inputs_rapid & HSD_BUTTON_A) != 0)
    {
        // check to advance a menu
        if ((currOption->option_kind == OPTKIND_MENU))
        {
            // access this menu
            currMenu->state = EMSTATE_OPENSUB;

            // update currMenu
            EventMenu *nextMenu = currMenu->options[cursor + scroll].menu;
            nextMenu->prev = currMenu;
            nextMenu->state = EMSTATE_FOCUS;
            currMenu = nextMenu;
            menuData->currMenu = currMenu;

            // recreate everything
            EventMenu_DestroyMenu(gobj);
            EventMenu_CreateModel(gobj, currMenu);
            EventMenu_CreateText(gobj, currMenu);
            EventMenu_UpdateText(gobj, currMenu);

            // also play sfx
            SFX_PlayCommon(1);
        }

        // check to create a popup
        if ((currOption->option_kind == OPTKIND_STRING) || (currOption->option_kind == OPTKIND_INT))
        {
            // access this menu
            currMenu->state = EMSTATE_OPENPOP;

            // init cursor and scroll value
            s32 cursor = 0;
            s32 scroll = currOption->option_val;

            // correct scroll
            s32 max_scroll;
            if (currOption->value_num <= MENU_POPMAXOPTION)
                max_scroll = 0;
            else
                max_scroll = currOption->value_num - MENU_POPMAXOPTION;
            // check if scrolled too far
            if (scroll > max_scroll)
            {
                cursor = scroll - max_scroll;
                scroll = max_scroll;
            }

            // update cursor and scroll
            menuData->popup_cursor = cursor;
            menuData->popup_scroll = scroll;

            // create popup menu and update
            EventMenu_CreatePopupModel(gobj, currMenu);
            EventMenu_CreatePopupText(gobj, currMenu);
            EventMenu_UpdatePopupText(gobj, currOption);

            // also play sfx
            SFX_PlayCommon(1);
        }

        // check to run a function
        if ((currOption->option_kind == OPTKIND_FUNC))
        {
            if (currOption->onOptionSelect != 0)
            {
                // save pointer to this gobj
                menuData->custom_gobj = currOption->onOptionSelect(gobj);

                // also play sfx
                SFX_PlayCommon(1);
            }
        }
    }
    // check to go back a menu
    else if ((inputs_rapid & HSD_BUTTON_B) != 0)
    {
        // check if a prev menu exists
        EventMenu *prevMenu = currMenu->prev;
        if (prevMenu != 0)
        {

            // clear previous menu
            EventMenu *prevMenu = currMenu->prev;
            currMenu->prev = 0;

            // reset this menu's cursor
            currMenu->scroll = 0;
            currMenu->cursor = 0;

            // update currMenu
            currMenu = prevMenu;
            menuData->currMenu = currMenu;

            // close this menu
            currMenu->state = EMSTATE_FOCUS;

            // recreate everything
            EventMenu_DestroyMenu(gobj);
            EventMenu_CreateModel(gobj, currMenu);
            EventMenu_CreateText(gobj, currMenu);
            EventMenu_UpdateText(gobj, currMenu);

            // also play sfx
            SFX_PlayCommon(0);
        }

        // no previous menu, unpause
        else
        {

            SFX_PlayCommon(0);

            menuData->isPaused = 0;

            // destroy menu
            EventMenu_DestroyMenu(gobj);

            // Unfreeze the game
            Match_UnfreezeGame(1);
            Match_ShowHUD();
        }
    }

    // if anything changed, update text
    if (isChanged != 0)
    {
        // update menu
        EventMenu_UpdateText(gobj, currMenu);
    }

    return;
}

void EventMenu_PopupThink(GOBJ *gobj, EventMenu *currMenu)
{

    MenuData *menuData = gobj->userdata;
    EventInfo *eventInfo = menuData->eventInfo;

    // get player who paused
    u8 *pauseData = (u8 *)0x8046b6a0;
    u8 pauser = pauseData[1];
    // get their  inputs
    HSD_Pad *pad = PadGet(pauser, PADGET_MASTER);
    int inputs_rapid = pad->rapidFire;
    int inputs_held = pad->held;
    int inputs = inputs_rapid;
    if ((inputs_held & HSD_TRIGGER_R) != 0)
        inputs = inputs_held;

    // get option variables
    int isChanged = 0;
    s32 cursor = menuData->popup_cursor;
    s32 scroll = menuData->popup_scroll;
    EventOption *currOption = &currMenu->options[currMenu->cursor + currMenu->scroll];
    s32 value_num = currOption->value_num;
    s32 cursor_min = 0;
    s32 cursor_max = value_num;
    if (cursor_max > MENU_POPMAXOPTION)
    {
        cursor_max = MENU_POPMAXOPTION;
    }

    // check for dpad down
    if (((inputs & HSD_BUTTON_DOWN) != 0) || ((inputs & HSD_BUTTON_DPAD_DOWN) != 0))
    {
        cursor += 1;

        // cursor is in bounds, move down
        if (cursor < cursor_max)
        {
            isChanged = 1;

            // update cursor
            menuData->popup_cursor = cursor;

            // also play sfx
            SFX_PlayCommon(2);
        }

        // cursor overflowed, check to scroll
        else
        {
            // cursor+scroll is in bounds, increment scroll
            if ((cursor + scroll) < value_num)
            {
                // adjust
                scroll++;
                cursor--;

                // update cursor
                menuData->popup_cursor = cursor;
                menuData->popup_scroll = scroll;

                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);
            }
        }
    }
    // check for dpad up
    else if (((inputs & HSD_BUTTON_UP) != 0) || ((inputs & HSD_BUTTON_DPAD_UP) != 0))
    {
        cursor -= 1;

        // cursor is in bounds, move up
        if (cursor >= 0)
        {
            isChanged = 1;

            // update cursor
            menuData->popup_cursor = cursor;

            // also play sfx
            SFX_PlayCommon(2);
        }

        // cursor overflowed, check to scroll
        else
        {
            // scroll is in bounds, decrement scroll
            if (scroll > 0)
            {
                // adjust
                scroll--;
                cursor++;

                // update cursor
                menuData->popup_cursor = cursor;
                menuData->popup_scroll = scroll;

                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);
            }
        }
    }

    // check for A
    else if ((inputs_rapid & HSD_BUTTON_A) != 0)
    {

        // update option_val
        currOption->option_val = cursor + scroll;

        // run on change function if it exists
        if (currOption->onOptionChange != 0)
            currOption->onOptionChange(gobj, currOption->option_val);

        EventMenu_DestroyPopup(gobj);

        // update menu
        EventMenu_UpdateText(gobj, currMenu);

        // play sfx
        SFX_PlayCommon(1);
    }
    // check to go back a menu
    else if ((inputs_rapid & HSD_BUTTON_B) != 0)
    {

        EventMenu_DestroyPopup(gobj);

        // update menu
        EventMenu_UpdateText(gobj, currMenu);

        // play sfx
        SFX_PlayCommon(0);
    }

    // if anything changed, update text
    if (isChanged != 0)
    {
        // update menu
        EventMenu_UpdatePopupText(gobj, currOption);
    }

    return;
}

void EventMenu_CreateModel(GOBJ *gobj, EventMenu *menu)
{

    MenuData *menuData = gobj->userdata;

    // create options background
    evMenu *menuAssets = menuData->menu_assets;
    JOBJ *jobj_options = JOBJ_LoadJoint(menuAssets->menu);
    // Add to gobj
    GObj_AddObject(gobj, 3, jobj_options);
    GObj_DestroyGXLink(gobj);
    GObj_AddGXLink(gobj, EventMenu_Think, GXLINK_MENUMODEL, GXPRI_MENUMODEL);

    // Get each corner's joints
    JOBJ *corners[4];
    JOBJ_GetChild(jobj_options, &corners, 2, 3, 4, 5, -1);
    // Modify scale and position
    jobj_options->trans.Z = OPT_Z;
    jobj_options->scale.X = 1;
    jobj_options->scale.Y = 1;
    jobj_options->scale.Z = 1;
    corners[0]->trans.X = -(OPT_WIDTH / 2) + OPT_X;
    corners[0]->trans.Y = (OPT_HEIGHT / 2) + OPT_Y;
    corners[1]->trans.X = (OPT_WIDTH / 2) + OPT_X;
    corners[1]->trans.Y = (OPT_HEIGHT / 2) + OPT_Y;
    corners[2]->trans.X = -(OPT_WIDTH / 2) + OPT_X;
    corners[2]->trans.Y = -(OPT_HEIGHT / 2) + OPT_Y;
    corners[3]->trans.X = (OPT_WIDTH / 2) + OPT_X;
    corners[3]->trans.Y = -(OPT_HEIGHT / 2) + OPT_Y;

    // create a border and arrow for every row
    s32 option_num = menu->option_num;
    if (option_num > MENU_MAXOPTION)
        option_num = MENU_MAXOPTION;
    for (int i = 0; i < option_num; i++)
    {
        // create a border jobj
        JOBJ *jobj_border = JOBJ_LoadJoint(menuAssets->popup);
        // attach to root jobj
        JOBJ_AddChild(gobj->hsd_object, jobj_border);
        // move it into position
        JOBJ_GetChild(jobj_border, &corners, 2, 3, 4, 5, -1);
        // Modify scale and position
        jobj_border->trans.Z = ROWBOX_Z;
        jobj_border->scale.X = 1;
        jobj_border->scale.Y = 1;
        jobj_border->scale.Z = 1;
        corners[0]->trans.X = -(ROWBOX_WIDTH / 2) + ROWBOX_X;
        corners[0]->trans.Y = (ROWBOX_HEIGHT / 2) + ROWBOX_Y + (i * ROWBOX_YOFFSET);
        corners[1]->trans.X = (ROWBOX_WIDTH / 2) + ROWBOX_X;
        corners[1]->trans.Y = (ROWBOX_HEIGHT / 2) + ROWBOX_Y + (i * ROWBOX_YOFFSET);
        corners[2]->trans.X = -(ROWBOX_WIDTH / 2) + ROWBOX_X;
        corners[2]->trans.Y = -(ROWBOX_HEIGHT / 2) + ROWBOX_Y + (i * ROWBOX_YOFFSET);
        corners[3]->trans.X = (ROWBOX_WIDTH / 2) + ROWBOX_X;
        corners[3]->trans.Y = -(ROWBOX_HEIGHT / 2) + ROWBOX_Y + (i * ROWBOX_YOFFSET);
        JOBJ_SetFlags(jobj_border, JOBJ_HIDDEN);
        jobj_border->dobj->next->mobj->mat->alpha = 0.6;
        // store pointer
        menuData->row_joints[i][0] = jobj_border;

        // create an arrow jobj
        JOBJ *jobj_arrow = JOBJ_LoadJoint(menuAssets->arrow);
        // attach to root jobj
        JOBJ_AddChild(gobj->hsd_object, jobj_arrow);
        // move it into position
        jobj_arrow->trans.X = TICKBOX_X;
        jobj_arrow->trans.Y = TICKBOX_Y + (i * ROWBOX_YOFFSET);
        jobj_arrow->trans.Z = ROWBOX_Z;
        jobj_arrow->scale.X = TICKBOX_SCALE;
        jobj_arrow->scale.Y = TICKBOX_SCALE;
        jobj_arrow->scale.Z = TICKBOX_SCALE;
        // change color
        //GXColor gx_color = {30, 40, 50, 255};
        //jobj_arrow->dobj->next->mobj->mat->diffuse = gx_color;

        JOBJ_SetFlags(jobj_arrow, JOBJ_HIDDEN);
        // store pointer
        menuData->row_joints[i][1] = jobj_arrow;
    }

    // create a highlight jobj
    JOBJ *jobj_highlight = JOBJ_LoadJoint(menuAssets->popup);
    // attach to root jobj
    JOBJ_AddChild(gobj->hsd_object, jobj_highlight);
    // move it into position
    JOBJ_GetChild(jobj_highlight, &corners, 2, 3, 4, 5, -1);
    // Modify scale and position
    jobj_highlight->trans.Z = MENUHIGHLIGHT_Z;
    jobj_highlight->scale.X = 1;
    jobj_highlight->scale.Y = 1;
    jobj_highlight->scale.Z = 1;
    corners[0]->trans.X = -(MENUHIGHLIGHT_WIDTH / 2) + MENUHIGHLIGHT_X;
    corners[0]->trans.Y = (MENUHIGHLIGHT_HEIGHT / 2) + MENUHIGHLIGHT_Y;
    corners[1]->trans.X = (MENUHIGHLIGHT_WIDTH / 2) + MENUHIGHLIGHT_X;
    corners[1]->trans.Y = (MENUHIGHLIGHT_HEIGHT / 2) + MENUHIGHLIGHT_Y;
    corners[2]->trans.X = -(MENUHIGHLIGHT_WIDTH / 2) + MENUHIGHLIGHT_X;
    corners[2]->trans.Y = -(MENUHIGHLIGHT_HEIGHT / 2) + MENUHIGHLIGHT_Y;
    corners[3]->trans.X = (MENUHIGHLIGHT_WIDTH / 2) + MENUHIGHLIGHT_X;
    corners[3]->trans.Y = -(MENUHIGHLIGHT_HEIGHT / 2) + MENUHIGHLIGHT_Y;
    GXColor highlight = MENUHIGHLIGHT_COLOR;
    jobj_highlight->dobj->next->mobj->mat->alpha = 0.6;
    jobj_highlight->dobj->next->mobj->mat->diffuse = highlight;

    menuData->highlight_menu = jobj_highlight;
    return;
}

void EventMenu_CreateText(GOBJ *gobj, EventMenu *menu)
{

    // Get event info
    MenuData *menuData = gobj->userdata;
    EventInfo *eventInfo = menuData->eventInfo;
    Text *text;
    int subtext;
    int canvasIndex = menuData->canvas_menu;
    s32 cursor = menu->cursor;

    // free text if it exists
    if (menuData->text_name != 0)
    {
        // free text
        Text_FreeText(menuData->text_name);
        menuData->text_name = 0;
        Text_FreeText(menuData->text_value);
        menuData->text_value = 0;
        Text_FreeText(menuData->text_title);
        menuData->text_title = 0;
        Text_FreeText(menuData->text_desc);
        menuData->text_desc = 0;
    }
    if (menuData->text_popup != 0)
    {
        Text_FreeText(menuData->text_popup);
        menuData->text_popup = 0;
    }

    //////////////////
    // Create Title //
    //////////////////

    text = Text_CreateText(2, canvasIndex);
    menuData->text_title = text;
    // enable align and kerning
    text->align = 0;
    text->kerning = 1;
    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;
    text->trans.Z = MENU_TEXTZ;

    // output menu title
    float optionX = MENU_TITLEXPOS;
    float optionY = MENU_TITLEYPOS;
    subtext = Text_AddSubtext(text, optionX, optionY, &nullString);
    Text_SetScale(text, subtext, MENU_TITLESCALE, MENU_TITLESCALE);

    ////////////////////////
    // Create Description //
    ////////////////////////

    text = Text_CreateText(2, canvasIndex);
    menuData->text_desc = text;

    //////////////////
    // Create Names //
    //////////////////

    text = Text_CreateText(2, canvasIndex);
    menuData->text_name = text;
    // enable align and kerning
    text->align = 0;
    text->kerning = 1;
    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;
    text->trans.Z = MENU_TEXTZ;

    // Output all options
    s32 option_num = menu->option_num;
    if (option_num > MENU_MAXOPTION)
        option_num = MENU_MAXOPTION;
    for (int i = 0; i < option_num; i++)
    {

        // output option name
        float optionX = MENU_OPTIONNAMEXPOS;
        float optionY = MENU_OPTIONNAMEYPOS + (i * MENU_TEXTYOFFSET);
        subtext = Text_AddSubtext(text, optionX, optionY, &nullString);
    }

    ///////////////////
    // Create Values //
    ///////////////////

    text = Text_CreateText(2, canvasIndex);
    menuData->text_value = text;
    // enable align and kerning
    text->align = 1;
    text->kerning = 1;
    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;
    text->trans.Z = MENU_TEXTZ;

    // Output all values
    for (int i = 0; i < option_num; i++)
    {
        // output option value
        float optionX = MENU_OPTIONVALXPOS;
        float optionY = MENU_OPTIONVALYPOS + (i * MENU_TEXTYOFFSET);
        subtext = Text_AddSubtext(text, optionX, optionY, &nullString);
    }

    return;
}

void EventMenu_UpdateText(GOBJ *gobj, EventMenu *menu)
{

    // Get event info
    MenuData *menuData = gobj->userdata;
    EventInfo *eventInfo = menuData->eventInfo;
    s32 cursor = menu->cursor;
    s32 scroll = menu->scroll;
    s32 option_num = menu->option_num;
    if (option_num > MENU_MAXOPTION)
        option_num = MENU_MAXOPTION;
    Text *text;

    /* 
    Update Title
    */

    text = menuData->text_title;
    //Text_SetText(text, 0, "Test Title");
    Text_SetText(text, 0, menu->name);

    /* 
    Update Desscription
    */

    text = menuData->text_desc;
    EventOption *currOption = &menu->options[menu->cursor + menu->scroll];
    // 0x07, 0xfe, 0x52, 0x01, 0x00 - offset
    // 0xE, 0x01, 0xE0, 0x01, 0x00 - fit
    static u8 descHeader[] = {0x16, 0xC, 0xFF, 0xFF, 0xFF};
    static u8 descTerminator[] = {0x0};

    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;
    text->trans.X = MENU_DESCXPOS;
    text->trans.Y = MENU_DESCYPOS;
    text->trans.Z = MENU_TEXTZ;

    // free current allocation
    Text_DestroyAlloc(text->textAlloc);
    // convert description into menu text
    u8 buffer[400];
    int menuTextSize = Text_StringToMenuText(&buffer, currOption->desc);
    // new alloc
    int allocSize = menuTextSize + sizeof(descHeader) + sizeof(descTerminator);
    u8 *textAlloc = Text_Alloc(allocSize);
    // copy header to new alloc
    memcpy(textAlloc, &descHeader, sizeof(descHeader));
    memcpy(textAlloc + sizeof(descHeader), &buffer, menuTextSize);
    memcpy(textAlloc + sizeof(descHeader) + menuTextSize, &descTerminator, sizeof(descTerminator));
    // update pointer to alloc
    text->textAlloc = textAlloc;
    text->allocInfo->start = textAlloc;
    text->allocInfo->curr = textAlloc + allocSize;
    text->allocInfo->size = allocSize;

    /* 
    Update Names
    */

    // Output all options
    text = menuData->text_name;
    for (int i = 0; i < option_num; i++)
    {
        // get this option
        EventOption *currOption = &menu->options[scroll + i];

        // output option name
        int optionVal = currOption->option_val;
        Text_SetText(text, i, currOption->option_name);
    }

    /* 
    Update Values
    */

    // Output all values
    text = menuData->text_value;
    for (int i = 0; i < option_num; i++)
    {
        // get this option
        EventOption *currOption = &menu->options[scroll + i];
        int optionVal = currOption->option_val;

        // hide row models
        JOBJ_SetFlags(menuData->row_joints[i][0], JOBJ_HIDDEN);
        JOBJ_SetFlags(menuData->row_joints[i][1], JOBJ_HIDDEN);

        // if this option has string values
        if (currOption->option_kind == OPTKIND_STRING)
        {
            // output option value
            Text_SetText(text, i, currOption->option_values[optionVal]);

            // show box
            JOBJ_ClearFlags(menuData->row_joints[i][0], JOBJ_HIDDEN);
        }

        // if this option has int values
        else if (currOption->option_kind == OPTKIND_INT)
        {
            // output option value
            Text_SetText(text, i, "%d", optionVal);

            // show box
            JOBJ_ClearFlags(menuData->row_joints[i][0], JOBJ_HIDDEN);
        }

        // if this option is a menu or function
        else if ((currOption->option_kind == OPTKIND_MENU) || (currOption->option_kind == OPTKIND_FUNC))
        {
            Text_SetText(text, i, &nullString);

            // show arrow
            //JOBJ_ClearFlags(menuData->row_joints[i][1], JOBJ_HIDDEN);
        }
    }

    // update cursor position
    JOBJ *highlight_joint = menuData->highlight_menu;
    highlight_joint->trans.Y = cursor * MENUHIGHLIGHT_YOFFSET;
    JOBJ_SetMtxDirtySub(highlight_joint);

    return;
}

void EventMenu_DestroyMenu(GOBJ *gobj)
{
    MenuData *menuData = gobj->userdata; // userdata

    // remove
    Text_FreeText(menuData->text_name);
    menuData->text_name = 0;
    // remove
    Text_FreeText(menuData->text_value);
    menuData->text_value = 0;
    // remove
    Text_FreeText(menuData->text_title);
    menuData->text_title = 0;
    // remove
    Text_FreeText(menuData->text_desc);
    menuData->text_desc = 0;

    // if popup box exists
    if (menuData->text_popup != 0)
        EventMenu_DestroyPopup(gobj);

    // if custom menu gobj exists
    if (menuData->custom_gobj != 0)
    {
        menuData->currMenu->state = EMSTATE_FOCUS;
        GObj_Destroy(menuData->custom_gobj);
        menuData->custom_gobj = 0;
    }

    // remove jobj
    GObj_FreeObject(gobj);
    //GObj_DestroyGXLink(gobj);

    return;
}

void EventMenu_CreatePopupModel(GOBJ *gobj, EventMenu *menu)
{
    // init variables
    MenuData *menuData = gobj->userdata; // userdata
    s32 cursor = menu->cursor;
    EventOption *option = &menu->options[cursor];

    // create options background
    evMenu *menuAssets = menuData->menu_assets;

    // create popup gobj
    GOBJ *popup_gobj = GObj_Create(0, 0, 0);

    // load popup joint
    JOBJ *popup_joint = JOBJ_LoadJoint(menuAssets->popup);

    // Get each corner's joints
    JOBJ *corners[4];
    JOBJ_GetChild(popup_joint, &corners, 2, 3, 4, 5, -1);

    // Modify scale and position
    popup_joint->scale.X = POPUP_SCALE;
    popup_joint->scale.Y = POPUP_SCALE;
    popup_joint->scale.Z = POPUP_SCALE;
    popup_joint->trans.Z = POPUP_Z;
    corners[0]->trans.X = -(POPUP_WIDTH / 2);
    corners[0]->trans.Y = (POPUP_HEIGHT / 2);
    corners[1]->trans.X = (POPUP_WIDTH / 2);
    corners[1]->trans.Y = (POPUP_HEIGHT / 2);
    corners[2]->trans.X = -(POPUP_WIDTH / 2);
    corners[2]->trans.Y = -(POPUP_HEIGHT / 2);
    corners[3]->trans.X = (POPUP_WIDTH / 2);
    corners[3]->trans.Y = -(POPUP_HEIGHT / 2);

    /*
    // Change color
    GXColor gx_color = TEXT_BGCOLOR;
    popup_joint->dobj->mobj->mat->diffuse = gx_color;
*/

    // add to gobj
    GObj_AddObject(popup_gobj, 3, popup_joint);
    // add gx link
    GObj_AddGXLink(popup_gobj, GXLink_Common, GXLINK_POPUPMODEL, GXPRI_POPUPMODEL);
    // save pointer
    menuData->popup = popup_gobj;

    // adjust scrollbar scale

    // position popup X and Y (based on cursor value)
    popup_joint->trans.X = POPUP_X;
    popup_joint->trans.Y = POPUP_Y + (POPUP_YOFFSET * cursor);

    // create a highlight jobj
    JOBJ *jobj_highlight = JOBJ_LoadJoint(menuAssets->popup);
    // attach to root jobj
    JOBJ_AddChild(popup_gobj->hsd_object, jobj_highlight);
    // move it into position
    JOBJ_GetChild(jobj_highlight, &corners, 2, 3, 4, 5, -1);
    // Modify scale and position
    jobj_highlight->trans.Z = POPUPHIGHLIGHT_Z;
    jobj_highlight->scale.X = 1;
    jobj_highlight->scale.Y = 1;
    jobj_highlight->scale.Z = 1;
    corners[0]->trans.X = -(POPUPHIGHLIGHT_WIDTH / 2) + POPUPHIGHLIGHT_X;
    corners[0]->trans.Y = (POPUPHIGHLIGHT_HEIGHT / 2) + POPUPHIGHLIGHT_Y;
    corners[1]->trans.X = (POPUPHIGHLIGHT_WIDTH / 2) + POPUPHIGHLIGHT_X;
    corners[1]->trans.Y = (POPUPHIGHLIGHT_HEIGHT / 2) + POPUPHIGHLIGHT_Y;
    corners[2]->trans.X = -(POPUPHIGHLIGHT_WIDTH / 2) + POPUPHIGHLIGHT_X;
    corners[2]->trans.Y = -(POPUPHIGHLIGHT_HEIGHT / 2) + POPUPHIGHLIGHT_Y;
    corners[3]->trans.X = (POPUPHIGHLIGHT_WIDTH / 2) + POPUPHIGHLIGHT_X;
    corners[3]->trans.Y = -(POPUPHIGHLIGHT_HEIGHT / 2) + POPUPHIGHLIGHT_Y;
    GXColor highlight = POPUPHIGHLIGHT_COLOR;
    jobj_highlight->dobj->next->mobj->mat->alpha = 0.6;
    jobj_highlight->dobj->next->mobj->mat->diffuse = highlight;

    menuData->highlight_popup = jobj_highlight;

    return;
}

void EventMenu_CreatePopupText(GOBJ *gobj, EventMenu *menu)
{
    // init variables
    MenuData *menuData = gobj->userdata;
    s32 cursor = menu->cursor;
    EventOption *option = &menu->options[cursor];
    int subtext;
    int canvasIndex = menuData->canvas_popup;
    s32 value_num = option->value_num;
    if (value_num > MENU_POPMAXOPTION)
        value_num = MENU_POPMAXOPTION;

    ///////////////////
    // Create Values //
    ///////////////////

    Text *text = Text_CreateText(2, canvasIndex);
    menuData->text_popup = text;
    // enable align and kerning
    text->align = 1;
    text->kerning = 1;
    // scale canvas
    text->scale.X = POPUP_CANVASSCALE;
    text->scale.Y = POPUP_CANVASSCALE;
    text->trans.Z = POPUP_TEXTZ;

    // determine base Y value
    float baseYPos = POPUP_OPTIONVALYPOS + (cursor * MENU_TEXTYOFFSET);

    // Output all values
    for (int i = 0; i < value_num; i++)
    {
        // output option value
        float optionX = POPUP_OPTIONVALXPOS;
        float optionY = baseYPos + (i * POPUP_TEXTYOFFSET);
        subtext = Text_AddSubtext(text, optionX, optionY, &nullString);
    }

    return;
}

void EventMenu_UpdatePopupText(GOBJ *gobj, EventOption *option)
{
    // init variables
    MenuData *menuData = gobj->userdata; // userdata
    s32 cursor = menuData->popup_cursor;
    s32 scroll = menuData->popup_scroll;
    s32 value_num = option->value_num;
    if (value_num > MENU_POPMAXOPTION)
        value_num = MENU_POPMAXOPTION;

    ///////////////////
    // Update Values //
    ///////////////////

    Text *text = menuData->text_popup;

    // update int list
    if (option->option_kind == OPTKIND_INT)
    {
        // Output all values
        for (int i = 0; i < value_num; i++)
        {
            // output option value
            Text_SetText(text, i, "%d", scroll + i);
        }
    }

    // update string list
    else if (option->option_kind == OPTKIND_STRING)
    {
        // Output all values
        for (int i = 0; i < value_num; i++)
        {
            // output option value
            Text_SetText(text, i, option->option_values[scroll + i]);
        }
    }

    // update cursor position
    JOBJ *highlight_joint = menuData->highlight_popup;
    highlight_joint->trans.Y = cursor * POPUPHIGHLIGHT_YOFFSET;
    JOBJ_SetMtxDirtySub(highlight_joint);

    return;
}

void EventMenu_DestroyPopup(GOBJ *gobj)
{
    MenuData *menuData = gobj->userdata; // userdata

    // remove text
    Text_FreeText(menuData->text_popup);
    menuData->text_popup = 0;

    // destory gobj
    GObj_Destroy(menuData->popup);
    menuData->popup = 0;

    // also change the menus state
    EventMenu *currMenu = menuData->currMenu;
    currMenu->state = EMSTATE_FOCUS;
}

///////////////////////////////
/// Member-Access Functions ///
///////////////////////////////

EventInfo *GetEvent(int page, int event)
{
    EventPage *thisPage = EventPages[page];
    EventInfo *thisEvent = thisPage->events[event];
    return (thisEvent);
}
char *GetEventName(int page, int event)
{
    EventInfo *thisEvent = GetEvent(page, event);
    return (thisEvent->eventName);
}
char *GetEventDesc(int page, int event)
{
    EventInfo *thisEvent = GetEvent(page, event);
    return (thisEvent->eventDescription);
}
char *GetEventTut(int page, int event)
{
    EventInfo *thisEvent = GetEvent(page, event);
    return (thisEvent->eventTutorial);
}
char *GetPageName(int page)
{
    EventPage *thisPage = EventPages[page];
    return (thisPage->name);
}
int GetPageEventNum(int page)
{
    EventPage *thisPage = EventPages[page];
    return (thisPage->eventNum);
}
char *GetTMVers()
{
    return (TM_Vers);
}
char *GetTMCompile()
{
    return (TM_Compile);
}
int GetPageNum()
{
    int pageNum = (sizeof(EventPages) / 4) - 1;
    return (pageNum);
}
u8 GetIsChooseCPU(int page, int event)
{
    EventInfo *thisEvent = GetEvent(page, event);
    return (thisEvent->isChooseCPU);
}
u8 GetIsSelectStage(int page, int event)
{
    EventInfo *thisEvent = GetEvent(page, event);
    return (thisEvent->isSelectStage);
}
s8 GetFighter(int page, int event)
{
    EventInfo *thisEvent = GetEvent(page, event);
    return (thisEvent->matchData->playerKind);
}
s8 GetCPUFighter(int page, int event)
{
    EventInfo *thisEvent = GetEvent(page, event);
    return (thisEvent->matchData->cpuKind);
}
s16 GetStage(int page, int event)
{
    EventInfo *thisEvent = GetEvent(page, event);
    return (thisEvent->matchData->stage);
}
