#include "events.h"

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
    .timer = MATCH_TIMER_COUNTDOWN,
    .matchType = MATCH_MATCHTYPE_TIME,
    .isDisableMusic = true,
    .hideGo = false,
    .hideReady = false,
    .isCreateHUD = false,
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
    .timerSeconds = 60,   // 0xFFFFFFFF
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
    .eventNum = (sizeof(Minigames_Events) / 4),
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
    (sizeof(General_Events) / 4),
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
    (sizeof(Spacie_Events) / 4),
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

///////////////////////////////
/// Member-Access Functions ///
///////////////////////////////

static EventLookup stc_event_lookup = {
    .GetEventDesc = GetEventDesc,
    .GetEventName = GetEventName,
    .GetEventDescription = GetEventDescription,
    .GetEventTut = GetEventTut,
    .GetPageName = GetPageName,
    .GetEventFile = GetEventFile,
    .GetCSSFile = GetCSSFile,
    .GetPageEventNum = GetPageEventNum,
    .GetPageNum = GetPageNum,
    .GetIsChooseCPU = GetIsChooseCPU,
    .GetIsSelectStage = GetIsSelectStage,
    .GetFighter = GetFighter,
    .GetCPUFighter = GetCPUFighter,
    .GetStage = GetStage,
};

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
int GetPageNum()
{
    int pageNum = (sizeof(EventPages) / 4);
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
