#include "../../../../MexTK/mex.h"
#include "../../../tmdata/source/events.h"

#ifdef TM_DEBUG
//#define OSReport TMLOG
#endif

typedef struct LCancelData LCancelData;
typedef struct LCancelAssets LCancelAssets;

struct LCancelData
{
    EventInfo *eventInfo;
    LCancelAssets *lcancel_assets;
    struct hud
    {
        GOBJ *gobj;
        u16 lcl_success;
        u16 lcl_total;
        Text *text_time;
        Text *text_air;
        Text *text_scs;
    } hud;
};

typedef struct LCancelAssets
{
    JOBJ *hud;
    void **hudmatanim; // pointer to array
};

#define LCLTEXT_SCALE 4

void Event_Exit();