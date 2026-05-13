DROP TABLE IF EXISTS gold.vbi002006;
CREATE TABLE gold.vbi002006 AS
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
base_data AS (
  SELECT
    CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE) AS jp_today
    , DATE_TRUNC('MONTH', FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) AS current_month_start
    , LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AS last_month_end
    , tbba001g.cd_hansya || tbba001g.cd_kaisya || tbba001g.no_cyumon || TRIM(tbba001g.no_cyumoned) AS cd_pk
    , tbba001g.cd_hansya || tbba001g.cd_kaisya || tbba001g.cd_tenpo AS cd_hankaisya_tenpo
    , tbba001g.cd_hansya
    , tbba001g.cd_kaisya
    , tbba001g.cd_tenpo
    , tbba001g.no_cyumon
    , tbba001g.no_cyumoned
    , tbba001g.dd_touroku
    , tbba001g.dd_nosya
    , tbba001g.dd_fr
    , tbba001g.dd_urikzumi
    , tbba001g.dd_jucyu
    , tbba001g.dd_torikesi
    , tbba001g.dd_torotrkk
    , tbba052g.dd_minasksy
    , tbba052g.dd_kaisyuyo
    , tbba052g.ki_haseirui
    , tbba052g.ki_genknykg
    , tbba052g.ki_sitanykg
    , tbba052g.ki_fuharnyk
    , tbba052g.ki_genkhasg
    , tbba052g.ki_fuharhsk
    , tbba052g.mj_keiykeit
    , COALESCE(tbi002001m.su_leadtime, 20) AS su_leadtime
    , COALESCE(tbi002001m.su_minosya, 30) AS su_minosya
    , COALESCE(tbi002001m.su_touroku, 90) AS su_touroku
    , COALESCE(tbi002001m.su_fr, 90) AS su_fr
    , COALESCE(tbi002001m.su_jucyu, 365) AS su_jucyu
  FROM
    ai21rep_ve_dx.tbba001g tbba001g
  LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g
      ON tbba001g.cd_hansya = tbba052g.cd_hansya
      AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
      AND tbba001g.no_cyumon = tbba052g.no_cyumon
      AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
  LEFT JOIN dx_ve.tbi002001m tbi002001m
      ON tbba001g.cd_hansya = tbi002001m.cd_hansya
      AND tbba001g.cd_kaisya = tbi002001m.cd_kaisya
  WHERE
    ISNOTTRUE(
        (NVL(tbba052g.ki_haseirui,0) - NVL(tbba052g.ki_genknykg,0) - NVL(tbba052g.ki_sitanykg,0) - NVL(tbba052g.ki_fuharnyk,0)) = 0
        AND((tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_nosya < DATE '2023-03-01'
            AND (tbba001g.dd_urikzumi IS NULL OR tbba001g.dd_urikzumi < DATE '2024-03-01'))
            OR (tbba001g.dd_nosya IS NULL AND tbba001g.dd_touroku < DATE '2023-03-01')
            OR tbba001g.dd_urikzumi < DATE '2024-03-01'
            OR (tbba001g.dd_touroku IS NULL AND tbba001g.dd_jucyu < DATE '2020-12-01')
            )
        )
    AND (tbba001g.dd_torotrkk IS NULL OR (tbba001g.dd_torotrkk IS NOT NULL AND (NVL(tbba052g.ki_haseirui,0) - NVL(tbba052g.ki_genknykg,0) - NVL(tbba052g.ki_sitanykg,0) - NVL(tbba052g.ki_fuharnyk,0)) <> 0))
    AND (LEFT(tbba001g.kb_haraidas, 1) = '1' OR (
        LEFT(tbba001g.kb_haraidas, 1) = '3'
        AND NOT((NVL(tbba052g.ki_haseirui,0) - NVL(tbba052g.ki_genknykg,0) - NVL(tbba052g.ki_sitanykg,0) - NVL(tbba052g.ki_fuharnyk,0)) = 0
        AND (NVL(tbba052g.ki_genkhasg,0) - NVL(tbba052g.ki_genknykg,0)) = 0
        AND (NVL(tbba052g.ki_fuharhsk,0) - NVL(tbba052g.ki_fuharnyk,0)) = 0
        AND (NVL(tbba052g.ki_sitahasg,0) - NVL(tbba052g.ki_sitanykg,0)) = 0)))
)
SELECT
  cd_pk AS pk_販社会社注文no枝番
  , cd_hankaisya_tenpo AS pk_販社会社店舗コード
  , cd_hansya AS 販社コード
  , cd_kaisya AS 会社コード
  , IF(CONCAT_WS('',flg_1, flg_2, flg_3, flg_4, flg_5, flg_6, flg_a, flg_b, flg_c, flg_d, flg_e, flg_f) = '','99',CONCAT_WS('',flg_1, flg_2, flg_3, flg_4, flg_5, flg_6, flg_a, flg_b, flg_c, flg_d, flg_e, flg_f)) AS アラート判断
  , no_cyumon AS 注文ＮＯ
  , cd_tenpo AS 店舗コード
  , dd_nosya AS 納車日
  , dd_touroku AS 登録日
  , dd_fr AS 振当日
  , dd_jucyu AS 受注日
  , flg_1
  , flg_2
  , flg_3
  , flg_4
  , flg_5
  , flg_6
  , flg_a
  , flg_b
  , flg_c
  , flg_d
  , flg_e
  , flg_f
  , dd_minasksy AS 見直し回収予定日
  , dd_kaisyuyo AS 回収予定日
  , su_leadtime AS リードタイム日
  , su_minosya AS 未納車経過日
  , su_touroku AS 登録経過日
  , su_fr AS 振当経過日
  , su_jucyu AS 受注経過日
  FROM(
  SELECT
    cd_pk
    , cd_hankaisya_tenpo
    , cd_hansya
    , cd_kaisya
    , no_cyumon
    , cd_tenpo
    , dd_nosya
    , dd_touroku
    , dd_fr
    , dd_jucyu
    , dd_minasksy
    , dd_kaisyuyo
    , su_leadtime
    , su_minosya
    , su_touroku
    , su_fr
    , su_jucyu
    , IF(COALESCE(dd_minasksy,dd_kaisyuyo) IS NOT NULL AND COALESCE(dd_minasksy,dd_kaisyuyo) < jp_today AND (NVL(ki_haseirui,0) - NVL(ki_genknykg,0) - NVL(ki_sitanykg,0) - NVL(ki_fuharnyk,0)) <> 0,'1','') AS flg_1
    , IF(dd_touroku IS NOT NULL AND (NVL(ki_haseirui,0) - NVL(ki_genknykg,0) - NVL(ki_sitanykg,0) - NVL(ki_fuharnyk,0)) < 0,'2','') AS flg_2
    , IF(dd_touroku IS NOT NULL AND dd_nosya IS NULL,'3','') AS flg_3
    , IF(dd_nosya IS NOT NULL AND ((NVL(ki_genkhasg,0) - NVL(ki_genknykg,0) ) <> 0 OR (NVL(ki_fuharhsk,0) - NVL(ki_fuharnyk,0)) <> 0) AND mj_keiykeit <> '4','4','') AS flg_4
    , IF(NVL(tbg8014m_2.ki_nyukinur2 - tbg8014m_2.ki_nyukinur3, 0) + NVL(tbg8014m_2.positive_count - tbg8014m_2.negative_count, 0) >= 3,'5','') AS flg_5,
    , IF(DATEDIFF(dd_nosya, dd_fr) != 0 AND DATEDIFF(dd_nosya, dd_fr) >= su_leadtime,'6','') AS flg_6
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL),'a','') AS flg_a
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_touroku) >= su_minosya AND dd_nosya IS NULL,'b','') AS flg_b
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_touroku) >= su_touroku,'c','') AS flg_c
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_fr) >= su_fr,'d','') AS flg_d
    , IF((dd_touroku < current_month_start AND dd_touroku IS NOT NULL) AND (dd_urikzumi > last_month_end OR dd_urikzumi IS NULL) AND DATEDIFF(last_month_end, dd_jucyu) >= su_jucyu,'e','') AS flg_e
    , IF(dd_torikesi IS NOT NULL AND dd_torotrkk IS NULL AND (nvl(ki_haseirui,0) - nvl(ki_genknykg,0) - nvl(ki_sitanykg,0) - nvl(ki_fuharnyk,0)) <> 0,'f','') AS flg_f
  FROM base_data
  LEFT JOIN (
      SELECT
        tbg8014m.cd_hansya AS cd_hansya_1
        , tbg8014m.cd_kaisya AS cd_kaisya_1
        , TRIM(tbg8014m.no_cyumon) AS no_cyumon_1
        , SUM(IF(tbg8014m.kb_nyukkanr = '01',1,0)) AS cash_receipt
        , SUM(IF(FIND_IN_SET(SUBSTR(tbg8014m.kb_nyuukin, 1, 2), (kb_genkin_table.kb_nyuukin_list)) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur >= 1,1,0)) AS positive_count
        , SUM(IF(FIND_IN_SET(SUBSTR(tbg8014m.kb_nyuukin, 1, 2), (kb_genkin_table.kb_nyuukin_list)) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur <= -1,1,0)) AS negative_count
        , SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2), (kb_crejcard_table.kb_nyuukin_list)) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur >= 1,1,0)) AS ki_nyukinur2
        , SUM(IF(FIND_IN_SET(LEFT(tbg8014m.kb_nyuukin, 2), (kb_crejcard_table.kb_nyuukin_list)) > 0 AND tbg8014m.kb_urinyuki = '2' AND tbg8014m.ki_nyukinur <= -1,1,0)) AS ki_nyukinur3
      FROM
        ai21rep_ve_dx.tbg8014m tbg8014m
      RIGHT JOIN ai21rep_ve_dx.tbba052g tbba052g
          ON tbg8014m.cd_hansya = tbba052g.cd_hansya
          AND tbg8014m.cd_kaisya = tbba052g.cd_kaisya
          AND TRIM(tbg8014m.no_cyumon) = (TRIM(tbba052g.no_cyumon) || TRIM(tbba052g.no_cyumoned))
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
;
