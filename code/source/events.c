#include "events.h"

void Event_Init(GOBJ *gobj)
{
    int *EventData = gobj->userdata;
    EventInfo *eventInfo = EventData[0];
    OSReport("this is %s\n", eventInfo->eventName);
    return;
}

/////////////////////
// Mod Information //
/////////////////////

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
// Event Description
static char Event_Controls[] = {"D-Pad Left = Load State\nD-Pad Right = Save State\n"};
// Event Tutorial Filename
static char LCancel_Tut[] = {"TvLC"};
// Event Menu Data
static char **LCancel_Stale[] = {"Off", "On"};
static char **LCancel_Intang[] = {"On", "Off"};
#define LCANCEL_MENUOPTIONNUM 2
static MenuInfo LCancel_Menu[] =
    {
        {
            "Stale Attacks",
            LCancel_Stale,
            sizeof(LCancel_Stale) / 4,
        },
        {
            "Intangibility",
            LCancel_Intang,
            sizeof(LCancel_Intang) / 4,
        },
};
// Match Data
static EventMatchData LCancel_MatchData =
    {
        .timer = MATCH_TIMER_COUNTUP,
        .matchType = MATCH_MATCHTYPE_TIME,
        .playMusic = false,
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
void LCancel_Think(GOBJ *event)
{
    return;
}
// Event Struct
static EventInfo LCancel =
    {
        // Event Name
        LCancel_Name,
        // Event Description
        LCancel_Desc,
        // Event Controls
        Event_Controls,
        // Event Tutorial File Name
        LCancel_Tut,
        // isChooseCPU
        false,
        // isSelectStage
        true,
        // Score Type
        0,
        // callback priority
        0,
        // Event Callback Function
        LCancel_Think,
        // Event Init Function
        Event_Init,
        // Match Data
        &LCancel_MatchData,
        // Menu Data
        &LCancel_Menu,
        // Menu Option Amount
        LCANCEL_MENUOPTIONNUM,
        // Default OSDs
        0xFFFFFFFF,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
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
        LCANCEL_MENUOPTIONNUM,
        // Default OSDs
        0xFFFFFFFF,
};

///////////////////////
/// Page Defintions ///
///////////////////////

// Minigames
static char Minigames_Name[] = {"Minigames"};
static EventInfo *Minigames_Events[] =
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
static EventInfo *General_Events[] =
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
static EventInfo *Spacie_Events[] =
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

//////////////////////
/// Init Functions ///
//////////////////////

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
    int *userdata = HSD_MemAlloc(EVENT_DATASIZE);
    GObj_AddUserData(gobj, 4, HSD_Free, userdata);
    GObj_AddProc(gobj, cb, pri);

    // store pointer to the event's data
    userdata[0] = eventInfo;

    // init the pause menu
    EventMenu_Init(eventInfo);

    // Run this event's init function
    if (eventInfo->eventOnInit != 0)
    {
        eventInfo->eventOnInit(gobj);
    }

    return;
};

void EventMenu_Init(EventInfo *eventInfo)
{
    // Ensure this event has a menu
    if (eventInfo->menuInfo == 0)
        return;

    // Create a gobj
    GOBJ *gobj = GObj_Create(0, 0, 0);
    MenuData *menuData = calloc(sizeof(MenuData));
    GObj_AddUserData(gobj, 4, HSD_Free, menuData);

    // store pointer to the gobj's data
    menuData->eventInfo = eventInfo;

    // Add per frame process
    GObj_AddProc(gobj, EventMenu_Think, 0);

    return;
};

