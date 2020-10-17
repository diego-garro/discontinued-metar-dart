// Regular expressions to decode various groups of the METAR code

class METAR_REGEX {
  RegExp MISSING_RE = RegExp(r'^[M/]+$');

  RegExp TYPE_RE = RegExp(r'^(METAR|SPECI)$');

  RegExp COR_RE = RegExp(r'^(COR)$');

  RegExp STATION_RE = RegExp(r'^([A-Z][A-Z0-9]{3})$');

  RegExp TIME_RE = RegExp(r'^(\d{6})Z?$');

  RegExp MODIFIER_RE = RegExp(r'^(AUTO|FINO|NIL|TEST|CORR?|RTD|CC[A-G])$');

  RegExp WIND_RE = RegExp(
      r'^([\dO]{3}|///|MMM|VRB|P)([\dO]{2}|[/M]{2})(G(\d{2}|[/M{2}]))?(KTS?|KT|MPS)$');

  RegExp WINDVARIATION_RE = RegExp(r'((\d{3})V(\d{3}))$');

  RegExp OPTIONALVIS_RE = RegExp(r'^\d$');

  RegExp VISIBILITY_RE = RegExp(
      r'^((\d{4}|\//\//)|((M|P)?(\d|\d{1,2}?/\d{1,2}?))(SM|KM|M|U))|(CAVOK)$');

  RegExp SECVISIBILITY_RE = RegExp(r'^(\d{4})([NSEW]([EW])?)$');

  RegExp RUNWAY_RE =
      RegExp(r'^(RVRNO | R(\d{2}(RR?|LL?|C)?)/(V((M|P)?\d{4}))?(FT)?[/NDU]*)');

  RegExp WEATHER_RE = RegExp(
      r'^((-|\+|VC)*)((MI|PR|BC|DR|BL|SH|TS|FZ)+)?((DZ|RA|SN|SG|IC|PL|GR|GS|UP|/)*)(BR|FG|FU|VA|DU|SA|HZ|PY)?(PO|SQ|FC|SS|DS|NSW|/+)?([-+])?');

  RegExp SKY_RE = RegExp(
      r'^(VV|CLR|SCK|SCK|NSC|NCD|BKN|SCT|FEW|[O0]VC|///)([\dO]{2,4}|///)?(([A-Z][A-Z]+|///))?');

  RegExp TEMP_RE = RegExp(r'^((M|-)?\d+|//|XX|MM)/((M|-)?\d+|//|XX|MM)?');

  RegExp PRESS_RE = RegExp(r'^(A|Q|QNH)?([\dO]{3,4}|\//\//)(INS)?');

  RegExp RECENT_RE = RegExp(
      r'^RE(MI|PR|BC|DR|BL|SH|TS|FZ)?((DZ|RA|SN|SG|IC|PL|GR|GS|UP)*)?(BR|FG|VA|DU|SA|HZ|PY)?(PO|SQ|FC|SS|DS)?');

  RegExp WINDSHEAR_RE = RegExp(r'^(WS\s+)?(ALL\s+RWY|RWY(\d{2}()))');

  RegExp COLOR_RE =
      RegExp(r'^(BLACK)?(BLU|GRN|WHT|RED)\+?(/?(BLACK)?(BLU|GRN|WHT|RED)\+?)*');

  RegExp RUNWAYSTATE_RE = RegExp(
      r'^((\d{2}) | R(\d{2})(RR?|LL?|C)?/?)((SNOCLO|CLRD(\d{2}|//)) | (\d|/)(\d|/)(\d{2}|//)(\d{2}|//))');

  RegExp TREND_RE = RegExp(r'^(TEMPO|BECMG|FCST|NOSIG)');

  RegExp TRENDTIME_RE = RegExp(r'^(FM|TL|AT)(\d{2})(\d{2}\s+)');

  RegExp REMARK_RE = RegExp(r'^((RMK(S)?)|NOSPECI|NOSIG)');

// Regular expressions for remark groups
  RegExp AUTO_RE = RegExp(r'^AO(\d)\s+');

  RegExp SEALVL_PRESS_RE = RegExp(r'^SLP(\d{3})');

  RegExp PEAK_WIND_RE =
      RegExp(r'^P[A-Z]\s+WND\s+(\d{3})(P?\d{3}?)/(\d{2})?(\d{2})');

  RegExp WIND_SHIFT_RE = RegExp(r'^WSHFT\s+(\d{2})?(\d{2})(\s+(FROPA))?');

  RegExp PRECIP_1HR_RE = RegExp(r'^P(\d{4})');

  RegExp PRECIP_24HR_RE = RegExp(r'^(6|7)(\d{4})');

  RegExp PRESS_3HR_RE = RegExp(r'^5([0-8])(\d{3})');

  RegExp TEMP_1HR_RE = RegExp(r'^T(1|2)(0|1)(\d{3})');

  RegExp TEMP_6HR_RE = RegExp(r'^(1|2)(0|1)(\d{3})');

  RegExp TEMP_24HR_RE = RegExp(r'^4(0|1)(\d{3})(0|1)(\d{3})');

  RegExp UNPARSED_RE = RegExp(r'(\S+)\s+');

  RegExp LIGHTNING_RE = RegExp(
      r'^((OCNL|FRQ|CONS)\s+)?LGT((IC|CC|CG|CA)*)( \s+(( OHD | VC | DSNT\s+ | \s+AND\s+ | [NSEW][EW]? (-[NSEW][EW]?)* )+) )?');

  RegExp TS_LOC_RE = RegExp(
      r'TS(\s+(( OHD | VC | DSNT\s+ | \s+AND\s+ | [NSEW][EW]? (-[NSEW][EW]?)* )+))?( \s+MOV\s+([NSEW][EW]?) )?');

  RegExp SNOWDEPTH_RE = RegExp(r'^4/(\d{3})');

  RegExp ICE_ACCRETION_RE = RegExp(r'^I([136])(\d{3})');
}
