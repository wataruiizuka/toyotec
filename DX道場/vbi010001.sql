DROP TABLE IF EXISTS gold.vbi010001;
CREATE TABLE gold.vbi010001 AS
SELECT
    t201m.cd_hansya AS 販社コード
    , t201m.cd_kaisya AS 会社コード
    , t201m.cd_tenpo AS 店舗コード
    , t201m.kj_tenpomei AS 店舗名称
    , t201m.kj_tentanms AS 店舗短縮名称
    , RANK() OVER (PARTITION BY t201m.cd_hansya,t201m.cd_kaisya ORDER BY IF(NVL(t033m.kj_zonmei,t033m_2.kj_zonmei) = '', 0,1), NVL(t033m.kj_zonmei,t033m_2.kj_zonmei) ,  t201m.cd_tenpo) as ソート順
    , CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗
    , '' AS ゾーン名称
    , t033m.kb_syohin AS 商品区分
    , CASE
        WHEN tbv0200m.KJ_KAISYA LIKE '%トヨペット%' THEN 'P'
        WHEN tbv0200m.KJ_KAISYA LIKE '%ネッツトヨタ%' THEN 'N'
        ELSE NULL
    END AS pn区分
    , CASE
        WHEN NVL(TRIM(t201m.cd_lexhan), '') = '' THEN 'ﾄﾖﾀ'
        ELSE 'ﾚｸｻｽ'
    END AS tl区分
    , CASE
        WHEN t201m.kb_ncbumumu = '1' AND t201m.kb_ucbumumu = '1' THEN '11'
        WHEN t201m.kb_ncbumumu = '1' AND NVL(t201m.kb_ucbumumu, '')<> '1' THEN '10'
        WHEN NVL(t201m.kb_ncbumumu, '')<> '1' AND t201m.kb_ucbumumu = '1' THEN '01'
        ELSE '00'
    END 新U区分
    , CASE
        WHEN (t047m.kb_nchonsya = '2' or t047m.kb_uchonsya = '2') AND (t047m.kb_nchonsya = '1' OR t047m.kb_uchonsya = '1') THEN '11'
        WHEN (t047m.kb_nchonsya = '2' or t047m.kb_uchonsya = '2') AND (NVL(t047m.kb_nchonsya, '')<> '1' AND NVL(t047m.kb_uchonsya, '')<> '1') THEN '10'
        WHEN (t047m.kb_nchonsya = '1' or t047m.kb_uchonsya = '1') AND (NVL(t047m.kb_nchonsya, '')<> '2' AND NVL(t047m.kb_uchonsya, '')<> '2') THEN '01'
        ELSE '00'
    END 本部店舗区分
FROM
    ai21rep_ve_dx.tbv0201m t201m
LEFT JOIN ai21rep_ve_dx.tbv0047m t047m
    ON t047m.cd_hansya = t201m.cd_hansya
    AND t047m.cd_kaisya = t201m.cd_kaisya
    AND t047m.cd_tenpo = t201m.cd_tenpo
LEFT JOIN ai21rep_ve_dx.tbv0033m t033m
    ON t033m.cd_hansya = t201m.cd_hansya
    AND t033m.cd_kaisya = t201m.cd_kaisya
    AND t033m.cd_zon = t047m.cd_nczon
    AND t033m.kb_syohin = '1'
LEFT JOIN ai21rep_ve_dx.tbv0033m t033m_2
    ON t033m_2.cd_hansya = t201m.cd_hansya
    AND t033m_2.cd_kaisya = t201m.cd_kaisya
    AND t033m_2.cd_zon = t047m.cd_uczon
    AND t033m_2.kb_syohin = '2'
LEFT JOIN ai21rep_ve_dx.tbv0200m tbv0200m
    ON t201m.cd_hansya = tbv0200m.cd_hansya
    AND t201m.cd_kaisya = tbv0200m.cd_kaisya
;
