#include "lab.h"
static char nullString[] = " ";

// CPU Action Definitions
static CPUAction Lab_CPUActionShield[] = {
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
static CPUAction Lab_CPUActionGrab[] = {
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
static CPUAction Lab_CPUActionUpB[] = {
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
static CPUAction Lab_CPUActionDownB[] = {
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
static CPUAction Lab_CPUActionSpotdodge[] = {
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
static CPUAction Lab_CPUActionRollAway[] = {
    {
        ASID_GUARD,    // state to perform this action. -1 for last
        0,             // first possible frame to perform this action
        0,             // last possible frame to perfrom this action
        127,           // left stick X value
        0,             // left stick Y value
        0,             // c stick X value
        0,             // c stick Y value
        PAD_TRIGGER_R, // button to input
        1,             // is the last input
        STCKDIR_AWAY,  // specify stick direction
    },
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
        STCKDIR_AWAY,      // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionRollTowards[] = {
    {
        ASID_GUARD,     // state to perform this action. -1 for last
        0,              // first possible frame to perform this action
        0,              // last possible frame to perfrom this action
        127,            // left stick X value
        0,              // left stick Y value
        0,              // c stick X value
        0,              // c stick Y value
        PAD_TRIGGER_R,  // button to input
        1,              // is the last input
        STCKDIR_TOWARD, // specify stick direction
    },
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
        STCKDIR_TOWARD,    // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionRollRandom[] = {
    {
        ASID_GUARD,    // state to perform this action. -1 for last
        0,             // first possible frame to perform this action
        0,             // last possible frame to perfrom this action
        127,           // left stick X value
        0,             // left stick Y value
        0,             // c stick X value
        0,             // c stick Y value
        PAD_TRIGGER_R, // button to input
        1,             // is the last input
        STICKDIR_RDM,  // specify stick direction
    },
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
        STICKDIR_RDM,      // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionNair[] = {
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
static CPUAction Lab_CPUActionFair[] = {
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
static CPUAction Lab_CPUActionDair[] = {
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
static CPUAction Lab_CPUActionBair[] = {
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
static CPUAction Lab_CPUActionUair[] = {
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
static CPUAction Lab_CPUActionJump[] = {
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
static CPUAction Lab_CPUActionJumpFull[] = {
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
        ASID_KNEEBEND, // state to perform this action. -1 for last
        0,             // first possible frame to perform this action
        0,             // last possible frame to perfrom this action
        0,             // left stick X value
        0,             // left stick Y value
        0,             // c stick X value
        0,             // c stick Y value
        PAD_BUTTON_X,  // button to input
        0,             // is the last input
        0,             // specify stick direction
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
static CPUAction Lab_CPUActionJumpAway[] = {
    {
        ASID_JUMPS, // state to perform this action. -1 for last
        0,          // first possible frame to perform this action
        0,          // last possible frame to perfrom this action
        127,        // left stick X value
        0,          // left stick Y value
        0,          // c stick X value
        0,          // c stick Y value
        0,          // button to input
        0,          // is the last input
        2,          // specify stick direction
    },
    {
        ASID_ACTIONABLE, // state to perform this action. -1 for last
        0,               // first possible frame to perform this action
        0,               // last possible frame to perfrom this action
        127,             // left stick X value
        0,               // left stick Y value
        0,               // c stick X value
        0,               // c stick Y value
        PAD_BUTTON_X,    // button to input
        0,               // is the last input
        STCKDIR_AWAY,    // specify stick direction
    },

    -1,
};
static CPUAction Lab_CPUActionJumpTowards[] = {
    {
        ASID_JUMPS, // state to perform this action. -1 for last
        0,          // first possible frame to perform this action
        0,          // last possible frame to perfrom this action
        127,        // left stick X value
        0,          // left stick Y value
        0,          // c stick X value
        0,          // c stick Y value
        0,          // button to input
        0,          // is the last input
        1,          // specify stick direction
    },
    {
        ASID_ACTIONABLE, // state to perform this action. -1 for last
        0,               // first possible frame to perform this action
        0,               // last possible frame to perfrom this action
        127,             // left stick X value
        0,               // left stick Y value
        0,               // c stick X value
        0,               // c stick Y value
        PAD_BUTTON_X,    // button to input
        0,               // is the last input
        STCKDIR_TOWARD,  // specify stick direction
    },

    -1,
};
static CPUAction Lab_CPUActionAirdodge[] = {
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
static CPUAction Lab_CPUActionFFTumble[] = {
    {
        ASID_DAMAGEAIR, // state to perform this action. -1 for last
        0,              // first possible frame to perform this action
        0,              // last possible frame to perfrom this action
        0,              // left stick X value
        -127,           // left stick Y value
        0,              // c stick X value
        0,              // c stick Y value
        0,              // button to input
        1,              // is the last input
        0,              // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionFFWiggle[] = {
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
        -127,               // left stick Y value
        0,                  // c stick X value
        0,                  // c stick Y value
        0,                  // button to input
        1,                  // is the last input
        0,                  // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionJab[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_BUTTON_A,          // button to input
        1,                     // is the last input
        0,                     // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionFTilt[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        80,                    // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_BUTTON_A,          // button to input
        1,                     // is the last input
        STCKDIR_TOWARD,        // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionUTilt[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        80,                    // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_BUTTON_A,          // button to input
        1,                     // is the last input
        0,                     // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionDTilt[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        -80,                   // left stick Y value
        0,                     // c stick X value
        0,                     // c stick Y value
        PAD_BUTTON_A,          // button to input
        1,                     // is the last input
        0,                     // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionUSmash[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        127,                   // c stick Y value
        0,                     // button to input
        1,                     // is the last input
        0,                     // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionDSmash[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        0,                     // c stick X value
        -127,                  // c stick Y value
        0,                     // button to input
        1,                     // is the last input
        0,                     // specify stick direction
    },
    -1,
};
static CPUAction Lab_CPUActionFSmash[] = {
    {
        ASID_ACTIONABLEGROUND, // state to perform this action. -1 for last
        0,                     // first possible frame to perform this action
        0,                     // last possible frame to perfrom this action
        0,                     // left stick X value
        0,                     // left stick Y value
        127,                   // c stick X value
        0,                     // c stick Y value
        0,                     // button to input
        1,                     // is the last input
        STCKDIR_TOWARD,        // specify stick direction
    },
    -1,
};

static CPUAction *Lab_CPUActions[] = {
    // none 0
    0,
    // shield 1
    &Lab_CPUActionShield,
    // grab 2
    &Lab_CPUActionGrab,
    // up b 3
    &Lab_CPUActionUpB,
    // down b 4
    &Lab_CPUActionDownB,
    // spotdodge 5
    &Lab_CPUActionSpotdodge,
    // roll away 6
    &Lab_CPUActionRollAway,
    // roll towards 7
    &Lab_CPUActionRollTowards,
    // roll random
    &Lab_CPUActionRollRandom,
    // nair 8
    &Lab_CPUActionNair,
    // fair 9
    &Lab_CPUActionFair,
    // dair 10
    &Lab_CPUActionDair,
    // bair 11
    &Lab_CPUActionBair,
    // uair 12
    &Lab_CPUActionUair,
    // short hop 13
    &Lab_CPUActionJump,
    // full hop 14
    &Lab_CPUActionJumpFull,
    // jump away 15
    &Lab_CPUActionJumpAway,
    // jump towards 16
    &Lab_CPUActionJumpTowards,
    // airdodge 17
    &Lab_CPUActionAirdodge,
    // fastfall 18
    &Lab_CPUActionFFTumble,
    // wiggle fastfall 19
    &Lab_CPUActionFFWiggle,
    // wiggle fastfall 19
    &Lab_CPUActionJab,
    &Lab_CPUActionFTilt,
    &Lab_CPUActionUTilt,
    &Lab_CPUActionDTilt,
    &Lab_CPUActionUSmash,
    &Lab_CPUActionDSmash,
    &Lab_CPUActionFSmash,
};
enum CPU_ACTIONS
{
    CPUACT_NONE,
    CPUACT_SHIELD,
    CPUACT_GRAB,
    CPUACT_UPB,
    CPUACT_DOWNB,
    CPUACT_SPOTDODGE,
    CPUACT_ROLLAWAY,
    CPUACT_ROLLTOWARDS,
    CPUACT_ROLLRDM,
    CPUACT_NAIR,
    CPUACT_FAIR,
    CPUACT_DAIR,
    CPUACT_BAIR,
    CPUACT_UAIR,
    CPUACT_SHORTHOP,
    CPUACT_FULLHOP,
    CPUACT_JUMPAWAY,
    CPUACT_JUMPTOWARDS,
    CPUACT_AIRDODGE,
    CPUACT_FFTUMBLE,
    CPUACT_FFWIGGLE,
    CPUACT_JAB,
    CPUACT_FTILT,
    CPUACT_UTILT,
    CPUACT_DTILT,
    CPUACT_USMASH,
    CPUACT_DSMASH,
    CPUACT_FSMASH,
};
static char *CPU_ACTIONS_NAMES[] = {
    "CPUACT_NONE",
    "CPUACT_SHIELD",
    "CPUACT_GRAB",
    "CPUACT_UPB",
    "CPUACT_DOWNB",
    "CPUACT_SPOTDODGE",
    "CPUACT_ROLLAWAY",
    "CPUACT_ROLLTOWARDS",
    "CPUACT_ROLLRDM",
    "CPUACT_NAIR",
    "CPUACT_FAIR",
    "CPUACT_DAIR",
    "CPUACT_BAIR",
    "CPUACT_UAIR",
    "CPUACT_SHORTHOP",
    "CPUACT_FULLHOP",
    "CPUACT_JUMPAWAY",
    "CPUACT_JUMPTOWARDS",
    "CPUACT_AIRDODGE",
    "CPUACT_FFTUMBLE",
    "CPUACT_FFWIGGLE",
    "CPUACT_JAB",
    "CPUACT_FTILT",
    "CPUACT_UTILT",
    "CPUACT_DTILT",
    "CPUACT_USMASH",
    "CPUACT_DSMASH",
    "CPUACT_FSMASH",
};
static u8 GrAcLookup[] = {CPUACT_NONE, CPUACT_SPOTDODGE, CPUACT_SHIELD, CPUACT_GRAB, CPUACT_UPB, CPUACT_DOWNB, CPUACT_USMASH, CPUACT_DSMASH, CPUACT_FSMASH, CPUACT_ROLLAWAY, CPUACT_ROLLTOWARDS, CPUACT_ROLLRDM, CPUACT_NAIR, CPUACT_FAIR, CPUACT_DAIR, CPUACT_BAIR, CPUACT_UAIR, CPUACT_JAB, CPUACT_FTILT, CPUACT_UTILT, CPUACT_DTILT, CPUACT_SHORTHOP, CPUACT_FULLHOP};
static u8 AirAcLookup[] = {CPUACT_NONE, CPUACT_AIRDODGE, CPUACT_JUMPAWAY, CPUACT_JUMPTOWARDS, CPUACT_UPB, CPUACT_DOWNB, CPUACT_NAIR, CPUACT_FAIR, CPUACT_DAIR, CPUACT_BAIR, CPUACT_UAIR, CPUACT_FFTUMBLE, CPUACT_FFWIGGLE};
static u8 ShieldAcLookup[] = {CPUACT_NONE, CPUACT_GRAB, CPUACT_SHORTHOP, CPUACT_FULLHOP, CPUACT_SPOTDODGE, CPUACT_ROLLAWAY, CPUACT_ROLLTOWARDS, CPUACT_ROLLRDM, CPUACT_UPB, CPUACT_DOWNB, CPUACT_NAIR, CPUACT_FAIR, CPUACT_DAIR, CPUACT_BAIR, CPUACT_UAIR};

// Main Menu
static char **LabOptions_OffOn[] = {"Off", "On"};
static EventOption LabOptions_Main[] = {
    {
        .option_kind = OPTKIND_MENU,                                                     // the type of option this is; menu, string list, integer list, etc
        .value_num = 0,                                                                  // number of values for this option
        .option_val = 0,                                                                 // value of this option
        .menu = &LabMenu_General,                                                        // pointer to the menu that pressing A opens
        .option_name = {"General"},                                                      // pointer to a string
        .desc = "Toggle player percent, overlays,\nframe advance, and camera settings.", // string describing what this option does
        .option_values = 0,                                                              // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_MENU,       // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                    // number of values for this option
        .option_val = 0,                   // value of this option
        .menu = &LabMenu_CPU,              // pointer to the menu that pressing A opens
        .option_name = {"CPU Options"},    // pointer to a string
        .desc = "Configure CPU behavior.", // string describing what this option does
        .option_values = 0,                // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_MENU,           // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                        // number of values for this option
        .option_val = 0,                       // value of this option
        .menu = &LabMenu_Record,               // pointer to the menu that pressing A opens
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
        .menu = &LabMenu_InfoDisplay,                         // pointer to the menu that pressing A opens
        .option_name = "Info Display",                        // pointer to a string
        .desc = "Display various game information onscreen.", // string describing what this option does
        .option_values = 0,                                   // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_FUNC,                                                                                       // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                                                                                                    // number of values for this option
        .option_val = 0,                                                                                                   // value of this option
        .menu = 0,                                                                                                         // pointer to the menu that pressing A opens
        .option_name = "Help",                                                                                             // pointer to a string
        .desc = "D-Pad Left - Load State\nD-Pad Right - Save State\nD-Pad Down - Move CPU\nHold R in the menu for turbo.", // string describing what this option does
        .option_values = 0,                                                                                                // pointer to an array of strings
        .onOptionChange = Lab_Exit,
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
        .onOptionSelect = Lab_Exit,
    },
};
static EventMenu LabMenu_Main = {
    .name = "Main Menu",                                         // the name of this menu
    .option_num = sizeof(LabOptions_Main) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                 // runtime variable used for how far down in the menu to start
    .state = 0,                                                  // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                 // index of the option currently selected, used at runtime
    .options = &LabOptions_Main,                                 // pointer to all of this menu's options
    .prev = 0,                                                   // pointer to previous menu, used at runtime
};
// General
static char **LabOptions_CamMode[] = {"Normal", "Zoom", "Fixed", "Advanced"};
static char **LabOptions_FrameAdvButton[] = {"L", "Z", "X", "Y"};
static EventOption LabOptions_General[] = {
    // frame advance
    {
        .option_kind = OPTKIND_STRING,                                                                 // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabOptions_OffOn) / 4,                                                     // number of values for this option
        .option_val = 0,                                                                               // value of this option
        .menu = 0,                                                                                     // pointer to the menu that pressing A opens
        .option_name = "Frame Advance",                                                                // pointer to a string
        .desc = "Enable frame advance. Press to advance one\nframe. Hold to advance at normal speed.", // string describing what this option does
        .option_values = LabOptions_OffOn,                                                             // pointer to an array of strings
        .onOptionChange = Lab_ChangeFrameAdvance,
    },
    // frame advance button
    {
        .option_kind = OPTKIND_STRING,                        // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabOptions_FrameAdvButton) / 4,   // number of values for this option
        .option_val = 0,                                      // value of this option
        .menu = 0,                                            // pointer to the menu that pressing A opens
        .option_name = "Frame Advance Button",                // pointer to a string
        .desc = "Choose which button will advance the frame", // string describing what this option does
        .option_values = LabOptions_FrameAdvButton,           // pointer to an array of strings
        .onOptionChange = 0,
        .disable = 1,
    },
    // p1 percent
    {
        .option_kind = OPTKIND_INT,             // the type of option this is; menu, string list, integer list, etc
        .value_num = 999,                       // number of values for this option
        .option_val = 0,                        // value of this option
        .menu = 0,                              // pointer to the menu that pressing A opens
        .option_name = "Player Percent",        // pointer to a string
        .desc = "Adjust the player's percent.", // string describing what this option does
        .option_values = "%d%%",                // pointer to an array of strings
        .onOptionChange = Lab_ChangePlayerPercent,
    },
    // model display
    {
        .option_kind = OPTKIND_STRING,                      // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                     // number of values for this option
        .option_val = 1,                                    // value of this option
        .menu = 0,                                          // pointer to the menu that pressing A opens
        .option_name = "Model Display",                     // pointer to a string
        .desc = "Toggle player and item model visibility.", // string describing what this option does
        .option_values = LabOptions_OffOn,                  // pointer to an array of strings
        .onOptionChange = Lab_ChangeModelDisplay,
    },
    // fighter collision
    {
        .option_kind = OPTKIND_STRING,                                                                                                                           // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                                                                                                                          // number of values for this option
        .option_val = 0,                                                                                                                                         // value of this option
        .menu = 0,                                                                                                                                               // pointer to the menu that pressing A opens
        .option_name = "Fighter Collision",                                                                                                                      // pointer to a string
        .desc = "Toggle hitbox and hurtbox visualization.\nYellow = hurt, red = hit, purple = grab, \nwhite = trigger, green = reflect,\nblue = shield/absorb.", // string describing what this option does
        .option_values = LabOptions_OffOn,                                                                                                                       // pointer to an array of strings
        .onOptionChange = Lab_ChangeHitDisplay,
    },
    // environment collision
    {
        .option_kind = OPTKIND_STRING,                                                                                          // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                                                                                         // number of values for this option
        .option_val = 0,                                                                                                        // value of this option
        .menu = 0,                                                                                                              // pointer to the menu that pressing A opens
        .option_name = "Environment Collision",                                                                                 // pointer to a string
        .desc = "Toggle environment collision visualization.\nAlso displays the players' ECB (environmental \ncollision box).", // string describing what this option does
        .option_values = LabOptions_OffOn,                                                                                      // pointer to an array of strings
        .onOptionChange = Lab_ChangeEnvCollDisplay,
    },
    // camera mode
    {
        .option_kind = OPTKIND_STRING,                                                                                                      // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabOptions_CamMode) / 4,                                                                                        // number of values for this option
        .option_val = 0,                                                                                                                    // value of this option
        .menu = 0,                                                                                                                          // pointer to the menu that pressing A opens
        .option_name = "Camera Mode",                                                                                                       // pointer to a string
        .desc = "Adjust the camera's behavior.\nIn advanced mode, use C-Stick while holding\nA/B/Y to pan, rotate and zoom, respectively.", // string describing what this option does
        .option_values = LabOptions_CamMode,                                                                                                // pointer to an array of strings
        .onOptionChange = Lab_ChangeCamMode,
    },
    // hud
    {
        .option_kind = OPTKIND_STRING,                          // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                         // number of values for this option
        .option_val = 1,                                        // value of this option
        .menu = 0,                                              // pointer to the menu that pressing A opens
        .option_name = "HUD",                                   // pointer to a string
        .desc = "Toggle player percents and timer visibility.", // string describing what this option does
        .option_values = LabOptions_OffOn,                      // pointer to an array of strings
        .onOptionChange = Lab_ChangeHUD,
    },
    // di display
    {
        .option_kind = OPTKIND_STRING,                                                                                      // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                                                                                     // number of values for this option
        .option_val = 0,                                                                                                    // value of this option
        .menu = 0,                                                                                                          // pointer to the menu that pressing A opens
        .option_name = "DI Display",                                                                                        // pointer to a string
        .desc = "Display knockback trajectories.\nUse frame advance to see the effects of DI\nin realtime during hitstop.", // string describing what this option does
        .option_values = LabOptions_OffOn,                                                                                  // pointer to an array of strings
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
        .option_values = LabOptions_OffOn,         // pointer to an array of strings
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
        .option_values = LabOptions_OffOn,                                                      // pointer to an array of strings
        .onOptionChange = 0,
    },
};
static EventMenu LabMenu_General = {
    .name = "General",                                              // the name of this menu
    .option_num = sizeof(LabOptions_General) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                    // runtime variable used for how far down in the menu to start
    .state = 0,                                                     // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                    // index of the option currently selected, used at runtime
    .options = &LabOptions_General,                                 // pointer to all of this menu's options
    .prev = 0,                                                      // pointer to previous menu, used at runtime
};
// Info Display
static char **LabValues_InfoDisplay[] = {"None", "Position", "State Name", "State Frame", "Velocity - Self", "Velocity - KB", "Velocity - Total", "Engine LStick", "System LStick", "Engine CStick", "System CStick", "Engine Trigger", "System Trigger", "Ledgegrab Timer", "Intangibility Timer", "Hitlag", "Hitstun", "Shield Health", "Shield Stun", "Grip Strength", "ECB Lock", "ECB Bottom", "Jumps", "Walljumps", "Jab Counter", "Line Info", "Blastzone Left/Right", "Blastzone Up/Down"};
static char **LabValues_InfoPresets[] = {"None", "Custom", "Ledge", "Damage"};
//static char **LabValues_InfoPosition[] = {"Top Left", "Top Mid", "Top Right", "Bottom Left", "Bottom Mid", "Bottom Right"};
static char **LabValues_InfoSize[] = {"Small", "Medium", "Large"};
static char **LabValues_InfoPlayers[] = {"Player 1", "Player 2", "Player 3", "Player 4"};
static EventOption LabOptions_InfoDisplay[] = {
    {
        .option_kind = OPTKIND_STRING,                           // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoPlayers) / 4,          // number of values for this option
        .option_val = 0,                                         // value of this option
        .menu = 0,                                               // pointer to the menu that pressing A opens
        .option_name = "Player",                                 // pointer to a string
        .desc = "Toggle which player's information to display.", // string describing what this option does
        .option_values = LabValues_InfoPlayers,                  // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoPlayer,
    },
    {
        .option_kind = OPTKIND_STRING,                                                                                                        // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoSize) / 4,                                                                                          // number of values for this option
        .option_val = 1,                                                                                                                      // value of this option
        .menu = 0,                                                                                                                            // pointer to the menu that pressing A opens
        .option_name = "Size",                                                                                                                // pointer to a string
        .desc = "Change the size of the info display window.\nLarge is recommended for CRT.\nMedium/Small recommended for Dolphin Emulator.", // string describing what this option does
        .option_values = LabValues_InfoSize,                                                                                                  // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoSizePos,
    },
    {
        .option_kind = OPTKIND_STRING,                       // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoPresets) / 4,      // number of values for this option
        .option_val = 0,                                     // value of this option
        .menu = 0,                                           // pointer to the menu that pressing A opens
        .option_name = "Display Preset",                     // pointer to a string
        .desc = "Choose between pre-configured selections.", // string describing what this option does
        .option_values = LabValues_InfoPresets,              // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoPreset,
    },
    {
        .option_kind = OPTKIND_STRING,                   // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoDisplay) / 4,  // number of values for this option
        .option_val = 0,                                 // value of this option
        .menu = 0,                                       // pointer to the menu that pressing A opens
        .option_name = "Row 1",                          // pointer to a string
        .desc = "Adjust what is displayed in this row.", // string describing what this option does
        .option_values = LabValues_InfoDisplay,          // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                   // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoDisplay) / 4,  // number of values for this option
        .option_val = 0,                                 // value of this option
        .menu = 0,                                       // pointer to the menu that pressing A opens
        .option_name = "Row 2",                          // pointer to a string
        .desc = "Adjust what is displayed in this row.", // string describing what this option does
        .option_values = LabValues_InfoDisplay,          // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                   // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoDisplay) / 4,  // number of values for this option
        .option_val = 0,                                 // value of this option
        .menu = 0,                                       // pointer to the menu that pressing A opens
        .option_name = "Row 3",                          // pointer to a string
        .desc = "Adjust what is displayed in this row.", // string describing what this option does
        .option_values = LabValues_InfoDisplay,          // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                   // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoDisplay) / 4,  // number of values for this option
        .option_val = 0,                                 // value of this option
        .menu = 0,                                       // pointer to the menu that pressing A opens
        .option_name = "Row 4",                          // pointer to a string
        .desc = "Adjust what is displayed in this row.", // string describing what this option does
        .option_values = LabValues_InfoDisplay,          // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                   // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoDisplay) / 4,  // number of values for this option
        .option_val = 0,                                 // value of this option
        .menu = 0,                                       // pointer to the menu that pressing A opens
        .option_name = "Row 5",                          // pointer to a string
        .desc = "Adjust what is displayed in this row.", // string describing what this option does
        .option_values = LabValues_InfoDisplay,          // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                   // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoDisplay) / 4,  // number of values for this option
        .option_val = 0,                                 // value of this option
        .menu = 0,                                       // pointer to the menu that pressing A opens
        .option_name = "Row 6",                          // pointer to a string
        .desc = "Adjust what is displayed in this row.", // string describing what this option does
        .option_values = LabValues_InfoDisplay,          // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                   // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoDisplay) / 4,  // number of values for this option
        .option_val = 0,                                 // value of this option
        .menu = 0,                                       // pointer to the menu that pressing A opens
        .option_name = "Row 7",                          // pointer to a string
        .desc = "Adjust what is displayed in this row.", // string describing what this option does
        .option_values = LabValues_InfoDisplay,          // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoRow,
    },
    {
        .option_kind = OPTKIND_STRING,                   // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_InfoDisplay) / 4,  // number of values for this option
        .option_val = 0,                                 // value of this option
        .menu = 0,                                       // pointer to the menu that pressing A opens
        .option_name = "Row 8",                          // pointer to a string
        .desc = "Adjust what is displayed in this row.", // string describing what this option does
        .option_values = LabValues_InfoDisplay,          // pointer to an array of strings
        .onOptionChange = Lab_ChangeInfoRow,
    },
};
static EventMenu LabMenu_InfoDisplay = {
    .name = "Info Display",             // the name of this menu
    .option_num = 11,                   // number of options this menu contains
    .scroll = 0,                        // runtime variable used for how far down in the menu to start
    .state = 0,                         // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                        // index of the option currently selected, used at runtime
    .options = &LabOptions_InfoDisplay, // pointer to all of this menu's options
    .prev = 0,                          // pointer to previous menu, used at runtime
};
// CPU
static char **LabValues_Shield[] = {"Off", "On Until Hit", "On"};
static char **LabValues_CPUBehave[] = {"Stand", "Shield", "Crouch", "Jump"};
static char **LabValues_TDI[] = {"Random", "Inwards", "Outwards", "Floorhug", "Custom", "None"};
static char **LabValues_SDIFreq[] = {"None", "Low", "Medium", "High"};
static char **LabValues_SDIDir[] = {"Random", "Away", "Towards"};
static char **LabValues_Tech[] = {"Random", "Neutral", "Away", "Towards", "None"};
static char **LabValues_Getup[] = {"Random", "Stand", "Away", "Towards", "Attack"};
static char **LabValues_CounterGround[] = {"None", "Spotdodge", "Shield", "Grab", "Up B", "Down B", "Up Smash", "Down Smash", "Forward Smash", "Roll Away", "Roll Towards", "Roll Random", "Neutral Air", "Forward Air", "Down Air", "Back Air", "Up Air", "Jab", "Forward Tilt", "Up Tilt", "Down Tilt", "Short Hop", "Full Hop"};
static char **LabValues_CounterAir[] = {"None", "Airdodge", "Jump Away", "Jump Towards", "Up B", "Down B", "Neutral Air", "Forward Air", "Down Air", "Back Air", "Up Air", "Tumble Fastfall", "Wiggle Fastfall"};
static char **LabValues_CounterShield[] = {"None", "Grab", "Short Hop", "Full Hop", "Spotdodge", "Roll Away", "Roll Towards", "Roll Random", "Up B", "Down B", "Neutral Air", "Forward Air", "Down Air", "Back Air", "Up Air"};
static char **LabValues_GrabEscape[] = {"None", "Medium", "High", "Perfect"};
static EventOption LabOptions_CPU[] = {
    // cpu percent
    {
        .option_kind = OPTKIND_INT,          // the type of option this is; menu, string list, integer list, etc
        .value_num = 999,                    // number of values for this option
        .option_val = 0,                     // value of this option
        .menu = 0,                           // pointer to the menu that pressing A opens
        .option_name = "CPU Percent",        // pointer to a string
        .desc = "Adjust the CPU's percent.", // string describing what this option does
        .option_values = "%d%%",             // pointer to an array of strings
        .onOptionChange = Lab_ChangeCPUPercent,
    },
    {
        .option_kind = OPTKIND_STRING,                // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_CPUBehave) / 4, // number of values for this option
        .option_val = 0,                              // value of this option
        .menu = 0,                                    // pointer to the menu that pressing A opens
        .option_name = "Behavior",                    // pointer to a string
        .desc = "Adjust the CPU's default action.",   // string describing what this option does
        .option_values = LabValues_CPUBehave,         // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                    // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_Shield) / 4,        // number of values for this option
        .option_val = 1,                                  // value of this option
        .menu = 0,                                        // pointer to the menu that pressing A opens
        .option_name = {"Infinite Shields"},              // pointer to a string
        .desc = "Adjust how shield health deteriorates.", // string describing what this option does
        .option_values = LabValues_Shield,                // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                      // the type of option this is; menu, string list, integer list, etc
        .value_num = 2,                                     // number of values for this option
        .option_val = 0,                                    // value of this option
        .menu = 0,                                          // pointer to the menu that pressing A opens
        .option_name = {"Intangibility"},                   // pointer to a string
        .desc = "Toggle the CPU's ability to take damage.", // string describing what this option does
        .option_values = LabOptions_OffOn,                  // pointer to an array of strings
        .onOptionChange = Lab_ChangeCPUIntang,
    },
    // SDI Freq
    {
        .option_kind = OPTKIND_STRING,                                                 // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_SDIFreq) / 4,                                    // number of values for this option
        .option_val = 2,                                                               // value of this option
        .menu = 0,                                                                     // pointer to the menu that pressing A opens
        .option_name = "Smash DI Frequency",                                           // pointer to a string
        .desc = "Adjust how often the CPU will alter their position\nduring hitstop.", // string describing what this option does
        .option_values = LabValues_SDIFreq,                                            // pointer to an array of strings
        .onOptionChange = 0,
    },
    // SDI Direction
    {
        .option_kind = OPTKIND_STRING,                                                               // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_SDIDir) / 4,                                                   // number of values for this option
        .option_val = 0,                                                                             // value of this option
        .menu = 0,                                                                                   // pointer to the menu that pressing A opens
        .option_name = "Smash DI Direction",                                                         // pointer to a string
        .desc = "Adjust the direction in which the CPU will alter \ntheir position during hitstop.", // string describing what this option does
        .option_values = LabValues_SDIDir,                                                           // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                        // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_TDI) / 4,                               // number of values for this option
        .option_val = 0,                                                      // value of this option
        .menu = 0,                                                            // pointer to the menu that pressing A opens
        .option_name = "Trajectory DI",                                       // pointer to a string
        .desc = "Adjust how the CPU will alter their knockback\ntrajectory.", // string describing what this option does
        .option_values = LabValues_TDI,                                       // pointer to an array of strings
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
        .onOptionSelect = Lab_SelectCustomTDI,
    },
    {
        .option_kind = OPTKIND_STRING,                                         // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_Tech) / 4,                               // number of values for this option
        .option_val = 0,                                                       // value of this option
        .menu = 0,                                                             // pointer to the menu that pressing A opens
        .option_name = "Tech Option",                                          // pointer to a string
        .desc = "Adjust what the CPU will do upon colliding\nwith the stage.", // string describing what this option does
        .option_values = LabValues_Tech,                                       // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                      // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_Getup) / 4,                           // number of values for this option
        .option_val = 0,                                                    // value of this option
        .menu = 0,                                                          // pointer to the menu that pressing A opens
        .option_name = "Get Up Option",                                     // pointer to a string
        .desc = "Adjust what the CPU will do after missing\na tech input.", // string describing what this option does
        .option_values = LabValues_Getup,                                   // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                               // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_GrabEscape) / 4,               // number of values for this option
        .option_val = CPUMASH_HIGH,                                  // value of this option
        .menu = 0,                                                   // pointer to the menu that pressing A opens
        .option_name = "Grab Escape",                                // pointer to a string
        .desc = "Adjust how the CPU will attempt to escape\ngrabs.", // string describing what this option does
        .option_values = LabValues_GrabEscape,                       // pointer to an array of strings
        .onOptionChange = 0,
    },
    /*
    {
        .option_kind = OPTKIND_STRING,                               // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabOptions_OffOn) / 4,                   // number of values for this option
        .option_val = 0,                                             // value of this option
        .menu = 0,                                                   // pointer to the menu that pressing A opens
        .option_name = "Auto Reset",                                 // pointer to a string
        .desc = "Automatically reset after the CPU is\nactionable.", // string describing what this option does
        .option_values = LabOptions_OffOn,                           // pointer to an array of strings
        .onOptionChange = 0,
    },
*/
    {
        .option_kind = OPTKIND_STRING,                                                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_CounterGround) / 4,                                  // number of values for this option
        .option_val = 1,                                                                   // value of this option
        .menu = 0,                                                                         // pointer to the menu that pressing A opens
        .option_name = "Counter Action (Ground)",                                          // pointer to a string
        .desc = "Select the action to be performed after a\ngrounded CPU's hitstun ends.", // string describing what this option does
        .option_values = LabValues_CounterGround,                                          // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                                      // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_CounterAir) / 4,                                      // number of values for this option
        .option_val = 1,                                                                    // value of this option
        .menu = 0,                                                                          // pointer to the menu that pressing A opens
        .option_name = "Counter Action (Air)",                                              // pointer to a string
        .desc = "Select the action to be performed after an\nairborne CPU's hitstun ends.", // string describing what this option does
        .option_values = LabValues_CounterAir,                                              // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                               // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_CounterShield) / 4,                            // number of values for this option
        .option_val = 1,                                                             // value of this option
        .menu = 0,                                                                   // pointer to the menu that pressing A opens
        .option_name = "Counter Action (Shield)",                                    // pointer to a string
        .desc = "Select the action to be performed after the\nCPU's shield is hit.", // string describing what this option does
        .option_values = LabValues_CounterShield,                                    // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_INT,                                                  // the type of option this is; menu, string list, integer list, etc
        .value_num = 100,                                                            // number of values for this option
        .option_val = 0,                                                             // value of this option
        .menu = 0,                                                                   // pointer to the menu that pressing A opens
        .option_name = "Counter After Frames",                                       // pointer to a string
        .desc = "Adjust the amount of actionable frames before \nthe CPU counters.", // string describing what this option does
        .option_values = "%d Frames",                                                // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_INT,                                           // the type of option this is; menu, string list, integer list, etc
        .value_num = 100,                                                     // number of values for this option
        .option_val = 1,                                                      // value of this option
        .menu = 0,                                                            // pointer to the menu that pressing A opens
        .option_name = "Counter After Hits",                                  // pointer to a string
        .desc = "Adjust the amount of hits taken before the \nCPU counters.", // string describing what this option does
        .option_values = "%d Hits",                                           // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_INT,                                                           // the type of option this is; menu, string list, integer list, etc
        .value_num = 100,                                                                     // number of values for this option
        .option_val = 1,                                                                      // value of this option
        .menu = 0,                                                                            // pointer to the menu that pressing A opens
        .option_name = "Counter After Shield Hits",                                           // pointer to a string
        .desc = "Adjust the amount of hits the CPU's shield\nwill take before they counter.", // string describing what this option does
        .option_values = "%d Hits",                                                           // pointer to an array of strings
        .onOptionChange = 0,
    },
};
static EventMenu LabMenu_CPU = {
    .name = "CPU Options",                                      // the name of this menu
    .option_num = sizeof(LabOptions_CPU) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                // runtime variable used for how far down in the menu to start
    .state = 0,                                                 // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                // index of the option currently selected, used at runtime
    .options = &LabOptions_CPU,                                 // pointer to all of this menu's options
    .prev = 0,                                                  // pointer to previous menu, used at runtime
};
// Recording
static char **LabValues_RecordSlot[] = {"Random", "Slot 1", "Slot 2", "Slot 3", "Slot 4", "Slot 5", "Slot 6"};
static char **LabValues_HMNRecordMode[] = {"Off", "Record", "Playback"};
static char **LabValues_CPURecordMode[] = {"Off", "Control", "Record", "Playback"};
static EventOption LabOptions_Record[] = {
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
        .option_kind = OPTKIND_FUNC,                                                             // the type of option this is; menu, string list, integer list, etc
        .value_num = 0,                                                                          // number of values for this option
        .option_val = 0,                                                                         // value of this option
        .menu = 0,                                                                               // pointer to the menu that pressing A opens
        .option_name = "Restore Positions",                                                      // pointer to a string
        .desc = "Load the saved fighter positions and \nstart the sequence from the beginning.", // string describing what this option does
        .option_values = 0,                                                                      // pointer to an array of strings
        .onOptionSelect = Record_RestoreState,
    },
    {
        .option_kind = OPTKIND_STRING,                               // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_HMNRecordMode) / 4,            // number of values for this option
        .option_val = 0,                                             // value of this option
        .menu = 0,                                                   // pointer to the menu that pressing A opens
        .option_name = "HMN Mode",                                   // pointer to a string
        .desc = "Toggle between recording and playback of\ninputs.", // string describing what this option does
        .option_values = LabValues_HMNRecordMode,                    // pointer to an array of strings
        .onOptionChange = Record_ChangeHMNMode,
    },
    {
        .option_kind = OPTKIND_STRING,                                                                                       // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_RecordSlot) / 4,                                                                       // number of values for this option
        .option_val = 1,                                                                                                     // value of this option
        .menu = 0,                                                                                                           // pointer to the menu that pressing A opens
        .option_name = "HMN Record Slot",                                                                                    // pointer to a string
        .desc = "Toggle which recording slot to save inputs \nto. Maximum of 6 and can be set to random \nduring playback.", // string describing what this option does
        .option_values = LabValues_RecordSlot,                                                                               // pointer to an array of strings
        .onOptionChange = Record_ChangeHMNSlot,
    },
    {
        .option_kind = OPTKIND_STRING,                               // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_CPURecordMode) / 4,            // number of values for this option
        .option_val = 0,                                             // value of this option
        .menu = 0,                                                   // pointer to the menu that pressing A opens
        .option_name = "CPU Mode",                                   // pointer to a string
        .desc = "Toggle between recording and playback of\ninputs.", // string describing what this option does
        .option_values = LabValues_CPURecordMode,                    // pointer to an array of strings
        .onOptionChange = Record_ChangeCPUMode,
    },
    {
        .option_kind = OPTKIND_STRING,                                                                                       // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabValues_RecordSlot) / 4,                                                                       // number of values for this option
        .option_val = 1,                                                                                                     // value of this option
        .menu = 0,                                                                                                           // pointer to the menu that pressing A opens
        .option_name = "CPU Record Slot",                                                                                    // pointer to a string
        .desc = "Toggle which recording slot to save inputs \nto. Maximum of 6 and can be set to random \nduring playback.", // string describing what this option does
        .option_values = LabValues_RecordSlot,                                                                               // pointer to an array of strings
        .onOptionChange = Record_ChangeCPUSlot,
    },
    {
        .option_kind = OPTKIND_STRING,                     // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabOptions_OffOn) / 4,         // number of values for this option
        .option_val = 0,                                   // value of this option
        .menu = 0,                                         // pointer to the menu that pressing A opens
        .option_name = "Loop Input Playback",              // pointer to a string
        .desc = "Loop the recorded inputs when they end.", // string describing what this option does
        .option_values = LabOptions_OffOn,                 // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_STRING,                                              // the type of option this is; menu, string list, integer list, etc
        .value_num = sizeof(LabOptions_OffOn) / 4,                                  // number of values for this option
        .option_val = 0,                                                            // value of this option
        .menu = 0,                                                                  // pointer to the menu that pressing A opens
        .option_name = "Auto Restore",                                              // pointer to a string
        .desc = "Automatically restore saved positions \nafter the playback ends.", // string describing what this option does
        .option_values = LabOptions_OffOn,                                          // pointer to an array of strings
        .onOptionChange = 0,
    },
    {
        .option_kind = OPTKIND_FUNC,                                                             // the type of option this is; menu, string list, integer list, etc
        .value_num = 0,                                                                          // number of values for this option
        .option_val = 0,                                                                         // value of this option
        .menu = 0,                                                                               // pointer to the menu that pressing A opens
        .option_name = "Export",                                                                 // pointer to a string
        .desc = "Export the recording to a memory card\nfor later use or to share with others.", // string describing what this option does
        .option_values = 0,                                                                      // pointer to an array of strings
        .onOptionSelect = Export_Init,
    },
};
static EventMenu LabMenu_Record = {
    .name = "Recording",                                           // the name of this menu
    .option_num = sizeof(LabOptions_Record) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                   // runtime variable used for how far down in the menu to start
    .state = 0,                                                    // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                   // index of the option currently selected, used at runtime
    .options = &LabOptions_Record,                                 // pointer to all of this menu's options
    .prev = 0,                                                     // pointer to previous menu, used at runtime
};

// Static Variables
static DIDraw didraws[6];
static GOBJ *infodisp_gobj;
static RecData rec_data;
static Savestate *rec_state;
static _HSD_ImageDesc snap_image = {0};
static _HSD_ImageDesc resized_image = {
    .format = 4,
    .height = RESIZE_HEIGHT,
    .width = RESIZE_WIDTH,
};
static u8 snap_status;
static u8 export_status;
static Arch_LabData *stc_lab_data;
static char *tm_filename = "TMREC_%02d%02d%04d_%02d%02d%02d";
static char stc_save_name[32] = "Training Mode Input Recording   ";
static DevText *stc_devtext;
static u8 stc_hmn_controller;             // making this static so importing recording doesnt overwrite
static u8 stc_cpu_controller;             // making this static so importing recording doesnt overwrite
static u8 stc_tdi_val_num;                // number of custom tdi values set
static s8 stc_tdi_vals[TDI_HITNUM][2][2]; // contains the custom tdi values
static u8 stc_sdifreqs[] = {6, 4, 2};

// Static Export Variables
static RecordingSave *stc_rec_save;
static u32 stc_transfer_buf_size;
static u8 *stc_transfer_buf;
static MemcardSave memcard_save;
static int chunk_num;
static int save_pre_tick;
static char *slots_names[] = {"A", "B"};

// lz77 functions credited to https://github.com/andyherbert/lz1
int x_to_the_n(int x, int n)
{
    int i; /* Variable used in loop counter */
    int number = 1;

    for (i = 0; i < n; ++i)
        number *= x;

    return (number);
}
u32 lz77_compress(u8 *uncompressed_text, u32 uncompressed_size, u8 *compressed_text, u8 pointer_length_width)
{
    u16 pointer_pos, temp_pointer_pos, output_pointer, pointer_length, temp_pointer_length;
    u32 compressed_pointer, output_size, coding_pos, output_lookahead_ref, look_behind, look_ahead;
    u16 pointer_pos_max, pointer_length_max;
    pointer_pos_max = x_to_the_n(2, 16 - pointer_length_width);
    pointer_length_max = x_to_the_n(2, pointer_length_width);

    *((u32 *)compressed_text) = uncompressed_size;
    *(compressed_text + 4) = pointer_length_width;
    compressed_pointer = output_size = 5;

    for (coding_pos = 0; coding_pos < uncompressed_size; ++coding_pos)
    {
        pointer_pos = 0;
        pointer_length = 0;
        for (temp_pointer_pos = 1; (temp_pointer_pos < pointer_pos_max) && (temp_pointer_pos <= coding_pos); ++temp_pointer_pos)
        {
            look_behind = coding_pos - temp_pointer_pos;
            look_ahead = coding_pos;
            for (temp_pointer_length = 0; uncompressed_text[look_ahead++] == uncompressed_text[look_behind++]; ++temp_pointer_length)
                if (temp_pointer_length == pointer_length_max)
                    break;
            if (temp_pointer_length > pointer_length)
            {
                pointer_pos = temp_pointer_pos;
                pointer_length = temp_pointer_length;
                if (pointer_length == pointer_length_max)
                    break;
            }
        }
        coding_pos += pointer_length;
        if ((coding_pos == uncompressed_size) && pointer_length)
        {
            output_pointer = (pointer_length == 1) ? 0 : ((pointer_pos << pointer_length_width) | (pointer_length - 2));
            output_lookahead_ref = coding_pos - 1;
        }
        else
        {
            output_pointer = (pointer_pos << pointer_length_width) | (pointer_length ? (pointer_length - 1) : 0);
            output_lookahead_ref = coding_pos;
        }
        *((u16 *)(compressed_text + compressed_pointer)) = output_pointer;
        compressed_pointer += 2;
        *(compressed_text + compressed_pointer++) = *(uncompressed_text + output_lookahead_ref);
        output_size += 3;
    }

    return output_size;
}
u32 lz77_decompress(u8 *compressed_text, u8 *uncompressed_text)
{
    u8 pointer_length_width;
    u16 input_pointer, pointer_length, pointer_pos, pointer_length_mask;
    u32 compressed_pointer, coding_pos, pointer_offset, uncompressed_size;

    uncompressed_size = *((u32 *)compressed_text);
    pointer_length_width = *(compressed_text + 4);
    compressed_pointer = 5;

    pointer_length_mask = x_to_the_n(2, pointer_length_width) - 1;

    for (coding_pos = 0; coding_pos < uncompressed_size; ++coding_pos)
    {
        input_pointer = *((u16 *)(compressed_text + compressed_pointer));
        compressed_pointer += 2;
        pointer_pos = input_pointer >> pointer_length_width;
        pointer_length = pointer_pos ? ((input_pointer & pointer_length_mask) + 1) : 0;
        if (pointer_pos)
            for (pointer_offset = coding_pos - pointer_pos; pointer_length > 0; --pointer_length)
                uncompressed_text[coding_pos++] = uncompressed_text[pointer_offset++];
        *(uncompressed_text + coding_pos) = *(compressed_text + compressed_pointer++);
    }

    return coding_pos;
}

// Menu Callbacks
void Lab_ChangePlayerPercent(GOBJ *menu_gobj, int value)
{
    GOBJ *fighter = Fighter_GetGObj(0);
    FighterData *fighter_data = fighter->userdata;

    fighter_data->dmg.percent = value;
    Fighter_SetHUDDamage(0, value);

    return;
}
void Lab_ChangeFrameAdvance(GOBJ *menu_gobj, int value)
{

    // remove colanim if toggling off
    if (value == 0)
        LabOptions_General[OPTGEN_FRAMEBTN].disable = 1;
    // apply colanim
    else
        LabOptions_General[OPTGEN_FRAMEBTN].disable = 0;

    return;
}
void Lab_ChangeCPUPercent(GOBJ *menu_gobj, int value)
{
    GOBJ *fighter = Fighter_GetGObj(1);
    FighterData *fighter_data = fighter->userdata;

    fighter_data->dmg.percent = value;
    Fighter_SetHUDDamage(1, value);

    return;
}
void Lab_ChangeCPUIntang(GOBJ *menu_gobj, int value)
{

    GOBJ *fighter = Fighter_GetGObj(1);
    FighterData *fighter_data = fighter->userdata;

    // remove colanim if toggling off
    if (value == 0)
        Fighter_ColorRemove(fighter_data, INTANG_COLANIM);
    // apply colanim
    else
        Fighter_ApplyOverlay(fighter_data, INTANG_COLANIM, 0);

    return;
}
void Lab_ChangeModelDisplay(GOBJ *menu_gobj, int value)
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
void Lab_ChangeHitDisplay(GOBJ *menu_gobj, int value)
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
void Lab_ChangeEnvCollDisplay(GOBJ *menu_gobj, int value)
{
    stc_matchcam->show_coll = value;
    return;
}
void Lab_ChangeCamMode(GOBJ *menu_gobj, int value)
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
void Lab_ChangeInfoRow(GOBJ *menu_gobj, int value)
{
    EventOption *idOptions = &LabOptions_InfoDisplay;

    // changed option, set preset to custom
    idOptions[OPTINF_PRESET].option_val = 1;
}
void Lab_ChangeInfoPreset(GOBJ *menu_gobj, int value)
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

    EventOption *idOptions = &LabOptions_InfoDisplay;
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
void Lab_ChangeInfoSizePos(GOBJ *menu_gobj, int value)
{

    return;
}
void Lab_ChangeInfoPlayer(GOBJ *menu_gobj, int value)
{

    return;
}
void Lab_ChangeHUD(GOBJ *menu_gobj, int value)
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
void Lab_Exit(int value)
{
    Match *match = MATCH;

    // end game
    match->state = 3;

    // cleanup
    Match_EndVS();

    // Unfreeze
    LabOptions_General[OPTGEN_FRAME].option_val = 0;
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
    infodisp_gobj = idGOBJ;
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
    //menu->scale.X = INFDISP_SCALE;
    //menu->scale.Y = INFDISP_SCALE;
    //menu->scale.Z = INFDISP_SCALE;
    menu->trans.X = INFDISP_X;
    menu->trans.Y = INFDISP_Y;
    corners[0]->trans.X = 0;
    corners[1]->trans.X = INFDISP_WIDTH;
    corners[2]->trans.X = 0;
    corners[3]->trans.X = INFDISP_WIDTH;
    corners[0]->trans.Y = 0;
    corners[1]->trans.Y = 0;
    corners[2]->trans.Y = 0;
    corners[3]->trans.Y = 0;

    //JOBJ_SetFlags(menu, JOBJ_HIDDEN);
    menu->dobj->next->mobj->mat->alpha = 0.6;

    // Create text object
    int canvas_index = Text_CreateCanvas(2, idGOBJ, 14, 15, 0, GXLINK_INFDISPTEXT, GXPRI_INFDISPTEXT, 19);
    Text *text = Text_CreateText(2, canvas_index);
    text->kerning = 1;
    text->use_aspect = 1;
    text->aspect.X = 545;

    // Create subtexts for each row
    for (int i = 0; i < 8; i++)
    {
        Text_AddSubtext(text, 0, (INFDISPTEXT_YOFFSET * i), &nullString);
    }
    idData->text = text;

    // adjust size based on the console / settings
    if ((OSGetConsoleType() == OS_CONSOLE_DEVHW3) || (stc_HSD_VI->is_prog == 1)) // 480p / dolphin uses medium by default
        LabOptions_InfoDisplay[OPT_SCALE].option_val = 1;
    else // 480i on wii uses large (shitty composite!)
        LabOptions_InfoDisplay[OPT_SCALE].option_val = 2;

    // update size
    Lab_ChangeInfoSizePos(0, 0);

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

    static Vec2 stc_info_pos[] = {
        {-26.5, 21.5},
        {-10, 21.5},
        {6, 21.5},
        {-26.5, -10.5},
        {-10, -10.5},
        {6, -10.5},
    };
    static float stc_info_scale[] = {
        2,
        3,
        4,
    };

    InfoDisplayData *idData = gobj->userdata;
    Text *text = idData->text;
    EventOption *idOptions = &LabOptions_InfoDisplay;
    if ((Pause_CheckStatus(1) != 2)) //&& (idOptions[OPTINF_TOGGLE].option_val == 1))
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
                    switch (value)
                    {
                    case (INFDISPROW_POS):
                    {
                        Text_SetText(text, i, "Pos: (%+.3f , %+.3f)", fighter_data->phys.pos.X, fighter_data->phys.pos.Y);
                        break;
                    }
                    case (INFDISPROW_STATE):
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
                    case (INFDISPROW_FRAME):
                    {
                        float *animStruct = fighter_data->anim_curr_flags_ptr;
                        int frameCurr = 0;
                        int frameTotal = 0;

                        // if exists
                        if (animStruct != 0)
                        {
                            // determine how many frames shield stun is
                            float animFrameTotal = animStruct[2];
                            float animFrameCurr = fighter_data->stateFrame;
                            float animSpeed = fighter_data->stateSpeed;
                            frameTotal = (animFrameTotal / animSpeed);
                            frameCurr = (animFrameCurr / animSpeed);
                        }

                        Text_SetText(text, i, "State Frame: %d/%d", frameCurr, frameTotal);
                        break;
                    }
                    case (INFDISPROW_SELFVEL):
                    {
                        Text_SetText(text, i, "SelfVel: (%+.3f , %+.3f)", fighter_data->phys.self_vel.X, fighter_data->phys.self_vel.Y);
                        break;
                    }
                    case (INFDISPROW_KBVEL):
                    {
                        Text_SetText(text, i, "KBVel: (%+.3f , %+.3f)", fighter_data->phys.kb_vel.X, fighter_data->phys.kb_vel.Y);
                        break;
                    }
                    case (INFDISPROW_TOTALVEL):
                    {
                        Text_SetText(text, i, "TotalVel: (%+.3f , %+.3f)", fighter_data->phys.self_vel.X + fighter_data->phys.kb_vel.X, fighter_data->phys.self_vel.Y + fighter_data->phys.kb_vel.Y);
                        break;
                    }
                    case (INFDISPROW_ENGLSTICK):
                    {
                        Text_SetText(text, i, "LStick:      (%+.4f , %+.4f)", fighter_data->input.lstick_x, fighter_data->input.lstick_y);
                        break;
                    }
                    case (INFDISPROW_SYSLSTICK):
                    {
                        HSD_Pad *pad = PadGet(ply, PADGET_MASTER);
                        Text_SetText(text, i, "LStick Sys: (%+.4f , %+.4f)", pad->fstickX, pad->fstickY);
                        break;
                    }
                    case (INFDISPROW_ENGCSTICK):
                    {
                        Text_SetText(text, i, "CStick:     (%+.4f , %+.4f)", fighter_data->input.cstick_x, fighter_data->input.cstick_y);
                        break;
                    }
                    case (INFDISPROW_SYSCSTICK):
                    {
                        HSD_Pad *pad = PadGet(ply, PADGET_MASTER);
                        Text_SetText(text, i, "CStick Sys: (%+.4f , %+.4f)", pad->fsubstickX, pad->fsubstickY);
                        break;
                    }
                    case (INFDISPROW_ENGTRIGGER):
                    {
                        Text_SetText(text, i, "Trigger:     (%+.3f)", fighter_data->input.trigger);
                        break;
                    }
                    case (INFDISPROW_SYSTRIGGER):
                    {
                        HSD_Pad *pad = PadGet(ply, PADGET_MASTER);
                        Text_SetText(text, i, "Trigger Sys: (%+.3f , %+.3f)", pad->ftriggerLeft, pad->ftriggerRight);
                        break;
                    }
                    case (INFDISPROW_LEDGECOOLDOWN):
                    {
                        Text_SetText(text, i, "Ledgegrab Timer: %d", fighter_data->ledge_cooldown);
                        break;
                    }
                    case (INFDISPROW_INTANGREMAIN):
                    {
                        int intang = fighter_data->hurtstatus.respawn_intang_left;
                        if (fighter_data->hurtstatus.ledge_intang_left > fighter_data->hurtstatus.respawn_intang_left)
                            intang = fighter_data->hurtstatus.ledge_intang_left;

                        Text_SetText(text, i, "Intangibility Timer: %d", intang);
                        break;
                    }
                    case (INFDISPROW_HITSTOP):
                    {
                        Text_SetText(text, i, "Hitlag: %.0f", fighter_data->dmg.hitlag_frames);
                        break;
                    }
                    case (INFDISPROW_HITSTUN):
                    {
                        // get hitstun
                        float hitstun = 0;
                        if (fighter_data->flags.hitstun == 1)
                            hitstun = AS_FLOAT(fighter_data->state_var.stateVar1);

                        Text_SetText(text, i, "Hitstun: %.0f", hitstun);
                        break;
                    }
                    case (INFDISPROW_SHIELDHEALTH):
                    {
                        Text_SetText(text, i, "Shield Health: %.3f", fighter_data->shield.health);
                        break;
                    }
                    case (INFDISPROW_SHIELDSTUN):
                    {
                        int stunTotal = 0;
                        int stunLeft = 0;

                        // check if taking shield stun
                        if (fighter_data->state == ASID_GUARDSETOFF)
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
                    case (INFDISPROW_GRIP):
                    {
                        float grip = 0;
                        if (fighter_data->grab.grab_victim != 0)
                        {
                            GOBJ *victim = fighter_data->grab.grab_victim;
                            FighterData *victim_data = victim->userdata;
                            grip = victim_data->grab.grab_timer;
                        }

                        Text_SetText(text, i, "Grip Strength: %.0f", grip);
                        break;
                    }
                    case (INFDISPROW_ECBLOCK):
                    {
                        Text_SetText(text, i, "ECB Lock: %d", fighter_data->coll_data.ecb_lock);
                        break;
                    }
                    case (INFDISPROW_ECBBOT):
                    {
                        Text_SetText(text, i, "ECB Bottom: %.3f", fighter_data->coll_data.ecbCurr_bot.Y);
                        break;
                    }
                    case (INFDISPROW_JUMPS):
                    {
                        Text_SetText(text, i, "Jumps: %d/%d", fighter_data->jump.jumps_used, fighter_data->attr.max_jumps);
                        break;
                    }
                    case (INFDISPROW_WALLJUMPS):
                    {
                        Text_SetText(text, i, "Walljumps: %d", fighter_data->jump.walljumps_used);
                        break;
                    }
                    case (INFDISPROW_JAB):
                    {
                        Text_SetText(text, i, "Jab Counter: IDK");
                        break;
                    }
                    case (INFDISPROW_LINE):
                    {
                        CollData *colldata = &fighter_data->coll_data;
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
                    case (INFDISPROW_BLASTLR):
                    {
                        Stage *stage = STAGE;
                        Text_SetText(text, i, "Blastzone L/R: (%+.3f,%+.3f)", stage->blastzoneLeft, stage->blastzoneRight);
                        break;
                    }
                    case (INFDISPROW_BLASTUD):
                    {
                        Stage *stage = STAGE;
                        Text_SetText(text, i, "Blastzone U/D: (%.2f,%.2f)", stage->blastzoneTop, stage->blastzoneBottom);
                        break;
                    }
                    }
                }
            }

            // adjust scale
            JOBJ *info_jobj = idData->menuModel;
            Text *info_text = idData->text;
            Vec2 *pos = &info_jobj->trans;
            //Vec2 *pos = &stc_info_pos[LabOptions_InfoDisplay[OPTINF_POS].option_val];
            float scale = stc_info_scale[LabOptions_InfoDisplay[OPTINF_SIZE].option_val];
            // background scale
            info_jobj->scale.X = scale;
            info_jobj->scale.Y = scale;
            // text scale
            info_text->scale.X = ((scale / 4.0) * INFDISPTEXT_SCALE);
            info_text->scale.Y = ((scale / 4.0) * INFDISPTEXT_SCALE);
            /*
            // background position
            info_jobj->trans.X = pos->X;
            info_jobj->trans.Y = pos->Y;
            */
            // text position
            info_text->trans.X = pos->X + (INFDISPTEXT_X * (scale / 4.0));
            info_text->trans.Y = (pos->Y * -1) + (INFDISPTEXT_Y * (scale / 4.0));

            // model color
            int info_player = LabOptions_InfoDisplay[OPTINF_PLAYER].option_val;
            GXColor *shield_color = *stc_shieldcolors;
            GXColor *border_color = &info_jobj->dobj->mobj->mat->diffuse;
            border_color->r = shield_color[info_player].r;
            border_color->g = shield_color[info_player].g;
            border_color->b = shield_color[info_player].b;

            // update jobj
            JOBJ_SetMtxDirtySub(info_jobj);
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
    Vec3 *from_pos = &from->phys.pos;
    Vec3 *to_pos = &to->phys.pos;

    if (from_pos->X <= to_pos->X)
        dir = 1;

    return dir;
}
int CPUAction_CheckMultipleState(GOBJ *cpu, int group_kind)
{
    static u8 grActionable[] = {ASID_WAIT, ASID_WALKSLOW, ASID_WALKMIDDLE, ASID_WALKFAST, ASID_RUN, ASID_SQUATWAIT, ASID_OTTOTTOWAIT, ASID_GUARD};
    static u8 airActionable[] = {ASID_JUMPF, ASID_JUMPB, ASID_JUMPAERIALF, ASID_JUMPAERIALB, ASID_FALL, ASID_FALLAERIALF, ASID_FALLAERIALB, ASID_DAMAGEFALL, ASID_DAMAGEFLYROLL, ASID_DAMAGEFLYTOP};
    static u8 airDamage[] = {ASID_DAMAGEFLYHI, ASID_DAMAGEFLYN, ASID_DAMAGEFLYLW, ASID_DAMAGEFLYTOP, ASID_DAMAGEFLYROLL, ASID_DAMAGEFALL};
    static u8 jumpStates[] = {ASID_JUMPF, ASID_JUMPB, ASID_JUMPAERIALF, ASID_JUMPAERIALB};
    static u8 fallStates[] = {ASID_FALL, ASID_FALLAERIAL, ASID_FALLAERIALF, ASID_FALLAERIALB};

    FighterData *cpu_data = cpu->userdata;
    int isActionable = 0;
    int cpu_state = cpu_data->state;

    // if 0, check the one that corresponds with ground state
    if (group_kind == 0)
    {
        group_kind = cpu_data->phys.air_state + 1;
    }

    // ground
    if (group_kind == 1)
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
        if ((cpu_data->state == ASID_LANDING) && (cpu_data->stateFrame >= cpu_data->attr.normal_landing_lag))
            isActionable = 1;
    }
    // air
    else if (group_kind == 2)
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
    else if (group_kind == 3)
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
    // jump states
    else if (group_kind == 4)
    {
        for (int i = 0; i < sizeof(jumpStates); i++)
        {
            if (cpu_state == jumpStates[i])
            {
                isActionable = 1;
                break;
            }
        }
    }
    // fall states
    else if (group_kind == 5)
    {
        for (int i = 0; i < sizeof(fallStates); i++)
        {
            if (cpu_state == fallStates[i])
            {
                isActionable = 1;
                break;
            }
        }
    }

    return isActionable;
}
int CPU_IsThrown(GOBJ *cpu)
{
    FighterData *cpu_data = cpu->userdata;

    int is_thrown = 0;
    int cpu_state = cpu_data->state;

    // check if thrown
    if (((cpu_state >= ASID_THROWNF) && (cpu_state <= ASID_THROWNLW)) || (cpu_state == ASID_CAPTURECAPTAIN) || (cpu_state == ASID_THROWNKOOPAF) || (cpu_state == ASID_THROWNKOOPAB) || (cpu_state == ASID_THROWNKOOPAAIRF) || ((cpu_state >= ASID_THROWNFF) && (cpu_state <= ASID_THROWNFLW)))
        is_thrown = 1;

    return is_thrown;
}
int CPU_IsGrabbed(GOBJ *cpu)
{
    FighterData *cpu_data = cpu->userdata;

    int is_grabbed = 0;
    int cpu_state = cpu_data->state;

    // check if thrown
    if ((cpu_state == ASID_CAPTUREWAITHI) || (cpu_state == ASID_CAPTUREWAITLW) || (cpu_state == ASID_CAPTUREWAITKOOPA) || (cpu_state == ASID_CAPTUREWAITKOOPAAIR) || (cpu_state == ASID_CAPTUREWAITKIRBY) || (cpu_state == ASID_DAMAGEICE) || (cpu_state == ASID_CAPTUREMASTERHAND) || (cpu_state == ASID_YOSHIEGG) || (cpu_state == ASID_CAPTUREKIRBYYOSHI) || (cpu_state == ASID_KIRBYYOSHIEGG) || (cpu_state == ASID_CAPTURELEADEAD) || (cpu_state == ASID_CAPTURELIKELIKE) || (cpu_state == ASID_CAPTUREWAITCRAZYHAND) || ((cpu_state >= ASID_SHOULDEREDWAIT) && (cpu_state <= ASID_SHOULDEREDTURN)))
        is_grabbed = 1;

    return is_grabbed;
}
int LCancel_CPUPerformAction(GOBJ *cpu, int action_id, GOBJ *hmn)
{
    FighterData *cpu_data = cpu->userdata;
    FighterData *hmn_data = hmn->userdata;

    // get CPU action
    int action_done = 0;
    CPUAction *action_list = Lab_CPUActions[action_id];
    int cpu_state = cpu_data->state;
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
            if ((action_input->state >= ASID_ACTIONABLE) && (action_input->state <= ASID_FALLS))
                isState = CPUAction_CheckMultipleState(cpu, (action_input->state - ASID_ACTIONABLE));
            else if (action_input->state == cpu_state)
                isState = 1;

            // check if this is the current state
            if (isState == 1)
            {
                // check if im on the right frame
                if (cpu_frame >= action_input->frameLow)
                {

                    OSReport("exec input %d of %s\n", action_parse, CPU_ACTIONS_NAMES[action_id]);

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
                        cstickX *= dir;
                        break;
                    }
                    case (STCKDIR_AWAY):
                    {
                        dir = Fighter_GetOpponentDir(cpu_data, hmn_data) * -1;
                        lstickX *= dir;
                        cstickX *= dir;
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
                    case (STICKDIR_RDM):
                    {
                        // random direction
                        if (HSD_Randi(2) == 0)
                            dir = 1;
                        else
                            dir = -1;

                        lstickX *= dir;
                        cstickX *= dir;
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
    int cpu_state = cpu_data->state;

    // noact
    cpu_data->cpu.ai = 15;

    // if first throw frame, advance hitnum
    int is_thrown = CPU_IsThrown(cpu);
    if ((is_thrown == 1) && (eventData->cpu_isthrown == 0))
    {
        eventData->cpu_hitnum++;
    }
    eventData->cpu_isthrown = is_thrown;

    // ALWAYS CHECK FOR X AND OVERRIDE STATE

    // check if damaged
    if (cpu_data->flags.hitstun == 1)
    {
        eventData->cpu_hitkind = HITKIND_DAMAGE;
        // go to SDI state
        eventData->cpu_state = CPUSTATE_SDI;
        Fighter_ZeroCPUInputs(cpu_data);
    }
    // check if being held in a grab
    if (CPU_IsGrabbed(cpu) == 1)
    {
        eventData->cpu_state = CPUSTATE_GRABBED;
    }
    // check if being thrown
    if (is_thrown == 1)
    {
        eventData->cpu_state = CPUSTATE_TDI;
    }
    // check for shield hit
    if ((cpu_state == ASID_GUARDSETOFF) || ((cpu_data->kind == 0xE) && (cpu_state == 344)))
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
    // check for missed tech
    if ((cpu_state == ASID_DOWNBOUNDD) || (cpu_state == ASID_DOWNBOUNDU) || (cpu_state == ASID_DOWNWAITU) || (cpu_state == ASID_DOWNWAITD) || (cpu_state == ASID_PASSIVE) || (cpu_state == ASID_PASSIVESTANDB) || (cpu_state == ASID_PASSIVESTANDF))
        eventData->cpu_state = CPUSTATE_GETUP;
    // check for cliffgrab
    if ((cpu_state == ASID_CLIFFWAIT))
        eventData->cpu_state = CPUSTATE_RECOVER;
    // check if dead
    if (cpu_data->flags.dead == 1)
        goto CPUSTATE_ENTERSTART;

    // run CPU state logic
    switch (eventData->cpu_state)
    {
    // Initial State, hasn't been hit yet
    case (CPUSTATE_START):
    CPULOGIC_START:
    {

        // if in the air somehow, enter recovery
        if (cpu_data->phys.air_state == 1)
        {
            eventData->cpu_state = CPUSTATE_RECOVER;
            goto CPULOGIC_RECOVER;
        }

        // clear held inputs
        Fighter_ZeroCPUInputs(cpu_data);

        // perform default behavior
        int behavior = LabOptions_CPU[OPTCPU_BEHAVE].option_val;
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

    case (CPUSTATE_GRABBED):
    CPULOGIC_GRABBED:
    {
        // if no longer being grabbed, exit
        if (CPU_IsGrabbed(cpu) == 0)
        {
            eventData->cpu_state = CPUSTATE_RECOVER;
            goto CPULOGIC_RECOVER;
        }

        switch (LabOptions_CPU[OPTCPU_MASH].option_val)
        {
        case (CPUMASH_NONE):
        {
            Fighter_ZeroCPUInputs(cpu_data);
            break;
        }
        case (CPUMASH_MED):
        {
            if (HSD_Randi(100) <= CPUMASHRNG_MED)
            {
                // remove last frame inputs
                cpu_data->input.held = 0;
                cpu_data->input.lstick_x = 0;
                cpu_data->input.lstick_y = 0;

                // input
                cpu_data->cpu.held = PAD_BUTTON_A;
                cpu_data->cpu.lstickX = 127;
            }
            break;
        }
        case (CPUMASH_HIGH):
        {
            if (HSD_Randi(100) <= CPUMASHRNG_HIGH)
            {
                // remove last frame inputs
                cpu_data->input.held = 0;
                cpu_data->input.lstick_x = 0;
                cpu_data->input.lstick_y = 0;

                // input
                cpu_data->cpu.held = PAD_BUTTON_A;
                cpu_data->cpu.lstickX = 127;
            }
            break;
        }
        case (CPUMASH_PERFECT):
        {
            // remove last frame inputs
            cpu_data->input.held = 0;
            cpu_data->input.lstick_x = 0;
            cpu_data->input.lstick_y = 0;

            // input
            cpu_data->cpu.held = PAD_BUTTON_A;
            cpu_data->cpu.lstickX = 127;
            break;
        }
        }

        break;
    }

    case (CPUSTATE_SDI):
    CPULOGIC_SDI:
    {

        // if no more hitlag, enter tech state
        if (cpu_data->flags.hitlag == 0)
        {
            eventData->cpu_state = CPUSTATE_TECH;
            goto CPULOGIC_TECH;
        }

        // if final frame of hitlag, enter TDI state
        else if (cpu_data->dmg.hitlag_frames == 1)
        {
            eventData->cpu_state = CPUSTATE_TDI;
            goto CPULOGIC_TDI;
        }

        // update move instance
        if (eventData->cpu_lasthit != cpu_data->dmg.instancehitby)
        {
            eventData->cpu_sincehit = 0;
            eventData->cpu_hitnum++;
            eventData->cpu_lasthit = cpu_data->dmg.instancehitby;
            //OSReport("hit count %d/%d", eventData->cpu_hitnum, LabOptions_CPU[OPTCPU_CTRHITS].option_val);

            // decide random SDI direction for grounded cpu
            if ((LabOptions_CPU[OPTCPU_SDIFREQ].option_val != SDIFREQ_NONE) && (LabOptions_CPU[OPTCPU_SDIDIR].option_val == SDIDIR_RANDOM))
            {
                eventData->cpu_sdidir = HSD_Randi(2);
            }
        }

        // to-do: shield SDI
        if ((cpu_data->state >= ASID_GUARDON) && (cpu_data->state <= ASID_GUARDREFLECT))
        {
            ;
        }

        // perform SDI behavior
        else if (LabOptions_CPU[OPTCPU_SDIFREQ].option_val != SDIFREQ_NONE)
        {

            int chance = stc_sdifreqs[LabOptions_CPU[OPTCPU_SDIFREQ].option_val - 1];

            // chance to SDI
            if (HSD_Randi(chance) == 0)
            {

                float angle, magnitude;

                switch (LabOptions_CPU[OPTCPU_SDIDIR].option_val)
                {
                case SDIDIR_RANDOM:
                {
                    // when grounded, only left right
                    if (cpu_data->phys.air_state == 0)
                    {

                        magnitude = 1;

                        // decide left or right
                        if (eventData->cpu_sdidir == 0)
                            angle = 0; // right
                        else
                            angle = M_PI; // left
                    }
                    // when airborne, any direction
                    else
                    {
                        // random input
                        angle = HSD_Randi(360) * M_1DEGREE;
                        magnitude = 0.49 + (HSD_Randf() * 0.51);
                    }

                    break;
                }
                case SDIDIR_AWAY:
                {
                    // get angle from center bubble to hit collision
                    angle = atan2(hmn_data->unk_hitbox.pos.Y - cpu_data->unk_hitbox.pos.Y, hmn_data->unk_hitbox.pos.X - cpu_data->unk_hitbox.pos.X);

                    // flip
                    angle += M_PI;
                    while (angle > (M_PI * 2))
                    {
                        angle -= (M_PI * 2);
                    }

                    magnitude = 1;

                    break;
                }
                case SDIDIR_TOWARD:
                {
                    // get angle from center bubble to hit collision
                    angle = atan2(hmn_data->unk_hitbox.pos.Y - cpu_data->unk_hitbox.pos.Y, hmn_data->unk_hitbox.pos.X - cpu_data->unk_hitbox.pos.X);

                    magnitude = 1;

                    break;
                }
                }

                // store
                cpu_data->cpu.lstickX = cos(angle) * 127 * magnitude;
                cpu_data->cpu.lstickY = sin(angle) * 127 * magnitude;
            }
        }

        break;
    }

    case (CPUSTATE_TDI):
    CPULOGIC_TDI:
    {

        // if no more hitlag and not being thrown, enter tech state. this might never be hit, just being safe
        if ((cpu_data->flags.hitlag == 0) && (is_thrown == 0))
        {
            eventData->cpu_state = CPUSTATE_TECH;
            goto CPULOGIC_TECH;
        }

        // if in shield, no need to TDI
        if ((cpu_data->state >= ASID_GUARDON) && (cpu_data->state <= ASID_GUARDREFLECT))
        {
            break;
        }

        // get knockback value
        float kb_angle;
        if (is_thrown == 1)
        {
            // if being thrown, get knockback info from attacker
            FighterData *attacker_data = cpu_data->grab.grab_attacker->userdata;
            kb_angle = ((float)attacker_data->throw_hitbox[0].angle * M_1DEGREE) * (attacker_data->facing_direction);
        }
        else
        {
            // not being thrown, get knockback angle normally
            //kb_angle = Fighter_GetKnockbackAngle(cpu_data) * cpu_data->dmg.direction;
            kb_angle = atan2(cpu_data->phys.kb_vel.Y, cpu_data->phys.kb_vel.X);
        }

        // perform TDI behavior
        int tdi_kind = LabOptions_CPU[OPTCPU_TDI].option_val;

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

            /*
            NOTE: im using 94 degrees here because some moves like marth
            uthrow use this angle, and drawing the line at 90 would make 
            inward DI cause the opponent to DI in the direction marth is facing
            and looks confusing
            */

            float orig_dir;
            if ((kb_angle > (-94 * M_1DEGREE)) && (kb_angle <= (94 * M_1DEGREE)))
                orig_dir = -1;
            else
                orig_dir = 1;

            // get optimal tdi
            float tdi_angle = kb_angle + (orig_dir * -(M_PI / 2));

            // convert to analog input
            cpu_data->cpu.lstickX = cos(tdi_angle) * 127;
            cpu_data->cpu.lstickY = sin(tdi_angle) * 127;

            break;
        }

        case (CPUTDI_OUT):
        TDI_OUT:
        {

            /*
            NOTE: im using 94 degrees here because some moves like marth
            uthrow use a 93 degree angle, and drawing the line at 90 would make 
            inward DI cause the opponent to DI in the direction marth is facing
            and looks confusing
            */

            float orig_dir;
            if ((kb_angle > (-94 * M_1DEGREE)) && (kb_angle <= (94 * M_1DEGREE)))
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
            if (cpu_hitnum <= stc_tdi_val_num)
            {

                // get the stick values for this hit num
                cpu_hitnum--;

                s8 lstickX = stc_tdi_vals[cpu_hitnum][0][0];
                s8 lstickY = stc_tdi_vals[cpu_hitnum][0][1];
                s8 cstickX = stc_tdi_vals[cpu_hitnum][1][0];
                s8 cstickY = stc_tdi_vals[cpu_hitnum][1][1];

                cpu_data->cpu.lstickX = ((float)lstickX / 80) * 127.0;
                cpu_data->cpu.lstickY = ((float)lstickY / 80) * 127.0;
                cpu_data->cpu.cstickX = ((float)cstickX / 80) * 127.0;
                cpu_data->cpu.cstickY = ((float)cstickY / 80) * 127.0;

                // increment
            }

            break;
        }

        case (CPUTDI_NONE):
        {
            Fighter_ZeroCPUInputs(cpu_data);
            break;
        }
        }

        // this is kinda meh, maybe i can come up with something better later
        // spoof last input as current input as to not trigger SDI
        // also spoof input as held for more than the SDI window
        cpu_data->input.lstick_x = ((float)cpu_data->cpu.lstickX * 0.0078125);
        cpu_data->input.timer_lstick_tilt_x = 5;
        cpu_data->input.lstick_y = ((float)cpu_data->cpu.lstickY * 0.0078125);
        cpu_data->input.timer_lstick_tilt_y = 5;

        break;
    }

    case (CPUSTATE_TECH):
    CPULOGIC_TECH:
    {

        // if no more hitstun, go to counter
        if (cpu_data->flags.hitstun == 0)
        {
            // also reset stick timer (messes with airdodge wiggle)
            cpu_data->input.lstick_x = 0;
            cpu_data->input.timer_lstick_tilt_x = 254;
            eventData->cpu_state = CPUSTATE_COUNTER;
            goto CPULOGIC_COUNTER;
        }

        // perform tech behavior
        int tech_kind = LabOptions_CPU[OPTCPU_TECH].option_val;
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
            tech_kind = (HSD_Randi((sizeof(LabValues_Tech) / 4) - 1) + 1);
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
        cpu_data->input.timer_LR = sincePress;
        cpu_data->input.sinceRapidLR = since2Press;
        cpu_data->cpu.lstickX = stickX;
        cpu_data->input.timer_lstick_smash_x = sinceXSmash;

        break;
    }

    case (CPUSTATE_GETUP):
    CPULOGIC_GETUP:
    {

        // if im in downwait, perform getup logic
        if ((cpu_data->state == ASID_DOWNWAITD) || (cpu_data->state == ASID_DOWNWAITU))
        {
            // perform getup behavior
            int getup = LabOptions_CPU[OPTCPU_GETUP].option_val;
            s8 dir;
            int inputs = 0;
            s8 stickX = 0;
            s8 stickY = 0;

        GETUP_SWITCH:
            switch (getup)
            {
            case (CPUGETUP_RANDOM):
            {
                getup = (HSD_Randi((sizeof(LabValues_Tech) / 4) - 1) + 1);
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
        else if ((cpu_data->state >= ASID_DOWNBOUNDU) && (cpu_data->state <= ASID_DOWNSPOTD))
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
            if (CPUAction_CheckMultipleState(cpu, 0) == 0)
            {
                break;
            }
            else
            {
                eventData->cpu_isactionable = 1;                       // set actionable flag to begin running code
                eventData->cpu_groundstate = cpu_data->phys.air_state; // remember initial ground state
            }
        }

        // if started in the air, didnt finish action, but now grounded, perform ground action
        if ((eventData->cpu_groundstate == 1) && (cpu_data->phys.air_state == 0))
        {
            eventData->cpu_groundstate = 0;
        }

        // increment frames since actionable
        eventData->cpu_sincehit++;

        // ensure hit count and frame count criteria are met
        int action_id;
        if (eventData->cpu_hitkind == HITKIND_DAMAGE)
        {
            if ((eventData->cpu_hitnum < LabOptions_CPU[OPTCPU_CTRHITS].option_val) || (eventData->cpu_sincehit < LabOptions_CPU[OPTCPU_CTRFRAMES].option_val))
            {
                break;
            }

            // get counter action
            if (cpu_data->phys.air_state == 0 || (eventData->cpu_groundstate == 0)) // if am grounded or started grounded
            {
                int grndCtr = LabOptions_CPU[OPTCPU_CTRGRND].option_val;
                action_id = GrAcLookup[grndCtr];
            }
            else if (cpu_data->phys.air_state == 1) // only if in the air at the time of hitstun ending
            {
                int airCtr = LabOptions_CPU[OPTCPU_CTRAIR].option_val;
                action_id = AirAcLookup[airCtr];
            }
        }
        else if (eventData->cpu_hitkind == HITKIND_SHIELD)
        {

            // if the shield wasnt hit enough times, return to start
            if (eventData->cpu_hitshieldnum < LabOptions_CPU[OPTCPU_SHIELDHITS].option_val)
            {
                eventData->cpu_state = CPUSTATE_START;
                goto CPULOGIC_START;
                break;
            }

            // if this isnt the frame to counter, keep holding shield
            if (eventData->cpu_sincehit < LabOptions_CPU[OPTCPU_CTRFRAMES].option_val)
            {
                cpu_data->cpu.held = PAD_TRIGGER_R;
                break;
            }

            // get action to perform
            int shieldCtr = LabOptions_CPU[OPTCPU_CTRSHIELD].option_val;
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
        if (cpu_data->phys.air_state == 0)
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

    // update isthrown
    eventData->cpu_isthrown = is_thrown;

    // update cpu_hitshield
    if (eventData->cpu_hitshield == 0)
    {
        GOBJ *fighter = gobjlist[8];
        while (fighter != 0)
        {
            FighterData *fighter_data = fighter->userdata;

            // check if in guard off
            if (fighter_data->state == ASID_GUARDSETOFF)
            {
                eventData->cpu_hitshield = 1;
                break;
            }

            fighter = fighter->next;
        }
    }

    // update shield deterioration
    int infShield = LabOptions_CPU[OPTCPU_SHIELD].option_val;
    if (infShield == 1)
    {
        if (eventData->cpu_hitshield == 0)
        {
            // inf shield
            GOBJ *fighter = gobjlist[8];
            while (fighter != 0)
            {
                FighterData *fighter_data = fighter->userdata;
                fighter_data->shield.health = 60;
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
            fighter_data->shield.health = 60;

            fighter = fighter->next;
        }
    }

    return;
}
int Update_CheckPause()
{
    HSD_Update *update = HSD_UPDATE;
    int isChange = 0;

    // get their pad
    int controller = Fighter_GetControllerPort(0);
    HSD_Pad *pad = PadGet(controller, PADGET_MASTER);

    // if event menu not showing, develop mode + pause input, toggle frame advance
    if ((Pause_CheckStatus(1) != 2) && (*stc_dblevel >= 3) && (pad->down & HSD_BUTTON_START))
    {
        LabOptions_General[OPTGEN_FRAME].option_val ^= 1;
        Lab_ChangeFrameAdvance(0, LabOptions_General[OPTGEN_FRAME].option_val);
        isChange = 1;
    }

    // menu paused
    else if (LabOptions_General[OPTGEN_FRAME].option_val == 1)
    {
        // check if unpaused
        if (update->pause_develop != 1)
        {
            // pause
            isChange = 1;
        }
    }

    // menu unpaused
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

    // get their advance input
    static int stc_advance_btns[] = {HSD_TRIGGER_L, HSD_TRIGGER_Z, HSD_BUTTON_X, HSD_BUTTON_Y};
    int advance_btn = stc_advance_btns[LabOptions_General[OPTGEN_FRAMEBTN].option_val];

    // check if holding L
    if ((pad->held & advance_btn))
    {
        timer++;

        // advance if first press or holding more than 10 frames
        if (timer == 1 || timer > 30)
        {
            isAdvance = 1;

            // remove button input
            pad->down &= ~advance_btn;
            pad->held &= ~advance_btn;

            // if using L, remove analog press too
            if (LabOptions_CPU[OPTGEN_FRAMEBTN].option_val == 0)
            {
                pad->triggerLeft = 0;
                pad->ftriggerLeft = 0;
            }
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
    if ((LabOptions_General[OPTGEN_DI].option_val == 1)) //  && (Pause_CheckStatus(1) != 2)
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
            if ((fighter_data->flags.hitlag == 1) && (fighter_data->flags.hitstun == 1))
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
                    lstickX = fighter_data->input.lstick_x;
                    lstickY = fighter_data->input.lstick_y;
                    cstickX = fighter_data->input.cstick_x;
                    cstickY = fighter_data->input.cstick_y;
                }

                // get kb vector
                Vec3 kb = fighter_data->phys.kb_vel;
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
                int air_state = fighter_data->phys.air_state;
                float gravity = 0;
                Vec3 pos = fighter_data->phys.pos;
                ftCommonData *ftCommon = R13_PTR(-0x514C);
                float decay = ftCommon->kb_frameDecay;
                int hitstun_frames = AS_FLOAT(fighter_data->state_var.stateVar1);
                int vertices_num = 0;    // used to track how many vertices will be needed
                int override_frames = 0; // used as an alternate countdown
                DIDrawCalculate *DICollData = calloc(sizeof(DIDrawCalculate) * hitstun_frames);
                CollData ecb;
                ECBBones ecb_bones;

                // init ecb struct
                Coll_InitECB(&ecb);
                if (fighter_data->phys.air_state == 0) // copy ecb struct if grounded
                {
                    memcpy(&ecb.envFlags, &fighter_data->coll_data.envFlags, 0x28);
                }

                // simulate each frame of knockback
                for (int i = 0; i < hitstun_frames; i++)
                {

                    // update bone positions.  If loop count < noECBUpdate-remaining hitlag fraes, use current ECB bottom Y offset
                    if (vertices_num < (fighter_data->coll_data.ecb_lock - fighter_data->dmg.hitlag_frames))
                    {

                        ecb_bones.topY = fighter_data->coll_data.ecbCurr_top.Y;
                        ecb_bones.botY = fighter_data->coll_data.ecbCurr_bot.Y;
                        ecb_bones.left = fighter_data->coll_data.ecbCurr_left;
                        ecb_bones.right = fighter_data->coll_data.ecbCurr_right;

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
                    gravity -= fighter_data->attr.gravity;
                    float terminal_velocity = fighter_data->attr.terminal_velocity * -1;
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
                didraw->vertices[ply][0].X = fighter_data->coll_data.topN_Curr.X;
                didraw->vertices[ply][0].Y = fighter_data->coll_data.topN_Curr.Y + fighter_data->coll_data.ecbCurr_left.Y;
                didraw->vertices[ply][1].X = fighter_data->coll_data.topN_Curr.X + asdi_orig.X;
                didraw->vertices[ply][1].Y = fighter_data->coll_data.topN_Curr.Y + fighter_data->coll_data.ecbCurr_left.Y + asdi_orig.Y;

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
            else if (fighter_data->flags.hitstun == 0)
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
    if (LabOptions_General[OPTGEN_DI].option_val == 1)
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
    if (LabOptions_General[OPTGEN_CAM].option_val == 3)
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
void Lab_SelectCustomTDI(GOBJ *menu_gobj)
{
    MenuData *menu_data = menu_gobj->userdata;
    EventMenu *curr_menu = menu_data->currMenu;
    evMenu *menuAssets = event_vars->menu_assets;
    GOBJ *event_gobj = event_vars->event_gobj;
    LCancelData *event_data = event_gobj->userdata;
    Arch_LabData *LabAssets = stc_lab_data;

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
    JOBJ *stick_joint = JOBJ_LoadJoint(stc_lab_data->stick);
    stick_joint->scale.X = 2;
    stick_joint->scale.Y = 2;
    stick_joint->scale.Z = 2;
    stick_joint->trans.X = -6;
    stick_joint->trans.Y = -6;
    userdata->stick_curr[0] = stick_joint;
    JOBJ_AddChild(tdi_gobj->hsd_object, stick_joint);
    // current c stick
    stick_joint = JOBJ_LoadJoint(stc_lab_data->cstick);
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
    Text_AddSubtext(text_curr, -50, 185, &nullString);
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
        JOBJ *prevstick_joint = JOBJ_LoadJoint(stc_lab_data->stick);
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
        prevstick_joint = JOBJ_LoadJoint(stc_lab_data->cstick);
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
    Text_AddSubtext(text_curr, -460, 240, "Input TDI angles for the CPU to use.");
    Text_AddSubtext(text_curr, -460, 285, "A = Save Input  X = Delete Input  B = Return");

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
void CustomTDI_Update(GOBJ *gobj)
{
    // get data
    TDIData *tdi_data = gobj->userdata;
    MenuData *menu_data = event_vars->menu_gobj->userdata;
    LCancelData *event_data = event_vars->event_gobj->userdata;

    // get pausing players inputs
    HSD_Pad *pad = PadGet(menu_data->controller_index, PADGET_MASTER);
    int inputs = pad->down;

    // if press A, save stick
    if ((inputs & HSD_BUTTON_A) != 0)
    {
        if (stc_tdi_val_num < TDI_HITNUM)
        {
            stc_tdi_vals[stc_tdi_val_num][0][0] = (pad->fstickX * 80);
            stc_tdi_vals[stc_tdi_val_num][0][1] = (pad->fstickY * 80);
            stc_tdi_vals[stc_tdi_val_num][1][0] = (pad->fsubstickX * 80);
            stc_tdi_vals[stc_tdi_val_num][1][1] = (pad->fsubstickY * 80);
            stc_tdi_val_num++;
            SFX_PlayCommon(1);
        }
    }

    // if press X, go back a hit
    if ((inputs & HSD_BUTTON_X) != 0)
    {
        if (stc_tdi_val_num > 0)
        {
            stc_tdi_val_num--;
            SFX_PlayCommon(0);
        }
    }

    // if press B, exit
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
    Text_SetText(text_curr, 0, "Hit: %d", stc_tdi_val_num + 1);
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
        if (stc_tdi_val_num > TDI_DISPNUM)
            this_hit = (stc_tdi_val_num - TDI_DISPNUM + i);

        // show stick
        if (i < stc_tdi_val_num)
        {
            // remove hidden flag
            JOBJ_ClearFlags(lstick_prev, JOBJ_HIDDEN);
            JOBJ_ClearFlags(cstick_prev, JOBJ_HIDDEN);

            // update rotation
            lstick_prev->rot.Y = ((float)(stc_tdi_vals[this_hit][0][0]) * 1 / 80) * 0.75;
            lstick_prev->rot.X = ((float)(stc_tdi_vals[this_hit][0][1]) * 1 / 80) * 0.75 * -1;
            cstick_prev->rot.Y = ((float)(stc_tdi_vals[this_hit][1][0]) * 1 / 80) * 0.75;
            cstick_prev->rot.X = ((float)(stc_tdi_vals[this_hit][1][1]) * 1 / 80) * 0.75 * -1;

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
    LCancelData *event_data = event_vars->event_gobj->userdata;

    // set TDI to custom
    if (stc_tdi_val_num > 0)
        LabOptions_CPU[OPTCPU_TDI].option_val = CPUTDI_CUSTOM;
    else
        LabOptions_CPU[OPTCPU_TDI].option_val = CPUTDI_RANDOM;

    // free text
    Text_Destroy(tdi_data->text_curr);

    // destroy
    GObj_Destroy(gobj);

    // show menu
    event_vars->hide_menu = 0;
    menu_data->custom_gobj = 0;
    menu_data->custom_gobj_think = 0;
    menu_data->custom_gobj_destroy = 0;

    // play sfx
    SFX_PlayCommon(0);

    return;
}
void Inputs_GX(GOBJ *gobj, int pass)
{
    // only render when enabled and unpaused
    if ((LabOptions_General[OPTGEN_INPUT].option_val == 1) && (Pause_CheckStatus(1) != 2))
    {
        GXLink_Common(gobj, pass);
    }

    return;
}
void Inputs_Think(GOBJ *gobj)
{
    InputData *input_data = gobj->userdata;

    // update controllers
    for (int i = 0; i < (sizeof(input_data->controller_joint) / 4); i++)
    {
        JOBJ *controller = input_data->controller_joint[i];

        if (controller != 0)
        {

            // get port and controller data
            int port = Fighter_GetControllerPort(i);
            HSD_Pad *pad = PadGet(port, PADGET_ENGINE);

            // move lstick
            JOBJ *lstick_joint;
            JOBJ_GetChild(controller, &lstick_joint, 10, -1);
            lstick_joint->trans.X = (pad->fstickX * 2.3);
            lstick_joint->trans.Y = (pad->fstickY * 2.3);

            // move lstick
            JOBJ *rstick_joint;
            JOBJ_GetChild(controller, &rstick_joint, 8, -1);
            rstick_joint->trans.X = (pad->fsubstickX * 2.3);
            rstick_joint->trans.Y = (pad->fsubstickY * 2.3);

            // move ltrigger
            JOBJ *ltrig_joint;
            JOBJ_GetChild(controller, &ltrig_joint, button_lookup[BTN_L].jobj, -1);
            ltrig_joint->trans.X = (pad->ftriggerLeft * 0.5) + input_data->ltrig_origin.X;
            ltrig_joint->trans.Z = (pad->ftriggerLeft * 1.5) + input_data->ltrig_origin.Y;

            // move rtrigger
            JOBJ *rtrig_joint;
            JOBJ_GetChild(controller, &rtrig_joint, button_lookup[BTN_R].jobj, -1);
            rtrig_joint->trans.X = (pad->ftriggerRight * -0.5) + input_data->rtrig_origin.X;
            rtrig_joint->trans.Z = (pad->ftriggerRight * 1.5) + input_data->rtrig_origin.Y;

            // update button colors
            int held = pad->held;
            for (int i = 0; i < (BTN_NUM); i++)
            {

                // Get buttons jobj and dobj from the lookup table
                JOBJ *button_jobj;
                JOBJ_GetChild(controller, &button_jobj, button_lookup[i].jobj, -1);
                DOBJ *button_dobj = JOBJ_GetDObjChild(button_jobj, button_lookup[i].dobj);

                // check if button is pressed
                if (held & button_bits[i])
                {
                    // make white i guess for now
                    GXColor color_pressed = INPUT_COLOR_PRESSED;
                    button_dobj->mobj->mat->diffuse = color_pressed;
                }
                // not pressed, make the default color
                else
                {
                    GXColor *color_released = &button_colors[i];
                    button_dobj->mobj->mat->diffuse = *color_released;
                }
            }

            JOBJ_SetMtxDirtySub(controller);
        }
    }

    // toggle visibility
    JOBJ *root = gobj->hsd_object;
    if ((LabOptions_General[OPTGEN_INPUT].option_val == 1) && (Pause_CheckStatus(1) != 2))
    {
        Match_HideTimer();
        JOBJ_ClearFlags(root, JOBJ_HIDDEN);
    }
    else if ((LabOptions_General[OPTGEN_INPUT].option_val == 0) && (Pause_CheckStatus(1) != 2))
    {
        Match_ShowTimer();
        JOBJ_SetFlags(root, JOBJ_HIDDEN);
    }

    /*
        // toggle timer visibility
        if (LabOptions_General[OPTGEN_INPUT].option_val == 1)
            Match_HideTimer();
        else if (Pause_CheckStatus(1) != 2)
            Match_ShowTimer();
*/
    return;
}
void Inputs_Init()
{
    // Create Input Display GOBJ
    GOBJ *input_gobj = GObj_Create(0, 0, 0);
    InputData *input_data = calloc(sizeof(InputData));
    GObj_AddUserData(input_gobj, 4, HSD_Free, input_data);
    GObj_AddProc(input_gobj, Inputs_Think, 4);

    // alloc a dummy root jobj
    JOBJDesc *root_desc = calloc(sizeof(JOBJDesc));
    root_desc->flags = JOBJ_ROOT_XLU | JOBJ_ROOT_TEXEDGE;
    root_desc->scale.X = 1;
    root_desc->scale.Y = 1;
    root_desc->scale.Z = 1;
    JOBJ *root = JOBJ_LoadJoint(root_desc);

    // init jobj pointers
    for (int i = 0; i < (sizeof(input_data->controller_joint) / 4); i++)
    {
        input_data->controller_joint[i] = 0;
    }

    // count humans in this match
    int hmn_count = 0;
    for (int i = 0; i < 4; i++)
    {
        if (Fighter_GetSlotType(i) == 0)
            hmn_count++;
    }

    // create X controllers
    int found_origin = 0;
    for (int i = 0; i < hmn_count; i++)
    {

        JOBJ *controller = JOBJ_LoadJoint(stc_lab_data->controller); // Load jobj
        input_data->controller_joint[i] = controller;                // store jobj pointer

        // Add to root
        JOBJ_AddChild(root, controller);

        if (found_origin == 0)
        {
            // save trigger origins
            JOBJ *ltrig_jobj, *rtrig_jobj;
            JOBJ_GetChild(controller, &ltrig_jobj, button_lookup[BTN_L].jobj, -1);
            JOBJ_GetChild(controller, &rtrig_jobj, button_lookup[BTN_R].jobj, -1);
            input_data->ltrig_origin.X = ltrig_jobj->trans.X;
            input_data->ltrig_origin.Y = ltrig_jobj->trans.Z;
            input_data->rtrig_origin.X = rtrig_jobj->trans.X;
            input_data->rtrig_origin.Y = rtrig_jobj->trans.Z;

            found_origin = 1;
        }

        /*
        // adjust size based on the console / settings
        if ((OSGetConsoleType() == OS_CONSOLE_DEVHW3) || (stc_HSD_VI->is_prog == 1)) // 480p / dolphin uses medium by default
            LabOptions_InfoDisplay[OPT_SCALE].option_val = 1;
        else // 480i on wii uses large (shitty composite!)
            LabOptions_InfoDisplay[OPT_SCALE].option_val = 2;
        */
    }

    GObj_AddObject(input_gobj, 3, root);                              // add to gobj
    GObj_AddGXLink(input_gobj, Inputs_GX, INPUT_GXLINK, INPUT_GXPRI); // add gx link

    return;
}

// Recording Functions
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
    cam_gobj->cobj_links = RECCAM_COBJGXLINK;

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
    GObj_AddGXLink(rec_gobj, Record_GX, REC_GXLINK, GXPRI_RECJOINT);

    // Create text
    int canvas_index = Text_CreateCanvas(2, rec_gobj, 14, 15, 0, REC_GXLINK, GXPRI_RECTEXT, 19);
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

    // alloc rec_state
    rec_state = calloc(sizeof(Savestate));
    // set as not exist
    rec_state->is_exist = 0;

    // disable menu options
    for (int i = 1; i < sizeof(LabOptions_Record) / sizeof(EventOption); i++)
    {
        LabOptions_Record[i].disable = 1;
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

    // init memcard stuff
    Memcard_InitWorkArea();
    Memcard_InitSnapshotList(HSD_MemAlloc(2112), HSD_MemAlloc(256064));

    // Create snapshot cam
    snap_image.img_ptr = 0;
    GOBJ *snap_gobj = GObj_Create(18, 18, 0);
    GOBJ_InitCamera(snap_gobj, Snap_CObjThink, 4);
    GX_AllocImageData(&snap_image, EXP_SCREENSHOT_WIDTH, EXP_SCREENSHOT_HEIGHT, 4, 2006);
    export_status = EXSTAT_NONE;

    /*
    // init dev text
    int height = 18;
    int width = 28;
    int x = -50;
    int y = 410;
    DevText *dev_text = DevelopText_CreateDataTable(x, y, 0, width, height, HSD_MemAlloc(height * width * 2));
    stc_devtext = dev_text;
    DevelopText_Activate(0, dev_text);
    dev_text->cursorBlink = 0;
    GXColor color = {21, 20, 59, 135};
    DevelopText_StoreBGColor(dev_text, &color);
    DevelopText_StoreTextScale(dev_text, 7.5, 10);
    */
    return rec_gobj;
}
void Record_CObjThink(GOBJ *gobj)
{
    // hide UI if set to off
    if ((rec_state->is_exist == 1) && ((LabOptions_Record[OPTREC_CPUMODE].option_val != 0) || (LabOptions_Record[OPTREC_HMNMODE].option_val != 0)))
    {
        CObjThink_Common(gobj);
    }

    return;
}
void Record_GX(GOBJ *gobj, int pass)
{
    // update UI position
    // the reason im doing this here is because i want it to update in the menu
    if (pass == 0)
    {
        // get hmn slot
        int hmn_slot = LabOptions_Record[OPTREC_HMNSLOT].option_val;
        if (hmn_slot == 0) // use random slot
            hmn_slot = rec_data.hmn_rndm_slot;
        else
            hmn_slot--;

        // get cpu slot
        int cpu_slot = LabOptions_Record[OPTREC_CPUSLOT].option_val;
        if (cpu_slot == 0) // use random slot
            cpu_slot = rec_data.cpu_rndm_slot;
        else
            cpu_slot--;

        RecInputData *hmn_inputs = rec_data.hmn_inputs[hmn_slot];
        RecInputData *cpu_inputs = rec_data.cpu_inputs[cpu_slot];
        JOBJ *seek = rec_data.seek_jobj;
        Text *text = rec_data.text;

        // get curr frame (the current position in the recording)
        int curr_frame = Record_GetCurrFrame();
        int end_frame = Record_GetEndFrame();

        // hide seek bar during recording
        if ((LabOptions_Record[OPTREC_CPUMODE].option_val == 2) || (LabOptions_Record[OPTREC_HMNMODE].option_val == 1))
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

            // if playing back with no recording, adjust both numbers
            int local_frame_seek = curr_frame + 1;
            if (curr_frame >= end_frame)
            {
                local_frame_seek = curr_frame + 1;
                end_frame = curr_frame + 1;
            }

            // update seek bar position
            float range = rec_data.seek_right - rec_data.seek_left;
            float curr_pos;
            curr_pos = (float)local_frame_seek / (float)end_frame;
            seek->trans.X = rec_data.seek_left + (curr_pos * range);
            JOBJ_ClearFlagsAll(seek, JOBJ_HIDDEN);
            JOBJ_SetMtxDirtySub(seek);

            // update seek bar frames
            Text_SetText(text, 0, "%d", local_frame_seek);
            Text_SetText(text, 1, "%d", end_frame);

            // if random playback, hide frame count and bar
            if ((LabOptions_Record[OPTREC_CPUSLOT].option_val == 0) || (LabOptions_Record[OPTREC_HMNSLOT].option_val == 0))
            {
                Text_SetText(text, 1, "?");          // hide count
                JOBJ_SetFlagsAll(seek, JOBJ_HIDDEN); // hide bar
            }

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
    // get current hmn recording slot
    int hmn_slot = LabOptions_Record[OPTREC_HMNSLOT].option_val;
    if (hmn_slot == 0) // use random slot
        hmn_slot = rec_data.hmn_rndm_slot;
    else
        hmn_slot--;

    // get current cpu recording slot
    int cpu_slot = LabOptions_Record[OPTREC_CPUSLOT].option_val;
    if (cpu_slot == 0) // use random slot
        cpu_slot = rec_data.cpu_rndm_slot;
    else
        cpu_slot--;

    RecInputData *hmn_inputs = rec_data.hmn_inputs[hmn_slot];
    RecInputData *cpu_inputs = rec_data.cpu_inputs[cpu_slot];

    // ensure the state exists
    if (rec_state->is_exist == 1)
    {
        // get longest recording
        int input_num = hmn_inputs->num;
        if (cpu_inputs->num > hmn_inputs->num)
            input_num = cpu_inputs->num;

        // get curr frame (the current position in the recording)
        int curr_frame = Record_GetCurrFrame();
        int end_frame = Record_GetEndFrame();

        // if at the end of the recording
        if ((input_num != 0) && (curr_frame >= end_frame))
        {

            // but not during a recording/control
            if ((LabOptions_Record[OPTREC_HMNMODE].option_val != 1) && (LabOptions_Record[OPTREC_CPUMODE].option_val != 1) && (LabOptions_Record[OPTREC_CPUMODE].option_val != 2))
            {

                // init flag
                int is_loop = 0;

                // check to auto reset
                if ((LabOptions_Record[OPTREC_AUTOLOAD].option_val == 1))
                {
                    event_vars->Savestate_Load(rec_state);
                    event_vars->game_timer = rec_state->frame + 1;
                    is_loop = 1;
                }

                // check to loop inputs
                else if ((LabOptions_Record[OPTREC_LOOP].option_val == 1))
                {
                    event_vars->game_timer = rec_state->frame + 1;
                    is_loop = 1;
                }

                // if recording looped, check to re-roll random slot
                if (is_loop == 1)
                {
                    // re-roll random slot
                    if (LabOptions_Record[OPTREC_HMNSLOT].option_val == 0)
                    {
                        rec_data.hmn_rndm_slot = Record_GetRandomSlot(&rec_data.hmn_inputs);
                    }
                    if (LabOptions_Record[OPTREC_CPUSLOT].option_val == 0)
                    {
                        rec_data.cpu_rndm_slot = Record_GetRandomSlot(&rec_data.cpu_inputs);
                    }
                }
            }
        }

        // check record mode for HMN
        int hmn_mode = LabOptions_Record[OPTREC_HMNMODE].option_val;
        if (hmn_mode > 0) // adjust mode
            hmn_mode++;
        Record_Update(0, hmn_inputs, hmn_mode);
        // check record mode for CPU
        int cpu_mode = LabOptions_Record[OPTREC_CPUMODE].option_val;
        Record_Update(1, cpu_inputs, cpu_mode);
    }
    /*
    GOBJ *cpu = Fighter_GetGObj(1);
    FighterData *cpu_data = cpu->userdata;

    DevText *dev_text = stc_devtext;
    // clear text
    DevelopText_EraseAllText(dev_text);
    DevelopMode_ResetCursorXY(dev_text, 0, 0);
    DevelopText_AddString(dev_text, "isthrown: %d\n", cpu_data->flags.is_thrown);
    */
    return;
}
void Record_Update(int ply, RecInputData *input_data, int rec_mode)
{
    GOBJ *fighter = Fighter_GetGObj(ply);
    FighterData *fighter_data = fighter->userdata;

    // get curr frame (the time since saving positions)
    int curr_frame = (event_vars->game_timer - rec_state->frame);

    // get the frame the recording starts on. i actually hate this code and need to change how this works
    int rec_start;
    if (input_data->start_frame == -1) // case 1: recording didnt start, use current frame
    {
        rec_start = curr_frame - 1;
    }
    else // case 2: recording has started, use the frame saved
    {
        rec_start = input_data->start_frame - rec_state->frame;
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
void Record_InitState(GOBJ *menu_gobj)
{
    if (event_vars->Savestate_Save(rec_state))
    {

        Record_OnSuccessfulSave();
    }
    return;
}
void Record_RestoreState(GOBJ *menu_gobj)
{
    event_vars->Savestate_Load(rec_state);

    return;
}
void Record_ChangeHMNSlot(GOBJ *menu_gobj, int value)
{
    // upon changing to random
    if (value == 0)
    {
        // if set to record
        if (LabOptions_Record[OPTREC_HMNMODE].option_val == 1)
        {
            // change to slot 1
            LabOptions_Record[OPTREC_HMNSLOT].option_val = 1;
        }

        // update random slot
        else
        {
            rec_data.hmn_rndm_slot = Record_GetRandomSlot(&rec_data.hmn_inputs);
        }
    }

    // reload save
    event_vars->Savestate_Load(rec_state);

    return;
}
void Record_ChangeCPUSlot(GOBJ *menu_gobj, int value)
{
    // upon changing to random
    if (value == 0)
    {
        // if set to record
        if (LabOptions_Record[OPTREC_CPUMODE].option_val == 2)
        {
            // change to slot 1
            LabOptions_Record[OPTREC_CPUSLOT].option_val = 1;
        }

        // update random slot
        else
        {
            rec_data.cpu_rndm_slot = Record_GetRandomSlot(&rec_data.cpu_inputs);
        }
    }

    // reload save
    event_vars->Savestate_Load(rec_state);

    return;
}
void Record_ChangeHMNMode(GOBJ *menu_gobj, int value)
{
    // upon changing to record
    if (value == 1)
    {
        // if set to random
        if (LabOptions_Record[OPTREC_HMNSLOT].option_val == 0)
        {
            LabOptions_Record[OPTREC_HMNSLOT].option_val = 1;
        }
    }

    // upon changing to playback
    if (value == 2)
    {
        event_vars->Savestate_Load(rec_state);
    }

    // disable loop options if recording is in use
    if ((LabOptions_Record[OPTREC_HMNMODE].option_val != 1) && (LabOptions_Record[OPTREC_CPUMODE].option_val != 2))
    {
        LabOptions_Record[OPTREC_LOOP].disable = 0;
        LabOptions_Record[OPTREC_AUTOLOAD].disable = 0;
    }
    else
    {
        LabOptions_Record[OPTREC_LOOP].disable = 1;
        LabOptions_Record[OPTREC_AUTOLOAD].disable = 1;
    }

    return;
}
void Record_ChangeCPUMode(GOBJ *menu_gobj, int value)
{
    // upon changing to record
    if (value == 2)
    {
        // if set to random
        if (LabOptions_Record[OPTREC_CPUSLOT].option_val == 0)
        {
            // change to slot 1
            LabOptions_Record[OPTREC_CPUSLOT].option_val = 1;
        }
    }

    // upon toggling playback
    if (value == 3)
    {
        event_vars->Savestate_Load(rec_state);
    }

    // disable loop options if recording is in use
    if ((LabOptions_Record[OPTREC_HMNMODE].option_val != 1) && (LabOptions_Record[OPTREC_CPUMODE].option_val != 2))
    {
        LabOptions_Record[OPTREC_LOOP].disable = 0;
        LabOptions_Record[OPTREC_AUTOLOAD].disable = 0;
    }
    else
    {
        LabOptions_Record[OPTREC_LOOP].disable = 1;
        LabOptions_Record[OPTREC_AUTOLOAD].disable = 1;
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
int Record_GetCurrFrame()
{
    return (event_vars->game_timer - 1) - rec_state->frame;
}
int Record_GetEndFrame()
{

    // get hmn slot
    int hmn_slot = LabOptions_Record[OPTREC_HMNSLOT].option_val;
    if (hmn_slot == 0) // use random slot
        hmn_slot = rec_data.hmn_rndm_slot;
    else
        hmn_slot--;

    // get cpu slot
    int cpu_slot = LabOptions_Record[OPTREC_CPUSLOT].option_val;
    if (cpu_slot == 0) // use random slot
        cpu_slot = rec_data.cpu_rndm_slot;
    else
        cpu_slot--;

    int curr_frame = Record_GetCurrFrame();
    RecInputData *hmn_inputs = rec_data.hmn_inputs[hmn_slot];
    RecInputData *cpu_inputs = rec_data.cpu_inputs[cpu_slot];

    // get what frame the longest recording ends on (savestate frame + recording start frame + recording time)
    int hmn_end_frame = 0;
    int cpu_end_frame = 0;
    if (hmn_inputs->start_frame != -1) // ensure a recording exists
        hmn_end_frame = (hmn_inputs->start_frame + hmn_inputs->num);
    if (cpu_inputs->start_frame != -1) // ensure a recording exists
        cpu_end_frame = (cpu_inputs->start_frame + cpu_inputs->num);

    // find the larger recording
    RecInputData *input_data = hmn_inputs;
    if (cpu_end_frame > hmn_end_frame)
        input_data = cpu_inputs;

    // get the frame the recording starts on. i actually hate this code and need to change how this works
    int rec_start;
    if (input_data->start_frame == -1) // case 1: recording didnt start, use current frame
        rec_start = curr_frame - 1;
    else // case 2: recording has started, use the frame saved
        rec_start = input_data->start_frame - rec_state->frame;

    // get end frame
    int end_frame = rec_start + input_data->num;

    return end_frame;
}
void Record_OnSuccessfulSave()
{
    // enable other options
    for (int i = 1; i < sizeof(LabOptions_Record) / sizeof(EventOption); i++)
    {
        LabOptions_Record[i].disable = 0;
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
    LabOptions_Record[OPTREC_HMNMODE].option_val = 0; // set hmn to off
    LabOptions_Record[OPTREC_HMNSLOT].option_val = 1; // set hmn to slot 1
    LabOptions_Record[OPTREC_CPUMODE].option_val = 0; // set cpu to off
    LabOptions_Record[OPTREC_CPUSLOT].option_val = 1; // set cpu to slot 1

    // also save to personal savestate
    event_vars->Savestate_Save(event_vars->savestate);

    // take screenshot
    snap_status = 1;

    return;
}
void Memcard_Wait()
{

    while (stc_memcard_work->is_done == 0)
    {
        blr2();
    }

    return;
}
void Record_MemcardLoad(int slot, int file_no)
{
    // search card for this save file
    u8 file_found = 0;
    char filename[32];
    int file_size;
    s32 memSize, sectorSize;
    if (CARDProbeEx(slot, &memSize, &sectorSize) == CARD_RESULT_READY)
    {
        // mount card
        stc_memcard_work->is_done = 0;
        if (CARDMountAsync(slot, stc_memcard_work->work_area, 0, Memcard_RemovedCallback) == CARD_RESULT_READY)
        {
            // check card
            Memcard_Wait();
            stc_memcard_work->is_done = 0;
            if (CARDCheckAsync(slot, Memcard_RemovedCallback) == CARD_RESULT_READY)
            {
                Memcard_Wait();

                // search for nth file with name TM_DEBUG
                int tmrec_num = 0;
                for (int i = 0; i < CARD_MAX_FILE; i++)
                {

                    CARDStat card_stat;

                    if (CARDGetStatus(slot, i, &card_stat) == CARD_RESULT_READY)
                    {
                        // check company code
                        if (strncmp(os_info->company, card_stat.company, sizeof(os_info->company)) == 0)
                        {
                            // check game name
                            if (strncmp(os_info->gameName, card_stat.gameName, sizeof(os_info->gameName)) == 0)
                            {
                                // check file name
                                if (strncmp("TMREC", card_stat.fileName, 5) == 0)
                                {

                                    // if the desired file
                                    if (tmrec_num == file_no)
                                    {
                                        file_found = 1;
                                        memcpy(&filename, card_stat.fileName, sizeof(filename)); // copy filename to load after this
                                        file_size = card_stat.length;
                                        break;
                                    }

                                    // increment tmrec num
                                    tmrec_num++;
                                }
                            }
                        }
                    }
                }
            }

            CARDUnmount(slot);
            stc_memcard_work->is_done = 0;
        }
    }

    // if found, load it
    if (file_found == 1)
    {

        int load_pre_tick = OSGetTick();

        // setup load
        MemcardSave memcard_save;
        memcard_save.data = HSD_MemAlloc(file_size);
        memcard_save.x4 = 3;
        memcard_save.size = file_size;
        memcard_save.xc = -1;
        Memcard_LoadSnapshot(slot, filename, &memcard_save, &stc_memcard_info->file_name, 0, 0, 0);

        // wait to load
        int memcard_status = Memcard_CheckStatus();
        while (memcard_status == 11)
        {
            memcard_status = Memcard_CheckStatus();
        }

        // if file loaded successfully
        if (memcard_status == 0)
        {

            // enable other options
            for (int i = 1; i < sizeof(LabOptions_Record) / sizeof(EventOption); i++)
            {
                LabOptions_Record[i].disable = 0;
            }

            // take screenshot
            snap_status = 1;

            // begin unpacking
            u8 *transfer_buf = memcard_save.data;
            ExportHeader *header = transfer_buf;
            u8 *compressed_recording = transfer_buf + header->lookup.ofst_recording;
            RGB565 *img = transfer_buf + header->lookup.ofst_screenshot;
            ExportMenuSettings *menu_settings = transfer_buf + header->lookup.ofst_menusettings;
            OSReport("rec: ft %d vs ft %d on stage %d\n", header->metadata.hmn, header->metadata.cpu, header->metadata.stage_internal);

            // decompress
            RecordingSave *loaded_recsave = calloc(sizeof(RecordingSave) * 1.06);
            lz77_decompress(compressed_recording, loaded_recsave);

            // copy buffer to savestate
            memcpy(rec_state, &loaded_recsave->savestate, sizeof(Savestate));

            // restore controller indices
            rec_state->ft_state[0].player_block.controller = stc_hmn_controller;
            rec_state->ft_state[1].player_block.controller = stc_cpu_controller;

            // load state
            event_vars->Savestate_Load(rec_state);

            // copy recordings
            for (int i = 0; i < REC_SLOTS; i++)
            {
                memcpy(rec_data.hmn_inputs[i], &loaded_recsave->hmn_inputs[i], sizeof(RecInputData));
                memcpy(rec_data.cpu_inputs[i], &loaded_recsave->cpu_inputs[i], sizeof(RecInputData));
            }

            HSD_Free(loaded_recsave);

            // copy recording settings
            LabOptions_Record[OPTREC_HMNMODE].option_val = menu_settings->hmn_mode;
            LabOptions_Record[OPTREC_HMNSLOT].option_val = menu_settings->hmn_slot;
            LabOptions_Record[OPTREC_CPUMODE].option_val = menu_settings->cpu_mode;
            LabOptions_Record[OPTREC_CPUSLOT].option_val = menu_settings->cpu_slot;
            LabOptions_Record[OPTREC_LOOP].option_val = menu_settings->loop_inputs;
            LabOptions_Record[OPTREC_AUTOLOAD].option_val = menu_settings->auto_restore;

            // enter recording menu
            MenuData *menu_data = event_vars->menu_gobj->userdata;
            EventMenu *curr_menu = menu_data->currMenu;
            curr_menu->state = EMSTATE_OPENSUB;
            // update curr_menu
            EventMenu *next_menu = curr_menu->options[2].menu;
            next_menu->prev = curr_menu;
            next_menu->state = EMSTATE_FOCUS;
            curr_menu = next_menu;
            menu_data->currMenu = curr_menu;

            // save to personal savestate
            event_vars->Savestate_Save(event_vars->savestate);
        }

        HSD_Free(memcard_save.data);

        int load_post_tick = OSGetTick();
        int load_time = OSTicksToMilliseconds(load_post_tick - load_pre_tick);
        OSReport("processed memcard load in %dms\n", load_time);
    }

    return;
}
int Record_MenuThink(GOBJ *menu_gobj)
{

    int is_update = 1;

    // check to run export logic
    if (export_status != EXSTAT_NONE)
    {
        is_update = Record_ExportThink();
    }

    return is_update;
}
void Record_StartExport(GOBJ *menu_gobj)
{

    export_status = EXSTAT_REQSAVE;

    return;
}
void Snap_CObjThink(GOBJ *gobj)
{

    // logic based on state
    switch (snap_status)
    {
    case (1):
    {
        // take snap
        HSD_ImageDescCopyFromEFB(&snap_image, 0, 0, 0);
        snap_status = 0;
        OSReport("got snap!\n");

        break;
    }
    }

    return;
}
void Savestates_Update()
{

    /*
    So i have code to do this in events.c that runs based a variable in
    the EventDesc, but i need to execute code directly after loading state
    so im just gonna do this here...
    */

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
                    event_vars->Savestate_Save(event_vars->savestate);
                }
                else if (((pad->down & HSD_BUTTON_DPAD_LEFT) != 0) && ((pad->held & (blacklist)) == 0))
                {
                    // load state
                    event_vars->Savestate_Load(event_vars->savestate);

                    // re-roll random slot
                    if (LabOptions_Record[OPTREC_HMNSLOT].option_val == 0)
                    {
                        rec_data.hmn_rndm_slot = Record_GetRandomSlot(&rec_data.hmn_inputs);
                    }
                    if (LabOptions_Record[OPTREC_CPUSLOT].option_val == 0)
                    {
                        rec_data.cpu_rndm_slot = Record_GetRandomSlot(&rec_data.cpu_inputs);
                    }
                }
            }
        }
    }

    return;
}

// Export functions
static char *keyboard_rows[2][4] = {
    {"1234567890", "qwertyuiop", "asdfghjkl-", "zxcvbnm,./"},
    {"!@#$%^&*()", "QWERTYUIOP", "ASDFGHJKL: ", "ZXCVBNM<>?"}};
int RowPixelToBlockPixel(int pixel_x, int pixel_y, int width, int height)
{

    // get block width and height
    int block_width = divide_roundup(width, 4);

    // get block num
    int block_num = ((pixel_y / 4) * block_width) + (pixel_x / 4);

    // get pixels x and y within this block
    int block_pos_x = pixel_x % 4;
    int block_pos_y = pixel_y % 4;

    // get block pixel index
    int block_pixel = (block_num * 16) + (block_pos_y * 4) + block_pos_x;

    return block_pixel;
}
void ImageScale(RGB565 *out_img, RGB565 *in_img, int OutWidth, int OutHeight, int InWidth, int InHeight)
{

    int x_ratio = (InWidth / OutWidth);
    int y_ratio = (InHeight / OutHeight);
    int px, py;
    int in_pixel, out_pixel;

    for (int y = 0; y < (OutHeight); y++)
    {
        for (int x = 0; x < (OutWidth); x++)
        {
            px = x * x_ratio;
            py = y * y_ratio;
            in_pixel = RowPixelToBlockPixel(x, y, OutWidth, OutHeight);
            out_pixel = RowPixelToBlockPixel(px, py, InWidth, InHeight);
            out_img[in_pixel] = in_img[out_pixel];
        }
    }

    return;
}
void Export_Init(GOBJ *menu_gobj)
{

    MenuData *menu_data = menu_gobj->userdata;
    EventMenu *curr_menu = menu_data->currMenu;
    evMenu *menuAssets = event_vars->menu_assets;

    // create gobj
    GOBJ *export_gobj = GObj_Create(0, 0, 0);
    ExportData *export_data = calloc(sizeof(ExportData));
    GObj_AddUserData(export_gobj, 4, HSD_Free, export_data);

    // load menu joint
    JOBJ *export_joint = JOBJ_LoadJoint(stc_lab_data->export_menu);
    GObj_AddObject(export_gobj, 3, export_joint);                                  // add to gobj
    GObj_AddGXLink(export_gobj, GXLink_Common, GXLINK_MENUMODEL, GXPRI_MENUMODEL); // add gx link
    menu_data->custom_gobj_think = Export_Think;                                   // set callback

    // save jobj pointers
    JOBJ_GetChild(export_joint, &export_data->memcard_jobj[0], EXP_MEMCARDAJOBJ, -1);
    JOBJ_GetChild(export_joint, &export_data->memcard_jobj[1], EXP_MEMCARDBJOBJ, -1);
    JOBJ_GetChild(export_joint, &export_data->screenshot_jobj, EXP_SCREENSHOTJOBJ, -1);
    JOBJ_GetChild(export_joint, &export_data->textbox_jobj, EXP_TEXTBOXJOBJ, -1);

    // hide all
    JOBJ_SetFlags(export_data->memcard_jobj[0], JOBJ_HIDDEN);
    JOBJ_SetFlags(export_data->memcard_jobj[1], JOBJ_HIDDEN);
    JOBJ_SetFlags(export_data->screenshot_jobj, JOBJ_HIDDEN);
    JOBJ_SetFlags(export_data->textbox_jobj, JOBJ_HIDDEN);

    // alloc a buffer for all of the recording data
    RecordingSave *temp_rec_save = calloc(sizeof(RecordingSave));

    // copy match data to buffer
    memcpy(&temp_rec_save->match_data, &stc_match->match, sizeof(MatchInit));
    // copy savestate to buffer
    memcpy(&temp_rec_save->savestate, rec_state, sizeof(Savestate));
    // copy recordings
    for (int i = 0; i < REC_SLOTS; i++)
    {
        memcpy(&temp_rec_save->hmn_inputs[i], rec_data.hmn_inputs[i], sizeof(RecInputData));
        memcpy(&temp_rec_save->cpu_inputs[i], rec_data.cpu_inputs[i], sizeof(RecInputData));
    }

    // compress all recording data
    u8 *recording_buffer = calloc(sizeof(RecordingSave));
    int compress_size = Export_Compress(recording_buffer, temp_rec_save, sizeof(RecordingSave));
    HSD_Free(temp_rec_save); // free original data buffer

    // resize screenshot
    int img_size = GXGetTexBufferSize(RESIZE_WIDTH, RESIZE_HEIGHT, 4, 0, 0);
    RGB565 *orig_img = snap_image.img_ptr;
    RGB565 *new_img = calloc(img_size);
    export_data->scaled_image = new_img;
    ImageScale(new_img, orig_img, RESIZE_WIDTH, RESIZE_HEIGHT, EXP_SCREENSHOT_WIDTH, EXP_SCREENSHOT_HEIGHT);
    OSReport("scaled image to %d kb\n", (img_size / 1000));
    resized_image.img_ptr = new_img;                                            // store pointer to resized image
    export_data->screenshot_jobj->dobj->mobj->tobj->imagedesc = &resized_image; // replace pointer to imagedesc

    // get curr date
    OSCalendarTime td;
    OSTicksToCalendarTime(OSGetTime(), &td);

    // alloc a buffer to transfer to memcard
    stc_transfer_buf_size = sizeof(ExportHeader) + img_size + sizeof(ExportMenuSettings) + compress_size;
    stc_transfer_buf = calloc(stc_transfer_buf_size);

    // init header
    ExportHeader *header = stc_transfer_buf;
    header->metadata.version = REC_VERS;
    header->metadata.image_width = RESIZE_WIDTH;
    header->metadata.image_height = RESIZE_HEIGHT;
    header->metadata.image_fmt = 4;
    header->metadata.hmn = Fighter_GetExternalID(0);
    header->metadata.hmn_costume = Fighter_GetCostumeID(0);
    header->metadata.cpu = Fighter_GetExternalID(1);
    header->metadata.cpu_costume = Fighter_GetCostumeID(1);
    header->metadata.stage_external = Stage_GetExternalID();
    header->metadata.stage_internal = Stage_ExternalToInternal(header->metadata.stage_external);
    header->metadata.month = td.mon + 1;
    header->metadata.day = td.mday;
    header->metadata.year = td.year;
    header->metadata.hour = td.hour;
    header->metadata.minute = td.min;
    header->metadata.second = td.sec;
    header->lookup.ofst_screenshot = sizeof(ExportHeader);
    header->lookup.ofst_recording = sizeof(ExportHeader) + img_size;
    header->lookup.ofst_menusettings = sizeof(ExportHeader) + img_size + compress_size;
    OSReport("prepared buffer of %d kb\n", (stc_transfer_buf_size / 1000));

    // copy data to buffer
    // image
    memcpy(stc_transfer_buf + header->lookup.ofst_screenshot, new_img, img_size);
    // menu settings
    ExportMenuSettings *menu_settings = stc_transfer_buf + header->lookup.ofst_menusettings;
    menu_settings->hmn_mode = LabOptions_Record[OPTREC_HMNMODE].option_val;
    menu_settings->hmn_slot = LabOptions_Record[OPTREC_HMNSLOT].option_val;
    menu_settings->cpu_mode = LabOptions_Record[OPTREC_CPUMODE].option_val;
    menu_settings->cpu_slot = LabOptions_Record[OPTREC_CPUSLOT].option_val;
    menu_settings->loop_inputs = LabOptions_Record[OPTREC_LOOP].option_val;
    menu_settings->auto_restore = LabOptions_Record[OPTREC_AUTOLOAD].option_val;
    // recording data
    memcpy(stc_transfer_buf + header->lookup.ofst_recording, recording_buffer, compress_size); // compressed recording

    // free compresed data buffer
    HSD_Free(recording_buffer);

    // alloc filename buffer
    export_data->filename_buffer = calloc(32 + 2); // +2 for terminator and cursor

    // initialize memcard menu
    Export_SelCardInit(export_gobj);

    event_vars->hide_menu = 1;                       // hide original menu
    menu_data->custom_gobj = export_gobj;            // set custom gobj
    menu_data->custom_gobj_think = Export_Think;     // set think function
    menu_data->custom_gobj_destroy = Export_Destroy; // set destroy function

    return;
}
int Export_Think(GOBJ *export_gobj)
{
    ExportData *export_data = export_gobj->userdata;
    int can_unpause = 0;

    switch (export_data->menu_index)
    {
    case (EXMENU_SELCARD):
    {
        can_unpause = Export_SelCardThink(export_gobj);
        break;
    }
    case (EXMENU_NAME):
    {
        can_unpause = Export_EnterNameThink(export_gobj);
        break;
    }
    case (EXMENU_CONFIRM):
    {
        can_unpause = Export_ConfirmThink(export_gobj);
        break;
    }
    }

    return can_unpause;
}
void Export_Destroy(GOBJ *export_gobj)
{
    ExportData *export_data = export_gobj->userdata;
    MenuData *menu_data = event_vars->menu_gobj->userdata;

    switch (export_data->menu_index)
    {
    case (EXMENU_SELCARD):
    {
        Export_SelCardExit(export_gobj);
        break;
    }
    case (EXMENU_NAME):
    {
        Export_EnterNameExit(export_gobj);
        break;
    }
    }

    // free buffer allocs
    HSD_Free(stc_transfer_buf);
    HSD_Free(export_data->filename_buffer);
    HSD_Free(export_data->scaled_image);

    // destroy gobj
    GObj_Destroy(export_gobj);

    // show menu
    event_vars->hide_menu = 0;
    menu_data->custom_gobj = 0;
    menu_data->custom_gobj_think = 0;
    menu_data->custom_gobj_destroy = 0;

    return;
}
void Export_SelCardInit(GOBJ *export_gobj)
{
    ExportData *export_data = export_gobj->userdata;
    MenuData *menu_data = event_vars->menu_gobj->userdata;

    // show menu jobjs
    JOBJ_ClearFlags(export_data->memcard_jobj[0], JOBJ_HIDDEN);
    JOBJ_ClearFlags(export_data->memcard_jobj[1], JOBJ_HIDDEN);

    // create text
    Text *text_misc = Text_CreateText(2, menu_data->canvas_menu);
    export_data->text_misc = text_misc;
    // enable align and kerning
    text_misc->align = 1;
    text_misc->kerning = 1;
    // scale canvas
    text_misc->scale.X = MENU_CANVASSCALE;
    text_misc->scale.Y = MENU_CANVASSCALE;
    text_misc->trans.Z = MENU_TEXTZ;

    // create title text
    Text *text_title = Text_CreateText(2, menu_data->canvas_menu);
    export_data->text_title = text_title;
    // enable align and kerning
    text_title->align = 0;
    text_title->kerning = 1;
    // scale canvas
    text_title->trans.X = -23;
    text_title->trans.Y = -18;
    text_title->scale.X = MENU_CANVASSCALE * 2;
    text_title->scale.Y = MENU_CANVASSCALE * 2;
    text_title->trans.Z = MENU_TEXTZ;

    // create desc text
    Text *text_desc = Text_CreateText(2, menu_data->canvas_menu);
    export_data->text_desc = text_desc;
    // enable align and kerning
    text_desc->align = 0;
    text_desc->kerning = 1;
    // scale canvas
    text_desc->trans.X = -23;
    text_desc->trans.Y = 12;
    text_desc->scale.X = MENU_CANVASSCALE;
    text_desc->scale.Y = MENU_CANVASSCALE;
    text_desc->trans.Z = MENU_TEXTZ;

    Text_AddSubtext(text_title, 0, 0, "Select a Memory Card"); // add title
    Text_AddSubtext(text_desc, 0, 0, "");                      // add description

    // add dummy text
    Text_AddSubtext(text_misc, -165, 67, "Slot A");
    Text_AddSubtext(text_misc, 165, 67, "Slot B");

    // init memcard inserted status
    for (int i = 0; i < 2; i++)
    {
        export_data->is_inserted[i] = 0;
    }

    // init cursor
    export_data->menu_index = EXMENU_SELCARD;
    export_data->slot = 0;

    return;
}
int Export_SelCardThink(GOBJ *export_gobj)
{

    ExportData *export_data = export_gobj->userdata;

    int req_blocks = (divide_roundup(stc_transfer_buf_size, 8192) + 1);

    // get pausing players inputs
    HSD_Pad *pad = PadGet(stc_hmn_controller, PADGET_MASTER);
    int inputs = pad->down;

    // update memcard info
    for (int i = 1; i >= 0; i--)
    {
        // probe slot
        u8 is_inserted;

        s32 memSize, sectorSize;
        if (CARDProbeEx(i, &memSize, &sectorSize) == CARD_RESULT_READY)
        {
            // if it was just inserted, get info
            if (export_data->is_inserted[i] == 0)
            {

                // mount card
                stc_memcard_work->is_done = 0;
                if (CARDMountAsync(i, stc_memcard_work->work_area, 0, Memcard_RemovedCallback) == CARD_RESULT_READY)
                {
                    // check card
                    Memcard_Wait();
                    stc_memcard_work->is_done = 0;
                    if (CARDCheckAsync(i, Memcard_RemovedCallback) == CARD_RESULT_READY)
                    {
                        Memcard_Wait();

                        // if we get this far, a valid memcard is inserted
                        is_inserted = 1;
                        SFX_PlayCommon(2);
                        //export_data->slot = i;  // move cursor to this

                        // get free blocks
                        s32 byteNotUsed, filesNotUsed;
                        if (CARDFreeBlocks(i, &byteNotUsed, &filesNotUsed) == CARD_RESULT_READY)
                        {
                            export_data->free_blocks[i] = (byteNotUsed / 8192);
                            export_data->free_files[i] = filesNotUsed;
                        }
                    }
                    else
                        is_inserted = 0;

                    CARDUnmount(i);
                    stc_memcard_work->is_done = 0;
                }
                else
                    is_inserted = 0;
            }
            else
                is_inserted = 1;
        }
        else
            is_inserted = 0;

        export_data->is_inserted[i] = is_inserted;
    }

    // if left
    if ((inputs & HSD_BUTTON_LEFT) || (inputs & HSD_BUTTON_DPAD_LEFT))
    {
        if (export_data->slot > 0)
        {
            export_data->slot--;
            SFX_PlayCommon(2);
        }
    }

    // if right
    if ((inputs & HSD_BUTTON_RIGHT) || (inputs & HSD_BUTTON_DPAD_RIGHT))
    {
        if (export_data->slot < 1)
        {
            export_data->slot++;
            SFX_PlayCommon(2);
        }
    }

    int cursor = export_data->slot;
    // if press A,
    if ((inputs & HSD_BUTTON_A) || (inputs & HSD_BUTTON_START))
    {
        // ensure it can be saved
        if ((export_data->is_inserted[cursor] == 1) && (export_data->free_files[cursor] >= 1) && (export_data->free_blocks[cursor] >= req_blocks))
        {
            // can save move to next screen
            Export_SelCardExit(export_gobj);

            // init next menu
            Export_EnterNameInit(export_gobj);

            SFX_PlayCommon(1);

            return;
        }

        else
            SFX_PlayCommon(3);
    }

    // if press B,
    if ((inputs & HSD_BUTTON_B))
    {
        Export_Destroy(export_gobj);

        // play sfx
        SFX_PlayCommon(0);

        return;
    }

    // update selection
    Text *text = export_data->text_misc;
    for (int i = 0; i < 2; i++)
    {
        static GXColor white = {255, 255, 255, 255};
        static GXColor yellow = {201, 178, 0, 255};
        GXColor *color;

        // highlight cursor only
        if (export_data->slot == i)
            color = &yellow;
        else
            color = &white;

        Text_SetColor(text, i, color);
    }

    // update description
    Text *text_desc = export_data->text_desc;
    if (export_data->is_inserted[cursor] == 0)
    {
        Text_SetText(text_desc, 0, "No device is inserted in Slot %s.", slots_names[cursor]);
    }
    else if (export_data->free_files[cursor] < 1)
    {
        Text_SetText(text_desc, 0, "The memory card in Slot %s does not \nhave enough free files. 1 free file is \nrequired to save.", slots_names[cursor]);
    }
    else if (export_data->free_blocks[cursor] < req_blocks)
    {
        Text_SetText(text_desc, 0, "The memory card in Slot %s does not \nhave enough free blocks. %d blocks is \nrequired to save.", slots_names[cursor], req_blocks);
    }
    else
    {
        Text_SetText(text_desc, 0, "Slot %s: %d free blocks. %d blocks will be used.", slots_names[cursor], export_data->free_blocks[cursor], req_blocks);
    }
    return 1;
}
void Export_SelCardExit(GOBJ *export_gobj)
{
    ExportData *export_data = export_gobj->userdata;

    // hide menu jobjs
    JOBJ_SetFlags(export_data->memcard_jobj[0], JOBJ_HIDDEN);
    JOBJ_SetFlags(export_data->memcard_jobj[1], JOBJ_HIDDEN);

    Text_Destroy(export_data->text_title);
    Text_Destroy(export_data->text_desc);
    Text_Destroy(export_data->text_misc);
}
void Export_EnterNameInit(GOBJ *export_gobj)
{
    ExportData *export_data = export_gobj->userdata;
    MenuData *menu_data = event_vars->menu_gobj->userdata;

    // show menu jobjs
    JOBJ_ClearFlags(export_data->screenshot_jobj, JOBJ_HIDDEN);
    JOBJ_ClearFlags(export_data->textbox_jobj, JOBJ_HIDDEN);

    // create keyboard text
    Text *text_keyboard = Text_CreateText(2, menu_data->canvas_menu);
    export_data->text_keyboard = text_keyboard;
    // enable align and kerning
    text_keyboard->align = 1;
    text_keyboard->kerning = 1;
    // scale canvas
    text_keyboard->trans.X = EXP_KEYBOARD_X;
    text_keyboard->trans.Y = EXP_KEYBOARD_Y;
    text_keyboard->scale.X = MENU_CANVASSCALE * EXP_KEYBOARD_SIZE;
    text_keyboard->scale.Y = MENU_CANVASSCALE * EXP_KEYBOARD_SIZE;
    // init keyboard
    for (int i = 0; i < 4; i++)
    {
        // iterate through columns
        for (int j = 0; j < 10; j++)
        {
            Text_AddSubtext(text_keyboard, (-(9.0 / 2.0) * 60) + (j * 60), -80 + (i * 60), "");
        }
    }
    export_data->key_cursor[0] = 0;
    export_data->key_cursor[1] = 0;
    export_data->caps_lock = 0;
    Export_EnterNameUpdateKeyboard(export_gobj);

    // create file details
    ExportHeader *header = stc_transfer_buf;
    char *stage_name = stage_names[header->metadata.stage_internal];
    char *hmn_name = Fighter_GetName(header->metadata.hmn);
    char *cpu_name = Fighter_GetName(header->metadata.cpu);
    Text *text_filedetails = Text_CreateText(2, menu_data->canvas_menu);
    export_data->text_filedetails = text_filedetails;
    // enable align and kerning
    text_filedetails->align = 0;
    text_filedetails->kerning = 1;
    // scale canvas
    text_filedetails->trans.X = EXP_FILEDETAILS_X;
    text_filedetails->trans.Y = EXP_FILEDETAILS_Y;
    text_filedetails->scale.X = MENU_CANVASSCALE * EXP_FILEDETAILS_SIZE;
    text_filedetails->scale.Y = MENU_CANVASSCALE * EXP_FILEDETAILS_SIZE;

    Text_AddSubtext(text_filedetails, 0, 0, "Stage: %s\nHMN: %s\nCPU: %s\n\nSlot %s", stage_name, hmn_name, cpu_name, slots_names[export_data->slot]); // add title

    // create title text
    Text *text_title = Text_CreateText(2, menu_data->canvas_menu);
    export_data->text_title = text_title;
    // enable align and kerning
    text_title->align = 0;
    text_title->kerning = 1;
    // scale canvas
    text_title->trans.X = -23;
    text_title->trans.Y = -18;
    text_title->scale.X = MENU_CANVASSCALE * 2;
    text_title->scale.Y = MENU_CANVASSCALE * 2;
    text_title->trans.Z = MENU_TEXTZ;
    Text_AddSubtext(text_title, 0, 0, "Enter File Name");

    // create desc text
    Text *text_desc = Text_CreateText(2, menu_data->canvas_menu);
    export_data->text_desc = text_desc;
    // enable align and kerning
    text_desc->align = 0;
    text_desc->kerning = 1;
    // scale canvas
    text_desc->trans.X = -23;
    text_desc->trans.Y = 12;
    text_desc->scale.X = MENU_CANVASSCALE;
    text_desc->scale.Y = MENU_CANVASSCALE;
    Text_AddSubtext(text_desc, 0, 0, "A: Select  B: Backspace  Y: Caps  Start: Confirm"); // add description
    Text_AddSubtext(text_desc, 0, 40, "     X: Space  L: Cursor left  R: Cursor right");  // add description

    // create filename
    Text *text_filename = Text_CreateText(2, menu_data->canvas_menu);
    export_data->text_filename = text_filename;
    // enable align and kerning
    text_filename->align = 0;
    text_filename->kerning = 1;
    text_filename->use_aspect = 1;
    GXColor filename_color = {225, 225, 225, 255};
    text_filename->color = filename_color;
    // scale canvas
    text_filename->trans.X = EXP_FILENAME_X;
    text_filename->trans.Y = EXP_FILENAME_Y;
    text_filename->aspect.X = EXP_FILENAME_ASPECTX;
    text_filename->aspect.Y = EXP_FILENAME_ASPECTY;
    text_filename->scale.X = MENU_CANVASSCALE * EXP_FILENAME_SIZE;
    text_filename->scale.Y = MENU_CANVASSCALE * EXP_FILENAME_SIZE;
    // init filename buffer
    export_data->filename_buffer[0] = '_';
    export_data->filename_buffer[1] = '\0';
    Text_AddSubtext(text_filename, 0, 0, export_data->filename_buffer); // add title

    // init menu variables
    export_data->menu_index = EXMENU_NAME;
    export_data->filename_cursor = 0;

    return;
}
int Export_EnterNameThink(GOBJ *export_gobj)
{

    ExportData *export_data = export_gobj->userdata;

    // get pausing players inputs
    HSD_Pad *pad = PadGet(stc_hmn_controller, PADGET_MASTER);
    int inputs = pad->rapidFire;
    int input_down = pad->down;
    u8 *cursor = export_data->key_cursor;
    int update_keyboard = 0;
    int update_filename = 0;
    char *filename_buffer = export_data->filename_buffer;

    // first ensure memcard is still inserted
    s32 memSize, sectorSize;
    if (CARDProbeEx(export_data->slot, &memSize, &sectorSize) != CARD_RESULT_READY)
        goto EXIT;

    // if left
    if ((inputs & HSD_BUTTON_LEFT) || (inputs & HSD_BUTTON_DPAD_LEFT))
    {
        if (cursor[0] > 0)
        {
            cursor[0]--;
        }
        else
        {
            cursor[0] = (10 - 1);
        }
        update_keyboard = 1;
    }
    // if right
    else if ((inputs & HSD_BUTTON_RIGHT) || (inputs & HSD_BUTTON_DPAD_RIGHT))
    {
        if (cursor[0] < (10 - 1))
        {
            cursor[0]++;
        }
        else
        {
            cursor[0] = 0;
        }
        update_keyboard = 1;
    }
    // if up
    else if ((inputs & HSD_BUTTON_UP) || (inputs & HSD_BUTTON_DPAD_UP))
    {
        if (cursor[1] > 0)
        {
            cursor[1]--;
        }
        else
        {
            cursor[1] = (4 - 1);
        }
        update_keyboard = 1;
    }
    // if down
    else if ((inputs & HSD_BUTTON_DOWN) || (inputs & HSD_BUTTON_DPAD_DOWN))
    {
        if (cursor[1] < 4 - 1)
        {
            cursor[1]++;
        }
        else
        {
            cursor[1] = 0;
        }
        update_keyboard = 1;
    }
    // if A
    else if ((inputs & HSD_BUTTON_A))
    {

        // check if any remaining characters
        if (export_data->filename_cursor < 32)
        {

            // get correct set of letters
            char **keyboard_letters = keyboard_rows[export_data->caps_lock];

            // add character to buffer
            filename_buffer[export_data->filename_cursor] = keyboard_letters[cursor[1]][cursor[0]];

            // add cursor and terminator
            filename_buffer[export_data->filename_cursor + 1] = '_';
            filename_buffer[export_data->filename_cursor + 2] = '\0';

            // inc cursor
            export_data->filename_cursor++;

            // update filename
            update_filename = 1;

            // remove caps lock
            export_data->caps_lock = 0;
            update_keyboard = 1;

            SFX_PlayCommon(1);
        }
        else
        {
            SFX_PlayCommon(3);
        }
    }
    // if B
    else if ((inputs & HSD_BUTTON_B))
    {

        // check if can delete
        if (export_data->filename_cursor > 0)
        {
            // dec cursor
            export_data->filename_cursor--;

            // add cursor and terminator
            filename_buffer[export_data->filename_cursor] = '_';
            filename_buffer[export_data->filename_cursor + 1] = '\0';

            // update filename
            update_filename = 1;

            SFX_PlayCommon(0);
        }

        // exit here
        else if (input_down & HSD_BUTTON_B)
        {
        EXIT:
            Export_EnterNameExit(export_gobj);
            Export_SelCardInit(export_gobj);
            SFX_PlayCommon(0);
            return 0;
        }
    }
    // if Y
    if ((inputs & HSD_BUTTON_Y))
    {
        // toggle capslock
        if (export_data->caps_lock == 0)
            export_data->caps_lock = 1;
        else
            export_data->caps_lock = 0;

        // update keyboard
        update_keyboard = 1;

        SFX_PlayCommon(1);
    }
    // if X
    if ((inputs & HSD_BUTTON_X))
    {

        // check if any remaining characters
        if (export_data->filename_cursor < 32)
        {
            // add character to buffer
            filename_buffer[export_data->filename_cursor] = ' ';

            // add cursor and terminator
            filename_buffer[export_data->filename_cursor + 1] = '_';
            filename_buffer[export_data->filename_cursor + 2] = '\0';

            // inc cursor
            export_data->filename_cursor++;

            // update filename
            update_filename = 1;

            SFX_PlayCommon(1);
        }
        else
        {
            OSReport("max characters!\n");
        }
    }
    // if START
    if ((inputs & HSD_BUTTON_START))
    {
        // at least 1 character
        if (export_data->filename_cursor > 0)
        {
            Export_ConfirmInit(export_gobj);

            // play sfx
            SFX_PlayCommon(1);
        }
        else
        {
            SFX_PlayCommon(3);
        }

        return 0;
    }

    // update keyboard
    if (update_keyboard == 1)
    {
        Export_EnterNameUpdateKeyboard(export_gobj);
        SFX_PlayCommon(2);
    }

    // update filename if changed
    if (update_filename == 1)
    {
        Text_SetText(export_data->text_filename, 0, filename_buffer);
    }

    return 0;
}
void Export_EnterNameExit(GOBJ *export_gobj)
{
    ExportData *export_data = export_gobj->userdata;

    // hide menu jobjs
    JOBJ_SetFlags(export_data->screenshot_jobj, JOBJ_HIDDEN);
    JOBJ_SetFlags(export_data->textbox_jobj, JOBJ_HIDDEN);

    Text_Destroy(export_data->text_title);
    Text_Destroy(export_data->text_desc);
    Text_Destroy(export_data->text_keyboard);
    Text_Destroy(export_data->text_filename);
    Text_Destroy(export_data->text_filedetails);
}
void Export_ConfirmInit(GOBJ *export_gobj)
{
    ExportData *export_data = export_gobj->userdata;
    MenuData *menu_data = event_vars->menu_gobj->userdata;

    // create gobj
    GOBJ *confirm_gobj = GObj_Create(0, 0, 0);
    export_data->confirm_gobj = confirm_gobj;

    // load menu joint
    JOBJ *confirm_jobj = JOBJ_LoadJoint(stc_lab_data->export_popup);
    GObj_AddObject(confirm_gobj, 3, confirm_jobj);                                   // add to gobj
    GObj_AddGXLink(confirm_gobj, GXLink_Common, GXLINK_MENUMODEL, GXPRI_POPUPMODEL); // add gx link

    // create text
    Text *confirm_text = Text_CreateText(2, menu_data->canvas_popup);
    export_data->confirm_text = confirm_text;
    // enable align and kerning
    confirm_text->align = 1;
    confirm_text->kerning = 1;
    // scale canvas
    confirm_text->trans.X = 0;
    confirm_text->trans.Y = 0;
    confirm_text->scale.X = MENU_CANVASSCALE;
    confirm_text->scale.Y = MENU_CANVASSCALE;
    confirm_text->trans.Z = MENU_TEXTZ;
    Text_AddSubtext(confirm_text, 0, -40, "Save File to Slot %s?", slots_names[export_data->slot]);
    int yes_subtext = Text_AddSubtext(confirm_text, -60, 20, "Yes");
    GXColor yellow = {201, 178, 0, 255};
    Text_SetColor(confirm_text, yes_subtext, &yellow);
    Text_AddSubtext(confirm_text, 60, 20, "No");

    export_data->menu_index = EXMENU_CONFIRM;
    export_data->confirm_state = EXPOP_CONFIRM;
    export_data->confirm_cursor = 0;

    return 0;
}
int Export_ConfirmThink(GOBJ *export_gobj)
{
    ExportData *export_data = export_gobj->userdata;

    // get pausing players inputs
    HSD_Pad *pad = PadGet(stc_hmn_controller, PADGET_MASTER);
    int inputs = pad->down;

    // if unplugged exit
    s32 memSize, sectorSize;
    if (CARDProbeEx(export_data->slot, &memSize, &sectorSize) != CARD_RESULT_READY)
    {
        Export_ConfirmExit(export_gobj);
        Export_EnterNameExit(export_gobj);

        // play sfx
        SFX_PlayCommon(0);
    }

    switch (export_data->confirm_state)
    {
    case (EXPOP_CONFIRM):
    {

        int update_cursor = 0;

        // if left
        if ((inputs & HSD_BUTTON_LEFT) || (inputs & HSD_BUTTON_DPAD_LEFT))
        {
            if (export_data->confirm_cursor > 0)
            {
                export_data->confirm_cursor--;
                update_cursor = 1;
            }
        }
        // if right
        else if ((inputs & HSD_BUTTON_RIGHT) || (inputs & HSD_BUTTON_DPAD_RIGHT))
        {
            if (export_data->confirm_cursor < 1)
            {
                export_data->confirm_cursor++;
                update_cursor = 1;
            }
        }

        // if b
        else if ((inputs & HSD_BUTTON_B))
        {
            Export_ConfirmExit(export_gobj);

            // play sfx
            SFX_PlayCommon(0);

            return 0;
        }
        // if a
        else if ((inputs & HSD_BUTTON_A) || (inputs & HSD_BUTTON_START))
        {

            // begin save
            if (export_data->confirm_cursor == 0)
            {

                MenuData *menu_data = event_vars->menu_gobj->userdata;

                // free current text
                Text_Destroy(export_data->confirm_text);

                // create text
                Text *confirm_text = Text_CreateText(2, menu_data->canvas_popup);
                export_data->confirm_text = confirm_text;
                // enable align and kerning
                confirm_text->align = 1;
                confirm_text->kerning = 1;
                // scale canvas
                confirm_text->trans.X = 0;
                confirm_text->trans.Y = 0;
                confirm_text->scale.X = MENU_CANVASSCALE;
                confirm_text->scale.Y = MENU_CANVASSCALE;
                confirm_text->trans.Z = MENU_TEXTZ;
                Text_AddSubtext(confirm_text, 0, -20, "");

                export_data->confirm_state = EXPOP_SAVE;

                export_status = EXSTAT_REQSAVE;

                // play sfx
                SFX_PlayCommon(1);

                return 0;
            }
            // go back to keyboard menu
            else
            {
                Export_ConfirmExit(export_gobj);

                // play sfx
                SFX_PlayCommon(0);

                return 0;
            }
        }

        if (update_cursor == 1)
        {
            for (int i = 0; i < 2; i++)
            {
                static GXColor white = {255, 255, 255, 255};
                static GXColor yellow = {201, 178, 0, 255};
                GXColor *color;

                // highlight cursor only
                if (export_data->confirm_cursor == i)
                    color = &yellow;
                else
                    color = &white;

                Text_SetColor(export_data->confirm_text, i + 1, color);
            }

            SFX_PlayCommon(2);
        }
        break;
    }
    case (EXPOP_SAVE):
    {
        // wait for save to finish
        if (Export_Process(export_gobj) == 1)
        {
            Export_ConfirmExit(export_gobj);
            Export_Destroy(export_gobj);

            // play sfx
            SFX_PlayCommon(1);

            return 0;
        }
        break;
    }
    }
    return 0;
}
void Export_ConfirmExit(GOBJ *export_gobj)
{
    ExportData *export_data = export_gobj->userdata;

    GObj_Destroy(export_data->confirm_gobj);
    Text_Destroy(export_data->confirm_text);

    export_data->menu_index = EXMENU_NAME;
}
void Export_EnterNameUpdateKeyboard(GOBJ *export_gobj)
{
    ExportData *export_data = export_gobj->userdata;
    Text *text_keyboard = export_data->text_keyboard;
    u8 *cursor = export_data->key_cursor;

    // get correct set of letters
    char **keyboard_letters = keyboard_rows[export_data->caps_lock];

    // iterate through rows
    for (int i = 0; i < 4; i++)
    {
        // iterate through columns
        for (int j = 0; j < 10; j++)
        {

            int this_subtext = (i * 10) + j;

            // update letter text
            char letter[2];
            letter[0] = keyboard_letters[i][j];
            letter[1] = '\0';
            Text_SetText(text_keyboard, this_subtext, &letter);

            // update letter color
            static GXColor white = {255, 255, 255, 255};
            static GXColor yellow = {201, 178, 0, 255};
            GXColor *color;
            // check for cursor
            if ((cursor[0] == j) && (cursor[1] == i))
                color = &yellow;
            else
                color = &white;
            Text_SetColor(text_keyboard, this_subtext, color);
        }
    }

    return;
}
int Export_Process(GOBJ *export_gobj)
{

    ExportData *export_data = export_gobj->userdata;
    Text *text = export_data->confirm_text;

    int finished = 0;

    // if snapshot is processing, dont update
    switch (export_status)
    {
    case (EXSTAT_REQSAVE):
    {

        int slot = export_data->slot;

        save_pre_tick = OSGetTick();

        // create filename string
        ExportHeader *header = stc_transfer_buf;
        char filename[32];
        sprintf(filename, tm_filename, header->metadata.month, header->metadata.day, header->metadata.year, header->metadata.hour, header->metadata.minute, header->metadata.second); // generate filename based on date, time, fighters, and stage

        // save file name to metadata
        memcpy(&header->metadata.filename, export_data->filename_buffer, export_data->filename_cursor);

        // check if file exists and delete it
        s32 memSize, sectorSize;
        if (CARDProbeEx(slot, &memSize, &sectorSize) == CARD_RESULT_READY)
        {
            // mount card
            stc_memcard_work->is_done = 0;
            if (CARDMountAsync(slot, stc_memcard_work->work_area, 0, Memcard_RemovedCallback) == CARD_RESULT_READY)
            {
                // check card
                Memcard_Wait();
                stc_memcard_work->is_done = 0;
                if (CARDCheckAsync(slot, Memcard_RemovedCallback) == CARD_RESULT_READY)
                {
                    Memcard_Wait();
                    // get free blocks
                    s32 byteNotUsed, filesNotUsed;
                    if (CARDFreeBlocks(slot, &byteNotUsed, &filesNotUsed) == CARD_RESULT_READY)
                    {
                        // search for file with this name
                        for (int i = 0; i < CARD_MAX_FILE; i++)
                        {
                            CARDStat card_stat;

                            if (CARDGetStatus(slot, i, &card_stat) == CARD_RESULT_READY)
                            {
                                // check company code
                                if (strncmp(os_info->company, card_stat.company, sizeof(os_info->company)) == 0)
                                {
                                    // check game name
                                    if (strncmp(os_info->gameName, card_stat.gameName, sizeof(os_info->gameName)) == 0)
                                    {
                                        // check file name
                                        if (strncmp(&filename, card_stat.fileName, sizeof(filename)) == 0)
                                        {
                                            // delete
                                            CARDDeleteAsync(slot, &filename, Memcard_RemovedCallback);
                                            stc_memcard_work->is_done = 0;
                                            Memcard_Wait();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                CARDUnmount(slot);
                stc_memcard_work->is_done = 0;
            }
        }

        // setup save
        memcpy(stc_memcard_info->file_name, &stc_save_name, sizeof(stc_save_name));
        memset(stc_memcard_info->file_desc, '\0', 32);                                                   // fill with spaces
        memcpy(stc_memcard_info->file_desc, export_data->filename_buffer, export_data->filename_cursor); // copy inputted name
        memcard_save.data = stc_transfer_buf;
        memcard_save.x4 = 3;
        memcard_save.size = stc_transfer_buf_size;
        memcard_save.xc = -1;
        Memcard_CreateSnapshot(slot, &filename, &memcard_save, stc_memcard_unk, stc_memcard_info->file_name, stc_lab_data->save_banner, stc_lab_data->save_icon, 0);

        // change status
        export_status = EXSTAT_SAVEWAIT;
        OSReport("now saving...\n");

        break;
    }
    case (EXSTAT_SAVEWAIT):
    {

        // wait to finish writing
        if (Memcard_CheckStatus() != 11)
        {
            // change state
            export_status = EXSTAT_DONE;
        }
        else
        {
            OSReport("status %d // progress %d/%d\n", *stc_memcard_write_status, *stc_memcard_block_curr, *stc_memcard_block_last);

            if (*stc_memcard_write_status == 6)
            {
                Text_SetText(text, 0, "Writing Data...");
            }
            else
            {
                Text_SetText(text, 0, "Creating File");
            }
        }

        break;
    }
    case (EXSTAT_DONE):
    {

        export_status = EXSTAT_NONE;
        finished = 1;

        Text_Destroy(text);

        // done saving, output time
        int save_post_tick = OSGetTick();
        int save_time = OSTicksToMilliseconds(save_post_tick - save_pre_tick);
        OSReport("wrote save in %dms\n", save_time);

        break;
    }
    }

    return finished;
}
int Export_Compress(u8 *dest, u8 *source, u32 size)
{

    int pre_tick = OSGetTick();
    int compress_size = lz77_compress(source, size, dest, 8);
    int post_tick = OSGetTick();
    int time_dif = OSTicksToMilliseconds(post_tick - pre_tick);

    OSReport("compressed %d bytes to %d bytes (%.2fx) in %dms\n", size, compress_size, ((float)size / (float)compress_size), time_dif);

    return compress_size;
}

// Init Function
void Event_Init(GOBJ *gobj)
{
    LCancelData *eventData = gobj->userdata;
    EventDesc *eventInfo = eventData->eventInfo;
    GOBJ *hmn = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn->userdata;
    GOBJ *cpu = Fighter_GetGObj(1);
    FighterData *cpu_data = cpu->userdata;

    // theres got to be a better way to do this...
    event_vars = *event_vars_ptr;

    // get this events assets
    stc_lab_data = File_GetSymbol(event_vars->event_archive, "labData");

    // Init Info Display
    InfoDisplay_Init();

    // Init DIDraw
    DIDraw_Init();

    // Init Recording
    Record_Init();

    // Init Input Display
    Inputs_Init();

    // store hsd_update functions
    HSD_Update *hsd_update = HSD_UPDATE;
    hsd_update->checkPause = Update_CheckPause;
    hsd_update->checkAdvance = Update_CheckAdvance;

    // determine cpu controller
    stc_hmn_controller = Fighter_GetControllerPort(hmn_data->ply);
    u8 cpu_controller = 1;
    if (stc_hmn_controller != 0)
        cpu_controller = 0;
    stc_cpu_controller = cpu_controller;

    // set CPU AI to no_act 15
    cpu_data->cpu.ai = 0;

    // check to immediately load recording
    if (*onload_fileno != -1)
    {
        Record_MemcardLoad(*onload_slot, *onload_fileno);
    }

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

    // Check for savestates
    Savestates_Update();
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
    LabOptions_General[OPTGEN_HMNPCNT].option_val = hmn_data->dmg.percent;
    LabOptions_CPU[OPTCPU_PCNT].option_val = cpu_data->dmg.percent;

    // reset stale moves
    if (LabOptions_General[OPTGEN_STALE].option_val == 0)
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
    if (LabOptions_CPU[OPTCPU_INTANG].option_val == 1)
    {
        cpu_data->flags.no_reaction_always = 1;
        cpu_data->flags.nudge_disable = 1;
        cpu_data->grab.vuln = 0x1FF;
        cpu_data->dmg.percent = 0;
        Fighter_SetHUDDamage(cpu_data->ply, 0);

        // if new state, apply colanim
        if (cpu_data->TM.state_frame <= 1)
        {
            Fighter_ApplyOverlay(cpu_data, INTANG_COLANIM, 0);
        }
    }
    else
    {
        cpu_data->flags.no_reaction_always = 0;
        cpu_data->flags.nudge_disable = 0;
    }

    // Move CPU
    if (pad->down == PAD_BUTTON_DPAD_DOWN)
    {
        // ensure CPU is not dead
        if (cpu_data->flags.dead == 0)
        {
            // ensure player is grounded
            int isGround = 0;
            if (hmn_data->phys.air_state == 0)
            {

                // check for ground in front of player
                Vec3 coll_pos;
                int line_index;
                int line_kind;
                Vec3 line_unk;
                float fromX = (hmn_data->phys.pos.X) + (hmn_data->facing_direction * 16);
                float toX = fromX;
                float fromY = (hmn_data->phys.pos.Y + 5);
                float toY = fromY - 10;
                isGround = GrColl_RaycastGround(&coll_pos, &line_index, &line_kind, &line_unk, -1, -1, -1, 0, fromX, fromY, toX, toY, 0);
                if (isGround == 1)
                {

                    // do this for every subfighter (thanks for complicated code ice climbers)
                    int is_moved = 0;
                    for (int i = 0; i < 2; i++)
                    {
                        GOBJ *this_fighter = Fighter_GetSubcharGObj(cpu_data->ply, i);

                        if (this_fighter != 0)
                        {

                            FighterData *this_fighter_data = this_fighter->userdata;

                            if ((this_fighter_data->flags.sleep == 0) && (this_fighter_data->flags.dead == 0))
                            {

                                is_moved = 1;

                                // place CPU here
                                this_fighter_data->phys.pos = coll_pos;
                                this_fighter_data->coll_data.ground_index = line_index;

                                // facing player
                                this_fighter_data->facing_direction = hmn_data->facing_direction * -1;

                                // set grounded
                                this_fighter_data->phys.air_state = 0;
                                //Fighter_SetGrounded(this_fighter);

                                // kill velocity
                                Fighter_KillAllVelocity(this_fighter);

                                // enter wait
                                Fighter_EnterWait(this_fighter);

                                // update ECB
                                this_fighter_data->coll_data.topN_Curr = this_fighter_data->phys.pos; // move current ECB location to new position
                                Coll_ECBCurrToPrev(&this_fighter_data->coll_data);
                                this_fighter_data->cb.Coll(this_fighter);

                                // update camera box
                                Fighter_UpdateCameraBox(this_fighter);
                                this_fighter_data->cameraBox->boundleft_curr = this_fighter_data->cameraBox->boundleft_proj;
                                this_fighter_data->cameraBox->boundright_curr = this_fighter_data->cameraBox->boundright_proj;

                                // init CPU logic (for nana's popo position history...)
                                int cpu_kind = Fighter_GetCPUKind(this_fighter_data->ply);
                                int cpu_level = Fighter_GetCPULevel(this_fighter_data->ply);
                                Fighter_CPUInitialize(this_fighter_data, cpu_kind, cpu_level, 0);

                                // place subfighter in the Z axis
                                if (this_fighter_data->flags.ms == 1)
                                {
                                    ftCommonData *ft_common = *stc_ftcommon;
                                    this_fighter_data->phys.pos.Z = ft_common->ms_zjostle_max * -1;
                                }
                            }
                        }
                    }

                    if (is_moved == 1)
                    {

                        // reset CPU think variables
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

                        // savestate
                        event_vars->Savestate_Save(event_vars->savestate);
                    }
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
    }

    // Adjust control of fighters
    switch (LabOptions_Record[OPTREC_CPUMODE].option_val)
    {
    case RECMODE_OFF:
    {
        // human is human
        hmn_data->player_controller_number = stc_hmn_controller;

        // cpu is cpu
        Fighter_SetSlotType(cpu_data->ply, 1);
        cpu_data->player_controller_number = stc_cpu_controller;

        break;
    }
    case RECMODE_PLAY:
    {

        // human is human
        hmn_data->player_controller_number = stc_hmn_controller;

        // cpu is hmn
        Fighter_SetSlotType(cpu_data->ply, 0);
        cpu_data->player_controller_number = stc_cpu_controller;

        break;
    }
    case RECMODE_CTRL:
    case RECMODE_REC:
    {
        // human is human
        hmn_data->player_controller_number = stc_cpu_controller;

        // cpu is hmn
        Fighter_SetSlotType(cpu_data->ply, 0);
        cpu_data->player_controller_number = stc_hmn_controller;

        break;
    }
    }

    // CPU Think if not using recording
    if ((LabOptions_Record[OPTREC_CPUMODE].option_val == 0) && (LabOptions_Record[OPTREC_HMNMODE].option_val == 0))
        LCancel_CPUThink(event, hmn, cpu);

    return;
}
// Initial Menu
static EventMenu *Event_Menu = &LabMenu_Main;