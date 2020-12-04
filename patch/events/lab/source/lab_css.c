#include "lab.h"

// Static Variables
static Arch_ImportData *stc_import_assets;
static ImportData import_data;
static char *slots_names[] = {"A", "B"};
static _HSD_ImageDesc image_desc = {
    .format = 4,
    .height = RESIZE_HEIGHT,
    .width = RESIZE_WIDTH,
};

// OnLoad
void OnCSSLoad(ArchiveInfo *archive)
{
    EventVars *event_vars = *event_vars_ptr;

    // get assets from this file
    stc_import_assets = File_GetSymbol(archive, "importData");

    Button_Create();

    // Create a cobj for the menu
    COBJ *cam_cobj = COBJ_LoadDesc(stc_import_assets->import_cam);
    GOBJ *cam_gobj = GObj_Create(2, 3, 128);
    GObj_AddObject(cam_gobj, R13_U8(-0x3E55), cam_cobj);
    GOBJ_InitCamera(cam_gobj, CObjThink_Common, 1);
    GObj_AddProc(cam_gobj, MainMenu_CamRotateThink, 5);
    cam_gobj->cobj_links = 1 << MENUCAM_GXLINK;

    // Create text canvas
    import_data.canvas = Text_CreateCanvas(SIS_ID, 0, 2, 3, 128, MENUCAM_GXLINK, 129, 0);

    // allocate filename array
    import_data.file_info = calloc(CARD_MAX_FILE * sizeof(FileInfo)); // allocate 128 entries
    // allocate filename buffers
    for (int i = 0; i < CARD_MAX_FILE; i++)
    {
        import_data.file_info[i].file_name = calloc(CARD_FILENAME_MAX);
        import_data.file_info[i].file_name_user = calloc(CARD_FILENAME_MAX);
    }
    return;
}

// Button Functions
void Button_Create()
{
    // Create GOBJ
    GOBJ *button_gobj = GObj_Create(4, 5, 0);
    GObj_AddGXLink(button_gobj, GXLink_Common, 1, 128);
    GObj_AddProc(button_gobj, Button_Think, 8);
    JOBJ *button_jobj = JOBJ_LoadJoint(stc_import_assets->import_button);
    GObj_AddObject(button_gobj, R13_U8(-0x3E55), button_jobj);

    // scale message jobj
    Vec3 *scale = &button_jobj->scale;

    // Create text object
    Text *button_text = Text_CreateText(SIS_ID, 0);
    button_text->kerning = 1;
    button_text->align = 1;
    button_text->use_aspect = 1;
    button_text->scale.X = (scale->X * 0.01) * 3;
    button_text->scale.Y = (scale->Y * 0.01) * 3;
    button_text->trans.X = button_jobj->trans.X + (0 * (scale->X / 4.0));
    button_text->trans.Y = (button_jobj->trans.Y * -1) + (-1.6 * (scale->Y / 4.0));
    Text_AddSubtext(button_text, 0, 0, "Import");

    return;
}
void Button_Think(GOBJ *button_gobj)
{

#define BUTTON_WIDTH 5
#define BUTTON_HEIGHT 2.2

    // init
    CSSCursor *css_cursors = *stc_css_cursors;
    CSSCursor *this_cursor = &css_cursors[*stc_css_hmnport]; // get the main player's hand cursor data
    Vec2 cursor_pos = this_cursor->pos;
    cursor_pos.X += 5;
    cursor_pos.Y -= 1;
    HSD_Pad *pads = stc_css_pad;
    HSD_Pad *this_pad = &pads[*stc_css_hmnport];
    int down = this_pad->down;                   // get this cursors inputs
    JOBJ *button_jobj = button_gobj->hsd_object; // get jobj
    Vec3 *button_pos = &button_jobj->trans;

    // check if cursor is hovered over button
    if ((import_data.menu_gobj == 0) &&
        (cursor_pos.X < (button_pos->X + BUTTON_WIDTH)) &&
        (cursor_pos.X > (button_pos->X - BUTTON_WIDTH)) &&
        (cursor_pos.Y < (button_pos->Y + BUTTON_HEIGHT)) &&
        (cursor_pos.Y > (button_pos->Y - BUTTON_HEIGHT)) &&
        (down & HSD_BUTTON_A))
    {
        import_data.menu_gobj = Menu_Create();
        SFX_PlayCommon(1);
    }

    return;
}

