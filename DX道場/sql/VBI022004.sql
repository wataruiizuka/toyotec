DROP TABLE IF EXISTS gold.vbi022004;
CREATE TABLE gold.vbi022004 AS
SELECT
    cd_hansya AS `販社コード`
    , cd_kaisya AS `会社コード`
    , cd_tenpo AS `店舗コード`
    , kn_syame AS `車名`
    , kj_tenpomei AS `店舗名称`
    , kj_tentanms AS `店舗短縮名称`
    , cd_zon AS `ゾーンコード`
    , kj_zonmei AS `ゾーン名称`
    , su_jusya_jucyu AS `中古車受注実績`
    , su_jusya_jucyu_torikesi AS `中古車受注取消`
    , su_jusya_jucyu_goukei AS `中古車受注合計`
    , su_jusya_jucyucan AS `中古車受注残`
    , su_jusya_hanbai AS `中古車販売実績`
    , su_jusya_hanbai_torikesi AS `中古車販売取消`
    , su_jusya_hanbai_goukei AS `中古車販売合計`
    , su_jusya_hanbai_current AS `当月中古車販売`
    , su_jusya_hanbai_mikomi AS `中古車販売見込み`
    , dd_jucyu AS `受注日付`
    , dd_jusya_hanbai AS `中古車販売日付`
    , dd_jusya_mikomi AS `中古車見込み日付`
    , DENSE_RANK() OVER (
        PARTITION BY cd_hansya,cd_kaisya
        ORDER BY cd_zon,mj_sortjyun
    ) AS `店舗ソート順`,
    DENSE_RANK() OVER (
        PARTITION BY cd_hansya,cd_kaisya
        ORDER BY sort_tyu,syamei_tyu,kn_syame
    ) AS `車名ソート順`
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
    , syame.su_jusya_jucyu AS su_jusya_jucyu
    , syame.su_jusya_jucyu_torikesi AS su_jusya_jucyu_torikesi
    , syame.su_jusya_jucyu_goukei AS su_jusya_jucyu_goukei
    , syame.su_jusya_jucyucan AS su_jusya_jucyucan
    , syame.su_jusya_hanbai AS su_jusya_hanbai
    , syame.su_jusya_hanbai_torikesi AS su_jusya_hanbai_torikesi
    , syame.su_jusya_hanbai_goukei AS su_jusya_hanbai_goukei
    , syame.su_jusya_hanbai_current AS su_jusya_hanbai_current
    , syame.su_jusya_hanbai_mikomi AS su_jusya_hanbai_mikomi
    , syame.dd_jucyu
    , syame.dd_jusya_hanbai
    , syame.dd_jusya_mikomi
    , RANK() OVER (
        PARTITION BY t201m.cd_hansya, t201m.cd_kaisya
        ORDER BY tbi999003m.mj_sortjyun, t201m.cd_tenpo
    ) AS mj_sortjyun,
        MIN(sort_car_tyu.mj_sortjyun) OVER ( PARTITION BY t201m.cd_hansya, t201m.cd_kaisya, sort_car_tyu.kn_syame ) AS sort_tyu
        , MIN(sort_car_tyu.cd_ocsyamei) OVER ( PARTITION BY t201m.cd_hansya, t201m.cd_kaisya, sort_car_tyu.kn_syame ) AS syamei_tyu
FROM ai21rep_ve_dx.tbv0201m t201m
LEFT JOIN dx_ve.tbi999003m tbi999003m
    ON t201m.cd_hansya = tbi999003m.cd_hansya
    AND t201m.cd_kaisya = tbi999003m.cd_kaisya
    AND t201m.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '022'
LEFT JOIN ai21rep_ve_dx.tbv0047m t047m
    ON t047m.cd_hansya = t201m.cd_hansya
    AND t047m.cd_kaisya = t201m.cd_kaisya
    AND t047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m t033m
    ON t033m.cd_hansya = t201m.cd_hansya
    AND t033m.cd_kaisya = t201m.cd_kaisya
    AND t033m.cd_zon = t047m.cd_uczon
    AND t033m.kb_syohin = '2'
