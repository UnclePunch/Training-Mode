#include "../../../MexTK/mex.h"

#define EVENT_DATASIZE 128
#define TM_DATA -(50 * 4) - 4
#define MENU_MAXOPTION 9
#define MENU_POPMAXOPTION 5

// Custom File Structs
typedef struct TMData
{
    JOBJDesc *messageJoint;
} TMData;
typedef struct evMenu
{
    JOBJDesc *menu;
    JOBJDesc *popup;
    JOBJDesc *scroll;
    JOBJDesc *check;
    JOBJDesc *arrow;
} evMenu;

// Structure Definitions
typedef struct EventMenu EventMenu;
typedef struct MenuInfo
{
    char *optionName;
    char **optionValues;
    int optionValuesNum;
} MenuInfo;
typedef struct EventMatchData
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
typedef struct EventInfo
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
    void (*eventUpdate)();
    EventMatchData *matchData;
    EventMenu *startMenu;
    int menuOptionNum;
    int defaultOSD;
} EventInfo;
typedef struct EventPage
{
    char *name;
    int eventNum;
    EventInfo **events;
} EventPage;
typedef struct MenuData
{
    EventInfo *eventInfo;
    u16 canvas_menu;
    u16 canvas_popup;
    u8 isPaused;
    Text *text_name;
    Text *text_value;
    Text *text_popup;
    Text *text_title;
    Text *text_desc;
    u16 popup_cursor;
    u16 popup_scroll;
    GOBJ *popup;
    evMenu *menu_assets;
    JOBJ *row_joints[MENU_MAXOPTION][2]; // pointers to row jobjs
    JOBJ *highlight_menu;                // pointer to the highlight jobj
    JOBJ *highlight_popup;               // pointer to the highlight jobj
} MenuData;
typedef struct EventOption
{
    u8 option_kind;                    // the type of option this is; string, integers, etc
    u16 value_num;                     // number of values
    u16 option_val;                    // value of this option
    EventMenu *menu;                   // pointer to the menu that pressing A opens
    char *option_name;                 // pointer to the name of this option
    char *desc;                        // pointer to the description string for this option
    void **option_values;              // pointer to an array of strings
    void (*onOptionChange)(int value); // function that runs when option is changed
} EventOption;
typedef struct EventMenu
{
    char *name;           // name of this menu
    u8 option_num;        // number of options this menu contains
    u8 scroll;            // how wide to make the menu
    u8 state;             // bool used to know if this menu is focused
    u8 cursor;            // index of the option currently selected
    EventOption *options; // pointer to all of this menu's options
    EventMenu *prev;      // pointer to previous menu, used at runtime
} EventMenu;

typedef struct Savestate
{
    FighterData fighter_data[2];
    CameraBox camera[2];
    Playerblock player_block;
    int stale_queue[11];
} Savestate;

// Function prototypes
EventInfo *GetEvent(int page, int event);
void EventInit(int page, int eventID, MatchData *matchData);
void EventLoad();
void EventMenu_Init(EventInfo *eventInfo);
void EventMenu_Think(GOBJ *eventMenu, int pass);
void EventMenu_Draw(GOBJ *eventMenu);
int Text_AddSubtextManual(Text *text, char *string, int posx, int posy, int scalex, int scaley);
EventMenu *EventMenu_GetCurrentMenu(GOBJ *gobj);
static Savestate *savestates[6];
static int *eventDataBackup;
void Savestate_Save();
void Savestate_Load();

// Labbing event
typedef struct LCancelData
{
    EventInfo *eventInfo;
    u8 cpu_state;
    u8 cpu_hitshield;
    u8 cpu_hitcount;
    u8 cpu_sincehit;
    s16 cpu_lasthit;
    s32 timer;
} LCancelData;
typedef struct InfoDisplayData
{
    JOBJ *menuModel;
    JOBJ *botLeftEdge;
    JOBJ *botRightEdge;
    Text *text;
} InfoDisplayData;
typedef struct DIDraw
{
    int num[2];        // number of vertices
    Vec2 *vertices[2]; // pointer to vertices to draw
} DIDraw;
typedef struct CPUAction
{
    u16 state;                  // state to perform this action. -1 for last
    u8 frameLow;                // first possible frame to perform this action
    u8 frameHi;                 // last possible frame to perfrom this action
    s8 stickX;                  // left stick X value
    s8 stickY;                  // left stick Y value
    s8 cstickX;                 // c stick X value
    s8 cstickY;                 // c stick Y value
    int input;                  // button to input
    unsigned char isLast : 1;   // flag to indicate this was the final input
    unsigned char stickDir : 3; // 0 = none, 1 = towards opponent, 2 = away from opponent, 3 = forward, 4 = backward

} CPUAction;

