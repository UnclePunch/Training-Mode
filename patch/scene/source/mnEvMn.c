#include "../../../m-ex/MexTK/mex.h"
#include "../../../patch/tm.h"
#include "mnEvMn.h"
#include "mjEv.h"

static u8 leave_kind;
static ESSMinorData *stc_minor_data;
static ArchiveInfo *stc_menu_archive;
static HSD_Fog *stc_fog;                                           // fog pointer, used for cobj erase color
static COBJ *movie_cobj;                                           // "dummy" live cobj pointer used for rendering mth frame
static _HSD_ImageDesc movie_imagedesc = {.format = MNSLEV_IMGFMT}; // movie imagedesc
static _HSD_ImageDesc *orig_imagedesc;                             // original static imagedesc
static TOBJ *orig_tobj;                                            // original tobj
static MTHPlayParam play_param = {1048576, (60 / 30)};             //
static MTHData mth_data;                                           // status of the current mth operation
static EventSelectData *stc_menu_data;                             // minor_exit needs to save page and event to major data, needs to access this
static EventLookup *ev_lookup;

void Minor_Load(ESSMinorData *minor_data)
{

    // save pointer to minor data
    // not sure why it doesnt just pass this into the think function...
    stc_minor_data = minor_data;
    ev_lookup = minor_data->ev_lookup;

    Menu_Init();

    /*
    *stc_css_minorscene = minor_data;

    // init memcard stuff
    Memcard_InitWorkArea();
    Memcard_LoadAssets(0);

    // init unk stuff
    *stc_css_49b0 = minor_data->x0 - 1;

    // init nametag stuff
    *stc_css_regtagnum = 0;
    for (int i = 0; i < 120; i++)
    {
        if (Nametag_GetText(i) != 0)
        {
            *stc_css_regtagnum++;
        }
    }
    *stc_css_regtagnum++;
    *stc_css_49a7 = -1;
    *stc_css_49a8++;

    // TO DO @ 80266918

    // init audio
    Audio_ResetCache(18);
    u64 audio_bits = 1ULL << 35;
    Audio_QueueFileLoad(2, audio_bits);
    Audio_UpdateCache();
    Audio_SyncLoadAll();

    // load css file
    *stc_css_archive = File_Load("MnSlChr");
    *stc_css_menuarchive = File_Load("MnExtAll");
    *stc_css_datatable = File_GetSymbol(*stc_css_archive, 0x803f1170);

    // load text file
    Text_LoadSdFile(0, "SdSlChr", "SIS_SelCharData");
    *stc_css_49ac = 0;

    // init css
    CSS_Init();
*/
    return;
}
void Minor_Think()
{

    ESSMinorData *minor_data = stc_minor_data;

    // check to exit
    HSD_Pad *pads = stc_css_pad;
    HSD_Pad *this_pad = &pads[0];
    if (minor_data->leave_kind)
        Scene_ExitMinor();

    return;
}
void Minor_Exit(VSMinorData *minor_data)
{

    // save event page and id
    stc_minor_data->event = stc_menu_data->cursor.pos + stc_menu_data->cursor.scroll;
    stc_minor_data->page = stc_menu_data->page;
    stc_minor_data->cursor.pos = stc_menu_data->cursor.pos;
    stc_minor_data->cursor.scroll = stc_menu_data->cursor.scroll;

    return;
}

