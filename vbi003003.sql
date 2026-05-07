DROP TABLE IF EXISTS gold.vbi003003;
CREATE TABLE gold.vbi003003 AS
WITH t275m AS (
    SELECT
        t275m.cd_hansya
        , t275m.cd_kaisya
        , t275m.cd_tenpo
        , v3001.dd_date AS dd_kado
        , CASE day(v3001.dd_date)
            WHEN 1 THEN t275m.kb_kado1
            WHEN 2 THEN t275m.kb_kado2
            WHEN 3 THEN t275m.kb_kado3
            WHEN 4 THEN t275m.kb_kado4
            WHEN 5 THEN t275m.kb_kado5
            WHEN 6 THEN t275m.kb_kado6
            WHEN 7 THEN t275m.kb_kado7
            WHEN 8 THEN t275m.kb_kado8
            WHEN 9 THEN t275m.kb_kado9
            WHEN 10 THEN t275m.kb_kado10
            WHEN 11 THEN t275m.kb_kado11
            WHEN 12 THEN t275m.kb_kado12
            WHEN 13 THEN t275m.kb_kado13
            WHEN 14 THEN t275m.kb_kado14
            WHEN 15 THEN t275m.kb_kado15
            WHEN 16 THEN t275m.kb_kado16
            WHEN 17 THEN t275m.kb_kado17
            WHEN 18 THEN t275m.kb_kado18
            WHEN 19 THEN t275m.kb_kado19
            WHEN 20 THEN t275m.kb_kado20
            WHEN 21 THEN t275m.kb_kado21
            WHEN 22 THEN t275m.kb_kado22
            WHEN 23 THEN t275m.kb_kado23
            WHEN 24 THEN t275m.kb_kado24
            WHEN 25 THEN t275m.kb_kado25
            WHEN 26 THEN t275m.kb_kado26
            WHEN 27 THEN t275m.kb_kado27
            WHEN 28 THEN t275m.kb_kado28
            WHEN 29 THEN t275m.kb_kado29
            WHEN 30 THEN t275m.kb_kado30
            WHEN 31 THEN t275m.kb_kado31
        END AS kb_kado
    FROM ai21rep_ve_dx.tbfy275m t275m
    INNER JOIN dx_ve.vbi003001_en v3001
        ON v3001.dd_month = t275m.dd_kadoyymm
)
SELECT
    v3002.mj_sortjyun
    , v3002.cd_hansya
    , v3002.cd_kaisya
    , v3002.cd_tenpo
    , v3002.kj_tenpomei
    , v3002.cd_hansyakaisyatenpostall
    , v3002.no_stall
    , v3002.mj_stallmei
    , v3002.kb_stallsentaku
    , v3002.cd_zon
    , v3002.kj_zonmei
    , v3002.kb_teigaikitei
    , if(
        t275m.kb_kado NOT IN('1', '9')
        OR t002m.kb_hikado = '1',
        0,
        v3002.kb_teinaikitei
    ) AS kb_teinaikitei,
    if(
        t275m.kb_kado NOT IN('1', '9')
        OR t002m.kb_hikado = '1',
        1,
        0
    ) AS kb_kyukei
    , v3001.dd_date
    , concat(v3002.cd_hansyakaisyatenpostall, v3001.`dd_yyyy/MM/dd`) AS cd_hansyakaisyatenpostalldate
    , v3001.kb_week
FROM dx_ve.vbi003002 v3002
CROSS JOIN dx_ve.vbi003001_en v3001
LEFT JOIN t275m
    ON t275m.cd_hansya = v3002.cd_hansya
    AND t275m.cd_kaisya = v3002.cd_kaisya
    AND t275m.cd_tenpo = v3002.cd_tenpo
    AND t275m.dd_kado = v3001.dd_date
    AND t275m.kb_kado <> 'Z'
LEFT JOIN ai21rep_ve_dx.tbsa002m t002m
    ON t002m.cd_hansya = v3002.cd_hansya
    AND t002m.cd_kaisya = v3002.cd_kaisya
    AND t002m.cd_tenpo = v3002.cd_tenpo
    AND t002m.no_stall = v3002.no_stall
    AND t002m.dd_hikado = v3001.`dd_yyyyMMdd`
;
