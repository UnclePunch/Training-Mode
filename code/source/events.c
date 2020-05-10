#include "events.h"

////////////////////
// Version Number //
////////////////////

static char TM_Vers[] = {"Training Mode v3.0\n"};
static char TM_Compile[] = "COMPILED: " __DATE__ " " __TIME__;

////////////////////////
/// Event Defintions ///
////////////////////////

// L-Cancel Training
// Event Name
static char LCancel_Name[] = {"L-Cancel Training\n"};
// Event Description
static char LCancel_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char LCancel_Tut[] = {"TvLC"};
// Event Menu Data
static char** LCancel_Stale[] = {"Off", "On"};
static char** LCancel_Intang[] = {"On", "Off"};
static MenuData LCancel_Menu[] =
{
    {
        "Stale Attacks",
        LCancel_Stale,
        sizeof(LCancel_Stale) / 4,
    },
    {
        "Option2",
        LCancel_Intang,
        sizeof(LCancel_Intang) / 4,
    },
};
// Match Data
static EventMatchData LCancel_MatchData =
{
    .timer = MATCH_TIMER_COUNTUP,
    .matchType = MATCH_MATCHTYPE_TIME,
    .playMusic = true,
    .hideGo = true,
    .hideReady = true,
    .isCreateHUD = true,
    .isDisablePause = false,
    // byte 0x3
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void LCancel_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData LCancel =
{
    // Event Name
    LCancel_Name,
    // Event Description
    LCancel_Desc,
    // Event Tutorial File Name
    LCancel_Tut,
    // isChooseCPU
    true,
    // isSelectStage
    true,
    // Score Type
    0,
    // callback priority
    0,
    // Event Callback Function
    LCancel_Think,
    // Match Data
    &LCancel_MatchData,
    // Menu Data
    &LCancel_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Ledgedash_Name[] = {"L-Cancel Training\n"};
// Event Description
static char Ledgedash_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char Ledgedash_Tut[] = {"TvLC"};
// Event Menu Data
static char** Ledgedash_Stale[] = {"Off", "On"};
static char** Ledgedash_Intang[] = {"On", "Off"};
static MenuData Ledgedash_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void Ledgedash_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData Ledgedash =
{
    // Event Name
    &Ledgedash_Name,
    // Event Description
    &Ledgedash_Desc,
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
    // Match Data
    &Ledgedash_MatchData,
    // Menu Data
    &Ledgedash_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Combo_Name[] = {"L-Cancel Training\n"};
// Event Description
static char Combo_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char Combo_Tut[] = {"TvLC"};
// Event Menu Data
static char** Combo_Stale[] = {"Off", "On"};
static char** Combo_Intang[] = {"On", "Off"};
static MenuData Combo_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void Combo_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData Combo =
{
    // Event Name
    &Combo_Name,
    // Event Description
    &Combo_Desc,
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
    // Match Data
    &Combo_MatchData,
    // Menu Data
    &Combo_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char AttackOnShield_Name[] = {"L-Cancel Training\n"};
// Event Description
static char AttackOnShield_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char AttackOnShield_Tut[] = {"TvLC"};
// Event Menu Data
static char** AttackOnShield_Stale[] = {"Off", "On"};
static char** AttackOnShield_Intang[] = {"On", "Off"};
static MenuData AttackOnShield_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void AttackOnShield_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData AttackOnShield =
{
    // Event Name
    &AttackOnShield_Name,
    // Event Description
    &AttackOnShield_Desc,
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
    // Match Data
    &AttackOnShield_MatchData,
    // Menu Data
    &AttackOnShield_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Reversal_Name[] = {"L-Cancel Training\n"};
// Event Description
static char Reversal_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char Reversal_Tut[] = {"TvLC"};
// Event Menu Data
static char** Reversal_Stale[] = {"Off", "On"};
static char** Reversal_Intang[] = {"On", "Off"};
static MenuData Reversal_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void Reversal_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData Reversal =
{
    // Event Name
    &Reversal_Name,
    // Event Description
    &Reversal_Desc,
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
    // Match Data
    &Reversal_MatchData,
    // Menu Data
    &Reversal_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char SDI_Name[] = {"L-Cancel Training\n"};
// Event Description
static char SDI_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char SDI_Tut[] = {"TvLC"};
// Event Menu Data
static char** SDI_Stale[] = {"Off", "On"};
static char** SDI_Intang[] = {"On", "Off"};
static MenuData SDI_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void SDI_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData SDI =
{
    // Event Name
    &SDI_Name,
    // Event Description
    &SDI_Desc,
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
    // Match Data
    &SDI_MatchData,
    // Menu Data
    &SDI_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Powershield_Name[] = {"L-Cancel Training\n"};
// Event Description
static char Powershield_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char Powershield_Tut[] = {"TvLC"};
// Event Menu Data
static char** Powershield_Stale[] = {"Off", "On"};
static char** Powershield_Intang[] = {"On", "Off"};
static MenuData Powershield_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void Powershield_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData Powershield =
{
    // Event Name
    &Powershield_Name,
    // Event Description
    &Powershield_Desc,
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
    // Match Data
    &Powershield_MatchData,
    // Menu Data
    &Powershield_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Ledgetech_Name[] = {"L-Cancel Training\n"};
// Event Description
static char Ledgetech_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char Ledgetech_Tut[] = {"TvLC"};
// Event Menu Data
static char** Ledgetech_Stale[] = {"Off", "On"};
static char** Ledgetech_Intang[] = {"On", "Off"};
static MenuData Ledgetech_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void Ledgetech_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData Ledgetech =
{
    // Event Name
    &Ledgetech_Name,
    // Event Description
    &Ledgetech_Desc,
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
    // Match Data
    &Ledgetech_MatchData,
    // Menu Data
    &Ledgetech_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char AmsahTech_Name[] = {"L-Cancel Training\n"};
// Event Description
static char AmsahTech_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char AmsahTech_Tut[] = {"TvLC"};
// Event Menu Data
static char** AmsahTech_Stale[] = {"Off", "On"};
static char** AmsahTech_Intang[] = {"On", "Off"};
static MenuData AmsahTech_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void AmsahTech_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData AmsahTech =
{
    // Event Name
    &AmsahTech_Name,
    // Event Description
    &AmsahTech_Desc,
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
    // Match Data
    &AmsahTech_MatchData,
    // Menu Data
    &AmsahTech_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char ShieldDrop_Name[] = {"L-Cancel Training\n"};
// Event Description
static char ShieldDrop_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char ShieldDrop_Tut[] = {"TvLC"};
// Event Menu Data
static char** ShieldDrop_Stale[] = {"Off", "On"};
static char** ShieldDrop_Intang[] = {"On", "Off"};
static MenuData ShieldDrop_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void ShieldDrop_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData ShieldDrop =
{
    // Event Name
    &ShieldDrop_Name,
    // Event Description
    &ShieldDrop_Desc,
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
    // Match Data
    &ShieldDrop_MatchData,
    // Menu Data
    &ShieldDrop_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char WaveshineSDI_Name[] = {"L-Cancel Training\n"};
// Event Description
static char WaveshineSDI_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char WaveshineSDI_Tut[] = {"TvLC"};
// Event Menu Data
static char** WaveshineSDI_Stale[] = {"Off", "On"};
static char** WaveshineSDI_Intang[] = {"On", "Off"};
static MenuData WaveshineSDI_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void WaveshineSDI_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData WaveshineSDI =
{
    // Event Name
    &WaveshineSDI_Name,
    // Event Description
    &WaveshineSDI_Desc,
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
    // Match Data
    &WaveshineSDI_MatchData,
    // Menu Data
    &WaveshineSDI_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char SlideOff_Name[] = {"L-Cancel Training\n"};
// Event Description
static char SlideOff_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char SlideOff_Tut[] = {"TvLC"};
// Event Menu Data
static char** SlideOff_Stale[] = {"Off", "On"};
static char** SlideOff_Intang[] = {"On", "Off"};
static MenuData SlideOff_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void SlideOff_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData SlideOff =
{
    // Event Name
    &SlideOff_Name,
    // Event Description
    &SlideOff_Desc,
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
    // Match Data
    &SlideOff_MatchData,
    // Menu Data
    &SlideOff_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char GrabMash_Name[] = {"L-Cancel Training\n"};
// Event Description
static char GrabMash_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char GrabMash_Tut[] = {"TvLC"};
// Event Menu Data
static char** GrabMash_Stale[] = {"Off", "On"};
static char** GrabMash_Intang[] = {"On", "Off"};
static MenuData GrabMash_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void GrabMash_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData GrabMash =
{
    // Event Name
    &GrabMash_Name,
    // Event Description
    &GrabMash_Desc,
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
    // Match Data
    &GrabMash_MatchData,
    // Menu Data
    &GrabMash_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char TechCounter_Name[] = {"L-Cancel Training\n"};
// Event Description
static char TechCounter_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char TechCounter_Tut[] = {"TvLC"};
// Event Menu Data
static char** TechCounter_Stale[] = {"Off", "On"};
static char** TechCounter_Intang[] = {"On", "Off"};
static MenuData TechCounter_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void TechCounter_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData TechCounter =
{
    // Event Name
    &TechCounter_Name,
    // Event Description
    &TechCounter_Desc,
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
    // Match Data
    &TechCounter_MatchData,
    // Menu Data
    &TechCounter_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char ArmadaShine_Name[] = {"L-Cancel Training\n"};
// Event Description
static char ArmadaShine_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char ArmadaShine_Tut[] = {"TvLC"};
// Event Menu Data
static char** ArmadaShine_Stale[] = {"Off", "On"};
static char** ArmadaShine_Intang[] = {"On", "Off"};
static MenuData ArmadaShine_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void ArmadaShine_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData ArmadaShine =
{
    // Event Name
    &ArmadaShine_Name,
    // Event Description
    &ArmadaShine_Desc,
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
    // Match Data
    &ArmadaShine_MatchData,
    // Menu Data
    &ArmadaShine_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char SideBSweet_Name[] = {"L-Cancel Training\n"};
// Event Description
static char SideBSweet_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char SideBSweet_Tut[] = {"TvLC"};
// Event Menu Data
static char** SideBSweet_Stale[] = {"Off", "On"};
static char** SideBSweet_Intang[] = {"On", "Off"};
static MenuData SideBSweet_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void SideBSweet_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData SideBSweet =
{
    // Event Name
    &SideBSweet_Name,
    // Event Description
    &SideBSweet_Desc,
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
    // Match Data
    &SideBSweet_MatchData,
    // Menu Data
    &SideBSweet_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char EscapeSheik_Name[] = {"L-Cancel Training\n"};
// Event Description
static char EscapeSheik_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char EscapeSheik_Tut[] = {"TvLC"};
// Event Menu Data
static char** EscapeSheik_Stale[] = {"Off", "On"};
static char** EscapeSheik_Intang[] = {"On", "Off"};
static MenuData EscapeSheik_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void EscapeSheik_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData EscapeSheik =
{
    // Event Name
    &EscapeSheik_Name,
    // Event Description
    &EscapeSheik_Desc,
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
    // Match Data
    &EscapeSheik_MatchData,
    // Menu Data
    &EscapeSheik_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Eggs_Name[] = {"L-Cancel Training\n"};
// Event Description
static char Eggs_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char Eggs_Tut[] = {"TvLC"};
// Event Menu Data
static char** Eggs_Stale[] = {"Off", "On"};
static char** Eggs_Intang[] = {"On", "Off"};
static MenuData Eggs_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void Eggs_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData Eggs =
{
    // Event Name
    &Eggs_Name,
    // Event Description
    &Eggs_Desc,
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
    // Match Data
    &Eggs_MatchData,
    // Menu Data
    &Eggs_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Multishine_Name[] = {"L-Cancel Training\n"};
// Event Description
static char Multishine_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char Multishine_Tut[] = {"TvLC"};
// Event Menu Data
static char** Multishine_Stale[] = {"Off", "On"};
static char** Multishine_Intang[] = {"On", "Off"};
static MenuData Multishine_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void Multishine_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData Multishine =
{
    // Event Name
    &Multishine_Name,
    // Event Description
    &Multishine_Desc,
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
    // Match Data
    &Multishine_MatchData,
    // Menu Data
    &Multishine_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Reaction_Name[] = {"L-Cancel Training\n"};
// Event Description
static char Reaction_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char Reaction_Tut[] = {"TvLC"};
// Event Menu Data
static char** Reaction_Stale[] = {"Off", "On"};
static char** Reaction_Intang[] = {"On", "Off"};
static MenuData Reaction_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void Reaction_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData Reaction =
{
    // Event Name
    &Reaction_Name,
    // Event Description
    &Reaction_Desc,
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
    // Match Data
    &Reaction_MatchData,
    // Menu Data
    &Reaction_Menu,
    // Default OSDs
    0xFFFFFFFF,
};

// L-Cancel Training
// Event Name
static char Ledgestall_Name[] = {"L-Cancel Training\n"};
// Event Description
static char Ledgestall_Desc[] = {"Practice L-Cancelling on\na stationary CPU.\n"};
// Event Tutorial Filename
static char Ledgestall_Tut[] = {"TvLC"};
// Event Menu Data
static char** Ledgestall_Stale[] = {"Off", "On"};
static char** Ledgestall_Intang[] = {"On", "Off"};
static MenuData Ledgestall_Menu[] =
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
    .timerRunOnPause = false, // 0x01
    .isHidePauseHUD = true, // 0x02
    .isShowLRAStart = true, // 0x04
    .isCheckForLRAStart = true, // 0x08
    .isShowZRetry = true, // 0x10
    .isCheckForZRetry = true, // 0x20
    .isShowAnalogStick = true, // 0x40
    .isShowScore = false, // 0x80

    .isRunStockLogic = true, // 0x20
    .isDisableHit = false, // 0x20
    .useKOCounter = false,
    .cpuFighter = 8, // 0xFF=
    .stage = 16, // 0xFFFF
    .timerSeconds = 32, // 0xFFFFFFFF
    .timerSubSeconds = 8, // 0xFF
    .onCheckPause = 0,
    .onMatchEnd = 0,
};
// Think Function
void Ledgestall_Think (GOBJ* event)
{
    return;
}
// Event Struct
static EventData Ledgestall =
{
    // Event Name
    &Ledgestall_Name,
    // Event Description
    &Ledgestall_Desc,
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
    // Match Data
    &Ledgestall_MatchData,
    // Menu Data
    &Ledgestall_Menu,
    // Default OSDs
    0xFFFFFFFF,
};







///////////////////////
/// Page Defintions ///
///////////////////////

// Minigames
static char Minigames_Name[] = {"Minigames"};
static EventData *Minigames_Events[] =
{
    &Eggs,
    &Multishine,
    &Reaction,
    &Ledgestall,
};
static EventPage Minigames_Page =
{
    Minigames_Name,
    (sizeof(Minigames_Events) / 4) - 1,
    Minigames_Events,
};

// Page 2 Events
static char General_Name[] = {"General Tech"};
static EventData *General_Events[] =
{
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
static EventPage General_Page =
{
    General_Name,
    (sizeof(General_Events) / 4) - 1,
    General_Events,
};

// Page 3 Events
static char Spacie_Name[] = {"Spacie Tech"};
static EventData *Spacie_Events[] =
{
    &TechCounter,
    &ArmadaShine,
    &SideBSweet,
    &EscapeSheik,
};
static EventPage Spacie_Page =
{
    Spacie_Name,
    (sizeof(Spacie_Events) / 4) - 1,
    Spacie_Events,
};

///////////////////////
/// Page Order ///
///////////////////////

// Page Order
static EventPage **EventPages[] =
{
    &Minigames_Page,
    &General_Page,
    &Spacie_Page,
};


///////////////////////////////
/// Member-Access Functions ///
///////////////////////////////
char *GetEventName(int page, int event)
{
    EventPage *thisPage = EventPages[page];
    EventData *thisEvent = thisPage->events[event];
    return (thisEvent->eventName);
}
char *GetEventDesc(int page, int event)
{
    EventPage *thisPage = EventPages[page];
    EventData *thisEvent = thisPage->events[event];
    return (thisEvent->eventDescription);
}
char *GetEventTut(int page, int event)
{
    EventPage *thisPage = EventPages[page];
    EventData *thisEvent = thisPage->events[event];
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
