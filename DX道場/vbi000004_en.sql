DROP TABLE IF EXISTS gold.vbi000004_en;
CREATE TABLE gold.vbi000004_en AS
SELECT
    t022g.cd_hansya
    , t022g.cd_kaisya
    , t022g.no_seiri
    , max(t022g.kj_recallme) AS kj_recallme
FROM ai21rep_ve_dx.tbfj022g t022g
GROUP BY t022g.cd_hansya, t022g.cd_kaisya, t022g.no_seiri
;