// Menu Functions
void Menu_Init()
{
    // load menu asset file
    stc_menu_archive = File_Load("TM/MnSlEv.dat");
    MnSlEvData *menu_assets = File_GetSymbol(stc_menu_archive, "MnEvSlData");

    // create camera
    GOBJ *cam_gobj = GObj_Create(2, 3, 128);
    COBJ *cam_cobj = COBJ_LoadDesc(menu_assets->menu_cobj);
    GObj_AddObject(cam_gobj, 1, cam_cobj);
    GOBJ_InitCamera(cam_gobj, Menu_CObjThink, 0);
    GObj_AddProc(cam_gobj, MainMenu_CamRotateThink, 5);
    cam_gobj->cobj_links = (1 << 0) + (1 << 1) + (1 << 2) + (1 << 3) + (1 << 4);
    // store cobj to static pointer, needed for MainMenu_CamRotateThink, maybe i should rewrite it?
    void **stc_cam_cobj = (R13 + (-0x4ADC));
    *stc_cam_cobj = menu_assets->menu_cobj;

    // create text canvas
    int canvas_id = Text_CreateCanvas(0, cam_gobj, 7, 8, 128, 1, 128, 0);

    // create fog
    GOBJ *fog_gobj = GObj_Create(14, 2, 0);
    HSD_Fog *fog = Fog_LoadDesc(menu_assets->fog);
    stc_fog = fog;
    GObj_AddObject(fog_gobj, 4, fog);
    GObj_AddGXLink(fog_gobj, GXLink_Fog, 0, 128);

    // create background
    JOBJ_LoadSet(0, menu_assets->bg, 0, 0, 3, 1, 1, GObj_Anim);

    // create menu
    GOBJ *menu_gobj = JOBJ_LoadSet(0, menu_assets->menu, 0, 0, 3, 1, 1, Menu_Animate);
    JOBJ *menu_jobj = menu_gobj->hsd_object;
    GObj_AddProc(menu_gobj, Menu_Think, 5);
    EventSelectData *menu_data = calloc(sizeof(EventSelectData));
    GObj_AddUserData(menu_gobj, 4, HSD_Free, menu_data);
    stc_menu_data = menu_data;
    menu_data->canvas_id = canvas_id; // save canvas id
    orig_tobj = menu_jobj->child->dobj->next->next->next->next->next->next->next->next->mobj->tobj;
    orig_imagedesc = orig_tobj->imagedesc;

    // alloc movie camera
    movie_cobj = COBJ_LoadDescSetScissor(menu_assets->movie_cobj);
    mth_data.status = MTHSTATUS_NONE;

    // save scroll bar jobj
    JOBJ_GetChild(menu_jobj, &menu_data->scroll_jobj, 2, -1);
    JOBJ_GetChild(menu_jobj, &menu_data->scroll_top, 2 + 2, -1);
    JOBJ_GetChild(menu_jobj, &menu_data->scroll_bot, 2 + 3, -1);

    // create cursor
    GOBJ *cursor_gobj = JOBJ_LoadSet(0, menu_assets->cursor, 0, 0, 3, 1, 1, GObj_Anim);
    menu_data->cursor.jobj = cursor_gobj->hsd_object;

    // init page and cursor
    menu_data->page = stc_minor_data->page;
    menu_data->cursor.pos = stc_minor_data->cursor.pos;
    menu_data->cursor.scroll = stc_minor_data->cursor.scroll;

    // Create page text
    Vec3 *menu_scale = &menu_jobj->scale;
    {
        Text **text_arr = &menu_data->text.page_curr;
        Vec3 *scale = &menu_jobj->scale;
        static float text_size[3] = {7, 5, 5};
        static float text_aspectx[3] = {250, 220, 220};
        for (int i = 0; i < 3; i++)
        {

            // get text position
            Vec3 text_pos;
            JOBJ *text_jobj;
            JOBJ_GetChild(menu_jobj, &text_jobj, 8 + i, -1);
            JOBJ_GetWorldPosition(text_jobj, 0, &text_pos);

            // create test text
            Text *text = Text_CreateText(0, canvas_id);
            text_arr[i] = text;
            // enable align and kerning
            text->align = 1;
            text->kerning = 1;
            text->use_aspect = 1;
            text->aspect.X = text_aspectx[i];
            text->scale.X = (menu_scale->X * 0.01) * text_size[i];
            text->scale.Y = (menu_scale->Y * 0.01) * text_size[i];
            text->trans.X = text_pos.X + (0 * (menu_scale->X / 4.0));
            text->trans.Y = (text_pos.Y * -1) + (-1.6 * (menu_scale->Y / 4.0));
            Text_AddSubtext(text, 0, 0, "");
        }
        menu_data->text.page_curr->align = 1;
        menu_data->text.page_prev->align = 0;
        menu_data->text.page_next->align = 2;
    }

    // Create event name text
    // *im now recreating this every update because there was some
    // memory leak issue i couldnt figure out while re-using it...
    /* 
    {
        // get text position
        Vec3 text_jobj_pos;
        JOBJ *text_jobj;
        JOBJ_GetChild(menu_jobj, &text_jobj, 11, -1);
        JOBJ_GetWorldPosition(text_jobj, 0, &text_jobj_pos);

        // get base text world pos and scale
        Vec3 text_pos, text_scale;
        text_scale.X = (menu_scale->X * 0.01) * 6;
        text_scale.Y = (menu_scale->Y * 0.01) * 6;
        text_pos.X = text_jobj_pos.X + (0 * (menu_scale->X / 4.0));
        text_pos.Y = (text_jobj_pos.Y * -1) + (-1.6 * (menu_scale->Y / 4.0));

        // create test text
        Text *text = Text_CreateText(0, canvas_id);
        menu_data->text.event_name = text;
        // enable align and kerning
        text->align = 0;
        text->kerning = 1;
        text->use_aspect = 1;
        text->scale.X = text_scale.X;
        text->scale.Y = text_scale.Y;
        text->trans.X = text_pos.X;
        text->trans.Y = text_pos.Y;

        int event_num = ev_lookup->GetPageEventNum(1);
        for (int i = 0; i < MNSLEV_MAXEVENT; i++)
        {
            Text_AddSubtext(text, 0, (40 * i), "----------------------------");
        }
    }
 */

    // Create event description text
    {
        // get text position
        Vec3 text_pos;
        JOBJ *text_jobj;
        JOBJ_GetChild(menu_jobj, &text_jobj, 12, -1);
        JOBJ_GetWorldPosition(text_jobj, 0, &text_pos);

        // create test text
        Text *text = Text_CreateText(0, canvas_id);
        menu_data->text.event_desc = text;
        // enable align and kerning
        text->align = 0;
        text->kerning = 1;
        text->use_aspect = 1;
        text->scale.X = (menu_scale->X * 0.01) * 5;
        text->scale.Y = (menu_scale->Y * 0.01) * 5;
        text->trans.X = text_pos.X + (0 * (menu_scale->X / 4.0));
        text->trans.Y = (text_pos.Y * -1) + (-1.6 * (menu_scale->Y / 4.0));
        text->aspect.X = 585;
        Text_AddSubtext(text, 0, 0, "");
    }

    Menu_Update(menu_gobj);
    Menu_PlayEventMovie(menu_gobj);

    return;
}
void Menu_Think(GOBJ *menu_gobj)
{
    EventSelectData *menu_data = menu_gobj->userdata;

    // Inputs Think
    {
        int inputs = Pad_GetRapidHeld(4);
        int inputs_down = Pad_GetDown(4);
        int input_kind = INPTKIND_NONE;

        if (inputs & (HSD_BUTTON_UP | HSD_BUTTON_DPAD_UP))
        {

            // check to move cursor up
            if (menu_data->cursor.pos > 0)
            {
                menu_data->cursor.pos--;
                input_kind = INPTKIND_MOVE;
            }
            // check to scroll up
            else if (menu_data->cursor.scroll > 0)
            {
                menu_data->cursor.scroll--;
                input_kind = INPTKIND_MOVE;
            }
        }
        else if (inputs & (HSD_BUTTON_DOWN | HSD_BUTTON_DPAD_DOWN))
        {

            // get number of events onscreen
            int event_num = ev_lookup->GetPageEventNum(menu_data->page);
            if (event_num > MNSLEV_MAXEVENT)
                event_num = MNSLEV_MAXEVENT;

            // determine max scroll
            int scroll_max = ev_lookup->GetPageEventNum(menu_data->page) - MNSLEV_MAXEVENT;
            if (scroll_max < 0)
                scroll_max = 0;

            // check to move cursor down
            if (menu_data->cursor.pos < (event_num - 1))
            {
                menu_data->cursor.pos++;
                input_kind = INPTKIND_MOVE;
            }
            // check to scroll up
            else if (menu_data->cursor.scroll < scroll_max)
            {
                menu_data->cursor.scroll++;
                input_kind = INPTKIND_MOVE;
            }
        }
        else if (inputs & HSD_TRIGGER_L)
        {
            // check to move to prev page
            if (menu_data->page > 0)
            {
                menu_data->page--;
                input_kind = INPTKIND_CHANGE;
            }
        }
        else if (inputs & HSD_TRIGGER_R)
        {

            int page_num = ev_lookup->GetPageNum();

            // check to move to next page
            if (menu_data->page < (page_num - 1))
            {
                menu_data->page++;
                input_kind = INPTKIND_CHANGE;
            }
        }
        else if (inputs_down & (HSD_BUTTON_A | HSD_BUTTON_START))
        {
            stc_minor_data->leave_kind = 2; // advance
            input_kind = INPTKIND_ENTER;
        }
        else if (inputs_down & HSD_BUTTON_B)
        {
            stc_minor_data->leave_kind = 1; // back
            input_kind = INPTKIND_EXIT;
        }

        // act on inputs
        switch (input_kind)
        {
        case (INPTKIND_MOVE):
        {
            // redraw menu
            Menu_Update(menu_gobj);

            // play sfx
            SFX_PlayCommon(2);

            // play mth
            Menu_PlayEventMovie(menu_gobj);

            break;
        }
        case (INPTKIND_CHANGE):
        {

            // reset cursors
            menu_data->cursor.pos = 0;
            menu_data->cursor.scroll = 0;

            // redraw menu
            Menu_Update(menu_gobj);

            // play sfx
            SFX_PlayCommon(2);

            // load mth
            Menu_PlayEventMovie(menu_gobj);

            break;
        }
        case (INPTKIND_ENTER):
        {

            // play sfx
            SFX_PlayCommon(2);

            break;
        }
        case (INPTKIND_EXIT):
        {

            // play sfx
            SFX_PlayCommon(0);

            break;
        }
        }
    }

    // MTH think
    {
        MTHPlayback *mth_header = 0x804333e0;

        // mth state logic
        switch (mth_data.status)
        {
        case (MTHSTATUS_NONE):
        {

            break;
        }
        case (MTHSTATUS_TERMINATE):
        {

            /*
            todo: wait even more, frame is still loading after terminate runs
            */

            // wait for frame and header load to finish
            if ((mth_data.is_loading_header == 0) && (mth_header->is_loading_frame == 0))
            {
                OSReport("terminate\n");

                // free jpeg buffers
                MTH_Terminate();

                // destroy decode gobj and decode buffer
                if (menu_data->mth_gobj)
                {
                    GObj_Destroy(menu_data->mth_gobj);
                    menu_data->mth_gobj = 0;
                }
                if (movie_imagedesc.img_ptr)
                {
                    HSD_Free(movie_imagedesc.img_ptr);
                    movie_imagedesc.img_ptr = 0;
                }

                // disable mth power
                mth_header->power = 0;

                // begin loading next mth header
                mth_data.status = MTHSTATUS_LOADHEADER;
            }
            else
                OSReport("waiting to terminate\n");

            break;
        }
        case (MTHSTATUS_LOADHEADER):
        {

            // append .mth
            static char *extension = "TM/%s.mth";
            char *buffer[20];
            sprintf(buffer, extension, mth_data.filename);

            // if this new file exists, begin loading it
            if (DVDConvertPathToEntrynum(buffer) != -1)
            {

                OSReport("load header\n");

                // init variables
                mth_data.is_loading_header = 1; // raise header load flag
                mth_header->play_param = &play_param;

                // unknown cache stuff @ 8001eb30
                void (*MTH_CacheUnk)() = 0x80335c58;
                MTH_CacheUnk();

                // begin file load
                int entrynum = DVDConvertPathToEntrynum(buffer);
                mth_header->entrynum = entrynum;
                File_Read(entrynum, 0, &mth_header->header, sizeof(MTHHeader), 0x21, 1, MTH_HeaderLoadCb, 0);

                // set status to loading header
                mth_data.status = MTHSTATUS_LOADHEADERWAIT;

                /*
                // begin mth load
                MTH_Init(filename, &play_param, 0, 0, 0);
                play_param.rate = (60 / mth_header->header.framerate); // update framerate based on loaded mth
                mth_data.status = MTHSTATUS_PLAY;
                mth_header->loop = 1;

                // init imagedesc
                orig_imagedesc->format = MNSLEV_IMGFMT;
                orig_imagedesc->width = mth_header->header.xSize;
                orig_imagedesc->height = mth_header->header.ySize;
                // allocate image data ptr
                int tex_size = GXGetTexBufferSize(mth_header->header.xSize,
                                                  mth_header->header.ySize,
                                                  MNSLEV_IMGFMT,
                                                  0,
                                                  0);
                void *movie_imgdata = HSD_MemAlloc(tex_size);
                memset(movie_imgdata, 0, tex_size);
                DCFlushRange(movie_imgdata, tex_size);
                orig_imagedesc->img_ptr = movie_imgdata;

                // create gobj to decode frames
                GOBJ *mth_gobj = GObj_Create(6, 7, 0x80);
                GObj_AddRenderObject(mth_gobj, mth_header->header.xSize, mth_header->header.ySize);
                GObj_AddProc(mth_gobj, MTH_Think, 0);
                menu_data->mth_gobj = mth_gobj;

                // set status to playback
                mth_data.status = MTHSTATUS_PLAY;
                */
            }
            else
                mth_data.status = MTHSTATUS_NONE; // set status to nothing playing

            break;
        }
        case (MTHSTATUS_LOADHEADERWAIT):
        {

            // begin loading frames after header loads
            if (mth_data.is_loading_header == 0)
                mth_data.status = MTHSTATUS_LOADFRAMES;

            break;
        }
        case (MTHSTATUS_LOADFRAMES):
        {

            OSReport("load frames\n");

            // finish initializing mth playback

            // copy some info from header @ 8001eb5c
            play_param.rate = (60 / mth_header->header.framerate); // update framerate based on loaded mth
            mth_header->numFrames = mth_header->header.numFrames;
            mth_header->xSize = mth_header->header.xSize;
            mth_header->ySize = mth_header->header.ySize;
            mth_header->bufSize = mth_header->header.bufSize;
            mth_header->x11c = 1;
            mth_header->x6c = 1;
            mth_header->is_loading_frame = 0;
            mth_header->x70 = 1;
            mth_header->x130 = 0;
            mth_header->x134 = 0;
            mth_header->power = 1; // enable power variable

            // allocate frame buffers @ 8001f480
            int (*x8001ebf0)() = 0x8001ebf0;
            int unk_size = x8001ebf0(mth_header);
            void *buffer = HSD_MemAlloc(unk_size);
            memset(buffer, 0, unk_size);
            mth_header->x140 = buffer;
            mth_header->jpeg_lookup = buffer;

            // set loop flag, x8001ebf0 sets this to 0
            mth_header->loop = 1; // enable mth loop

            // init frame buffers
            {

                // begin loading first X frames
                if ((mth_header->x6c) || (mth_header->x11c))
                {

                    // set first frame pointer (after jpeg lookup)
                    char *jpeg_lookup = mth_header->jpeg_lookup;
                    mth_data.next_frame_ptr = jpeg_lookup + OSRoundUp32B(mth_header->jpeg_cache_num * 4);

                    // init frame count
                    mth_data.frame_num = 0;
                    mth_data.next_frame_size = mth_header->header.firstFrameSize;
                    mth_header->next_jpeg_offset = mth_header->header.firstFrame;

                    // load frame
                    MTH_LoadFrame();

                    mth_data.status = MTHSTATUS_LOADFRAMESWAIT;
                }
                else
                {
                    OSReport("how did i get here??? will stall now\n");
                    __asm__("b 0x0");
                }
            }

            break;
        }
        case (MTHSTATUS_LOADFRAMESWAIT):
        {

            // callback will advance out of this state

            break;
        }
        case (MTHSTATUS_LOADFINALIZE):
        {

            OSReport("finalizing\n");

            // init alarm
            mth_header->x144 = 0;
            mth_header->x148 = 1;
            OSCreateAlarm(&mth_header->alarm);
            OSTime start = cvt_dbl_usll((float)(os_info->bus_clock / 4) * 0.0166667);
            OSTime period = cvt_dbl_usll((float)(os_info->bus_clock / 4) * 0.0166667);
            OSSetPeriodicAlarm(&mth_header->alarm, start, period, 0x8001f2a4);

            /*
            // create cobj
            void (*AllocDummyCObj)(GOBJ * gobj, int width, int height, int r6, int r7) = 0x801a9dd0;
            GOBJ *cam_gobj = GObj_Create(13, 14, 0);
            AllocDummyCObj(cam_gobj, 640, 480, 8, 0);
            //COBJ *cobj = COBJ_LoadDescSetScissor(stc_cobj_desc);
            //GObj_AddObject(cam_gobj, 1, cobj);
            //GOBJ_InitCamera(cam_gobj, 0x803a54ec, 8);
            cam_gobj->cobj_links = (1 << 11);

            // create decode gobj
            GOBJ *decode_gobj = GObj_Create(14, 15, 0);
            GObj_AddObject(decode_gobj, 0, 0);
            GObj_AddGXLink(decode_gobj, MTH_Render, 11, 0);
            GObj_AddRenderObject(decode_gobj, 640, 480);

            // create think gobj
            GOBJ *movie_gobj = GObj_Create(6, 7, 0x80);
            GObj_AddProc(movie_gobj, MTH_Advance, 0);
            */

            // init movie imagedesc
            movie_imagedesc.format = MNSLEV_IMGFMT;
            movie_imagedesc.width = mth_header->header.xSize;
            movie_imagedesc.height = mth_header->header.ySize;
            // allocate image data ptr
            int tex_size = GXGetTexBufferSize(mth_header->header.xSize,
                                              mth_header->header.ySize,
                                              MNSLEV_IMGFMT,
                                              0,
                                              0);
            void *img_buffer = HSD_MemAlloc(tex_size);
            memset(img_buffer, 0, tex_size);
            DCFlushRange(img_buffer, tex_size);
            movie_imagedesc.img_ptr = img_buffer; // display decoded frame on menu

            // set imagedesc pointer
            orig_tobj->imagedesc = &movie_imagedesc;

            // create gobj to decode frames
            GOBJ *mth_gobj = GObj_Create(6, 7, 0x80);
            GObj_AddRenderObject(mth_gobj, mth_header->header.xSize, mth_header->header.ySize);
            GObj_AddProc(mth_gobj, MTH_Think, 0);
            menu_data->mth_gobj = mth_gobj;

            mth_data.status = MTHSTATUS_PLAY;

            break;
        }
        case (MTHSTATUS_PLAY):
        {
            // play mth on menu

            break;
        }
        }
    }

    return;
}
void Menu_Update(GOBJ *gobj)
{
    EventSelectData *menu_data = gobj->userdata;

    // update cursor
    {
        JOBJ *cursor_jobj = menu_data->cursor.jobj;
        cursor_jobj->trans.Y = menu_data->cursor.pos * -1.8;
        JOBJ_SetMtxDirtySub(cursor_jobj);
    }

    // update scroll bar
    {

        // determine max scroll
        int scroll_max = ev_lookup->GetPageEventNum(menu_data->page) - MNSLEV_MAXEVENT;
        if (scroll_max < 0)
            scroll_max = 0;

        // get events on this page
        int event_num = ev_lookup->GetPageEventNum(menu_data->page);

        // hide if less than X events on this page
        if (event_num <= MNSLEV_MAXEVENT)
            JOBJ_SetFlagsAll(menu_data->scroll_jobj, JOBJ_HIDDEN);

        // update and display scroll bar
        else
        {
            JOBJ_ClearFlagsAll(menu_data->scroll_jobj, JOBJ_HIDDEN);
            menu_data->scroll_top->trans.Y = ((float)menu_data->cursor.scroll / (float)(scroll_max)) * (-11);
            JOBJ_SetMtxDirtySub(menu_data->scroll_jobj);
        }
    }

    // Update page text
    {
        // current page
        Text_SetText(menu_data->text.page_curr, 0, ev_lookup->GetPageName(menu_data->page));

        // previous page
        if (menu_data->page > 0)
        {
            Text_SetText(menu_data->text.page_prev, 0, ev_lookup->GetPageName(menu_data->page - 1));
        }
        else
            Text_SetText(menu_data->text.page_prev, 0, "");

        // next page
        if (menu_data->page < (ev_lookup->GetPageNum() - 1))
        {
            Text_SetText(menu_data->text.page_next, 0, ev_lookup->GetPageName(menu_data->page + 1));
        }
        else
            Text_SetText(menu_data->text.page_next, 0, "");
    }

    // Update event name text
    {

        // destroy old alloc
        if (menu_data->text.event_name)
        {
            Text_Destroy(menu_data->text.event_name);
            menu_data->text.event_name = 0;
        }

        // Create event name text
        {
            // get text position
            Vec3 text_jobj_pos;
            JOBJ *text_jobj;
            JOBJ *menu_jobj = gobj->hsd_object;
            Vec3 *menu_scale = &menu_jobj->scale;
            JOBJ_GetChild(menu_jobj, &text_jobj, 11, -1);
            JOBJ_GetWorldPosition(text_jobj, 0, &text_jobj_pos);

            // get base text world pos and scale
            Vec3 text_pos, text_scale;
            text_scale.X = (menu_scale->X * 0.01) * 6;
            text_scale.Y = (menu_scale->Y * 0.01) * 6;
            text_pos.X = text_jobj_pos.X + (0 * (menu_scale->X / 4.0));
            text_pos.Y = (text_jobj_pos.Y * -1) + (-1.6 * (menu_scale->Y / 4.0));

            // create text
            Text *text = Text_CreateText(0, menu_data->canvas_id);
            menu_data->text.event_name = text;
            // enable align and kerning
            text->align = 0;
            text->kerning = 1;
            text->use_aspect = 1;
            text->scale.X = text_scale.X;
            text->scale.Y = text_scale.Y;
            text->trans.X = text_pos.X;
            text->trans.Y = text_pos.Y;
        }

        // get number of events onscreen
        int event_num = ev_lookup->GetPageEventNum(menu_data->page);
        if (event_num > MNSLEV_MAXEVENT)
            event_num = MNSLEV_MAXEVENT;

        // update event text
        for (int i = 0; i < event_num; i++)
        {
            Text_AddSubtext(menu_data->text.event_name, 0, i * 40, ev_lookup->GetEventName(menu_data->page, i + menu_data->cursor.scroll));
        }
    }

    // Update event description text
    {

        // free old if exists
        if (menu_data->text.event_desc)
        {
            Text_Destroy(menu_data->text.event_desc);
            menu_data->text.event_desc = 0;
        }

        // get text position
        Vec3 text_pos;
        JOBJ *text_jobj;
        JOBJ *menu_jobj = gobj->hsd_object;
        Vec3 *menu_scale = &menu_jobj->scale;
        JOBJ_GetChild(menu_jobj, &text_jobj, 12, -1);
        JOBJ_GetWorldPosition(text_jobj, 0, &text_pos);

        // create test text
        Text *text = Text_CreateText(0, menu_data->canvas_id);
        menu_data->text.event_desc = text;
        // enable align and kerning
        text->align = 0;
        text->kerning = 1;
        text->use_aspect = 1;
        text->scale.X = (menu_scale->X * 0.01) * 5;
        text->scale.Y = (menu_scale->Y * 0.01) * 5;
        text->trans.X = text_pos.X + (0 * (menu_scale->X / 4.0));
        text->trans.Y = (text_pos.Y * -1) + (-1.6 * (menu_scale->Y / 4.0));
        text->aspect.X = 585;

        char *msg = ev_lookup->GetEventDescription(menu_data->page, menu_data->cursor.pos + menu_data->cursor.scroll);

        // count newlines
        int line_num = 1;
        int line_length_arr[MNSLEV_DESCLINEMAX];
        char *msg_cursor_prev, *msg_cursor_curr; // declare char pointers
        msg_cursor_prev = msg;
        msg_cursor_curr = strchr(msg_cursor_prev, '\n'); // check for occurrence
        while (msg_cursor_curr != 0)                     // if occurrence found, increment values
        {
            // check if exceeds max lines
            if (line_num >= MNSLEV_DESCLINEMAX)
                assert("MNSLEV_DESCLINEMAX exceeded!");

            // Save information about this line
            line_length_arr[line_num - 1] = msg_cursor_curr - msg_cursor_prev; // determine length of the line
            line_num++;                                                        // increment number of newlines found
            msg_cursor_prev = msg_cursor_curr + 1;                             // update prev cursor
            msg_cursor_curr = strchr(msg_cursor_prev, '\n');                   // check for another occurrence
        }

        // get last lines length
        msg_cursor_curr = strchr(msg_cursor_prev, 0);
        line_length_arr[line_num - 1] = msg_cursor_curr - msg_cursor_prev;

        // copy each line to an individual char array
        char *msg_cursor = &msg;
        for (int i = 0; i < line_num; i++)
        {

            // check if over char max
            u8 line_length = line_length_arr[i];
            if (line_length > MNSLEV_DESCCHARMAX)
                assert("DESC_CHARMAX exceeded!");

            // copy char array
            char msg_line[MNSLEV_DESCCHARMAX + 1];
            memcpy(msg_line, msg, line_length);

            // add null terminator
            msg_line[line_length] = '\0';

            // increment msg
            msg += (line_length + 1); // +1 to skip past newline

            // print line
            int y_delta = (i * MNSLEV_DESCLINEOFFSET);
            Text_AddSubtext(text, 0, y_delta, msg_line);
        }
    }
    /* 
    // output text stuff
    TextAllocInfo *text_alloc = *stc_textheap_first;
    int alloc_num = 0;
    while (text_alloc != 0)
    {
        OSReport("text_alloc %x:\nnum %d\nprev %x\nnext %x\nsize 0x%x\n\n", text_alloc, alloc_num, text_alloc->prev, text_alloc->next, text_alloc->size);

        text_alloc = text_alloc->next;

        alloc_num++;
    } 
    */

    return;
}
void Menu_CObjThink(GOBJ *gobj)
{

    COBJ *cobj = gobj->hsd_object;

    if (CObj_SetCurrent(cobj))
    {
        HSD_Fog *fog = stc_fog;
        CObj_SetEraseColor(fog->color.r, fog->color.g, fog->color.b, fog->color.a);
        CObj_EraseScreen(cobj, 1, 0, 1);
        CObj_RenderGXLinks(gobj, 7);
        CObj_EndCurrent();
    }

    return;
}
void Menu_PlayEventMovie(GOBJ *gobj)
{
    EventSelectData *menu_data = gobj->userdata;

    // get this events file name
    char *file = ev_lookup->GetEventFile(menu_data->page, menu_data->cursor.pos + menu_data->cursor.scroll);

    // play this file
    MTH_Start(gobj, file);

    return;
}
void Menu_Animate(GOBJ *gobj)
{

    // animate menu if no movie is playing
    if (mth_data.status != MTHSTATUS_PLAY)
    {
        GObj_Anim(gobj);
    }
}

