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
    JOBJDesc *playback;
} evMenu;

// Structure Definitions
typedef struct EventMenu EventMenu;
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
    char *eventTutorial;
    char *eventFile;
    u8 isChooseCPU;
    u8 isSelectStage;
    u8 scoreType;
    u8 callbackPriority;
    EventMatchData *matchData;
    int defaultOSD;
} EventInfo;
typedef struct EventPage
{
    char *name;
    int eventNum;
    EventInfo **events;
} EventPage;
typedef struct EventOption
{
    u8 option_kind;                                     // the type of option this is; string, integers, etc
    u8 disable;                                         // boolean for disabling the option
    u16 value_num;                                      // number of values
    u16 option_val;                                     // value of this option
    EventMenu *menu;                                    // pointer to the menu that pressing A opens
    char *option_name;                                  // pointer to the name of this option
    char *desc;                                         // pointer to the description string for this option
    void **option_values;                               // pointer to an array of strings
    void (*onOptionChange)(GOBJ *menu_gobj, int value); // function that runs when option is changed
    GOBJ *(*onOptionSelect)(GOBJ *menu_gobj);           // function that runs when option is selected
} EventOption;
struct EventMenu
{
    char *name;           // name of this menu
    u8 option_num;        // number of options this menu contains
    u8 scroll;            // how wide to make the menu
    u8 state;             // bool used to know if this menu is focused
    u8 cursor;            // index of the option currently selected
    EventOption *options; // pointer to all of this menu's options
    EventMenu *prev;      // pointer to previous menu, used at runtime
};
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
    JOBJ *scroll_top;
    JOBJ *scroll_bot;
    GOBJ *custom_gobj;                               // onSelect gobj
    void *(*custom_gobj_think)(GOBJ *custom_gobj);   // per frame function
    void *(*custom_gobj_destroy)(GOBJ *custom_gobj); // on destroy function
} MenuData;
typedef struct FtState
{
    FighterData fighter_data[2];
    CameraBox camera[2];
    Playerblock player_block;
    int stale_queue[11];
} FtState;
typedef struct SaveState
{
    u8 is_exist;
    int frame;
    FtState *ft_state[6];
} SaveState;
typedef struct evFunction
{
    void (*Event_Init)(GOBJ *event);
    void (*Event_Update)();
    void (*Event_Think)(GOBJ *event);
    EventMenu **menu_start;
} evFunction;
typedef struct EventVars
{
    EventInfo *event_info;                       // event information
    evMenu *menu_assets;                         // menu assets
    GOBJ *event_gobj;                            // event gobj
    GOBJ *menu_gobj;                             // event menu gobj
    int game_timer;                              // amount of game frames passed
    u8 hide_menu;                                // enable this to hide the base menu. used for custom menus.
    int (*Savestate_Save)(SaveState *savestate); // function pointer to save state
    int (*Savestate_Load)(SaveState *savestate); // function pointer to load state
    evFunction evFunction;                       // event specific functions
    ArchiveInfo *event_archive;                  // event archive header
} EventVars;

// Function prototypes
EventInfo *GetEvent(int page, int event);
void EventInit(int page, int eventID, MatchData *matchData);
void EventLoad();
GOBJ *EventMenu_Init(EventInfo *eventInfo, EventMenu *start_menu);
void EventMenu_Think(GOBJ *eventMenu, int pass);
void EventMenu_COBJThink(GOBJ *gobj);
void EventMenu_Draw(GOBJ *eventMenu);
int Text_AddSubtextManual(Text *text, char *string, int posx, int posy, int scalex, int scaley);
EventMenu *EventMenu_GetCurrentMenu(GOBJ *gobj);
int Savestate_Save(SaveState *savestate);
int Savestate_Load(SaveState *savestate);
void Update_Savestates();
void EventUpdate();
void Event_IncTimer(GOBJ *gobj);
static EventInfo *static_eventInfo;
static MenuData *static_menuData;
static EventVars stc_event_vars;
static int *eventDataBackup;
static SaveState stc_savestate;

static EventVars **event_vars_ptr = R13 + (EVENT_VAR); //
static EventVars *event_vars;

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
// cobj
#define MENUCAM_COBJGXLINK (1 << GXLINK_MENUMODEL) | (1 << GXLINK_MENUTEXT) | (1 << GXLINK_POPUPMODEL) | (1 << GXLINK_POPUPTEXT)
#define MENUCAM_GXPRI 8

// menu model
#define OPT_SCALE 1
#define OPT_X 0.5
#define OPT_Y -1
#define OPT_Z 0
#define OPT_WIDTH 55 / OPT_SCALE
#define OPT_HEIGHT 40 / OPT_SCALE
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
#define MENU_DESCYPOS 12
#define MENU_DESCSCALE 1
// menu option name
#define MENU_OPTIONNAMEXPOS -430
#define MENU_OPTIONNAMEYPOS -230
// menu option value
#define MENU_OPTIONVALXPOS 250
#define MENU_OPTIONVALYPOS -230
#define MENU_TEXTYOFFSET 50
// menu highlight
#define MENUHIGHLIGHT_SCALE 1 // OPT_SCALE
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
// menu scroll
#define MENUSCROLL_SCALE 2                         // OPT_SCALE
#define MENUSCROLL_SCALEY 1.105 * MENUSCROLL_SCALE // OPT_SCALE
#define MENUSCROLL_X 22.5
#define MENUSCROLL_Y 12
#define MENUSCROLL_Z 0.01
#define MENUSCROLL_PEROPTION 1
#define MENUSCROLL_MINLENGTH -1
#define MENUSCROLL_MAXLENGTH -10
#define MENUSCROLL_COLOR \
    {                    \
        255, 211, 0, 255 \
    }

// row jobj
#define ROWBOX_HEIGHT 2.3
#define ROWBOX_WIDTH 18
#define ROWBOX_X 13
#define ROWBOX_Y 10.3
#define ROWBOX_Z 0
#define ROWBOX_YOFFSET -2.5
#define ROWBOX_COLOR       \
    {                      \
        104, 105, 129, 100 \
    }
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
