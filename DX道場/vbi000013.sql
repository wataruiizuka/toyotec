DROP TABLE IF EXISTS gold.vbi000013;
CREATE TABLE gold.vbi000013 AS
SELECT
    v0001.mj_sortjyun AS `ソート順`
    , t001g.cd_hansya AS `販社コード`
    , t001g.cd_kaisya AS `会社コード`
    , t001g.cd_tenpo AS `店舗コード`
    , v0001.kj_tenpomei AS `店舗名称`
    , trim(t001g.mj_hinban) AS `品番`
    , t001g.mj_hinmei AS `品名`
    , t001g.su_zaikosu AS `在庫数`
FROM ai21rep_ve_dx.tbfb001g t001g
LEFT SEMI JOIN dx_ve.vbi000002_en v0002
    ON v0002.cd_hansya = t001g.cd_hansya
    AND v0002.cd_kaisya = t001g.cd_kaisya
    AND v0002.mj_toribhhn = trim(t001g.mj_hinban)
INNER JOIN dx_ve.vbi000001_en v0001
    ON v0001.cd_hansya = t001g.cd_hansya
    AND v0001.cd_kaisya = t001g.cd_kaisya
    AND v0001.cd_tenpo = t001g.cd_tenpo
WHERE t001g.su_zaikosu > 0
;
