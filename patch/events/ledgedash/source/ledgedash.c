#include "ledgedash.h"
static char nullString[] = " ";

static GXColor tmgbar_black = {40, 40, 40, 255};
static GXColor tmgbar_grey = {80, 80, 80, 255};
static GXColor tmgbar_blue = {128, 128, 255, 255};
static GXColor tmgbar_green = {128, 255, 128, 255};
static GXColor tmgbar_yellow = {255, 255, 128, 255};
static GXColor tmgbar_red = {255, 128, 128, 255};
static GXColor tmgbar_indigo = {255, 128, 255, 255};
static GXColor tmgbar_white = {255, 255, 255, 255};
static GXColor *tmgbar_colors[] = {
    &tmgbar_black,
    &tmgbar_grey,
    &tmgbar_green,
    &tmgbar_yellow,
    &tmgbar_indigo,
    &tmgbar_white,
    &tmgbar_red,
};

// Main Menu
static char **LdshOptions_Start[] = {"Ledge", "Respawn Platform"};
static char **LdshOptions_Reset[] = {"On", "Off"};
static char **LdshOptions_HUD[] = {"On", "Off"};
static EventOption LdshOptions_Main[] = {
    // Position
    {
        .option_kind = OPTKIND_STRING,                                             // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(LdshOptions_Start) / 4,                                // number of values for this option
        .option_val = 0,                                                           // value of this option
        .menu = 0,                                                                 // pointer to the menu that pressing A opens
        .option_name = "Starting Position",                                        // pointer to a string
        .desc = "Choose where the fighter is placed \nafter resetting positions.", // string describing what this option does
        .option_values = LdshOptions_Start,                                        // pointer to an array of strings
        .onOptionChange = Ledgedash_ToggleStartPosition,
    },
    // Reset
    {
        .option_kind = OPTKIND_STRING,                                                                  // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(LdshOptions_Reset) / 4,                                                     // number of values for this option
        .option_val = 0,                                                                                // value of this option
        .menu = 0,                                                                                      // pointer to the menu that pressing A opens
        .option_name = "Auto-Reset",                                                                    // pointer to a string
        .desc = "Toggle the automatic resetting of the \nfighter's position after ledgedash attempts.", // string describing what this option does
        .option_values = LdshOptions_Reset,                                                             // pointer to an array of strings
        .onOptionChange = Ledgedash_ToggleAutoReset,
    },
    // HUD
    {
        .option_kind = OPTKIND_STRING,            // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(LdshOptions_HUD) / 4, // number of values for this option
        .option_val = 0,                          // value of this option
        .menu = 0,                                // pointer to the menu that pressing A opens
        .option_name = "HUD",                     // pointer to a string
        .desc = "Toggle visibility of the HUD.",  // string describing what this option does
        .option_values = LdshOptions_HUD,         // pointer to an array of strings
        .onOptionChange = 0,
    },
    // Tips
    {
        .option_kind = OPTKIND_STRING,                  // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(LdshOptions_HUD) / 4,       // number of values for this option
        .option_val = 0,                                // value of this option
        .menu = 0,                                      // pointer to the menu that pressing A opens
        .option_name = "Tips",                          // pointer to a string
        .desc = "Toggle the onscreen display of tips.", // string describing what this option does
        .option_values = LdshOptions_HUD,               // pointer to an array of strings
        .onOptionChange = Tips_Toggle,
    },
    // Help
    {
        .option_kind = OPTKIND_FUNC,                                                                                                                                                                                                                                                  // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                                                                                                                                                                                                                                                               // number of values for this option
        .option_val = 0,                                                                                                                                                                                                                                                              // value of this option
        .menu = 0,                                                                                                                                                                                                                                                                    // pointer to the menu that pressing A opens
        .option_name = "About",                                                                                                                                                                                                                                                       // pointer to a string
        .desc = "Ledgedashing is the act of wavedashing onto stage from ledge.\nThis is most commonly done by dropping off ledge, double jumping \nimmediately, and quickly airdodging onto stage. Each input \nis performed quickly after the last, making it difficult and risky.", // string describing what this option does
        .option_values = 0,                                                                                                                                                                                                                                                           // pointer to an array of strings
        .onOptionChange = 0,
    },
    // Exit
    {
        .option_kind = OPTKIND_FUNC,                     // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                                  // number of values for this option
        .option_val = 0,                                 // value of this option
        .menu = 0,                                       // pointer to the menu that pressing A opens
        .option_name = "Exit",                           // pointer to a string
        .desc = "Return to the Event Selection Screen.", // string describing what this option does
        .option_values = 0,                              // pointer to an array of strings
        .onOptionChange = 0,
        .onOptionSelect = Event_Exit,
    },
};
static EventMenu LdshMenu_Main = {
    .name = "Ledgedash Training",                                 // the name of this menu
    .option_num = sizeof(LdshOptions_Main) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                  // runtime variable used for how far down in the menu to start
    .state = 0,                                                   // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                  // index of the option currently selected, used at runtime
    .options = &LdshOptions_Main,                                 // pointer to all of this menu's options
    .prev = 0,                                                    // pointer to previous menu, used at runtime
};

