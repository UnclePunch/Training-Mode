#ifndef MEX_H_EFFECTS
#define MEX_H_EFFECTS

#include "structs.h"
#include "datatypes.h"
#include "obj.h"

#define PTCL_LINKMAX 16

/*** Structs ***/

struct Effect
{
    GOBJ *child;
    GOBJ *gobj;
    int x8;
    int xc;
    void *callback;
    int x14;
    int x18;
    int x1c;
    float x20;
    short lifetime;
    char x26;
    char x27;
    char x28;
    char x29;
};

struct Particle
{
    int x0;
    int x4;
    int x8;
    int xc;
    int x10;
    int x14;
    int x18;
    int x1c;
    int x20;
    int x24;
    int x28;
    int x2c;
    int x30;
    int x34;
    int x38;
    int x3c;
    int x40;
    int x44;
    int x48;
    int x4c;
    int x50;
    GeneratorAppSRT *param;
};

struct ptclGen // allocated at 8039d9c8
{
    struct ptclGen *next; // 0x0
    int kind;             // x4
    float random;         // x8
    float xc;             // xc
    JOBJ *joint;          // x10
    u16 genlife;          // x14
    u16 type;             // x16
    u8 ef_file;           // x18
    u8 link_no;           // x19, r3 for 8039f05c
    u8 tex_group;         // x1a
    u8 x1b;               // x1b
    u16 instance;         // x1c
    u16 life;             // x1e
    void *track;          // x20, pointer to track data
    Vec3 pos;             // x24
    Vec3 vel;             // x30
    float gravity;        // x3c
    float friction;       // x40
    float size;           // x44
    float radius;         // x48
    float angle;          // x4c
    int timer;            // x50
    void *mtx;            // x54, points to an SRT mtx used for transforming the generator while attached to a joint
};

struct GeneratorAppSRT // allocated at 803a42b0
{
    int x0;     //x0
    int x4;     //x4
    int x8;     //x8
    int xc;     //xc
    int x10;    //x10
    int x14;    //x14
    int x18;    //x18
    int x1c;    //x1c
    int x20;    //x20
    Vec3 scale; //x24
    int x30;    //x30
    int x34;    //x34
    int x38;    //x38
    int x3c;    //x3c
    int x40;    //x40
    int x44;    //x44
    int x48;    //x48
    int x4c;    //x4c
    int x50;    //x50
    int x54;    //x54
    int x58;    //x58
    int x5c;    //x5c
    int x60;    //x60
    int x64;    //x64
    int x68;    //x68
    int x6c;    //x6c
    int x70;    //x70
    int x74;    //x74
    int x78;    //x78
    int x7c;    //x7c
    int x80;    //x80
    int x84;    //x84
    int x88;    //x88
    int x8c;    //x8c
    int x90;    //x90
    int x94;    //x94
    int x98;    //x98
    int x9c;    //x9c
    int xa0;    //xa0
    u16 xa2;
};

struct Particle2 // created at 80398c90. dont feel like labelling this, offsets are @ 80398de4
{
    struct Particle2 *next; // 0x0
    u32 kind;               // 0x4
    u8 bank;                // 0x8
    u8 texGroup;            // 0x9
    u8 poseNum;             // 0xa
    u8 palNum;              // 0xb
    u16 sizeCount;          // 0xc
    u16 primColCount;       // 0xe
    u16 envColCount;        // 0x10
    u8 primCol[4];          // 0x12
    u8 envCol[4];           // 0x16
    u16 cmdWait;            // 0x1a
    u8 loopCount;           // 0x1c
    u8 linkNo;              // 0x1d
    u16 idnum;              // 0x1e
    void *cmdList;          // 0x20
    u16 cmdPtr;             // 0x24
    u16 cmdMarkPtr;         // 0x26
    u16 cmdLoopPtr;         // 0x28
    u16 life;               // 0x2a
    Vec3 v;                 // 0x2C
    float grav;             // 0x38
    float fric;             // 0x3C
    Vec3 pos;               // 0x40
    float size;             // 0x4C
    float rotate;           // 0x50
    u16 aCmpCount;          // 0x54
    u8 aCmpMode;            // 0x56
    u8 aCmpParam1;          // 0x57
    u8 aCmpParam2;          // 0x58
    void *x5c;
    void *x60;
    void *x64;
    void *x68;
    void *x6c;
    void *x70;
    void *x74;
    void *x78;
    void *x7c;
    void *x80;
    void *x84;
    void *x88;
    void *gen;
    void *x90;
    // theres more but i got bored, rest are here courtesy of psilupan: https://pastebin.com/raw/yQdjypW0
};

/*** Functions ***/

Effect *Effect_SpawnSync(int gfx_id, ...);
void Effect_SpawnAsync(GOBJ *fighter, Effect *ptr, int type, int gfx_id, ...);
void Effect_SpawnFtEffectLookup(GOBJ *gobj, int gfx_id, int bone, int unk, int destroy_on_leave, ...);
void Effect_SpawnItEffectLookup(GOBJ *gobj, int gfx_id, int bone, Vec3 *offset, Vec3 *scatter, int unk3);
void Effect_SpawnItEffect(GOBJ *gobj, int gfx_id);
void Effect_DestroyAll(GOBJ *fighter);
void Particle_DestroyAll(JOBJ *jobj);
void Effect_PauseAll(GOBJ *fighter);
void Effect_ResumeAll(GOBJ *fighter);
int psRemoveParticleAppSRT(Particle2 *ptcl);
void psDeletePntJObjwithParticle(Particle2 *ptcl);
ptclGen *psKillGenerator(ptclGen *gen, ptclGen *unk);

u16 *stc_ptclnum = R13 + (-0x3DBE);      // number of pctls alive
Particle2 **stc_ptcl = 0x804d0908;       // last created ptcl
ptclGen **stc_ptclgen = R13 + (-0x3DA4); // last created gen
ptclGen **stc_ptclgencurr = R13 + (-0x3DA8);
u16 *stc_ptclgennum = R13 + (-0x3DC0);

#endif
