DROP TABLE IF EXISTS gold.vbi002004_en;
CREATE TABLE gold.vbi002004_en AS
SELECT
    tbba001g.cd_hansya
    , tbba001g.cd_kaisya
    , tbba001g.cd_tenpo
    , tbba001g.cd_hansya || tbba001g.cd_kaisya || tbba001g.cd_tenpo AS cd_hansya_kaisya_tenpo
    , IF(MONTH(tbba001g.dd_jucyu) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')),1,0) AS su_order
    , IF(MONTH(tbba001g.dd_touroku) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')),1,0) AS su_registered_vehicle
    , IF(MONTH(tbba001g.dd_touroku) = MONTH(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST')) AND tbba052g.su_sitadori = 0,1,0) AS su_no_trade_in_vehicle_registered_this_month
    , COALESCE(tbba001g_1.su_avg_lead_time, 0) AS su_average_lead_time_for_collections_completed_this_month
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL,1,0) AS su_currently_registered_but_uncollected_case
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL,tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk,0) AS su_currently_registered_uncollected_amount
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL AND TRUNC(tbba001g.dd_touroku, 'month') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'),1,0) AS su_registered_but_uncollected_items_from_the_previous_month
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL AND TRUNC(tbba001g.dd_touroku, 'month') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'),tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk,0) AS su_uncollected_amount_registered_in_the_previous_month
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL AND (TRUNC(tbba001g.dd_touroku, 'year') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') OR (TRUNC(tbba001g.dd_touroku, 'year') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') AND TRUNC(tbba001g.dd_touroku, 'month') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'))),1,0) AS su_registered_but_uncollected_items_from_the_previous_month_or_earlier
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL AND (TRUNC(tbba001g.dd_touroku, 'year') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') OR (TRUNC(tbba001g.dd_touroku, 'year') = TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'year') AND TRUNC(tbba001g.dd_touroku, 'month') < TRUNC(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1), 'month'))),tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk,0) AS su_uncollected_amount_registered_in_the_previous_month_or_earlier
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL,1,NULL) AS su_pieces
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_urikzumi IS NULL,(tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) / 1000,NULL)   AS su_amount
    , v2001.sort_order
FROM
    ai21rep_ve_dx.tbba001g tbba001g
INNER JOIN dx_ve.vbi002001_en v2001
    ON v2001.cd_hansya = tbba001g.cd_hansya
    AND v2001.cd_kaisya = tbba001g.cd_kaisya
    AND v2001.cd_tenpo = tbba001g.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g
    ON tbba001g.cd_hansya = tbba052g.cd_hansya
    AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
    AND tbba001g.no_cyumon = tbba052g.no_cyumon
    AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
LEFT JOIN (
    SELECT
        tbba001g.cd_hansya
        , tbba001g.cd_kaisya
        , tbba001g.cd_tenpo
        , AVG(DATEDIFF(
            CAST(tbba001g.dd_urikzumi AS DATE),
            CAST(tbba001g.dd_fr AS DATE)
          )
        )
    AS su_avg_lead_time
    FROM
        ai21rep_ve_dx.tbba001g tbba001g
    LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g
        ON tbba001g.cd_hansya = tbba052g.cd_hansya
        AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
        AND tbba001g.no_cyumon = tbba052g.no_cyumon
        AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
    WHERE
        tbba001g.dd_touroku IS NOT NULL
        AND (tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) = 0
        AND TRUNC(tbba001g.dd_urikzumi, 'month') = TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'month')
    GROUP BY
        tbba001g.cd_hansya,
        tbba001g.cd_kaisya,
        tbba001g.cd_tenpo) tbba001g_1
    ON tbba001g.cd_hansya = tbba001g_1.cd_hansya
    AND tbba001g.cd_kaisya = tbba001g_1.cd_kaisya
    AND tbba001g.cd_tenpo = tbba001g_1.cd_tenpo
WHERE tbba001g.dd_torikesi IS NULL
    AND (dd_torotrkk IS NULL
        OR (dd_torotrkk IS NOT NULL
            AND (tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) != 0
            )
        )
    AND LEFT(CAST (tbba001g.kb_haraidas AS STRING), 1) = '1'
    AND ISNOTTRUE(
        (tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) = 0
        AND(
            (
                tbba001g.dd_touroku IS NOT NULL
                AND tbba001g.dd_nosya < DATE '2023-03-01'
                AND (tbba001g.dd_urikzumi IS NULL OR tbba001g.dd_urikzumi < DATE '2024-03-01')
            )
            OR (tbba001g.dd_nosya IS NULL AND tbba001g.dd_touroku < DATE '2023-03-01')
            OR tbba001g.dd_urikzumi < DATE '2024-03-01'
            OR (tbba001g.dd_touroku IS NULL AND tbba001g.dd_jucyu < DATE '2020-12-01')
            )
        )
;
