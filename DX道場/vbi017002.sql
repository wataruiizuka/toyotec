DROP TABLE IF EXISTS gold.vbi017002;
CREATE TABLE gold.vbi017002 AS
SELECT
    cd_hansya
    , cd_kaisya
    , cd_tenpo
    , kj_tenpomei
    , cd_hanstaff
    , kj_syainmei
    , month
    , SUM(su_hanbai) AS 'su_hanbai'
    , SUM(su_hanbai) - SUM(su_hanbaicancel) AS 'su_hanbaicancelhane'
    , SUM(su_hanbaijyokei) AS 'su_hanbaijyokei'
    , SUM(su_hanbaijyokei) - SUM(su_hanbaicanceljyokei) AS 'su_hanbaicanceljyokeihene'
FROM
(
    SELECT
        t001g.cd_hansya
        , t001g.cd_kaisya
        , t001g.cd_tenpo
        , regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei'
        , t001g.cd_hanstaff
        , regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei'
        , IF(IF(ft168g.dd_torokei IS NULL, t001g.dd_uriagekj, ft168g.dd_torokei) >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month'
        , 1 AS 'su_hanbai'
        , 0 AS 'su_hanbaicancel'
        , IF(t001m.kn_kei <> '1',1,0) AS 'su_hanbaijyokei'
        , 0 AS 'su_hanbaicanceljyokei'
    FROM
    ai21rep_ve_dx.tbba001g t001g
    LEFT JOIN
        ON (
            SELECT
                t168g.cd_hansya
                , t168g.cd_kaisya
                , t168g.no_cyumon
                , t168g.no_cyumoned
                , min(t168g.dd_torokei) AS dd_torokei
            FROM ai21rep_ve_dx.tbbg168g t168g
            WHERE
                t168g.no_gyomu = '07'
            AND t168g.no_syori = '01'
            GROUP BY t168g.cd_hansya,t168g.cd_kaisya, t168g.no_cyumon, t168g.no_cyumoned
        ) ft168g
        ON ft168g.cd_kaisya = t001g.cd_kaisya
        AND ft168g.cd_hansya = t001g.cd_hansya
        AND ft168g.no_cyumon = t001g.no_cyumon
        AND TRIM(ft168g.no_cyumoned) = TRIM(t001g.no_cyumoned)
    LEFT JOIN ai21rep_ve_dx.tbbf008m t008m
        ON t001g.cd_kaisya = t008m.cd_kaisya
        AND t001g.cd_hansya = t008m.cd_hansya
        AND t001g.mj_sinkysed = t008m.mj_sinkysed
        AND t001g.mj_gaihansy = t008m.cd_spec
        AND t001g.mj_hantenkt  = t008m.mj_hantenkt
        AND t008m.kb_spec = 'G'
    LEFT JOIN ai21rep_ve_dx.tbbf001m t001m
        ON t001m.cd_kaisya = t008m.cd_kaisya
        AND t001m.cd_hansya = t008m.cd_hansya
        AND t001m.cd_ncsyamei = t008m.mj_syamei
    LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
        ON t014m.cd_kaisya = t001g.cd_kaisya
        AND t014m.cd_hansya = t001g.cd_hansya
        AND t014m.cd_syain = t001g.cd_hanstaff
    LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
        ON t0201m.cd_kaisya = t001g.cd_kaisya
        AND t0201m.cd_hansya = t001g.cd_hansya
        AND t0201m.cd_tenpo = t001g.cd_tenpo
    LEFT SEMI JOIN dx_ve.tbi999003m
        ON tbi999003m.cd_kaisya = t001g.cd_kaisya
        AND tbi999003m.cd_hansya = t001g.cd_hansya
        AND tbi999003m.cd_tenpo = t001g.cd_tenpo
        AND tbi999003m.mj_cyohyoid = '017'
        AND tbi999003m.kb_tenji = 1
    WHERE
        t001g.kb_haraidas NOT IN ('00', '40')
        AND t001g.dd_jucyuke IS NOT NULL
        AND (
            (ft168g.dd_torokei >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM'))
            OR
            (ft168g.dd_torokei IS NULL AND t001g.dd_uriagekj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM'))
        )
    UNION ALL
    SELECT
        t001g.cd_hansya
        , t001g.cd_kaisya
        , t001g.cd_tenpo
        , regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei'
        , t001g.cd_hanstaff
        , regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei'
        , IF(t001g.dd_uritrkkj >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month'
        , 0 AS 'su_hanbai'
        , 1 AS 'su_hanbaicancel'
        , 0 AS 'su_hanbaijyokei'
        , IF(t001m.kn_kei <> '1',1,0) AS 'su_hanbaicanceljyokei'
    FROM
    ai21rep_ve_dx.tbba001g t001g
    LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
        ON t014m.cd_kaisya = t001g.cd_kaisya
        AND t014m.cd_hansya = t001g.cd_hansya
        AND t014m.cd_syain = t001g.cd_hanstaff
    LEFT JOIN ai21rep_ve_dx.tbbf008m t008m
        ON t001g.cd_kaisya = t008m.cd_kaisya
        AND t001g.cd_hansya = t008m.cd_hansya
        AND t001g.mj_sinkysed = t008m.mj_sinkysed
        AND t001g.mj_gaihansy = t008m.cd_spec
        AND t001g.mj_hantenkt  = t008m.mj_hantenkt
        AND t008m.kb_spec = 'G'
    LEFT JOIN ai21rep_ve_dx.tbbf001m t001m
        ON t001m.cd_kaisya = t008m.cd_kaisya
        AND t001m.cd_hansya = t008m.cd_hansya
        AND t001m.cd_ncsyamei = t008m.mj_syamei
    LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
        ON t0201m.cd_kaisya = t001g.cd_kaisya
        AND t0201m.cd_hansya = t001g.cd_hansya
        AND t0201m.cd_tenpo = t001g.cd_tenpo
    LEFT SEMI JOIN dx_ve.tbi999003m
        ON tbi999003m.cd_kaisya = t001g.cd_kaisya
        AND tbi999003m.cd_hansya = t001g.cd_hansya
        AND tbi999003m.cd_tenpo = t001g.cd_tenpo
        AND tbi999003m.mj_cyohyoid = '017'
        AND tbi999003m.kb_tenji = 1
    WHERE
        t001g.kb_haraidas NOT IN ('00', '40')
        AND t001g.dd_jucyuke IS NOT NULL
        AND t001g.dd_uritrkkj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
)combined
GROUP BY
    cd_hansya,
    cd_kaisya,
    cd_tenpo,
    kj_tenpomei,
    cd_hanstaff,
    kj_syainmei,
    month
;