//////////////////////
/// Hook Functions ///
//////////////////////

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
    /*
    // Create a gobj
    GOBJ *gobj = GObj_Create(0, 0, 0);
    int *userdata = HSD_MemAlloc(64);
    GObj_AddUserData(gobj, 4, HSD_Free, userdata);
    GObj_AddProc(gobj, DebugLogThink, 0);

    // Create some dev text
    DevText *text = DevelopText_CreateDataTable(13, 0, 0, 28, 40, HSD_MemAlloc(0x1000));
    DevelopText_Activate(0, text);
    text->cursorBlink = 0;
    userdata[0] = text;
    u8 color[] = {0x40, 0x50, 0x80, 180};
    DevelopText_StoreBGColor(text, &color);
    DevelopText_StoreTextScale(text, 7.5, 10);
    */

    // Create a gobj
    GOBJ *gobj = GObj_Create(0, 0, 0);
    // Create a jobj
    TMData *tmData = RTOC_PTR(TM_DATA);
    JOBJ *jobj = JOBJ_LoadJoint(tmData->messageJoint);
    // Add to gobj
    GObj_AddObject(gobj, 3, jobj);
    // Add gx_link
    GObj_AddGXLink(gobj, GXLink_Common, 7, 127);

    // Get each corner's joints
    JOBJ *corners[4];
    JOBJ_GetChild(jobj, &corners, 1, 2, 3, 4, -1);

    // Modify scale and position
    jobj->trans.Z = 20;
    corners[0]->trans.X = -10;
    corners[0]->trans.Y = 5;
    corners[1]->trans.X = 10;
    corners[1]->trans.Y = 5;
    corners[2]->trans.X = -10;
    corners[2]->trans.Y = -5;
    corners[3]->trans.X = 10;
    corners[3]->trans.Y = -5;

    // Change color
    GXColor gx_color = {0, 255, 255, 255};
    jobj->dobj->mobj->mat->diffuse = gx_color;

    return;
};

void OnBoot()
{
    // OSReport("hi this is boot\n");
    return;
};

