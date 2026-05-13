DROP TABLE IF EXISTS gold.vbi999009;
CREATE TABLE gold.vbi999009 AS
SELECT
    ROW_NUMBER() OVER(PARTITION BY tf001m.cd_hansya, tf001m.cd_kaisya ORDER BY CAST(tf001m.nu_symenarb AS int), tf001m.cd_ncsyamei) AS `No.`
    , tf001m.cd_hansya AS `販社コード`
    , tf001m.cd_kaisya AS `会社コード`
    , tf001m.cd_ncsyamei AS `車名コード`
    , CONCAT(tf001m.kn_syame, '##', CAST(ROW_NUMBER() OVER(PARTITION BY tf001m.cd_hansya, tf001m.cd_kaisya ORDER BY CAST(tf001m.nu_symenarb AS int), tf001m.cd_ncsyamei) AS string), '##') AS `カナ車名`
    , CONCAT(tf001m.kj_kurumame, '##', CAST(ROW_NUMBER() OVER(PARTITION BY tf001m.cd_hansya, tf001m.cd_kaisya ORDER BY CAST(tf001m.nu_symenarb AS int), tf001m.cd_ncsyamei) AS string), '##') AS `漢字車名`
    , IF(t9008m.kb_tenji = 0, '×', IF(tf001m.kb_oem IN('0', '3', '6'), '○', '×')) AS `表示可否`
    , CAST(tf001m.nu_symenarb AS int) AS `車名並び順`
FROM ai21rep_ve_dx.tbbf001m tf001m
LEFT JOIN dx_ve.tbi999008m t9008m
    ON t9008m.cd_hansya = tf001m.cd_hansya
    AND t9008m.cd_kaisya = tf001m.cd_kaisya
    AND t9008m.cd_ncsyamei = tf001m.cd_ncsyamei
WHERE tf001m.kn_syame IS NOT NULL
GROUP BY tf001m.cd_hansya, tf001m.cd_kaisya, tf001m.kn_syame, tf001m.cd_ncsyamei, tf001m.kj_kurumame, t9008m.kb_tenji, tf001m.kb_oem, tf001m.nu_symenarb
;
