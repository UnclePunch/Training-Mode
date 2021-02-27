#include "../../../m-ex/MexTK/mex.h"
#include "../../../patch/tm.h"
#include "mjEv.h"

// static variables
static ScDataVS major_data = {0};         // final VS data. each scene adds its data to this
static ESSMinorData ess_minor_data = {0}; // event select screen minor scene data
static VSMinorData css_minor_data = {0};  // css minor scene data
static SSSMinorData sss_minor_data = {0}; // sss minor scene data

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

    return;
};

// Menu Functions
void Menu_Prep(MinorScene *minor_scene)
{

    ESSMinorData *ess_data = minor_scene->load_data;

    // reset leave_kind
    ess_data->leave_kind = 0;

    return;
}
void Menu_Decide(MinorScene *minor_scene)
{

    ESSMinorData *ess_data = minor_scene->load_data;

    bp();

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

    // determine CSS kind based on event
    int css_kind;
    if (tm_function->GetIsChooseCPU(ess_minor_data.page, ess_minor_data.event))
        css_kind = 23; // training CSS
    else
        css_kind = 14; // event CSS

    // copy
    CSS_InitMinorData(minor_scene, &major_data, css_kind);

    return;
}
void CSS_Decide(MinorScene *minor_scene)
{

    VSMinorData *css_data = minor_scene->load_data;

    bp();

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

        // load ssms

        // advance to next minor
        Scene_SetNextMinor(2);
        Scene_ExitMinor();
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

    // get event callback

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