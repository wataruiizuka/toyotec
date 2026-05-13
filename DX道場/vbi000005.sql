DROP TABLE IF EXISTS gold.vbi000005;
CREATE TABLE gold.vbi000005 AS
SELECT
     t001g.cd_hansya AS `販社コード`
     , t001g.cd_kaisya AS `会社コード`
     , t001g.cd_flwtenp AS `フォロー店舗コード`
     , t001g.cd_nyuukoyt AS `入庫予定店舗 `
    , t001g.no_seiri AS `整理ＮＯ`
    , t001g.mj_framekat AS `フレーム型式`
    , v0004.kj_recallme AS `リコール名称`
    , t205m.dd_tekkikst AS `適用期間始期`
    , sum(t001g.kb_massyo = '1' AND t001g.kb_jissi= '0') AS `一時抹消`
FROM ai21rep_ve_dx.tbfj001g t001g
LEFT SEMI JOIN dx_ve.tbi999003m t9003m
    ON (t9003m.cd_hansya = t001g.cd_hansya
    AND t9003m.cd_kaisya = t001g.cd_kaisya
    AND t9003m.cd_tenpo = t001g.cd_nyuukoyt
    AND t9003m.mj_cyohyoid = '000'
    AND t9003m.kb_tenji = 1) OR trim(t001g.cd_nyuukoyt) = ''
LEFT JOIN dx_ve.vbi000004_en v0004
    ON v0004.cd_hansya = t001g.cd_hansya
    AND v0004.cd_kaisya = t001g.cd_kaisya
    AND v0004.no_seiri = t001g.no_seiri
LEFT JOIN (
    SELECT
        t205m.cd_hansya
        , t205m.cd_kaisya
        , t205m.no_seiri
        , trim(t205m.mj_framekat) AS mj_framekat
        , max(t205m.dd_tekkikst) AS dd_tekkikst
    FROM ai21rep_ve_dx.tbfy205m t205m
    GROUP BY t205m.cd_hansya, t205m.cd_kaisya, t205m.no_seiri, trim(t205m.mj_framekat)
) t205m ON t205m.cd_hansya = t001g.cd_hansya
AND t205m.cd_kaisya = t001g.cd_kaisya
AND t205m.no_seiri = t001g.no_seiri
AND trim(t205m.mj_framekat) = trim(t001g.mj_framekat)
GROUP BY t001g.cd_hansya, t001g.cd_kaisya, t001g.cd_flwtenp, t001g.cd_nyuukoyt, t001g.no_seiri, t001g.mj_framekat, v0004.kj_recallme, t205m.dd_tekkikst
;
