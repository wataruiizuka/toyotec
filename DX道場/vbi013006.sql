DROP TABLE IF EXISTS gold.vbi013006;
CREATE TABLE gold.vbi013006 AS
WITH kb_genkin_table AS(
    SELECT
        tbi999013m.cd_hansya
        , tbi999013m.cd_kaisya
        , GROUP_CONCAT(tbi999013m.kb_nyuukin, ',') AS kb_nyuukin_list
    FROM dx_ve.tbi999013m tbi999013m
    WHERE tbi999013m.kb_genkin = '1'
    GROUP BY tbi999013m.cd_hansya
            ,tbi999013m.cd_kaisya
),
kb_crejcard_table AS(
    SELECT
        tbi999013m.cd_hansya
        , tbi999013m.cd_kaisya
        , GROUP_CONCAT(tbi999013m.kb_nyuukin, ',') AS kb_nyuukin_list
    FROM dx_ve.tbi999013m tbi999013m
    WHERE tbi999013m.kb_crejcard = '1'
    GROUP BY tbi999013m.cd_hansya
            ,tbi999013m.cd_kaisya
),
nt8014m AS(
    SELECT
        t014m.cd_hansya
        , t014m.cd_kaisya
        , t014m.no_cyumon
        , MAX(IF(t014m.kb_nyukkanr = '01',t014m.dd_keijyou,NULL)) AS dd_keijyou1
        , MAX(IF(t014m.kb_nyukkanr = '02',t014m.dd_keijyou,NULL)) AS dd_keijyou2
    FROM ai21rep_ve_dx.tbg8014m t014m
    GROUP BY t014m.cd_hansya, t014m.cd_kaisya, t014m.no_cyumon
),
base_data AS (
  SELECT
    CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE) AS jp_today
    , DATE_TRUNC('MONTH', FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) AS current_month_start
    , LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AS last_month_end
    , tbbc017g.cd_hansya || tbbc017g.cd_kaisya || tbbc017g.no_cyumon || trim(tbbc017g.no_cyumoned) AS cd_pk
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,tbbc017g.cd_hansya || tbbc017g.cd_kaisya || LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_hansya || tbbc017g.cd_kaisya || tbbc017g.cd_jytyuten) AS cd_hankaisya_tenpo
    , tbbc017g.cd_hansya
    , tbbc017g.cd_kaisya
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_jytyuten) AS cd_jytyuten
    , tbbc017g.no_cyumon
    , tbbc017g.no_cyumoned
    , tbbc017g.dd_touroku
    , tbbc017g.dd_nosya
    , tbbc017g.dd_urikzumi
    , tbbc017g.dd_jucyu
    , tbbc017g.dd_torikesi
    , tbbc017g.dd_torotrkk
    , tbbc020g.dd_minasksy
    , tbbc020g.dd_kaisyuyo
    , tbbc020g.ki_haseirui
    , tbbc020g.ki_genknykg
    , tbbc020g.ki_sitanykg
    , tbbc020g.ki_fuharnyk
    , tbbc020g.ki_genkhasg
    , tbbc020g.ki_fuharhsk
    , CASE tbbc020g.mj_keiykeit
        WHEN '1' THEN '現金'
        WHEN '2' THEN '後払い'
        WHEN '3' THEN '自社割賦'
        WHEN '4' THEN '信用購入斡旋'
        WHEN '5' THEN '債権譲渡'
        WHEN '' THEN 'その他'
    END AS mj_keiykeit
    , TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou1 AS STRING), 'yyyyMMdd') AS dd_keijyou1
    , TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou2 AS STRING), 'yyyyMMdd') AS dd_keijyou2
    , COALESCE(tbi002001m.su_minosya, 14) AS su_minosya
    , COALESCE(tbi002001m.su_touroku, 30) AS su_touroku
    , COALESCE(tbi002001m.su_jucyu, 30) AS su_jucyu
  FROM
    ai21rep_ve_dx.tbbc017g tbbc017g
  LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
      ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
      AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
      AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
      AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
LEFT JOIN (
    SELECT
         tbbc017g.cd_hansya
        ,tbbc017g.cd_kaisya
        ,tbbc017g.no_cyumon
        ,tbbc017g.no_cyumoned
        ,MIN(tbg8014m.no_denpyo) AS no_min_denpyo
    FROM ai21rep_ve_dx.tbg8014m tbg8014m
    RIGHT JOIN ai21rep_ve_dx.tbbc017g tbbc017g
        ON tbg8014m.cd_hansya = tbbc017g.cd_hansya
        AND tbg8014m.cd_kaisya = tbbc017g.cd_kaisya
        AND TRIM(tbg8014m.no_cyumon) = (TRIM(tbbc017g.no_cyumon) || TRIM(tbbc017g.no_cyumoned))
        AND tbg8014m.kb_urinyuki = '2'
        AND tbg8014m.kb_nyukkanr = '01'
    GROUP BY
         tbbc017g.cd_hansya
        ,tbbc017g.cd_kaisya
        ,tbbc017g.no_cyumon
        ,tbbc017g.no_cyumoned
) tbbc017g_2
ON tbbc017g_2.cd_hansya = tbbc017g.cd_hansya
AND tbbc017g_2.cd_kaisya = tbbc017g.cd_kaisya
AND tbbc017g_2.no_cyumon = tbbc017g.no_cyumon
AND tbbc017g_2.no_cyumoned = tbbc017g.no_cyumoned
    LEFT JOIN dx_ve.tbi013001m tbi002001m
        ON tbbc017g.cd_hansya = tbi002001m.cd_hansya
        AND tbbc017g.cd_kaisya = tbi002001m.cd_kaisya
