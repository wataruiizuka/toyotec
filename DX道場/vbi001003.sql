DROP TABLE IF EXISTS gold.vbi001003;
CREATE TABLE gold.vbi001003 AS
SELECT
    cd_hansya AS 販社コード
    , cd_kaisya AS 会社コード
    , cd_tenpo AS 店舗コード
    , kn_syame AS 車名
    , kj_tenpomei AS 店舗名称
    , kj_tentanms AS 店舗短縮名称
    , cd_zon AS ゾーンコード
    , kj_zonmei AS ゾーン名称
    , su_sinsya_jucyu AS 新車受注実績
    , su_sinsya_jucyu_torikesi AS 新車受注取消
    , su_sinsya_jucyu_goukei AS 新車受注合計
    , su_sinsya_jucyucan AS 新車受注残
    , su_sinsya_hanbai AS 新車販売実績
    , su_sinsya_hanbai_torikesi AS 新車販売取消
    , su_sinsya_hanbai_goukei AS 新車販売合計
    , dd_jucyu AS 受注日付
    , dd_sinsya_hanbai AS 新車販売日付
    , DENSE_RANK() OVER (
        PARTITION BY cd_hansya,cd_kaisya
        ORDER BY cd_zon,mj_sortjyun
    ) AS 店舗ソート順,
    DENSE_RANK() OVER (
        PARTITION BY cd_hansya,cd_kaisya
        ORDER BY sort_sin,syamei_sin,kn_syame
    ) AS 車名ソート順
