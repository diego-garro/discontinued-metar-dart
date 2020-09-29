// Regular expressions to decode various groups of the METAR code

RegExp MISSING_RE = RegExp(r'^[M/]+$');

RegExp TYPE_RE = RegExp(r'^(METAR|SPECI)\s+');

RegExp COR_RE = RegExp(r'^(COR)\s+');

RegExp STATION_RE = RegExp(r'^([A-Z][A-Z0-9]{3})\s+');

RegExp TIME_RE = RegExp(r'^(\d{6})Z?\s+');

RegExp MODIFIER_RE = RegExp(r'^(AUTO|FINO|NIL|TEST|CORR?|RTD|CC[A-G])\s+');

RegExp WIND_RE = RegExp(
    r'^([\dO]{3}|[0O]|///|MMM|VRB)([\dO]{2,3}|[/M]{2,3})(G(\d{1,3}|[/M{1,3}]))?(KTS?|LT|K|T|KMH|MPS)?(\s+(\d{3})V(\d{3}))?\s+');

RegExp VISIBILITY_RE = RegExp(
    r'^(((M|P)?\d{4}|\//\//)([NSEW][EW]? | NVD)? |((M|P)?(\d+|\d{2}?/\d{2}?|\d+\s+\d/\d))(SM|KM|M|U) | CAVOK )\s+');

RegExp RUNWAY_RE =
    RegExp(r'^(RVRNO | R(\d{2}(RR?|LL?|C)?)/(V((M|P)?\d{4}))?(FT)?[/NDU]*)\s+');

RegExp WEATHER_RE = RegExp(
    r'^((-|\+|VC)*)((MI|PR|BC|DR|BL|SH|TS|FZ)+)?((DZ|RA|SN|SG|IC|PL|GR|GS|UP|/)*)(BR|FG|FU|VA|DU|SA|HZ|PY)?(PO|SQ|FC|SS|DS|NSW|/+)?([-+])?\s+');

RegExp SKY_RE = RegExp(
    r'^(VV|CLR|SCK|SCK|NSC|NCD|BKN|SCT|FEW|[O0]VC|///)([\dO]{2,4}|///)?(([A-Z][A-Z]+|///))?\s+');

RegExp TEMP_RE = RegExp(r'^((M|-)?\d+|//|XX|MM)/((M|-)?\d+|//|XX|MM)?\s+');

RegExp PRESS_RE = RegExp(r'^(A|Q|QNH)?([\dO]{3,4}|\//\//)(INS)?\s+');

RegExp RECENT_RE = RegExp(
    r'^RE(MI|PR|BC|DR|BL|SH|TS|FZ)?((DZ|RA|SN|SG|IC|PL|GR|GS|UP)*)?(BR|FG|VA|DU|SA|HZ|PY)?(PO|SQ|FC|SS|DS)?\s+');

RegExp WINDSHEAR_RE = RegExp(r'^(WS\s+)?(ALL\s+RWY|RWY(\d{2}()))');

RegExp COLOR_RE = RegExp(
    r'^(BLACK)?(BLU|GRN|WHT|RED)\+?(/?(BLACK)?(BLU|GRN|WHT|RED)\+?)*\s+');

RegExp RUNWAYSTATE_RE = RegExp(
    r'^((\d{2}) | R(\d{2})(RR?|LL?|C)?/?)((SNOCLO|CLRD(\d{2}|//)) | (\d|/)(\d|/)(\d{2}|//)(\d{2}|//))\s+');

RegExp TREND_RE = RegExp(r'^(TEMPO|BECMG|FCST|NOSIG)\s+');

RegExp TRENDTIME_RE = RegExp(r'^(FM|TL|AT)(\d{2})(\d{2}\s+)');

RegExp REMARK_RE = RegExp(r'^(RMKS?|NOSPECI|NOSIG)\s+');

// Regular expressions for remark groups
RegExp AUTO_RE = RegExp(r'^AO(\d)\s+');

RegExp SEALVL_PRESS_RE = RegExp(r'^SLP(\d{3})\s+');

RegExp PEAK_WIND_RE =
    RegExp(r'^P[A-Z]\s+WND\s+(\d{3})(P?\d{3}?)/(\d{2})?(\d{2})\s+');

RegExp WIND_SHIFT_RE = RegExp(r'^WSHFT\s+(\d{2})?(\d{2})(\s+(FROPA))?\s+');

RegExp PRECIP_1HR_RE = RegExp(r'^P(\d{4})\s+');

RegExp PRECIP_24HR_RE = RegExp(r'^(6|7)(\d{4})\s+');

RegExp PRESS_3HR_RE = RegExp(r'^5([0-8])(\d{3})\s+');

RegExp TEMP_1HR_RE = RegExp(r'^T(1|2)(0|1)(\d{3})\s+');

RegExp TEMP_6HR_RE = RegExp(r'^(1|2)(0|1)(\d{3})\s+');

RegExp TEMP_24HR_RE = RegExp(r'^4(0|1)(\d{3})(0|1)(\d{3})\s+');

RegExp UNPARSED_RE = RegExp(r'(\S+)\s+');

RegExp LIGHTNING_RE = RegExp(
    r'^((OCNL|FRQ|CONS)\s+)?LGT((IC|CC|CG|CA)*)( \s+(( OHD | VC | DSNT\s+ | \s+AND\s+ | [NSEW][EW]? (-[NSEW][EW]?)* )+) )?\s+');

RegExp TS_LOC_RE = RegExp(
    r'TS(\s+(( OHD | VC | DSNT\s+ | \s+AND\s+ | [NSEW][EW]? (-[NSEW][EW]?)* )+))?( \s+MOV\s+([NSEW][EW]?) )?\s+');

RegExp SNOWDEPTH_RE = RegExp(r'^4/(\d{3})\s+');

RegExp ICE_ACCRETION_RE = RegExp(r'^I([136])(\d{3})\s+');
