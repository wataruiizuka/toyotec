DROP TABLE IF EXISTS gold.vbi003006_en;
CREATE TABLE gold.vbi003006_en AS
WITH crs AS(
    SELECT
        v3004.cd_hansya
        , v3004.cd_kaisya
        , v3004.cd_tenpo
        , v3004.no_yoyakuid
        , v3004.cd_yoykmsai
        , sum(nvl(v3005.tm_kyukeensecond - v3005.tm_kyukestsecond, 0)) AS tm_mtgkyukesecond
    FROM dx_ve.vbi003004 v3004
    LEFT JOIN dx_ve.vbi003005 v3005
        ON v3005.cd_hansya = v3004.cd_hansya
        AND v3005.cd_kaisya = v3004.cd_kaisya
        AND v3005.cd_tenpo = v3004.cd_tenpo
        AND v3005.no_stall = v3004.no_stall
        AND v3005.tm_kyukest > from_timestamp(v3004.dt_siyost, 'HH:mm:ss')
        AND v3005.tm_kyukeen < from_timestamp(v3004.dt_siyoed, 'HH:mm:ss')
    GROUP BY v3004.cd_hansya, v3004.cd_kaisya, v3004.cd_tenpo, v3004.no_yoyakuid, v3004.cd_yoykmsai
)
SELECT
    bt.cd_hansya
    , bt.cd_kaisya
    , bt.cd_tenpo
    , bt.no_yoyakuid
    , bt.cd_yoykmsai
    , bt.no_stall
    , bt.mj_gyme
    , bt.kb_koutei
    , bt.dt_siyost AS dt_nyuukoyt
    , bt.dt_siyoed AS dt_shukkoyt
    , bt.tm_siyotime
    , bt.kb_nyuuko
    , bt.cd_jisekist
    , t231m.mj_kubunnai AS mj_jisekist
    , bt.cd_restcros
    , bt.mj_sakujyo
    , concat(bt.cd_hansyakaisyatenpostall, from_timestamp(bt.dt_siyost, 'yyyy/MM/dd')) AS cd_hansyakaisyatenpostalldate
    , bt.dd_nyuukoyt
    , IF (
        bt.kb_shukkonyuko = 1,
        IF (
            bt.tm_nyuukoytsecond < bt.tm_taikinsecond,
            bt.tm_siyotime,
            null
        ),
        IF (
            bt.tm_nyuukoytsecond <= bt.tm_shukkinsecond AND bt.tm_shukkoytsecond <= bt.tm_shukkinsecond,
            null,
            IF (
                bt.tm_nyuukoytsecond <= bt.tm_shukkinsecond AND bt.tm_shukkoytsecond > bt.tm_shukkinsecond AND bt.tm_shukkoytsecond <= bt.tm_taikinsecond,
                (bt.tm_shukkoytsecond - bt.tm_shukkinsecond) / 60,
                IF (
                    bt.tm_nyuukoytsecond <= bt.tm_shukkinsecond AND bt.tm_shukkoytsecond > bt.tm_taikinsecond,
                    (bt.tm_taikinsecond - bt.tm_shukkinsecond) / 60,
                    IF (
                        bt.tm_nyuukoytsecond > bt.tm_shukkinsecond AND bt.tm_nyuukoytsecond <= bt.tm_taikinsecond AND bt.tm_shukkoytsecond > bt.tm_shukkinsecond AND bt.tm_shukkoytsecond <= bt.tm_taikinsecond,
                        (bt.tm_shukkoytsecond - bt.tm_nyuukoytsecond) / 60,
                        IF (
                            bt.tm_nyuukoytsecond > bt.tm_shukkinsecond AND bt.tm_nyuukoytsecond <= bt.tm_taikinsecond AND bt.tm_shukkoytsecond > bt.tm_taikinsecond,
                            (bt.tm_taikinsecond - bt.tm_nyuukoytsecond) / 60,
                            IF (
                                bt.tm_nyuukoytsecond > bt.tm_taikinsecond,
                                0,
                                null
                            )
                        )
                    )
                )
            )
        )
    ) - IF (
        bt.cd_restcros = '0' OR bt.cd_restcros = '2',
        0,
        IF (
            bt.kb_shukkonyuko = 1,
            0,
            IF (
                bt.kb_stall_syasumi_dif = 0,
                (bt.tm_shukkoytsecond - bt.tm_nyuukoytsecond) / 60,
                (bt.tm_nyukoyukesecond + bt.tm_shukkoyukesecond + bt.tm_mtgkyukesecond) / 60
            )
        )
    ) AS mj_yoyaku
    , bt.tm_shukkin
    , bt.tm_taikin
    , bt.tm_zangyo
