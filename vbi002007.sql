DROP TABLE IF EXISTS gold.vbi002007;
CREATE TABLE gold.vbi002007 AS
WITH table_8014m AS (SELECT
    ROW_NUMBER() OVER(ORDER BY 1) AS logic_pk,
    tbg8014m.*
FROM ai21rep_ve_dx.tbg8014m
)
SELECT
    t014m.logic_pk AS 主キー
    , t014m.cd_hansya AS 販社コード
    , t014m.cd_kaisya AS 会社コード
    , t014m.no_cyumon AS 注文ＮＯ
    , CONCAT(t014m.cd_hansya, t014m.cd_kaisya, TRIM(t014m.no_cyumon)) AS 販社会社注文no
    , CAST(t014m.dd_keijyou AS STRING) AS 日付_順番用
    , TO_TIMESTAMP(CAST(t014m.dd_keijyou AS STRING), 'yyyyMMdd') AS 日付
    , COALESCE(t053m.kb_syohmei, t204m.kj_nasemei, t208m.kj_nyuukinm) AS 項目名
    , IF (t014m.kb_urinyuki = '1', t014m.ki_nyukinur, NULL) AS 発生額
    , IF (t014m.kb_urinyuki = '2', t014m.KI_NYUKINUR, NULL) AS 入金額
    , IF (t014m.kb_urinyuki = '1'
        CASE SUBSTR(t014m.kb_nyuukin, 3, 1)
            WHEN '1' THEN '取消'
            WHEN '2' THEN '売上'
            WHEN '3' THEN '条変'
        END,
    IF (t014m.kb_urinyuki = '2',
        CASE t014m.kb_nyukkanr
            WHEN '01' THEN '現金'
            WHEN '02' THEN '割賦'
            WHEN '03' THEN '下取'
            WHEN '04' THEN '約手'
            WHEN '05' THEN '残債'
        END,
        NULL
        )
        ) AS 空白欄,
    , t014m.no_denpyo AS 伝票番号
    , t014m.kb_gyoumu AS 業務区分
    , t014m.kb_nyuukin AS 入金区分
    , 1 AS 件数
FROM(
    SELECT
        t014m.logic_pk
        , LEFT(t014m.kb_nyuukin, 2) AS kb_nyuukin
        , MAX(t053m.dt_saisinup) AS dt_saisinup
    FROM
        table_8014m t014m
    LEFT JOIN ai21rep_ve_dx.tbbf053m t053m
        ON t014m.cd_hansya = t053m.cd_hansya
        AND t014m.cd_kaisya = t053m.cd_kaisya
        AND CAST(FROM_TIMESTAMP(t053m.dt_saisinup, 'yyyyMMdd') AS INT) <= t014m.dd_keijyou
    GROUP BY
        t014m.logic_pk,
        t014m.kb_nyuukin
  ) bt
LEFT JOIN table_8014m t014m
    ON t014m.logic_pk = bt.logic_pk
LEFT JOIN ai21rep_ve_dx.tbbf053m t053m
    ON t014m.kb_urinyuki = '1'
    AND t053m.dt_saisinup = bt.dt_saisinup
    AND CONCAT(t053m.kb_syohmei, t053m.kb_syohmsy) = CASE LEFT(t014m.kb_nyuukin, 2)
        WHEN '14' THEN '210'
        WHEN '15' THEN '220'
        WHEN '16' THEN '231'
        WHEN '17' THEN '232'
        WHEN '18' THEN '233'
        WHEN '20' THEN '520'
        WHEN '21' THEN '510'
        WHEN '22' THEN '610'
        WHEN '23' THEN '620'
        WHEN '24' THEN '631'
        WHEN '25' THEN '632'
        WHEN '26' THEN '633'
    END
LEFT JOIN ai21rep_ve_dx.tbgm024m t204m
    ON t014m.kb_urinyuki = '1'
    AND FIND_IN_SET(LEFT(t014m.kb_nyuukin, 2), '14,15,16,17,18,20,21,22,23,24,25,26') = 0
    AND t204m.cd_hansya = t014m.cd_hansya
    AND t204m.cd_kaisya = t014m.cd_kaisya
    AND t204m.kb_hassei = LEFT(t014m.kb_nyuukin, 2)
LEFT JOIN ai21rep_ve_dx.tbv0208m t208m
    ON t014m.kb_urinyuki = '2'
    AND t208m.cd_hansya = t014m.cd_hansya
    AND t208m.cd_kaisya = t014m.cd_kaisya
    AND t208m.kb_nyuukin = LEFT(t014m.kb_nyuukin, 2)
;
