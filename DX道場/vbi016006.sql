DROP TABLE IF EXISTS gold.vbi016006;
CREATE TABLE gold.vbi016006 AS
SELECT
    `販社コード`
    , `会社コード`
    , IF(`自社他社` = 'トヨタ', '1', '3') AS `番号`
    , `自社他社` AS `自社他社`
    , `下取車の車名` AS `車名`
    , `カテゴリー`
    , CONCAT(NVL(`カテゴリー`,''), `下取車の車名`) AS `カテゴリー車名`
    , IF(`カテゴリー` IS NULL, 1, 2) AS `カテゴリーソート順`
FROM
    (
    SELECT
        `販社コード`
        , `会社コード`
        , `下取車の車名`
        , `カテゴリー`
        , `自社他社`
    FROM
    (
        SELECT
            tbba001g.cd_hansya AS `販社コード`
            , tbba001g.cd_kaisya AS `会社コード`
            , IF(tbv0232m.cd_maker = '01' AND LEFT(tbv0232m.cd_syamei,1) <> 'L' , 'トヨタ' , '他メーカー' ) AS `自社他社`
              , tbv0232m.kj_syamei AS `下取車の車名`
              , tbv0231m.mj_kubunnai AS `カテゴリー`
        FROM
            ai21rep_ve_dx.tbba001g tbba001g
        LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m
            ON tbba001g.cd_hansya = tbi999003m.cd_hansya
            AND tbba001g.cd_kaisya = tbi999003m.cd_kaisya
            AND tbba001g.cd_tenpo = tbi999003m.cd_tenpo
            AND tbi999003m.mj_cyohyoid = '016'
            AND tbi999003m.kb_tenji = 1
         LEFT JOIN (
              SELECT
                 tbba003g.cd_hansya
                ,tbba003g.cd_kaisya
                ,tbba003g.no_cyumon
                ,tbba003g.no_cyumoned
                ,MAX(tbba003g.cd_sitadosy) AS cd_sitadosy
              FROM ai21rep_ve_dx.tbba003g tbba003g
              WHERE tbba003g.kb_sincyu  = '1'
              GROUP BY
                 tbba003g.cd_hansya
                ,tbba003g.cd_kaisya
                ,tbba003g.no_cyumon
                ,tbba003g.no_cyumoned
            ) tbba003g_group
            ON tbba001g.cd_hansya = tbba003g_group.cd_hansya
            AND tbba001g.cd_kaisya = tbba003g_group.cd_kaisya
            AND tbba001g.no_cyumon = tbba003g_group.no_cyumon
            AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba003g_group.no_cyumoned)
        LEFT JOIN ai21rep_ve_dx.tbv0232m tbv0232m
            ON tbv0232m.cd_hansya = tbba003g_group.cd_hansya
            AND tbv0232m.cd_kaisya = tbba003g_group.cd_kaisya
            AND tbv0232m.cd_syamei = tbba003g_group.cd_sitadosy
         LEFT JOIN ai21rep_ve_dx.tbv0231m tbv0231m
             ON tbv0231m.cd_hansya = tbv0232m.cd_hansya
             AND tbv0231m.cd_kaisya = tbv0232m.cd_kaisya
             AND tbv0231m.mj_blockid = '00'
             AND tbv0231m.mj_kubunid = '0031'
             AND tbv0231m.cd_kubun = tbv0232m.cd_category
        WHERE tbba001g.dd_uritrkkj IS NULL
            AND tbba001g.dd_torikesi IS NULL
            AND tbba001g.dd_jucyuke IS NOT NULL
     ) t
     GROUP BY
        `販社コード`,
        `会社コード`,
        `下取車の車名`,
        `カテゴリー`,
        `自社他社`
    ) t
GROUP BY
    `販社コード`,
    `会社コード`,
    `自社他社`,
    `下取車の車名`,
    `カテゴリー`,
    `カテゴリーソート順`
UNION ALL
SELECT
    '固定' AS `販社コード`
    , '' AS `会社コード`
    , '4' AS `番号`
    , ' ' AS `自社他社`
    , "他社計" AS `車名`
    , ' ' AS `カテゴリー`
    , ' ' AS `カテゴリー車名`
    , 1 AS `カテゴリーソート順`
UNION ALL
SELECT
    '固定' AS `販社コード`
    , '' AS `会社コード`
    , '5' AS `番号`
    , '合　計' AS `自社他社`
    , ' ' AS `車名`
    , ' ' AS `カテゴリー`
    , ' ' AS `カテゴリー車名`
    , 1 AS `カテゴリーソート順`
UNION ALL
SELECT
    '固定' AS `販社コード`
    , '' AS `会社コード`
    , '6' AS `番号`
    , '構成比' AS `自社他社`
    , ' ' AS `車名`
    , ' ' AS `カテゴリー`
    , ' ' AS `カテゴリー車名`
    , 1 AS `カテゴリーソート順`
UNION ALL
SELECT
    '固定' AS `販社コード`
    , '' AS `会社コード`
    , '2' AS `番号`
    , '' AS `自社他社`
    , "自社計" AS `車名`
    , ' ' AS `カテゴリー`
    , ' ' AS `カテゴリー車名`
    , 1 AS `カテゴリーソート順`
;
