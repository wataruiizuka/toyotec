DROP TABLE IF EXISTS gold.vbi999001;
CREATE TABLE gold.vbi999001 AS
SELECT
    t200m.cd_hanbaitn AS `販売店コード`
    , t200m.cd_hansya AS `販社コード`
    , t200m.cd_kaisya AS `会社コード`
    , CONCAT(t200m.cd_hanbaitn, '_', regexp_replace(t200m.kj_kaisya, '　| +$', '')) AS `会社名`
    , GROUP_CONCAT(v9001m.mj_account, ';') AS `メール`
    , GROUP_CONCAT(IF(
        v9001m.mj_account LIKE '%toyotecdap.onmicrosoft.com',
        v9001m.mj_account,
        CONCAT(REPLACE(v9001m.mj_account, '@', '_'), '#EXT#@toyotecdap.onmicrosoft.com')
    ), ';') AS `メールSP`
FROM ai21rep_ve_dx.tbv0200m t200m
INNER JOIN dx_ve.tbi999001m v9001m
    ON v9001m.cd_hanbaitn = t200m.cd_hanbaitn
    AND v9001m.kb_masterkengen = '1'
GROUP BY t200m.cd_hansya, t200m.cd_kaisya, t200m.cd_hanbaitn, regexp_replace(t200m.kj_kaisya, '　| +$', '')
;
