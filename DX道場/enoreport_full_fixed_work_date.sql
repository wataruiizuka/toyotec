DROP TABLE IF EXISTS gold.enoreport_full_fixed_work_date;
CREATE TABLE gold.enoreport_full_fixed_work_date AS
SELECT
    t.cd_hansya
    , t.cd_kaisya
    , TO_TIMESTAMP(
        concat(
            CAST(t.nu_yyyy AS STRING), '-',
            lpad(CAST(t.nu_tuki AS STRING),2,'0'), '-',
            lpad(CAST(d.day AS STRING),2,'0')
        ) , 'yyyy-MM-dd'
    ) AS mj_youbi
FROM ai21rep_ve_dx.tbbf018m t
CROSS JOIN (
    SELECT 1 AS day UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
    UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8
    UNION ALL SELECT 9 UNION ALL SELECT 10 UNION ALL SELECT 11 UNION ALL SELECT 12
    UNION ALL SELECT 13 UNION ALL SELECT 14 UNION ALL SELECT 15 UNION ALL SELECT 16
    UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL SELECT 19 UNION ALL SELECT 20
    UNION ALL SELECT 21 UNION ALL SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24
    UNION ALL SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL SELECT 28
    UNION ALL SELECT 29 UNION ALL SELECT 30 UNION ALL SELECT 31
) d
WHERE
    t.nu_karend = 10
    AND
    CASE d.day
        WHEN 1 THEN t.mj_kyjium1
        WHEN 2 THEN t.mj_kyjium2
        WHEN 3 THEN t.mj_kyjium3
        WHEN 4 THEN t.mj_kyjium4
        WHEN 5 THEN t.mj_kyjium5
        WHEN 6 THEN t.mj_kyjium6
        WHEN 7 THEN t.mj_kyjium7
        WHEN 8 THEN t.mj_kyjium8
        WHEN 9 THEN t.mj_kyjium9
        WHEN 10 THEN t.mj_kyjium10
        WHEN 11 THEN t.mj_kyjium11
        WHEN 12 THEN t.mj_kyjium12
        WHEN 13 THEN t.mj_kyjium13
        WHEN 14 THEN t.mj_kyjium14
        WHEN 15 THEN t.mj_kyjium15
        WHEN 16 THEN t.mj_kyjium16
        WHEN 17 THEN t.mj_kyjium17
        WHEN 18 THEN t.mj_kyjium18
        WHEN 19 THEN t.mj_kyjium19
        WHEN 20 THEN t.mj_kyjium20
        WHEN 21 THEN t.mj_kyjium21
        WHEN 22 THEN t.mj_kyjium22
        WHEN 23 THEN t.mj_kyjium23
        WHEN 24 THEN t.mj_kyjium24
        WHEN 25 THEN t.mj_kyjium25
        WHEN 26 THEN t.mj_kyjium26
        WHEN 27 THEN t.mj_kyjium27
        WHEN 28 THEN t.mj_kyjium28
        WHEN 29 THEN t.mj_kyjium29
        WHEN 30 THEN t.mj_kyjium30
        WHEN 31 THEN t.mj_kyjium31
    END IN ('0','1')
;
