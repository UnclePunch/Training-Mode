#include "../../../../MexTK/mex.h"
#include "../../../tmdata/source/events.h"

// Labbing event
// Custom TDI definitions
#define TDI_HITNUM 10
#define TDI_DISPNUM 4
// menu model
#define TDIMENU_SCALE 1
#define TDIMENU_X 0
#define TDIMENU_Y 0
#define TDIMENU_Z 0
#define TDIMENU_WIDTH 55 / TDIMENU_SCALE
#define TDIMENU_HEIGHT 40 / TDIMENU_SCALE
// menu text object
#define TDITEXT_CANVASSCALE 0.05
#define TDITEXT_TEXTSCALE 1
#define TDITEXT_TEXTZ 0

// recording
#define REC_VERS 1
/*
Recording Version History:
v0 = 3.0 Alpha 1-3.
v1 = 3.0 Alpha 4. First version with importing UI. Added filename and match settings to metadata, menu settings and adjusted the playerblock and grab struct for the fighters.
v2 = not released
*/

#define GXPRI_RECJOINT 80
#define REC_GXLINK 18
#define GXPRI_RECTEXT GXPRI_RECJOINT + 1
// cobj
#define RECCAM_COBJGXLINK (1 << REC_GXLINK)
#define RECCAM_GXPRI 8
// params
#define REC_LENGTH (1 * 60 * 60)
#define REC_SLOTS 6
#define REC_SEEKJOINT 7
#define REC_LEFTBOUNDJOINT 5
#define REC_RIGHTBOUNDJOINT 6
#define REC_LEFTTEXTJOINT 2
#define REC_RIGHTTEXTJOINT 3

// export
enum export_status
{
    EXSTAT_NONE,
    EXSTAT_REQSAVE,
    EXSTAT_SAVEWAIT,
    EXSTAT_DONE,
};
enum export_menuindex
{
    EXMENU_SELCARD,
    EXMENU_NAME,
    EXMENU_CONFIRM,
};
enum export_popup
{
    EXPOP_CONFIRM,
    EXPOP_SAVE,
};
#define EXP_MEMCARDAJOBJ 9
#define EXP_MEMCARDBJOBJ 11
#define EXP_TEXTBOXJOBJ 12
#define EXP_SCREENSHOTJOBJ 18

#define EXP_KEYBOARD_X 0
#define EXP_KEYBOARD_Y 3.5
#define EXP_KEYBOARD_SIZE 1

#define EXP_FILEDETAILS_X -8
#define EXP_FILEDETAILS_Y -11.7
#define EXP_FILEDETAILS_SIZE 0.7

#define EXP_FILENAME_X -7
#define EXP_FILENAME_Y -4.8
#define EXP_FILENAME_ASPECTX 560
#define EXP_FILENAME_ASPECTY 100
#define EXP_FILENAME_SIZE 1

#define EXP_SCREENSHOT_WIDTH (640)
#define EXP_SCREENSHOT_HEIGHT (480)

#define RESIZE_MULT (0.15)
#define RESIZE_WIDTH (EXP_SCREENSHOT_WIDTH * RESIZE_MULT)
#define RESIZE_HEIGHT (EXP_SCREENSHOT_HEIGHT * RESIZE_MULT)

