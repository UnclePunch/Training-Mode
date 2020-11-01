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
    int x40;                   // 0x40
    int x44;                   // 0x44
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

/*** Functions ***/

void Coll_ECBCurrToPrev(CollData *collData);
void Coll_InitECB(CollData *collData);
int ECB_CollGround_PassLedge(CollData *ecb, ECBBones *bones); // returns is touching ground bool
void ECB_CollAir(CollData *ecb, ECBBones *bones);

static int *stc_colltest = R13 + (COLL_TEST);

#endif
