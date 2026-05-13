DROP TABLE IF EXISTS gold.vbi003001;
CREATE TABLE gold.vbi003001 AS
SELECT
    dd_date AS `日付`
    , dd_month AS `日付_月`
    , `dd_yyyy/MM/dd` AS `日付_yyyy/MM/dd`
    , `dd_yyyyMMdd` AS `日付_yyyyMMdd`
    , kb_week AS `週末判定`
FROM dx_ve.vbi003001_en
;
