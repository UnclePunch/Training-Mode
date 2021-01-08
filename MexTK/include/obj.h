#ifndef MEX_H_OBJ
#define MEX_H_OBJ

#include "structs.h"
#include "datatypes.h"
#include "color.h"

// JObj Flags
#define JOBJ_SKELETON (1 << 0)
#define JOBJ_SKELETON_ROOT (1 << 1)
#define JOBJ_ENVELOPE_MODEL (1 << 2)
#define JOBJ_CLASSICAL_SCALING (1 << 3)
#define JOBJ_HIDDEN (1 << 4)
#define JOBJ_PTCL (1 << 5)
#define JOBJ_MTX_DIRTY (1 << 6)
#define JOBJ_LIGHTING (1 << 7)
#define JOBJ_TEXGEN (1 << 8)
#define JOBJ_BILLBOARD (1 << 9)
#define JOBJ_VBILLBOARD (2 << 9)
#define JOBJ_HBILLBOARD (3 << 9)
#define JOBJ_RBILLBOARD (4 << 9)
#define JOBJ_INSTANCE (1 << 12)
#define JOBJ_PBILLBOARD (1 << 13)
#define JOBJ_SPLINE (1 << 14)
#define JOBJ_FLIP_IK (1 << 15)
#define JOBJ_SPECULAR (1 << 16)
#define JOBJ_USE_QUATERNION (1 << 17)
#define JOBJ_OPA (1 << 18)
#define JOBJ_XLU (1 << 19)
#define JOBJ_TEXEDGE (1 << 20)
#define JOBJ_NULL (0 << 21)
#define JOBJ_JOINT1 (1 << 21)
#define JOBJ_JOINT2 (2 << 21)
#define JOBJ_EFFECTOR (3 << 21)
#define JOBJ_USER_DEFINED_MTX (1 << 23)
#define JOBJ_MTX_INDEPEND_PARENT (1 << 24)
#define JOBJ_MTS_INDEPEND_SRT (1 << 25)
#define JOBJ_GENERALFLAG (1 << 26)
#define JOBJ_GENERALFLAG2 (1 << 27)
#define JOBJ_ROOT_OPA (1 << 28)
#define JOBJ_ROOT_XLU (1 << 29)
#define JOBJ_ROOT_TEXEDGE (1 << 30)
#define JOBJ_31 (1 << 31)

// MObj Flags
#define MOBJ_ANIM 0x4
#define TOBJ_ANIM 0x10
#define ALL_ANIM 0x7FF
#define HSD_A_M_AMBIENT_R 1
#define HSD_A_M_AMBIENT_G 2
#define HSD_A_M_AMBIENT_B 3
#define HSD_A_M_DIFFUSE_R 4
#define HSD_A_M_DIFFUSE_G 5
#define HSD_A_M_DIFFUSE_B 6
#define HSD_A_M_SPECULAR_R 7
#define HSD_A_M_SPECULAR_G 8
#define HSD_A_M_SPECULAR_B 9
#define HSD_A_M_ALPHA 10
#define HSD_A_M_PE_REF0 11
#define HSD_A_M_PE_REF1 12
#define HSD_A_M_PE_DSTALPHA 13
#define RENDER_DIFFUSE_SHIFT 0
#define RENDER_DIFFUSE_BITS (3 << RENDER_DIFFUSE_SHIFT)
#define RENDER_DIFFUSE_MAT0 (0 << RENDER_DIFFUSE_SHIFT)
#define RENDER_DIFFUSE_MAT (1 << RENDER_DIFFUSE_SHIFT)
#define RENDER_DIFFUSE_VTX (2 << RENDER_DIFFUSE_SHIFT)
#define RENDER_DIFFUSE_BOTH (3 << RENDER_DIFFUSE_SHIFT)
#define RENDER_CONSTANT (1 << 0)
#define RENDER_VERTEX (1 << 1)
#define RENDER_DIFFUSE (1 << 2)
#define RENDER_SPECULAR (1 << 3)
#define CHANNEL_FIELD (RENDER_CONSTANT | RENDER_VERTEX | RENDER_DIFFUSE | RENDER_SPECULAR)
#define RENDER_TEX0 (1 << 4)
#define RENDER_TEX1 (1 << 5)
#define RENDER_TEX2 (1 << 6)
#define RENDER_TEX3 (1 << 7)
#define RENDER_TEX4 (1 << 8)
#define RENDER_TEX5 (1 << 9)
#define RENDER_TEX6 (1 << 10)
#define RENDER_TEX7 (1 << 11)
#define RENDER_TEXTURES (RENDER_TEX0 | RENDER_TEX1 | RENDER_TEX2 | RENDER_TEX3 | RENDER_TEX4 | RENDER_TEX5 | RENDER_TEX6 | RENDER_TEX7)
#define RENDER_TOON (1 << 12)
#define RENDER_ALPHA_SHIFT 13
#define RENDER_ALPHA_BITS (3 << RENDER_ALPHA_SHIFT)
#define RENDER_ALPHA_COMPAT (0 << RENDER_ALPHA_SHIFT)
#define RENDER_ALPHA_MAT (1 << RENDER_ALPHA_SHIFT)
#define RENDER_ALPHA_VTX (2 << RENDER_ALPHA_SHIFT)
#define RENDER_ALPHA_BOTH (3 << RENDER_ALPHA_SHIFT)
#define RENDER_SHADOW (1 << 26)
#define RENDER_ZMODE_ALWAYS (1 << 27)
#define RENDER_NO_ZUPDATE (1 << 29)
#define RENDER_XLU (1 << 30)

