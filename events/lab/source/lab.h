#include "../../../../MexTK/mex.h"
#include "../../../tmdata/source/events.h"

// Labbing event
// Custom TDI definitions
#define TDI_HITNUM 10
#define TDI_DISPNUM 4
// menu model
#define TDIMENU_SCALE 1
#define TDIMENU_X 0.5
#define TDIMENU_Y -1
#define TDIMENU_Z 0
#define TDIMENU_WIDTH 55 / TDIMENU_SCALE
#define TDIMENU_HEIGHT 40 / TDIMENU_SCALE
// menu text object
#define TDITEXT_CANVASSCALE 0.05
#define TDITEXT_TEXTSCALE 1
#define TDITEXT_TEXTZ 0

// recording
#define GXPRI_RECJOINT 80
#define GXLINK_RECJOINT 13
#define GXPRI_RECTEXT GXPRI_RECJOINT + 1
#define GXLINK_RECTEXT 13
// cobj
#define RECCAM_COBJGXLINK (1 << GXLINK_RECJOINT) | (1 << GXLINK_RECTEXT)
#define RECCAM_GXPRI 8
// params
#define REC_LENGTH (1 * 60 * 60)
#define REC_SLOTS 6
#define REC_SEEKJOINT 7
#define REC_LEFTBOUNDJOINT 5
#define REC_RIGHTBOUNDJOINT 6
#define REC_LEFTTEXTJOINT 2
#define REC_RIGHTTEXTJOINT 3

