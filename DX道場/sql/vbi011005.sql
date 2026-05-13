DROP TABLE IF EXISTS gold.vbi011005;
CREATE TABLE gold.vbi011005 AS
SELECT
    tz006m.cd_hansya
    , tz006m.cd_kaisya
    , tz006m.cd_okyaku
    , tz006m.cd_stafften
    , tz006m.cd_staff
    , vbi011002.cd_zon
    , vbi011002.kj_zonmei
    , vbi011002.kj_tenpomei
    , vbi011002.mj_sortjyun
    , t0014m.kj_syainmei
FROM ai21rep_ve_dx.tbaz006m tz006m
INNER JOIN dx_ve.vbi011002 vbi011002
    ON tz006m.cd_hansya = vbi011002.cd_hansya
    AND tz006m.cd_kaisya = vbi011002.cd_kaisya
    AND tz006m.cd_stafften = vbi011002.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0014m t0014m
    ON tz006m.cd_hansya = t0014m.cd_hansya
    AND tz006m.cd_kaisya = t0014m.cd_kaisya
    AND tz006m.cd_staff = t0014m.cd_syain
WHERE tz006m.kb_tantobun = '1'
;
