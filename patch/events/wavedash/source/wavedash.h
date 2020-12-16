#include "../../../../MexTK/mex.h"
#include "../../../tmdata/source/events.h"

#define WDJOBJ_BAR 1
#define WDFRAMES 15

typedef struct WavedashData WavedashData;
typedef struct WavedashAssets WavedashAssets;

struct WavedashData
{
    EventDesc *event_desc;
    WavedashAssets *assets;
    GOBJ *hud_gobj;
    int timer;
    u8 airdodge_frame;
    u8 is_airdodge;
    u8 is_early_airdodge;
    float wd_angle;
    struct
    {
        u16 line_index;
        Vec2 pos;
    } restore;
    GXColor orig_colors[WDFRAMES];
};

typedef struct WavedashAssets
{
    JOBJ *hud;
    void **hudmatanim; // pointer to array
};

void Wavedash_HUDCamThink(GOBJ *gobj);
void Event_Exit();