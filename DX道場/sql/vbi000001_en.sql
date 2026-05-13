DROP TABLE IF EXISTS gold.vbi000001_en;
CREATE TABLE gold.vbi000001_en AS
SELECT
    row_number() OVER(ORDER BY t201m.cd_hansya, t201m.cd_kaisya, t9003m.mj_sortjyun, t201m.cd_tenpo) AS mj_sortjyun
    , t201m.cd_hansya
    , t201m.cd_kaisya
    , t201m.cd_tenpo
    , regexp_replace(t201m.kj_tenpomei, '　+$', '') AS kj_tenpomei
FROM ai21rep_ve_dx.tbv0201m t201m
INNER JOIN dx_ve.tbi999003m t9003m
    ON t9003m.cd_hansya = t201m.cd_hansya
    AND t9003m.cd_kaisya = t201m.cd_kaisya
    AND t9003m.cd_tenpo = t201m.cd_tenpo
    AND t9003m.mj_cyohyoid = '000'
    AND t9003m.kb_tenji = 1
;
