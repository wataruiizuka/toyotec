DROP TABLE IF EXISTS gold.vbi022003;
CREATE TABLE gold.vbi022003 AS
SELECT
    tg.cd_hansya
    , tg.cd_kaisya
    , tg.cd_jytyuten AS cd_tenpo
    , UPPER(NVL(tbv0232m.mj_syamei, '')) AS kn_syame
    , CONCAT(
        NVL(tbbc001g.mj_21syamek, ''),
        NVL(tbbc001g.mj_21syasyu, ''),
        NVL(tbbc001g.mj_21syamak, ''),
        NVL(tbbc001g.no_21syaren, ''),
        NVL(tbbc001g.mj_21syanin, '')
    ) AS cd_ncsyamei,
    CAST(TO_DATE(tg.dd_uriagyot) AS DATE) AS dd_uriagyot
    , COUNT(*) AS su_jusya_hanbai_mikomi
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
    tg.dd_uriagekj IS NULL
    AND tg.dd_torikesi IS NULL
    AND tg.dd_moduriag IS NULL
    AND FROM_TIMESTAMP(tg.dd_uriagyot, 'yyyyMM') =
        FROM_TIMESTAMP(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'yyyyMM')
GROUP BY
    tg.cd_hansya,
    tg.cd_kaisya,
    tg.cd_jytyuten,
    UPPER(NVL(tbv0232m.mj_syamei, '')),
    CONCAT(
        NVL(tbbc001g.mj_21syamek, ''),
        NVL(tbbc001g.mj_21syasyu, ''),
        NVL(tbbc001g.mj_21syamak, ''),
        NVL(tbbc001g.no_21syaren, ''),
        NVL(tbbc001g.mj_21syanin, '')
    ),
    dd_uriagyot,
    tbbc001g.no_syaryou
;
