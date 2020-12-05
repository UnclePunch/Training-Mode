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
    import_data.confirm.canvas = Text_CreateCanvas(SIS_ID, 0, 2, 3, 128, MENUCAM_GXLINK, 131, 0);

    // allocate filename array
    import_data.file_info = calloc(CARD_MAX_FILE * sizeof(FileInfo)); // allocate 128 entries
    // allocate filename buffers
    for (int i = 0; i < CARD_MAX_FILE; i++)
    {
        import_data.file_info[i].file_name = calloc(CARD_FILENAME_MAX);
    }

    // alloc image (needs to be 32 byte aligned)
    import_data.image = calloc(GXGetTexBufferSize(RESIZE_WIDTH, RESIZE_HEIGHT, 4, 0, 0)); // allocate 128 entries

    // HUGE HACK ALERT
    EventDesc *(*GetEventDesc)(int page, int event) = RTOC_PTR(TM_DATA + (24 * 4));
    EventDesc *event_desc = GetEventDesc(1, 0);
    event_desc->isSelectStage = 1;
    event_desc->matchData->stage = -1;
    *onload_fileno = -1;

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
    GObj_AddProc(menu_gobj, Menu_Think, 1);
    JOBJ *menu_jobj = JOBJ_LoadJoint(stc_import_assets->import_menu);
    GObj_AddObject(menu_gobj, R13_U8(-0x3E55), menu_jobj);

    // save jobj pointers
    JOBJ_GetChild(menu_jobj, &import_data.memcard_jobj[0], 2, -1);
    JOBJ_GetChild(menu_jobj, &import_data.memcard_jobj[1], 4, -1);
    JOBJ_GetChild(menu_jobj, &import_data.screenshot_jobj, 6, -1);
    JOBJ_GetChild(menu_jobj, &import_data.scroll_jobj, 7, -1);
    JOBJ_GetChild(menu_jobj, &import_data.scroll_top, 9, -1);
    JOBJ_GetChild(menu_jobj, &import_data.scroll_bot, 10, -1);

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
    title_text->trans.Y = -21;
    title_text->trans.Z = menu_jobj->trans.Z;
    title_text->scale.X = (menu_jobj->scale.X * 0.01) * 11;
    title_text->scale.Y = (menu_jobj->scale.Y * 0.01) * 11;
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

    // disable inputs for CSS
    *stc_css_exitkind = 5;

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
    if (down & (HSD_BUTTON_LEFT | HSD_BUTTON_DPAD_LEFT)) // check for cursor left
    {
        if (import_data.cursor > 0)
        {
            import_data.cursor--;
            SFX_PlayCommon(2);
        }
    }
    else if (down & (HSD_BUTTON_RIGHT | HSD_BUTTON_DPAD_RIGHT)) // check for cursor right
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
    import_data.page = 0;

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
    filename_text->scale.X = (menu_jobj->scale.X * 0.01) * 5;
    filename_text->scale.Y = (menu_jobj->scale.Y * 0.01) * 5;
    import_data.filename_text = filename_text;
    for (int i = 0; i < IMPORT_FILESPERPAGE; i++)
    {
        Text_AddSubtext(filename_text, 0, i * 40, "-");
    }

