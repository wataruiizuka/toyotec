DROP TABLE IF EXISTS gold.vbi012001;
CREATE TABLE gold.vbi012001 AS
SELECT
    dd_date AS `日付`
    , dd_month AS `日付_月`
    , `dd_yyyy/MM/dd` AS `日付_yyyy/MM/dd`
    , `dd_yyyyMMdd` AS `日付_yyyyMMdd`
    , dd_week AS `日付_曜日`
    , kb_senshuraishu AS `先週/来週`
FROM dx_ve.vbi012001_en
;
