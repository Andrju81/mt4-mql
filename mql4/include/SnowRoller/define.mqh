
// eindeutige ID der Strategie (Bereich 101-1023)
#define STRATEGY_ID               103


// Grid-Directions
#define D_LONG                      1
#define D_SHORT                     2
#define D_ALT                       3
string  directionDescr[] = {"undefined", "Long", "Short", "Alternative"};


// Sequenzstatus-Werte
#define STATUS_UNINITIALIZED        0
#define STATUS_WAITING              1
#define STATUS_STARTING             2
#define STATUS_PROGRESSING          3
#define STATUS_STOPPING             4
#define STATUS_STOPPED              5
#define STATUS_DISABLED             6


// Event-Types f�r SynchronizeStatus()
#define EV_SEQUENCE_START           1
#define EV_SEQUENCE_STOP            2
#define EV_GRIDBASE_CHANGE          3
#define EV_POSITION_OPEN            4
#define EV_POSITION_STOPOUT         5
#define EV_POSITION_CLOSE           6


// Start/StopCondition-PriceTypes
#define SCP_BID                     0
#define SCP_ASK                     1
#define SCP_MEDIAN                  2                                   // (Bid+Ask)/2
string  scpDescr[] = {"Bid", "Ask", "Avg"};


// Start/StopDisplay-Modes
#define SDM_NONE                    0                                   // - keine Anzeige -
#define SDM_PRICE    SYMBOL_LEFTPRICE                                   // Preismarker
int startStopDisplayModes[] = {SDM_NONE, SDM_PRICE};


// OrderDisplay-Flags
#define ODF_PENDING                 1
#define ODF_OPEN                    2
#define ODF_STOPPEDOUT              4
#define ODF_CLOSED                  8

// OrderDisplay-Modes
#define ODM_NONE                    0                                   // - keine Anzeige -
#define ODM_STOPS                   1                                   // Pending,       ClosedBySL
#define ODM_PYRAMID                 2                                   // Pending, Open,             Closed
#define ODM_ALL                     3                                   // Pending, Open, ClosedBySL, Closed
int orderDisplayModes[] = {ODM_NONE, ODM_STOPS, ODM_PYRAMID, ODM_ALL};

// OrderDisplay-Farben
#define CLR_PENDING                 DeepSkyBlue
#define CLR_LONG                    Blue
#define CLR_SHORT                   Red
#define CLR_CLOSE                   Orange
