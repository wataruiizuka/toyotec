DROP TABLE IF EXISTS gold.vbi016008;
CREATE TABLE gold.vbi016008 AS
SELECT
    `販社コード`
    , `会社コード`
    , `店舗コード`
    , `下取有無`
    , `下取車の車名`
    , `新車車名`
    , `受注計上日`
    , `店舗短縮名称`
    , `ゾーンコード`
    , `ゾーン名称`
    , `下取車の自社他社`
    , `下取車の年式`
    , RANK() OVER (PARTITION BY `販社コード`,`会社コード` ORDER BY IF(NVL(`ゾーン名称`,'') = '', 0,1), `ゾーン名称`,`ソート順` , `店舗コード`) AS `ソート順`
    , RANK() OVER (PARTITION BY `販社コード`, `会社コード` ORDER BY `車名ソート順`, `新車車名コード`) AS `車名ソート順`
    , `台数`
    , `下取台数`
FROM
(
SELECT
    tbv0201m.cd_hansya AS `販社コード`
    , tbv0201m.cd_kaisya AS `会社コード`
    , tbv0201m.cd_tenpo AS `店舗コード`
    , sort_sub.mj_sortjyun AS `ソート順`
    , MIN(sort_car.mj_sortjyun) AS `車名ソート順`
    , MIN(sort_car.cd_ncsyamei) AS `新車車名コード`
    , IF(tbba003g_group.sitasu > 0, '有', '無') AS `下取有無`
    , tbv0232m.kj_syamei AS `下取車の車名`
    , tbbf001m.kj_kurumame AS `新車車名`
    , CAST(tbba001g.dd_jucyuke AS DATE) AS `受注計上日`
    , tbv0201m.kj_tentanms AS `店舗短縮名称`
    , IF(
        (tbv0033m.cd_zon IS NULL OR regexp_replace(tbv0033m.cd_zon, '[ 　]+', '') = ''),
            IF((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = ''),
            '999999',
            '999998'
            ),
            IF(((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = '')),
            '999999',
            tbv0033m.cd_zon)
        ) AS `ゾーンコード`,
    TBV0033M.kj_zonmei AS `ゾーン名称`
    , IF(tbv0232m.cd_hansya IS NULL, NULL, IF(tbv0232m.cd_maker = '01' AND LEFT(tbv0232m.cd_syamei,1) <> 'L' , 'トヨタ' , '他メーカー' )) AS `下取車の自社他社`
     , CASE
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) < (YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 8) THEN
      CASE
        WHEN (YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 9) >= 2019 THEN
          CONCAT('R', LPAD(CAST((YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 2018 - 9) AS STRING), 2, '0'), '～')
        ELSE
          CONCAT('H', LPAD(CAST((YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 1988 - 9) AS STRING), 2, '0'), '～')
      END
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) >= 2019 THEN
      CONCAT('R', LPAD(CAST(CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) - 2018 AS STRING), 2, '0'))
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) >= 1989 THEN
      CONCAT('H', LPAD(CAST(CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) - 1988 AS STRING), 2, '0'))
    ELSE
      NULL
      END AS `下取車の年式`
    , CASE
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) < (YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 8) THEN
      CASE
        WHEN (YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 9) >= 2019 THEN
          CONCAT('R', LPAD(CAST((YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 2018 - 9) AS STRING), 2, '0'), '～')
        ELSE
          CONCAT('H', LPAD(CAST((YEAR(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE)) - 1988 - 9) AS STRING), 2, '0'), '～')
      END
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) >= 2019 THEN
      CONCAT('R', LPAD(CAST(CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) - 2018 AS STRING), 2, '0'))
    WHEN CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) >= 1989 THEN
      CONCAT('H', LPAD(CAST(CAST(SUBSTR(tbba003g_group.su_syndotor, 1, 4) AS INT) - 1988 AS STRING), 2, '0'))
    ELSE
      NULL
      END AS `下取車の年式`
      , COUNT(tbba001g.cd_hansya) AS `台数`
      , SUM(IF(tbv0232m.cd_hansya IS NOT NULL, tbba003g_group.sitasu,0)) AS `下取台数`
FROM ai21rep_ve_dx.tbv0201m tbv0201m
INNER JOIN dx_ve.tbi999003m tbi999003m
    ON tbv0201m.cd_hansya = tbi999003m.cd_hansya
    AND tbv0201m.cd_kaisya = tbi999003m.cd_kaisya
    AND tbv0201m.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '016'
    AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbv0047m TBV0047M
    ON TBV0047M.cd_hansya = tbv0201m.cd_hansya
    AND TBV0047M.cd_kaisya = tbv0201m.cd_kaisya
    AND TBV0047M.cd_tenpo = tbv0201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m TBV0033M
    ON TBV0033M.cd_hansya = TBV0047M.cd_hansya
    AND TBV0033M.cd_kaisya = TBV0047M.cd_kaisya
    AND TBV0033M.cd_zon = TBV0047M.cd_nczon
    AND tbv0033m.kb_syohin  = '1'