LEFT JOIN (
    SELECT
        all_view.cd_hansya
        , all_view.cd_kaisya
        , all_view.cd_tenpo
        , all_view.kn_syame
        , SUM(su_jusya_jucyu) AS su_jusya_jucyu
        , SUM(su_jusya_jucyu_torikesi) AS su_jusya_jucyu_torikesi
        , SUM(su_jusya_jucyu_goukei) AS su_jusya_jucyu_goukei
        , SUM(su_jusya_jucyucan) AS su_jusya_jucyucan
        , SUM(su_jusya_hanbai) AS su_jusya_hanbai
        , SUM(su_jusya_hanbai_torikesi) AS su_jusya_hanbai_torikesi
        , SUM(su_jusya_hanbai_goukei) AS su_jusya_hanbai_goukei
        , SUM(su_jusya_hanbai_current) AS su_jusya_hanbai_current
        , SUM(su_jusya_hanbai_mikomi) AS su_jusya_hanbai_mikomi
        , dd_jucyu
        , dd_jusya_hanbai
        , dd_jusya_mikomi
    FROM (
        SELECT
            v1.cd_hansya
            , v1.cd_kaisya
            , v1.cd_tenpo
            , v1.cd_ncsyamei
            , v1.kn_syame
            , v1.su_jusya_jucyu
            , v1.su_jusya_jucyu_torikesi
            , v1.su_jusya_jucyu_goukei
            , v1.su_jusya_jucyucan
            , NULL AS su_jusya_hanbai
            , NULL AS su_jusya_hanbai_torikesi
            , NULL AS su_jusya_hanbai_goukei
            , NULL AS su_jusya_hanbai_current
            , NULL AS su_jusya_hanbai_mikomi
            , v1.dd_date AS dd_jucyu
            , NULL AS dd_jusya_hanbai
            , NULL AS dd_jusya_mikomi
        FROM dx_ve.vbi022001 v1
        UNION ALL
        SELECT
            v2.cd_hansya
            , v2.cd_kaisya
            , v2.cd_tenpo
            , v2.cd_ncsyamei
            , v2.kn_syame
            , NULL AS su_jusya_jucyu
            , NULL AS su_jusya_jucyu_torikesi
            , NULL AS su_jusya_jucyu_goukei
            , NULL AS su_jusya_jucyucan
            , v2.su_jusya_hanbai
            , v2.su_jusya_hanbai_torikesi
            , v2.su_jusya_hanbai_goukei
            , v2.su_jusya_hanbai_current
            , NULL AS su_jusya_hanbai_mikomi
            , NULL AS dd_jucyu
            , v2.dd_date AS dd_jusya_hanbai
            , NULL AS dd_jusya_mikomi
        FROM dx_ve.vbi022002 v2
        UNION ALL
        SELECT
            v3.cd_hansya
            , v3.cd_kaisya
            , v3.cd_tenpo
            , v3.cd_ncsyamei
            , v3.kn_syame
            , NULL AS su_jusya_jucyu
            , NULL AS su_jusya_jucyu_torikesi
            , NULL AS su_jusya_jucyu_goukei
            , NULL AS su_jusya_jucyucan
            , NULL AS su_jusya_hanbai
            , NULL AS su_jusya_hanbai_torikesi
            , NULL AS su_jusya_hanbai_goukei
            , NULL AS su_jusya_hanbai_current
            , v3.su_jusya_hanbai_mikomi
            , NULL AS dd_jucyu
            , NULL AS dd_jusya_hanbai
            , v3.dd_uriagyot AS dd_jusya_mikomi
        FROM dx_ve.vbi022003 v3
    ) all_view
    LEFT JOIN dx_ve.tbi999009m tbi999009m
        ON tbi999009m.cd_hansya = all_view.cd_hansya
        AND tbi999009m.cd_kaisya = all_view.cd_kaisya
        AND tbi999009m.cd_ocsyamei = all_view.cd_ncsyamei
        AND tbi999009m.kb_tenji = 1
    WHERE
        tbi999009m.cd_hansya IS NOT NULL
    GROUP BY
        cd_hansya,
        cd_kaisya,
        cd_tenpo,
        kn_syame,
        dd_jucyu,
        dd_jusya_hanbai,
        dd_jusya_mikomi
) syame
    ON t201m.cd_hansya = syame.cd_hansya
    AND t201m.cd_kaisya = syame.cd_kaisya
    AND t201m.cd_tenpo = syame.cd_tenpo
LEFT JOIN (SELECT
    ON tbi999009m.cd_hansya,
                 tbi999009m.cd_kaisya,
                 TRIM(tbi999009m.kn_syame) AS kn_syame,
                 MIN(tbi999009m.mj_sortjyun) AS mj_sortjyun,
                 MIN(tbi999009m.cd_ocsyamei) AS cd_ocsyamei
         FROM dx_ve.tbi999009m
        WHERE
            tbi999009m.kb_tenji = 1
        GROUP BY
            tbi999009m.cd_hansya,
            tbi999009m.cd_kaisya,
            TRIM(tbi999009m.kn_syame)
        ) sort_car_tyu
    ON syame.cd_hansya = sort_car_tyu.cd_hansya
    AND syame.cd_kaisya = sort_car_tyu.cd_kaisya
    AND TRIM(syame.kn_syame) = TRIM(sort_car_tyu.kn_syame)
WHERE
    tbi999003m.kb_tenji = 1
) zhugokusya_nippou
;
