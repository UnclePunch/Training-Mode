#include "meteor.h"
static char nullString[] = " ";

// Main Menu
static char **WdOptions_Target[] = {"Off", "On"};
static char **WdOptions_HUD[] = {"On", "Off"};
static EventOption WdOptions_Main[] = {
    // Target
    {
        .option_kind = OPTKIND_STRING,                                 // the type of option this is; menu, string list, integers list, etc
        .value_num = sizeof(WdOptions_Target) / 4,                     // number of values for this option
        .option_val = 0,                                               // value of this option
        .menu = 0,                                                     // pointer to the menu that pressing A opens
        .option_name = "Target",                                       // pointer to a string
        .desc = "Highlight an area of the stage to wavedash towards.", // string describing what this option does
        .option_values = WdOptions_Target,                             // pointer to an array of strings
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
        .option_kind = OPTKIND_FUNC,                                                                                                                                                                                                                               // the type of option this is; menu, string list, integers list, etc
        .value_num = 0,                                                                                                                                                                                                                                            // number of values for this option
        .option_val = 0,                                                                                                                                                                                                                                           // value of this option
        .menu = 0,                                                                                                                                                                                                                                                 // pointer to the menu that pressing A opens
        .option_name = "Help",                                                                                                                                                                                                                                     // pointer to a string
        .desc = "A wavedash is performed by air-dodging diagonally down\nas soon you leave the ground from a jump, causing the fighter\nto slide a short distance. This technique will allow you to quickly\nadjust your position and even attack while sliding.", // string describing what this option does
        .option_values = 0,                                                                                                                                                                                                                                        // pointer to an array of strings
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
    .name = "Wavedash Training",                                // the name of this menu
    .option_num = sizeof(WdOptions_Main) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                // runtime variable used for how far down in the menu to start
    .state = 0,                                                 // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                // index of the option currently selected, used at runtime
    .options = &WdOptions_Main,                                 // pointer to all of this menu's options
    .prev = 0,                                                  // pointer to previous menu, used at runtime
};

// Dialogue
static char **Dialogue_Test[] = {
    "This is one line.",
    "This is another line.",
};

// Init Function
void Event_Init(GOBJ *gobj)
{

    evco_data = *evco_data_ptr;

    // get assets
    MeteorData *meteor_data = gobj->userdata;
    meteor_data->assets = File_GetSymbol(evco_data->event_archive, "mclData");

    // init arrows
    Arrows_Init(gobj);

    // init hud
    HUD_Init(gobj);

    // test dialogue
    evco_data->Dialogue_Display(Dialogue_Test);

    return;
}
// Think Function
void Event_Think(GOBJ *event)
{

    //Arrows_Think(event);
    HUD_Think(event);

    // test dialogue
    if (evco_data->Dialogue_CheckEnd())
        evco_data->Dialogue_Display(Dialogue_Test);

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

// Arrow Functions
void Arrows_Init(GOBJ *event)
{
    MeteorData *meteor_data = event->userdata;

    // create thing
    GOBJ *arrow_gobj = JOBJ_LoadSet(0, meteor_data->assets->arrows, 0, 0, 11, 5, 1, Arrows_Think);
    ArrowData *arrow_data = calloc(sizeof(ArrowData));
    GObj_AddUserData(arrow_gobj, 4, HSD_Free, arrow_data);
    meteor_data->arrow_gobj = arrow_gobj;
    arrow_data->set = meteor_data->assets->arrows; // store pointer to jobj set (contains animation data)

    // init ALDYakuAll
    ItemDesc **itdesc_enemies = *stc_itdesc_enemies;
    itdesc_enemies[117]->states[0].script = meteor_data->assets->script;

    // item spawn
    GOBJ *item = Item_CreateMapItem(7, 0, 0, arrow_gobj->hsd_object, 0, 0, 0);
    ItemData *item_data = item->userdata;
    arrow_data->item = item;

    // alloc camera box
    CameraBox *cam_box = CameraBox_Alloc();
    cam_box->boundleft_curr = -8;
    cam_box->boundright_curr = 8;
    cam_box->boundtop_curr = 8;
    cam_box->boundbottom_curr = -8;
    cam_box->boundleft_proj = -8;
    cam_box->boundright_proj = 8;
    cam_box->boundtop_proj = 8;
    cam_box->boundbottom_proj = -8;
    item_data->camerabox = cam_box;
    item_data->cam_kind = 1;

    // move arrow
    JOBJ *arrow_jobj = arrow_gobj->hsd_object;
    arrow_jobj->trans.X = 100;
    arrow_jobj->trans.Y = 55;
    JOBJ_SetMtxDirtySub(arrow_jobj);

    // enter wait
    Arrows_EnterState(arrow_gobj, ARWSTATE_WAIT);

    return;
}
void Arrows_Think(GOBJ *arrow_gobj)
{
    ArrowData *arrow_data = arrow_gobj->userdata;
    JOBJ *arrow_jobj = arrow_gobj->hsd_object;
    GOBJ *item = arrow_data->item;
    ItemData *item_data = item->userdata;

    // update animation
    if (item_data->is_hitlag == 0)
        JOBJ_AnimAll(arrow_jobj);

    // get main arrow joint
    JOBJ *arrow_joint;
    JOBJ_GetChild(arrow_jobj, &arrow_joint, 1, -1);

    // state logic
    switch (arrow_data->state)
    {
    case (ARWSTATE_WAIT):
    {

        // get arrow position
        Vec3 pos;
        JOBJ_GetWorldPosition(arrow_joint, 0, &pos);

        // search for fighter below arrows
        GOBJList *gobj_list = *stc_gobj_list;
        GOBJ *f = gobj_list->fighter;
        while (f)
        {
            FighterData *fd = f->userdata;

            if ((fd->phys.pos.X < (pos.X + (22))) &&
                (fd->phys.pos.X > (pos.X + (-22))) &&
                (fd->phys.pos.Y < (pos.Y + (0))) &&
                (fd->phys.pos.Y > (pos.Y + (-65))))
            {
                Arrows_EnterState(arrow_gobj, ARWSTATE_DOWN);
                break;
            }

            // get next
            f = f->next;
        }

        break;
    }
    case (ARWSTATE_DOWN):
    {

        // wait for anim to finish
        if (JOBJ_CheckAObjEnd(arrow_jobj) == 0)
            Arrows_EnterState(arrow_gobj, ARWSTATE_WAIT);

        break;
    }
    }

    // update hitbox position
    Vec3 pos;
    static Vec3 pos_curr = {22, 0, 0};
    static Vec3 pos_prev = {-22, 0, 0};
    JOBJ_GetWorldPosition(arrow_joint, 0, &pos);
    item_data->hitbox[0].active = 4;
    VECAdd(&pos, &pos_curr, &item_data->hitbox[0].pos);
    VECAdd(&pos, &pos_prev, &item_data->hitbox[0].pos_prev);

    return;
}
void Arrows_EnterState(GOBJ *arrow, int state)
{
    ArrowData *arrow_data = arrow->userdata;

    arrow_data->state = state;

    // add joint anim
    JOBJ_AddAnimAll(arrow->hsd_object,
                    arrow_data->set->animjoint[state],
                    0,
                    0);

    JOBJ_ReqAnimAll(arrow->hsd_object, 0);

    return;
}

// HUD Functions
void HUD_Init(GOBJ *event)
{
    MeteorData *meteor_data = event->userdata;

    // create HUD
    GOBJ *hud_gobj = JOBJ_LoadSet(0, meteor_data->assets->time_bar, 0, 0, 11, 10, 1, 0);
    JOBJ *hud_jobj = hud_gobj->hsd_object;
    hud_gobj->gx_cb = HUD_GX;         // swap out GX callback (hides on pause)
    meteor_data->hud.gobj = hud_gobj; // save gobj

    // get slider jobj pointer
    JOBJ_GetChild(hud_jobj, &meteor_data->hud.slider, HUD_SLIDERJOINT, -1);
    // get arrow jobj pointer
    JOBJ_GetChild(hud_jobj, &meteor_data->hud.input_arrow, HUD_INPUTARROWJOINT, -1);
    // get text jobj pointer
    JOBJ_GetChild(hud_jobj, &meteor_data->hud.input_text, HUD_INPUTTEXTJOINT, -1);
    // get meteor lockout slider jobj pointer
    JOBJ_GetChild(hud_jobj, &meteor_data->hud.meteor_slider, HUD_LEFTJOINT, -1);

    // get left and right bounds
    JOBJ *left_jobj, *right_jobj;
    Vec3 left_pos, right_pos;
    JOBJ_GetChild(hud_jobj, &left_jobj, HUD_LEFTJOINT, -1);
    meteor_data->hud.left = left_jobj->trans.X;

    // hide stuff
    JOBJ_SetFlags(meteor_data->hud.input_text, JOBJ_HIDDEN);
    JOBJ_SetFlags(meteor_data->hud.input_arrow, JOBJ_HIDDEN);
    meteor_data->hud.slider->trans.X = meteor_data->hud.meteor_slider->trans.X;
    JOBJ_SetMtxDirtySub(hud_jobj);

    return;
}
void HUD_Think(GOBJ *event)
{

    MeteorData *meteor_data = event->userdata;
    GOBJ *hud_gobj = meteor_data->hud.gobj;
    GOBJ *hmn_gobj = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn_gobj->userdata;

    switch (meteor_data->state)
    {
    case (METEORSTATE_ACTIONABLE):
    {
        // look for damaged
        if (hmn_data->flags.hitstun)
        {
            meteor_data->state = METEORSTATE_DAMAGED;

            // save timers
            meteor_data->lockout_upb = hmn_data->input.timer_specialhi;
            meteor_data->lockout_jump = hmn_data->input.timer_jump;

            // init timer
            meteor_data->timer = 0;
        }

        break;
    }
    case (METEORSTATE_DAMAGED):
    {
        // update logic if no longer in hitlag
        if (hmn_data->flags.hitlag == 0)
        {

            // increment timer
            meteor_data->timer++;

            if (meteor_data->timer < 80)
            {

                ftCommonData *ftcommon = *stc_ftcommon;

                // check if inputted up b
                int upb_kind = Fighter_CheckSpecialHi(hmn_gobj);
                if (upb_kind)
                {

                    // change indicator frame to up b
                    JOBJ_ReqAnim(meteor_data->hud.input_arrow, 0);
                    JOBJ_Anim(meteor_data->hud.input_arrow);
                    JOBJ_RunAObjCallback(meteor_data->hud.input_arrow, 6, 0x400, AOBJ_StopAnim, 6, 0, 0);

                    // update lockout bar
                    HUD_UpdateLockout(event, meteor_data->lockout_upb);

                    // check if outside of meteor cancel window
                    if (hmn_data->input.timer_specialhi_lockout >= (ftcommon->meteor_lockout))
                    {
                        // ok i up b'd
                        SFX_PlayCommon(1);
                    }
                    else
                    {
                        // failed up b
                        SFX_PlayCommon(3);
                    }

                    // stop checking
                    meteor_data->state = METEORSTATE_ACTIONABLE;
                }

                // check if inputted jump
                else
                {
                    int jump_kind = Fighter_CheckJump(hmn_gobj);
                    if (jump_kind)
                    {

                        // change indicator frame to corresponding jump type
                        float frame;
                        if (jump_kind == 1)
                            frame = 2;
                        else if (jump_kind == 2)
                            frame = 1;

                        // change indicator frame to stick
                        JOBJ_ReqAnim(meteor_data->hud.input_arrow, frame);
                        JOBJ_Anim(meteor_data->hud.input_arrow);
                        JOBJ_RunAObjCallback(meteor_data->hud.input_arrow, 6, 0x400, AOBJ_StopAnim, 6, 0, 0);

                        // update lockout bar
                        HUD_UpdateLockout(event, meteor_data->lockout_jump);

                        // check if outside of meteor cancel window
                        if (hmn_data->input.timer_jump_lockout >= (ftcommon->meteor_lockout))
                        {
                            // ok i jumped
                            SFX_PlayCommon(1);
                        }
                        else
                        {
                            // failed jumped
                            SFX_PlayCommon(3);
                        }

                        // stop checking
                        meteor_data->state = METEORSTATE_ACTIONABLE;
                    }
                }

                // if out of hitstun and didnt meteor cancel, stop looking for it
                if (hmn_data->flags.hitstun == 0)
                    meteor_data->state = METEORSTATE_ACTIONABLE;
            }

            // exit
            else
                meteor_data->state = METEORSTATE_ACTIONABLE;
        }

        break;
    }
    }

    return;
}
void HUD_GX(GOBJ *hud, int pass)
{

    if ((Pause_CheckStatus(1) == 0) && (Pause_CheckStatus(2) == 0))
        GXLink_Common(hud, pass);

    return;
}
void HUD_UpdateLockout(GOBJ *event, int timer)
{
    MeteorData *meteor_data = event->userdata;
    ftCommonData *ftcommon = *stc_ftcommon;

    // lockout_frames = meteor_lockout - (timer_onhit + delay)
    int lockout_remain = (ftcommon->meteor_lockout + 1) - (timer + ftcommon->meteor_delay);

    // if this is negative, there is no effective lockout
    if (lockout_remain < 0)
        lockout_remain = 0;

    // adjust input lockout slider position
    meteor_data->hud.slider->trans.X = meteor_data->hud.left + ((float)lockout_remain * 1);

    // adjust input lockout text
    if (lockout_remain > 4)
    {
        // show text
        JOBJ_ClearFlags(meteor_data->hud.input_text, JOBJ_HIDDEN);

        // move text
        meteor_data->hud.input_text->trans.X = ((meteor_data->hud.slider->trans.X - meteor_data->hud.meteor_slider->trans.X) / 2) + meteor_data->hud.meteor_slider->trans.X;
    }
    else if (lockout_remain == 0)
    {
        // hide text
        JOBJ_SetFlags(meteor_data->hud.input_text, JOBJ_HIDDEN);
    }
    else
    {
        // hide text
        //JOBJ_SetFlags(meteor_data->hud.input_text, JOBJ_HIDDEN);
        meteor_data->hud.input_text->trans.X = meteor_data->hud.meteor_slider->trans.X + (4 / 2);
    }

    // adjust indicator
    meteor_data->hud.input_arrow->trans.X = (((float)(meteor_data->timer)) * 1) - 0.7;
    JOBJ_ClearFlags(meteor_data->hud.input_arrow, JOBJ_HIDDEN);

    // update mtx
    JOBJ_SetMtxDirtySub(meteor_data->hud.gobj->hsd_object);

    return;
}

int Fighter_CheckJump(GOBJ *hmn)
{

    FighterData *hmn_data = hmn->userdata;
    ftCommonData *ftcommon = *stc_ftcommon;
    int jumped = 0;

    // check if jumped (this runs after the state changed)
    if ((hmn_data->state_id == ASID_JUMPAERIALF) || (hmn_data->state_id == ASID_JUMPAERIALB))
    {
        // check if jumped via button
        if ((hmn_data->input.down) & (PAD_BUTTON_X | PAD_BUTTON_Y))
            jumped = 1;

        // jumped via stick
        else
            jumped = 2;
    }

    // didnt jump, check if they tried to
    else
    {
        if (hmn_data->jump.jumps_used < hmn_data->attr.max_jumps)
        {
            if ((hmn_data->input.down) & (PAD_BUTTON_X | PAD_BUTTON_Y))
                jumped = 1;

            else if ((hmn_data->input.lstick.Y > ftcommon->jumpaerial_lsticky) && (hmn_data->input.timer_lstick_tilt_y < ftcommon->jumpaerial_lsticktimer))
                jumped = 2;
        }
    }

    return jumped;
}
int Fighter_CheckSpecialHi(GOBJ *hmn)
{

    FighterData *hmn_data = hmn->userdata;
    ftCommonData *ftcommon = *stc_ftcommon;
    int is_upb = 0;

    // check for up b conditions
    if ((1) &&                                  // check if can up b (references mxdt, just going to assume they can)
        (hmn_data->input.timer_specialhi == 0)) // check if just pressed up b
    {
        is_upb = 1;
    }

    return is_upb;
}

// Initial Menu
static EventMenu *Event_Menu = &WdMenu_Main;