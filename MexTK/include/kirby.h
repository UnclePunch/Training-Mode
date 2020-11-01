#ifndef MEX_H_KIRBY
#define MEX_H_KIRBY

#include "structs.h"
#include "datatypes.h"
#include "obj.h"
#include "color.h"
#include "effects.h"
#include "match.h"
#include "collision.h"

struct FtVarKirby
{
    int charVar1;          // 0x222c
    int charVar2;          // 0x2230
    int charVar3;          // 0x2234
    int copy_index;        // 0x2238
    JOBJ *copy_jobj;       // 0x223c
    FtParts ftparts_model; // 0x2240
    FtDOBJUnk ftdobj_unk;  // 0x2250
};

#endif
