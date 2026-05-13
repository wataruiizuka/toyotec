DROP TABLE IF EXISTS gold.vbi021002;
CREATE TABLE gold.vbi021002 AS
WITH
a003g AS (
  SELECT *
  FROM (
    SELECT
      cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU
      , RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, no_cyumon, no_cyumoned, NO_SYADAIBA ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,1 AS sortn
      FROM ai21rep_ve_dx.tbba003g TBBA003G
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,2 AS sortn
      FROM ai21rep_ve_dx.tbba095g TBBA095G
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,3 AS sortn
      FROM ai21rep_ve_dx.tbba117g TBBA117G
    ) jucyushitatr1
  ) jucyushitatr2
  WHERE rnk = 1
),
a001g AS (
  SELECT *
  FROM (
    SELECT
      NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY
      , RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, no_cyumon, no_cyumoned ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,1 AS sortn
      FROM ai21rep_ve_dx.tbba001g TBBA001G WHERE (DD_TOUROKU >= '2025-8-27' AND DD_TOUROKU < '2028-4-1' OR DD_TOUROKU IS null)
      UNION ALL
      SELECT
        NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,2 AS sortn
      FROM ai21rep_ve_dx.tbba085g TBBA085G WHERE (DD_TOUROKU >= '2025-8-27' AND DD_TOUROKU < '2028-4-1' OR DD_TOUROKU IS null)
      UNION ALL
      SELECT
        NO_SYADAIBA,KJ_MEIGIME1,DD_JUCYU,DD_TOUROKU,MJ_HANTENKT,DD_TORIKESI,cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,MJ_SINKYSED,MJ_GAIHANSY,3 AS sortn
      FROM ai21rep_ve_dx.tbba108g TBBA108G WHERE (DD_TOUROKU >= '2025-8-27' AND DD_TOUROKU < '2028-4-1' OR DD_TOUROKU IS null)
    ) shinsha1
  ) shinsha2
  WHERE rnk = 1
),
c001g AS (
  SELECT *
  FROM (
    SELECT
      DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou
      , RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, NO_SYADAIBA ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,1 AS sortn
      FROM ai21rep_ve_dx.tbbc001g TBBC001G
      WHERE (LOWER(MJ_KATASIKI) LIKE '%xeam10%' OR LOWER(MJ_KATASIKI) LIKE '%yeam15%')
        AND KB_SIIRE LIKE '1%'
      UNION ALL
      SELECT
        DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,2 AS sortn
      FROM ai21rep_ve_dx.tbbc050g TBBC050G
      WHERE  (LOWER(MJ_KATASIKI) LIKE '%xeam10%' OR LOWER(MJ_KATASIKI) LIKE '%yeam15%')
        AND KB_SIIRE LIKE '1%'
      UNION ALL
      SELECT
        DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,3 AS sortn
      FROM ai21rep_ve_dx.tbbc065g TBBC065G
      WHERE (LOWER(MJ_KATASIKI) LIKE '%xeam10%' OR LOWER(MJ_KATASIKI) LIKE '%yeam15%')
        AND KB_SIIRE LIKE '1%'
    ) cyukokh1
  ) cyukokh2
  WHERE rnk = 1
),
c006g AS (
  SELECT *
  FROM (
    SELECT
      DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU
      , RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, NO_SYARYOU ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,1 AS sortn
      FROM ai21rep_ve_dx.tbbc006g TBBC006G
      UNION ALL
      SELECT
        DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,2 AS sortn
      FROM ai21rep_ve_dx.tbbc052g TBBC052G
      UNION ALL
      SELECT
        max(DD_1JTOROKU) AS DD_1JTOROKU,cd_hansya,cd_kaisya,NO_SYARYOU,3 AS sortn
      FROM ai21rep_ve_dx.tbbc064g TBBC064G
      GROUP BY cd_hansya,cd_kaisya,NO_SYARYOU
    ) cyukotr1
  ) cyukotr2
  WHERE rnk = 1
)
SELECT
  t.cd_hansya
  , t200m.kj_kaisyatn
  , t200m.cd_hanbaitn
  , t.cd_kaisya
  , t201m.kj_tenpomei
  , t.NO_SYADAIBA
  , t.NO_SYADAIBA AS NO_SYADAIBA_yotei
  , t.MJ_KATASIKI
  , t.KJ_SITAMEIG
  , t.MJ_FURUSYAM
  , t.KB_SIREHANB
  , c001g.DD_KEIRIKEI AS DD_KEIRIKEI_zako
  , c001g.NO_SYADAIBA AS NO_SYADAIBA_zako
  , c001g.MJ_KATASIKI AS MJ_KATASIKI_zako
  , c001g.KJ_SITAMEIG AS KJ_SITAMEIG_zako
  , c001g.MJ_FURUSYAM AS MJ_FURUSYAM_zako
  , c001g.KB_SIIRE AS KB_SIIRE_zako
  , c001g.DD_SIREJYTY AS DD_SIREJYTY_zako
  , c001g.DD_SIRETORO AS DD_SIRETORO_zako
  , c001g.CD_SYOYUSYA AS CD_SYOYUSYA_zako
  , c001g.KJ_SAISSYYU AS KJ_SAISSYYU_zako
  , a001g.NO_SYADAIBA AS NO_SYADAIBA_shinsya
  , a001g.KJ_MEIGIME1 AS kj_meigime1_shinsya
  , a001g.DD_JUCYU AS dd_jucyu_shinsya
  , a001g.DD_TOUROKU AS dd_touroku_shinsya
  , a001g.MJ_HANTENKT AS mj_katasiki_shinsya
  , a001g.NO_CYUMON AS no_cyumon_shinsya
  , f001m.KJ_KURUMAME AS kj_kurumame_shinsya
  , c006g.DD_1JTOROKU
