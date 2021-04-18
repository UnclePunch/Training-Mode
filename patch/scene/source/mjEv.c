#include "../../../m-ex/MexTK/mex.h"
#include "../../../patch/tm.h"
#include "mjEv.h"
#include "events.c"

// static variables
static ScDataVS major_data = {0};         // final VS data. each scene adds its data to this
static ESSMinorData ess_minor_data = {0}; // event select screen minor scene data
static VSMinorData css_minor_data = {0};  // css minor scene data
static SSSMinorData sss_minor_data = {0}; // sss minor scene data
static int stc_play_song;                 // bool to play alt song

// Major onload
void Major_Load()
{

    /*
    this is usually done on the scene's onboot function
    but this code isnt available on boot, so we init stuff here
    */
    // init major data
    memset(&major_data, 0, sizeof(major_data));
    CSS_InitMajorData(&major_data);

    CSS_ResetKOStars();

    // set starting page
    ess_minor_data.page = 1;
    ess_minor_data.event = 0;
    ess_minor_data.cursor.pos = 0;
    ess_minor_data.cursor.scroll = 0;

    return;
};

// Menu Functions
void Menu_Prep(MinorScene *minor_scene)
{

    ESSMinorData *ess_data = minor_scene->load_data;

    // reset leave_kind
    ess_data->leave_kind = 0;

    // store pointer to event lookup
    ess_data->ev_lookup = &stc_event_lookup;

    return;
}
void Menu_Decide(MinorScene *minor_scene)
{

    ESSMinorData *ess_data = minor_scene->load_data;

    // back to main menu
    if (ess_data->leave_kind == 1)
    {
        Scene_SetNextMajor(1);
        Scene_ExitMajor();
    }
    // go to CSS
    else if (ess_data->leave_kind == 2)
    {
        Scene_SetNextMinor(1);
        Scene_ExitMinor();
    }

    return;
}

// CSS Functions
void CSS_Prep(MinorScene *minor_scene)
{

    VSMinorData *css_data = minor_scene->load_data;

    int page = ess_minor_data.page;
    int event = ess_minor_data.event;
    int is_choose_cpu = GetIsChooseCPU(page, event);
    int is_choose_stage = GetIsSelectStage(page, event);

    // determine CSS kind based on event
    int css_kind;
    if (is_choose_cpu)
        css_kind = 23; // training CSS
    else
        css_kind = 14; // event CSS

    // init minor
    CSS_InitMinorData(minor_scene, &major_data, css_kind);

    // get CPU and stage from tmFunction
    Preload *preload = Preload_GetTable();
    if (is_choose_cpu == 0)
    {
        int cpu_kind = GetCPUFighter(page, event);
        //css_data->vs_data.match_init.playerData[1].kind = cpu_kind;
        preload->fighters[1].kind = cpu_kind;
    }
    if (is_choose_stage == 0)
    {
        int stage_kind = GetStage(page, event);
        //css_data->vs_data.match_init.stage = stage_kind;
        preload->stage = stage_kind;
    }
    // not sure if i should force a preload here or if
    // the game will handle it...

    return;
}
void CSS_Decide(MinorScene *minor_scene)
{

    VSMinorData *css_data = minor_scene->load_data;

    // check to return to ESS
    if (css_data->exit_kind == 2)
    {
        Scene_SetNextMinor(0);
        Scene_ExitMinor();
    }
    else
    {
        // copy match data, load ssm's, advance to SSS
        memcpy(&major_data, &css_data->vs_data, sizeof(major_data));

        // TODO! load ssms

        // check if this event has a stage defined
        if (GetIsSelectStage(ess_minor_data.page, ess_minor_data.event))
        {
            // advance to next minor (SSS)
            Scene_SetNextMinor(2);
            Scene_ExitMinor();
        }
        else
        {
            // advance to match scene
            Scene_SetNextMinor(3);
            Scene_ExitMinor();
        }
    }

    // copy CSS data to major data, load ssm's, and decide next scene
    //CSS_DecideNext(minor_scene, &major_data);

    return;
}

// SSS Functions
void SSS_Prep(MinorScene *minor_scene)
{

    // copy
    SSS_InitMinorData(minor_scene, &major_data);

    return;
}
void SSS_Decide(MinorScene *minor_scene)
{

    SSSMinorData *sss_data = minor_scene->load_data;

    // copy CSS data to major data, load ssm's, and decide next scene
    SSS_DecideNext(minor_scene, &major_data, 1);

    return;
}

