DROP TABLE IF EXISTS gold.vbi000003;
CREATE TABLE gold.vbi000003 AS
SELECT
    t001g.cd_hansya AS `販社コード`
    , t001g.cd_kaisya AS `会社コード`
    , t001g.no_seiri AS `整理ＮＯ`
    , t001g.mj_framekat AS `フレーム型式`
    , if (
        max(t205m.dd_tekkikst) >= months_sub(cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date), 24),
        '2年のみ',
        '過去全部'
    ) AS `データ分類`
FROM ai21rep_ve_dx.tbfj001g t001g
LEFT JOIN ai21rep_ve_dx.tbsa001g ta001g
    ON ta001g.cd_hansya = t001g.cd_hansya
    AND ta001g.cd_kaisya = t001g.cd_kaisya
    AND ta001g.no_aijutyu = t001g.no_jucyu
LEFT JOIN ai21rep_ve_dx.tbfy205m t205m
    ON t205m.cd_hansya = t001g.cd_hansya
    AND t205m.cd_kaisya = t001g.cd_kaisya
    AND t205m.no_seiri = t001g.no_seiri
    AND trim(t205m.mj_framekat) = trim(t001g.mj_framekat)
GROUP BY t001g.cd_hansya, t001g.cd_kaisya, t001g.no_seiri, t001g.mj_framekat
;
