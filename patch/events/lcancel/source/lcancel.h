#include "../../../../MexTK/mex.h"
#include "../../../tmdata/source/events.h"

typedef struct LCancelData LCancelData;
typedef struct LCancelAssets LCancelAssets;

struct LCancelData
{
    EventInfo *eventInfo;
    LCancelAssets *lcancel_assets;
    GOBJ *barrel_gobj;
    Vec3 barrel_lastpos;
    int is_fail; // status of the last l-cancel
    struct
    {
        GOBJ *gobj;
        u16 lcl_success;
        u16 lcl_total;
        Text *text_time;
        Text *text_air;
        Text *text_scs;
        int canvas;
    } hud;
    struct
    {
        GOBJ *gobj;       // tip gobj
        Text *text;       // tip text object
        int state;        // state this tip is in. 0 = in, 1 = wait, 2 = out
        int lifetime;     // tips time spent onscreen
        u8 shield_isdisp; // whether tip has been shown to the player
        u8 shield_num;    // number of times condition has been met
        u8 hitbox_active; // whether or not the last aerial used had a hitbox active
        u8 hitbox_isdisp; // whether tip has been shown to the player
        u8 hitbox_num;    // number of times condition has been met
    } tip;
};

typedef struct LCancelAssets
{
    JOBJ *hud;
    void **hudmatanim; // pointer to array
    JOBJ *tip_jobj;
    void **tip_jointanim; // pointer to array
};

typedef struct TipData
{
    Text *text;
    int lifetime;
} TipData;

#define LCLTEXT_SCALE 4

static void *item_callbacks[];
int Tips_Create(LCancelData *event_data, int lifetime, char *fmt, ...);
void LCancel_HUDCamThink(GOBJ *gobj);
void Barrel_Think(LCancelData *event_data);
void Barrel_Toggle(GOBJ *menu_gobj, int value);
GOBJ *Barrel_Spawn(int pos_kind);
void Barrel_Null();
void Event_Exit();