// Match Functions
void Match_Prep(MinorScene *minor_scene)
{

    MatchInit *minor_data = minor_scene->load_data;
    int page = ess_minor_data.page;
    int event = ess_minor_data.event;

    // init match data
    EventInit(page, event, &major_data.match_init);

    // copy to match data
    Match_InitMinorData(minor_scene, &major_data, 0, 0);

    return;
}

// Minor scene table
static MinorScene minor_scene[] = {
    // Menu
    {
        .minor_id = 0,
        .heap_kind = HEAPKIND_UNK3,
        .minor_prep = Menu_Prep,     //0x801b14a0,
        .minor_decide = Menu_Decide, //0x801b14dc,
        .minor_kind = 60,
        .load_data = &ess_minor_data,
        .unload_data = &ess_minor_data,
    },
    // CSS
    {
        .minor_id = 1,
        .heap_kind = HEAPKIND_UNK3,
        .minor_prep = CSS_Prep,     //0x801b14a0,
        .minor_decide = CSS_Decide, //0x801b14dc,
        .minor_kind = MNRKIND_CSS,
        .load_data = &css_minor_data,
        .unload_data = &css_minor_data,
    },
    // SSS @ 80722c74
    {
        .minor_id = 2,
        .heap_kind = HEAPKIND_UNK3,
        .minor_prep = SSS_Prep, // 0x801b1514
        .minor_decide = SSS_Decide,
        .minor_kind = MNRKIND_SSS,
        .load_data = &sss_minor_data,
        .unload_data = &sss_minor_data,
    },
    // Match
    {
        .minor_id = 3,
        .heap_kind = HEAPKIND_UNK3,
        .minor_prep = Match_Prep, // 0x801b1588,
        .minor_decide = 0x801b15c8,
        .minor_kind = MNRKIND_MATCH,
        .load_data = 0x80480530,   // is a matchinit pointer
        .unload_data = 0x80479d98, // os a rstdata pointer
    },
};

///////////////////////
/// Event Functions ///
///////////////////////

