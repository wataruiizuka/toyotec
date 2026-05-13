DROP TABLE IF EXISTS gold.vbi012006;
CREATE TABLE gold.vbi012006 AS
SELECT
    row_number() OVER(PARTITION BY v12002.cd_hansya, v12002.cd_kaisya ORDER BY v12002.mj_sortjyun, v12002.cd_tenpo) AS `ソート順`
    , v12002.cd_hansya AS `販社コード`
    , v12002.cd_kaisya AS `会社コード`
    , v12002.cd_tenpo AS `店舗コード`
    , regexp_replace(t201m.kj_tenpomei, '　+$', '') AS `店舗名`
    , concat(v12002.cd_hansya, v12002.cd_kaisya, v12002.cd_tenpo) AS `販社会社店舗コード`
FROM dx_ve.vbi012002 v12002
LEFT JOIN ai21rep_ve_stg_kudu.tbv0201m t201m
    ON t201m.cd_hansya = v12002.cd_hansya
    AND t201m.cd_kaisya = v12002.cd_kaisya
    AND t201m.cd_tenpo = v12002.cd_tenpo
GROUP BY v12002.cd_hansya, v12002.cd_kaisya, v12002.cd_tenpo, t201m.kj_tenpomei, v12002.mj_sortjyun
;
