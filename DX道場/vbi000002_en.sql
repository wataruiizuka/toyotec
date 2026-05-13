DROP TABLE IF EXISTS gold.vbi000002_en;
CREATE TABLE gold.vbi000002_en AS
SELECT
    t206m.cd_hansya
    , t206m.cd_kaisya
    , trim(t206m.mj_toribhhn) AS mj_toribhhn
    , max(t022g.mj_torihnme) AS mj_torihnme
FROM ai21rep_ve_dx.tbfy206m t206m
LEFT JOIN ai21rep_ve_dx.tbfj022g t022g
    ON t022g.cd_hansya = t206m.cd_hansya
    AND t022g.cd_kaisya = t206m.cd_kaisya
    AND trim(t022g.mj_toribhhn) = trim(t206m.mj_toribhhn)
    AND nvl(trim(t022g.mj_torihnme), '') <> ''
WHERE left(t206m.mj_toribhhn, 3) = '040'
GROUP BY t206m.cd_hansya, t206m.cd_kaisya, trim(t206m.mj_toribhhn)
;
