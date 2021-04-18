#include "common.h"
//#include <stdarg.h>

////////////////////////
/// Static Variables ///
///////////////////////

static EventCommonData stc_evco_data = {
    .event_desc = 0,
    .menu_assets = 0,
    .event_gobj = 0,
    .menu_gobj = 0,
    .game_timer = 0,
    .hide_menu = 0,
    .Savestate_Save = Savestate_Save,
    .Savestate_Load = Savestate_Load,
    .Message_Display = Message_Display,
    .Tip_Display = Tip_Display,
    .Tip_Destroy = Tip_Destroy,
    .Dialogue_Display = Dialogue_Create,
    .Dialogue_CheckEnd = Dialogue_CheckEnd,
    .Scenario_Exec = Scenario_Exec,
    .Scenario_CheckEnd = Scenario_CheckEnd,
    .savestate = 0,
};
static int *eventDataBackup;
static Savestate *stc_savestate;
static EventDesc *static_eventInfo;
static MenuData *static_menuData;
static TipMgr stc_tipmgr;

//////////////////////
/// Hook Functions ///
//////////////////////

void OnLoad(ArchiveInfo *archive)
{

    // save pointer to stc_evco_data
    *evco_data_ptr = &stc_evco_data;

    // Create a gobj to track match time
    stc_evco_data.game_timer = 0;
    GOBJ *timer_gobj = GObj_Create(0, 7, 0);
    GObj_AddProc(timer_gobj, Event_IncTimer, 0);

    // init savestate struct
    stc_savestate = calloc(sizeof(Savestate));
    eventDataBackup = calloc(EVENT_DATASIZE);
    stc_savestate->is_exist = 0;
    stc_evco_data.savestate = stc_savestate;

    // init event menu assets
    stc_evco_data.menu_assets = File_GetSymbol(archive, "evMenu");

    // Store update function
    HSD_Update *update = HSD_UPDATE;
    update->onFrame = EventUpdate;

    Message_Init();
    Tip_Init();
    Scenario_Init(archive);

    // disable player inputs for 1f (avoid instant buffer attacks)
    // this is a mess so im gonna deal with it later...
    // inputs are enabled by the game after startmelee is called
    // unless the READY graphic is being shown...
    // i would have to schedule a gobj to run after this happens and
    // disable inputs for 1f, then re-enable next frame =/
    /*
    GOBJList *gobj_list;
    GOBJ *ft_gobj = gobj_list->fighter;
    while (ft_gobj)
    {
        FighterData *ft_data = ft_gobj->userdata;
        ft_data->flags.x221d_5 = 1;
    }

    // gobj to re-enable inputs after processed once
    GOBJ *input_gobj = GObj_Create(0, 7, 0);
    GObj_AddProc(input_gobj, Event_InputEnable, 0);
    */

    return;
}

///////////////////////////////
/// Miscellaneous Functions ///
///////////////////////////////

