DROP TABLE IF EXISTS gold.vbi011002;
CREATE TABLE gold.vbi011002 AS
SELECT
    t0201m.cd_hansya
    , t0201m.cd_kaisya
    , t0201m.cd_tenpo
    , t0201m.kj_tenpomei
     , IF(
        t0033m.kj_zonmei IS NULL OR regexp_replace(t0033m.kj_zonmei, '[ 　]+', '') = '',
        '999999',
        IF(
            t0033m.cd_zon IS NULL OR regexp_replace(t0033m.cd_zon, '[ 　]+', '') = '',
            '999998',
            t0033m.cd_zon
        )
    ) AS cd_zon
    , t0033m.kj_zonmei
    , t9003m.mj_sortjyun
FROM
    ai21rep_ve_dx.tbv0201m t0201m
LEFT JOIN ai21rep_ve_dx.tbv0047m t0047m
    ON t0047m.cd_hansya = t0201m.cd_hansya
    AND t0047m.cd_kaisya = t0201m.cd_kaisya
    AND t0047m.cd_tenpo = t0201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m t0033m
    ON t0033m.cd_hansya = t0047m.cd_hansya
    AND t0033m.cd_kaisya = t0047m.cd_kaisya
    AND t0033m.cd_zon = t0047m.CD_NCZON
    AND t0033m.kb_syohin = '3'
INNER JOIN dx_ve.tbi999003m t9003m
    ON t9003m.cd_hansya = t0201m.cd_hansya
    AND t9003m.cd_kaisya = t0201m.cd_kaisya
    AND t9003m.cd_tenpo = t0201m.cd_tenpo
    AND t9003m.mj_cyohyoid = '011'
    AND t9003m.kb_tenji = 1
;