typedef struct LabData
{
    JOBJDesc *stick;
    JOBJDesc *cstick;
    void *save_icon;
    void *save_banner;
} LabData;
typedef struct LCancelData
{
    EventInfo *eventInfo;
    u8 cpu_state;
    u8 cpu_hitshield;
    u8 cpu_hitnum;
    u8 cpu_sincehit;
    s16 cpu_lasthit;
    s16 cpu_lastshieldstun; // last move instance of the opponent in shield stun. used to tell how many times the shield was hit
    s8 cpu_hitkind;         // how the CPU was hit, damage or shield
    u8 cpu_hitshieldnum;    // times the CPUs shield was hit
    u8 cpu_isactionable;    // flag that indicates if a cpu has become actionable
    u8 cpu_groundstate;     // indicates if the player was touching ground upon being actionable
    s32 timer;
    u8 tdi_val_num;                // number of custom tdi values set
    s8 tdi_vals[TDI_HITNUM][2][2]; // contains the custom tdi values
    GOBJ *rec_gobj;
    u8 hmn_controller;
    u8 cpu_controller;
} LCancelData;
typedef struct InfoDisplayData
{
    JOBJ *menuModel;
    JOBJ *botLeftEdge;
    JOBJ *botRightEdge;
    Text *text;
} InfoDisplayData;
typedef struct DIDraw
{
    int num[2];        // number of vertices
    Vec2 *vertices[2]; // pointer to vertex to draw
    GXColor color;     // color of this vertex
} DIDraw;
typedef struct DIDrawCalculate
{
    Vec2 pos;       // position of vertices
    int envFlags;   // environment flags
    float ECBTopY;  // used for determining middle of body
    float ECBLeftY; // used for determining middle of body
    float kb_Y;     // used to determine ceiling KOs
} DIDrawCalculate;
typedef struct TDIData
{
    JOBJ *stick_curr[2];
    JOBJ *stick_prev[6][2];
    Text *text_curr;
} TDIData;
typedef struct CPUAction
{
    u16 state;                  // state to perform this action. -1 for last
    u8 frameLow;                // first possible frame to perform this action
    u8 frameHi;                 // last possible frame to perfrom this action
    s8 stickX;                  // left stick X value
    s8 stickY;                  // left stick Y value
    s8 cstickX;                 // c stick X value
    s8 cstickY;                 // c stick Y value
    int input;                  // button to input
    unsigned char isLast : 1;   // flag to indicate this was the final input
    unsigned char stickDir : 3; // 0 = none, 1 = towards opponent, 2 = away from opponent, 3 = forward, 4 = backward

} CPUAction;
typedef struct RecInputs
{
    unsigned char btn_dpadup : 1;
    unsigned char btn_a : 1;
    unsigned char btn_b : 1;
    unsigned char btn_x : 1;
    unsigned char btn_y : 1;
    unsigned char btn_L : 1;
    unsigned char btn_R : 1;
    unsigned char btn_Z : 1;
    s8 stickX;
    s8 stickY;
    s8 substickX;
    s8 substickY;
    u8 trigger;
} RecInputs;
typedef struct RecInputData
{
    int start_frame; // the frame these inputs start on
    int num;
    RecInputs inputs[REC_LENGTH]
} RecInputData;
typedef struct RecData
{
    int timer; // this is updated at runtime to know which frames inputs to use.
    int hmn_rndm_slot;
    RecInputData *hmn_inputs[REC_SLOTS];
    int cpu_rndm_slot;
    RecInputData *cpu_inputs[REC_SLOTS];
    JOBJ *seek_jobj;
    Text *text;
    float seek_left;
    float seek_right;
} RecData;
typedef struct OptFtStateData
{
    int is_exist;
    int state_id;
    float facing_direction;
    float stateFrame;
    float stateSpeed;
    float stateBlend;
    Vec4 XRotN_rot; // XRotN
    struct
    {                                                          //
        Vec3 animVel;                                          // 0x74
        Vec3 selfVel;                                          // 0x80
        Vec3 kbVel;                                            // 0x8C
        int x98;                                               // 0x98
        int x9c;                                               // 0x9C
        int xa0;                                               // 0xA0
        int xa4;                                               // 0xA4
        int xa8;                                               // 0xA8
        int xac;                                               // 0xAC
        Vec3 pos;                                              // 0xb0
        Vec3 pos_prev;                                         // 0xBC
        Vec3 pos_delta;                                        // 0xC8
        Vec3 unknownD4;                                        // 0xD4
        int air_state;                                         // 0xE0
        float horzitonal_velocity_queue_will_be_added_to_0xec; // 0xE4
        float vertical_velocity_queue_will_be_added_to_0xec;   // 0xE8
        Vec3 selfVelGround;                                    // 0xEC
        int unknownF8;                                         // 0xF8
        int unknownFC;                                         // 0xFC
        int unknown100;                                        // 0x100
    } phys;                                                    //
    ColorOverlay color[2];
    struct
    {                               //
        float lstick_x;             // 0x620
        float lstick_y;             // 0x624
        float lstick_prev_x;        // 0x628
        float lstick_prev_y;        // 0x62C
        int unknown630;             // 0x630
        int unknown634;             // 0x634
        float cstick_x;             // 0x638
        float cstick_y;             // 0x63C
        int x640;                   // 0x640
        int unknown644;             // 0x644
        int unknown648;             // 0x648
        int unknown64C;             // 0x64C
        float trigger;              // 0x650
        int unknown654;             // 0x654
        int unknown658;             // 0x658
        int held;                   // 0x65C
        int held_prev;              // 0x660
        int unknown664;             // 0x664
        int pressed;                // 0x668
        int unknown66C;             // 0x66C
        char timer_lstick_tilt_x;   // 0x670
        char timer_lstick_tilt_y;   // 0x671
        char timer_trigger_analog;  // 0x672
        char timer_lstick_smash_x;  // 0x673
        char timer_lstick_smash_y;  // 0x674
        char timer_trigger_digital; // 0x675
        char timer_lstick_any_x;    // 0x676
        char timer_lstick_any_y;    // 0x677
        char timer_trigger_any;     // 0x678
        char x679;                  // 0x679
        char x67A;                  // 0x67A
        char x67B;                  // 0x67B
        char timer_a;               // 0x67C
        char timer_b;               // 0x67D
        char timer_xy;              // 0x67E
        char timer_z;               // 0x67F
        char timer_LR;              // 0x680
        char timer_padup;           // 0x681
        char timer_paddown;         // 0x682
        char timer_item_release;    // 0x683
        char sinceRapidLR;          // 0x684
        char timer_unk2;            // 0x685
        char timer_unk3;            // 0x686
        char timer_unk4;            // 0x687
        char timer_sideb;           // 0x688
        char timer_neutralb;        // 0x689
        char timer_unk5;            // 0x68A
        char timer_unk6;            // 0x68B
    } input;                        //
    CollData collData;
    CameraBox cameraBox;
    ftHit hitbox[4];
    ftHit throw_hitbox[2];
    ftHit unk_hitbox;
    struct
    {
        unsigned char throw_1 : 1;               // 0x80 - x2210
        unsigned char throw_2 : 1;               // 0x40 - x2210
        unsigned char throw_3 : 1;               // 0x20 - x2210
        unsigned char throw_release : 1;         // 0x10 - x2210. also used to change users direction during aerial attacks
        unsigned char throw_turn : 1;            // 0x8 - x2210
        unsigned char throw_6 : 1;               // 0x4 - x2210
        unsigned char throw_7 : 1;               // 0x2 - x2210
        unsigned char throw_8 : 1;               // 0x1 - x2210
        float throw_timerval;                    // equal to script_event_timer of the attacker
        unsigned char x2218_1 : 1;               // 0x80 - x2218
        unsigned char x2218_2 : 1;               // 0x40 - x2218
        unsigned char x2218_3 : 1;               // 0x20 - x2218
        unsigned char reflect_enable : 1;        // 0x10 - x2218
        unsigned char reflect_nochangeowner : 1; // 0x8 - x2218
        unsigned char x2218_6 : 1;               // 0x4 - x2218
        unsigned char absorb_enable : 1;         // 0x2 - x2218
        unsigned char absorb_unk : 1;            // 0x1 - x2218
        unsigned char shield : 1;                // is shielding bool. 0x80 - 0x2219
        unsigned char immune : 1;                // 0x40 - 0x2219
        unsigned char x2219_3 : 1;               // 0x20 - 0x2219
        unsigned char hitbox_active : 1;         // 0x10 - 0x2219
        unsigned char x2219_5 : 1;               // 0x8 - 0x2219
        unsigned char freeze : 1;                // 0x4 - 0x2219
        unsigned char hitlag_unk : 1;            // 0x2 - 0x2219
        unsigned char hitlag_unk2 : 1;           // 0x1 - 0x2219
        unsigned char x221a_1 : 1;               // 0x80 - 0x221a
        unsigned char x221a_2 : 1;               // 0x40 - 0x221a
        unsigned char hitlag : 1;                // 0x20 - 0x221a
        unsigned char x221a_4 : 1;               // 0x10 - 0x221a
        unsigned char fastfall : 1;              // 0x8 - 0x221a
        unsigned char no_hurt_script : 1;        // 0x4 - 0x221a
        unsigned char x221a_7 : 1;               // 0x2 - 0x221a
        unsigned char gfx_persist : 1;           // 0x1 - 0x221a
        unsigned char shield_enable : 1;         // 0x80 - 0x221b
        unsigned char shield_x40 : 1;            // 0x40 - 0x221b
        unsigned char shield_x20 : 1;            // 0x20 - 0x221b
        unsigned char shield_x10 : 1;            // 0x10 - 0x221b
        unsigned char shield_x8 : 1;             //  0x8 - 0x221b
        unsigned char x221b_6 : 1;               // 0x4 - 0x221b
        unsigned char x221b_7 : 1;               // 0x2 - 0x221b
        unsigned char x221b_8 : 1;               // 0x1 - 0x221b
        unsigned char x221c_1 : 1;               // 0x80 - 0x221c
        unsigned char x221c_2 : 1;               // 0x40 - 0x221c
        unsigned char x221c_3 : 1;               // 0x20 - 0x221c
        unsigned char x221c_4 : 1;               // 0x10 - 0x221c
        unsigned char x221c_5 : 1;               // 0x8 - 0x221c
        unsigned char x221c_6 : 1;               // 0x4 - 0x221c
        unsigned char hitstun : 1;               // 0x2 - 0x221c
        unsigned char x221c_8 : 1;               // 0x1 = 0x221c
        unsigned char x221d_1 : 1;               // 0x80 - 0x221d
        unsigned char x221d_2 : 1;               // 0x40 - 0x221d
        unsigned char x221d_3 : 1;               // 0x20 - 0x221d
        unsigned char input_enable : 1;          // 0x10 - 0x221d
        unsigned char x221d_5 : 1;               // 0x8 - 0x221d
        unsigned char nudge_disable : 1;         // 0x4 - 0x221d
        unsigned char ground_ignore : 1;         // 0x2 - 0x221d
        unsigned char x221d_8 : 1;               // 0x1 - 0x221d
        unsigned char invisible : 1;             // 0x80 - 0x221e
        unsigned char x221e_2 : 1;               // 0x40 - 0x221e
        unsigned char x221e_3 : 1;               // 0x20 - 0x221e
        unsigned char isItemVisible : 1;         // 0x10 - 0x221e
        unsigned char x221e_5 : 1;               // 0x8 - 0x221e
        unsigned char x221e_6 : 1;               // 0x4 - 0x221e
        unsigned char x221e_7 : 1;               // 0x2 - 0x221e
        unsigned char x221e_8 : 1;               // 0x1 - 0x221e
        unsigned char mag_glass : 1;             // 0x80 - 0x221f
        unsigned char dead : 1;                  // 0x40 - 0x221f
        unsigned char x221f_3 : 1;               // 0x20 - 0x221f
        unsigned char sleep : 1;                 // 0x10
        unsigned char ms : 1;                    // ms = master/slave. is 1 when the player is a slave
        unsigned char x221f_6 : 1;
        unsigned char x221f_7 : 1;
        unsigned char x221f_8 : 1;
        char flags_2220;                      // 0x2220
        char flags_2221;                      // 0x2221
        char flags_2222;                      // 0x2222
        char flags_2223;                      // 0x2223
        unsigned char x2224_1 : 1;            // 0x80 - 0x2224
        unsigned char x2224_2 : 1;            // 0x40 - 0x2224
        unsigned char stamina_dead : 1;       // 0x20 - 0x2224
        unsigned char x2224_4 : 1;            // 0x10 - 0x2224
        unsigned char x2224_5 : 1;            // 0x8 - 0x2224
        unsigned char x2224_6 : 1;            // 0x4 - 0x2224
        unsigned char x2224_7 : 1;            // 0x2 - 0x2224
        unsigned char x2224_8 : 1;            // 0x1 - 0x2224
        char flags_2225;                      // 0x2225
        unsigned char x2226_1 : 1;            // 0x80 - 0x2226
        unsigned char x2226_2 : 1;            // 0x40 - 0x2226
        unsigned char is_thrown : 1;          // 0x20 - 0x2226
        unsigned char x2226_4 : 1;            // 0x10 - 0x2226
        unsigned char x2226_5 : 1;            // 0x8 - 0x2226
        unsigned char x2226_6 : 1;            // 0x4 - 0x2226
        unsigned char x2226_7 : 1;            // 0x2 - 0x2226
        unsigned char x2226_8 : 1;            // 0x1 - 0x2226
        char flags_2227;                      // 0x2227
        char flags_2228;                      // 0x2228
        unsigned char x2229_1 : 1;            // 0x80 - 0x2229
        unsigned char x2229_2 : 1;            // 0x40 - 0x2229
        unsigned char x2229_3 : 1;            // 0x20 - 0x2229
        unsigned char x2229_4 : 1;            // 0x10 - 0x2229
        unsigned char x2229_5 : 1;            // 0x8 - 0x2229
        unsigned char x2229_6 : 1;            // 0x4 - 0x2229
        unsigned char x2229_7 : 1;            // 0x2 - 0x2229
        unsigned char no_reaction_always : 1; // 0x1 - 0x2229
        char flags_222A;                      // 0x222A
        char flags_222B;                      // 0x222B
    } flags;                                  //
    struct
    {
        int charVar1;  // 0x222c
        int charVar2;  // 0x2230
        int charVar3;  // 0x2234
        int charVar4;  // 0x2238
        int charVar5;  // 0x223c
        int charVar6;  // 0x2240
        int charVar7;  // 0x2244
        int charVar8;  // 0x2248
        int charVar9;  // 0x224c
        int charVar10; // 0x2250
        int charVar11; // 0x2254
        int charVar12; // 0x2258
        int charVar13; // 0x225c
        int charVar14; // 0x2260
        int charVar15; // 0x2264
        int charVar16; // 0x2268
        int charVar17; // 0x226c
        int charVar18; // 0x2270
        int charVar19; // 0x2274
        int charVar20; // 0x2278
        int charVar21; // 0x227c
        int charVar22; // 0x2280
        int charVar23; // 0x2284
        int charVar24; // 0x2288
        int charVar25; // 0x228c
        int charVar26; // 0x2290
        int charVar27; // 0x2294
        int charVar28; // 0x2298
        int charVar29; // 0x229c
        int charVar30; // 0x22a0
        int charVar31; // 0x22a4
        int charVar32; // 0x22a8
        int charVar33; // 0x22ac
        int charVar34; // 0x22b0
        int charVar35; // 0x22b4
        int charVar36; // 0x22b8
        int charVar37; // 0x22bc
        int charVar38; // 0x22c0
        int charVar39; // 0x22c4
        int charVar40; // 0x22c8
        int charVar41; // 0x22cc
        int charVar42; // 0x22d0
        int charVar43; // 0x22d4
        int charVar44; // 0x22d8
        int charVar45; // 0x22dc
        int charVar46; // 0x22e0
        int charVar47; // 0x22e4
        int charVar48; // 0x22e8
        int charVar49; // 0x22ec
        int charVar50; // 0x22f0
        int charVar51; // 0x22f4
        int charVar52; // 0x22f8
    } fighter_var;
    struct
    {                   //
        int stateVar1;  // 0x2340
        int stateVar2;  // 0x2344
        int stateVar3;  // 0x2348
        int stateVar4;  // 0x234c
        int stateVar5;  // 0x2350
        int stateVar6;  // 0x2354
        int stateVar7;  // 0x2358
        int stateVar8;  // 0x235c
        int stateVar9;  // 0x2360
        int stateVar10; // 0x2364
        int stateVar11; // 0x2368
        int stateVar12; // 0x236c
        int stateVar13; // 0x2370
        int stateVar14; // 0x2374
        int stateVar15; // 0x2378
        int stateVar16; // 0x237c
        int stateVar17; // 0x2380
        int stateVar18; // 0x2384
    } state_var;        //
    struct
    {                       //
        int subactionFlag0; // 0x2200
        int subactionFlag1; // 0x2204
        int subactionFlag2; // 0x2208
        int subactionFlag3; // 0x220C
    } ftcmd_var;            //
    struct
    {                           //
        int behavior;           // 0x182c
        float percent;          // 0x1830
        int x1834;              // 0x1834
        float percent_temp;     // 0x1838
        float applied;          // 0x183c
        int x1840;              // 0x1840
        float direction;        // 0x1844
        int kb_angle;           // 0x1848
        int damaged_hurtbox;    // 0x184c
        float force_applied;    // 0x1850
        Vec3 collpos;           // 0x1854
        int dealt;              // 0x1860
        int x1864;              // 0x1864
        GOBJ *source;           // 0x1868
        int x186c;              // 0x186c
        int x1870;              // 0x1870
        int x1874;              // 0x1874
        int x1878;              // 0x1878
        int x187c;              // 0x187c
        int x1880;              // 0x1880
        int x1884;              // 0x1884
        int x1888;              // 0x1888
        int x188c;              // 0x188c
        int x1890;              // 0x1890
        int x1894;              // 0x1894
        int x1898;              // 0x1898
        int x189c;              // 0x189c
        int x18a0;              // 0x18a0
        float kb_mag;           // 0x18a4  kb magnitude
        int x18a8;              // 0x18a8
        int time_since_hit;     // 0x18ac   in frames
        int x18b0;              // 0x18b0
        float armor;            // 0x18b4
        int x18b8;              // 0x18b8
        int x18bc;              // 0x18bc
        int x18c0;              // 0x18c0
        int source_ply;         // 0x18c4   damage source ply number
        int x18c8;              // 0x18c8
        int x18cc;              // 0x18cc
        int x18d0;              // 0x18d0
        int x18d4;              // 0x18d4
        int x18d8;              // 0x18d8
        int x18dc;              // 0x18dc
        int x18e0;              // 0x18e0
        int x18e4;              // 0x18e4
        int x18e8;              // 0x18e8
        u16 instancehitby;      // 0x18ec. Last Move Instance This Player Was Hit by
        int x18f0;              // 0x18f0
        int x18f4;              // 0x18f4
        u8 x18f8;               // 0x18f8
        u8 x18f9;               // 0x18f8
        u16 model_shift_frames; // 0x18f8
        int x18fc;              // 0x18fc
        int x1900;              // 0x1900
        int x1904;              // 0x1904
        int x1908;              // 0x1908
        int x190c;              // 0x190c
        int x1910;              // 0x1910
        int x1914;              // 0x1914
        int x1918;              // 0x1918
        int x191c;              // 0x191c
        int x1920;              // 0x1920
        int x1924;              // 0x1924
        int x1928;              // 0x1928
        int x192c;              // 0x192c
        int x1930;              // 0x1930
        int x1934;              // 0x1934
        int x1938;              // 0x1938
        int x193c;              // 0x193c
        int x1940;              // 0x1940
        int x1944;              // 0x1944
        int x1948;              // 0x1948
        int x194c;              // 0x194c
        int x1950;              // 0x1950
        int x1954;              // 0x1954
        int x1958;              // 0x1958
        float hitlag_frames;    // 0x195c
    } dmg;                      //
    struct
    {                        //
        float grab_timer;    // 0x1a4c
        int x1a50;           // 0x1a50
        int x1a54;           // 0x1a54
        GOBJ *grab_attacker; // 0x1a58
        GOBJ *grab_victim;   // 0x1a5c
    } grab;
    struct                   // 0x1968
    {                        //
        char jumps_used;     // 0x1968
        char walljumps_used; // 0x1969
    } jump;
    struct // 0x2114
    {
        int state;          // 0x2114 0 = none, 1 = pre-charge, 2 = charging, 3 = release
        int frame;          // 0x2118 number of frames fighter has charged for
        float hold_frame;   // 0x211c frame that charge begins/ends
        float dmg_mult;     // 0x2120 damage multiplier
        float speed_mult;   // 0x2124 speed multiplier?
        int x2128;          // 0x2128
        int x212c;          // 0x212c
        int is_sfx_played;  // 0x2130 bool for smash sfx?
        u8 vibrate_frame;   // 0x2134
        u8 x2135;           // 0x2135
        float since_hitbox; // 0x2138
    } smash;
    struct                       // 0x1988
    {                            //
        int script;              // 0x1988
        int game;                // 0x198c
        int ledge_intang_left;   // 0x1990
        int respawn_intang_left; // 0x1994
    } hurtstatus;
    struct
    {
        float health;          // 0x1998
        float lightshield_amt; // 0x199c
        int dmg_taken;         // 0x19a0, seems to be all damage taken during the frame, is reset at the end of the frame
        int dmg_taken2;        // 0x19a4, idk there so many of these
        GOBJ *dmg_source;      // 0x19a8, points to the entity that hit the shield
        float hit_direction;   // 0x19ac
        int hit_attr;          // 0x19b0, attribute of the hitbox that collided
        float x19b4;           // 0x19b4
        float x19b8;           // 0x19b8
        int dmg_taken3;        // 0x19bc, seems to be the most recent amount of damage taken
    } shield;
    struct
    {
        JOBJ *bone;                   // 0x19c0
        unsigned char is_checked : 1; // 0x19d0 0x80. is checked for collision when 0
        Vec3 pos;                     // 19d4
        Vec3 offset;                  // 0x19d4
        float size_mult;              // 0x19e0
    } shield_bubble;
    struct
    {
        JOBJ *bone;                   // 0x19e4
        unsigned char is_checked : 1; // 0x19d0 0x80. is checked for collision when 0
        Vec3 pos;                     // 0x19d4
        Vec3 offset;                  // 0x19f8
        float size_mult;              // 0x1a04
    } reflect_bubble;
    struct
    {
        JOBJ *bone;                   // 0x1a08
        unsigned char is_checked : 1; // 0x1a0c 0x80. is checked for collision when 0
        Vec3 pos;                     // 0x1a10
        Vec3 offset;                  // 0x1a1c
        float size_mult;              // 0x1a28
    } absorb_bubble;
    struct
    {                        //
        float hit_direction; // 0x1a2c
        int max_dmg;         // 0x1a30
        float dmg_mult;      // 0x1a34
        int is_break;        // 0x1a38
    } reflect_hit;           //
    struct
    {                        //
        int x1a3c;           // 0x1a3c
        float hit_direction; // 0x1a40
        int dmg_taken;       // 0x1a44
        int hits_taken;      // 0x1a48
    } absorb_hit;            //
    struct
    {
        void (*OnGrabFighter_Self)(GOBJ *fighter);   // 0x2190
        void (*x2194)(GOBJ *fighter);                // 0x2194
        void (*OnGrabFighter_Victim)(GOBJ *fighter); // 0x2198
        void (*IASA)(GOBJ *fighter);                 // 0x219C
        void (*Anim)(GOBJ *fighter);                 // 0x21A0
        void (*Phys)(GOBJ *fighter);                 // 0x21a4
        void (*Coll)(GOBJ *fighter);                 // 0x21a8
        void (*Cam)(GOBJ *fighter);                  // 0x21ac
        void (*Accessory1)(GOBJ *fighter);           // 0x21b0
        void (*Accessory2)(GOBJ *fighter);           // 0x21b4
        void (*Accessory3)(GOBJ *fighter);           // 0x21b8
        void (*Accessory4)(GOBJ *fighter);           // 0x21bc
        void (*OnGiveDamage)(GOBJ *fighter);         // 0x21c0
        void (*OnShieldHit)(GOBJ *fighter);          // 0x21c4
        void (*OnReflectHit)(GOBJ *fighter);         // 0x21c8
        void (*x21cc)(GOBJ *fighter);                // 0x21cc
        void (*EveryHitlag)(GOBJ *fighter);          // 0x21d0
        void (*EnterHitlag)(GOBJ *fighter);          // 0x21d4
        void (*ExitHitlag)(GOBJ *fighter);           // 0x21d8
        void (*OnTakeDamage)(GOBJ *fighter);         // 0x21dc
        void (*OnDeath)(GOBJ *fighter);              // 0x21e0
        void (*OnDeath2)(GOBJ *fighter);             // 0x21e4
        void (*OnDeath3)(GOBJ *fighter);             // 0x21e8
        void (*OnActionStateChange)(GOBJ *fighter);  // 0x21ec
        void (*OnTakeDamage2)(GOBJ *fighter);        // 0x21f0
        void (*OnHurtboxDetect)(GOBJ *fighter);      // 0x21f4
        void (*OnSpin)(GOBJ *fighter);               // 0x21f8
    } cb;
} OptFtStateData;
typedef struct OptFtState
{
    OptFtStateData data[2];
    Playerblock player_block;
    int stale_queue[11];
} OptFtState;
typedef struct RecordingSavestate
{
    int is_exist;
    int frame;
    OptFtState ft_state[6];
} RecordingSavestate;
typedef struct RecordingSave
{
    MatchData match_data; // this will point to a struct containing match info
    RecordingSavestate savestate;
    RecInputData hmn_inputs[REC_SLOTS];
    RecInputData cpu_inputs[REC_SLOTS];
} RecordingSave;

