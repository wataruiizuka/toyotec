DROP TABLE IF EXISTS gold.vbi012005;
CREATE TABLE gold.vbi012005 AS
SELECT
    v12003.cd_hansya AS `販社コード`
    , v12003.cd_kaisya AS `会社コード`
    , v12003.cd_tenpo AS `店舗コード`
    , concat(v12003.cd_hansya, v12003.cd_kaisya, v12003.cd_tenpo) AS `販社会社店舗コード`
    , v12003.no_stall AS `ストール番号`
    , v12003.mj_stallmei AS `ストール名称`
    , v12003.kb_stallsentaku AS `ストール選択`
    , v12003.dd_date AS `日付`
    , bt.tm_jikoku AS `時刻`
    , if (
        v12003.kb_kyukei = 1,
        1,
        CASE bt.tm_jikoku
            WHEN '08:00' THEN if (minutes_add(v12003.dd_date, 510) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 480) < v12004.dt_siyoed, 1, 0)
            WHEN '08:30' THEN if (minutes_add(v12003.dd_date, 540) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 510) < v12004.dt_siyoed, 1, 0)
            WHEN '09:00' THEN if (minutes_add(v12003.dd_date, 570) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 540) < v12004.dt_siyoed, 1, 0)
            WHEN '09:30' THEN if (minutes_add(v12003.dd_date, 600) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 570) < v12004.dt_siyoed, 1, 0)
            WHEN '10:00' THEN if (minutes_add(v12003.dd_date, 630) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 600) < v12004.dt_siyoed, 1, 0)
            WHEN '10:30' THEN if (minutes_add(v12003.dd_date, 660) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 630) < v12004.dt_siyoed, 1, 0)
            WHEN '11:00' THEN if (minutes_add(v12003.dd_date, 690) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 660) < v12004.dt_siyoed, 1, 0)
            WHEN '11:30' THEN if (minutes_add(v12003.dd_date, 720) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 690) < v12004.dt_siyoed, 1, 0)
            WHEN '12:00' THEN if (minutes_add(v12003.dd_date, 750) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 720) < v12004.dt_siyoed, 1, 0)
            WHEN '12:30' THEN if (minutes_add(v12003.dd_date, 780) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 750) < v12004.dt_siyoed, 1, 0)
            WHEN '13:00' THEN if (minutes_add(v12003.dd_date, 810) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 780) < v12004.dt_siyoed, 1, 0)
            WHEN '13:30' THEN if (minutes_add(v12003.dd_date, 840) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 810) < v12004.dt_siyoed, 1, 0)
            WHEN '14:00' THEN if (minutes_add(v12003.dd_date, 870) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 840) < v12004.dt_siyoed, 1, 0)
            WHEN '14:30' THEN if (minutes_add(v12003.dd_date, 900) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 870) < v12004.dt_siyoed, 1, 0)
            WHEN '15:00' THEN if (minutes_add(v12003.dd_date, 930) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 900) < v12004.dt_siyoed, 1, 0)
            WHEN '15:30' THEN if (minutes_add(v12003.dd_date, 960) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 930) < v12004.dt_siyoed, 1, 0)
            WHEN '16:00' THEN if (minutes_add(v12003.dd_date, 990) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 960) < v12004.dt_siyoed, 1, 0)
            WHEN '16:30' THEN if (minutes_add(v12003.dd_date, 1020) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 990) < v12004.dt_siyoed, 1, 0)
            WHEN '17:00' THEN if (minutes_add(v12003.dd_date, 1050) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 1020) < v12004.dt_siyoed, 1, 0)
            WHEN '17:30' THEN if (minutes_add(v12003.dd_date, 1080) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 1050) < v12004.dt_siyoed, 1, 0)
            WHEN '18:00' THEN if (minutes_add(v12003.dd_date, 1110) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 1080) < v12004.dt_siyoed, 1, 0)
            WHEN '18:30' THEN if (minutes_add(v12003.dd_date, 1140) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 1110) < v12004.dt_siyoed, 1, 0)
            WHEN '19:00' THEN if (minutes_add(v12003.dd_date, 1170) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 1140) < v12004.dt_siyoed, 1, 0)
            WHEN '19:30' THEN if (minutes_add(v12003.dd_date, 1200) > v12004.dt_siyost AND minutes_add(v12003.dd_date, 1170) < v12004.dt_siyoed, 1, 0)
        END
    ) AS `予約不可フラグ`
FROM dx_ve.vbi012003 v12003
INNER JOIN dx_ve.tbi003001m t3001m
    ON t3001m.cd_hansya = v12003.cd_hansya
    AND t3001m.cd_kaisya = v12003.cd_kaisya
    AND t3001m.cd_tenpo = v12003.cd_tenpo
LEFT JOIN dx_ve.vbi012004 v12004
    ON v12004.cd_hansya = v12003.cd_hansya
    AND v12004.cd_kaisya = v12003.cd_kaisya
    AND v12004.cd_tenpo = v12003.cd_tenpo
    AND v12004.no_stall = v12003.no_stall
    AND ((v12004.dt_siyost >= v12003.dd_date AND v12004.dt_siyost < days_add(v12003.dd_date, 1))
    OR (v12004.dt_siyoed >= v12003.dd_date AND v12004.dt_siyoed < days_add(v12003.dd_date, 1))
)
AND v12003.kb_kyukei = 0
CROSS JOIN (
    ON VALUES(('08:00' as tm_jikoku), ('08:30'), ('09:00'), ('09:30'), ('10:00'), ('10:30'), ('11:00'), ('11:30'), ('12:00'), ('12:30'), ('13:00'), ('13:30'), ('14:00'), ('14:30'), ('15:00'), ('15:30'), ('16:00'), ('16:30'), ('17:00'), ('17:30'), ('18:00'), ('18:30'), ('19:00'), ('19:30'))
) bt
WHERE left(t3001m.tm_kaiten, 5) <= bt.tm_jikoku
AND left(t3001m.tm_heiten, 5) > bt.tm_jikoku
;
