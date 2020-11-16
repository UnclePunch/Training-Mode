#include "lcancel.h"
static char nullString[] = " ";

// Main Menu
static char **LcOptions_Barrel[] = {"Off", "Stationary", "Move"};
static char **LcOptions_HUD[] = {"On", "Off"};
static EventOption LcOptions_Main[] = {
    // Target
    {
        .option_kind = OPTKIND_STRING,             // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(LcOptions_Barrel) / 4, // number of values for this option
        .option_val = 0,                           // value of this option
        .menu = 0,                                 // pointer to the menu that pressing A opens
        .option_name = "Target",                   // pointer to a string
        .desc = "Enable a target to attack.",      // string describing what this option does
        .option_values = LcOptions_Barrel,         // pointer to an array of strings
        .onOptionChange = 0,
    },
    // HUD
    {
        .option_kind = OPTKIND_STRING,           // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(LcOptions_HUD) / 4,  // number of values for this option
        .option_val = 0,                         // value of this option
        .menu = 0,                               // pointer to the menu that pressing A opens
        .option_name = "HUD",                    // pointer to a string
        .desc = "Toggle visibility of the HUD.", // string describing what this option does
        .option_values = LcOptions_HUD,          // pointer to an array of strings
        .onOptionChange = 0,
    },
    // Help
    {
        .option_kind = OPTKIND_FUNC,                                                                                                                                                                             // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                                                                                                                                                                                          // number of values for this option
        .option_val = 0,                                                                                                                                                                                         // value of this option
        .menu = 0,                                                                                                                                                                                               // pointer to the menu that pressing A opens
        .option_name = "Help",                                                                                                                                                                                   // pointer to a string
        .desc = "L-canceling is performed by pressing L, R, or \nZ up to 7 frames before landing from an \naerial attack. This will cut the landing lag in \nhalf, allowing you to act faster after attacking.", // string describing what this option does
        .option_values = 0,                                                                                                                                                                                      // pointer to an array of strings
        .onOptionChange = 0,
    },
    // Exit
    {
        .option_kind = OPTKIND_FUNC,                  // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                               // number of values for this option
        .option_val = 0,                              // value of this option
        .menu = 0,                                    // pointer to the menu that pressing A opens
        .option_name = "Exit",                        // pointer to a string
        .desc = "Return to the Event Select Screen.", // string describing what this option does
        .option_values = 0,                           // pointer to an array of strings
        .onOptionChange = 0,
        .onOptionSelect = Event_Exit,
    },
};
static EventMenu LabMenu_Main = {
    .name = "L-Cancel Training",                                // the name of this menu
    .option_num = sizeof(LcOptions_Main) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                // runtime variable used for how far down in the menu to start
    .state = 0,                                                 // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                // index of the option currently selected, used at runtime
    .options = &LcOptions_Main,                                 // pointer to all of this menu's options
    .prev = 0,                                                  // pointer to previous menu, used at runtime
};

