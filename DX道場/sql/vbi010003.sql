DROP TABLE IF EXISTS gold.vbi010003;
CREATE TABLE gold.vbi010003 AS
SELECT
    t201m.cd_hansya AS 販社コード
    , t201m.cd_kaisya AS 会社コード
    , t201m.cd_tenpo AS 店舗コード
    , CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗
    , NVL(newcar.新車下取数, 0) AS 新車下取数
    , NVL(newcar.入会数, 0) AS 新車入会数
    , NVL(newcar.直販数, 0) AS 新車直販数
    , NVL(newcar.直販下取数, 0) AS 直販下取数
    , NVL(newcar.新車軽OEM数, 0) AS 新車軽OEM数
    , NVL(newcar.新車登録車数, 0) AS 新車登録車数
FROM
    ai21rep_ve_dx.tbv0201m t201m
LEFT JOIN
    ON (
    SELECT
        cd_hansya
        , cd_kaisya
        , cd_tenpo
        , CONCAT(cd_hansya, cd_kaisya, cd_tenpo) AS 販社会社店舗コード
        , SUM(新車数) AS 新車数
        , SUM(新車下取数) AS 新車下取数
        , SUM(入会数) AS 入会数
        , SUM(直販数) AS 直販数
        , SUM(直販下取数) AS 直販下取数
        , SUM(CASE WHEN 軽区分 = '1' THEN 新車数 ELSE 0 END) AS 新車軽OEM数
        , SUM(CASE WHEN NVL(軽区分,'') != '1' THEN 新車数 ELSE 0 END) AS 新車登録車数
    FROM
        (
        SELECT
            tbba001g.cd_hansya
            , tbba001g.cd_kaisya
            , tbba001g.cd_tenpo
            , SUM(calflg) AS 新車数
            , SUM( CASE WHEN tbba003g_1.新車下取数 > 0 THEN calflg ELSE 0 END) AS 新車下取数
            , TBBF001M.kn_kei AS 軽区分
            , SUM( CASE WHEN NVL(REPLACE(REPLACE(tbba052g.kb_mntpkkei, '　', ''), ' ', ''),'') <>'' THEN calflg ELSE 0 END) AS 入会数
            , SUM( CASE WHEN TBBA056G.kb_gyocyok = '1' THEN calflg ELSE 0 END) AS 直販数
            , SUM( CASE WHEN TBBA056G.kb_gyocyok = '1' AND tbba003g_1.新車下取数 > 0 THEN calflg ELSE 0 END)  AS 直販下取数
        FROM
            (
            SELECT
                tbba001g.cd_hansya
                , tbba001g.cd_kaisya
                , tbba001g.cd_tenpo
                , tbba001g.no_cyumon
                , tbba001g.no_cyumoned
                , tbba001g.mj_sinkysed
                , tbba001g.mj_gaihansy
                , tbba001g.mj_hantenkt
                , (CASE
                    WHEN ft168g.dd_torokei IS NULL THEN tbba001g.dd_uriagekj
                    ELSE ft168g.dd_torokei
                END) AS 日付,
                1 AS calflg
            FROM
                ai21rep_ve_dx.tbba001g tbba001g
            LEFT JOIN(
                SELECT
                    t168g.cd_hansya
                    , t168g.cd_kaisya
                    , t168g.no_cyumon
                    , min(t168g.dd_torokei) AS dd_torokei
                FROM ai21rep_ve_dx.tbbg168g t168g
                WHERE
                    t168g.no_gyomu = '07'
                  AND t168g.no_syori = '01'
                GROUP BY t168g.cd_hansya, t168g.cd_kaisya, t168g.no_cyumon
            ) ft168g ON
                ft168g.cd_kaisya = tbba001g.cd_kaisya
                AND ft168g.cd_hansya = tbba001g.cd_hansya
                AND ft168g.no_cyumon = tbba001g.no_cyumon
            WHERE
                tbba001g.kb_haraidas NOT IN ('00', '40')
                    AND tbba001g.dd_jucyuke IS NOT NULL
                    AND ( (ft168g.dd_torokei IS NULL AND tbba001g.dd_uriagekj >= trunc(add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
                        OR  (ft168g.dd_torokei IS NOT NULL
                        AND ft168g.dd_torokei >= trunc(add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM'))
                      )
            UNION ALL
                SELECT
                    tbba001g.cd_hansya
                    , tbba001g.cd_kaisya,
                    , tbba001g.cd_tenpo
                    , tbba001g.no_cyumon
                    , tbba001g.no_cyumoned
                    , tbba001g.mj_sinkysed
                    , tbba001g.mj_gaihansy
                    , tbba001g.mj_hantenkt
                    , tbba001g.dd_uritrkkj AS 日付
                    , -1 AS calflg
                FROM
                    ai21rep_ve_dx.tbba001g tbba001g
                WHERE
                    tbba001g.kb_haraidas NOT IN ('00', '40')
                    AND tbba001g.dd_jucyuke IS NOT NULL
                    AND tbba001g.dd_uritrkkj >= trunc(add_months(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 0), 'MM')
        ) tbba001g
        LEFT JOIN ai21rep_ve_dx.tbbf008m TBBF008M
            ON tbba001g.cd_kaisya = TBBF008M.cd_kaisya
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
            LEFT JOIN (
                SELECT
                    tbba003g.cd_hansya
                    , tbba003g.cd_kaisya
                    , tbba003g.no_cyumon
                    , tbba003g.no_cyumoned
                    , COUNT(1) AS 新車下取数
                FROM
                    ai21rep_ve_dx.tbba003g tbba003g
                WHERE
                    tbba003g.kb_sincyu = '1'
                GROUP BY
                    tbba003g.cd_hansya,
                    tbba003g.cd_kaisya,
                    tbba003g.no_cyumon,
                    tbba003g.no_cyumoned
            ) tbba003g_1
                ON tbba001g.cd_hansya = tbba003g_1.cd_hansya
                AND tbba001g.cd_kaisya = tbba003g_1.cd_kaisya
                AND tbba001g.no_cyumon = tbba003g_1.no_cyumon
                AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba003g_1.no_cyumoned)
            LEFT JOIN ai21rep_ve_dx.tbba052g tbba052g
                ON tbba001g.cd_hansya = tbba052g.cd_hansya
                AND tbba001g.cd_kaisya = tbba052g.cd_kaisya
                AND tbba001g.no_cyumon = tbba052g.no_cyumon
                AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba052g.no_cyumoned)
            LEFT JOIN ai21rep_ve_dx.tbba056g tbba056g
                ON tbba001g.cd_hansya = tbba056g.cd_hansya
                AND tbba001g.cd_kaisya = tbba056g.cd_kaisya
                AND tbba001g.no_cyumon = tbba056g.no_cyumon
                AND TRIM(tbba001g.no_cyumoned) = TRIM(tbba056g.no_cyumoned)
                GROUP BY
                    tbba001g.cd_hansya,
                    tbba001g.cd_kaisya,
                    tbba001g.cd_tenpo,
                    TBBF001M.kn_kei
            ) combined
                GROUP BY
                    cd_hansya,
                    cd_kaisya,
                    cd_tenpo,
                    販社会社店舗コード
) newcar
        ON t201m.cd_hansya = newcar.cd_hansya
        AND t201m.cd_kaisya = newcar.cd_kaisya
        AND t201m.cd_tenpo = newcar.cd_tenpo
;
