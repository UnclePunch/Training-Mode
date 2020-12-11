#ifndef MEX_H_DEVTEXT
#define MEX_H_DEVTEXT

#include "structs.h"
#include "color.h"

/*** Structs ***/

struct DevText
{
    int x0;                   // 0x0
    int x4;                   // 0x4
    int x8;                   // 0x8
    int xc;                   // 0xc
    GXColor bg_color;         // 0x10
    int x14;                  // 0x14
    int x18;                  // 0x18
    int x1c;                  // 0x1c
    int x20;                  // 0x20
    char x24;                 // 0x24
    char x25;                 // 0x25
    char show_text : 1;       // 0x26
    char show_background : 1; // 0x26
    char show_cursor : 1;     // 0x26
    char x27;                 // 0x27
    int x28;                  // 0x28
    int x2c;                  // 0x2c
    DevText *next;            // 0x30
    int x34;                  // 0x34
    int x38;                  // 0x38
    int x3c;                  // 0x3c
    int x40;                  // 0x40
    int x44;                  // 0x44
    int x48;                  // 0x48
    int x4c;                  // 0x4c
    int x50;                  // 0x50
    int x54;                  // 0x54
    int x58;                  // 0x58
    int x5c;                  // 0x5c
};

/*** Functions ***/

DevText *DevelopText_CreateDataTable(int unk1, int x, int y, int width, int height, void *alloc);
void DevelopText_Activate(void *unk, DevText *text);
void DevelopText_AddString(DevText *text, ...);
void DevelopText_EraseAllText(DevText *text);
void DevelopText_StoreBGColor(DevText *text, u8 *RGBA);
void DevelopText_HideText(DevText *text);
void DevelopText_HideBG(DevText *text);
void DevelopText_StoreTextScale(DevText *text, float x, float y);
void Develop_DrawSphere(float size, Vec3 *pos1, Vec2 *pos2, GXColor *diffuse, GXColor *ambient);

int *stc_dblevel = R13 + (-0x6C98);

#endif
