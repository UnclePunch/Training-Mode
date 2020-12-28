#include "../../../MexTK/mex.h"

#define TM_VERSSHORT "TM v3.0-a8"
#define TM_VERSLONG "Training Mode v3.0 Alpha 8"
#define TM_DEBUG 0 // 0 = release (no logging), 1 = OSReport logs, 2 = onscreen logs
#define EVENT_DATASIZE 512
#define TM_DATA -(50 * 4) - 4
#define MENU_MAXOPTION 9
#define MENU_POPMAXOPTION 5

#define TMLOG(...) DevelopText_AddString(event_vars->db_console_text, __VA_ARGS__)

// disable all logs in release mode
#if TM_DEBUG == 0
#define OSReport (void)sizeof
#define TMLOG (void)sizeof
//#define assert (void)sizeof
#endif

// use OSReport for all logs
#if TM_DEBUG == 1
#define OSReport OSReport
#endif

// use TMLog for all logs
#if TM_DEBUG == 2
#define OSReport TMLOG
#endif

// Custom File Structs
typedef struct evMenu
{
    JOBJDesc *menu;
    JOBJDesc *popup;
    JOBJDesc *scroll;
    JOBJDesc *check;
    JOBJDesc *arrow;
    JOBJDesc *playback;
    JOBJDesc *message;
    COBJDesc *hud_cobjdesc;
    JOBJ *tip_jobj;
    void **tip_jointanim; // pointer to array
} evMenu;