// Init Function
void Event_Init(GOBJ *gobj)
{
    LCancelData *event_data = gobj->userdata;
    EventDesc *event_desc = event_data->event_desc;
    GOBJ *hmn = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn->userdata;
    //GOBJ *cpu = Fighter_GetGObj(1);
    //FighterData *cpu_data = cpu->userdata;

    // theres got to be a better way to do this...
    event_vars = *event_vars_ptr;

    // get l-cancel assets
    event_data->lcancel_assets = File_GetSymbol(event_vars->event_archive, "lclData");

    // create HUD
    LCancel_Init(event_data);

    // set CPU AI to no_act 15
    //cpu_data->cpu.ai = 0;

    return;
}
// Think Function
void Event_Think(GOBJ *event)
{
    LCancelData *event_data = event->userdata;

    // get fighter data
    GOBJ *hmn = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn->userdata;
    //GOBJ *cpu = Fighter_GetGObj(1);
    //FighterData *cpu_data = cpu->userdata;
    HSD_Pad *pad = PadGet(hmn_data->player_controller_number, PADGET_ENGINE);

    /*
    // give intangibility to cpu
    cpu_data->flags.no_reaction_always = 1;
    cpu_data->flags.nudge_disable = 1;
    Fighter_ApplyOverlay(cpu_data, 9, 0);
    Fighter_UpdateOverlay(cpu);
    cpu_data->dmg.percent = 0;
    Fighter_SetHUDDamage(cpu_data->ply, 0);


    // Move CPU
    if (pad->down == PAD_BUTTON_DPAD_DOWN)
    {
        // ensure player is grounded
        int is_ground = 0;
        if (hmn_data->phys.air_state == 0)
        {

            // check for ground in front of player
            Vec3 coll_pos;
            int line_index;
            int line_kind;
            Vec3 line_unk;
            float from_x = (hmn_data->phys.pos.X) + (hmn_data->facing_direction * 16);
            float to_x = from_x;
            float from_y = (hmn_data->phys.pos.Y + 5);
            float to_y = from_y - 10;
            is_ground = Stage_RaycastGround(&coll_pos, &line_index, &line_kind, &line_unk, -1, -1, -1, 0, from_x, from_y, to_x, to_y, 0);
            if (is_ground == 1)
            {

                // do this for every subfighter (thanks for complicated code ice climbers)
                int is_moved = 0;
                for (int i = 0; i < 2; i++)
                {
                    GOBJ *this_fighter = Fighter_GetSubcharGObj(cpu_data->ply, i);

                    if (this_fighter != 0)
                    {

                        FighterData *this_fighter_data = this_fighter->userdata;

                        if ((this_fighter_data->flags.sleep == 0) && (this_fighter_data->flags.dead == 0))
                        {

                            is_moved = 1;

                            // place CPU here
                            this_fighter_data->phys.pos = coll_pos;
                            this_fighter_data->collData.ground_index = line_index;

                            // facing player
                            this_fighter_data->facing_direction = hmn_data->facing_direction * -1;

                            // update camera box
                            Fighter_UpdateCameraBox(this_fighter);
                            this_fighter_data->cameraBox->boundleft_curr = this_fighter_data->cameraBox->boundleft_proj;
                            this_fighter_data->cameraBox->boundright_curr = this_fighter_data->cameraBox->boundright_proj;

                            // set grounded
                            this_fighter_data->phys.air_state = 0;
                            //Fighter_SetGrounded(this_fighter);

                            // kill velocity
                            Fighter_KillAllVelocity(this_fighter);

                            // enter wait
                            Fighter_EnterWait(this_fighter);

                            // update ECB
                            this_fighter_data->collData.topN_Curr = this_fighter_data->phys.pos; // move current ECB location to new position
                            Coll_ECBCurrToPrev(&this_fighter_data->collData);
                            this_fighter_data->cb.Coll(this_fighter);

                            // init CPU logic (for nana's popo position history...)
                            int cpu_kind = Fighter_GetCPUKind(this_fighter_data->ply);
                            int cpu_level = Fighter_GetCPULevel(this_fighter_data->ply);
                            Fighter_CPUInitialize(this_fighter_data, cpu_kind, cpu_level, 0);

                            // place subfighter in the Z axis
                            if (this_fighter_data->flags.ms == 1)
                            {
                                ftCommonData *ft_common = *stc_ftcommon;
                                this_fighter_data->phys.pos.Z = ft_common->ms_zjostle_max * -1;
                            }
                        }
                    }
                }

                if (is_moved == 1)
                {
                    // savestate
                    event_vars->Savestate_Save(event_vars->savestate);
                }
            }
        }

        // play SFX
        if (is_ground == 0)
        {
            SFX_PlayCommon(3);
        }
        else
        {
            SFX_Play(221);
        }
    }
    */

    LCancel_Think(event_data, hmn_data);
    Barrel_Think(event_data);

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

// L-Cancel functions
void LCancel_Init(LCancelData *event_data)
{

    // create hud cobj
    GOBJ *hudcam_gobj = GObj_Create(19, 20, 0);
    ArchiveInfo **ifall_archive = 0x804d6d5c;
    COBJDesc ***dmgScnMdls = File_GetSymbol(*ifall_archive, 0x803f94d0);
    COBJDesc *cam_desc = dmgScnMdls[1][0];
    COBJ *hud_cobj = COBJ_LoadDesc(cam_desc);
    // init camera
    GObj_AddObject(hudcam_gobj, R13_U8(-0x3E55), hud_cobj);
    GOBJ_InitCamera(hudcam_gobj, LCancel_HUDCamThink, 8);
    hudcam_gobj->cobj_links = 1 << 18;

    GOBJ *hud_gobj = GObj_Create(0, 0, 0);
    event_data->hud.gobj = hud_gobj;
    // Load jobj
    JOBJ *hud_jobj = JOBJ_LoadJoint(event_data->lcancel_assets->hud);
    GObj_AddObject(hud_gobj, 3, hud_jobj);
    GObj_AddGXLink(hud_gobj, GXLink_Common, 18, 80);

    // create text canvas
    int canvas = Text_CreateCanvas(2, hud_gobj, 14, 15, 0, 18, 81, 19);
    event_data->hud.canvas = canvas;

    // init text
    Text **text_arr = &event_data->hud.text_time;
    for (int i = 0; i < 3; i++)
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
        hud_text->aspect.X = MSGTEXT_BASEWIDTH;

        // text position
        hud_text->trans.X = text_pos.X + (scale->X / 4.0);
        hud_text->trans.Y = (text_pos.Y * -1) + (scale->Y / 4.0);

        // dummy text
        Text_AddSubtext(hud_text, 0, 0, "-");
    }

    return 0;
}
void LCancel_Think(LCancelData *event_data, FighterData *hmn_data)
{

    // run tip logic
    Tips_Think(event_data, hmn_data);

    // if aerial landing
    JOBJ *hud_jobj = event_data->hud.gobj->hsd_object;
    if (((hmn_data->state_id >= ASID_LANDINGAIRN) && (hmn_data->state_id <= ASID_LANDINGAIRLW)) && (hmn_data->TM.state_frame == 0))
    {

        // increment total lcls
        event_data->hud.lcl_total++;

        // determine succession
        int is_fail = 1;
        if (hmn_data->input.timer_trigger_any_ignore_hitlag < 7)
        {
            is_fail = 0;
            event_data->hud.lcl_success++;
        }
        event_data->is_fail = is_fail; // save l-cancel bool

        // Play appropriate sfx
        if (is_fail == 0)
            SFX_PlayRaw(303, 255, 128, 20, 3);
        else
            SFX_PlayCommon(3);

        // Update timing hud
        JOBJ *timingbar_jobj;
        JOBJ_GetChild(hud_jobj, &timingbar_jobj, 5, -1); // get timing bar jobj
        // reset all colors first
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
                    static GXColor tmgbar_green = {128, 255, 128, 255};
                    static GXColor tmgbar_red = {255, 128, 128, 255};

                    // set green
                    if (count < 7)
                        mat->diffuse = tmgbar_green;
                    // set red
                    else if (count >= 7)
                        mat->diffuse = tmgbar_red;
                }
            }

            // inc
            count++;
            d = d->next;
        }

        // update text + frame box
        int frame_box_id;
        if (hmn_data->input.timer_trigger_any_ignore_hitlag >= 30)
        {
            // update text
            Text_SetText(event_data->hud.text_time, 0, "No Press");
            frame_box_id = 29;
        }
        else
        {
            Text_SetText(event_data->hud.text_time, 0, "%df/7f", hmn_data->input.timer_trigger_any_ignore_hitlag + 1);
            frame_box_id = hmn_data->input.timer_trigger_any_ignore_hitlag;
        }

        // set current timing bar
        d = timingbar_jobj->dobj;
        count = 0;
        while (d != 0)
        {

            // if this frames' box
            if (count == frame_box_id)
            {

                // if mobj exists (it will)
                MOBJ *m = d->mobj;
                if (m != 0)
                {

                    HSD_Material *mat = m->mat;

                    // set color
                    static GXColor tmgbar_white = {255, 255, 255, 255};
                    mat->diffuse = tmgbar_white;
                    mat->alpha = 1;
                }

                break;
            }

            // inc
            count++;
            d = d->next;
        }

        // Print airborne frames
        Text_SetText(event_data->hud.text_air, 0, "%df", hmn_data->TM.state_prev_frames[0]);

        // Print succession
        float succession = ((float)event_data->hud.lcl_success / (float)event_data->hud.lcl_total) * 100.0;
        Text_SetText(event_data->hud.text_scs, 0, "%.1f%%", succession);

        // Play HUD anim
        JOBJ_RemoveAnimAll(hud_jobj);
        JOBJ_AddAnimAll(hud_jobj, 0, event_data->lcancel_assets->hudmatanim[is_fail], 0);
        JOBJ_ReqAnimAll(hud_jobj, 0);
    }

    // update HUD anim
    JOBJ_AnimAll(hud_jobj);

    return;
}
void LCancel_HUDCamThink(GOBJ *gobj)
{

    // if HUD enabled and not paused
    if ((LcOptions_Main[1].option_val == 0) && (Pause_CheckStatus(1) != 2))
    {
        CObjThink_Common(gobj);
    }

    return;
}