// Init Function
void Event_Init(GOBJ *gobj)
{
    LedgedashData *event_data = gobj->userdata;

    // theres got to be a better way to do this...
    event_vars = *event_vars_ptr;

    // get assets
    event_data->assets = File_GetSymbol(event_vars->event_archive, "ldshData");

    // standardize camera
    Stage *stage = stc_stage;
    float *unk_cam = 0x803bcca0;
    stc_stage->fov_r = 0; // no camera rotation
    stc_stage->x28 = 1;   // pan value?
    stc_stage->x2c = 1;   // pan value?
    stc_stage->x30 = 1;   // pan value?
    stc_stage->x34 = 130; // zoom out
    unk_cam[0x40 / 4] = 30;

    // Init hitlog
    event_data->hitlog_gobj = Ledgedash_HitLogInit();

    // Init HUD
    Ledgedash_HUDInit(event_data);

    // Init Fighter
    Ledgedash_FtInit(event_data);

    return;
}
// Think Function
void Event_Think(GOBJ *event)
{
    LedgedashData *event_data = event->userdata;

    // get fighter data
    GOBJ *hmn = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn->userdata;
    HSD_Pad *pad = PadGet(hmn_data->player_controller_number, PADGET_ENGINE);

    // no ledgefall
    FtCliffCatch *ft_state = &hmn_data->state_var;
    if (hmn_data->state == ASID_CLIFFWAIT)
        ft_state->fall_timer = 2;

    Ledgedash_HUDThink(event_data, hmn_data);
    Ledgedash_HitLogThink(event_data, hmn);
    Ledgedash_ResetThink(event_data, hmn);
    Ledgedash_ChangeLedgeThink(event_data, hmn);

    return;
}
void Event_Exit()
{
    Match *match = MATCH;

    // end game
    match->state = 3;

    // cleanup
    Match_EndVS();

    // unfreeze
    HSD_Update *update = HSD_UPDATE;
    update->pause_develop = 0;
    return;
}

