#ifndef MEX_H_MEMCARD
#define MEX_H_MEMCARD

#include "structs.h"
#include "datatypes.h"
#include "css.h"

#define MEMCARD_BANNER_SIZE 0x1800
#define MEMCARD_ICON_SIZE 0x400

/*** Memcard Library ***/
void Memcard_InitWorkArea();
void Memcard_LoadAssets(int unk);
Rules1 *Memcard_GetRules1();
void Memcard_InitSnapshotList(void *snap_data, void *snap_list);
void Memcard_UpdateSnapshotList(int slot);
void Memcard_CreateSnapshot(int slot, char *save_id, MemcardSave *memcard_save, MemcardUnk *memcard_unk, char *file_name, _HSD_ImageDesc *banner, _HSD_ImageDesc *icon, int unk);
void Memcard_DeleteSnapshot(int slot, int index);
void Memcard_LoadSnapshot(int slot, char *save_id, MemcardSave *memcard_save, char *file_name, _HSD_ImageDesc *banner, _HSD_ImageDesc *icon, int unk);
int Memcard_CheckStatus(); // returns 11 when operation in effect
void Memcard_RemovedCallback();
void Memcard_Deobfuscate(void *data, int size);

/*** Structs ***/
struct Memcard
{
    int unk0;              //0x0
    int unk1;              //0x4
    int unk2;              //0x8
    int unk3;              //0xC
    int unk4;              //0x10
    int unk5;              //0x14
    int unk6;              //0x18
    int unk7;              //0x1C
    int unk8;              //0x20
    int unk9;              //0x24
    int unk10;             //0x28
    int unk11;             //0x2C
    int unk12;             //0x30
    int unk13;             //0x34
    int unk14;             //0x38
    int unk15;             //0x3C
    int unk16;             //0x40
    int unk17;             //0x44
    int unk18;             //0x48
    int unk19;             //0x4C
    int unk20;             //0x50
    int unk21;             //0x54
    int unk22;             //0x58
    int unk23;             //0x5C
    int unk24;             //0x60
    int unk25;             //0x64
    int unk26;             //0x68
    int unk27;             //0x6C
    int unk28;             //0x70
    int unk29;             //0x74
    int unk30;             //0x78
    int unk31;             //0x7C
    int unk32;             //0x80
    int unk33;             //0x84
    int unk34;             //0x88
    int unk35;             //0x8C
    int unk36;             //0x90
    int unk37;             //0x94
    int unk38;             //0x98
    int unk39;             //0x9C
    int unk40;             //0xA0
    int unk41;             //0xA4
    int unk42;             //0xA8
    int unk43;             //0xAC
    int unk44;             //0xB0
    int unk45;             //0xB4
    int unk46;             //0xB8
    int unk47;             //0xBC
    int unk48;             //0xC0
    int unk49;             //0xC4
    int unk50;             //0xC8
    int unk51;             //0xCC
    int unk52;             //0xD0
    int unk53;             //0xD4
    int unk54;             //0xD8
    int unk55;             //0xDC
    int unk56;             //0xE0
    int unk57;             //0xE4
    int unk58;             //0xE8
    int unk59;             //0xEC
    int unk60;             //0xF0
    int unk61;             //0xF4
    int unk62;             //0xF8
    int unk63;             //0xFC
    int unk64;             //0x100
    int unk65;             //0x104
    int unk66;             //0x108
    int unk67;             //0x10C
    int unk68;             //0x110
    int unk69;             //0x114
    int unk70;             //0x118
    int unk71;             //0x11C
    int unk72;             //0x120
    int unk73;             //0x124
    int unk74;             //0x128
    int unk75;             //0x12C
    int unk76;             //0x130
    int unk77;             //0x134
    int unk78;             //0x138
    int unk79;             //0x13C
    int unk80;             //0x140
    int unk81;             //0x144
    int unk82;             //0x148
    int unk83;             //0x14C
    int unk84;             //0x150
    int unk85;             //0x154
    int unk86;             //0x158
    int unk87;             //0x15C
    int unk88;             //0x160
    int unk89;             //0x164
    int unk90;             //0x168
    int unk91;             //0x16C
    int unk92;             //0x170
    int unk93;             //0x174
    int unk94;             //0x178
    int unk95;             //0x17C
    int unk96;             //0x180
    int unk97;             //0x184
    int unk98;             //0x188
    int unk99;             //0x18C
    int unk100;            //0x190
    int unk101;            //0x194
    int unk102;            //0x198
    int unk103;            //0x19C
    int unk104;            //0x1A0
    int unk105;            //0x1A4
    int unk106;            //0x1A8
    int unk107;            //0x1AC
    int unk108;            //0x1B0
    int unk109;            //0x1B4
    int unk110;            //0x1B8
    int unk111;            //0x1BC
    int unk112;            //0x1C0
    int unk113;            //0x1C4
    int unk114;            //0x1C8
    int unk115;            //0x1CC
    int unk116;            //0x1D0
    int unk117;            //0x1D4
    int unk118;            //0x1D8
    int unk119;            //0x1DC
    int unk120;            //0x1E0
    int unk121;            //0x1E4
    int unk122;            //0x1E8
    int unk123;            //0x1EC
    int unk124;            //0x1F0
    int unk125;            //0x1F4
    int unk126;            //0x1F8
    int unk127;            //0x1FC
    int unk128;            //0x200
    int unk129;            //0x204
    int unk130;            //0x208
    int unk131;            //0x20C
    int unk132;            //0x210
    int unk133;            //0x214
    int unk134;            //0x218
    int unk135;            //0x21C
    int unk136;            //0x220
    int unk137;            //0x224
    int unk138;            //0x228
    int unk139;            //0x22C
    int unk140;            //0x230
    int unk141;            //0x234
    int unk142;            //0x238
    int unk143;            //0x23C
    int unk144;            //0x240
    int unk145;            //0x244
    int unk146;            //0x248
    int unk147;            //0x24C
    int unk148;            //0x250
    int unk149;            //0x254
    int unk150;            //0x258
    int unk151;            //0x25C
    int unk152;            //0x260
    int unk153;            //0x264
    int unk154;            //0x268
    int unk155;            //0x26C
    int unk156;            //0x270
    int unk157;            //0x274
    int unk158;            //0x278
    int unk159;            //0x27C
    int unk160;            //0x280
    int unk161;            //0x284
    int unk162;            //0x288
    int unk163;            //0x28C
    int unk164;            //0x290
    int unk165;            //0x294
    int unk166;            //0x298
    int unk167;            //0x29C
    int unk168;            //0x2A0
    int unk169;            //0x2A4
    int unk170;            //0x2A8
    int unk171;            //0x2AC
    int unk172;            //0x2B0
    int unk173;            //0x2B4
    int unk174;            //0x2B8
    int unk175;            //0x2BC
    int unk176;            //0x2C0
    int unk177;            //0x2C4
    int unk178;            //0x2C8
    int unk179;            //0x2CC
    int unk180;            //0x2D0
    int unk181;            //0x2D4
    int unk182;            //0x2D8
    int unk183;            //0x2DC
    int unk184;            //0x2E0
    int unk185;            //0x2E4
    int unk186;            //0x2E8
    int unk187;            //0x2EC
    int unk188;            //0x2F0
    int unk189;            //0x2F4
    int unk190;            //0x2F8
    int unk191;            //0x2FC
    int unk192;            //0x300
    int unk193;            //0x304
    int unk194;            //0x308
    int unk195;            //0x30C
    int unk196;            //0x310
    int unk197;            //0x314
    int unk198;            //0x318
    int unk199;            //0x31C
    int unk200;            //0x320
    int unk201;            //0x324
    int unk202;            //0x328
    int unk203;            //0x32C
    int unk204;            //0x330
    int unk205;            //0x334
    int unk206;            //0x338
    int unk207;            //0x33C
    int unk208;            //0x340
    int unk209;            //0x344
    int unk210;            //0x348
    int unk211;            //0x34C
    int unk212;            //0x350
    int unk213;            //0x354
    int unk214;            //0x358
    int unk215;            //0x35C
    int unk216;            //0x360
    int unk217;            //0x364
    int unk218;            //0x368
    int unk219;            //0x36C
    int unk220;            //0x370
    int unk221;            //0x374
    int unk222;            //0x378
    int unk223;            //0x37C
    int unk224;            //0x380
    int unk225;            //0x384
    int unk226;            //0x388
    int unk227;            //0x38C
    int unk228;            //0x390
    int unk229;            //0x394
    int unk230;            //0x398
    int unk231;            //0x39C
    int unk232;            //0x3A0
    int unk233;            //0x3A4
    int unk234;            //0x3A8
    int unk235;            //0x3AC
    int unk236;            //0x3B0
    int unk237;            //0x3B4
    int unk238;            //0x3B8
    int unk239;            //0x3BC
    int unk240;            //0x3C0
    int unk241;            //0x3C4
    int unk242;            //0x3C8
    int unk243;            //0x3CC
    int unk244;            //0x3D0
    int unk245;            //0x3D4
    int unk246;            //0x3D8
    int unk247;            //0x3DC
    int unk248;            //0x3E0
    int unk249;            //0x3E4
    int unk250;            //0x3E8
    int unk251;            //0x3EC
    int unk252;            //0x3F0
    int unk253;            //0x3F4
    int unk254;            //0x3F8
    int unk255;            //0x3FC
    int unk256;            //0x400
    int unk257;            //0x404
    int unk258;            //0x408
    int unk259;            //0x40C
    int unk260;            //0x410
    int unk261;            //0x414
    int unk262;            //0x418
    int unk263;            //0x41C
    int unk264;            //0x420
    int unk265;            //0x424
    int unk266;            //0x428
    int unk267;            //0x42C
    int unk268;            //0x430
    int unk269;            //0x434
    int unk270;            //0x438
    int unk271;            //0x43C
    int unk272;            //0x440
    int unk273;            //0x444
    int unk274;            //0x448
    int unk275;            //0x44C
    int unk276;            //0x450
    int unk277;            //0x454
    int unk278;            //0x458
    int unk279;            //0x45C
    int unk280;            //0x460
    int unk281;            //0x464
    int unk282;            //0x468
    int unk283;            //0x46C
    int unk284;            //0x470
    int unk285;            //0x474
    int unk286;            //0x478
    int unk287;            //0x47C
    int unk288;            //0x480
    int unk289;            //0x484
    int unk290;            //0x488
    int unk291;            //0x48C
    int unk292;            //0x490
    int unk293;            //0x494
    int unk294;            //0x498
    int unk295;            //0x49C
    int unk296;            //0x4A0
    int unk297;            //0x4A4
    int unk298;            //0x4A8
    int unk299;            //0x4AC
    int unk300;            //0x4B0
    int unk301;            //0x4B4
    int unk302;            //0x4B8
    int unk303;            //0x4BC
    int unk304;            //0x4C0
    int unk305;            //0x4C4
    int unk306;            //0x4C8
    int unk307;            //0x4CC
    int unk308;            //0x4D0
    int unk309;            //0x4D4
    int unk310;            //0x4D8
    int unk311;            //0x4DC
    int unk312;            //0x4E0
    int unk313;            //0x4E4
    int unk314;            //0x4E8
    int unk315;            //0x4EC
    int unk316;            //0x4F0
    int unk317;            //0x4F4
    int unk318;            //0x4F8
    int unk319;            //0x4FC
    int unk320;            //0x500
    int unk321;            //0x504
    int unk322;            //0x508
    int unk323;            //0x50C
    int unk324;            //0x510
    int unk325;            //0x514
    int unk326;            //0x518
    int unk327;            //0x51C
    int unk328;            //0x520
    int unk329;            //0x524
    int unk330;            //0x528
    int unk331;            //0x52C
    CSSBackup EventBackup; //0x530
    int unk335;            //0x53C
    int unk336;            //0x540
    int unk337;            //0x544
    int unk338;            //0x548
    int unk339;            //0x54C
    int unk340;            //0x550
    int unk341;            //0x554
    int unk342;            //0x558
    int unk343;            //0x55C
    int unk344;            //0x560
    int unk345;            //0x564
    int unk346;            //0x568
    int unk347;            //0x56C
    int unk348;            //0x570
    int unk349;            //0x574
    int unk350;            //0x578
    int unk351;            //0x57C
    int unk352;            //0x580
    int unk353;            //0x584
    int unk354;            //0x588
    int unk355;            //0x58C
    int unk356;            //0x590
    int unk357;            //0x594
    int unk358;            //0x598
    int unk359;            //0x59C
    int unk360;            //0x5A0
    int unk361;            //0x5A4
    int unk362;            //0x5A8
    int unk363;            //0x5AC
    int unk364;            //0x5B0
    int unk365;            //0x5B4
    int unk366;            //0x5B8
    int unk367;            //0x5BC
    int unk368;            //0x5C0
    int unk369;            //0x5C4
    int unk370;            //0x5C8
    int unk371;            //0x5CC
    int unk372;            //0x5D0
    int unk373;            //0x5D4
    int unk374;            //0x5D8
    int unk375;            //0x5DC
    int unk376;            //0x5E0
    int unk377;            //0x5E4
    int unk378;            //0x5E8
    int unk379;            //0x5EC
    int unk380;            //0x5F0
    int unk381;            //0x5F4
    int unk382;            //0x5F8
    int unk383;            //0x5FC
    int unk384;            //0x600
    int unk385;            //0x604
    int unk386;            //0x608
    int unk387;            //0x60C
    int unk388;            //0x610
    int unk389;            //0x614
    int unk390;            //0x618
    int unk391;            //0x61C
    int unk392;            //0x620
    int unk393;            //0x624
    int unk394;            //0x628
    int unk395;            //0x62C
    int unk396;            //0x630
    int unk397;            //0x634
    int unk398;            //0x638
    int unk399;            //0x63C
    int unk400;            //0x640
    int unk401;            //0x644
    int unk402;            //0x648
    int unk403;            //0x64C
    int unk404;            //0x650
    int unk405;            //0x654
    int unk406;            //0x658
    int unk407;            //0x65C
    int unk408;            //0x660
    int unk409;            //0x664
    int unk410;            //0x668
    int unk411;            //0x66C
    int unk412;            //0x670
    int unk413;            //0x674
    int unk414;            //0x678
    int unk415;            //0x67C
    int unk416;            //0x680
    int unk417;            //0x684
    int unk418;            //0x688
    int unk419;            //0x68C
    int unk420;            //0x690
    int unk421;            //0x694
    int unk422;            //0x698
    int unk423;            //0x69C
    int unk424;            //0x6A0
    int unk425;            //0x6A4
    int unk426;            //0x6A8
    int unk427;            //0x6AC
    int unk428;            //0x6B0
    int unk429;            //0x6B4
    int unk430;            //0x6B8
    int unk431;            //0x6BC
    int unk432;            //0x6C0
    int unk433;            //0x6C4
    int unk434;            //0x6C8
    int unk435;            //0x6CC
    int unk436;            //0x6D0
    int unk437;            //0x6D4
    int unk438;            //0x6D8
    int unk439;            //0x6DC
    int unk440;            //0x6E0
    int unk441;            //0x6E4
    int unk442;            //0x6E8
    int unk443;            //0x6EC
    int unk444;            //0x6F0
    int unk445;            //0x6F4
    int unk446;            //0x6F8
    int unk447;            //0x6FC
    int unk448;            //0x700
    int unk449;            //0x704
    int unk450;            //0x708
    int unk451;            //0x70C
    int unk452;            //0x710
    int unk453;            //0x714
    int unk454;            //0x718
    int unk455;            //0x71C
    int unk456;            //0x720
    int unk457;            //0x724
    int unk458;            //0x728
    int unk459;            //0x72C
    int unk460;            //0x730
    int unk461;            //0x734
    int unk462;            //0x738
    int unk463;            //0x73C
    int unk464;            //0x740
    int unk465;            //0x744
    int unk466;            //0x748
    int unk467;            //0x74C
    int unk468;            //0x750
    int unk469;            //0x754
    int unk470;            //0x758
    int unk471;            //0x75C
    int unk472;            //0x760
    int unk473;            //0x764
    int unk474;            //0x768
    int unk475;            //0x76C
    int unk476;            //0x770
    int unk477;            //0x774
    int unk478;            //0x778
    int unk479;            //0x77C
    int unk480;            //0x780
    int unk481;            //0x784
    int unk482;            //0x788
    int unk483;            //0x78C
    int unk484;            //0x790
    int unk485;            //0x794
    int unk486;            //0x798
    int unk487;            //0x79C
    int unk488;            //0x7A0
    int unk489;            //0x7A4
    int unk490;            //0x7A8
    int unk491;            //0x7AC
    int unk492;            //0x7B0
    int unk493;            //0x7B4
    int unk494;            //0x7B8
    int unk495;            //0x7BC
    int unk496;            //0x7C0
    int unk497;            //0x7C4
    int unk498;            //0x7C8
    int unk499;            //0x7CC
    int unk500;            //0x7D0
    int unk501;            //0x7D4
    int unk502;            //0x7D8
    int unk503;            //0x7DC
    int unk504;            //0x7E0
    int unk505;            //0x7E4
    int unk506;            //0x7E8
    int unk507;            //0x7EC
    int unk508;            //0x7F0
    int unk509;            //0x7F4
    int unk510;            //0x7F8
    int unk511;            //0x7FC
    int unk512;            //0x800
    int unk513;            //0x804
    int unk514;            //0x808
    int unk515;            //0x80C
    int unk516;            //0x810
    int unk517;            //0x814
    int unk518;            //0x818
    int unk519;            //0x81C
    int unk520;            //0x820
    int unk521;            //0x824
    int unk522;            //0x828
    int unk523;            //0x82C
    int unk524;            //0x830
    int unk525;            //0x834
    int unk526;            //0x838
    int unk527;            //0x83C
    int unk528;            //0x840
    int unk529;            //0x844
    int unk530;            //0x848
    int unk531;            //0x84C
    int unk532;            //0x850
    int unk533;            //0x854
    int unk534;            //0x858
    int unk535;            //0x85C
    int unk536;            //0x860
    int unk537;            //0x864
    int unk538;            //0x868
    int unk539;            //0x86C
    int unk540;            //0x870
    int unk541;            //0x874
    int unk542;            //0x878
    int unk543;            //0x87C
    int unk544;            //0x880
    int unk545;            //0x884
    int unk546;            //0x888
    int unk547;            //0x88C
    int unk548;            //0x890
    int unk549;            //0x894
    int unk550;            //0x898
    int unk551;            //0x89C
    int unk552;            //0x8A0
    int unk553;            //0x8A4
    int unk554;            //0x8A8
    int unk555;            //0x8AC
    int unk556;            //0x8B0
    int unk557;            //0x8B4
    int unk558;            //0x8B8
    int unk559;            //0x8BC
    int unk560;            //0x8C0
    int unk561;            //0x8C4
    int unk562;            //0x8C8
    int unk563;            //0x8CC
    int unk564;            //0x8D0
    int unk565;            //0x8D4
    int unk566;            //0x8D8
    int unk567;            //0x8DC
    int unk568;            //0x8E0
    int unk569;            //0x8E4
    int unk570;            //0x8E8
    int unk571;            //0x8EC
    int unk572;            //0x8F0
    int unk573;            //0x8F4
    int unk574;            //0x8F8
    int unk575;            //0x8FC
    int unk576;            //0x900
    int unk577;            //0x904
    int unk578;            //0x908
    int unk579;            //0x90C
    int unk580;            //0x910
    int unk581;            //0x914
    int unk582;            //0x918
    int unk583;            //0x91C
    int unk584;            //0x920
    int unk585;            //0x924
    int unk586;            //0x928
    int unk587;            //0x92C
    int unk588;            //0x930
    int unk589;            //0x934
    int unk590;            //0x938
    int unk591;            //0x93C
    int unk592;            //0x940
    int unk593;            //0x944
    int unk594;            //0x948
    int unk595;            //0x94C
    int unk596;            //0x950
    int unk597;            //0x954
    int unk598;            //0x958
    int unk599;            //0x95C
    int unk600;            //0x960
    int unk601;            //0x964
    int unk602;            //0x968
    int unk603;            //0x96C
    int unk604;            //0x970
    int unk605;            //0x974
    int unk606;            //0x978
    int unk607;            //0x97C
    int unk608;            //0x980
    int unk609;            //0x984
    int unk610;            //0x988
    int unk611;            //0x98C
    int unk612;            //0x990
    int unk613;            //0x994
    int unk614;            //0x998
    int unk615;            //0x99C
    int unk616;            //0x9A0
    int unk617;            //0x9A4
    int unk618;            //0x9A8
    int unk619;            //0x9AC
    int unk620;            //0x9B0
    int unk621;            //0x9B4
    int unk622;            //0x9B8
    int unk623;            //0x9BC
    int unk624;            //0x9C0
    int unk625;            //0x9C4
    int unk626;            //0x9C8
    int unk627;            //0x9CC
    int unk628;            //0x9D0
    int unk629;            //0x9D4
    int unk630;            //0x9D8
    int unk631;            //0x9DC
    int unk632;            //0x9E0
    int unk633;            //0x9E4
    int unk634;            //0x9E8
    int unk635;            //0x9EC
    int unk636;            //0x9F0
    int unk637;            //0x9F4
    int unk638;            //0x9F8
    int unk639;            //0x9FC
    int unk640;            //0xA00
    int unk641;            //0xA04
    int unk642;            //0xA08
    int unk643;            //0xA0C
    int unk644;            //0xA10
    int unk645;            //0xA14
    int unk646;            //0xA18
    int unk647;            //0xA1C
    int unk648;            //0xA20
    int unk649;            //0xA24
    int unk650;            //0xA28
    int unk651;            //0xA2C
    int unk652;            //0xA30
    int unk653;            //0xA34
    int unk654;            //0xA38
    int unk655;            //0xA3C
    int unk656;            //0xA40
    int unk657;            //0xA44
    int unk658;            //0xA48
    int unk659;            //0xA4C
    int unk660;            //0xA50
    int unk661;            //0xA54
    int unk662;            //0xA58
    int unk663;            //0xA5C
    int unk664;            //0xA60
    int unk665;            //0xA64
    int unk666;            //0xA68
    int unk667;            //0xA6C
    int unk668;            //0xA70
    int unk669;            //0xA74
    int unk670;            //0xA78
    int unk671;            //0xA7C
    int unk672;            //0xA80
    int unk673;            //0xA84
    int unk674;            //0xA88
    int unk675;            //0xA8C
    int unk676;            //0xA90
    int unk677;            //0xA94
    int unk678;            //0xA98
    int unk679;            //0xA9C
    int unk680;            //0xAA0
    int unk681;            //0xAA4
    int unk682;            //0xAA8
    int unk683;            //0xAAC
    int unk684;            //0xAB0
    int unk685;            //0xAB4
    int unk686;            //0xAB8
    int unk687;            //0xABC
    int unk688;            //0xAC0
    int unk689;            //0xAC4
    int unk690;            //0xAC8
    int unk691;            //0xACC
    int unk692;            //0xAD0
    int unk693;            //0xAD4
    int unk694;            //0xAD8
    int unk695;            //0xADC
    int unk696;            //0xAE0
    int unk697;            //0xAE4
    int unk698;            //0xAE8
    int unk699;            //0xAEC
    int unk700;            //0xAF0
    int unk701;            //0xAF4
    int unk702;            //0xAF8
    int unk703;            //0xAFC
    int unk704;            //0xB00
    int unk705;            //0xB04
    int unk706;            //0xB08
    int unk707;            //0xB0C
    int unk708;            //0xB10
    int unk709;            //0xB14
    int unk710;            //0xB18
    int unk711;            //0xB1C
    int unk712;            //0xB20
    int unk713;            //0xB24
    int unk714;            //0xB28
    int unk715;            //0xB2C
    int unk716;            //0xB30
    int unk717;            //0xB34
    int unk718;            //0xB38
    int unk719;            //0xB3C
    int unk720;            //0xB40
    int unk721;            //0xB44
    int unk722;            //0xB48
    int unk723;            //0xB4C
    int unk724;            //0xB50
    int unk725;            //0xB54
    int unk726;            //0xB58
    int unk727;            //0xB5C
    int unk728;            //0xB60
    int unk729;            //0xB64
    int unk730;            //0xB68
    int unk731;            //0xB6C
    int unk732;            //0xB70
    int unk733;            //0xB74
    int unk734;            //0xB78
    int unk735;            //0xB7C
    int unk736;            //0xB80
    int unk737;            //0xB84
    int unk738;            //0xB88
    int unk739;            //0xB8C
    int unk740;            //0xB90
    int unk741;            //0xB94
    int unk742;            //0xB98
    int unk743;            //0xB9C
    int unk744;            //0xBA0
    int unk745;            //0xBA4
    int unk746;            //0xBA8
    int unk747;            //0xBAC
    int unk748;            //0xBB0
    int unk749;            //0xBB4
    int unk750;            //0xBB8
    int unk751;            //0xBBC
    int unk752;            //0xBC0
    int unk753;            //0xBC4
    int unk754;            //0xBC8
    int unk755;            //0xBCC
    int unk756;            //0xBD0
    int unk757;            //0xBD4
    int unk758;            //0xBD8
    int unk759;            //0xBDC
    int unk760;            //0xBE0
    int unk761;            //0xBE4
    int unk762;            //0xBE8
    int unk763;            //0xBEC
    int unk764;            //0xBF0
    int unk765;            //0xBF4
    int unk766;            //0xBF8
    int unk767;            //0xBFC
    int unk768;            //0xC00
    int unk769;            //0xC04
    int unk770;            //0xC08
    int unk771;            //0xC0C
    int unk772;            //0xC10
    int unk773;            //0xC14
    int unk774;            //0xC18
    int unk775;            //0xC1C
    int unk776;            //0xC20
    int unk777;            //0xC24
    int unk778;            //0xC28
    int unk779;            //0xC2C
    int unk780;            //0xC30
    int unk781;            //0xC34
    int unk782;            //0xC38
    int unk783;            //0xC3C
    int unk784;            //0xC40
    int unk785;            //0xC44
    int unk786;            //0xC48
    int unk787;            //0xC4C
    int unk788;            //0xC50
    int unk789;            //0xC54
    int unk790;            //0xC58
    int unk791;            //0xC5C
    int unk792;            //0xC60
    int unk793;            //0xC64
    int unk794;            //0xC68
    int unk795;            //0xC6C
    int unk796;            //0xC70
    int unk797;            //0xC74
    int unk798;            //0xC78
    int unk799;            //0xC7C
    int unk800;            //0xC80
    int unk801;            //0xC84
    int unk802;            //0xC88
    int unk803;            //0xC8C
    int unk804;            //0xC90
    int unk805;            //0xC94
    int unk806;            //0xC98
    int unk807;            //0xC9C
    int unk808;            //0xCA0
    int unk809;            //0xCA4
    int unk810;            //0xCA8
    int unk811;            //0xCAC
    int unk812;            //0xCB0
    int unk813;            //0xCB4
    int unk814;            //0xCB8
    int unk815;            //0xCBC
    int unk816;            //0xCC0
    int unk817;            //0xCC4
    int unk818;            //0xCC8
    int unk819;            //0xCCC
    int unk820;            //0xCD0
    int unk821;            //0xCD4
    int unk822;            //0xCD8
    int unk823;            //0xCDC
    int unk824;            //0xCE0
    int unk825;            //0xCE4
    int unk826;            //0xCE8
    int unk827;            //0xCEC
    int unk828;            //0xCF0
    int unk829;            //0xCF4
    int unk830;            //0xCF8
    int unk831;            //0xCFC
    int unk832;            //0xD00
    int unk833;            //0xD04
    int unk834;            //0xD08
    int unk835;            //0xD0C
    int unk836;            //0xD10
    int unk837;            //0xD14
    int unk838;            //0xD18
    int unk839;            //0xD1C
    int unk840;            //0xD20
    int unk841;            //0xD24
    int unk842;            //0xD28
    int unk843;            //0xD2C
    int unk844;            //0xD30
    int unk845;            //0xD34
    int unk846;            //0xD38
    int unk847;            //0xD3C
    int unk848;            //0xD40
    int unk849;            //0xD44
    int unk850;            //0xD48
    int unk851;            //0xD4C
    int unk852;            //0xD50
    int unk853;            //0xD54
    int unk854;            //0xD58
    int unk855;            //0xD5C
    int unk856;            //0xD60
    int unk857;            //0xD64
    int unk858;            //0xD68
    int unk859;            //0xD6C
    int unk860;            //0xD70
    int unk861;            //0xD74
    int unk862;            //0xD78
    int unk863;            //0xD7C
    int unk864;            //0xD80
    int unk865;            //0xD84
    int unk866;            //0xD88
    int unk867;            //0xD8C
    int unk868;            //0xD90
    int unk869;            //0xD94
    int unk870;            //0xD98
    int unk871;            //0xD9C
    int unk872;            //0xDA0
    int unk873;            //0xDA4
    int unk874;            //0xDA8
    int unk875;            //0xDAC
    int unk876;            //0xDB0
    int unk877;            //0xDB4
    int unk878;            //0xDB8
    int unk879;            //0xDBC
    int unk880;            //0xDC0
    int unk881;            //0xDC4
    int unk882;            //0xDC8
    int unk883;            //0xDCC
    int unk884;            //0xDD0
    int unk885;            //0xDD4
    int unk886;            //0xDD8
    int unk887;            //0xDDC
    int unk888;            //0xDE0
    int unk889;            //0xDE4
    int unk890;            //0xDE8
    int unk891;            //0xDEC
    int unk892;            //0xDF0
    int unk893;            //0xDF4
    int unk894;            //0xDF8
    int unk895;            //0xDFC
    int unk896;            //0xE00
    int unk897;            //0xE04
    int unk898;            //0xE08
    int unk899;            //0xE0C
    int unk900;            //0xE10
    int unk901;            //0xE14
    int unk902;            //0xE18
    int unk903;            //0xE1C
    int unk904;            //0xE20
    int unk905;            //0xE24
    int unk906;            //0xE28
    int unk907;            //0xE2C
    int unk908;            //0xE30
    int unk909;            //0xE34
    int unk910;            //0xE38
    int unk911;            //0xE3C
    int unk912;            //0xE40
    int unk913;            //0xE44
    int unk914;            //0xE48
    int unk915;            //0xE4C
    int unk916;            //0xE50
    int unk917;            //0xE54
    int unk918;            //0xE58
    int unk919;            //0xE5C
    int unk920;            //0xE60
    int unk921;            //0xE64
    int unk922;            //0xE68
    int unk923;            //0xE6C
    int unk924;            //0xE70
    int unk925;            //0xE74
    int unk926;            //0xE78
    int unk927;            //0xE7C
    int unk928;            //0xE80
    int unk929;            //0xE84
    int unk930;            //0xE88
    int unk931;            //0xE8C
    int unk932;            //0xE90
    int unk933;            //0xE94
    int unk934;            //0xE98
    int unk935;            //0xE9C
    int unk936;            //0xEA0
    int unk937;            //0xEA4
    int unk938;            //0xEA8
    int unk939;            //0xEAC
    int unk940;            //0xEB0
    int unk941;            //0xEB4
    int unk942;            //0xEB8
    int unk943;            //0xEBC
    int unk944;            //0xEC0
    int unk945;            //0xEC4
    int unk946;            //0xEC8
    int unk947;            //0xECC
    int unk948;            //0xED0
    int unk949;            //0xED4
    int unk950;            //0xED8
    int unk951;            //0xEDC
    int unk952;            //0xEE0
    int unk953;            //0xEE4
    int unk954;            //0xEE8
    int unk955;            //0xEEC
    int unk956;            //0xEF0
    int unk957;            //0xEF4
    int unk958;            //0xEF8
    int unk959;            //0xEFC
    int unk960;            //0xF00
    int unk961;            //0xF04
    int unk962;            //0xF08
    int unk963;            //0xF0C
    int unk964;            //0xF10
    int unk965;            //0xF14
    int unk966;            //0xF18
    int unk967;            //0xF1C
    int unk968;            //0xF20
    int unk969;            //0xF24
    int unk970;            //0xF28
    int unk971;            //0xF2C
    int unk972;            //0xF30
    int unk973;            //0xF34
    int unk974;            //0xF38
    int unk975;            //0xF3C
    int unk976;            //0xF40
    int unk977;            //0xF44
    int unk978;            //0xF48
    int unk979;            //0xF4C
    int unk980;            //0xF50
    int unk981;            //0xF54
    int unk982;            //0xF58
    int unk983;            //0xF5C
    int unk984;            //0xF60
    int unk985;            //0xF64
    int unk986;            //0xF68
    int unk987;            //0xF6C
    int unk988;            //0xF70
    int unk989;            //0xF74
    int unk990;            //0xF78
    int unk991;            //0xF7C
    int unk992;            //0xF80
    int unk993;            //0xF84
    int unk994;            //0xF88
    int unk995;            //0xF8C
    int unk996;            //0xF90
    int unk997;            //0xF94
    int unk998;            //0xF98
    int unk999;            //0xF9C
    int unk1000;           //0xFA0
    int unk1001;           //0xFA4
    int unk1002;           //0xFA8
    int unk1003;           //0xFAC
    int unk1004;           //0xFB0
    int unk1005;           //0xFB4
    int unk1006;           //0xFB8
    int unk1007;           //0xFBC
    int unk1008;           //0xFC0
    int unk1009;           //0xFC4
    int unk1010;           //0xFC8
    int unk1011;           //0xFCC
    int unk1012;           //0xFD0
    int unk1013;           //0xFD4
    int unk1014;           //0xFD8
    int unk1015;           //0xFDC
    int unk1016;           //0xFE0
    int unk1017;           //0xFE4
    int unk1018;           //0xFE8
    int unk1019;           //0xFEC
    int unk1020;           //0xFF0
    int unk1021;           //0xFF4
    int unk1022;           //0xFF8
    int unk1023;           //0xFFC
    int unk1024;           //0x1000
    int unk1025;           //0x1004
    int unk1026;           //0x1008
    int unk1027;           //0x100C
    int unk1028;           //0x1010
    int unk1029;           //0x1014
    int unk1030;           //0x1018
    int unk1031;           //0x101C
    int unk1032;           //0x1020
    int unk1033;           //0x1024
    int unk1034;           //0x1028
    int unk1035;           //0x102C
    int unk1036;           //0x1030
    int unk1037;           //0x1034
    int unk1038;           //0x1038
    int unk1039;           //0x103C
    int unk1040;           //0x1040
    int unk1041;           //0x1044
    int unk1042;           //0x1048
    int unk1043;           //0x104C
    int unk1044;           //0x1050
    int unk1045;           //0x1054
    int unk1046;           //0x1058
    int unk1047;           //0x105C
    int unk1048;           //0x1060
    int unk1049;           //0x1064
    int unk1050;           //0x1068
    int unk1051;           //0x106C
    int unk1052;           //0x1070
    int unk1053;           //0x1074
    int unk1054;           //0x1078
    int unk1055;           //0x107C
    int unk1056;           //0x1080
    int unk1057;           //0x1084
    int unk1058;           //0x1088
    int unk1059;           //0x108C
    int unk1060;           //0x1090
    int unk1061;           //0x1094
    int unk1062;           //0x1098
    int unk1063;           //0x109C
    int unk1064;           //0x10A0
    int unk1065;           //0x10A4
    int unk1066;           //0x10A8
    int unk1067;           //0x10AC
    int unk1068;           //0x10B0
    int unk1069;           //0x10B4
    int unk1070;           //0x10B8
    int unk1071;           //0x10BC
    int unk1072;           //0x10C0
    int unk1073;           //0x10C4
    int unk1074;           //0x10C8
    int unk1075;           //0x10CC
    int unk1076;           //0x10D0
    int unk1077;           //0x10D4
    int unk1078;           //0x10D8
    int unk1079;           //0x10DC
    int unk1080;           //0x10E0
    int unk1081;           //0x10E4
    int unk1082;           //0x10E8
    int unk1083;           //0x10EC
    int unk1084;           //0x10F0
    int unk1085;           //0x10F4
    int unk1086;           //0x10F8
    int unk1087;           //0x10FC
    int unk1088;           //0x1100
    int unk1089;           //0x1104
    int unk1090;           //0x1108
    int unk1091;           //0x110C
    int unk1092;           //0x1110
    int unk1093;           //0x1114
    int unk1094;           //0x1118
    int unk1095;           //0x111C
    int unk1096;           //0x1120
    int unk1097;           //0x1124
    int unk1098;           //0x1128
    int unk1099;           //0x112C
    int unk1100;           //0x1130
    int unk1101;           //0x1134
    int unk1102;           //0x1138
    int unk1103;           //0x113C
    int unk1104;           //0x1140
    int unk1105;           //0x1144
    int unk1106;           //0x1148
    int unk1107;           //0x114C
    int unk1108;           //0x1150
    int unk1109;           //0x1154
    int unk1110;           //0x1158
    int unk1111;           //0x115C
    int unk1112;           //0x1160
    int unk1113;           //0x1164
    int unk1114;           //0x1168
    int unk1115;           //0x116C
    int unk1116;           //0x1170
    int unk1117;           //0x1174
    int unk1118;           //0x1178
    int unk1119;           //0x117C
    int unk1120;           //0x1180
    int unk1121;           //0x1184
    int unk1122;           //0x1188
    int unk1123;           //0x118C
    int unk1124;           //0x1190
    int unk1125;           //0x1194
    int unk1126;           //0x1198
    int unk1127;           //0x119C
    int unk1128;           //0x11A0
    int unk1129;           //0x11A4
    int unk1130;           //0x11A8
    int unk1131;           //0x11AC
    int unk1132;           //0x11B0
    int unk1133;           //0x11B4
    int unk1134;           //0x11B8
    int unk1135;           //0x11BC
    int unk1136;           //0x11C0
    int unk1137;           //0x11C4
    int unk1138;           //0x11C8
    int unk1139;           //0x11CC
    int unk1140;           //0x11D0
    int unk1141;           //0x11D4
    int unk1142;           //0x11D8
    int unk1143;           //0x11DC
    int unk1144;           //0x11E0
    int unk1145;           //0x11E4
    int unk1146;           //0x11E8
    int unk1147;           //0x11EC
    int unk1148;           //0x11F0
    int unk1149;           //0x11F4
    int unk1150;           //0x11F8
    int unk1151;           //0x11FC
    int unk1152;           //0x1200
    int unk1153;           //0x1204
    int unk1154;           //0x1208
    int unk1155;           //0x120C
    int unk1156;           //0x1210
    int unk1157;           //0x1214
    int unk1158;           //0x1218
    int unk1159;           //0x121C
    int unk1160;           //0x1220
    int unk1161;           //0x1224
    int unk1162;           //0x1228
    int unk1163;           //0x122C
    int unk1164;           //0x1230
    int unk1165;           //0x1234
    int unk1166;           //0x1238
    int unk1167;           //0x123C
    int unk1168;           //0x1240
    int unk1169;           //0x1244
    int unk1170;           //0x1248
    int unk1171;           //0x124C
    int unk1172;           //0x1250
    int unk1173;           //0x1254
    int unk1174;           //0x1258
    int unk1175;           //0x125C
    int unk1176;           //0x1260
    int unk1177;           //0x1264
    int unk1178;           //0x1268
    int unk1179;           //0x126C
    int unk1180;           //0x1270
    int unk1181;           //0x1274
    int unk1182;           //0x1278
    int unk1183;           //0x127C
    int unk1184;           //0x1280
    int unk1185;           //0x1284
    int unk1186;           //0x1288
    int unk1187;           //0x128C
    int unk1188;           //0x1290
    int unk1189;           //0x1294
    int unk1190;           //0x1298
    int unk1191;           //0x129C
    int unk1192;           //0x12A0
    int unk1193;           //0x12A4
    int unk1194;           //0x12A8
    int unk1195;           //0x12AC
    int unk1196;           //0x12B0
    int unk1197;           //0x12B4
    int unk1198;           //0x12B8
    int unk1199;           //0x12BC
    int unk1200;           //0x12C0
    int unk1201;           //0x12C4
    int unk1202;           //0x12C8
    int unk1203;           //0x12CC
    int unk1204;           //0x12D0
    int unk1205;           //0x12D4
    int unk1206;           //0x12D8
    int unk1207;           //0x12DC
    int unk1208;           //0x12E0
    int unk1209;           //0x12E4
    int unk1210;           //0x12E8
    int unk1211;           //0x12EC
    int unk1212;           //0x12F0
    int unk1213;           //0x12F4
    int unk1214;           //0x12F8
    int unk1215;           //0x12FC
    int unk1216;           //0x1300
    int unk1217;           //0x1304
    int unk1218;           //0x1308
    int unk1219;           //0x130C
    int unk1220;           //0x1310
    int unk1221;           //0x1314
    int unk1222;           //0x1318
    int unk1223;           //0x131C
    int unk1224;           //0x1320
    int unk1225;           //0x1324
    int unk1226;           //0x1328
    int unk1227;           //0x132C
    int unk1228;           //0x1330
    int unk1229;           //0x1334
    int unk1230;           //0x1338
    int unk1231;           //0x133C
    int unk1232;           //0x1340
    int unk1233;           //0x1344
    int unk1234;           //0x1348
    int unk1235;           //0x134C
    int unk1236;           //0x1350
    int unk1237;           //0x1354
    int unk1238;           //0x1358
    int unk1239;           //0x135C
    int unk1240;           //0x1360
    int unk1241;           //0x1364
    int unk1242;           //0x1368
    int unk1243;           //0x136C
    int unk1244;           //0x1370
    int unk1245;           //0x1374
    int unk1246;           //0x1378
    int unk1247;           //0x137C
    int unk1248;           //0x1380
    int unk1249;           //0x1384
    int unk1250;           //0x1388
    int unk1251;           //0x138C
    int unk1252;           //0x1390
    int unk1253;           //0x1394
    int unk1254;           //0x1398
    int unk1255;           //0x139C
    int unk1256;           //0x13A0
    int unk1257;           //0x13A4
    int unk1258;           //0x13A8
    int unk1259;           //0x13AC
    int unk1260;           //0x13B0
    int unk1261;           //0x13B4
    int unk1262;           //0x13B8
    int unk1263;           //0x13BC
    int unk1264;           //0x13C0
    int unk1265;           //0x13C4
    int unk1266;           //0x13C8
    int unk1267;           //0x13CC
    int unk1268;           //0x13D0
    int unk1269;           //0x13D4
    int unk1270;           //0x13D8
    int unk1271;           //0x13DC
    int unk1272;           //0x13E0
    int unk1273;           //0x13E4
    int unk1274;           //0x13E8
    int unk1275;           //0x13EC
    int unk1276;           //0x13F0
    int unk1277;           //0x13F4
    int unk1278;           //0x13F8
    int unk1279;           //0x13FC
    int unk1280;           //0x1400
    int unk1281;           //0x1404
    int unk1282;           //0x1408
    int unk1283;           //0x140C
    int unk1284;           //0x1410
    int unk1285;           //0x1414
    int unk1286;           //0x1418
    int unk1287;           //0x141C
    int unk1288;           //0x1420
    int unk1289;           //0x1424
    int unk1290;           //0x1428
    int unk1291;           //0x142C
    int unk1292;           //0x1430
    int unk1293;           //0x1434
    int unk1294;           //0x1438
    int unk1295;           //0x143C
    int unk1296;           //0x1440
    int unk1297;           //0x1444
    int unk1298;           //0x1448
    int unk1299;           //0x144C
    int unk1300;           //0x1450
    int unk1301;           //0x1454
    int unk1302;           //0x1458
    int unk1303;           //0x145C
    int unk1304;           //0x1460
    int unk1305;           //0x1464
    int unk1306;           //0x1468
    int unk1307;           //0x146C
    int unk1308;           //0x1470
    int unk1309;           //0x1474
    int unk1310;           //0x1478
    int unk1311;           //0x147C
    int unk1312;           //0x1480
    int unk1313;           //0x1484
    int unk1314;           //0x1488
    int unk1315;           //0x148C
    int unk1316;           //0x1490
    int unk1317;           //0x1494
    int unk1318;           //0x1498
    int unk1319;           //0x149C
    int unk1320;           //0x14A0
    int unk1321;           //0x14A4
    int unk1322;           //0x14A8
    int unk1323;           //0x14AC
    int unk1324;           //0x14B0
    int unk1325;           //0x14B4
    int unk1326;           //0x14B8
    int unk1327;           //0x14BC
    int unk1328;           //0x14C0
    int unk1329;           //0x14C4
    int unk1330;           //0x14C8
    int unk1331;           //0x14CC
    int unk1332;           //0x14D0
    int unk1333;           //0x14D4
    int unk1334;           //0x14D8
    int unk1335;           //0x14DC
    int unk1336;           //0x14E0
    int unk1337;           //0x14E4
    int unk1338;           //0x14E8
    int unk1339;           //0x14EC
    int unk1340;           //0x14F0
    int unk1341;           //0x14F4
    int unk1342;           //0x14F8
    int unk1343;           //0x14FC
    int unk1344;           //0x1500
    int unk1345;           //0x1504
    int unk1346;           //0x1508
    int unk1347;           //0x150C
    int unk1348;           //0x1510
    int unk1349;           //0x1514
    int unk1350;           //0x1518
    int unk1351;           //0x151C
    int unk1352;           //0x1520
    int unk1353;           //0x1524
    int unk1354;           //0x1528
    int unk1355;           //0x152C
    int unk1356;           //0x1530
    int unk1357;           //0x1534
    int unk1358;           //0x1538
    int unk1359;           //0x153C
    int unk1360;           //0x1540
    int unk1361;           //0x1544
    int unk1362;           //0x1548
    int unk1363;           //0x154C
    int unk1364;           //0x1550
    int unk1365;           //0x1554
    int unk1366;           //0x1558
    int unk1367;           //0x155C
    int unk1368;           //0x1560
    int unk1369;           //0x1564
    int unk1370;           //0x1568
    int unk1371;           //0x156C
    int unk1372;           //0x1570
    int unk1373;           //0x1574
    int unk1374;           //0x1578
    int unk1375;           //0x157C
    int unk1376;           //0x1580
    int unk1377;           //0x1584
    int unk1378;           //0x1588
    int unk1379;           //0x158C
    int unk1380;           //0x1590
    int unk1381;           //0x1594
    int unk1382;           //0x1598
    int unk1383;           //0x159C
    int unk1384;           //0x15A0
    int unk1385;           //0x15A4
    int unk1386;           //0x15A8
    int unk1387;           //0x15AC
    int unk1388;           //0x15B0
    int unk1389;           //0x15B4
    int unk1390;           //0x15B8
    int unk1391;           //0x15BC
    int unk1392;           //0x15C0
    int unk1393;           //0x15C4
    int unk1394;           //0x15C8
    int unk1395;           //0x15CC
    int unk1396;           //0x15D0
    int unk1397;           //0x15D4
    int unk1398;           //0x15D8
    int unk1399;           //0x15DC
    int unk1400;           //0x15E0
    int unk1401;           //0x15E4
    int unk1402;           //0x15E8
    int unk1403;           //0x15EC
    int unk1404;           //0x15F0
    int unk1405;           //0x15F4
    int unk1406;           //0x15F8
    int unk1407;           //0x15FC
    int unk1408;           //0x1600
    int unk1409;           //0x1604
    int unk1410;           //0x1608
    int unk1411;           //0x160C
    int unk1412;           //0x1610
    int unk1413;           //0x1614
    int unk1414;           //0x1618
    int unk1415;           //0x161C
    int unk1416;           //0x1620
    int unk1417;           //0x1624
    int unk1418;           //0x1628
    int unk1419;           //0x162C
    int unk1420;           //0x1630
    int unk1421;           //0x1634
    int unk1422;           //0x1638
    int unk1423;           //0x163C
    int unk1424;           //0x1640
    int unk1425;           //0x1644
    int unk1426;           //0x1648
    int unk1427;           //0x164C
    int unk1428;           //0x1650
    int unk1429;           //0x1654
    int unk1430;           //0x1658
    int unk1431;           //0x165C
    int unk1432;           //0x1660
    int unk1433;           //0x1664
    int unk1434;           //0x1668
    int unk1435;           //0x166C
    int unk1436;           //0x1670
    int unk1437;           //0x1674
    int unk1438;           //0x1678
    int unk1439;           //0x167C
    int unk1440;           //0x1680
    int unk1441;           //0x1684
    int unk1442;           //0x1688
    int unk1443;           //0x168C
    int unk1444;           //0x1690
    int unk1445;           //0x1694
    int unk1446;           //0x1698
    int unk1447;           //0x169C
    int unk1448;           //0x16A0
    int unk1449;           //0x16A4
    int unk1450;           //0x16A8
    int unk1451;           //0x16AC
    int unk1452;           //0x16B0
    int unk1453;           //0x16B4
    int unk1454;           //0x16B8
    int unk1455;           //0x16BC
    int unk1456;           //0x16C0
    int unk1457;           //0x16C4
    int unk1458;           //0x16C8
    int unk1459;           //0x16CC
    int unk1460;           //0x16D0
    int unk1461;           //0x16D4
    int unk1462;           //0x16D8
    int unk1463;           //0x16DC
    int unk1464;           //0x16E0
    int unk1465;           //0x16E4
    int unk1466;           //0x16E8
    int unk1467;           //0x16EC
    int unk1468;           //0x16F0
    int unk1469;           //0x16F4
    int unk1470;           //0x16F8
    int unk1471;           //0x16FC
    int unk1472;           //0x1700
    int unk1473;           //0x1704
    int unk1474;           //0x1708
    int unk1475;           //0x170C
    int unk1476;           //0x1710
    int unk1477;           //0x1714
    int unk1478;           //0x1718
    int unk1479;           //0x171C
    int unk1480;           //0x1720
    int unk1481;           //0x1724
    int unk1482;           //0x1728
    int unk1483;           //0x172C
    int unk1484;           //0x1730
    int unk1485;           //0x1734
    int unk1486;           //0x1738
    int unk1487;           //0x173C
    int unk1488;           //0x1740
    int unk1489;           //0x1744
    int unk1490;           //0x1748
    int unk1491;           //0x174C
    int unk1492;           //0x1750
    int unk1493;           //0x1754
    int unk1494;           //0x1758
    int unk1495;           //0x175C
    int unk1496;           //0x1760
    int unk1497;           //0x1764
    int unk1498;           //0x1768
    int unk1499;           //0x176C
    int unk1500;           //0x1770
    int unk1501;           //0x1774
    int unk1502;           //0x1778
    int unk1503;           //0x177C
    int unk1504;           //0x1780
    int unk1505;           //0x1784
    int unk1506;           //0x1788
    int unk1507;           //0x178C
    int unk1508;           //0x1790
    int unk1509;           //0x1794
    int unk1510;           //0x1798
    int unk1511;           //0x179C
    int unk1512;           //0x17A0
    int unk1513;           //0x17A4
    int unk1514;           //0x17A8
    int unk1515;           //0x17AC
    int unk1516;           //0x17B0
    int unk1517;           //0x17B4
    int unk1518;           //0x17B8
    int unk1519;           //0x17BC
    int unk1520;           //0x17C0
    int unk1521;           //0x17C4
    int unk1522;           //0x17C8
    int unk1523;           //0x17CC
    int unk1524;           //0x17D0
    int unk1525;           //0x17D4
    int unk1526;           //0x17D8
    int unk1527;           //0x17DC
    int unk1528;           //0x17E0
    int unk1529;           //0x17E4
    int unk1530;           //0x17E8
    int unk1531;           //0x17EC
    int unk1532;           //0x17F0
    int unk1533;           //0x17F4
    int unk1534;           //0x17F8
    int unk1535;           //0x17FC
    int unk1536;           //0x1800
    int unk1537;           //0x1804
    int unk1538;           //0x1808
    int unk1539;           //0x180C
    int unk1540;           //0x1810
    int unk1541;           //0x1814
    int unk1542;           //0x1818
    int unk1543;           //0x181C
    int unk1544;           //0x1820
    int unk1545;           //0x1824
    int unk1546;           //0x1828
    int unk1547;           //0x182C
    int unk1548;           //0x1830
    int unk1549;           //0x1834
    int unk1550;           //0x1838
    int unk1551;           //0x183C
    int unk1552;           //0x1840
    int unk1553;           //0x1844
    int unk1554;           //0x1848
    int unk1555;           //0x184C
    int unk1556;           //0x1850
    int unk1557;           //0x1854
    int unk1558;           //0x1858
    int unk1559;           //0x185C
    int unk1560;           //0x1860
    int unk1561;           //0x1864
    int unk1562;           //0x1868
    int unk1563;           //0x186C
    int unk1564;           //0x1870
    int unk1565;           //0x1874
    int unk1566;           //0x1878
    int unk1567;           //0x187C
    int unk1568;           //0x1880
    int unk1569;           //0x1884
    int unk1570;           //0x1888
    int unk1571;           //0x188C
    int unk1572;           //0x1890
    int unk1573;           //0x1894
    int unk1574;           //0x1898
    int unk1575;           //0x189C
    int unk1576;           //0x18A0
    int unk1577;           //0x18A4
    int unk1578;           //0x18A8
    int unk1579;           //0x18AC
    int unk1580;           //0x18B0
    int unk1581;           //0x18B4
    int unk1582;           //0x18B8
    int unk1583;           //0x18BC
    int unk1584;           //0x18C0
    int unk1585;           //0x18C4
    int unk1586;           //0x18C8
    int unk1587;           //0x18CC
    int unk1588;           //0x18D0
    int unk1589;           //0x18D4
    int unk1590;           //0x18D8
    int unk1591;           //0x18DC
    int unk1592;           //0x18E0
    int unk1593;           //0x18E4
    int unk1594;           //0x18E8
    int unk1595;           //0x18EC
    int unk1596;           //0x18F0
    int unk1597;           //0x18F4
    int unk1598;           //0x18F8
    int unk1599;           //0x18FC
    int unk1600;           //0x1900
    int unk1601;           //0x1904
    int unk1602;           //0x1908
    int unk1603;           //0x190C
    int unk1604;           //0x1910
    int unk1605;           //0x1914
    int unk1606;           //0x1918
    int unk1607;           //0x191C
    int unk1608;           //0x1920
    int unk1609;           //0x1924
    int unk1610;           //0x1928
    int unk1611;           //0x192C
    int unk1612;           //0x1930
    int unk1613;           //0x1934
    int unk1614;           //0x1938
    int unk1615;           //0x193C
    int unk1616;           //0x1940
    int unk1617;           //0x1944
    int unk1618;           //0x1948
    int unk1619;           //0x194C
    int unk1620;           //0x1950
    int unk1621;           //0x1954
    int unk1622;           //0x1958
    int unk1623;           //0x195C
    int unk1624;           //0x1960
    int unk1625;           //0x1964
    int unk1626;           //0x1968
    int unk1627;           //0x196C
    int unk1628;           //0x1970
    int unk1629;           //0x1974
    int unk1630;           //0x1978
    int unk1631;           //0x197C
    int unk1632;           //0x1980
    int unk1633;           //0x1984
    int unk1634;           //0x1988
    int unk1635;           //0x198C
    int unk1636;           //0x1990
    int unk1637;           //0x1994
    int unk1638;           //0x1998
    int unk1639;           //0x199C
    int unk1640;           //0x19A0
    int unk1641;           //0x19A4
    int unk1642;           //0x19A8
    int unk1643;           //0x19AC
    int unk1644;           //0x19B0
    int unk1645;           //0x19B4
    int unk1646;           //0x19B8
    int unk1647;           //0x19BC
    int unk1648;           //0x19C0
    int unk1649;           //0x19C4
    int unk1650;           //0x19C8
    int unk1651;           //0x19CC
    int unk1652;           //0x19D0
    int unk1653;           //0x19D4
    int unk1654;           //0x19D8
    int unk1655;           //0x19DC
    int unk1656;           //0x19E0
    int unk1657;           //0x19E4
    int unk1658;           //0x19E8
    int unk1659;           //0x19EC
    int unk1660;           //0x19F0
    int unk1661;           //0x19F4
    int unk1662;           //0x19F8
    int unk1663;           //0x19FC
    int unk1664;           //0x1A00
    int unk1665;           //0x1A04
    int unk1666;           //0x1A08
    int unk1667;           //0x1A0C
    int unk1668;           //0x1A10
    int unk1669;           //0x1A14
    int unk1670;           //0x1A18
    int unk1671;           //0x1A1C
    int unk1672;           //0x1A20
    int unk1673;           //0x1A24
    int unk1674;           //0x1A28
    int unk1675;           //0x1A2C
    int unk1676;           //0x1A30
    int unk1677;           //0x1A34
    int unk1678;           //0x1A38
    int unk1679;           //0x1A3C
    int unk1680;           //0x1A40
    int unk1681;           //0x1A44
    int unk1682;           //0x1A48
    int unk1683;           //0x1A4C
    int unk1684;           //0x1A50
    int unk1685;           //0x1A54
    int unk1686;           //0x1A58
    int unk1687;           //0x1A5C
    int unk1688;           //0x1A60
    int unk1689;           //0x1A64
    int unk1690;           //0x1A68
    int unk1691;           //0x1A6C
    int unk1692;           //0x1A70
    int unk1693;           //0x1A74
    int unk1694;           //0x1A78
    int unk1695;           //0x1A7C
    int unk1696;           //0x1A80
    int unk1697;           //0x1A84
    int unk1698;           //0x1A88
    int unk1699;           //0x1A8C
    int unk1700;           //0x1A90
    int unk1701;           //0x1A94
    int unk1702;           //0x1A98
    int unk1703;           //0x1A9C
    int unk1704;           //0x1AA0
    int unk1705;           //0x1AA4
    int unk1706;           //0x1AA8
    int unk1707;           //0x1AAC
    int unk1708;           //0x1AB0
    int unk1709;           //0x1AB4
    int unk1710;           //0x1AB8
    int unk1711;           //0x1ABC
    int unk1712;           //0x1AC0
    int unk1713;           //0x1AC4
    int unk1714;           //0x1AC8
    int unk1715;           //0x1ACC
    int unk1716;           //0x1AD0
    int unk1717;           //0x1AD4
    int unk1718;           //0x1AD8
    int unk1719;           //0x1ADC
    int unk1720;           //0x1AE0
    int unk1721;           //0x1AE4
    int unk1722;           //0x1AE8
    int unk1723;           //0x1AEC
    int unk1724;           //0x1AF0
    int unk1725;           //0x1AF4
    int unk1726;           //0x1AF8
    int unk1727;           //0x1AFC
    int unk1728;           //0x1B00
    int unk1729;           //0x1B04
    int unk1730;           //0x1B08
    int unk1731;           //0x1B0C
    int unk1732;           //0x1B10
    int unk1733;           //0x1B14
    int unk1734;           //0x1B18
    int unk1735;           //0x1B1C
    int unk1736;           //0x1B20
    int unk1737;           //0x1B24
    int unk1738;           //0x1B28
    int unk1739;           //0x1B2C
    int unk1740;           //0x1B30
    int unk1741;           //0x1B34
    int unk1742;           //0x1B38
    int unk1743;           //0x1B3C
    int unk1744;           //0x1B40
    int unk1745;           //0x1B44
    int unk1746;           //0x1B48
    int unk1747;           //0x1B4C
    int unk1748;           //0x1B50
    int unk1749;           //0x1B54
    int unk1750;           //0x1B58
    int unk1751;           //0x1B5C
    int unk1752;           //0x1B60
    int unk1753;           //0x1B64
    int unk1754;           //0x1B68
    int unk1755;           //0x1B6C
    int unk1756;           //0x1B70
    int unk1757;           //0x1B74
    int unk1758;           //0x1B78
    int unk1759;           //0x1B7C
    int unk1760;           //0x1B80
    int unk1761;           //0x1B84
    int unk1762;           //0x1B88
    int unk1763;           //0x1B8C
    int unk1764;           //0x1B90
    int unk1765;           //0x1B94
    int unk1766;           //0x1B98
    int unk1767;           //0x1B9C
    int unk1768;           //0x1BA0
    int unk1769;           //0x1BA4
    int unk1770;           //0x1BA8
    int unk1771;           //0x1BAC
    int unk1772;           //0x1BB0
    int unk1773;           //0x1BB4
    int unk1774;           //0x1BB8
    int unk1775;           //0x1BBC
    int unk1776;           //0x1BC0
    int unk1777;           //0x1BC4
    int unk1778;           //0x1BC8
    int unk1779;           //0x1BCC
    int unk1780;           //0x1BD0
    int unk1781;           //0x1BD4
    int unk1782;           //0x1BD8
    int unk1783;           //0x1BDC
    int unk1784;           //0x1BE0
    int unk1785;           //0x1BE4
    int unk1786;           //0x1BE8
    int unk1787;           //0x1BEC
    int unk1788;           //0x1BF0
    int unk1789;           //0x1BF4
    int unk1790;           //0x1BF8
    int unk1791;           //0x1BFC
    int unk1792;           //0x1C00
    int unk1793;           //0x1C04
    int unk1794;           //0x1C08
    int unk1795;           //0x1C0C
    int unk1796;           //0x1C10
    int unk1797;           //0x1C14
    int unk1798;           //0x1C18
    int unk1799;           //0x1C1C
    int unk1800;           //0x1C20
    int unk1801;           //0x1C24
    int unk1802;           //0x1C28
    int unk1803;           //0x1C2C
    int unk1804;           //0x1C30
    int unk1805;           //0x1C34
    int unk1806;           //0x1C38
    int unk1807;           //0x1C3C
    int unk1808;           //0x1C40
    int unk1809;           //0x1C44
    int unk1810;           //0x1C48
    int unk1811;           //0x1C4C
    int unk1812;           //0x1C50
    int unk1813;           //0x1C54
    int unk1814;           //0x1C58
    int unk1815;           //0x1C5C
    int unk1816;           //0x1C60
    int unk1817;           //0x1C64
    int unk1818;           //0x1C68
    int unk1819;           //0x1C6C
    int unk1820;           //0x1C70
    int unk1821;           //0x1C74
    int unk1822;           //0x1C78
    int unk1823;           //0x1C7C
    int unk1824;           //0x1C80
    int unk1825;           //0x1C84
    int unk1826;           //0x1C88
    int unk1827;           //0x1C8C
    int unk1828;           //0x1C90
    int unk1829;           //0x1C94
    int unk1830;           //0x1C98
    int unk1831;           //0x1C9C
    int unk1832;           //0x1CA0
    int unk1833;           //0x1CA4
    int unk1834;           //0x1CA8
    int unk1835;           //0x1CAC
    int unk1836;           //0x1CB0
    int unk1837;           //0x1CB4
    int unk1838;           //0x1CB8
    int unk1839;           //0x1CBC
    int unk1840;           //0x1CC0
    int unk1841;           //0x1CC4
    int unk1842;           //0x1CC8
    int unk1843;           //0x1CCC
    int unk1844;           //0x1CD0
    int unk1845;           //0x1CD4
    int unk1846;           //0x1CD8
    int unk1847;           //0x1CDC
    int unk1848;           //0x1CE0
    int unk1849;           //0x1CE4
    int unk1850;           //0x1CE8
    int unk1851;           //0x1CEC
    int unk1852;           //0x1CF0
    int unk1853;           //0x1CF4
    int unk1854;           //0x1CF8
    int unk1855;           //0x1CFC
    int unk1856;           //0x1D00
    int unk1857;           //0x1D04
    int unk1858;           //0x1D08
    int unk1859;           //0x1D0C
    int unk1860;           //0x1D10
    int unk1861;           //0x1D14
    int unk1862;           //0x1D18
    int unk1863;           //0x1D1C
    int unk1864;           //0x1D20
    int unk1865;           //0x1D24
    int unk1866;           //0x1D28
    int unk1867;           //0x1D2C
    int unk1868;           //0x1D30
    int unk1869;           //0x1D34
    int unk1870;           //0x1D38
    int unk1871;           //0x1D3C
    int unk1872;           //0x1D40
    int unk1873;           //0x1D44
    int unk1874;           //0x1D48
    int unk1875;           //0x1D4C
    int unk1876;           //0x1D50
    int unk1877;           //0x1D54
    int unk1878;           //0x1D58
    int unk1879;           //0x1D5C
    int unk1880;           //0x1D60
    int unk1881;           //0x1D64
    int unk1882;           //0x1D68
    int unk1883;           //0x1D6C
    int unk1884;           //0x1D70
    int unk1885;           //0x1D74
    int unk1886;           //0x1D78
    int unk1887;           //0x1D7C
    int unk1888;           //0x1D80
    int unk1889;           //0x1D84
    int unk1890;           //0x1D88
    int unk1891;           //0x1D8C
    int unk1892;           //0x1D90
    int unk1893;           //0x1D94
    int unk1894;           //0x1D98
    int unk1895;           //0x1D9C
    int unk1896;           //0x1DA0
    int unk1897;           //0x1DA4
    int unk1898;           //0x1DA8
    int unk1899;           //0x1DAC
    int unk1900;           //0x1DB0
    int unk1901;           //0x1DB4
    int unk1902;           //0x1DB8
    int unk1903;           //0x1DBC
    int unk1904;           //0x1DC0
    int unk1905;           //0x1DC4
    int unk1906;           //0x1DC8
    int unk1907;           //0x1DCC
    int unk1908;           //0x1DD0
    int unk1909;           //0x1DD4
    int unk1910;           //0x1DD8
    int unk1911;           //0x1DDC
    int unk1912;           //0x1DE0
    int unk1913;           //0x1DE4
    int unk1914;           //0x1DE8
    int unk1915;           //0x1DEC
    int unk1916;           //0x1DF0
    int unk1917;           //0x1DF4
    int unk1918;           //0x1DF8
    int unk1919;           //0x1DFC
    int unk1920;           //0x1E00
    int unk1921;           //0x1E04
    int unk1922;           //0x1E08
    int unk1923;           //0x1E0C
    int unk1924;           //0x1E10
    int unk1925;           //0x1E14
    int unk1926;           //0x1E18
    int unk1927;           //0x1E1C
    int unk1928;           //0x1E20
    int unk1929;           //0x1E24
    int unk1930;           //0x1E28
    int unk1931;           //0x1E2C
    int unk1932;           //0x1E30
    int unk1933;           //0x1E34
    int unk1934;           //0x1E38
    int unk1935;           //0x1E3C
    int unk1936;           //0x1E40
    int unk1937;           //0x1E44
    int unk1938;           //0x1E48
    int unk1939;           //0x1E4C
    int unk1940;           //0x1E50
    int unk1941;           //0x1E54
    int unk1942;           //0x1E58
    int unk1943;           //0x1E5C
    int unk1944;           //0x1E60
    int unk1945;           //0x1E64
    int unk1946;           //0x1E68
    int unk1947;           //0x1E6C
    int unk1948;           //0x1E70
    int unk1949;           //0x1E74
    int unk1950;           //0x1E78
    int unk1951;           //0x1E7C
    int unk1952;           //0x1E80
    int unk1953;           //0x1E84
    int unk1954;           //0x1E88
    int unk1955;           //0x1E8C
    int unk1956;           //0x1E90
    int unk1957;           //0x1E94
    int unk1958;           //0x1E98
    int unk1959;           //0x1E9C
    int unk1960;           //0x1EA0
    int unk1961;           //0x1EA4
    int unk1962;           //0x1EA8
    int unk1963;           //0x1EAC
    int unk1964;           //0x1EB0
    int unk1965;           //0x1EB4
    int unk1966;           //0x1EB8
    int unk1967;           //0x1EBC
    int unk1968;           //0x1EC0
    int unk1969;           //0x1EC4
    int unk1970;           //0x1EC8
    int unk1971;           //0x1ECC
    int unk1972;           //0x1ED0
    int unk1973;           //0x1ED4
    int unk1974;           //0x1ED8
    int unk1975;           //0x1EDC
    int unk1976;           //0x1EE0
    int unk1977;           //0x1EE4
    int unk1978;           //0x1EE8
    int unk1979;           //0x1EEC
    int unk1980;           //0x1EF0
    int unk1981;           //0x1EF4
    int unk1982;           //0x1EF8
    int unk1983;           //0x1EFC
    int unk1984;           //0x1F00
    int unk1985;           //0x1F04
    int unk1986;           //0x1F08
    int unk1987;           //0x1F0C
    int unk1988;           //0x1F10
    int unk1989;           //0x1F14
    int unk1990;           //0x1F18
    int unk1991;           //0x1F1C
    int unk1992;           //0x1F20
    int TM_OSDEnabled;     //0x1F24
    u8 TM_OSDMax;          //0x1F28
    u8 TM_EventPage;       //0x1F29
    u8 TM_OSDRecommended;  //0x1F2A
    int unk1995;           //0x1F2C
    int unk1996;           //0x1F30
    int unk1997;           //0x1F34
    int unk1998;           //0x1F38
    int unk1999;           //0x1F3C
    int unk2000;           //0x1F40
    int unk2001;           //0x1F44
    int unk2002;           //0x1F48
    int unk2003;           //0x1F4C
    int unk2004;           //0x1F50
    int unk2005;           //0x1F54
    int unk2006;           //0x1F58
    int unk2007;           //0x1F5C
    int unk2008;           //0x1F60
    int unk2009;           //0x1F64
    int unk2010;           //0x1F68
    int unk2011;           //0x1F6C
    int unk2012;           //0x1F70
    int unk2013;           //0x1F74
    int unk2014;           //0x1F78
    int unk2015;           //0x1F7C
    int unk2016;           //0x1F80
    int unk2017;           //0x1F84
    int unk2018;           //0x1F88
    int unk2019;           //0x1F8C
    int unk2020;           //0x1F90
    int unk2021;           //0x1F94
    int unk2022;           //0x1F98
    int unk2023;           //0x1F9C
    int unk2024;           //0x1FA0
    int unk2025;           //0x1FA4
    int unk2026;           //0x1FA8
    int unk2027;           //0x1FAC
    int unk2028;           //0x1FB0
    int unk2029;           //0x1FB4
    int unk2030;           //0x1FB8
    int unk2031;           //0x1FBC
    int unk2032;           //0x1FC0
    int unk2033;           //0x1FC4
    int unk2034;           //0x1FC8
    int unk2035;           //0x1FCC
    int unk2036;           //0x1FD0
    int unk2037;           //0x1FD4
    int unk2038;           //0x1FD8
    int unk2039;           //0x1FDC
    int unk2040;           //0x1FE0
    int unk2041;           //0x1FE4
    int unk2042;           //0x1FE8
    int unk2043;           //0x1FEC
    int unk2044;           //0x1FF0
    int unk2045;           //0x1FF4
    int unk2046;           //0x1FF8
    int unk2047;           //0x1FFC
};

