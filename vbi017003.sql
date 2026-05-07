DROP TABLE IF EXISTS gold.vbi017003;
CREATE TABLE gold.vbi017003 AS
SELECT
    t.cd_hansya AS '販社コード'
    , t.cd_kaisya AS '会社コード'
    , t.cd_tenpo AS '店舗コード'
    , t.kj_tenpomei AS '店舗名称'
    , t.cd_hanstaff AS '販売スタッフコード'
    , t.kj_syainmei AS '社員名'
    , t.month AS '月'
    , t.su_jucyu AS '受注'
    , t.su_jucyucancelhane AS '受注キャンセル反映'
    , t.su_jucyujyokei AS '受注除軽'
    , t.su_jucyucanceljyokeihane AS '受注除軽キャンセル反映'
    , t.su_hanbai AS '販売'
    , t.su_hanbaicancelhane AS '販売キャンセル反映'
    , t.su_hanbaijyokei AS '販売除軽'
    , t.su_hanbaicanceljyokeihene AS '販売除軽キャンセル反映'
    , t.su_kap AS '割賦'
    , t.su_maintenancepack AS 'メンテナンスパック'
    , t.su_sitadori AS '下取り'
    , rank() OVER (PARTITION BY t.cd_hansya,t.cd_kaisya ORDER BY tbi999003m.mj_sortjyun , t.cd_tenpo) AS 'ソート順'
FROM
(
    SELECT
        cd_hansya
        , cd_kaisya
        , cd_tenpo
        , kj_tenpomei
        , cd_hanstaff
        , kj_syainmei
        , month
        , SUM(su_jucyu) AS 'su_jucyu'
        , SUM(su_jucyucancelhane) AS 'su_jucyucancelhane'
        , SUM(su_jucyujyokei) AS 'su_jucyujyokei'
        , SUM(su_jucyucanceljyokeihane) AS 'su_jucyucanceljyokeihane'
        , SUM(su_hanbai) AS 'su_hanbai'
        , SUM(su_hanbaicancelhane) AS 'su_hanbaicancelhane'
        , SUM(su_hanbaijyokei) AS 'su_hanbaijyokei'
        , SUM(su_hanbaicanceljyokeihene) AS 'su_hanbaicanceljyokeihene'
        , SUM(su_kap) AS 'su_kap'
        , SUM(su_maintenancepack) AS 'su_maintenancepack'
        , SUM(su_sitadori) AS 'su_sitadori'
    FROM
    (
        SELECT
            cd_hansya
            , cd_kaisya
            , cd_tenpo
            , kj_tenpomei
            , cd_hanstaff
            , kj_syainmei
            , month
            , su_jucyu
            , su_jucyucancelhane
            , su_jucyujyokei
            , su_jucyucanceljyokeihane
            , 0 AS 'su_hanbai'
            , 0 AS 'su_hanbaicancelhane'
            , 0 AS 'su_hanbaijyokei'
            , 0 AS 'su_hanbaicanceljyokeihene'
            , su_kap
            , su_maintenancepack
            , su_sitadori
        FROM dx_ve.vbi017001
        UNION ALL
        SELECT
            cd_hansya
            , cd_kaisya
            , cd_tenpo
            , kj_tenpomei
            , cd_hanstaff
            , kj_syainmei
            , month
            , 0 AS 'su_jucyu'
            , 0 AS 'su_jucyucancelhane'
            , 0 AS 'su_jucyujyokei'
            , 0 AS 'su_jucyucanceljyokeihane'
            , su_hanbai
            , su_hanbaicancelhane
            , su_hanbaijyokei
            , su_hanbaicanceljyokeihene
            , 0 AS 'su_kap'
            , 0 AS 'su_maintenancepack'
            , 0 AS 'su_sitadori'
        FROM dx_ve.vbi017002
    )combined
    GROUP BY
        cd_hansya,
        cd_kaisya,
        cd_tenpo,
        kj_tenpomei,
        cd_hanstaff,
        kj_syainmei,
        month
)t
INNER JOIN dx_ve.tbi999003m
    ON tbi999003m.cd_kaisya = t.cd_kaisya
    AND tbi999003m.cd_hansya = t.cd_hansya
    AND tbi999003m.cd_tenpo = t.cd_tenpo
    AND tbi999003m.mj_cyohyoid = '017'
    AND tbi999003m.kb_tenji = 1
;
