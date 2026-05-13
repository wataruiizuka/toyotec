DROP TABLE IF EXISTS gold.vbi021004;
CREATE TABLE gold.vbi021004 AS
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
      FROM ai21rep_ve_dx.tbba003g TBBA003G WHERE cd_hansya IS null
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,2 AS sortn
      FROM ai21rep_ve_dx.tbba095g TBBA095G WHERE cd_hansya IS null
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,no_cyumon,no_cyumoned,NO_SYADAIBA,DD_SITATORI,KB_SINCYU,3 AS sortn
      FROM ai21rep_ve_dx.tbba117g TBBA117G WHERE cd_hansya IS null
    ) jucyushitatr1
  ) jucyushitatr2
  WHERE rnk = 1
),
a051g AS (
  SELECT *
  FROM (
    SELECT
      cd_hansya,cd_kaisya,CD_KOKYAKU,KB_KOKYAKU,NO_CYUMON,NO_CYUMONED
      , RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, no_cyumon, no_cyumoned,KB_KOKYAKU ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        cd_hansya,cd_kaisya,CD_KOKYAKU,KB_KOKYAKU,NO_CYUMON,NO_CYUMONED,1 AS sortn
      FROM ai21rep_ve_dx.tbba051g TBBA051G
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,CD_KOKYAKU,KB_KOKYAKU,NO_CYUMON,NO_CYUMONED,2 AS sortn
      FROM ai21rep_ve_dx.tbba087g TBBA087G
      UNION ALL
      SELECT
        cd_hansya,cd_kaisya,CD_KOKYAKU,KB_KOKYAKU,NO_CYUMON,NO_CYUMONED,3 AS sortn
      FROM ai21rep_ve_dx.tbba130g TBBA130G
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
      MJ_SIRENORI,KB_SIRETOSY,CD_SIRETOGY,NO_SIRETOSE,DD_SIIRE,DT_SAISINUP,DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou
      , RANK() OVER (PARTITION BY cd_hansya, cd_kaisya, NO_SYADAIBA ORDER BY sortn ASC) AS rnk
    FROM (
      SELECT
        MJ_SIRENORI,KB_SIRETOSY,CD_SIRETOGY,NO_SIRETOSE,DD_SIIRE,DT_SAISINUP,DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,1 AS sortn
      FROM ai21rep_ve_dx.tbbc001g TBBC001G
      WHERE (lOWER(MJ_KATASIKI) LIKE '%xeam10%' OR lOWER(MJ_KATASIKI) LIKE '%yeam15%')
        AND DD_TORIKESI IS NULL
        AND KB_SIIRE LIKE '3%'
      UNION ALL
      SELECT
        MJ_SIRENORI,KB_SIRETOSY,CD_SIRETOGY,NO_SIRETOSE,DD_SIIRE,DT_SAISINUP,DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,2 AS sortn
      FROM ai21rep_ve_dx.tbbc050g TBBC050G
      WHERE (lOWER(MJ_KATASIKI) LIKE '%xeam10%' OR lOWER(MJ_KATASIKI) LIKE '%yeam15%')
        AND DD_TORIKESI IS NULL
        AND KB_SIIRE LIKE '3%'
      UNION ALL
      SELECT
        MJ_SIRENORI,KB_SIRETOSY,CD_SIRETOGY,NO_SIRETOSE,DD_SIIRE,DT_SAISINUP,DD_KEIRIKEI,NO_SYADAIBA,MJ_KATASIKI,KJ_SITAMEIG,MJ_FURUSYAM,KB_SIIRE,DD_SIREJYTY,DD_SIRETORO,CD_SYOYUSYA,KJ_SAISSYYU,cd_hansya,cd_kaisya,DD_TORIKESI,cd_sitadote,NO_SIRETYUM,no_syaryou,3 AS sortn
      FROM ai21rep_ve_dx.tbbc065g TBBC065G
      WHERE (lOWER(MJ_KATASIKI) LIKE '%xeam10%' OR lOWER(MJ_KATASIKI) LIKE '%yeam15%')
        AND DD_TORIKESI IS NULL
        AND KB_SIIRE LIKE '3%'
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
, t.MJ_KATASIKI
, t.KJ_SITAMEIG
, t.MJ_FURUSYAM
, t.KB_SIIRE
, t.DD_KEIRIKEI
, t.DD_SIRETORO
, t.DD_SIREJYTY
, t.CD_SYOYUSYA
, t.KJ_SAISSYYU
, NULLIF(
  LEAST(
    COALESCE(t.DD_SIIRE, DATE '9999-12-31'),
    COALESCE(t.DD_KEIRIKEI, DATE '9999-12-31'),
    COALESCE(t.DD_SIREJYTY, DATE '9999-12-31'),
    COALESCE(t.DD_SIRETORO, DATE '9999-12-31'),
    COALESCE(t.DT_SAISINUP, DATE '9999-12-31')
  ),
  DATE '9999-12-31'
) AS min_non_null_date_zaiko,
a001g.NO_SYADAIBA AS NO_SYADAIBA_shinsya
, a001g.KJ_MEIGIME1 AS kj_meigime1_shinsya
, a001g.DD_JUCYU AS dd_jucyu_shinsya
, a001g.DD_TOUROKU AS dd_touroku_shinsya
, a001g.MJ_HANTENKT AS mj_katasiki_shinsya
, a001g.NO_CYUMON AS no_cyumon_shinsya
, f001m.KJ_KURUMAME AS kj_kurumame_shinsya
, c003g.KB_SIREHANB
, c006g.DD_1JTOROKU
FROM c001g t
INNER JOIN ai21rep_ve_dx.tbtec05g c05g
    ON c05g.cd_hansya = t.cd_hansya
    AND c05g.cd_kaisya = t.cd_kaisya
    AND RTRIM(c05g.NO_SYADAI) = rtrim(t.NO_SYADAIBA)
    AND c05g.CD_NORIKUSI = t.MJ_SIRENORI
    AND c05g.KB_NOSYASYU = t.KB_SIRETOSY
    AND c05g.CD_NOGYOTAI = t.CD_SIRETOGY
    AND c05g.NO_NOSEIRI = t.NO_SIRETOSE
LEFT JOIN ai21rep_ve_dx.tbv0200m t200m
    ON t200m.cd_hansya = t.cd_hansya
    AND t200m.cd_kaisya = t.cd_kaisya
LEFT JOIN ai21rep_ve_dx.tbv0201m t201m
    ON t201m.cd_hansya = t.cd_hansya
    AND t201m.cd_kaisya = t.cd_kaisya
    AND t201m.cd_tenpo = t.CD_SITADOTE
INNER JOIN a051g
    ON a051g.cd_hansya = t.cd_hansya
    AND a051g.cd_kaisya = t.cd_kaisya
    AND a051g.CD_KOKYAKU = c05g.CD_OKYAKU
    AND a051g.KB_KOKYAKU = '2'
INNER JOIN a001g
    ON a001g.cd_hansya = t.cd_hansya
    AND a001g.cd_kaisya = t.cd_kaisya
    AND a001g.NO_CYUMON = a051g.NO_CYUMON
    AND a001g.NO_CYUMONED = a051g.NO_CYUMONED
    AND a001g.DD_TORIKESI IS NULL
INNER JOIN ai21rep_ve_dx.tbbf008m f008m
    ON f008m.cd_hansya = a001g.cd_hansya
    AND f008m.cd_kaisya = a001g.cd_kaisya
    AND f008m.MJ_SINKYSED = a001g.MJ_SINKYSED
    AND f008m.CD_SPEC = a001g.MJ_GAIHANSY
    AND f008m.MJ_HANTENKT = a001g.MJ_HANTENKT
    AND f008m.kb_spec = 'G'
INNER JOIN ai21rep_ve_dx.tbbf001m f001m
    ON f001m.cd_hansya = f008m.cd_hansya
    AND f001m.cd_kaisya = f008m.cd_kaisya
    AND f001m.cd_ncsyamei = f008m.mj_syamei
LEFT JOIN ai21rep_ve_dx.tbbc003g c003g
    ON c003g.cd_hansya = a001g.cd_hansya
    AND c003g.cd_kaisya = a001g.cd_kaisya
    AND c003g.NO_SIRETYUM = CONCAT(a001g.NO_CYUMON, a001g.NO_CYUMONED)
LEFT JOIN a003g
    ON a003g.cd_hansya = t.cd_hansya
    AND a003g.cd_kaisya = t.cd_kaisya
    AND a003g.NO_CYUMON = a001g.NO_CYUMON
    AND a003g.NO_CYUMONED = a001g.NO_CYUMONED
    AND RTRIM(a003g.NO_SYADAIBA) = RTRIM(a001g.NO_SYADAIBA)
    AND a003g.DD_SITATORI IS NULL
    AND a003g.KB_SINCYU ='1'
LEFT JOIN c006g
    ON c006g.cd_hansya = t.cd_hansya
    AND c006g.cd_kaisya = t.cd_kaisya
    AND c006g.NO_SYARYOU = t.NO_SYARYOU
WHERE (lOWER(t.MJ_KATASIKI) LIKE '%xeam10%' OR lOWER(t.MJ_KATASIKI) LIKE '%yeam15%')
AND t.DD_TORIKESI IS NULL
AND t.KB_SIIRE LIKE '3%'
AND a003g.cd_hansya IS null
AND (c003g.KB_SIREHANB NOT IN ('1', '2', '4') OR c003g.KB_SIREHANB IS null)
AND ( ((f001m.KJ_KURUMAME LIKE '%bZ4X%' OR  f001m.KJ_KURUMAME LIKE '%ｂＺ４Ｘ%') AND (a001g.MJ_HANTENKT LIKE '%XEAM11%' OR a001g.MJ_HANTENKT LIKE '%XEAM15%'))
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