// Structure Definitions
typedef struct EventMenu EventMenu;
typedef struct EventMatchData
{
    unsigned int timer : 2;
    unsigned int matchType : 3;
    unsigned int isDisableMusic : 1;
    unsigned int hideGo : 1;
    unsigned int hideReady : 1;
    unsigned int isCreateHUD : 1;
    unsigned int isDisablePause : 1;
    unsigned int timerRunOnPause : 1;    // 0x01
    unsigned int isHidePauseHUD : 1;     // 0x02
    unsigned int isShowLRAStart : 1;     // 0x04
    unsigned int isCheckForLRAStart : 1; // 0x08
    unsigned int isShowZRetry : 1;       // 0x10
    unsigned int isCheckForZRetry : 1;   // 0x20
    unsigned int isShowAnalogStick : 1;  // 0x40
    unsigned int isShowScore : 1;        // 0x80
    unsigned int isRunStockLogic : 1;    // 0x20
    unsigned int isDisableHit : 1;       // 0x20
    unsigned int useKOCounter : 1;
    s8 playerKind;                    // -1 = use selected fighter
    s8 cpuKind;                       // -1 = no CPU
    s16 stage;                        // -1 = use selected stage
    unsigned int timerSeconds : 32;   // 0xFFFFFFFF
    unsigned int timerSubSeconds : 8; // 0xFF
    void *onCheckPause;
    void *onMatchEnd;
} EventMatchData;
typedef struct EventDesc
{
    char *eventName;
    char *eventDescription;
    char *eventTutorial;
    char *eventFile;
    char *eventCSSFile;
    u8 isChooseCPU : 1;
    u8 isSelectStage : 1;
    u8 use_savestates : 1;  // enables dpad left and right savestates
    u8 disable_hazards : 1; // removes stage hazards
    u8 scoreType;
    u8 callbackPriority;
    EventMatchData *matchData;
    int defaultOSD;
} EventDesc;
typedef struct EventPage
{
    char *name;
    int eventNum;
    EventDesc **events;
} EventPage;
typedef struct EventOption
{
    u8 option_kind;                                     // the type of option this is; string, integers, etc
    u8 disable;                                         // boolean for disabling the option
    u16 value_num;                                      // number of values
    u16 option_val;                                     // value of this option
    EventMenu *menu;                                    // pointer to the menu that pressing A opens
    char *option_name;                                  // pointer to the name of this option
    char *desc;                                         // pointer to the description string for this option
    void **option_values;                               // pointer to an array of strings
    void (*onOptionChange)(GOBJ *menu_gobj, int value); // function that runs when option is changed
    GOBJ *(*onOptionSelect)(GOBJ *menu_gobj);           // function that runs when option is selected
} EventOption;
struct EventMenu
{
    char *name;                         // name of this menu
    u8 option_num;                      // number of options this menu contains
    u8 scroll;                          //
    u8 state;                           // bool used to know if this menu is focused
    u8 cursor;                          // index of the option currently selected
    EventOption *options;               // pointer to all of this menu's options
    EventMenu *prev;                    // pointer to previous menu, used at runtime
    int (*menu_think)(GOBJ *menu_gobj); // function that runs every frame of this menu. returns a bool which indicates if basic menu code should be execution
};
typedef struct MenuData
{
    EventDesc *event_desc;
    EventMenu *currMenu;
    u16 canvas_menu;
    u16 canvas_popup;
    u8 isPaused;
    u8 controller_index; // index of the controller who paused
    Text *text_name;
    Text *text_value;
    Text *text_popup;
    Text *text_title;
    Text *text_desc;
    u16 popup_cursor;
    u16 popup_scroll;
    GOBJ *popup;
    evMenu *menu_assets;
    JOBJ *row_joints[MENU_MAXOPTION][2]; // pointers to row jobjs
    JOBJ *highlight_menu;                // pointer to the highlight jobj
    JOBJ *highlight_popup;               // pointer to the highlight jobj
    JOBJ *scroll_top;
    JOBJ *scroll_bot;
    GOBJ *custom_gobj;                               // onSelect gobj
    int (*custom_gobj_think)(GOBJ *custom_gobj);     // per frame function. Returns bool indicating if the program should check to unpause
    void *(*custom_gobj_destroy)(GOBJ *custom_gobj); // on destroy function
} MenuData;
typedef struct FtStateData
{
    int is_exist;
    int state;
    float facing_direction;
    float stateFrame;
    float stateSpeed;
    float stateBlend;
    Vec4 XRotN_rot; // XRotN
    struct
    {                                                          //
        Vec3 anim_vel;                                         // 0x74
        Vec3 self_vel;                                         // 0x80
        Vec3 kb_vel;                                           // 0x8C
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
    ColorOverlay color[3];
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
    CollData coll_data;
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
        int x1a60;           // 0x1a60
        int x1a64;           // 0x1a64
        u16 x1a68;           // 0x1a68
        u16 vuln;            // 0x1a6a
        int x1a6c;           // 0x1a6c
        int x1a70;           // 0x1a70
        int x1a74;           // 0x1a74
        int x1a78;           // 0x1a78
        int x1a7c;           // 0x1a7c
        int x1a80;           // 0x1a80
        int x1a84;           // 0x1a84
    } grab;                  //
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
} FtStateData;
typedef struct FtState
{
    FtStateData data[2];
    Playerblock player_block;
    int stale_queue[11];
} FtState;
typedef struct Savestate
{
    int is_exist;
    int frame;
    u8 event_data[EVENT_DATASIZE];
    FtState ft_state[6];
} Savestate;
typedef struct evFunction
{
    void (*Event_Init)(GOBJ *event);
    void (*Event_Update)();
    void (*Event_Think)(GOBJ *event);
    EventMenu **menu_start;
} evFunction;
typedef struct EventVars
{
    EventDesc *event_desc;                                                                   // event information
    evMenu *menu_assets;                                                                     // menu assets
    GOBJ *event_gobj;                                                                        // event gobj
    GOBJ *menu_gobj;                                                                         // event menu gobj
    int game_timer;                                                                          // amount of game frames passed
    u8 hide_menu;                                                                            // enable this to hide the base menu. used for custom menus.
    int (*Savestate_Save)(Savestate *savestate);                                             // function pointer to save state
    int (*Savestate_Load)(Savestate *savestate);                                             // function pointer to load state
    GOBJ *(*Message_Display)(int msg_kind, int queue_num, int msg_color, char *format, ...); // function pointer to display message
    int *(*Tip_Display)(int lifetime, char *fmt, ...);
    void (*Tip_Destroy)();      // function pointer to destroy tip
    Savestate *savestate;       // points to the events main savestate
    evFunction evFunction;      // event specific functions
    ArchiveInfo *event_archive; // event archive header
    DevText *db_console_text;
} EventVars;

// Function prototypes
EventDesc *GetEventDesc(int page, int event);
void EventInit(int page, int eventID, MatchInit *matchData);
void EventLoad();
GOBJ *EventMenu_Init(EventDesc *event_desc, EventMenu *start_menu);
void EventMenu_Think(GOBJ *eventMenu, int pass);
void EventMenu_COBJThink(GOBJ *gobj);
void EventMenu_Draw(GOBJ *eventMenu);
int Text_AddSubtextManual(Text *text, char *string, int posx, int posy, int scalex, int scaley);
EventMenu *EventMenu_GetCurrentMenu(GOBJ *gobj);
int Savestate_Save(Savestate *savestate);
int Savestate_Load(Savestate *savestate);
void Update_Savestates();
int GOBJToID(GOBJ *gobj);
int FtDataToID(FighterData *fighter_data);
int BoneToID(FighterData *fighter_data, JOBJ *bone);
GOBJ *IDToGOBJ(int id);
FighterData *IDToFtData(int id);
JOBJ *IDToBone(FighterData *fighter_data, int id);
void EventUpdate();
void Event_IncTimer(GOBJ *gobj);
void Test_Think(GOBJ *gobj);
static EventDesc *static_eventInfo;
static MenuData *static_menuData;
static EventVars stc_event_vars;
static int *eventDataBackup;

