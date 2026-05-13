DROP TABLE IF EXISTS gold.vbi999006;
CREATE TABLE gold.vbi999006 AS
    SELECT
         tbi999002m.cd_hanbaitn AS `販売店コード`
        ,tbi999002m.mj_cyohyoid AS `帳票ID`
        ,tbi999002m.mj_url AS `URL`
        ,CONCAT(COALESCE(tbv0200m.kj_kaisyatn, ''), '(', tbi999002m.cd_hanbaitn, ')') AS `販売店名`
        ,tbi999006m.mj_url AS `マスタメンテナンスURL`
        ,tbi999002m.kb_sakujo AS `削除フラグ`
    FROM dx_ve.tbi999002m tbi999002m
    LEFT JOIN (
        SELECT
             tbv0200m.cd_hanbaitn
            ,tbv0200m.kj_kaisyatn
            ,ROW_NUMBER() OVER (PARTITION BY tbv0200m.cd_hanbaitn ORDER BY tbv0200m.dd_saisinup DESC) AS rn
      FROM ai21rep_ve_dx.tbv0200m tbv0200m
    ) tbv0200m
    ON tbi999002m.cd_hanbaitn = tbv0200m.cd_hanbaitn
    AND tbv0200m.rn = 1
    LEFT JOIN dx_ve.tbi999006m tbi999006m
        ON tbi999002m.`cd_hanbaitn` = tbi999006m.cd_hanbaitn
        AND tbi999006m.kb_sakujo = 0
;