void Event_Init(GOBJ *gobj);
void Event_Update();
void Event_Think(GOBJ *event);

void Lab_ChangePlayerPercent(GOBJ *menu_gobj, int value);
void Lab_ChangeCPUPercent(GOBJ *menu_gobj, int value);
void Lab_ChangeCPUIntang(GOBJ *menu_gobj, int value);
void Lab_ChangeModelDisplay(GOBJ *menu_gobj, int value);
void Lab_ChangeHitDisplay(GOBJ *menu_gobj, int value);
void Lab_ChangeEnvCollDisplay(GOBJ *menu_gobj, int value);
void Lab_ChangeCamMode(GOBJ *menu_gobj, int value);
void Lab_ChangeInfoPreset(GOBJ *menu_gobj, int value);
void Lab_ChangeInfoRow(GOBJ *menu_gobj, int value);
void Lab_ChangeInfoSizePos(GOBJ *menu_gobj, int value);
void Lab_ChangeInfoPlayer(GOBJ *menu_gobj, int value);
void Lab_ChangeHUD(GOBJ *menu_gobj, int value);
void Lab_SelectCustomTDI(GOBJ *menu_gobj);
void DIDraw_GX();
void Record_ChangeHMNSlot(GOBJ *menu_gobj, int value);
void Record_ChangeCPUSlot(GOBJ *menu_gobj, int value);
void Record_ChangeHMNMode(GOBJ *menu_gobj, int value);
void Record_ChangeCPUMode(GOBJ *menu_gobj, int value);
void Record_ChangeSlot(GOBJ *menu_gobj, int value);
void Record_MemcardSave(GOBJ *menu_gobj);
void Record_MemcardLoad(GOBJ *menu_gobj);
void Record_InitState(GOBJ *menu_gobj);
void Record_RestoreState(GOBJ *menu_gobj);
void Record_CObjThink(GOBJ *gobj);
void Record_GX(GOBJ *gobj, int pass);
void Record_Think(GOBJ *rec_gobj);
void Record_Update(int ply, RecInputData *inputs, int rec_mode);
int Record_OptimizedSave(RecordingSavestate *savestate);
int Record_OptimizedLoad(RecordingSavestate *savestate);
int Record_GetRandomSlot(RecInputData **input_data);
int Record_GOBJToID(GOBJ *gobj);
int Record_FtDataToID(FighterData *fighter_data);
int Record_BoneToID(FighterData *fighter_data, JOBJ *bone);
GOBJ *Record_IDToGOBJ(int id);
FighterData *Record_IDToFtData(int id);
JOBJ *Record_IDToBone(FighterData *fighter_data, int id);
void CustomTDI_Update(GOBJ *gobj);
void CustomTDI_Destroy(GOBJ *gobj);
void Lab_Exit(int value);
void InfoDisplay_Think(GOBJ *gobj);
void InfoDisplay_GX(GOBJ *gobj, int pass);