#define FILEINFO_X 235
#define FILEINFO_Y -20
#define FILEINFO_YOFFSET 35
#define FILEINFO_STAGEY FILEINFO_Y
#define FILEINFO_HMNY FILEINFO_STAGEY + FILEINFO_YOFFSET
#define FILEINFO_CPUY FILEINFO_HMNY + FILEINFO_YOFFSET
#define FILEINFO_DATEY FILEINFO_CPUY + (FILEINFO_YOFFSET * 2)
#define FILEINFO_TIMEY FILEINFO_DATEY + FILEINFO_YOFFSET

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
    Text_AddSubtext(fileinfo_text, FILEINFO_X, FILEINFO_STAGEY, "-");
    Text_AddSubtext(fileinfo_text, FILEINFO_X, FILEINFO_HMNY, "-");
    Text_AddSubtext(fileinfo_text, FILEINFO_X, FILEINFO_CPUY, "-");
    Text_AddSubtext(fileinfo_text, FILEINFO_X, FILEINFO_DATEY, "-");
    Text_AddSubtext(fileinfo_text, FILEINFO_X, FILEINFO_TIMEY, "-");

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
                                        import_data.file_info[import_data.file_num].file_no = i;                                                       // save file no
                                        memcpy(import_data.file_info[import_data.file_num].file_name, card_stat.fileName, sizeof(card_stat.fileName)); // save file name
                                        import_data.file_num++;                                                                                        // increment file amount
                                    }
                                }
                            }
                        }
                    }
                }
            }

            CARDUnmount(slot);
            stc_memcard_work->is_done = 0;
        }
    }

    // init scroll bar according to import_data.file_num
    // get scroll bar size (-16.2 / page_num)
    int page_total = import_data.file_num / IMPORT_FILESPERPAGE;
    import_data.scroll_bot->trans.Y = (-16.2 / (page_total + 1));

    // load in first page recordsings
    Menu_SelFile_LoadPage(menu_gobj, 0);

    return;
}
void Menu_SelFile_Think(GOBJ *menu_gobj)
{

    // do not run if confirm popup is shown
    if (import_data.confirm.gobj == 0)
    {
        // init
        int down = Pad_GetRapidHeld(*stc_css_hmnport);

        // first ensure memcard is still inserted
        s32 memSize, sectorSize;
        if (CARDProbeEx(import_data.memcard_slot, &memSize, &sectorSize) != CARD_RESULT_READY)
            goto EXIT;

        // cursor movement
        if (down & (HSD_BUTTON_UP | HSD_BUTTON_DPAD_UP)) // check for cursor up
        {
            // if cursor is at the top of the page, try to advance to prev
            if (import_data.cursor == 0)
            {
                // try to load prev page
                if (Menu_SelFile_LoadPage(menu_gobj, import_data.page - 1))
                {
                    SFX_PlayCommon(2);
                    import_data.cursor = (IMPORT_FILESPERPAGE - 1);
                    import_data.page--;
                };
            }
            // if cursor can be advanced
            else if (import_data.cursor > 0)
            {
                import_data.cursor--;
                SFX_PlayCommon(2);
            }
        }
        else if (down & (HSD_BUTTON_DOWN | HSD_BUTTON_DPAD_DOWN)) // check for cursor down
        {

            // if cursor is at the end of the page, try to advance to next
            if (import_data.cursor == (IMPORT_FILESPERPAGE - 1))
            {
                // try to load next page
                if (Menu_SelFile_LoadPage(menu_gobj, import_data.page + 1))
                {
                    SFX_PlayCommon(2);
                    import_data.cursor = 0;
                    import_data.page++;
                };
            }

            // if cursor can be advanced
            else if ((import_data.cursor < import_data.files_on_page - 1))
            {
                import_data.cursor++;
                SFX_PlayCommon(2);
            }
        }
        else if (down & (HSD_BUTTON_RIGHT | HSD_BUTTON_DPAD_RIGHT)) // check for cursor right
        {
            // try to load next page
            if (Menu_SelFile_LoadPage(menu_gobj, import_data.page + 1))
            {
                SFX_PlayCommon(2);
                import_data.cursor = 0;
                import_data.page++;
            };
        }
        else if (down & (HSD_BUTTON_LEFT | HSD_BUTTON_DPAD_LEFT)) // check for cursor down
        {
            // try to load prev page
            if (Menu_SelFile_LoadPage(menu_gobj, import_data.page - 1))
            {
                SFX_PlayCommon(2);
                import_data.cursor = 0;
                import_data.page--;
            };
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
        /*
    u8 *transfer_buf = import_data.file_data[cursor];
    ExportHeader *header = transfer_buf;
    u8 *compressed_recording = transfer_buf + header->lookup.ofst_recording;
    Text_SetText(import_data.fileinfo_text, 0, "Stage: %s", stage_names[header->metadata.stage_internal]);
    Text_SetText(import_data.fileinfo_text, 1, "HMN: %s", Fighter_GetName(header->metadata.hmn));
    Text_SetText(import_data.fileinfo_text, 2, "CPU: %s", Fighter_GetName(header->metadata.cpu));
    Text_SetText(import_data.fileinfo_text, 3, "Created: %d/%d/%d", 10, 30, 1995);
    */

        // update file info text from header data
        int this_file_index = (import_data.page * IMPORT_FILESPERPAGE) + cursor;
        ExportHeader *header = &import_data.file_info[this_file_index].rec_header;

        // update file info text
        Text_SetText(import_data.fileinfo_text, 0, "Stage: %s", stage_names[header->metadata.stage_internal]);
        Text_SetText(import_data.fileinfo_text, 1, "HMN: %s", Fighter_GetName(header->metadata.hmn));
        Text_SetText(import_data.fileinfo_text, 2, "CPU: %s", Fighter_GetName(header->metadata.cpu));
        Text_SetText(import_data.fileinfo_text, 3, "Date: %d/%d/%d", header->metadata.month, header->metadata.day, header->metadata.year);
        Text_SetText(import_data.fileinfo_text, 4, "Time: %d:%02d:%02d", header->metadata.hour, header->metadata.minute, header->metadata.second);

        // update file image
        /*
    RGB565 *img = transfer_buf + header->lookup.ofst_screenshot;
    int img_size = GXGetTexBufferSize(header->metadata.image_width, header->metadata.image_height, 4, 0, 0);
    memcpy(import_data.image, img, img_size);                               // copu image to 32 byte aligned buffer
    image_desc.img_ptr = import_data.image;                                 // store pointer to resized image
    import_data.screenshot_jobj->dobj->mobj->tobj->imagedesc = &image_desc; // replace pointer to imagedesc
    */

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
            if (import_data.file_info[this_file_index].rec_header.metadata.version == REC_VERS)
            {
                Menu_Confirm_Init(menu_gobj);
                SFX_PlayCommon(1);
            }
            else
                SFX_PlayCommon(2);
        }
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
int Menu_SelFile_LoadPage(GOBJ *menu_gobj, int page)
{

    int result = 0;
    int files_on_page;
    int cursor = import_data.cursor; // start at cursor
    int page_total = import_data.file_num / IMPORT_FILESPERPAGE;

    // ensure page exists
    if ((page >= 0) && (page <= page_total))
    {
        // determine files on page
        if (((page + 1) * IMPORT_FILESPERPAGE) < import_data.file_num)
            files_on_page = IMPORT_FILESPERPAGE; // page is filled with files
        else
            files_on_page = import_data.file_num - (page * IMPORT_FILESPERPAGE); // remaining files

        // ensure page has at least one recording
        if (files_on_page > 0)
        {

            void *buffer = calloc(CARD_READ_SIZE);
            import_data.files_on_page = files_on_page; // update amount of files on page
            result = 1;                                // set page as toggled
            int slot = import_data.memcard_slot;

            // update scroll bar position
            import_data.scroll_top->trans.Y = ((float)page / (float)(page_total)) * (import_data.scroll_bot->trans.Y);
            JOBJ_SetMtxDirtySub(menu_gobj->hsd_object);

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

            // blank out all text
            for (int i = 0; i < IMPORT_FILESPERPAGE; i++)
            {
                Text_SetText(import_data.filename_text, i, "");
            }

            // mount card
            s32 memSize, sectorSize;
            if (CARDProbeEx(slot, &memSize, &sectorSize) == CARD_RESULT_READY)
            {
                // mount card
                stc_memcard_work->is_done = 0;
                if (CARDMountAsync(slot, stc_memcard_work->work_area, 0, Memcard_RemovedCallback) == CARD_RESULT_READY)
                {
                    Memcard_Wait();

                    // check card
                    stc_memcard_work->is_done = 0;
                    if (CARDCheckAsync(slot, Memcard_RemovedCallback) == CARD_RESULT_READY)
                    {
                        Memcard_Wait();

                        // begin loading this page's files
                        for (int i = 0; i < files_on_page; i++)
                        {

                            // get file info
                            int this_file_index = (page * IMPORT_FILESPERPAGE) + i;
                            char *file_name = import_data.file_info[this_file_index].file_name;
                            int file_size = import_data.file_info[this_file_index].file_size;
                            int file_no = import_data.file_info[this_file_index].file_no;

                            // get comment from card
                            CARDFileInfo card_file_info;
                            CARDStat card_stat;

                            // get status
                            if (CARDGetStatus(slot, file_no, &card_stat) == CARD_RESULT_READY)
                            {
                                // open card (get file info)
                                if (CARDOpen(slot, file_name, &card_file_info) == CARD_RESULT_READY)
                                {
                                    // try to get header
                                    if (CARDRead(&card_file_info, buffer, CARD_READ_SIZE, 0x1E00) == CARD_RESULT_READY)
                                    {
                                        // deobfuscate stupid melee bullshit
                                        Memcard_Deobfuscate(buffer, CARD_READ_SIZE);
                                        ExportHeader *header = buffer + 0x90; // get to header (need to find a less hardcoded way of doing this)

                                        // save header
                                        memcpy(&import_data.file_info[this_file_index].rec_header, header, sizeof(ExportHeader));

                                        // print user file name
                                        Text_SetText(import_data.filename_text, i, header->metadata.filename);
                                    }

                                    CARDClose(&card_file_info);
                                }
                            }

                            /*
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
                */
                        }
                    }
                    // unmount
                    CARDUnmount(slot);
                    stc_memcard_work->is_done = 0;
                }
            }

            // free temp read buffer
            HSD_Free(buffer);
        }
    }

    return result;
}
// Confirm Dialog
void Menu_Confirm_Init(GOBJ *menu_gobj)
{

    // Create GOBJ
    GOBJ *confirm_gobj = GObj_Create(4, 5, 0);
    GObj_AddGXLink(confirm_gobj, GXLink_Common, MENUCAM_GXLINK, 130);
    GObj_AddProc(confirm_gobj, Menu_Confirm_Think, 0);
    JOBJ *confirm_jobj = JOBJ_LoadJoint(stc_import_assets->import_popup);
    GObj_AddObject(confirm_gobj, R13_U8(-0x3E55), confirm_jobj);
    import_data.confirm.gobj = confirm_gobj;

    // create text
    Text *text = Text_CreateText(SIS_ID, import_data.confirm.canvas);
    text->kerning = 1;
    text->align = 1;
    text->trans.Z = confirm_jobj->trans.Z;
    text->scale.X = (confirm_jobj->scale.X * 0.01) * 6;
    text->scale.Y = (confirm_jobj->scale.Y * 0.01) * 6;
    import_data.confirm.text = text;
    Text_AddSubtext(text, -0, -40, "Load this recording?");
    Text_AddSubtext(text, -65, 40, "Yes");
    Text_AddSubtext(text, 65, 40, "No");

    // init cursor
    import_data.confirm.cursor = 0;

    return;
}
void Menu_Confirm_Think(GOBJ *menu_gobj)
{

    // init
    int down = Pad_GetRapidHeld(*stc_css_hmnport);

    // first ensure memcard is still inserted
    s32 memSize, sectorSize;
    if (CARDProbeEx(import_data.memcard_slot, &memSize, &sectorSize) != CARD_RESULT_READY)
        goto EXIT;

    // cursor movement
    if (down & (HSD_BUTTON_RIGHT | HSD_BUTTON_DPAD_RIGHT)) // check for cursor right
    {
        if (import_data.confirm.cursor < 1)
        {
            import_data.confirm.cursor++;
            SFX_PlayCommon(2);
        }
    }
    else if (down & (HSD_BUTTON_LEFT | HSD_BUTTON_DPAD_LEFT)) // check for cursor down
    {
        if (import_data.confirm.cursor > 0)
        {
            import_data.confirm.cursor--;
            SFX_PlayCommon(2);
        }
    }

    // highlight cursor
    int cursor = import_data.confirm.cursor;
    static GXColor text_white = {255, 255, 255, 255};
    static GXColor text_gold = {255, 211, 0, 255};
    for (int i = 0; i < 2; i++)
    {
        Text_SetColor(import_data.confirm.text, i + 1, &text_white);
    }
    Text_SetColor(import_data.confirm.text, cursor + 1, &text_gold);

    // check for exit
    if (down & HSD_BUTTON_B)
    {
    EXIT:
        Menu_Confirm_Exit(menu_gobj);
        SFX_PlayCommon(0);
    }

    // check for select
    else if (down & HSD_BUTTON_A)
    {
        // check which option is selected
        if (cursor == 0)
        {

            // get variables and junk
            VSMinorData *css_minorscene = *stc_css_minorscene;
            int this_file_index = (import_data.page * IMPORT_FILESPERPAGE) + import_data.cursor;
            ExportHeader *header = &import_data.file_info[this_file_index].rec_header;
            Preload *preload = Preload_GetTable();

            // get match data
            u8 hmn_kind = header->metadata.hmn;
            u8 hmn_costume = header->metadata.hmn_costume;
            u8 cpu_kind = header->metadata.cpu;
            u8 cpu_costume = header->metadata.cpu_costume;
            u16 stage_kind = header->metadata.stage_external;

            // set fighters
            css_minorscene->vs_data.match_init.playerData[0].kind = hmn_kind;
            css_minorscene->vs_data.match_init.playerData[0].costume = hmn_costume; // header->metadata.hmn_costume;
            preload->fighters[0].kind = hmn_kind;
            preload->fighters[0].costume = hmn_costume;
            css_minorscene->vs_data.match_init.playerData[1].kind = cpu_kind;
            css_minorscene->vs_data.match_init.playerData[1].costume = cpu_costume; // header->metadata.cpu_costume;
            preload->fighters[1].kind = cpu_kind;
            preload->fighters[1].costume = cpu_costume;

            // set stage
            css_minorscene->vs_data.match_init.stage = stage_kind;
            preload->stage = stage_kind;

            // load files
            Preload_Update();

            // advance scene
            *stc_css_exitkind = 1;

            // HUGE HACK ALERT
            EventDesc *(*GetEventDesc)(int page, int event) = RTOC_PTR(TM_DATA + (24 * 4));
            EventDesc *event_desc = GetEventDesc(1, 0);
            event_desc->isSelectStage = 0;
            event_desc->matchData->stage = stage_kind;
            *onload_fileno = this_file_index;
            *onload_slot = import_data.memcard_slot;

            SFX_PlayCommon(1);
        }
        else
            goto EXIT;
    }

    return;
}
void Menu_Confirm_Exit(GOBJ *menu_gobj)
{
    // destroy option text
    Text_Destroy(import_data.confirm.text);
    import_data.confirm.text = 0;

    // destroy gobj
    GObj_Destroy(import_data.confirm.gobj);
    import_data.confirm.gobj = 0;

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