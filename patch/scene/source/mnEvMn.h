#include "../../../m-ex/MexTK/mex.h"

typedef struct MnSlEvData
{
    JOBJDesc *menu_jobj;
    COBJDesc *menu_cobj;
    JOBJDesc *bg_jobj;
    void *bg_anim;
} MnSlEvData;

typedef struct EventSelectData
{
    Text *page_curr;
    Text *page_next;
    Text *page_prev;
    Text *event_name;
    Text *event_desc;
} EventSelectData;

void Menu_Think(GOBJ *menu_gobj);