// Ledgedash functions
void Ledgedash_HUDInit(LedgedashData *event_data)
{

    // create hud cobj
    GOBJ *hudcam_gobj = GObj_Create(19, 20, 0);
    ArchiveInfo **ifall_archive = 0x804d6d5c;
    COBJDesc ***dmgScnMdls = File_GetSymbol(*ifall_archive, 0x803f94d0);
    COBJDesc *cam_desc = dmgScnMdls[1][0];
    COBJ *hud_cobj = COBJ_LoadDesc(cam_desc);
    // init camera
    GObj_AddObject(hudcam_gobj, R13_U8(-0x3E55), hud_cobj);
    GOBJ_InitCamera(hudcam_gobj, Ledgedash_HUDCamThink, 7);
    hudcam_gobj->cobj_links = 1 << 18;

    GOBJ *hud_gobj = GObj_Create(0, 0, 0);
    event_data->hud.gobj = hud_gobj;
    // Load jobj
    JOBJ *hud_jobj = JOBJ_LoadJoint(event_data->assets->hud);
    GObj_AddObject(hud_gobj, 3, hud_jobj);
    GObj_AddGXLink(hud_gobj, GXLink_Common, 18, 80);

    // account for widescreen
    /*
    float aspect = (hud_cobj->projection_param.perspective.aspect / 1.216667) - 1;
    JOBJ *this_jobj;
    JOBJ_GetChild(hud_jobj, &this_jobj, 1, -1);
    this_jobj->trans.X += (this_jobj->trans.X * aspect);
    JOBJ_SetMtxDirtySub(hud_jobj);
    */

    // create text canvas
    int canvas = Text_CreateCanvas(2, hud_gobj, 14, 15, 0, 18, 81, 19);
    event_data->hud.canvas = canvas;

    // init text
    Text **text_arr = &event_data->hud.text_angle;
    for (int i = 0; i < 2; i++)
    {

        // Create text object
        Text *hud_text = Text_CreateText(2, canvas);
        text_arr[i] = hud_text;
        hud_text->kerning = 1;
        hud_text->align = 1;
        hud_text->use_aspect = 1;

        // Get position
        Vec3 text_pos;
        JOBJ *text_jobj;
        JOBJ_GetChild(hud_jobj, &text_jobj, 2 + i, -1);
        JOBJ_GetWorldPosition(text_jobj, 0, &text_pos);

        // adjust scale
        Vec3 *scale = &hud_jobj->scale;
        // text scale
        hud_text->scale.X = (scale->X * 0.01) * LCLTEXT_SCALE;
        hud_text->scale.Y = (scale->Y * 0.01) * LCLTEXT_SCALE;
        hud_text->aspect.X = 165;

        // text position
        hud_text->trans.X = text_pos.X + (scale->X / 4.0);
        hud_text->trans.Y = (text_pos.Y * -1) + (scale->Y / 4.0);

        // dummy text
        Text_AddSubtext(hud_text, 0, 0, "-");
    }

    // reset all bar colors
    JOBJ *timingbar_jobj;
    JOBJ_GetChild(hud_jobj, &timingbar_jobj, LCLJOBJ_BAR, -1); // get timing bar jobj
    DOBJ *d = timingbar_jobj->dobj;
    int count = 0;
    while (d != 0)
    {
        // if a box dobj
        if ((count >= 0) && (count < 30))
        {

            // if mobj exists (it will)
            MOBJ *m = d->mobj;
            if (m != 0)
            {

                HSD_Material *mat = m->mat;

                // set alpha
                mat->alpha = 0.7;

                // set color
                mat->diffuse = tmgbar_black;
            }
        }

        // inc
        count++;
        d = d->next;
    }

    return 0;
}
void Ledgedash_HUDThink(LedgedashData *event_data, FighterData *hmn_data)
{

    // run tip logic
    Tips_Think(event_data, hmn_data);

    JOBJ *hud_jobj = event_data->hud.gobj->hsd_object;

    // only run logic if ledge exists
    if (event_data->ledge_line != -1)
    {
        // increment timer
        event_data->hud.timer++;

        // check to initialize timer
        if ((hmn_data->state == ASID_CLIFFWAIT) && (hmn_data->TM.state_frame == 1))
        {
            Ledgedash_InitVariables(event_data);

            event_data->tip.refresh_num++;
        }

        int curr_frame = event_data->hud.timer;

        // update action log
        if (curr_frame < (sizeof(event_data->hud.action_log) / sizeof(u8)))
        {
            // look for cliffwait
            if (hmn_data->state == ASID_CLIFFWAIT)
            {
                event_data->hud.action_log[curr_frame] = LDACT_CLIFFWAIT;
            }
            // look for release
            else if (hmn_data->state == ASID_FALL)
            {
                event_data->hud.is_release = 1;
                event_data->hud.action_log[curr_frame] = LDACT_FALL;
            }
            // look for jump
            else if ((hmn_data->state == ASID_JUMPAERIALF) || (hmn_data->state == ASID_JUMPAERIALB) ||
                     (((hmn_data->kind == 4) || (hmn_data->kind == 15)) && ((hmn_data->state >= 341) && (hmn_data->state <= 345)))) // check for kirby and jiggs jump
            {
                event_data->hud.is_jump = 1;
                event_data->hud.action_log[curr_frame] = LDACT_JUMP;
            }
            // look for airdodge
            else if (hmn_data->state == ASID_ESCAPEAIR)
            {
                //event_data->hud.is_airdodge = 1;
                event_data->hud.action_log[curr_frame] = LDACT_AIRDODGE;
            }
            // look for aerial
            else if (hmn_data->attack_kind != 1)
            {
                event_data->hud.is_aerial = 1;
                event_data->hud.action_log[curr_frame] = LDACT_ATTACK;
            }
            // look for land
            else if (((hmn_data->state == ASID_LANDING) || (hmn_data->state == ASID_LANDINGFALLSPECIAL)) || ((hmn_data->state == ASID_WAIT) && (hmn_data->TM.state_frame == 0) && ((hmn_data->TM.state_prev != ASID_LANDING) || (hmn_data->TM.state_prev != ASID_LANDINGFALLSPECIAL)))) // this is first frame of a no impact land
            {
                event_data->hud.is_land = 1;
                event_data->hud.action_log[curr_frame] = LDACT_LANDING;
            }
        }

        // grab airdodge angle
        if (event_data->hud.is_airdodge == 0)
        {

            if ((hmn_data->state == ASID_ESCAPEAIR) || (hmn_data->TM.state_prev[0] == ASID_ESCAPEAIR))
            {
                // determine airdodge angle
                float angle = atan2(hmn_data->input.lstick_y, hmn_data->input.lstick_x) - -(M_PI / 2);

                // save airdodge angle
                event_data->hud.airdodge_angle = angle;
                event_data->hud.is_airdodge = 1;
            }
        }

        // look for actionable
        if (((event_data->hud.is_actionable == 0) && (event_data->hud.is_release == 1)) &&
            (((((hmn_data->state == ASID_WAIT) && ((hmn_data->TM.state_prev[0] != ASID_LANDING) || (hmn_data->TM.state_prev[0] != ASID_LANDINGFALLSPECIAL)) && (hmn_data->TM.state_frame > 0)) || (hmn_data->TM.state_prev[0] == ASID_WAIT)) && (hmn_data->TM.state_frame <= 1)) || // prev frame too cause you can attack on the same frame
             ((hmn_data->state == ASID_LANDING) && (hmn_data->TM.state_frame >= hmn_data->attr.normal_landing_lag)) ||
             ((hmn_data->TM.state_prev[0] == ASID_LANDING) && (hmn_data->TM.state_prev_frames[0] >= hmn_data->attr.normal_landing_lag))))
        {
            event_data->hud.is_actionable = 1;
            event_data->hud.actionable_frame = event_data->hud.timer;

            // destroy any tips
            event_vars->Tip_Destroy();

            // update bar colors
            JOBJ *timingbar_jobj;
            JOBJ_GetChild(hud_jobj, &timingbar_jobj, LCLJOBJ_BAR, -1); // get timing bar jobj
            DOBJ *d = timingbar_jobj->dobj;
            int count = 0;
            while (d != 0)
            {
                // if a box dobj
                if ((count >= 0) && (count < 30))
                {

                    // if mobj exists (it will)
                    MOBJ *m = d->mobj;
                    if (m != 0)
                    {

                        HSD_Material *mat = m->mat;
                        int this_frame = 29 - count;
                        GXColor *bar_color;

                        // check if GALINT frame
                        if ((this_frame >= curr_frame) && ((this_frame <= (curr_frame + hmn_data->hurtstatus.ledge_intang_left))))
                            bar_color = &tmgbar_blue;
                        else
                            bar_color = tmgbar_colors[event_data->hud.action_log[this_frame]];

                        mat->diffuse = *bar_color;
                    }
                }

                // inc
                count++;
                d = d->next;
            }

            // output remaining airdodge angle
            if (event_data->hud.is_airdodge == 1)
                Text_SetText(event_data->hud.text_angle, 0, "%.2f", fabs(event_data->hud.airdodge_angle / M_1DEGREE));
            else
                Text_SetText(event_data->hud.text_angle, 0, "-");

            // output remaining GALINT
            void *matanim;
            Text *text_galint = event_data->hud.text_galint;
            if (hmn_data->hurtstatus.ledge_intang_left > 0)
            {
                SFX_Play(303);
                matanim = event_data->assets->hudmatanim[0];
                Text_SetText(text_galint, 0, "%df", hmn_data->hurtstatus.ledge_intang_left);
            }
            else if (hmn_data->TM.vuln_frames < 25)
            {
                matanim = event_data->assets->hudmatanim[1];
                Text_SetText(text_galint, 0, "-%df", hmn_data->TM.vuln_frames);
            }
            else
            {
                matanim = event_data->assets->hudmatanim[1];
                Text_SetText(text_galint, 0, "-");
            }

            // init hitbox num
            LdshHitlogData *hitlog_data = event_data->hitlog_gobj->userdata;
            hitlog_data->num = 0;

            // apply HUD animation
            JOBJ_RemoveAnimAll(hud_jobj);
            JOBJ_AddAnimAll(hud_jobj, 0, matanim, 0);
            JOBJ_ReqAnimAll(hud_jobj, 0);
        }
    }

    // update HUD anim
    JOBJ_AnimAll(hud_jobj);

    return;
}
void Ledgedash_HUDCamThink(GOBJ *gobj)
{

    // if HUD enabled and not paused
    if ((LdshOptions_Main[2].option_val == 0) && (Pause_CheckStatus(1) != 2))
    {
        CObjThink_Common(gobj);
    }

    return;
}
void Ledgedash_ResetThink(LedgedashData *event_data, GOBJ *hmn)
{

    FighterData *hmn_data = hmn->userdata;
    JOBJ *hud_jobj = event_data->hud.gobj->hsd_object;

    // check if enabled and ledge exists
    if ((LdshOptions_Main[1].option_val == 0) && (event_data->ledge_line != -1))
    {

        // check if reset timer is set
        if (event_data->reset_timer > 0)
        {
            // decrement reset timer
            event_data->reset_timer--;

            // if reset timer is up, go back to ledge
            if (event_data->reset_timer == 0)
            {
                Fighter_PlaceOnLedge(event_data, hmn, event_data->ledge_line, (float)event_data->ledge_dir);
            }
        }
        // check to set reset timner
        else if (event_data->hud.is_actionable)
        {
            event_data->reset_timer = 30;
        }
        else
        {
            int state = hmn_data->state;

            // reset actions
            if ((hmn_data->flags.dead == 1) ||                                              // if dead
                ((hmn_data->state == ASID_ESCAPEAIR) && (hmn_data->TM.state_frame >= 9)) || // missed airdodge
                ((((state >= ASID_CLIFFCLIMBSLOW) && (state <= ASID_CLIFFJUMPQUICK2)) ||    // reset if any other ledge action
                  ((state >= ASID_ATTACKAIRN) && (state <= ASID_ATTACKAIRLW)) ||
                  ((hmn_data->phys.air_state == 0) && ((state != ASID_LANDING) && (state != ASID_LANDINGFALLSPECIAL) && (state != ASID_REBIRTHWAIT)))) && // reset if grounded non landing
                 (hmn_data->TM.state_frame >= 7)))
            {
                // reset and play sfx
                Fighter_PlaceOnLedge(event_data, hmn, event_data->ledge_line, (float)event_data->ledge_dir);
                SFX_PlayCommon(3);
            }
        }
    }

    return;
}
void Ledgedash_InitVariables(LedgedashData *event_data)
{
    event_data->hud.timer = 0;
    event_data->tip.is_input_release = 0;
    event_data->tip.is_input_jump = 0;
    event_data->tip.refresh_displayed = 0;
    event_data->hud.is_release = 0;
    event_data->hud.is_jump = 0;
    event_data->hud.is_airdodge = 0;
    event_data->hud.is_aerial = 0;
    event_data->hud.is_land = 0;
    event_data->hud.is_actionable = 0;

    // init action log
    for (int i = 0; i < sizeof(event_data->hud.action_log) / sizeof(u8); i++)
    {
        event_data->hud.action_log[i] = 0;
    }
}

