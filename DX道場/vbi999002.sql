DROP TABLE IF EXISTS gold.vbi999002;
CREATE TABLE gold.vbi999002 AS
WITH bs AS(
    SELECT
        bt.cd_hansya
        , bt.cd_kaisya
        , bt.cd_tenpo
        , max(bt.`表示可否1`) AS `表示可否1`
        , max(bt.`表示可否2`) AS `表示可否2`
        , max(bt.`表示可否3`) AS `表示可否3`
        , max(bt.`表示可否4`) AS `表示可否4`
        , max(bt.`表示可否5`) AS `表示可否5`
        , max(bt.`表示可否6`) AS `表示可否6`
        , max(bt.`表示可否7`) AS `表示可否7`
        , max(bt.`表示可否8`) AS `表示可否8`
        , max(bt.`表示可否9`) AS `表示可否9`
        , max(bt.`表示可否10`) AS `表示可否10`
        , max(bt.`表示可否11`) AS `表示可否11`
        , max(bt.`表示順1`) AS `表示順1`
        , max(bt.`表示順2`) AS `表示順2`
        , max(bt.`表示順3`) AS `表示順3`
        , max(bt.`表示順4`) AS `表示順4`
        , max(bt.`表示順5`) AS `表示順5`
        , max(bt.`表示順6`) AS `表示順6`
        , max(bt.`表示順7`) AS `表示順7`
        , max(bt.`表示順8`) AS `表示順8`
        , max(bt.`表示順9`) AS `表示順9`
        , max(bt.`表示順10`) AS `表示順10`
        , max(bt.`表示順11`) AS `表示順11`
    FROM(
        SELECT
            v9003m.cd_hansya
            , v9003m.cd_kaisya
            , v9003m.cd_tenpo
            , IF(v9003m.mj_cyohyoid = '000' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否1`
            , IF(v9003m.mj_cyohyoid = '001' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否2`
            , IF(v9003m.mj_cyohyoid = '022' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否3`
            , IF(v9003m.mj_cyohyoid = '002' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否4`
            , IF(v9003m.mj_cyohyoid = '013' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否5`
            , IF(v9003m.mj_cyohyoid = '011' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否6`
            , IF(v9003m.mj_cyohyoid = '003' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否7`
            , IF(v9003m.mj_cyohyoid = '012' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否8`
            , IF(v9003m.mj_cyohyoid = '016' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否9`
            , IF(v9003m.mj_cyohyoid = '017' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否10`
            , IF(v9003m.mj_cyohyoid = '019' AND v9003m.kb_tenji = 0, '×', NULL) AS `表示可否11`
            , IF(v9003m.mj_cyohyoid = '000', v9003m.mj_sortjyun, NULL) AS `表示順1`
            , IF(v9003m.mj_cyohyoid = '001', v9003m.mj_sortjyun, NULL) AS `表示順2`
            , IF(v9003m.mj_cyohyoid = '022', v9003m.mj_sortjyun, NULL) AS `表示順3`
            , IF(v9003m.mj_cyohyoid = '002', v9003m.mj_sortjyun, NULL) AS `表示順4`
            , IF(v9003m.mj_cyohyoid = '013', v9003m.mj_sortjyun, NULL) AS `表示順5`
            , IF(v9003m.mj_cyohyoid = '011', v9003m.mj_sortjyun, NULL) AS `表示順6`
            , IF(v9003m.mj_cyohyoid = '003', v9003m.mj_sortjyun, NULL) AS `表示順7`
            , IF(v9003m.mj_cyohyoid = '012', v9003m.mj_sortjyun, NULL) AS `表示順8`
            , IF(v9003m.mj_cyohyoid = '016', v9003m.mj_sortjyun, NULL) AS `表示順9`
            , IF(v9003m.mj_cyohyoid = '017', v9003m.mj_sortjyun, NULL) AS `表示順10`
            , IF(v9003m.mj_cyohyoid = '019', v9003m.mj_sortjyun, NULL) AS `表示順11`
        FROM dx_ve.tbi999003m v9003m
        WHERE v9003m.mj_cyohyoid IN('000', '001', '002', '003', '011', '012', '013', '016', '017', '019', '022')
    ) bt
    GROUP BY bt.cd_hansya, bt.cd_kaisya, bt.cd_tenpo
)
SELECT
    ROW_NUMBER() OVER(PARTITION BY t201m.cd_hansya, t201m.cd_kaisya ORDER BY t201m.kj_tenpomei, t201m.cd_tenpo) AS `No.`
    , t201m.cd_hansya AS `販社コード`
    , t201m.cd_kaisya AS `会社コード`
    , t201m.cd_tenpo AS `店舗コード`
    , regexp_replace(t201m.kj_tenpomei, '　+$', '') AS `店舗名`
    , NVL(v3001m.tm_kaiten, '09:00:00') AS `開店時間`
    , NVL(v3001m.tm_heiten, '17:00:00') AS `閉店時間`
    , v1001m.nu_sinsyajucyu AS `新車受注`
    , v1001m.nu_sinsyahanbai AS `新車販売`
    , v1001m.nu_jusyajucyu AS `中古車受注`
    , v1001m.nu_jusyahanbai AS `中古車販売`
    , NVL(bs.`表示可否1`, '○') AS `表示可否1`
    , NVL(bs.`表示可否2`, '○') AS `表示可否2`
    , NVL(bs.`表示可否3`, '○') AS `表示可否3`
    , NVL(bs.`表示可否4`, '○') AS `表示可否4`
    , NVL(bs.`表示可否5`, '○') AS `表示可否5`
    , NVL(bs.`表示可否6`, '○') AS `表示可否6`
    , NVL(bs.`表示可否7`, '○') AS `表示可否7`
    , NVL(bs.`表示可否8`, '○') AS `表示可否8`
    , NVL(bs.`表示可否9`, '○') AS `表示可否9`
    , NVL(bs.`表示可否10`, '○') AS `表示可否10`
    , NVL(bs.`表示可否11`, '○') AS `表示可否11`
    , bs.`表示順1`
    , bs.`表示順2`
    , bs.`表示順3`
    , bs.`表示順4`
    , bs.`表示順5`
    , bs.`表示順6`
    , bs.`表示順7`
    , bs.`表示順8`
    , bs.`表示順9`
    , bs.`表示順10`
    , bs.`表示順11`
FROM ai21rep_ve_dx.tbv0201m t201m
LEFT SEMI JOIN ai21rep_ve_dx.tbv0200m t200m
    ON t200m.cd_hansya = t201m.cd_hansya
    AND t200m.cd_kaisya = t201m.cd_kaisya
LEFT JOIN dx_ve.tbi003001m v3001m
    ON v3001m.cd_hansya = t201m.cd_hansya
    AND v3001m.cd_kaisya = t201m.cd_kaisya
    AND v3001m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN dx_ve.tbi001001m v1001m
    ON v1001m.cd_hansya = t201m.cd_hansya
    AND v1001m.cd_kaisya = t201m.cd_kaisya
    AND v1001m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN bs
    ON bs.cd_hansya = t201m.cd_hansya
    AND bs.cd_kaisya = t201m.cd_kaisya
    AND bs.cd_tenpo = t201m.cd_tenpo
;
