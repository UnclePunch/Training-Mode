#ifndef MEX_H_DATATYPES
#define MEX_H_DATATYPES

#include "structs.h"
#include "offsets.h"

// Data types
typedef signed char s8;
typedef signed short s16;
typedef signed int s32;
typedef signed long long s64;
typedef unsigned char u8;
typedef unsigned short u16;
typedef unsigned int u32;
typedef unsigned long long u64;
typedef float f32;
typedef double f64;

// PadGet Types
#define PADGET_MASTER 0
#define PADGET_ENGINE 1

// Matrix definition
typedef float Mtx[3][4];
typedef float (*MtxPtr)[4];

// Ghidrish
#define undefined8 long
#define undefined4 int
#define byte char
#define uint unsigned int

// bool lingo
#define true 1
#define false 0

// Other Macros
#define RTOC_PTR(offset) *(void **)(0x804df9e0 + offset)
#define R13_PTR(offset) *(void **)(R13 + offset)
#define R13_INT(offset) *(int *)(R13 + offset)
#define R13_U8(offset) *(u8 *)(R13 + offset)
#define R13_FLOAT(offset) *(float *)(R13 + offset)
#define AS_FLOAT(num) *(float *)&num
#define AS_INT(num) *(int *)&num
#define ACCESS_INT(addr) *(int *)(addr)
#define ACCESS_U8(addr) *(u8 *)(addr)
#define ACCESS_PTR(addr) *(void **)(addr)

/*** Structs ***/

struct Vec2
{
    float X;
    float Y;
};

struct Vec3
{
    float X;
    float Y;
    float Z;
};

struct Vec4
{
    float X;
    float Y;
    float Z;
    float W;
};

#endif
