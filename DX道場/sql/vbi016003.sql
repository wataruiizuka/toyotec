DROP TABLE IF EXISTS gold.vbi016003;
CREATE TABLE gold.vbi016003 AS
SELECT
    main.cd_hansya AS `販社コード`
    , main.cd_kaisya AS `会社コード`
    , main.kj_tentanms AS `店舗短縮名称`
    , main.kj_kurumame AS `新車車名`
    , main.cd_tenpo AS `店舗コード`
    , CONCAT(kj_kurumame, from_timestamp(dd_jucyuke, 'yyyyMMdd')) AS `車名受注日`
    , RANK() OVER (PARTITION BY cd_hansya, cd_kaisya ORDER BY mj_sortjyun , cd_tenpo) AS `ソート順`
    , daisu AS `台数`
FROM
    (
    SELECT
        main1.cd_hansya
        , main1.cd_kaisya
        , main1.cd_tenpo
        , main1.kj_tentanms
        , main1.dd_jucyuke
        , main1.kj_kurumame
        , sort_sub.mj_sortjyun
        , SUM(daisu) AS daisu
    FROM
        (
        SELECT
            t201m.cd_hansya
            , t201m.cd_kaisya
            , t201m.cd_tenpo
            , t201m.kj_tenpomei
            , t201m.kj_tentanms
            , CAST(tbba001g.dd_jucyuke AS DATE) AS dd_jucyuke
            , TBBF001M.kj_kurumame AS kj_kurumame
            , COUNT(tbba001g.cd_hansya) AS daisu
        FROM
             ai21rep_ve_dx.tbv0201m t201m
        LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m
            ON
            t201m.cd_hansya = tbi999003m.cd_hansya
            AND t201m.cd_kaisya = tbi999003m.cd_kaisya
            AND t201m.cd_tenpo = tbi999003m.cd_tenpo
            AND tbi999003m.mj_cyohyoid = '016'
            AND tbi999003m.kb_tenji = 1
        LEFT JOIN ai21rep_ve_dx.tbba001g tbba001g
            ON
            t201m.cd_hansya = tbba001g.cd_hansya
            AND t201m.cd_kaisya = tbba001g.cd_kaisya
            AND t201m.cd_tenpo = tbba001g.cd_tenpo
        LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M
            ON
            tbba001g.cd_kaisya = TBBF008M.cd_kaisya
            AND tbba001g.cd_hansya = TBBF008M.cd_hansya
            AND tbba001g.mj_sinkysed = TBBF008M.mj_sinkysed
            AND tbba001g.mj_gaihansy = TBBF008M.cd_spec
            AND tbba001g.mj_hantenkt = TBBF008M.mj_hantenkt
            AND TBBF008M.kb_spec = 'G'
        LEFT JOIN ai21rep_ve_dx.tbbf001m TBBF001M
            ON
            TBBF001M.cd_kaisya = TBBF008M.cd_kaisya
            AND TBBF001M.cd_hansya = TBBF008M.cd_hansya
            AND TBBF001M.cd_ncsyamei = TBBF008M.mj_syamei
        LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m
            ON
            TBBF001M.cd_hansya = tbi999008m.cd_hansya
            AND TBBF001M.cd_kaisya = tbi999008m.cd_kaisya
            AND TBBF001M.cd_ncsyamei = tbi999008m.cd_ncsyamei
            AND tbi999008m.kb_tenji = 1
        WHERE
            tbba001g.dd_uritrkkj IS NULL
            AND tbba001g.dd_torikesi IS NULL
            AND tbba001g.dd_jucyuke IS NOT NULL
        GROUP BY
            t201m.cd_hansya,
            t201m.cd_kaisya,
            t201m.cd_tenpo,
            kj_tenpomei,
            kj_tentanms,
            CAST(tbba001g.dd_jucyuke AS DATE),
            kj_kurumame
        HAVING NOT (NVL(t201m.kj_tenpomei, '') LIKE '%廃）%'
                AND COUNT(tbba001g.cd_hansya)= 0)
    ) main1
    LEFT JOIN (
        SELECT
            kj_tentanms
            , t201m_2.cd_hansya
            , t201m_2.cd_kaisya
            , MIN(tbi999003m.mj_sortjyun) AS mj_sortjyun
        FROM
            ai21rep_ve_dx.tbv0201m t201m_2
        INNER JOIN dx_ve.tbi999003m tbi999003m
            ON
            t201m_2.cd_hansya = tbi999003m.cd_hansya
            AND t201m_2.cd_kaisya = tbi999003m.cd_kaisya
            AND t201m_2.cd_tenpo = tbi999003m.cd_tenpo
            AND tbi999003m.mj_cyohyoid = '016'
            AND tbi999003m.kb_tenji = 1
        GROUP BY
            t201m_2.cd_hansya,
            t201m_2.cd_kaisya,
            kj_tentanms
    ) sort_sub
    ON
        main1.cd_hansya = sort_sub.cd_hansya
        AND main1.cd_kaisya = sort_sub.cd_kaisya
        AND main1.kj_tentanms = sort_sub.kj_tentanms
    GROUP BY
        main1.cd_hansya,
        main1.cd_kaisya,
        main1.cd_tenpo,
        main1.kj_tentanms,
        main1.dd_jucyuke,
        sort_sub.mj_sortjyun,
        main1.kj_kurumame
 ) main
;
