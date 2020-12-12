#ifndef MEX_H_STAGE
#define MEX_H_STAGE

#include "structs.h"
#include "datatypes.h"
#include "hsd.h"
#include "obj.h"

// map_gobjDesc Flags
#define map_isBG 0x40000000
#define map_isUnk 0x80000000

enum GrInternal
{
    GR_DUMMY,
    GR_TEST,
    GR_CASTLE,
    GR_RCRUISE,
    GR_KONGO,
    GR_GARDEN,
    GR_GREATBAY,
    GR_SHRINE,
    GR_ZEBES,
    GR_KRAID,
    GR_STORY,
    GR_YOSTER,
    GR_IZUMI,
    GR_GREENS,
    GR_CORNERIA,
    GR_VENOM,
    GR_PSTAD,
    GR_PURA,
    GR_MUTECITY,
    GR_BIGBLUE,
    GR_ONETT,
    GR_FOURSIDE,
    GR_ICEMT,
    GR_ICETOP,
    GR_MK1,
    GR_MK2,
    GR_AKANEIA,
    GR_FLATZONE,
    GR_OLDPU,
    GR_OLDSTORY,
    GR_OLDKONGO,
    GR_ADVKRAID,
    GR_ADVSHRINE,
    GR_ADVZR,
    GR_ADVBR,
    GR_ADVTE,
    GR_BATTLE,
    GR_FD,
};

/*** Structs ***/

struct map_gobjDesc
{
    void *(*onCreation)(GOBJ *map);
    void *onDeletion;
    void *onFrame;
    void *onUnk;
    int flags;
};

struct map_gobjData
{
    int x0;                    // 0x0
    GOBJ *gobj;                // 0x4
    int x8;                    // 0x8
    int xC;                    // 0xC
    unsigned char flagx80 : 1; //  0x80
    unsigned char flagx40 : 1; //  0x40
    unsigned char isFog : 1;   //  0x20, checked @ 801c5e80 and 801c5f10
    unsigned char flagx10 : 1; //  0x10
    unsigned char flagx8 : 1;  //  0x08
    unsigned char gx_unk1 : 1; //  0x04, checked @ 801c5e9c
    unsigned char flagx2 : 1;  //  0x02
    unsigned char flagx1 : 1;  //  0x01

    unsigned char gx_unk2 : 3;  //  0x80
    unsigned char flag2x10 : 1; //  0x10
    unsigned char flag2x08 : 1; //  0x08
    unsigned char flag2x04 : 1; //  0x04, checked @ 801c5e9c
    unsigned char flag2x02 : 1; //  0x02
    unsigned char flag2x01 : 1; //  0x01