// DOBJ flags
#define DOBJ_HIDDEN 1

/*** Structs ***/

struct GOBJ
{
    short entity_class;      // 0x0
    char p_link;             // 0x2
    char gx_link;            // 0x3. 0-63 are gx. 64+ are reserved for camera objects
    char p_priority;         // 0x4
    char gx_pri;             // 0x5
    char obj_kind;           // 0x6
    char data_kind;          // 0x7
    GOBJ *next;              // 0x8
    GOBJ *previous;          // 0xC
    GOBJ *nextOrdered;       // 0x10
    GOBJ *previousOrdered;   // 0x14
    GOBJProc *proc;          // 0x18
    void *gx_cb;             // 0x1C
    u64 cobj_links;          // 0x20. this is used to know which cobj to render to
    void *hsd_object;        // 0x28
    void *userdata;          // 0x2C
    int destructor_function; // 0x30
    int unk_linked_list;     // 0x34
};

struct GOBJProc
{
    GOBJ *parent;
    GOBJProc *next;
    GOBJProc *prev;
    char s_link;            // 0xC
    char flags;             // 0xD
    GOBJ *parentGOBJ;       // 0x10
    void (*cb)(GOBJ *gobj); // function callback
};

struct GOBJList
{
    // pointed to @ -0x3e74(r13)
    // indexed by p_link
    GOBJ *x0;
    GOBJ *x4;
    GOBJ *x8;
    GOBJ *xc;
    GOBJ *x10;
    GOBJ *cobj;
    GOBJ *x18;
    GOBJ *x1c;
    GOBJ *fighter;
    GOBJ *item;
    GOBJ *x28;
    GOBJ *effect_model; // 0x2c
    GOBJ *effect_unk;   // 0x30, used for blastzone effect
    GOBJ *x34;
    GOBJ *x38;
    GOBJ *x3c;
    GOBJ *x40;
    GOBJ *x44;
    GOBJ *match_cam; // 0x48, used for the match camera and shake gobjs
};

struct GXList
{
    // pointed to @ -0x3e80(r13)
    GOBJ *gx_render[63]; // pointer to 63 gobjs
    GOBJ *gx_camera;     // pointer to the highest priority cobj gobj. they are linked together via the next member.
};

