#include "events.h"
#include <stdarg.h>

void Event_Init(GOBJ *gobj)
{
    int *EventData = gobj->userdata;
    EventDesc *event_desc = EventData[0];

    return;
}

/////////////////////
// Mod Information //
/////////////////////

static char TM_VersShort[] = TM_VERSSHORT "\n";
static char TM_VersLong[] = TM_VERSLONG "\n";
static char TM_Compile[] = "COMPILED: " __DATE__ " " __TIME__;
static char nullString[] = " ";

////////////////////////
/// Event Defintions ///
////////////////////////

// Lab
// Match Data
static EventMatchData Lab_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = false,
    .hideGo = true,
    .hideReady = true,
    .isCreateHUD = true,
    .isDisablePause = true,
    // byte 0x3
    .timerRunOnPause = false,   // 0x01
    .isHidePauseHUD = true,     // 0x02
    .isShowLRAStart = true,     // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = false,      // 0x10
    .isCheckForZRetry = false,  // 0x20
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
static EventDesc Lab = {
    // Event Name
    .eventName = "Training Lab\n",
    .eventDescription = "Free practice with\ncomplete control.\n",
    .eventTutorial = "",
    .eventFile = "EvLab",
    .eventCSSFile = "TM/EvLabCSS.dat",
    .isChooseCPU = true,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Lab_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData LCancel_MatchData = {
    .timer = MATCH_TIMER_HIDE,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = false,
    .hideGo = true,
    .hideReady = true,
    .isCreateHUD = false,
    .isDisablePause = true,
    // byte 0x3
    .timerRunOnPause = false,   // 0x01
    .isHidePauseHUD = true,     // 0x02
    .isShowLRAStart = true,     // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = false,      // 0x10
    .isCheckForZRetry = false,  // 0x20
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
static EventDesc LCancel = {
    // Event Name
    .eventName = "L-Cancel Training\n",
    .eventDescription = "Practice L-Cancelling on\na stationary CPU.\n",
    .eventTutorial = "TvLC",
    .eventFile = "EvLcl",
    .isChooseCPU = false,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 15,
    .matchData = &LCancel_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// Ledgedash Training
// Match Data
static EventMatchData Ledgedash_MatchData = {
    .timer = MATCH_TIMER_HIDE,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = false,
    .hideGo = true,
    .hideReady = true,
    .isCreateHUD = false,
    .isDisablePause = true,
    // byte 0x3
    .timerRunOnPause = false,   // 0x01
    .isHidePauseHUD = true,     // 0x02
    .isShowLRAStart = true,     // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = false,      // 0x10
    .isCheckForZRetry = false,  // 0x20
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
static EventDesc Ledgedash = {
    .eventName = "Ledgedash Training\n",
    .eventDescription = "Practice Ledgedashes!\nUse D-Pad to change ledge.\n",
    .eventTutorial = "TvLedDa",
    .eventFile = "EvLdsh",
    .isChooseCPU = false,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 15,
    .matchData = &Ledgedash_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// Wavedash Training
// Match Data
static EventMatchData Wavedash_MatchData = {
    .timer = MATCH_TIMER_HIDE,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = false,
    .hideGo = true,
    .hideReady = true,
    .isCreateHUD = false,
    .isDisablePause = true,
    // byte 0x3
    .timerRunOnPause = false,   // 0x01
    .isHidePauseHUD = true,     // 0x02
    .isShowLRAStart = true,     // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = false,      // 0x10
    .isCheckForZRetry = false,  // 0x20
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
static EventDesc Wavedash = {
    .eventName = "Wavedash Training\n",
    .eventDescription = "Practice timing your wavedash,\na fundamental movement technique.\n",
    .eventTutorial = "TvWvDsh",
    .eventFile = "EvWdsh",
    .isChooseCPU = false,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 15,
    .matchData = &Wavedash_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// Combo Training
// Match Data
static EventMatchData Combo_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
// Event Struct
static EventDesc Combo = {

    .eventName = "Combo Training\n",
    .eventDescription = "L+DPad adjusts percent | DPadDown moves CPU\nDPad right/left saves and loads positions.",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = true,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Combo_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// Attack On Shield Training
// Match Data
static EventMatchData AttackOnShield_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .stage = 32,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc AttackOnShield = {
    .eventName = "Attack on Shield\n",
    .eventDescription = "Practice attacks on a shielding opponent\nPause to change their OoS option\n",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = true,
    .isSelectStage = false,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &AttackOnShield_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// Reversal Training
// Match Data
static EventMatchData Reversal_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
// Event Struct
static EventDesc Reversal = {
    .eventName = "Reversal Training\n",
    .eventDescription = "Practice OoS punishes! DPad left/right\nmoves characters close and further apart.",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = true,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Reversal_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData SDI_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .stage = 32,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc SDI = {
    .eventName = "SDI Training\n",
    .eventDescription = "Use Smash DI to escape\nFox's up-air attack!",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = false,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &SDI_MatchData,
    .defaultOSD = 0xFFFFFFFF,

};

// L-Cancel Training
// Match Data
static EventMatchData Powershield_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .cpuKind = 20,        // 0xFF=
    .stage = 32,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc Powershield = {
    .eventName = "Powershield Training\n",
    .eventDescription = "Powershield Falco's laser!\nPause to change to fire-rate.",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = false,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Powershield_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData Ledgetech_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .cpuKind = 20,        // 0xFF=
    .stage = -1,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc Ledgetech = {
    .eventName = "Ledge-Tech Training\n",
    .eventDescription = "Practice ledge-teching\nFalco's down-smash",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Ledgetech_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData AmsahTech_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .cpuKind = 9,         // 0xFF=
    .stage = -1,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc AmsahTech = {
    .eventName = "Amsah-Tech Training\n",
    .eventDescription = "Taunt to have Marth Up-B,\nthen ASDI down and tech!\n",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &AmsahTech_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData ShieldDrop_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
// Event Struct
static EventDesc ShieldDrop = {
    .eventName = "Shield Drop Training\n",
    .eventDescription = "Counter with a shield-drop aerial!\nDPad left/right moves players apart.",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = true,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &ShieldDrop_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData WaveshineSDI_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .stage = 32,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc WaveshineSDI = {
    .eventName = "Waveshine SDI\n",
    .eventDescription = "Use Smash DI to get out\nof Fox's waveshine!",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = false,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &WaveshineSDI_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData SlideOff_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .cpuKind = 9,         // 0xFF=
    .stage = 3,           // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc SlideOff = {
    .eventName = "Slide-Off Training\n",
    .eventDescription = "Use Slide-Off DI to slide off\nthe platform and counter attack!\n",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = false,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &SlideOff_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData GrabMash_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .cpuKind = 9,         // 0xFF=
    .stage = 32,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc GrabMash = {
    .eventName = "Grab Mash Training\n",
    .eventDescription = "Mash buttons to escape the grab\nas quickly as possible!\n",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = false,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &GrabMash_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData TechCounter_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .cpuKind = 9,         // 0xFF=
    .stage = -1,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc TechCounter = {
    .eventName = "Ledgetech Marth Counter\n",
    .eventDescription = "Practice ledge-teching\nMarth's counter!\n",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &TechCounter_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData ArmadaShine_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
// Event Struct
static EventDesc ArmadaShine = {
    .eventName = "Armada-Shine Training\n",
    .eventDescription = "Finish the enemy Fox\nwith an Armada Shine!",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &ArmadaShine_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData SideBSweet_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .cpuKind = 9,         // 0xFF=
    .stage = -1,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc SideBSweet = {
    .eventName = "Side-B Sweetspot\n",
    .eventDescription = "Use a sweetspot Side-B to avoid Marth's\ndown-tilt and grab the ledge!",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &SideBSweet_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData EscapeSheik_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .cpuKind = 19,        // 0xFF=
    .stage = 32,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc EscapeSheik = {
    .eventName = "Escape Sheik Techchase\n",
    .eventDescription = "Practice escaping the tech chase with a\nframe perfect shine or jab SDI!\n",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = false,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &EscapeSheik_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData Eggs_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
// Event Struct
static EventDesc Eggs = {
    .eventName = "Eggs-ercise\n",
    .eventDescription = "Break the eggs! Only strong hits will\nbreak them. DPad down = free practice.",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = true,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Eggs_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData Multishine_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .stage = 32,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc Multishine = {
    .eventName = "Shined Blind\n",
    .eventDescription = "How many shines can you\nperform in 10 seconds?",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = false,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Multishine_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData Reaction_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .stage = 32,          // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc Reaction = {
    .eventName = "Reaction Test\n",
    .eventDescription = "Test your reaction time by pressing\nany button when you see/hear Fox shine!",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = false,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Reaction_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// L-Cancel Training
// Match Data
static EventMatchData Ledgestall_MatchData = {
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
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
    .stage = 6,           // 0xFFFF
    .timerSeconds = 0,    // 0xFFFFFFFF
    .timerSubSeconds = 0, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Event Struct
static EventDesc Ledgestall = {
    .eventName = "Under Fire\n",
    .eventDescription = "Ledgestall to remain\ninvincible while the lava rises!\n",
    .eventTutorial = "TvLC",
    .eventFile = 0,
    .isChooseCPU = false,
    .isSelectStage = false,
    .use_savestates = false,
    .disable_hazards = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Ledgestall_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

///////////////////////
/// Page Defintions ///
///////////////////////

// Minigames
static EventDesc *Minigames_Events[] = {
    &Eggs,
    &Multishine,
    &Reaction,
    &Ledgestall,
};
static EventPage Minigames_Page = {
    .name = "Minigames",
    .eventNum = (sizeof(Minigames_Events) / 4) - 1,
    .events = Minigames_Events,
};

// Page 2 Events
static EventDesc *General_Events[] = {
    &Lab,
    &LCancel,
    &Ledgedash,
    &Wavedash,
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
static EventDesc *Spacie_Events[] = {
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

static EventVars stc_event_vars = {
    .event_desc = 0,
    .menu_assets = 0,
    .event_gobj = 0,
    .menu_gobj = 0,
    .game_timer = 0,
    .hide_menu = 0,
    .Savestate_Save = Savestate_Save,
    .Savestate_Load = Savestate_Load,
    .Message_Display = Message_Display,
    .Tip_Display = Tip_Display,
    .Tip_Destroy = Tip_Destroy,
    .savestate = 0,
};
static Savestate *stc_savestate;
static EventDesc *static_eventInfo;
static MenuData *static_menuData;
static int show_console = 1;
static int *eventDataBackup;
static TipMgr stc_tipmgr;

///////////////////////
/// Event Functions ///
///////////////////////

void EventInit(int page, int eventID, MatchInit *matchData)
{

    /* 
    This function runs when leaving the main menu/css and handles
    setting up the match information, such as rules, players, stage.
    All of this data comes from the EventDesc in events.c
    */

    // get event pointer
    EventDesc *event = GetEventDesc(page, eventID);

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
    matchData->isDisableMusic = eventMatchData->isDisableMusic;
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

    // Determine player ports
    u8 hmn_port = *stc_css_hmnport + 1;
    u8 cpu_port = *stc_css_cpuport + 1;

    // Determine the Player
    s32 playerKind;
    s32 playerCostume;
    Preload *preload = Preload_GetTable();
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

        // change zelda to sheik
        if (cpuKind == 18)
        {
            cpuKind = 19;
            preload->fighters[1].kind = cpuKind;
        }
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
    matchData->playerData[0].portNumberOverride = hmn_port;

    // Copy CPU if they exist for this event
    if (cpuKind != -1)
    {
        matchData->playerData[1].kind = cpuKind;
        matchData->playerData[1].costume = cpuCostume;
        matchData->playerData[1].status = 1;
        matchData->playerData[1].portNumberOverride = cpu_port;
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
    EventDesc *event_desc = GetEventDesc(page, eventID);
    evFunction *evFunction = &stc_event_vars.evFunction;

    // clear evFunction
    memset(evFunction, 0, sizeof(*evFunction));

    // append extension
    static char *extension = "TM/%s.dat";
    char *buffer[20];
    sprintf(buffer, extension, event_desc->eventFile);

    // load this events file
    ArchiveInfo *archive = MEX_LoadRelArchive(buffer, evFunction, "evFunction");
    stc_event_vars.event_archive = archive;

    // Create this event's gobj
    int pri = event_desc->callbackPriority;
    void *cb = evFunction->Event_Think;
    GOBJ *gobj = GObj_Create(0, 7, 0);
    int *userdata = calloc(EVENT_DATASIZE);
    GObj_AddUserData(gobj, 4, HSD_Free, userdata);
    GObj_AddProc(gobj, cb, pri);

    // store pointer to the event's data
    userdata[0] = event_desc;

    // Create a gobj to track match time
    stc_event_vars.game_timer = 0;
    GOBJ *timer_gobj = GObj_Create(0, 7, 0);
    GObj_AddProc(timer_gobj, Event_IncTimer, 0);

    // init the pause menu
    GOBJ *menu_gobj = EventMenu_Init(event_desc, *evFunction->menu_start);

    // Init static structure containing event variables
    stc_event_vars.event_desc = event_desc;
    stc_event_vars.event_gobj = gobj;
    stc_event_vars.menu_gobj = menu_gobj;

    // init savestate struct
    stc_savestate = calloc(sizeof(Savestate));
    eventDataBackup = calloc(EVENT_DATASIZE);
    stc_savestate->is_exist = 0;
    stc_event_vars.savestate = stc_savestate;

    // disable hazards if enabled
    if (event_desc->disable_hazards == 1)
        Hazards_Disable();

    // Run this event's init function
    if (evFunction->Event_Init != 0)
    {
        evFunction->Event_Init(gobj);
    }

    // Store update function
    HSD_Update *update = HSD_UPDATE;
    update->onFrame = EventUpdate;

    return;
};

void EventUpdate()
{

    // get event info
    EventDesc *event_desc = stc_event_vars.event_desc;
    evFunction *evFunction = &stc_event_vars.evFunction;
    GOBJ *menu_gobj = stc_event_vars.menu_gobj;

    // run savestate logic if enabled
    if (event_desc->use_savestates == true)
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
    if (evFunction->Event_Update != 0)
    {
        evFunction->Event_Update();
    }
    else
        Develop_UpdateMatchHotkeys();

    return;
}

//////////////////////
/// Hook Functions ///
//////////////////////

void TM_ConsoleThink(GOBJ *gobj)
{
    // init variables
    int *data = gobj->userdata;
    DevText *text = data[0];

    // check to toggle console
    for (int i = 0; i < 4; i++)
    {
        HSD_Pad *pad = PadGet(i, PADGET_MASTER);
        if (pad->held & (HSD_TRIGGER_L | HSD_TRIGGER_R) && (pad->down & HSD_TRIGGER_Z))
        {
            // toggle visibility
            text->show_text ^= 1;
            text->show_background ^= 1;
            show_console ^= 1;

            break;
        }
    }

    // clear text
    //DevelopText_EraseAllText(text);
    //DevelopMode_ResetCursorXY(text, 0, 0);
}
void TM_CreateConsole()
{
    // init dev text
    GOBJ *gobj = GObj_Create(0, 0, 0);
    int *data = calloc(32);
    GObj_AddUserData(gobj, 4, HSD_Free, data);
    GObj_AddProc(gobj, TM_ConsoleThink, 0);

    DevText *text = DevelopText_CreateDataTable(13, 0, 0, 28, 8, HSD_MemAlloc(0x1000));
    DevelopText_Activate(0, text);
    text->show_cursor = 0;
    data[0] = text;
    GXColor color = {21, 20, 59, 135};
    DevelopText_StoreBGColor(text, &color);
    DevelopText_StoreTextScale(text, 10, 12);
    stc_event_vars.db_console_text = text;

    if (show_console != 1)
    {
        // toggle visibility
        DevelopText_HideBG(text);
        DevelopText_HideText(text);
    }

    return;
}

void OnFileLoad(ArchiveInfo *archive) // this function is run right after TmDt is loaded into memory on boot
{
    // init event menu assets
    stc_event_vars.menu_assets = File_GetSymbol(archive, "evMenu");

    // store pointer to static variables
    *event_vars_ptr = &stc_event_vars;
    event_vars = *event_vars_ptr;

    return;
}

void OnSceneChange()
{
    // Hook exists at 801a4c94

    TM_CreateWatermark();

#if TM_DEBUG == 2
    TM_CreateConsole();
#endif

    return;
};

void OnBoot()
{
    // OSReport("hi this is boot\n");
    return;
};

void OnStartMelee()
{

    Message_Init();
    Tip_Init();

    return;
}

///////////////////////////////
/// Miscellaneous Functions ///
///////////////////////////////

int Savestate_Save(Savestate *savestate)
{
    typedef struct BackupQueue
    {
        GOBJ *fighter;
        FighterData *fighter_data;
    } BackupQueue;

#if TM_DEBUG > 0
    int save_pre_tick = OSGetTick();
#endif

    // ensure no players are in problematic states
    int canSave = 1;
    GOBJ **gobj_list = R13_PTR(GOBJLIST);
    GOBJ *fighter = gobj_list[8];
    while (fighter != 0)
    {

        FighterData *fighter_data = fighter->userdata;

        if ((fighter_data->cb.OnDeath != 0) ||
            (fighter_data->cb.OnDeath2 != 0) ||
            (fighter_data->cb.OnDeath3 != 0) ||
            (fighter_data->heldItem != 0) ||
            (fighter_data->x1978 != 0) ||
            (fighter_data->accessory != 0) ||
            ((fighter_data->kind == 8) && ((fighter_data->state >= 342) && (fighter_data->state <= 344)))) // hardcode ness' usmash because it doesnt destroy the yoyo via onhit callback...
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

        savestate->is_exist = 1;

        // save frame
        savestate->frame = stc_event_vars.game_timer;

        // save event data
        memcpy(&savestate->event_data, stc_event_vars.event_gobj->userdata, sizeof(savestate->event_data));

        // backup all players
        for (int i = 0; i < 6; i++)
        {
            // get fighter gobjs
            BackupQueue queue[2];
            for (int j = 0; j < 2; j++)
            {
                GOBJ *fighter = 0;
                FighterData *fighter_data = 0;

                // get fighter gobj and data if they exist
                fighter = Fighter_GetSubcharGObj(i, j);
                if (fighter != 0)
                    fighter_data = fighter->userdata;

                // store fighter pointers
                queue[j].fighter = fighter;
                queue[j].fighter_data = fighter_data;
            }

            // if the main fighter exists
            if (queue[0].fighter != 0)
            {

                FtState *ft_state = &savestate->ft_state[i];

                isSaved = 1;

                // save playerblock
                Playerblock *playerblock = Fighter_GetPlayerblock(queue[0].fighter_data->ply);
                memcpy(&ft_state->player_block, playerblock, sizeof(Playerblock));

                // save stale moves
                int *stale_queue = Fighter_GetStaleMoveTable(queue[0].fighter_data->ply);
                memcpy(&ft_state->stale_queue, stale_queue, sizeof(ft_state->stale_queue));

                // backup each subfighters data
                for (int j = 0; j < 2; j++)
                {
                    // if exists
                    if (queue[j].fighter != 0)
                    {

                        FtStateData *ft_data = &ft_state->data[j];
                        FighterData *fighter_data = queue[j].fighter_data;

                        // backup to ft_state
                        ft_data->is_exist = 1;
                        ft_data->state = fighter_data->state;
                        ft_data->facing_direction = fighter_data->facing_direction;
                        ft_data->stateFrame = fighter_data->stateFrame;
                        ft_data->stateSpeed = fighter_data->stateSpeed;
                        ft_data->stateBlend = fighter_data->stateBlend;
                        memcpy(&ft_data->phys, &fighter_data->phys, sizeof(fighter_data->phys));                               // copy physics
                        memcpy(&ft_data->color, &fighter_data->color, sizeof(fighter_data->color));                            // copy color overlay
                        memcpy(&ft_data->input, &fighter_data->input, sizeof(fighter_data->input));                            // copy inputs
                        memcpy(&ft_data->coll_data, &fighter_data->coll_data, sizeof(fighter_data->coll_data));                // copy collision
                        memcpy(&ft_data->cameraBox, fighter_data->cameraBox, sizeof(CameraBox));                               // copy camerabox
                        memcpy(&ft_data->hitbox, &fighter_data->hitbox, sizeof(fighter_data->hitbox));                         // copy hitbox
                        memcpy(&ft_data->throw_hitbox, &fighter_data->throw_hitbox, sizeof(fighter_data->throw_hitbox));       // copy hitbox
                        memcpy(&ft_data->unk_hitbox, &fighter_data->unk_hitbox, sizeof(fighter_data->unk_hitbox));             // copy hitbox
                        memcpy(&ft_data->flags, &fighter_data->flags, sizeof(fighter_data->flags));                            // copy flags
                        memcpy(&ft_data->fighter_var, &fighter_data->fighter_var, sizeof(fighter_data->fighter_var));          // copy var
                        memcpy(&ft_data->state_var, &fighter_data->state_var, sizeof(fighter_data->state_var));                // copy var
                        memcpy(&ft_data->ftcmd_var, &fighter_data->ftcmd_var, sizeof(fighter_data->ftcmd_var));                // copy var
                        memcpy(&ft_data->jump, &fighter_data->jump, sizeof(fighter_data->jump));                               // copy var
                        memcpy(&ft_data->smash, &fighter_data->smash, sizeof(fighter_data->smash));                            // copy var
                        memcpy(&ft_data->hurtstatus, &fighter_data->hurtstatus, sizeof(fighter_data->hurtstatus));             // copy var
                        memcpy(&ft_data->shield, &fighter_data->shield, sizeof(fighter_data->shield));                         // copy hitbox
                        memcpy(&ft_data->shield_bubble, &fighter_data->shield_bubble, sizeof(fighter_data->shield_bubble));    // copy hitbox
                        memcpy(&ft_data->reflect_bubble, &fighter_data->reflect_bubble, sizeof(fighter_data->reflect_bubble)); // copy hitbox
                        memcpy(&ft_data->absorb_bubble, &fighter_data->absorb_bubble, sizeof(fighter_data->absorb_bubble));    // copy hitbox
                        memcpy(&ft_data->reflect_hit, &fighter_data->reflect_hit, sizeof(fighter_data->reflect_hit));          // copy hitbox
                        memcpy(&ft_data->absorb_hit, &fighter_data->absorb_hit, sizeof(fighter_data->absorb_hit));             // copy hitbox

                        // copy dmg
                        memcpy(&ft_data->dmg, &fighter_data->dmg, sizeof(fighter_data->dmg));
                        ft_data->dmg.source = GOBJToID(ft_data->dmg.source);

                        // copy grab
                        memcpy(&ft_data->grab, &fighter_data->grab, sizeof(fighter_data->grab));
                        ft_data->grab.grab_attacker = GOBJToID(ft_data->grab.grab_attacker);
                        ft_data->grab.grab_victim = GOBJToID(ft_data->grab.grab_victim);

                        // copy callbacks
                        memcpy(&ft_data->cb, &fighter_data->cb, sizeof(fighter_data->cb)); // copy hitbox

                        // convert hitbox pointers
                        for (int k = 0; k < (sizeof(fighter_data->hitbox) / sizeof(ftHit)); k++)
                        {

                            ft_data->hitbox[k].bone = BoneToID(fighter_data, ft_data->hitbox[k].bone);
                            for (int l = 0; l < (sizeof(fighter_data->hitbox->victims) / sizeof(HitVictim)); l++) // pointers to hitbox victims
                            {
                                ft_data->hitbox[k].victims[l].victim_data = FtDataToID(ft_data->hitbox[k].victims[l].victim_data);
                            }
                        }
                        for (int k = 0; k < (sizeof(fighter_data->throw_hitbox) / sizeof(ftHit)); k++)
                        {
                            ft_data->throw_hitbox[k].bone = BoneToID(fighter_data, ft_data->throw_hitbox[k].bone);
                            for (int l = 0; l < (sizeof(fighter_data->throw_hitbox->victims) / sizeof(HitVictim)); l++) // pointers to hitbox victims
                            {
                                ft_data->throw_hitbox[k].victims[l].victim_data = FtDataToID(ft_data->throw_hitbox[k].victims[l].victim_data);
                            }
                        }

                        ft_data->unk_hitbox.bone = BoneToID(fighter_data, ft_data->unk_hitbox.bone);
                        for (int k = 0; k < (sizeof(fighter_data->unk_hitbox.victims) / sizeof(HitVictim)); k++) // pointers to hitbox victims
                        {

                            ft_data->unk_hitbox.victims[k].victim_data = FtDataToID(ft_data->unk_hitbox.victims[k].victim_data);
                        }

                        // copy XRotN rotation
                        s8 XRotN_id = Fighter_BoneLookup(fighter_data, XRotN);
                        if (XRotN_id != -1)
                        {
                            ft_data->XRotN_rot = fighter_data->bones[XRotN_id].joint->rot;
                        }
                    }
                }
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

        // if not in frame advance, flash screen. I wrote it like this because the second condition kept getting optimized out
        if ((Pause_CheckStatus(0) != 1))
        {
            if ((Pause_CheckStatus(1) != 2))
            {
                ScreenFlash_Create(2, 0);
            }
        }
    }

#if TM_DEBUG > 0
    int save_post_tick = OSGetTick();
    int save_time = OSTicksToMilliseconds(save_post_tick - save_pre_tick);
    OSReport("processed save in %dms\n", save_time);
#endif

    return isSaved;
}
int Savestate_Load(Savestate *savestate)
{
    typedef struct BackupQueue
    {
        GOBJ *fighter;
        FighterData *fighter_data;
    } BackupQueue;

#if TM_DEBUG > 0
    int load_pre_tick = OSGetTick();
#endif

    // loop through all players
    int isLoaded = 0;
    for (int i = 0; i < 6; i++)
    {
        // get fighter gobjs
        BackupQueue queue[2];
        for (int j = 0; j < 2; j++)
        {
            GOBJ *fighter = 0;
            FighterData *fighter_data = 0;

            // get fighter gobj and data if they exist
            fighter = Fighter_GetSubcharGObj(i, j);
            if (fighter != 0)
                fighter_data = fighter->userdata;

            // store fighter pointers
            queue[j].fighter = fighter;
            queue[j].fighter_data = fighter_data;
        }

        // if the main fighter and backup exists
        if ((queue[0].fighter != 0) && (savestate->ft_state[i].data[0].is_exist == 1))
        {

            FtState *ft_state = &savestate->ft_state[i];

            isLoaded = 1;

            // restore playerblock
            Playerblock *playerblock = Fighter_GetPlayerblock(queue[0].fighter_data->ply);
            GOBJ *fighter_gobj[2];
            fighter_gobj[0] = playerblock->fighterData;
            fighter_gobj[1] = playerblock->fighterDataSub;
            memcpy(playerblock, &ft_state->player_block, sizeof(Playerblock));
            playerblock->fighterData = fighter_gobj[0];
            playerblock->fighterDataSub = fighter_gobj[1];

            // restore stale moves
            int *stale_queue = Fighter_GetStaleMoveTable(queue[0].fighter_data->ply);
            memcpy(stale_queue, &ft_state->stale_queue, sizeof(ft_state->stale_queue));

            // restore fighter data
            for (int j = 0; j < 2; j++)
            {

                GOBJ *fighter = queue[j].fighter;

                if (fighter != 0)
                {

                    // get state
                    FtStateData *ft_data = &ft_state->data[j];
                    FighterData *fighter_data = queue[j].fighter_data;

                    // sleep
                    Fighter_EnterSleep(fighter, 0);

                    fighter_data->state = ft_data->state;
                    fighter_data->facing_direction = ft_data->facing_direction;
                    fighter_data->stateFrame = ft_data->stateFrame;
                    fighter_data->stateSpeed = ft_data->stateSpeed;
                    fighter_data->stateBlend = ft_data->stateBlend;

                    // restore phys struct
                    memcpy(&fighter_data->phys, &ft_data->phys, sizeof(fighter_data->phys)); // copy physics

                    // restore inputs
                    memcpy(&fighter_data->input, &ft_data->input, sizeof(fighter_data->input)); // copy inputs

                    // restore coll data
                    CollData *thiscoll = &fighter_data->coll_data;
                    CollData *savedcoll = &ft_data->coll_data;
                    GOBJ *gobj = thiscoll->gobj;                                                            // 0x0
                    JOBJ *joint_1 = thiscoll->joint_1;                                                      // 0x108
                    JOBJ *joint_2 = thiscoll->joint_2;                                                      // 0x10c
                    JOBJ *joint_3 = thiscoll->joint_3;                                                      // 0x110
                    JOBJ *joint_4 = thiscoll->joint_4;                                                      // 0x114
                    JOBJ *joint_5 = thiscoll->joint_5;                                                      // 0x118
                    JOBJ *joint_6 = thiscoll->joint_6;                                                      // 0x11c
                    JOBJ *joint_7 = thiscoll->joint_7;                                                      // 0x120
                    memcpy(&fighter_data->coll_data, &ft_data->coll_data, sizeof(fighter_data->coll_data)); // copy collision
                    thiscoll->gobj = gobj;
                    thiscoll->joint_1 = joint_1;
                    thiscoll->joint_2 = joint_2;
                    thiscoll->joint_3 = joint_3;
                    thiscoll->joint_4 = joint_4;
                    thiscoll->joint_5 = joint_5;
                    thiscoll->joint_6 = joint_6;
                    thiscoll->joint_7 = joint_7;

                    // restore hitboxes
                    memcpy(&fighter_data->hitbox, &ft_data->hitbox, sizeof(fighter_data->hitbox));                   // copy hitbox
                    memcpy(&fighter_data->throw_hitbox, &ft_data->throw_hitbox, sizeof(fighter_data->throw_hitbox)); // copy hitbox
                    memcpy(&fighter_data->unk_hitbox, &ft_data->unk_hitbox, sizeof(fighter_data->unk_hitbox));       // copy hitbox

                    // copy grab
                    memcpy(&fighter_data->grab, &ft_data->grab, sizeof(fighter_data->grab));
                    fighter_data->grab.grab_attacker = IDToGOBJ(fighter_data->grab.grab_attacker);
                    fighter_data->grab.grab_victim = IDToGOBJ(fighter_data->grab.grab_victim);

                    // convert pointers
                    for (int k = 0; k < (sizeof(fighter_data->hitbox) / sizeof(ftHit)); k++)
                    {
                        fighter_data->hitbox[k].bone = IDToBone(fighter_data, ft_data->hitbox[k].bone);
                        for (int l = 0; l < (sizeof(fighter_data->hitbox->victims) / sizeof(HitVictim)); l++) // pointers to hitbox victims
                        {
                            fighter_data->hitbox[k].victims[l].victim_data = IDToFtData(ft_data->hitbox[k].victims[l].victim_data);
                        }
                    }
                    for (int k = 0; k < (sizeof(fighter_data->throw_hitbox) / sizeof(ftHit)); k++)
                    {
                        fighter_data->throw_hitbox[k].bone = IDToBone(fighter_data, ft_data->throw_hitbox[k].bone);
                        for (int l = 0; l < (sizeof(fighter_data->throw_hitbox->victims) / sizeof(HitVictim)); l++) // pointers to hitbox victims
                        {
                            fighter_data->throw_hitbox[k].victims[l].victim_data = IDToFtData(ft_data->throw_hitbox[k].victims[l].victim_data);
                        }
                    }
                    fighter_data->unk_hitbox.bone = IDToBone(fighter_data, ft_data->unk_hitbox.bone);
                    for (int k = 0; k < (sizeof(fighter_data->unk_hitbox.victims) / sizeof(HitVictim)); k++) // pointers to hitbox victims
                    {

                        fighter_data->unk_hitbox.victims[k].victim_data = IDToFtData(ft_data->unk_hitbox.victims[k].victim_data);
                    }

                    // restore fighter variables
                    memcpy(&fighter_data->fighter_var, &ft_data->fighter_var, sizeof(fighter_data->fighter_var)); // copy hitbox

                    // zero pointer to cached animations to force anim load (fixes fall crash)
                    fighter_data->anim_curr_ARAM = 0;
                    fighter_data->anim_persist_ARAM = 0;

                    // enter backed up state
                    GOBJ *anim_source = 0;
                    if (fighter_data->flags.is_thrown == 1)
                        anim_source = fighter_data->grab.grab_attacker;
                    Fighter_SetAllHurtboxesNotUpdated(fighter);
                    ActionStateChange(ft_data->stateFrame, ft_data->stateSpeed, -1, fighter, ft_data->state, 0, anim_source);
                    fighter_data->stateBlend = 0;

                    // restore XRotN rotation
                    s8 XRotN_id = Fighter_BoneLookup(fighter_data, XRotN);
                    if (XRotN_id != -1)
                    {
                        fighter_data->bones[XRotN_id].joint->rot = ft_data->XRotN_rot;
                    }

                    // restore state variables
                    memcpy(&fighter_data->state_var, &ft_data->state_var, sizeof(fighter_data->state_var)); // copy hitbox

                    // restore ftcmd variables
                    memcpy(&fighter_data->ftcmd_var, &ft_data->ftcmd_var, sizeof(fighter_data->ftcmd_var)); // copy hitbox

                    // restore damage variables
                    memcpy(&fighter_data->dmg, &ft_data->dmg, sizeof(fighter_data->dmg)); // copy hitbox
                    fighter_data->dmg.source = IDToGOBJ(fighter_data->dmg.source);

                    // restore jump variables
                    memcpy(&fighter_data->jump, &ft_data->jump, sizeof(fighter_data->jump)); // copy hitbox

                    // restore flags
                    memcpy(&fighter_data->flags, &ft_data->flags, sizeof(fighter_data->flags)); // copy hitbox

                    // restore hurtstatus variables
                    memcpy(&fighter_data->hurtstatus, &ft_data->hurtstatus, sizeof(fighter_data->hurtstatus)); // copy hitbox

                    // update jobj position
                    JOBJ *fighter_jobj = fighter->hsd_object;
                    fighter_jobj->trans = fighter_data->phys.pos;
                    // dirtysub their jobj
                    JOBJ_SetMtxDirtySub(fighter_jobj);

                    // update hurtbox position
                    Fighter_UpdateHurtboxes(fighter_data);

                    // remove color overlay
                    Fighter_ColorRemove(fighter_data, 9);

                    // restore color
                    for (int k = 0; k < (sizeof(fighter_data->color) / sizeof(ColorOverlay)); k++)
                    {

                        ColorOverlay *thiscolor = &fighter_data->color[k];
                        ColorOverlay *savedcolor = &ft_data->color[k];

                        // backup nono pointers
                        int *ptr1 = thiscolor->ptr1;
                        int *ptr2 = thiscolor->ptr2;
                        int *alloc = thiscolor->alloc;

                        // mempcy entire
                        memcpy(thiscolor, savedcolor, sizeof(ColorOverlay));

                        // restore nono pointers
                        thiscolor->ptr1 = ptr1;
                        thiscolor->ptr2 = ptr2;
                        thiscolor->alloc = alloc;
                    }

                    // restore smash variables
                    memcpy(&fighter_data->smash, &ft_data->smash, sizeof(fighter_data->smash)); // copy hitbox

                    // restore shield/reflect/absorb variables
                    memcpy(&fighter_data->shield, &ft_data->shield, sizeof(fighter_data->shield));                         // copy hitbox
                    memcpy(&fighter_data->shield_bubble, &ft_data->shield_bubble, sizeof(fighter_data->shield_bubble));    // copy hitbox
                    memcpy(&fighter_data->reflect_bubble, &ft_data->reflect_bubble, sizeof(fighter_data->reflect_bubble)); // copy hitbox
                    memcpy(&fighter_data->absorb_bubble, &ft_data->absorb_bubble, sizeof(fighter_data->absorb_bubble));    // copy hitbox
                    memcpy(&fighter_data->reflect_hit, &ft_data->reflect_hit, sizeof(fighter_data->reflect_hit));          // copy hitbox
                    memcpy(&fighter_data->absorb_hit, &ft_data->absorb_hit, sizeof(fighter_data->absorb_hit));             // copy hitbox

                    // restore callback functions
                    memcpy(&fighter_data->cb, &ft_data->cb, sizeof(fighter_data->cb)); // copy hitbox

                    // stop player SFX
                    SFX_StopAllFighterSFX(fighter_data);

                    // update colltest frame
                    fighter_data->coll_data.coll_test = *stc_colltest;

                    // restore camera box
                    CameraBox *thiscam = fighter_data->cameraBox;
                    CameraBox *savedcam = &ft_data->cameraBox;
                    void *alloc = thiscam->alloc;
                    CameraBox *next = thiscam->next;
                    memcpy(thiscam, savedcam, sizeof(CameraBox)); // copy camerabox
                    thiscam->alloc = alloc;
                    thiscam->next = next;

                    // update their IK
                    Fighter_UpdateIK(fighter);

                    // if shield is up, update shield
                    if ((fighter_data->state >= ASID_GUARDON) && (fighter_data->state <= ASID_GUARDREFLECT))
                    {
                        // get gfx ID
                        int shieldGFX;
                        static u16 ShieldGFXLookup[] = {1047, 1048, -1, 1049, -1}; // covers GUARDON -> GUARDREFLECT
                        shieldGFX = ShieldGFXLookup[fighter_data->state - ASID_GUARDON];

                        // create GFX
                        int color_index = Fighter_GetShieldColorIndex(fighter_data->ply);
                        GXColor *shieldColors = R13_PTR(-0x5194);
                        GXColor *shieldColor = &shieldColors[color_index];
                        JOBJ *shieldBone = fighter_data->bones[fighter_data->ftData->modelLookup[0x11]].joint;
                        int shieldColorParam = (shieldColor->r << 16) | (shieldColor->b << 8) | (shieldColor->g);
                        Effect_SpawnSync(shieldGFX, fighter, shieldBone, shieldColorParam);

                        Fighter_UpdateShieldGFX(fighter, 1);
                    }

                    // process dynamics

#if TM_DEBUG > 0
                    int dyn_pre_tick = OSGetTick();
#endif
                    int dyn_proc_num = 45;

                    // simulate dynamics a bunch to fall in place
                    for (int d = 0; d < dyn_proc_num; d++)
                    {
                        Fighter_ProcDynamics(fighter);
                    }

#if TM_DEBUG > 0
                    int dyn_post_tick = OSGetTick();
                    int dyn_time = OSTicksToMilliseconds(dyn_post_tick - dyn_pre_tick);
                    OSReport("processed dyn %d times in %dms\n", dyn_proc_num, dyn_time);
#endif

                    // remove all items belonging to this fighter
                    GOBJList *gobj_list = *stc_gobj_list;
                    GOBJ *item = gobj_list->item;
                    while (item != 0)
                    {

                        // get next
                        GOBJ *next_item = item->next;

                        // check to delete
                        ItemData *item_data = item->userdata;
                        if (fighter == item_data->fighter)
                        {
                            // destroy it
                            Item_Destroy(item);
                        }

                        item = next_item;
                    }
                }
            }

            sizeof(FtStateData);

            // check to recreate HUD
            MatchHUD *hud = &stc_matchhud[i];

            // check if fighter is perm dead
            if (Match_CheckIfStock() == 1)
            {
                // remove HUD if no stocks left
                if (Fighter_GetStocks(i) <= 0)
                {
                    hud->is_removed = 0;
                }
            }

            // check to create it
            if (hud->is_removed == 1)
            {
                Match_CreateHUD(i);
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

        // restore frame
        Match *match = stc_match;
        match->time_frames = savestate->frame;
        stc_event_vars.game_timer = savestate->frame;

        // update timer
        int frames = match->time_frames - 1; // this is because the scenethink function runs once before the gobj procs do
        match->time_seconds = frames / 60;
        match->time_ms = frames % 60;

        // restore event data
        memcpy(stc_event_vars.event_gobj->userdata, &savestate->event_data, sizeof(savestate->event_data));

        // remove all particles
        for (int i = 0; i < PTCL_LINKMAX; i++)
        {
            Particle2 **ptcls = &stc_ptcl[i];
            Particle2 *ptcl = *ptcls;
            while (ptcl != 0)
            {

                Particle2 *ptcl_next = ptcl->next;

                // begin destroying this particle

                // subtract some value, 8039c9f0
                if (ptcl->x88 != 0)
                {
                    int *arr = ptcl->x88;
                    arr[0x50 / 4]--;
                }
                // remove from generator? 8039ca14
                if (ptcl->gen != 0)
                    psRemoveParticleAppSRT(ptcl);

                // delete parent jobj, 8039ca48
                psDeletePntJObjwithParticle(ptcl);

                // update most recent ptcl pointer
                *ptcls = ptcl->next;

                // free alloc, 8039ca54
                HSD_ObjFree(0x804d0f60, ptcl);

                // decrement ptcl total
                u16 ptclnum = *stc_ptclnum;
                ptclnum--;
                *stc_ptclnum = ptclnum;

                // get next
                ptcl = ptcl_next;
            }
        }

        /*
    // remove all generators with linkNo 2 (blastzone)
    ptclGen *gen = *stc_ptclgen;
    while (gen != 0)
    {
        // get next
        ptclGen *gen_next = gen->next;

        // if linkNo 2, destroy it
        if (gen->link_no == 2)
        {
            // set a flag for some reason
            gen->type |= 0x80;

            // kill gen
            gen = psKillGenerator(gen, *stc_ptclgencurr);
        }

        // save last
        *stc_ptclgencurr = gen;
        // get next
        gen = gen_next;
    }
*/

        // remove all camera shake gobjs (p_link 18, entity_class 3)
        GOBJList *gobj_list = *stc_gobj_list;
        GOBJ *gobj = gobj_list->match_cam;
        while (gobj != 0)
        {

            GOBJ *gobj_next = gobj->next;

            // if entity class 3 (quake)
            if (gobj->entity_class == 3)
            {
                GObj_Destroy(gobj);
            }

            gobj = gobj_next;
        }

        // play sfx
        SFX_PlayCommon(0);
    }

#if TM_DEBUG > 0
    int load_post_tick = OSGetTick();
    int load_time = OSTicksToMilliseconds(load_post_tick - load_pre_tick);
    OSReport("processed load in %dms\n", load_time);
    sizeof(FtState);
#endif

    return isLoaded;
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
                    Savestate_Save(stc_savestate);
                }
                else if (((pad->down & HSD_BUTTON_DPAD_LEFT) != 0) && ((pad->held & (blacklist)) == 0))
                {
                    // load state
                    Savestate_Load(stc_savestate);
                }
            }
        }
    }

    return;
}
int GOBJToID(GOBJ *gobj)
{
    // ensure valid pointer
    if (gobj == 0)
        return -1;

    // ensure its a fighter
    if (gobj->entity_class != 4)
        return -1;

    // access the data
    FighterData *ft_data = gobj->userdata;
    u8 ply = ft_data->ply;
    u8 ms = ft_data->flags.ms;

    return ((ply << 4) | ms);
}
int FtDataToID(FighterData *fighter_data)
{
    // ensure valid pointer
    if (fighter_data == 0)
        return -1;

    // ensure its a fighter
    if (fighter_data->fighter == 0)
        return -1;

    // get ply and ms
    u8 ply = fighter_data->ply;
    u8 ms = fighter_data->flags.ms;

    return ((ply << 4) | ms);
}
int BoneToID(FighterData *fighter_data, JOBJ *bone)
{

    // ensure bone exists
    if (bone == 0)
        return -1;

    int bone_id = -1;

    // painstakingly look for a match
    for (int i = 0; i < fighter_data->bone_num; i++)
    {
        if (bone == fighter_data->bones[i].joint)
        {
            bone_id = i;
            break;
        }
    }

#if TM_DEBUG > 0
    // no bone found
    if (bone_id == -1)
    {
        assert("no bone found");
    }
#endif

    return bone_id;
}
GOBJ *IDToGOBJ(int id)
{
    // ensure valid pointer
    if (id == -1)
        return 0;

    // get ply and ms
    u8 ply = (id >> 4) & 0xF;
    u8 ms = id & 0xF;

    // get the gobj for this fighter
    GOBJ *gobj = Fighter_GetSubcharGObj(ply, ms);

    return gobj;
}
FighterData *IDToFtData(int id)
{
    // ensure valid pointer
    if (id == -1)
        return 0;

    // get ply and ms
    u8 ply = (id >> 4) & 0xF;
    u8 ms = id & 0xF;

    // get the gobj for this fighter
    GOBJ *gobj = Fighter_GetSubcharGObj(ply, ms);
    FighterData *fighter_data = gobj->userdata;

    return fighter_data;
}
JOBJ *IDToBone(FighterData *fighter_data, int id)
{
    // ensure valid pointer
    if (id == -1)
        return 0;

    // get the bone
    JOBJ *bone = fighter_data->bones[id].joint;

    return bone;
}

void Event_IncTimer(GOBJ *gobj)
{
    stc_event_vars.game_timer++;
    return;
}
void TM_CreateWatermark()
{
    // create text canvas
    int canvas = Text_CreateCanvas(10, 0, 9, 13, 0, 14, 0, 19);

    // create text
    Text *text = Text_CreateText(10, canvas);
    // enable align and kerning
    text->align = 2;
    text->kerning = 1;
    // scale canvas
    text->scale.X = 0.4;
    text->scale.Y = 0.4;
    text->trans.X = 615;
    text->trans.Y = 446;

    // print string
    int shadow = Text_AddSubtext(text, 2, 2, TM_VersShort);
    GXColor shadow_color = {0, 0, 0, 0};
    Text_SetColor(text, shadow, &shadow_color);

    int shadow1 = Text_AddSubtext(text, 2, -2, TM_VersShort);
    Text_SetColor(text, shadow1, &shadow_color);

    int shadow2 = Text_AddSubtext(text, -2, 2, TM_VersShort);
    Text_SetColor(text, shadow2, &shadow_color);

    int shadow3 = Text_AddSubtext(text, -2, -2, TM_VersShort);
    Text_SetColor(text, shadow3, &shadow_color);

    Text_AddSubtext(text, 0, 0, TM_VersShort);

    return;
}
void Hazards_Disable()
{
    // get stage id
    int stage_internal = Stage_ExternalToInternal(Stage_GetExternalID());
    int is_fixwind = 0;

    switch (stage_internal)
    {
    case (GR_STORY):
    {
        // remove shyguy map gobj proc
        GOBJ *shyguy_gobj = Stage_GetMapGObj(3);
        GObj_RemoveProc(shyguy_gobj);

        // remove randall
        GOBJ *randall_gobj = Stage_GetMapGObj(2);
        Stage_DestroyMapGObj(randall_gobj);

        is_fixwind = 1;

        break;
    }
    case (GR_PSTAD):
    {
        // remove map gobj proc
        GOBJ *map_gobj = Stage_GetMapGObj(2);
        GObj_RemoveProc(map_gobj);

        is_fixwind = 1;

        break;
    }
    case (GR_OLDPU):
    {
        // remove map gobj proc
        GOBJ *map_gobj = Stage_GetMapGObj(7);
        GObj_RemoveProc(map_gobj);

        // remove map gobj proc
        map_gobj = Stage_GetMapGObj(6);
        GObj_RemoveProc(map_gobj);

        // set wind hazard num to 0
        *ftchkdevice_windnum = 0;

        break;
    }
    case (GR_FD):
    {
        // set bg skip flag
        GOBJ *map_gobj = Stage_GetMapGObj(3);
        map_gobjData *map_data = map_gobj->userdata;
        map_data->xc4 |= 0x40;

        // remove on-go function that changes this flag
        StageOnGO *on_go = stc_stage->on_go;
        stc_stage->on_go = on_go->next;
        HSD_Free(on_go);

        break;
    }
    }

    // Certain stages have an essential ragdoll function
    // in their map_gobj think function. If the think function is removed,
    // the ragdoll function must be re-scheduled to function properly.
    if (is_fixwind == 1)
    {
        GOBJ *wind_gobj = GObj_Create(3, 5, 0);
        GObj_AddProc(wind_gobj, Dynamics_DecayWind, 4);
    }
}

// Message Functions
void Message_Init()
{

    // create cobj
    GOBJ *cam_gobj = GObj_Create(19, 20, 0);
    COBJDesc *cam_desc = stc_event_vars.menu_assets->hud_cobjdesc;
    COBJ *cam_cobj = COBJ_LoadDescSetScissor(cam_desc);
    cam_cobj->scissor_bottom = 400;
    // init camera
    GObj_AddObject(cam_gobj, R13_U8(-0x3E55), cam_cobj); //R13_U8(-0x3E55)
    GOBJ_InitCamera(cam_gobj, Message_CObjThink, MSG_COBJLGXPRI);
    cam_gobj->cobj_links = MSG_COBJLGXLINKS;

    // Create manager GOBJ
    GOBJ *mgr_gobj = GObj_Create(0, 7, 0);
    MsgMngrData *mgr_data = calloc(sizeof(MsgMngrData));
    GObj_AddUserData(mgr_gobj, 4, HSD_Free, mgr_data);
    GObj_AddProc(mgr_gobj, Message_Manager, 18);

    // create text canvas
    int canvas = Text_CreateCanvas(2, mgr_gobj, 14, 15, 0, MSG_GXLINK, MSGTEXT_GXPRI, 19);
    mgr_data->canvas = canvas;

    // store cobj
    mgr_data->cobj = cam_cobj;

    // store gobj pointer
    stc_msgmgr = mgr_gobj;

    return;
}
GOBJ *Message_Display(int msg_kind, int queue_num, int msg_color, char *format, ...)
{

    va_list args;

    MsgMngrData *mgr_data = stc_msgmgr->userdata;

    // Create GOBJ
    GOBJ *msg_gobj = GObj_Create(0, 7, 0);
    MsgData *msg_data = calloc(sizeof(MsgData));
    GObj_AddUserData(msg_gobj, 4, HSD_Free, msg_data);
    GObj_AddGXLink(msg_gobj, GXLink_Common, MSG_GXLINK, MSG_GXPRI);
    JOBJ *msg_jobj = JOBJ_LoadJoint(stc_event_vars.menu_assets->message);
    GObj_AddObject(msg_gobj, R13_U8(-0x3E55), msg_jobj);
    msg_data->lifetime = MSG_LIFETIME;
    msg_data->kind = msg_kind;
    msg_data->state = MSGSTATE_SHIFT;
    msg_data->anim_timer = MSGTIMER_SHIFT;
    msg_jobj->scale.X = MSGJOINT_SCALE;
    msg_jobj->scale.Y = MSGJOINT_SCALE;
    msg_jobj->scale.Z = MSGJOINT_SCALE;
    msg_jobj->trans.X = MSGJOINT_X;
    msg_jobj->trans.Y = MSGJOINT_Y;
    msg_jobj->trans.Z = MSGJOINT_Z;

    // Create text object
    Text *msg_text = Text_CreateText(2, mgr_data->canvas);
    msg_data->text = msg_text;
    msg_text->kerning = 1;
    msg_text->align = 1;
    msg_text->use_aspect = 1;
    msg_text->color = stc_msg_colors[msg_color];

    // adjust scale
    Vec3 scale = msg_jobj->scale;
    // background scale
    msg_jobj->scale = scale;
    // text scale
    msg_text->scale.X = (scale.X * 0.01) * MSGTEXT_BASESCALE;
    msg_text->scale.Y = (scale.Y * 0.01) * MSGTEXT_BASESCALE;
    msg_text->aspect.X = MSGTEXT_BASEWIDTH;

    JOBJ_SetMtxDirtySub(msg_jobj);

    // build string
    char buffer[(MSG_LINEMAX * MSG_CHARMAX) + 1];
    va_start(args, format);
    vsprintf(buffer, format, args);
    va_end(args);
    char *msg = &buffer;

    // count newlines
    int line_num = 1;
    int line_length_arr[MSG_LINEMAX];
    char *msg_cursor_prev, *msg_cursor_curr; // declare char pointers
    msg_cursor_prev = msg;
    msg_cursor_curr = strchr(msg_cursor_prev, '\n'); // check for occurrence
    while (msg_cursor_curr != 0)                     // if occurrence found, increment values
    {
        // check if exceeds max lines
        if (line_num >= MSG_LINEMAX)
            assert("MSG_LINEMAX exceeded!");

        // Save information about this line
        line_length_arr[line_num - 1] = msg_cursor_curr - msg_cursor_prev; // determine length of the line
        line_num++;                                                        // increment number of newlines found
        msg_cursor_prev = msg_cursor_curr + 1;                             // update prev cursor
        msg_cursor_curr = strchr(msg_cursor_prev, '\n');                   // check for another occurrence
    }

    // get last lines length
    msg_cursor_curr = strchr(msg_cursor_prev, 0);
    line_length_arr[line_num - 1] = msg_cursor_curr - msg_cursor_prev;

    // copy each line to an individual char array
    char *msg_cursor = &msg;
    for (int i = 0; i < line_num; i++)
    {

        // check if over char max
        u8 line_length = line_length_arr[i];
        if (line_length > MSG_CHARMAX)
            assert("MSG_CHARMAX exceeded!");

        // copy char array
        char msg_line[MSG_CHARMAX + 1];
        memcpy(msg_line, msg, line_length);

        // add null terminator
        msg_line[line_length] = '\0';

        // increment msg
        msg += (line_length + 1); // +1 to skip past newline

        // print line
        int y_base = (line_num - 1) * ((-1 * MSGTEXT_YOFFSET) / 2);
        int y_delta = (i * MSGTEXT_YOFFSET);
        Text_AddSubtext(msg_text, 0, y_base + y_delta, msg_line);
    }

    // Add to queue
    Message_Add(msg_gobj, queue_num);

    return msg_gobj;
}
void Message_Manager(GOBJ *mngr_gobj)
{
    MsgMngrData *mgr_data = mngr_gobj->userdata;

    // Iterate through each queue
    for (int i = 0; i < MSGQUEUE_NUM; i++)
    {
        GOBJ **msg_queue = &mgr_data->msg_queue[i];

        // anim update (time based logic)
        for (int j = (MSGQUEUE_SIZE - 2); j >= 0; j--) // iterate through backwards (because deletions)
        {
            GOBJ *this_msg_gobj = msg_queue[j];

            // if message exists
            if (this_msg_gobj != 0)
            {
                MsgData *this_msg_data = this_msg_gobj->userdata;
                Text *this_msg_text = this_msg_data->text;
                JOBJ *this_msg_jobj = this_msg_gobj->hsd_object;

                // check if the message moved this frame
                if (this_msg_data->orig_index != j)
                {
                    this_msg_data->orig_index = j;              // moved so update this
                    this_msg_data->state = MSGSTATE_SHIFT;      // enter shift
                    this_msg_data->anim_timer = MSGTIMER_SHIFT; // shift timer
                }

                // decrement state timer if above 0
                if (this_msg_data->anim_timer > 0)
                    this_msg_data->anim_timer--;

                switch (this_msg_data->state)
                {
                case (MSGSTATE_WAIT):
                case (MSGSTATE_SHIFT):
                {

                    // increment alive time
                    this_msg_data->alive_timer++;

                    // if lifetime is ended, enter delete state
                    if (this_msg_data->alive_timer >= this_msg_data->lifetime)
                    {
                        // if using frame advance, instantly remove this message
                        if (Pause_CheckStatus(0) == 1)
                        {
                            Message_Destroy(msg_queue, j);
                        }
                        else
                        {
                            this_msg_data->state = MSGSTATE_DELETE;
                            this_msg_data->anim_timer = MSGTIMER_DELETE;
                        }
                    }

                    break;
                }

                case (MSGSTATE_DELETE):
                {

                    // if timer is ended, remove the message
                    if ((this_msg_data->anim_timer <= 0))
                    {
                        Message_Destroy(msg_queue, j);
                    }

                    break;
                }
                }
            }
        }

        // position update (update messages' onscreen positions)
        for (int j = 0; j < MSGQUEUE_SIZE; j++)
        {
            GOBJ *this_msg_gobj = msg_queue[j];

            // if message exists
            if (this_msg_gobj != 0)
            {
                MsgData *this_msg_data = this_msg_gobj->userdata;
                Text *this_msg_text = this_msg_data->text;
                JOBJ *this_msg_jobj = this_msg_gobj->hsd_object;

                // Get the onscreen position for this queue
                Vec3 base_pos;
                Vec3 this_msg_pos;
                float pos_delta = stc_msg_queue_offsets[i];
                if (i < 6)
                {
                    Vec3 *hud_pos = Match_GetPlayerHUDPos(i);

                    base_pos.X = hud_pos->X;
                    base_pos.Y = hud_pos->Y + MSG_HUDYOFFSET;
                    base_pos.Z = hud_pos->Z;
                }
                else if (i == MSGQUEUE_GENERAL)
                {
                    base_pos = stc_msg_queue_general_pos;
                }
                this_msg_pos.X = base_pos.X; // Get this messages position

                switch (this_msg_data->state)
                {
                case (MSGSTATE_WAIT):
                case (MSGSTATE_SHIFT):
                {

                    // get time
                    float t = (((float)MSGTIMER_SHIFT - this_msg_data->anim_timer) / MSGTIMER_SHIFT);

                    // get initial and final position for animation
                    float final_pos = base_pos.Y + ((float)j * pos_delta);
                    float initial_pos = base_pos.Y + ((float)this_msg_data->prev_index * pos_delta);
                    if (Pause_CheckStatus(0) == 1) // if using frame advance, do not animate
                    {
                        this_msg_pos.Y = final_pos;
                    }
                    else
                    {
                        this_msg_pos.Y = (BezierBlend(t) * (final_pos - initial_pos)) + initial_pos;
                    }

                    Vec3 scale = this_msg_jobj->scale;

                    // BG position
                    this_msg_jobj->trans.X = this_msg_pos.X;
                    this_msg_jobj->trans.Y = this_msg_pos.Y;
                    // text position
                    this_msg_text->trans.X = this_msg_pos.X + (MSGTEXT_BASEX * (scale.X / 4.0));
                    this_msg_text->trans.Y = (this_msg_pos.Y * -1) + (MSGTEXT_BASEY * (scale.Y / 4.0));

                    // adjust bar
                    JOBJ *bar;
                    JOBJ_GetChild(this_msg_jobj, &bar, 4, -1);
                    bar->trans.X = (float)(this_msg_data->lifetime - this_msg_data->alive_timer) / (float)this_msg_data->lifetime;

                    break;
                }
                case (MSGSTATE_DELETE):
                {
                    // get time
                    float t = ((this_msg_data->anim_timer) / (float)MSGTIMER_DELETE);

                    Vec3 *scale = &this_msg_jobj->scale;
                    Vec3 *pos = &this_msg_jobj->trans;

                    // BG scale
                    scale->Y = BezierBlend(t);
                    // text scale
                    this_msg_text->scale.Y = (scale->Y * 0.01) * MSGTEXT_BASESCALE;
                    // text position
                    this_msg_text->trans.Y = (pos->Y * -1) + (MSGTEXT_BASEY * (scale->Y / 4.0));

                    break;
                }
                }

                JOBJ_SetMtxDirtySub(this_msg_jobj);
            }
        }
    }
}
void Message_Destroy(GOBJ **msg_queue, int msg_num)
{

    GOBJ *msg_gobj = msg_queue[msg_num];
    MsgData *msg_data = msg_gobj->userdata;

    // Destroy text
    Text *text = msg_data->text;
    if (text != 0)
        Text_Destroy(text);

    // Destroy GOBJ
    GObj_Destroy(msg_gobj);

    // null pointer
    msg_queue[msg_num] = 0;

    // shift others
    for (int i = (msg_num); i < (MSGQUEUE_SIZE - 1); i++)
    {
        msg_queue[i] = msg_queue[i + 1];

        // update its prev pos
        GOBJ *this_msg_gobj = msg_queue[i];
        if (this_msg_gobj != 0)
        {
            MsgData *this_msg_data = this_msg_gobj->userdata;
            this_msg_data->prev_index = i + 1; // prev position
        }
    }

    return;
}
void Message_Add(GOBJ *msg_gobj, int queue_num)
{

    MsgData *msg_data = msg_gobj->userdata;
    MsgMngrData *mgr_data = stc_msgmgr->userdata;
    GOBJ **msg_queue = &mgr_data->msg_queue[queue_num];

    // ensure this queue exists
    if (queue_num >= MSGQUEUE_NUM)
        assert("queue_num over!");

    // remove any existing messages of this kind
    for (int i = 0; i < MSGQUEUE_SIZE; i++)
    {
        GOBJ *this_msg_gobj = msg_queue[i];

        // if it exists
        if (this_msg_gobj != 0)
        {
            MsgData *this_msg_data = this_msg_gobj->userdata;

            // Remove this message if its of the same kind
            if ((this_msg_data->kind == msg_data->kind))
            {

                Message_Destroy(msg_queue, i); // remove the message and shift others

                // if the message we're replacing is the most recent message, instantly
                // remove the old one and do not animate the new one
                if (i == 0)
                {
                    msg_data->state = MSGSTATE_WAIT;
                    msg_data->anim_timer = 0;
                }
            }
        }
    }

    // first remove last message in the queue
    if (msg_queue[MSGQUEUE_SIZE - 1] != 0)
    {
        Message_Destroy(msg_queue, MSGQUEUE_SIZE - 1);
    }

    // shift other messages
    for (int i = (MSGQUEUE_SIZE - 2); i >= 0; i--)
    {
        // shift message
        msg_queue[i + 1] = msg_queue[i];

        // update its prev pos
        GOBJ *this_msg_gobj = msg_queue[i + 1];
        if (this_msg_gobj != 0)
        {
            MsgData *this_msg_data = this_msg_gobj->userdata;
            this_msg_data->prev_index = i; // prev position
        }
    }

    // add this new message
    msg_queue[0] = msg_gobj;

    // set prev pos to -1 (slides in)
    msg_data->prev_index = -1;
    msg_data->orig_index = 0;

    return;
}
void Message_CObjThink(GOBJ *gobj)
{

    if (Pause_CheckStatus(1) != 2)
        CObjThink_Common(gobj);

    return;
}

float BezierBlend(float t)
{
    return t * t * (3.0f - 2.0f * t);
}

// Tips Functions
void Tip_Init()
{
    // init static struct
    memset(&stc_tipmgr, 0, sizeof(TipMgr));

    // create tipmgr gobj
    GOBJ *tipmgr_gobj = GObj_Create(0, 7, 0);
    GObj_AddProc(tipmgr_gobj, Tip_Think, 18);

    return;
}
void Tip_Think(GOBJ *gobj)
{

    GOBJ *tip_gobj = stc_tipmgr.gobj;

    stc_event_vars.menu_assets->tip_jobj;

    // update tip
    if (tip_gobj != 0)
    {

        // update anim
        JOBJ_AnimAll(tip_gobj->hsd_object);

        // update text position
        JOBJ *tip_jobj;
        Vec3 tip_pos;
        JOBJ_GetChild(tip_gobj->hsd_object, &tip_jobj, TIP_TXTJOINT, -1);
        JOBJ_GetWorldPosition(tip_jobj, 0, &tip_pos);
        Text *tip_text = stc_tipmgr.text;
        tip_text->trans.X = tip_pos.X + (0 * (tip_jobj->scale.X / 4.0));
        tip_text->trans.Y = (tip_pos.Y * -1) + (0 * (tip_jobj->scale.Y / 4.0));

        // state logic
        switch (stc_tipmgr.state)
        {
        case (0): // in
        {
            // if anim is done, enter wait
            if (JOBJ_CheckAObjEnd(tip_gobj->hsd_object) == 0)
                stc_tipmgr.state = 1; // enter wait

            break;
        }
        case (1): // wait
        {
            // sub timer
            stc_tipmgr.lifetime--;
            if (stc_tipmgr.lifetime <= 0)
            {
                // apply exit anim
                JOBJ *tip_root = tip_gobj->hsd_object;
                JOBJ_RemoveAnimAll(tip_root);
                JOBJ_AddAnimAll(tip_root, stc_event_vars.menu_assets->tip_jointanim[1], 0, 0);
                JOBJ_ReqAnimAll(tip_root, 0);

                stc_tipmgr.state = 2; // enter wait
            }

            break;
        }
        case (2): // out
        {
            // if anim is done, destroy
            if (JOBJ_CheckAObjEnd(tip_gobj->hsd_object) == 0)
            {
                // remove text
                Text_Destroy(stc_tipmgr.text);
                GObj_Destroy(stc_tipmgr.gobj);
                stc_tipmgr.gobj = 0;
            }
            break;
        }
        }
    }

    return;
}
int Tip_Display(int lifetime, char *fmt, ...)
{

#define TIP_TXTSIZE 4.7
#define TIP_TXTSIZEX TIP_TXTSIZE * 0.85
#define TIP_TXTSIZEY TIP_TXTSIZE
#define TIP_TXTASPECT 2430
#define TIP_LINEMAX 5
#define TIP_CHARMAX 48

    va_list args;

    // if tip exists
    if (stc_tipmgr.gobj != 0)
    {
        // if tip is in the process of exiting
        if (stc_tipmgr.state == 2)
        {
            // remove text
            Text_Destroy(stc_tipmgr.text);
            GObj_Destroy(stc_tipmgr.gobj);
            stc_tipmgr.gobj = 0;
        }
        // if is active onscreen do nothing
        else
            return 0;
    }

    MsgMngrData *msgmngr_data = stc_msgmgr->userdata; // using message canvas cause there are so many god damn text canvases

    // Create bg
    GOBJ *tip_gobj = GObj_Create(0, 0, 0);
    stc_tipmgr.gobj = tip_gobj;
    GObj_AddGXLink(tip_gobj, GXLink_Common, MSG_GXLINK, 80);
    JOBJ *tip_jobj = JOBJ_LoadJoint(stc_event_vars.menu_assets->tip_jobj);
    GObj_AddObject(tip_gobj, R13_U8(-0x3E55), tip_jobj);

    // account for widescreen
    /*
    float aspect = (msgmngr_data->cobj->projection_param.perspective.aspect / 1.216667) - 1;
    tip_jobj->trans.X += (tip_jobj->trans.X * aspect);
    JOBJ_SetMtxDirtySub(tip_jobj);
    */

    // Create text object
    Text *tip_text = Text_CreateText(2, msgmngr_data->canvas);
    stc_tipmgr.text = tip_text;
    stc_tipmgr.lifetime = lifetime;
    stc_tipmgr.state = 0;
    tip_text->kerning = 1;
    tip_text->align = 0;
    tip_text->use_aspect = 1;

    // adjust text scale
    Vec3 scale = tip_jobj->scale;
    // background scale
    tip_jobj->scale = scale;
    // text scale
    tip_text->scale.X = (scale.X * 0.01) * TIP_TXTSIZEX;
    tip_text->scale.Y = (scale.Y * 0.01) * TIP_TXTSIZEY;
    tip_text->aspect.X = (TIP_TXTASPECT / TIP_TXTSIZEX);

    // apply enter anim
    JOBJ_RemoveAnimAll(tip_jobj);
    JOBJ_AddAnimAll(tip_jobj, stc_event_vars.menu_assets->tip_jointanim[0], 0, 0);
    JOBJ_ReqAnimAll(tip_jobj, 0);

    // build string
    char buffer[(TIP_LINEMAX * TIP_CHARMAX) + 1];
    va_start(args, fmt);
    vsprintf(buffer, fmt, args);
    va_end(args);
    char *msg = &buffer;

    // count newlines
    int line_num = 1;
    int line_length_arr[TIP_LINEMAX];
    char *msg_cursor_prev, *msg_cursor_curr; // declare char pointers
    msg_cursor_prev = msg;
    msg_cursor_curr = strchr(msg_cursor_prev, '\n'); // check for occurrence
    while (msg_cursor_curr != 0)                     // if occurrence found, increment values
    {
        // check if exceeds max lines
        if (line_num >= TIP_LINEMAX)
            assert("TIP_LINEMAX exceeded!");

        // Save information about this line
        line_length_arr[line_num - 1] = msg_cursor_curr - msg_cursor_prev; // determine length of the line
        line_num++;                                                        // increment number of newlines found
        msg_cursor_prev = msg_cursor_curr + 1;                             // update prev cursor
        msg_cursor_curr = strchr(msg_cursor_prev, '\n');                   // check for another occurrence
    }

    // get last lines length
    msg_cursor_curr = strchr(msg_cursor_prev, 0);
    line_length_arr[line_num - 1] = msg_cursor_curr - msg_cursor_prev;

    // copy each line to an individual char array
    char *msg_cursor = &msg;
    for (int i = 0; i < line_num; i++)
    {

        // check if over char max
        u8 line_length = line_length_arr[i];
        if (line_length > TIP_CHARMAX)
            assert("TIP_CHARMAX exceeded!");

        // copy char array
        char msg_line[TIP_CHARMAX + 1];
        memcpy(msg_line, msg, line_length);

        // add null terminator
        msg_line[line_length] = '\0';

        // increment msg
        msg += (line_length + 1); // +1 to skip past newline

        // print line
        int y_delta = (i * MSGTEXT_YOFFSET);
        Text_AddSubtext(tip_text, 0, y_delta, msg_line);
    }

    return 1; // tip created
}
void Tip_Destroy()
{
    // check if tip exists and isnt in exit state, enter exit
    if ((stc_tipmgr.gobj != 0) && (stc_tipmgr.state != 2))
    {
        // apply exit anim
        JOBJ *tip_root = stc_tipmgr.gobj->hsd_object;
        JOBJ_RemoveAnimAll(tip_root);
        JOBJ_AddAnimAll(tip_root, stc_event_vars.menu_assets->tip_jointanim[1], 0, 0);
        JOBJ_ReqAnimAll(tip_root, 0);
        JOBJ_RunAOBJCallback(tip_root, 6, 0xfb7f, AOBJ_SetRate, 1, (float)2);

        stc_tipmgr.state = 2; // enter wait
    }

    return;
}

////////////////////////////
/// Event Menu Functions ///
////////////////////////////

GOBJ *EventMenu_Init(EventDesc *event_desc, EventMenu *start_menu)
{
    // Ensure this event has a menu
    if (start_menu == 0)
        return 0;

    // Create a cobj for the event menu
    COBJDesc ***dmgScnMdls = File_GetSymbol(ACCESS_PTR(0x804d6d5c), 0x803f94d0);
    COBJDesc *cam_desc = dmgScnMdls[1][0];
    COBJ *cam_cobj = COBJ_LoadDesc(cam_desc);
    GOBJ *cam_gobj = GObj_Create(19, 20, 0);
    GObj_AddObject(cam_gobj, R13_U8(-0x3E55), cam_cobj);
    GOBJ_InitCamera(cam_gobj, CObjThink_Common, MENUCAM_GXPRI);
    cam_gobj->cobj_links = MENUCAM_COBJGXLINK;

    // Create menu gobj
    GOBJ *gobj = GObj_Create(0, 0, 0);
    MenuData *menuData = calloc(sizeof(MenuData));
    GObj_AddUserData(gobj, 4, HSD_Free, menuData);

    // store pointer to the gobj's data
    menuData->event_desc = event_desc;

    // Add gx_link
    GObj_AddGXLink(gobj, GXLink_Common, GXLINK_MENUMODEL, GXPRI_MENUMODEL);

    // Create 2 text canvases (menu and popup)
    menuData->canvas_menu = Text_CreateCanvas(2, cam_gobj, 9, 13, 0, GXLINK_MENUTEXT, GXPRI_MENUTEXT, MENUCAM_GXPRI);
    menuData->canvas_popup = Text_CreateCanvas(2, cam_gobj, 9, 13, 0, GXLINK_MENUTEXT, GXPRI_POPUPTEXT, MENUCAM_GXPRI);

    // Init currMenu
    menuData->currMenu = start_menu;

    // set menu as not hidden
    stc_event_vars.hide_menu = 0;

    return gobj;
};

void EventMenu_Update(GOBJ *gobj)
{

    //MenuCamData *camData = gobj->userdata;
    MenuData *menuData = gobj->userdata;
    EventDesc *event_desc = menuData->event_desc;
    EventMenu *currMenu = menuData->currMenu;

    int update_menu = 1;

    // if a custom menu is in use, run its function
    if (menuData->custom_gobj_think != 0)
    {
        update_menu = menuData->custom_gobj_think(menuData->custom_gobj);
    }

    // if this menu has an upate function, run its function
    else if ((menuData->isPaused == 1) && (currMenu->menu_think != 0))
    {
        update_menu = currMenu->menu_think(gobj);
    }

    if (update_menu == 1)
    {
        // Check if being pressed
        int isPress = 0;
        for (int i = 0; i < 6; i++)
        {

            // humans only
            if (Fighter_GetSlotType(i) == 0)
            {
                GOBJ *fighter = Fighter_GetGObj(i);
                FighterData *fighter_data = fighter->userdata;
                int controller_index = Fighter_GetControllerPort(i);

                HSD_Pad *pad = PadGet(controller_index, PADGET_MASTER);

                // in develop mode, use X+DPad up
                if (*stc_dblevel >= 3)
                {
                    if ((pad->held & HSD_BUTTON_X) && (pad->down & HSD_BUTTON_DPAD_UP))
                    {
                        isPress = 1;
                        menuData->controller_index = controller_index;
                        break;
                    }
                }
                else
                {
                    if ((pad->down & HSD_BUTTON_START) != 0)
                    {
                        isPress = 1;
                        menuData->controller_index = controller_index;
                        break;
                    }
                }
            }
        }

        // change pause state
        if (isPress != 0)
        {

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
                Match_AdjustSoundOnPause(1);
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
                Match_AdjustSoundOnPause(0);
            }
        }

        // run menu logic if the menu is shown
        else if ((menuData->isPaused == 1) && (stc_event_vars.hide_menu == 0))
        {
            // Get the current menu
            EventMenu *currMenu = menuData->currMenu;

            // menu think
            if (currMenu->state == EMSTATE_FOCUS)
            {
                // check to run custom menu think function
                EventMenu_MenuThink(gobj, currMenu);
            }

            // popup think
            else if (currMenu->state == EMSTATE_OPENPOP)
                EventMenu_PopupThink(gobj, currMenu);
        }
    }

    return;
}

void EventMenu_MenuGX(GOBJ *gobj, int pass)
{
    if (stc_event_vars.hide_menu == 0)
        GXLink_Common(gobj, pass);
    return;
}

void EventMenu_TextGX(GOBJ *gobj, int pass)
{

    if (stc_event_vars.hide_menu == 0)
        Text_GX(gobj, pass);
    return;
}

void EventMenu_MenuThink(GOBJ *gobj, EventMenu *currMenu)
{

    MenuData *menuData = gobj->userdata;
    EventDesc *event_desc = menuData->event_desc;

    // get player who paused
    u8 pauser = menuData->controller_index;
    // get their  inputs
    HSD_Pad *pad = PadGet(pauser, PADGET_MASTER);
    int inputs_rapid = Pad_GetRapidHeld(pauser); //pad->rapidFire;
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

        // loop to find next option
        int count = 1;       //
        int cursor_next = 0; // how much to move the cursor by
        while (((cursor + count + scroll) < option_num))
        {
            // option exists, check if its enabled
            if (currMenu->options[cursor + count + scroll].disable == 0)
            {
                cursor_next = count;
                break;
            }

            // option is disabled, loop
            count++;
        }

        // if another option exists, move down
        if (cursor_next > 0)
        {
            cursor += cursor_next;

            // cursor is in bounds, move down
            if (cursor < cursor_max)
            {
                isChanged = 1;

                // update cursor
                currMenu->cursor = cursor;

                // also play sfx
                SFX_PlayCommon(2);
            }

            // cursor overflowed, correct it
            else
            {

                // adjust
                scroll -= (cursor_max - (cursor + 1));
                cursor = (cursor_max - 1);

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
        // loop to find next option
        int count = 1;       //
        int cursor_next = 0; // how much to move the cursor by
        while (((cursor + scroll - count) >= 0))
        {
            // option exists, check if its enabled
            if (currMenu->options[cursor + scroll - count].disable == 0)
            {
                cursor_next = count;
                break;
            }

            // option is disabled, loop
            count++;
        }

        // if another option exists, move up
        if (cursor_next > 0)
        {
            cursor -= cursor_next;

            // cursor is in bounds, move up
            if (cursor >= 0)
            {
                isChanged = 1;

                // update cursor
                currMenu->cursor = cursor;

                // also play sfx
                SFX_PlayCommon(2);
            }

            // cursor overflowed, correct it
            else
            {

                // adjust
                scroll += cursor; // effectively scroll up by adding a negative number
                cursor = 0;       // cursor is positioned at 0

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
    else if (inputs_rapid & HSD_BUTTON_A)
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

        /*
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
        */

        // check to run a function
        if ((currOption->option_kind == OPTKIND_FUNC) && (currOption->onOptionSelect != 0))
        {

            // execute function
            currOption->onOptionSelect(gobj);

            // update text
            EventMenu_UpdateText(gobj, currMenu);

            // also play sfx
            SFX_PlayCommon(1);
        }
    }
    // check to go back a menu
    else if (inputs_rapid & HSD_BUTTON_B)
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

        /*
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
            Match_AdjustSoundOnPause(0);
        }
        */
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
    EventDesc *event_desc = menuData->event_desc;

    // get player who paused
    u8 pauser = menuData->controller_index; // get their  inputs
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
    evMenu *menuAssets = stc_event_vars.menu_assets;
    JOBJ *jobj_options = JOBJ_LoadJoint(menuAssets->menu);
    // Add to gobj
    GObj_AddObject(gobj, 3, jobj_options);
    GObj_DestroyGXLink(gobj);
    GObj_AddGXLink(gobj, EventMenu_MenuGX, GXLINK_MENUMODEL, GXPRI_MENUMODEL);

    // JOBJ array for getting the corner joints
    JOBJ *corners[4];

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
        DOBJ_SetFlags(jobj_border->dobj, DOBJ_HIDDEN);
        jobj_border->dobj->next->mobj->mat->alpha = 0.6;
        //GXColor border_color = ROWBOX_COLOR;
        //jobj_border->dobj->next->mobj->mat->diffuse = border_color;
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
    // remove outline
    DOBJ_SetFlags(jobj_highlight->dobj, DOBJ_HIDDEN);
    // attach to root jobj
    JOBJ_AddChild(gobj->hsd_object, jobj_highlight);
    // move it into position
    JOBJ_GetChild(jobj_highlight, &corners, 2, 3, 4, 5, -1);
    // Modify scale and position
    jobj_highlight->trans.Z = MENUHIGHLIGHT_Z;
    jobj_highlight->scale.X = MENUHIGHLIGHT_SCALE;
    jobj_highlight->scale.Y = MENUHIGHLIGHT_SCALE;
    jobj_highlight->scale.Z = MENUHIGHLIGHT_SCALE;
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

    // check to create scroll bar
    if (menuData->currMenu->option_num > MENU_MAXOPTION)
    {
        // create scroll bar
        JOBJ *scroll_jobj = JOBJ_LoadJoint(menuAssets->scroll);
        // attach to root jobj
        JOBJ_AddChild(gobj->hsd_object, scroll_jobj);
        // move it into position
        JOBJ_GetChild(scroll_jobj, &corners, 2, 3, -1);
        // scale scrollbar accordingly
        scroll_jobj->scale.X = MENUSCROLL_SCALE;
        scroll_jobj->scale.Y = MENUSCROLL_SCALEY;
        scroll_jobj->scale.Z = MENUSCROLL_SCALE;
        scroll_jobj->trans.X = MENUSCROLL_X;
        scroll_jobj->trans.Y = MENUSCROLL_Y;
        scroll_jobj->trans.Z = MENUSCROLL_Z;
        menuData->scroll_top = corners[0];
        menuData->scroll_bot = corners[1];
        GXColor highlight = MENUSCROLL_COLOR;
        scroll_jobj->dobj->next->mobj->mat->alpha = 0.6;
        scroll_jobj->dobj->next->mobj->mat->diffuse = highlight;

        // calculate scrollbar size
        int max_steps = menuData->currMenu->option_num - MENU_MAXOPTION;
        float botPos = MENUSCROLL_MAXLENGTH + (max_steps * MENUSCROLL_PEROPTION);
        if (botPos > MENUSCROLL_MINLENGTH)
            botPos = MENUSCROLL_MINLENGTH;

        // set size
        corners[1]->trans.Y = botPos;
    }
    else
    {
        menuData->scroll_bot = 0;
        menuData->scroll_top = 0;
    }

    return;
}

void EventMenu_CreateText(GOBJ *gobj, EventMenu *menu)
{

    // Get event info
    MenuData *menuData = gobj->userdata;
    EventDesc *event_desc = menuData->event_desc;
    Text *text;
    int subtext;
    int canvasIndex = menuData->canvas_menu;
    s32 cursor = menu->cursor;

    // free text if it exists
    if (menuData->text_name != 0)
    {
        // free text
        Text_Destroy(menuData->text_name);
        menuData->text_name = 0;
        Text_Destroy(menuData->text_value);
        menuData->text_value = 0;
        Text_Destroy(menuData->text_title);
        menuData->text_title = 0;
        Text_Destroy(menuData->text_desc);
        menuData->text_desc = 0;
    }
    if (menuData->text_popup != 0)
    {
        Text_Destroy(menuData->text_popup);
        menuData->text_popup = 0;
    }

    /*******************
    *** Create Title ***
    *******************/

    text = Text_CreateText(2, canvasIndex);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_title = text;
    // enable align and kerning
    text->align = 0;
    text->kerning = 1;
    text->use_aspect = 1;
    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;
    text->trans.Z = MENU_TEXTZ;
    text->aspect.X = MENU_TITLEASPECT;

    // output menu title
    float optionX = MENU_TITLEXPOS;
    float optionY = MENU_TITLEYPOS;
    subtext = Text_AddSubtext(text, optionX, optionY, &nullString);
    Text_SetScale(text, subtext, MENU_TITLESCALE, MENU_TITLESCALE);

    /**************************
    *** Create Description ***
    *************************/

    text = Text_CreateText(2, canvasIndex);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_desc = text;

    /*******************
    *** Create Names ***
    *******************/

    text = Text_CreateText(2, canvasIndex);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_name = text;
    // enable align and kerning
    text->align = 0;
    text->kerning = 1;
    text->use_aspect = 1;
    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;
    text->trans.Z = MENU_TEXTZ;
    text->aspect.X = MENU_NAMEASPECT;

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

    /********************
    *** Create Values ***
    ********************/

    text = Text_CreateText(2, canvasIndex);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_value = text;
    // enable align and kerning
    text->align = 1;
    text->kerning = 1;
    text->use_aspect = 1;
    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;
    text->trans.Z = MENU_TEXTZ;
    text->aspect.X = MENU_VALASPECT;

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
    EventDesc *event_desc = menuData->event_desc;
    s32 cursor = menu->cursor;
    s32 scroll = menu->scroll;
    s32 option_num = menu->option_num;
    if (option_num > MENU_MAXOPTION)
        option_num = MENU_MAXOPTION;
    Text *text;

    // Update Title

    text = menuData->text_title;
    Text_SetText(text, 0, menu->name);

    // Update Description
    Text_Destroy(menuData->text_desc); // i think its best to recreate it...
    text = Text_CreateText(2, menuData->canvas_menu);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_desc = text;
    EventOption *currOption = &menu->options[menu->cursor + menu->scroll];

#define DESC_TXTSIZEX 5
#define DESC_TXTSIZEY 5
#define DESC_TXTASPECT 885
#define DESC_LINEMAX 4
#define DESC_CHARMAX 100
#define DESC_YOFFSET 30

    text->kerning = 1;
    text->align = 0;
    text->use_aspect = 1;

    // scale canvas
    text->scale.X = 0.01 * DESC_TXTSIZEX;
    text->scale.Y = 0.01 * DESC_TXTSIZEY;
    text->trans.X = MENU_DESCXPOS;
    text->trans.Y = MENU_DESCYPOS;
    text->trans.Z = MENU_TEXTZ;
    text->aspect.X = (DESC_TXTASPECT);

    char *msg = currOption->desc;

    // count newlines
    int line_num = 1;
    int line_length_arr[DESC_LINEMAX];
    char *msg_cursor_prev, *msg_cursor_curr; // declare char pointers
    msg_cursor_prev = msg;
    msg_cursor_curr = strchr(msg_cursor_prev, '\n'); // check for occurrence
    while (msg_cursor_curr != 0)                     // if occurrence found, increment values
    {
        // check if exceeds max lines
        if (line_num >= DESC_LINEMAX)
            assert("DESC_LINEMAX exceeded!");

        // Save information about this line
        line_length_arr[line_num - 1] = msg_cursor_curr - msg_cursor_prev; // determine length of the line
        line_num++;                                                        // increment number of newlines found
        msg_cursor_prev = msg_cursor_curr + 1;                             // update prev cursor
        msg_cursor_curr = strchr(msg_cursor_prev, '\n');                   // check for another occurrence
    }

    // get last lines length
    msg_cursor_curr = strchr(msg_cursor_prev, 0);
    line_length_arr[line_num - 1] = msg_cursor_curr - msg_cursor_prev;

    // copy each line to an individual char array
    char *msg_cursor = &msg;
    for (int i = 0; i < line_num; i++)
    {

        // check if over char max
        u8 line_length = line_length_arr[i];
        if (line_length > DESC_CHARMAX)
            assert("DESC_CHARMAX exceeded!");

        // copy char array
        char msg_line[DESC_CHARMAX + 1];
        memcpy(msg_line, msg, line_length);

        // add null terminator
        msg_line[line_length] = '\0';

        // increment msg
        msg += (line_length + 1); // +1 to skip past newline

        // print line
        int y_delta = (i * DESC_YOFFSET);
        Text_AddSubtext(text, 0, y_delta, msg_line);
    }

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

        // output color
        GXColor color;
        if (currOption->disable == 0)
        {
            color.r = 255;
            color.b = 255;
            color.g = 255;
            color.a = 255;
        }
        else
        {
            color.r = 128;
            color.b = 128;
            color.g = 128;
            color.a = 0;
        }
        Text_SetColor(text, i, &color);
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
            Text_SetText(text, i, currOption->option_values, optionVal);

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

        // output color
        GXColor color;
        if (currOption->disable == 0)
        {
            color.r = 255;
            color.b = 255;
            color.g = 255;
            color.a = 255;
        }
        else
        {
            color.r = 128;
            color.b = 128;
            color.g = 128;
            color.a = 0;
        }
        Text_SetColor(text, i, &color);
    }

    // update cursor position
    JOBJ *highlight_joint = menuData->highlight_menu;
    highlight_joint->trans.Y = cursor * MENUHIGHLIGHT_YOFFSET;

    // update scrollbar position
    if (menuData->scroll_top != 0)
    {
        float curr_steps = menuData->currMenu->scroll;
        float max_steps;
        if (menuData->currMenu->option_num < MENU_MAXOPTION)
            max_steps = 0;
        else
            max_steps = menuData->currMenu->option_num - MENU_MAXOPTION;

        // scrollTop = -1 * ((curr_steps/max_steps) * (botY - -10))
        menuData->scroll_top->trans.Y = -1 * (curr_steps / max_steps) * (menuData->scroll_bot->trans.Y - MENUSCROLL_MAXLENGTH);
    }

    // update jobj
    JOBJ_SetMtxDirtySub(gobj->hsd_object);

    return;
}

void EventMenu_DestroyMenu(GOBJ *gobj)
{
    MenuData *menuData = gobj->userdata; // userdata

    // remove
    Text_Destroy(menuData->text_name);
    menuData->text_name = 0;
    // remove
    Text_Destroy(menuData->text_value);
    menuData->text_value = 0;
    // remove
    Text_Destroy(menuData->text_title);
    menuData->text_title = 0;
    // remove
    Text_Destroy(menuData->text_desc);
    menuData->text_desc = 0;

    // if popup box exists
    if (menuData->text_popup != 0)
        EventMenu_DestroyPopup(gobj);

    // if custom menu gobj exists
    if (menuData->custom_gobj != 0)
    {
        // run on destroy function
        if (menuData->custom_gobj_destroy != 0)
            menuData->custom_gobj_destroy(menuData->custom_gobj);

        // null pointers
        menuData->custom_gobj = 0;
        menuData->custom_gobj_destroy = 0;
        menuData->custom_gobj_think = 0;
    }

    // set menu as visible
    stc_event_vars.hide_menu = 0;

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
    evMenu *menuAssets = stc_event_vars.menu_assets;

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
    GObj_AddGXLink(popup_gobj, EventMenu_MenuGX, GXLINK_POPUPMODEL, GXPRI_POPUPMODEL);
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
    text->gobj->gx_cb = EventMenu_TextGX;
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
    Text_Destroy(menuData->text_popup);
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

EventDesc *GetEventDesc(int page, int event)
{
    EventPage *thisPage = EventPages[page];
    EventDesc *thisEvent = thisPage->events[event];
    return (thisEvent);
}
char *GetEventName(int page, int event)
{
    EventDesc *thisEvent = GetEventDesc(page, event);
    return (thisEvent->eventName);
}
char *GetEventDescription(int page, int event)
{
    EventDesc *thisEvent = GetEventDesc(page, event);
    return (thisEvent->eventDescription);
}
char *GetEventTut(int page, int event)
{
    EventDesc *thisEvent = GetEventDesc(page, event);
    return (thisEvent->eventTutorial);
}
char *GetPageName(int page)
{
    EventPage *thisPage = EventPages[page];
    return (thisPage->name);
}
char *GetEventFile(int page, int event)
{
    EventDesc *thisEvent = GetEventDesc(page, event);
    return (thisEvent->eventFile);
}
char *GetCSSFile(int page, int event)
{
    EventDesc *thisEvent = GetEventDesc(page, event);
    return (thisEvent->eventCSSFile);
}
int GetPageEventNum(int page)
{
    EventPage *thisPage = EventPages[page];
    return (thisPage->eventNum);
}
char *GetTMVersShort()
{
    return (TM_VersShort);
}
char *GetTMVersLong()
{
    return (TM_VersLong);
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
    EventDesc *thisEvent = GetEventDesc(page, event);
    return (thisEvent->isChooseCPU);
}
u8 GetIsSelectStage(int page, int event)
{
    EventDesc *thisEvent = GetEventDesc(page, event);
    return (thisEvent->isSelectStage);
}
s8 GetFighter(int page, int event)
{
    EventDesc *thisEvent = GetEventDesc(page, event);
    return (thisEvent->matchData->playerKind);
}
s8 GetCPUFighter(int page, int event)
{
    EventDesc *thisEvent = GetEventDesc(page, event);
    return (thisEvent->matchData->cpuKind);
}
s16 GetStage(int page, int event)
{
    EventDesc *thisEvent = GetEventDesc(page, event);
    return (thisEvent->matchData->stage);
}
