DROP TABLE IF EXISTS gold.vbi999003;
CREATE TABLE gold.vbi999003 AS
SELECT
    1 AS `No.`
    , t200m.cd_hansya AS `販社コード`
    , t200m.cd_kaisya AS `会社コード`
    , '新車' AS `新車中古車区分`
    , CAST(NVL(v2001m.su_leadtime, 20) AS string) AS `リードタイム日`
    , NVL(v2001m.su_minosya, 30) AS `未納車経過日`
    , NVL(v2001m.su_touroku, 90) AS `登録経過日`
    , CAST(NVL(v2001m.su_fr, 90) AS string) AS `振当経過日`
    , NVL(v2001m.su_jucyu, 365) AS `受注経過日`
FROM ai21rep_ve_dx.tbv0200m t200m
LEFT JOIN dx_ve.tbi002001m v2001m
    ON v2001m.cd_hansya = t200m.cd_hansya
    AND v2001m.cd_kaisya = t200m.cd_kaisya
UNION ALL
SELECT
    2 AS `No.`
    , t200m.cd_hansya AS `販社コード`
    , t200m.cd_kaisya AS `会社コード`
    , '中古車' AS `新車中古車区分`
    , '-' AS `リードタイム日`
    , NVL(v13001m.su_minosya, 14) AS `未納車経過日`
    , NVL(v13001m.su_touroku, 30) AS `登録経過日`
    , '-' AS `振当経過日`
    , NVL(v13001m.su_jucyu, 30) AS `受注経過日`
FROM ai21rep_ve_dx.tbv0200m t200m
LEFT JOIN dx_ve.tbi013001m v13001m
    ON v13001m.cd_hansya = t200m.cd_hansya
    AND v13001m.cd_kaisya = t200m.cd_kaisya
;
