#include "../../../m-ex/MexTK/mex.h"
#include "../../tm.h"

GOBJ *EventMenu_Init(EventDesc *event_desc, EventMenu *start_menu);
void EventMenu_Think(GOBJ *eventMenu, int pass);
void EventMenu_COBJThink(GOBJ *gobj);
void EventMenu_Draw(GOBJ *eventMenu);
int Text_AddSubtextManual(Text *text, char *string, int posx, int posy, int scalex, int scaley);
EventMenu *EventMenu_GetCurrentMenu(GOBJ *gobj);
int Savestate_Save(Savestate *savestate);
int Savestate_Load(Savestate *savestate);
void Update_Savestates();
int GOBJToID(GOBJ *gobj);
int FtDataToID(FighterData *fighter_data);
int BoneToID(FighterData *fighter_data, JOBJ *bone);
GOBJ *IDToGOBJ(int id);
FighterData *IDToFtData(int id);
JOBJ *IDToBone(FighterData *fighter_data, int id);
void EventUpdate();
void Event_IncTimer(GOBJ *gobj);
void Test_Think(GOBJ *gobj);
static EventDesc *static_eventInfo;
static MenuData *static_menuData;
static EventCommonData stc_evco_data;

// Message
void Message_Init();
GOBJ *Message_Display(int msg_kind, int queue_num, int msg_color, char *format, ...);
void Message_Manager(GOBJ *mngr_gobj);
void Message_Destroy(GOBJ **msg_queue, int msg_num);
void Message_Add(GOBJ *msg_gobj, int queue_num);
void Message_CObjThink(GOBJ *gobj);
float BezierBlend(float t);

#define MSGQUEUE_NUM 7
#define MSGQUEUE_SIZE 5
#define MSGQUEUE_GENERAL 6
static GOBJ *stc_msgmgr;
typedef struct MsgMngrData
{
    COBJ *cobj;
    int state;
    int canvas;
    GOBJ *msg_queue[MSGQUEUE_NUM][MSGQUEUE_SIZE]; // array 7 is for miscellaneous messages, not related to a player
} MsgMngrData;

static float stc_msg_queue_offsets[] = {5.15, 5.15, 5.15, 5.15, 5.15, 5.15, -5.15}; // Y offsets for each message in the queue
static Vec3 stc_msg_queue_general_pos = {-21, 18.5, 0};
static GXColor stc_msg_colors[] = {
    {255, 255, 255, 255},
    {141, 255, 110, 255},
    {255, 162, 186, 255},
    {255, 240, 0, 255},
};

#define MSGTIMER_SHIFT 6
#define MSGTIMER_DELETE 6
#define MSG_LIFETIME (2 * 60)
#define MSG_LINEMAX 3  // lines per message
#define MSG_CHARMAX 32 // characters per line
#define MSG_HUDYOFFSET 8
#define MSGJOINT_SCALE 3
#define MSGJOINT_X 0
#define MSGJOINT_Y 0
#define MSGJOINT_Z 0
#define MSGTEXT_BASESCALE 1.4
#define MSGTEXT_BASEWIDTH (330 / MSGTEXT_BASESCALE)
#define MSGTEXT_BASEX 0
#define MSGTEXT_BASEY -1
#define MSGTEXT_YOFFSET 30

// dialogue stuff
static GOBJ *stc_dialogue;
enum DialogueState
{
    DLGSTATE_START,  // spawning animation
    DLGSTATE_SCROLL, // scrolling text
    DLGSTATE_WAIT,   // wait for input
    DLGSTATE_EXIT,   // ending animation

};
typedef struct DialogueData
{
    int state;          // box state
    int index;          // string index currently displaying
    int canvas;         //
    char **string_data; // string array for all dialogue
    int scroll_timer;   // scroll timer
    Text *text;         // text object pointer
    int char_num;       // number of characters in the current string
} DialogueData;
#define DLG_SIS 3
#define DLG_GXLINK 8
#define DLG_GXPRI 81
#define DLG_LINEMAX 3
#define DLG_CHARMAX 64

// GX stuff
#define MSG_GXLINK 13
#define MSG_GXPRI 80
#define MSGTEXT_GXPRI MSG_GXPRI + 1
#define MSG_COBJLGXLINKS (1 << MSG_GXLINK)
#define MSG_COBJLGXPRI 8

// misc function declarations
int Tip_Display(int lifetime, char *fmt, ...);
void Tip_Destroy(); // 0 = immediately destroy, 1 = force exit
void Tip_Think(GOBJ *gobj);
void Dialogue_Create(char **string_data);
void Dialogue_Think(GOBJ *dialogue_gobj);
void Dialogue_Destroy(DialogueData *dialogue_data);
int Dialogue_CheckEnd();

#define TIP_TXTJOINT 2
