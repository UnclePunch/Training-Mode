#include "../../../m-ex/MexTK/mex.h"

typedef struct MnSlEvData
{
    JOBJDesc *menu_jobj;
    COBJDesc *menu_cobj;
    JOBJSet *bg;
    void *fog;
} MnSlEvData;

typedef struct EventSelectData
{
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