struct SnapshotInfo
{
    int snap_id;
    u16 is_exist;
    u16 block_size;
};

struct SnapshotList
{
    int x0;
    int snap_num;
    int x8;
    int xc;
    SnapshotInfo snap_info[128];
};

struct MemSnapIconData
{
    _HSD_ImageDesc *banner;
    _HSD_ImageDesc *icon;
};

struct MemcardSave
{
    int size;   // size of the data, only used when writing to the card
    int x4;     // unknown, is usually 3
    void *data; // pointer to the save data
    int xc;     // is -1 to signify end of data
};

struct MemcardWork
{

    void *work_area;             // 0x0
    void *buffer;                // 0x4, temp transfer buffer used during CARDReads. is 0x2000 bytes
    int x8;                      // 0x8
    int xc;                      // 0xc
    int x10;                     // 0x10
    int x14;                     // 0x14
    void *icon_data;             // 0x18
    void *banner_data;           // 0x1c
    int x20;                     // 0x20
    int x24;                     // 0x24
    int x28;                     // 0x28
    int x2c;                     // 0x2c
    int x30;                     // 0x30
    int x34;                     // 0x34
    int x38;                     // 0x38
    int x3c;                     // 0x3c
    int x40;                     // 0x40
    int x44;                     // 0x44
    int x48;                     // 0x48
    int x4c;                     // 0x4c
    int x50;                     // 0x50
    int x54;                     // 0x54
    int x58;                     // 0x58
    int x5c;                     // 0x5c
    int x60;                     // 0x60
    int x64;                     // 0x64
    int x68;                     // 0x68
    int x6c;                     // 0x6c
    int x70;                     // 0x70
    int x74;                     // 0x74
    int x78;                     // 0x78
    int x7c;                     // 0x7c
    int x80;                     // 0x80
    int x84;                     // 0x84
    int x88;                     // 0x88
    int x8c;                     // 0x8c
    int x90;                     // 0x90
    CARDFileInfo card_file_x94;  // 0x94
    void *buffer_use;            // 0xa8, temp transfer buffer used during CARDReads
    int xac;                     // 0xac
    int buffer_size;             // 0xb0
    CARDFileInfo card_file_info; // 0xb4    cancel vanilla memcard reads with this fileinfo
    int xc8;                     // 0xc8
    int card_data_start;         // 0xcc, data after header and banner and metadata
    int xd0;                     // 0xd0
    int xd4;                     // 0xd4
    int xd8;                     // 0xd8
    int xdc;                     // 0xdc
    int xe0;                     // 0xe0
    int xe4;                     // 0xe4
    int xe8;                     // 0xe8
    int xec;                     // 0xec
    int xf0;                     // 0xf0
    int xf4;                     // 0xf4
    int xf8;                     // 0xf8
    int xfc;                     // 0xfc
    int x100;                    // 0x100
    int x104;                    // 0x104
    int x108;                    // 0x108
    int x10c;                    // 0x10c
    int x110;                    // 0x110
    int x114;                    // 0x114
    int x118;                    // 0x118
    int x11c;                    // 0x11c
    int x120;                    // 0x120
    int x124;                    // 0x124
    int x128;                    // 0x128
    int x12c;                    // 0x12c
    int x130;                    // 0x130
    int x134;                    // 0x134
    int x138;                    // 0x138
    int x13c;                    // 0x13c
    int x140;                    // 0x140
    int x144;                    // 0x144
    int x148;                    // 0x148
    int x14c;                    // 0x14c
    int x150;                    // 0x150
    int x154;                    // 0x154
    int x158;                    // 0x158
    int x15c;                    // 0x15c
    int x160;                    // 0x160
    int x164;                    // 0x164
    int x168;                    // 0x168
    int x16c;                    // 0x16c
    int x170;                    // 0x170
    int x174;                    // 0x174
    int x178;                    // 0x178
    int x17c;                    // 0x17c
    int x180;                    // 0x180
    int x184;                    // 0x184
    int x188;                    // 0x188
    int x18c;                    // 0x18c
    int x190;                    // 0x190
    int x194;                    // 0x194
    int x198;                    // 0x198
    int x19c;                    // 0x19c
    int x1a0;                    // 0x1a0
    int x1a4;                    // 0x1a4
    int x1a8;                    // 0x1a8
    int x1ac;                    // 0x1ac
    int x1b0;                    // 0x1b0
    int x1b4;                    // 0x1b4
    int x1b8;                    // 0x1b8
    int x1bc;                    // 0x1bc
    int x1c0;                    // 0x1c0
    int x1c4;                    // 0x1c4
    int x1c8;                    // 0x1c8
    int x1cc;                    // 0x1cc
    int x1d0;                    // 0x1d0
    int x1d4;                    // 0x1d4
    int x1d8;                    // 0x1d8
    int x1dc;                    // 0x1dc
    int x1e0;                    // 0x1e0
    int x1e4;                    // 0x1e4
    int x1e8;                    // 0x1e8
    int x1ec;                    // 0x1ec
    int x1f0;                    // 0x1f0
    int x1f4;                    // 0x1f4
    int x1f8;                    // 0x1f8
    int x1fc;                    // 0x1fc
    int x200;                    // 0x200
    int x204;                    // 0x204
    int x208;                    // 0x208
    int x20c;                    // 0x20c
    int x210;                    // 0x210
    int x214;                    // 0x214
    int x218;                    // 0x218
    int x21c;                    // 0x21c
    int x220;                    // 0x220
    int x224;                    // 0x224
    int x228;                    // 0x228
    int x22c;                    // 0x22c
    int x230;                    // 0x230
    int x234;                    // 0x234
    int x238;                    // 0x238
    int x23c;                    // 0x23c
    int x240;                    // 0x240
    int x244;                    // 0x244
    int x248;                    // 0x248
    int x24c;                    // 0x24c
    int x250;                    // 0x250
    int x254;                    // 0x254
    int x258;                    // 0x258
    int x25c;                    // 0x25c
    int x260;                    // 0x260
    int x264;                    // 0x264
    int x268;                    // 0x268
    int x26c;                    // 0x26c
    int x270;                    // 0x270
    int x274;                    // 0x274
    int x278;                    // 0x278
    int x27c;                    // 0x27c
    int x280;                    // 0x280
    int x284;                    // 0x284
    int x288;                    // 0x288
    int x28c;                    // 0x28c
    int x290;                    // 0x290
    int x294;                    // 0x294
    int x298;                    // 0x298
    int x29c;                    // 0x29c
    int x2a0;                    // 0x2a0
    int x2a4;                    // 0x2a4
    int x2a8;                    // 0x2a8
    int x2ac;                    // 0x2ac
    int x2b0;                    // 0x2b0
    int x2b4;                    // 0x2b4
    int x2b8;                    // 0x2b8
    int x2bc;                    // 0x2bc
    int x2c0;                    // 0x2c0
    int x2c4;                    // 0x2c4
    int x2c8;                    // 0x2c8
    int x2cc;                    // 0x2cc
    int x2d0;                    // 0x2d0
    int x2d4;                    // 0x2d4
    int x2d8;                    // 0x2d8
    int x2dc;                    // 0x2dc
    int x2e0;                    // 0x2e0
    int x2e4;                    // 0x2e4
    int x2e8;                    // 0x2e8
    int x2ec;                    // 0x2ec
    int x2f0;                    // 0x2f0
    int x2f4;                    // 0x2f4
    int x2f8;                    // 0x2f8
    int x2fc;                    // 0x2fc
    int x300;                    // 0x300
    int x304;                    // 0x304
    int x308;                    // 0x308
    int x30c;                    // 0x30c
    int x310;                    // 0x310
    int x314;                    // 0x314
    int x318;                    // 0x318
    int x31c;                    // 0x31c
    int x320;                    // 0x320
    int x324;                    // 0x324
    int x328;                    // 0x328
    int x32c;                    // 0x32c
    int x330;                    // 0x330
    int x334;                    // 0x334
    int x338;                    // 0x338
    int x33c;                    // 0x33c
    int x340;                    // 0x340
    int x344;                    // 0x344
    int x348;                    // 0x348
    int x34c;                    // 0x34c
    int x350;                    // 0x350
    int x354;                    // 0x354
    int x358;                    // 0x358
    int x35c;                    // 0x35c
    int x360;                    // 0x360
    int x364;                    // 0x364
    int x368;                    // 0x368
    int x36c;                    // 0x36c
    int x370;                    // 0x370
    int x374;                    // 0x374
    int x378;                    // 0x378
    int x37c;                    // 0x37c
    int x380;                    // 0x380
    int x384;                    // 0x384
    int x388;                    // 0x388
    int x38c;                    // 0x38c
    int x390;                    // 0x390
    int x394;                    // 0x394
    int x398;                    // 0x398
    int x39c;                    // 0x39c
    int x3a0;                    // 0x3a0
    int x3a4;                    // 0x3a4
    int x3a8;                    // 0x3a8
    int x3ac;                    // 0x3ac
    int x3b0;                    // 0x3b0
    int x3b4;                    // 0x3b4
    int x3b8;                    // 0x3b8
    int x3bc;                    // 0x3bc
    int x3c0;                    // 0x3c0
    int x3c4;                    // 0x3c4
    int x3c8;                    // 0x3c8
    int x3cc;                    // 0x3cc
    int x3d0;                    // 0x3d0
    int x3d4;                    // 0x3d4
    int x3d8;                    // 0x3d8
    int x3dc;                    // 0x3dc
    int x3e0;                    // 0x3e0
    int x3e4;                    // 0x3e4
    int x3e8;                    // 0x3e8
    int x3ec;                    // 0x3ec
    int x3f0;                    // 0x3f0
    int x3f4;                    // 0x3f4
    int x3f8;                    // 0x3f8
    int x3fc;                    // 0x3fc
    int x400;                    // 0x400
    int x404;                    // 0x404
    int x408;                    // 0x408
    int x40c;                    // 0x40c
    int x410;                    // 0x410
    int x414;                    // 0x414
    int x418;                    // 0x418
    int x41c;                    // 0x41c
    int x420;                    // 0x420
    int x424;                    // 0x424
    int x428;                    // 0x428
    int x42c;                    // 0x42c
    int x430;                    // 0x430
    int x434;                    // 0x434
    int x438;                    // 0x438
    int x43c;                    // 0x43c
    int x440;                    // 0x440
    int x444;                    // 0x444
    int x448;                    // 0x448
    int x44c;                    // 0x44c
    int x450;                    // 0x450
    int x454;                    // 0x454
    int x458;                    // 0x458
    int x45c;                    // 0x45c
    int x460;                    // 0x460
    int x464;                    // 0x464
    int x468;                    // 0x468
    int x46c;                    // 0x46c
    int x470;                    // 0x470
    int x474;                    // 0x474
    int x478;                    // 0x478
    int x47c;                    // 0x47c
    int x480;                    // 0x480
    int x484;                    // 0x484
    int x488;                    // 0x488
    int x48c;                    // 0x48c
    int x490;                    // 0x490
    int x494;                    // 0x494
    int x498;                    // 0x498
    int x49c;                    // 0x49c
    int x4a0;                    // 0x4a0
    int x4a4;                    // 0x4a4
    int x4a8;                    // 0x4a8
    int x4ac;                    // 0x4ac
    int x4b0;                    // 0x4b0
    int x4b4;                    // 0x4b4
    int x4b8;                    // 0x4b8
    int x4bc;                    // 0x4bc
    int x4c0;                    // 0x4c0
    int x4c4;                    // 0x4c4
    int x4c8;                    // 0x4c8
    int x4cc;                    // 0x4cc
    int x4d0;                    // 0x4d0
    int x4d4;                    // 0x4d4
    int x4d8;                    // 0x4d8
    int x4dc;                    // 0x4dc
    int x4e0;                    // 0x4e0
    int x4e4;                    // 0x4e4
    int x4e8;                    // 0x4e8
    int x4ec;                    // 0x4ec
    int x4f0;                    // 0x4f0
    int x4f4;                    // 0x4f4
    int x4f8;                    // 0x4f8
    int x4fc;                    // 0x4fc
    int x500;                    // 0x500
    int x504;                    // 0x504
    int x508;                    // 0x508
    int x50c;                    // 0x50c
    int x510;                    // 0x510
    int x514;                    // 0x514
    int x518;                    // 0x518
    int x51c;                    // 0x51c
    int x520;                    // 0x520
    int x524;                    // 0x524
    int x528;                    // 0x528
    int x52c;                    // 0x52c
    int x530;                    // 0x530
    int x534;                    // 0x534
    int x538;                    // 0x538
    int x53c;                    // 0x53c
    int x540;                    // 0x540
    int x544;                    // 0x544
    int x548;                    // 0x548
    int x54c;                    // 0x54c
    int x550;                    // 0x550
    int x554;                    // 0x554
    int x558;                    // 0x558
    int x55c;                    // 0x55c
    int x560;                    // 0x560
    int x564;                    // 0x564
    int x568;                    // 0x568
    int x56c;                    // 0x56c
    int x570;                    // 0x570
    int x574;                    // 0x574
    int x578;                    // 0x578
    int x57c;                    // 0x57c
    int x580;                    // 0x580
    int x584;                    // 0x584
    int x588;                    // 0x588
    int x58c;                    // 0x58c
    int x590;                    // 0x590
    int x594;                    // 0x594
    int x598;                    // 0x598
    int x59c;                    // 0x59c
    int x5a0;                    // 0x5a0
    int x5a4;                    // 0x5a4
    int x5a8;                    // 0x5a8
    int x5ac;                    // 0x5ac
    int x5b0;                    // 0x5b0
    int x5b4;                    // 0x5b4
    int x5b8;                    // 0x5b8
    int x5bc;                    // 0x5bc
    int x5c0;                    // 0x5c0
    int x5c4;                    // 0x5c4
    int x5c8;                    // 0x5c8
    int x5cc;                    // 0x5cc
    int x5d0;                    // 0x5d0
    int x5d4;                    // 0x5d4
    int x5d8;                    // 0x5d8
    int x5dc;                    // 0x5dc
    int x5e0;                    // 0x5e0
    int x5e4;                    // 0x5e4
    int x5e8;                    // 0x5e8
    int x5ec;                    // 0x5ec
    int x5f0;                    // 0x5f0
    int x5f4;                    // 0x5f4
    int x5f8;                    // 0x5f8
    int x5fc;                    // 0x5fc
    int x600;                    // 0x600
    int x604;                    // 0x604
    int x608;                    // 0x608
    int x60c;                    // 0x60c
    int x610;                    // 0x610
    int x614;                    // 0x614
    int x618;                    // 0x618
    int x61c;                    // 0x61c
    int x620;                    // 0x620
    int x624;                    // 0x624
    int x628;                    // 0x628
    int x62c;                    // 0x62c
    int x630;                    // 0x630
    int x634;                    // 0x634
    int x638;                    // 0x638
    int x63c;                    // 0x63c
    int x640;                    // 0x640
    int x644;                    // 0x644
    int x648;                    // 0x648
    int x64c;                    // 0x64c
    int x650;                    // 0x650
    int x654;                    // 0x654
    int x658;                    // 0x658
    int x65c;                    // 0x65c
    int x660;                    // 0x660
    int x664;                    // 0x664
    int x668;                    // 0x668
    int x66c;                    // 0x66c
    int x670;                    // 0x670
    int x674;                    // 0x674
    int x678;                    // 0x678
    int x67c;                    // 0x67c
    int x680;                    // 0x680
    int x684;                    // 0x684
    int x688;                    // 0x688
    int x68c;                    // 0x68c
    int x690;                    // 0x690
    int x694;                    // 0x694
    int x698;                    // 0x698
    int x69c;                    // 0x69c
    int x6a0;                    // 0x6a0
    int x6a4;                    // 0x6a4
    int x6a8;                    // 0x6a8
    int x6ac;                    // 0x6ac
    int x6b0;                    // 0x6b0
    int x6b4;                    // 0x6b4
    int x6b8;                    // 0x6b8
    int x6bc;                    // 0x6bc
    int x6c0;                    // 0x6c0
    int x6c4;                    // 0x6c4
    int x6c8;                    // 0x6c8
    int x6cc;                    // 0x6cc
    int x6d0;                    // 0x6d0
    int x6d4;                    // 0x6d4
    int x6d8;                    // 0x6d8
    int x6dc;                    // 0x6dc
    int x6e0;                    // 0x6e0
    int x6e4;                    // 0x6e4
    int x6e8;                    // 0x6e8
    int x6ec;                    // 0x6ec
    int x6f0;                    // 0x6f0
    int x6f4;                    // 0x6f4
    int x6f8;                    // 0x6f8
    int x6fc;                    // 0x6fc
    int x700;                    // 0x700
    int x704;                    // 0x704
    int x708;                    // 0x708
    int x70c;                    // 0x70c
    int x710;                    // 0x710
    int x714;                    // 0x714
    int x718;                    // 0x718
    int x71c;                    // 0x71c
    int x720;                    // 0x720
    int x724;                    // 0x724
    int x728;                    // 0x728
    int x72c;                    // 0x72c
    int x730;                    // 0x730
    int x734;                    // 0x734
    int x738;                    // 0x738
    int x73c;                    // 0x73c
    int x740;                    // 0x740
    int x744;                    // 0x744
    int x748;                    // 0x748
    int x74c;                    // 0x74c
    int x750;                    // 0x750
    int x754;                    // 0x754
    int x758;                    // 0x758
    int x75c;                    // 0x75c
    int x760;                    // 0x760
    int x764;                    // 0x764
    int x768;                    // 0x768
    int x76c;                    // 0x76c
    int x770;                    // 0x770
    int x774;                    // 0x774
    int x778;                    // 0x778
    int x77c;                    // 0x77c
    int x780;                    // 0x780
    int x784;                    // 0x784
    int x788;                    // 0x788
    int x78c;                    // 0x78c
    int x790;                    // 0x790
    int x794;                    // 0x794
    int x798;                    // 0x798
    int x79c;                    // 0x79c
    int x7a0;                    // 0x7a0
    int x7a4;                    // 0x7a4
    int x7a8;                    // 0x7a8
    int x7ac;                    // 0x7ac
    int x7b0;                    // 0x7b0
    int x7b4;                    // 0x7b4
    int x7b8;                    // 0x7b8
    int x7bc;                    // 0x7bc
    int x7c0;                    // 0x7c0
    int x7c4;                    // 0x7c4
    int x7c8;                    // 0x7c8
    int x7cc;                    // 0x7cc
    int x7d0;                    // 0x7d0
    int x7d4;                    // 0x7d4
    int x7d8;                    // 0x7d8
    int x7dc;                    // 0x7dc
    int x7e0;                    // 0x7e0
    int x7e4;                    // 0x7e4
    int x7e8;                    // 0x7e8
    int x7ec;                    // 0x7ec
    int x7f0;                    // 0x7f0
    int x7f4;                    // 0x7f4
    int x7f8;                    // 0x7f8
    int x7fc;                    // 0x7fc
    int x800;                    // 0x800
    int x804;                    // 0x804
    int x808;                    // 0x808
    int x80c;                    // 0x80c
    int x810;                    // 0x810
    int x814;                    // 0x814
    int x818;                    // 0x818
    int x81c;                    // 0x81c
    int x820;                    // 0x820
    int x824;                    // 0x824
    int x828;                    // 0x828
    int x82c;                    // 0x82c
    int x830;                    // 0x830
    int x834;                    // 0x834
    int x838;                    // 0x838
    int x83c;                    // 0x83c
    int x840;                    // 0x840
    int x844;                    // 0x844
    int x848;                    // 0x848
    int x84c;                    // 0x84c
    int x850;                    // 0x850
    int x854;                    // 0x854
    int x858;                    // 0x858
    int x85c;                    // 0x85c
    int x860;                    // 0x860
    int x864;                    // 0x864
    int x868;                    // 0x868
    int x86c;                    // 0x86c
    int x870;                    // 0x870
    int x874;                    // 0x874
    int x878;                    // 0x878
    int x87c;                    // 0x87c
    int x880;                    // 0x880
    int x884;                    // 0x884
    int x888;                    // 0x888
    int x88c;                    // 0x88c
    int x890;                    // 0x890
    int x894;                    // 0x894
    int x898;                    // 0x898
    int x89c;                    // 0x89c
    int x8a0;                    // 0x8a0
    int x8a4;                    // 0x8a4
    int x8a8;                    // 0x8a8
    int is_done;                 // 0x8ac. operation callback sets this to 1 when the operation finishes
};

