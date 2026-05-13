DROP TABLE IF EXISTS gold.vbi000011;
CREATE TABLE gold.vbi000011 AS
SELECT
    t206m.cd_hansya AS `販社コード`
    , t206m.cd_kaisya AS `会社コード`
    , ta001g.cd_tenpo AS `店舗コード`
    , trim(t206m.mj_toribhhn) AS `取替部品品番`
    , t206m.no_seiri AS `整理ＮＯ`
    , t206m.mj_framekat AS `フレーム型式`
    , right(trim(t008g.cd_seibi), 1) AS `支払区分`
    , concat(t206m.cd_hansya, t206m.cd_kaisya, t206m.no_seiri, trim(t206m.mj_framekat), right(trim(t008g.cd_seibi), 1)) AS `販社会社整理ＮＯフレーム型式支払区分`
    , t206m.su_toribhsu AS `取替部品個数`
    , v0002.mj_torihnme AS `取替部品品名`
FROM ai21rep_ve_dx.tbfj001g t001g
INNER JOIN ai21rep_ve_dx.tbsa001g ta001g
    ON ta001g.cd_hansya = t001g.cd_hansya
    AND ta001g.cd_kaisya = t001g.cd_kaisya
    AND ta001g.no_aijutyu = t001g.no_jucyu
LEFT SEMI JOIN dx_ve.tbi999003m t9003m
    ON t9003m.cd_hansya = ta001g.cd_hansya
    AND t9003m.cd_kaisya = ta001g.cd_kaisya
    AND t9003m.cd_tenpo = ta001g.cd_tenpo
    AND t9003m.mj_cyohyoid = '000'
    AND t9003m.kb_tenji = 1
INNER JOIN ai21rep_ve_dx.tbfa008g t008g
    ON t008g.cd_hansya = t001g.cd_hansya
    AND t008g.cd_kaisya = t001g.cd_kaisya
    AND t008g.cd_tenpo = ta001g.cd_tenpo
    AND left(t008g.cd_seibi, 5) = t001g.no_seiri
    AND t008g.no_jucyu = t001g.no_jucyu
INNER JOIN ai21rep_ve_dx.tbfy206m t206m
    ON t206m.cd_hansya = t001g.cd_hansya
    AND t206m.cd_kaisya = t001g.cd_kaisya
    AND t206m.no_seiri = t001g.no_seiri
    AND trim(t206m.mj_framekat) = (t001g.mj_framekat)
    AND t206m.kb_siharai = right(trim(t008g.cd_seibi), 1)
    AND left(t206m.mj_toribhhn, 3) = '040'
LEFT JOIN dx_ve.vbi000002_en v0002
    ON v0002.cd_hansya = t206m.cd_hansya
    AND v0002.cd_kaisya = t206m.cd_kaisya
    AND v0002.mj_toribhhn = trim(t206m.mj_toribhhn)
GROUP BY t206m.cd_hansya, t206m.cd_kaisya, ta001g.cd_tenpo, trim(t206m.mj_toribhhn), t206m.no_seiri, t206m.mj_framekat, right(trim(t008g.cd_seibi), 1), t206m.su_toribhsu, v0002.mj_torihnme
;
