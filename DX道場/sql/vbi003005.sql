DROP TABLE IF EXISTS gold.vbi003005;
CREATE TABLE gold.vbi003005 AS
SELECT
    t021m.cd_hansya
    , t021m.cd_kaisya
    , t021m.cd_tenpo
    , t021m.no_stall
    , t021m.no_stlkyuke
    , t021m.mj_kyukeyko
    , t021m.tm_kyukest
    , unix_timestamp(concat('1970-01-01 ', t021m.tm_kyukest)) AS tm_kyukestsecond
    , t021m.tm_kyukeen
    , unix_timestamp(concat('1970-01-01 ', t021m.tm_kyukeen)) AS tm_kyukeensecond
FROM ai21rep_ve_dx.tbsa021m t021m
LEFT SEMI JOIN dx_ve.tbi999003m t9003m
    ON t9003m.cd_hansya = t021m.cd_hansya
    AND t9003m.cd_kaisya = t021m.cd_kaisya
    AND t9003m.cd_tenpo = t021m.cd_tenpo
    AND t9003m.mj_cyohyoid = '003'
    AND t9003m.kb_tenji = 1
LEFT SEMI JOIN dx_ve.tbi003001m t3001m
    ON t3001m.cd_hansya = t021m.cd_hansya
    AND t3001m.cd_kaisya = t021m.cd_kaisya
    AND t3001m.cd_tenpo = t021m.cd_tenpo
    AND t3001m.tm_kaiten < t021m.tm_kyukest
    AND t3001m.tm_heiten > t021m.tm_kyukeen
WHERE t021m.mj_sakujyo = '0'
AND t021m.mj_kyukeyko = '1'
;
