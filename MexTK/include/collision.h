#ifndef MEX_H_COLLISION
#define MEX_H_COLLISION

#include "structs.h"
#include "datatypes.h"
#include "obj.h"

// ECB Flags
#define ECB_GROUND 0x8000
#define ECB_CEIL 0x4000
#define ECB_WALLLEFT 0x800
#define ECB_WALLRIGHT 0x20

// Line Directions
#define LINE_GROUND 1
#define LINE_CEIL 2
#define LINE_WALLRIGHT 4
#define LINE_WALLLEFT 8

/*** Structs ***/

struct ECBBones
{
    float topY;
    float botY;
    Vec2 left;
    Vec2 right;
};

struct DmgHazard
{
    int x0;
    int dmg;
    int angle;
    int kb_growth;
    int x10;
    int kb_base;
    int element;
    int x1c;
    int sfx;
};

struct CollData
{
    GOBJ *gobj;                // 0x0
    Vec3 topN_Curr;            // 0x4
    Vec3 topN_CurrCorrect;     // 0x10
    Vec3 topN_Prev;            // 0x1c
    Vec3 topN_Proj;            // 0x28
    int flags1;                // 0x34
    int coll_test;             // 0x38, is the ID of the most recent collision test for this object
    int ignore_line;           // 0x3c, ignores this line ID during collision
    int ledge_left;            // 0x40, ledge ID in contact with
    int ledge_right;           // 0x44, ledge ID in contact with
    int ignore_group;          // 0x48  ignores this line group during collision
    int check_group;           // 0x4c  checks only this line group during collision
    int x50;                   // 0x50
    int x54;                   // 0x54
    int x58;                   // 0x58
    int x5c;                   // 0x5c
    int x60;                   // 0x60
    int x64;                   // 0x64
    int x68;                   // 0x68
    int x6c;                   // 0x6c
    int x70;                   // 0x70
    int x74;                   // 0x74
    int x78;                   // 0x78
    int x7c;                   // 0x7c
    int x80;                   // 0x80
    Vec2 ecbCurr_top;          // 0x84
    Vec2 ecbCurr_bot;          // 0x8C
    Vec2 ecbCurr_right;        // 0x94
    Vec2 ecbCurr_left;         // 0x9C
    Vec2 ecbCurrCorrect_top;   // 0xA4
    Vec2 ecbCurrCorrect_bot;   // 0xAC
    Vec2 ecbCurrCorrect_right; // 0xB4
    Vec2 ecbCurrCorrect_left;  // 0xBC
    Vec2 ecbPrev_top;          // 0xC4
    Vec2 ecbPrev_bot;          // 0xCC
    Vec2 ecbPrev_right;        // 0xD4
    Vec2 ecbPrev_left;         // 0xDC
    Vec2 ecbProj_top;          // 0xE4
    Vec2 ecbProj_bot;          // 0xEC
    Vec2 ecbProj_right;        // 0xF4
    Vec2 ecbProj_left;         // 0xFC
    int x104;                  // 0x104
    JOBJ *joint_1;             // 0x108
    JOBJ *joint_2;             // 0x10c
    JOBJ *joint_3;             // 0x110
    JOBJ *joint_4;             // 0x114
    JOBJ *joint_5;             // 0x118
    JOBJ *joint_6;             // 0x11c
    JOBJ *joint_7;             // 0x120
    int x124;                  // 0x124
    int x128;                  // 0x128
    int x12c;                  // 0x12c
    int flags;                 // 0x130
    int envFlags;              // 0x134
    int envFlags_prev;         // 0x138
    int x13c;                  // 0x13c
    int x140;                  // 0x140
    int x144;                  // 0x144
    int x148;                  // 0x148
    int ground_index;          // 0x14c, ground
    u8 ground_info;            // 0x150
    u8 ground_unk;             // 0x151
    u8 ground_type;            // 0x152, platform/ledgegrab
    u8 ground_mat;             // 0x153, grass/ice etc
    Vec3 ground_slope;         // 0x154
    int rightwall_index;       // 0x160
    u8 rightwall_info;         // 0x164
    u8 rightwall_unk;          // 0x165
    u8 rightwall_type;         // 0x166, platform/ledgegrab
    u8 rightwall_mat;          // 0x167, grass/ice etc
    Vec3 rightwall_slope;      // 0x168
    int leftwall_index;        // 0x174
    u8 leftwall_info;          // 0x178
    u8 leftwall_unk;           // 0x179
    u8 leftwall_type;          // 0x17A, platform/ledgegrab
    u8 leftwall_mat;           // 0x17B, grass/ice etc
    Vec3 leftwall_slope;       // 0x17C
    int ceil_index;            // 0x188
    u8 ceil_info;              // 0x18C
    u8 ceil_unk;               // 0x18D
    u8 ceil_type;              // 0x18E, platform/ledgegrab
    u8 ceil_mat;               // 0x18F, grass/ice etc
    Vec3 ceil_slope;           // 0x190
    int ecb_lock;              // 0x19c
};

struct CollGroupDesc // exists in stage file
{
    u16 floor_start;
    u16 floor_num;
    u16 ceil_start;
    u16 ceil_num;
    u16 rwall_start;
    u16 rwall_num;
    u16 lwall_start;
    u16 lwall_num;
    u16 dyn_start;
    u16 dyn_num;
    Vec2 area_min; // 0x10
    Vec2 area_max; // 0x18
    u16 vert_start;
    u16 vert_num;
};

