#include "../../../MexFF/mex.h"

#define EVENT_DATASIZE 128
#define TM_DATA -(50 * 4) - 4

// Structure Definitions
typedef struct
{
    char *optionName;
    char **optionValues;
    int optionValuesNum;
} MenuInfo;
typedef struct
{
    unsigned int timer : 2;
    unsigned int matchType : 3;
    unsigned int playMusic : 1;
    unsigned int hideGo : 1;
    unsigned int hideReady : 1;
    unsigned int isCreateHUD : 1;
    unsigned int isDisablePause : 1;
    unsigned int timerRunOnPause : 1;    // 0x01
    unsigned int isHidePauseHUD : 1;     // 0x02
    unsigned int isShowLRAStart : 1;     // 0x04
    unsigned int isCheckForLRAStart : 1; // 0x08
    unsigned int isShowZRetry : 1;       // 0x10
    unsigned int isCheckForZRetry : 1;   // 0x20
    unsigned int isShowAnalogStick : 1;  // 0x40
    unsigned int isShowScore : 1;        // 0x80
    unsigned int isRunStockLogic : 1;    // 0x20
    unsigned int isDisableHit : 1;       // 0x20
    unsigned int useKOCounter : 1;
    s8 playerKind;                    // -1 = use selected fighter
    s8 cpuKind;                       // -1 = no CPU
    s16 stage;                        // -1 = use selected stage
    unsigned int timerSeconds : 32;   // 0xFFFFFFFF
    unsigned int timerSubSeconds : 8; // 0xFF
    void *onCheckPause;
    void *onMatchEnd;
} EventMatchData;
typedef struct
{
    char *eventName;
    char *eventDescription;
    char *eventControls;
    char *eventTutorial;
    u8 isChooseCPU;
    u8 isSelectStage;
    u8 scoreType;
    u8 callbackPriority;
    void (*eventOnFrame)(GOBJ *gobj);
    void (*eventOnInit)(GOBJ *gobj);
    EventMatchData *matchData;
    MenuInfo *menuInfo;
    int menuOptionNum;
    int defaultOSD;
} EventInfo;
typedef struct
{
    char *name;
    int eventNum;
    EventInfo **events;
} EventPage;
typedef struct
{
    JOBJDesc *messageJoint;
} TMData;
typedef struct
{
    EventInfo *eventInfo;
    Text *menu;
    Text *controls;
    Text *description;
    s32 cursor;
    u8 *options[50];
} MenuData;

// Function prototypes
EventInfo *GetEvent(int page, int event);
void EventInit(int page, int eventID, MatchData *matchData);
void EventLoad();
void EventMenu_Init(EventInfo *eventInfo);
void EventMenu_Think(GOBJ *eventMenu);
void EventMenu_Draw(GOBJ *eventMenu);
int Text_AddSubtextManual(Text *text, char *string, int posx, int posy, int scalex, int scaley);
