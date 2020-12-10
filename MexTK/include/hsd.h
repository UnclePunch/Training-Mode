#ifndef MEX_H_HSD
#define MEX_H_HSD

#include "structs.h"
#include "datatypes.h"
#include "obj.h"
#include "color.h"

// button bits
#define PAD_BUTTON_DPAD_LEFT 0x1
#define PAD_BUTTON_DPAD_RIGHT 0x2
#define PAD_BUTTON_DPAD_DOWN 0x4
#define PAD_BUTTON_DPAD_UP 0x8
#define PAD_TRIGGER_Z 0x10
#define PAD_TRIGGER_R 0x20
#define PAD_TRIGGER_L 0x40
#define PAD_BUTTON_A 0x100
#define PAD_BUTTON_B 0x200
#define PAD_BUTTON_X 0x400
#define PAD_BUTTON_Y 0x800
#define PAD_BUTTON_START 0x1000
#define PAD_BUTTON_UP 0x10000
#define PAD_BUTTON_DOWN 0x20000
#define PAD_BUTTON_LEFT 0x40000
#define PAD_BUTTON_RIGHT 0x80000

#define HSD_BUTTON_DPAD_LEFT 0x0001
#define HSD_BUTTON_DPAD_RIGHT 0x0002
#define HSD_BUTTON_DPAD_DOWN 0x0004
#define HSD_BUTTON_DPAD_UP 0x0008
#define HSD_TRIGGER_Z 0x0010
#define HSD_TRIGGER_R 0x0020
#define HSD_TRIGGER_L 0x0040
#define HSD_BUTTON_A 0x0100
#define HSD_BUTTON_B 0x0200
#define HSD_BUTTON_X 0x0400
#define HSD_BUTTON_Y 0x0800
#define HSD_BUTTON_START 0x1000
#define HSD_BUTTON_UP 0x10000
#define HSD_BUTTON_DOWN 0x20000
#define HSD_BUTTON_LEFT 0x40000
#define HSD_BUTTON_RIGHT 0x80000

/*** Structs ***/

struct HSD_ObjAllocData
{
    u32 flags;                     //0x00 - Technically 2 diff flags
    void *freehead;                //0x04
    u32 used;                      //0x08
    u32 free;                      //0x0C
    u32 peak;                      //0x10
    u32 num_limit;                 //0x14
    u32 heap_limit_size;           //0x18
    u32 heap_limit_num;            //0x1C
    u32 size;                      //0x20
    u32 align;                     //0x24
    struct HSD_ObjAllocData *next; //0x28
};

struct HSD_Material
{
    GXColor ambient;
    GXColor diffuse;
    GXColor specular;
    float alpha;
    float shininess;
};

struct HSD_Pad
{
    int held;            // 0x0
    int heldPrev;        // 0x4
    int down;            // 0x8
    int rapidFire;       // 0xc
    int up;              // 0x10
    int rapidTimer;      // 0x14
    s8 stickX;           // 0x18
    s8 stickY;           // 0x19
    s8 substickX;        // 0x1a
    s8 substickY;        // 0x1b
    u8 triggerLeft;      // 0x1c
    u8 triggerRight;     // 0x1d
    float fstickX;       // 0x20
    float fstickY;       // 0x24
    float fsubstickX;    // 0x28
    float fsubstickY;    // 0x2c
    float ftriggerLeft;  // 0x30
    float ftriggerRight; // 0x34
    float x38;           // 0x38
    float x3c;           // 0x3c
    u8 x40;              // 0x40
    u8 status;           // 0x41   0 = plugged, -1 = unplugged
};

struct HSD_Pads
{
    HSD_Pad pad[4];
};

struct HSD_Update
{
    // 0x80479d58
    u32 sys_frames_pre;                   //0x0
    u32 sys_frames_post;                  //0x4
    u32 engine_frames;                    //0x8
    u32 change_scene;                     //0xC
    unsigned char flag1 : 1;              //0x10 - 0x80
    unsigned char flag2 : 1;              //0x10 - 0x40
    unsigned char flag3 : 1;              //0x10 - 0x20
    unsigned char flag4 : 1;              //0x10 - 0x10
    unsigned char flag5 : 1;              //0x10 - 0x08
    unsigned char flag6 : 1;              //0x10 - 0x04
    unsigned char pause_game : 1;         //0x10 - 0x02
    unsigned char pause_develop : 1;      //0x10 - 0x01
    unsigned char flag9 : 1;              //0x11 - 0x80
    unsigned char flag10 : 1;             //0x11 - 0x40
    unsigned char flag11 : 1;             //0x11 - 0x20
    unsigned char flag12 : 1;             //0x11 - 0x10
    unsigned char flag13 : 1;             //0x11 - 0x08
    unsigned char flag14 : 1;             //0x11 - 0x04
    unsigned char pause_game_prev : 1;    //0x11 - 0x02
    unsigned char pause_develop_prev : 1; //0x11 - 0x01
    unsigned char flag17 : 1;             //0x12 - 0x80
    unsigned char flag18 : 1;             //0x12 - 0x40
    unsigned char flag19 : 1;             //0x12 - 0x20
    unsigned char flag20 : 1;             //0x12 - 0x10
    unsigned char flag21 : 1;             //0x12 - 0x08
    unsigned char flag22 : 1;             //0x12 - 0x04
    unsigned char flag23 : 1;             //0x12 - 0x02
    unsigned char advance : 1;            //0x12 - 0x01
    unsigned char flag24 : 1;             //0x12 - 0x80
    unsigned char flag25 : 1;             //0x12 - 0x40
    unsigned char flag26 : 1;             //0x12 - 0x20
    unsigned char flag27 : 1;             //0x12 - 0x10
    unsigned char flag28 : 1;             //0x12 - 0x08
    unsigned char flag29 : 1;             //0x12 - 0x04
    unsigned char flag30 : 1;             //0x12 - 0x02
    unsigned char advance_prev : 1;       //0x12 - 0x01
    int (*checkPause)();                  //0x14 returns 1 when toggling pause
    int (*checkAdvance)();                //0x18 returns 1 when advancing frame
    u32 x1c;                              //0x1C
    u32 x20;
    u32 x24;
    u32 x28;
    u32 x2c;
    void (*onFrame)(); //0x30
};

struct HSD_VI
{
    int x0;
    int x4;
    int is_prog;
};

/*** Static Variables ***/
static HSD_VI *stc_HSD_VI = 0x8046b0f0;

/*** Functions ***/

int HSD_Randi(int max);
float HSD_Randf();
void *HSD_MemAlloc(int size);
void HSD_Free(void *ptr);
void *HSD_ObjAlloc(HSD_ObjAllocData *obj_def);
void HSD_ObjFree(HSD_ObjAllocData *obj_def, void *obj);
void HSD_ImageDescCopyFromEFB(_HSD_ImageDesc *image_desc, int left, int top, int z_flag);     // must be called from a cobj callback!
void GX_AllocImageData(_HSD_ImageDesc *image_desc, int width, int height, int fmt, int size); // image data buffer is stored to the image_desc
void GXTexModeSync();
void GXPixModeSync();
void GXInvalidateTexAll();
u64 Pad_GetRapidHeld(int pad);
#endif
