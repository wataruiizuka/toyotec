DROP TABLE IF EXISTS gold.vbi010004;
CREATE TABLE gold.vbi010004 AS
SELECT
    t201m.cd_hansya AS 販社コード
    , t201m.cd_kaisya AS 会社コード
    , t201m.cd_tenpo AS 店舗コード
    , CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗
    , NVL(ucar.TAD販売実績, 0) AS TAD販売実績
    , NVL(ucar.TAD下取数, 0) AS TAD下取数
    , NVL(ucar.TAD入会数, 0) AS TAD入会数
    , NVL(ucar.Ucar下取数, 0) AS Ucar下取数
    , NVL(ucar.UCar買取数, 0) AS UCar買取数
    , NVL(ucar.UCar入会数, 0) AS UCar入会数
    , NVL(ucar.UCar小売, 0) AS UCar小売
    , NVL(ucar.UCar卸, 0) AS UCar卸
FROM
    ai21rep_ve_dx.tbv0201m t201m
LEFT JOIN
    ON (
    SELECT
        cd_hansya
        , cd_kaisya
        , cd_jytyuten
        , SUM(CASE WHEN 売上区分 = '11' THEN Ucar下取数 ELSE 0 END) AS Ucar下取数
        , SUM(CASE WHEN 売上区分 = '11' THEN UCar入会数 ELSE 0 END) AS UCar入会数
        , SUM(UCar買取数) AS UCar買取数
        , SUM(CASE WHEN 売上区分 = '11' THEN Ucar販売数 ELSE 0 END) AS UCar小売
        , SUM(CASE WHEN 売上区分 = '20' THEN Ucar販売数 ELSE 0 END) AS UCar卸
        , SUM(CASE WHEN 売上区分 = '14' THEN Ucar販売数 ELSE 0 END) AS TAD販売実績
        , SUM(CASE WHEN 売上区分 = '14' THEN Ucar下取数 ELSE 0 END) AS TAD下取数
        , SUM(CASE WHEN 売上区分 = '14' THEN UCar入会数 ELSE 0 END) AS TAD入会数
    FROM
        (
        SELECT
            tbbc017g.cd_hansya
            , tbbc017g.cd_kaisya
            , tbbc017g.cd_jytyuten
            , tbbc017g.kb_uriage AS 売上区分
            , SUM(calflg) AS Ucar販売数
             , (SUM(CASE WHEN tbba003g_1.Ucar下取数 > 0  THEN calflg ELSE 0 END) ) AS Ucar下取数
            , SUM(CASE WHEN TBBC001G.kb_siire LIKE '3%' THEN calflg ELSE 0 END) AS UCar買取数
            , SUM(CASE WHEN NVL(REPLACE(REPLACE(tbbc020g.kb_mntpkkei, '　', ''), ' ', ''),'') <> '' THEN calflg ELSE 0 END)  AS UCar入会数
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
            FROM
                ai21rep_ve_dx.tbbc017g tbbc017g
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
                AND ( (ft8006.dd_uriage IS NULL
                    AND tbbc017g.dd_uriagekj >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
                    OR
                        (ft8006.dd_uriage IS NOT NULL
                    AND from_timestamp(to_timestamp(CAST(ft8006.dd_uriage AS STRING), 'yyyyMM'), 'yyyyMM') >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
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
                AND tbbc017g.dd_uritorik >= TRUNC(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
        ) tbbc017g
        LEFT JOIN ai21rep_ve_dx.tbbc001g TBBC001G
            ON TBBC001G.cd_kaisya = tbbc017g.cd_kaisya
            AND TBBC001G.cd_hansya = tbbc017g.cd_hansya
            AND TBBC001G.no_syaryou = tbbc017g.no_syaryou
        LEFT JOIN (
            SELECT
                tbba003g.cd_hansya
                , tbba003g.cd_kaisya
                , tbba003g.no_cyumon
                , tbba003g.no_cyumoned
                , COUNT(1) AS Ucar下取数
            FROM
                ai21rep_ve_dx.tbba003g tbba003g
            WHERE
                tbba003g.kb_sincyu = '2'
            GROUP BY
                tbba003g.cd_hansya,
                tbba003g.cd_kaisya,
                tbba003g.no_cyumon,
                tbba003g.no_cyumoned
           ) tbba003g_1
           ON tbbc017g.cd_hansya = tbba003g_1.cd_hansya
            AND tbbc017g.cd_kaisya = tbba003g_1.cd_kaisya
            AND tbbc017g.no_cyumon = tbba003g_1.no_cyumon
            AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbba003g_1.no_cyumoned)
        LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
            ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
            AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
            AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
            AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
        WHERE tbbc017g.kb_uriage IN ('11', '14', '20')
            GROUP BY
                tbbc017g.cd_hansya,
                tbbc017g.cd_kaisya,
                tbbc017g.cd_jytyuten,
                tbbc017g.kb_uriage
) combined
    GROUP BY
        cd_hansya,
        cd_kaisya,
        cd_jytyuten
) ucar ON
    t201m.cd_hansya = ucar.cd_hansya
    AND t201m.cd_kaisya = ucar.cd_kaisya
    AND t201m.cd_tenpo = ucar.cd_jytyuten
;
