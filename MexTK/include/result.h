#ifndef MEX_H_RESULT
#define MEX_H_RESULT

#include "structs.h"
#include "datatypes.h"

struct RstPlayer
{
    u8 type;           // x0 (0x00 is HMN, 0x01 is CPU, 0x02 is Demo, 0x03 n/a)
    u8 ext_id;         // x1 (external fighter id)
    u8 kind;           // x2 internal id
    u8 costume : 6;    // x3 costume id
    u8 is_rumble : 1;  // x3 rumble flag
    u8 is_stamina : 1; // x3 stamina flag
    u8 nametag;        // x4 nametag index
    u8 x5;             // x5
    u8 x6;             // x6
    u8 team;           // x7 team id
    u8 stock_num;      // x8 remaining stocks
    u8 hp;             // x9 remaining hp
    u8 sd_num;         // xa times self destructed
    u8 fall_num;       // xb times died
    u16 dmg_num;       // unk
    u16 xe;            // absolutely dont know, takes stick inputs and scene into account??
    int x10;           // unk
    int x14;           // unk
    int x18;           // unk
    int coins;         // x1c
    int x20;           // unk
    int x24;           // unk
    int frames_alive;  // unk
    int x2c;           // unk
    int x30;           // unk
    int x34;           // unk
    int hits_landed;   // x38
    int attack_num;    // x3c total attacks
    int x40;           // unk
    int x44;           // unk
    int x48;           // unk
    int x4c;           // unk
    int x50;           // unk
    int x54;           // unk
    int x58;           // unk
    int x5c;           // unk
    int x60;           // unk
    int x64;           // unk
    int x68;           // unk
    int x6c;           // unk
    int x70;           // unk
    int x74;           // unk
    int x78;           // unk
    int x7c;           // unk
    int x80;           // unk
    int x84;           // unk
    int x88;           // unk
    int ledgegrab_num; // x8c
    int x90;           // unk
    int x94;           // unk
    int x98;           // unk
    int x9c;           // unk
    int xa0;           // unk
    int xa4;           // unk
};

struct RstInit
{
    int x0;
    u8 end_kind;          // how the match ended. (0x2 = GAME!, 0x1 = TIME!, and 0x7 = no contest)
    u8 x5;                // unk
    u8 match_kind;        // 0 = ffa, 1 = teams
    int match_frames;     // how many frames passed in the match
    u8 xc;                // unk
    u8 winner_num;        // is greater than 1 when a tie occurs
    u8 placings[4];       // array of player indices in order of placement
    int x10;              // unk
    int x14;              // unk
    int x18;              // unk
    int x1c;              // unk, totals up 0x88 of rstplayer
    u8 x20;               // unk
    u8 x21;               // unk
    u8 x22;               // unk
    u8 x23;               // unk
    int x24;              // unk
    int x28;              // unk
    int x2c;              // unk
    int x30;              // unk
    int x34;              // unk
    int x38;              // unk
    int x3c;              // unk
    int x40;              // unk
    int x44;              // unk
    int x48;              // unk
    int x4c;              // unk
    int x50;              // unk
    RstPlayer players[6]; // unk
};

#endif
