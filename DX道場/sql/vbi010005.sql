DROP TABLE IF EXISTS gold.vbi010005;
CREATE TABLE gold.vbi010005 AS
SELECT
    t201m.cd_hansya AS 販社コード
    , t201m.cd_kaisya AS 会社コード
    , t201m.cd_tenpo AS 店舗コード
    , CONCAT(t201m.cd_hansya, t201m.cd_kaisya, t201m.cd_tenpo) AS 販社会社店舗
    , NVL(newcar_daitei.新車代替, 0) AS 新車代替
    , NVL(newcar_daitei.新車実績, 0) AS 新車実績
FROM
    ai21rep_ve_dx.tbv0201m t201m
LEFT JOIN
    ON (
    SELECT
        tbba001g.cd_hansya
        , tbba001g.cd_kaisya
        , tbba001g.cd_tenpo
        , SUM( IF(tbba056g.mj_jucyuke4 IN ('02','03'),calflg ,0)) AS 新車代替
        , SUM(calflg) AS 新車実績
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
                AND ( (ft168g.dd_torokei IS NULL
                    AND tbba001g.dd_uriagekj IS NOT NULL)
                    OR  (ft168g.dd_torokei IS NOT NULL)
        )
        UNION ALL
            SELECT
                tbba001g.cd_hansya
                , tbba001g.cd_kaisya
                , tbba001g.cd_tenpo
                , tbba001g.no_cyumon
                , tbba001g.no_cyumoned
                , tbba001g.mj_sinkysed
                , tbba001g.mj_gaihansy
                , tbba001g.mj_hantenkt
                , tbba001g.dd_uritrkkj AS dd_uritrkkj
                , -1 AS calflg
            FROM
                ai21rep_ve_dx.tbba001g tbba001g
            WHERE
                tbba001g.kb_haraidas NOT IN ('00', '40')
                    AND tbba001g.dd_jucyuke IS NOT NULL
                    AND tbba001g.dd_uritrkkj IS NOT NULL
        ) tbba001g
        LEFT JOIN ai21rep_ve_dx.tbba056g tbba056g
            ON tbba001g.cd_hansya = TBBA056G.cd_hansya
            AND tbba001g.cd_kaisya = TBBA056G.cd_kaisya
            AND tbba001g.no_cyumon = TBBA056G.no_cyumon
            AND TRIM(tbba001g.no_cyumoned) = TRIM(TBBA056G.no_cyumoned)
    GROUP BY
        tbba001g.cd_hansya,
        tbba001g.cd_kaisya,
        tbba001g.cd_tenpo
    ) newcar_daitei
    ON t201m.cd_hansya = newcar_daitei.cd_hansya
    AND t201m.cd_kaisya = newcar_daitei.cd_kaisya
    AND t201m.cd_tenpo = newcar_daitei.cd_tenpo
;
