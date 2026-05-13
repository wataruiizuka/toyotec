DROP TABLE IF EXISTS gold.vbi013005;
CREATE TABLE gold.vbi013005 AS
SELECT
    tbbc017g.cd_hansya AS `販社コード`
    , tbbc017g.cd_kaisya AS `会社コード`
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_1.no_min_denpyo) > 0,tbbc017g.cd_hansya || tbbc017g.cd_kaisya || LEFT(tbbc017g_1.no_min_denpyo, 3),tbbc017g.cd_hansya || tbbc017g.cd_kaisya || tbbc017g.cd_jytyuten) AS `販社会社店舗コード`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND (tbbc017g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'MM') OR tbbc017g.dd_urikzumi IS NULL),1,0) AS `登録済件数`
    , IF(COALESCE(tbbc020g.su_sitadori, 0) = 0 AND tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND (tbbc017g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'MM') OR tbbc017g.dd_urikzumi IS NULL),1,0) AS `下取車なし総件数`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) != 0,1,0) AS `未回収総件数`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) != 0,tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk,0) AS `未回収総金額`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_genkhasg - tbbc020g.ki_genknykg) != 0,1,0) AS `未回収現金総件数`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_genkhasg - tbbc020g.ki_genknykg) != 0,tbbc020g.ki_genkhasg - tbbc020g.ki_genknykg,0) AS `未回収現金総金額`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_sitahasg - tbbc020g.ki_sitanykg) != 0,1,0) AS `未回収下取総件数`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbbc017g.dd_urikzumi IS NULL AND (tbbc020g.ki_sitahasg - tbbc020g.ki_sitanykg) != 0,tbbc020g.ki_sitahasg - tbbc020g.ki_sitanykg,0) AS `未回収下取総金額`
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND (tbbc017g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'MM') OR tbbc017g.dd_urikzumi IS NULL) AND tbbc017g.dd_nosya IS NULL,1,0) AS `登録済未納車件数`
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
) tbbc017g_1
ON tbbc017g_1.cd_hansya = tbbc017g.cd_hansya
AND tbbc017g_1.cd_kaisya = tbbc017g.cd_kaisya
AND tbbc017g_1.no_cyumon = tbbc017g.no_cyumon
AND tbbc017g_1.no_cyumoned = tbbc017g.no_cyumoned
INNER JOIN dx_ve.vbi013001_en vbi013001
    ON vbi013001.cd_hansya = tbbc017g.cd_hansya
    AND vbi013001.cd_kaisya = tbbc017g.cd_kaisya
    AND vbi013001.cd_tenpo = IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_1.no_min_denpyo) > 0,LEFT(tbbc017g_1.no_min_denpyo, 3),tbbc017g.cd_jytyuten)
LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
    ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
    AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
    AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
    AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
WHERE tbbc017g.dd_torikesi IS NULL
    AND (dd_torotrkk IS NULL OR (dd_torotrkk IS NOT NULL AND (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) != 0))
    AND LEFT(CAST (tbbc017g.kb_uriage AS STRING), 1) = '1'
    AND ISNOTTRUE(
        (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) = 0
        AND((tbbc017g.dd_touroku IS NOT NULL
            AND tbbc017g.dd_nosya < DATE '2023-03-01'
            AND (tbbc017g.dd_urikzumi IS NULL OR tbbc017g.dd_urikzumi < DATE '2024-03-01'))
        OR (tbbc017g.dd_nosya IS NULL AND tbbc017g.dd_touroku < DATE '2023-03-01')
            OR tbbc017g.dd_urikzumi < DATE '2024-03-01'
            OR (tbbc017g.dd_touroku IS NULL AND tbbc017g.dd_jucyu < DATE '2020-12-01')
        ))