static EventOption LabOptions_Main[];
static EventOption LabOptions_General[];
static EventOption LabOptions_InfoDisplay[];
static EventMenu LabMenu_General;
static EventMenu LabMenu_InfoDisplay;
static EventMenu LabMenu_CPU;
static EventMenu LabMenu_Record;

// info display
#define GXPRI_INFDISP GXPRI_MENUMODEL - 2
#define GXLINK_INFDISP 12
#define GXPRI_INFDISPTEXT GXPRI_INFDISP + 1
#define GXLINK_INFDISPTEXT 12

// info display jobj
#define INFDISP_WIDTH 6
#define INFDISP_SCALE 4
#define INFDISP_X -26.5
#define INFDISP_Y 21.5
#define INFDISP_Z 0.01
#define INFDISP_YOFFSET -2.5
#define INFDISP_BOTY -0.5
#define INFDISP_BOTYOFFSET -0.30
// info display text
#define INFDISPTEXT_SCALE 0.04
#define INFDISPTEXT_X 1
#define INFDISPTEXT_Y 1
#define INFDISPTEXT_YOFFSET 30

// General Options
enum gen_option
{
    OPTGEN_FRAME,
    OPTGEN_HMNPCNT,
    OPTGEN_MODEL,
    OPTGEN_HIT,
    OPTGEN_COLL,
    OPTGEN_CAM,
    OPTGEN_HUD,
    OPTGEN_DI,
    OPTGEN_INPUT,
    OPTGEN_STALE,
};

