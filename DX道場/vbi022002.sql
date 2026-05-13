DROP TABLE IF EXISTS gold.vbi022002;
CREATE TABLE gold.vbi022002 AS
SELECT
    cd_hansya
    , cd_kaisya
    , cd_jytyuten AS cd_tenpo
    , cd_ncsyamei
    , kn_syame
    , CAST(TO_DATE(dd_date) AS DATE) AS dd_date
    , NULLIFZERO(SUM(su_jusya_hanbai)) AS su_jusya_hanbai
    , NULLIFZERO(SUM(su_jusya_hanbai_torikesi)) AS su_jusya_hanbai_torikesi
    , NULLIFZERO(SUM(su_jusya_hanbai) - SUM(su_jusya_hanbai_torikesi)) AS su_jusya_hanbai_goukei
    , NULLIFZERO(
        SUM(
            CASE
                WHEN FROM_TIMESTAMP(dd_date, 'yyyyMM') =
                     FROM_TIMESTAMP(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'yyyyMM')
                THEN su_jusya_hanbai - su_jusya_hanbai_torikesi
                ELSE 0
            END
        )
    ) AS su_jusya_hanbai_current
FROM
(
    SELECT
        tg.cd_hansya
        , tg.cd_kaisya
        , tg.cd_jytyuten
        , CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        ) AS cd_ncsyamei,
        UPPER(NVL(tbv0232m.mj_syamei, '')) AS kn_syame
        , CASE
            WHEN ft8006.dd_uriage IS NULL THEN tg.dd_uriagekj
            ELSE TO_TIMESTAMP(CAST(ft8006.dd_uriage AS STRING), 'yyyyMMdd')
        END AS dd_date
        , COUNT(*) AS su_jusya_hanbai
        , 0 AS su_jusya_hanbai_torikesi
    FROM ai21rep_ve_dx.tbbc017g tg
    LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g
        ON tbbc001g.cd_kaisya = tg.cd_kaisya
        AND tbbc001g.cd_hansya = tg.cd_hansya
        AND tbbc001g.no_syaryou = tg.no_syaryou
    LEFT JOIN
        ON (
        SELECT
            t8006.cd_hansya
            , t8006.cd_kaisya
            , t8006.no_cyumon
            , MIN(t8006.dd_uriage) AS dd_uriage
        FROM ai21rep_ve_dx.tbg8006m t8006
        GROUP BY
            t8006.cd_hansya,
            t8006.cd_kaisya,
            t8006.no_cyumon,
            t8006.dd_uriage
    ) ft8006
        ON tg.cd_kaisya = ft8006.cd_kaisya
        AND tg.cd_kaisya = ft8006.cd_kaisya
        AND tg.no_cyumon = ft8006.no_cyumon
        AND tg.dd_uritorik IS NULL
    LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m
        ON tbv0232m.cd_hansya = tbbc001g.cd_hansya
        AND tbv0232m.cd_kaisya = tbbc001g.cd_kaisya
        AND tbv0232m.cd_syamei = CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        )
    WHERE
        tg.dd_uriagekj IS NOT NULL
        AND tg.dd_torikesi IS NULL
        AND (
            (
            ft8006.dd_uriage IS NULL
                AND FROM_TIMESTAMP(tg.dd_uriagekj, 'yyyyMM') >=
                    FROM_TIMESTAMP(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM'))
            OR
            (
            ft8006.dd_uriage IS NOT NULL
                AND FROM_TIMESTAMP(TO_TIMESTAMP(CAST(ft8006.dd_uriage AS STRING), 'yyyyMMdd'), 'yyyyMM') >=
                    FROM_TIMESTAMP(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM'))
        )
    GROUP BY
        tg.cd_hansya,
        tg.cd_kaisya,
        tg.cd_jytyuten,
        CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        ),
        kn_syame,
        dd_date,
        tbbc001g.no_syaryou
    UNION ALL
    SELECT
        tg.cd_hansya
        , tg.cd_kaisya
        , tg.cd_jytyuten
        , CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        ) AS cd_ncsyamei,
        UPPER(NVL(tbv0232m.mj_syamei, '')) AS kn_syame
        , tg.dd_uritorik AS dd_date
        , 0 AS su_jusya_hanbai
        , COUNT(*) AS su_jusya_hanbai_torikesi
    FROM ai21rep_ve_dx.tbbc017g tg
    LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g
        ON tbbc001g.cd_kaisya = tg.cd_kaisya
        AND tbbc001g.cd_hansya = tg.cd_hansya
        AND tbbc001g.no_syaryou = tg.no_syaryou
    LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m
        ON tbv0232m.cd_hansya = tbbc001g.cd_hansya
        AND tbv0232m.cd_kaisya = tbbc001g.cd_kaisya
        AND tbv0232m.cd_syamei = CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        )
    WHERE
        tg.dd_jucyuke IS NOT NULL
        AND FROM_TIMESTAMP(tg.dd_uritorik, 'yyyyMM') >=
            FROM_TIMESTAMP(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'yyyyMM')
    GROUP BY
        tg.cd_hansya,
        tg.cd_kaisya,
        tg.cd_jytyuten,
        CONCAT(
            NVL(tbbc001g.mj_21syamek, ''),
            NVL(tbbc001g.mj_21syasyu, ''),
            NVL(tbbc001g.mj_21syamak, ''),
            NVL(tbbc001g.no_21syaren, ''),
            NVL(tbbc001g.mj_21syanin, '')
        ),
        kn_syame,
        tg.dd_uritorik,
        tbbc001g.no_syaryou
) combined
GROUP BY
    cd_hansya,
    cd_kaisya,
    cd_jytyuten,
    cd_ncsyamei,
    kn_syame,
    TO_DATE(dd_date)
;