FROM(
    SELECT
        v3004.cd_hansya
        , v3004.cd_kaisya
        , v3004.cd_tenpo
        , v3004.no_yoyakuid
        , v3004.cd_yoykmsai
        , v3004.no_stall
        , v3004.mj_gyme
        , v3004.kb_koutei
        , v3004.dt_siyost
        , v3004.dt_siyoed
        , v3004.tm_siyotime
        , v3004.kb_nyuuko
        , v3004.cd_jisekist
        , v3004.cd_restcros
        , v3004.mj_sakujyo
        , concat(v3004.cd_hansya, v3004.cd_kaisya, v3004.cd_tenpo, v3004.mj_stallno) AS cd_hansyakaisyatenpostall
        , v3004.dd_nyuukoyt
        , IF (v3004.dd_nyuukoyt <> v3004.dd_shukkoyt, 1, 0) AS kb_shukkonyuko
        , IF (v3005i.no_stlkyuke IS NULL AND v3005o.no_stlkyuke IS NULL, 2, IF (nvl(v3005i.no_stlkyuke, -1) <> nvl(v3005o.no_stlkyuke, -1), 1, 0)) AS kb_stall_syasumi_dif
        , v3004.tm_nyuukoytsecond
        , v3004.tm_shukkoytsecond
        , v3002.tm_kaiten AS tm_shukkin
        , v3002.tm_shukkinsecond
        , v3002.tm_heiten AS tm_taikin
        , v3002.tm_taikinsecond
        , v3002.tm_zangyo
        , nvl(v3005i.tm_kyukeensecond - v3004.tm_nyuukoytsecond, 0) AS tm_nyukoyukesecond
        , nvl(v3004.tm_shukkoytsecond - v3005o.tm_kyukestsecond, 0) AS tm_shukkoyukesecond
        , nvl(crs.tm_mtgkyukesecond, 0) AS tm_mtgkyukesecond
    FROM dx_ve.vbi003004 v3004
    LEFT SEMI JOIN dx_ve.vbi003003 v3003
        ON v3003.cd_hansya = v3004.cd_hansya
        AND v3003.cd_kaisya = v3004.cd_kaisya
        AND v3003.cd_tenpo = v3004.cd_tenpo
        AND v3003.no_stall = v3004.no_stall
        AND v3003.dd_date = v3004.dd_nyuukoyt
        AND v3003. kb_kyukei = 0
    LEFT JOIN dx_ve.vbi003002 v3002
        ON v3002.cd_hansya = v3004.cd_hansya
        AND v3002.cd_kaisya = v3004.cd_kaisya
        AND v3002.cd_tenpo = v3004.cd_tenpo
        AND v3002.no_stall = v3004.no_stall
    LEFT JOIN dx_ve.vbi003005 v3005i
        ON v3005i.cd_hansya = v3004.cd_hansya
        AND v3005i.cd_kaisya = v3004.cd_kaisya
        AND v3005i.cd_tenpo = v3004.cd_tenpo
        AND v3005i.no_stall = v3004.no_stall
        AND v3005i.tm_kyukestsecond <= v3004.tm_nyuukoytsecond
        AND v3005i.tm_kyukeensecond >= v3004.tm_nyuukoytsecond
    LEFT JOIN dx_ve.vbi003005 v3005o
        ON v3005o.cd_hansya = v3004.cd_hansya
        AND v3005o.cd_kaisya = v3004.cd_kaisya
        AND v3005o.cd_tenpo = v3004.cd_tenpo
        AND v3005o.no_stall = v3004.no_stall
        AND v3005o.tm_kyukestsecond <= v3004.tm_shukkoytsecond
        AND v3005o.tm_kyukeensecond >= v3004.tm_shukkoytsecond
    LEFT JOIN crs
        ON crs.cd_hansya = v3004.cd_hansya
        AND crs.cd_kaisya = v3004.cd_kaisya
        AND crs.cd_tenpo = v3004.cd_tenpo
        AND crs.no_yoyakuid = v3004.no_yoyakuid
        AND crs.cd_yoykmsai = v3004.cd_yoykmsai
) bt
LEFT JOIN ai21rep_ve_dx.tbv0231m t231m
    ON t231m.cd_hansya = bt.cd_hansya
    AND t231m.cd_kaisya = bt.cd_kaisya
    AND t231m.mj_blockid = '09'
    AND t231m.mj_kubunid = '0016'
    AND t231m.cd_kubun = bt.cd_jisekist
;
