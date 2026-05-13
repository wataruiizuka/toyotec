DROP TABLE IF EXISTS gold.vbi001002;
CREATE TABLE gold.vbi001002 AS
SELECT
    cd_hansya
    , cd_kaisya
    , cd_tenpo
    , cd_ncsyamei
    , kn_syame
    , CAST(to_date(dd_date) AS DATE) AS dd_date
    , NULLIFZERO(SUM(su_sinsya_hanbai)) AS su_sinsya_hanbai
    , NULLIFZERO(SUM(su_sinsya_torikesi)) AS su_sinsya_hanbai_torikesi
    , NULLIFZERO(SUM(su_sinsya_hanbai) - SUM(su_sinsya_torikesi)) AS su_sinsya_hanbai_goukei
FROM (
    SELECT
        tg.cd_hansya
        , tg.cd_kaisya
        , tg.cd_tenpo
        , tbbf001m.cd_ncsyamei
        , UPPER(NVL(tbbf001m.kn_syame, '')) AS kn_syame
        , (CASE
            WHEN ft168g.dd_torokei IS NULL THEN tg.dd_uriagekj
            ELSE ft168g.dd_torokei
         END) AS dd_date,
        COUNT(*) AS su_sinsya_hanbai
        , 0 AS su_sinsya_torikesi
    FROM ai21rep_ve_dx.tbba001g tg
    LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m
        ON tg.cd_kaisya = tbbf008m.cd_kaisya
        AND tg.cd_hansya = tbbf008m.cd_hansya
        AND tg.mj_sinkysed = tbbf008m.mj_sinkysed
        AND tg.mj_gaihansy = tbbf008m.cd_spec
        AND tg.mj_hantenkt = tbbf008m.mj_hantenkt
        AND tbbf008m.kb_spec = 'G'
    LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m
        ON tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
        AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
        AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
    LEFT JOIN (
        SELECT
            t168g.cd_hansya
            , t168g.cd_kaisya
            , t168g.no_cyumon
            , MIN(t168g.dd_torokei) AS dd_torokei
        FROM ai21rep_ve_dx.tbbg168g t168g
        WHERE
            t168g.no_gyomu = '07'
            AND t168g.no_syori = '01'
        GROUP BY
            t168g.cd_hansya,
            t168g.cd_kaisya,
            t168g.no_cyumon
    ) ft168g
        ON ft168g.cd_kaisya = tg.cd_kaisya
        AND ft168g.cd_hansya = tg.cd_hansya
        AND ft168g.no_cyumon = tg.no_cyumon
    WHERE
        tg.kb_haraidas NOT IN ('00', '40')
        AND tg.dd_jucyuke IS NOT NULL
        AND (
            (
            ft168g.dd_torokei IS NULL
                AND from_timestamp(tg.dd_uriagekj, 'yyyyMM') >= from_timestamp(add_months(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM')
            )
            OR (
            ft168g.dd_torokei IS NOT NULL
                AND from_timestamp(ft168g.dd_torokei, 'yyyyMM') >= from_timestamp(add_months(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM')
            )
        )
    GROUP BY
        tg.cd_hansya,
        tg.cd_kaisya,
        tg.cd_tenpo,
        dd_date,
        tbbf001m.cd_ncsyamei,
        NVL(tbbf001m.kn_syame, '')
    UNION ALL
    SELECT
        tg.cd_hansya
        , tg.cd_kaisya
        , tg.cd_tenpo
        , tbbf001m.cd_ncsyamei
        , UPPER(NVL(tbbf001m.kn_syame, '')) AS kn_syame
        , tg.dd_uritrkkj AS dd_date
        , 0 AS su_sinsya_hanbai
        , COUNT(*) AS su_sinsya_torikesi
    FROM ai21rep_ve_dx.tbba001g tg
    LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m
        ON tg.cd_kaisya = tbbf008m.cd_kaisya
        AND tg.cd_hansya = tbbf008m.cd_hansya
        AND tg.mj_sinkysed = tbbf008m.mj_sinkysed
        AND tg.mj_gaihansy = tbbf008m.cd_spec
        AND tg.mj_hantenkt = tbbf008m.mj_hantenkt
        AND tbbf008m.kb_spec = 'G'
    LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m
        ON tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
        AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
        AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
    WHERE
        tg.kb_haraidas NOT IN ('00', '40')
        AND tg.dd_jucyuke IS NOT NULL
        AND from_timestamp(tg.dd_uritrkkj, 'yyyyMM') >= from_timestamp(add_months(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM')
    GROUP BY
        tg.cd_hansya,
        tg.cd_kaisya,
        tg.cd_tenpo,
        tbbf001m.cd_ncsyamei,
        NVL(tbbf001m.kn_syame, ''),
        tg.dd_uritrkkj
) combined
GROUP BY
    cd_hansya,
    cd_kaisya,
    cd_tenpo,
    to_date(dd_date),
    cd_ncsyamei,
    kn_syame
;
