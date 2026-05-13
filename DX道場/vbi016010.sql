DROP TABLE IF EXISTS gold.vbi016010;
CREATE TABLE gold.vbi016010 AS
SELECT
    t201m.cd_hansya AS `販社コード`
    , t201m.cd_kaisya AS `会社コード`
    , t201m.cd_tenpo AS `店舗コード`
    , tbv0033m.cd_zon AS `ゾーンコード`
    , t201m.kj_tentanms AS `エリア店舗`
    , '店舗略称' AS `区分名称`
FROM  ai21rep_ve_dx.tbv0201m t201m
LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m
    ON t201m.cd_hansya = tbi999003m.cd_hansya
    AND t201m.cd_kaisya = tbi999003m.cd_kaisya
    AND t201m.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '016'
    AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbv0047m  tbv0047m
    ON tbv0047m.cd_hansya = t201m.cd_hansya
    AND tbv0047m.cd_kaisya = t201m.cd_kaisya
    AND tbv0047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m tbv0033m
    ON tbv0033m.cd_hansya = t201m.cd_hansya
    AND tbv0033m.cd_kaisya = t201m.cd_kaisya
    AND tbv0033m.cd_zon = tbv0047m.cd_nczon
    AND tbv0033m.kb_syohin  = '1'
UNION ALL
SELECT
    t201m.cd_hansya AS `販社コード`
    , t201m.cd_kaisya AS `会社コード`
    , t201m.cd_tenpo AS `店舗コード`
    , tbv0033m.cd_zon AS `ゾーンコード`
    , tbv0033m.kj_zonmei AS `エリア統括部と店舗`
    , 'ゾーン名称' AS `区分名称`
FROM  ai21rep_ve_dx.tbv0201m t201m
LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m
    ON t201m.cd_hansya = tbi999003m.cd_hansya
    AND t201m.cd_kaisya = tbi999003m.cd_kaisya
    AND t201m.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '016'
    AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbv0047m  tbv0047m
    ON tbv0047m.cd_hansya = t201m.cd_hansya
    AND tbv0047m.cd_kaisya = t201m.cd_kaisya
    AND tbv0047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m tbv0033m
    ON tbv0033m.cd_hansya = t201m.cd_hansya
    AND tbv0033m.cd_kaisya = t201m.cd_kaisya
    AND tbv0033m.cd_zon = tbv0047m.cd_nczon
    AND tbv0033m.kb_syohin  = '1'
;
