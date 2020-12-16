#include "wavedash.h"
static char nullString[] = " ";

// Main Menu
static char **WdOptions_Barrel[] = {"Off", "Stationary", "Move"};
static char **WdOptions_HUD[] = {"On", "Off"};
static EventOption WdOptions_Main[] = {
    // Target
    {
        .option_kind = OPTKIND_STRING,             // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(WdOptions_Barrel) / 4, // number of values for this option
        .option_val = 0,                           // value of this option
        .menu = 0,                                 // pointer to the menu that pressing A opens
        .option_name = "Target",                   // pointer to a string
        .desc = "Enable a target to attack.",      // string describing what this option does
        .option_values = WdOptions_Barrel,         // pointer to an array of strings
        .onOptionChange = 0,
    },
    // HUD
    {
        .option_kind = OPTKIND_STRING,           // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(WdOptions_HUD) / 4,  // number of values for this option
        .option_val = 0,                         // value of this option
        .menu = 0,                               // pointer to the menu that pressing A opens
        .option_name = "HUD",                    // pointer to a string
        .desc = "Toggle visibility of the HUD.", // string describing what this option does
        .option_values = WdOptions_HUD,          // pointer to an array of strings
        .onOptionChange = 0,
    },
    // Tips
    {
        .option_kind = OPTKIND_STRING,                  // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(WdOptions_HUD) / 4,         // number of values for this option
        .option_val = 0,                                // value of this option
        .menu = 0,                                      // pointer to the menu that pressing A opens
        .option_name = "Tips",                          // pointer to a string
        .desc = "Toggle the onscreen display of tips.", // string describing what this option does
        .option_values = WdOptions_HUD,                 // pointer to an array of strings
        .onOptionChange = 0,
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
static EventMenu WdMenu_Main = {
    .name = "L-Cancel Training",                                // the name of this menu
    .option_num = sizeof(WdOptions_Main) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                // runtime variable used for how far down in the menu to start
    .state = 0,                                                 // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                // index of the option currently selected, used at runtime
    .options = &WdOptions_Main,                                 // pointer to all of this menu's options
    .prev = 0,                                                  // pointer to previous menu, used at runtime
};

// Init Function
void Event_Init(GOBJ *gobj)
{
    WavedashData *event_data = gobj->userdata;
    EventDesc *event_desc = event_data->event_desc;
    GOBJ *hmn = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn->userdata;
    //GOBJ *cpu = Fighter_GetGObj(1);
    //FighterData *cpu_data = cpu->userdata;

    // theres got to be a better way to do this...
    event_vars = *event_vars_ptr;

    // get l-cancel assets
    event_data->assets = File_GetSymbol(event_vars->event_archive, "wdshData");

    // create HUD
    Wavedash_Init(event_data);

    return;
}
// Think Function
void Event_Think(GOBJ *event)
{
    WavedashData *event_data = event->userdata;
    GOBJ *hmn = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn->userdata;

    Wavedash_Think(event_data, hmn_data);

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

// Event functions
void Wavedash_Init(WavedashData *event_data)
{

    // create hud cobj
    GOBJ *hudcam_gobj = GObj_Create(19, 20, 0);
    ArchiveInfo **ifall_archive = 0x804d6d5c;
    COBJDesc ***dmgScnMdls = File_GetSymbol(*ifall_archive, 0x803f94d0);
    COBJDesc *cam_desc = dmgScnMdls[1][0];
    COBJ *hud_cobj = COBJ_LoadDesc(cam_desc);
    // init camera
    GObj_AddObject(hudcam_gobj, R13_U8(-0x3E55), hud_cobj);
    GOBJ_InitCamera(hudcam_gobj, Wavedash_HUDCamThink, 7);
    hudcam_gobj->cobj_links = 1 << 18;

    GOBJ *hud_gobj = GObj_Create(0, 0, 0);
    event_data->hud_gobj = hud_gobj;
    // Load jobj
    JOBJ *hud_jobj = JOBJ_LoadJoint(event_data->assets->hud);
    GObj_AddObject(hud_gobj, 3, hud_jobj);
    GObj_AddGXLink(hud_gobj, GXLink_Common, 18, 80);

    // save bar frame colors
    JOBJ *timingbar_jobj;
    JOBJ_GetChild(hud_jobj, &timingbar_jobj, WDJOBJ_BAR, -1); // get timing bar jobj
    DOBJ *d = timingbar_jobj->dobj;
    int count = 0;
    while (d != 0)
    {
        // if a box dobj
        if ((count >= 3) && (count <= 17))
        {

            // if mobj exists (it will)
            MOBJ *m = d->mobj;
            if (m != 0)
                event_data->orig_colors[(count - 3)] = m->mat->diffuse; // save gxcolor
        }

        // inc
        count++;
        d = d->next;
    }

    // init timer
    event_data->timer = -1;

    return 0;
}
void Wavedash_Think(WavedashData *event_data, FighterData *hmn_data)
{

    // run tip logic
    //Tips_Think(event_data, hmn_data);

    JOBJ *hud_jobj = event_data->hud_gobj->hsd_object;

    // start sequence on jump squat
    if ((hmn_data->state == ASID_KNEEBEND) && (hmn_data->TM.state_frame == 0))
    {
        event_data->is_airdodge = 0;

        // start timer
        event_data->timer = 0;

        // save line and position
        event_data->restore.pos.X = hmn_data->phys.pos.X;
        event_data->restore.pos.Y = hmn_data->phys.pos.Y;
        event_data->restore.line_index = hmn_data->coll_data.ground_index;
    }

    // if sequence started
    if (event_data->timer >= 0)
    {
        event_data->timer++; // inc timer

        // if grounded and not in kneebend, stop sequence
        if ((hmn_data->state != ASID_KNEEBEND) && (hmn_data->state != ASID_LANDINGFALLSPECIAL) && (hmn_data->phys.air_state == 0))
            event_data->timer = -1;

        // run sequence logic
        else
        {

            // catch early airdodge input
            if (hmn_data->input.down & (PAD_TRIGGER_L | PAD_TRIGGER_R))
            {
                event_data->airdodge_frame = event_data->timer; // save airdodge frame
                event_data->is_early_airdodge = 1;
            }

            // save airdodge angle
            if ((event_data->is_airdodge == 0) &&
                (((hmn_data->state == ASID_ESCAPEAIR) && (hmn_data->TM.state_frame == 0)) || // if entered airdodge
                 ((hmn_data->state == ASID_LANDINGFALLSPECIAL) && (hmn_data->TM.state_frame == 0) && (hmn_data->TM.state_prev[0] == ASID_ESCAPEAIR))))
            {
                // determine airdodge angle
                float angle = atan2(hmn_data->input.lstick_y, hmn_data->input.lstick_x) - -(M_PI / 2);

                // save airdodge angle
                event_data->wd_angle = angle;
                event_data->is_airdodge = 1;
                event_data->airdodge_frame = event_data->timer; // save airdodge frame
            }

            int is_finished = 0;

            // look for successful WD
            if ((hmn_data->state == ASID_LANDINGFALLSPECIAL) && (hmn_data->TM.state_frame == 0) && // is in special landing
                (hmn_data->TM.state_prev[0] == ASID_ESCAPEAIR) &&                                  // came from airdodge
                (hmn_data->TM.state_prev[2] == ASID_KNEEBEND))                                     // came from jump
            {
                is_finished = 1;

                // check for perfect
                bp();
                if (event_data->airdodge_frame == ((int)hmn_data->attr.jump_startup_time + 1))
                    SFX_Play(303);
            }

            // look for failed WD
            else if ((event_data->is_early_airdodge == 1) && (((hmn_data->state == ASID_JUMPF) || (hmn_data->state == ASID_JUMPB)) && (hmn_data->TM.state_frame >= 10)) ||
                     ((hmn_data->state == ASID_ESCAPEAIR) && (hmn_data->TM.state_frame >= 10) && (hmn_data->TM.state_prev[1] == ASID_KNEEBEND)))
            {
                is_finished = 1;
                SFX_PlayCommon(3);

                // restore position
                int ray_index;
                int ray_kind;
                Vec2 ray_angle;
                Vec3 ray_pos;
                float from_x = event_data->restore.pos.X;
                float to_x = from_x;
                float from_y = event_data->restore.pos.Y + 3;
                float to_y = from_y - 6;
                int is_ground = GrColl_RaycastGround(&ray_pos, &ray_index, &ray_kind, &ray_angle, -1, -1, -1, 0, from_x, from_y, to_x, to_y, 0);
                if ((is_ground == 1) && (ray_index == event_data->restore.line_index))
                {
                    // do this for every subfighter (thanks for complicated code ice climbers)
                    for (int i = 0; i < 2; i++)
                    {
                        GOBJ *this_fighter = Fighter_GetSubcharGObj(hmn_data->ply, i);

                        if (this_fighter != 0)
                        {

                            FighterData *this_fighter_data = this_fighter->userdata;

                            if ((this_fighter_data->flags.sleep == 0) && (this_fighter_data->flags.dead == 0))
                            {

                                // place CPU here
                                this_fighter_data->phys.pos = ray_pos;
                                this_fighter_data->coll_data.ground_index = ray_index;

                                // set grounded
                                this_fighter_data->phys.air_state = 0;
                                //Fighter_SetGrounded(this_fighter);

                                // kill velocity
                                Fighter_KillAllVelocity(this_fighter);

                                // enter wait
                                ActionStateChange(0, 1, -1, this_fighter, ASID_WAIT, 0, 0);
                                this_fighter_data->stateBlend = 0;

                                // update ECB
                                this_fighter_data->coll_data.topN_Curr = this_fighter_data->phys.pos; // move current ECB location to new position
                                Coll_ECBCurrToPrev(&this_fighter_data->coll_data);
                                this_fighter_data->cb.Coll(this_fighter);

                                // update camera box
                                Fighter_UpdateCameraBox(this_fighter);
                                this_fighter_data->cameraBox->boundleft_curr = this_fighter_data->cameraBox->boundleft_proj;
                                this_fighter_data->cameraBox->boundright_curr = this_fighter_data->cameraBox->boundright_proj;

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

                    // update camera
                    Match_CorrectCamera();
                }
            }

            // update bar
            if (is_finished)
            {
                // reset variables
                event_data->timer = -1;
                event_data->is_airdodge = 0;
                event_data->is_early_airdodge = 0;

                // update bar frame colors
                JOBJ *timingbar_jobj;
                JOBJ_GetChild(hud_jobj, &timingbar_jobj, WDJOBJ_BAR, -1); // get timing bar jobj
                DOBJ *d = timingbar_jobj->dobj;
                int count = 0;
                static GXColor framecol_white = {255, 255, 255, 255};
                // get in terms of bar timeframe
                int jump_frame = ((WDFRAMES - 1) / 2) - (int)hmn_data->attr.jump_startup_time;
                int input_frame = jump_frame + event_data->airdodge_frame - 1;
                // iterate through dobjs
                while (d != 0)
                {
                    // if a box dobj
                    if ((count >= 3) && (count <= 17))
                    {

                        // if mobj exists (it will)
                        MOBJ *m = d->mobj;
                        if (m != 0)
                        {

                            // dobj index to frame index
                            int frame_index = count - 3;

                            // check to highlight this frame
                            if (input_frame == frame_index)
                                m->mat->diffuse = framecol_white; //
                            // restore orig color
                            else
                                m->mat->diffuse = event_data->orig_colors[frame_index]; // set to orig color
                        }
                    }

                    // inc
                    count++;
                    d = d->next;
                }

                // apply HUD animation
                //JOBJ_RemoveAnimAll(hud_jobj);
                //JOBJ_AddAnimAll(hud_jobj, 0, matanim, 0);
                //JOBJ_ReqAnimAll(hud_jobj, 0);
            }
        }
    }
    // update HUD anim
    //JOBJ_AnimAll(hud_jobj);

    return;
}
void Wavedash_HUDCamThink(GOBJ *gobj)
{

    // if HUD enabled and not paused
    if ((WdOptions_Main[1].option_val == 0) && (Pause_CheckStatus(1) != 2))
    {
        CObjThink_Common(gobj);
    }

    return;
}

// Initial Menu
static EventMenu *Event_Menu = &WdMenu_Main;