DROP TABLE IF EXISTS gold.vbi000001;
CREATE TABLE gold.vbi000001 AS
SELECT
    mj_sortjyun AS `ソート順`
    , cd_hansya AS `販社コード`
    , cd_kaisya AS `会社コード`
    , cd_tenpo AS `店舗コード`
    , kj_tenpomei AS `店舗名称`
FROM dx_ve.vbi000001_en
;