    int map_gobjID;      // 0x14
    int x18;             // 0x18
    int onUnk;           // 0x1c
    int x20;             // 0x20
    int x24;             // 0x24
    int stateID;         // 0x28
    int facingDirection; // 0x2c
    int x30;             // 0x30
    int x34;             // 0x34
    float scale;         // 0x38
    int x3c;             // 0x3c
    float selfVelX;      // 0x40
    float selfVelY;      // 0x44
    float selfVelZ;      // 0x48
    float posX;          // 0x4c
    float posY;          // 0x50
    float posZ;          // 0x54
    int x58;             // 0x58
    int x5c;             // 0x5c
    int x60;             // 0x60
    int x64;             // 0x64
    int x68;             // 0x68
    int x6c;             // 0x6c
    int x70;             // 0x70
    int x74;             // 0x74
    int x78;             // 0x78
    int x7c;             // 0x7c
    int x80;             // 0x80
    int x84;             // 0x84
    int x88;             // 0x88
    int x8c;             // 0x8c
    int x90;             // 0x90
    int x94;             // 0x94
    int x98;             // 0x98
    int x9c;             // 0x9c
    int xa0;             // 0xa0
    int xa4;             // 0xa4
    int xa8;             // 0xa8
    int xac;             // 0xac
    int xb0;             // 0xb0
    int xb4;             // 0xb4
    int xb8;             // 0xb8
    int xbc;             // 0xbc
    int xc0;             // 0xc0
    u8 xc4;              // 0xc4
    u8 xc5;              // 0xc5
    u8 xc6;              // 0xc6
    u8 xc7;              // 0xc7
    int xc8;             // 0xc8
    int xcc;             // 0xcc
    int xd0;             // 0xd0
    int xd4;             // 0xd4
    int xd8;             // 0xd8
    int xdc;             // 0xdc
    struct
    {
        int mapVar0; // 0xe0
        int mapVar1; // 0xe4
        int mapVar2; // 0xe8
        int mapVar3; // 0xec
        int mapVar4; // 0xf0
        int mapVar5; // 0xf4
        int mapVar6; // 0xf8
        int mapVar7; // 0xfc
        int x100;    // 0x100
        int x104;    // 0x104
        int x108;    // 0x108
        int x10c;    // 0x10c
        int x110;    // 0x110
        int x114;    // 0x114
        int x118;    // 0x118
        int x11c;    // 0x11c
        int x120;    // 0x120
        int x124;    // 0x124
        int x128;    // 0x128
        int x12c;    // 0x12c
        int x130;    // 0x130
        int x134;    // 0x134
        int x138;    // 0x138
        int x13c;    // 0x13c
        int x140;    // 0x140
        int x144;    // 0x144
        int x148;    // 0x148
        int x14c;    // 0x14c
        int x150;    // 0x150
        int x154;    // 0x154
        int x158;    // 0x158
        int x15c;    // 0x15c
        int x160;    // 0x160
        int x164;    // 0x164
        int x168;    // 0x168
        int x16c;    // 0x16c
        int x170;    // 0x170
        int x174;    // 0x174
        int x178;    // 0x178
        int x17c;    // 0x17c
        int x180;    // 0x180
        int x184;    // 0x184
        int x188;    // 0x188
        int x18c;    // 0x18c
        int x190;    // 0x190
        int x194;    // 0x194
        int x198;    // 0x198
        int x19c;    // 0x19c
        int x1a0;    // 0x1a0
        int x1a4;    // 0x1a4
        int x1a8;    // 0x1a8
        int x1ac;    // 0x1ac
        int x1b0;    // 0x1b0
        int x1b4;    // 0x1b4
        int x1b8;    // 0x1b8
        int x1bc;    // 0x1bc
        int x1c0;    // 0x1c0
        int x1c4;    // 0x1c4
        int x1c8;    // 0x1c8
        int x1cc;    // 0x1cc
        int x1d0;    // 0x1d0
        int x1d4;    // 0x1d4
        int x1d8;    // 0x1d8
        int x1dc;    // 0x1dc
        int x1e0;    // 0x1e0
        int x1e4;    // 0x1e4
        int x1e8;    // 0x1e8
        int x1ec;    // 0x1ec
        int x1f0;    // 0x1f0
        int x1f4;    // 0x1f4
        int x1f8;    // 0x1f8
        int x1fc;    // 0x1fc
        int x200;    // 0x200
    } map_struct;
};

struct StageOnGO
{
    StageOnGO *next;
    GOBJ *map_gobj;
    void *cb;
};