// Tips Functions
void Tips_Think(LCancelData *event_data, FighterData *hmn_data)
{
    // shield tip
    if (event_data->tip.shield_isdisp == 0) // if not shown
    {

        // update tip conditions
        // look for a freshly buffered guard off
        if (((hmn_data->state_id == ASID_GUARDOFF) && (hmn_data->TM.state_frame == 0)) &&                            // currently in guardoff first frame
            (hmn_data->TM.state_prev[0] == ASID_GUARD) &&                                                            // was just in wait
            ((hmn_data->TM.state_prev[3] >= ASID_LANDINGAIRN) && (hmn_data->TM.state_prev[3] <= ASID_LANDINGAIRLW))) // was in aerial landing a few frames ago
        {
            // increment condition count
            event_data->tip.shield_num++;

            // if condition met X times, show tip
            if (event_data->tip.shield_num >= 3)
            {
                // display tip
                char *shield_string = "Tip:\nDon't hold the trigger! Quickly \npress and release to prevent \nshielding after landing.";
                if (Tips_Create(event_data, 5 * 60, shield_string))
                {
                    // set as shown
                    //event_data->tip.shield_isdisp = 1;
                    event_data->tip.shield_num = 0;
                }
            }
        }
    }

    // hitbox tip
    if (event_data->tip.hitbox_isdisp == 0) // if not shown
    {
        // update hitbox active bool
        if ((hmn_data->state_id >= ASID_ATTACKAIRN) && (hmn_data->state_id <= ASID_ATTACKAIRLW)) // check if currently in aerial attack)                                                      // check if in first frame of aerial attack
        {

            // reset hitbox bool on first frame of aerial attack
            if (hmn_data->TM.state_frame == 0)
                event_data->tip.hitbox_active = 0;

            // check if hitbox active
            for (int i = 0; i < (sizeof(hmn_data->hitbox) / sizeof(ftHit)); i++)
            {
                if (hmn_data->hitbox[i].active != 0)
                {
                    event_data->tip.hitbox_active = 1;
                    break;
                }
            }
        }

        // update tip conditions
        if ((hmn_data->state_id >= ASID_LANDINGAIRN) && (hmn_data->state_id <= ASID_LANDINGAIRLW) && (hmn_data->TM.state_frame == 0) && // is in aerial landing
            (event_data->is_fail == 0) &&
            (event_data->tip.hitbox_active == 0)) // succeeded the last aerial landing
        {
            // increment condition count
            event_data->tip.hitbox_num++;

            // if condition met X times, show tip
            if (event_data->tip.hitbox_num >= 3)
            {
                // display tip
                char *hitbox_string = "Tip:\nDon't land too quickly! Make \nsure you land after the attack \nbecomes active.";
                if (Tips_Create(event_data, 5 * 60, hitbox_string))
                {

                    // set as shown
                    //event_data->tip.hitbox_isdisp = 1;
                    event_data->tip.hitbox_num = 0;
                }
            }
        }
    }

    // fastfall tip
    if (event_data->tip.fastfall_isdisp == 0) // if not shown
    {
        // update fastfell bool
        if ((hmn_data->state_id >= ASID_ATTACKAIRN) && (hmn_data->state_id <= ASID_ATTACKAIRLW)) // check if currently in aerial attack)                                                      // check if in first frame of aerial attack
        {

            // reset hitbox bool on first frame of aerial attack
            if (hmn_data->TM.state_frame == 0)
                event_data->tip.fastfall_active = 0;

            // check if fastfalling
            if (hmn_data->flags.is_fastfall == 1)
                event_data->tip.fastfall_active = 1;
        }

        // update tip conditions
        if ((hmn_data->state_id >= ASID_LANDINGAIRN) && (hmn_data->state_id <= ASID_LANDINGAIRLW) && (hmn_data->TM.state_frame == 0) && // is in aerial landing
            ((hmn_data->input.timer_trigger_any > 7) && (hmn_data->input.timer_trigger_any <= 30)) &&                                   // was early for an l-cancel
            (event_data->tip.fastfall_active == 0))                                                                                     // succeeded the last aerial landing
        {
            // increment condition count
            event_data->tip.fastfall_num++;

            // if condition met X times, show tip
            if (event_data->tip.fastfall_num >= 3)
            {
                // display tip
                char *fastfall_string = "Tip:\nDon't forget to fastfall!\nIt will let you act sooner \nand help with your \ntiming.";
                if (Tips_Create(event_data, 5 * 60, fastfall_string))
                {

                    // set as shown
                    //event_data->tip.hitbox_isdisp = 1;
                    event_data->tip.fastfall_num = 0;
                }
            }
        }
    }

    // late tip
    if (event_data->tip.late_isdisp == 0) // if not shown
    {

        // update tip conditions
        if ((hmn_data->state_id >= ASID_LANDINGAIRN) && (hmn_data->state_id <= ASID_LANDINGAIRLW) && // is in aerial landing
            (event_data->is_fail == 1) &&                                                            // failed the l-cancel
            (hmn_data->input.down & (HSD_TRIGGER_L | HSD_TRIGGER_R | HSD_TRIGGER_Z)))                // was late for an l-cancel by pressing it just now
        {
            // increment condition count
            event_data->tip.late_num++;

            // if condition met X times, show tip
            if (event_data->tip.late_num >= 3)
            {
                // display tip
                char *late_string = "Tip:\nTry pressing the trigger a\nbit earlier, before the\nfighter lands.";
                if (Tips_Create(event_data, 5 * 60, late_string))
                {

                    // set as shown
                    //event_data->tip.hitbox_isdisp = 1;
                    event_data->tip.late_num = 0;
                }
            }
        }
    }

    // update tip
    GOBJ *tip_gobj = event_data->tip.gobj;

    if (tip_gobj != 0)
    {

        // update anim
        JOBJ_AnimAll(tip_gobj->hsd_object);

        // update text position
        JOBJ *tip_jobj;
        Vec3 tip_pos;
        JOBJ_GetChild(tip_gobj->hsd_object, &tip_jobj, 6, -1);
        JOBJ_GetWorldPosition(tip_jobj, 0, &tip_pos);
        Text *tip_text = event_data->tip.text;
        tip_text->trans.X = tip_pos.X + (0 * (tip_jobj->scale.X / 4.0));
        tip_text->trans.Y = (tip_pos.Y * -1) + (0 * (tip_jobj->scale.Y / 4.0));

        // state logic
        switch (event_data->tip.state)
        {
        case (0): // in
        {
            // if anim is done, enter wait
            if (JOBJ_CheckAObjEnd(tip_gobj->hsd_object) == 0)
                event_data->tip.state = 1; // enter wait

            break;
        }
        case (1): // wait
        {
            // sub timer
            event_data->tip.lifetime--;
            if (event_data->tip.lifetime <= 0)
            {
                // apply exit anim
                JOBJ *tip_root = tip_gobj->hsd_object;
                JOBJ_RemoveAnimAll(tip_root);
                JOBJ_AddAnimAll(tip_root, event_data->lcancel_assets->tip_jointanim[1], 0, 0);
                JOBJ_ReqAnimAll(tip_root, 0);

                event_data->tip.state = 2; // enter wait
            }

            break;
        }
        case (2): // out
        {
            // if anim is done, destroy
            if (JOBJ_CheckAObjEnd(tip_gobj->hsd_object) == 0)
            {
                // remove text
                Text_Destroy(event_data->tip.text);
                GObj_Destroy(event_data->tip.gobj);
                event_data->tip.gobj = 0;
            }
        }

        break;
        }
    }

    return;
}
int Tips_Create(LCancelData *event_data, int lifetime, char *fmt, ...)
{

#define TIP_TXTSIZEX 0.9
#define TIP_TXTSIZEY 1.1
#define TIP_TXTASPECT 410
#define TIP_LINEMAX 5
#define TIP_CHARMAX 32

    va_list args;

    // check if tip exists, return 0
    if (event_data->tip.gobj != 0)
        return 0;

    // Create bg
    GOBJ *tip_gobj = GObj_Create(0, 0, 0);
    event_data->tip.gobj = tip_gobj;
    GObj_AddGXLink(tip_gobj, GXLink_Common, 18, 80);
    JOBJ *tip_jobj = JOBJ_LoadJoint(event_data->lcancel_assets->tip_jobj);
    GObj_AddObject(tip_gobj, R13_U8(-0x3E55), tip_jobj);

    // Create text object
    Text *tip_text = Text_CreateText(2, event_data->hud.canvas);
    event_data->tip.text = tip_text;
    event_data->tip.lifetime = lifetime;
    event_data->tip.state = 0;
    tip_text->kerning = 1;
    tip_text->align = 0;
    tip_text->use_aspect = 1;

    // adjust text scale
    Vec3 scale = tip_jobj->scale;
    // background scale
    tip_jobj->scale = scale;
    // text scale
    tip_text->scale.X = (scale.X * 0.01) * TIP_TXTSIZEX;
    tip_text->scale.Y = (scale.Y * 0.01) * TIP_TXTSIZEY;
    tip_text->aspect.X = (TIP_TXTASPECT / TIP_TXTSIZEX);

    // apply exit anim
    JOBJ_RemoveAnimAll(tip_jobj);
    JOBJ_AddAnimAll(tip_jobj, event_data->lcancel_assets->tip_jointanim[0], 0, 0);
    JOBJ_ReqAnimAll(tip_jobj, 0);

    // build string
    char buffer[(TIP_LINEMAX * TIP_CHARMAX) + 1];
    va_start(args, fmt);
    vsprintf(buffer, fmt, args);
    va_end(args);
    char *msg = &buffer;

    // count newlines
    int line_num = 1;
    int line_length_arr[TIP_LINEMAX];
    char *msg_cursor_prev, *msg_cursor_curr; // declare char pointers
    msg_cursor_prev = msg;
    msg_cursor_curr = strchr(msg_cursor_prev, '\n'); // check for occurrence
    while (msg_cursor_curr != 0)                     // if occurrence found, increment values
    {
        // check if exceeds max lines
        if (line_num >= TIP_LINEMAX)
            assert("TIP_LINEMAX exceeded!");

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
        if (line_length > TIP_CHARMAX)
            assert("TIP_CHARMAX exceeded!");

        // copy char array
        char msg_line[TIP_CHARMAX + 1];
        memcpy(msg_line, msg, line_length);

        // add null terminator
        msg_line[line_length] = '\0';

        // increment msg
        msg += (line_length + 1); // +1 to skip past newline

        // print line
        int y_base = (line_num - 1) * ((-1 * MSGTEXT_YOFFSET) / 2);
        int y_delta = (i * MSGTEXT_YOFFSET);
        Text_AddSubtext(tip_text, 0, y_base + y_delta, msg_line);
    }

    return 1; // tip created
}

