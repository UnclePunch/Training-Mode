#ifndef MEX_H_ARCHIVE
#define MEX_H_ARCHIVE

#include "structs.h"
#include "datatypes.h"

struct ArchiveInfo
{
    int file_size;       // size of file
    int *reloc_offset;   // pointer to relocation table offset?
    int reloc_num;       // number of entries on the rleoc table
    int symbol_num;      // total number of symbols
    int refsymbol_num;   // number of reference symbols
    int archive_vers;    // idk for sure sometimes 001B
    int unk1;            //
    int unk2;            //
    int *general_points; //0x20 = pointer to the "general points"
    int *reloc_table;    //pointer to relocation table in memory
    int *symbols1;       //pointer to symbol pointers and name offsets
    int *refsymmbols;    //pointer to reference symbol info in memory
    int *symbols2;       //pointer to symbol list in memory
    int *file_start;     //pointer to the header of the dat
};

ArchiveInfo *File_Load(char *filename);
void File_LoadInitReturnSymbol(char *filename, void *ptr, ...); // input each symbol name pointer sequentially and terminate with 0;
void *File_GetSymbol(void *archive, char *symbol);

#endif
