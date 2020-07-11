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
    EventMenu *currMenu;
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
    GOBJ *custom_gobj;                   // onSelect gobj
} MenuData;
typedef struct MenuCamData
{
    GOBJ *menu;
} MenuCamData;
typedef struct EventOption
{
    u8 option_kind;                                     // the type of option this is; string, integers, etc
    u16 value_num;                                      // number of values
    u16 option_val;                                     // value of this option
    EventMenu *menu;                                    // pointer to the menu that pressing A opens
    char *option_name;                                  // pointer to the name of this option
    char *desc;                                         // pointer to the description string for this option
    void **option_values;                               // pointer to an array of strings
    void (*onOptionChange)(GOBJ *menu_gobj, int value); // function that runs when option is changed
    GOBJ *(*onOptionSelect)(GOBJ *menu_gobj);           // function that runs when option is selected
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
typedef struct EventVars
{
    EventInfo *event_info; // event information
    GOBJ *event_gobj;      // event gobj
    GOBJ *menu_gobj;       // event menu gobj
} EventVars;

// Function prototypes
EventInfo *GetEvent(int page, int event);
void EventInit(int page, int eventID, MatchData *matchData);
void EventLoad();
GOBJ *EventMenu_Init(EventInfo *eventInfo);
void EventMenu_Think(GOBJ *eventMenu, int pass);
void EventMenu_COBJThink(GOBJ *gobj);
void EventMenu_Draw(GOBJ *eventMenu);
int Text_AddSubtextManual(Text *text, char *string, int posx, int posy, int scalex, int scaley);
EventMenu *EventMenu_GetCurrentMenu(GOBJ *gobj);
void Savestate_Save();
void Savestate_Load();
void EventUpdate();
static Savestate *savestates[6];
static EventInfo *static_eventInfo;
static MenuData *static_menuData;
static EventVars event_vars;
static int *eventDataBackup;

// Labbing event
typedef struct evLcAssets
{
    JOBJDesc *stick;
} evLcAssets;
typedef struct LCancelData
{
    EventInfo *eventInfo;
    evLcAssets *assets;
    u8 cpu_state;
    u8 cpu_hitshield;
    u8 cpu_hitnum;
    u8 cpu_sincehit;
    s16 cpu_lasthit;
    s16 cpu_lastshieldstun; // last move instance of the opponent in shield stun. used to tell how many times the shield was hit
    s8 cpu_hitkind;         // how the CPU was hit, damage or shield
    u8 cpu_hitshieldnum;    // times the CPUs shield was hit
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
    Vec2 *vertices[2]; // pointer to vertex to draw
    GXColor color;     // color of this vertex
} DIDraw;
typedef struct DIDrawCalculate
{
    Vec2 pos;       // position of vertices
    int envFlags;   // environment flags
    float ECBTopY;  // used for determining middle of body
    float ECBLeftY; // used for determining middle of body
    float kb_Y;     // used to determine ceiling KOs
} DIDrawCalculate;
typedef struct TDIData
{
    JOBJ *stick_curr;
    JOBJ *stick_prev[6];
} TDIData;

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

void EvFree_ChangePlayerPercent(GOBJ *menu_gobj, int value);
void EvFree_ChangeCPUPercent(GOBJ *menu_gobj, int value);
void EvFree_ChangeModelDisplay(GOBJ *menu_gobj, int value);
void EvFree_ChangeHitDisplay(GOBJ *menu_gobj, int value);
void EvFree_ChangeEnvCollDisplay(GOBJ *menu_gobj, int value);
void EvFree_ChangeCamMode(GOBJ *menu_gobj, int value);
void EvFree_ChangeInfoPreset(GOBJ *menu_gobj, int value);
void EvFree_ChangeInfoRow(GOBJ *menu_gobj, int value);
GOBJ *EvFree_SelectCustomTDI(GOBJ *menu_gobj);
void CustomTDI_Update(GOBJ *gobj);
void EvFree_Exit(int value);
void InfoDisplay_Think(GOBJ *gobj);
void InfoDisplay_GX(GOBJ *gobj, int pass);

static EventOption EvFreeOptions_Main[];
static EventOption EvFreeOptions_General[];
static EventOption EvFreeOptions_InfoDisplay[];
static EventMenu EvFreeMenu_General;
static EventMenu EvFreeMenu_InfoDisplay;
static EventMenu EvFreeMenu_CPU;
static EventMenu EvFreeMenu_Record;

// Custom TDI definitions
#define CUSTOMTDI_DATASIZE 32

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
#define EMSTATE_WAIT 3 // pauses menu logic, used for when a custom window is being shown

// GX Link args
#define GXLINK_MENUMODEL 12
#define GXPRI_MENUMODEL 80
#define GXLINK_MENUTEXT 12
#define GXPRI_MENUTEXT GXPRI_MENUMODEL + 1
// popup menu
#define GXPRI_POPUPMODEL GXPRI_MENUTEXT + 1
#define GXLINK_POPUPMODEL 12
#define GXPRI_POPUPTEXT GXPRI_POPUPMODEL + 1
#define GXLINK_POPUPTEXT 12
// info display
#define GXPRI_INFDISP GXPRI_MENUMODEL - 2
#define GXLINK_INFDISP 12
#define GXPRI_INFDISPTEXT GXPRI_INFDISP + 1
#define GXLINK_INFDISPTEXT 12
// cobj
#define MENUCAM_COBJGXLINK (1 << GXLINK_MENUMODEL) | (1 << GXLINK_MENUTEXT) | (1 << GXLINK_POPUPMODEL) | (1 << GXLINK_POPUPTEXT)
#define MENUCAM_GXPRI 8

// menu model
#define OPT_X 0.5
#define OPT_Y -1
#define OPT_Z 0
#define OPT_SCALE 1
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

// row jobj
#define ROWBOX_HEIGHT 2.3
#define ROWBOX_WIDTH 18
#define ROWBOX_X 13
#define ROWBOX_Y 10.3
#define ROWBOX_Z 0
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
#define POPUP_Z 0.01
#define POPUP_YOFFSET -2.5
// popup text object
#define POPUP_CANVASSCALE 0.05
#define POPUP_TEXTSCALE 1
#define POPUP_TEXTZ 0.01
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

// General Options
#define OPTGEN_FRAME 0
#define OPTGEN_HMNPCNT 1
#define OPTGEN_MODEL 2
#define OPTGEN_HIT 3
#define OPTGEN_COLL 4
#define OPTGEN_CAM 5
#define OPTGEN_HUD 6
#define OPTGEN_DI 7
#define OPTGEN_INPUT 8
#define OPTGEN_STALE 9

// CPU Options
#define OPTCPU_PCNT 0
#define OPTCPU_INTANG 1
#define OPTCPU_SHIELD 2
#define OPTCPU_BEHAVE 3
#define OPTCPU_SDI 4
#define OPTCPU_TDI 5
#define OPTCPU_CUSTOMTDI 6
#define OPTCPU_TECH 7
#define OPTCPU_GETUP 8
#define OPTCPU_RESET 9
#define OPTCPU_CTRGRND 10
#define OPTCPU_CTRAIR 11
#define OPTCPU_CTRSHIELD 12
#define OPTCPU_CTRFRAMES 13
#define OPTCPU_CTRHITS 14
#define OPTCPU_SHIELDHITS 15

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
#define CPUSTATE_SDI 1
#define CPUSTATE_TDI 2
#define CPUSTATE_TECH 3
#define CPUSTATE_GETUP 4
#define CPUSTATE_COUNTER 5
#define CPUSTATE_RECOVER 6

// Behavior Definitions
#define CPUBEHAVE_STAND 0
#define CPUBEHAVE_SHIELD 1
#define CPUBEHAVE_CROUCH 2
#define CPUBEHAVE_JUMP 3

// SDI Definitions
#define CPUSDI_RANDOM 0
#define CPUSDI_NONE 1

// TDI Definitions
#define CPUTDI_RANDOM 0
#define CPUTDI_IN 1
#define CPUTDI_OUT 2
#define CPUTDI_FLOORHUG 3
#define CPUTDI_CUSTOM 4
#define CPUTDI_NONE 5
#define CPUTDI_NUM 6

// Tech Definitions
#define CPUTECH_RANDOM 0
#define CPUTECH_NEUTRAL 1
#define CPUTECH_AWAY 2
#define CPUTECH_TOWARDS 3
#define CPUTECH_NONE 4

// Getup Definitions
#define CPUGETUP_RANDOM 0
#define CPUGETUP_STAND 1
#define CPUGETUP_AWAY 2
#define CPUGETUP_TOWARD 3
#define CPUGETUP_ATTACK 4

// Stick Direction Definitions
#define STCKDIR_NONE 0
#define STCKDIR_TOWARD 1
#define STCKDIR_AWAY 2
#define STCKDIR_FRONT 3
#define STCKDIR_BACK 4

// Hit kind defintions
#define HITKIND_DAMAGE 0
#define HITKIND_SHIELD 1

// DI Draw Constants
#define DI_MaxColl 50