// Barrel Functions
void Barrel_Think(LCancelData *event_data)
{
    GOBJ *barrel_gobj = event_data->barrel_gobj;

    switch (LcOptions_Main[0].option_val)
    {
    case (0): // off
    {
        // if spawned, remove
        if (barrel_gobj != 0)
        {
            Item_Destroy(barrel_gobj);
            event_data->barrel_gobj = 0;
        }

        break;
    }
    case (1): // stationary
    {

        // if not spawned, spawn
        if (barrel_gobj == 0)
        {
            // spawn barrel at center stage
            barrel_gobj = Barrel_Spawn(0);
            event_data->barrel_gobj = barrel_gobj;
        }

        ItemData *barrel_data = barrel_gobj->userdata;
        barrel_data->can_hold = 0;

        break;
    }
    case (2): // move
    {
        // if not spawned, spawn
        if (barrel_gobj == 0)
        {
            // spawn barrel at center stage
            barrel_gobj = Barrel_Spawn(1);
            event_data->barrel_gobj = barrel_gobj;
        }

        ItemData *barrel_data = barrel_gobj->userdata;
        barrel_data->can_hold = 0;
        barrel_data->can_nudge = 0;

        break;
    }
    }

    return;
}
GOBJ *Barrel_Spawn(int pos_kind)
{

    LCancelData *event_data = event_vars->event_gobj->userdata;
    Vec3 *barrel_lastpos = &event_data->barrel_lastpos;

    // determine position to spawn
    Vec3 pos;
    pos.Z = 0;
    switch (pos_kind)
    {
    case (0): // center stage
    {
        // get position
        int line_index;
        int line_kind;
        Vec3 line_angle;
        float from_x = 0;
        float to_x = from_x;
        float from_y = 6;
        float to_y = from_y - 1000;
        int is_ground = Stage_RaycastGround(&pos, &line_index, &line_kind, &line_angle, -1, -1, -1, 0, from_x, from_y, to_x, to_y, 0);
        if (is_ground == 0)
            goto BARREL_RANDPOS;
        break;
    }
    case (1): // random pos
    {
        // setup time
        int raycast_num = 0;
        int raytime_start, raytime_end, raytime_time;
        raytime_start = OSGetTick();
    BARREL_RANDPOS:
    {

        // get position
        int line_index;
        int line_kind;
        Vec3 line_angle;
        float from_x = Stage_GetCameraLeft() + (HSD_Randi(Stage_GetCameraRight() - Stage_GetCameraLeft())) + HSD_Randf();
        float to_x = from_x;
        float from_y = Stage_GetCameraBottom() + (HSD_Randi(Stage_GetCameraTop() - Stage_GetCameraBottom())) + HSD_Randf();
        float to_y = from_y - 1000;
        int is_ground = Stage_RaycastGround(&pos, &line_index, &line_kind, &line_angle, -1, -1, -1, 0, from_x, from_y, to_x, to_y, 0);
        raycast_num++;
        if (is_ground == 0)
            goto BARREL_RANDPOS;

        // ensure it isnt too close to the previous
        float distance = sqrtf(pow((pos.X - barrel_lastpos->X), 2) + pow((pos.Y - barrel_lastpos->Y), 2));
        if (distance < 25)
            goto BARREL_RANDPOS;

        // ensure left and right have ground
        Vec3 near_pos;
        float near_fromX = pos.X + 8;
        float near_fromY = pos.Y + 4;
        to_y = near_fromY - 4;
        is_ground = Stage_RaycastGround(&near_pos, &line_index, &line_kind, &line_angle, -1, -1, -1, 0, near_fromX, near_fromY, near_fromX, to_y, 0);
        raycast_num++;
        if (is_ground == 0)
            goto BARREL_RANDPOS;
        near_fromX = pos.X - 8;
        is_ground = Stage_RaycastGround(&near_pos, &line_index, &line_kind, &line_angle, -1, -1, -1, 0, near_fromX, near_fromY, near_fromX, to_y, 0);
        raycast_num++;
        if (is_ground == 0)
            goto BARREL_RANDPOS;

        // output num and time
        raytime_end = OSGetTick();
        raytime_time = OSTicksToMilliseconds(raytime_end - raytime_start);
        OSReport("lcl: %d ray in %dms\n", raycast_num, raytime_time);

        break;
    }
    }
    }

    // spawn item
    SpawnItem spawnItem;
    spawnItem.parent_gobj = 0;
    spawnItem.parent_gobj2 = 0;
    spawnItem.it_kind = ITEM_BARREL;
    spawnItem.hold_kind = 0;
    spawnItem.unk2 = 0;
    spawnItem.pos = pos;
    spawnItem.pos2 = pos;
    spawnItem.vel.X = 0;
    spawnItem.vel.Y = 0;
    spawnItem.vel.Z = 0;
    spawnItem.facing_direction = 1;
    spawnItem.damage = 0;
    spawnItem.unk5 = 0;
    spawnItem.unk6 = 0;
    spawnItem.unk7 = 0x80;
    spawnItem.is_spin = 0;
    GOBJ *barrel_gobj = Item_CreateItem2(&spawnItem);
    Item_CollAir(barrel_gobj, Barrel_Null);

    // replace collision callback
    ItemData *barrel_data = barrel_gobj->userdata;
    barrel_data->it_cb = item_callbacks;
    barrel_data->camerabox->kind = 0;

    // update last barrel pos
    event_data->barrel_lastpos = pos;

    return barrel_gobj;
}
void Barrel_Null()
{
    return;
}
void Barrel_Break(GOBJ *barrel_gobj)
{

    ItemData *barrel_data = barrel_gobj->userdata;
    Effect_SpawnSync(1063, barrel_gobj, &barrel_data->pos);
    SFX_Play(251);
    ScreenRumble_Execute(2, &barrel_data->pos);
    JOBJ *barrel_jobj = barrel_gobj->hsd_object;
    JOBJ_SetFlagsAll(barrel_jobj, JOBJ_HIDDEN);
    barrel_data->xd0c = 2;
    barrel_data->selfVel.X = 0;
    barrel_data->selfVel.Y = 0;
    barrel_data->itemVar1 = 1;
    barrel_data->itemVar2 = 40;
    barrel_data->xdcf3 = 1;
    ItemStateChange(barrel_gobj, 7, 2);

    return;
}
int Barrel_OnHurt(GOBJ *barrel_gobj)
{

    // get event data
    LCancelData *event_data = event_vars->event_gobj->userdata;

    switch (LcOptions_Main[0].option_val)
    {
    case (0): // off
    {

        break;
    }
    case (1): // stationary
    {
        break;
    }
    case (2): // move
    {
        // Break this barrel
        Barrel_Break(event_data->barrel_gobj);

        // spawn new barrel at a random position
        barrel_gobj = Barrel_Spawn(1);
        event_data->barrel_gobj = barrel_gobj;
        break;
    }
    }

    return 0;
}
int Barrel_OnDestroy(GOBJ *barrel_gobj)
{

    // get event data
    LCancelData *event_data = event_vars->event_gobj->userdata;

    // if this barrel is still the current barrel
    if (barrel_gobj == event_data->barrel_gobj)
        event_data->barrel_gobj = 0;

    return 0;
}
static void *item_callbacks[] = {
    0x803f58e0,
    0x80287458,
    Barrel_OnDestroy, // onDestroy
    0x80287e68,
    0x80287ea8,
    0x80287ec8,
    0x80288818,
    Barrel_OnHurt, // onhurt
    0x802889f8,
    0x802888b8,
    0x00000000,
    0x00000000,
    0x80288958,
    0x80288c68,
    0x803f5988,
};

// Initial Menu
static EventMenu *Event_Menu = &LabMenu_Main;