// Menu Toggle functions
void Ledgedash_ToggleStartPosition(GOBJ *menu_gobj, int value)
{

    // get fighter data
    GOBJ *hmn = Fighter_GetGObj(0);
    LedgedashData *event_data = event_vars->event_gobj->userdata;

    Fighter_PlaceOnLedge(event_data, hmn, event_data->ledge_line, (float)event_data->ledge_dir);

    return;
}
void Ledgedash_ToggleAutoReset(GOBJ *menu_gobj, int value)
{

    LedgedashData *event_data = event_vars->event_gobj->userdata;

    // enable camera
    if (value == 0)
        event_data->cam->kind = 0;
    // disable camera
    else
        event_data->cam->kind = 1;

    return;
}

// Hitlog functions
GOBJ *Ledgedash_HitLogInit()
{

    GOBJ *hit_gobj = GObj_Create(0, 0, 0);
    LdshHitlogData *hit_data = calloc(sizeof(LdshHitlogData));
    GObj_AddUserData(hit_gobj, 4, HSD_Free, hit_data);
    GObj_AddGXLink(hit_gobj, Ledgedash_HitLogGX, 5, 0);

    // init array
    hit_data->num = 0;

    return hit_gobj;
}
void Ledgedash_HitLogThink(LedgedashData *event_data, GOBJ *hmn)
{
    FighterData *hmn_data = hmn->userdata;
    LdshHitlogData *hitlog_data = event_data->hitlog_gobj->userdata;

    // log hitboxes
    if ((event_data->hud.is_actionable == 1) && (hmn_data->hurtstatus.ledge_intang_left > 0))
    {

        // iterate through fighter hitboxes
        for (int i = 0; i < sizeof(hmn_data->hitbox) / sizeof(ftHit); i++)
        {

            ftHit *this_hit = &hmn_data->hitbox[i];

            if ((this_hit->active != 0) &&           // if hitbox is active
                (hitlog_data->num < LDSH_HITBOXNUM)) // if not over max
            {

                // log info
                LdshHitboxData *this_ldsh_hit = &hitlog_data->hitlog[hitlog_data->num];
                this_ldsh_hit->size = this_hit->size;
                this_ldsh_hit->pos_curr = this_hit->pos;
                this_ldsh_hit->pos_prev = this_hit->pos_prev;
                this_ldsh_hit->kind = this_hit->attribute;

                // increment hitboxes
                hitlog_data->num++;
            }
        }

        // iterate through items belonging to fighter
        GOBJList *gobj_list = *stc_gobj_list;
        GOBJ *this_item = gobj_list->item;
        while (this_item != 0)
        {
            ItemData *this_itemdata = this_item->userdata;

            // ensure belongs to the fighter
            if (this_itemdata->fighter == hmn)
            {
                // iterate through item hitboxes
                for (int i = 0; i < sizeof(hmn_data->hitbox) / sizeof(ftHit); i++)
                {

                    itHit *this_hit = &this_itemdata->hitbox[i];

                    if ((this_hit->active != 0) &&           // if hitbox is active
                        (hitlog_data->num < LDSH_HITBOXNUM)) // if not over max
                    {

                        // log info
                        LdshHitboxData *this_ldsh_hit = &hitlog_data->hitlog[hitlog_data->num];
                        this_ldsh_hit->size = this_hit->size;
                        this_ldsh_hit->pos_curr = this_hit->pos;
                        this_ldsh_hit->pos_prev = this_hit->pos_prev;
                        this_ldsh_hit->kind = this_hit->attribute;

                        // increment hitboxes
                        hitlog_data->num++;
                    }
                }
            }

            this_item = this_item->next;
        }
    }

    return;
}
void Ledgedash_HitLogGX(GOBJ *gobj, int pass)
{

    static GXColor hitlog_ambient = {128, 0, 0, 50};
    static GXColor hit_diffuse = {255, 99, 99, 50};
    static GXColor grab_diffuse = {255, 0, 255, 50};
    static GXColor detect_diffuse = {255, 255, 255, 50};

    LdshHitlogData *hitlog_data = gobj->userdata;

    for (int i = 0; i < hitlog_data->num; i++)
    {
        LdshHitboxData *this_ldsh_hit = &hitlog_data->hitlog[i];

        // determine color
        GXColor *diffuse, *ambient;
        if (this_ldsh_hit->kind == 0)
            diffuse = &hit_diffuse;
        else if (this_ldsh_hit->kind == 8)
            diffuse = &grab_diffuse;
        else if (this_ldsh_hit->kind == 11)
            diffuse = &detect_diffuse;
        else
            diffuse = &hit_diffuse;

        Develop_DrawSphere(this_ldsh_hit->size, &this_ldsh_hit->pos_curr, &this_ldsh_hit->pos_prev, diffuse, &hitlog_ambient);
    }

    return;
}

