DROP TABLE IF EXISTS gold.vbi016002;
CREATE TABLE gold.vbi016002 AS
SELECT
    tbbf008m.cd_hansya AS `販社コード`
    , tbbf008m.cd_kaisya AS `会社コード`
    , tbbf007m.kn_hinmei AS `品名カナ`
    , CONCAT(tbbf001m.kj_kurumame, FROM_TIMESTAMP(tbba001g.dd_jucyuke, 'yyyyMMdd')) AS `車名受注日`
    , tbbf001m.kj_kurumame AS `新車車名`
    , tbv0229m.mj_guredo AS `グレード`
    , SUM(IF(tbba001g.cd_hansya IS NOT NULL AND tbi999003m.cd_hansya IS NOT NULL
               AND tbba001g.dd_uritrkkj IS NULL AND tbba001g.dd_torikesi IS NULL AND tbba001g.dd_jucyuke IS NOT NULL, 1, 0)) AS `台数`
FROM
    ai21rep_ve_dx.tbbf008m tbbf008m
INNER JOIN ai21rep_ve_dx.tbbf001m tbbf001m
    ON
    tbbf001m.cd_kaisya = tbbf008m.cd_kaisya
    AND tbbf001m.cd_hansya = tbbf008m.cd_hansya
    AND tbbf001m.cd_ncsyamei = tbbf008m.mj_syamei
    AND tbbf008m.kb_spec = 'G'
LEFT JOIN ai21rep_ve_dx.tbbf007m tbbf007m
    ON
    tbbf007m.cd_hansya = tbbf008m.cd_hansya
    AND tbbf007m.cd_kaisya = tbbf008m.cd_kaisya
    AND tbbf007m.mj_syamei = tbbf008m.mj_syamei
    AND tbbf007m.kb_spec = tbbf008m.kb_spec
    AND tbbf007m.cd_spec = tbbf008m.cd_spec
    AND tbbf007m.no_hinmei = tbbf008m.no_hinmei
LEFT JOIN ai21rep_ve_dx.tbba001g tbba001g
    ON
    tbba001g.cd_kaisya = tbbf008m.cd_kaisya
    AND tbba001g.cd_hansya = tbbf008m.cd_hansya
    AND tbba001g.mj_sinkysed = tbbf008m.mj_sinkysed
    AND tbba001g.mj_gaihansy = tbbf008m.cd_spec
    AND tbba001g.mj_hantenkt = tbbf008m.mj_hantenkt
LEFT JOIN ai21rep_ve_dx.tbv0229m tbv0229m
    ON
    tbv0229m.cd_hansya = tbba001g.cd_hansya
    AND tbv0229m.cd_kaisya = tbba001g.cd_kaisya
    AND tbv0229m.no_siteruib = tbba001g.no_siteruib
LEFT JOIN dx_ve.tbi999003m tbi999003m
    ON
    tbba001g.cd_hansya = tbi999003m.cd_hansya
    AND tbba001g.cd_kaisya = tbi999003m.cd_kaisya
    AND tbba001g.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '016'
    AND tbi999003m.kb_tenji = 1
LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m
    ON
    tbbf001m.cd_hansya = tbi999008m.cd_hansya
    AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
    AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
    AND tbi999008m.kb_tenji = 1
GROUP BY
    `販社コード`,
    `会社コード`,
    `品名カナ`,
    `車名受注日`,
    `新車車名`,
    `グレード`
;