static EventVars **event_vars_ptr = 0x803d7054; //R13 + (-0x4730)
static EventVars *event_vars;

// EventOption option_kind definitions
#define OPTKIND_MENU 0
#define OPTKIND_STRING 1
#define OPTKIND_INT 2
#define OPTKIND_FLOAT 3
#define OPTKIND_FUNC 4

// EventMenu state definitions
#define EMSTATE_FOCUS 0
#define EMSTATE_OPENSUB 1
#define EMSTATE_OPENPOP 2
#define EMSTATE_WAIT 3 // pauses menu logic, used for when a custom window is being shown

// GX Link args
#define GXLINK_MENUMODEL 12
#define GXPRI_MENUMODEL 80
#define GXLINK_MENUTEXT 12
#define GXPRI_MENUTEXT GXPRI_MENUMODEL + 1
// popup menu
#define GXPRI_POPUPMODEL GXPRI_MENUTEXT + 1
#define GXLINK_POPUPMODEL 12
#define GXPRI_POPUPTEXT GXPRI_POPUPMODEL + 1
#define GXLINK_POPUPTEXT 12
// cobj
#define MENUCAM_COBJGXLINK (1 << GXLINK_MENUMODEL) | (1 << GXLINK_MENUTEXT) | (1 << GXLINK_POPUPMODEL) | (1 << GXLINK_POPUPTEXT)
#define MENUCAM_GXPRI 9

// menu model
#define OPT_SCALE 1
#define OPT_X 0 //0.5
#define OPT_Y -1
#define OPT_Z 0
#define OPT_WIDTH 55 / OPT_SCALE
#define OPT_HEIGHT 40 / OPT_SCALE
// menu text object
#define MENU_CANVASSCALE 0.05
#define MENU_TEXTSCALE 1
#define MENU_TEXTZ 0
// menu title
#define MENU_TITLEXPOS -430
#define MENU_TITLEYPOS -366
#define MENU_TITLESCALE 2.3
#define MENU_TITLEASPECT 870
// menu description
#define MENU_DESCXPOS -21.5
#define MENU_DESCYPOS 12
#define MENU_DESCSCALE 1
// menu option name
#define MENU_OPTIONNAMEXPOS -430
#define MENU_OPTIONNAMEYPOS -230
#define MENU_NAMEASPECT 440
// menu option value
#define MENU_OPTIONVALXPOS 250
#define MENU_OPTIONVALYPOS -230
#define MENU_TEXTYOFFSET 50
#define MENU_VALASPECT 280
// menu highlight
#define MENUHIGHLIGHT_SCALE 1 // OPT_SCALE
#define MENUHIGHLIGHT_HEIGHT ROWBOX_HEIGHT
#define MENUHIGHLIGHT_WIDTH (OPT_WIDTH * 0.785)
#define MENUHIGHLIGHT_X OPT_X
#define MENUHIGHLIGHT_Y 10.8 //10.3
#define MENUHIGHLIGHT_Z 0.01
#define MENUHIGHLIGHT_YOFFSET ROWBOX_YOFFSET
#define MENUHIGHLIGHT_COLOR \
    {                       \
        255, 211, 0, 255    \
    }
// menu scroll
#define MENUSCROLL_SCALE 2                         // OPT_SCALE
#define MENUSCROLL_SCALEY 1.105 * MENUSCROLL_SCALE // OPT_SCALE
#define MENUSCROLL_X 22.5
#define MENUSCROLL_Y 12
#define MENUSCROLL_Z 0.01
#define MENUSCROLL_PEROPTION 1
#define MENUSCROLL_MINLENGTH -1
#define MENUSCROLL_MAXLENGTH -10
#define MENUSCROLL_COLOR \
    {                    \
        255, 211, 0, 255 \
    }

// row jobj
#define ROWBOX_HEIGHT 2.3
#define ROWBOX_WIDTH 18
#define ROWBOX_X 12.5 //13
#define ROWBOX_Y 10.8 //10.3
#define ROWBOX_Z 0
#define ROWBOX_YOFFSET -2.5
#define ROWBOX_COLOR       \
    {                      \
        104, 105, 129, 100 \
    }
// arrow jobj
#define TICKBOX_SCALE 1.8
#define TICKBOX_X 11.7
#define TICKBOX_Y 11.7