// Fighter fuctions
void Ledgedash_FtInit(LedgedashData *event_data)
{
    GOBJ *hmn = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn->userdata;

    // create camera box
    CameraBox *cam = CameraBox_Alloc();
    cam->boundleft_proj = -10;
    cam->boundright_proj = 10;
    cam->boundtop_proj = 10;
    cam->boundbottom_proj = -10;
    cam->boundleft_curr = cam->boundleft_proj;
    cam->boundright_curr = cam->boundright_proj;
    cam->boundtop_curr = cam->boundtop_proj;
    cam->boundbottom_curr = cam->boundbottom_proj;
    event_data->cam = cam;

    // search for nearest ledge
    float ledge_dir;
    int line_index = Ledge_Find(0, 0, &ledge_dir);
    if (line_index != -1)
        Fighter_PlaceOnLedge(event_data, hmn, line_index, ledge_dir);
    else
    {
        event_data->cam->flags = 0;
        event_data->ledge_line = -1;
        event_vars->Tip_Display(500 * 60, "Error:\nIt appears there are no \nledges on this stage...");
    }

    return;
}
void Ledgedash_ChangeLedgeThink(LedgedashData *event_data, GOBJ *hmn)
{
    FighterData *hmn_data = hmn->userdata;

    if (hmn_data->input.down & (HSD_BUTTON_DPAD_LEFT | HSD_BUTTON_DPAD_RIGHT))
    {

        // get current ledge position
        CollVert *collvert = *stc_collvert;
        CollLine *collline = *stc_collline;
        CollVert *this_vert;
        CollLine *this_line = &collline[event_data->ledge_line];
        float ledge_pos;
        if (event_data->ledge_dir == -1)
            ledge_pos = collvert[this_line->info->vert_next].pos_curr.X;
        else if (event_data->ledge_dir == 1)
            ledge_pos = collvert[this_line->info->vert_prev].pos_curr.X;

        // find ledge
        float ledge_dir;
        int line_index = -1;
        if (hmn_data->input.down & HSD_BUTTON_DPAD_LEFT)
            line_index = Ledge_Find(-1, ledge_pos, &ledge_dir);
        else if (hmn_data->input.down & HSD_BUTTON_DPAD_RIGHT)
            line_index = Ledge_Find(1, ledge_pos, &ledge_dir);

        if (line_index != -1)
            Fighter_PlaceOnLedge(event_data, hmn, line_index, ledge_dir);
        else
            Fighter_PlaceOnLedge(event_data, hmn, event_data->ledge_line, (float)event_data->ledge_dir);
    }

    return;
}
int Ledge_Find(int search_dir, float xpos_start, float *ledge_dir)
{

    // get line and vert pointers
    CollLine *collline = *stc_collline;
    CollVert *collvert = *stc_collvert;
    CollDataStage *coll_data = *stc_colldata;

    // get initial closest
    float xpos_closest;
    if (search_dir == -1) // search left
        xpos_closest = -5000;
    else if (search_dir == 1) // search right
        xpos_closest = 5000;
    else // search both
        xpos_closest = 5000;

    // look for the closest ledge
    CollLine *line_closest = 0;
    int index_closest = -1;
    int group_index = 0;                  // first ground link
    int group_num = coll_data->group_num; // ground link num
    CollGroup *this_group = *stc_firstcollgroup;
    while (this_group != 0) // loop through ground links
    {

        // 2 passes, one for ground and one for dynamic lines
        int line_index, line_num;
        for (int i = 0; i < 2; i++)
        {
            // first pass, use floors
            if (i == 0)
            {
                line_index = this_group->desc->floor_start;          // first ground link
                line_num = line_index + this_group->desc->floor_num; // ground link num
            }
            // second pass, use dynamics
            else if (i == 1)
            {
                line_index = this_group->desc->dyn_start;          // first ground link
                line_num = line_index + this_group->desc->dyn_num; // ground link num
            }

            // loop through lines
            while (line_index < line_num)
            {
                // get all data for this line
                CollLine *this_line = &collline[line_index]; // ??? i actually dont know why i cant access this directly
                CollLineInfo *this_lineinfo = this_line->info;

                // check if this link is a ledge
                if (this_lineinfo->is_ledge)
                {

                    // check both sides of this ledge
                    Vec3 ledge_pos;
                    for (int j = 0; j < 2; j++)
                    {
                        // first pass, check left
                        if (j == 0)
                        {
                            GrColl_GetLedgeLeft2(line_index, &ledge_pos);
                        }
                        else if (j == 1)
                        {
                            GrColl_GetLedgeRight2(line_index, &ledge_pos);
                        }

                        // is within the camera range
                        if ((ledge_pos.X > Stage_GetCameraLeft()) && (ledge_pos.X < Stage_GetCameraRight()) && (ledge_pos.Y > Stage_GetCameraBottom()) && (ledge_pos.Y < Stage_GetCameraTop()))
                        {

                            // check for any obstructions
                            float dir_mult;
                            if (j == 0) // left ledge
                                dir_mult = -1;
                            else if (j == 1) // right ledge
                                dir_mult = 1;
                            int ray_index;
                            int ray_kind;
                            Vec2 ray_angle;
                            Vec3 ray_pos;
                            float from_x = ledge_pos.X + (2 * dir_mult);
                            float to_x = from_x;
                            float from_y = ledge_pos.Y + 5;
                            float to_y = from_y - 10;
                            int is_ground = GrColl_RaycastGround(&ray_pos, &ray_index, &ray_kind, &ray_angle, -1, -1, -1, 0, from_x, from_y, to_x, to_y, 0);
                            if (is_ground == 0)
                            {
                                int is_closer = 0;

                                if (search_dir == -1) // check if to the left
                                {
                                    if ((ledge_pos.X > xpos_closest) && (ledge_pos.X < xpos_start))
                                        is_closer = 1;
                                }
                                else if (search_dir == 1) // check if to the right
                                {
                                    if ((ledge_pos.X < xpos_closest) && (ledge_pos.X > xpos_start))
                                        is_closer = 1;
                                }
                                else // check if any direction
                                {
                                    float dist_old = fabs(xpos_start - xpos_closest);
                                    float dist_new = fabs(xpos_start - ledge_pos.X);
                                    if (dist_new < dist_old)
                                        is_closer = 1;
                                }

                                // determine direction
                                if (is_closer)
                                {

                                    // now determine if this line is a ledge in this direction
                                    if (j == 0) // left ledge
                                    {
                                        CollLine *prev_line = &collline[this_lineinfo->line_prev];          // ??? i actually dont know why i cant access this directly
                                        if ((this_lineinfo->line_prev == -1) || (prev_line->is_rwall == 1)) // if prev line is a right wall / if prev line doesnt exist
                                        {

                                            // save info on this line
                                            xpos_closest = ledge_pos.X; // save left vert's X position
                                            line_closest = this_line;
                                            index_closest = line_index;
                                            *ledge_dir = 1;
                                        }
                                    }
                                    else if (j == 1) // right ledge
                                    {
                                        CollLine *next_line = &collline[this_lineinfo->line_next];          // ??? i actually dont know why i cant access this directly
                                        if ((this_lineinfo->line_prev == -1) || (next_line->is_lwall == 1)) // if prev line is a right wall / if prev line doesnt exist
                                        {

                                            // save info on this line
                                            xpos_closest = ledge_pos.X; // save left vert's X position
                                            line_closest = this_line;
                                            index_closest = line_index;
                                            *ledge_dir = -1;
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                line_index++;
            }
        }

        // get next
        this_group = this_group->next;
    }

    return index_closest;
}
void Fighter_PlaceOnLedge(LedgedashData *event_data, GOBJ *hmn, int line_index, float ledge_dir)
{
    FighterData *hmn_data = hmn->userdata;

    // save ledge info
    event_data->ledge_line = line_index;
    event_data->ledge_dir = ledge_dir;

    // get ledge position
    Vec3 ledge_pos;
    if (ledge_dir > 0)
        GrColl_GetLedgeLeft2(line_index, &ledge_pos);
    else
        GrColl_GetLedgeRight2(line_index, &ledge_pos);

    // remove velocity
    hmn_data->phys.self_vel.X = 0;
    hmn_data->phys.self_vel.Y = 0;

    // restore tether
    hmn_data->flags.used_tether = 0;

    // check if starting on ledge
    if (LdshMenu_Main.options[0].option_val == 0)
    {

        // init refresh num
        event_data->tip.refresh_num = -1; // setting this to -1 because the per frame code will add 1 and make it 0

        // Sleep first
        Fighter_EnterSleep(hmn, 0);
        Fighter_EnterRebirth(hmn);

        // place player on this ledge
        FtCliffCatch *ft_state = &hmn_data->state_var;
        hmn_data->facing_direction = ledge_dir;
        ft_state->ledge_index = line_index; // store line index
        Fighter_EnterCliffWait(hmn);
        ft_state->timer = 0; // spoof as on ledge for a frame already
        Fighter_LoseGroundJump(hmn_data);
        Fighter_EnableCollUpdate(hmn_data);
        Coll_CheckLedge(&hmn_data->coll_data);
        Fighter_MoveToCliff(hmn);
        Fighter_UpdatePosition(hmn);
        hmn_data->phys.self_vel.X = 0;
        hmn_data->phys.self_vel.Y = 0;
        ftCommonData *ftcommon = *stc_ftcommon;
        Fighter_ApplyIntang(hmn, ftcommon->cliff_invuln_time);
    }
    else
    {

        // init refresh num
        event_data->tip.refresh_num = 0; // setting this to -1 because the per frame code will add 1 and make it 0

        // place player in a random position in respawn wait
        Fighter_EnterSleep(hmn, 0);
        Fighter_EnterRebirth(hmn);
        hmn_data->facing_direction = ledge_dir;

        // get random position
        float xpos_min = 40;
        float xpos_max = 65;
        float ypos_min = -30;
        float ypos_max = 30;
        hmn_data->phys.pos.X = ((ledge_dir * -1) * (xpos_min + HSD_Randi(xpos_max - xpos_min) + HSD_Randf())) + (ledge_pos.X);
        hmn_data->phys.pos.Y = ((ledge_dir * -1) * (ypos_min + HSD_Randi(ypos_max - ypos_min) + HSD_Randf())) + (ledge_pos.Y);

        // enter rebirth
        Fighter_EnterRebirthWait(hmn);
        hmn_data->cb.Phys = RebirthWait_Phys;
        hmn_data->cb.IASA = RebirthWait_IASA;

        Fighter_UpdateRebirthPlatformPos(hmn);

        Ledgedash_InitVariables(event_data);
    }

    // update camera box
    CameraBox *cam = event_data->cam;
    cam->cam_pos.X = ledge_pos.X + (ledge_dir * 20);
    cam->cam_pos.Y = ledge_pos.Y + 15;

    Fighter_UpdateCamera(hmn);

    // remove all particles
    for (int i = 0; i < PTCL_LINKMAX; i++)
    {
        Particle2 **ptcls = &stc_ptcl[i];
        Particle2 *ptcl = *ptcls;
        while (ptcl != 0)
        {

            Particle2 *ptcl_next = ptcl->next;

            // begin destroying this particle

            // subtract some value, 8039c9f0
            if (ptcl->x88 != 0)
            {
                int *arr = ptcl->x88;
                arr[0x50 / 4]--;
            }
            // remove from generator? 8039ca14
            if (ptcl->gen != 0)
                psRemoveParticleAppSRT(ptcl);

            // delete parent jobj, 8039ca48
            psDeletePntJObjwithParticle(ptcl);

            // update most recent ptcl pointer
            *ptcls = ptcl->next;

            // free alloc, 8039ca54
            HSD_ObjFree(0x804d0f60, ptcl);

            // decrement ptcl total
            u16 ptclnum = *stc_ptclnum;
            ptclnum--;
            *stc_ptclnum = ptclnum;

            // get next
            ptcl = ptcl_next;
        }
    }

    /*
    // remove all generators with linkNo 2 (blastzone)
    ptclGen *gen = *stc_ptclgen;
    while (gen != 0)
    {
        // get next
        ptclGen *gen_next = gen->next;

        // if linkNo 2, destroy it
        if (gen->link_no == 2)
        {
            // set a flag for some reason
            gen->type |= 0x80;

            // kill gen
            gen = psKillGenerator(gen, *stc_ptclgencurr);
        }

        // save last
        *stc_ptclgencurr = gen;
        // get next
        gen = gen_next;
    }
*/
    // remove all camera shake gobjs (p_link 18, entity_class 3)
    GOBJList *gobj_list = *stc_gobj_list;
    GOBJ *gobj = gobj_list->match_cam;
    while (gobj != 0)
    {

        GOBJ *gobj_next = gobj->next;

        // if entity class 3 (quake)
        if (gobj->entity_class == 3)
        {
            GObj_Destroy(gobj);
        }

        gobj = gobj_next;
    }

    return;
}
void Fighter_UpdatePosition(GOBJ *fighter)
{

    FighterData *fighter_data = fighter->userdata;

    // Update Position (Copy Physics XYZ into all ECB XYZ)
    fighter_data->coll_data.topN_Curr.X = fighter_data->phys.pos.X;
    fighter_data->coll_data.topN_Curr.Y = fighter_data->phys.pos.Y;
    fighter_data->coll_data.topN_Prev.X = fighter_data->phys.pos.X;
    fighter_data->coll_data.topN_Prev.Y = fighter_data->phys.pos.Y;
    fighter_data->coll_data.topN_CurrCorrect.X = fighter_data->phys.pos.X;
    fighter_data->coll_data.topN_CurrCorrect.Y = fighter_data->phys.pos.Y;
    fighter_data->coll_data.topN_Proj.X = fighter_data->phys.pos.X;
    fighter_data->coll_data.topN_Proj.Y = fighter_data->phys.pos.Y;

    // Update Collision Frame ID
    fighter_data->coll_data.coll_test = *stc_colltest;

    // Adjust JObj position (code copied from 8006c324)
    JOBJ *fighter_jobj = fighter->hsd_object;
    fighter_jobj->trans.X = fighter_data->phys.pos.X;
    fighter_jobj->trans.Y = fighter_data->phys.pos.Y;
    fighter_jobj->trans.Z = fighter_data->phys.pos.Z;
    JOBJ_SetMtxDirtySub(fighter_jobj);

    // Update Static Player Block Coords
    Fighter_SetPosition(fighter_data->ply, fighter_data->flags.ms, &fighter_data->phys.pos);
    return;
}
void Fighter_UpdateCamera(GOBJ *fighter)
{
    FighterData *fighter_data = fighter->userdata;

    // Update camerabox pos
    Fighter_UpdateCameraBox(fighter);

    // Update tween
    fighter_data->cameraBox->boundleft_curr = fighter_data->cameraBox->boundleft_proj;
    fighter_data->cameraBox->boundright_curr = fighter_data->cameraBox->boundright_proj;

    // update camera position
    Match_CorrectCamera();

    // reset onscreen bool
    //Fighter_UpdateOnscreenBool(fighter);
    fighter_data->flags.is_offscreen = 0;
}
void RebirthWait_Phys(GOBJ *fighter)
{

    FighterData *fighter_data = fighter->userdata;

    // infinite time
    fighter_data->state_var.stateVar1 = 2;

    return;
}
int RebirthWait_IASA(GOBJ *fighter)
{

    FighterData *fighter_data = fighter->userdata;

    if (Fighter_IASACheck_JumpAerial(fighter))
    {
    }
    else
    {
        ftCommonData *ftcommon = *stc_ftcommon;

        // check for lstick movement
        float stick_x = fabs(fighter_data->input.lstick_x);
        float stick_y = fighter_data->input.lstick_y;
        if ((stick_x > 0.2875) && (fighter_data->input.timer_lstick_tilt_x < 2) ||
            (stick_y < (ftcommon->lstick_rebirthfall * -1)) && (fighter_data->input.timer_lstick_tilt_y < 4))
        {
            Fighter_EnterFall(fighter);
            return 1;
        }
    }

    return 0;
}
int Fighter_CheckFall(FighterData *hmn_data)
{

    int is_fall = 0;

    // look for Fall input
    float stick_x = fabs(hmn_data->input.lstick_x);
    float stick_y = hmn_data->input.lstick_y;
    if ((stick_x >= 0.2875) && (hmn_data->input.timer_lstick_tilt_x < 2) ||
        (stick_y <= -0.2875) && (hmn_data->input.timer_lstick_tilt_y < 2))
    {
        is_fall = 1;
    }

    return is_fall;
}

// Tips Functions
void Tips_Toggle(GOBJ *menu_gobj, int value)
{
    // destroy existing tips when disabling
    if (value == 1)
        event_vars->Tip_Destroy();

    return;
}
void Tips_Think(LedgedashData *event_data, FighterData *hmn_data)
{

    if (LdshOptions_Main[3].option_val == 0)
    {

        // check for early fall input in cliffcatch
        if ((event_data->tip.is_input_release == 0) && (hmn_data->state == ASID_CLIFFCATCH) && (Fighter_CheckFall(hmn_data) == 1))
        {
            event_data->tip.is_input_release = 1;
            event_vars->Tip_Destroy();

            // determine how many frames early
            float *anim_ptr = Animation_GetAddress(hmn_data, hmn_data->anim_id);
            float frame_total = anim_ptr[0x8 / 4];
            float frames_early = frame_total - hmn_data->stateFrame;
            event_vars->Tip_Display(3 * 60, "Misinput:\nFell %d frames early.", (int)frames_early + 1);
        }

        // check for early fall input on cliffwait frame 0
        if ((event_data->tip.is_input_release == 0) && (hmn_data->state == ASID_CLIFFWAIT) && (hmn_data->TM.state_frame == 1) && (Fighter_CheckFall(hmn_data) == 1))
        {
            event_data->tip.is_input_release = 1;
            event_vars->Tip_Destroy();
            event_vars->Tip_Display(LSDH_TIPDURATION, "Misinput:\nFell 1 frame early.");
        }

        // check for late fall input
        if ((event_data->tip.is_input_release == 0) && (hmn_data->state == ASID_CLIFFJUMPQUICK1) && (Fighter_CheckFall(hmn_data) == 1))
        {
            event_data->tip.is_input_release = 1;
            event_vars->Tip_Destroy();

            // jumped and fell on same frame
            if (hmn_data->TM.state_frame == 0)
                event_vars->Tip_Display(LSDH_TIPDURATION, "Misinput:\nInputted jump and fall \non the same frame.");

            // fell late
            else
                event_vars->Tip_Display(LSDH_TIPDURATION, "Misinput:\nJumped %d frame(s) early.", hmn_data->TM.state_frame);
        }

        // check for ledgedash without refreshing
        if ((event_data->tip.refresh_displayed == 0) && (event_data->hud.is_actionable == 1) && (event_data->tip.refresh_num == 0))
        {

            event_data->tip.refresh_displayed = 1;

            // increment condition count
            event_data->tip.refresh_cond_num++;

            // after 3 conditions, display tip
            if (event_data->tip.refresh_cond_num >= 3)
            {
                // if tip is displayed, reset cond num
                if (event_vars->Tip_Display(5 * 60, "Warning:\nIt is higly recommended to\nre-grab ledge after \nbeing reset to simulate \na realistic scenario!"))
                    event_data->tip.refresh_cond_num = 0;
            }
        }
    }
    return;
}

// Initial Menu
static EventMenu *Event_Menu = &LdshMenu_Main;