int Savestate_Save(Savestate *savestate)
{
    typedef struct BackupQueue
    {
        GOBJ *fighter;
        FighterData *fighter_data;
    } BackupQueue;

#if TM_DEBUG > 0
    int save_pre_tick = OSGetTick();
#endif

    // ensure no players are in problematic states
    int canSave = 1;
    GOBJ **gobj_list = R13_PTR(GOBJLIST);
    GOBJ *fighter = gobj_list[8];
    while (fighter != 0)
    {

        FighterData *fighter_data = fighter->userdata;

        if ((fighter_data->cb.OnDeath_Persist != 0) ||
            (fighter_data->cb.OnDeath_State != 0) ||
            (fighter_data->cb.OnDeath3 != 0) ||
            (fighter_data->item_held != 0) ||
            (fighter_data->x1978 != 0) ||
            (fighter_data->accessory != 0) ||
            ((fighter_data->kind == 8) && ((fighter_data->state_id >= 342) && (fighter_data->state_id <= 344)))) // hardcode ness' usmash because it doesnt destroy the yoyo via onhit callback...
        {
            // cannot save
            canSave = 0;
            break;
        }

        fighter = fighter->next;
    }

    // loop through all players
    int isSaved = 0;
    if (canSave == 1)
    {

        savestate->is_exist = 1;

        // save frame
        savestate->frame = stc_evco_data.game_timer;

        // save event data
        memcpy(&savestate->event_data, stc_evco_data.event_gobj->userdata, sizeof(savestate->event_data));

        // backup all players
        for (int i = 0; i < 6; i++)
        {
            // get fighter gobjs
            BackupQueue queue[2];
            for (int j = 0; j < 2; j++)
            {
                GOBJ *fighter = 0;
                FighterData *fighter_data = 0;

                // get fighter gobj and data if they exist
                fighter = Fighter_GetSubcharGObj(i, j);
                if (fighter != 0)
                    fighter_data = fighter->userdata;

                // store fighter pointers
                queue[j].fighter = fighter;
                queue[j].fighter_data = fighter_data;
            }

            // if the main fighter exists
            if (queue[0].fighter != 0)
            {

                FtState *ft_state = &savestate->ft_state[i];

                isSaved = 1;

                // save playerblock
                Playerblock *playerblock = Fighter_GetPlayerblock(queue[0].fighter_data->ply);
                memcpy(&ft_state->player_block, playerblock, sizeof(Playerblock));

                // save stale moves
                int *stale_queue = Fighter_GetStaleMoveTable(queue[0].fighter_data->ply);
                memcpy(&ft_state->stale_queue, stale_queue, sizeof(ft_state->stale_queue));

                // backup each subfighters data
                for (int j = 0; j < 2; j++)
                {
                    // if exists
                    if (queue[j].fighter != 0)
                    {

                        FtStateData *ft_data = &ft_state->data[j];
                        FighterData *fighter_data = queue[j].fighter_data;

                        // backup to ft_state
                        ft_data->is_exist = 1;
                        ft_data->state = fighter_data->state_id;
                        ft_data->facing_direction = fighter_data->facing_direction;
                        ft_data->frame = fighter_data->state.frame;
                        ft_data->rate = fighter_data->state.rate;
                        ft_data->blend = fighter_data->state.blend;
                        memcpy(&ft_data->phys, &fighter_data->phys, sizeof(fighter_data->phys));                               // copy physics
                        memcpy(&ft_data->color, &fighter_data->color, sizeof(fighter_data->color));                            // copy color overlay
                        memcpy(&ft_data->input, &fighter_data->input, sizeof(fighter_data->input));                            // copy inputs
                        memcpy(&ft_data->coll_data, &fighter_data->coll_data, sizeof(fighter_data->coll_data));                // copy collision
                        memcpy(&ft_data->cameraBox, fighter_data->cameraBox, sizeof(CameraBox));                               // copy camerabox
                        memcpy(&ft_data->hitbox, &fighter_data->hitbox, sizeof(fighter_data->hitbox));                         // copy hitbox
                        memcpy(&ft_data->throw_hitbox, &fighter_data->throw_hitbox, sizeof(fighter_data->throw_hitbox));       // copy hitbox
                        memcpy(&ft_data->unk_hitbox, &fighter_data->unk_hitbox, sizeof(fighter_data->unk_hitbox));             // copy hitbox
                        memcpy(&ft_data->flags, &fighter_data->flags, sizeof(fighter_data->flags));                            // copy flags
                        memcpy(&ft_data->fighter_var, &fighter_data->fighter_var, sizeof(fighter_data->fighter_var));          // copy var
                        memcpy(&ft_data->state_var, &fighter_data->state_var, sizeof(fighter_data->state_var));                // copy var
                        memcpy(&ft_data->ftcmd_var, &fighter_data->ftcmd_var, sizeof(fighter_data->ftcmd_var));                // copy var
                        memcpy(&ft_data->jump, &fighter_data->jump, sizeof(fighter_data->jump));                               // copy var
                        memcpy(&ft_data->smash, &fighter_data->smash, sizeof(fighter_data->smash));                            // copy var
                        memcpy(&ft_data->hurtstatus, &fighter_data->hurtstatus, sizeof(fighter_data->hurtstatus));             // copy var
                        memcpy(&ft_data->shield, &fighter_data->shield, sizeof(fighter_data->shield));                         // copy hitbox
                        memcpy(&ft_data->shield_bubble, &fighter_data->shield_bubble, sizeof(fighter_data->shield_bubble));    // copy hitbox
                        memcpy(&ft_data->reflect_bubble, &fighter_data->reflect_bubble, sizeof(fighter_data->reflect_bubble)); // copy hitbox
                        memcpy(&ft_data->absorb_bubble, &fighter_data->absorb_bubble, sizeof(fighter_data->absorb_bubble));    // copy hitbox
                        memcpy(&ft_data->reflect_hit, &fighter_data->reflect_hit, sizeof(fighter_data->reflect_hit));          // copy hitbox
                        memcpy(&ft_data->absorb_hit, &fighter_data->absorb_hit, sizeof(fighter_data->absorb_hit));             // copy hitbox

                        // copy dmg
                        memcpy(&ft_data->dmg, &fighter_data->dmg, sizeof(fighter_data->dmg));
                        ft_data->dmg.source = GOBJToID(ft_data->dmg.source);

                        // copy grab
                        memcpy(&ft_data->grab, &fighter_data->grab, sizeof(fighter_data->grab));
                        ft_data->grab.attacker = GOBJToID(ft_data->grab.attacker);
                        ft_data->grab.victim = GOBJToID(ft_data->grab.victim);

                        // copy callbacks
                        memcpy(&ft_data->cb, &fighter_data->cb, sizeof(fighter_data->cb)); // copy hitbox

                        // convert hitbox pointers
                        for (int k = 0; k < (sizeof(fighter_data->hitbox) / sizeof(ftHit)); k++)
                        {

                            ft_data->hitbox[k].bone = BoneToID(fighter_data, ft_data->hitbox[k].bone);
                            for (int l = 0; l < (sizeof(fighter_data->hitbox->victims) / sizeof(HitVictim)); l++) // pointers to hitbox victims
                            {
                                ft_data->hitbox[k].victims[l].victim_data = FtDataToID(ft_data->hitbox[k].victims[l].victim_data);
                            }
                        }
                        for (int k = 0; k < (sizeof(fighter_data->throw_hitbox) / sizeof(ftHit)); k++)
                        {
                            ft_data->throw_hitbox[k].bone = BoneToID(fighter_data, ft_data->throw_hitbox[k].bone);
                            for (int l = 0; l < (sizeof(fighter_data->throw_hitbox->victims) / sizeof(HitVictim)); l++) // pointers to hitbox victims
                            {
                                ft_data->throw_hitbox[k].victims[l].victim_data = FtDataToID(ft_data->throw_hitbox[k].victims[l].victim_data);
                            }
                        }

                        ft_data->unk_hitbox.bone = BoneToID(fighter_data, ft_data->unk_hitbox.bone);
                        for (int k = 0; k < (sizeof(fighter_data->unk_hitbox.victims) / sizeof(HitVictim)); k++) // pointers to hitbox victims
                        {

                            ft_data->unk_hitbox.victims[k].victim_data = FtDataToID(ft_data->unk_hitbox.victims[k].victim_data);
                        }

                        // copy XRotN rotation
                        s8 XRotN_id = Fighter_BoneLookup(fighter_data, XRotN);
                        if (XRotN_id != -1)
                        {
                            ft_data->XRotN_rot = fighter_data->bones[XRotN_id].joint->rot;
                        }
                    }
                }
            }
        }
    }

    // Play SFX
    if (isSaved == 0)
    {
        SFX_PlayCommon(3);
    }
    if (isSaved == 1)
    {
        // play sfx
        SFX_PlayCommon(1);

        // if not in frame advance, flash screen. I wrote it like this because the second condition kept getting optimized out
        if ((Pause_CheckStatus(0) != 1))
        {
            if ((Pause_CheckStatus(1) != 2))
            {
                ScreenFlash_Create(2, 0);
            }
        }
    }

#if TM_DEBUG > 0
    int save_post_tick = OSGetTick();
    int save_time = OSTicksToMilliseconds(save_post_tick - save_pre_tick);
    OSReport("processed save in %dms\n", save_time);
#endif

    return isSaved;
}
int Savestate_Load(Savestate *savestate)
{
    typedef struct BackupQueue
    {
        GOBJ *fighter;
        FighterData *fighter_data;
    } BackupQueue;

#if TM_DEBUG > 0
    int load_pre_tick = OSGetTick();
#endif

    // loop through all players
    int isLoaded = 0;
    for (int i = 0; i < 6; i++)
    {
        // get fighter gobjs
        BackupQueue queue[2];
        for (int j = 0; j < 2; j++)
        {
            GOBJ *fighter = 0;
            FighterData *fighter_data = 0;

            // get fighter gobj and data if they exist
            fighter = Fighter_GetSubcharGObj(i, j);
            if (fighter != 0)
                fighter_data = fighter->userdata;

            // store fighter pointers
            queue[j].fighter = fighter;
            queue[j].fighter_data = fighter_data;
        }

        // if the main fighter and backup exists
        if ((queue[0].fighter != 0) && (savestate->ft_state[i].data[0].is_exist == 1))
        {

            FtState *ft_state = &savestate->ft_state[i];

            isLoaded = 1;

            // restore playerblock
            Playerblock *playerblock = Fighter_GetPlayerblock(queue[0].fighter_data->ply);
            GOBJ *fighter_gobj[2];
            fighter_gobj[0] = playerblock->fighterData;
            fighter_gobj[1] = playerblock->fighterDataSub;
            memcpy(playerblock, &ft_state->player_block, sizeof(Playerblock));
            playerblock->fighterData = fighter_gobj[0];
            playerblock->fighterDataSub = fighter_gobj[1];

            // restore stale moves
            int *stale_queue = Fighter_GetStaleMoveTable(queue[0].fighter_data->ply);
            memcpy(stale_queue, &ft_state->stale_queue, sizeof(ft_state->stale_queue));

            // restore fighter data
            for (int j = 0; j < 2; j++)
            {

                GOBJ *fighter = queue[j].fighter;

                if (fighter != 0)
                {

                    // get state
                    FtStateData *ft_data = &ft_state->data[j];
                    FighterData *fighter_data = queue[j].fighter_data;

                    // sleep
                    Fighter_EnterSleep(fighter, 0);

                    fighter_data->state_id = ft_data->state;
                    fighter_data->facing_direction = ft_data->facing_direction;
                    fighter_data->state.frame = ft_data->frame;
                    fighter_data->state.rate = ft_data->rate;
                    fighter_data->state.blend = ft_data->blend;

                    // restore phys struct
                    memcpy(&fighter_data->phys, &ft_data->phys, sizeof(fighter_data->phys)); // copy physics

                    // restore inputs
                    memcpy(&fighter_data->input, &ft_data->input, sizeof(fighter_data->input)); // copy inputs

                    // restore coll data
                    CollData *thiscoll = &fighter_data->coll_data;
                    CollData *savedcoll = &ft_data->coll_data;
                    GOBJ *gobj = thiscoll->gobj;                                                            // 0x0
                    JOBJ *joint_1 = thiscoll->joint_1;                                                      // 0x108
                    JOBJ *joint_2 = thiscoll->joint_2;                                                      // 0x10c
                    JOBJ *joint_3 = thiscoll->joint_3;                                                      // 0x110
                    JOBJ *joint_4 = thiscoll->joint_4;                                                      // 0x114
                    JOBJ *joint_5 = thiscoll->joint_5;                                                      // 0x118
                    JOBJ *joint_6 = thiscoll->joint_6;                                                      // 0x11c
                    JOBJ *joint_7 = thiscoll->joint_7;                                                      // 0x120
                    memcpy(&fighter_data->coll_data, &ft_data->coll_data, sizeof(fighter_data->coll_data)); // copy collision
                    thiscoll->gobj = gobj;
                    thiscoll->joint_1 = joint_1;
                    thiscoll->joint_2 = joint_2;
                    thiscoll->joint_3 = joint_3;
                    thiscoll->joint_4 = joint_4;
                    thiscoll->joint_5 = joint_5;
                    thiscoll->joint_6 = joint_6;
                    thiscoll->joint_7 = joint_7;

                    // restore hitboxes
                    memcpy(&fighter_data->hitbox, &ft_data->hitbox, sizeof(fighter_data->hitbox));                   // copy hitbox
                    memcpy(&fighter_data->throw_hitbox, &ft_data->throw_hitbox, sizeof(fighter_data->throw_hitbox)); // copy hitbox
                    memcpy(&fighter_data->unk_hitbox, &ft_data->unk_hitbox, sizeof(fighter_data->unk_hitbox));       // copy hitbox

                    // copy grab
                    memcpy(&fighter_data->grab, &ft_data->grab, sizeof(fighter_data->grab));
                    fighter_data->grab.attacker = IDToGOBJ(fighter_data->grab.attacker);
                    fighter_data->grab.victim = IDToGOBJ(fighter_data->grab.victim);

                    // convert pointers
                    for (int k = 0; k < (sizeof(fighter_data->hitbox) / sizeof(ftHit)); k++)
                    {
                        fighter_data->hitbox[k].bone = IDToBone(fighter_data, ft_data->hitbox[k].bone);
                        for (int l = 0; l < (sizeof(fighter_data->hitbox->victims) / sizeof(HitVictim)); l++) // pointers to hitbox victims
                        {
                            fighter_data->hitbox[k].victims[l].victim_data = IDToFtData(ft_data->hitbox[k].victims[l].victim_data);
                        }
                    }
                    for (int k = 0; k < (sizeof(fighter_data->throw_hitbox) / sizeof(ftHit)); k++)
                    {
                        fighter_data->throw_hitbox[k].bone = IDToBone(fighter_data, ft_data->throw_hitbox[k].bone);
                        for (int l = 0; l < (sizeof(fighter_data->throw_hitbox->victims) / sizeof(HitVictim)); l++) // pointers to hitbox victims
                        {
                            fighter_data->throw_hitbox[k].victims[l].victim_data = IDToFtData(ft_data->throw_hitbox[k].victims[l].victim_data);
                        }
                    }
                    fighter_data->unk_hitbox.bone = IDToBone(fighter_data, ft_data->unk_hitbox.bone);
                    for (int k = 0; k < (sizeof(fighter_data->unk_hitbox.victims) / sizeof(HitVictim)); k++) // pointers to hitbox victims
                    {

                        fighter_data->unk_hitbox.victims[k].victim_data = IDToFtData(ft_data->unk_hitbox.victims[k].victim_data);
                    }

                    // restore fighter variables
                    memcpy(&fighter_data->fighter_var, &ft_data->fighter_var, sizeof(fighter_data->fighter_var)); // copy hitbox

                    // zero pointer to cached animations to force anim load (fixes fall crash)
                    fighter_data->anim_curr_ARAM = 0;
                    fighter_data->anim_persist_ARAM = 0;

                    // enter backed up state
                    GOBJ *anim_source = 0;
                    if (fighter_data->flags.is_thrown == 1)
                        anim_source = fighter_data->grab.attacker;
                    Fighter_SetAllHurtboxesNotUpdated(fighter);
                    ActionStateChange(ft_data->frame, ft_data->rate, -1, fighter, ft_data->state, 0, anim_source);
                    fighter_data->state.blend = 0;

                    // restore XRotN rotation
                    s8 XRotN_id = Fighter_BoneLookup(fighter_data, XRotN);
                    if (XRotN_id != -1)
                    {
                        fighter_data->bones[XRotN_id].joint->rot = ft_data->XRotN_rot;
                    }

                    // restore state variables
                    memcpy(&fighter_data->state_var, &ft_data->state_var, sizeof(fighter_data->state_var)); // copy hitbox

                    // restore ftcmd variables
                    memcpy(&fighter_data->ftcmd_var, &ft_data->ftcmd_var, sizeof(fighter_data->ftcmd_var)); // copy hitbox

                    // restore damage variables
                    memcpy(&fighter_data->dmg, &ft_data->dmg, sizeof(fighter_data->dmg)); // copy hitbox
                    fighter_data->dmg.source = IDToGOBJ(fighter_data->dmg.source);

                    // restore jump variables
                    memcpy(&fighter_data->jump, &ft_data->jump, sizeof(fighter_data->jump)); // copy hitbox

                    // restore flags
                    memcpy(&fighter_data->flags, &ft_data->flags, sizeof(fighter_data->flags)); // copy hitbox

                    // restore hurtstatus variables
                    memcpy(&fighter_data->hurtstatus, &ft_data->hurtstatus, sizeof(fighter_data->hurtstatus)); // copy hitbox

                    // update jobj position
                    JOBJ *fighter_jobj = fighter->hsd_object;
                    fighter_jobj->trans = fighter_data->phys.pos;
                    // dirtysub their jobj
                    JOBJ_SetMtxDirtySub(fighter_jobj);

                    // update hurtbox position
                    Fighter_UpdateHurtboxes(fighter_data);

                    // remove color overlay
                    Fighter_ColorRemove(fighter_data, 9);

                    // restore color
                    for (int k = 0; k < (sizeof(fighter_data->color) / sizeof(ColorOverlay)); k++)
                    {

                        ColorOverlay *thiscolor = &fighter_data->color[k];
                        ColorOverlay *savedcolor = &ft_data->color[k];

                        // backup nono pointers
                        int *ptr1 = thiscolor->ptr1;
                        int *ptr2 = thiscolor->ptr2;
                        int *alloc = thiscolor->alloc;

                        // mempcy entire
                        memcpy(thiscolor, savedcolor, sizeof(ColorOverlay));

                        // restore nono pointers
                        thiscolor->ptr1 = ptr1;
                        thiscolor->ptr2 = ptr2;
                        thiscolor->alloc = alloc;
                    }

                    // restore smash variables
                    memcpy(&fighter_data->smash, &ft_data->smash, sizeof(fighter_data->smash)); // copy hitbox

                    // restore shield/reflect/absorb variables
                    memcpy(&fighter_data->shield, &ft_data->shield, sizeof(fighter_data->shield));                         // copy hitbox
                    memcpy(&fighter_data->shield_bubble, &ft_data->shield_bubble, sizeof(fighter_data->shield_bubble));    // copy hitbox
                    memcpy(&fighter_data->reflect_bubble, &ft_data->reflect_bubble, sizeof(fighter_data->reflect_bubble)); // copy hitbox
                    memcpy(&fighter_data->absorb_bubble, &ft_data->absorb_bubble, sizeof(fighter_data->absorb_bubble));    // copy hitbox
                    memcpy(&fighter_data->reflect_hit, &ft_data->reflect_hit, sizeof(fighter_data->reflect_hit));          // copy hitbox
                    memcpy(&fighter_data->absorb_hit, &ft_data->absorb_hit, sizeof(fighter_data->absorb_hit));             // copy hitbox

                    // restore callback functions
                    memcpy(&fighter_data->cb, &ft_data->cb, sizeof(fighter_data->cb)); // copy hitbox

                    // stop player SFX
                    SFX_StopAllFighterSFX(fighter_data);

                    // update colltest frame
                    fighter_data->coll_data.coll_test = *stc_colltest;

                    // restore camera box
                    CameraBox *thiscam = fighter_data->cameraBox;
                    CameraBox *savedcam = &ft_data->cameraBox;
                    void *alloc = thiscam->alloc;
                    CameraBox *next = thiscam->next;
                    memcpy(thiscam, savedcam, sizeof(CameraBox)); // copy camerabox
                    thiscam->alloc = alloc;
                    thiscam->next = next;

                    // update their IK
                    Fighter_UpdateIK(fighter);

                    // if shield is up, update shield
                    if ((fighter_data->state_id >= ASID_GUARDON) && (fighter_data->state_id <= ASID_GUARDREFLECT))
                    {
                        // get gfx ID
                        int shieldGFX;
                        static u16 ShieldGFXLookup[] = {1047, 1048, -1, 1049, -1}; // covers GUARDON -> GUARDREFLECT
                        shieldGFX = ShieldGFXLookup[fighter_data->state_id - ASID_GUARDON];

                        // create GFX
                        int color_index = Fighter_GetShieldColorIndex(fighter_data->ply);
                        GXColor *shieldColors = R13_PTR(-0x5194);
                        GXColor *shieldColor = &shieldColors[color_index];
                        JOBJ *shieldBone = fighter_data->bones[fighter_data->ftData->modelLookup[0x11]].joint;
                        int shieldColorParam = (shieldColor->r << 16) | (shieldColor->b << 8) | (shieldColor->g);
                        Effect_SpawnSync(shieldGFX, fighter, shieldBone, shieldColorParam);

                        Fighter_UpdateShieldGFX(fighter, 1);
                    }

                    // process dynamics

#if TM_DEBUG > 0
                    int dyn_pre_tick = OSGetTick();
#endif
                    int dyn_proc_num = 45;

                    // simulate dynamics a bunch to fall in place
                    for (int d = 0; d < dyn_proc_num; d++)
                    {
                        Fighter_ProcDynamics(fighter);
                    }

#if TM_DEBUG > 0
                    int dyn_post_tick = OSGetTick();
                    int dyn_time = OSTicksToMilliseconds(dyn_post_tick - dyn_pre_tick);
                    OSReport("processed dyn %d times in %dms\n", dyn_proc_num, dyn_time);
#endif

                    // remove all items belonging to this fighter
                    GOBJList *gobj_list = *stc_gobj_list;
                    GOBJ *item = gobj_list->item;
                    while (item != 0)
                    {

                        // get next
                        GOBJ *next_item = item->next;

                        // check to delete
                        ItemData *item_data = item->userdata;
                        if (fighter == item_data->fighter_gobj)
                        {
                            // destroy it
                            Item_Destroy(item);
                        }

                        item = next_item;
                    }
                }
            }

            sizeof(FtStateData);

            // check to recreate HUD
            MatchHUD *hud = &stc_matchhud[i];

            // check if fighter is perm dead
            if (Match_CheckIfStock() == 1)
            {
                // remove HUD if no stocks left
                if (Fighter_GetStocks(i) <= 0)
                {
                    hud->is_removed = 0;
                }
            }

            // check to create it
            if (hud->is_removed == 1)
            {
                Match_CreateHUD(i);
            }

            // snap camera to the new positions
            Match_CorrectCamera();

            // stop crowd cheer
            SFX_StopCrowd();
        }
    }

    // Restore event data and Play SFX
    if (isLoaded == 0)
    {
        SFX_PlayCommon(3);
    }
    if (isLoaded == 1)
    {

        // restore frame
        Match *match = stc_match;
        match->time_frames = savestate->frame;
        stc_evco_data.game_timer = savestate->frame;

        // update timer
        int frames = match->time_frames - 1; // this is because the scenethink function runs once before the gobj procs do
        match->time_seconds = frames / 60;
        match->time_ms = frames % 60;

        // restore event data
        memcpy(stc_evco_data.event_gobj->userdata, &savestate->event_data, sizeof(savestate->event_data));

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

        // play sfx
        SFX_PlayCommon(0);
    }

#if TM_DEBUG > 0
    int load_post_tick = OSGetTick();
    int load_time = OSTicksToMilliseconds(load_post_tick - load_pre_tick);
    OSReport("processed load in %dms\n", load_time);
    sizeof(FtState);
#endif

    return isLoaded;
}
void Update_Savestates()
{

    // not when pause menu is showing
    if (Pause_CheckStatus(1) != 2)
    {
        // loop through all humans
        for (int i = 0; i < 6; i++)
        {
            // check if fighter exists
            GOBJ *fighter = Fighter_GetGObj(i);
            if (fighter != 0)
            {
                // get fighter data
                FighterData *fighter_data = fighter->userdata;
                HSD_Pad *pad = PadGet(fighter_data->ply, PADGET_MASTER);

                // check for savestate
                int blacklist = (HSD_BUTTON_DPAD_DOWN | HSD_BUTTON_DPAD_UP | HSD_TRIGGER_Z | HSD_TRIGGER_R | HSD_BUTTON_A | HSD_BUTTON_B | HSD_BUTTON_X | HSD_BUTTON_Y | HSD_BUTTON_START);
                if (((pad->down & HSD_BUTTON_DPAD_RIGHT) != 0) && ((pad->held & (blacklist)) == 0))
                {
                    // save state
                    Savestate_Save(stc_savestate);
                }
                else if (((pad->down & HSD_BUTTON_DPAD_LEFT) != 0) && ((pad->held & (blacklist)) == 0))
                {
                    // load state
                    Savestate_Load(stc_savestate);
                }
            }
        }
    }

    return;
}
int GOBJToID(GOBJ *gobj)
{
    // ensure valid pointer
    if (gobj == 0)
        return -1;

    // ensure its a fighter
    if (gobj->entity_class != 4)
        return -1;

    // access the data
    FighterData *ft_data = gobj->userdata;
    u8 ply = ft_data->ply;
    u8 ms = ft_data->flags.ms;

    return ((ply << 4) | ms);
}
int FtDataToID(FighterData *fighter_data)
{
    // ensure valid pointer
    if (fighter_data == 0)
        return -1;

    // ensure its a fighter
    if (fighter_data->fighter == 0)
        return -1;

    // get ply and ms
    u8 ply = fighter_data->ply;
    u8 ms = fighter_data->flags.ms;

    return ((ply << 4) | ms);
}
int BoneToID(FighterData *fighter_data, JOBJ *bone)
{

    // ensure bone exists
    if (bone == 0)
        return -1;

    int bone_id = -1;

    // painstakingly look for a match
    for (int i = 0; i < fighter_data->bone_num; i++)
    {
        if (bone == fighter_data->bones[i].joint)
        {
            bone_id = i;
            break;
        }
    }

#if TM_DEBUG > 0
    // no bone found
    if (bone_id == -1)
    {
        assert("no bone found");
    }
#endif

    return bone_id;
}
GOBJ *IDToGOBJ(int id)
{
    // ensure valid pointer
    if (id == -1)
        return 0;

    // get ply and ms
    u8 ply = (id >> 4) & 0xF;
    u8 ms = id & 0xF;

    // get the gobj for this fighter
    GOBJ *gobj = Fighter_GetSubcharGObj(ply, ms);

    return gobj;
}
FighterData *IDToFtData(int id)
{
    // ensure valid pointer
    if (id == -1)
        return 0;

    // get ply and ms
    u8 ply = (id >> 4) & 0xF;
    u8 ms = id & 0xF;

    // get the gobj for this fighter
    GOBJ *gobj = Fighter_GetSubcharGObj(ply, ms);
    FighterData *fighter_data = gobj->userdata;

    return fighter_data;
}
JOBJ *IDToBone(FighterData *fighter_data, int id)
{
    // ensure valid pointer
    if (id == -1)
        return 0;

    // get the bone
    JOBJ *bone = fighter_data->bones[id].joint;

    return bone;
}

void Event_IncTimer(GOBJ *gobj)
{
    stc_evco_data.game_timer++;
    return;
}
/*
void Event_InputEnable(GOBJ *gobj)
{

    // re-enable inputs for all players
    GOBJList *gobj_list;
    GOBJ *ft_gobj = gobj_list->fighter;
    while (ft_gobj)
    {
        FighterData *ft_data = ft_gobj->userdata;
        ft_data->flags.x221d_5 = 0;
    }
    // self destruct
    GObj_Destroy(gobj);

    return;
}
*/