// popup model
#define POPUP_WIDTH ROWBOX_WIDTH
#define POPUP_HEIGHT 19
#define POPUP_SCALE 1
#define POPUP_X 12.5
#define POPUP_Y 8.3
#define POPUP_Z 0.01
#define POPUP_YOFFSET -2.5
// popup text object
#define POPUP_CANVASSCALE 0.05
#define POPUP_TEXTSCALE 1
#define POPUP_TEXTZ 0.01
// popup text
#define POPUP_OPTIONVALXPOS 250
#define POPUP_OPTIONVALYPOS -280
#define POPUP_TEXTYOFFSET 50
// popup highlight
#define POPUPHIGHLIGHT_HEIGHT ROWBOX_HEIGHT
#define POPUPHIGHLIGHT_WIDTH (POPUP_WIDTH * 0.785)
#define POPUPHIGHLIGHT_X 0
#define POPUPHIGHLIGHT_Y 5
#define POPUPHIGHLIGHT_Z 1
#define POPUPHIGHLIGHT_YOFFSET ROWBOX_YOFFSET
#define POPUPHIGHLIGHT_COLOR \
    {                        \
        255, 211, 0, 255     \
    }

// Message
void Message_Init();
GOBJ *Message_Display(int msg_kind, int queue_num, int msg_color, char *format, ...);
void Message_Manager(GOBJ *mngr_gobj);
void Message_Destroy(GOBJ **msg_queue, int msg_num);
void Message_Add(GOBJ *msg_gobj, int queue_num);
void Message_CObjThink(GOBJ *gobj);
float BezierBlend(float t);

#define MSGQUEUE_NUM 7
#define MSGQUEUE_SIZE 5
#define MSGQUEUE_GENERAL 6
enum MsgState
{
    MSGSTATE_WAIT,
    MSGSTATE_SHIFT,
    MSGSTATE_DELETE,
};
enum MsgArea
{
    MSGKIND_P1,
    MSGKIND_P2,
    MSGKIND_P3,
    MSGKIND_P4,
    MSGKIND_P5,
    MSGKIND_P6,
    MSGKIND_GENERAL,
};
typedef struct MsgData
{
    Text *text;      // text pointer
    int kind;        // the type of message this is
    int state;       // unused atm
    int prev_index;  // used to animate the messages position during shifts
    int orig_index;  // used to tell if the message moved throughout the course of the frame
    int anim_timer;  // used to track animation frame
    int lifetime;    // amount of frames after spawning to kill this message
    int alive_timer; // amount of frames this message has been alive for
} MsgData;
typedef struct MsgMngrData
{
    COBJ *cobj;
    int state;
    int canvas;
    GOBJ *msg_queue[MSGQUEUE_NUM][MSGQUEUE_SIZE]; // array 7 is for miscellaneous messages, not related to a player
} MsgMngrData;
static GOBJ *stc_msgmgr;
static float stc_msg_queue_offsets[] = {5.15, 5.15, 5.15, 5.15, 5.15, 5.15, -5.15}; // Y offsets for each message in the queue
static Vec3 stc_msg_queue_general_pos = {-21, 18.5, 0};
enum MsgColors
{
    MSGCOLOR_WHITE,
    MSGCOLOR_GREEN,
    MSGCOLOR_RED,
    MSGCOLOR_YELLOW
};
static GXColor stc_msg_colors[] = {
    {255, 255, 255, 255},
    {141, 255, 110, 255},
    {255, 162, 186, 255},
    {255, 240, 0, 255},
};

#define MSGTIMER_SHIFT 6
#define MSGTIMER_DELETE 6
#define MSG_LIFETIME (2 * 60)
#define MSG_LINEMAX 3  // lines per message
#define MSG_CHARMAX 32 // characters per line
#define MSG_HUDYOFFSET 8
#define MSGJOINT_SCALE 3
#define MSGJOINT_X 0
#define MSGJOINT_Y 0
#define MSGJOINT_Z 0
#define MSGTEXT_BASESCALE 1.4
#define MSGTEXT_BASEWIDTH (330 / MSGTEXT_BASESCALE)
#define MSGTEXT_BASEX 0
#define MSGTEXT_BASEY -1
#define MSGTEXT_YOFFSET 30

// GX stuff
#define MSG_GXLINK 13
#define MSG_GXPRI 80
#define MSGTEXT_GXPRI MSG_GXPRI + 1
#define MSG_COBJLGXLINKS (1 << MSG_GXLINK)
#define MSG_COBJLGXPRI 8

typedef struct TipMgr
{
    GOBJ *gobj;   // tip gobj
    Text *text;   // tip text object
    int state;    // state this tip is in. 0 = in, 1 = wait, 2 = out
    int lifetime; // tips time spent onscreen
} TipMgr;

int Tip_Display(int lifetime, char *fmt, ...);
void Tip_Destroy(); // 0 = immediately destroy, 1 = force exit
void Tip_Think(GOBJ *gobj);

#define TIP_TXTJOINT 2