struct Stage
{
    float cam_LeftBound;   // 0x0
    float cam_RightBound;  // 0x4
    float cam_TopBound;    // 0x8
    float cam_BottomBound; // 0xc
    float cam_HorizOffset; // 0x10
    float crowdReactStart; // 0x14, begins checking for crowd gasps below this position
    float fov_d;           // 0x18
    float fov_u;           // 0x1c
    float fov_r;           // 0x20, actually horizontal rotation?
    float fov_l;           // 0x24
    float x28;             // 0x28
    float x2c;             // 0x2c
    float x30;             // 0x30
    float x34;             // 0x34, camera distance min
    float x38;             // 0x38
    float x3c;             // 0x3c
    float x40;             // 0x40
    int x44;               // 0x44
    int x48;               // 0x48
    int x4c;               // 0x4c
    int x50;               // 0x50
    int x54;               // 0x54
    int x58;               // 0x58
    int x5c;               // 0x5c
    int x60;               // 0x60
    int x64;               // 0x64
    int x68;               // 0x68
    int x6c;               // 0x6c
    int x70;               // 0x70
    float blastzoneLeft;   // 0x74
    float blastzoneRight;  // 0x78
    float blastzoneTop;    // 0x7c
    float blastzoneBottom; // 0x80
    int flags;             // 0x84
    int stageID;           // 0x88
    int flags2;            // 0x8c
    int x90;               // 0x90
    int x94;               // 0x94
    int hpsID;             // 0x98
    int x9c;               // 0x9c
    int xa0;               // 0xa0
    int xa4;               // 0xa4
    int xa8;               // 0xa8
    int xac;               // 0xac
    int xb0;               // 0xb0
    int xb4;               // 0xb4
    int xb8;               // 0xb8
    int xbc;               // 0xbc
    int xc0;               // 0xc0
    int xc4;               // 0xc4
    int xc8;               // 0xc8
    int xcc;               // 0xcc
    int xd0;               // 0xd0
    int xd4;               // 0xd4
    int xd8;               // 0xd8
    int xdc;               // 0xdc
    int xe0;               // 0xe0
    int xe4;               // 0xe4
    int xe8;               // 0xe8
    int xec;               // 0xec
    int xf0;               // 0xf0
    int xf4;               // 0xf4
    int xf8;               // 0xf8
    int xfc;               // 0xfc
    int x100;              // 0x100
    int x104;              // 0x104
    int x108;              // 0x108
    int x10c;              // 0x10c
    int x110;              // 0x110
    int x114;              // 0x114
    int x118;              // 0x118
    int x11c;              // 0x11c
    int x120;              // 0x120
    int x124;              // 0x124
    int x128;              // 0x128
    int x12c;              // 0x12c
    int x130;              // 0x130
    int x134;              // 0x134
    int x138;              // 0x138
    int x13c;              // 0x13c
    int x140;              // 0x140
    int x144;              // 0x144
    int x148;              // 0x148
    int x14c;              // 0x14c
    int x150;              // 0x150
    int x154;              // 0x154
    int x158;              // 0x158
    int x15c;              // 0x15c
    int x160;              // 0x160
    int x164;              // 0x164
    int x168;              // 0x168
    int x16c;              // 0x16c
    int x170;              // 0x170
    int x174;              // 0x174
    int x178;              // 0x178
    int x17c;              // 0x17c
    GOBJ *map_gobjs[64];
    JOBJ *general_points[256]; // 0x280
    int x680;                  // 0x680
    int x684;                  // 0x684
    int x688;                  // 0x688
    int x68c;                  // 0x68c
    int x690;                  // 0x690
    int x694;                  // 0x694
    int x698;                  // 0x698
    int x69c;                  // 0x69c
    int x6a0;                  // 0x6a0
    StageOnGO *on_go;          // 0x6a4
    int *itemData;             // 0x6a8
    int *coll_data;            // 0x6ac
    int *grGroundParam;        // 0x6b0
    int *ALDYakuAll;           // 0x6b4
    int *map_ptcl;             // 0x6b8
    int *map_texg;             // 0x6bc
    int *yakumono_param;       // 0x6c0
    int *map_plit;             // 0x6c4
    int *x6c8;                 // 0x6c8
    void *quake_model_set;     // 0x6cc
    int *x6d0;                 // 0x6d0
    int *targetsRemaining;     // 0x6d4
    int x6d8;                  // 0x6d8
    int x6dc;                  // 0x6dc
    int x6e0;                  // 0x6e0
    int x6e4;                  // 0x6e4
    int x6e8;                  // 0x6e8
    int x6ec;                  // 0x6ec
    int x6f0;                  // 0x6f0
    int x6f4;                  // 0x6f4
    int x6f8;                  // 0x6f8
    int x6fc;                  // 0x6fc
    int x700;                  // 0x700
    int x704;                  // 0x704
    int x708;                  // 0x708
    int x70c;                  // 0x70c
    int x710;                  // 0x710
    int x714;                  // 0x714
    int x718;                  // 0x718
    int x71c;                  // 0x71c
    int x720;                  // 0x720
    int x724;                  // 0x724
    int x728;                  // 0x728
    int x72C;                  // 0x728
};

