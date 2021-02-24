#include "../../../m-ex/MexTK/mex.h"

enum InputKind
{
    INPTKIND_NONE,
    INPTKIND_MOVE,
    INPTKIND_CHANGE,
    INPTKIND_ENTER,
    INPTKIND_EXIT,
};

enum MTHStatus
{
    MTHSTATUS_NONE,
    MTHSTATUS_LOADHEADER,
    MTHSTATUS_LOADFRAMES,
    MTHSTATUS_LOADFINALIZE,
    MTHSTATUS_PLAY,
};

#define MNSLEV_MAXEVENT 9
#define MNSLEV_STARTPAGE 1
#define MNSLEV_DESCCHARMAX 50
#define MNSLEV_DESCLINEMAX 6
#define MNSLEV_DESCLINEOFFSET 30
#define MNSLEV_IMGFMT 4

typedef struct MnSlEvData
{
    JOBJSet *menu;
    COBJDesc *menu_cobj;
    JOBJSet *bg;
    void *fog;
    JOBJDesc *cursor;
    COBJDesc *movie_cobj;
} MnSlEvData;

typedef struct EventSelectData
{
    int canvas_id;
    int page;
    JOBJ *scroll_jobj;
    JOBJ *scroll_top;
    JOBJ *scroll_bot;
    GOBJ *mth_gobj;
    struct
    {
        JOBJ *jobj;
        u8 pos;
        u8 scroll;
    } cursor;
    struct
    {
        Text *page_curr;
        Text *page_next;
        Text *page_prev;
        Text *event_name;
        Text *event_desc;
    } text;
} EventSelectData;

typedef struct MTHData
{
    int status;
    int frame_num; // number of frames loaded initially
    char *next_frame_ptr;
    int next_frame_size;
} MTHData;

void Menu_Think(GOBJ *menu_gobj);
void Menu_CObjThink(GOBJ *gobj);
void MTH_Think(GOBJ *gobj);
void Menu_Animate(GOBJ *gobj);
void MTH_HeaderLoadCb();