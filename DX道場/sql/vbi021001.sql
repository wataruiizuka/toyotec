DROP TABLE IF EXISTS gold.vbi021001;
CREATE TABLE gold.vbi021001 AS
SELECT t.cd_hansya ,
        t200m.kj_kaisyatn
        , t200m.cd_hanbaitn
        , t.cd_kaisya
        , t.CD_OKYAKU
        , t.KB_SINCYU
        , t.NO_SYADAI
        , t.MJ_KATASIKI
        , t.MJ_SYAMEI
        , t006m.CD_STAFFTEN
        , t201m.kj_tenpomei
        , t000m.KJ_OKYAKUM1
FROM ai21rep_ve_dx.tbtec05g t
LEFT JOIN ai21rep_ve_dx.tbaz006m t006m
    ON t006m.cd_hansya = t.cd_hansya
    AND t006m.cd_kaisya = t.cd_kaisya
    AND t006m.CD_OKYAKU = t.CD_OKYAKU
LEFT JOIN ai21rep_ve_dx.tbv0200m t200m
    ON t200m.cd_hansya = t.cd_hansya
    AND t200m.cd_kaisya = t.cd_kaisya
LEFT JOIN ai21rep_ve_dx.tbv0201m t201m
    ON t201m.cd_hansya = t.cd_hansya
    AND t201m.cd_kaisya = t.cd_kaisya
    AND t201m.cd_tenpo = t006m.CD_STAFFTEN
LEFT JOIN ai21rep_ve_dx.tbaz000m t000m
    ON t000m.cd_hansya = t.cd_hansya
    AND t000m.cd_kaisya = t.cd_kaisya
    AND t000m.CD_OKYAKU = t.CD_OKYAKU
WHERE (lOWER(t.MJ_KATASIKI) LIKE '%xeam10%' OR lOWER(t.MJ_KATASIKI) LIKE '%yeam15%')
AND t006m.KB_TANTOBUN = '1'
AND t.KB_SYAMASSY  <> '1'
;