struct TOBJ
{
    int *parent;
    int x4;
    TOBJ *next;
    u32 id;                           //GXTexMapID
    u32 src;                          //GXTexGenSrc 0x10
    u32 mtxid;                        // 0x14
    Vec4 rotate;                      // 0x18
    Vec3 scale;                       // 0x28
    Vec3 translate;                   // 0x34
    u32 wrap_s;                       // 0x40 GXTexWrapMode
    u32 wrap_t;                       // 0x44 GXTexWrapMode
    u8 repeat_s;                      // 0x48
    u8 repeat_t;                      // 0x49
    u16 anim_id;                      // 0x4A
    u32 flags;                        // 0x4C
    f32 blending;                     // 0x50
    u32 magFilt;                      // 0x54 GXTexFilter
    struct _HSD_ImageDesc *imagedesc; // 0x58
    struct _HSD_Tlut *tlut;           // 0x5C
    struct _HSD_TexLODDesc *lod;      // 0x60
    AOBJ *aobj;                       // 0x64
    struct _HSD_ImageDesc **imagetbl;
    struct _HSD_Tlut **tluttbl;
    u8 tlut_no;
    Mtx mtx;
    u32 coord; //GXTexCoordID
    struct _HSD_TObjTev *tev;
};

struct AOBJ
{
    u32 flags;
    f32 curr_frame;
    f32 rewind_frame;
    f32 end_frame;
    f32 framerate;
    struct _HSD_FObj *fobj;
    struct _HSD_Obj *hsd_obj;
};

struct MOBJ
{
    int *parent;
    u32 rendermode;
    TOBJ *tobj;
    HSD_Material *mat;
    struct _HSD_PEDesc *pe;
    AOBJ *aobj;
    /*
    struct _HSD_TObj *ambient_tobj;
    struct _HSD_TObj *specular_tobj;
    */
    struct _HSD_TExpTevDesc *tevdesc;
    union _HSD_TExp *texp;

    struct _HSD_TObj *tobj_toon;
    struct _HSD_TObj *tobj_gradation;
    struct _HSD_TObj *tobj_backlight;
    f32 z_offset;
};

struct JOBJDesc
{
    char *class_name;       //0x00
    u32 flags;              //0x04
    struct JOBJDesc *child; //0x08
    struct JOBJDesc *next;  //0x0C
    union
    {
        struct _HSD_DObjDesc *dobjdesc;
        struct _HSD_Spline *spline;
        struct _HSD_SList *ptcl;
    } u;                            //0x10
    Vec3 rotation;                  //0x14 - 0x1C
    Vec3 scale;                     //0x20 - 0x28
    Vec3 position;                  //0x2C - 0x34
    Mtx mtx;                        //0x38
    struct _HSD_RObjDesc *robjdesc; //0x3C
};

struct COBJDesc
{
    char *class_name;                    //0x00
    u16 flags;                           //0x04
    u16 projection_type;                 //0x06
    u16 viewport_left;                   //0x08
    u16 viewport_right;                  //0x0A
    u16 viewport_top;                    //0x0C
    u16 viewport_bottom;                 //0x0E
    u32 scissor_lr;                      //0x10
    u32 scissor_tb;                      //0x14
    struct _HSD_WObjDesc *eye_desc;      //0x18
    struct _HSD_WObjDesc *interest_desc; //0x1C
    f32 roll;                            //0x20
    Vec3 *vector;                        //0x24
    f32 near;                            //0x28
    f32 far;                             //0x2C
    union
    {
        struct
        {
            f32 fov;
            f32 aspect;
        } perspective;

        struct
        {
            f32 top;
            f32 bottom;
            f32 left;
            f32 right;
        } frustrum;

        struct
        {
            f32 top;
            f32 bottom;
            f32 left;
            f32 right;
        } ortho;
    } projection_param;
};

struct DOBJ
{
    int parent;
    DOBJ *next; //0x04
    MOBJ *mobj; //0x08
    int *pobj;  //0x0C
    AOBJ *aobj; //0x10
    u32 flags;  //0x14
    u32 unk;
};

