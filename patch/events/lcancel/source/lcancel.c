#include "lcancel.h"
static char nullString[] = " ";

// Main Menu
static char **LcOptions_Barrel[] = {"Off", "Stationary", "Move"};
static char **LcOptions_HUD[] = {"On", "Off"};
static EventOption LcOptions_Main[] = {
    // Target
    {
        .option_kind = OPTKIND_STRING,                                            // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(LcOptions_Barrel) / 4,                                // number of values for this option
        .option_val = 0,                                                          // value of this option
        .menu = 0,                                                                // pointer to the menu that pressing A opens
        .option_name = "Target",                                                  // pointer to a string
        .desc = "Enable a target to attack. Use DPad down to\nmanually move it.", // string describing what this option does
        .option_values = LcOptions_Barrel,                                        // pointer to an array of strings
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
    // Tips
    {
        .option_kind = OPTKIND_STRING,                  // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(LcOptions_HUD) / 4,         // number of values for this option
        .option_val = 0,                                // value of this option
        .menu = 0,                                      // pointer to the menu that pressing A opens
        .option_name = "Tips",                          // pointer to a string
        .desc = "Toggle the onscreen display of tips.", // string describing what this option does
        .option_values = LcOptions_HUD,                 // pointer to an array of strings
        .onOptionChange = Tips_Toggle,
    },
    // Help
    {
        .option_kind = OPTKIND_FUNC,                                                                                                                                                                                       // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                                                                                                                                                                                                    // number of values for this option
        .option_val = 0,                                                                                                                                                                                                   // value of this option
        .menu = 0,                                                                                                                                                                                                         // pointer to the menu that pressing A opens
        .option_name = "Help",                                                                                                                                                                                             // pointer to a string
        .desc = "L-canceling is performed by pressing L, R, or Z up to \n7 frames before landing from a non-special aerial\nattack. This will cut the landing lag in half, allowing \nyou to act sooner after attacking.", // string describing what this option does
        .option_values = 0,                                                                                                                                                                                                // pointer to an array of strings
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
            is_ground = GrColl_RaycastGround(&coll_pos, &line_index, &line_kind, &line_unk, -1, -1, -1, 0, from_x, from_y, to_x, to_y, 0);
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
                            this_fighter_data->coll_data.ground_index = line_index;

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
                            this_fighter_data->coll_data.topN_Curr = this_fighter_data->phys.pos; // move current ECB location to new position
                            Coll_ECBCurrToPrev(&this_fighter_data->coll_data);
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
    GOBJ_InitCamera(hudcam_gobj, LCancel_HUDCamThink, 7);
    hudcam_gobj->cobj_links = 1 << 18;

    GOBJ *hud_gobj = GObj_Create(0, 0, 0);
    event_data->hud.gobj = hud_gobj;
    // Load jobj
    JOBJ *hud_jobj = JOBJ_LoadJoint(event_data->lcancel_assets->hud);
    GObj_AddObject(hud_gobj, 3, hud_jobj);
    GObj_AddGXLink(hud_gobj, GXLink_Common, 18, 80);

    /*
    // account for widescreen
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
        hud_text->aspect.X = 165;

        // text position
        hud_text->trans.X = text_pos.X + (scale->X / 4.0);
        hud_text->trans.Y = (text_pos.Y * -1) + (scale->Y / 4.0);

        // dummy text
        Text_AddSubtext(hud_text, 0, 0, "-");
    }

    // save initial arrow position
    JOBJ *arrow_jobj;
    JOBJ_GetChild(hud_jobj, &arrow_jobj, LCLARROW_JOBJ, -1);
    event_data->hud.arrow_base_x = arrow_jobj->trans.X;
    event_data->hud.arrow_timer = 0;
    arrow_jobj->trans.X = 0;
    JOBJ_SetFlags(arrow_jobj, JOBJ_HIDDEN);

    return 0;
}
void LCancel_Think(LCancelData *event_data, FighterData *hmn_data)
{

    // run tip logic
    Tips_Think(event_data, hmn_data);

    JOBJ *hud_jobj = event_data->hud.gobj->hsd_object;

    // log fastfall frame
    // if im in a fastfall-able state
    int state = hmn_data->state;
    //if ((state == ASID_JUMPF) || (state == ASID_JUMPB) || (state == ASID_JUMPAERIALF) || (state == ASID_JUMPAERIALB) || (state == ASID_FALL) || (state == ASID_FALLAERIAL) || ((state >= ASID_ATTACKAIRN) && (state <= ASID_ATTACKAIRLW))
    {
        if (hmn_data->phys.self_vel.Y < 0) // can i fastfall?
        {
            // did i fastfall yet?
            if (hmn_data->flags.is_fastfall)
                event_data->is_fastfall = 1; // set as fastfall this session
            else
                event_data->fastfall_frame++; // increment frames
        }
        else // cant fastfall, reset frames
        {
            event_data->fastfall_frame = 0;
        }
    }

    // if aerial landing
    if (((hmn_data->state >= ASID_LANDINGAIRN) && (hmn_data->state <= ASID_LANDINGAIRLW)) && (hmn_data->TM.state_frame == 0))
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

        // update timing text
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

        // update arrow
        JOBJ *arrow_jobj;
        JOBJ_GetChild(hud_jobj, &arrow_jobj, LCLARROW_JOBJ, -1);
        event_data->hud.arrow_prevpos = arrow_jobj->trans.X;
        event_data->hud.arrow_nextpos = event_data->hud.arrow_base_x - (frame_box_id * LCLARROW_OFFSET);
        JOBJ_ClearFlags(arrow_jobj, JOBJ_HIDDEN);
        event_data->hud.arrow_timer = LCLARROW_ANIMFRAMES;

        // Print airborne frames
        if (event_data->is_fastfall)
            Text_SetText(event_data->hud.text_air, 0, "%df", event_data->fastfall_frame - 1);
        else
            Text_SetText(event_data->hud.text_air, 0, "-");
        event_data->is_fastfall = 0; // reset fastfall bool

        // Print succession
        float succession = ((float)event_data->hud.lcl_success / (float)event_data->hud.lcl_total) * 100.0;
        Text_SetText(event_data->hud.text_scs, 0, "%.1f%%", succession);

        // Play HUD anim
        JOBJ_RemoveAnimAll(hud_jobj);
        JOBJ_AddAnimAll(hud_jobj, 0, event_data->lcancel_assets->hudmatanim[is_fail], 0);
        JOBJ_ReqAnimAll(hud_jobj, 0);
    }

    // if autocancel landing
    if (((hmn_data->state == ASID_LANDING) && (hmn_data->TM.state_frame == 0)) &&                   // if first frame of landing
        ((hmn_data->TM.state_prev[0] >= ASID_ATTACKAIRN) && (hmn_data->state <= ASID_ATTACKAIRLW))) // came from aerial attack
    {
        // state as autocancelled
        Text_SetText(event_data->hud.text_time, 0, "Auto-canceled");

        // Play HUD anim
        JOBJ_RemoveAnimAll(hud_jobj);
        JOBJ_AddAnimAll(hud_jobj, 0, event_data->lcancel_assets->hudmatanim[2], 0);
        JOBJ_ReqAnimAll(hud_jobj, 0);
    }

    // update arrow animation
    if (event_data->hud.arrow_timer > 0)
    {
        // decrement timer
        event_data->hud.arrow_timer--;

        // get this frames position
        float time = 1 - ((float)event_data->hud.arrow_timer / (float)LCLARROW_ANIMFRAMES);
        float xpos = Bezier(time, event_data->hud.arrow_prevpos, event_data->hud.arrow_nextpos);

        // update position
        JOBJ *arrow_jobj;
        JOBJ_GetChild(hud_jobj, &arrow_jobj, LCLARROW_JOBJ, -1); // get timing bar jobj
        arrow_jobj->trans.X = xpos;
        JOBJ_SetMtxDirtySub(arrow_jobj);
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
void Tips_Toggle(GOBJ *menu_gobj, int value)
{
    // destroy existing tips when disabling
    if (value == 1)
        event_vars->Tip_Destroy();

    return;
}
void Tips_Think(LCancelData *event_data, FighterData *hmn_data)
{

    if (LcOptions_Main[2].option_val == 0)
    {
        // shield tip
        if (event_data->tip.shield_isdisp == 0) // if not shown
        {

            // update tip conditions
            // look for a freshly buffered guard off
            if (((hmn_data->state == ASID_GUARDOFF) && (hmn_data->TM.state_frame == 0)) &&                               // currently in guardoff first frame
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
                    if (event_vars->Tip_Display(5 * 60, shield_string))
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
            if ((hmn_data->state >= ASID_ATTACKAIRN) && (hmn_data->state <= ASID_ATTACKAIRLW)) // check if currently in aerial attack)                                                      // check if in first frame of aerial attack
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
            if ((hmn_data->state >= ASID_LANDINGAIRN) && (hmn_data->state <= ASID_LANDINGAIRLW) && (hmn_data->TM.state_frame == 0) && // is in aerial landing
                (event_data->is_fail == 0) &&
                (event_data->tip.hitbox_active == 0)) // succeeded the last aerial landing
            {
                // increment condition count
                event_data->tip.hitbox_num++;

                // if condition met X times, show tip
                if (event_data->tip.hitbox_num >= 3)
                {
                    // display tip
                    char *hitbox_string = "Tip:\nDon't land too quickly! Make \nsure you land after the \nattack becomes active.";
                    if (event_vars->Tip_Display(5 * 60, hitbox_string))
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
            if ((hmn_data->state >= ASID_ATTACKAIRN) && (hmn_data->state <= ASID_ATTACKAIRLW)) // check if currently in aerial attack)                                                      // check if in first frame of aerial attack
            {

                // reset hitbox bool on first frame of aerial attack
                if (hmn_data->TM.state_frame == 0)
                    event_data->tip.fastfall_active = 0;

                // check if fastfalling
                if (hmn_data->flags.is_fastfall == 1)
                    event_data->tip.fastfall_active = 1;
            }

            // update tip conditions
            if ((hmn_data->state >= ASID_LANDINGAIRN) && (hmn_data->state <= ASID_LANDINGAIRLW) && (hmn_data->TM.state_frame == 0) &&  // is in aerial landing
                ((hmn_data->input.timer_trigger_any_ignore_hitlag >= 7) && (hmn_data->input.timer_trigger_any_ignore_hitlag <= 15)) && // was early for an l-cancel
                (event_data->tip.fastfall_active == 0))                                                                                // succeeded the last aerial landing
            {
                // increment condition count
                event_data->tip.fastfall_num++;

                // if condition met X times, show tip
                if (event_data->tip.fastfall_num >= 3)
                {
                    // display tip
                    char *fastfall_string = "Tip:\nDon't forget to fastfall!\nIt will let you act sooner \nand help with your \ntiming.";
                    if (event_vars->Tip_Display(5 * 60, fastfall_string))
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
            if ((hmn_data->state >= ASID_LANDINGAIRN) && (hmn_data->state <= ASID_LANDINGAIRLW) && // is in aerial landing
                (event_data->is_fail == 1) &&                                                      // failed the l-cancel
                (hmn_data->input.down & (HSD_TRIGGER_L | HSD_TRIGGER_R | HSD_TRIGGER_Z)))          // was late for an l-cancel by pressing it just now
            {
                // increment condition count
                event_data->tip.late_num++;

                // if condition met X times, show tip
                if (event_data->tip.late_num >= 3)
                {
                    // display tip
                    char *late_string = "Tip:\nTry pressing the trigger a\nbit earlier, before the\nfighter lands.";
                    if (event_vars->Tip_Display(5 * 60, late_string))
                    {

                        // set as shown
                        //event_data->tip.hitbox_isdisp = 1;
                        event_data->tip.late_num = 0;
                    }
                }
            }
        }
    }
    return;
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

        // check to move barrel
        // get fighter data
        GOBJ *hmn = Fighter_GetGObj(0);
        FighterData *hmn_data = hmn->userdata;
        if (hmn_data->input.down & PAD_BUTTON_DPAD_DOWN)
        {
            // ensure player is grounded
            int isGround = 0;
            if (hmn_data->phys.air_state == 0)
            {

                // check for ground in front of player
                Vec3 coll_pos;
                int line_index;
                int line_kind;
                Vec3 line_unk;
                float fromX = (hmn_data->phys.pos.X) + (hmn_data->facing_direction * 16);
                float toX = fromX;
                float fromY = (hmn_data->phys.pos.Y + 5);
                float toY = fromY - 10;
                isGround = GrColl_RaycastGround(&coll_pos, &line_index, &line_kind, &line_unk, -1, -1, -1, 0, fromX, fromY, toX, toY, 0);
                if (isGround == 1)
                {

                    // update last pos
                    event_data->barrel_lastpos = coll_pos;

                    // place barrel here
                    barrel_data->pos = coll_pos;
                    barrel_data->coll_data.ground_index = line_index;

                    // update ECB
                    barrel_data->coll_data.topN_Curr = barrel_data->pos; // move current ECB location to new position
                    Coll_ECBCurrToPrev(&barrel_data->coll_data);
                    barrel_data->cb.coll(barrel_gobj);

                    SFX_Play(221);
                }
                else
                {
                    // play SFX
                    SFX_PlayCommon(3);
                }
            }
            break;
        }
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
        int is_ground = GrColl_RaycastGround(&pos, &line_index, &line_kind, &line_angle, -1, -1, -1, 0, from_x, from_y, to_x, to_y, 0);
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
        int is_ground = GrColl_RaycastGround(&pos, &line_index, &line_kind, &line_angle, -1, -1, -1, 0, from_x, from_y, to_x, to_y, 0);
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
        is_ground = GrColl_RaycastGround(&near_pos, &line_index, &line_kind, &line_angle, -1, -1, -1, 0, near_fromX, near_fromY, near_fromX, to_y, 0);
        raycast_num++;
        if (is_ground == 0)
            goto BARREL_RANDPOS;
        near_fromX = pos.X - 8;
        is_ground = GrColl_RaycastGround(&near_pos, &line_index, &line_kind, &line_angle, -1, -1, -1, 0, near_fromX, near_fromY, near_fromX, to_y, 0);
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
    barrel_data->self_vel.X = 0;
    barrel_data->self_vel.Y = 0;
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

// Misc
float Bezier(float time, float start, float end)
{
    float bez = time * time * (3.0f - 2.0f * time);
    return bez * (end - start) + start;
}

// Initial Menu
static EventMenu *Event_Menu = &LabMenu_Main;