// Message Functions
void Message_Init()
{

    // create cobj
    GOBJ *cam_gobj = GObj_Create(19, 20, 0);
    COBJDesc *cam_desc = stc_evco_data.menu_assets->hud_cobjdesc;
    COBJ *cam_cobj = COBJ_LoadDescSetScissor(cam_desc);
    cam_cobj->scissor_bottom = 400;
    // init camera
    GObj_AddObject(cam_gobj, R13_U8(-0x3E55), cam_cobj); //R13_U8(-0x3E55)
    GOBJ_InitCamera(cam_gobj, Message_CObjThink, MSG_COBJLGXPRI);
    cam_gobj->cobj_links = MSG_COBJLGXLINKS;

    // Create manager GOBJ
    GOBJ *mgr_gobj = GObj_Create(0, 7, 0);
    MsgMngrData *mgr_data = calloc(sizeof(MsgMngrData));
    GObj_AddUserData(mgr_gobj, 4, HSD_Free, mgr_data);
    GObj_AddProc(mgr_gobj, Message_Manager, 18);

    // create text canvas
    int canvas = Text_CreateCanvas(2, mgr_gobj, 14, 15, 0, MSG_GXLINK, MSGTEXT_GXPRI, 19);
    mgr_data->canvas = canvas;

    // store cobj
    mgr_data->cobj = cam_cobj;

    // store gobj pointer
    stc_msgmgr = mgr_gobj;

    return;
}
GOBJ *Message_Display(int msg_kind, int queue_num, int msg_color, char *format, ...)
{

    va_list args;

    MsgMngrData *mgr_data = stc_msgmgr->userdata;

    // Create GOBJ
    GOBJ *msg_gobj = GObj_Create(0, 7, 0);
    MsgData *msg_data = calloc(sizeof(MsgData));
    GObj_AddUserData(msg_gobj, 4, HSD_Free, msg_data);
    GObj_AddGXLink(msg_gobj, GXLink_Common, MSG_GXLINK, MSG_GXPRI);
    JOBJ *msg_jobj = JOBJ_LoadJoint(stc_evco_data.menu_assets->message);
    GObj_AddObject(msg_gobj, R13_U8(-0x3E55), msg_jobj);
    msg_data->lifetime = MSG_LIFETIME;
    msg_data->kind = msg_kind;
    msg_data->state = MSGSTATE_SHIFT;
    msg_data->anim_timer = MSGTIMER_SHIFT;
    msg_jobj->scale.X = MSGJOINT_SCALE;
    msg_jobj->scale.Y = MSGJOINT_SCALE;
    msg_jobj->scale.Z = MSGJOINT_SCALE;
    msg_jobj->trans.X = MSGJOINT_X;
    msg_jobj->trans.Y = MSGJOINT_Y;
    msg_jobj->trans.Z = MSGJOINT_Z;

    // Create text object
    Text *msg_text = Text_CreateText(2, mgr_data->canvas);
    msg_data->text = msg_text;
    msg_text->kerning = 1;
    msg_text->align = 1;
    msg_text->use_aspect = 1;
    msg_text->color = stc_msg_colors[msg_color];

    // adjust scale
    Vec3 scale = msg_jobj->scale;
    // background scale
    msg_jobj->scale = scale;
    // text scale
    msg_text->scale.X = (scale.X * 0.01) * MSGTEXT_BASESCALE;
    msg_text->scale.Y = (scale.Y * 0.01) * MSGTEXT_BASESCALE;
    msg_text->aspect.X = MSGTEXT_BASEWIDTH;

    JOBJ_SetMtxDirtySub(msg_jobj);

    // build string
    char buffer[(MSG_LINEMAX * MSG_CHARMAX) + 1];
    va_start(args, format);
    vsprintf(buffer, format, args);
    va_end(args);
    char *msg = &buffer;

    // count newlines
    int line_num = 1;
    int line_length_arr[MSG_LINEMAX];
    char *msg_cursor_prev, *msg_cursor_curr; // declare char pointers
    msg_cursor_prev = msg;
    msg_cursor_curr = strchr(msg_cursor_prev, '\n'); // check for occurrence
    while (msg_cursor_curr != 0)                     // if occurrence found, increment values
    {
        // check if exceeds max lines
        if (line_num >= MSG_LINEMAX)
            assert("MSG_LINEMAX exceeded!");

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
        if (line_length > MSG_CHARMAX)
            assert("MSG_CHARMAX exceeded!");

        // copy char array
        char msg_line[MSG_CHARMAX + 1];
        memcpy(msg_line, msg, line_length);

        // add null terminator
        msg_line[line_length] = '\0';

        // increment msg
        msg += (line_length + 1); // +1 to skip past newline

        // print line
        int y_base = (line_num - 1) * ((-1 * MSGTEXT_YOFFSET) / 2);
        int y_delta = (i * MSGTEXT_YOFFSET);
        Text_AddSubtext(msg_text, 0, y_base + y_delta, msg_line);
    }

    // Add to queue
    Message_Add(msg_gobj, queue_num);

    return msg_gobj;
}
void Message_Manager(GOBJ *mngr_gobj)
{
    MsgMngrData *mgr_data = mngr_gobj->userdata;

    // Iterate through each queue
    for (int i = 0; i < MSGQUEUE_NUM; i++)
    {
        GOBJ **msg_queue = &mgr_data->msg_queue[i];

        // anim update (time based logic)
        for (int j = (MSGQUEUE_SIZE - 2); j >= 0; j--) // iterate through backwards (because deletions)
        {
            GOBJ *this_msg_gobj = msg_queue[j];

            // if message exists
            if (this_msg_gobj != 0)
            {
                MsgData *this_msg_data = this_msg_gobj->userdata;
                Text *this_msg_text = this_msg_data->text;
                JOBJ *this_msg_jobj = this_msg_gobj->hsd_object;

                // check if the message moved this frame
                if (this_msg_data->orig_index != j)
                {
                    this_msg_data->orig_index = j;              // moved so update this
                    this_msg_data->state = MSGSTATE_SHIFT;      // enter shift
                    this_msg_data->anim_timer = MSGTIMER_SHIFT; // shift timer
                }

                // decrement state timer if above 0
                if (this_msg_data->anim_timer > 0)
                    this_msg_data->anim_timer--;

                switch (this_msg_data->state)
                {
                case (MSGSTATE_WAIT):
                case (MSGSTATE_SHIFT):
                {

                    // increment alive time
                    this_msg_data->alive_timer++;

                    // if lifetime is ended, enter delete state
                    if (this_msg_data->alive_timer >= this_msg_data->lifetime)
                    {
                        // if using frame advance, instantly remove this message
                        if (Pause_CheckStatus(0) == 1)
                        {
                            Message_Destroy(msg_queue, j);
                        }
                        else
                        {
                            this_msg_data->state = MSGSTATE_DELETE;
                            this_msg_data->anim_timer = MSGTIMER_DELETE;
                        }
                    }

                    break;
                }

                case (MSGSTATE_DELETE):
                {

                    // if timer is ended, remove the message
                    if ((this_msg_data->anim_timer <= 0))
                    {
                        Message_Destroy(msg_queue, j);
                    }

                    break;
                }
                }
            }
        }

        // position update (update messages' onscreen positions)
        for (int j = 0; j < MSGQUEUE_SIZE; j++)
        {
            GOBJ *this_msg_gobj = msg_queue[j];

            // if message exists
            if (this_msg_gobj != 0)
            {
                MsgData *this_msg_data = this_msg_gobj->userdata;
                Text *this_msg_text = this_msg_data->text;
                JOBJ *this_msg_jobj = this_msg_gobj->hsd_object;

                // Get the onscreen position for this queue
                Vec3 base_pos;
                Vec3 this_msg_pos;
                float pos_delta = stc_msg_queue_offsets[i];
                if (i < 6)
                {
                    Vec3 *hud_pos = Match_GetPlayerHUDPos(i);

                    base_pos.X = hud_pos->X;
                    base_pos.Y = hud_pos->Y + MSG_HUDYOFFSET;
                    base_pos.Z = hud_pos->Z;
                }
                else if (i == MSGQUEUE_GENERAL)
                {
                    base_pos = stc_msg_queue_general_pos;
                }
                this_msg_pos.X = base_pos.X; // Get this messages position

                switch (this_msg_data->state)
                {
                case (MSGSTATE_WAIT):
                case (MSGSTATE_SHIFT):
                {

                    // get time
                    float t = (((float)MSGTIMER_SHIFT - this_msg_data->anim_timer) / MSGTIMER_SHIFT);

                    // get initial and final position for animation
                    float final_pos = base_pos.Y + ((float)j * pos_delta);
                    float initial_pos = base_pos.Y + ((float)this_msg_data->prev_index * pos_delta);
                    if (Pause_CheckStatus(0) == 1) // if using frame advance, do not animate
                    {
                        this_msg_pos.Y = final_pos;
                    }
                    else
                    {
                        this_msg_pos.Y = (BezierBlend(t) * (final_pos - initial_pos)) + initial_pos;
                    }

                    Vec3 scale = this_msg_jobj->scale;

                    // BG position
                    this_msg_jobj->trans.X = this_msg_pos.X;
                    this_msg_jobj->trans.Y = this_msg_pos.Y;
                    // text position
                    this_msg_text->trans.X = this_msg_pos.X + (MSGTEXT_BASEX * (scale.X / 4.0));
                    this_msg_text->trans.Y = (this_msg_pos.Y * -1) + (MSGTEXT_BASEY * (scale.Y / 4.0));

                    // adjust bar
                    JOBJ *bar;
                    JOBJ_GetChild(this_msg_jobj, &bar, 4, -1);
                    bar->trans.X = (float)(this_msg_data->lifetime - this_msg_data->alive_timer) / (float)this_msg_data->lifetime;

                    break;
                }
                case (MSGSTATE_DELETE):
                {
                    // get time
                    float t = ((this_msg_data->anim_timer) / (float)MSGTIMER_DELETE);

                    Vec3 *scale = &this_msg_jobj->scale;
                    Vec3 *pos = &this_msg_jobj->trans;

                    // BG scale
                    scale->Y = BezierBlend(t);
                    // text scale
                    this_msg_text->scale.Y = (scale->Y * 0.01) * MSGTEXT_BASESCALE;
                    // text position
                    this_msg_text->trans.Y = (pos->Y * -1) + (MSGTEXT_BASEY * (scale->Y / 4.0));

                    break;
                }
                }

                JOBJ_SetMtxDirtySub(this_msg_jobj);
            }
        }
    }
}
void Message_Destroy(GOBJ **msg_queue, int msg_num)
{

    GOBJ *msg_gobj = msg_queue[msg_num];
    MsgData *msg_data = msg_gobj->userdata;

    // Destroy text
    Text *text = msg_data->text;
    if (text != 0)
        Text_Destroy(text);

    // Destroy GOBJ
    GObj_Destroy(msg_gobj);

    // null pointer
    msg_queue[msg_num] = 0;

    // shift others
    for (int i = (msg_num); i < (MSGQUEUE_SIZE - 1); i++)
    {
        msg_queue[i] = msg_queue[i + 1];

        // update its prev pos
        GOBJ *this_msg_gobj = msg_queue[i];
        if (this_msg_gobj != 0)
        {
            MsgData *this_msg_data = this_msg_gobj->userdata;
            this_msg_data->prev_index = i + 1; // prev position
        }
    }

    return;
}
void Message_Add(GOBJ *msg_gobj, int queue_num)
{

    MsgData *msg_data = msg_gobj->userdata;
    MsgMngrData *mgr_data = stc_msgmgr->userdata;
    GOBJ **msg_queue = &mgr_data->msg_queue[queue_num];

    // ensure this queue exists
    if (queue_num >= MSGQUEUE_NUM)
        assert("queue_num over!");

    // remove any existing messages of this kind
    for (int i = 0; i < MSGQUEUE_SIZE; i++)
    {
        GOBJ *this_msg_gobj = msg_queue[i];

        // if it exists
        if (this_msg_gobj != 0)
        {
            MsgData *this_msg_data = this_msg_gobj->userdata;

            // Remove this message if its of the same kind
            if ((this_msg_data->kind == msg_data->kind))
            {

                Message_Destroy(msg_queue, i); // remove the message and shift others

                // if the message we're replacing is the most recent message, instantly
                // remove the old one and do not animate the new one
                if (i == 0)
                {
                    msg_data->state = MSGSTATE_WAIT;
                    msg_data->anim_timer = 0;
                }
            }
        }
    }

    // first remove last message in the queue
    if (msg_queue[MSGQUEUE_SIZE - 1] != 0)
    {
        Message_Destroy(msg_queue, MSGQUEUE_SIZE - 1);
    }

    // shift other messages
    for (int i = (MSGQUEUE_SIZE - 2); i >= 0; i--)
    {
        // shift message
        msg_queue[i + 1] = msg_queue[i];

        // update its prev pos
        GOBJ *this_msg_gobj = msg_queue[i + 1];
        if (this_msg_gobj != 0)
        {
            MsgData *this_msg_data = this_msg_gobj->userdata;
            this_msg_data->prev_index = i; // prev position
        }
    }

    // add this new message
    msg_queue[0] = msg_gobj;

    // set prev pos to -1 (slides in)
    msg_data->prev_index = -1;
    msg_data->orig_index = 0;

    return;
}
void Message_CObjThink(GOBJ *gobj)
{

    if (Pause_CheckStatus(1) != 2)
        CObjThink_Common(gobj);

    return;
}

float BezierBlend(float t)
{
    return t * t * (3.0f - 2.0f * t);
}