void EvFree_ChangePlayerPercent(int value);
void EvFree_ChangeCPUPercent(int value);
void EvFree_ChangeModelDisplay(int value);
void EvFree_ChangeHitDisplay(int value);
void EvFree_ChangeEnvCollDisplay(int value);
void EvFree_ChangeCamMode(int value);
void EvFree_ChangeInfoPreset(int value);
void EvFree_ChangeInfoRow(int value);
void EvFree_Exit(int value);
void InfoDisplay_Think(GOBJ *gobj);
void InfoDisplay_GX(GOBJ *gobj, int pass);

static DIDraw didraws[6];
static EventOption EvFreeOptions_Main[];
static EventOption EvFreeOptions_General[];
static EventOption EvFreeOptions_InfoDisplay[];
static EventMenu EvFreeMenu_General;
static EventMenu EvFreeMenu_InfoDisplay;
static EventMenu EvFreeMenu_CPU;
static EventMenu EvFreeMenu_Record;

// EventOption option_kind definitions
#define OPTKIND_MENU 0
#define OPTKIND_STRING 1
#define OPTKIND_INT 2
#define OPTKIND_FLOAT 3
#define OPTKIND_FUNC 4

// EventMenu state definitions
#define EMSTATE_FOCUS 0
#define EMSTATE_OPENSUB 1
#define EMSTATE_OPENPOP 2

// GX Link args
#define GXPRI_MENUMODEL 80
#define GXRENDER_MENUMODEL 11
#define GXPRI_MENU GXPRI_MENUMODEL + 1
#define GXRENDER_MENU 11
// popup menu
#define GXPRI_POPUPMODEL GXPRI_MENU + 1
#define GXRENDER_POPUPMODEL 11
#define GXPRI_POPUP GXPRI_POPUPMODEL + 1
#define GXRENDER_POPUP 11
// info display
#define GXPRI_INFDISPTEXT GXPRI_MENUMODEL - 1
#define GXRENDER_INFDISPTEXT 11
#define GXPRI_INFDISP GXPRI_INFDISPTEXT - 1
#define GXRENDER_INFDISP 11

// menu model
#define OPT_X 0.5
#define OPT_Y -1
#define OPT_Z 0
#define OPT_WIDTH 55
#define OPT_HEIGHT 40
// menu text object
#define MENU_CANVASSCALE 0.05
#define MENU_TEXTSCALE 1
#define MENU_TEXTZ 0
// menu title
#define MENU_TITLEXPOS -430
#define MENU_TITLEYPOS -366
#define MENU_TITLESCALE 2.3
// menu description
#define MENU_DESCXPOS -21.5
#define MENU_DESCYPOS 13
#define MENU_DESCSCALE 1
// menu option name
#define MENU_OPTIONNAMEXPOS -430
#define MENU_OPTIONNAMEYPOS -230
// menu option value
#define MENU_OPTIONVALXPOS 250
#define MENU_OPTIONVALYPOS -230
#define MENU_TEXTYOFFSET 50
// menu highlight
#define MENUHIGHLIGHT_HEIGHT ROWBOX_HEIGHT
#define MENUHIGHLIGHT_WIDTH (OPT_WIDTH * 0.785)
#define MENUHIGHLIGHT_X OPT_X
#define MENUHIGHLIGHT_Y 10.3
#define MENUHIGHLIGHT_Z 0.01
#define MENUHIGHLIGHT_YOFFSET ROWBOX_YOFFSET
#define MENUHIGHLIGHT_COLOR \
    {                       \
        255, 211, 0, 255    \
    }

