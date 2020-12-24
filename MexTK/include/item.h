#ifndef MEX_H_ITEM
#define MEX_H_ITEM

#include "structs.h"
#include "datatypes.h"
#include "obj.h"
#include "color.h"

// Item IDs
#define ITEM_CAPSULE 0
#define ITEM_BOX 1
#define ITEM_BARREL 2
#define ITEM_EGG 3
#define ITEM_PARTYBALL 4
#define ITEM_BARRELCANNON 5
#define ITEM_BOBOMB 6
#define ITEM_MRSATURN 7
#define ITEM_HEARTCONTAINER 8
#define ITEM_MAXIMTOMATO 9
#define ITEM_STARMAN 10
#define ITEM_HOMERUNBAT 11
#define ITEM_BEAMSWORD 12
#define ITEM_PARASOL 13
#define ITEM_GREENSHELL 14
#define ITEM_REDSHELL 15
#define ITEM_RAYGUN 16
#define ITEM_FREEZIE 17
#define ITEM_FOOD 18
#define ITEM_MOTIONSENSORBOMB 19
#define ITEM_FLIPPER 20
#define ITEM_SUPERSCOPE 21
#define ITEM_STARROD 22
#define ITEM_LIPSSTICK 23
#define ITEM_FAN 24
#define ITEM_FIREFLOWER 25
#define ITEM_SUPERMUSHROOM 26
#define ITEM_POISONMUSHROOM 27
#define ITEM_HAMMER 28
#define ITEM_WARPSTAR 29
#define ITEM_SCREWATTACK 30
#define ITEM_BUNNYHOOD 31
#define ITEM_METALBOX 32
#define ITEM_CLOAKINGDEVICE 33
#define ITEM_POKEBALL 34
#define ITEM_RAYGUNUNK 35
#define ITEM_STARRODSTAR 36
#define ITEM_LIPSSTICKDUST 37
#define ITEM_SUPERSCOPEBEAM 38
#define ITEM_RAYGUNBEAM 39
#define ITEM_HAMMERHEAD 40
#define ITEM_FLOWER 41
#define ITEM_YOSHISEGG 42
#define ITEM_GOOMBA 43
#define ITEM_REDEAD 44
#define ITEM_OCTAROK 45
#define ITEM_OTTOSEA 46
#define ITEM_STONE 47
#define ITEM_MARIOFIRE 48
#define ITEM_DRMARIOPILL 49
#define ITEM_KIRBYCUTTER 50
#define ITEM_KIRBYHAMMER 51
#define ITEM_KIRBYABILITYSTAR 52
/*
 #define ITEM_ 53
 #define ITEM_ 54
 #define ITEM_ 55
 #define ITEM_ 56
 #define ITEM_ 57
 #define ITEM_ 58
 #define ITEM_ 59
 #define ITEM_ 60
 #define ITEM_ 61
 #define ITEM_ 62
 #define ITEM_ 63
 #define ITEM_ 64
 #define ITEM_ 65
 #define ITEM_ 66
 #define ITEM_ 67
 #define ITEM_ 68
 #define ITEM_ 69
 #define ITEM_ 70
 #define ITEM_ 71
 #define ITEM_ 72
 #define ITEM_ 73
 #define ITEM_ 74
 #define ITEM_ 75
 #define ITEM_ 76
 #define ITEM_ 77
 #define ITEM_ 78
 #define ITEM_ 79
 #define ITEM_ 80
 #define ITEM_ 81
 #define ITEM_ 82
 #define ITEM_ 83
 #define ITEM_ 84
 #define ITEM_ 85
 #define ITEM_ 86
 #define ITEM_ 87
 #define ITEM_ 88
 #define ITEM_ 89
 #define ITEM_ 90
 #define ITEM_ 91
 #define ITEM_ 92
 #define ITEM_ 93
 #define ITEM_ 94
 #define ITEM_ 95
 #define ITEM_ 96
 #define ITEM_ 97
 #define ITEM_ 98
 #define ITEM_ 99
 #define ITEM_ 100
 #define ITEM_ 101
 #define ITEM_ 102
 #define ITEM_ 103
 #define ITEM_ 104
 #define ITEM_ 105
 #define ITEM_ 106
 #define ITEM_ 107
 #define ITEM_ 108
 #define ITEM_ 109
 #define ITEM_ 110
 #define ITEM_ 111
 #define ITEM_ 112
 #define ITEM_ 113
 #define ITEM_ 114
 #define ITEM_ 115
 #define ITEM_ 116
 #define ITEM_ 117
 #define ITEM_ 118
 #define ITEM_ 119
 #define ITEM_ 120
 #define ITEM_ 121
 #define ITEM_ 122
 #define ITEM_ 123
 #define ITEM_ 124
 #define ITEM_ 125
 #define ITEM_ 126
 #define ITEM_ 127
 #define ITEM_ 128
 #define ITEM_ 129
 #define ITEM_ 130
 #define ITEM_ 131
 #define ITEM_ 132
 #define ITEM_ 133
 #define ITEM_ 134
 #define ITEM_ 135
 #define ITEM_ 136
 #define ITEM_ 137
 #define ITEM_ 138
 #define ITEM_ 139
 #define ITEM_ 140
 #define ITEM_ 141
 #define ITEM_ 142
 #define ITEM_ 143
 #define ITEM_ 144
 #define ITEM_ 145
 #define ITEM_ 146
 #define ITEM_ 147
 #define ITEM_ 148
 #define ITEM_ 149
 #define ITEM_ 150
 #define ITEM_ 151
 #define ITEM_ 152
 #define ITEM_ 153
 #define ITEM_ 154
 #define ITEM_ 155
 #define ITEM_ 156
 #define ITEM_ 157
 #define ITEM_ 158
 #define ITEM_ 159
 */