struct JOBJ
{
    int hsd_info;     //0x0
    int class_parent; //0x4
    JOBJ *sibling;    //0x08
    JOBJ *parent;     //0x0C
    JOBJ *child;      //0x10
    int flags;        //0x14
    DOBJ *dobj;       //0x18
    Vec4 rot;         //0x1C 0x20 0x24 0x28
    Vec3 scale;       //0x2C
    Vec3 trans;
    Mtx rotMtx;
    Vec3 *VEC;
    Mtx *MTX;
    AOBJ *aobj;
    int *RObj;
    JOBJDesc *desc;
};

struct WOBJ
{
    void *parent;
    u32 flags;  //0x08
    Vec3 pos;   //0xC
    AOBJ *aobj; //0x18
    void *robj; //0x1C
};

struct COBJ
{
    u64 parent;          // 0x0
    u32 flags;           //0x08
    f32 viewport_left;   //0x0C
    f32 viewport_right;  //0x10
    f32 viewport_top;    //0x14
    f32 viewport_bottom; //0x18
    u16 scissor_left;    //0x1C
    u16 scissor_right;   //0x1E
    u16 scissor_top;     //0x20
    u16 scissor_bottom;  //0x22
    WOBJ *eye_position;  //0x24
    WOBJ *interest;      //0x28
    union
    {
        f32 roll; //0x28
        Vec3 up;  //0x2C - 0x38
    } u;
    f32 near; //0x3C
    f32 far;  //0x40
    union
    {
        struct
        {
            f32 fov;
            f32 aspect;
        } perspective;

        struct
        {
            f32 top;
            f32 bottom;
            f32 left;
            f32 right;
        } frustrum;

        struct
        {
            f32 top;
            f32 bottom;
            f32 left;
            f32 right;
        } ortho;
    } projection_param;
    u8 projection_type; //0x50
    Mtx view_mtx;       //0x54
    AOBJ *aobj;         //0x84
    Mtx proj_mtx;       //0x88
};

struct _HSD_ImageDesc
{
    void *img_ptr;
    u16 width;
    u16 height;
    u32 format;
    u32 mipmap;
    f32 minLOD;
    f32 maxLOD;
};

struct _HSD_LightPoint
{
    f32 cutoff;
    u8 point_func;
    f32 ref_br;
    f32 ref_dist;
    u8 dist_func;
};

struct _HSD_LightPointDesc
{
    f32 cutoff;
    u8 point_func;
    f32 ref_br;
    f32 ref_dist;
    u8 dist_func;
};

struct _HSD_LightSpot
{
    f32 cutoff;
    u8 spot_func;
    f32 ref_br;
    f32 ref_dist;
    u8 dist_func;
};

struct _HSD_LightSpotDesc
{
    f32 cutoff;
    u8 spot_func;
    f32 ref_br;
    f32 ref_dist;
    u8 dist_func;
};

struct _HSD_LightAttn
{
    f32 a0;
    f32 a1;
    f32 a2;
    f32 k0;
    f32 k1;
    f32 k2;
};

struct LOBJ
{
    u64 parent;        //0x00
    u16 flags;         //0x08
    u16 priority;      //0x0A
    struct LOBJ *next; //0x0C
    GXColor color;     //0x10
    GXColor hw_color;  //0x14
    WOBJ *position;    //0x18
    WOBJ *interest;    //0x1C
    union
    {
        _HSD_LightPoint point;
        _HSD_LightSpot spot;
        _HSD_LightAttn attn;
    } u;
    f32 shininess;
    Vec3 lvec;
    struct AOBJ *aobj;
    u32 id; //GXLightID
    //GXLightObj lightobj;      //0x50
    u32 spec_id; //0x90 GXLightID
    //GXLightObj spec_lightobj; //0x94
};

struct JOBJAnimSet
{
    JOBJDesc *jobj;
    void *animjoint;
    void *matanimjoint;
    void *shapeaninjoint;
};

/*** Static Variables ***/
GOBJList **stc_gobj_list = R13 + (-0x3E74);
u8 *obj_kind = R13 + -(0x3E55);

