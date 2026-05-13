DROP TABLE IF EXISTS gold.vbi013011;
CREATE TABLE gold.vbi013011 AS
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
        , MAX(IF(t014m.kb_nyukkanr = '01', t014m.dd_keijyou, NULL)) AS dd_keijyou1
        , MAX(IF(t014m.kb_nyukkanr = '02', t014m.dd_keijyou, NULL)) AS dd_keijyou2
        , MAX(IF(t014m.kb_nyukkanr = '03', t014m.dd_keijyou, NULL)) AS dd_keijyou3
    FROM ai21rep_ve_dx.tbg8014m t014m
    GROUP BY t014m.cd_hansya, t014m.cd_kaisya, t014m.no_cyumon
),
kt8014m AS(
    SELECT
        tbbc017g.cd_hansya
        , tbbc017g.cd_kaisya
        , tbbc017g.no_cyumon
        , TRIM(tbbc017g.no_cyumoned) AS no_cyumoned
        , SUM(IF(t014m.dd_keijyou < CAST(FROM_TIMESTAMP(tbbc017g.dd_touroku, 'yyyyMMdd') AS INT),t014m.ki_nyukinur,0)) AS ki_nyukinur1
        , SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_crejcard_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur >= 1,1,0)) AS ki_nyukinur2
        , SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_crejcard_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur <= -1,1,0)) AS ki_nyukinur3
        , SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_genkin_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur >= 1,1,0)) AS ki_nyukinur4
        , SUM(IF(FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2),kb_genkin_table.kb_nyuukin_list) > 0 AND t014m.ki_nyukinur <= -1,1,0)) AS ki_nyukinur5
    FROM ai21rep_ve_dx.tbbc017g tbbc017g
    INNER JOIN ai21rep_ve_dx.tbg8014m t014m
        ON t014m.cd_hansya = tbbc017g.cd_hansya
        AND t014m.cd_kaisya = tbbc017g.cd_kaisya
        AND TRIM(t014m.no_cyumon) = TRIM(CONCAT(tbbc017g.no_cyumon, tbbc017g.no_cyumoned))
        AND t014m.kb_urinyuki = '2'
     LEFT JOIN kb_genkin_table
         ON kb_genkin_table.cd_hansya = tbbc017g.cd_hansya
         AND kb_genkin_table.cd_kaisya = tbbc017g.cd_kaisya
     LEFT JOIN kb_crejcard_table
         ON kb_crejcard_table.cd_hansya = tbbc017g.cd_hansya
         AND kb_crejcard_table.cd_kaisya = tbbc017g.cd_kaisya
    GROUP BY tbbc017g.cd_hansya, tbbc017g.cd_kaisya, tbbc017g.no_cyumon, TRIM(tbbc017g.no_cyumoned)
)
SELECT
    tbbc017g.cd_hansya AS `販社コード`
    , tbbc017g.cd_kaisya AS `会社コード`
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_jytyuten) AS `店舗コード`
    , tbbc017g.no_cyumon AS `注文no`
    , TRIM(tbbc017g.no_cyumoned) AS `注文枝番`
    , CONCAT(tbbc017g.cd_hansya, tbbc017g.cd_kaisya, tbbc017g.no_cyumon, TRIM(tbbc017g.no_cyumoned)) AS `pk_販社会社注文no枝番`
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,tbbc017g.cd_hansya || tbbc017g.cd_kaisya || LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_hansya || tbbc017g.cd_kaisya || tbbc017g.cd_jytyuten) AS `販社会社店舗コード`
    , v2001.kj_tentanms AS `店舗略称`
    , v2001.zone_name AS `エリア統括部`
    , v2001.cd_zon AS `ゾーンコード`
    , v2001.mj_sortjyun AS `ソート順`
    , IF(tbbc017g.dd_touroku IS NOT NULL,'登録済','未登録') AS `登録`
    , IF(tbbc017g.dd_nosya IS NOT NULL,'納車済','未納車') AS `納車`
    , IF(tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk = 0,'残高なし','残高あり') AS `売掛残高`
    , t014m.kj_syainmei AS `社員名`
    , DATEDIFF(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), tbbc017g.dd_touroku) AS `売上経過日数`
    , CONCAT(REGEXP_REPLACE(tbbc017g.kj_kainmei1, '　+$', ''), REGEXP_REPLACE(tbbc017g.kj_kainmei2, '　+$', '')) AS `買主名`
    , CONCAT(REGEXP_REPLACE(tbbc017g.kj_meigime1, '　+$', ''), REGEXP_REPLACE(tbbc017g.kj_meigime2, '　+$', '')) AS `名義人`
    , CASE tbbc020g.mj_keiykeit
        WHEN '1' THEN '現金'
        WHEN '2' THEN '後払い'
        WHEN '3' THEN '自社割賦'
        WHEN '4' THEN '信用購入斡旋'
        WHEN '5' THEN '債権譲渡'
        WHEN ''  THEN 'その他'
    END AS `契約形態`
    , TRIM(CONCAT(tbbc017g.no_cyumon, tbbc017g.no_cyumoned)) AS `注文NO_枝番`
    , IF(INSTR(tbbc001g.mj_katasiki, '-') > 0,SUBSTR(tbbc001g.mj_katasiki, 1, INSTR(tbbc001g.mj_katasiki, '-') - 1),tbbc001g.mj_katasiki) AS `型式`
    , tbbc017g.dd_jucyu AS `受注日`
    , tbbc020g.dd_maeuknyu AS `申込金受領日`
    , tbbc017g.dd_touroku AS `登録日`
    , tbbc017g.dd_nosya AS `納車日`
    , NVL(tbbc020g.dd_minasksy, tbbc020g.dd_kaisyuyo) AS `回収予定日`
    , TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou1 AS STRING), 'yyyyMMdd') AS `最終入金日（現金）`
    , TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou2 AS STRING), 'yyyyMMdd') AS `最終入金日（割賦）`
    , TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou3 AS STRING), 'yyyyMMdd') AS `下取完了日`
    , tbbc017g.dd_urikzumi AS `完了`
    , (NVL(tbbc020g.ki_haseirui ,0) - NVL(tbbc020g.ki_genknykg ,0) - NVL(tbbc020g.ki_sitanykg,0) - NVL(tbbc020g.ki_fuharnyk,0)) as `売掛金残高合計`
    , (NVL(tbbc020g.ki_genkhasg ,0) - NVL(tbbc020g.ki_genknykg ,0)) AS `現金残高`
    , (NVL(tbbc020g.ki_fuharhsk ,0) - NVL(tbbc020g.ki_fuharnyk ,0)) AS `割賦残高`
    , (NVL(tbbc020g.ki_sitahasg ,0) - NVL(tbbc020g.ki_sitanykg ,0)) AS `下取車残高`
    , IF (
        tbbc017g.dd_touroku IS NULL OR nt8014m1.dd_keijyou1 IS NULL OR TO_TIMESTAMP(CAST(nt8014m1.dd_keijyou1 AS STRING), 'yyyyMMdd') < tbbc017g.dd_touroku,
        tbbc020g.ki_nyuruike,
        NVL(kt8014m.ki_nyukinur1, 0)
    ) AS `申込金`,
    NVL(kt8014m.ki_nyukinur4 - kt8014m.ki_nyukinur5, 0) AS `現金入金回数`
    , NVL(kt8014m.ki_nyukinur2 - kt8014m.ki_nyukinur3, 0) AS `カード入金回数`
    , tbbc017g.dd_nosya AS `振当-納車`
    , DATEDIFF(tbbc017g.dd_nosya, tbbc017g.dd_touroku) AS `登録-納車`
    , DATEDIFF(tbbc017g.dd_urikzumi, tbbc017g.dd_touroku) AS `登録-完了`
    , CASE LEFT(tbbc017g.kb_uriage, 1)
        WHEN '1' THEN '一般売上'
        WHEN '3' THEN 'リース'
    END AS `払出区分`
    , IF(
        t051g1.kb_seibetu = '1' AND t051g2.kb_seibetu = '1'
        OR t051g1.kb_seibetu = '2' AND t051g2.kb_seibetu = '1'
        OR t051g1.kb_seibetu = '1' AND t051g2.kb_seibetu = '2'
        OR t051g1.kb_seibetu = '2' AND t051g2.kb_seibetu = '2',
        '個人',
        '法人'
    ) AS `法人個人区分`,
    tbbc020g.ki_haseirui AS `発生累計`
    , tbbc017g.dt_saisinup AS `更新日時`
    , CASE
        WHEN tbbc017g.dd_nosya IS NOT NULL AND tbbc017g.dd_urikzumi IS NOT NULL THEN
            CASE
                WHEN DATEDIFF(tbbc017g.dd_nosya, tbbc017g.dd_urikzumi) <> 0
                    THEN
                        DATEDIFF(tbbc017g.dd_nosya, tbbc017g.dd_urikzumi)
                    ELSE 0
            END
        ELSE NULL
    END AS `納車～完了`
