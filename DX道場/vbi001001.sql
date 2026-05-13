DROP TABLE IF EXISTS gold.vbi001001;
CREATE TABLE gold.vbi001001 AS
SELECT
    cd_hansya
    , cd_kaisya
    , cd_tenpo
    , CAST(to_date(dd_date) AS DATE) AS dd_date
    , cd_ncsyamei
    , kn_syame
    , NULLIFZERO(SUM(su_sinsya_jucyu)) AS su_sinsya_jucyu
    , NULLIFZERO(SUM(su_sinsya_jucyu_torikesi)) AS su_sinsya_jucyu_torikesi
    , NULLIFZERO(SUM(su_sinsya_jucyu) - SUM(su_sinsya_jucyu_torikesi)) AS su_sinsya_jucyu_goukei
    , NULLIFZERO(SUM(su_sinsya_jucyucan)) AS su_sinsya_jucyucan
FROM
    (
    SELECT
        tg.cd_hansya
        , tg.cd_kaisya
        , tg.cd_tenpo
        , tg.dd_jucyuke AS dd_date
        , tbbf001m.cd_ncsyamei
        , UPPER(NVL(tbbf001m.kn_syame, '')) AS kn_syame
        , CASE
            WHEN tg.dd_jucyuke IS NOT NULL THEN 1
            ELSE 0
        END AS su_sinsya_jucyu
        , 0 AS su_sinsya_jucyu_torikesi
        , CASE
            WHEN tg.dd_jucyuke IS NOT NULL
            AND tg.dd_touroku IS NULL THEN 1
            ELSE 0
        END AS su_sinsya_jucyucan
    FROM
        ai21rep_ve_dx.tbba001g tg
    LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m
        ON
        tg.cd_kaisya = tbbf008m.cd_kaisya
        AND tg.cd_hansya = tbbf008m.cd_hansya
        AND tg.mj_sinkysed = tbbf008m.mj_sinkysed
        AND tg.mj_gaihansy = tbbf008m.cd_spec
        AND tg.mj_hantenkt = tbbf008m.mj_hantenkt
        AND tbbf008m.kb_spec = 'G'
    LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m
        ON
        tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
        AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
        AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
    WHERE
        tg.kb_haraidas NOT IN ('00', '40')
        AND tg.dd_jucyuke IS NOT NULL
        AND from_timestamp(tg.dd_jucyuke, 'yyyyMM') >= from_timestamp(
            add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1),
            'yyyyMM'
        )
UNION ALL
    SELECT
        tg.cd_hansya
        , tg.cd_kaisya
        , tg.cd_tenpo
        , tg.dd_torikesi AS dd_date
        , tbbf001m.cd_ncsyamei
        , UPPER(NVL(tbbf001m.kn_syame, '')) AS kn_syame
        , 0 AS su_sinsya_jucyu
        , CASE
            WHEN tg.dd_torikesi IS NOT NULL THEN 1
            ELSE 0
        END AS su_sinsya_jucyu_torikesi
        , 0 AS su_sinsya_jucyucan
    FROM
        ai21rep_ve_dx.tbba001g tg
    LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m
        ON
        tg.cd_kaisya = tbbf008m.cd_kaisya
        AND tg.cd_hansya = tbbf008m.cd_hansya
        AND tg.mj_sinkysed = tbbf008m.mj_sinkysed
        AND tg.mj_gaihansy = tbbf008m.cd_spec
        AND tg.mj_hantenkt = tbbf008m.mj_hantenkt
        AND tbbf008m.kb_spec = 'G'
    LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m
        ON
        tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
        AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
        AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
    WHERE
        tg.kb_haraidas NOT IN ('00', '40')
        AND tg.dd_torikesi IS NOT NULL
        AND from_timestamp(tg.dd_torikesi, 'yyyyMM') >= from_timestamp(
            add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1),
            'yyyyMM'
        )
) combined
GROUP BY
    cd_hansya,
    cd_kaisya,
    cd_tenpo,
    to_date(dd_date),
    cd_ncsyamei,
    kn_syame
;
