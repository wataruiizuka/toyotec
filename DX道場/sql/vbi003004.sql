DROP TABLE IF EXISTS gold.vbi003004;
CREATE TABLE gold.vbi003004 AS
SELECT
    t005g.cd_hansya
    , t005g.cd_kaisya
    , t005g.cd_tenpo
    , t005g.no_yoyakuid
    , t005g.cd_yoykmsai
    , t005g.no_msaiedmx
    , t005g.no_stall
    , cast(t005g.no_stall AS string) AS mj_stallno
    , t005g.mj_gyme
    , t005g.kb_koutei
    , t005g.dt_siyost
    , trunc(t005g.dt_siyost, 'J') AS dd_nyuukoyt
    , unix_timestamp(concat('1970-01-01 ', from_timestamp(t005g.dt_siyost, 'HH:mm:ss'))) AS tm_nyuukoytsecond
    , t005g.dt_siyoed
    , trunc(t005g.dt_siyoed, 'J') AS dd_shukkoyt
    , unix_timestamp(concat('1970-01-01 ', from_timestamp(t005g.dt_siyoed, 'HH:mm:ss'))) AS tm_shukkoytsecond
    , t005g.tm_siyotime
    , t005g.kb_nyuuko
    , t005g.cd_jisekist
    , t005g.cd_restcros
    , t005g.su_sgyninz
    , t005g.dt_nyukjisk
    , t005g.dt_sesnjisk
    , t005g.mj_sakujyo
FROM ai21rep_ve_dx.tbsa005g t005g
LEFT SEMI JOIN dx_ve.vbi003002 v3002
    ON v3002.cd_hansya = t005g.cd_hansya
    AND v3002.cd_kaisya = t005g.cd_kaisya
    AND v3002.cd_tenpo = t005g.cd_tenpo
    AND v3002.no_stall = t005g.no_stall
WHERE t005g.mj_sakujyo = '0'
AND isnottrue(t005g.cd_jisekist IN('00', '01', '02'))
AND t005g.dt_siyost >= cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date)
AND t005g.dt_siyost < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date), 14)
UNION ALL
SELECT
    tb05s.cd_hansya
    , tb05s.cd_kaisya
    , tb05s.cd_tenpo
    , tb05s.no_yoyakuid
    , tb05s.cd_yoykmsai
    , tb05s.no_msaiedmx
    , tb05s.no_stall
    , cast(tb05s.no_stall AS string) AS mj_stallno
    , tb05s.mj_gyme
    , tb05s.kb_koutei
    , tb05s.dt_siyost
    , trunc(tb05s.dt_siyost, 'J') AS dd_nyuukoyt
    , unix_timestamp(concat('1970-01-01 ', from_timestamp(tb05s.dt_siyost, 'HH:mm:ss'))) AS tm_nyuukoytsecond
    , tb05s.dt_siyoed
    , trunc(tb05s.dt_siyoed, 'J') AS dd_shukkoyt
    , unix_timestamp(concat('1970-01-01 ', from_timestamp(tb05s.dt_siyoed, 'HH:mm:ss'))) AS tm_shukkoytsecond
    , tb05s.tm_siyotime
    , tb05s.kb_nyuuko
    , tb05s.cd_jisekist
    , tb05s.cd_restcros
    , tb05s.su_sgyninz
    , tb05s.dt_nyukjisk
    , tb05s.dt_sesnjisk
    , tb05s.mj_sakujyo
FROM ai21rep_ve_dx.tbsab05s tb05s
LEFT SEMI JOIN dx_ve.vbi003002 v3002
    ON v3002.cd_hansya = tb05s.cd_hansya
    AND v3002.cd_kaisya = tb05s.cd_kaisya
    AND v3002.cd_tenpo = tb05s.cd_tenpo
    AND v3002.no_stall = tb05s.no_stall
LEFT ANTI JOIN ai21rep_ve_dx.tbsa005g t005g
    ON t005g.cd_hansya = tb05s.cd_hansya
    AND t005g.cd_kaisya = tb05s.cd_kaisya
    AND t005g.cd_tenpo = tb05s.cd_tenpo
    AND t005g.no_yoyakuid = tb05s.no_yoyakuid
    AND t005g.no_stall = tb05s.no_stall
    AND t005g.mj_sakujyo = '0'
    AND isnottrue(t005g.cd_jisekist IN('00', '01', '02'))
LEFT ANTI JOIN ai21rep_ve_dx.tbsab05s tb05s2
    ON tb05s2.cd_hansya = tb05s.cd_hansya
    AND tb05s2.cd_kaisya = tb05s.cd_kaisya
    AND tb05s2.cd_tenpo = tb05s.cd_tenpo
    AND tb05s2.no_yoyakuid = tb05s.no_yoyakuid
    AND tb05s2.cd_yoykmsai = tb05s.cd_yoykmsai
    AND tb05s2.no_stall = tb05s.no_stall
    AND tb05s2.mj_sakujyo = '0'
    AND isnottrue(tb05s2.cd_jisekist IN('00', '01', '02'))
    AND tb05s2.no_msaiedmx <> tb05s.no_msaiedmx
WHERE tb05s.mj_sakujyo = '0'
AND isnottrue(tb05s.cd_jisekist IN('00', '01', '02'))
AND tb05s.dt_siyost >= cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date)
AND tb05s.dt_siyost < days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date), 14)
;