// Import Menu Functions
GOBJ *Menu_Create()
{
    // Create GOBJ
    GOBJ *menu_gobj = GObj_Create(4, 5, 0);
    GObj_AddGXLink(menu_gobj, GXLink_Common, MENUCAM_GXLINK, 128);
    GObj_AddProc(menu_gobj, Menu_Think, 0);
    JOBJ *menu_jobj = JOBJ_LoadJoint(stc_import_assets->import_menu);
    GObj_AddObject(menu_gobj, R13_U8(-0x3E55), menu_jobj);

    // save jobj pointers
    JOBJ_GetChild(menu_jobj, &import_data.memcard_jobj[0], 2, -1);
    JOBJ_GetChild(menu_jobj, &import_data.memcard_jobj[1], 4, -1);
    JOBJ_GetChild(menu_jobj, &import_data.screenshot_jobj, 6, -1);
    JOBJ_GetChild(menu_jobj, &import_data.scroll_jobj, 7, -1);

    // hide all
    JOBJ_SetFlagsAll(import_data.memcard_jobj[0], JOBJ_HIDDEN);
    JOBJ_SetFlagsAll(import_data.memcard_jobj[1], JOBJ_HIDDEN);
    JOBJ_SetFlagsAll(import_data.screenshot_jobj, JOBJ_HIDDEN);
    JOBJ_SetFlagsAll(import_data.scroll_jobj, JOBJ_HIDDEN);

    // create title and desc text
    Text *title_text = Text_CreateText(SIS_ID, import_data.canvas);
    title_text->kerning = 1;
    title_text->use_aspect = 1;
    title_text->aspect.X = 305;
    title_text->trans.X = -28;
    title_text->trans.Y = -22;
    title_text->trans.Z = menu_jobj->trans.Z;
    title_text->scale.X = (menu_jobj->scale.X * 0.01) * 14;
    title_text->scale.Y = (menu_jobj->scale.Y * 0.01) * 14;
    Text_AddSubtext(title_text, 0, 0, "-");
    import_data.title_text = title_text;
    Text *desc_text = Text_CreateText(SIS_ID, import_data.canvas);
    desc_text->kerning = 1;
    desc_text->use_aspect = 1;
    desc_text->aspect.X = 930;
    desc_text->trans.X = -28;
    desc_text->trans.Y = 14.5;
    desc_text->trans.Z = menu_jobj->trans.Z;
    desc_text->scale.X = (menu_jobj->scale.X * 0.01) * 5;
    desc_text->scale.Y = (menu_jobj->scale.Y * 0.01) * 5;
    Text_AddSubtext(desc_text, 0, 0, "-");
    import_data.desc_text = desc_text;

    // init card select menu
    Menu_SelCard_Init(menu_gobj);

    return menu_gobj;
}
void Menu_Destroy(GOBJ *menu_gobj)
{
    // run specific menu state code
    switch (import_data.menu_state)
    {
    case (SELCARD):
    {
        Menu_SelCard_Exit(menu_gobj);
        break;
    }
    case (SELFILE):
    {
        Menu_SelFile_Exit(menu_gobj);
        break;
    }
    }

    // destroy text
    Text_Destroy(import_data.title_text);
    import_data.title_text = 0;
    Text_Destroy(import_data.desc_text);
    import_data.desc_text = 0;

    // destroy gobj
    GObj_Destroy(menu_gobj);
    import_data.menu_gobj = 0;

    // enable CSS inputs
    *stc_css_exitkind = 0;

    return;
}
void Menu_Think(GOBJ *menu_gobj)
{

    // disable inputs for CSS
    *stc_css_exitkind = 5;

    switch (import_data.menu_state)
    {
    case (SELCARD):
    {
        Menu_SelCard_Think(menu_gobj);
        break;
    }
    case (SELFILE):
    {
        Menu_SelFile_Think(menu_gobj);
        break;
    }
    }

    return;
}
// Select Card
void Menu_SelCard_Init(GOBJ *menu_gobj)
{

    // get jobj
    JOBJ *menu_jobj = menu_gobj->hsd_object;

    // init state and cursor
    import_data.menu_state = SELCARD;
    import_data.cursor = 0;

    // init memcard inserted state
    import_data.memcard_inserted[0] == 0;
    import_data.memcard_inserted[1] == 0;

    // show memcards
    JOBJ_ClearFlagsAll(import_data.memcard_jobj[0], JOBJ_HIDDEN);
    JOBJ_ClearFlagsAll(import_data.memcard_jobj[1], JOBJ_HIDDEN);

    // create memcard text
    Text *memcard_text = Text_CreateText(SIS_ID, import_data.canvas);
    memcard_text->kerning = 1;
    memcard_text->align = 1;
    memcard_text->trans.Z = menu_jobj->trans.Z;
    memcard_text->scale.X = (menu_jobj->scale.X * 0.01) * 6;
    memcard_text->scale.Y = (menu_jobj->scale.Y * 0.01) * 6;
    import_data.option_text = memcard_text;
    Text_AddSubtext(memcard_text, -130, 110, "Slot A");
    Text_AddSubtext(memcard_text, 130, 110, "Slot B");

    // edit title
    Text_SetText(import_data.title_text, 0, "Select Memory Card");

    // edit description
    Text_SetText(import_data.desc_text, 0, "");

    return;
}
void Menu_SelCard_Think(GOBJ *menu_gobj)
{

    // init
    int down = Pad_GetRapidHeld(*stc_css_hmnport);

    // update memcard info
    for (int i = 0; i < 2; i++)
    {
        // probe slot
        u8 is_inserted;

        s32 memSize, sectorSize;
        if (CARDProbeEx(i, &memSize, &sectorSize) == CARD_RESULT_READY)
        {
            // if it was just inserted, get info
            if (import_data.memcard_inserted[i] == 0)
            {

                // mount card
                stc_memcard_work->is_done = 0;
                if (CARDMountAsync(i, stc_memcard_work->work_area, 0, Memcard_RemovedCallback) == CARD_RESULT_READY)
                {
                    // check card
                    Memcard_Wait();
                    stc_memcard_work->is_done = 0;
                    if (CARDCheckAsync(i, Memcard_RemovedCallback) == CARD_RESULT_READY)
                    {
                        Memcard_Wait();

                        // if we get this far, a valid memcard is inserted
                        is_inserted = 1;
                        SFX_PlayCommon(2);

                        // get free blocks
                        s32 byteNotUsed, filesNotUsed;
                        if (CARDFreeBlocks(i, &byteNotUsed, &filesNotUsed) == CARD_RESULT_READY)
                        {
                            import_data.memcard_free_blocks[i] = (byteNotUsed / 8192);
                            import_data.memcard_free_files[i] = filesNotUsed;
                        }
                    }
                    else
                        is_inserted = 0;

                    CARDUnmount(i);
                    stc_memcard_work->is_done = 0;
                }
                else
                    is_inserted = 0;
            }
            else
                is_inserted = 1;
        }
        else
            is_inserted = 0;

        import_data.memcard_inserted[i] = is_inserted;
    }

    // cursor movement
    if (down & HSD_BUTTON_LEFT) // check for cursor left
    {
        if (import_data.cursor > 0)
        {
            import_data.cursor--;
            SFX_PlayCommon(2);
        }
    }
    else if (down & HSD_BUTTON_RIGHT) // check for cursor right
    {
        if (import_data.cursor < 1)
        {
            import_data.cursor++;
            SFX_PlayCommon(2);
        }
    }

    // highlight cursor
    static GXColor text_white = {255, 255, 255, 255};
    static GXColor text_gold = {255, 211, 0, 255};
    for (int i = 0; i < 2; i++)
    {
        Text_SetColor(import_data.option_text, i, &text_white);
    }
    Text_SetColor(import_data.option_text, import_data.cursor, &text_gold);

    Text *desc_text = import_data.desc_text;
    int cursor = import_data.cursor;
    if (import_data.memcard_inserted[cursor] == 0)
        Text_SetText(desc_text, 0, "No device is inserted in Slot %s.", slots_names[cursor]);
    else
        Text_SetText(desc_text, 0, "Load recording from the memory card in Slot %s.", slots_names[cursor]);

    // check for exit
    if (down & HSD_BUTTON_B)
    {
        Menu_Destroy(menu_gobj);
        SFX_PlayCommon(0);
    }

    // check for A
    else if (down & HSD_BUTTON_A)
    {
        // check if valid memcard inserted
        if (import_data.memcard_inserted[cursor] == 0)
            SFX_PlayCommon(3);

        // is inserted
        else
        {
            import_data.memcard_slot = cursor;
            SFX_PlayCommon(1);
            Menu_SelCard_Exit(menu_gobj);
            Menu_SelFile_Init(menu_gobj);
        }
    }

    return;
}
void Menu_SelCard_Exit(GOBJ *menu_gobj)
{
    JOBJ_SetFlagsAll(import_data.memcard_jobj[0], JOBJ_HIDDEN);
    JOBJ_SetFlagsAll(import_data.memcard_jobj[1], JOBJ_HIDDEN);

    // destroy memcard text
    Text_Destroy(import_data.option_text);
    import_data.option_text = 0;

    return;
}
// Select File
void Menu_SelFile_Init(GOBJ *menu_gobj)
{

    // get jobj
    JOBJ *menu_jobj = menu_gobj->hsd_object;

    // init state and cursor
    import_data.menu_state = SELFILE;
    import_data.cursor = 0;

    // show memcards
    JOBJ_ClearFlagsAll(import_data.scroll_jobj, JOBJ_HIDDEN);
    JOBJ_ClearFlagsAll(import_data.screenshot_jobj, JOBJ_HIDDEN);

    // create file name text
    Text *filename_text = Text_CreateText(SIS_ID, import_data.canvas);
    filename_text->kerning = 1;
    filename_text->align = 0;
    filename_text->use_aspect = 1;
    filename_text->aspect.X = 440;
    filename_text->trans.X = -27.8;
    filename_text->trans.Y = -13.6;
    filename_text->trans.Z = menu_jobj->trans.Z;
    filename_text->scale.X = (menu_jobj->scale.X * 0.01) * 6;
    filename_text->scale.Y = (menu_jobj->scale.Y * 0.01) * 6;
    import_data.filename_text = filename_text;
    for (int i = 0; i < IMPORT_FILESPERPAGE; i++)
    {
        Text_AddSubtext(filename_text, 0, i * 38, "This is the max amount of text");
    }

#define FILEINFO_X 235
#define FILEINFO_Y -20
#define FILEINFO_YOFFSET 35
#define FILEINFO_STAGEY FILEINFO_Y
#define FILEINFO_HMNY FILEINFO_STAGEY + FILEINFO_YOFFSET
#define FILEINFO_CPUY FILEINFO_HMNY + FILEINFO_YOFFSET
#define FILEINFO_STATUSY FILEINFO_CPUY + FILEINFO_YOFFSET

    // create file info text
    Text *fileinfo_text = Text_CreateText(SIS_ID, import_data.canvas);
    fileinfo_text->kerning = 1;
    fileinfo_text->align = 0;
    fileinfo_text->use_aspect = 1;
    fileinfo_text->aspect.X = 300;
    fileinfo_text->trans.Z = menu_jobj->trans.Z;
    fileinfo_text->scale.X = (menu_jobj->scale.X * 0.01) * 4.5;
    fileinfo_text->scale.Y = (menu_jobj->scale.Y * 0.01) * 4.5;
    import_data.fileinfo_text = fileinfo_text;
    Text_AddSubtext(fileinfo_text, FILEINFO_X, FILEINFO_STAGEY, "Stage: Final Destinaton");
    Text_AddSubtext(fileinfo_text, FILEINFO_X, FILEINFO_HMNY, "HMN: Fox");
    Text_AddSubtext(fileinfo_text, FILEINFO_X, FILEINFO_CPUY, "CPU: C. Falcon");
    Text_AddSubtext(fileinfo_text, FILEINFO_X, FILEINFO_STATUSY, "Status: Compatible");

    // edit title
    Text_SetText(import_data.title_text, 0, "Select Recording");

    // edit description
    Text_SetText(import_data.desc_text, 0, "Choose a recording to load.");

    // search card for save files
    import_data.file_num = 0;
    int slot = import_data.memcard_slot;
    char *filename[32];
    int file_size;
    s32 memSize, sectorSize;
    if (CARDProbeEx(slot, &memSize, &sectorSize) == CARD_RESULT_READY)
    {
        // mount card
        stc_memcard_work->is_done = 0;
        if (CARDMountAsync(slot, stc_memcard_work->work_area, 0, Memcard_RemovedCallback) == CARD_RESULT_READY)
        {
            // check card
            Memcard_Wait();
            stc_memcard_work->is_done = 0;
            if (CARDCheckAsync(slot, Memcard_RemovedCallback) == CARD_RESULT_READY)
            {
                Memcard_Wait();
                // get free blocks
                s32 byteNotUsed, filesNotUsed;
                if (CARDFreeBlocks(slot, &byteNotUsed, &filesNotUsed) == CARD_RESULT_READY)
                {

                    // search for files with name TMREC
                    for (int i = 0; i < CARD_MAX_FILE; i++)
                    {

                        CARDStat card_stat;

                        if (CARDGetStatus(slot, i, &card_stat) == CARD_RESULT_READY)
                        {
                            // check company code
                            if (strncmp(os_info->company, card_stat.company, sizeof(os_info->company)) == 0)
                            {
                                // check game name
                                if (strncmp(os_info->gameName, card_stat.gameName, sizeof(os_info->gameName)) == 0)
                                {
                                    // check file name
                                    if (strncmp("TMREC", card_stat.fileName, 5) == 0)
                                    {
                                        OSReport("found recording file %s with size %d\n", card_stat.fileName, card_stat.length);
                                        import_data.file_info[import_data.file_num].file_size = card_stat.length;                                      // save file size
                                        memcpy(import_data.file_info[import_data.file_num].file_name, card_stat.fileName, sizeof(card_stat.fileName)); // save file name
                                        import_data.file_num++;                                                                                        // increment file amount
                                    }
                                }
                            }
                        }
                    }
                }
            }

            CARDUnmount(0);
            stc_memcard_work->is_done = 0;
        }
    }

    // init scroll bar according to import_data.file_num

    // load in next X recordsings
    Menu_SelFile_LoadPage(menu_gobj);

    return;
}
void Menu_SelFile_Think(GOBJ *menu_gobj)
{

    OSReport("heap: %d bytes\n", OSCheckHeap(3));

    // init
    int down = Pad_GetRapidHeld(*stc_css_hmnport);

    // first ensure memcard is still inserted
    s32 memSize, sectorSize;
    if (CARDProbeEx(import_data.memcard_slot, &memSize, &sectorSize) != CARD_RESULT_READY)
        goto EXIT;

    // cursor movement
    if (down & HSD_BUTTON_UP) // check for cursor left
    {
        if (import_data.cursor > 0)
        {
            import_data.cursor--;
            SFX_PlayCommon(2);
        }
    }
    else if (down & HSD_BUTTON_DOWN) // check for cursor right
    {
        if (import_data.cursor < IMPORT_FILESPERPAGE - 1)
        {
            import_data.cursor++;
            SFX_PlayCommon(2);
        }
    }

    // highlight cursor
    int cursor = import_data.cursor;
    static GXColor text_white = {255, 255, 255, 255};
    static GXColor text_gold = {255, 211, 0, 255};
    for (int i = 0; i < IMPORT_FILESPERPAGE; i++)
    {
        Text_SetColor(import_data.filename_text, i, &text_white);
    }
    Text_SetColor(import_data.filename_text, cursor, &text_gold);

    // update file info text
    u8 *transfer_buf = import_data.file_data[cursor];
    ExportHeader *header = transfer_buf;
    u8 *compressed_recording = transfer_buf + header->lookup.ofst_recording;
    Text_SetText(import_data.fileinfo_text, 0, "Stage: %d", header->metadata.stage);
    Text_SetText(import_data.fileinfo_text, 1, "HMN: %s", Fighter_GetName(header->metadata.hmn));
    Text_SetText(import_data.fileinfo_text, 2, "CPU: %s", Fighter_GetName(header->metadata.cpu));

    // update file image
    RGB565 *img = transfer_buf + header->lookup.ofst_screenshot;
    image_desc.img_ptr = img;                                               // store pointer to resized image
    import_data.screenshot_jobj->dobj->mobj->tobj->imagedesc = &image_desc; // replace pointer to imagedesc

    // check for exit
    if (down & HSD_BUTTON_B)
    {
    EXIT:
        Menu_SelFile_Exit(menu_gobj);
        Menu_SelCard_Init(menu_gobj);
        SFX_PlayCommon(0);
    }

    // check for select
    else if (down & HSD_BUTTON_A)
    {
        SFX_PlayCommon(1);
    }

    return;
}
void Menu_SelFile_Exit(GOBJ *menu_gobj)
{
    JOBJ_SetFlagsAll(import_data.scroll_jobj, JOBJ_HIDDEN);
    JOBJ_SetFlagsAll(import_data.screenshot_jobj, JOBJ_HIDDEN);

    // destroy option text
    Text_Destroy(import_data.filename_text);
    import_data.filename_text = 0;
    Text_Destroy(import_data.fileinfo_text);
    import_data.fileinfo_text = 0;

    // free prev buffers
    for (int i = 0; i < IMPORT_FILESPERPAGE; i++)
    {
        // if exists
        if (import_data.file_data[i] != 0)
        {
            HSD_Free(import_data.file_data[i]);
            import_data.file_data[i] = 0;
        }
    }

    return;
}
void Menu_SelFile_LoadPage(GOBJ *menu_gobj)
{

    int cursor = import_data.cursor; // start at cursor

    // free prev buffers
    for (int i = 0; i < IMPORT_FILESPERPAGE; i++)
    {
        // if exists
        if (import_data.file_data[i] != 0)
        {
            HSD_Free(import_data.file_data[i]);
            import_data.file_data[i] = 0;
        }
    }

    // begin loading next batch
    for (int i = 0; i < IMPORT_FILESPERPAGE; i++)
    {

        // if exists
        if ((cursor + i) < import_data.file_num)
        {

            // get file info
            char *file_name = import_data.file_info[cursor + i].file_name;
            int file_size = import_data.file_info[cursor + i].file_size;

            // setup load
            MemcardSave memcard_save;
            void *buffer = HSD_MemAlloc(file_size); // alloc buffer for this save
            import_data.file_data[i] = buffer;      // save buffer pointer
            memcard_save.data = buffer;             // store pointer to buffer for memcard load operation
            memcard_save.x4 = 3;
            memcard_save.size = file_size;
            memcard_save.xc = -1;
            Memcard_LoadSnapshot(import_data.memcard_slot, file_name, &memcard_save, &stc_memcard_info->file_name, 0, 0, 0);

            // wait to load
            int memcard_status = Memcard_CheckStatus();
            while (memcard_status == 11)
            {
                memcard_status = Memcard_CheckStatus();
            }

            // if file loaded successfully
            if (memcard_status == 0)
                Text_SetText(import_data.filename_text, i, &stc_memcard_info->file_name[32]);
        }
        else
            Text_SetText(import_data.filename_text, i, "");
    }

    return;
}

// Misc functions
void Memcard_Wait()
{

    while (stc_memcard_work->is_done == 0)
    {
        blr2();
    }

    return;
}