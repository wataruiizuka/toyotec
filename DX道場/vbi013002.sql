DROP TABLE IF EXISTS gold.vbi013002;
CREATE TABLE gold.vbi013002 AS
SELECT
    v2001.zone_name AS `エリア統括部と店舗`
    , 'ゾーン名称' AS `区分名称`
    , '1' AS `区分コード`
    , v2001.cd_hansya AS `販社コード`
    , v2001.cd_kaisya AS `会社コード`
    , v2001.cd_zon AS `ゾーンコード`
    , NULL AS `店舗コード`
    , NULL AS `販社会社店舗コード`
    , NULL AS `販社会社ゾーン店舗コード`
    , SUM(v2004.su_pieces) AS `件数`
    , SUM(v2004.su_amount) AS `金額`
    , CAST(v2001.cd_zon AS INT) AS `ソート順`
FROM dx_ve.vbi013001_en v2001
LEFT JOIN dx_ve.vbi013004_en v2004
    ON v2001.cd_hansya = v2004.cd_hansya
    AND v2001.cd_kaisya = v2004.cd_kaisya
    AND v2001.cd_tenpo = v2004.cd_jytyuten
GROUP BY
    エリア統括部と店舗,
    区分名称,
    区分コード,
    販社コード,
    会社コード,
    ゾーンコード
UNION ALL
SELECT
    v2001.kj_tentanms AS `エリア統括部と店舗`
    , '店舗略称' AS `区分名称`
    , '2' AS `区分コード`
    , v2001.cd_hansya AS `販社コード`
    , v2001.cd_kaisya AS `会社コード`
    , v2001.cd_zon AS `ゾーンコード`
    , v2001.cd_tenpo AS `店舗コード`
    , v2001.cd_hansya_kaisya_tenpo AS `販社会社店舗コード`
    , v2001.cd_hansya_kaisya_zon_tenpo AS `販社会社ゾーン店舗コード`
    , SUM(su_pieces) AS `件数`
    , SUM(su_amount) AS `金額`
    , v2001.mj_sortjyun AS `ソート順`
FROM dx_ve.vbi013001_en v2001
LEFT JOIN dx_ve.vbi013004_en v2004
    ON v2001.cd_hansya = v2004.cd_hansya
    AND v2001.cd_kaisya = v2004.cd_kaisya
    AND v2001.cd_tenpo = v2004.cd_jytyuten
GROUP BY
    `エリア統括部と店舗`,
    `区分名称`,
    `区分コード`,
    `販社コード`,
    `会社コード`,
    `ゾーンコード`,
    `店舗コード`,
    `販社会社店舗コード`,
    `販社会社ゾーン店舗コード`,
    `ソート順`