// CPU Options
enum cpu_option
{
    OPTCPU_PCNT,
    OPTCPU_INTANG,
    OPTCPU_SHIELD,
    OPTCPU_BEHAVE,
    OPTCPU_SDI,
    OPTCPU_TDI,
    OPTCPU_CUSTOMTDI,
    OPTCPU_TECH,
    OPTCPU_GETUP,
    OPTCPU_MASH,
    OPTCPU_RESET,
    OPTCPU_CTRGRND,
    OPTCPU_CTRAIR,
    OPTCPU_CTRSHIELD,
    OPTCPU_CTRFRAMES,
    OPTCPU_CTRHITS,
    OPTCPU_SHIELDHITS,
};

// Recording Options
#define OPTREC_SAVE 0
#define OPTREC_LOAD 1
#define OPTREC_HMNMODE 2
#define OPTREC_HMNSLOT 3
#define OPTREC_CPUMODE 4
#define OPTREC_CPUSLOT 5
#define OPTREC_LOOP 6
#define OPTREC_AUTOLOAD 7

// Recording Modes
#define RECMODE_OFF 0
#define RECMODE_CTRL 1
#define RECMODE_REC 2
#define RECMODE_PLAY 3

// Info Display Options
//#define OPTINF_TOGGLE 0
#define OPTINF_PLAYER 0
#define OPTINF_SIZE 1
#define OPTINF_PRESET 2
#define OPTINF_ROW1 3

