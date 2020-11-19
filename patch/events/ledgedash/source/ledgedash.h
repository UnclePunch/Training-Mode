#include "../../../../MexTK/mex.h"
#include "../../../tmdata/source/events.h"

typedef struct LedgedashData LedgedashData;
typedef struct LedgedashAssets LedgedashAssets;

struct LedgedashData
{
    EventDesc *event_desc;
    LedgedashAssets *assets;
    float ledge_pos;
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

typedef struct LedgedashAssets
{
    JOBJ *hud;
    void **hudmatanim; // pointer to array
};

#define LCLTEXT_SCALE 4

void Event_Exit();
void LedgedashHUDCamThink(GOBJ *gobj);
int Ledge_Find(int search_dir, float xpos_start, float *ledge_dir);