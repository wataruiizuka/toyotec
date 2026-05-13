DROP TABLE IF EXISTS gold.vbi003002;
CREATE TABLE gold.vbi003002 AS
SELECT
    dense_rank() OVER(PARTITION BY t3002m.cd_hansya, t3002m.cd_kaisya ORDER BY  IF(
                t033m.kj_zonmei IS NULL OR regexp_replace(t033m.kj_zonmei, '[ 　]+', '') = '',
                '999999',
                IF(
                    t033m.cd_zon IS NULL OR regexp_replace(t033m.cd_zon, '[ 　]+', '') = '',
                    '999998',
                    t033m.cd_zon
                )
            ), t9003m.mj_sortjyun, t3002m.cd_tenpo) AS mj_sortjyun
    , t3002m.cd_hansya
    , t3002m.cd_kaisya
    , t3002m.cd_tenpo
    , regexp_replace(t201m.kj_tenpomei, '　+$', '') AS kj_tenpomei
    , IF(
        t033m.kj_zonmei IS NULL OR regexp_replace(t033m.kj_zonmei, '[ 　]+', '') = '',
        '999999',
        IF(
            t033m.cd_zon IS NULL OR regexp_replace(t033m.cd_zon, '[ 　]+', '') = '',
            '999998',
            t033m.cd_zon
        )
    ) AS cd_zon,
    regexp_replace(t033m.kj_zonmei, '　+$', '') AS kj_zonmei
    , t3002m.no_stall
    , t3002m.mj_stallmei
    , t3002m.kb_shuukeitaishou
    , concat(t3002m.cd_hansya, t3002m.cd_kaisya, t3002m.cd_tenpo, cast(t3002m.no_stall AS string)) AS cd_hansyakaisyatenpostall
    , concat(cast(t3002m.no_stall AS string), '　', t3002m.mj_stallmei) AS kb_stallsentaku
    , t3001m.tm_kaiten
    , unix_timestamp(concat('1970-01-01 ', t3001m.tm_kaiten)) AS tm_shukkinsecond
    , t3001m.tm_heiten
    , unix_timestamp(concat('1970-01-01 ', t3001m.tm_heiten)) AS tm_taikinsecond
    , from_timestamp(hours_add(concat('1970-01-01 ', t3001m.tm_heiten), 2), 'HH:mm:ss') AS tm_zangyo
    , 1440 / 12 AS kb_teigaikitei
    , (unix_timestamp(concat('1970-01-01 ', t3001m.tm_heiten)) - unix_timestamp(concat('1970-01-01 ', t3001m.tm_kaiten))) / 60 - 60 AS kb_teinaikitei
    , concat(t3002m.cd_hansya, t3002m.cd_kaisya, t3002m.cd_tenpo) AS cd_hansyakaisyatenpo
FROM dx_ve.tbi003002m t3002m
INNER JOIN dx_ve.tbi999003m t9003m
    ON t9003m.cd_hansya = t3002m.cd_hansya
    AND t9003m.cd_kaisya = t3002m.cd_kaisya
    AND t9003m.cd_tenpo = t3002m.cd_tenpo
    AND t9003m.mj_cyohyoid = '003'
    AND t9003m.kb_tenji = 1
INNER JOIN dx_ve.tbi003001m t3001m
    ON t3001m.cd_hansya = t3002m.cd_hansya
    AND t3001m.cd_kaisya = t3002m.cd_kaisya
    AND t3001m.cd_tenpo = t3002m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0201m t201m
    ON t201m.cd_hansya = t3002m.cd_hansya
    AND t201m.cd_kaisya = t3002m.cd_kaisya
    AND t201m.cd_tenpo = t3002m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0202m t202m
    ON t202m.cd_hansya = t201m.cd_hansya
    AND t202m.cd_kaisya = t201m.cd_kaisya
    AND t202m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m t033m
    ON t033m.cd_hansya = t202m.cd_hansya
    AND t033m.cd_kaisya = t202m.cd_kaisya
    AND t033m.cd_zon = t202m.cd_zon
    AND t033m.kb_syohin  = '3'
WHERE t3002m.kb_shuukeitaishou = '1'
AND instr(t3002m.mj_stallmei, 'コント') = 0
AND instr(t3002m.mj_stallmei, '外注') = 0
;