FROM
    (
SELECT
    t201m.cd_hansya
    , t201m.cd_kaisya
    , t201m.cd_tenpo
    , syame.kn_syame
    , t201m.kj_tenpomei
    , t201m.kj_tentanms
    , IF(
        t033m.kj_zonmei IS NULL OR regexp_replace(t033m.kj_zonmei, '[ 　]+', '') = '',
        '999999',
        IF(
            t033m.cd_zon IS NULL OR regexp_replace(t033m.cd_zon, '[ 　]+', '') = '',
            '999998',
            t033m.cd_zon
        )
    ) AS cd_zon,
    t033m.kj_zonmei
    , syame.su_sinsya_jucyu AS su_sinsya_jucyu
    , syame.su_sinsya_jucyu_torikesi AS su_sinsya_jucyu_torikesi
    , syame.su_sinsya_jucyu_goukei AS su_sinsya_jucyu_goukei
    , syame.su_sinsya_jucyucan AS su_sinsya_jucyucan
    , syame.su_sinsya_hanbai AS su_sinsya_hanbai
    , syame.su_sinsya_hanbai_torikesi AS su_sinsya_hanbai_torikesi
    , syame.su_sinsya_hanbai_goukei AS su_sinsya_hanbai_goukei
    , syame.dd_jucyu
    , syame.dd_sinsya_hanbai
    , RANK() OVER (
        PARTITION BY t201m.cd_hansya, t201m.cd_kaisya
        ORDER BY tbi999003m.mj_sortjyun, t201m.cd_tenpo
    ) AS mj_sortjyun,
        MIN(sort_car_sin.mj_sortjyun) OVER ( PARTITION BY t201m.cd_hansya, t201m.cd_kaisya, sort_car_sin.kn_syamei ) AS sort_sin
        , MIN(sort_car_sin.cd_ncsyamei) OVER ( PARTITION BY t201m.cd_hansya, t201m.cd_kaisya, sort_car_sin.kn_syamei ) AS syamei_sin
FROM ai21rep_ve_dx.tbv0201m t201m
LEFT JOIN dx_ve.tbi999003m tbi999003m
    ON t201m.cd_hansya = tbi999003m.cd_hansya
    AND t201m.cd_kaisya = tbi999003m.cd_kaisya
    AND t201m.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '001'
LEFT JOIN ai21rep_ve_dx.tbv0047m t047m
    ON t047m.cd_hansya = t201m.cd_hansya
    AND t047m.cd_kaisya = t201m.cd_kaisya
    AND t047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m t033m
    ON t033m.cd_hansya = t201m.cd_hansya
    AND t033m.cd_kaisya = t201m.cd_kaisya
    AND t033m.cd_zon = t047m.cd_nczon
    AND t033m.kb_syohin = '1'
LEFT JOIN (
    SELECT
        all_view.cd_hansya
        , all_view.cd_kaisya
        , all_view.cd_tenpo
        , all_view.kn_syame
        , SUM(su_sinsya_jucyu) AS su_sinsya_jucyu
        , SUM(su_sinsya_jucyu_torikesi) AS su_sinsya_jucyu_torikesi
        , SUM(su_sinsya_jucyu_goukei) AS su_sinsya_jucyu_goukei
        , SUM(su_sinsya_jucyucan) AS su_sinsya_jucyucan
        , SUM(su_sinsya_hanbai) AS su_sinsya_hanbai
        , SUM(su_sinsya_hanbai_torikesi) AS su_sinsya_hanbai_torikesi
        , SUM(su_sinsya_hanbai_goukei) AS su_sinsya_hanbai_goukei
        , dd_jucyu
        , dd_sinsya_hanbai
    FROM (
        SELECT
            v1.cd_hansya
            , v1.cd_kaisya
            , v1.cd_tenpo
            , v1.cd_ncsyamei
            , v1.kn_syame
            , v1.su_sinsya_jucyu
            , v1.su_sinsya_jucyu_torikesi
            , v1.su_sinsya_jucyu_goukei
            , v1.su_sinsya_jucyucan
            , NULL AS su_jusya_jucyu
            , NULL AS su_jusya_jucyu_torikesi
            , NULL AS su_jusya_jucyu_goukei
            , NULL AS su_jusya_jucyucan
            , NULL AS su_sinsya_hanbai
            , NULL AS su_sinsya_hanbai_torikesi
            , NULL AS su_sinsya_hanbai_goukei
            , NULL AS su_jusya_hanbai
            , NULL AS su_jusya_hanbai_torikesi
            , NULL AS su_jusya_hanbai_goukei
            , NULL AS su_jusya_hanbai_current
            , NULL AS su_jusya_hanbai_mikomi
            , v1.dd_date AS dd_jucyu
            , NULL AS dd_sinsya_hanbai
            , NULL AS dd_jusya_hanbai
            , NULL AS dd_jusya_mikomi
        FROM dx_ve.vbi001001 v1
        UNION ALL
        SELECT
            v2.cd_hansya
            , v2.cd_kaisya
            , v2.cd_tenpo
            , v2.cd_ncsyamei
            , v2.kn_syame
            , NULL AS su_sinsya_jucyu
            , NULL AS su_sinsya_jucyu_torikesi
            , NULL AS su_sinsya_jucyu_goukei
            , NULL AS su_sinsya_jucyucan
            , NULL AS su_jusya_jucyu
            , NULL AS su_jusya_jucyu_torikesi
            , NULL AS su_jusya_jucyu_goukei
            , NULL AS su_jusya_jucyucan
            , v2.su_sinsya_hanbai
            , v2.su_sinsya_hanbai_torikesi
            , v2.su_sinsya_hanbai_goukei
            , NULL AS su_jusya_hanbai
            , NULL AS su_jusya_hanbai_torikesi
            , NULL AS su_jusya_hanbai_goukei
            , NULL AS su_jusya_hanbai_current
            , NULL AS su_jusya_hanbai_mikomi
            , NULL AS dd_jucyu
            , v2.dd_date AS dd_sinsya_hanbai
            , NULL AS dd_jusya_hanbai
            , NULL AS dd_jusya_mikomi
        FROM dx_ve.vbi001002 v2
    ) all_view
    LEFT JOIN dx_ve.tbi999008m tbi999008m
        ON tbi999008m.cd_hansya = all_view.cd_hansya
        AND tbi999008m.cd_kaisya = all_view.cd_kaisya
        AND tbi999008m.cd_ncsyamei = all_view.cd_ncsyamei
        AND tbi999008m.kb_tenji = 1
    WHERE
        tbi999008m.cd_hansya IS NOT NULL
    GROUP BY
        cd_hansya,
        cd_kaisya,
        cd_tenpo,
        kn_syame,
        dd_jucyu,
        dd_sinsya_hanbai
) syame
    ON t201m.cd_hansya = syame.cd_hansya
    AND t201m.cd_kaisya = syame.cd_kaisya
    AND t201m.cd_tenpo = syame.cd_tenpo
LEFT JOIN (SELECT
    ON tbi999008m.cd_hansya,
                 tbi999008m.cd_kaisya,
                 TRIM(tbi999008m.kn_syamei) AS kn_syamei,
                 MIN(tbi999008m.mj_sortjyun) AS mj_sortjyun,
                 MIN(tbi999008m.cd_ncsyamei) AS cd_ncsyamei
         FROM dx_ve.tbi999008m
        WHERE
            tbi999008m.kb_tenji = 1
        GROUP BY
            tbi999008m.cd_hansya,
            tbi999008m.cd_kaisya,
            TRIM(tbi999008m.kn_syamei)
        ) sort_car_sin
    ON syame.cd_hansya = sort_car_sin.cd_hansya
    AND syame.cd_kaisya = sort_car_sin.cd_kaisya
    AND TRIM(syame.kn_syame) = TRIM(sort_car_sin.kn_syamei)
WHERE
    tbi999003m.kb_tenji = 1
) sinsya_nippou
;
