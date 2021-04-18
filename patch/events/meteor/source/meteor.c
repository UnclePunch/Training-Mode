#include "meteor.h"

// Main Menu
static char **WdOptions_Target[] = {"Off", "On"};
static char **WdOptions_HUD[] = {"On", "Off"};
static EventOption WdOptions_Main[] = {
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
    .name = "Meteor Cancel Training",                           // the name of this menu
    .option_num = sizeof(WdOptions_Main) / sizeof(EventOption), // number of options this menu contains
    .scroll = 0,                                                // runtime variable used for how far down in the menu to start
    .state = 0,                                                 // bool used to know if this menu is focused, used at runtime
    .cursor = 0,                                                // index of the option currently selected, used at runtime
    .options = &WdOptions_Main,                                 // pointer to all of this menu's options
    .prev = 0,                                                  // pointer to previous menu, used at runtime
};

// Dialogue
static char **Dialogue_Intro[] = {
    "Hello! Today I'll be teaching\nyou about meteor cancelling.",
    "Melee has 2 types of spikes,\ntrue spikes and meteor spikes.",
    "A true spike will send you\ndownwards and diagonal. These\ncannot be cancelled.",
    "A meteor spike will send you\nstraight down. These CAN be cancelled.",
    "If you find yourself being \nmeteor spiked, you can cancel \nit and get a second chance!",
    "You can cancel it with either\na double jump or an up-b.",
    -1,
};
static char **Dialogue_MLock[] = {
    "There is a short amount of time\nafter getting spiked where it's \nimpossible to meteor cancel.",
    "You must wait 8 frames\n(0.15 seconds) before cancelling.",
    "This is called the\n\"meteor lockout\".",
    -1,
};
static char **Dialogue_ILock[] = {
    "This is the earliest Fox can cancel\nhis knockback with a meteor cancel.\nBut there is one more rule.",
    "You must wait 40 frames (0.7 seconds)\nsince the last time you inputted\na double jump or up-b.",
    "This is referred to as the\n\"input lockout\".",
    "This means you shouldn't mash your\nrecovery! If you do, you will find yourself\nalways being locked out.",
    "Anyway, Fox hasn't up-b'd recently,\nso he is able to use it right now.",
    -1,
};
static char **Dialogue_ILock2[] = {
    "Oh, this is unfortunate...",
    "Now Fox has no double jump and must\nwait almost a second to up-b\nagain because he just used it.",
    "Let's see if he can make it back.",
    -1,
};
static char **Dialogue_End[] = {
    "Looks like Fox was too\nfar to recover...",
    "Try not to get hit directly after\nup-b'ing! You'll have to wait a while\nbefore up-b'ing again.",
    "Okay, now you can try for yourself.\nUse the bar along the top of the screen\nto see how well you timed your input.",
    "Good luck!",
    -1,
};

static InpSeqTest input_seq[] = {
    // wait to get off respawn plat
    InpSeqWait(25),
    // drift towards respawn for a bit
    InpSeqInput(0, -127, 0, 0, 0, 10),
    // jump into arrows and drift towards
    InpSeqInput(PAD_BUTTON_X, -127, 0, 0, 0, 1),
    InpSeqInput(0, -127, 0, 0, 0, 25),
    InpSeqWait(15),
    // after getting hit, input up b
    InpSeqInput(PAD_BUTTON_B, 0, 127, 0, 0, 1),
    InpSeqWait(47),
    InpSeqInput(PAD_BUTTON_B, 0, 127, 0, 0, 1),
    InpSeqInput(PAD_BUTTON_B, -36, 127, 0, 0, 60),
    InpSeqEnd(),
};

