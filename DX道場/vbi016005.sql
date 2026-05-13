DROP TABLE IF EXISTS gold.vbi016005;
CREATE TABLE gold.vbi016005 AS
SELECT
    `販社コード`
    , `会社コード`
    , `新車車名`
    , `購入形態`
    , `下取車の年式`
    , `下取車の車名`
    , `カテゴリー`
    , CONCAT(NVL(`カテゴリー`, '') , `下取車の車名`) AS `カテゴリー車名`
    , `自社他社`
    , CONCAT(`新車車名`,from_timestamp(`受注計上日`, 'yyyyMMdd')) AS `車名受注日`
    , SUM(`下取台数`) AS `下取台数`
    , COUNT(1) AS `台数`
FROM
(
SELECT
    tbba001g.cd_hansya AS `販社コード`
    , tbba001g.cd_kaisya AS `会社コード`
    , CASE WHEN tbbf001m.kb_syasikib='6' THEN
        CASE
            WHEN tbba056g.mj_jucyuk11  IN ('03', '04') THEN '自社代替'
            WHEN tbba056g.mj_jucyuk11  = '01' AND NVL(tbba003g_group.sitasu,0) = 0 THEN '新規下取無'
            WHEN tbba056g.mj_jucyuk11  = '01' AND tbba003g_group.sitasu > 0 THEN '新規下取有'
            WHEN tbba056g.mj_jucyuk11  IN ('05', '06') THEN '併有他社替'
            WHEN tbba056g.mj_jucyuk11  = '02' THEN '自社増車'
            ELSE 'その他'
        END
    ELSE
        CASE
            WHEN tbba056g.mj_jucyuke4  IN ('03', '04') THEN '自社代替'
            WHEN tbba056g.mj_jucyuke4  = '01' AND NVL(tbba003g_group.sitasu,0) = 0 THEN '新規下取無'
            WHEN tbba056g.mj_jucyuke4  = '01' AND tbba003g_group.sitasu > 0 THEN '新規下取有'
            WHEN tbba056g.mj_jucyuke4  IN ('05', '06') THEN '併有他社替'
            WHEN tbba056g.mj_jucyuke4  = '02' THEN '自社増車'
            ELSE 'その他'
        END
    END AS `購入形態`
    , IF(tbv0232m.cd_hansya IS NOT NULL, tbba003g_group.sitasu,0) AS `下取台数`
    , tbbf001m.kj_kurumame AS `新車車名`
    , tbba001g.dd_jucyuke AS `受注計上日`
    , IF(tbv0232m.cd_maker = '01' AND LEFT(tbv0232m.cd_syamei,1) <> 'L' , 'トヨタ' , '他メーカー' ) AS `自社他社`
      , tbv0232m.kj_syamei AS `下取車の車名`
      , tbv0231m.mj_kubunnai AS `カテゴリー`
      , (CASE
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
      END) AS `下取車の年式`
FROM
    ai21rep_ve_dx.tbba001g tbba001g
LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m
    ON tbba001g.cd_hansya = tbi999003m.cd_hansya
    AND tbba001g.cd_kaisya = tbi999003m.cd_kaisya
    AND tbba001g.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '016'
    AND tbi999003m.kb_tenji = 1
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
LEFT JOIN ai21rep_ve_dx.tbba056g tbba056g
    ON tbba056g.cd_hansya = tbba001g.cd_hansya
    AND tbba056g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba056g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba056g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
 LEFT JOIN ai21rep_ve_dx.tbba051g tbba051g
     ON tbba051g.cd_hansya = tbba001g.cd_hansya
     AND tbba051g.cd_kaisya = tbba001g.cd_kaisya
     AND tbba051g.no_cyumon = tbba001g.no_cyumon
     AND TRIM(tbba051g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
     AND tbba051g.kb_kokyaku = '2'
 LEFT JOIN (
      SELECT
        tbba003g.cd_hansya
        ,tbba003g.cd_kaisya
        ,tbba003g.no_cyumon
        ,tbba003g.no_cyumoned
        ,COUNT(1) AS sitasu
        ,MAX(su_syndotor) AS su_syndotor
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
    `新車車名`,
    `車名受注日`,
    `カテゴリー`,
    `購入形態`,
    `下取車の年式`,
    `下取車の車名`,
    `自社他社`
;