/*** Functions ***/
int JOBJ_GetWorldPosition(JOBJ *source, Vec3 *add, Vec3 *dest);
void JOBJ_SetMtxDirtySub(JOBJ *jobj);
JOBJ *JOBJ_LoadJoint(JOBJDesc *joint);
void JOBJ_RemoveAll(JOBJ *joint);
void JOBJ_Remove(JOBJ *joint);
void JOBJ_GetChild(JOBJ *joint, int ptr, int index, ...);
void JOBJ_AddChild(JOBJ *parent, JOBJ *child);
float JOBJ_GetCurrentMatAnimFrame(JOBJ *joint);
void JOBJ_SetFlags(JOBJ *joint, int flags);
void JOBJ_SetFlagsAll(JOBJ *joint, int flags);
void JOBJ_ClearFlags(JOBJ *joint, int flags);
void JOBJ_ClearFlagsAll(JOBJ *joint, int flags);
void JOBJ_BillBoard(JOBJ *joint, Mtx *m, Mtx *mx);
void JOBJ_RunAOBJCallback(JOBJ *joint, int unk, u16 flags, void *cb, int argkind, ...); // flags: 0x400 matanim, 0x20 jointanim, argkind specifies how to pop args off the va_list
void JOBJ_Anim(JOBJ *joint);
void JOBJ_AnimAll(JOBJ *joint);
void JOBJ_AddAnimAll(JOBJ *joint, void *animjoint, void *matanimjoint, void *shapeanimjoint);
void JOBJ_RemoveAnimAll(JOBJ *joint);
void JOBJ_ReqAnim(JOBJ *joint, float frame);
void JOBJ_ReqAnimByFlags(JOBJ *joint, int flags, float frame);
void JOBJ_ReqAnimAll(JOBJ *joint, float unk);
void JOBJ_ReqAnimAllByFlags(JOBJ *joint, int flags, float frame);
float JOBJ_GetJointAnimFrameTotal(JOBJ *joint);
float JOBJ_GetJointAnimNextFrame(JOBJ *joint);
void JOBJ_SetAllMOBJFlags(JOBJ *joint, int flags);
int JOBJ_CheckAObjEnd(JOBJ *joint);
void AOBJ_ReqAnim(int *aobj, float unk);
void AOBJ_StopAnim(JOBJ *jobj, int flags, int flags2);
void AOBJ_SetRate(AOBJ *aobj, float rate);
void DOBJ_SetFlags(DOBJ *dobj, int flags);
void DOBJ_ClearFlags(DOBJ *dobj, int flags);
COBJ *COBJ_LoadDesc(COBJDesc *cobj);
COBJ *COBJ_LoadDescSetScissor(COBJDesc *cobj);
COBJ *COBJ_GetMatchCamera();
void CObjThink_Common(GOBJ *gobj);
GOBJ *GObj_Create(int type, int subclass, int flags);
void GObj_Destroy(GOBJ *gobj);
void GObj_AddGXLink(GOBJ *gobj, void *cb, int gx_link, int gx_pri);
void GObj_DestroyGXLink(GOBJ *gobj);
void GObj_GXReorder(GOBJ *gobj, int unk);
void GObj_AddProc(GOBJ *gobj, void *callback, int priority);
void GObj_RemoveProc(GOBJ *gobj);
void GObj_AddObject(GOBJ *gobj, u8 unk, void *object);
void GObj_FreeObject(GOBJ *gobj);
void GObj_AddUserData(GOBJ *gobj, int userDataKind, void *destructor, void *userData);
void GOBJ_InitCamera(GOBJ *gobj, void *cb, int gx_pri);
void GXLink_Common(GOBJ *gobj, int pass);
void GXLink_LObj(GOBJ *gobj, int pass);
void GXLink_Fog(GOBJ *gobj, int pass);
void *LObj_LoadDesc(void *lobjdesc);
void *Fog_LoadDesc(void *fogdesc);
DOBJ *JOBJ_GetDObj(JOBJ *jobj);
void *MOBJ_SetAlpha(DOBJ *dobj);
void GObj_CopyGXPri(GOBJ *target, GOBJ *source);

#endif