static DlgScnTest tut_scn[] = {
    // init
    DlgScnEnterState(0, DLGSCNSTATES_SLEEP),
    DlgScnMove(1, 160, 0, -1.0, 0),
    DlgScnEnterState(1, DLGSCNSTATES_REBIRTHWAIT),
    DlgScnText(Dialogue_Intro, 1),
    DlgScnWaitText(),
    DlgScnAssetCreate(1),
    DlgScnAssetChange(0),
    // start main input sequence
    DlgScnPlayInputs(1, input_seq),
    // explain meteor lockout
    DlgScnWaitFrame(67),
    DlgScnAssetChange(0),
    DlgScnFreeze(),
    DlgScnText(Dialogue_MLock, 1),
    DlgScnWaitText(),
    DlgScnUnfreeze(),
    // explain input lockout
    DlgScnWaitFrame(9),
    DlgScnAssetDestroy(),
    DlgScnFreeze(),
    DlgScnText(Dialogue_ILock, 1),
    DlgScnWaitText(),
    DlgScnUnfreeze(),
    // get hit immediately and demonstrate input lockout
    DlgScnWaitFrame(18),
    DlgScnFreeze(),
    DlgScnText(Dialogue_ILock2, 1),
    DlgScnWaitText(),
    DlgScnUnfreeze(),
    // wait for fox to miss the stage and explain
    DlgScnWaitFrame(115),
    DlgScnFreeze(),
    DlgScnText(Dialogue_End, 1),
    DlgScnWaitText(),
    DlgScnUnfreeze(),
    // play out remaining inputs
    DlgScnWaitInputs(1),
    // give control back to hmn
    DlgScnEnterState(1, DLGSCNSTATES_SLEEP),
    DlgScnMove(0, 160, 0, -1.0, 0),
    DlgScnEnterState(0, DLGSCNSTATES_REBIRTHWAIT),
    DlgScnEnd(),
};
static DlgScnTest reset_scn[] = {
    // give control back to hmn
    DlgScnEnterState(1, DLGSCNSTATES_SLEEP),
    DlgScnMove(0, 160, 0, -1.0, 0),
    DlgScnEnterState(0, DLGSCNSTATES_REBIRTHWAIT),
    DlgScnEnd(),
};

static DlgScnTest tut_test[] = {
    // init
    DlgScnEnterState(0, DLGSCNSTATES_SLEEP),
    DlgScnMove(1, 145, 0, -1.0, 0),
    DlgScnEnterState(1, DLGSCNSTATES_REBIRTHWAIT),
    // start main input sequence
    DlgScnPlayInputs(1, input_seq),
    DlgScnWaitInputs(1),
    // give control back to hmn
    DlgScnEnterState(1, DLGSCNSTATES_SLEEP),
    DlgScnMove(0, 145, 0, -1.0, 0),
    DlgScnEnterState(0, DLGSCNSTATES_REBIRTHWAIT),
    DlgScnEnd(),
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

    // start tutorial
    evco_data->Scenario_Exec(&tut_scn, &reset_scn);
    meteor_data->is_tutorial = 1;

    // hide hud during tutorial
    JOBJ *hud_jobj = meteor_data->hud.gobj->hsd_object;
    JOBJ_AddSetAnim(hud_jobj, meteor_data->assets->time_bar, 1);
    JOBJ_ReqAnimAll(hud_jobj, 0);
    JOBJ_AnimAll(hud_jobj);

    return;
}
// Think Function
void Event_Think(GOBJ *event)
{

    MeteorData *meteor_data = event->userdata;

    GOBJ *hmn_gobj = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn_gobj->userdata;

    //Arrows_Think(event);
    HUD_Think(event);

    // wait for tut to end
    if (meteor_data->is_tutorial)
    {
        if ((evco_data->Scenario_CheckEnd()))
        {
            meteor_data->is_tutorial = 0;

            // show hud after tutorial
            JOBJ *hud_jobj = meteor_data->hud.gobj->hsd_object;
            JOBJ_AddSetAnim(hud_jobj, meteor_data->assets->time_bar, 0);
            JOBJ_ReqAnimAll(hud_jobj, 0);
            JOBJ_AnimAll(hud_jobj);

            // hide arrow and input text
            JOBJ_SetFlags(meteor_data->hud.input_text, JOBJ_HIDDEN);
            JOBJ_SetFlags(meteor_data->hud.input_arrow, JOBJ_HIDDEN);
        }
    }
    else
    {
        // reset
        if ((hmn_data->flags.dead) ||
            (hmn_data->phys.air_state == 0) ||
            (hmn_data->state_id == ASID_CLIFFWAIT))
            evco_data->Scenario_Exec(&reset_scn, 0);
    }

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
    arrow_jobj->trans.X = 115;
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

            if ((fd->flags.sleep == 0) &&
                (fd->flags.dead == 0) &&
                (fd->phys.pos.X < (pos.X + (22))) &&
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
    GOBJ *hud_gobj = JOBJ_LoadSet(0, meteor_data->assets->time_bar, 0, 0, 11, 8, 1, 0);
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

                    // check if failed
                    bp();
                    if (hmn_data->input.timer_specialhi_lockout < (ftcommon->meteor_lockout) || // less than 40 frames since last input
                        (meteor_data->timer < ftcommon->meteor_delay))                          // within first X frames of meteor
                    {
                        // failed up b
                        SFX_PlayCommon(3);
                    }
                    else if (hmn_data->input.timer_specialhi_lockout >= (ftcommon->meteor_lockout))
                    {
                        // ok i up b'd
                        SFX_PlayCommon(1);
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