////////////////////
// MTH functions //
///////////////////

/*------------------------------------------------------------------
|  Function MTH_Start
|
|  Purpose:  Initializes the load of an .mth file.
|            Begins to terminate 
|
*-------------------------------------------------------------------*/
void MTH_Start(GOBJ *gobj, char *filename)
{

    EventSelectData *menu_data = gobj->userdata;
    MTHPlayback *mth_header = 0x804333e0;

    // init some stuff
    orig_tobj->imagedesc = orig_imagedesc; // play static animation on menu
    mth_data.filename = filename;          // save pointer to this mth filename

    // terminate current operation if running
    if (mth_data.status != MTHSTATUS_NONE)
        mth_data.status = MTHSTATUS_TERMINATE; // signal to decode function to stop loading new frames
    else
        mth_data.status = MTHSTATUS_LOADHEADER; // begin loading mth header

    return;
}
void MTH_HeaderLoadCb()
{

    OSReport("header loaded\n");

    // lower header load flag
    mth_data.is_loading_header = 0;

    return;
}
void MTH_LoadFrame()
{
    MTHPlayback *mth_header = 0x804333e0;

    // lower is loading flag
    mth_header->is_loading_frame = 0;

    // stop loading if a termination is pending
    if (mth_data.status != MTH_Terminate)
    {

        // update next offset and size (except for first)
        //
        // weird conditional but i think this is just
        // a consequence of making this async
        if (mth_data.frame_num > 0)
        {
            // get next jpegs size and file offset
            mth_header->next_jpeg_offset += mth_data.next_frame_size;

            JPEGHeader *last_jpeg_header = mth_header->jpeg_lookup[mth_data.frame_num - 1];
            if (last_jpeg_header->nextSize != 0)
            {
                mth_data.next_frame_size = last_jpeg_header->nextSize; // next size is at 0x0 of the previous jpeg data
                mth_data.next_frame_ptr += mth_header->bufSize;
            }
            else
            {
                assert("last_jpeg_header->nextSize == 0\n");
            }
        }

        // check to continue loading
        if (mth_data.frame_num < mth_header->jpeg_cache_num)
        {

            // store pointer to this frame
            mth_header->jpeg_lookup[mth_data.frame_num] = mth_data.next_frame_ptr;

            // set load flag
            mth_header->is_loading_frame = 1;

            // load this frame
            File_Read(mth_header->entrynum,
                      mth_header->next_jpeg_offset,
                      mth_data.next_frame_ptr,
                      OSRoundUp32B(mth_data.next_frame_size),
                      0x21,
                      1,
                      MTH_LoadFrame,
                      0);

            mth_data.frame_num++;
        }
        // finished loading, clear buffer caches
        else
        {

            // next jpeg size 8001eed4
            JPEGHeader *last_jpeg_header = mth_header->jpeg_lookup[mth_data.frame_num - 1];
            mth_header->x124 = last_jpeg_header->nextSize;
            // total jepg cache? 8001eed0
            if (mth_header->jpeg_cache_num >= mth_header->numFrames)
                mth_header->x74 = 0;
            else
                mth_header->x74 = mth_header->jpeg_cache_num;
            mth_header->x8c = 0;
            mth_header->x108 = mth_header->jpeg_cache_num - 1;
            mth_header->x10c = mth_header->jpeg_cache_num - 1;

            // init decode buffers
            {

                // get pointer to decoded frame data
                char *buffer = mth_data.next_frame_ptr + mth_data.next_frame_size;

                // calculate brightness and chroma data sizes
                int brightness_size = mth_header->xSize * mth_header->ySize;
                int chrom_size = brightness_size / 4;

                // invalidate image buffers, these exist in the main buffer after the initial 32 jpeg frames
                mth_header->decoded_bright = buffer;        // store buffer pointer
                DCInvalidateRange(buffer, brightness_size); // invalidate cache
                buffer = buffer + brightness_size;
                mth_header->decoded_chromeb = buffer;  // store buffer pointer
                DCInvalidateRange(buffer, chrom_size); // invalidate cache
                buffer = buffer + chrom_size;
                mth_header->decoded_chromer = buffer;  // store buffer pointer
                DCInvalidateRange(buffer, chrom_size); // invalidate cache
                buffer = buffer + chrom_size;
                mth_header->x98 = buffer; // store buffer pointer
            }

            // set status to playback
            mth_data.status = MTHSTATUS_LOADFINALIZE;
        }
    }
    return;
}
void MTH_Think(GOBJ *gobj)
{

    MTHPlayback *mth_header = 0x804333e0;

    // skip this logic if terminating mth playback
    if (mth_data.status == MTHSTATUS_PLAY)
    {

        int render_pre_tick = OSGetTick();

        // advance MTH logic, load next frame and decode
        MTH_Advance();

        // Render Frame
        {

            // decode THP frame
            HSD_StartRender(3);
            if (CObj_SetCurrent(movie_cobj))
            {
                // render to EFB
                MTH_Render(gobj, 2);
                CObj_EndCurrent();
            }

            // dump EFB to texture
            HSD_ImageDescCopyFromEFB(&movie_imagedesc, 0, 0, 0);

            // flush cache on image data
            int tex_size = GXGetTexBufferSize(mth_header->header.xSize,
                                              mth_header->header.ySize,
                                              MNSLEV_IMGFMT,
                                              0,
                                              0);
            DCFlushRange(movie_imagedesc.img_ptr, tex_size);

            // free cobj, i used to do this but idk how to totally
            // free the cobj, this was causing a memleak
            //CObj_Release(movie_cobj);
        }

        // done saving, output time
        int render_post_tick = OSGetTick();
        int save_time = OSTicksToMicroseconds(render_post_tick - render_pre_tick);
        OSReport("rendered mth frame in %dus\n", save_time);
    }

    return;
}
