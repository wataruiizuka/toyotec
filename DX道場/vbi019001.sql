DROP TABLE IF EXISTS gold.vbi019001;
CREATE TABLE gold.vbi019001 AS
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
FROM
(
    SELECT
        t.cd_hansya
        , t.cd_kaisya
        , t.cd_jytyuten AS 'cd_tenpo'
        , regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei'
        , t.cd_hanstaff
        , regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei'
        , IF(t.dd_jucyuke >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month'
        , 1 AS 'su_jucyu'
        , 0 AS 'su_jucyucancel'
        , IF(t001g.kn_kei <> '1',1,0) AS 'su_jucyujyokei'
        , 0 AS 'su_jucyucanceljyokei'
        , IF(t020g.kb_siharai = '2',1 ,0) AS 'su_kap'
        , IF(
            t020g.kb_mntpkkei IS NOT NULL
            AND REPLACE(REPLACE(t020g.kb_mntpkkei, '　', ''), ' ', '') != '',
            1 ,0
        ) AS 'su_maintenancepack'
    FROM
    (
        SELECT cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,cd_jytyuten,cd_hanstaff,dd_jucyuke,no_syaryou FROM ai21rep_ve_dx.tbbc040g tbbc040g
        WHERE tbbc040g.dd_jucyuke >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
        UNION ALL
        SELECT cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,cd_jytyuten,cd_hanstaff,dd_jucyuke,no_syaryou FROM ai21rep_ve_dx.tbbc017g tbbc017g
        WHERE tbbc017g.dd_jucyuke >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
    ) t
    LEFT JOIN ai21rep_ve_dx.tbbc020g t020g
        ON t.cd_kaisya = t020g.cd_kaisya
        AND t.cd_hansya = t020g.cd_hansya
        AND t.no_cyumon = t020g.no_cyumon
        AND TRIM(t.no_cyumoned) = TRIM(t020g.no_cyumoned)
    LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
        ON t014m.cd_kaisya = t.cd_kaisya
        AND t014m.cd_hansya = t.cd_hansya
        AND t014m.cd_syain = t.cd_hanstaff
    LEFT JOIN ai21rep_ve_dx.tbbc001g t001g
        ON t001g.cd_kaisya = t.cd_kaisya
        AND t001g.cd_hansya = t.cd_hansya
        AND t001g.no_syaryou = t.no_syaryou
    LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
        ON t0201m.cd_kaisya = t.cd_kaisya
        AND t0201m.cd_hansya = t.cd_hansya
        AND t0201m.cd_tenpo = t.cd_jytyuten
    LEFT SEMI JOIN dx_ve.tbi999003m
        ON tbi999003m.cd_kaisya = t.cd_kaisya
        AND tbi999003m.cd_hansya = t.cd_hansya
        AND tbi999003m.cd_tenpo = t.cd_jytyuten
        AND tbi999003m.mj_cyohyoid = '019'
        AND tbi999003m.kb_tenji = 1
    UNION ALL
    SELECT
        t.cd_hansya
        , t.cd_kaisya
        , t.cd_jytyuten AS 'cd_tenpo'
        , regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei'
        , t.cd_hanstaff
        , regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei'
        , IF(t.dd_torikesi >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month'
        , 0 AS 'su_jucyu'
        , 1 AS 'su_jucyucancel'
        , 0 AS 'su_jucyujyokei'
        , IF(t001g.kn_kei <> '1',1,0) AS 'su_jucyucanceljyokei'
        , 0 AS 'su_kap'
        , 0 AS 'su_maintenancepack'
    FROM
    (
        SELECT cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,cd_jytyuten,cd_hanstaff,dd_jucyuke,dd_torikesi,no_syaryou
        FROM ai21rep_ve_dx.tbbc040g
        WHERE tbbc040g.dd_torikesi >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM') AND tbbc040g.dd_jucyuke IS NOT NULL
        UNION ALL
        SELECT cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,cd_jytyuten,cd_hanstaff,dd_jucyuke,dd_torikesi,no_syaryou
        FROM ai21rep_ve_dx.tbbc017g
        WHERE tbbc017g.dd_torikesi >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM') AND tbbc017g.dd_jucyuke IS NOT NULL
    ) t
    LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
        ON t014m.cd_kaisya = t.cd_kaisya
        AND t014m.cd_hansya = t.cd_hansya
        AND t014m.cd_syain = t.cd_hanstaff
    LEFT JOIN ai21rep_ve_dx.tbbc001g t001g
        ON t001g.cd_kaisya = t.cd_kaisya
        AND t001g.cd_hansya = t.cd_hansya
        AND t001g.no_syaryou = t.no_syaryou
    LEFT JOIN ai21rep_ve_dx.tbv0201m t0201m
        ON t0201m.cd_kaisya = t.cd_kaisya
        AND t0201m.cd_hansya = t.cd_hansya
        AND t0201m.cd_tenpo = t.cd_jytyuten
    LEFT SEMI JOIN dx_ve.tbi999003m
        ON tbi999003m.cd_kaisya = t.cd_kaisya
        AND tbi999003m.cd_hansya = t.cd_hansya
        AND tbi999003m.cd_tenpo = t.cd_jytyuten
        AND tbi999003m.mj_cyohyoid = '019'
        AND tbi999003m.kb_tenji = 1
) t
GROUP BY
    cd_hansya,
    cd_kaisya,
    cd_tenpo,
    kj_tenpomei,
    cd_hanstaff,
    kj_syainmei,
    month
;
