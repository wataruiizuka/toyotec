DROP TABLE IF EXISTS gold.vbi013015;
CREATE TABLE gold.vbi013015 AS
WITH alert_text AS (
    SELECT '0' AS value, '' AS alert_text
    UNION ALL
    SELECT '1', ''
    UNION ALL
    SELECT '2', ''
    UNION ALL
    SELECT '3', ''
    UNION ALL
    SELECT '4', ''
    UNION ALL
    SELECT '5', ''
    UNION ALL
    SELECT '6', ''
    UNION ALL
    SELECT 'a', '売掛回収チェック'
    UNION ALL
    SELECT 'b', '未納車14日経過'
    UNION ALL
    SELECT 'c', '登録30日経過'
    UNION ALL
    SELECT 'd', '受注30日経過'
    )
SELECT
     tbi013001m.cd_hansya AS `販社コード`
    ,tbi013001m.cd_kaisya AS `会社コード`
    ,value AS `値`
    ,CASE
        WHEN value = 'b' THEN CONCAT('未納車', CAST(COALESCE(tbi013001m.su_minosya, 14) AS STRING), '日経過')
        WHEN value = 'c' THEN CONCAT('登録', CAST(COALESCE(tbi013001m.su_touroku, 30) AS STRING), '日経過')
        WHEN value = 'd' THEN CONCAT('受注', CAST(COALESCE(tbi013001m.su_jucyu, 30) AS STRING), '日経過')
        ELSE alert_text
    END AS `アラート文言`
FROM
    alert_text
CROSS JOIN
    ON dx_ve.tbi013001m tbi013001m
