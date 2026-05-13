DROP TABLE IF EXISTS gold.vbi017001;
CREATE TABLE gold.vbi017001 AS
SELECT
    cd_hansya
    , cd_kaisya
    , cd_tenpo
    , kj_tenpomei
    , cd_hanstaff
    , kj_syainmei
    , month
    , SUM(su_jucyu) AS 'su_jucyu'
    , SUM(su_jucyu) - SUM(su_jucyucancel) AS 'su_jucyucancelhane'
    , SUM(su_jucyujyokei) AS 'su_jucyujyokei'
    , SUM(su_jucyujyokei) - SUM(su_jucyucanceljyokei) AS 'su_jucyucanceljyokeihane'
    , SUM(su_kap) AS 'su_kap'
    , SUM(su_maintenancepack) AS 'su_maintenancepack'
    , SUM(su_sitadori) AS 'su_sitadori'
FROM
(
    SELECT
        t001g.cd_hansya
        , t001g.cd_kaisya
        , t001g.cd_tenpo
        , regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei'
        , t001g.cd_hanstaff
        , regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei'
        , IF(t001g.dd_jucyuke >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month'
        , 1 AS 'su_jucyu'
        , 0 AS 'su_jucyucancel'
        , IF(t001m.kn_kei <> '1',1,0) AS 'su_jucyujyokei'
        , 0 AS 'su_jucyucanceljyokei'
        , IF(t052g.kb_siharai = '2',1 ,0) AS 'su_kap'
        , IF(t052g.kb_mntpkkei IS NOT NULL
            AND REPLACE(REPLACE(t052g.kb_mntpkkei, '　', ''), ' ', '') != '',1 ,0) AS 'su_maintenancepack',
        IF(t052g.su_sitadori > 0, 1, 0) AS 'su_sitadori'
    FROM ai21rep_ve_dx.tbba001g t001g
    LEFT JOIN ai21rep_ve_dx.tbba052g t052g
        ON t052g.cd_kaisya = t001g.cd_kaisya
        AND t052g.cd_hansya = t001g.cd_hansya
        AND t052g.no_cyumon = t001g.no_cyumon
        AND TRIM(t052g.no_cyumoned) = TRIM(t001g.no_cyumoned)
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
        AND
        t001g.dd_jucyuke >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
    UNION ALL
    SELECT
        t001g.cd_hansya
        , t001g.cd_kaisya
        , t001g.cd_tenpo
        , regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei'
        , t001g.cd_hanstaff
        , regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei'
        , IF(t001g.dd_torikesi >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month'
        , 0 AS 'su_jucyu'
        , 1 AS 'su_jucyucancel'
        , 0 AS 'su_jucyujyokei'
        , IF(t001m.kn_kei <> '1',1,0) AS 'su_jucyucanceljyokei'
        , 0 AS 'su_kap'
        , 0 AS 'su_maintenancepack'
        , 0 AS 'su_sitadori'
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
        AND t001g.dd_torikesi >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
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