#define ITEM_POKERANDOM 160
#define ITEM_GOLDEEN 161
#define ITEM_CHICORITA 162
#define ITEM_SNORLAX 163
#define ITEM_BLASTOISE 164
#define ITEM_WEEZING 165
#define ITEM_CHARIZARD 166
#define ITEM_MOLTRES 167
#define ITEM_ZAPDOS 168
#define ITEM_ARCTICUNO 169
#define ITEM_WOBBUFFET 170
#define ITEM_SCIZOR 171
#define ITEM_UNOWN 172
#define ITEM_ENTEI 173
#define ITEM_RAIKOU 174
#define ITEM_SUICUNE 175
#define ITEM_BELLOSSOM 176
#define ITEM_ELECTRODE 177
#define ITEM_LUGIA 178
#define ITEM_HOOH 179
#define ITEM_DITTO 180
#define ITEM_CLEFAIRY 181
#define ITEM_TOGEPI 182
#define ITEM_MEW 183
#define ITEM_CELEBI 184
#define ITEM_STARYU 185
#define ITEM_CHANSEY 186
#define ITEM_PORYGON2 187
#define ITEM_CYNDAQUIL 188
#define ITEM_MARILL 189
#define ITEM_VENUSAUR 190
/*
 #define ITEM_ 191
 #define ITEM_ 192
 #define ITEM_ 193
 #define ITEM_ 194
 #define ITEM_ 195
 #define ITEM_ 196
 #define ITEM_ 197
 #define ITEM_ 198
 #define ITEM_ 199
 #define ITEM_ 200
 #define ITEM_ 201
 #define ITEM_ 202
 #define ITEM_ 203
 #define ITEM_ 204
 #define ITEM_ 205
 #define ITEM_ 206
 #define ITEM_ 207
 #define ITEM_ 208
 */
#define ITEM_TARGET 209
/*
 #define ITEM_ 210
 #define ITEM_ 211
 #define ITEM_ 212
 #define ITEM_ 213
 #define ITEM_ 214
 #define ITEM_ 215
 #define ITEM_ 216
 #define ITEM_ 217
 #define ITEM_ 218
 #define ITEM_ 219
 #define ITEM_ 220
 #define ITEM_ 221
 #define ITEM_ 222
 #define ITEM_ 223
 #define ITEM_ 224
 #define ITEM_ 225
 #define ITEM_ 226
 #define ITEM_ 227
 #define ITEM_ 228
 #define ITEM_ 229
 #define ITEM_ 230
 #define ITEM_ 231
 #define ITEM_ 232
 #define ITEM_ 233
 #define ITEM_ 234
 #define ITEM_ 235
 */

// ItemStateChange Flags
#define ITEMSTATE_UPDATEANIM 0x2
#define ITEMSTATE_GRAB 0x4
#define ITEMSTATE_KEEPHIT 0x10 // dont remove hitboxes on state change

// Item hold_kind definitions
#define ITHOLD_HAND 0  // held item, like a capsule
#define ITHOLD_HEAVY 1 // overhead item, like a crate
#define ITHOLD_NONE 8  // unable to be held

/*** Structs ***/

struct itData
{
    int x0;
    float *param_ext;
    void *archive;
    void *animFlags;
    void *animDynamics;
    int x14;
    int x18;
    int x1C;
    int x20;
    int x24;
    int x28;
    int dynamics;
    int hurtbox;
    int x34;
    int x38;
    int x3C;
    int x40;
    int coll;
    int *items;
    int x4C;
    int x50;
    int x54;
    int boneLookup;
};

