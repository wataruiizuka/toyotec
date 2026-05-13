DROP TABLE IF EXISTS gold.vbi010006;
CREATE TABLE gold.vbi010006 AS
SELECT
    t201m.cd_hansya AS 販社コード
    , t201m.cd_kaisya AS 会社コード
    , t201m.cd_tenpo AS 店舗コード
    , CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗
    , NVL(ucar_daitei.Ucar実績, 0) AS Ucar実績
    , NVL(ucar_daitei.Ucar代替, 0) AS Ucar代替
    , NVL(ucar_daitei.TAD実績, 0) AS TAD実績
    , NVL(ucar_daitei.TAD代替, 0) AS TAD代替
FROM
    ai21rep_ve_dx.tbv0201m t201m
LEFT JOIN
    ON (
    SELECT
        tbbc017g.cd_hansya
        , tbbc017g.cd_kaisya
        , tbbc017g.cd_jytyuten
        , SUM(IF(tbbc017g.kb_uriage = '11', calflg,0)) AS Ucar実績
        , SUM(IF(tbbc017g.kb_uriage ='11' AND tbbc034g.mj_jucyuke4 IN ('02','03'), calflg,0)) AS Ucar代替
        , SUM(IF(tbbc017g.kb_uriage='14', calflg,0)) AS TAD実績
        , SUM(IF(tbbc017g.kb_uriage='14' AND tbbc034g.mj_jucyuke4 IN ('02','03'), calflg,0)) AS TAD代替
    FROM
        (
        SELECT
            tbbc017g.cd_hansya
                , tbbc017g.cd_kaisya
                , tbbc017g.cd_jytyuten
                , tbbc017g.no_cyumon
                , tbbc017g.no_cyumoned
                , tbbc017g.no_syaryou
                , tbbc017g.kb_uriage
                , 1 AS calflg
        FROM ai21rep_ve_dx.tbbc017g tbbc017g
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
         )ft8006 ON
                tbbc017g.cd_kaisya = ft8006.cd_kaisya
            AND tbbc017g.cd_kaisya = ft8006.cd_kaisya
            AND tbbc017g.no_cyumon = ft8006.no_cyumon
            AND tbbc017g.dd_uritorik IS NULL
        WHERE
            tbbc017g.dd_uriagekj IS NOT NULL
            AND tbbc017g.dd_torikesi IS NULL
            AND (
                    (ft8006.dd_uriage IS NULL AND tbbc017g.dd_uriagekj IS NOT NULL)
            OR
                    (ft8006.dd_uriage IS NOT NULL
                ))
    UNION ALL
        SELECT
            tbbc017g.cd_hansya
            , tbbc017g.cd_kaisya
            , tbbc017g.cd_jytyuten
            , tbbc017g.no_cyumon
            , tbbc017g.no_cyumoned
            , tbbc017g.no_syaryou
            , tbbc017g.kb_uriage
            , -1 AS calflg
        FROM
            ai21rep_ve_dx.tbbc017g tbbc017g
        WHERE
        tbbc017g.dd_jucyuke IS NOT NULL
        AND tbbc017g.dd_uritorik IS NOT NULL
    ) tbbc017g
    LEFT JOIN ai21rep_ve_dx.tbbc034g tbbc034g
        ON tbbc017g.cd_hansya = tbbc034g.cd_hansya
        AND tbbc017g.cd_kaisya = tbbc034g.cd_kaisya
        AND tbbc017g.no_cyumon = tbbc034g.no_cyumon
        AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc034g.no_cyumoned)
    GROUP BY
            tbbc017g.cd_hansya,
            tbbc017g.cd_kaisya,
            tbbc017g.cd_jytyuten
) ucar_daitei
    ON t201m.cd_hansya = ucar_daitei.cd_hansya
    AND t201m.cd_kaisya = ucar_daitei.cd_kaisya
    AND t201m.cd_tenpo = ucar_daitei.cd_jytyuten
;
