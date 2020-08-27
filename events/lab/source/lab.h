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
#define GXPRI_RECJOINT 80
#define GXLINK_RECJOINT 13
#define GXPRI_RECTEXT GXPRI_RECJOINT + 1
#define GXLINK_RECTEXT 13
// cobj
#define RECCAM_COBJGXLINK (1 << GXLINK_RECJOINT) | (1 << GXLINK_RECTEXT)
#define RECCAM_GXPRI 8
// params
#define REC_LENGTH (1 * 60 * 60)
#define REC_SLOTS 6
#define REC_SEEKJOINT 7
#define REC_LEFTBOUNDJOINT 5
#define REC_RIGHTBOUNDJOINT 6
#define REC_LEFTTEXTJOINT 2
#define REC_RIGHTTEXTJOINT 3

typedef struct LabData
{
    JOBJDesc *stick;
    JOBJDesc *cstick;
    void *save_icon;
    void *save_banner;
} LabData;
typedef struct LCancelData
{
    EventInfo *eventInfo;
    u8 cpu_state;
    u8 cpu_hitshield;
    u8 cpu_hitnum;
    u8 cpu_sincehit;
    s16 cpu_lasthit;
    s16 cpu_lastshieldstun; // last move instance of the opponent in shield stun. used to tell how many times the shield was hit
    s8 cpu_hitkind;         // how the CPU was hit, damage or shield
    u8 cpu_hitshieldnum;    // times the CPUs shield was hit
    u8 cpu_isactionable;    // flag that indicates if a cpu has become actionable
    u8 cpu_groundstate;     // indicates if the player was touching ground upon being actionable
    s32 timer;
    u8 tdi_val_num;                // number of custom tdi values set
    s8 tdi_vals[TDI_HITNUM][2][2]; // contains the custom tdi values
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
    MatchData match_data; // this will point to a struct containing match info
    Savestate savestate;
    RecInputData hmn_inputs[REC_SLOTS];
    RecInputData cpu_inputs[REC_SLOTS];
} RecordingSave;

void Event_Init(GOBJ *gobj);
void Event_Update();
void Event_Think(GOBJ *event);

void Lab_ChangePlayerPercent(GOBJ *menu_gobj, int value);
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
void Record_MemcardLoad(GOBJ *menu_gobj);
void Record_InitState(GOBJ *menu_gobj);
void Record_RestoreState(GOBJ *menu_gobj);
void Record_CObjThink(GOBJ *gobj);
void Record_GX(GOBJ *gobj, int pass);
void Record_Think(GOBJ *rec_gobj);
void Record_Update(int ply, RecInputData *inputs, int rec_mode);
int Record_OptimizedSave(Savestate *savestate);
int Record_OptimizedLoad(Savestate *savestate);
int Record_GetRandomSlot(RecInputData **input_data);
int Record_GOBJToID(GOBJ *gobj);
int Record_FtDataToID(FighterData *fighter_data);
int Record_BoneToID(FighterData *fighter_data, JOBJ *bone);
GOBJ *Record_IDToGOBJ(int id);
FighterData *Record_IDToFtData(int id);
JOBJ *Record_IDToBone(FighterData *fighter_data, int id);
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
    OPTCPU_SDI,
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