FROM ai21rep_ve_dx.tbbc003g t
LEFT JOIN ai21rep_ve_dx.tbv0200m t200m
    ON t200m.cd_hansya = t.cd_hansya
    AND t200m.cd_kaisya = t.cd_kaisya
LEFT JOIN ai21rep_ve_dx.tbv0201m t201m
    ON t201m.cd_hansya = t.cd_hansya
    AND t201m.cd_kaisya = t.cd_kaisya
    AND t201m.cd_tenpo  = t.CD_SITADOTE
INNER JOIN a003g
    ON a003g.cd_hansya = t.cd_hansya
    AND a003g.cd_kaisya = t.cd_kaisya
    AND CONCAT(COALESCE(a003g.NO_CYUMON,''), COALESCE(a003g.NO_CYUMONED,'')) = t.NO_SIRETYUM
    AND TRIM(a003g.NO_SYADAIBA) = TRIM(t.NO_SYADAIBA)
    AND a003g.DD_SITATORI IS NULL
    AND a003g.KB_SINCYU = '1'
INNER JOIN a001g
    ON a001g.cd_hansya = t.cd_hansya
    AND a001g.cd_kaisya = t.cd_kaisya
    AND CONCAT(COALESCE(a001g.NO_CYUMON,''), COALESCE(a001g.NO_CYUMONED,'')) = t.NO_SIRETYUM
    AND a001g.DD_TORIKESI IS NULL
INNER JOIN ai21rep_ve_dx.tbbf008m f008m
    ON f008m.cd_hansya   = a001g.cd_hansya
    AND f008m.cd_kaisya   = a001g.cd_kaisya
    AND f008m.MJ_SINKYSED = a001g.MJ_SINKYSED
    AND f008m.CD_SPEC     = a001g.MJ_GAIHANSY
    AND f008m.MJ_HANTENKT = a001g.MJ_HANTENKT
    AND f008m.kb_spec     = 'G'
INNER JOIN ai21rep_ve_dx.tbbf001m f001m
    ON f001m.cd_hansya    = f008m.cd_hansya
    AND f001m.cd_kaisya    = f008m.cd_kaisya
    AND f001m.cd_ncsyamei  = f008m.mj_syamei
LEFT JOIN c001g
    ON c001g.cd_hansya = t.cd_hansya
    AND c001g.cd_kaisya = t.cd_kaisya
    AND TRIM(c001g.NO_SYADAIBA) = TRIM(t.NO_SYADAIBA)
    AND c001g.DD_TORIKESI IS NULL
LEFT JOIN c006g
    ON c006g.cd_hansya = t.cd_hansya
    AND c006g.cd_kaisya = t.cd_kaisya
    AND c006g.NO_SYARYOU = t.NO_SYARYOU