FROM ai21rep_ve_dx.tbbc017g tbbc017g
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
INNER JOIN dx_ve.vbi013001_en v2001
    ON v2001.cd_hansya = tbbc017g.cd_hansya
    AND v2001.cd_kaisya = tbbc017g.cd_kaisya
    AND v2001.cd_tenpo = IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_jytyuten)
LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
    ON tbbc020g.cd_hansya = tbbc017g.cd_hansya
    AND tbbc020g.cd_kaisya = tbbc017g.cd_kaisya
    AND tbbc020g.no_cyumon = tbbc017g.no_cyumon
    AND TRIM(tbbc020g.no_cyumoned) = TRIM(tbbc017g.no_cyumoned)
LEFT JOIN ai21rep_ve_dx.tbv0014m t014m
    ON t014m.cd_hansya = tbbc017g.cd_hansya
    AND t014m.cd_kaisya = tbbc017g.cd_kaisya
    AND t014m.cd_syain = tbbc017g.cd_hanstaff
LEFT JOIN nt8014m nt8014m1
    ON nt8014m1.cd_hansya = tbbc017g.cd_hansya
    AND nt8014m1.cd_kaisya = tbbc017g.cd_kaisya
    AND TRIM(nt8014m1.no_cyumon) = TRIM(concat(tbbc017g.no_cyumon, tbbc017g.no_cyumoned))