struct itCommonAttr
{
    char flags1;                //0x0, bit 0x80 = is heavy item (crate)
    unsigned char x1_1 : 1;     // 0x1 0x80
    unsigned char x1_2 : 1;     // 0x1 0x40
    unsigned char x1_3 : 1;     // 0x1 0x20
    unsigned char x1_4 : 1;     // 0x1 0x10
    unsigned char x1_5 : 1;     // 0x1 0x08
    unsigned char cam_kind : 2; // 0x1 0x06, is stored to 0xdcd
    unsigned char x1_8 : 1;     // 0x1 0x01    char flags3; //0x2
    char flags4;                //0x3
    int x4;
    int x8;
    float spinVelocity;
    float fallSpeed;
    float maxFallSpeed;
    float x18;
    float x1C;       //collision related
    int x20;         // 0x20
    int x24;         // 0x24
    int x28;         // 0x28
    int x2c;         // 0x2c
    int x30;         // 0x30
    int x34;         // 0x34
    int x38;         // 0x38
    int x3c;         // 0x3c
    float ecb_top;   // 0x40
    float ecb_bot;   // 0x44
    float ecb_right; // 0x48
    float ecb_left;  // 0x4c
    int x50;         // 0x50
    int x54;         // 0x54
    int x58;         // 0x58
    int x5c;         // 0x5c
    int x60;         // 0x60
    int x64;         // 0x64
    int x68;         // 0x68
    int x6c;         // 0x6c
    int x70;         // 0x70
    int x74;         // 0x74
    int x78;         // 0x78
    int x7c;         // 0x7c
    int x80;         // 0x80
    int x84;         // 0x84
    int x88;         // 0x88
    int x8c;         // 0x8c
    int x90;         // 0x90
    int x94;         // 0x94
    int x98;         // 0x98
    int x9c;         // 0x9c
};

struct ItemState
{
    int state;
    void *animCallback;
    void *physCallback;
    void *collCallback;
};

struct SpawnItem
{
    GOBJ *parent_gobj;      // 0x0
    GOBJ *parent_gobj2;     // 0x4
    int it_kind;            // 0x8, id of the item to spawn
    int hold_kind;          // 0xC, defines the behavior of the item, such as thrown and pickup. 0 = capsule
    int unk2;               // 0x10
    Vec3 pos;               // 0x14
    Vec3 pos2;              // 0x20
    Vec3 vel;               // 0x2C
    float facing_direction; // 0x38
    short damage;           // 0x3C
    short unk5;             // 0x3E
    int unk6;               // 0x40, 1 = correct initial position
    char unk7;              // 0x44, 0x80 = perform initial collision check
    int is_spin;            // 0x48, enables item spinning
};

struct itHit
{
    int active;                   // 0x0
    int x4;                       // 0x4, depends on
    int dmg;                      // 0x8
    float dmg_f;                  // 0xc
    Vec3 offset;                  // 0x10
    float size;                   // 0x1c
    int angle;                    // 0x20
    int kb_growth;                // 0x24
    int wdsk;                     // 0x28
    int kb;                       // 0x2c
    int attribute;                // 0x30
    int shield_dmg;               // 0x34
    int hitsound_severity;        // 0x38. hurtbox interaction. 0 = none, 1 = grounded, 2 = aerial, 3 = both
    int hitsound_kind;            // 0x3c
    unsigned char x401 : 1;       // 0x40 0x80
    unsigned char x402 : 1;       // 0x40 0x40
    unsigned char hit_air : 1;    // 0x40 0x20. bool to check against aerial fighters
    unsigned char hit_ground : 1; // 0x40 0x10. bool to check against grounded fighters
    unsigned char x405 : 1;       // 0x40 0x08
    unsigned char x406 : 1;       // 0x40 0x04
    unsigned char x407 : 1;       // 0x40 0x02
    unsigned char x408 : 1;       // 0x40 0x01
    char x41;                     // 0x41
    unsigned char x421 : 1;       // 0x42 0x80
    unsigned char x422 : 1;       // 0x42 0x40
    unsigned char hit_facing : 1; // 0x42 0x20. bool to only hit fighters facing the item
    unsigned char x424 : 1;       // 0x42 0x10
    unsigned char no_hurt : 1;    // 0x42 0x08      ignore hurtbox
    unsigned char no_reflect : 1; // 0x42 0x04      ignore reflect?
    unsigned char x427 : 1;       // 0x42 0x02
    unsigned char x428 : 1;       // 0x42 0x01
    unsigned char x431 : 1;       // 0x43 0x80
    unsigned char x432 : 1;       // 0x43 0x40
    unsigned char hit_all : 1;    // 0x43 0x20
    unsigned char x434 : 1;       // 0x43 0x10
    unsigned char x435 : 1;       // 0x43 0x08
    unsigned char x436 : 1;       // 0x43 0x04
    unsigned char x437 : 1;       // 0x43 0x02
    unsigned char x438 : 1;       // 0x43 0x01
    int x44;                      // 0x44
    JOBJ *bone;                   // 0x48
    Vec3 pos;                     // 0x4c
    Vec3 pos_prev;                // 0x58
    Vec3 pos_coll;                // 0x64   position of hurt collision
    float coll_distance;          // 0x70   Distance From Collding Hurtbox (Used for phantom hit collision calculation)
    GOBJ *victim;                 // 0x74
    int x78;                      // 0x78
    int x7c;                      // 0x7c
    int x80;                      // 0x80
    int x84;                      // 0x84
    int x88;                      // 0x88
    int x8c;                      // 0x8c
    int x90;                      // 0x90
    int x94;                      // 0x94
    int x98;                      // 0x98
    int x9c;                      // 0x9c
    int xa0;                      // 0xa0
    int xa4;                      // 0xa4
    int xa8;                      // 0xa8
    int xac;                      // 0xac
    int xb0;                      // 0xb0
    int xb4;                      // 0xb4
    int xb8;                      // 0xb8
    int xbc;                      // 0xbc
    int xc0;                      // 0xc0
    int xc4;                      // 0xc4
    int xc8;                      // 0xc8
    int xcc;                      // 0xcc
    int xd0;                      // 0xd0
    int xd4;                      // 0xd4
    int xd8;                      // 0xd8
    int xdc;                      // 0xdc
    int xe0;                      // 0xe0
    int xe4;                      // 0xe4
    int xe8;                      // 0xe8
    int xec;                      // 0xec
    int xf0;                      // 0xf0
    int xf4;                      // 0xf4
    int xf8;                      // 0xf8
    int xfc;                      // 0xfc
    int x100;                     // 0x100
    int x104;                     // 0x104
    int x108;                     // 0x108
    int x10c;                     // 0x10c
    int x110;                     // 0x110
    int x114;                     // 0x114
    int x118;                     // 0x118
    int x11c;                     // 0x11c
    int x120;                     // 0x120
    int x124;                     // 0x124
    int x128;                     // 0x128
    int x12c;                     // 0x12c
    int x130;                     // 0x130
    int x134;                     // 0x134
    int x138;                     // 0x138
};