WHERE (LOWER(t.MJ_KATASIKI) LIKE '%xeam10%' OR LOWER(t.MJ_KATASIKI) LIKE '%yeam15%')
AND t.KB_SIREHANB = '1'
AND (((f001m.KJ_KURUMAME LIKE '%bZ4X%' OR f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘ%')
    AND (a001g.MJ_HANTENKT LIKE '%XEAM11%' OR a001g.MJ_HANTENKT LIKE '%XEAM15%'))
    OR f001m.KJ_KURUMAME LIKE '%bZ4Xツーリング%'
    OR f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘツーリング%'
    OR f001m.KJ_KURUMAME LIKE '%プリウス%'
    OR f001m.KJ_KURUMAME LIKE '%RAV4%'
    OR f001m.KJ_KURUMAME LIKE '%ＲＡＶ４%'
    OR f001m.KJ_KURUMAME LIKE '%ハリアー%'
    OR f001m.KJ_KURUMAME LIKE '%アルファード%'
    OR f001m.KJ_KURUMAME LIKE '%ヴェルファイア%'
    OR f001m.KJ_KURUMAME LIKE '%クラウンスポーツ%'
    OR f001m.KJ_KURUMAME LIKE '%クラウンエステート%'
  )
UNION
SELECT
  t.cd_hansya
  , t200m.kj_kaisyatn
  , t200m.cd_hanbaitn
  , t.cd_kaisya
  , t201m.kj_tenpomei
  , t.NO_SYADAIBA
  , t.NO_SYADAIBA AS NO_SYADAIBA_yotei
  , t.MJ_KATASIKI AS MJ_KATASIKI
  , t.KJ_SITAMEIG AS KJ_SITAMEIG
  , t.MJ_FURUSYAM AS MJ_FURUSYAM
  , t.KB_SIIRE AS KB_SIREHANB
  , t.DD_KEIRIKEI AS DD_KEIRIKEI_zako
  , t.NO_SYADAIBA AS NO_SYADAIBA_zako
  , t.MJ_KATASIKI AS MJ_KATASIKI_zako
  , t.KJ_SITAMEIG AS KJ_SITAMEIG_zako
  , t.MJ_FURUSYAM AS MJ_FURUSYAM_zako
  , t.KB_SIIRE AS KB_SIIRE_zako
  , t.DD_SIREJYTY AS DD_SIREJYTY_zako
  , t.DD_SIRETORO AS DD_SIRETORO_zako
  , t.CD_SYOYUSYA AS CD_SYOYUSYA_zako
  , t.KJ_SAISSYYU AS KJ_SAISSYYU_zako
  , a001g.NO_SYADAIBA AS NO_SYADAIBA_shinsya
  , a001g.KJ_MEIGIME1 AS kj_meigime1_shinsya
  , a001g.DD_JUCYU AS dd_jucyu_shinsya
  , a001g.DD_TOUROKU AS dd_touroku_shinsya
  , a001g.MJ_HANTENKT AS mj_katasiki_shinsya
  , a001g.NO_CYUMON AS no_cyumon_shinsya
  , f001m.KJ_KURUMAME AS kj_kurumame_shinsya
  , c006g.DD_1JTOROKU
FROM c001g t
LEFT JOIN ai21rep_ve_dx.tbv0200m t200m
    ON t200m.cd_hansya = t.cd_hansya
    AND t200m.cd_kaisya = t.cd_kaisya
LEFT JOIN ai21rep_ve_dx.tbv0201m t201m
    ON t201m.cd_hansya = t.cd_hansya
    AND t201m.cd_kaisya = t.cd_kaisya
    AND t201m.cd_tenpo  = t.CD_SITADOTE
LEFT JOIN a001g
    ON a001g.cd_hansya = t.cd_hansya
    AND a001g.cd_kaisya = t.cd_kaisya
    AND CONCAT(COALESCE(a001g.NO_CYUMON,''), COALESCE(a001g.NO_CYUMONED,'')) = t.NO_SIRETYUM
    AND a001g.DD_TORIKESI IS NULL
INNER JOIN ai21rep_ve_dx.tbbf008m f008m
    ON f008m.cd_hansya   = a001g.cd_hansya
    AND f008m.cd_kaisya   = a001g.cd_kaisya
    AND f008m.MJ_SINKYSED = a001g.MJ_SINKYSED
    AND f008m.CD_SPEC     = a001g.MJ_GAIHANSY
    AND f008m.MJ_HANTENKT = a001g.MJ_HANTENKT
    AND f008m.kb_spec     = 'G'
INNER JOIN ai21rep_ve_dx.tbbf001m f001m
    ON f001m.cd_hansya    = f008m.cd_hansya
    AND f001m.cd_kaisya    = f008m.cd_kaisya
    AND f001m.cd_ncsyamei  = f008m.mj_syamei
LEFT JOIN c006g
    ON c006g.cd_hansya = t.cd_hansya
    AND c006g.cd_kaisya = t.cd_kaisya
    AND c006g.NO_SYARYOU = t.NO_SYARYOU
WHERE (LOWER(t.MJ_KATASIKI) LIKE '%xeam10%' OR LOWER(t.MJ_KATASIKI) LIKE '%yeam15%')
AND t.KB_SIIRE LIKE '1%'
AND (((f001m.KJ_KURUMAME LIKE '%bZ4X%' OR f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘ%')
    AND (a001g.MJ_HANTENKT LIKE '%XEAM11%' OR a001g.MJ_HANTENKT LIKE '%XEAM15%'))
    OR f001m.KJ_KURUMAME LIKE '%bZ4Xツーリング%'
    OR f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘツーリング%'
    OR f001m.KJ_KURUMAME LIKE '%プリウス%'
    OR f001m.KJ_KURUMAME LIKE '%RAV4%'
    OR f001m.KJ_KURUMAME LIKE '%ＲＡＶ４%'
    OR f001m.KJ_KURUMAME LIKE '%ハリアー%'
    OR f001m.KJ_KURUMAME LIKE '%アルファード%'
    OR f001m.KJ_KURUMAME LIKE '%ヴェルファイア%'
    OR f001m.KJ_KURUMAME LIKE '%クラウンスポーツ%'
    OR f001m.KJ_KURUMAME LIKE '%クラウンエステート%'
  )
;
