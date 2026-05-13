DROP TABLE IF EXISTS gold.vbi000009;
CREATE TABLE gold.vbi000009 AS
SELECT
    t206m.cd_hansya AS `販社コード`
    , t206m.cd_kaisya AS `会社コード`
    , t206m.no_seiri AS `整理ＮＯ`
    , t206m.mj_framekat AS `フレーム型式`
    , t206m.kb_siharai AS `支払区分`
    , trim(t206m.mj_toribhhn) AS `取替部品品番`
    , t206m.su_toribhsu AS `取替部品個数`
    , concat(t206m.cd_hansya, t206m.cd_kaisya, t206m.no_seiri, trim(t206m.mj_framekat),t206m.kb_siharai) AS `販社会社整理ＮＯフレーム型式支払区分`
FROM ai21rep_ve_dx.tbfy206m t206m
LEFT SEMI JOIN dx_ve.vbi000002_en v0002
    ON v0002.cd_hansya = t206m.cd_hansya
    AND v0002.cd_kaisya = t206m.cd_kaisya
    AND v0002.mj_toribhhn = trim(t206m.mj_toribhhn)
;