struct CollGroup // exists in heap
{
    CollGroup *next;
    CollGroupDesc *desc;
    int x8;               // flags
    u16 ray_id;           // id of the last raycast
    u16 xe;               // flags
    Vec2 area_min;        // 0x10
    Vec2 area_max;        // 0x18
    JOBJ *jobj;           // 0x20
    void *cb_floor;       // 0x24
    void *map_data_floor; // 0x28
    void *cb_ceil;        // 0x2C
    void *map_data_ceil;  // 0x30
    int x34;              // 0x34
};

struct CollLineInfo
{
    s16 vert_prev;          // 0x0
    s16 vert_next;          // 0x2
    s16 line_prev;          // 0x4
    s16 line_next;          // 0x6
    s16 line_prev_altgroup; // 0x8
    s16 line_next_altgroup; // 0xA
    u8 xc;
    u8 xd_1 : 1;     // 0xD, 0x8000
    u8 xd_2 : 1;     // 0xD, 0x8000
    u8 xd_3 : 1;     // 0xD, 0x8000
    u8 disabled : 1; // 0xD, 0x8000
    u8 is_left : 1;  // 0xD, 0x8000
    u8 is_right : 1; // 0xD, 0x8000
    u8 is_ceil : 1;  // 0xD, 0x0200
    u8 is_floor : 1; // 0xD, 0x8000
    u8 xe_1 : 1;     // 0xE, 0x8000
    u8 xe_2 : 1;     // 0xE, 0x8000
    u8 xe_3 : 1;     // 0xE, 0x8000
    u8 xe_4 : 1;     // 0xE, 0x8000
    u8 xe_5 : 1;     // 0xE, 0x8000
    u8 is_drop : 1;  // 0xE, 0x8000
    u8 is_ledge : 1; // 0xE, 0x0200
    u8 is_unk : 1;   // 0xE, 0x8000
    u8 material;
};

struct CollLine
{
    CollLineInfo *info;
    u8 x4;             // 0x4
    u8 x5_1 : 1;       // 0x5
    u8 x5_2 : 1;       // 0x5
    u8 x5_3 : 1;       // 0x5
    u8 x5_4 : 1;       // 0x5
    u8 x5_5 : 1;       // 0x5
    u8 x5_6 : 1;       // 0x5
    u8 x5_7 : 1;       // 0x5
    u8 is_enabled : 1; // 0x5
    u8 x6;             // 0x6
    u8 x7 : 4;         // 0x7
    u8 is_rwall : 1;   // 0x7, 0x8
    u8 is_lwall : 1;   // 0x7, 0x4
    u8 is_ceil : 1;    // 0x7, 0x2
    u8 is_floor : 1;   // 0x7, 0x1
};

struct CollVert
{
    Vec2 pos_orig;
    Vec2 pos_curr;
    Vec2 pos_prev;
};

struct CollDataStage
{
    void *verts;
    int vert_num;
    void *lines;
    int line_num;
    u16 floor_start;
    u16 floor_num;
    u16 ceil_start;
    u16 ceil_num;
    u16 rwall_start;
    u16 rwall_num;
    u16 lwall_start;
    u16 lwall_num;
    u16 dyn_start;
    u16 dyn_num;
    void *groups;
    int group_num;
};

/*** Functions ***/
void Coll_ECBCurrToPrev(CollData *coll_data);
void Coll_InitECB(CollData *coll_data);
int ECB_CollGround_PassLedge(CollData *ecb, ECBBones *bones); // returns is touching ground bool
void ECB_CollAir(CollData *ecb, ECBBones *bones);
void GrColl_GetLedgeLeft(int floor_index, Vec3 *pos);                                                                                                                                            // this functon will crawl along the entire line sequence and find the end of the ledge
void GrColl_GetLedgeRight(int floor_index, Vec3 *pos);                                                                                                                                           // this functon will crawl along the entire line sequence and find the end of the ledge
void GrColl_GetLedgeLeft2(int floor_index, Vec3 *pos);                                                                                                                                           // this functon will crawl along the entire line sequence and find the end of the ledge
void GrColl_GetLedgeRight2(int floor_index, Vec3 *pos);                                                                                                                                          // this functon will crawl along the entire line sequence and find the end of the ledge
int GrColl_RaycastGround(Vec3 *coll_pos, int *line_index, int *line_kind, Vec3 *unk1, Vec3 *unk2, Vec3 *unk3, Vec3 *unk4, void *cb, float fromX, float fromY, float toX, float toY, float unk5); // make unk5
int GrColl_CrawlGround(int line_index, Vec3 *pos, int *return_line, Vec3 *return_pos, int *return_flags, Vec3 *return_slope, float x_offset, float y_offset);                                    // returns bool for if position on line series exists
int GrColl_GetPosDifference(int line_index, Vec3 *pos, Vec3 *return_pos);
int GrColl_GetLineInfo(int line_index, Vec3 *r4, void *r5, int *flags, Vec3 *return_slope);
void GrColl_GetLineSlope(int line_index, Vec3 *return_slope);
int GrColl_CheckIfLineEnabled(int line_index);

static int *stc_colltest = R13 + (COLL_TEST);
static CollGroup **stc_firstcollgroup = R13 + (-0x51DC);
static CollGroup **stc_collgroup = R13 + (-0x51E0);
static CollLine **stc_collline = R13 + (-0x51E4);
static CollVert **stc_collvert = R13 + (-0x51E8);
static CollDataStage **stc_colldata = R13 + (-0x51EC);

#endif
