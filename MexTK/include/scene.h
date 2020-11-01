#ifndef MEX_H_SCENE
#define MEX_H_SCENE

#include "structs.h"
#include "datatypes.h"
#include "match.h"
#include "result.h"

// Scene Enums
enum HEAP_KIND
{
    HEAPKIND_UNK0,
    HEAPKIND_UNK1,
    HEAPKIND_UNK2,
    HEAPKIND_UNK3,
    HEAPKIND_UNK4,
};
enum MINOR_KIND
{
    MNRKIND_TITLE,      // Title Screen
    MNRKIND_MNMA,       // Main Menu
    MNRKIND_MATCH,      // VS Dairantou (In-Game)
    MNRKIND_SUDDEATH,   // Sudden Death Dairantou (In-Game)
    MNRKIND_TRAIN,      // Training Mode Dairantou (In-Game)
    MNRKIND_RST,        // Result Screen
    MNRKIND_X6,         //
    MNRKIND_DB,         // Debug Menu
    MNRKIND_CSS,        // CSS
    MNRKIND_SSS,        // SSS
    MNRKIND_XA,         //
    MNRKIND_TYGAL,      // Trophy Gallery
    MNRKIND_TYLOT,      // Trophy Lottery
    MNRKIND_TYCOL,      // Trophy Collection
    MNRKIND_ADVSPLSH,   // Adventure Mode Splash Screen
    MNRKIND_TYFALL,     // 1P Mode Trophy Falling Cutscene
    MNRKIND_ADVCGRT,    // Adventure Mode Congratulations
    MNRKIND_VI1,        // VisualScene_Luigi
    MNRKIND_VI2,        // VisualScene_BrinstarLava
    MNRKIND_VI3,        // VisualScene_PlanetExplode
    MNRKIND_VI4,        // VisualScene_3KirbysSpawn
    MNRKIND_VI5,        // VisualScene_GiantKirbySpawns
    MNRKIND_VI6,        // VisualScene_StarFoxDialog
    MNRKIND_VI7,        // VisualScene_FZeroRace
    MNRKIND_VI8,        // VisualScene_MetalMarioLuigi
    MNRKIND_VI9,        // VisualScene_BowserTrophyFalls
    MNRKIND_VI10,       // VisualScene_GigaBowserTransformation
    MNRKIND_VI11,       // VisualScene_GigaBowserDefeated
    MNRKIND_OP,         // Opening Movie
    MNRKIND_1PENDMV,    // 1P Mode End Movie
    MNRKIND_HOWMV,      // How to Play Movie
    MNRKIND_OMAKE,      // Special Movie
    MNRKIND_CLSCSPLSH,  // TEST
    MNRKIND_ALSPLSH,    // TEST
    MNRKIND_GMOV,       // Game over
    MNRKIND_SOON,       // coming soon
    MNRKIND_TOSETUP,    // tournament setup
    MNRKIND_TOBRCK,     // tourn bracket
    MNRKIND_TOUNK,      // tourn unk
    MNRKIND_SPCLMSG,    // special msg
    MNRKIND_PROG,       // progressive
    MNRKIND_CHLG,       // challenger
    MNRKIND_CARD,       // memcard prompt
    MNRKIND_STAFF,      // credits
    MNRKIND_CAMWARN,    // camera mode memcard prompt
    MNRKIND_NULL,       // terminator
    MNRKIND_SMSHDWNCSS, // custom smashdown css
};

struct MajorScene
{
    u8 is_preload;
    u8 major_id;
    void *onLoad;
    void *onExit;
    void *onBoot;
    void *MinorScene; // array of minor scenes
};
struct MinorScene
{
    u8 minor_id;        // is 255 for last entry
    u8 heap_kind;       // heap behavior
    void *minor_prep;   // inits data for this minor (major exclusive)
    void *minor_decide; // decides next minor scene
    u8 minor_kind;      // index for a re-useable list of scene functions. contains a load, think, and leave function.
    void *load_data;    // points to static data used throughout this minor. other minors may use the same pointer to exchange data between minors
    void *unload_data;  // points to static data used throughout this minor. other minors may use the same pointer to exchange data between minors
};

struct ScDataVS
{
    u8 x8;
    u8 x9;
    u8 xa;
    int xc;
    MatchInit match_init;
};

struct ScDataRst
{
    int x0;
    int x4;
    int x8;
    int xc;
    RstInit rst_init;
};

void Scene_EnterMajor(int major_id);
void CSS_DecideNext(MinorScene *minor_scene, ScDataVS *css_data);
void CSS_ResetKOStars();
void CSS_InitMajorData(ScDataVS *major_data);
void CSS_InitMinorData(MinorScene *minor_scene, ScDataVS *major_data, int css_kind);
void SSS_InitMinorData(MinorScene *minor_scene, ScDataVS *major_data);
void Match_InitMinorData(MinorScene *minor_scene, ScDataVS *major_data, void *init_cb, void *startmelee_cb);
void Match_SetNametags(MatchInit *match_init);
#endif
