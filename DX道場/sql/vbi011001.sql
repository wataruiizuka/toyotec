DROP TABLE IF EXISTS gold.vbi011001;
CREATE TABLE gold.vbi011001 AS
SELECT
    t0021m.cd_hansya
    , t0021m.cd_kaisya
    , t0021m.kb_keiyaku
    , t0021m.no_edaban
    , t0021m.nu_sotezert
    , t0021m.no_renban
    , t0021m.kj_riyoseim
    , t0020m.kj_kanyusyu
    , t0021m.ki_goukei + t0021m.ki_syohizei AS `totalcount`
FROM
    ai21rep_ve_dx.tbv0021m t0021m
LEFT JOIN
    ON ai21rep_ve_dx.tbv0020m t0020m
    ON
    t0021m.cd_hansya = t0020m.cd_hansya
    AND t0021m.cd_kaisya = t0020m.cd_kaisya
    AND t0021m.kb_keiyaku = t0020m.kb_keiyaku
    AND t0021m.no_edaban = t0020m.no_edaban
    AND t0021m.nu_sotezert = t0020m.nu_sotezert
;
