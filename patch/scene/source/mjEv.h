typedef struct ESSMinorData
{
    u8 leave_kind; // 0 = back, 1 = forward
    u8 page;
    u8 event;
    struct
    {
        u8 pos;
        u8 scroll;
    } cursor;
    EventLookup *ev_lookup;
} ESSMinorData;

#define ALT_SONG 98