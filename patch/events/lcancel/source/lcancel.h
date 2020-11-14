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
    GOBJ *barrel_gobj;
    Vec3 barrel_lastpos;
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

static void *item_callbacks[];
void Barrel_Think(LCancelData *event_data);
void Barrel_Toggle(GOBJ *menu_gobj, int value);
GOBJ *Barrel_Spawn(int pos_kind);
void Barrel_Null();
void Event_Exit();