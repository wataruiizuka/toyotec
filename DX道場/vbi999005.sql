DROP TABLE IF EXISTS gold.vbi999005;
CREATE TABLE gold.vbi999005 AS
SELECT
    ROW_NUMBER() OVER(PARTITION BY t0232m.cd_hansya, t0232m.cd_kaisya ORDER BY CAST(t0232m.mj_sortjyun AS int), t0232m.cd_syamei) AS `No.`
    , t0232m.cd_hansya AS `販社コード`
    , t0232m.cd_kaisya AS `会社コード`
    , t0232m.cd_syamei AS `車名コード`
    , CONCAT(t0232m.kj_syamei, '##', CAST(ROW_NUMBER() OVER(PARTITION BY t0232m.cd_hansya, t0232m.cd_kaisya ORDER BY CAST(t0232m.mj_sortjyun AS int), t0232m.cd_syamei) AS string), '##') AS `車名（漢字）`
    , CONCAT(t0232m.mj_syamei, '##', CAST(ROW_NUMBER() OVER(PARTITION BY t0232m.cd_hansya, t0232m.cd_kaisya ORDER BY CAST(t0232m.mj_sortjyun AS int), t0232m.cd_syamei) AS string), '##') AS `車名（カナ）`
    , IF(t9009m.kb_tenji = 0, '×', '○') AS `表示可否`
    , CAST(t0232m.mj_sortjyun AS int) AS `ソート順`
FROM ai21rep_ve_dx.tbv0232m t0232m
LEFT JOIN dx_ve.tbi999009m t9009m
    ON t9009m.cd_hansya = t0232m.cd_hansya
    AND t9009m.cd_kaisya = t0232m.cd_kaisya
    AND t9009m.cd_ocsyamei = t0232m.cd_syamei
WHERE t0232m.mj_syamei IS NOT NULL
GROUP BY t0232m.cd_hansya, t0232m.cd_kaisya, t0232m.cd_syamei, t0232m.kj_syamei, t0232m.mj_syamei, t9009m.kb_tenji, t0232m.mj_sortjyun
;