void EventInit(int page, int eventID, MatchInit *match_data)
{

    /* 
    This function runs when leaving the main menu/css and handles
    setting up the match information, such as rules, players, stage.
    All of this data comes from the EventDesc in events.c
    */

    // get event pointer
    EventDesc *event = GetEventDesc(page, eventID);

    //Init default match info
    match_data->timer_unk2 = 0;
    match_data->unk2 = 1;
    match_data->unk7 = 1;
    match_data->isCheckStockSteal = 1;
    match_data->unk10 = 3;
    match_data->isSkipEndCheck = 1;
    match_data->itemFreq = MATCH_ITEMFREQ_OFF;
    match_data->onStartMelee = EventLoad;

    //Copy event's match info struct
    EventMatchData *ev_matchdata = event->matchData;
    match_data->timer = ev_matchdata->timer;
    match_data->matchType = ev_matchdata->matchType;
    match_data->isDisableMusic = ev_matchdata->isDisableMusic;
    match_data->hideGo = ev_matchdata->hideGo;
    match_data->hideReady = ev_matchdata->hideReady;
    match_data->isCreateHUD = ev_matchdata->isCreateHUD;
    match_data->isDisablePause = ev_matchdata->isDisablePause;
    match_data->timerRunOnPause = ev_matchdata->timerRunOnPause;
    match_data->isHidePauseHUD = ev_matchdata->isHidePauseHUD;
    match_data->isShowLRAStart = ev_matchdata->isShowLRAStart;
    match_data->isCheckForLRAStart = ev_matchdata->isCheckForLRAStart;
    match_data->isShowZRetry = ev_matchdata->isShowZRetry;
    match_data->isCheckForZRetry = ev_matchdata->isCheckForZRetry;
    match_data->isShowAnalogStick = ev_matchdata->isShowAnalogStick;
    match_data->isShowScore = ev_matchdata->isShowScore;
    match_data->isRunStockLogic = ev_matchdata->isRunStockLogic;
    match_data->isDisableHit = ev_matchdata->isDisableHit;
    match_data->timerSeconds = ev_matchdata->timerSeconds;
    match_data->timerSubSeconds = ev_matchdata->timerSubSeconds;
    match_data->onCheckPause = ev_matchdata->onCheckPause;
    match_data->onMatchEnd = ev_matchdata->onMatchEnd;

    // check to play alt song
    if (Pad_GetHeld(*stc_css_singeplyport) & PAD_TRIGGER_L)
    {
        match_data->isDisableMusic = 1;
        stc_play_song = 1;
    }
    else
        stc_play_song = 0;

    // Initialize all player data
    Memcard *memcard = R13_PTR(MEMCARD);
    CSSBackup eventBackup = memcard->EventBackup;
    for (int i = 0; i < 6; i++)
    {
        // initialize data
        CSS_InitPlayerData(&match_data->playerData[i]);

        // set to enter fall on match start
        match_data->playerData[i].isEntry = false;

        // copy nametag id for the player
        if (i == 0)
        {
            // Update the player's nametag ID
            match_data->playerData[i].nametag = eventBackup.nametag;

            // Update the player's rumble setting
            int tagRumble = CSS_GetNametagRumble(0, match_data->playerData[0].nametag);
            match_data->playerData[0].isRumble = tagRumble;
        }
    }

    // Determine player ports
    u8 hmn_port = *stc_css_hmnport + 1;
    u8 cpu_port = *stc_css_cpuport + 1;

    // Determine the Player
    s32 playerKind;
    s32 playerCostume;
    Preload *preload = Preload_GetTable();
    // If fighter is -1, copy the player from event data
    if (ev_matchdata->playerKind != -1)
    {
        playerKind = ev_matchdata->playerKind;
        playerCostume = 0;
    }
    // use the fighter chosen on the CSS
    else
    {
        playerKind = preload->fighters[0].kind;
        playerCostume = preload->fighters[0].costume;
    }

    // Determine the CPU
    s32 cpuKind;
    s32 cpuCostume;
    // If isChooseCPU is true, use the selected CPU
    if (event->isChooseCPU == true)
    {
        cpuKind = preload->fighters[1].kind;
        cpuCostume = preload->fighters[1].costume;

        // change zelda to sheik
        if (cpuKind == 18)
        {
            cpuKind = 19;
            preload->fighters[1].kind = cpuKind;
        }
    }
    // If isChooseCPU is false, copy the CPU from event data
    else
    {
        cpuKind = ev_matchdata->cpuKind;
        cpuCostume = 0;
        cpuCostume = 0;
    }

    // Check if CPU is using the same character and color as P1
    if ((playerKind == cpuKind) && (playerCostume == cpuCostume))
    {
        // this doesnt account for if theyre both using the last costume
        cpuCostume += 1;
    }

    // Copy player data to match info struct (update their rumble setting 801bb1ec)
    match_data->playerData[0].kind = playerKind;
    match_data->playerData[0].costume = playerCostume;
    match_data->playerData[0].status = 0;
    match_data->playerData[0].portNumberOverride = hmn_port;

    // Copy CPU if they exist for this event
    if (cpuKind != -1)
    {
        match_data->playerData[1].kind = cpuKind;
        match_data->playerData[1].costume = cpuCostume;
        match_data->playerData[1].status = 1;
        match_data->playerData[1].portNumberOverride = cpu_port;
        match_data->playerData[1].cpuKind = 5; // set to manual AI?
    }

    // Determine the correct HUD position for this amount of players
    int hudPos = 0;
    for (int i = 0; i < 6; i++)
    {
        if (match_data->playerData[i].status != 3)
            hudPos++;
    }
    match_data->hudPos = hudPos;

    // Determine the Stage
    int stage;
    // If isSelectStage is true, use the selected stage
    if (event->isSelectStage == true)
    {
        stage = preload->stage;
    }
    // If isSelectStage is false, copy the stage from event data
    else
    {
        stage = ev_matchdata->stage;
    }
    // Update match struct with this stage
    match_data->stage = stage;

    //Update preload table? (801bb63c)

    return;
};
void EventLoad()
{

    // get this event
    int page = ess_minor_data.page;
    int event = ess_minor_data.event;
    EventDesc *event_desc = GetEventDesc(page, event);

    // ensure event has a file
    if (event_desc->eventFile)
    {

        // load EvCo
        evcoFunction evcoFunction;
        ArchiveInfo *evco_archive = MEX_LoadRelArchive("TM/EvCo.dat", &evcoFunction, "evcoFunction");
        evcoFunction.OnLoad(evco_archive); // execute onload function
        evco_data = *evco_data_ptr;        // get event common data pointer
        // init evFunction
        evFunction *evFunction = &evco_data->evFunction;
        memset(evFunction, 0, sizeof(*evFunction)); // clear evFunction

        // load evcommon.ssm
        Audio_RequestSSMLoad(56);
        Audio_UpdateCache();
        Audio_SyncLoadAll();

        // append extension
        static char *extension = "TM/%s.dat";
        char *buffer[20];
        sprintf(buffer, extension, event_desc->eventFile);

        // load this events file
        ArchiveInfo *archive = MEX_LoadRelArchive(buffer, evFunction, "evFunction");
        evco_data->event_archive = archive;

        // Store ptr to events scenario assets if exists
        evco_data->scn_assets = File_GetSymbol(archive, "scnData");

        // Create this event's gobj
        int pri = event_desc->callbackPriority;
        void *cb = evFunction->Event_Think;
        GOBJ *gobj = GObj_Create(0, 7, 0);
        int *userdata = calloc(EVENT_DATASIZE);
        GObj_AddUserData(gobj, 4, HSD_Free, userdata);
        GObj_AddProc(gobj, cb, pri);

        // store pointer to the event's data
        userdata[0] = event_desc;

        // init the pause menu,
        // i would have dont this in the OnLoad function in common.c but
        // the init function needs the initial menu pointer
        GOBJ *menu_gobj = evcoFunction.EventMenu_Init(event_desc, *evFunction->menu_start);

        // Init static structure containing event variables
        evco_data->event_desc = event_desc;
        evco_data->event_gobj = gobj;
        evco_data->menu_gobj = menu_gobj;

        // disable hazards if enabled
        if (event_desc->disable_hazards == 1)
            Hazards_Disable();

        // Run this event's init function
        if (evFunction->Event_Init != 0)
            evFunction->Event_Init(gobj);
    }
    // init legacy event
    else
    {
        // get legacy onload
        void *(*Event_GetLegacyCallback)(int page, int event) = 0x804df9dc;
        void *(*Legacy_OnLoad)() = Event_GetLegacyCallback(page, event);
        Legacy_OnLoad();
    }

    if (stc_play_song)
        BGM_Play(ALT_SONG);

    return;
};