LEFT JOIN ai21rep_ve_dx.tbba001g tbba001g
    ON tbv0201m.cd_hansya = tbba001g.cd_hansya
    AND tbv0201m.cd_kaisya = tbba001g.cd_kaisya
    AND tbv0201m.cd_tenpo = tbba001g.cd_tenpo
    AND tbba001g.dd_uritrkkj IS NULL
    AND tbba001g.dd_torikesi IS NULL
    AND tbba001g.dd_jucyuke IS NOT NULL
LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m
    ON tbba001g.cd_kaisya = tbbf008m.cd_kaisya
    AND tbba001g.cd_hansya = tbbf008m.cd_hansya
    AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
    AND tbba001g.mj_gaihansy  = tbbf008m.cd_spec
    AND tbba001g.mj_hantenkt  = tbbf008m.mj_hantenkt
    AND tbbf008m.kb_spec = 'G'
LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m
    ON tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
    AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
    AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m
    ON tbbf001m.cd_hansya = tbi999008m.cd_hansya
    AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
    AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
    AND tbi999008m.kb_tenji = 1
LEFT JOIN (
      SELECT
         tbba003g.cd_hansya
        ,tbba003g.cd_kaisya
        ,tbba003g.no_cyumon
        ,tbba003g.no_cyumoned
        ,MAX(su_syndotor) AS su_syndotor
        ,MAX(tbba003g.cd_sitadosy) AS cd_sitadosy
        ,COUNT(1) AS sitasu
      FROM ai21rep_ve_dx.tbba003g tbba003g
      WHERE tbba003g.kb_sincyu = '1'
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
LEFT JOIN   (SELECT     kj_tentanms,
    ON t201m_2.cd_hansya,
                     t201m_2.cd_kaisya,
                     MIN(t201m_2.cd_tenpo) AS cd_tenpo,
                     MIN(tbi999003m.mj_sortjyun) AS mj_sortjyun
         FROM ai21rep_ve_dx.tbv0201m t201m_2
         INNER JOIN dx_ve.tbi999003m tbi999003m
             ON t201m_2.cd_hansya = tbi999003m.cd_hansya
             AND t201m_2.cd_kaisya = tbi999003m.cd_kaisya
             AND t201m_2.cd_tenpo = tbi999003m.cd_tenpo
             AND tbi999003m.mj_cyohyoid = '016'
             AND tbi999003m.kb_tenji = 1
        GROUP BY
            t201m_2.cd_hansya,
            t201m_2.cd_kaisya,
            kj_tentanms
        ) sort_sub
    ON tbv0201m.cd_hansya = sort_sub.cd_hansya
    AND tbv0201m.cd_kaisya = sort_sub.cd_kaisya
    AND tbv0201m.kj_tentanms = sort_sub.kj_tentanms
    LEFT JOIN (SELECT
        ON tbi999008m.cd_hansya,
                 tbi999008m.cd_kaisya,
                 TRIM(tbi999008m.kj_kurumame) AS kj_kurumame,
                 MIN(tbi999008m.mj_sortjyun) AS mj_sortjyun,
                 MIN(tbi999008m.cd_ncsyamei) AS cd_ncsyamei
         FROM dx_ve.tbi999008m tbi999008m
        WHERE tbi999008m.kb_tenji = 1
        GROUP BY
            tbi999008m.cd_hansya,
            tbi999008m.cd_kaisya,
            TRIM(tbi999008m.kj_kurumame)
        ) sort_car
    ON tbbf001m.cd_hansya = sort_car.cd_hansya
    AND tbbf001m.cd_kaisya = sort_car.cd_kaisya
    AND TRIM(tbbf001m.kj_kurumame) = TRIM(sort_car.kj_kurumame)
WHERE NOT (tbv0201m.kj_tenpomei LIKE '%廃）%' AND tbba001g.cd_hansya IS NULL)
GROUP BY
    `販社コード`,
    `会社コード`,
    `店舗コード`,
    `ゾーンコード`,
    `ソート順`,
    `下取有無`,
    `下取車の車名`,
    `新車車名`,
    `受注計上日`,
    `店舗短縮名称`,
    `ゾーン名称`,
    `下取車の自社他社`,
    `下取車の年式`
 ) t
;
