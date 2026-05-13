DROP TABLE IF EXISTS gold.vbi003007;
CREATE TABLE gold.vbi003007 AS
SELECT
    v3003.mj_sortjyun AS `ソート順`
    , v3003.cd_hansya AS `販社コード`
    , v3003.cd_kaisya AS `会社コード`
    , v3003.cd_tenpo AS `店舗コード`
    , concat(v3003.cd_hansya, v3003.cd_kaisya, v3003.cd_tenpo) AS `販社会社店舗コード`
    , v3003.cd_zon AS `エリアコード`
    , v3003.kj_zonmei AS `エリア名`
    , v3003.kj_tenpomei AS `店舗名`
    , v3003.no_stall AS `ストール番号`
    , v3003.mj_stallmei AS `ストール名称`
    , v3003.cd_hansyakaisyatenpostalldate AS `販社会社店舗ストール番号日付`
    , v3003.kb_stallsentaku AS `ストール選択`
    , v3003.dd_date AS `日付`
    , v3003.kb_teinaikitei AS `定内規定`
    , nvl(v3006.mj_yoyaku, 0) AS `予約`
FROM dx_ve.vbi003003 v3003
LEFT JOIN (
    SELECT
        v3006.cd_hansya
        , v3006.cd_kaisya
        , v3006.cd_tenpo
        , v3006.no_stall
        , v3006.dd_nyuukoyt
        , sum(v3006.mj_yoyaku) AS mj_yoyaku
    FROM dx_ve.vbi003006_en v3006
    GROUP BY v3006.cd_hansya, v3006.cd_kaisya, v3006.cd_tenpo, v3006.no_stall, v3006.dd_nyuukoyt
) v3006 ON v3006.cd_hansya = v3003.cd_hansya
AND v3006.cd_kaisya = v3003.cd_kaisya
AND v3006.cd_tenpo = v3003.cd_tenpo
AND v3006.no_stall = v3003.no_stall
AND v3006.dd_nyuukoyt = v3003.dd_date
;
