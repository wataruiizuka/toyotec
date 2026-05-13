DROP TABLE IF EXISTS gold.vbi016001;
CREATE TABLE gold.vbi016001 AS
SELECT
    `販社コード`
    , `会社コード`
    , `新車車名`
    , `受注計上日`
    , CASE
        WHEN FROM_TIMESTAMP(ADD_MONTHS(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), -1), 'yyyyMM') = FROM_TIMESTAMP(`受注計上日`, 'yyyyMM')
        THEN '前月'
        WHEN FROM_TIMESTAMP(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'yyyyMM') = FROM_TIMESTAMP(`受注計上日`, 'yyyyMM')
        THEN '当月'
        ELSE
        ' '
    END AS `月別`
    , CONCAT(`新車車名`, FROM_TIMESTAMP(`受注計上日`, 'yyyyMMdd')) AS `車名受注日`
    , DENSE_RANK() OVER (PARTITION BY `販社コード`, `会社コード` ORDER BY `ソート順`, `新車車名コード` ) AS `ソート順`
    , `台数`
FROM
    (
    SELECT
        tbba001g.cd_hansya AS `販社コード`
        , tbba001g.cd_kaisya AS `会社コード`
        , CAST(tbba001g.dd_jucyuke AS DATE) AS `受注計上日`
        , tbbf001m.kj_kurumame AS `新車車名`
        , MIN(sort_car.mj_sortjyun) AS `ソート順`
        , MIN(sort_car.cd_ncsyamei) AS `新車車名コード`
        , COUNT(1) AS `台数`
    FROM
        ai21rep_ve_dx.tbba001g tbba001g
    LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m
        ON
        tbba001g.cd_hansya = tbi999003m.cd_hansya
        AND tbba001g.cd_kaisya = tbi999003m.cd_kaisya
        AND tbba001g.cd_tenpo = tbi999003m.cd_tenpo
        AND tbi999003m.mj_cyohyoid = '016'
        AND tbi999003m.kb_tenji = 1
    LEFT JOIN ai21rep_ve_dx.tbbf008m tbbf008m
        ON
        tbba001g.cd_hansya = tbbf008m.cd_hansya
        AND tbba001g.cd_kaisya = tbbf008m.cd_kaisya
        AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
        AND tbba001g.mj_gaihansy = tbbf008m.cd_spec
        AND tbba001g.mj_hantenkt = tbbf008m.mj_hantenkt
        AND tbbf008m.kb_spec = 'G'
    LEFT JOIN ai21rep_ve_dx.tbbf001m tbbf001m
        ON
        tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
        AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
        AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
    INNER JOIN dx_ve.tbi999008m tbi999008m
        ON
        tbbf001m.cd_hansya = tbi999008m.cd_hansya
        AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
        AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
        AND tbi999008m.kb_tenji = 1
    LEFT JOIN (
        SELECT
                 tbi999008m.cd_hansya
                 , tbi999008m.cd_kaisya
                 , TRIM(tbi999008m.kj_kurumame) AS kj_kurumame
                 , MIN(tbi999008m.mj_sortjyun) AS mj_sortjyun
                 , MIN(tbi999008m.cd_ncsyamei) AS cd_ncsyamei
        FROM
            dx_ve.tbi999008m tbi999008m
        WHERE
            tbi999008m.kb_tenji = 1
        GROUP BY
            tbi999008m.cd_hansya,
            tbi999008m.cd_kaisya,
            TRIM(tbi999008m.kj_kurumame)
        ) sort_car
    ON
        tbbf001m.cd_hansya = sort_car.cd_hansya
        AND tbbf001m.cd_kaisya = sort_car.cd_kaisya
        AND TRIM(tbbf001m.kj_kurumame) = TRIM(sort_car.kj_kurumame)
    WHERE
        tbba001g.dd_uritrkkj IS NULL
        AND tbba001g.dd_torikesi IS NULL
        AND tbba001g.dd_jucyuke IS NOT NULL
    GROUP BY
        tbba001g.cd_hansya,
        tbba001g.cd_kaisya,
        CAST(tbba001g.dd_jucyuke AS DATE) AS `受注計上日`,
        `新車車名`
) t
UNION ALL
SELECT
    '固定' AS `販社コード`
    , '' AS `会社コード`
    , '合計' AS `新車車名`
    , NULL AS `受注計上日`
    , NULL AS `月別`
    , NULL AS `車名受注日`
    , -1 AS `ソート順`
    , 0 AS `台数`
;