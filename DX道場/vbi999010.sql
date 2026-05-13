DROP TABLE IF EXISTS gold.vbi999010;
CREATE TABLE gold.vbi999010 AS
SELECT
    ROW_NUMBER() OVER (PARTITION BY tbv0208m.cd_hansya, tbv0208m.cd_kaisya ORDER BY tbv0208m.kb_nyuukin ASC) AS `No.`
    , tbv0208m.cd_hansya AS 販社コード
    , tbv0208m.cd_kaisya AS 会社コード
    , tbv0208m.kb_nyuukin AS 入金区分
    , tbv0208m.kj_nyuukinm AS 入金区分名
    , IF(tbi999013m.cd_hansya IS NULL , IF(tbv0208m.kj_nyuukinm RLIKE '現金', '○', '×') ,IF(tbi999013m.kb_genkin='1', '○', '×')) AS 現金
    , IF(tbi999013m.cd_hansya IS NULL , IF(tbv0208m.kj_nyuukinm RLIKE 'クレジット', '○', '×'),IF(tbi999013m.kb_crejcard='1', '○', '×')) AS クレジットカード
FROM
    ai21rep_ve_dx.tbv0208m tbv0208m
LEFT JOIN dx_ve.tbi999013m tbi999013m
    ON tbv0208m.cd_hansya = tbi999013m.cd_hansya
    AND tbv0208m.cd_kaisya = tbi999013m.cd_kaisya
    AND tbv0208m.kb_nyuukin = tbi999013m.kb_nyuukin
;
