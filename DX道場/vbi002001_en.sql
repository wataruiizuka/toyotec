DROP TABLE IF EXISTS gold.vbi002001_en;
CREATE TABLE gold.vbi002001_en AS
SELECT
    main_table.su_store_number
    , main_table.cd_hansya_kaisya_tenpo
    , main_table.cd_hansya_kaisya_zon_tenpo
    , main_table.cd_hansya
    , main_table.cd_kaisya
    , main_table.cd_tenpo
    , main_table.kj_tenpomei
    , main_table.kj_tentanms
    , IF(main_table.zone_name_abbreviation IS NULL OR regexp_replace(main_table.zone_name_abbreviation, '[ 　]+', '') = '','999999',IF(main_table.cd_zon IS NULL OR regexp_replace(main_table.cd_zon, '[ 　]+', '') = '','999998',main_table.cd_zon)) AS cd_zon
    , main_table.cd_nczon
    , main_table.kj_zonmei
    , main_table.zone_name_abbreviation
    , main_table.sort_order
FROM(
    SELECT
        1 AS su_store_number
        , CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya, tbv201m.cd_tenpo) AS cd_hansya_kaisya_tenpo
        , IF(tntenpo.cd_zon IS NOT NULL,CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya,tntenpo.cd_zon, tbv201m.cd_tenpo),CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya,tbv003m.cd_zon, tbv201m.cd_tenpo)) AS cd_hansya_kaisya_zon_tenpo
        , tbv201m.cd_hansya
        , tbv201m.cd_kaisya
        , tbv201m.cd_tenpo
        , tbv201m.kj_tenpomei
        , tbv201m.kj_tentanms
        , NVL(tntenpo.cd_zon,tbv003m.cd_zon) AS cd_zon
        , NVL(tntenpo.cd_zon,tbv0047m.cd_nczon) AS cd_nczon
        , NVL(tbv003m1.kj_zonmei,tbv003m.kj_zonmei) AS kj_zonmei
        , CASE
            WHEN tbv003m1.kj_zonmei IS NOT NULL AND (LEFT(CAST (tbv003m1.kj_zonmei AS STRING), 3) = 'ト' OR LEFT (CAST (tbv003m1.kj_zonmei AS STRING), 3) = 'レ') AND RIGHT (CAST (tbv003m1.kj_zonmei AS STRING), 6) = 'エ統'
            THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTR(CAST (tbv003m1.kj_zonmei AS STRING), 1, 9), 'レ', 'L-'), 'ト', 'T-'), '０', '0'), '１', '1'), '２', '2'), '３', '3'), '４', '4'), '５', '5'), '６', '6'), '７', '7'), '８', '8'), '９', '9')
            WHEN tbv003m1.kj_zonmei IS NOT NULL
            THEN TRIM(REPLACE(CAST(tbv003m1.kj_zonmei AS STRING), '　', ' '))
            WHEN (LEFT(CAST (tbv003m.kj_zonmei AS STRING), 3) = 'ト' OR LEFT (CAST (tbv003m.kj_zonmei AS STRING), 3) = 'レ') AND RIGHT (CAST (tbv003m.kj_zonmei AS STRING), 6) = 'エ統'
            THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(SUBSTR(CAST (tbv003m.kj_zonmei AS STRING), 1, 9), 'レ', 'L-'), 'ト', 'T-'), '０', '0'), '１', '1'), '２', '2'), '３', '3'), '４', '4'), '５', '5'), '６', '6'), '７', '7'), '８', '8'), '９', '9')
            ELSE TRIM(REPLACE(CAST(tbv003m.kj_zonmei AS STRING), '　', ' '))
        END AS zone_name_abbreviation
        , RANK() OVER (PARTITION BY tbv201m.cd_hansya,tbv201m.cd_kaisya ORDER BY NVL(tntenpo.cd_zon,tbv003m.cd_zon), tbi999003m.mj_sortjyun, tbv201m.cd_tenpo) AS sort_order
    FROM
        ai21rep_ve_dx.tbv0201m tbv201m
    LEFT JOIN dx_ve.tbi999003m tbi999003m
        ON tbv201m.cd_hansya = tbi999003m.cd_hansya
        AND tbv201m.cd_kaisya = tbi999003m.cd_kaisya
        AND tbv201m.cd_tenpo = tbi999003m.cd_tenpo
        AND tbi999003m.mj_cyohyoid = "002"
    LEFT JOIN ai21rep_ve_dx.tbv0047m tbv0047m
        ON tbv0047m.cd_hansya = '03601'
        AND tbv0047m.cd_kaisya = '01'
        AND tbv0047m.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m
        ON tbv003m.cd_hansya = '03601'
        AND tbv003m.cd_kaisya = '01'
        AND tbv003m.cd_zon = tbv0047m.cd_nczon
        AND tbv003m.kb_syohin = '1'
    LEFT JOIN dx_ve.tbi002003m tntenpo
        ON tntenpo.cd_hansya = '03601'
        AND tntenpo.cd_kaisya = '01'
        AND tntenpo.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m1
        ON tbv003m1.cd_hansya = '03601'
        AND tbv003m1.cd_kaisya = '01'
        AND tntenpo.cd_zon = tbv003m1.cd_zon
    WHERE
        tbi999003m.kb_tenji = 1
        AND tbv201m.kj_tenpomei NOT LIKE '%廃）%'
        AND tbv201m.cd_hansya = '03601'
        AND tbv201m.cd_kaisya = '01'
        AND (tbv003m.cd_zon IN ('01','02','03','04','05','06','07','08','09','10','11','12','13','14','15','30','31','32','33','60','90')
        OR SUBSTRING(tbv003m.cd_zon, 1, 3) = 'TK_')
        AND tbv201m.cd_tenpo NOT IN ( 'T01','T02','T03','T04','T05','T06','T07','T08','T09','T10','T11','T12','T13','T14','T15','L01','L02','L03','L04')
    UNION ALL
    SELECT
        1 AS su_store_number
        , CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya, tbv201m.cd_tenpo) AS cd_hansya_kaisya_tenpo
        , IF(tntenpo.cd_zon IS NOT NULL,CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya,tntenpo.cd_zon, tbv201m.cd_tenpo),CONCAT(tbv201m.cd_hansya, tbv201m.cd_kaisya,tbv003m.cd_zon, tbv201m.cd_tenpo)) AS cd_hansya_kaisya_zon_tenpo
        , tbv201m.cd_hansya
        , tbv201m.cd_kaisya
        , tbv201m.cd_tenpo
        , tbv201m.kj_tenpomei
        , tbv201m.kj_tentanms
        , NVL(tntenpo.cd_zon,tbv003m.cd_zon) AS cd_zon
        , NVL(tntenpo.cd_zon,tbv0047m.cd_nczon) AS cd_nczon
        , NVL(tbv003m1.kj_zonmei,tbv003m.kj_zonmei) AS kj_zonmei
        , NVL(tbv003m1.kj_zonmei,tbv003m.kj_zonmei) AS zone_name_abbreviation
        , RANK() OVER (PARTITION BY tbv201m.cd_hansya,tbv201m.cd_kaisya ORDER BY NVL(tntenpo.cd_zon,tbv003m.cd_zon), tbi999003m.mj_sortjyun, tbv201m.cd_tenpo) AS sort_order
    FROM
        ai21rep_ve_dx.tbv0201m tbv201m
    LEFT JOIN dx_ve.tbi999003m tbi999003m
        ON tbv201m.cd_hansya = tbi999003m.cd_hansya
        AND tbv201m.cd_kaisya = tbi999003m.cd_kaisya
        AND tbv201m.cd_tenpo = tbi999003m.cd_tenpo
        AND tbi999003m.mj_cyohyoid = "002"
    LEFT JOIN ai21rep_ve_dx.tbv0047m tbv0047m
        ON tbv0047m.cd_hansya = tbv201m.cd_hansya
        AND tbv0047m.cd_tenpo = tbv201m.cd_kaisya
        AND tbv0047m.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m
        ON tbv003m.cd_hansya = tbv0047m.cd_hansya
        AND tbv003m.cd_kaisya = tbv0047m.cd_tenpo
        AND tbv003m.cd_zon = tbv0047m.cd_nczon
        AND tbv003m.kb_syohin = '1'
    LEFT JOIN dx_ve.tbi002003m tntenpo
        ON tntenpo.cd_hansya = tbv201m.cd_hansya
        AND tntenpo.cd_kaisya = tbv201m.cd_kaisya
        AND tntenpo.cd_tenpo = tbv201m.cd_tenpo
    LEFT JOIN ai21rep_ve_dx.tbv0033m tbv003m1
        ON tntenpo.cd_hansya = tbv003m1.cd_hansya
        AND tntenpo.cd_kaisya = tbv003m1.cd_kaisya
        AND tntenpo.cd_tenpo = tbv003m1.cd_zon
    WHERE
        tbi999003m.kb_tenji = 1
        AND tbv201m.cd_hansya <> '03601'
        AND tbv201m.kj_tenpomei NOT LIKE '%廃）%'
) main_table
;
