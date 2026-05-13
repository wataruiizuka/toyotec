DROP TABLE IF EXISTS gold.vbi003008;
CREATE TABLE gold.vbi003008 AS
SELECT
    v3002.mj_sortjyun AS`ソート順`
    , v3002.cd_hansya AS `販社コード`
    , v3002.cd_kaisya AS `会社コード`
    , v3002.cd_tenpo AS `店舗コード`
    , concat(v3002.cd_hansya, v3002.cd_kaisya, v3002.cd_tenpo) AS `販社会社店舗コード`
    , v3002.cd_zon AS `エリアコード`
    , v3002.kj_zonmei AS `エリア名`
    , v3002.kj_tenpomei AS `店舗名`
FROM dx_ve.vbi003002 v3002
GROUP BY v3002.cd_hansya, v3002.cd_kaisya, v3002.cd_tenpo, v3002.kj_zonmei,v3002.cd_zon, v3002.kj_tenpomei, v3002.mj_sortjyun
;
