DROP TABLE IF EXISTS gold.vbi012001_en;
CREATE TABLE gold.vbi012001_en AS
SELECT
    bt.dd_date
    , trunc(bt.dd_date, 'MM') AS dd_month
    , from_timestamp(bt.dd_date, 'yyyy/MM/dd') AS `dd_yyyy/MM/dd`
    , from_timestamp(bt.dd_date, 'yyyyMMdd') AS `dd_yyyyMMdd`
    , concat(from_timestamp(bt.dd_date, 'MM/dd'), CHR(10), '('
        CASE dayofweek(bt.dd_date)
            WHEN 1 THEN '日'
            WHEN 2 THEN '月'
            WHEN 3 THEN '火'
            WHEN 4 THEN '水'
            WHEN 5 THEN '木'
            WHEN 6 THEN '金'
            WHEN 7 THEN '土'
        END,
    ')') AS dd_week,
    , bt.kb_senshuraishu
FROM (
    SELECT
        days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date), i) AS dd_date
        , if (i < 7, "先週", "来週") AS kb_senshuraishu
    FROM(
        VALUES((0 AS i),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13))
    ) dd
) bt
;