void Hazards_Disable()
{
    // get stage id
    int stage_internal = Stage_ExternalToInternal(Stage_GetExternalID());
    int is_fixwind = 0;

    switch (stage_internal)
    {
    case (GRKIND_STORY):
    {
        // remove shyguy map gobj proc
        GOBJ *shyguy_gobj = Stage_GetMapGObj(3);
        GObj_RemoveProc(shyguy_gobj);

        // remove randall
        GOBJ *randall_gobj = Stage_GetMapGObj(2);
        Stage_DestroyMapGObj(randall_gobj);

        is_fixwind = 1;

        break;
    }
    case (GRKIND_PSTAD):
    {
        // remove map gobj proc
        GOBJ *map_gobj = Stage_GetMapGObj(2);
        GObj_RemoveProc(map_gobj);

        is_fixwind = 1;

        break;
    }
    case (GRKIND_OLDPU):
    {
        // remove map gobj proc
        GOBJ *map_gobj = Stage_GetMapGObj(7);
        GObj_RemoveProc(map_gobj);

        // remove map gobj proc
        map_gobj = Stage_GetMapGObj(6);
        GObj_RemoveProc(map_gobj);

        // set wind hazard num to 0
        *ftchkdevice_windnum = 0;

        break;
    }
    case (GRKIND_FD):
    {
        // set bg skip flag
        GOBJ *map_gobj = Stage_GetMapGObj(3);
        MapData *map_data = map_gobj->userdata;
        map_data->xc4 |= 0x40;

        // remove on-go function that changes this flag
        StageOnGO *on_go = stc_stage->on_go;
        stc_stage->on_go = on_go->next;
        HSD_Free(on_go);

        break;
    }
    }

    // Certain stages have an essential dynamics function
    // in their map_gobj think function. If the think function is removed,
    // the dynamics function must be re-added to function properly.
    if (is_fixwind == 1)
    {
        GOBJ *wind_gobj = GObj_Create(3, 5, 0);
        GObj_AddProc(wind_gobj, Dynamics_DecayWind, 4);
    }
}