// Info Display Rows
enum infdisp_rows
{
    INFDISPROW_NONE,
    INFDISPROW_POS,
    INFDISPROW_STATE,
    INFDISPROW_FRAME,
    INFDISPROW_SELFVEL,
    INFDISPROW_KBVEL,
    INFDISPROW_TOTALVEL,
    INFDISPROW_ENGLSTICK,
    INFDISPROW_SYSLSTICK,
    INFDISPROW_ENGCSTICK,
    INFDISPROW_SYSCSTICK,
    INFDISPROW_ENGTRIGGER,
    INFDISPROW_SYSTRIGGER,
    INFDISPROW_LEDGECOOLDOWN,
    INFDISPROW_INTANGREMAIN,
    INFDISPROW_HITSTOP,
    INFDISPROW_HITSTUN,
    INFDISPROW_SHIELDHEALTH,
    INFDISPROW_SHIELDSTUN,
    INFDISPROW_GRIP,
    INFDISPROW_ECBLOCK,
    INFDISPROW_ECBBOT,
    INFDISPROW_JUMPS,
    INFDISPROW_WALLJUMPS,
    INFDISPROW_JAB,
    INFDISPROW_LINE,
    INFDISPROW_BLASTLR,
    INFDISPROW_BLASTUD,
};

// CPU States
enum cpu_state
{
    CPUSTATE_START,
    CPUSTATE_GRABBED,
    CPUSTATE_SDI,
    CPUSTATE_TDI,
    CPUSTATE_TECH,
    CPUSTATE_GETUP,
    CPUSTATE_COUNTER,
    CPUSTATE_RECOVER,
};

