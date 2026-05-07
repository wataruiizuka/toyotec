DROP TABLE IF EXISTS gold.vbi016007;
CREATE TABLE gold.vbi016007 AS
WITH tbbg068m AS (
    SELECT cd_hansya, cd_kaisya, cd_mondai, '01' AS searchKey, cd_kotaem1 AS cd_kotaem  FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '02' AS searchKey, cd_kotaem2 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '03' AS searchKey, cd_kotaem3 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '04' AS searchKey, cd_kotaem4 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '05' AS searchKey, cd_kotaem5 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '06' AS searchKey, cd_kotaem6 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '07' AS searchKey, cd_kotaem7 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '08' AS searchKey, cd_kotaem8 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '09' AS searchKey, cd_kotaem9 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '10' AS searchKey, cd_kotaem10 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '11' AS searchKey, cd_kotaem11 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '12' AS searchKey, cd_kotaem12 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '13' AS searchKey, cd_kotaem13 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '14' AS searchKey, cd_kotaem14 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '15' AS searchKey, cd_kotaem15 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '16' AS searchKey, cd_kotaem16 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '17' AS searchKey, cd_kotaem17 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '18' AS searchKey, cd_kotaem18 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '19' AS searchKey, cd_kotaem19 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, cd_mondai, '20' AS searchKey, cd_kotaem20 AS cd_kotaem FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai IN ('101','104','111') AND kn_sincyu  = '1'
)
SELECT
    販社コード
    , 会社コード
    , ゾーン名称
    , ゾーンコード
    , 店舗短縮名称
    , 新車車名
    , 受注計上日
    , 購入形態
    , 法人個人区分
    , 年齢別
    , 商談動機
    , 支払区分
    , RANK() OVER (PARTITION BY 販社コード,会社コード ORDER BY IF(NVL(ゾーン名称,'') = '', 0,1), ゾーン名称 , ソート順 , 店舗コード) AS ソート順
    , RANK() OVER (PARTITION BY 販社コード, 会社コード ORDER BY 車名ソート順,新車車名コード) AS 車名ソート順
    , 台数
