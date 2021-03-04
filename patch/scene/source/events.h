// Function prototypes
EventDesc *GetEventDesc(int page, int event);
void EventInit(int page, int eventID, MatchInit *matchData);
void EventLoad();

EventDesc *GetEventDesc(int page, int event);
char *GetEventName(int page, int event);
char *GetEventDescription(int page, int event);
char *GetEventTut(int page, int event);
char *GetPageName(int page);
char *GetEventFile(int page, int event);
char *GetCSSFile(int page, int event);
int GetPageEventNum(int page);
int GetPageNum();
u8 GetIsChooseCPU(int page, int event);
u8 GetIsSelectStage(int page, int event);
s8 GetFighter(int page, int event);
s8 GetCPUFighter(int page, int event);
s16 GetStage(int page, int event);