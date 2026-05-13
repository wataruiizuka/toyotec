DROP TABLE IF EXISTS gold.vbi000008;
CREATE TABLE gold.vbi000008 AS
SELECT
    t001g.cd_hansya AS `販社コード`
    , t001g.cd_kaisya AS `会社コード`
    , t001g.cd_tenpo AS `店舗コード`
    , trim(t001g.mj_hinban) AS `品番`
    , sum(t001g.su_zaikosu) AS `在庫数`
    , sum(t001g.su_hacyusu) AS `発注数`
FROM ai21rep_ve_dx.tbfb001g t001g
LEFT SEMI JOIN dx_ve.tbi999003m t9003m
    ON t9003m.cd_hansya = t001g.cd_hansya
    AND t9003m.cd_kaisya = t001g.cd_kaisya
    AND t9003m.cd_tenpo = t001g.cd_tenpo
    AND t9003m.mj_cyohyoid = '000'
    AND t9003m.kb_tenji = 1
LEFT SEMI JOIN dx_ve.vbi000002_en v0002
    ON v0002.cd_hansya = t001g.cd_hansya
    AND v0002.cd_kaisya = t001g.cd_kaisya
    AND v0002.mj_toribhhn = trim(t001g.mj_hinban)
LEFT SEMI JOIN dx_ve.vbi000001_en v0001
    ON v0001.cd_hansya = t001g.cd_hansya
    AND v0001.cd_kaisya = t001g.cd_kaisya
    AND v0001.cd_tenpo = t001g.cd_tenpo
GROUP BY t001g.cd_hansya, t001g.cd_kaisya, t001g.cd_tenpo, trim(t001g.mj_hinban)
;
