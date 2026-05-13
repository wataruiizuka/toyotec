DROP TABLE IF EXISTS gold.vbi000004;
CREATE TABLE gold.vbi000004 AS
SELECT
    cd_hansya AS `販社コード`
    , cd_kaisya AS `会社コード`
    , no_seiri AS `整理ＮＯ`
    , kj_recallme AS `リコール名称`
FROM dx_ve.vbi000004_en
;
