#ifndef MEX_H_MEX
#define MEX_H_MEX

#include "structs.h"
#include "datatypes.h"
#include "obj.h"

#define DB_FLAG 0

enum MEX_GETDATA
{
    MXDT_FTINTNUM,
    MXDT_FTEXTNUM,
    MXDT_FTICONNUM,
    MXDT_FTICONDATA,
    MXDT_GRINTNUM,
    MXDT_GREXTNUM,
    MXDT_GRICONNUM,
    MXDT_GRICONDATA,
};

/*** Structs ***/

struct PRIM
{
    void *data;
};

struct Translation
{
    float frame;
    float value;
};

struct MEXPlaylist
{
    u16 bgm;
    u16 chance;
};

/*** Functions ***/
ArchiveInfo *MEX_LoadRelArchive(char *file, void *functions, char *symbol);
void MEX_IndexFighterItem(int fighter_kind, void *itemdata, int item_id);
void SpawnMEXEffect(int effectID, int fighter, int arg1, int arg2, int arg3, int arg4, int arg5);
int MEX_GetItemExtID(GOBJ *gobj, int item_id); // gobj can be fighter or stage
int MEX_GetFtItemID(int ft_kind, int item_id); // gobj can be fighter or stage
int MEX_GetGrItemID(int item_id);              // gobj can be fighter or stage
void SFX_PlayStageSFX(int sfx_id);
void *calloc(int size);
PRIM *PRIM_NEW(int vert_count, int params1, int params2);
void PRIM_CLOSE();
MEXPlaylist *MEX_GetPlaylist();
int MEX_GetStageItemExtID(int item_id);
void KirbyStateChange(GOBJ *fighter, int state, float startFrame, float animSpeed, float animBlend);
void *MEX_GetKirbyCpData(int copy_id);
int MEX_GetCopyItemExtID(int copy_id, int item_id);
void *MEX_GetData(int index);
#endif
