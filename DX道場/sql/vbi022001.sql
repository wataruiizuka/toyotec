DROP TABLE IF EXISTS gold.vbi022001;
CREATE TABLE gold.vbi022001 AS
SELECT
    cd_hansya
    , cd_kaisya
    , cd_jytyuten AS cd_tenpo
    , CAST(to_date(dd_date) AS DATE) AS dd_date
    , cd_ncsyamei
    , kn_syame
    , NULLIFZERO(SUM(su_jusya_jucyu)) AS su_jusya_jucyu
    , NULLIFZERO(SUM(su_jusya_jucyu_torikesi)) AS su_jusya_jucyu_torikesi
    , NULLIFZERO(SUM(su_jusya_jucyu) - SUM(su_jusya_jucyu_torikesi)) AS su_jusya_jucyu_goukei
    , NULLIFZERO(SUM(su_jusya_jucyucan)) AS su_jusya_jucyucan
FROM
    (
    SELECT
        tg.cd_hansya
        , tg.cd_kaisya
        , tg.cd_jytyuten
        , CONCAT(NVL(tbbc001g.mj_21syamek, '')
               NVL(tbbc001g.mj_21syasyu, ''),
               NVL(tbbc001g.mj_21syamak, ''),
               NVL(tbbc001g.no_21syaren, ''),
               NVL(tbbc001g.mj_21syanin, '')) AS cd_ncsyamei,
        , UPPER(NVL(tbv0232m.mj_syamei, '')) AS kn_syame
        , tg.dd_jucyuke AS dd_date
        , CASE
            WHEN tg.dd_jucyuke IS NOT NULL THEN 1
            ELSE NULL
        END AS su_jusya_jucyu
        , 0 AS su_jusya_jucyu_torikesi
        , CASE
            WHEN tg.dd_jucyuke IS NOT NULL
            AND tg.dd_touroku IS NULL THEN 1
            ELSE NULL
        END AS su_jusya_jucyucan
    FROM
        ai21rep_ve_dx.tbbc017g tg
    LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g
        ON
        tbbc001g.cd_kaisya = tg.cd_kaisya
        AND tbbc001g.cd_hansya = tg.cd_hansya
        AND tbbc001g.no_syaryou = tg.no_syaryou
    LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m
        ON
        tbv0232m.cd_hansya = tbbc001g.cd_hansya
        AND tbv0232m.cd_kaisya = tbbc001g.cd_kaisya
        AND tbv0232m.cd_syamei = CONCAT(NVL(tbbc001g.mj_21syamek, ''),
                                        NVL(tbbc001g.mj_21syasyu, ''),
                                        NVL(tbbc001g.mj_21syamak, ''),
                                        NVL(tbbc001g.no_21syaren, ''),
                                        NVL(tbbc001g.mj_21syanin, ''))
    WHERE
        tg.dd_jucyuke IS NOT NULL
        AND from_timestamp(tg.dd_jucyuke, 'yyyyMM') >= from_timestamp(
            add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1),
            'yyyyMM'
        )
UNION ALL
    SELECT
        tg.cd_hansya
        , tg.cd_kaisya
        , tg.cd_jytyuten
        , CONCAT(NVL(tbbc001g.mj_21syamek, '')
               NVL(tbbc001g.mj_21syasyu, ''),
               NVL(tbbc001g.mj_21syamak, ''),
               NVL(tbbc001g.no_21syaren, ''),
               NVL(tbbc001g.mj_21syanin, '')) AS cd_ncsyamei,
        , UPPER(NVL(tbv0232m.mj_syamei, '')) AS kn_syame
        , tg.dd_torikesi AS dd_date
        , 0 AS su_jusya_jucyu
        , CASE
            WHEN tg.dd_torikesi IS NOT NULL THEN 1
            ELSE NULL
        END AS su_jusya_jucyu_torikesi
        , 0 AS su_jusya_jucyucan
    FROM
        ai21rep_ve_dx.tbbc017g tg
    LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g
        ON
        tbbc001g.cd_kaisya = tg.cd_kaisya
        AND tbbc001g.cd_hansya = tg.cd_hansya
        AND tbbc001g.no_syaryou = tg.no_syaryou
    LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m
        ON
        tbv0232m.cd_hansya = tbbc001g.cd_hansya
        AND tbv0232m.cd_kaisya = tbbc001g.cd_kaisya
        AND tbv0232m.cd_syamei = CONCAT(NVL(tbbc001g.mj_21syamek, ''),
                                        NVL(tbbc001g.mj_21syasyu, ''),
                                        NVL(tbbc001g.mj_21syamak, ''),
                                        NVL(tbbc001g.no_21syaren, ''),
                                        NVL(tbbc001g.mj_21syanin, ''))
    WHERE
        tg.dd_jucyuke IS NOT NULL
        AND from_timestamp(tg.dd_torikesi, 'yyyyMM') >= from_timestamp(
            add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1),
            'yyyyMM'
        )
) combined
GROUP BY
    cd_hansya,
    cd_kaisya,
    cd_jytyuten,
    to_date(dd_date),
    cd_ncsyamei,
    kn_syame
;