struct ItemData
{
    int x0;                                  // 0x0
    GOBJ *item;                              // 0x0
    int x8;                                  // 0x8
    int spawnType;                           // 0xC
    int itemID;                              // 0x10
    int x14;                                 // 0x14
    int x18;                                 // 0x18
    int x1c;                                 // 0x1c
    int x20;                                 // 0x20
    int stateID;                             // 0x24
    int x28;                                 // 0x28
    float facing_direction;                  // 0x2c
    int x30;                                 // 0x30
    float spinUnk;                           // 0x34
    float scale;                             // 0x38
    int x3c;                                 // 0x3c
    Vec3 self_vel;                           // 0x40
    Vec3 pos;                                // 0x4C
    Vec3 unkVel;                             // 0x58-0x64
    int x64;                                 // 0x64
    int x68;                                 // 0x68
    int x6c;                                 // 0x6c
    Vec3 nudgeVel;                           // 0x70 - 0x7C
    int x7c;                                 // 0x7c
    int x80;                                 // 0x80
    int x84;                                 // 0x84
    int x88;                                 // 0x88
    int x8c;                                 // 0x8c
    int x90;                                 // 0x90
    int x94;                                 // 0x94
    int x98;                                 // 0x98
    int x9c;                                 // 0x9c
    int xa0;                                 // 0xa0
    int xa4;                                 // 0xa4
    int xa8;                                 // 0xa8
    int xac;                                 // 0xac
    int xb0;                                 // 0xb0
    int xb4;                                 // 0xb4
    void *it_cb;                             // 0xb8, global item callbacks
    ItemState *itemStates;                   // 0xbc
    int isRotate;                            // 0xc0
    itData *itData;                          // 0xc4
    JOBJ *joint;                             // 0xc8
    itCommonAttr *itemAttributes;            // 0xcc
    int xd0;                                 // 0xd0
    int xd4;                                 // 0xd4
    int xd8;                                 // 0xd8
    int xdc;                                 // 0xdc
    int xe0;                                 // 0xe0
    int xe4;                                 // 0xe4
    int xe8;                                 // 0xe8
    int xec;                                 // 0xec
    int xf0;                                 // 0xf0
    int xf4;                                 // 0xf4
    int xf8;                                 // 0xf8
    int xfc;                                 // 0xfc
    int x100;                                // 0x100
    int x104;                                // 0x104
    int x108;                                // 0x108
    int x10c;                                // 0x10c
    int x110;                                // 0x110
    int x114;                                // 0x114
    int x118;                                // 0x118
    int x11c;                                // 0x11c
    int x120;                                // 0x120
    int x124;                                // 0x124
    int x128;                                // 0x128
    int x12c;                                // 0x12c
    int x130;                                // 0x130
    int x134;                                // 0x134
    int x138;                                // 0x138
    int x13c;                                // 0x13c
    int x140;                                // 0x140
    int x144;                                // 0x144
    int x148;                                // 0x148
    int x14c;                                // 0x14c
    int x150;                                // 0x150
    int x154;                                // 0x154
    int x158;                                // 0x158
    int x15c;                                // 0x15c
    int x160;                                // 0x160
    int x164;                                // 0x164
    int x168;                                // 0x168
    int x16c;                                // 0x16c
    int x170;                                // 0x170
    int x174;                                // 0x174
    int x178;                                // 0x178
    int x17c;                                // 0x17c
    int x180;                                // 0x180
    int x184;                                // 0x184
    int x188;                                // 0x188
    int x18c;                                // 0x18c
    int x190;                                // 0x190
    int x194;                                // 0x194
    int x198;                                // 0x198
    int x19c;                                // 0x19c
    int x1a0;                                // 0x1a0
    int x1a4;                                // 0x1a4
    int x1a8;                                // 0x1a8
    int x1ac;                                // 0x1ac
    int x1b0;                                // 0x1b0
    int x1b4;                                // 0x1b4
    int x1b8;                                // 0x1b8
    int x1bc;                                // 0x1bc
    int x1c0;                                // 0x1c0
    int x1c4;                                // 0x1c4
    int x1c8;                                // 0x1c8
    int x1cc;                                // 0x1cc
    int x1d0;                                // 0x1d0
    int x1d4;                                // 0x1d4
    int x1d8;                                // 0x1d8
    int x1dc;                                // 0x1dc
    int x1e0;                                // 0x1e0
    int x1e4;                                // 0x1e4
    int x1e8;                                // 0x1e8
    int x1ec;                                // 0x1ec
    int x1f0;                                // 0x1f0
    int x1f4;                                // 0x1f4
    int x1f8;                                // 0x1f8
    int x1fc;                                // 0x1fc
    int x200;                                // 0x200
    int x204;                                // 0x204
    int x208;                                // 0x208
    int x20c;                                // 0x20c
    int x210;                                // 0x210
    int x214;                                // 0x214
    int x218;                                // 0x218
    int x21c;                                // 0x21c
    int x220;                                // 0x220
    int x224;                                // 0x224
    int x228;                                // 0x228
    int x22c;                                // 0x22c
    int x230;                                // 0x230
    int x234;                                // 0x234
    int x238;                                // 0x238
    int x23c;                                // 0x23c
    int x240;                                // 0x240
    int x244;                                // 0x244
    int x248;                                // 0x248
    int x24c;                                // 0x24c
    int x250;                                // 0x250
    int x254;                                // 0x254
    int x258;                                // 0x258
    int x25c;                                // 0x25c
    int x260;                                // 0x260
    int x264;                                // 0x264
    int x268;                                // 0x268
    int x26c;                                // 0x26c
    int x270;                                // 0x270
    int x274;                                // 0x274
    int x278;                                // 0x278
    int x27c;                                // 0x27c
    int x280;                                // 0x280
    int x284;                                // 0x284
    int x288;                                // 0x288
    int x28c;                                // 0x28c
    int x290;                                // 0x290
    int x294;                                // 0x294
    int x298;                                // 0x298
    int x29c;                                // 0x29c
    int x2a0;                                // 0x2a0
    int x2a4;                                // 0x2a4
    int x2a8;                                // 0x2a8
    int x2ac;                                // 0x2ac
    int x2b0;                                // 0x2b0
    int x2b4;                                // 0x2b4
    int x2b8;                                // 0x2b8
    int x2bc;                                // 0x2bc
    int x2c0;                                // 0x2c0
    int x2c4;                                // 0x2c4
    int x2c8;                                // 0x2c8
    int x2cc;                                // 0x2cc
    int x2d0;                                // 0x2d0
    int x2d4;                                // 0x2d4
    int x2d8;                                // 0x2d8
    int x2dc;                                // 0x2dc
    int x2e0;                                // 0x2e0
    int x2e4;                                // 0x2e4
    int x2e8;                                // 0x2e8
    int x2ec;                                // 0x2ec
    int x2f0;                                // 0x2f0
    int x2f4;                                // 0x2f4
    int x2f8;                                // 0x2f8
    int x2fc;                                // 0x2fc
    int x300;                                // 0x300
    int x304;                                // 0x304
    int x308;                                // 0x308
    int x30c;                                // 0x30c
    int x310;                                // 0x310
    int x314;                                // 0x314
    int x318;                                // 0x318
    int x31c;                                // 0x31c
    int x320;                                // 0x320
    int x324;                                // 0x324
    int x328;                                // 0x328
    int x32c;                                // 0x32c
    int x330;                                // 0x330
    int x334;                                // 0x334
    int x338;                                // 0x338
    int x33c;                                // 0x33c
    int x340;                                // 0x340
    int x344;                                // 0x344
    int x348;                                // 0x348
    int x34c;                                // 0x34c
    int x350;                                // 0x350
    int x354;                                // 0x354
    int x358;                                // 0x358
    int x35c;                                // 0x35c
    int x360;                                // 0x360
    int x364;                                // 0x364
    int x368;                                // 0x368
    int x36c;                                // 0x36c
    int x370;                                // 0x370
    int x374;                                // 0x374
    CollData coll_data;                      // 0x378 -> 0x518
    FighterData *fighter;                    // 0x518
    int x51c;                                // 0x51c
    CameraBox *camerabox;                    // 0x520
    int x524;                                // 0x524
    int x528;                                // 0x528
    int *script_parse;                       // 0x52c
    int x530;                                // 0x530
    int x534;                                // 0x534
    int x538;                                // 0x538
    int x53c;                                // 0x53c
    int x540;                                // 0x540
    int x544;                                // 0x544
    ColorOverlay color;                      // 0x548
    int x5c8;                                // 0x5c8
    int x5cc;                                // 0x5cc
    int x5d0;                                // 0x5d0
    itHit hitbox[4];                         // 0x5d4
    int xac4;                                // 0xac4
    int xac8;                                // 0xac8
    int hurt_status;                         // 0xacc
    int xad0;                                // 0xad0
    int xad4;                                // 0xad4
    int xad8;                                // 0xad8
    int xadc;                                // 0xadc
    int xae0;                                // 0xae0
    int xae4;                                // 0xae4
    int xae8;                                // 0xae8
    int xaec;                                // 0xaec
    int xaf0;                                // 0xaf0
    int xaf4;                                // 0xaf4
    int xaf8;                                // 0xaf8
    int xafc;                                // 0xafc
    int xb00;                                // 0xb00
    int xb04;                                // 0xb04
    int xb08;                                // 0xb08
    int xb0c;                                // 0xb0c
    int xb10;                                // 0xb10
    int xb14;                                // 0xb14
    int xb18;                                // 0xb18
    int xb1c;                                // 0xb1c
    int xb20;                                // 0xb20
    int xb24;                                // 0xb24
    int xb28;                                // 0xb28
    int xb2c;                                // 0xb2c
    int xb30;                                // 0xb30
    int xb34;                                // 0xb34
    int xb38;                                // 0xb38
    int xb3c;                                // 0xb3c
    int xb40;                                // 0xb40
    int xb44;                                // 0xb44
    int xb48;                                // 0xb48
    int xb4c;                                // 0xb4c
    int xb50;                                // 0xb50
    int xb54;                                // 0xb54
    int xb58;                                // 0xb58
    int xb5c;                                // 0xb5c
    int xb60;                                // 0xb60
    int xb64;                                // 0xb64
    int xb68;                                // 0xb68
    int xb6c;                                // 0xb6c
    int xb70;                                // 0xb70
    int xb74;                                // 0xb74
    int xb78;                                // 0xb78
    int xb7c;                                // 0xb7c
    int xb80;                                // 0xb80
    int xb84;                                // 0xb84
    int xb88;                                // 0xb88
    int xb8c;                                // 0xb8c
    int xb90;                                // 0xb90
    int xb94;                                // 0xb94
    int xb98;                                // 0xb98
    int xb9c;                                // 0xb9c
    int xba0;                                // 0xba0
    int xba4;                                // 0xba4
    int xba8;                                // 0xba8
    int xbac;                                // 0xbac
    int xbb0;                                // 0xbb0
    int xbb4;                                // 0xbb4
    int xbb8;                                // 0xbb8
    int xbbc;                                // 0xbbc
    int xbc0;                                // 0xbc0
    int xbc4;                                // 0xbc4
    int xbc8;                                // 0xbc8
    int xbcc;                                // 0xbcc
    int xbd0;                                // 0xbd0
    int xbd4;                                // 0xbd4
    int xbd8;                                // 0xbd8
    int xbdc;                                // 0xbdc
    int xbe0;                                // 0xbe0
    int xbe4;                                // 0xbe4
    int xbe8;                                // 0xbe8
    int xbec;                                // 0xbec
    int xbf0;                                // 0xbf0
    int xbf4;                                // 0xbf4
    int xbf8;                                // 0xbf8
    int xbfc;                                // 0xbfc
    int xc00;                                // 0xc00
    int xc04;                                // 0xc04
    int xc08;                                // 0xc08
    int xc0c;                                // 0xc0c
    int xc10;                                // 0xc10
    int xc14;                                // 0xc14
    int xc18;                                // 0xc18
    float ecb_top;                           // 0xc1c
    float ecb_bottom;                        // 0xc20
    float ecb_right;                         // 0xc24
    float ecb_left;                          // 0xc28
    int xc2c;                                // 0xc2c
    int xc30;                                // 0xc30
    int xc34;                                // 0xc34
    int xc38;                                // 0xc38
    int xc3c;                                // 0xc3c
    int xc40;                                // 0xc40
    int xc44;                                // 0xc44
    int xc48;                                // 0xc48
    int xc4c;                                // 0xc4c
    int xc50;                                // 0xc50
    int xc54;                                // 0xc54
    int xc58;                                // 0xc58
    int xc5c;                                // 0xc5c
    int xc60;                                // 0xc60
    int xc64;                                // 0xc64
    int xc68;                                // 0xc68
    int xc6c;                                // 0xc6c
    int xc70;                                // 0xc70
    int xc74;                                // 0xc74
    int xc78;                                // 0xc78
    int xc7c;                                // 0xc7c
    int xc80;                                // 0xc80
    int xc84;                                // 0xc84
    int xc88;                                // 0xc88
    int xc8c;                                // 0xc8c
    int xc90;                                // 0xc90
    int xc94;                                // 0xc94
    int xc98;                                // 0xc98
    int dmg_total;                           // 0xc9c
    int dmg_recent;                          // 0xca0
    int xca4;                                // 0xca4
    int xca8;                                // 0xca8
    int dmg_angle;                           // 0xcac
    int xcb0;                                // 0xcb0
    int xcb4;                                // 0xcb4
    int xcb8;                                // 0xcb8
    int xcbc;                                // 0xcbc
    int xcc0;                                // 0xcc0
    int xcc4;                                // 0xcc4
    float dmg_kb;                            // 0xcc8
    float dmg_direction;                     // 0xccc
    int xcd0;                                // 0xcd0
    int xcd4;                                // 0xcd4
    int xcd8;                                // 0xcd8
    int xcdc;                                // 0xcdc
    int xce0;                                // 0xce0
    int xce4;                                // 0xce4
    int xce8;                                // 0xce8
    GOBJ *dmgsource_fighter;                 // 0xcec
    GOBJ *dmgsource_item;                    // 0xcf0
    int xcf4;                                // 0xcf4
    int xcf8;                                // 0xcf8
    int xcfc;                                // 0xcfc
    GOBJ *grabbedFighter;                    // 0xd00
    int xd04;                                // 0xd04
    int xd08;                                // 0xd08
    int xd0c;                                // 0xd0c
    int xd10;                                // 0xd10
    struct                                   // cb
    {                                        //
        void (*anim)(GOBJ *item);            // 0xd14
        void (*phys)(GOBJ *item);            // 0xd18
        void (*coll)(GOBJ *item);            // 0xd1c
        void (*accessory)(GOBJ *item);       // 0xd20
        void *xd24;                          // 0xd24
        void *xd28;                          // 0xd28
        void *xd2c;                          // 0xd2c
        void *jumped_on;                     // 0xd30, runs when the item is "jumped on", 80269bac
        void *grabFt_onIt;                   // 0xd34, when grabbing a fighter, run this function on self
        void *grabFt_onFt;                   // 0xd38, when grabbing a fighter, run this function on fighter
    } cb;                                    //
    float rotateSpeed;                       // 0xd3c
    int xd40;                                // 0xd40
    float lifetime;                          // 0xd44
    int xd48;                                // 0xd48
    int xd4c;                                // 0xd4c
    int xd50;                                // 0xd50
    int xd54;                                // 0xd54
    int xd58;                                // 0xd58
    int xd5c;                                // 0xd5c
    int xd60;                                // 0xd60
    int xd64;                                // 0xd64
    int xd68;                                // 0xd68
    int xd6c;                                // 0xd6c
    int xd70;                                // 0xd70
    int xd74;                                // 0xd74
    int xd78;                                // 0xd78
    int xd7c;                                // 0xd7c
    int xd80;                                // 0xd80
    int xd84;                                // 0xd84
    int xd88;                                // 0xd88
    int xd8c;                                // 0xd8c
    int xd90;                                // 0xd90
    int xd94;                                // 0xd94
    int xd98;                                // 0xd98
    int xd9c;                                // 0xd9c
    int xda0;                                // 0xda0
    int xda4;                                // 0xda4
    char xda8;                               // 0xda8
    char xda9;                               // 0xda8
    unsigned char xdaa1 : 1;                 // 0xda8 0x80
    unsigned char xdaa2 : 1;                 // 0xda8 0x40
    unsigned char xdaa3 : 1;                 // 0xda8 0x20
    unsigned char xdaa4 : 1;                 // 0xda8 0x10
    unsigned char xdaa5 : 1;                 // 0xda8 0x08
    unsigned char xdaa6 : 1;                 // 0xda8 0x04
    unsigned char xdaa7 : 1;                 // 0xda8 0x02
    unsigned char visible : 1;               // 0xda8 0x01
    char xdab;                               // 0xda8
    int scriptFlag1;                         // 0xdac
    int scriptFlag2;                         // 0xdb0
    int scriptFlag3;                         // 0xdb4
    int xdb8;                                // 0xdb8
    int scriptFlag4;                         // 0xdbc
    int xdc0;                                // 0xdc0
    int xdc4;                                // 0xdc4
    u16 flags1 : 16;                         // 0xdc8
    u16 xdca1 : 1;                           // 0xdca 0x80
    u16 xdca2 : 1;                           // 0xdca 0x40
    u16 xdca3 : 1;                           // 0xdca 0x20
    u16 xdca4 : 1;                           // 0xdca 0x10
    u16 xdca5 : 1;                           // 0xdca 0x08
    u16 can_hold : 1;                        // 0xdca 0x04
    u16 xdca7 : 1;                           // 0xdca 0x02
    u16 rotateAxis : 3;                      // 0xdcb,
    u16 flags4 : 2;                          // 0xdcb, 0x30
    u16 can_nudge : 1;                       // 0xdcb, 0x08
    u16 xdcb_7 : 3;                          // 0xdcb, 0x07
    unsigned char xdcc1 : 1;                 // 0xdcc, 0x80
    unsigned char xdcc2 : 1;                 // 0xdcc, 0x40
    unsigned char xdcc3 : 1;                 // 0xdcc, 0x20
    unsigned char isCheckBlastzone : 1;      // 0xdcc, 0x10
    unsigned char isCheckRightBlastzone : 1; // 0xdcc, 0x08
    unsigned char isCheckLeftBlastzone : 1;  // 0xdcc, 0x04
    unsigned char isCheckUpBlastzone : 1;    // 0xdcc, 0x02
    unsigned char isCheckDownBlastzone : 1;  // 0xdcc, 0x01
    unsigned char cam_kind : 2;              // 0xdcd, 0xc0. indicates this item has a camera box
    unsigned char xdcd3 : 1;                 // 0xdcd, 0x20
    unsigned char xdcd4 : 1;                 // 0xdcd, 0x10
    unsigned char xdcd5 : 1;                 // 0xdcd, 0x08
    unsigned char xdcd6 : 1;                 // 0xdcd, 0x04
    unsigned char xdcd7 : 1;                 // 0xdcd, 0x02
    unsigned char xdcd8 : 1;                 // 0xdcd, 0x01
    unsigned char xdce1 : 1;                 // 0xdce, 0x80
    unsigned char xdce2 : 1;                 // 0xdce, 0x40
    unsigned char xdce3 : 1;                 // 0xdce, 0x20
    unsigned char xdce4 : 1;                 // 0xdce, 0x10
    unsigned char xdce5 : 1;                 // 0xdce, 0x08
    unsigned char xdce6 : 1;                 // 0xdce, 0x04
    unsigned char xdce7 : 1;                 // 0xdce, 0x02
    unsigned char xdce8 : 1;                 // 0xdce, 0x01
    unsigned char xdcf1 : 1;                 // 0xdcf, 0x80
    unsigned char xdcf2 : 1;                 // 0xdcf, 0x40
    unsigned char xdcf3 : 1;                 // 0xdcf, 0x20
    unsigned char xdcf4 : 1;                 // 0xdcf, 0x10
    unsigned char xdcf5 : 1;                 // 0xdcf, 0x08
    unsigned char xdcf6 : 1;                 // 0xdcf, 0x04
    unsigned char xdcf7 : 1;                 // 0xdcf, 0x02
    unsigned char xdcf8 : 1;                 // 0xdcf, 0x01
    int xdd0;                                // 0xdd0
    int itemVar1;                            // 0xdd4
    int itemVar2;                            // 0xdd8
    int itemVar3;                            // 0xddc
    int itemVar4;                            // 0xde0
    int itemVar5;                            // 0xde4
    int itemVar6;                            // 0xde8
    int itemVar7;                            // 0xdec
    int itemVar8;                            // 0xdf0
    int itemVar9;                            // 0xdf4
    int itemVar10;                           // 0xdf8
    int itemVar11;                           // 0xdfc
    int itemVar12;                           // 0xe00
    int xe04;                                // 0xe04
    int xe08;                                // 0xe08
    int xe0c;                                // 0xe0c
    int xe10;                                // 0xe10
    int xe14;                                // 0xe14
    int xe18;                                // 0xe18
    int xe1c;                                // 0xe1c
    int xe20;                                // 0xe20
    int xe24;                                // 0xe24
    int xe28;                                // 0xe28
    int xe2c;                                // 0xe2c
    int xe30;                                // 0xe30
    int xe34;                                // 0xe34
    int xe38;                                // 0xe38
    int xe3c;                                // 0xe3c
};

