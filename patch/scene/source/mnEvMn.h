#include "../../../m-ex/MexTK/mex.h"

enum InputKind
{
    INPTKIND_NONE,
    INPTKIND_MOVE,
    INPTKIND_CHANGE,
    INPTKIND_ENTER,
    INPTKIND_EXIT,
};

#define MNSLEV_MAXEVENT 9
#define MNSLEV_STARTPAGE 1
#define MNSLEV_DESCCHARMAX 50
#define MNSLEV_DESCLINEMAX 6
#define MNSLEV_DESCLINEOFFSET 30
#define MNSLEV_IMGFMT 6

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

void Menu_Think(GOBJ *menu_gobj);
void Menu_CObjThink(GOBJ *gobj);
void MTH_Think(GOBJ *gobj);