LEFT JOIN kt8014m
    ON kt8014m.cd_hansya = tbbc017g.cd_hansya
    AND kt8014m.cd_kaisya = tbbc017g.cd_kaisya
    AND TRIM(kt8014m.no_cyumon) = tbbc017g.no_cyumon
    AND TRIM(kt8014m.no_cyumoned) = TRIM(tbbc017g.no_cyumoned)
LEFT JOIN ai21rep_ve_dx.tbbc018g t051g1
    ON t051g1.cd_hansya = tbbc017g.cd_hansya
    AND t051g1.cd_kaisya = tbbc017g.cd_kaisya
    AND t051g1.no_cyumon = tbbc017g.no_cyumon
    AND TRIM(t051g1.no_cyumoned) = TRIM(tbbc017g.no_cyumoned)
    AND t051g1.kb_kokyaku = '1'
LEFT JOIN ai21rep_ve_dx.tbbc018g t051g2
    ON t051g2.cd_hansya = tbbc017g.cd_hansya
    AND t051g2.cd_kaisya = tbbc017g.cd_kaisya
    AND t051g2.no_cyumon = tbbc017g.no_cyumon
    AND TRIM(t051g2.no_cyumoned) = TRIM(tbbc017g.no_cyumoned)
    AND t051g2.kb_kokyaku = '2'
LEFT JOIN ai21rep_ve_dx.tbbc001g tbbc001g
    ON tbbc017g.cd_hansya = tbbc001g.cd_hansya
    AND tbbc017g.cd_kaisya = tbbc001g.cd_kaisya
    AND tbbc017g.no_syaryou = tbbc001g.no_syaryou
WHERE ISNOTTRUE(
    (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) = 0
    AND((tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_nosya < DATE '2023-03-01'
        AND (tbbc017g.dd_urikzumi IS NULL OR tbbc017g.dd_urikzumi < DATE '2024-03-01'))
        OR (tbbc017g.dd_nosya IS NULL AND tbbc017g.dd_touroku < DATE '2023-03-01')
        OR tbbc017g.dd_urikzumi < DATE '2024-03-01'
        OR (tbbc017g.dd_touroku IS NULL AND tbbc017g.dd_jucyu < DATE '2020-12-01')
        )
    )
AND (tbbc017g.dd_torotrkk IS NULL
    OR (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) <> 0)
AND (
        LEFT(tbbc017g.kb_uriage, 1) = '1'
    OR (
        LEFT(tbbc017g.kb_uriage, 1) = '3'
        AND
            NOT((tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) = 0
            AND (tbbc020g.ki_genkhasg - tbbc020g.ki_genknykg) = 0
            AND (tbbc020g.ki_fuharhsk - tbbc020g.ki_fuharnyk) = 0
            AND (tbbc020g.ki_sitahasg - tbbc020g.ki_sitanykg) = 0
            )
        )
    )