// Tips Functions
void Tip_Init()
{
    // init static struct
    memset(&stc_tipmgr, 0, sizeof(TipMgr));

    // create tipmgr gobj
    GOBJ *tipmgr_gobj = GObj_Create(0, 7, 0);
    GObj_AddProc(tipmgr_gobj, Tip_Think, 18);

    return;
}
void Tip_Think(GOBJ *gobj)
{

    GOBJ *tip_gobj = stc_tipmgr.gobj;

    stc_evco_data.menu_assets->tip_jobj;

    // update tip
    if (tip_gobj != 0)
    {

        // update anim
        JOBJ_AnimAll(tip_gobj->hsd_object);

        // update text position
        JOBJ *tip_jobj;
        Vec3 tip_pos;
        JOBJ_GetChild(tip_gobj->hsd_object, &tip_jobj, TIP_TXTJOINT, -1);
        JOBJ_GetWorldPosition(tip_jobj, 0, &tip_pos);
        Text *tip_text = stc_tipmgr.text;
        tip_text->trans.X = tip_pos.X + (0 * (tip_jobj->scale.X / 4.0));
        tip_text->trans.Y = (tip_pos.Y * -1) + (0 * (tip_jobj->scale.Y / 4.0));

        // state logic
        switch (stc_tipmgr.state)
        {
        case (0): // in
        {
            // if anim is done, enter wait
            if (JOBJ_CheckAObjEnd(tip_gobj->hsd_object) == 0)
                stc_tipmgr.state = 1; // enter wait

            break;
        }
        case (1): // wait
        {
            // sub timer
            stc_tipmgr.lifetime--;
            if (stc_tipmgr.lifetime <= 0)
            {
                // apply exit anim
                JOBJ *tip_root = tip_gobj->hsd_object;
                JOBJ_RemoveAnimAll(tip_root);
                JOBJ_AddAnimAll(tip_root, stc_evco_data.menu_assets->tip_jointanim[1], 0, 0);
                JOBJ_ReqAnimAll(tip_root, 0);

                stc_tipmgr.state = 2; // enter wait
            }

            break;
        }
        case (2): // out
        {
            // if anim is done, destroy
            if (JOBJ_CheckAObjEnd(tip_gobj->hsd_object) == 0)
            {
                // remove text
                Text_Destroy(stc_tipmgr.text);
                GObj_Destroy(stc_tipmgr.gobj);
                stc_tipmgr.gobj = 0;
            }
            break;
        }
        }
    }

    return;
}
int Tip_Display(int lifetime, char *fmt, ...)
{

#define TIP_TXTSIZE 4.7
#define TIP_TXTSIZEX TIP_TXTSIZE * 0.85
#define TIP_TXTSIZEY TIP_TXTSIZE
#define TIP_TXTASPECT 2430
#define TIP_LINEMAX 5
#define TIP_CHARMAX 48

    va_list args;

    // if tip exists
    if (stc_tipmgr.gobj != 0)
    {
        // if tip is in the process of exiting
        if (stc_tipmgr.state == 2)
        {
            // remove text
            Text_Destroy(stc_tipmgr.text);
            GObj_Destroy(stc_tipmgr.gobj);
            stc_tipmgr.gobj = 0;
        }
        // if is active onscreen do nothing
        else
            return 0;
    }

    MsgMngrData *msgmngr_data = stc_msgmgr->userdata; // using message canvas cause there are so many god damn text canvases

    // Create bg
    GOBJ *tip_gobj = GObj_Create(0, 0, 0);
    stc_tipmgr.gobj = tip_gobj;
    GObj_AddGXLink(tip_gobj, GXLink_Common, MSG_GXLINK, 80);
    JOBJ *tip_jobj = JOBJ_LoadJoint(stc_evco_data.menu_assets->tip_jobj);
    GObj_AddObject(tip_gobj, R13_U8(-0x3E55), tip_jobj);

    // account for widescreen
    /*
    float aspect = (msgmngr_data->cobj->projection_param.perspective.aspect / 1.216667) - 1;
    tip_jobj->trans.X += (tip_jobj->trans.X * aspect);
    JOBJ_SetMtxDirtySub(tip_jobj);
    */

    // Create text object
    Text *tip_text = Text_CreateText(2, msgmngr_data->canvas);
    stc_tipmgr.text = tip_text;
    stc_tipmgr.lifetime = lifetime;
    stc_tipmgr.state = 0;
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

    // apply enter anim
    JOBJ_RemoveAnimAll(tip_jobj);
    JOBJ_AddAnimAll(tip_jobj, stc_evco_data.menu_assets->tip_jointanim[0], 0, 0);
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
        int y_delta = (i * MSGTEXT_YOFFSET);
        Text_AddSubtext(tip_text, 0, y_delta, msg_line);
    }

    return 1; // tip created
}
void Tip_Destroy()
{
    // check if tip exists and isnt in exit state, enter exit
    if ((stc_tipmgr.gobj != 0) && (stc_tipmgr.state != 2))
    {
        // apply exit anim
        JOBJ *tip_root = stc_tipmgr.gobj->hsd_object;
        JOBJ_RemoveAnimAll(tip_root);
        JOBJ_AddAnimAll(tip_root, stc_evco_data.menu_assets->tip_jointanim[1], 0, 0);
        JOBJ_ReqAnimAll(tip_root, 0);
        JOBJ_RunAObjCallback(tip_root, 6, 0xfb7f, AOBJ_SetRate, 1, (float)2);

        stc_tipmgr.state = 2; // enter wait
    }

    return;
}

