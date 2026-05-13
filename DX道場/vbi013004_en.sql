DROP TABLE IF EXISTS gold.vbi013004_en;
CREATE TABLE gold.vbi013004_en AS
SELECT
    tbbc017g.cd_hansya
    , tbbc017g.cd_kaisya
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_jytyuten) AS cd_jytyuten
    , IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,tbbc017g.cd_hansya || tbbc017g.cd_kaisya || LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_hansya || tbbc017g.cd_kaisya || tbbc017g.cd_jytyuten) AS cd_hansya_kaisya_jytyuten
    , IF(MONTH(tbbc017g.dd_jucyu) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')),1,0) AS su_jucyu
    , IF(MONTH(tbbc017g.dd_touroku) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')),1,0) AS su_touroku
    , IF(MONTH(tbbc017g.dd_touroku) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) AND tbbc020g.su_sitadori = 0,1,0) AS no_trade_in_vehicles_registered_this_month
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL,1,0) AS currently_registered_but_uncollected_cases
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL,tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk,0) AS currently_registered_uncollected_amount
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL AND TRUNC(tbbc017g.dd_touroku, 'month') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'),1,0) AS registered_but_uncollected_items_from_the_previous_month
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL AND TRUNC(tbbc017g.dd_touroku, 'month') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'),tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk,0) AS uncollected_amount_registered_in_the_previous_month
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL AND (TRUNC(tbbc017g.dd_touroku, 'year') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') OR (TRUNC(tbbc017g.dd_touroku, 'year') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') AND TRUNC(tbbc017g.dd_touroku, 'month') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'))),1,0) AS uncollected_cases_registered_two_months_prior
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL AND (TRUNC(tbbc017g.dd_touroku, 'year') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') OR (TRUNC(tbbc017g.dd_touroku, 'year') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') AND TRUNC(tbbc017g.dd_touroku, 'month') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'))),tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk,0) AS uncollected_amount_registered_two_months_prior
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL,1,NULL) AS su_pieces
    , IF(tbbc017g.dd_touroku IS NOT NULL AND tbbc017g.dd_urikzumi IS NULL,(tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) / 1000,NULL) AS su_amount
    , vbi013001.mj_sortjyun
FROM ai21rep_ve_dx.tbbc017g tbbc017g
LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
    ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
    AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
    AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
    AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
LEFT JOIN (
    SELECT
        tbbc017g.cd_hansya
        , tbbc017g.cd_kaisya
        , tbbc017g.cd_jytyuten
    FROM
        ai21rep_ve_dx.tbbc017g tbbc017g
    LEFT JOIN ai21rep_ve_dx.tbbc020g tbbc020g
        ON tbbc017g.cd_hansya = tbbc020g.cd_hansya
        AND tbbc017g.cd_kaisya = tbbc020g.cd_kaisya
        AND tbbc017g.no_cyumon = tbbc020g.no_cyumon
        AND TRIM(tbbc017g.no_cyumoned) = TRIM(tbbc020g.no_cyumoned)
    WHERE tbbc017g.dd_touroku IS NOT NULL
        AND (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) = 0
        AND TRUNC(tbbc017g.dd_urikzumi, 'month') = TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'month')
    GROUP BY
        tbbc017g.cd_hansya,
        tbbc017g.cd_kaisya,
        tbbc017g.cd_jytyuten) tbbc017g_1
    ON tbbc017g.cd_hansya = tbbc017g_1.cd_hansya
    AND tbbc017g.cd_kaisya = tbbc017g_1.cd_kaisya
    AND tbbc017g.cd_jytyuten = tbbc017g_1.cd_jytyuten
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
INNER JOIN dx_ve.vbi013001_en vbi013001
    ON vbi013001.cd_hansya = tbbc017g.cd_hansya
    AND vbi013001.cd_kaisya = tbbc017g.cd_kaisya
    AND vbi013001.cd_tenpo = IF(LEFT(tbbc017g.no_cyumon, 3) = 'TAD' AND LENGTH(tbbc017g_2.no_min_denpyo) > 0,LEFT(tbbc017g_2.no_min_denpyo, 3),tbbc017g.cd_jytyuten)
WHERE tbbc017g.dd_torikesi IS NULL
    AND (dd_torotrkk IS NULL OR (dd_torotrkk IS NOT NULL AND (tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) != 0))
    AND LEFT(CAST (tbbc017g.kb_uriage AS STRING), 1) = '1'
    AND ISNOTTRUE((tbbc020g.ki_haseirui - tbbc020g.ki_genknykg - tbbc020g.ki_sitanykg - tbbc020g.ki_fuharnyk) = 0
        AND((tbbc017g.dd_touroku IS NOT NULL
            AND tbbc017g.dd_nosya < DATE '2023-03-01'
            AND (tbbc017g.dd_urikzumi IS NULL OR tbbc017g.dd_urikzumi < DATE '2024-03-01'))
        OR (tbbc017g.dd_nosya IS NULL AND tbbc017g.dd_touroku < DATE '2023-03-01')
            OR tbbc017g.dd_urikzumi < DATE '2024-03-01'
            OR (tbbc017g.dd_touroku IS NULL AND tbbc017g.dd_jucyu < DATE '2020-12-01')))