struct MemcardUnk
{
    u8 block_size;
    u8 x1;
    u8 x2;
    u8 x3;
    u8 x4;
    u8 x5;
    u8 x6;
    u8 x7;
    u8 x8;
    u8 x9;
    u8 xa[8];
};

struct MemcardInfo
{
    void *snap_data;            // 0x0 (should be 256,064 bytes)
    char file_name[32];         // should end with spaces
    char file_desc[32];         // should end with spaces
    MemSnapIconData *icon_data; // 0x44
    SnapshotList *snap_list;    // 0x48 (should be 2112 bytes) points to an allocation where info on the snapshots present on slot A exists
    int memcard_probe;          // 0x4c 1 == is present. is updated every controller poll
    int x50;                    // 0x50
    int x54;                    // 0x54
    int x58;                    // 0x58
    int x5c;                    // 0x5c
    int x60;                    // 0x60
    int x64;                    // 0x64
    int x68;                    // 0x68
    int x6c;                    // 0x6c
    int x70;                    // 0x70
    int x74;                    // 0x74
    int x78;                    // 0x78
    int x7c;                    // 0x7c
    int x80;                    // 0x80
    int x84;                    // 0x84
    int x88;                    // 0x88
    int x8c;                    // 0x8c
    int x90;                    // 0x90
    int x94;                    // 0x94
    int x98;                    // 0x98
    int x9c;                    // 0x9c
    int xa0;                    // 0xa0
    int xa4;                    // 0xa4
    int xa8;                    // 0xa8
    int xac;                    // 0xac
    int xb0;                    // 0xb0
    int xb4;                    // 0xb4
    int xb8;                    // 0xb8
    int xbc;                    // 0xbc
    int xc0;                    // 0xc0
    int xc4;                    // 0xc4
    int xc8;                    // 0xc8
    int xcc;                    // 0xcc
    int xd0;                    // 0xd0
    int xd4;                    // 0xd4
    int xd8;                    // 0xd8
    int xdc;                    // 0xdc
    int xe0;                    // 0xe0
    int xe4;                    // 0xe4
    int xe8;                    // 0xe8
    int xec;                    // 0xec
};

struct Rules1
{
    u8 x0;
    u8 x1;
    u8 x2;
    u8 x3;
    u8 x4;
    u8 handicap;
    u8 x6;
    u8 x7;
    u8 x8;
    u8 x9;
    u8 xa;
    u8 xb;
    u8 xc;
};

/*** Static Variables ***/
static MemcardInfo *stc_memcard_info = 0x80433380;
static MemcardUnk *stc_memcard_unk = 0x803bacc8;
static MemcardWork *stc_memcard_work = 0x80432a68;
int *stc_memcard_block_curr = R13 + (-0x3d20);
int *stc_memcard_block_last = R13 + (-0x3d1c);
int *stc_memcard_write_status = 0x804d1138;
int *stc_CardXferredBytes = R13 + (-0x3D14);

#endif