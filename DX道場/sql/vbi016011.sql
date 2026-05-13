DROP TABLE IF EXISTS gold.vbi016011;
CREATE TABLE gold.vbi016011 AS
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
        t201m.cd_hansya AS `販社コード`
        , t201m.cd_kaisya AS `会社コード`
        , t201m.cd_tenpo AS `店舗コード`
        , RANK() OVER (PARTITION BY t201m.cd_hansya,t201m.cd_kaisya ORDER BY IF(NVL(tbv0033m.kj_zonmei,'') = '', 0,1), tbv0033m.kj_zonmei , sort_sub.mj_sortjyun, t201m.cd_tenpo) AS `ソート順`
        , RANK() OVER (PARTITION BY t201m.cd_hansya, t201m.cd_kaisya ORDER BY sort_car.mj_sortjyun, sort_car.cd_ncsyamei) AS `車名ソート順`
        , t201m.kj_tentanms AS `店舗短縮名称`
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
        , tbba001g.no_cyumon AS `注文ＮＯ`
        , tbbf001m.kj_kurumame AS `新車車名`
        , CAST(tbba001g.dd_jucyuke AS DATE) AS `受注計上日`
        , tbv0229m.mj_guredo AS `グレード`
        , tbbf007m.kn_hinmei AS `品名カナ`
        , CASE WHEN tbba051g.kb_seibetu ='1' THEN '男' WHEN tbba051g.kb_seibetu ='2' THEN '女' WHEN tbba051g.kb_seibetu = '3' THEN '法人' ELSE NULL END AS `法人個人区分`
        , CASE WHEN tbba051g.nu_nenrei >=60 THEN '60歳以上'
            WHEN tbba051g.nu_nenrei >=50 THEN '50歳代'
            WHEN tbba051g.nu_nenrei >=40 THEN '40歳代'
            WHEN tbba051g.nu_nenrei >=30 THEN '30歳代'
            ELSE '29歳以下'
        END AS `年齢別`
        , tbbg068m_1.cd_kotaem AS `商談動機`
        , IF(tbbf001m.kb_syasikib='6' , tbbg068m_2.cd_kotaem    , tbbg068m_3.cd_kotaem) AS `購入形態`
        , IF(NVL(tbba003g_group.sitasu,0) = 0 , '無', '有') AS `下取有無`
        , IF(tbv0232m.cd_maker = '01' AND LEFT(tbv0232m.cd_syamei,1) <> 'L' , 'トヨタ' ,IF(tbv0232m.cd_syamei IS NOT NULL,'他メーカー', NULL )  ) AS `メーカー区分`
        , tbv0232m.kj_syamei AS `下取車名`
        , tbv0232m.mj_sysyubur AS `車種分類`
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
        END) AS `下取車年式`,
        (CASE
            WHEN tbv0232m.cd_maker = "01" AND LEFT(tbv0232m.cd_syamei,1) <> 'L' THEN
                CASE
                WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'クラウン' THEN 'クラウン'
                    WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'プリウス' THEN 'プリウス'
                    WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'カローラ' THEN 'カローラ'
                    WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'シエンタ' THEN 'シエンタ'
                    WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'アイシス' OR regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,3})', 0) = 'ガイア' THEN 'アイシス・ガイア'
                    WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,5})', 0) = 'エスティマ' THEN 'エスティマ'
                    WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'ハリアー' THEN 'ハリアー'
                    ELSE 'その他　トヨタ車'
                END
             WHEN tbv0232m.cd_hansya IS NOT NULL THEN
                CASE
                    WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,3})', 0) = 'ホンダ' THEN 'ホンダ系'
                    WHEN LEFT(tbv0232m.cd_syamei, 1) = 'L' THEN 'レクサス'
                    WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,3})', 0) = 'スバル' THEN 'スバル系'
                    WHEN regexp_extract(tbv0232m.kj_syamei, '^(?:.{1,4})', 0) = 'ニッサン' THEN 'ニッサン系'
                    WHEN INSTR(tbv0232m.kj_syamei, '輸入車') > 0 THEN '輸入車'
                    ELSE 'その他メーカー'
                END
            ELSE NULL
        END) AS `下取車メーカー`
    FROM ai21rep_ve_dx.tbv0201m t201m
    LEFT JOIN ai21rep_ve_dx.tbv0047m  tbv0047m
        ON tbv0047m.cd_hansya = t201m.cd_hansya
        AND tbv0047m.cd_kaisya = t201m.cd_kaisya
        AND tbv0047m.cd_tenpo = t201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv0033m
        ON tbv0033m.cd_hansya = t201m.cd_hansya
        AND tbv0033m.cd_kaisya = t201m.cd_kaisya
        AND tbv0033m.cd_zon = tbv0047m.cd_nczon
        AND tbv0033m.kb_syohin  = '1'
    INNER JOIN dx_ve.tbi999003m tbi999003m
        ON t201m.cd_hansya = tbi999003m.cd_hansya
        AND t201m.cd_kaisya = tbi999003m.cd_kaisya
        AND t201m.cd_tenpo = tbi999003m.cd_tenpo
        AND tbi999003m.mj_cyohyoid = '016'
        AND tbi999003m.kb_tenji = 1
    INNER JOIN ai21rep_ve_dx.tbba001g tbba001g
        ON t201m.cd_hansya = tbba001g.cd_hansya
        AND t201m.cd_kaisya = tbba001g.cd_kaisya
        AND t201m.cd_tenpo = tbba001g.cd_tenpo
        AND tbba001g.dd_uritrkkj IS NULL
        AND tbba001g.dd_torikesi IS NULL
        AND tbba001g.dd_jucyuke IS NOT NULL
    LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M
        ON tbba001g.cd_kaisya = TBBF008M.cd_kaisya
        AND tbba001g.cd_hansya = TBBF008M.cd_hansya
        AND tbba001g.mj_sinkysed = TBBF008M.mj_sinkysed
        AND tbba001g.mj_gaihansy  = TBBF008M.cd_spec
        AND tbba001g.mj_hantenkt  = TBBF008M.mj_hantenkt
        AND TBBF008M.kb_spec = 'G'
    LEFT  JOIN ai21rep_ve_dx.tbbf001m tbbf001m
        ON tbbf001m.cd_kaisya = TBBF008M.cd_kaisya
        AND tbbf001m.cd_hansya = TBBF008M.cd_hansya
        AND tbbf001m.cd_ncsyamei = TBBF008M.mj_syamei
    INNER JOIN  dx_ve.tbi999008m tbi999008m
        ON tbbf001m.cd_hansya = tbi999008m.cd_hansya
        AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
        AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
        AND tbi999008m.kb_tenji = 1
    LEFT JOIN ai21rep_ve_dx.tbbf007m tbbf007m
        ON tbbf007m.cd_hansya = TBBF008M.cd_hansya
        AND tbbf007m.cd_kaisya = TBBF008M.cd_kaisya
        AND tbbf007m.mj_syamei = TBBF008M.mj_syamei
        AND tbbf007m.kb_spec = TBBF008M.kb_spec
        AND tbbf007m.cd_spec = TBBF008M.cd_spec
        AND tbbf007m.no_hinmei = TBBF008M.no_hinmei
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
    LEFT JOIN ai21rep_ve_dx.tbv0229m tbv0229m
        ON tbv0229m.cd_hansya = tbba001g.cd_hansya
        AND tbv0229m.cd_kaisya = tbba001g.cd_kaisya
        AND tbv0229m.no_siteruib = tbba001g.no_siteruib
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
    AND sort_sub.kj_tentanms=t201m.kj_tentanms
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
;
