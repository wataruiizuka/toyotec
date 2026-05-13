DROP TABLE IF EXISTS gold.vbi011004;
CREATE TABLE gold.vbi011004 AS
SELECT
    t005g.cd_hansya
    , t005g.cd_kaisya
    , ta001g.cd_okyaku
    , ta001g.cd_norikusi
    , ta001g.kb_nosyasyu
    , ta001g.cd_nogyotai
    , ta001g.no_noseiri
    , ta001g.dt_nyuukoyt
    , t005g.kb_nyuuko
FROM ai21rep_ve_dx.tbsa005g t005g
LEFT JOIN ai21rep_ve_dx.tbsa001g ta001g
    ON t005g.cd_hansya = ta001g.cd_hansya
    AND t005g.cd_kaisya = ta001g.cd_kaisya
    AND t005g.cd_tenpo = ta001g.cd_tenpo
    AND t005g.no_yoyakuid = ta001g.no_yoyakuid
    AND ta001g.no_yoyakuid IS NOT NULL
    AND ta001g.cd_norikusi != ''
    AND ta001g.mj_sakujyo = '0'
WHERE
t005g.mj_sakujyo = '0'
AND t005g.kb_nyuuko != ''
AND t005g.kb_nyuuko != '0'
AND t005g.kb_nyuuko != '8'
AND t005g.kb_nyuuko != '9'
;
