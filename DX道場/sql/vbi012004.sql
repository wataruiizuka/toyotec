DROP TABLE IF EXISTS gold.vbi012004;
CREATE TABLE gold.vbi012004 AS
SELECT
    t005g.cd_hansya
    , t005g.cd_kaisya
    , t005g.cd_tenpo
    , t005g.no_stall
    , t005g.dt_siyost
    , t005g.dt_siyoed
FROM ai21rep_ve_stg_kudu.tbsa005g t005g
LEFT SEMI JOIN dx_ve.vbi012002 v3002
    ON v3002.cd_hansya = t005g.cd_hansya
    AND v3002.cd_kaisya = t005g.cd_kaisya
    AND v3002.cd_tenpo = t005g.cd_tenpo
    AND v3002.no_stall = t005g.no_stall
WHERE t005g.mj_sakujyo = '0'
AND ((t005g.dt_siyost >= cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date) AND t005g.dt_siyost < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date), 14))
OR (t005g.dt_siyoed >= cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date) AND t005g.dt_siyoed < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date), 14)))
UNION ALL
SELECT
    tb05s.cd_hansya
    , tb05s.cd_kaisya
    , tb05s.cd_tenpo
    , tb05s.no_stall
    , tb05s.dt_siyost
    , tb05s.dt_siyoed
FROM ai21rep_ve_stg_kudu.tbsab05s tb05s
LEFT SEMI JOIN dx_ve.vbi012002 v3002
    ON v3002.cd_hansya = tb05s.cd_hansya
    AND v3002.cd_kaisya = tb05s.cd_kaisya
    AND v3002.cd_tenpo = tb05s.cd_tenpo
    AND v3002.no_stall = tb05s.no_stall
LEFT ANTI JOIN ai21rep_ve_stg_kudu.tbsa005g t005g
    ON t005g.cd_hansya = tb05s.cd_hansya
    AND t005g.cd_kaisya = tb05s.cd_kaisya
    AND t005g.cd_tenpo = tb05s.cd_tenpo
    AND t005g.no_yoyakuid = tb05s.no_yoyakuid
    AND t005g.no_stall = tb05s.no_stall
    AND t005g.mj_sakujyo = '0'
LEFT ANTI JOIN ai21rep_ve_stg_kudu.tbsab05s tb05s2
    ON tb05s2.cd_hansya = tb05s.cd_hansya
    AND tb05s2.cd_kaisya = tb05s.cd_kaisya
    AND tb05s2.cd_tenpo = tb05s.cd_tenpo
    AND tb05s2.no_yoyakuid = tb05s.no_yoyakuid
    AND tb05s2.cd_yoykmsai = tb05s.cd_yoykmsai
    AND tb05s2.no_stall = tb05s.no_stall
    AND tb05s2.mj_sakujyo = '0'
    AND tb05s2.no_msaiedmx <> tb05s.no_msaiedmx
WHERE tb05s.mj_sakujyo = '0'
AND ((tb05s.dt_siyost >= cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date) AND tb05s.dt_siyost < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date), 14))
OR (tb05s.dt_siyoed >= cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date) AND tb05s.dt_siyoed < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date), 14)))
;
