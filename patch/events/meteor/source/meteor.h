#include "../../../../m-ex/MexTK/mex.h"
#include "../../../tm.h"

#define HUD_LEFTJOINT 3
#define HUD_SLIDERJOINT 4
#define HUD_RIGHTJOINT 5
#define HUD_INPUTARROWJOINT 6
#define HUD_INPUTTEXTJOINT 8

typedef struct MeteorData MeteorData;
typedef struct ArrowData ArrowData;
typedef struct MeteorAssets MeteorAssets;
typedef struct TargetData TargetData;

enum MeteorState
{
    METEORSTATE_ACTIONABLE,
    METEORSTATE_DAMAGED,
};
struct MeteorData
{
    EventDesc *event_desc;
    MeteorAssets *assets;
    GOBJ *arrow_gobj;
    struct
    {
        GOBJ *gobj;
        JOBJ *slider;
        JOBJ *input_arrow;
        JOBJ *input_text;
        JOBJ *meteor_slider;
        float left;
        float right;
    } hud;
    u16 is_tutorial;  // whether or not tutorial is active
    u16 state;        // state of the event
    u16 timer;        // increments for each frame in damaged state
    u16 lockout_jump; // value of the jump lockout timer when entering damage
    u16 lockout_upb;  // value of the upb lockout timer when entering damage
};

struct ArrowData
{
    int state;
    GOBJ *item;
    JOBJSet *set;
};
enum ArrowState
{
    ARWSTATE_WAIT,
    ARWSTATE_DOWN,
};

struct MeteorAssets
{
    JOBJSet *arrows;
    void *script;
    JOBJSet *time_bar;
};

void Arrows_Think(GOBJ *arrow_gobj);
void HUD_GX(GOBJ *hud, int pass);
void Event_Exit();