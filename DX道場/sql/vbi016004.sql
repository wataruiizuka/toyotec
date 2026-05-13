DROP TABLE IF EXISTS gold.vbi016004;
CREATE TABLE gold.vbi016004 AS
SELECT
    `販社コード`
    , `会社コード`
    , `新車車名`
    , `法人個人区分`
    , `法人個人区分ソート順`
    , `年齢別`
    , `商談動機`
    , `業直区分`
    , `支払区分`
    , CONCAT(`新車車名`,from_timestamp(`受注計上日`, 'yyyyMMdd')) AS `車名受注日`
    , COUNT(1) AS `台数`
    , SUM(`受注台数`) AS `受注台数`
FROM
(
SELECT
    tbba001g.cd_hansya AS `販社コード`
    , tbba001g.cd_kaisya AS `会社コード`
    , CASE WHEN tbba051g.kb_seibetu ='1' THEN '男' WHEN tbba051g.kb_seibetu ='2' THEN '女' WHEN tbba051g.kb_seibetu = '3' THEN '法人' ELSE NULL END AS `法人個人区分`
    , CASE WHEN tbba051g.kb_seibetu ='1' THEN 1 WHEN tbba051g.kb_seibetu ='2' THEN 2 WHEN tbba051g.kb_seibetu = '3' THEN 3 ELSE 4 END AS `法人個人区分ソート順`
    , CASE WHEN tbba051g.nu_nenrei >=60 THEN '60歳以上'
        WHEN tbba051g.nu_nenrei >=50 THEN '50歳代'
        WHEN tbba051g.nu_nenrei >=40 THEN '40歳代'
        WHEN tbba051g.nu_nenrei >=30 THEN '30歳代'
        ELSE '29歳以下'
    END AS `年齢別`
    , tbbf001m.kj_kurumame AS `新車車名`
    , tbba001g.dd_jucyuke AS `受注計上日`
    , NVL(tbbg068m.答名,'') AS `商談動機`
    , IF(tbba056g.kb_gyocyok = '1','直','業') AS `業直区分`
    , REPLACE(TRIM(tbv0231m.mj_kubunnai),'　','') AS `支払区分`
    , tbba001g.su_juchudai AS `受注台数`
FROM
    ai21rep_ve_dx.tbba001g tbba001g
LEFT SEMI JOIN dx_ve.tbi999003m tbi999003m
    ON tbba001g.cd_hansya = tbi999003m.cd_hansya
    AND tbba001g.cd_kaisya = tbi999003m.cd_kaisya
    AND tbba001g.cd_tenpo = tbi999003m.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '016'
    AND tbi999003m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M
    ON tbba001g.cd_kaisya = TBBF008M.cd_kaisya
    AND tbba001g.cd_hansya = TBBF008M.cd_hansya
    AND tbba001g.mj_sinkysed = TBBF008M.mj_sinkysed
    AND tbba001g.mj_gaihansy  = TBBF008M.cd_spec
    AND tbba001g.mj_hantenkt  = TBBF008M.mj_hantenkt
    AND TBBF008M.kb_spec = 'G'
LEFT  JOIN ai21rep_ve_dx.tbbf001m tbbf001m
    ON tbbf001m.cd_kaisya = TBBF008M.cd_kaisya
    AND tbbf001m.cd_hansya = TBBF008M.cd_hansya
    AND tbbf001m.cd_ncsyamei = TBBF008M.mj_syamei
LEFT SEMI JOIN dx_ve.tbi999008m tbi999008m
    ON tbbf001m.cd_hansya = tbi999008m.cd_hansya
    AND tbbf001m.cd_kaisya = tbi999008m.cd_kaisya
    AND tbbf001m.cd_ncsyamei = tbi999008m.cd_ncsyamei
    AND tbi999008m.kb_tenji = 1
LEFT JOIN ai21rep_ve_dx.tbba056g tbba056g
    ON tbba056g.cd_hansya = tbba001g.cd_hansya
    AND tbba056g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba056g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba056g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
LEFT JOIN ai21rep_ve_dx.tbba051g tbba051g
    ON tbba051g.cd_hansya = tbba001g.cd_hansya
    AND tbba051g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba051g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba051g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
    AND tbba051g.kb_kokyaku = '2'
LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g
    ON tbba052g.cd_hansya = tbba001g.cd_hansya
    AND tbba052g.cd_kaisya = tbba001g.cd_kaisya
    AND tbba052g.no_cyumon = tbba001g.no_cyumon
    AND TRIM(tbba052g.no_cyumoned) = TRIM(tbba001g.no_cyumoned)
LEFT JOIN ai21rep_ve_dx.tbv0231m tbv0231m
    ON tbv0231m.cd_hansya = tbba001g.cd_hansya
    AND tbv0231m.cd_kaisya = tbba001g.cd_kaisya
    AND tbv0231m.mj_blockid  = '02'
    AND tbv0231m.mj_kubunid = '0018'
    AND TRIM(tbv0231m.cd_kubun) = tbba052g.kb_siharai
LEFT JOIN(
    SELECT cd_hansya, cd_kaisya, '01' AS searchKey, cd_kotaem1 AS `答名`  FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '02' AS searchKey, cd_kotaem2 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '03' AS searchKey, cd_kotaem3 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '04' AS searchKey, cd_kotaem4 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '05' AS searchKey, cd_kotaem5 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '06' AS searchKey, cd_kotaem6 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '07' AS searchKey, cd_kotaem7 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '08' AS searchKey, cd_kotaem8 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '09' AS searchKey, cd_kotaem9 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '10' AS searchKey, cd_kotaem10 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '11' AS searchKey, cd_kotaem11 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '12' AS searchKey, cd_kotaem12 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '13' AS searchKey, cd_kotaem13 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '14' AS searchKey, cd_kotaem14 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '15' AS searchKey, cd_kotaem15 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '16' AS searchKey, cd_kotaem16 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '17' AS searchKey, cd_kotaem17 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '18' AS searchKey, cd_kotaem18 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '19' AS searchKey, cd_kotaem19 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
    UNION ALL
    SELECT cd_hansya, cd_kaisya, '20' AS searchKey, cd_kotaem20 AS `答名` FROM ai21rep_ve_dx.tbbg068m WHERE cd_mondai ='101' AND kn_sincyu  = '1'
 ) tbbg068m
     ON tbba056g.mj_jucyuke1=tbbg068m.searchKey
     AND tbba001g.cd_hansya = tbbg068m.cd_hansya
    AND tbba001g.cd_kaisya = tbbg068m.cd_kaisya
WHERE tbba001g.dd_uritrkkj IS NULL
    AND tbba001g.dd_torikesi IS NULL
    AND tbba001g.dd_jucyuke IS NOT NULL
     ) t
GROUP BY
    `販社コード`,
    `会社コード`,
    `新車車名`,
    `車名受注日`,
    `法人個人区分`,
    `法人個人区分ソート順`,
    `年齢別`,
    `商談動機`,
    `業直区分`,
    `支払区分`
;
