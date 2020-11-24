#include "../../../../MexTK/mex.h"
#include "../../../tmdata/source/events.h"

typedef struct LedgedashData LedgedashData;
typedef struct LedgedashAssets LedgedashAssets;

struct LedgedashData
{
    EventDesc *event_desc;
    LedgedashAssets *assets;
    s16 ledge_line;
    s16 ledge_dir;
    struct
    {
        GOBJ *gobj;
        Text *text_angle;
        Text *text_galint;
        int canvas;
        int timer;
        u8 is_release : 1;
        u8 is_jump : 1;
        u8 is_airdodge : 1;
        u8 is_aerial : 1;
        u8 is_land : 1;
        u8 is_actionable : 1;
        u16 release_frame;
        u16 jump_frame;
        u16 airdodge_frame;
        u16 aerial_frame;
        u16 land_frame;
        u16 actionable_frame;
        u8 action_log[30];
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

typedef enum LDSH_ACTION
{
    LDACT_NONE,
    LDACT_CLIFFWAIT,
    LDACT_FALL,
    LDACT_JUMP,
    LDACT_AIRDODGE,
    LDACT_ATTACK,
    LDACT_LANDING,
};

#define LCLTEXT_SCALE 4
#define LCLJOBJ_BAR 4

void Event_Exit();
void LedgedashHUDCamThink(GOBJ *gobj);
int Ledge_Find(int search_dir, float xpos_start, float *ledge_dir);