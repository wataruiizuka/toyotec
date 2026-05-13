DROP TABLE IF EXISTS gold.vbi019002;
CREATE TABLE gold.vbi019002 AS
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
        t.cd_hansya
        , t.cd_kaisya
        , t.cd_jytyuten AS 'cd_tenpo'
        , regexp_replace(t0201m.kj_tenpomei, '　+$', '') AS 'kj_tenpomei'
        , t.cd_hanstaff
        , regexp_replace(t014m.kj_syainmei, '　+$', '') AS 'kj_syainmei'
        , IF(
            IF(t.dd_uriage IS NULL, CAST(t.dd_uriagekj AS DATE), CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(t.dd_uriage AS STRING), 'yyyyMMdd')) AS DATE))
            >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM')
            ,'当月','前月'
        ) AS 'month',
        IF(
            (t.dd_uriage IS NOT NULL AND CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(t.dd_uriage AS STRING), 'yyyyMMdd')) AS DATE) >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM'))
            OR
            (t.dd_uriage IS NULL AND t.dd_uriagekj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM'))
            ,1 ,0
        ) AS 'su_hanbai',
        0 AS 'su_hanbaicancel'
        , IF(
            t001g.kn_kei <> '1'
            AND
            (
                t.dd_uriage IS NOT NULL AND CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(t.dd_uriage AS STRING), 'yyyyMMdd')) AS DATE) >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
                OR
                t.dd_uriage IS NULL AND t.dd_uriagekj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
            )
            ,1 ,0
        ) AS 'su_hanbaijyokei',
        0 AS 'su_hanbaicanceljyokei'
    FROM
    (
        SELECT t040g.cd_hansya,t040g.cd_kaisya,t040g.no_cyumon,t040g.no_cyumoned,t040g.cd_jytyuten,t040g.cd_hanstaff,t040g.dd_torikesi,t040g.dd_uriagekj,t040g.no_syaryou,ft8006.dd_uriage
        FROM ai21rep_ve_dx.tbbc040g t040g
        LEFT JOIN
            ON (
            SELECT
                t8006.cd_hansya
                , t8006.cd_kaisya
                , t8006.no_cyumon
                , MIN(t8006.dd_uriage) AS dd_uriage
            FROM
                ai21rep_ve_dx.tbg8006m t8006
            GROUP BY
                t8006.cd_hansya,
                t8006.cd_kaisya,
                t8006.no_cyumon
        )ft8006
        ON t040g.cd_kaisya = ft8006.cd_kaisya
        AND t040g.cd_kaisya = ft8006.cd_kaisya
        AND t040g.no_cyumon = ft8006.no_cyumon
        WHERE t040g.kb_uriage = '1A'
            AND t040g.dd_uriagekj IS NOT NULL
            AND t040g.dd_torikesi IS NULL
            AND (
                t040g.dd_uriagekj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
                OR
                CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(ft8006.dd_uriage AS STRING), 'yyyyMMdd')) AS DATE) >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
            )
        UNION ALL
        SELECT t017g.cd_hansya,t017g.cd_kaisya,t017g.no_cyumon,t017g.no_cyumoned,t017g.cd_jytyuten,t017g.cd_hanstaff,t017g.dd_torikesi,t017g.dd_uriagekj,t017g.no_syaryou,ft8006.dd_uriage
        FROM ai21rep_ve_dx.tbbc017g t017g
        LEFT JOIN
            ON (
            SELECT
                t8006.cd_hansya
                , t8006.cd_kaisya
                , t8006.no_cyumon
                , MIN(t8006.dd_uriage) AS dd_uriage
            FROM
                ai21rep_ve_dx.tbg8006m t8006
            GROUP BY
                t8006.cd_hansya,
                t8006.cd_kaisya,
                t8006.no_cyumon
        )ft8006
        ON t017g.cd_kaisya = ft8006.cd_kaisya
        AND t017g.cd_kaisya = ft8006.cd_kaisya
        AND t017g.no_cyumon = ft8006.no_cyumon
        WHERE t017g.kb_uriage = '1A'
            AND t017g.dd_uriagekj IS NOT NULL
            AND t017g.dd_torikesi IS NULL
            AND (
                t017g.dd_uriagekj >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
                OR
                CAST(FROM_UNIXTIME(UNIX_TIMESTAMP(CAST(ft8006.dd_uriage AS STRING), 'yyyyMMdd')) AS DATE) >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
            )
    )t
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
        , IF(t.dd_uritorik >= trunc(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'MM'),'当月','前月') AS 'month'
        , 0 AS 'su_hanbai'
        , 1 AS 'su_hanbaicancel'
        , 0 AS 'su_hanbaijyokei'
        , IF(t001g.kn_kei <> '1',1,0) AS 'su_hanbaicanceljyokei'
    FROM
    (
        SELECT t040g.cd_hansya,t040g.cd_kaisya,t040g.no_cyumon,t040g.no_cyumoned,t040g.cd_jytyuten,t040g.cd_hanstaff,t040g.dd_jucyuke,t040g.dd_uritorik,t040g.no_syaryou,t040g.kb_uriage
        FROM ai21rep_ve_dx.tbbc040g t040g
        WHERE t040g.kb_uriage = '1A' AND t040g.dd_jucyuke IS NOT NULL
        AND t040g.dd_uritorik >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
        UNION ALL
        SELECT t017g.cd_hansya,t017g.cd_kaisya,t017g.no_cyumon,t017g.no_cyumoned,t017g.cd_jytyuten,t017g.cd_hanstaff,t017g.dd_jucyuke,t017g.dd_uritorik,t017g.no_syaryou,t017g.kb_uriage
        FROM ai21rep_ve_dx.tbbc017g t017g
        WHERE t017g.kb_uriage = '1A' AND t017g.dd_jucyuke IS NOT NULL
        AND t017g.dd_uritorik >= trunc(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'MM')
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
