DROP TABLE IF EXISTS gold.vbi000006;
CREATE TABLE gold.vbi000006 AS
SELECT
    t003g.cd_hansya AS `販社コード`
    , t003g.cd_kaisya AS `会社コード`
    , t003g.cd_tenpo AS `店舗コード`
    , t003g.no_seiri AS `整理ＮＯ`
    , sum(t003g.su_taisyasu) AS `対象車両台数`
    , sum(t003g.su_jitejida) AS `自店実施台数`
    , sum(t003g.su_tatenjis) AS `他店実施台数`
    , sum(t003g.su_tasyjiss) AS `他社実施台数`
FROM ai21rep_ve_dx.tbfj003g t003g
LEFT SEMI JOIN dx_ve.tbi999003m t9003m
    ON t9003m.cd_hansya = t003g.cd_hansya
    AND t9003m.cd_kaisya = t003g.cd_kaisya
    AND t9003m.cd_tenpo = t003g.cd_tenpo
    AND t9003m.mj_cyohyoid = '000'
    AND t9003m.kb_tenji = 1
GROUP BY t003g.cd_hansya, t003g.cd_kaisya, t003g.cd_tenpo, t003g.no_seiri
;
