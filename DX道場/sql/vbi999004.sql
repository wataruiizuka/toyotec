DROP TABLE IF EXISTS gold.vbi999004;
CREATE TABLE gold.vbi999004 AS
SELECT
    ROW_NUMBER() OVER(PARTITION BY t001m.cd_hansya, t001m.cd_kaisya ORDER BY t001m.cd_tenpo, t001m.no_stall) AS `No.`
    , t001m.cd_hansya AS `販社コード`
    , t001m.cd_kaisya AS `会社コード`
    , t001m.cd_tenpo AS `店舗コード`
    , regexp_replace(t201m.kj_tenpomei, '　+$', '') AS `店舗名`
    , t001m.no_stall AS `ストール番号`
    , CONCAT(t001m.mj_stallmei, '##', CAST(ROW_NUMBER() OVER(PARTITION BY t001m.cd_hansya, t001m.cd_kaisya ORDER BY t001m.cd_tenpo, t001m.no_stall) AS string), '##') AS `ストール名称`
    , if (v3002m.kb_shuukeitaishou = '0', '×', '○') AS `集計対象判別`
FROM ai21rep_ve_dx.tbsa001m t001m
LEFT JOIN ai21rep_ve_dx.tbv0201m t201m
    ON t201m.cd_hansya = t001m.cd_hansya
    AND t201m.cd_kaisya = t001m.cd_kaisya
    AND t201m.cd_tenpo = t001m.cd_tenpo
LEFT JOIN dx_ve.tbi003002m v3002m
    ON v3002m.cd_hansya = t001m.cd_hansya
    AND v3002m.cd_kaisya = t001m.cd_kaisya
    AND v3002m.cd_tenpo = t001m.cd_tenpo
    AND v3002m.no_stall = t001m.no_stall
;
