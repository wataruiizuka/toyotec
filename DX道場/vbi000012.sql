DROP TABLE IF EXISTS gold.vbi000012;
CREATE TABLE gold.vbi000012 AS
SELECT
    v0001.mj_sortjyun AS `ソート順`
    , t001g.cd_hansya AS `販社コード`
    , t001g.cd_kaisya AS `会社コード`
    , ta001g.cd_tenpo AS `店舗コード`
    , v0001.kj_tenpomei AS `店舗名称`
    , t001g.no_seiri AS `整理ＮＯ`
    , t001g.mj_framekat AS `フレーム型式`
    , t001g.no_frame AS `フレームＮＯ`
    , t001g.no_jucyu AS `受注ＮＯ`
    , ta001g.dt_nyuukoyt AS `入庫予定日時`
    , concat(t001g.cd_hansya, t001g.cd_kaisya, t001g.no_seiri, trim(t001g.mj_framekat), right(trim(t008g.cd_seibi), 1)) AS `販社会社整理ＮＯフレーム型式支払区分`
    , concat(from_timestamp(ta001g.dt_nyuukoyt, 'yyyyMM'), '0') AS `入庫予定日0`
    , 1 AS `台数`
FROM ai21rep_ve_dx.tbfj001g t001g
INNER JOIN ai21rep_ve_dx.tbsa001g ta001g
    ON ta001g.cd_hansya = t001g.cd_hansya
    AND ta001g.cd_kaisya = t001g.cd_kaisya
    AND ta001g.no_aijutyu = t001g.no_jucyu
INNER JOIN ai21rep_ve_dx.tbfa008g t008g
    ON t008g.cd_hansya = ta001g.cd_hansya
    AND t008g.cd_kaisya = ta001g.cd_kaisya
    AND t008g.cd_tenpo = ta001g.cd_tenpo
    AND left(t008g.cd_seibi, 5) = t001g.no_seiri
    AND t008g.no_jucyu = t001g.no_jucyu
LEFT SEMI JOIN ai21rep_ve_dx.tbfy206m t206m
    ON t206m.cd_hansya = t001g.cd_hansya
    AND t206m.cd_kaisya = t001g.cd_kaisya
    AND t206m.no_seiri = t001g.no_seiri
    AND trim(t206m.mj_framekat) = trim(t001g.mj_framekat)
    AND t206m.kb_siharai = right(trim(t008g.cd_seibi), 1)
INNER JOIN dx_ve.vbi000001_en v0001
    ON v0001.cd_hansya =  ta001g.cd_hansya
    AND v0001.cd_kaisya = ta001g.cd_kaisya
    AND v0001.cd_tenpo = ta001g.cd_tenpo
WHERE ta001g.dt_nyuukoyt > cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date)
AND ta001g.dt_nyuukoyt < months_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date), 6)
;