///////////////////////////////
/// Miscellaneous Functions ///
///////////////////////////////
void EventMenu_Think(GOBJ *gobj)
{
    // Get event info
    MenuData *menuData = gobj->userdata;
    EventInfo *eventInfo = menuData->eventInfo;

    // Check if paused
    if (Pause_CheckStatus(1) == 2)
    {
        // check if text is created, create it if not
        if (menuData->menu == 0)
        {
            // draw text
            EventMenu_Draw(gobj);

            /**/ #define TEXT_BGCOLOR{0, 255, 255, 255}

            // create options background
            TMData *tmData = RTOC_PTR(TM_DATA);
            JOBJ *jobj_options = JOBJ_LoadJoint(tmData->messageJoint);
            // Add to gobj
            GObj_AddObject(gobj, 3, jobj_options);
            // Add gx_link
            GObj_AddGXLink(gobj, GXLink_Common, 11, 0);
            // Get each corner's joints
            JOBJ *corners[4];
            JOBJ_GetChild(jobj_options, &corners, 1, 2, 3, 4, -1);
// Modify scale and position
#define OPT_X 0
#define OPT_Y -1
#define OPT_WIDTH 55
#define OPT_HEIGHT 28
            jobj_options->trans.Z = 63;
            jobj_options->scale.X = 0.013;
            jobj_options->scale.Y = 0.013;
            jobj_options->scale.Z = 0.013;
            corners[0]->trans.X = -(OPT_WIDTH / 2) + OPT_X;
            corners[0]->trans.Y = (OPT_HEIGHT / 2) + OPT_Y;
            corners[1]->trans.X = (OPT_WIDTH / 2) + OPT_X;
            corners[1]->trans.Y = (OPT_HEIGHT / 2) + OPT_Y;
            corners[2]->trans.X = -(OPT_WIDTH / 2) + OPT_X;
            corners[2]->trans.Y = -(OPT_HEIGHT / 2) + OPT_Y;
            corners[3]->trans.X = (OPT_WIDTH / 2) + OPT_X;
            corners[3]->trans.Y = -(OPT_HEIGHT / 2) + OPT_Y;
            // Change color
            GXColor gx_color = TEXT_BGCOLOR;
            jobj_options->dobj->mobj->mat->diffuse = gx_color;

            // create description background
            JOBJ *jobj_desc = JOBJ_LoadJoint(tmData->messageJoint);
            // Add as child
            JOBJ_AddChild(jobj_options, jobj_desc);
            // Get each corner's joints
            JOBJ_GetChild(jobj_desc, &corners, 1, 2, 3, 4, -1);
// Modify scale and position
#define DESC_X 0
#define DESC_Y -22
#define DESC_WIDTH 60
#define DESC_HEIGHT 7
            corners[0]->trans.X = -(DESC_WIDTH / 2) + DESC_X;
            corners[0]->trans.Y = (DESC_HEIGHT / 2) + DESC_Y;
            corners[1]->trans.X = (DESC_WIDTH / 2) + DESC_X;
            corners[1]->trans.Y = (DESC_HEIGHT / 2) + DESC_Y;
            corners[2]->trans.X = -(DESC_WIDTH / 2) + DESC_X;
            corners[2]->trans.Y = -(DESC_HEIGHT / 2) + DESC_Y;
            corners[3]->trans.X = (DESC_WIDTH / 2) + DESC_X;
            corners[3]->trans.Y = -(DESC_HEIGHT / 2) + DESC_Y;
            // Change color
            GXColor desc_color = {255, 0, 0, 255};
            jobj_desc->dobj->mobj->mat->diffuse = desc_color;

            // create controls background
            JOBJ *jobj_controls = JOBJ_LoadJoint(tmData->messageJoint);
            // Add as child
            JOBJ_AddChild(jobj_options, jobj_controls);
            // Get each corner's joints
            JOBJ_GetChild(jobj_controls, &corners, 1, 2, 3, 4, -1);
// Modify scale and position
#define DESC_X 0
#define DESC_Y 21
#define DESC_WIDTH 60
#define DESC_HEIGHT 8.5
            corners[0]->trans.X = -(DESC_WIDTH / 2) + DESC_X;
            corners[0]->trans.Y = (DESC_HEIGHT / 2) + DESC_Y;
            corners[1]->trans.X = (DESC_WIDTH / 2) + DESC_X;
            corners[1]->trans.Y = (DESC_HEIGHT / 2) + DESC_Y;
            corners[2]->trans.X = -(DESC_WIDTH / 2) + DESC_X;
            corners[2]->trans.Y = -(DESC_HEIGHT / 2) + DESC_Y;
            corners[3]->trans.X = (DESC_WIDTH / 2) + DESC_X;
            corners[3]->trans.Y = -(DESC_HEIGHT / 2) + DESC_Y;
            // Change color
            GXColor controls_color = {0, 255, 0, 255};
            jobj_controls->dobj->mobj->mat->diffuse = controls_color;
        }

        else
        {
            // get player who paused
            u8 *pauseData = (u8 *)0x8046b6a0;
            u8 pauser = pauseData[1];
            // get their rapid inputs
            HSD_Pad *pad = PadGet(pauser, PADGET_MASTER);
            int inputs = pad->rapidFire;

            // check for up/down
            int isChanged = 0;
            s32 cursor = menuData->cursor;
            s32 cursor_min = 0;
            s32 cursor_max = eventInfo->menuOptionNum;
            // check for dpad down
            if ((inputs & HSD_BUTTON_DOWN) != 0)
            {
                cursor += 1;
                if (cursor >= cursor_max)
                {
                    cursor = (cursor_max - 1);
                }
                else
                {
                    isChanged = 1;
                }
            }
            // check for dpad up
            else if ((inputs & HSD_BUTTON_UP) != 0)
            {
                cursor -= 1;
                if (cursor < cursor_min)
                {
                    cursor = cursor_min;
                }
                else
                {
                    isChanged = 1;
                }
            }
            // update cursor value
            menuData->cursor = cursor;

            // check for left/right
            s8 option = menuData->options[cursor];
            s8 option_min = 0;
            s8 option_max = eventInfo->menuInfo[cursor].optionValuesNum;
            // check for dpad left
            if ((inputs & HSD_BUTTON_LEFT) != 0)
            {
                option -= 1;
                if (option < option_min)
                {
                    option = option_min;
                }
                else
                {
                    isChanged = 1;
                }
            }
            // check for dpad right
            else if ((inputs & HSD_BUTTON_RIGHT) != 0)
            {
                option += 1;
                if (option >= option_max)
                {
                    option = (option_max - 1);
                }
                else
                {
                    isChanged = 1;
                }
            }
            // update option value
            menuData->options[cursor] = option;

            // if anything changed, draw menu
            if (isChanged != 0)
            {
                EventMenu_Draw(gobj);

                // also play sfx
                SFX_PlayCommon(2);
            }
        }
    }
    // Not paused, check if text is created, and free it if so
    else
    {
        if (menuData->menu != 0)
        {
            // free text
            Text_FreeText(menuData->menu);
            menuData->menu = 0;
            Text_FreeText(menuData->controls);
            menuData->controls = 0;
            Text_FreeText(menuData->description);
            menuData->description = 0;
            // remove jobj
            GObj_FreeObject(gobj);
            GObj_DestroyGXLink(gobj);
        }
    }

    return;
}
void EventMenu_Draw(GOBJ *gobj)
{

#define MENU_CANVASSCALE 0.05
#define MENU_TEXTSCALE 1
#define MENU_EVENTXPOS 0
#define MENU_EVENTYPOS -420
#define MENU_OPTIONNAMEXPOS -250
#define MENU_OPTIONNAMEYPOS -200
#define MENU_OPTIONVALXPOS 250
#define MENU_OPTIONVALYPOS -200
#define MENU_DESCXPOS -250
#define MENU_DESCYPOS 320
#define MENU_TEXTYOFFSET 50
#define MENU_HIGHLIGHT {255, 211, 0, 255}

    // Get event info
    MenuData *menuData = gobj->userdata;
    EventInfo *eventInfo = menuData->eventInfo;

    // free text if it exists
    if (menuData->menu != 0)
    {
        // free text
        Text_FreeText(menuData->menu);
        menuData->menu = 0;
        Text_FreeText(menuData->controls);
        menuData->controls = 0;
        Text_FreeText(menuData->description);
        menuData->description = 0;
    }

    // create text
    int subtext;
    int *hudData = 0x804a1f58;
    int canvasIndex = hudData[0];
    Text *text = Text_CreateText(2, canvasIndex);
    menuData->menu = text;
    // enable align and kerning
    text->align = 1;
    text->kerning = 1;
    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;

    // Output all options
    GXColor highlight = MENU_HIGHLIGHT;
    s32 cursor = menuData->cursor;
    s32 option_max = eventInfo->menuInfo[cursor].optionValuesNum;
    for (int i = 0; i < option_max; i++)
    {
        // output option name
        float optionX = MENU_OPTIONNAMEXPOS;
        float optionY = MENU_OPTIONNAMEYPOS + (i * MENU_TEXTYOFFSET);
        int optionVal = menuData->options[i];
        subtext = Text_AddSubtext(text, optionX, optionY, eventInfo->menuInfo[i].optionName);

        // output option value
        optionX = MENU_OPTIONVALXPOS;
        optionY = MENU_OPTIONVALYPOS + (i * MENU_TEXTYOFFSET);
        subtext = Text_AddSubtext(text, optionX, optionY, eventInfo->menuInfo[i].optionValues[optionVal]);
        // highlight this if this is the cursor
        if (i == cursor)
        {
            Text_SetColor(text, subtext, &highlight);
        }
    }

    // create controls text
    Text *controls = Text_CreateText(2, canvasIndex);
    menuData->controls = controls;
    // enable align and kerning
    controls->align = 1;
    controls->kerning = 1;
    // scale canvas
    controls->scale.X = MENU_CANVASSCALE;
    controls->scale.Y = MENU_CANVASSCALE;
    // Display event name
    Text_AddSubtext(controls, MENU_EVENTXPOS, MENU_EVENTYPOS, eventInfo->eventName);

    // create description text
    Text *desc = Text_CreateText(2, canvasIndex);
    menuData->description = desc;
    // enable align and kerning
    desc->align = 1;
    desc->kerning = 1;
    // scale canvas
    desc->scale.X = MENU_CANVASSCALE;
    desc->scale.Y = MENU_CANVASSCALE;
    // Display event name
    Text_AddSubtext(desc, MENU_DESCXPOS, MENU_DESCYPOS, eventInfo->eventDescription);

    return;
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
