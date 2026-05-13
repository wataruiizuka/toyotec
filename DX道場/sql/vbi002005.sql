DROP TABLE IF EXISTS gold.vbi002005;
CREATE TABLE gold.vbi002005 AS
SELECT
    tbba001g.cd_hansya AS 販社コード
    , tbba001g.cd_kaisya AS 会社コード
    , tbba001g.cd_hansya || tbba001g.cd_kaisya || tbba001g.cd_tenpo AS 販社会社店舗コード
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'),-1)) AND (tbba001g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(),'JST'),'MM') OR tbba001g.dd_urikzumi IS NULL),1,0) AS 登録済件数
    , IF(COALESCE(tbba052g.su_sitadori, 0) = 0 AND tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND (tbba001g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'MM') OR tbba001g.dd_urikzumi IS NULL),1,0) AS 下取車なし総件数
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) != 0,1,0) AS 未回収総件数
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk) != 0,tbba052g.ki_haseirui - tbba052g.ki_genknykg - tbba052g.ki_sitanykg - tbba052g.ki_fuharnyk,0) AS 未回収総金額
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_genkhasg - tbba052g.ki_genknykg) != 0,1,0) AS 未回収現金総件数
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_genkhasg - tbba052g.ki_genknykg) != 0,tbba052g.ki_genkhasg - tbba052g.ki_genknykg,0) AS 未回収現金総金額
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_fuharhsk - tbba052g.ki_fuharnyk) != 0,1,0) AS 未回収割賦総総件数
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_fuharhsk - tbba052g.ki_fuharnyk) != 0,tbba052g.ki_fuharhsk - tbba052g.ki_fuharnyk,0) AS 未回収割賦総総金額
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_sitahasg - tbba052g.ki_sitanykg) != 0,1,0) AS 未回収下取総件数
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND tbba001g.dd_urikzumi IS NULL AND (tbba052g.ki_sitahasg - tbba052g.ki_sitanykg) != 0,tbba052g.ki_sitahasg - tbba052g.ki_sitanykg,0) AS 未回収下取総金額
    , IF(tbba001g.dd_touroku IS NOT NULL AND tbba001g.dd_touroku <= LAST_DAY(ADD_MONTHS(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), -1)) AND (tbba001g.dd_urikzumi >= TRUNC(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST'), 'MM') OR tbba001g.dd_urikzumi IS NULL) AND tbba001g.dd_nosya IS NULL,1,0) AS 登録済未納車件数
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
WHERE
tbba001g.dd_torikesi IS NULL
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
