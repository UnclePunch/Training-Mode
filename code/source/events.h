#include "../../../MexFF/mex.h"

// Structure Definitions
typedef struct
{
    char *optionName;
    char **optionValues;
    int optionValuesNum;
}MenuData;
typedef struct
{
    unsigned int timer : 2;
    unsigned int matchType : 3;
    unsigned int playMusic : 1;
    unsigned int hideGo : 1;
    unsigned int hideReady : 1;
    unsigned int isCreateHUD : 1;
    unsigned int isDisablePause : 1;
    unsigned int timerRunOnPause : 1; // 0x01
    unsigned int isHidePauseHUD : 1; // 0x02
    unsigned int isShowLRAStart : 1; // 0x04
    unsigned int isCheckForLRAStart : 1; // 0x08
    unsigned int isShowZRetry : 1; // 0x10
    unsigned int isCheckForZRetry : 1; // 0x20
    unsigned int isShowAnalogStick : 1; // 0x40
    unsigned int isShowScore : 1; // 0x80
    unsigned int isRunStockLogic : 1; // 0x20
    unsigned int isDisableHit : 1; // 0x20
    unsigned int useKOCounter : 1;
    s8 fighter;    // -1 = use selected fighter
    s8 cpuFighter;    // -1 = use selected CPU
    s16 stage;        // -1 = use selected stage
    unsigned int timerSeconds : 32; // 0xFFFFFFFF
    unsigned int timerSubSeconds : 8; // 0xFF
    void *onCheckPause;
    void *onMatchEnd;
}EventMatchData;
typedef struct
{
    char* eventName;
    char* eventDescription;
    char* eventTutorial;
    u8 isChooseCPU;
    u8 isSelectStage;
    u8 scoreType;
    u8 callbackPriority;
    void* eventCallback;
    EventMatchData* matchData;
    MenuData *menuData;
    int defaultOSD;
}EventData;
typedef struct
{
    char *name;
    int eventNum;
    EventData **events;
}EventPage;

// Function prototypes
EventData *GetEvent(int page, int event);
void EventInit(int page, int eventID, MatchData *matchData);