// Scenario Functions
void Scenario_Init(ArchiveInfo *archive)
{
    //GOBJ *scenario_gobj = GObj_Create(0, 0, 0);
    GOBJ *scenario_gobj = JOBJ_LoadSet(0, stc_evco_data.menu_assets->scenario, 0, 0, 0, DLG_GXLINK, 1, 0);
    ScenarioData *scenario_data = calloc(sizeof(ScenarioData));
    GObj_AddUserData(scenario_gobj, 4, HSD_Free, scenario_data);
    GObj_AddProc(scenario_gobj, Scenario_Think, 3); // was 18

    // store static pointer
    stc_scenario = scenario_gobj;

    return;
}
void Scenario_Think(GOBJ *gobj)
{
    ScenarioData *scn_data = gobj->userdata;
    JOBJ *scn_jobj = gobj->hsd_object;

    // update graphic animation
    JOBJ_AnimAll(scn_jobj);

    // update input sequence when game engine is running
    if (Pause_CheckStatus(1) != 2)
        InputSeq_Think(gobj);

    // if script exists
    if (scn_data->cur)
    {

        // check to skip the scenario
        {
            HSD_Pad *pad = PadGet(Fighter_GetControllerPort(0), PADGET_MASTER);
            if ((pad->down & HSD_BUTTON_START) && (scn_data->skip_scn != 0))
            {

                // sfx
                SFX_PlayCommon(0);

                // init new script
                scn_data->cur = scn_data->skip_scn;
                scn_data->timer = 0;

                // stop input sequences
                for (int i = 0; i < sizeof(scn_data->input) / sizeof(scn_data->input[0]); i++)
                {

                    InpSeqData *input_data = &scn_data->input[i];

                    // if sequence exists
                    if (input_data->cur)
                    {

                        // get fighter
                        GOBJ *this_fighter = Fighter_GetGObj(i);
                        FighterData *this_fighter_data = this_fighter->userdata;

                        // clear script ptr
                        input_data->cur = 0;

                        // restore the slot type
                        Fighter_SetSlotType(i, input_data->slot);

                        // restore ai type
                        this_fighter_data->cpu.ai = input_data->cpu_ai;
                    }
                }

                // destroy asset if it exists
                if (scn_data->asset.gobj)
                {
                    GObj_Destroy(scn_data->asset.gobj);
                    scn_data->asset.gobj = 0;
                }

                // end dialogue if it exists
                if (stc_dialogue)
                    GObj_Destroy(stc_dialogue);
            }
        }

        // wait a frame if timer is set
        if (scn_data->timer > 0)
            scn_data->timer--;

        // update script
        else
        {

            DlgScnTest *script = scn_data->cur;
            int command_kind = script->x0.i;

            while (1)
            {

                switch (command_kind)
                {
                case (DLGSCN_END):
                {
                    scn_data->cur = 0;

                    // hide prompt
                    JOBJ_AddSetAnim(scn_jobj, stc_evco_data.menu_assets->scenario, 0);
                    JOBJ_ReqAnimAll(scn_jobj, 0);

                    // stop input sequences
                    for (int i = 0; i < sizeof(scn_data->input) / sizeof(scn_data->input[0]); i++)
                    {

                        InpSeqData *input_data = &scn_data->input[i];

                        // if sequence exists
                        if (input_data->cur)
                        {

                            // get fighter
                            GOBJ *this_fighter = Fighter_GetGObj(i);
                            FighterData *this_fighter_data = this_fighter->userdata;

                            // clear script ptr
                            input_data->cur = 0;

                            // restore the slot type
                            Fighter_SetSlotType(i, input_data->slot);

                            // restore ai type
                            this_fighter_data->cpu.ai = input_data->cpu_ai;
                        }
                    }

                    // destroy asset if it exists
                    if (scn_data->asset.gobj)
                    {
                        GObj_Destroy(scn_data->asset.gobj);
                        scn_data->asset.gobj = 0;
                    }

                    // end dialogue if it exists
                    if (stc_dialogue)
                        GObj_Destroy(stc_dialogue);

                    goto EXIT;
                    break;
                }
                case (DLGSCN_TEXT):
                {
                    DlgScnText *text = script;

                    // disable inputs
                    if (text->disable_inputs == 1)
                    {
                        GOBJ *hmn_gobj = Fighter_GetGObj(0);
                        FighterData *hmn_data = hmn_gobj->userdata;
                        Fighter_InitInputs(hmn_gobj); // disables and clears inputs
                        //Fighter_SetSlotType(0, 1);
                        //hmn_data->cpu.ai = 0; // noact
                    }

                    Dialogue_Create(text->text);

                    break;
                }
                case (DLGSCN_FREEZE):
                {
                    DlgScnFreeze *freeze = script;

                    Match_FreezeGame(1);

                    break;
                }
                case (DLGSCN_UNFREEZE):
                {

                    DlgScnUnfreeze *unfreeze = script;

                    Match_UnfreezeGame(1);

                    break;
                }
                case (DLGSCN_MOVE):
                {

                    DlgScnMove *move = script;

                    // run on each subchar
                    for (int i = 0; i < 2; i++)
                    {
                        GOBJ *this_fighter = Fighter_GetSubcharGObj(move->ft_index, i);

                        if (this_fighter)
                        {

                            FighterData *this_fighter_data = this_fighter->userdata;

                            // Sleep first
                            Fighter_EnterSleep(this_fighter, 0);
                            Fighter_EnterRebirth(this_fighter);

                            // place CPU here
                            this_fighter_data->phys.pos.X = move->pos.X;
                            this_fighter_data->phys.pos.Y = move->pos.Y;
                            this_fighter_data->phys.pos.Z = 0;

                            // facing player
                            this_fighter_data->facing_direction = move->facing_direction;

                            // grounded logic
                            int is_ground = 0;
                            if (move->check_ground)
                            {

                                // check for ground below fighter
                                Vec3 coll_pos;
                                int line_index;
                                int line_kind;
                                Vec3 line_unk;
                                float fromX = (this_fighter_data->phys.pos.X);
                                float toX = fromX;
                                float fromY = (this_fighter_data->phys.pos.Y + 7);
                                float toY = (this_fighter_data->phys.pos.Y - 7);
                                is_ground = GrColl_RaycastGround(&coll_pos, &line_index, &line_kind, &line_unk, -1, -1, -1, 0, fromX, fromY, toX, toY, 0);
                                if (is_ground == 1)
                                {

                                    // place them here
                                    this_fighter_data->phys.pos = coll_pos;
                                    this_fighter_data->coll_data.ground_index = line_index;

                                    // set grounded
                                    this_fighter_data->phys.air_state = 0;

                                    // enter wait
                                    ActionStateChange(0, 1, -1, this_fighter, ASID_WAIT, 0, 0);
                                }
                            }

                            // airborne logic
                            if (is_ground == 0)
                            {
                                // set airborne
                                this_fighter_data->phys.air_state = 0;

                                // enter fall
                                ActionStateChange(0, 1, -1, this_fighter, ASID_FALL, 0, 0);
                            }

                            // generic logic
                            {
                                // kill velocity
                                Fighter_KillAllVelocity(this_fighter);

                                // update ECB
                                this_fighter_data->coll_data.topN_Curr = this_fighter_data->phys.pos; // move current ECB location to new position
                                Coll_ECBCurrToPrev(&this_fighter_data->coll_data);
                                this_fighter_data->cb.Coll(this_fighter);

                                // update camera box
                                JOBJ_SetMtxDirtySub(this_fighter->hsd_object);
                                Fighter_UpdateCameraBox(this_fighter);
                                this_fighter_data->cameraBox->boundleft_curr = this_fighter_data->cameraBox->boundleft_proj;
                                this_fighter_data->cameraBox->boundright_curr = this_fighter_data->cameraBox->boundright_proj;
                                Match_CorrectCamera();

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
                    break;
                }
                case (DLGSCN_WAITFRAME):
                {

                    DlgScnWaitFrame *wait = script;
                    scn_data->timer = wait->frames;

                    // get next
                    script = &script[1];    // get next command
                    scn_data->cur = script; // update cur ptr

                    goto EXIT;
                    break;
                }
                case (DLGSCN_WAITTEXT):
                {

                    DlgScnWaitText *wait = script;

                    // is dialogue finished?
                    if (Dialogue_CheckEnd())
                        break;
                    else
                        goto EXIT;
                }
                case (DLGSCN_WAITINPUTS):
                {

                    DlgScnWaitInputs *wait = script;
                    int ft_index = wait->ft_index;

                    // check everyones inputs?
                    if (ft_index >= 6)
                    {
                        // loop through all input sequence structs
                        for (int i = 0; i < sizeof(scn_data->input) / sizeof(scn_data->input[0]); i++)
                        {

                            InpSeqData *input_data = &scn_data->input[i];

                            // if sequence exists
                            if (input_data->cur)
                                goto EXIT;
                        }
                        break;
                    }
                    else
                    {
                        if (scn_data->input[ft_index].cur == 0)
                            break;
                        else
                            goto EXIT;
                    }
                }
                case (DLGSCN_ENTERSTATE):
                {
                    DlgScnEnterState *state = script;

                    switch (state->state)
                    {
                    case (DLGSCNSTATES_REBIRTHWAIT):
                    {

                        // run on each subchar
                        for (int i = 0; i < 2; i++)
                        {
                            GOBJ *this_fighter = Fighter_GetSubcharGObj(state->ft_index, i);

                            if (this_fighter)
                            {

                                FighterData *this_fighter_data = this_fighter->userdata;

                                // enter state
                                this_fighter_data->phys.air_state = 1;
                                ActionStateChange(0, 1, -1, this_fighter, ASID_REBIRTHWAIT, 0xb002, 0);
                                this_fighter_data->cb.Phys = RebirthWait_Phys;
                                this_fighter_data->cb.IASA = RebirthWait_IASA;
                                Fighter_ApplyColAnim(this_fighter_data, 10, 0); // colanim

                                // create respawn platform model
                                if (this_fighter_data->flags.ms == 0)
                                {
                                    void ***respawn_desc = (R13 + -0x516C);
                                    JOBJ *respawn_jobj = JOBJ_LoadJoint(**respawn_desc);
                                    this_fighter_data->accessory = respawn_jobj;
                                    respawn_jobj->scale.X *= this_fighter_data->attr.respawn_platform_scale;
                                    respawn_jobj->scale.Y *= this_fighter_data->attr.respawn_platform_scale;
                                    respawn_jobj->scale.Z *= this_fighter_data->attr.respawn_platform_scale;
                                    // anim model
                                    void **anim = *respawn_desc;
                                    JOBJ_AddAnimAll(respawn_jobj, anim[1], 0, 0);
                                    JOBJ_ReqAnimAll(respawn_jobj, 0);

                                    this_fighter_data->cb.Accessory1 = Fighter_UpdateRebirthPlatformPos;
                                    Fighter_UpdateRebirthPlatformPos(this_fighter);
                                }
                                else
                                {
                                    this_fighter_data->cb.Accessory1 = 0x800d55b4; // follower update func

                                    // fuck it just move the follower behind 11 units i guess
                                    GOBJ *main_fighter = Fighter_GetSubcharGObj(state->ft_index, 0);
                                    FighterData *main_fighter_data = main_fighter->userdata;
                                    this_fighter_data->phys.pos.X = main_fighter_data->phys.pos.X - (main_fighter_data->facing_direction * 11);
                                }
                            }
                        }

                        break;
                    }
                    case (DLGSCNSTATES_SLEEP):
                    {
                        // run on each subchar
                        for (int i = 0; i < 2; i++)
                        {
                            GOBJ *this_fighter = Fighter_GetSubcharGObj(state->ft_index, i);

                            if (this_fighter)
                            {

                                FighterData *this_fighter_data = this_fighter->userdata;
                                Fighter_EnterSleep(this_fighter, 0);
                            }
                        }

                        break;
                    }
                    }

                    Match_CorrectCamera();

                    break;
                }
                case (DLGSCN_INPUTS):
                {

                    DlgScnPlayInputs *inputs = script;
                    InpSeqData *seq = &scn_data->input[inputs->ft_index];
                    seq->cur = inputs->inputs;

                    // make this fighter a CPU and puppet it using cpu inputs
                    seq->slot = Fighter_GetSlotType(inputs->ft_index);
                    Fighter_SetSlotType(inputs->ft_index, 1);

                    // set cpu to noact
                    GOBJ *this_fighter = Fighter_GetGObj(inputs->ft_index);
                    FighterData *this_fighter_data = this_fighter->userdata;
                    seq->cpu_ai = this_fighter_data->cpu.ai;
                    this_fighter_data->cpu.ai = 15; // noact

                    break;
                }
                case (DLGSCN_CAMNORMAL):
                {

                    DlgScnCamNormal *cam = script;

                    Match_SetNormalCamera();

                    break;
                }
                case (DLGSCN_CAMZOOM):
                {

                    DlgScnCamZoom *cam = script;

                    Match_SetFreeCamera(cam->ft_index, 3);
                    stc_matchcam->freecam_fov.X = 140;
                    stc_matchcam->freecam_rotate.Y = 10;

                    break;
                }
                case (DLGSCN_CAMCORRECT):
                {

                    Match_CorrectCamera();

                    break;
                }
                case (DLGSCN_ASSETCREATE):
                {

                    DlgScnAssetCreate *asset = script;

                    // destroy previous if it exists
                    if (scn_data->asset.gobj)
                    {
                        GObj_Destroy(scn_data->asset.gobj);
                        scn_data->asset.gobj = 0;
                    }

                    // create this asset
                    scn_data->asset.gobj = JOBJ_LoadSet(0, stc_evco_data.scn_assets[asset->index], 0, 0, 0, DLG_GXLINK, 1, GObj_Anim);
                    scn_data->asset.index = asset->index; // save index to lookup later

                    break;
                }
                case (DLGSCN_ASSETCHANGE):
                {

                    DlgScnAssetChange *asset = script;

                    // if it exists
                    if (scn_data->asset.gobj)
                    {
                        // add new animation
                        JOBJ *jobj = scn_data->asset.gobj->hsd_object;
                        JOBJ_AddSetAnim(jobj, stc_evco_data.scn_assets[scn_data->asset.index], asset->index);
                        JOBJ_ReqAnimAll(jobj, 0);
                    }

                    break;
                }
                case (DLGSCN_ASSETDESTROY):
                {

                    DlgScnAssetDestroy *asset = script;

                    // destroy previous if it exists
                    if (scn_data->asset.gobj)
                    {
                        GObj_Destroy(scn_data->asset.gobj);
                        scn_data->asset.gobj = 0;
                    }

                    break;
                }
                }

                // get next
                script = &script[1];         // get next command
                scn_data->cur = script;      // update cur ptr
                command_kind = script->x0.i; // get next command opcode
            }

        EXIT:;
        }
    }

    return;
}
void Scenario_Exec(DlgScnTest *scn, DlgScnTest *skip_scn)
{
    ScenarioData *scn_data = stc_scenario->userdata;
    JOBJ *scn_jobj = stc_scenario->hsd_object;

    scn_data->cur = scn;
    scn_data->timer = 0;
    scn_data->skip_scn = skip_scn;

    // display prompt
    if (scn_data->skip_scn != 0)
    {
        JOBJ_AddSetAnim(scn_jobj, stc_evco_data.menu_assets->scenario, 1);
        JOBJ_ReqAnimAll(scn_jobj, 0);
    }

    return;
}
int Scenario_CheckEnd()
{
    ScenarioData *scn_data = stc_scenario->userdata;

    if (scn_data->cur)
        return 0;
    else
        return 1;
}
void InputSeq_Think(GOBJ *gobj)
{

    ScenarioData *scn_data = gobj->userdata;

    // loop through all input sequence structs
    for (int i = 0; i < sizeof(scn_data->input) / sizeof(scn_data->input[0]); i++)
    {

        InpSeqData *input_data = &scn_data->input[i];

        // if sequence exists
        if (input_data->cur)
        {

            GOBJ *this_fighter = Fighter_GetGObj(i);
            FighterData *this_fighter_data = this_fighter->userdata;

            Fighter_ZeroCPUInputs(this_fighter_data);

            // update script if not holding anything
            if (input_data->hold_timer == 0)
            {

                // wait a frame if timer is set
                if (input_data->wait_timer > 0)
                    input_data->wait_timer--;

                // update script
                else
                {

                    InpSeqTest *seq = input_data->cur;
                    int command_kind = seq->x0.i;

                    while (1)
                    {
                        switch (command_kind)
                        {
                        case (INPSEQ_END):
                        {
                            // clear script ptr
                            input_data->cur = 0;

                            // restore the slot type
                            Fighter_SetSlotType(i, input_data->slot);

                            // restore ai type
                            this_fighter_data->cpu.ai = input_data->cpu_ai;

                            goto EXIT;
                            break;
                        }
                        case (INPSEQ_INPUT):
                        {

                            InpSeqInput *input = seq;

                            // remember these inputs
                            input_data->hold_timer = input->hold_timer;
                            input_data->buttons = input->buttons;
                            input_data->lstick_x = input->lstick_x;
                            input_data->lstick_y = input->lstick_y;
                            input_data->rstick_x = input->rstick_x;
                            input_data->rstick_y = input->rstick_y;

                            // get next
                            seq = &seq[1];            // get next command
                            input_data->cur = seq;    // update cur ptr
                            command_kind = seq->x0.i; // get next command opcode
                            goto EXIT;

                            break;
                        }
                        case (INPSEQ_WAIT):
                        {
                            InpSeqWait *wait = seq;

                            input_data->wait_timer = wait->frames;

                            // get next
                            seq = &seq[1];            // get next command
                            input_data->cur = seq;    // update cur ptr
                            command_kind = seq->x0.i; // get next command opcode

                            goto EXIT;

                            break;
                        }
                        }

                        // get next
                        seq = &seq[1];            // get next command
                        input_data->cur = seq;    // update cur ptr
                        command_kind = seq->x0.i; // get next command opcode
                    }

                EXIT:;
                }
            }

            // if any inputs are being held, input them
            if (input_data->hold_timer > 0)
            {

                input_data->hold_timer--;

                // input buttons
                this_fighter_data->cpu.held = input_data->buttons;
                this_fighter_data->cpu.lstickX = input_data->lstick_x;
                this_fighter_data->cpu.lstickY = input_data->lstick_y;
                this_fighter_data->cpu.cstickX = input_data->rstick_x;
                this_fighter_data->cpu.cstickY = input_data->rstick_y;
            }
        }
    }

    return;
}

// Dialogue Functions
void Dialogue_Create(char **string_data)
{

    // check if a dialogue box exists already
    if (stc_dialogue)
    {
        GObj_Destroy(stc_dialogue);
        stc_dialogue = 0;
    }

    // create dialogue gobj
    GOBJ *dialogue_gobj = JOBJ_LoadSet(0, stc_evco_data.menu_assets->dialogue, 0, 0, 0, DLG_GXLINK, 1, 0);
    DialogueData *dialogue_data = calloc(sizeof(DialogueData));
    GObj_AddUserData(dialogue_gobj, 4, Dialogue_Destroy, dialogue_data);
    GObj_AddProc(dialogue_gobj, Dialogue_Think, 18);

    // enter start state
    SFX_Play(560000);
    Dialogue_EnterState(dialogue_gobj, DLGSTATE_START);

    // init variables
    dialogue_data->string_data = string_data;

    // create canvas
    dialogue_data->canvas = Text_CreateCanvas(DLG_SIS, 1, 14, 15, 0, DLG_GXLINK, DLG_GXPRI, 19);

    // static pointer to dialogue gobj
    stc_dialogue = dialogue_gobj;

    return;
}
void Dialogue_Think(GOBJ *dialogue_gobj)
{

    // use single player port for inputs

    DialogueData *dialogue_data = dialogue_gobj->userdata;
    JOBJ *dialogue_jobj = dialogue_gobj->hsd_object;

    // Anim
    JOBJ_AnimAll(dialogue_jobj);

    // state logic
    switch (dialogue_data->state)
    {
    case (DLGSTATE_START):
    {
        // check if anim ended
        if (JOBJ_CheckAObjEnd(dialogue_jobj) == 0)
        {
            Dialogue_EnterScroll(dialogue_gobj);
        }
        break;
    }
    case (DLGSTATE_SCROLL):
    {

        // check to delay
        if (dialogue_data->delay_timer > 0)
            dialogue_data->delay_timer--;
        else
        {

            // inc timer
            dialogue_data->scroll_timer++;

            // check to play sfx every X frames
            {
                // decrement timer
                dialogue_data->sfx_timer--;
                if (dialogue_data->sfx_timer <= 0)
                {

                    // destroy old sfx
                    if (dialogue_data->sfx_id != -1)
                        FGM_Stop(dialogue_data->sfx_id);

                    // play new sfx
                    dialogue_data->sfx_id = SFX_Play(DLG_SFXSTART + HSD_Randi(DLG_SFXNUM));

                    // randomize next sfx timer
                    dialogue_data->sfx_timer = DLG_SFXFREQMIN + HSD_Randi(DLG_SFXFREQMAX - DLG_SFXFREQMIN);
                }
            }

            // check for delay char every X frames
            if (dialogue_data->scroll_timer % (int)(1 / DLG_CHARPERSEC) == 0)
            {
                // check if next character is a delay character
                static char delay_chars[] = {',', '.', '!', '?'};
                if ((int)(dialogue_data->scroll_timer * DLG_CHARPERSEC) > 0)
                {
                    char *cur = &dialogue_data->string_data[dialogue_data->index][(int)(dialogue_data->scroll_timer * DLG_CHARPERSEC) - 1];
                    char next_char = cur[0];
                    char second_char = cur[1];
                    OSReport("cur: %x\nnext_char: %c\nsecond_char: %c\n", cur, next_char, second_char);
                    for (int i = 0; i < sizeof(delay_chars); i++)
                    {
                        if (next_char == delay_chars[i]) // if next char is a delay char
                        {
                            if ((second_char == ' ') || (second_char == 0x00)) // if there is another sentence after it
                            {
                                dialogue_data->delay_timer = DLG_PUNCDELAY;
                                break;
                            }
                        }
                    }
                }
            }
        }

        // determine how many characters to display
        int display_char_num = (int)(dialogue_data->scroll_timer * DLG_CHARPERSEC);
        // limit num
        if (display_char_num > dialogue_data->char_num)
            display_char_num = dialogue_data->char_num;
        // update num
        if (display_char_num > 0)
            display_char_num--; // gx cb adds 1, this is a hack to make it be what we want
        dialogue_data->text->char_display_num = (display_char_num);

        // press A to skip scroll
        HSD_Pad *pad = PadGet(Fighter_GetControllerPort(0), PADGET_ENGINE);
        if (pad->down & HSD_BUTTON_A)
            dialogue_data->text->char_display_num = dialogue_data->char_num + 1;

        // check if done scrolling text
        if ((dialogue_data->text->char_display_num + 1) >= (dialogue_data->char_num))
        {
            // change state
            Dialogue_EnterState(dialogue_gobj, DLGSTATE_WAIT);
        }

        /*
        else
        {
            // update scroll text
            if (dialogue_data->text)
                Text_Destroy(dialogue_data->text);

            Text *text = Text_CreateText(DLG_SIS, dialogue_data->canvas);
            dialogue_data->text = text;

            // enable align and kerning
            text->align = 0;
            text->kerning = 1;
            text->use_aspect = 1;
            // scale canvas
            text->scale.X = MENU_CANVASSCALE;
            text->scale.Y = MENU_CANVASSCALE;
            text->aspect.X = 510;

            // set text position
            JOBJ *textpos_jobj;
            Vec3 text_pos;
            JOBJ_GetChild(dialogue_jobj, &textpos_jobj, 11, -1);
            JOBJ_GetWorldPosition(textpos_jobj, 0, &text_pos);
            text->trans.X = text_pos.X + (0 * (dialogue_jobj->scale.X / 4.0));
            text->trans.Y = (text_pos.Y * -1) + (0 * (dialogue_jobj->scale.Y / 4.0));

            // get first X characters
            char *msg = dialogue_data->string_data[dialogue_data->index];

            // output text
            {

                // count newlines
                int line_num = 1;
                int line_length_arr[DLG_LINEMAX];
                char *msg_cursor_prev, *msg_cursor_curr;         // declare char pointers
                msg_cursor_prev = msg;                           //
                msg_cursor_curr = strchr(msg_cursor_prev, '\n'); // check for occurrence
                while (msg_cursor_curr != 0)                     // if occurrence found, increment values
                {
                    // check if exceeds max lines
                    if (line_num >= DLG_LINEMAX)
                        assert("DLG_LINEMAX exceeded!");

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
                    if (line_length > DLG_CHARMAX)
                        assert("DLG_CHARMAX exceeded!");

                    // copy char array
                    char msg_line[DLG_CHARMAX + 1];
                    memcpy(msg_line, msg, line_length);

                    // add null terminator
                    msg_line[line_length] = '\0';

                    // increment msg
                    msg += (line_length + 1); // +1 to skip past newline

                    // print line
                    int y_delta = (i * MSGTEXT_YOFFSET);
                    Text_AddSubtext(text, 0, y_delta, msg_line);
                }
            }

            // check to skip scroll
            if (0)
            {
                0;
            }
        }
        */
        break;
    }
    case (DLGSTATE_WAIT):
    {

        HSD_Pad *pad = PadGet(Fighter_GetControllerPort(0), PADGET_ENGINE);

        // check for advance input
        if (pad->down & HSD_BUTTON_A)
        {

            // increment index
            dialogue_data->index++;

            // check if another line of dialogue exists
            if (dialogue_data->string_data[dialogue_data->index] != -1)
                Dialogue_EnterScroll(dialogue_gobj);

            // no more dialogue, exit
            else
            {

                // remove text
                Text_Destroy(dialogue_data->text);
                dialogue_data->text = 0;

                // change state
                SFX_Play(560001);
                Dialogue_EnterState(dialogue_gobj, DLGSTATE_EXIT);
            }
        }

        break;
    }
    case (DLGSTATE_EXIT):
    {
        // check if anim ended
        if (JOBJ_CheckAObjEnd(dialogue_jobj) == 0)
            GObj_Destroy(dialogue_gobj); // destroy gobj

        break;
    }
    }

    return;
}
void Dialogue_Destroy(DialogueData *dialogue_data)
{

    // free entire text canvas
    Text_DestroySisCanvas(DLG_SIS);

    // free data alloc
    HSD_Free(dialogue_data);

    stc_dialogue = 0;

    // enable inputs
    GOBJ *hmn_gobj = Fighter_GetGObj(0);
    FighterData *hmn_data = hmn_gobj->userdata;
    hmn_data->flags.x221d_5 = 0;
    //Fighter_SetSlotType(0, 0);

    return;
}
void Dialogue_EnterScroll(GOBJ *dialogue_gobj)
{
    DialogueData *dialogue_data = dialogue_gobj->userdata;
    JOBJ *dialogue_jobj = dialogue_gobj->hsd_object;

    // remove old text if exists text
    if (dialogue_data->text)
    {
        Text_Destroy(dialogue_data->text);
        dialogue_data->text = 0;
    }

    // change state
    Dialogue_EnterState(dialogue_gobj, DLGSTATE_SCROLL);

    // init speech variables
    dialogue_data->sfx_timer = 0;
    dialogue_data->sfx_id = -1;

    // count characters in the upcoming string
    dialogue_data->char_num = strlen(dialogue_data->string_data[dialogue_data->index]);
    dialogue_data->scroll_timer = 0;
    dialogue_data->delay_timer = 0;

    // get text position
    JOBJ *textpos_jobj;
    Vec3 text_pos;
    JOBJ_GetChild(dialogue_jobj, &textpos_jobj, 11, -1);
    JOBJ_GetWorldPosition(textpos_jobj, 0, &text_pos);
    float pos_x = text_pos.X + (0 * (dialogue_jobj->scale.X / 4.0));
    float pos_y = (text_pos.Y * -1) + (0 * (dialogue_jobj->scale.Y / 4.0));

    // create text
    Text *text = Text_CreateText2(DLG_SIS, dialogue_data->canvas, pos_x, pos_y, 0, 650, 96);
    dialogue_data->text = text;

    // scale canvas
    text->scale.X = 0.04;
    text->scale.Y = 0.06;

    // init text variables
    Text_SetSisText(text, 0);

    // convert string to menu text
    static u8 text_header[] = {0x01, 0x06, 0x00, 0x01, 0x00, 0x00, 0x18, 0x16};
    static u8 text_terminator[] = {0x17, 0x05, 0x64, 0x19, 0x00};
    char *orig_string = dialogue_data->string_data[dialogue_data->index];
    int length = strlen(orig_string);
    u8 *text_alloc = Text_Alloc(length * 3 + sizeof(text_header) + sizeof(text_terminator));
    // build text data
    memcpy(text_alloc, &text_header, sizeof(text_header));                                                // copy header data
    int converted_size = Text_ConvertToMenuText(text_alloc + sizeof(text_header), orig_string);           // convert string to text data
    memcpy(text_alloc + sizeof(text_header) + converted_size, &text_terminator, sizeof(text_terminator)); // copy ternimator data
    text->text_start = text_alloc;

    // try setting the text to init scroll with opcode 01, running the gxlink to init it, then disable the scroll flag in the text struct

    return;
}
void Dialogue_EnterState(GOBJ *dialogue_gobj, int state)
{
    DialogueData *dialogue_data = dialogue_gobj->userdata;
    JOBJ *dialogue_jobj = dialogue_gobj->hsd_object;

    dialogue_data->state = state;
    JOBJ_AddSetAnim(dialogue_jobj, stc_evco_data.menu_assets->dialogue, state);
    JOBJ_ReqAnimAll(dialogue_jobj, 0);

    return;
}
int Dialogue_CheckEnd()
{

    if (stc_dialogue)
        return 0;
    else
        return 1;
}
void RebirthWait_Phys(GOBJ *fighter)
{

    FighterData *fighter_data = fighter->userdata;

    // infinite time
    fighter_data->state_var.state_var1 = 2;

    return;
}
int RebirthWait_IASA(GOBJ *fighter)
{

    FighterData *fighter_data = fighter->userdata;

    // subchars can only interrupt if mainchar left rebirth
    if (fighter_data->flags.ms)
    {
        GOBJ *main_fighter = Fighter_GetSubcharGObj(fighter_data->ply, 0);
        if (main_fighter)
        {
            FighterData *main_fighter_data = main_fighter->userdata;
            if ((main_fighter_data->state_id == ASID_REBIRTH) ||
                (main_fighter_data->state_id == ASID_REBIRTHWAIT))
                return 0;
        }
    }

    if (Fighter_IASACheck_JumpAerial(fighter))
    {
    }
    else
    {
        ftCommonData *ftcommon = *stc_ftcommon;

        // check for lstick movement
        float stick_x = fabs(fighter_data->input.lstick.X);
        float stick_y = fighter_data->input.lstick.Y;
        if ((stick_x > 0.2875) && (fighter_data->input.timer_lstick_tilt_x < 2) ||
            (stick_y < (ftcommon->lstick_rebirthfall * -1)) && (fighter_data->input.timer_lstick_tilt_y < 4))
        {
            Fighter_EnterFall(fighter);
            return 1;
        }
    }

    return 0;
}

void EventUpdate()
{

    // get event info
    EventDesc *event_desc = stc_evco_data.event_desc;
    evFunction *evFunction = &stc_evco_data.evFunction;
    GOBJ *menu_gobj = stc_evco_data.menu_gobj;

    // run savestate logic if enabled
    if (event_desc->use_savestates == true)
    {
        Update_Savestates();
    }

    // run menu logic if exists
    if (menu_gobj != 0)
    {
        // update menu
        EventMenu_Update(menu_gobj);
    }

    // run custom event update function
    if (evFunction->Event_Update != 0)
    {
        evFunction->Event_Update();
    }
    else
        Develop_UpdateMatchHotkeys();

    return;
}

////////////////////////////
/// Event Menu Functions ///
////////////////////////////

GOBJ *EventMenu_Init(EventDesc *event_desc, EventMenu *start_menu)
{
    // Ensure this event has a menu
    if (start_menu == 0)
        return 0;

    // disable vanilla pause
    stc_match->match.isDisablePause = 1;

    // Create a cobj for the event menu
    COBJDesc ***dmgScnMdls = File_GetSymbol(ACCESS_PTR(0x804d6d5c), 0x803f94d0);
    COBJDesc *cam_desc = dmgScnMdls[1][0];
    COBJ *cam_cobj = COBJ_LoadDesc(cam_desc);
    GOBJ *cam_gobj = GObj_Create(19, 20, 0);
    GObj_AddObject(cam_gobj, R13_U8(-0x3E55), cam_cobj);
    GOBJ_InitCamera(cam_gobj, CObjThink_Common, MENUCAM_GXPRI);
    cam_gobj->cobj_links = MENUCAM_COBJGXLINK;

    // Create menu gobj
    GOBJ *gobj = GObj_Create(0, 0, 0);
    MenuData *menuData = calloc(sizeof(MenuData));
    GObj_AddUserData(gobj, 4, HSD_Free, menuData);

    // store pointer to the gobj's data
    menuData->event_desc = event_desc;

    // Add gx_link
    GObj_AddGXLink(gobj, GXLink_Common, GXLINK_MENUMODEL, GXPRI_MENUMODEL);

    // Create 2 text canvases (menu and popup)
    menuData->canvas_menu = Text_CreateCanvas(2, cam_gobj, 9, 13, 0, GXLINK_MENUTEXT, GXPRI_MENUTEXT, MENUCAM_GXPRI);
    menuData->canvas_popup = Text_CreateCanvas(2, cam_gobj, 9, 13, 0, GXLINK_MENUTEXT, GXPRI_POPUPTEXT, MENUCAM_GXPRI);

    // Init currMenu
    menuData->currMenu = start_menu;

    // set menu as not hidden
    stc_evco_data.hide_menu = 0;

    return gobj;
};
void EventMenu_Update(GOBJ *gobj)
{

    //MenuCamData *camData = gobj->userdata;
    MenuData *menuData = gobj->userdata;
    EventDesc *event_desc = menuData->event_desc;
    EventMenu *currMenu = menuData->currMenu;

    int update_menu = 1;

    // if a custom menu is in use, run its function
    if (menuData->custom_gobj_think != 0)
    {
        update_menu = menuData->custom_gobj_think(menuData->custom_gobj);
    }

    // if this menu has an upate function, run its function
    else if ((menuData->isPaused == 1) && (currMenu->menu_think != 0))
    {
        update_menu = currMenu->menu_think(gobj);
    }

    if (update_menu == 1)
    {
        // Check if being pressed
        int isPress = 0;
        for (int i = 0; i < 6; i++)
        {

            // humans only
            if (Fighter_GetSlotType(i) == 0)
            {
                GOBJ *fighter = Fighter_GetGObj(i);
                FighterData *fighter_data = fighter->userdata;
                int controller_index = Fighter_GetControllerPort(i);

                HSD_Pad *pad = PadGet(controller_index, PADGET_MASTER);

                // in develop mode, use X+DPad up
                if (*stc_dblevel >= 3)
                {
                    if ((pad->held & HSD_BUTTON_X) && (pad->down & HSD_BUTTON_DPAD_UP))
                    {
                        isPress = 1;
                        menuData->controller_index = controller_index;
                        break;
                    }
                }
                else
                {
                    if ((pad->down & HSD_BUTTON_START) != 0)
                    {
                        isPress = 1;
                        menuData->controller_index = controller_index;
                        break;
                    }
                }
            }
        }

        // change pause state
        if ((isPress != 0) && (Scenario_CheckEnd() == 1))
        {
            // pause game
            if (menuData->isPaused == 0)
            {

                // set state
                menuData->isPaused = 1;

                // Create menu
                EventMenu_CreateModel(gobj, currMenu);
                EventMenu_CreateText(gobj, currMenu);
                EventMenu_UpdateText(gobj, currMenu);
                if (currMenu->state == EMSTATE_OPENPOP)
                {
                    EventOption *currOption = &currMenu->options[currMenu->cursor];
                    EventMenu_CreatePopupModel(gobj, currMenu);
                    EventMenu_CreatePopupText(gobj, currMenu);
                    EventMenu_UpdatePopupText(gobj, currOption);
                }

                // Freeze the game
                Match_FreezeGame(1);
                SFX_PlayCommon(5);
                Match_HideHUD();
                Match_AdjustSoundOnPause(1);
            }
            // unpause game
            else
            {

                menuData->isPaused = 0;

                // destroy menu
                EventMenu_DestroyMenu(gobj);

                // Unfreeze the game
                Match_UnfreezeGame(1);
                Match_ShowHUD();
                Match_AdjustSoundOnPause(0);
            }
        }

        // run menu logic if the menu is shown
        else if ((menuData->isPaused == 1) && (stc_evco_data.hide_menu == 0))
        {
            // Get the current menu
            EventMenu *currMenu = menuData->currMenu;

            // menu think
            if (currMenu->state == EMSTATE_FOCUS)
            {
                // check to run custom menu think function
                EventMenu_MenuThink(gobj, currMenu);
            }

            // popup think
            else if (currMenu->state == EMSTATE_OPENPOP)
                EventMenu_PopupThink(gobj, currMenu);
        }
    }

    return;
}
void EventMenu_MenuGX(GOBJ *gobj, int pass)
{
    if (stc_evco_data.hide_menu == 0)
        GXLink_Common(gobj, pass);
    return;
}
void EventMenu_TextGX(GOBJ *gobj, int pass)
{

    if (stc_evco_data.hide_menu == 0)
        Text_GX(gobj, pass);
    return;
}
void EventMenu_MenuThink(GOBJ *gobj, EventMenu *currMenu)
{

    MenuData *menuData = gobj->userdata;
    EventDesc *event_desc = menuData->event_desc;

    // get player who paused
    u8 pauser = menuData->controller_index;
    // get their  inputs
    HSD_Pad *pad = PadGet(pauser, PADGET_MASTER);
    int inputs_rapid = Pad_GetRapidHeld(pauser); //pad->rapidFire;
    int inputs_held = pad->held;
    int inputs = inputs_rapid;
    if ((inputs_held & HSD_TRIGGER_R) != 0)
        inputs = inputs_held;

    // get menu variables
    int isChanged = 0;
    s32 cursor = currMenu->cursor;
    s32 scroll = currMenu->scroll;
    EventOption *currOption = &currMenu->options[cursor + scroll];
    s32 cursor_min = 0;
    s32 option_num = currMenu->option_num;
    s32 cursor_max = option_num;
    if (cursor_max > MENU_MAXOPTION)
        cursor_max = MENU_MAXOPTION;

    // get option variables
    s16 option_val = currOption->option_val;
    s16 value_min = 0;
    s16 value_max = currOption->value_num;

    // check for dpad down
    if (((inputs & HSD_BUTTON_DOWN) != 0) || ((inputs & HSD_BUTTON_DPAD_DOWN) != 0))
    {

        // loop to find next option
        int count = 1;       //
        int cursor_next = 0; // how much to move the cursor by
        while (((cursor + count + scroll) < option_num))
        {
            // option exists, check if its enabled
            if (currMenu->options[cursor + count + scroll].disable == 0)
            {
                cursor_next = count;
                break;
            }

            // option is disabled, loop
            count++;
        }

        // if another option exists, move down
        if (cursor_next > 0)
        {
            cursor += cursor_next;

            // cursor is in bounds, move down
            if (cursor < cursor_max)
            {
                isChanged = 1;

                // update cursor
                currMenu->cursor = cursor;

                // also play sfx
                SFX_PlayCommon(2);
            }

            // cursor overflowed, correct it
            else
            {

                // adjust
                scroll -= (cursor_max - (cursor + 1));
                cursor = (cursor_max - 1);

                // update cursor
                currMenu->cursor = cursor;
                currMenu->scroll = scroll;

                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);
            }
        }
    }
    // check for dpad up
    else if (((inputs & HSD_BUTTON_UP) != 0) || ((inputs & HSD_BUTTON_DPAD_UP) != 0))
    {
        // loop to find next option
        int count = 1;       //
        int cursor_next = 0; // how much to move the cursor by
        while (((cursor + scroll - count) >= 0))
        {
            // option exists, check if its enabled
            if (currMenu->options[cursor + scroll - count].disable == 0)
            {
                cursor_next = count;
                break;
            }

            // option is disabled, loop
            count++;
        }

        // if another option exists, move up
        if (cursor_next > 0)
        {
            cursor -= cursor_next;

            // cursor is in bounds, move up
            if (cursor >= 0)
            {
                isChanged = 1;

                // update cursor
                currMenu->cursor = cursor;

                // also play sfx
                SFX_PlayCommon(2);
            }

            // cursor overflowed, correct it
            else
            {

                // adjust
                scroll += cursor; // effectively scroll up by adding a negative number
                cursor = 0;       // cursor is positioned at 0

                // update cursor
                currMenu->cursor = cursor;
                currMenu->scroll = scroll;

                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);
            }
        }
    }

    // check for left
    else if (((inputs & HSD_BUTTON_LEFT) != 0) || ((inputs & HSD_BUTTON_DPAD_LEFT) != 0))
    {
        if ((currOption->option_kind == OPTKIND_STRING) || (currOption->option_kind == OPTKIND_INT) || (currOption->option_kind == OPTKIND_FLOAT))
        {

            option_val -= 1;
            if (option_val >= value_min)
            {
                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);

                // update val
                currOption->option_val = option_val;

                // run on change function if it exists
                if (currOption->onOptionChange != 0)
                    currOption->onOptionChange(gobj, currOption->option_val);
            }
        }
    }
    // check for right
    else if (((inputs & HSD_BUTTON_RIGHT) != 0) || ((inputs & HSD_BUTTON_DPAD_RIGHT) != 0))
    {
        // check for valid option kind
        if ((currOption->option_kind == OPTKIND_STRING) || (currOption->option_kind == OPTKIND_INT) || (currOption->option_kind == OPTKIND_FLOAT))
        {
            option_val += 1;
            if (option_val < value_max)
            {
                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);

                // update val
                currOption->option_val = option_val;

                // run on change function if it exists
                if (currOption->onOptionChange != 0)
                    currOption->onOptionChange(gobj, currOption->option_val);
            }
        }
    }

    // check for A
    else if (inputs_rapid & HSD_BUTTON_A)
    {
        // check to advance a menu
        if ((currOption->option_kind == OPTKIND_MENU))
        {
            // access this menu
            currMenu->state = EMSTATE_OPENSUB;

            // update currMenu
            EventMenu *nextMenu = currMenu->options[cursor + scroll].menu;
            nextMenu->prev = currMenu;
            nextMenu->state = EMSTATE_FOCUS;
            currMenu = nextMenu;
            menuData->currMenu = currMenu;

            // recreate everything
            EventMenu_DestroyMenu(gobj);
            EventMenu_CreateModel(gobj, currMenu);
            EventMenu_CreateText(gobj, currMenu);
            EventMenu_UpdateText(gobj, currMenu);

            // also play sfx
            SFX_PlayCommon(1);
        }

        /*
        // check to create a popup
        if ((currOption->option_kind == OPTKIND_STRING) || (currOption->option_kind == OPTKIND_INT))
        {
            // access this menu
            currMenu->state = EMSTATE_OPENPOP;

            // init cursor and scroll value
            s32 cursor = 0;
            s32 scroll = currOption->option_val;

            // correct scroll
            s32 max_scroll;
            if (currOption->value_num <= MENU_POPMAXOPTION)
                max_scroll = 0;
            else
                max_scroll = currOption->value_num - MENU_POPMAXOPTION;
            // check if scrolled too far
            if (scroll > max_scroll)
            {
                cursor = scroll - max_scroll;
                scroll = max_scroll;
            }

            // update cursor and scroll
            menuData->popup_cursor = cursor;
            menuData->popup_scroll = scroll;

            // create popup menu and update
            EventMenu_CreatePopupModel(gobj, currMenu);
            EventMenu_CreatePopupText(gobj, currMenu);
            EventMenu_UpdatePopupText(gobj, currOption);

            // also play sfx
            SFX_PlayCommon(1);
        }
        */

        // check to run a function
        if ((currOption->option_kind == OPTKIND_FUNC) && (currOption->onOptionSelect != 0))
        {

            // execute function
            currOption->onOptionSelect(gobj);

            // update text
            EventMenu_UpdateText(gobj, currMenu);

            // also play sfx
            SFX_PlayCommon(1);
        }
    }
    // check to go back a menu
    else if (inputs_rapid & HSD_BUTTON_B)
    {
        // check if a prev menu exists
        EventMenu *prevMenu = currMenu->prev;
        if (prevMenu != 0)
        {

            // clear previous menu
            EventMenu *prevMenu = currMenu->prev;
            currMenu->prev = 0;

            // reset this menu's cursor
            currMenu->scroll = 0;
            currMenu->cursor = 0;

            // update currMenu
            currMenu = prevMenu;
            menuData->currMenu = currMenu;

            // close this menu
            currMenu->state = EMSTATE_FOCUS;

            // recreate everything
            EventMenu_DestroyMenu(gobj);
            EventMenu_CreateModel(gobj, currMenu);
            EventMenu_CreateText(gobj, currMenu);
            EventMenu_UpdateText(gobj, currMenu);

            // also play sfx
            SFX_PlayCommon(0);
        }

        /*
        // no previous menu, unpause
        else
        {
            SFX_PlayCommon(0);

            menuData->isPaused = 0;

            // destroy menu
            EventMenu_DestroyMenu(gobj);

            // Unfreeze the game
            Match_UnfreezeGame(1);
            Match_ShowHUD();
            Match_AdjustSoundOnPause(0);
        }
        */
    }

    // if anything changed, update text
    if (isChanged != 0)
    {
        // update menu
        EventMenu_UpdateText(gobj, currMenu);
    }

    return;
}
void EventMenu_PopupThink(GOBJ *gobj, EventMenu *currMenu)
{

    MenuData *menuData = gobj->userdata;
    EventDesc *event_desc = menuData->event_desc;

    // get player who paused
    u8 pauser = menuData->controller_index; // get their  inputs
    HSD_Pad *pad = PadGet(pauser, PADGET_MASTER);
    int inputs_rapid = pad->rapidFire;
    int inputs_held = pad->held;
    int inputs = inputs_rapid;
    if ((inputs_held & HSD_TRIGGER_R) != 0)
        inputs = inputs_held;

    // get option variables
    int isChanged = 0;
    s32 cursor = menuData->popup_cursor;
    s32 scroll = menuData->popup_scroll;
    EventOption *currOption = &currMenu->options[currMenu->cursor + currMenu->scroll];
    s32 value_num = currOption->value_num;
    s32 cursor_min = 0;
    s32 cursor_max = value_num;
    if (cursor_max > MENU_POPMAXOPTION)
    {
        cursor_max = MENU_POPMAXOPTION;
    }

    // check for dpad down
    if (((inputs & HSD_BUTTON_DOWN) != 0) || ((inputs & HSD_BUTTON_DPAD_DOWN) != 0))
    {
        cursor += 1;

        // cursor is in bounds, move down
        if (cursor < cursor_max)
        {
            isChanged = 1;

            // update cursor
            menuData->popup_cursor = cursor;

            // also play sfx
            SFX_PlayCommon(2);
        }

        // cursor overflowed, check to scroll
        else
        {
            // cursor+scroll is in bounds, increment scroll
            if ((cursor + scroll) < value_num)
            {
                // adjust
                scroll++;
                cursor--;

                // update cursor
                menuData->popup_cursor = cursor;
                menuData->popup_scroll = scroll;

                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);
            }
        }
    }
    // check for dpad up
    else if (((inputs & HSD_BUTTON_UP) != 0) || ((inputs & HSD_BUTTON_DPAD_UP) != 0))
    {
        cursor -= 1;

        // cursor is in bounds, move up
        if (cursor >= 0)
        {
            isChanged = 1;

            // update cursor
            menuData->popup_cursor = cursor;

            // also play sfx
            SFX_PlayCommon(2);
        }

        // cursor overflowed, check to scroll
        else
        {
            // scroll is in bounds, decrement scroll
            if (scroll > 0)
            {
                // adjust
                scroll--;
                cursor++;

                // update cursor
                menuData->popup_cursor = cursor;
                menuData->popup_scroll = scroll;

                isChanged = 1;

                // also play sfx
                SFX_PlayCommon(2);
            }
        }
    }

    // check for A
    else if ((inputs_rapid & HSD_BUTTON_A) != 0)
    {

        // update option_val
        currOption->option_val = cursor + scroll;

        // run on change function if it exists
        if (currOption->onOptionChange != 0)
            currOption->onOptionChange(gobj, currOption->option_val);

        EventMenu_DestroyPopup(gobj);

        // update menu
        EventMenu_UpdateText(gobj, currMenu);

        // play sfx
        SFX_PlayCommon(1);
    }
    // check to go back a menu
    else if ((inputs_rapid & HSD_BUTTON_B) != 0)
    {

        EventMenu_DestroyPopup(gobj);

        // update menu
        EventMenu_UpdateText(gobj, currMenu);

        // play sfx
        SFX_PlayCommon(0);
    }

    // if anything changed, update text
    if (isChanged != 0)
    {
        // update menu
        EventMenu_UpdatePopupText(gobj, currOption);
    }

    return;
}
void EventMenu_CreateModel(GOBJ *gobj, EventMenu *menu)
{

    MenuData *menuData = gobj->userdata;

    // create options background
    evMenu *menuAssets = stc_evco_data.menu_assets;
    JOBJ *jobj_options = JOBJ_LoadJoint(menuAssets->menu);
    // Add to gobj
    GObj_AddObject(gobj, 3, jobj_options);
    GObj_DestroyGXLink(gobj);
    GObj_AddGXLink(gobj, EventMenu_MenuGX, GXLINK_MENUMODEL, GXPRI_MENUMODEL);

    // JOBJ array for getting the corner joints
    JOBJ *corners[4];

    // create a border and arrow for every row
    s32 option_num = menu->option_num;
    if (option_num > MENU_MAXOPTION)
        option_num = MENU_MAXOPTION;
    for (int i = 0; i < option_num; i++)
    {
        // create a border jobj
        JOBJ *jobj_border = JOBJ_LoadJoint(menuAssets->popup);
        // attach to root jobj
        JOBJ_AddChild(gobj->hsd_object, jobj_border);
        // move it into position
        JOBJ_GetChild(jobj_border, &corners, 2, 3, 4, 5, -1);
        // Modify scale and position
        jobj_border->trans.Z = ROWBOX_Z;
        jobj_border->scale.X = 1;
        jobj_border->scale.Y = 1;
        jobj_border->scale.Z = 1;
        corners[0]->trans.X = -(ROWBOX_WIDTH / 2) + ROWBOX_X;
        corners[0]->trans.Y = (ROWBOX_HEIGHT / 2) + ROWBOX_Y + (i * ROWBOX_YOFFSET);
        corners[1]->trans.X = (ROWBOX_WIDTH / 2) + ROWBOX_X;
        corners[1]->trans.Y = (ROWBOX_HEIGHT / 2) + ROWBOX_Y + (i * ROWBOX_YOFFSET);
        corners[2]->trans.X = -(ROWBOX_WIDTH / 2) + ROWBOX_X;
        corners[2]->trans.Y = -(ROWBOX_HEIGHT / 2) + ROWBOX_Y + (i * ROWBOX_YOFFSET);
        corners[3]->trans.X = (ROWBOX_WIDTH / 2) + ROWBOX_X;
        corners[3]->trans.Y = -(ROWBOX_HEIGHT / 2) + ROWBOX_Y + (i * ROWBOX_YOFFSET);
        JOBJ_SetFlags(jobj_border, JOBJ_HIDDEN);
        DOBJ_SetFlags(jobj_border->dobj, DOBJ_HIDDEN);
        jobj_border->dobj->next->mobj->mat->alpha = 0.6;
        //GXColor border_color = ROWBOX_COLOR;
        //jobj_border->dobj->next->mobj->mat->diffuse = border_color;
        // store pointer
        menuData->row_joints[i][0] = jobj_border;

        // create an arrow jobj
        JOBJ *jobj_arrow = JOBJ_LoadJoint(menuAssets->arrow);
        // attach to root jobj
        JOBJ_AddChild(gobj->hsd_object, jobj_arrow);
        // move it into position
        jobj_arrow->trans.X = TICKBOX_X;
        jobj_arrow->trans.Y = TICKBOX_Y + (i * ROWBOX_YOFFSET);
        jobj_arrow->trans.Z = ROWBOX_Z;
        jobj_arrow->scale.X = TICKBOX_SCALE;
        jobj_arrow->scale.Y = TICKBOX_SCALE;
        jobj_arrow->scale.Z = TICKBOX_SCALE;
        // change color
        //GXColor gx_color = {30, 40, 50, 255};
        //jobj_arrow->dobj->next->mobj->mat->diffuse = gx_color;

        JOBJ_SetFlags(jobj_arrow, JOBJ_HIDDEN);
        // store pointer
        menuData->row_joints[i][1] = jobj_arrow;
    }

    // create a highlight jobj
    JOBJ *jobj_highlight = JOBJ_LoadJoint(menuAssets->popup);
    // remove outline
    DOBJ_SetFlags(jobj_highlight->dobj, DOBJ_HIDDEN);
    // attach to root jobj
    JOBJ_AddChild(gobj->hsd_object, jobj_highlight);
    // move it into position
    JOBJ_GetChild(jobj_highlight, &corners, 2, 3, 4, 5, -1);
    // Modify scale and position
    jobj_highlight->trans.Z = MENUHIGHLIGHT_Z;
    jobj_highlight->scale.X = MENUHIGHLIGHT_SCALE;
    jobj_highlight->scale.Y = MENUHIGHLIGHT_SCALE;
    jobj_highlight->scale.Z = MENUHIGHLIGHT_SCALE;
    corners[0]->trans.X = -(MENUHIGHLIGHT_WIDTH / 2) + MENUHIGHLIGHT_X;
    corners[0]->trans.Y = (MENUHIGHLIGHT_HEIGHT / 2) + MENUHIGHLIGHT_Y;
    corners[1]->trans.X = (MENUHIGHLIGHT_WIDTH / 2) + MENUHIGHLIGHT_X;
    corners[1]->trans.Y = (MENUHIGHLIGHT_HEIGHT / 2) + MENUHIGHLIGHT_Y;
    corners[2]->trans.X = -(MENUHIGHLIGHT_WIDTH / 2) + MENUHIGHLIGHT_X;
    corners[2]->trans.Y = -(MENUHIGHLIGHT_HEIGHT / 2) + MENUHIGHLIGHT_Y;
    corners[3]->trans.X = (MENUHIGHLIGHT_WIDTH / 2) + MENUHIGHLIGHT_X;
    corners[3]->trans.Y = -(MENUHIGHLIGHT_HEIGHT / 2) + MENUHIGHLIGHT_Y;
    GXColor highlight = MENUHIGHLIGHT_COLOR;
    jobj_highlight->dobj->next->mobj->mat->alpha = 0.6;
    jobj_highlight->dobj->next->mobj->mat->diffuse = highlight;
    menuData->highlight_menu = jobj_highlight;

    // check to create scroll bar
    if (menuData->currMenu->option_num > MENU_MAXOPTION)
    {
        // create scroll bar
        JOBJ *scroll_jobj = JOBJ_LoadJoint(menuAssets->scroll);
        // attach to root jobj
        JOBJ_AddChild(gobj->hsd_object, scroll_jobj);
        // move it into position
        JOBJ_GetChild(scroll_jobj, &corners, 2, 3, -1);
        // scale scrollbar accordingly
        scroll_jobj->scale.X = MENUSCROLL_SCALE;
        scroll_jobj->scale.Y = MENUSCROLL_SCALEY;
        scroll_jobj->scale.Z = MENUSCROLL_SCALE;
        scroll_jobj->trans.X = MENUSCROLL_X;
        scroll_jobj->trans.Y = MENUSCROLL_Y;
        scroll_jobj->trans.Z = MENUSCROLL_Z;
        menuData->scroll_top = corners[0];
        menuData->scroll_bot = corners[1];
        GXColor highlight = MENUSCROLL_COLOR;
        scroll_jobj->dobj->next->mobj->mat->alpha = 0.6;
        scroll_jobj->dobj->next->mobj->mat->diffuse = highlight;

        // calculate scrollbar size
        int max_steps = menuData->currMenu->option_num - MENU_MAXOPTION;
        float botPos = MENUSCROLL_MAXLENGTH + (max_steps * MENUSCROLL_PEROPTION);
        if (botPos > MENUSCROLL_MINLENGTH)
            botPos = MENUSCROLL_MINLENGTH;

        // set size
        corners[1]->trans.Y = botPos;
    }
    else
    {
        menuData->scroll_bot = 0;
        menuData->scroll_top = 0;
    }

    return;
}
void EventMenu_CreateText(GOBJ *gobj, EventMenu *menu)
{

    // Get event info
    MenuData *menuData = gobj->userdata;
    EventDesc *event_desc = menuData->event_desc;
    Text *text;
    int subtext;
    int canvasIndex = menuData->canvas_menu;
    s32 cursor = menu->cursor;

    // free text if it exists
    if (menuData->text_name != 0)
    {
        // free text
        Text_Destroy(menuData->text_name);
        menuData->text_name = 0;
        Text_Destroy(menuData->text_value);
        menuData->text_value = 0;
        Text_Destroy(menuData->text_title);
        menuData->text_title = 0;
        Text_Destroy(menuData->text_desc);
        menuData->text_desc = 0;
    }
    if (menuData->text_popup != 0)
    {
        Text_Destroy(menuData->text_popup);
        menuData->text_popup = 0;
    }

    /*******************
    *** Create Title ***
    *******************/

    text = Text_CreateText(2, canvasIndex);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_title = text;
    // enable align and kerning
    text->align = 0;
    text->kerning = 1;
    text->use_aspect = 1;
    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;
    text->trans.Z = MENU_TEXTZ;
    text->aspect.X = MENU_TITLEASPECT;

    // output menu title
    float optionX = MENU_TITLEXPOS;
    float optionY = MENU_TITLEYPOS;
    subtext = Text_AddSubtext(text, optionX, optionY, "");
    Text_SetScale(text, subtext, MENU_TITLESCALE, MENU_TITLESCALE);

    /**************************
    *** Create Description ***
    *************************/

    text = Text_CreateText(2, canvasIndex);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_desc = text;

    /*******************
    *** Create Names ***
    *******************/

    text = Text_CreateText(2, canvasIndex);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_name = text;
    // enable align and kerning
    text->align = 0;
    text->kerning = 1;
    text->use_aspect = 1;
    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;
    text->trans.Z = MENU_TEXTZ;
    text->aspect.X = MENU_NAMEASPECT;

    // Output all options
    s32 option_num = menu->option_num;
    if (option_num > MENU_MAXOPTION)
        option_num = MENU_MAXOPTION;
    for (int i = 0; i < option_num; i++)
    {

        // output option name
        float optionX = MENU_OPTIONNAMEXPOS;
        float optionY = MENU_OPTIONNAMEYPOS + (i * MENU_TEXTYOFFSET);
        subtext = Text_AddSubtext(text, optionX, optionY, "");
    }

    /********************
    *** Create Values ***
    ********************/

    text = Text_CreateText(2, canvasIndex);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_value = text;
    // enable align and kerning
    text->align = 1;
    text->kerning = 1;
    text->use_aspect = 1;
    // scale canvas
    text->scale.X = MENU_CANVASSCALE;
    text->scale.Y = MENU_CANVASSCALE;
    text->trans.Z = MENU_TEXTZ;
    text->aspect.X = MENU_VALASPECT;

    // Output all values
    for (int i = 0; i < option_num; i++)
    {
        // output option value
        float optionX = MENU_OPTIONVALXPOS;
        float optionY = MENU_OPTIONVALYPOS + (i * MENU_TEXTYOFFSET);
        subtext = Text_AddSubtext(text, optionX, optionY, "");
    }

    return;
}
void EventMenu_UpdateText(GOBJ *gobj, EventMenu *menu)
{

    // Get event info
    MenuData *menuData = gobj->userdata;
    EventDesc *event_desc = menuData->event_desc;
    s32 cursor = menu->cursor;
    s32 scroll = menu->scroll;
    s32 option_num = menu->option_num;
    if (option_num > MENU_MAXOPTION)
        option_num = MENU_MAXOPTION;
    Text *text;

    // Update Title
    text = menuData->text_title;
    Text_SetText(text, 0, menu->name);

    // Update Description
    Text_Destroy(menuData->text_desc); // i think its best to recreate it...
    text = Text_CreateText(2, menuData->canvas_menu);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_desc = text;
    EventOption *currOption = &menu->options[menu->cursor + menu->scroll];

#define DESC_TXTSIZEX 5
#define DESC_TXTSIZEY 5
#define DESC_TXTASPECT 885
#define DESC_LINEMAX 4
#define DESC_CHARMAX 100
#define DESC_YOFFSET 30

    text->kerning = 1;
    text->align = 0;
    text->use_aspect = 1;

    // scale canvas
    text->scale.X = 0.01 * DESC_TXTSIZEX;
    text->scale.Y = 0.01 * DESC_TXTSIZEY;
    text->trans.X = MENU_DESCXPOS;
    text->trans.Y = MENU_DESCYPOS;
    text->trans.Z = MENU_TEXTZ;
    text->aspect.X = (DESC_TXTASPECT);

    char *msg = currOption->desc;

    // count newlines
    int line_num = 1;
    int line_length_arr[DESC_LINEMAX];
    char *msg_cursor_prev, *msg_cursor_curr; // declare char pointers
    msg_cursor_prev = msg;
    msg_cursor_curr = strchr(msg_cursor_prev, '\n'); // check for occurrence
    while (msg_cursor_curr != 0)                     // if occurrence found, increment values
    {
        // check if exceeds max lines
        if (line_num >= DESC_LINEMAX)
            assert("DESC_LINEMAX exceeded!");

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
        if (line_length > DESC_CHARMAX)
            assert("DESC_CHARMAX exceeded!");

        // copy char array
        char msg_line[DESC_CHARMAX + 1];
        memcpy(msg_line, msg, line_length);

        // add null terminator
        msg_line[line_length] = '\0';

        // increment msg
        msg += (line_length + 1); // +1 to skip past newline

        // print line
        int y_delta = (i * DESC_YOFFSET);
        Text_AddSubtext(text, 0, y_delta, msg_line);
    }

    /* 
    Update Names
    */

    // Output all options
    text = menuData->text_name;
    for (int i = 0; i < option_num; i++)
    {
        // get this option
        EventOption *currOption = &menu->options[scroll + i];

        // output option name
        int optionVal = currOption->option_val;
        Text_SetText(text, i, currOption->option_name);

        // output color
        GXColor color;
        if (currOption->disable == 0)
        {
            color.r = 255;
            color.b = 255;
            color.g = 255;
            color.a = 255;
        }
        else
        {
            color.r = 128;
            color.b = 128;
            color.g = 128;
            color.a = 0;
        }
        Text_SetColor(text, i, &color);
    }

    /* 
    Update Values
    */

    // Output all values
    text = menuData->text_value;
    for (int i = 0; i < option_num; i++)
    {
        // get this option
        EventOption *currOption = &menu->options[scroll + i];
        int optionVal = currOption->option_val;

        // hide row models
        JOBJ_SetFlags(menuData->row_joints[i][0], JOBJ_HIDDEN);
        JOBJ_SetFlags(menuData->row_joints[i][1], JOBJ_HIDDEN);

        // if this option has string values
        if (currOption->option_kind == OPTKIND_STRING)
        {
            // output option value
            Text_SetText(text, i, currOption->option_values[optionVal]);

            // show box
            JOBJ_ClearFlags(menuData->row_joints[i][0], JOBJ_HIDDEN);
        }

        // if this option has int values
        else if (currOption->option_kind == OPTKIND_INT)
        {
            // output option value
            Text_SetText(text, i, currOption->option_values, optionVal);

            // show box
            JOBJ_ClearFlags(menuData->row_joints[i][0], JOBJ_HIDDEN);
        }

        // if this option is a menu or function
        else if ((currOption->option_kind == OPTKIND_MENU) || (currOption->option_kind == OPTKIND_FUNC))
        {
            Text_SetText(text, i, "");

            // show arrow
            //JOBJ_ClearFlags(menuData->row_joints[i][1], JOBJ_HIDDEN);
        }

        // output color
        GXColor color;
        if (currOption->disable == 0)
        {
            color.r = 255;
            color.b = 255;
            color.g = 255;
            color.a = 255;
        }
        else
        {
            color.r = 128;
            color.b = 128;
            color.g = 128;
            color.a = 0;
        }
        Text_SetColor(text, i, &color);
    }

    // update cursor position
    JOBJ *highlight_joint = menuData->highlight_menu;
    highlight_joint->trans.Y = cursor * MENUHIGHLIGHT_YOFFSET;

    // update scrollbar position
    if (menuData->scroll_top != 0)
    {
        float curr_steps = menuData->currMenu->scroll;
        float max_steps;
        if (menuData->currMenu->option_num < MENU_MAXOPTION)
            max_steps = 0;
        else
            max_steps = menuData->currMenu->option_num - MENU_MAXOPTION;

        // scrollTop = -1 * ((curr_steps/max_steps) * (botY - -10))
        menuData->scroll_top->trans.Y = -1 * (curr_steps / max_steps) * (menuData->scroll_bot->trans.Y - MENUSCROLL_MAXLENGTH);
    }

    // update jobj
    JOBJ_SetMtxDirtySub(gobj->hsd_object);

    return;
}
void EventMenu_DestroyMenu(GOBJ *gobj)
{
    MenuData *menuData = gobj->userdata; // userdata

    // remove
    Text_Destroy(menuData->text_name);
    menuData->text_name = 0;
    // remove
    Text_Destroy(menuData->text_value);
    menuData->text_value = 0;
    // remove
    Text_Destroy(menuData->text_title);
    menuData->text_title = 0;
    // remove
    Text_Destroy(menuData->text_desc);
    menuData->text_desc = 0;

    // if popup box exists
    if (menuData->text_popup != 0)
        EventMenu_DestroyPopup(gobj);

    // if custom menu gobj exists
    if (menuData->custom_gobj != 0)
    {
        // run on destroy function
        if (menuData->custom_gobj_destroy != 0)
            menuData->custom_gobj_destroy(menuData->custom_gobj);

        // null pointers
        menuData->custom_gobj = 0;
        menuData->custom_gobj_destroy = 0;
        menuData->custom_gobj_think = 0;
    }

    // set menu as visible
    stc_evco_data.hide_menu = 0;

    // remove jobj
    GObj_FreeObject(gobj);
    //GObj_DestroyGXLink(gobj);

    return;
}
void EventMenu_CreatePopupModel(GOBJ *gobj, EventMenu *menu)
{
    // init variables
    MenuData *menuData = gobj->userdata; // userdata
    s32 cursor = menu->cursor;
    EventOption *option = &menu->options[cursor];

    // create options background
    evMenu *menuAssets = stc_evco_data.menu_assets;

    // create popup gobj
    GOBJ *popup_gobj = GObj_Create(0, 0, 0);

    // load popup joint
    JOBJ *popup_joint = JOBJ_LoadJoint(menuAssets->popup);

    // Get each corner's joints
    JOBJ *corners[4];
    JOBJ_GetChild(popup_joint, &corners, 2, 3, 4, 5, -1);

    // Modify scale and position
    popup_joint->scale.X = POPUP_SCALE;
    popup_joint->scale.Y = POPUP_SCALE;
    popup_joint->scale.Z = POPUP_SCALE;
    popup_joint->trans.Z = POPUP_Z;
    corners[0]->trans.X = -(POPUP_WIDTH / 2);
    corners[0]->trans.Y = (POPUP_HEIGHT / 2);
    corners[1]->trans.X = (POPUP_WIDTH / 2);
    corners[1]->trans.Y = (POPUP_HEIGHT / 2);
    corners[2]->trans.X = -(POPUP_WIDTH / 2);
    corners[2]->trans.Y = -(POPUP_HEIGHT / 2);
    corners[3]->trans.X = (POPUP_WIDTH / 2);
    corners[3]->trans.Y = -(POPUP_HEIGHT / 2);

    /*
    // Change color
    GXColor gx_color = TEXT_BGCOLOR;
    popup_joint->dobj->mobj->mat->diffuse = gx_color;
*/

    // add to gobj
    GObj_AddObject(popup_gobj, 3, popup_joint);
    // add gx link
    GObj_AddGXLink(popup_gobj, EventMenu_MenuGX, GXLINK_POPUPMODEL, GXPRI_POPUPMODEL);
    // save pointer
    menuData->popup = popup_gobj;

    // adjust scrollbar scale

    // position popup X and Y (based on cursor value)
    popup_joint->trans.X = POPUP_X;
    popup_joint->trans.Y = POPUP_Y + (POPUP_YOFFSET * cursor);

    // create a highlight jobj
    JOBJ *jobj_highlight = JOBJ_LoadJoint(menuAssets->popup);
    // attach to root jobj
    JOBJ_AddChild(popup_gobj->hsd_object, jobj_highlight);
    // move it into position
    JOBJ_GetChild(jobj_highlight, &corners, 2, 3, 4, 5, -1);
    // Modify scale and position
    jobj_highlight->trans.Z = POPUPHIGHLIGHT_Z;
    jobj_highlight->scale.X = 1;
    jobj_highlight->scale.Y = 1;
    jobj_highlight->scale.Z = 1;
    corners[0]->trans.X = -(POPUPHIGHLIGHT_WIDTH / 2) + POPUPHIGHLIGHT_X;
    corners[0]->trans.Y = (POPUPHIGHLIGHT_HEIGHT / 2) + POPUPHIGHLIGHT_Y;
    corners[1]->trans.X = (POPUPHIGHLIGHT_WIDTH / 2) + POPUPHIGHLIGHT_X;
    corners[1]->trans.Y = (POPUPHIGHLIGHT_HEIGHT / 2) + POPUPHIGHLIGHT_Y;
    corners[2]->trans.X = -(POPUPHIGHLIGHT_WIDTH / 2) + POPUPHIGHLIGHT_X;
    corners[2]->trans.Y = -(POPUPHIGHLIGHT_HEIGHT / 2) + POPUPHIGHLIGHT_Y;
    corners[3]->trans.X = (POPUPHIGHLIGHT_WIDTH / 2) + POPUPHIGHLIGHT_X;
    corners[3]->trans.Y = -(POPUPHIGHLIGHT_HEIGHT / 2) + POPUPHIGHLIGHT_Y;
    GXColor highlight = POPUPHIGHLIGHT_COLOR;
    jobj_highlight->dobj->next->mobj->mat->alpha = 0.6;
    jobj_highlight->dobj->next->mobj->mat->diffuse = highlight;

    menuData->highlight_popup = jobj_highlight;

    return;
}
void EventMenu_CreatePopupText(GOBJ *gobj, EventMenu *menu)
{
    // init variables
    MenuData *menuData = gobj->userdata;
    s32 cursor = menu->cursor;
    EventOption *option = &menu->options[cursor];
    int subtext;
    int canvasIndex = menuData->canvas_popup;
    s32 value_num = option->value_num;
    if (value_num > MENU_POPMAXOPTION)
        value_num = MENU_POPMAXOPTION;

    ///////////////////
    // Create Values //
    ///////////////////

    Text *text = Text_CreateText(2, canvasIndex);
    text->gobj->gx_cb = EventMenu_TextGX;
    menuData->text_popup = text;
    // enable align and kerning
    text->align = 1;
    text->kerning = 1;
    // scale canvas
    text->scale.X = POPUP_CANVASSCALE;
    text->scale.Y = POPUP_CANVASSCALE;
    text->trans.Z = POPUP_TEXTZ;

    // determine base Y value
    float baseYPos = POPUP_OPTIONVALYPOS + (cursor * MENU_TEXTYOFFSET);

    // Output all values
    for (int i = 0; i < value_num; i++)
    {
        // output option value
        float optionX = POPUP_OPTIONVALXPOS;
        float optionY = baseYPos + (i * POPUP_TEXTYOFFSET);
        subtext = Text_AddSubtext(text, optionX, optionY, "");
    }

    return;
}
void EventMenu_UpdatePopupText(GOBJ *gobj, EventOption *option)
{
    // init variables
    MenuData *menuData = gobj->userdata; // userdata
    s32 cursor = menuData->popup_cursor;
    s32 scroll = menuData->popup_scroll;
    s32 value_num = option->value_num;
    if (value_num > MENU_POPMAXOPTION)
        value_num = MENU_POPMAXOPTION;

    ///////////////////
    // Update Values //
    ///////////////////

    Text *text = menuData->text_popup;

    // update int list
    if (option->option_kind == OPTKIND_INT)
    {
        // Output all values
        for (int i = 0; i < value_num; i++)
        {
            // output option value
            Text_SetText(text, i, "%d", scroll + i);
        }
    }

    // update string list
    else if (option->option_kind == OPTKIND_STRING)
    {
        // Output all values
        for (int i = 0; i < value_num; i++)
        {
            // output option value
            Text_SetText(text, i, option->option_values[scroll + i]);
        }
    }

    // update cursor position
    JOBJ *highlight_joint = menuData->highlight_popup;
    highlight_joint->trans.Y = cursor * POPUPHIGHLIGHT_YOFFSET;
    JOBJ_SetMtxDirtySub(highlight_joint);

    return;
}
void EventMenu_DestroyPopup(GOBJ *gobj)
{
    MenuData *menuData = gobj->userdata; // userdata

    // remove text
    Text_Destroy(menuData->text_popup);
    menuData->text_popup = 0;

    // destory gobj
    GObj_Destroy(menuData->popup);
    menuData->popup = 0;

    // also change the menus state
    EventMenu *currMenu = menuData->currMenu;
    currMenu->state = EMSTATE_FOCUS;
}