LEFT JOIN nt8014m nt8014m1
    ON nt8014m1.cd_hansya = tbbc017g.cd_hansya
    AND nt8014m1.cd_kaisya = tbbc017g.cd_kaisya
    AND nt8014m1.no_cyumon = TRIM(CONCAT(tbbc017g.no_cyumon, tbbc017g.no_cyumoned))
  WHERE ISNOTTRUE((NVL(tbbc020g.ki_haseirui ,0) - NVL(tbbc020g.ki_genknykg ,0) - NVL(tbbc020g.ki_sitanykg ,0) - NVL(tbbc020g.ki_fuharnyk ,0)) = 0
    AND((tbbc017g.dd_touroku IS NOT NULL
      AND tbbc017g.dd_nosya < DATE '2023-03-01'
      AND (tbbc017g.dd_urikzumi IS NULL OR tbbc017g.dd_urikzumi < DATE '2024-03-01'))
    OR (tbbc017g.dd_nosya IS NULL AND tbbc017g.dd_touroku < DATE '2023-03-01')
      OR tbbc017g.dd_urikzumi < DATE '2024-03-01'
      OR (tbbc017g.dd_touroku IS NULL AND tbbc017g.dd_jucyu < DATE '2020-12-01')))
    AND (tbbc017g.dd_torotrkk IS NULL OR (tbbc017g.dd_torotrkk IS NOT NULL AND (NVL(tbbc020g.ki_haseirui ,0) - NVL(tbbc020g.ki_genknykg ,0) - NVL(tbbc020g.ki_sitanykg ,0) - NVL(tbbc020g.ki_fuharnyk ,0)) <> 0))
    AND (
        LEFT(tbbc017g.kb_uriage, 1) = '1'
        OR (
        LEFT(tbbc017g.kb_uriage, 1) = '3'
        AND
        NOT((NVL(tbbc020g.ki_haseirui ,0) - NVL(tbbc020g.ki_genknykg ,0) - NVL(tbbc020g.ki_sitanykg ,0) - NVL(tbbc020g.ki_fuharnyk ,0)) = 0
        AND (NVL(tbbc020g.ki_genkhasg ,0) - NVL(tbbc020g.ki_genknykg ,0)) = 0
        AND (NVL(tbbc020g.ki_fuharhsk ,0) - NVL(tbbc020g.ki_fuharnyk ,0)) = 0
        AND (NVL(tbbc020g.ki_sitahasg ,0) - NVL(tbbc020g.ki_sitanykg ,0)) = 0)))
)
SELECT
  cd_pk AS `PK_販社会社注文NO枝番`
  , cd_hankaisya_tenpo AS `PK_販社会社店舗コード`
  , cd_hansya AS `販社コード`
  , cd_kaisya AS `会社コード`
  , IF(CONCAT_WS('',flg_1, flg_2, flg_3, flg_4, flg_5, flg_6, flg_a, flg_b, flg_c, flg_d, flg_e, flg_f) = '','99',CONCAT_WS('',flg_1, flg_2, flg_3, flg_4, flg_5, flg_6, flg_a, flg_b, flg_c, flg_d, flg_e, flg_f)) AS `アラート判断`
  ,no_cyumon AS `注文no`
  ,cd_jytyuten AS `店舗コード`
  ,dd_nosya AS `納車日`
  ,dd_touroku AS `登録日`
  ,dd_jucyu AS `受注日`
  ,flg_1
  ,flg_2
  ,flg_3
  ,flg_4
  ,flg_5
  ,flg_6
  ,flg_a
  ,flg_b
  ,flg_c
  ,flg_d
  ,flg_e
  ,flg_f
  ,flg
  ,dd_minasksy AS `見直し回収予定日`
  ,dd_kaisyuyo AS `回収予定日`
  ,su_minosya AS `未納車経過日`
  ,su_touroku AS `登録経過日`
  ,su_jucyu AS `受注経過日`
  FROM(
  SELECT
    cd_pk
    , cd_hankaisya_tenpo
    , cd_hansya
    , cd_kaisya
    , no_cyumon
    , cd_jytyuten
    , dd_nosya
    , dd_touroku
    , dd_jucyu
    , dd_minasksy
    , dd_kaisyuyo
    , su_minosya
    , su_touroku
    , su_jucyu
    , IF(COALESCE(dd_minasksy ,dd_kaisyuyo) IS NOT NULL AND COALESCE(dd_minasksy ,dd_kaisyuyo) < jp_today AND ((NVL(ki_genkhasg ,0) - NVL(ki_genknykg ,0) ) <> 0 OR (NVL(ki_fuharhsk ,0) - NVL(ki_fuharnyk ,0)) <> 0),'1','') AS flg_1
    , IF(dd_touroku IS NOT NULL AND (NVL(ki_haseirui ,0) - NVL(ki_genknykg ,0) - NVL(ki_sitanykg ,0) - NVL(ki_fuharnyk ,0)) < 0,'2','') AS flg_2
    , IF(dd_touroku IS NOT NULL AND dd_nosya IS NULL,'3','') AS flg_3
    , IF(dd_nosya IS NOT NULL AND ((NVL(ki_genkhasg ,0) - NVL(ki_genknykg ,0) ) <> 0 OR (NVL(ki_fuharhsk ,0) - NVL(ki_fuharnyk ,0)) <> 0) AND mj_keiykeit <> '後払い','4','') AS flg_4
    , IF(dd_nosya IS NOT NULL AND mj_keiykeit <> '後払い' AND (dd_keijyou1 > dd_nosya || dd_keijyou2 > dd_nosya),'5','') AS flg_5
    , IF(NVL(tbg8014m_2.ki_nyukinur2 - tbg8014m_2.ki_nyukinur3, 0) + NVL(tbg8014m_2.positive_count - tbg8014m_2.negative_count, 0) >= 3,'6','') AS flg_6
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL),'a','') AS flg_a
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_touroku) >= su_minosya AND (dd_nosya IS NULL OR TRUNC(dd_nosya, 'month') >= TRUNC(last_month_end, 'month')),'b','') AS flg_b
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_touroku) >= su_touroku,'c','') AS flg_c
    , IF(dd_jucyu IS NOT NULL AND dd_touroku IS NULL AND DATEDIFF(last_month_end, dd_jucyu) >= su_jucyu,'d','') AS flg_d
    , '' AS flg_e
    , '' AS flg_f
   , CASE
       WHEN dd_nosya IS NOT NULL AND mj_keiykeit <> '後払い' AND (dd_keijyou1 > dd_nosya || dd_keijyou2 > dd_nosya)
       THEN
           CASE
               WHEN dd_keijyou1 > dd_nosya AND dd_keijyou2 > dd_nosya
               THEN '1'
               WHEN dd_keijyou1 > dd_nosya
               THEN '2'
               ELSE '3'
           END
       ELSE ''
   END AS flg
  FROM base_data
  LEFT JOIN (
      SELECT
        tbg8014m.cd_hansya AS cd_hansya_1
        , tbg8014m.cd_kaisya AS cd_kaisya_1
        , TRIM(tbg8014m.no_cyumon) AS no_cyumon_1
        , SUM(IF(tbg8014m.kb_nyukkanr = '01',1,0)) AS cash_receipt
        , SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2),kb_genkin_table.kb_nyuukin_list) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur >= 1,1,0)) AS positive_count
        , SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2),kb_genkin_table.kb_nyuukin_list) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur <= -1,1,0)) AS negative_count
        , SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2),kb_crejcard_table.kb_nyuukin_list) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur >= 1,1,0)) AS ki_nyukinur2
        , SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2),kb_crejcard_table.kb_nyuukin_list) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur <= -1,1,0)) AS ki_nyukinur3
      FROM
        ai21rep_ve_dx.tbg8014m tbg8014m
      RIGHT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
          ON tbg8014m.cd_hansya = tbbc020g.cd_hansya
          AND tbg8014m.cd_kaisya = tbbc020g.cd_kaisya
          AND TRIM(tbg8014m.no_cyumon) = (TRIM(tbbc020g.no_cyumon) || TRIM(tbbc020g.no_cyumoned))
       LEFT JOIN kb_genkin_table
           ON kb_genkin_table.cd_hansya = tbg8014m.cd_hansya
           AND kb_genkin_table.cd_kaisya = tbg8014m.cd_kaisya
       LEFT JOIN kb_crejcard_table
           ON kb_crejcard_table.cd_hansya = tbg8014m.cd_hansya
           AND kb_crejcard_table.cd_kaisya = tbg8014m.cd_kaisya
      GROUP BY
        tbg8014m.cd_hansya,
        tbg8014m.cd_kaisya,
        TRIM(tbg8014m.no_cyumon)
  )tbg8014m_2
    ON base_data.cd_hansya = tbg8014m_2.cd_hansya_1
   AND base_data.cd_kaisya = tbg8014m_2.cd_kaisya_1
   AND (TRIM(base_data.no_cyumon) ||  TRIM(base_data.no_cyumoned)) = tbg8014m_2.no_cyumon_1
  ) maintable