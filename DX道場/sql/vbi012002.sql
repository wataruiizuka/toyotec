DROP TABLE IF EXISTS gold.vbi012002;
CREATE TABLE gold.vbi012002 AS
SELECT
    t3002m.cd_hansya
    , t3002m.cd_kaisya
    , t3002m.cd_tenpo
    , t3002m.no_stall
    , t3002m.mj_stallmei
    , concat(cast(t3002m.no_stall AS string), '　', t3002m.mj_stallmei) AS kb_stallsentaku
    , concat(t3002m.cd_hansya, t3002m.cd_kaisya, t3002m.cd_tenpo) AS cd_hansyakaisyatenpo
    , t9003m.mj_sortjyun
FROM dx_ve.tbi003002m t3002m
LEFT SEMI JOIN dx_ve.tbi003001m t3001m
    ON t3001m.cd_hansya = t3002m.cd_hansya
    AND t3001m.cd_kaisya = t3002m.cd_kaisya
    AND t3001m.cd_tenpo = t3002m.cd_tenpo
INNER JOIN dx_ve.tbi999003m t9003m
    ON t9003m.cd_hansya = t3002m.cd_hansya
    AND t9003m.cd_kaisya = t3002m.cd_kaisya
    AND t9003m.cd_tenpo = t3002m.cd_tenpo
    AND t9003m.mj_cyohyoid = '012'
    AND t9003m.kb_tenji = 1
WHERE t3002m.kb_shuukeitaishou = '1'
AND instr(t3002m.mj_stallmei, 'コント') = 0
AND instr(t3002m.mj_stallmei, '外注') = 0
;