struct MapHead
{
    int *general_points;
    int general_points_num;
    int *map_gobjs; // pointer to array of map_gobjs
    int map_gobj_num;
    int *splines;
    int splines_num;
    int *lights;
    int lights_num;
};

struct StageFile
{
    ArchiveInfo *archive_info;
    MapHead *map_head;
};

/*** Functions ***/

StageFile *Stage_GetStageFiles();                 // returns an array of StageFiles
StageFile *Stage_GetStageFile(int mapgobj_index); // returns the StageFile the ID belongs to
void Stage_AddFtChkDevice(GOBJ *map, int hazard_kind, void *check);
void Stage_SetChkDevicePos(float y_pos);
void Stage_GetChkDevicePos(float *y_pos, float *y_delta);
float Stage_GetScale();
int *Stage_GetYakumonoParam();
void Stage_MapStateChange(GOBJ *map, int map_gobjID, int anim_id);
void Dynamics_DecayWind();
GOBJ *Stage_CreateMapGObj(int mapgobjID);
void Stage_DestroyMapGObj(GOBJ *map_gobj);
void *GXLink_Stage(GOBJ *gobj, int pass);
GOBJ *Stage_GetMapGObj(int mapgobjID);
JOBJ *Stage_GetMapGObjJObj(GOBJ *mapgobj, int jointIndex);
int Stage_GetLinesGroup(int line);
int Stage_GetLinesDirection(int line);
void Stage_SetGroundCallback(int line, void *userdata, void *callback);
void Stage_SetCeilingCallback(int line, void *userdata, void *callback);
void Stage_InitMovingColl(JOBJ *mapjoint, int mapgobjID);
void Stage_UpdateMovingColl(GOBJ *mapgobj);
Particle *Stage_SpawnEffectPos(int gfxID, int efFileID, Vec3 *pos);
Particle *Stage_SpawnEffectJointPos(int gfxID, int efFileID, JOBJ *pos);
Particle *Stage_SpawnEffectJointPos2(int gfxID, int efFileID, JOBJ *pos);
GOBJ *Zako_Create(int item_id, Vec3 *pos, JOBJ *jobj, Vec3 *velocity, int isMovingItem);
GOBJ *Stage_CreateMapItem(map_gobjData *map_data, int takeDamageSFXKind, int state, JOBJ *joint, Vec3 *pos, int unk_bool, void *onGiveDamage, void *onTakeDamage); // this function creates an item of id 0xA0, its a generic ID used across multiple stages. its mainly used for giving a joint a hurtbox/hitbox and an onTakeDamage callback.
int Stage_CheckForNearbyFighters(Vec3 *pos, float radius);
float Stage_GetBlastzoneRight();
float Stage_GetBlastzoneLeft();
float Stage_GetBlastzoneTop();
float Stage_GetBlastzoneBottom();
float Stage_GetCameraRight();
float Stage_GetCameraLeft();
float Stage_GetCameraTop();
float Stage_GetCameraBottom();
void Stage_GetGeneralPoint(int index, Vec3 *pos);
void Stage_EnableLineGroup(int index);
void Stage_DisableLineGroup(int index);
int Stage_GetExternalID();
int Stage_ExternalToInternal(int ext_id);

Stage *stc_stage = 0x8049e6c8;
int *ftchkdevice_windnum = R13 + (-0x5128);
int *ftchkdevice_grabnum = R13 + (-0x512C);
int *ftchkdevice_dmgnum = R13 + (-0x5130);
#endif
