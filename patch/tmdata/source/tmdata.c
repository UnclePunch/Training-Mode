#include "tmdata.h"

/////////////////////
// Mod Information //
/////////////////////

static char TM_VersShort[] = TM_VERSSHORT "\n";
static char TM_VersLong[] = TM_VERSLONG "\n";
static char TM_Compile[] = "COMPILED: " __DATE__ " " __TIME__;
static char nullString[] = " ";

////////////////////////
/// Static Variables ///
////////////////////////

static int show_console = 1;

//////////////////////
/// Hook Functions ///
//////////////////////

void TM_ConsoleThink(GOBJ *gobj)
{
    // init variables
    int *data = gobj->userdata;
    DevText *text = data[0];

    // check to toggle console
    for (int i = 0; i < 4; i++)
    {
        HSD_Pad *pad = PadGet(i, PADGET_MASTER);
        if (pad->held & (HSD_TRIGGER_L | HSD_TRIGGER_R) && (pad->down & HSD_TRIGGER_Z))
        {
            // toggle visibility
            text->show_text ^= 1;
            text->show_background ^= 1;
            show_console ^= 1;

            break;
        }
    }

    // clear text
    //DevelopText_EraseAllText(text);
    //DevelopMode_ResetCursorXY(text, 0, 0);
}
/*
void TM_CreateConsole()
{
    // init dev text
    GOBJ *gobj = GObj_Create(0, 0, 0);
    int *data = calloc(32);
    GObj_AddUserData(gobj, 4, HSD_Free, data);
    GObj_AddProc(gobj, TM_ConsoleThink, 0);

    DevText *text = DevelopText_CreateDataTable(13, 0, 0, 28, 8, HSD_MemAlloc(0x1000));
    DevelopText_Activate(0, text);
    text->show_cursor = 0;
    data[0] = text;
    GXColor color = {21, 20, 59, 135};
    DevelopText_StoreBGColor(text, &color);
    DevelopText_StoreTextScale(text, 10, 12);
    stc_evco_data.db_console_text = text;

    if (show_console != 1)
    {
        // toggle visibility
        DevelopText_HideBG(text);
        DevelopText_HideText(text);
    }

    return;
}
*/
void OnFileLoad(ArchiveInfo *archive) // this function is run right after TmDt is loaded into memory on boot
{

    return;
}
void OnSceneChange()
{
    // Hook exists at 801a4c94

    TM_CreateWatermark();

#if TM_DEBUG == 2
    TM_CreateConsole();
#endif

    return;
};
void OnBoot()
{
    // OSReport("hi this is boot\n");
    return;
};
void OnStartMelee()
{
    return;
}

void TM_CreateWatermark()
{

    // create text canvas
    int canvas = Text_CreateCanvas(10, 0, 9, 13, 0, 14, 0, 19);

    // create text
    Text *text = Text_CreateText(10, canvas);
    // enable align and kerning
    text->align = 2;
    text->kerning = 1;
    // scale text
    text->scale.X = 0.4;
    text->scale.Y = 0.4;
    // move text
    text->trans.X = 615;
    text->trans.Y = 446;

    // static shadow color
    static GXColor shadow_color = {0, 0, 0, 0};

    // instantiate text
    int shadow = Text_AddSubtext(text, 2, 2, TM_VersShort);
    Text_SetColor(text, shadow, &shadow_color);

    int shadow1 = Text_AddSubtext(text, 2, -2, TM_VersShort);
    Text_SetColor(text, shadow1, &shadow_color);

    int shadow2 = Text_AddSubtext(text, -2, 2, TM_VersShort);
    Text_SetColor(text, shadow2, &shadow_color);

    int shadow3 = Text_AddSubtext(text, -2, -2, TM_VersShort);
    Text_SetColor(text, shadow3, &shadow_color);

    Text_AddSubtext(text, 0, 0, TM_VersShort);

    return;
}

///////////////////////
///  Get Functions  ///
///////////////////////

char *GetTMVersShort()
{
    return (TM_VersShort);
}
char *GetTMVersLong()
{
    return (TM_VersLong);
}
char *GetTMCompile()
{
    return (TM_Compile);
}
