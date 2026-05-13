DROP TABLE IF EXISTS gold.vbi016009;
CREATE TABLE gold.vbi016009 AS
SELECT
    `販社コード`
    , `会社コード`
    , `店舗コード`
    , `店舗短縮名称`
    , `ゾーンコード`
    , `ゾーン名称`
    , `グレード`
    , `品名カナ`
    , `新車車名`
    , `受注計上日`
    , RANK() OVER (PARTITION BY `販社コード`,`会社コード` ORDER BY IF(NVL(`ゾーン名称`,'') = '', 0,1), `ゾーン名称` ,`ソート順` , `店舗コード`) AS `ソート順`
    , RANK() OVER (PARTITION BY `販社コード`, `会社コード` ORDER BY `車名ソート順`, `新車車名コード`) AS `車名ソート順`
    , `台数`
FROM(
    SELECT
        t201m.cd_hansya AS `販社コード`
        , t201m.cd_kaisya AS `会社コード`
        , t201m.cd_tenpo AS `店舗コード`
        , sort_sub.mj_sortjyun AS `ソート順`
        , MIN(sort_car.mj_sortjyun) AS `車名ソート順`
        , MIN(sort_car.cd_ncsyamei) AS `新車車名コード`
        , t201m.kj_tentanms AS `店舗短縮名称`
        , IF(
        (tbv0033m.cd_zon IS NULL OR regexp_replace(tbv0033m.cd_zon, '[ 　]+', '') = ''),
            IF((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = ''),
            '999999',
            '999998'
            ),
            IF(((tbv0033m.kj_zonmei IS NULL OR regexp_replace(tbv0033m.kj_zonmei, '[ 　]+', '') = '')),
            '999999',
            tbv0033m.cd_zon)
        ) AS `ゾーンコード`,
        tbv0033m.kj_zonmei AS `ゾーン名称`
        , tbv0229m.mj_guredo AS `グレード`
        , tbbf007m.kn_hinmei AS `品名カナ`
        , tbbf001m.kj_kurumame AS `新車車名`
        , CAST(tbba001g.dd_jucyuke AS DATE) AS `受注計上日`
        , COUNT(tbba001g.cd_hansya) AS `台数`
    FROM  ai21rep_ve_dx.tbv0201m t201m
    INNER JOIN dx_ve.tbi999003m tbi999003m
        ON t201m.cd_hansya = tbi999003m.cd_hansya
        AND t201m.cd_kaisya = tbi999003m.cd_kaisya
        AND t201m.cd_tenpo = tbi999003m.cd_tenpo
        AND tbi999003m.mj_cyohyoid = '016'
        AND tbi999003m.kb_tenji = 1
    LEFT JOIN ai21rep_ve_dx.tbba001g tbba001g
        ON tbba001g.cd_kaisya = t201m.cd_kaisya
        AND tbba001g.cd_hansya = t201m.cd_hansya
        AND tbba001g.cd_tenpo = t201m.cd_tenpo
        AND tbba001g.dd_uritrkkj IS NULL
        AND tbba001g.dd_torikesi IS NULL
        AND tbba001g.dd_jucyuke IS NOT NULL
    LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M
        ON tbba001g.cd_hansya = TBBF008M.cd_hansya
        AND tbba001g.cd_kaisya = TBBF008M.cd_kaisya
        AND tbba001g.mj_sinkysed = TBBF008M.mj_sinkysed
        AND tbba001g.mj_gaihansy  = TBBF008M.cd_spec
        AND tbba001g.mj_hantenkt  = TBBF008M.mj_hantenkt
        AND TBBF008M.kb_spec = 'G'
    LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m
        ON tbbf001m.cd_kaisya = TBBF008M.cd_kaisya
        AND tbbf001m.cd_hansya = TBBF008M.cd_hansya
        AND tbbf001m.cd_ncsyamei = TBBF008M.mj_syamei
    LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m
        ON tbbf001m.cd_hansya = tbi999008m.cd_hansya
        AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
        AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
        AND tbi999008m.kb_tenji = 1
    LEFT JOIN ai21rep_ve_dx.tbbf007m tbbf007m
        ON tbbf007m.cd_hansya = TBBF008M.cd_hansya
        AND tbbf007m.cd_kaisya = TBBF008M.cd_kaisya
        AND tbbf007m.mj_syamei = TBBF008M.mj_syamei
        AND tbbf007m.kb_spec = TBBF008M.kb_spec
        AND tbbf007m.cd_spec = TBBF008M.cd_spec
        AND tbbf007m.no_hinmei = TBBF008M.no_hinmei
    LEFT JOIN ai21rep_ve_dx.tbv0047m  tbv0047m
        ON tbv0047m.cd_hansya = t201m.cd_hansya
        AND tbv0047m.cd_kaisya = t201m.cd_kaisya
        AND tbv0047m.cd_tenpo = t201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv0033m
        ON tbv0033m.cd_hansya = t201m.cd_hansya
        AND tbv0033m.cd_kaisya = t201m.cd_kaisya
        AND tbv0033m.cd_zon = tbv0047m.cd_nczon
        AND tbv0033m.kb_syohin  = '1'
    LEFT JOIN ai21rep_ve_dx.tbv0229m tbv0229m
        ON tbv0229m.cd_hansya = tbba001g.cd_hansya
        AND tbv0229m.cd_kaisya = tbba001g.cd_kaisya
        AND tbv0229m.no_siteruib = tbba001g.no_siteruib
    LEFT JOIN   (SELECT     kj_tentanms,
        ON t201m_2.cd_hansya,
                     t201m_2.cd_kaisya,
                     MIN(t201m_2.cd_tenpo) AS cd_tenpo,
                     MIN(tbi999003m.mj_sortjyun) AS mj_sortjyun
         FROM ai21rep_ve_dx.tbv0201m t201m_2
         INNER JOIN dx_ve.tbi999003m tbi999003m
             ON t201m_2.cd_hansya = tbi999003m.cd_hansya
             AND t201m_2.cd_kaisya = tbi999003m.cd_kaisya
             AND t201m_2.cd_tenpo = tbi999003m.cd_tenpo
             AND tbi999003m.mj_cyohyoid = '016'
             AND tbi999003m.kb_tenji = 1
        GROUP BY
            t201m_2.cd_hansya,
            t201m_2.cd_kaisya,
            kj_tentanms
        ) sort_sub
    ON t201m.cd_hansya = sort_sub.cd_hansya
    AND t201m.cd_kaisya = sort_sub.cd_kaisya
    AND t201m.kj_tentanms = sort_sub.kj_tentanms
    LEFT JOIN (SELECT
        ON tbi999008m.cd_hansya,
                 tbi999008m.cd_kaisya,
                 TRIM(tbi999008m.kj_kurumame) AS kj_kurumame,
                 MIN(tbi999008m.mj_sortjyun) AS mj_sortjyun,
                 MIN(tbi999008m.cd_ncsyamei) AS cd_ncsyamei
         FROM dx_ve.tbi999008m tbi999008m
        WHERE tbi999008m.kb_tenji = 1
        GROUP BY
            tbi999008m.cd_hansya,
            tbi999008m.cd_kaisya,
            TRIM(tbi999008m.kj_kurumame)
        ) sort_car
    ON tbbf001m.cd_hansya = sort_car.cd_hansya
    AND tbbf001m.cd_kaisya = sort_car.cd_kaisya
    AND TRIM(tbbf001m.kj_kurumame) = TRIM(sort_car.kj_kurumame)
    WHERE NOT (t201m.kj_tenpomei LIKE '%廃）%' AND tbba001g.cd_hansya IS NULL)
    GROUP BY
        `販社コード`,
        `会社コード`,
        `店舗コード`,
        `ソート順`,
        `品名カナ`,
        `新車車名`,
        `受注計上日`,
        `店舗短縮名称`,
        `ゾーンコード`,
        `ゾーン名称`,
        `グレード`
) t
;