// info display jobj
#define INFDISP_WIDTH 7
#define INFDISP_SCALE 4
#define INFDISP_X -3.2
#define INFDISP_Y 20
#define INFDISP_Z 0.01
#define INFDISP_YOFFSET -2.5
#define INFDISP_BOTY -0.5
#define INFDISP_BOTYOFFSET -0.30
// info display text
#define INFDISPTEXT_SCALE 0.04
#define INFDISPTEXT_X -25.5
#define INFDISPTEXT_Y -21
#define INFDISPTEXT_YOFFSET 30

// row jobj
#define ROWBOX_HEIGHT 2.3
#define ROWBOX_WIDTH 18
#define ROWBOX_X 13
#define ROWBOX_Y 10.3
#define ROWBOX_Z 0.01
#define ROWBOX_YOFFSET -2.5
// arrow jobj
#define TICKBOX_SCALE 1.8
#define TICKBOX_X 11.7
#define TICKBOX_Y 11.7

// popup model
#define POPUP_WIDTH ROWBOX_WIDTH
#define POPUP_HEIGHT 19
#define POPUP_SCALE 1
#define POPUP_X 13
#define POPUP_Y 7.8
#define POPUP_Z 0
#define POPUP_YOFFSET -2.5
// popup text object
#define POPUP_CANVASSCALE 0.05
#define POPUP_TEXTSCALE 1
#define POPUP_TEXTZ 0
// popup text
#define POPUP_OPTIONVALXPOS 250
#define POPUP_OPTIONVALYPOS -280
#define POPUP_TEXTYOFFSET 50
// popup highlight
#define POPUPHIGHLIGHT_HEIGHT ROWBOX_HEIGHT
#define POPUPHIGHLIGHT_WIDTH (POPUP_WIDTH * 0.785)
#define POPUPHIGHLIGHT_X 0
#define POPUPHIGHLIGHT_Y 5
#define POPUPHIGHLIGHT_Z 1
#define POPUPHIGHLIGHT_YOFFSET ROWBOX_YOFFSET
#define POPUPHIGHLIGHT_COLOR \
    {                        \
        255, 211, 0, 255     \
    }

// General Options
#define OPTGEN_HMNPCNT 0
#define OPTGEN_CPUPCNT 1
#define OPTGEN_FRAME 2
#define OPTINF_INFO 3
#define OPTGEN_MODEL 4
#define OPTGEN_HIT 5
#define OPTGEN_COLL 6
#define OPTGEN_CAM 7
#define OPTGEN_HUD 8
#define OPTGEN_DI 9
#define OPTGEN_INPUT 10
#define OPTGEN_STALE 11

// CPU Options
#define OPTCPU_INTANG 0
#define OPTCPU_SHIELD 1
#define OPTCPU_BEHAVE 2
#define OPTCPU_TECH 3
#define OPTCPU_TDI 4
#define OPTCPU_SDI 5
#define OPTCPU_RESET 6
#define OPTCPU_CTRGRND 7
#define OPTCPU_CTRAIR 8
#define OPTCPU_CTRHITS 9
#define OPTCPU_CTRFRAMES 10

// Recording Options
#define OPTREC_SLOT 0
#define OPTREC_MODE 1
#define OPTREC_RESET 2

// Info Display Options
#define OPTINF_TOGGLE 0
#define OPTINF_PLAYER 1
#define OPTINF_PRESET 2
#define OPTINF_ROW1 3

// CPU States
#define CPUSTATE_START 0
#define CPUSTATE_DMG 1
#define CPUSTATE_COUNTER 2

// Tech Definitions
#define CPUTECH_RANDOM 0
#define CPUTECH_NEUTRAL 1
#define CPUTECH_AWAY 2
#define CPUTECH_TOWARDS 3
#define CPUTECH_NONE 4

// SDI Definitions
#define CPUSDI_RANDOM 0
#define CPUSDI_NONE 1

// TDI Definitions
#define CPUTDI_RANDOM 0
#define CPUTDI_SURVIVAL 1
#define CPUTDI_COMBO 2
#define CPUTDI_FLOORHUG 3
#define CPUTDI_NONE 4

// Stick Direction Definitions
#define STCKDIR_NONE 0
#define STCKDIR_TOWARD 1
#define STCKDIR_AWAY 2
#define STCKDIR_FRONT 3
#define STCKDIR_BACK 4