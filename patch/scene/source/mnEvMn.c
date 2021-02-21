#include "../../../m-ex/MexTK/mex.h"
#include "../../../patch/tm.h"
#include "mnEvMn.h"
#include "mjEv.h"

static u8 leave_kind;
static ESSMinorData *stc_minor_data;
static ArchiveInfo *stc_menu_archive;
static HSD_Fog *stc_fog;

void Minor_Load(ESSMinorData *minor_data)
{

    // save pointer to minor data
    // not sure why it doesnt just pass this into the think function...
    stc_minor_data = minor_data;

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

    // check for P1 B Press
    HSD_Pad *pads = stc_css_pad;
    HSD_Pad *this_pad = &pads[0];
    if (this_pad->down & HSD_BUTTON_A)
    {
        minor_data->leave_kind = 1; // advance
        Scene_ExitMinor();
    }
    else if (this_pad->down & HSD_BUTTON_B)
    {
        minor_data->leave_kind = 0; // back
        Scene_ExitMinor();
    }

    return;
}
void Minor_Exit(VSMinorData *minor_data)
{
    OSReport("event menu exit!\n");
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
    GOBJ *menu_gobj = JOBJ_LoadSet(0, menu_assets->menu, 0, 0, 3, 1, 1, GObj_Anim);
    JOBJ *menu_jobj = menu_gobj->hsd_object;
    GObj_AddProc(menu_gobj, Menu_Think, 5);
    EventSelectData *menu_data = calloc(sizeof(EventSelectData));
    GObj_AddUserData(menu_gobj, 4, HSD_Free, menu_data);
    menu_data->canvas_id = canvas_id; // save canvas id

    // save scroll bar jobj
    JOBJ_GetChild(menu_jobj, &menu_data->scroll_jobj, 2, -1);
    JOBJ_GetChild(menu_jobj, &menu_data->scroll_top, 2 + 2, -1);
    JOBJ_GetChild(menu_jobj, &menu_data->scroll_bot, 2 + 3, -1);

    // create cursor
    GOBJ *cursor_gobj = JOBJ_LoadSet(0, menu_assets->cursor, 0, 0, 3, 1, 1, GObj_Anim);
    menu_data->cursor.jobj = cursor_gobj->hsd_object;

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

        menu_data->page = MNSLEV_STARTPAGE;
    }

    // Create event name text
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

        int event_num = tm_function->GetPageEventNum(1);
        for (int i = 0; i < MNSLEV_MAXEVENT; i++)
        {
            Text_AddSubtext(text, 0, (40 * i), "");
        }
    }

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

    return;
}
void Menu_Think(GOBJ *menu_gobj)
{
    EventSelectData *menu_data = menu_gobj->userdata;

    // Inputs Think
    {
        int inputs = Pad_GetRapidHeld(4);
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
            int event_num = tm_function->GetPageEventNum(menu_data->page);
            if (event_num > MNSLEV_MAXEVENT)
                event_num = MNSLEV_MAXEVENT;

            // determine max scroll
            int scroll_max = tm_function->GetPageEventNum(menu_data->page) - MNSLEV_MAXEVENT;
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

            int page_num = tm_function->GetPageNum();

            // check to move to next page
            if (menu_data->page < (page_num - 1))
            {
                menu_data->page++;
                input_kind = INPTKIND_CHANGE;
            }
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
        int scroll_max = tm_function->GetPageEventNum(menu_data->page) - MNSLEV_MAXEVENT;
        if (scroll_max < 0)
            scroll_max = 0;

        // get events on this page
        int event_num = tm_function->GetPageEventNum(menu_data->page);

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
        Text_SetText(menu_data->text.page_curr, 0, tm_function->GetPageName(menu_data->page));

        // previous page
        if (menu_data->page > 0)
        {
            Text_SetText(menu_data->text.page_prev, 0, tm_function->GetPageName(menu_data->page - 1));
        }
        else
            Text_SetText(menu_data->text.page_prev, 0, "");

        // next page
        bp();
        if (menu_data->page < (tm_function->GetPageNum() - 1))
        {
            Text_SetText(menu_data->text.page_next, 0, tm_function->GetPageName(menu_data->page + 1));
        }
        else
            Text_SetText(menu_data->text.page_next, 0, "");
    }

    // Update event name text
    {

        // first clear all event names
        for (int i = 0; i < MNSLEV_MAXEVENT; i++)
        {
            Text_SetText(menu_data->text.event_name, i, "");
        }

        // get number of events onscreen
        int event_num = tm_function->GetPageEventNum(menu_data->page);
        if (event_num > MNSLEV_MAXEVENT)
            event_num = MNSLEV_MAXEVENT;

        // update event text
        for (int i = 0; i < event_num; i++)
        {
            Text_SetText(menu_data->text.event_name, i, tm_function->GetEventName(menu_data->page, i + menu_data->cursor.scroll));
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

        char *msg = tm_function->GetEventDescription(menu_data->page, menu_data->cursor.pos + menu_data->cursor.scroll);

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

/*
void CSS_Init()
{

    MnSlChrData *css_data = stc_css_data;

    // play announcer sfx
    SFX_Play(30005);

    // init some values
    *stc_css_49c0 = 0;
    *stc_css_49c4 = 0;
    *stc_css_49b8 = 0;
    *stc_css_49bc = 0;
    *stc_css_delay = 1;
    *stc_css_hasreleasedb = 0;
    *stc_css_maxply = 4;
    *stc_css_cpuport = 0;
    *stc_css_exitkind = 0;

    for (int i = 0; i < 4; i++)
    {
        css_data->doors[i].x9 = 0;
    }

    // create cobj
    MnSelectChrDataTable *css_datatable = *stc_css_datatable;
    GOBJ *cam_gobj = GObj_Create(2, 3, 128);
    *stc_css_cobjdesc = css_datatable->cobj;
    COBJ *css_cobj = COBJ_LoadDesc(css_datatable->cobj);
    GObj_AddObject(cam_gobj, 1, css_cobj);
    GOBJ_InitCamera(cam_gobj, CObjThink_Common, 0);
    cam_gobj->cobj_id = (1 << 0) + (1 << 1) + (1 << 2) + (1 << 3) + (1 << 4);
    GObj_AddProc(cam_gobj, CSS_CameraRotateThink, 5);

    // create text canvas
    int canvas_id = Text_CreateCanvas(0, cam_gobj, 7, 8, 128, 1, 128, 0);

    // create lobjs
    GOBJ *light_gobj = GObj_Create(3, 4, 128);
    LOBJ *lobj1 = LObj_LoadDesc(css_datatable->lobj1);
    LOBJ *lobj2 = LObj_LoadDesc(css_datatable->lobj2);
    lobj1->next = lobj2;
    GObj_AddObject(light_gobj, 2, lobj1);
    GObj_AddGXLink(light_gobj, GXLink_LObj, 0, 128);

    // create fog
    GOBJ *fog_gobj = GObj_Create(14, 2, 0);
    void *fog = Fog_LoadDesc(css_datatable->fog);
    GObj_AddObject(fog_gobj, 4, fog);
    GObj_AddGXLink(fog_gobj, GXLink_Fog, 0, 128);

    // create background
    GOBJ *bg_gobj = GObj_Create(3, 5, 128);
    JOBJ *bg_model = JOBJ_LoadJoint(css_datatable->bg.jobj);
    JOBJ_AddAnimAll(bg_model, css_datatable->bg.animjoint, css_datatable->bg.matanimjoint, css_datatable->bg.shapeaninjoint); // add anims
    GObj_AddObject(bg_gobj, 3, bg_model);
    GObj_AddGXLink(bg_gobj, GXLink_Common, 1, 128);
    GObj_AddProc(bg_gobj, 0x80263354, 4); // shitty callback to manually loop anim
    JOBJ_ReqAnimAll(bg_model, 0);
    JOBJ_AnimAll(bg_model);

    // create VS model
    GOBJ *vs_gobj = GObj_Create(4, 5, 128);
    *stc_css_menugobj = vs_gobj;
    JOBJ *vs_model = JOBJ_LoadJoint(css_datatable->vsmenu.jobj);
    *stc_css_menumodel = vs_model;
    JOBJ_AddAnimAll(vs_model, css_datatable->vsmenu.animjoint, css_datatable->vsmenu.matanimjoint, css_datatable->vsmenu.shapeaninjoint); // add anims
    GObj_AddObject(vs_gobj, 3, vs_model);
    GObj_AddGXLink(vs_gobj, GXLink_Common, 1, 128);
    GObj_AddProc(vs_gobj, CSS_MenuModelThink, 4);
    JOBJ_ReqAnimAll(vs_model, 0);
    JOBJ_AnimAll(vs_model);
    JOBJ_PlayAnim(vs_model, 6, 0xFFFF, AOBJ_StopAnim, 6, 0, 0);

    // ADD CUSTOM ICONS HERE

    // init hands 80264bd4
    CSSCursor *cursors = *stc_css_cursors;
    for (int i = 0; i < *stc_css_maxply; i++)
    {

        CSSCursor *cursor_data = HSD_MemAlloc(sizeof(CSSCursor));

        // create cursor model
        GOBJ *cursor_gobj = GObj_Create(4, 5, 128);
        JOBJ *cursor_model = JOBJ_LoadJoint(css_datatable->cursor.jobj);
        JOBJ_AddAnimAll(cursor_model, css_datatable->cursor.animjoint, css_datatable->cursor.matanimjoint, css_datatable->cursor.shapeaninjoint); // add anims
        GObj_AddObject(cursor_gobj, 3, cursor_model);
        GObj_AddGXLink(cursor_gobj, GXLink_Common, 3, 128);
        GObj_AddUserData(cursor_gobj, 4, HSD_Free, cursor_data);
        GObj_AddProc(cursor_gobj, CSS_CursorThink, 1);
        JOBJ_ReqAnimAll(cursor_model, 0);
        JOBJ_AnimAll(cursor_model);
        JOBJ_PlayAnim(cursor_model, 6, 0xFFFF, AOBJ_StopAnim, 6, 0, 0);

        // init data struct
        stc_css_cursors[i] = cursor_data;
        cursor_data->gobj = cursor_gobj;
        cursor_data->port = i;
        cursor_data->x8 = 0;
        cursor_data->xa = 0;
        cursor_data->puck = 0;
        cursor_data->x7 = 0;
        cursor_data->state = 2;
        cursor_data->pos.X = (i * 15) - 31;
        cursor_data->pos.Y = -21.5;
    }

    // init pucks 80264d48
    CSSPuck *pucks = *stc_css_pucks;
    for (int i = 0; i < *stc_css_maxply; i++)
    {

        CSSPuck *puck_data = HSD_MemAlloc(sizeof(CSSPuck));

        // create puck model
        GOBJ *puck_gobj = GObj_Create(4, 5, 128);
        JOBJ *puck_model = JOBJ_LoadJoint(css_datatable->puck.jobj);
        JOBJ_AddAnimAll(puck_model, css_datatable->puck.animjoint, css_datatable->puck.matanimjoint, css_datatable->puck.shapeaninjoint); // add anims
        GObj_AddObject(puck_gobj, 3, puck_model);
        GObj_AddGXLink(puck_gobj, GXLink_Common, 2, 128);
        //GObj_AddProc(puck_gobj, CSS_PuckThink, 2);
        GObj_AddUserData(puck_gobj, 4, HSD_Free, puck_data);
        JOBJ_ReqAnimAll(puck_model, 0);
        JOBJ_AnimAll(puck_model);
        JOBJ_PlayAnim(puck_model, 6, 0xFFFF, AOBJ_StopAnim, 6, 0, 0);

        // init data struct
        stc_css_pucks[i] = puck_data;
        puck_data->gobj = puck_gobj;
        puck_data->port = i;
        puck_data->state = 0;
        puck_data->held = -1;
        puck_data->anim_timer = 0;

        // search for selected icon
        VSMinorData *minor_data = *stc_css_minorscene;
        PlayerData *player_data = &minor_data->vs_data.match_init.playerData[i];
        int sel_fighter = player_data->kind;
        int sel_icon = 0;
        MnSlChrIcon *css_icons = &css_data->icons;
        for (int j = 0; j < icon_num; j++)
        {
            // check if this is the icon the player has selected
            if (css_icons[j].ft_kind == sel_fighter)
            {
                // and if this fighter is unlocked
                if (Fighter_CheckUnlocked(css_icons[j].ft_kind) != 0)
                    break;
            }

            // increment icon
            sel_icon++;
        }

        // if no icon is selected
        if (sel_icon == icon_num)
        {
            player_data->kind = icon_num + 1;
            if (player_data->status == 1)
            {
                player_data->status = 3;
            }
        }

        // save selected icon to door data
        css_data->doors[i].sel_icon = sel_icon;

        // set puck position to middle of the icon
        MnSlChrIcon *sel_icon_data = &css_icons[sel_icon];
        puck_data->pos_correct.X = sel_icon_data->bound_l + (sel_icon_data->bound_r - sel_icon_data->bound_l) / 2;
        puck_data->pos_correct.Y = sel_icon_data->bound_d + (sel_icon_data->bound_u - sel_icon_data->bound_d) / 2;
    }

    // nametags? 80264f54
    MnSlChrTag *tags = &css_data->tags;
    for (int i = 0; i < *stc_css_maxply; i++)
    {

        // get this static tag data
        MnSlChrTag *this_tag = &tags[i];

        // alloc tag data
        MnSlChrTagData *tag_data = HSD_MemAlloc(sizeof(MnSlChrTagData));
        this_tag->tag_data = tag_data;

        // create tag gobj
        GOBJ *tag_gobj = GObj_Create(4, 5, 128);
        //GObj_AddProc(tag_gobj, CSS_TagThink, 4);
        GObj_AddUserData(tag_gobj, 4, HSD_Free, tag_data);

        // init data
        tag_data->use_tag = 0;
        tag_data->timer = 0;
        tag_data->state = 0;
        tag_data->x8 = 0;
        tag_data->scroll_amt = 0;
        tag_data->scroll_force = 0;
        tag_data->state = 0;
        tag_data->port = i;

        // init display name text
        Text *tag_name = Text_CreateText(0, canvas_id);
        tag_data->name = tag_name;
        tag_name->x4c = 1;
        tag_name->fixed_width = 1;
        tag_name->align = 1;
        tag_name->scale.X = 0.058;
        tag_name->scale.Y = 0.055;

        // init nametag model
        JOBJ *name_joint;
        JOBJ_GetChild(*stc_css_menumodel, &name_joint, this_tag->name_joint, -1);
        JOBJ_PlayAnim(name_joint, 6, 0x20, AOBJ_ReqAnim, 1);
        JOBJ_AnimAll(name_joint);
        JOBJ_PlayAnim(name_joint, 6, 0x20, AOBJ_StopAnim, 6, 0, 0);

        // move text onto nametag box
        Vec3 name_pos;
        JOBJ_GetWorldPosition(name_joint, 0, &name_pos);
        tag_name->trans.X = name_pos.X + 0.5;
        tag_name->trans.Y = -0.4 - name_pos.Y;
        tag_name->trans.Z = name_pos.Z;
        tag_name->limit.X = 160;
        tag_name->limit.Y = 32;

        // init name text
        Text_AddSubtext(tag_name, 80, 0, 0x80c0ba2c);

        // init namelist text
        Text *tag_list = Text_CreateText(0, canvas_id);
        tag_data->namelist = tag_list;
        tag_list->fixed_width = 1;
        tag_list->x4e = 1;
        tag_list->hidden = 1;
        tag_list->scale.X = 0.065;
        tag_list->scale.Y = 0.065;

        // init lsit
        JOBJ *list_jobj;
        JOBJ_GetChild(*stc_css_menumodel, &list_jobj, this_tag->list_joint, -1);

        // move text onto nametag box
        Vec3 list_pos;
        JOBJ_GetWorldPosition(list_jobj, 0, &list_pos);
        tag_list->trans.X = list_pos.X - 0.6;
        tag_list->trans.Y = 0.8 - list_pos.Y;
        tag_list->trans.Z = list_pos.Z;
        tag_list->limit.X = 154;
        tag_list->limit.Y = 256;

        // init name text
        Text_AddSubtext(tag_list, 0, 0, 0x803f1024);
        static GXColor ftname_color = {255, 255, 0, 255};
        Text_SetColor(tag_list, 0, &ftname_color);

        // init name entry text
        Text_AddSubtext(tag_list, 0, 0, 0x803f103c);
        static GXColor unk_color = {255, 255, 0, 255};
        Text_SetColor(tag_list, 1, &unk_color);

        // create 9 tags
        BGM_GetMenuBGM();
        for (int j = 0; j < 9; j++)
        {
            Text_AddSubtext(tag_list, 10, 0, 0x803f1018);
        }

        // get next useable tag
        int tag_count = 0;
        for (int j = 0; tag_count < 120; tag_count++)
        {
            if (Nametag_GetText(tag_count) != 0)
            {
                break;
            }
        }
        tag_data->next_tag = tag_count + 1;

        // init unk
        JOBJ *unk_jobj;
        JOBJ_GetChild(*stc_css_menumodel, &unk_jobj, this_tag->x7, -1);
        JOBJ_SetFlags(unk_jobj, JOBJ_HIDDEN);

        // init arrows?
        JOBJ *unk_jobj2;
        JOBJ_GetChild(*stc_css_menumodel, &unk_jobj2, this_tag->kostartext_joint, -1);
        if (tag_data->next_tag <= 7)
        {
            JOBJ_SetFlags(unk_jobj2, JOBJ_HIDDEN);
        }
        else
        {
            JOBJ_ClearFlags(unk_jobj2, JOBJ_HIDDEN);
        }

        // get tag this player is using
        VSMinorData *minor_data = *stc_css_minorscene;
        PlayerData *player_data = &minor_data->vs_data.match_init.playerData[i];
        if (player_data->nametag != 120)
        {
            tag_data->use_tag = 1;

            // set text to this nametag string
            char *tag_text = Nametag_GetText(player_data->nametag);
            Text_SetText(tag_data->name, 0, tag_text);

            tag_data->name->kerning = 0;
        }
    }
    css_data->x483 = 0;

    // ucf indicator would go here

    // init rules 802662c8
    Text *rules_text = Text_CreateText2(0, canvas_id, -12, -23.3, 0, 450, 32);
    rules_text->align = 1;
    rules_text->fixed_width = 1;
    rules_text->kerning = 1;
    rules_text->scale.X = 0.07;
    rules_text->scale.Y = 0.07;
    Text_SetSisText(rules_text, 74);
    CSS_UpdateRulesText();

    // ko stars text 80266350
    for (int i = 0; i < *stc_css_maxply; i++)
    {

        MnSlChrKOStar *this_kostar = &css_data->ko_stars[i];
        JOBJ *konum_joint;
        JOBJ_GetChild(*stc_css_menumodel, &konum_joint, this_kostar->joint, -1);
        Vec3 konum_pos;
        JOBJ_GetWorldPosition(konum_joint, 0, &konum_pos);
        Text *konum_text = Text_CreateText2(0, canvas_id, konum_pos.X, (konum_pos.Y * 1) - 0.9, konum_pos.Z, 32, 32);
        konum_text->scale.X = 0.07;
        konum_text->scale.Y = 0.07;

        // store to static array
        this_kostar->text = konum_text;

        // update
        CSS_UpdateKOStars(i, 0);
    }

    // press start 80266438
    GOBJ *start_gobj = GObj_Create(4, 5, 128);
    JOBJ *start_model = JOBJ_LoadJoint(css_datatable->start.jobj);
    GObj_AddObject(start_gobj, 3, start_model);
    GObj_AddGXLink(start_gobj, GXLink_Common, 1, 128);
    //GObj_AddProc(start_gobj, CSS_StartThink, 4);                                                                                          // shitty callback to manually loop anim
    JOBJ_AddAnimAll(start_model, css_datatable->start.animjoint, css_datatable->start.matanimjoint, css_datatable->start.shapeaninjoint); // add anims
    JOBJ_ReqAnimAll(start_model, 0);
    JOBJ_PlayAnim(start_model, 6, 0xFFFF, AOBJ_StopAnim, 6, 0, 0);
    *stc_css_49a9 = 0;

    // init doors 802665b0
    for (int i = 0; i < *stc_css_maxply; i++)
    {
        VSMinorData *minor_data = *stc_css_minorscene;
        PlayerData *player_data = &minor_data->vs_data.match_init.playerData[i];
        MnSlChrDoor *door_data = &css_data->doors[i];

        // copy player info to door
        door_data->state = player_data->status;
        door_data->costume = player_data->costume;
        door_data->xc = 3;
        door_data->state = 0;
        door_data->x10 = 0;
        door_data->x13 = 0;
        door_data->x12 = 0;
        door_data->xf = door_data->sel_icon;

        Rules1 *rules = Memcard_GetRules1();

        // for handicap off
        if (rules->handicap == 0)
        {
            // set cpu to lv 1 if 0
            if (player_data->cpuLevel == 0)
            {
                player_data->cpuLevel = 1;
            }

            // get slider jobj
            JOBJ *cpuslider_model;
            JOBJ_GetChild(*stc_css_menumodel, &cpuslider_model, door_data->cpuslider_joint, -1);

            // move cpu slider
            cpuslider_model->trans.X = 1.25 * (player_data->cpuLevel - 1);
        }
        // handicap on
        else
        {

            int handicap_lv;

            // auto handicap
            if (rules->handicap == 1)
                handicap_lv = CSS_GetHandicapValue(i, player_data->nametag); // get nametag level

            // manual handicap
            else if (rules->handicap == 2)
                handicap_lv = player_data->handicap;

            if (handicap_lv == 0)
            {
                handicap_lv = 1;
            }

            handicap_lv--; // 0 index

            // move slider jobj
            JOBJ *cpuslider_model;
            JOBJ_GetChild(*stc_css_menumodel, &cpuslider_model, door_data->cpuslider_joint, -1);
            cpuslider_model->trans.X = 1.25 * (handicap_lv - 1);

            // set cpu to lv 1 if 0
            if (player_data->cpuLevel == 0)
            {
                player_data->cpuLevel = 1;
            }

            // get slider jobj
            JOBJ *slider2_model;
            JOBJ_GetChild(*stc_css_menumodel, &slider2_model, door_data->slider2_joint, -1);

            // move cpu slider
            slider2_model->trans.X = 1.25 * (player_data->cpuLevel - 1);
        }
    }

    // set mode texture
    CSS_SetModeTexture(0);
    BGM_Play(BGM_GetMenuBGM());

    return;
}
*/