DROP TABLE IF EXISTS gold.vbi003001_en;
CREATE TABLE gold.vbi003001_en AS
SELECT
    bt.dd_date
    , trunc(bt.dd_date, 'MM') AS dd_month
    , from_timestamp(bt.dd_date, 'yyyy/MM/dd') AS `dd_yyyy/MM/dd`
    , from_timestamp(bt.dd_date, 'yyyyMMdd') AS `dd_yyyyMMdd`
    , CASE dayofweek(bt.dd_date)
        WHEN 1 THEN '2'
        WHEN 7 THEN '2'
        ELSE '1'
    END AS kb_week
FROM (
    SELECT
        days_add(cast(from_utc_timestamp(utc_timestamp(), 'JST') AS date), i) AS dd_date
    FROM(
        VALUES((0 AS i),(1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13))
    ) dd
) bt
;