// Grab Escape Options
enum cpu_mash
{
    CPUMASH_NONE,
    CPUMASH_MED,
    CPUMASH_HIGH,
    CPUMASH_PERFECT,
};

// Grab Escape RNG Def
#define CPUMASHRNG_MED 35
#define CPUMASHRNG_HIGH 55

// Behavior Definitions
#define CPUBEHAVE_STAND 0
#define CPUBEHAVE_SHIELD 1
#define CPUBEHAVE_CROUCH 2
#define CPUBEHAVE_JUMP 3

// SDI Definitions
#define CPUSDI_RANDOM 0
#define CPUSDI_NONE 1

// TDI Definitions
#define CPUTDI_RANDOM 0
#define CPUTDI_IN 1
#define CPUTDI_OUT 2
#define CPUTDI_FLOORHUG 3
#define CPUTDI_CUSTOM 4
#define CPUTDI_NONE 5
#define CPUTDI_NUM 6

// Tech Definitions
#define CPUTECH_RANDOM 0
#define CPUTECH_NEUTRAL 1
#define CPUTECH_AWAY 2
#define CPUTECH_TOWARDS 3
#define CPUTECH_NONE 4

// Getup Definitions
#define CPUGETUP_RANDOM 0
#define CPUGETUP_STAND 1
#define CPUGETUP_AWAY 2
#define CPUGETUP_TOWARD 3
#define CPUGETUP_ATTACK 4

// Stick Direction Definitions
#define STCKDIR_NONE 0
#define STCKDIR_TOWARD 1
#define STCKDIR_AWAY 2
#define STCKDIR_FRONT 3
#define STCKDIR_BACK 4

// Hit kind defintions
#define HITKIND_DAMAGE 0
#define HITKIND_SHIELD 1

// DI Draw Constants
#define DI_MaxColl 50