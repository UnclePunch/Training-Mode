#ifndef MEX_H_STRUCTS
#define MEX_H_STRUCTS

/* 
 *  defines typedefs for structs used throughout m-ex
 */

// Basic Data Structs
typedef struct Vec2 Vec2;
typedef struct Vec3 Vec3;
typedef struct Vec4 Vec4;

// OS
typedef struct OSInfo OSInfo;
typedef struct OSCalendarTime OSCalendarTime;
typedef struct CARDStat CARDStat;
typedef struct CARDFileInfo CARDFileInfo;
typedef struct RGB565 RGB565;

// HSD Objects
typedef struct GOBJ GOBJ;
typedef struct GOBJProc GOBJProc;
typedef struct GOBJList GOBJList;
typedef struct GXList GXList;
typedef struct JOBJ JOBJ;
typedef struct JOBJDesc JOBJDesc;
typedef struct DOBJ DOBJ;
typedef struct TOBJ TOBJ;
typedef struct AOBJ AOBJ;
typedef struct MOBJ MOBJ;
typedef struct WOBJ WOBJ;
typedef struct COBJ COBJ;
typedef struct COBJDesc COBJDesc;
typedef struct _HSD_ImageDesc _HSD_ImageDesc;
typedef struct _HSD_LightPoint _HSD_LightPoint;
typedef struct _HSD_LightPointDesc _HSD_LightPointDesc;
typedef struct _HSD_LightSpot _HSD_LightSpot;
typedef struct _HSD_LightSpotDesc _HSD_LightSpotDesc;
typedef struct _HSD_LightAttn _HSD_LightAttn;
typedef struct LOBJ LOBJ;
typedef struct JOBJAnimSet JOBJAnimSet;

// Archive
typedef struct ArchiveInfo ArchiveInfo;
typedef struct MapHead MapHead;

// Stage
typedef struct Stage Stage;
typedef struct StageOnGO StageOnGO;
typedef struct map_gobjData map_gobjData;
typedef struct map_gobjDesc map_gobjDesc;
typedef struct StageFile StageFile;

// Match
typedef struct MatchInit MatchInit;
typedef struct Match Match;
typedef struct MatchHUD MatchHUD;
typedef struct MatchCamera MatchCamera;
typedef struct CameraBox CameraBox;
typedef struct MatchOffscreen MatchOffscreen;

// Text
typedef struct Text Text;
typedef struct TextAllocInfo TextAllocInfo;

// DevText
typedef struct DevText DevText;

// Effects
typedef struct Effect Effect;
typedef struct Particle Particle;
typedef struct Particle2 Particle2;
typedef struct ptclGen ptclGen;
typedef struct GeneratorAppSRT GeneratorAppSRT;

// Color
typedef struct GXColor GXColor;
typedef struct ColorOverlay ColorOverlay;

// Item
typedef struct ItemData ItemData;
typedef struct ItemState ItemState;
typedef struct SpawnItem SpawnItem;
typedef struct itData itData;
typedef struct itCommonAttr itCommonAttr;
typedef struct itHit itHit;

// Fighter
typedef struct FighterData FighterData;
typedef struct FighterBone FighterBone;
typedef struct Playerblock Playerblock;
typedef struct PlayerData PlayerData;
typedef struct MoveLogic MoveLogic;
typedef struct SubactionHeader SubactionHeader;
typedef struct ftHit ftHit;
typedef struct HitVictim HitVictim;
typedef struct FtHurt FtHurt;
typedef struct ReflectDesc ReflectDesc;
typedef struct ShieldDesc ShieldDesc;
typedef struct AbsorbDesc AbsorbDesc;
typedef struct CPU CPU;
typedef struct ftData ftData;
typedef struct ftCommonData ftCommonData;
typedef struct ftChkDevice ftChkDevice;
typedef struct FtSymbolLookup FtSymbolLookup;
typedef struct FtSymbols FtSymbols;
typedef struct FtParts FtParts;
typedef struct FtPartsDesc FtPartsDesc;
typedef struct FtDOBJUnk FtDOBJUnk;
typedef struct FtPartsLookup FtPartsLookup;
typedef struct FtDOBJUnk2 FtDOBJUnk2;
typedef struct FtDOBJUnk3 FtDOBJUnk3;
typedef struct FtDynamicBoneset FtDynamicBoneset;
typedef struct FtDynamicRoot FtDynamicRoot;
typedef struct FtDynamicHit FtDynamicHit;
typedef struct DynamicsDesc DynamicsDesc;
typedef struct DynamicsHitDesc DynamicsHitDesc;
typedef struct DynamicsBehave DynamicsBehave;
typedef struct ftDynamics ftDynamics;

// Fighter States
typedef struct FtCliffCatch FtCliffCatch;

// CSS
typedef struct CSSBackup CSSBackup;
typedef struct MnSelectChrDataTable MnSelectChrDataTable;
typedef struct VSMinorData VSMinorData;
typedef struct CSSCursor CSSCursor;
typedef struct CSSPuck CSSPuck;
typedef struct MnSlChrData MnSlChrData;
typedef struct MnSlChrIcon MnSlChrIcon;
typedef struct MnSlChrDoor MnSlChrDoor;
typedef struct MnSlChrTag MnSlChrTag;
typedef struct MnSlChrTagData MnSlChrTagData;
typedef struct MnSlChrKOStar MnSlChrKOStar;

// Memcard
typedef struct Memcard Memcard;
typedef struct MemcardWork MemcardWork;
typedef struct MemcardUnk MemcardUnk;
typedef struct MemcardSave MemcardSave;
typedef struct MemcardInfo MemcardInfo;
typedef struct SnapshotInfo SnapshotInfo;
typedef struct SnapshotList SnapshotList;
typedef struct MemSnapIconData MemSnapIconData;
typedef struct Rules1 Rules1;

// Collision
typedef struct CollData CollData;
typedef struct ECBBones ECBBones;
typedef struct DmgHazard DmgHazard;
typedef struct CollLineInfo CollLineInfo;
typedef struct CollLine CollLine;
typedef struct CollVert CollVert;
typedef struct CollDataStage CollDataStage;
typedef struct CollGroupDesc CollGroupDesc;
typedef struct CollGroup CollGroup;

// HSD
typedef struct HSD_Material HSD_Material;
typedef struct HSD_Pad HSD_Pad;
typedef struct HSD_Pads HSD_Pads;
typedef struct HSD_Update HSD_Update;
typedef struct HSD_VI HSD_VI;
typedef struct HSD_ObjAllocData HSD_ObjAllocData;

// Scene
typedef struct MajorScene MajorScene;
typedef struct MinorScene MinorScene;
typedef struct ScDataVS ScDataVS;
typedef struct ScDataRst ScDataRst;

// Results
typedef struct RstPlayer RstPlayer;
typedef struct RstInit RstInit;

// Preload
typedef struct Preload Preload;
typedef struct PreloadChar PreloadChar;

// Kirby
typedef struct FtVarKirby FtVarKirby;

// Custom
typedef struct PRIM PRIM;
typedef struct MEXPlaylist MEXPlaylist;
typedef struct Translation Translation;

#endif
