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

static char TM_Vers[] = {"Training Mode v3.0 ALPHA\n"};
static char TM_Compile[] = "COMPILED: " __DATE__ " " __TIME__;
static char nullString[] = " ";

////////////////////////
/// Event Defintions ///
////////////////////////

// L-Cancel Training

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
static EventInfo LCancel = {
    // Event Name
    .eventName = "L-Cancel Training\n",
    .eventDescription = "Practice L-Cancelling on\na stationary CPU.\n",
    .eventTutorial = "TvLC",
    .eventFile = "EvLab",
    .isChooseCPU = true,
    .isSelectStage = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &LCancel_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// Ledgedash Training
// Match Data
static EventMatchData Ledgedash_MatchData = {
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
// Event Struct
static EventInfo Ledgedash = {
    .eventName = "Ledgedash Training\n",
    .eventDescription = "Practice Ledgedashes!\nUse D-Pad to change ledge.\n",
    .eventTutorial = "TvLedDa",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Ledgedash_MatchData,
    .defaultOSD = 0xFFFFFFFF,
};

// Combo Training
// Match Data
static EventMatchData Combo_MatchData = {
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
// Event Struct
static EventInfo Combo = {

    .eventName = "Combo Training\n",
    .eventDescription = "L+DPad adjusts percent | DPadDown moves CPU\nDPad right/left saves and loads positions.",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo AttackOnShield = {
    .eventName = "Attack on Shield\n",
    .eventDescription = "Practice attacks on a shielding opponent\nPause to change their OoS option\n",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo Reversal = {
    .eventName = "Reversal Training\n",
    .eventDescription = "Practice OoS punishes! DPad left/right\nmoves characters close and further apart.",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo SDI = {
    .eventName = "SDI Training\n",
    .eventDescription = "Use Smash DI to escape\nFox's up-air attack!",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo Powershield = {
    .eventName = "Powershield Training\n",
    .eventDescription = "Powershield Falco's laser!\nPause to change to fire-rate.",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo Ledgetech = {
    .eventName = "Ledge-Tech Training\n",
    .eventDescription = "Practice ledge-teching\nFalco's down-smash",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo AmsahTech = {
    .eventName = "Amsah-Tech Training\n",
    .eventDescription = "Taunt to have Marth Up-B,\nthen ASDI down and tech!\n",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo ShieldDrop = {
    .eventName = "Shield Drop Training\n",
    .eventDescription = "Counter with a shield-drop aerial!\nDPad left/right moves players apart.",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo WaveshineSDI = {
    .eventName = "Waveshine SDI\n",
    .eventDescription = "Use Smash DI to get out\nof Fox's waveshine!",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo SlideOff = {
    .eventName = "Slide-Off Training\n",
    .eventDescription = "Use Slide-Off DI to slide off\nthe platform and counter attack!\n",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo GrabMash = {
    .eventName = "Grab Mash Training\n",
    .eventDescription = "Mash buttons to escape the grab\nas quickly as possible!\n",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo TechCounter = {
    .eventName = "Ledgetech Marth Counter\n",
    .eventDescription = "Practice ledge-teching\nMarth's counter!\n",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo ArmadaShine = {
    .eventName = "Armada-Shine Training\n",
    .eventDescription = "Finish the enemy Fox\nwith an Armada Shine!",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo SideBSweet = {
    .eventName = "Side-B Sweetspot\n",
    .eventDescription = "Use a sweetspot Side-B to avoid Marth's\ndown-tilt and grab the ledge!",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo EscapeSheik = {
    .eventName = "Escape Sheik Techchase\n",
    .eventDescription = "Practice escaping the tech chase with a\nframe perfect shine or jab SDI!\n",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo Eggs = {
    .eventName = "Eggs-ercise\n",
    .eventDescription = "Break the eggs! Only strong hits will\nbreak them. DPad down = free practice.",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo Multishine = {
    .eventName = "Shined Blind\n",
    .eventDescription = "How many shines can you\nperform in 10 seconds?",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo Reaction = {
    .eventName = "Reaction Test\n",
    .eventDescription = "Test your reaction time by pressing\nany button when you see/hear Fox shine!",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
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
// Event Struct
static EventInfo Ledgestall = {
    .eventName = "Under Fire\n",
    .eventDescription = "Ledgestall to remain\ninvincible while the lava rises!\n",
    .eventTutorial = "TvLC",
    .eventFile = "",
    .isChooseCPU = true,
    .isSelectStage = true,
    .scoreType = 0,
    .callbackPriority = 3,
    .matchData = &Ledgestall_MatchData,
    .defaultOSD = 0xFFFFFFFF,
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
    .eventNum = (sizeof(Minigames_Events) / 4) - 1,
    .events = Minigames_Events,
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

static SaveState stc_savestate;
static EventInfo *static_eventInfo;
static MenuData *static_menuData;
static EventVars stc_event_vars = {
    .event_info = 0,
    .menu_assets = 0,
    .event_gobj = 0,
    .menu_gobj = 0,
    .game_timer = 0,
    .hide_menu = 0,
    .Savestate_Save = Savestate_Save,
    .Savestate_Load = Savestate_Load,
};
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
    evFunction *evFunction = &stc_event_vars.evFunction;

    // append extension
    static char *extension = ".dat";
    char *buffer[20];
    strcpy(buffer, eventInfo->eventFile);
    strcat(buffer, extension);

    // load this events file
    ArchiveInfo *archive = MEX_LoadRelArchive(buffer, evFunction, "evFunction");
    stc_event_vars.event_archive = archive;

    // Create this event's gobj
    int pri = eventInfo->callbackPriority;
    void *cb = evFunction->Event_Think;
    GOBJ *gobj = GObj_Create(0, 7, 0);
    int *userdata = calloc(EVENT_DATASIZE);
    GObj_AddUserData(gobj, 4, HSD_Free, userdata);
    GObj_AddProc(gobj, cb, pri);

    // store pointer to the event's data
    userdata[0] = eventInfo;

    // Create a gobj to track match time
    stc_event_vars.game_timer = 0;
    GOBJ *timer_gobj = GObj_Create(0, 7, 0);
    GObj_AddProc(timer_gobj, Event_IncTimer, 0);

    // init the pause menu
    GOBJ *menu_gobj = EventMenu_Init(eventInfo, *evFunction->menu_start);

    blr();

    // Init static structure containing event variables
    stc_event_vars.event_info = eventInfo;
    stc_event_vars.event_gobj = gobj;
    stc_event_vars.menu_gobj = menu_gobj;
    // store pointer to this structure
    *event_vars_ptr = &stc_event_vars;

    // init savestate struct
    eventDataBackup = calloc(EVENT_DATASIZE);
    stc_savestate.is_exist = 0;
    for (int i = 0; i < sizeof(stc_savestate.ft_state) / 4; i++)
    {
        stc_savestate.ft_state[i] = 0;
    }

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
    EventInfo *event_info = stc_event_vars.event_info;
    evFunction *evFunction = &stc_event_vars.evFunction;
    GOBJ *menu_gobj = stc_event_vars.menu_gobj;

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

void OnFileLoad(ArchiveInfo *archive) // this function is run right after TmDt is loaded into memory on boot
{
    // get even menu
    stc_event_vars.menu_assets = File_GetSymbol(archive, "evMenu");
    return;
}

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
                spawnItem.it_kind = ITEM_MRSATURN;
                spawnItem.hold_kind = ITHOLD_HAND;
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
                GOBJ *item = Item_CreateItem(&spawnItem);
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

int Savestate_Save(SaveState *savestate)
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
    GOBJ *event_gobj = stc_event_vars.event_gobj;
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

        // save frame
        savestate->frame = stc_event_vars.game_timer;

        // backup event data
        memcpy(eventDataBackup, event_gobj->userdata, EVENT_DATASIZE);

        // free all savestates
        for (int i = 0; i < 6 / 4; i++)
        {
            if (savestate->ft_state[i] != 0)
                HSD_Free(savestate->ft_state[i]);
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

                // allocate new state
                FtState *state = calloc(sizeof(FtState));

                // backup playerblock
                Playerblock *playerblock = Fighter_GetPlayerblock(queue[0].fighter_data->ply);
                memcpy(&state->player_block, playerblock, sizeof(Playerblock));

                // backup stale moves
                int *staleMoves = Fighter_GetStaleMoveTable(queue[0].fighter_data->ply);
                memcpy(&state->stale_queue, staleMoves, 0x2C);

                // backup fighter data
                for (int j = 0; j < 2; j++)
                {
                    // if exists
                    if (queue[j].fighter != 0)
                    {
                        GOBJ *fighter = queue[j].fighter;
                        FighterData *fighter_data = queue[j].fighter_data;

                        // backup fighter data
                        memcpy(&state->fighter_data[j], fighter_data, sizeof(FighterData));

                        // backup camerabox
                        memcpy(&state->camera[j], fighter_data->cameraBox, sizeof(CameraBox));
                    }
                }

                // store pointer
                savestate->ft_state[i] = state;
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

        // if not in frame advance, flash screen. I wrote it like this because the second condition kept getting optimizing out...
        if ((Pause_CheckStatus(0) != 1))
        {
            if ((Pause_CheckStatus(1) != 2))
            {
                ScreenFlash_Create(2, 0);
            }
        }

        // set as exist
        savestate->is_exist = 1;
    }

    return isSaved;
}
int Savestate_Load(SaveState *savestate)
{
    typedef struct BackupQueue
    {
        GOBJ *fighter;
        FighterData *fighter_data;
    } BackupQueue;

    GOBJ *event_gobj = stc_event_vars.event_gobj;

    // return if savestate doesnt exist
    if (savestate->is_exist == 0)
        return 0;

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
        if ((queue[0].fighter != 0) && (savestate->ft_state[i] != 0))
        {

            isLoaded = 1;

            // get state
            FtState *state = savestate->ft_state[i];

            // restore playerblock
            Playerblock *playerblock = Fighter_GetPlayerblock(queue[0].fighter_data->ply);
            memcpy(playerblock, &state->player_block, sizeof(Playerblock));

            // restore stale moves
            int *staleMoves = Fighter_GetStaleMoveTable(queue[0].fighter_data->ply);
            memcpy(staleMoves, &state->stale_queue, 0x2C);

            // restore fighter data
            for (int j = 0; j < 2; j++)
            {
                // if exists
                if (queue[j].fighter != 0)
                {
                    GOBJ *fighter = queue[j].fighter;
                    FighterData *fighter_data = queue[j].fighter_data;
                    FighterData *backup_data = &state->fighter_data[j];

                    // backup buttons and collision bubble toggle
                    int input_lstick_x = fighter_data->input_lstick_x;
                    int input_lstick_y = fighter_data->input_lstick_y;
                    int dpad_held = (fighter_data->input_held & PAD_BUTTON_DPAD_LEFT) & (fighter_data->input_held & PAD_BUTTON_DPAD_RIGHT);
                    u8 show_model = fighter_data->show_model;
                    u8 show_hit = fighter_data->show_hit;

                    // restore facing direction
                    fighter_data->facing_direction = state->fighter_data[j].facing_direction;
                    // sleep
                    Fighter_EnterSleep(fighter, 0);
                    // enter backed up state
                    ActionStateChange(backup_data->stateFrame, backup_data->stateSpeed, -1, fighter, backup_data->state_id, 0, 0);
                    fighter_data->stateBlend = 0;

                    // snap dynamic bones in place
                    /*
                    if (fighter_data->state_id == ASID_WAIT)
                    {
                        Fighter_DisableBlend(fighter, 6);
                    }
                    */

                    // restore fighter data
                    memcpy(fighter_data, &state->fighter_data[j], sizeof(FighterData));

                    // restore buttons and collision bubble toggle
                    //fighter_data->input_lstick_x = input_lstick_x;
                    //fighter_data->input_lstick_y = input_lstick_y;
                    fighter_data->input_held &= dpad_held;
                    fighter_data->show_model = show_model;
                    fighter_data->show_hit = show_hit;

                    // zero pointer to cached animation (fixes fall crash)
                    fighter_data->anim_persist_ARAM = 0;

                    // update colltest frame
                    fighter_data->collData.coll_test = R13_INT(COLL_TEST);

                    // restore camerabox
                    memcpy(fighter_data->cameraBox, &state->camera[j], sizeof(CameraBox));

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

        // restore frame
        Match *match = stc_match;
        match->time_frames = savestate->frame;
        stc_event_vars.game_timer = savestate->frame;

        // update timer
        int frames = match->time_frames - 1; // this is because the scenethink function runs once before the gobj procs do
        match->time_seconds = frames / 60;
        match->time_ms = frames % 60;

        memcpy(event_gobj->userdata, eventDataBackup, EVENT_DATASIZE);

        SFX_PlayCommon(0);
    }

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
                    Savestate_Save(&stc_savestate);
                }
                else if (((pad->down & HSD_BUTTON_DPAD_LEFT) != 0) && ((pad->held & (blacklist)) == 0))
                {
                    // load state
                    Savestate_Load(&stc_savestate);
                }
            }
        }
    }

    return;
}
void Event_IncTimer(GOBJ *gobj)
{
    stc_event_vars.game_timer++;
    return;
}

////////////////////////////
/// Event Menu Functions ///
////////////////////////////

GOBJ *EventMenu_Init(EventInfo *eventInfo, EventMenu *start_menu)
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
    cam_gobj->cobj_id = MENUCAM_COBJGXLINK;

    // Create menu gobj
    GOBJ *gobj = GObj_Create(0, 0, 0);
    MenuData *menuData = calloc(sizeof(MenuData));
    GObj_AddUserData(gobj, 4, HSD_Free, menuData);

    // store pointer to the gobj's data
    menuData->eventInfo = eventInfo;

    // Add gx_link
    GObj_AddGXLink(gobj, GXLink_Common, GXLINK_MENUMODEL, GXPRI_MENUMODEL);

    // Create 2 text canvases (menu and popup)
    menuData->canvas_menu = Text_CreateCanvas(2, cam_gobj, 9, 13, 0, GXLINK_MENUTEXT, GXPRI_MENUTEXT, MENUCAM_GXPRI);
    menuData->canvas_popup = Text_CreateCanvas(2, cam_gobj, 9, 13, 0, GXLINK_MENUTEXT, GXPRI_POPUPTEXT, MENUCAM_GXPRI);

    // Init currMenu
    menuData->currMenu = start_menu;

    // set menu as not hidden
    stc_event_vars.hide_menu = 0;

    // Load EvMn.dat
    int *symbols;
    File_LoadInitReturnSymbol("EvMn.dat", &symbols, "evMenu", 0);
    menuData->menu_assets = &symbols[0];
    // also store to r13 in case any code needs to access these assets
    stc_event_vars.menu_assets = &symbols[0];

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

        // custom gobj think
        if (menuData->custom_gobj != 0)
        {

            menuData->custom_gobj_think(menuData->custom_gobj);

            /*
            // iterate through gobj proc's here
            GOBJ *custom_gobj = menuData->custom_gobj;
            GOBJProc **proc_arr = R13_PTR(-0x3E60);
            u8 max_gproc = ACCESS_U8(0x804ce380 + 0x2);
            for (int i = 0; i < max_gproc; i++)
            {
                GOBJProc *this_proc = proc_arr[i];
                while ((this_proc != 0) && (this_proc->cb != 0))
                {
                    if (this_proc->parentGOBJ == custom_gobj)
                    {
                        this_proc->cb(custom_gobj);
                    }
                    this_proc = this_proc->next;
                }
            }
            */
        }

        else
        {
            // menu think
            if (currMenu->state == EMSTATE_FOCUS)
                EventMenu_MenuThink(gobj, currMenu);

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
        if ((currOption->option_kind == OPTKIND_FUNC) && (currOption->onOptionSelect != 0))
        {

            // save pointer to this gobj
            currOption->onOptionSelect(gobj);

            // update text
            EventMenu_UpdateText(gobj, currMenu);

            // also play sfx
            SFX_PlayCommon(1);
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
    text->gobj->gx_cb = EventMenu_TextGX;
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
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_desc = text;

    //////////////////
    // Create Names //
    //////////////////

    text = Text_CreateText(2, canvasIndex);
    text->gobj->gx_cb = EventMenu_TextGX;
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
    text->gobj->gx_cb = EventMenu_TextGX;
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
        // run on destroy function
        if (menuData->custom_gobj_destroy != 0)
            menuData->custom_gobj_destroy(menuData->custom_gobj);

        // null pointers
        menuData->custom_gobj = 0;
        menuData->custom_gobj_destroy = 0;
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
