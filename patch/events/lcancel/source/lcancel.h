#include "../../../../MexTK/mex.h"
#include "../../../tmdata/source/events.h"

typedef struct LCancelData LCancelData;
typedef struct LCancelAssets LCancelAssets;

struct LCancelData
{
    EventDesc *event_desc;
    LCancelAssets *lcancel_assets;
    GOBJ *barrel_gobj;
    Vec3 barrel_lastpos;
    u8 is_fail;        // status of the last l-cancel
    u8 is_fastfall;    // bool used to detect fastfall frame
    u8 fastfall_frame; // frame the player fastfell on
    struct
    {
        GOBJ *gobj;
        u16 lcl_success;
        u16 lcl_total;
        Text *text_time;
        Text *text_air;
        Text *text_scs;
        int canvas;
        float arrow_base_x; // starting X position of arrow
        float arrow_prevpos;
        float arrow_nextpos;
        int arrow_timer;
    } hud;
    struct
    {
        u8 shield_isdisp;   // whether tip has been shown to the player
        u8 shield_num;      // number of times condition has been met
        u8 hitbox_active;   // whether or not the last aerial used had a hitbox active
        u8 hitbox_isdisp;   // whether tip has been shown to the player
        u8 hitbox_num;      // number of times condition has been met
        u8 fastfall_active; // whether or not the last aerial used had a hitbox active
        u8 fastfall_isdisp; // whether tip has been shown to the player
        u8 fastfall_num;    // number of times condition has been met
        u8 late_isdisp;     // whether tip has been shown to the player
        u8 late_num;        // number of times condition has been met
    } tip;
};

typedef struct LCancelAssets
{
    JOBJ *hud;
    void **hudmatanim; // pointer to array
};

#define LCLTEXT_SCALE 4.2
#define LCLARROW_ANIMFRAMES 4
#define LCLARROW_JOBJ 7
#define LCLARROW_OFFSET 0.365

static void *item_callbacks[];
float Bezier(float time, float start, float end);
void Tips_Toggle(GOBJ *menu_gobj, int value);
void LCancel_HUDCamThink(GOBJ *gobj);
void Barrel_Think(LCancelData *event_data);
void Barrel_Toggle(GOBJ *menu_gobj, int value);
GOBJ *Barrel_Spawn(int pos_kind);
void Barrel_Null();
void Event_Exit();