// input display
typedef struct ButtonLookup
{
    u8 jobj;
    u8 dobj;
} ButtonLookup;
typedef enum buttons_enum
{
    BTN_A,
    BTN_B,
    BTN_X,
    BTN_Y,
    BTN_START,
    BTN_DPADUP,
    BTN_DPADRIGHT,
    BTN_DPADLEFT,
    BTN_DPADDOWN,
    BTN_L,
    BTN_R,
    BTN_Z,
    BTN_NUM,
} buttons_enum;
static ButtonLookup button_lookup[] = {
    {1, 0},  // A
    {2, 0},  // B
    {3, 0},  // X
    {4, 0},  // Y
    {5, 0},  // Start
    {6, 1},  // Dpad Up
    {6, 2},  // Dpad Right
    {6, 3},  // Dpad Left
    {6, 4},  // Dpad Down
    {11, 0}, // L
    {12, 0}, // R
    {13, 0}, // Z
};
static GXColor button_colors[] = {
    {50, 180, 50, 255},   // A
    {255, 50, 50, 255},   // B
    {127, 127, 127, 255}, // X
    {127, 127, 127, 255}, // Y
    {192, 192, 192, 255}, // Start
    {192, 192, 192, 255}, // Dpad Up
    {192, 192, 192, 255}, // Dpad Right
    {192, 192, 192, 255}, // Dpad Left
    {192, 192, 192, 255}, // Dpad Down
    {127, 127, 127, 255}, // L
    {127, 127, 127, 255}, // R
    {0, 0, 255, 255},     // Z
};
static int button_bits[] = {
    HSD_BUTTON_A,          // A
    HSD_BUTTON_B,          // B
    HSD_BUTTON_X,          // X
    HSD_BUTTON_Y,          // Y
    HSD_BUTTON_START,      // Start
    HSD_BUTTON_DPAD_UP,    // Dpad Up
    HSD_BUTTON_DPAD_RIGHT, // Dpad Right
    HSD_BUTTON_DPAD_LEFT,  // Dpad Left
    HSD_BUTTON_DPAD_DOWN,  // Dpad Down
    HSD_TRIGGER_L,         // L
    HSD_TRIGGER_R,         // R
    HSD_TRIGGER_Z,         // Z
};
// GX
#define INPUT_GXLINK 12
#define INPUT_GXPRI 80
// params
#define INPUT_SHELL_JOBJ 14
#define INPUT_SHELL_DOBJ 0
#define INPUT_COLOR_PRESSED \
    {                       \
        255, 255, 255, 255  \
    }

