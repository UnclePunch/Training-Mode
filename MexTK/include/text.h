#ifndef MEX_H_TEXT
#define MEX_H_TEXT

#include "structs.h"
#include "datatypes.h"
#include "obj.h"
#include "color.h"

/*** Structs ***/

struct TextAllocInfo
{
    u8 *curr;
    u8 *start;
    int size;
};

struct Text
{
    Vec3 trans;  // 0x0-0xC
    Vec2 aspect; // 0xC-0x14
    int x14;
    int x18;
    int x1c;
    int x20;
    Vec2 scale; // 0x24-0x2C
    int x2C;
    GXColor color;
    Vec2 stretch;  // 0x34-0x3C
    int x3c;       // 0x3c
    int x40;       // 0x40
    int x44;       // 0x44
    u8 use_aspect; // 0x48
    u8 kerning;    // 0x49
    u8 align;      // 0x4a
    u8 x4b;
    u8 x4c;
    u8 hidden; // 0x4D
    u8 x4e;
    u8 sis_id; // 0x4F, id of the premade text file to use
    int x50;
    GOBJ *gobj;               // 0x54
    void *callback;           // 0x58, read at 803a878c
    u8 *textAlloc;            // 0x5C
    u8 *textAlloc2;           // 0x60
    TextAllocInfo *allocInfo; // 0x64
};

/*** Functions ***/

int Text_CreateCanvas(int unk, GOBJ *gobj, int text_gobjkind, int text_gobjsubclass, int text_gobjflags, int text_gxlink, int text_gxpri, int cobj_gxpri); // the optional gobj and cobj_gxlink are used to create a cobj as well. set gobj
Text *Text_CreateText(int SisIndex, int canvasID);
Text *Text_CreateText2(int SisIndex, int canvasID, float pos_x, float pos_y, float pos_z, float limit_x, float limit_y);
void Text_Destroy(Text *text);
int Text_AddSubtext(Text *text, float xPos, float yPos, char *string, ...);
void Text_SetScale(Text *text, int subtext, float x, float y);
void Text_SetColor(Text *text, int subtext, GXColor *color);
void Text_SetPosition(Text *text, int subtext, float x, float y);
void Text_SetText(Text *text, int subtext, char *string, ...);
int Text_ConvertToMenuText(char *buffer, char *string);
u8 *Text_Alloc(int size);
void Text_DestroyAlloc(u8 *alloc);
void Text_DestroyAllAlloc(Text *text);
int Text_StringToMenuText(u8 *out, char *in);
void Text_GX(GOBJ *gobj, int pass);
void Text_LoadSdFile(int index, char *filename, char *symbol);
void Text_SetSisText(Text *text, int text_index);

#endif
