DROP TABLE IF EXISTS gold.vbi000002;
CREATE TABLE gold.vbi000002 AS
SELECT
    cd_hansya AS `販社コード`
    , cd_kaisya AS `会社コード`
    , mj_toribhhn AS `取替部品品番`
    , mj_torihnme AS `取替部品品名`
FROM dx_ve.vbi000002_en
;