FROM
(
SELECT
    t201m.cd_hansya AS `販社コード`
    , t201m.cd_kaisya AS `会社コード`
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
    tbv0033m.kj_zonmei AS `ゾーン名称`
    , t201m.cd_tenpo AS `店舗コード`
    , sort_sub.mj_sortjyun AS `ソート順`
    , MIN(sort_car.mj_sortjyun) AS `車名ソート順`
    , MIN(sort_car.cd_ncsyamei) AS `新車車名コード`
    , t201m.kj_tentanms AS `店舗短縮名称`
    , CASE WHEN tbba051g.kb_seibetu ='1' THEN '男' WHEN tbba051g.kb_seibetu ='2' THEN '女' WHEN tbba051g.kb_seibetu = '3' THEN '法人' ELSE NULL END AS `法人個人区分`
    , CASE WHEN tbba051g.nu_nenrei >=60 THEN '60歳以上'
        WHEN tbba051g.nu_nenrei >=50 THEN '50歳代'
        WHEN tbba051g.nu_nenrei >=40 THEN '40歳代'
        WHEN tbba051g.nu_nenrei >=30 THEN '30歳代'
        ELSE '29歳以下'
    END AS `年齢別`
    , IF(tbbf001m.kb_syasikib='6' , IF(TRIM(tbbg068m_2.cd_kotaem)='',NULL, tbbg068m_2.cd_kotaem) , IF(TRIM(tbbg068m_3.cd_kotaem)='',NULL, tbbg068m_3.cd_kotaem)) AS `購入形態`
    , tbbf001m.kj_kurumame AS `新車車名`
    , CAST(tbba001g.dd_jucyuke AS DATE) AS `受注計上日`
    , IF(TRIM(tbbg068m_1.cd_kotaem)='',NULL, tbbg068m_1.cd_kotaem) AS `商談動機`
    , REPLACE(TRIM(tbv0231m.mj_kubunnai),'　','') AS `支払区分`
    , COUNT(tbba001g.cd_hansya) AS `台数`
FROM
    ai21rep_ve_dx.tbv0201m t201m
LEFT JOIN ai21rep_ve_dx.tbba001g tbba001g
    ON t201m.cd_hansya = tbba001g.cd_hansya
    AND t201m.cd_kaisya = tbba001g.cd_kaisya
    AND t201m.cd_tenpo = tbba001g.cd_tenpo
    AND tbba001g.dd_uritrkkj IS NULL
    AND tbba001g.dd_torikesi IS NULL
    AND tbba001g.dd_jucyuke IS NOT NULL
INNER JOIN dx_ve.tbi999003m tbi999003m
    ON t201m.cd_hansya = tbi999003m.cd_hansya
    AND t201m.cd_kaisya = tbi999003m.cd_kaisya
    AND t201m.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '016'
    AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbv0047m  tbv0047m
    ON tbv0047m.cd_hansya = t201m.cd_hansya
    AND tbv0047m.cd_kaisya = t201m.cd_kaisya
    AND tbv0047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m tbv0033m
    ON tbv0033m.cd_hansya = t201m.cd_hansya
    AND tbv0033m.cd_kaisya = t201m.cd_kaisya
    AND tbv0033m.cd_zon = tbv0047m.cd_nczon
    AND tbv0033m.kb_syohin  = '1'
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
 LEFT JOIN tbbg068m tbbg068m_1
     ON tbbg068m_1.cd_hansya = tbba056g.cd_hansya
     AND tbbg068m_1.cd_kaisya = tbba056g.cd_kaisya
     AND tbba056g.mj_jucyuke1=tbbg068m_1.searchKey
     AND tbbg068m_1.cd_mondai  = '101'
 LEFT JOIN tbbg068m tbbg068m_2
     ON tbbg068m_2.cd_hansya = tbba056g.cd_hansya
     AND tbbg068m_2.cd_kaisya = tbba056g.cd_kaisya
     AND tbba056g.mj_jucyuk11=tbbg068m_2.searchKey
     AND tbbg068m_2.cd_mondai  = '111'
 LEFT JOIN tbbg068m tbbg068m_3
     ON tbbg068m_3.cd_hansya = tbba056g.cd_hansya
     AND tbbg068m_3.cd_kaisya = tbba056g.cd_kaisya
     AND tbba056g.mj_jucyuke4=tbbg068m_3.searchKey
     AND tbbg068m_3.cd_mondai  = '104'
 LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g
     ON tbba052g.cd_hansya = tbba001g.cd_hansya
     AND tbba052g.cd_kaisya = tbba001g.cd_kaisya
     AND tbba052g.no_cyumon = tbba001g.no_cyumon
     AND TRIM(tbba052g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
 LEFT JOIN ai21rep_ve_dx.tbv0231m tbv0231m
     ON tbv0231m.cd_hansya = tbba001g.cd_hansya
     AND tbv0231m.cd_kaisya = tbba001g.cd_kaisya
     AND tbv0231m.mj_blockid = '02'
     AND tbv0231m.mj_kubunid = '0018'
     AND TRIM(tbv0231m.cd_kubun) = tbba052g.kb_siharai
 LEFT JOIN  (SELECT    kj_tentanms,
     ON t201m_2.cd_hansya,
                     t201m_2.cd_kaisya,
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
    ON t201m.cd_hansya = sort_sub.cd_hansya
    AND t201m.cd_kaisya = sort_sub.cd_kaisya
    AND t201m.kj_tentanms = sort_sub.kj_tentanms
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
WHERE NOT (t201m.kj_tenpomei LIKE '%廃）%' AND tbba001g.cd_hansya IS NULL)
GROUP BY
    `販社コード`,
    `会社コード`,
    `ゾーンコード`,
    `ゾーン名称`,
    `店舗コード`,
    `ソート順`,
    `店舗短縮名称`,
    `年齢別`,
    `新車車名`,
    `受注計上日`,
    `購入形態`,
    `法人個人区分`,
    `商談動機`,
    `支払区分`
 ) t
;
