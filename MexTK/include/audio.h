#ifndef MEX_H_AUDIO
#define MEX_H_AUDIO

#include "structs.h"
#include "datatypes.h"

char *Nametag_GetText(int tag_index);
void Audio_ResetCache(int group_index);
void Audio_QueueFileLoad(int group_index, u64 ssm_index);
void Audio_UpdateCache();
void Audio_SyncLoadAll();
int BGM_GetMenuBGM();
void BGM_Play(int hpsID);

#endif