typedef struct Arch_ImportData
{
    JOBJDesc *import_button;
    JOBJDesc *import_menu;
    COBJDesc *import_cam;
    JOBJDesc *import_popup;
} Arch_ImportData;
typedef struct Arch_LabData
{
    JOBJDesc *stick;
    JOBJDesc *cstick;
    void *save_icon;
    void *save_banner;
    JOBJDesc *controller;
    JOBJDesc *export_menu;
    JOBJDesc *export_popup;
} Arch_LabData;
typedef struct LCancelData
{
    EventDesc *eventInfo;
    u8 cpu_state;
    u8 cpu_hitshield;
    u8 cpu_hitnum;
    u8 cpu_sdidir;
    u8 cpu_sincehit;
    s16 cpu_lasthit;
    s16 cpu_lastshieldstun; // last move instance of the opponent in shield stun. used to tell how many times the shield was hit
    s8 cpu_hitkind;         // how the CPU was hit, damage or shield
    u8 cpu_hitshieldnum;    // times the CPUs shield was hit
    u8 cpu_isactionable;    // flag that indicates if a cpu has become actionable
    u8 cpu_groundstate;     // indicates if the player was touching ground upon being actionable
    s32 timer;
    u8 cpu_isthrown; // bool for if the cpu is being thrown
    GOBJ *rec_gobj;
    u8 hmn_controller;
    u8 cpu_controller;
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
    JOBJ *stick_curr[2];
    JOBJ *stick_prev[6][2];
    Text *text_curr;
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
typedef struct RecInputs
{
    unsigned char btn_dpadup : 1;
    unsigned char btn_a : 1;
    unsigned char btn_b : 1;
    unsigned char btn_x : 1;
    unsigned char btn_y : 1;
    unsigned char btn_L : 1;
    unsigned char btn_R : 1;
    unsigned char btn_Z : 1;
    s8 stickX;
    s8 stickY;
    s8 substickX;
    s8 substickY;
    u8 trigger;
} RecInputs;
typedef struct RecInputData
{
    int start_frame; // the frame these inputs start on
    int num;
    RecInputs inputs[REC_LENGTH]
} RecInputData;
typedef struct RecData
{
    int timer; // this is updated at runtime to know which frames inputs to use.
    int hmn_rndm_slot;
    RecInputData *hmn_inputs[REC_SLOTS];
    int cpu_rndm_slot;
    RecInputData *cpu_inputs[REC_SLOTS];
    JOBJ *seek_jobj;
    Text *text;
    float seek_left;
    float seek_right;
} RecData;
typedef struct RecordingSave
{
    MatchInit match_data; // this will point to a struct containing match info
    Savestate savestate;
    RecInputData hmn_inputs[REC_SLOTS];
    RecInputData cpu_inputs[REC_SLOTS];
} RecordingSave;
typedef struct InputData
{
    JOBJ *controller_joint[4];
    Vec2 ltrig_origin;
    Vec2 rtrig_origin;
} InputData;
typedef struct ExportData
{
    u16 menu_index;
    u16 menu_state;
    JOBJ *memcard_jobj[2];
    JOBJ *screenshot_jobj;
    JOBJ *textbox_jobj;
    RGB565 *scaled_image;
    Text *text_title;
    Text *text_desc;
    Text *text_misc;
    int slot;
    u8 is_inserted[2];
    int free_blocks[2];
    int free_files[2];
    Text *text_keyboard;
    Text *text_filename;
    Text *text_filedetails;
    u8 key_cursor[2];
    u8 filename_cursor;
    u8 caps_lock;
    char *filename_buffer;
    GOBJ *confirm_gobj;
    Text *confirm_text;
    u8 confirm_cursor;
    u8 confirm_state;
    int hmn_id;
    int cpu_id;
    int stage_id;
} ExportData;
typedef struct ExportMenuSettings
{
    u8 hmn_mode;
    u8 hmn_slot;
    u8 cpu_mode;
    u8 cpu_slot;
    u8 loop_inputs;
    u8 auto_restore;
} ExportMenuSettings;
typedef struct ExportHeader
{
    struct rec_metadata // metadata
    {
        u16 version;
        u16 image_width;
        u16 image_height;
        u16 image_fmt;
        u8 hmn;
        u8 hmn_costume;
        u8 cpu;
        u8 cpu_costume;
        u16 stage_external; // instance of the stage
        u16 stage_internal; //  unique stage
        u8 month;
        u8 day;
        u16 year;
        u8 hour;
        u8 minute;
        u8 second;
        char filename[32];
    } metadata;
    struct // lookup
    {
        int ofst_screenshot;
        int ofst_recording;
        int ofst_menusettings;
        // to-do, add menu data offset
    } lookup;
} ExportHeader;

void Event_Init(GOBJ *gobj);
void Event_Update();
void Event_Think(GOBJ *event);

void Button_Think(GOBJ *button_gobj);

void Lab_ChangePlayerPercent(GOBJ *menu_gobj, int value);
void Lab_ChangeFrameAdvance(GOBJ *menu_gobj, int value);
void Lab_ChangeCPUPercent(GOBJ *menu_gobj, int value);
void Lab_ChangeCPUIntang(GOBJ *menu_gobj, int value);
void Lab_ChangeModelDisplay(GOBJ *menu_gobj, int value);
void Lab_ChangeHitDisplay(GOBJ *menu_gobj, int value);
void Lab_ChangeEnvCollDisplay(GOBJ *menu_gobj, int value);
void Lab_ChangeCamMode(GOBJ *menu_gobj, int value);
void Lab_ChangeInfoPreset(GOBJ *menu_gobj, int value);
void Lab_ChangeInfoRow(GOBJ *menu_gobj, int value);
void Lab_ChangeInfoSizePos(GOBJ *menu_gobj, int value);
void Lab_ChangeInfoPlayer(GOBJ *menu_gobj, int value);
void Lab_ChangeHUD(GOBJ *menu_gobj, int value);
void Lab_SelectCustomTDI(GOBJ *menu_gobj);
void DIDraw_GX();
void Record_ChangeHMNSlot(GOBJ *menu_gobj, int value);
void Record_ChangeCPUSlot(GOBJ *menu_gobj, int value);
void Record_ChangeHMNMode(GOBJ *menu_gobj, int value);
void Record_ChangeCPUMode(GOBJ *menu_gobj, int value);
void Record_ChangeSlot(GOBJ *menu_gobj, int value);
void Record_MemcardSave(GOBJ *menu_gobj);
void Record_MemcardLoad(int slot, int file_no);
void Record_InitState(GOBJ *menu_gobj);
void Record_RestoreState(GOBJ *menu_gobj);
void Record_CObjThink(GOBJ *gobj);
void Record_GX(GOBJ *gobj, int pass);
void Record_Think(GOBJ *rec_gobj);
void Record_Update(int ply, RecInputData *inputs, int rec_mode);
int Record_MenuThink(GOBJ *menu_gobj);
int Record_OptimizedSave(Savestate *savestate);
int Record_OptimizedLoad(Savestate *savestate);
int Record_GetRandomSlot(RecInputData **input_data);
int Record_GOBJToID(GOBJ *gobj);
int Record_FtDataToID(FighterData *fighter_data);
int Record_BoneToID(FighterData *fighter_data, JOBJ *bone);
GOBJ *Record_IDToGOBJ(int id);
FighterData *Record_IDToFtData(int id);
JOBJ *Record_IDToBone(FighterData *fighter_data, int id);
void Snap_CObjThink(GOBJ *gobj);
void Record_StartExport(GOBJ *menu_gobj);
void Export_Init(GOBJ *menu_gobj);
int Export_Think(GOBJ *export_gobj);
void Export_Destroy(GOBJ *export_gobj);
void Export_SelCardInit(GOBJ *export_gobj);
int Export_SelCardThink(GOBJ *export_gobj);
int Export_Compress(u8 *dest, u8 *source, u32 size);
void CustomTDI_Update(GOBJ *gobj);
void CustomTDI_Destroy(GOBJ *gobj);
void Lab_Exit(int value);
void InfoDisplay_Think(GOBJ *gobj);
void InfoDisplay_GX(GOBJ *gobj, int pass);

static EventOption LabOptions_Main[];
static EventOption LabOptions_General[];
static EventOption LabOptions_InfoDisplay[];
static EventMenu LabMenu_General;
static EventMenu LabMenu_InfoDisplay;
static EventMenu LabMenu_CPU;
static EventMenu LabMenu_Record;

// info display
#define GXPRI_INFDISP GXPRI_MENUMODEL - 2
#define GXLINK_INFDISP 12
#define GXPRI_INFDISPTEXT GXPRI_INFDISP + 1
#define GXLINK_INFDISPTEXT 12

// info display jobj
#define INFDISP_WIDTH 6
#define INFDISP_SCALE 4
#define INFDISP_X -26.5
#define INFDISP_Y 21.5
#define INFDISP_Z 0.01
#define INFDISP_YOFFSET -2.5
#define INFDISP_BOTY -0.5
#define INFDISP_BOTYOFFSET -0.30
// info display text
#define INFDISPTEXT_SCALE 0.04
#define INFDISPTEXT_X 1
#define INFDISPTEXT_Y 1
#define INFDISPTEXT_YOFFSET 30

// General Options
enum gen_option
{
    OPTGEN_FRAME,
    OPTGEN_FRAMEBTN,
    OPTGEN_HMNPCNT,
    OPTGEN_MODEL,
    OPTGEN_HIT,
    OPTGEN_COLL,
    OPTGEN_CAM,
    OPTGEN_HUD,
    OPTGEN_DI,
    OPTGEN_INPUT,
    OPTGEN_STALE,
};

// CPU Options
enum cpu_option
{
    OPTCPU_PCNT,
    OPTCPU_BEHAVE,
    OPTCPU_SHIELD,
    OPTCPU_INTANG,
    OPTCPU_SDIFREQ,
    OPTCPU_SDIDIR,
    OPTCPU_TDI,
    OPTCPU_CUSTOMTDI,
    OPTCPU_TECH,
    OPTCPU_GETUP,
    OPTCPU_MASH,
    //OPTCPU_RESET,
    OPTCPU_CTRGRND,
    OPTCPU_CTRAIR,
    OPTCPU_CTRSHIELD,
    OPTCPU_CTRFRAMES,
    OPTCPU_CTRHITS,
    OPTCPU_SHIELDHITS,
};

// SDI Freq
enum sdi_freq
{
    SDIFREQ_NONE,
    SDIFREQ_LOW,
    SDIFREQ_MED,
    SDIFREQ_HIGH,
};

// SDI Freq
enum sdi_dir
{
    SDIDIR_RANDOM,
    SDIDIR_AWAY,
    SDIDIR_TOWARD,
};

// Recording Options
#define OPTREC_SAVE 0
#define OPTREC_LOAD 1
#define OPTREC_HMNMODE 2
#define OPTREC_HMNSLOT 3
#define OPTREC_CPUMODE 4
#define OPTREC_CPUSLOT 5
#define OPTREC_LOOP 6
#define OPTREC_AUTOLOAD 7

// Recording Modes
#define RECMODE_OFF 0
#define RECMODE_CTRL 1
#define RECMODE_REC 2
#define RECMODE_PLAY 3

// Info Display Options
//#define OPTINF_TOGGLE 0
#define OPTINF_PLAYER 0
#define OPTINF_SIZE 1
#define OPTINF_PRESET 2
#define OPTINF_ROW1 3

// Info Display Rows
enum infdisp_rows
{
    INFDISPROW_NONE,
    INFDISPROW_POS,
    INFDISPROW_STATE,
    INFDISPROW_FRAME,
    INFDISPROW_SELFVEL,
    INFDISPROW_KBVEL,
    INFDISPROW_TOTALVEL,
    INFDISPROW_ENGLSTICK,
    INFDISPROW_SYSLSTICK,
    INFDISPROW_ENGCSTICK,
    INFDISPROW_SYSCSTICK,
    INFDISPROW_ENGTRIGGER,
    INFDISPROW_SYSTRIGGER,
    INFDISPROW_LEDGECOOLDOWN,
    INFDISPROW_INTANGREMAIN,
    INFDISPROW_HITSTOP,
    INFDISPROW_HITSTUN,
    INFDISPROW_SHIELDHEALTH,
    INFDISPROW_SHIELDSTUN,
    INFDISPROW_GRIP,
    INFDISPROW_ECBLOCK,
    INFDISPROW_ECBBOT,
    INFDISPROW_JUMPS,
    INFDISPROW_WALLJUMPS,
    INFDISPROW_JAB,
    INFDISPROW_LINE,
    INFDISPROW_BLASTLR,
    INFDISPROW_BLASTUD,
};

// CPU States
enum cpu_state
{
    CPUSTATE_START,
    CPUSTATE_GRABBED,
    CPUSTATE_SDI,
    CPUSTATE_TDI,
    CPUSTATE_TECH,
    CPUSTATE_GETUP,
    CPUSTATE_COUNTER,
    CPUSTATE_RECOVER,
};

// Grab Escape Options
enum cpu_mash
{
    CPUMASH_NONE,
    CPUMASH_MED,
    CPUMASH_HIGH,
    CPUMASH_PERFECT,
};

#define INTANG_COLANIM 10

// Grab Escape RNG Def
#define CPUMASHRNG_MED 35
#define CPUMASHRNG_HIGH 55

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
enum STICKDIR
{
    STCKDIR_NONE,
    STCKDIR_TOWARD,
    STCKDIR_AWAY,
    STCKDIR_FRONT,
    STCKDIR_BACK,
    STICKDIR_RDM,
};

// Hit kind defintions
#define HITKIND_DAMAGE 0
#define HITKIND_SHIELD 1

// DI Draw Constants
#define DI_MaxColl 50

static char *stage_names[] = {
    "",
    "",
    "Princess Peach's Castle",
    "Rainbow Cruise",
    "Kongo Jungle",
    "Jungle Japes",
    "Great Bay",
    "Hyrule Temple",
    "Brinstar",
    "Brinstar Depths",
    "Yoshi's Story",
    "Yoshi's Island",
    "Fountain of Dreams",
    "Green Greens",
    "Corneria",
    "Venom",
    "Pokemon Stadium",
    "Poke Floats",
    "Mute City",
    "Big Blue",
    "Onett",
    "Fourside",
    "Icicle Mountain",
    "",
    "Mushroom Kingdom",
    "Mushroom Kingdom II",
    "",
    "Flat Zone",
    "Dream Land",
    "Yoshi's Island (64)",
    "Kongo Jungle (64)",
    "",
    "",
    "",
    "",
    "",
    "Battlefield",
    "Final Destination",
};

// CSS Import
s8 *onload_fileno = R13 + (-0x4670);
s8 *onload_slot = R13 + (-0x466F);
#define IMPORT_FILESPERPAGE 10
typedef enum ImportMenuStates
{
    IMP_SELCARD,
    IMP_SELFILE,
    IMP_CONFIRM,
};
typedef enum ImportConfirmKind
{
    CFRM_LOAD,
    CFRM_OLD,
    CFRM_NEW,
    CFRM_DEL,
    CFRM_ERR,
};
typedef struct FileInfo
{
    char **file_name; // pointer to file name array
    int file_size;    // number of files on card
    int file_no;      // index of this file on the card
} FileInfo;
typedef struct ImportData
{
    GOBJ *menu_gobj;
    u16 canvas;
    u8 menu_state;
    u8 cursor;
    u8 memcard_inserted[2];     // memcard inserted bools
    u16 memcard_free_files[2];  // free files on this card
    u16 memcard_free_blocks[2]; // free blocks on this card
    u16 memcard_slot;           // selected slot
    JOBJ *memcard_jobj[2];
    JOBJ *screenshot_jobj;
    JOBJ *scroll_jobj;
    JOBJ *scroll_top;
    JOBJ *scroll_bot;
    Text *title_text;
    Text *desc_text;
    Text *option_text;
    Text *filename_text;
    Text *fileinfo_text;
    int file_num;         // number of files on card
    FileInfo *file_info;  // pointer to file info array
    ExportHeader *header; // pointer to header array for the files on the current page
    u8 page;              // file page
    u8 files_on_page;     // number of files on the current page
    struct
    {
        GOBJ *gobj; // confirm gobj
        u16 canvas;
        u8 kind; // which kind of confirm dialog this is
        u8 cursor;
        Text *text;
    } confirm;
    struct
    {
        _HSD_ImageDesc *orig_image;           // pointer to jobj's original image desc
        RGB565 *image;                        // pointer to 32 byte aligned image allocation (one being displayed)
        int loaded_num;                       // number of completed snaps loaded
        u8 load_inprogress;                   // bool for if a file is being loaded
        u8 file_loading;                      // page local index of the file being loaded
        void *file_data[IMPORT_FILESPERPAGE]; // pointer to each files data
        u8 is_loaded[IMPORT_FILESPERPAGE];    // bools for which snap has been loaded
    } snap;
} ImportData;
void Button_Create();
void Button_Think(GOBJ *button_gobj);
void Menu_Confirm_Init(GOBJ *menu_gobj, int kind);
void Menu_Confirm_Think(GOBJ *menu_gobj);
void Menu_Confirm_Exit(GOBJ *menu_gobj);
GOBJ *Menu_Create();
void Menu_Think(GOBJ *menu_gobj);
#define MENUCAM_GXLINK 5
#define SIS_ID 0