/*** Functions ***/

void Item_Hold(GOBJ *item, GOBJ *fighter, int boneID);
void Item_Catch(GOBJ *fighter, int unk);
void Items_StoreItemDataToCharItemTable(undefined4, int);
void Items_StoreItemDataToCharItemTable2(int articleData, int articleID);
void Items_StoreTimeout(GOBJ *item, float timeout);
GOBJ *Item_CreateItem(SpawnItem *item_spawn); // sorry for confusion, use this one for best results
GOBJ *Item_CreateItem1(SpawnItem *item_spawn);
GOBJ *Item_CreateItem2(SpawnItem *item_spawn);
GOBJ *Item_CreateItem3(SpawnItem *item_spawn);
void Item_Destroy(GOBJ *item);
int Item_CollGround_PassLedge(GOBJ *item, void *callback);
int Item_CollGround_StopLedge(GOBJ *item, void *callback);
int Item_CollAir(GOBJ *item, void *callback);
void ItemStateChange(GOBJ *item, int stateID, int flags);
int ItemFrameTimer(GOBJ *item);
void Item_PlaceOnGroundBelow(GOBJ *item);
int Item_CheckIfTouchingWall(GOBJ *item, float *unk[]);
void Item_InitGrab(ItemData *item, int unk, void *OnItem, void *OnFighter);
void Item_ResetAllHitPlayers(ItemData *item);
int Item_CountActiveItems(int itemID);
void Item_CopyDevelopState(GOBJ *item, GOBJ *fighter);
int Items_DecLife(GOBJ *item);
void GXLink_Item(GOBJ *gobj, int pass);
void Item_UpdateSpin(GOBJ *item, float unk);
void Item_EnableSpin(GOBJ *item);
void Item_DisableSpin(GOBJ *item);
void Item_SetLifeTimer(GOBJ *item, float lifetime); // sets frames until item is destroyed
int Item_DecLifeTimer(GOBJ *item);                  // returns isEnd bool
JOBJ *Item_GetBoneJOBJ(GOBJ *item, int bone_index);
int Item_CheckIfEnabled(); // returns bool regarding if items are enabled for this match
void Barrel_EnterBreak(GOBJ *item);

#endif
