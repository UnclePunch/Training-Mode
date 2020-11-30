#include "../../../../MexTK/mex.h"
#include "../../../tmdata/source/events.h"

typedef struct LedgedashData LedgedashData;
typedef struct LedgedashAssets LedgedashAssets;
typedef struct LdshHitlogData LdshHitlogData;
typedef struct LdshHitboxData LdshHitboxData;

#define LSDH_TIPDURATION 1.7 * 60
#define LDSH_HITBOXNUM 30 * 4
#define LCLTEXT_SCALE 4.5
#define LCLJOBJ_BAR 4

struct LedgedashData
{
    EventDesc *event_desc;
    LedgedashAssets *assets;
    s16 ledge_line;
    s16 ledge_dir;
    s16 reset_timer;
    GOBJ *hitlog_gobj;
    CameraBox *cam;
    struct
    {
        GOBJ *gobj;
        Text *text_angle;
        Text *text_galint;
        int canvas;
        int timer;
        float airdodge_angle;
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
        s16 refresh_num;     // number of times refreshed
        u8 refresh_cond_num; // number of times tip condition has been met
        u8 refresh_displayed : 1;
        u8 is_input_release : 1;
        u8 is_input_jump : 1;
    } tip;
};

struct LedgedashAssets
{
    JOBJ *hud;
    void **hudmatanim; // pointer to array
};

struct LdshHitboxData
{
    int kind;
    float size;
    Vec3 pos_curr;
    Vec3 pos_prev;
};

struct LdshHitlogData
{
    int num;
    LdshHitboxData hitlog[LDSH_HITBOXNUM];
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

void Event_Exit();
void Tips_Toggle(GOBJ *menu_gobj, int value);
void Ledgedash_ToggleStartPosition(GOBJ *menu_gobj, int value);
void Ledgedash_ToggleAutoReset(GOBJ *menu_gobj, int value);
void Ledgedash_HUDCamThink(GOBJ *gobj);
GOBJ *Ledgedash_HitLogInit();
void Ledgedash_HitLogGX(GOBJ *gobj, int pass);
void RebirthWait_Phys(GOBJ *fighter);
int RebirthWait_IASA(GOBJ *fighter);
int Ledge_Find(int search_dir, float xpos_start, float *ledge_dir);