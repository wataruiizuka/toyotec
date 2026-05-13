DROP TABLE IF EXISTS gold.vbi011006;
CREATE TABLE gold.vbi011006 AS
SELECT
        tz030m.cd_hansya AS '販社コード'
        , tz030m.cd_kaisya AS '会社コード'
        , tz030m.cd_okyaku AS 'お客様コード'
        , vbi011005.cd_zon AS 'スタッフエリアコード'
        , vbi011005.kj_zonmei AS 'スタッフエリア名'
        , vbi011005.kj_tenpomei AS 'スタッフ店舗名'
        , vbi011005.kj_tenpomei AS 'テーブル店舗名'
        , vbi011005.kj_syainmei AS 'スタッフ名'
        , CONCAT(vbi011005.cd_stafften, vbi011005.cd_staff) AS '店舗スタッフ'
        , tz031m.kb_jissi AS '実施区分'
        , vbi011001.kj_kanyusyu AS 'メンテパック名称'
        , vbi011001.kj_riyoseim AS '項目利用整備名称'
        , vbi011001.kb_keiyaku AS '契約区分'
        , vbi011001.totalcount AS '税込金額'
        , DENSE_RANK() OVER (
            PARTITION BY
            CONCAT(tz030m.cd_okyaku, tz030m.cd_norikusi, tz030m.kb_nosyasyu, tz030m.cd_nogyotai, tz030m.no_noseiri, vbi011001.kb_keiyaku, vbi011001.kj_kanyusyu)
            ORDER BY tz031m.dd_jisiyote ASC, vbi011001.no_renban ASC
        ) AS '新規連番'
        , tz031m.dd_jisiyote AS '実施予定年月日'
        , IF(tz031m.dd_jisiyote IS NULL, NULL
        , IF(tz031m.dd_jisiyote >= DATE_ADD(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), INTERVAL -3 MONTH)
            , CONCAT(FROM_TIMESTAMP(tz031m.dd_jisiyote, 'yy年MM月'), '分')
            , CONCAT(FROM_TIMESTAMP(DATE_ADD(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), INTERVAL -3 MONTH), 'yy年MM月'), '以前分')
            )
        ) AS '実施予定年月スライサー',
        IF(tz030m.dd_mntkanry IS NULL, NULL
        ,IF(
            FROM_TIMESTAMP(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'yyyyMM') > FROM_TIMESTAMP(tz030m.dd_mntkanry, 'yyyyMM')
            , CONCAT(FROM_TIMESTAMP(CAST(FROM_UTC_TIMESTAMP(UTC_TIMESTAMP(), 'JST') AS DATE), 'yy年MM月'), '以前分')
            , CONCAT(FROM_TIMESTAMP(tz030m.dd_mntkanry, 'yy年MM月'), '分')
            )
        ) AS '契約終了予定年月スライサー',
        CONCAT(
            tz030m.cd_hansya,
            tz030m.cd_kaisya,
            tz030m.cd_okyaku,
            tz030m.cd_norikusi,
            tz030m.kb_nosyasyu,
            tz030m.cd_nogyotai,
            tz030m.no_noseiri
            ) AS '登録ＮＯ',
        CASE
                WHEN INSTR(vbi011001.kj_riyoseim, '無') > 0 THEN '無点'
                  WHEN INSTR(vbi011001.kj_riyoseim, '１２') > 0 THEN '１２点'
                  WHEN INSTR(vbi011001.kj_riyoseim, '６') > 0 THEN '６点'
                  WHEN INSTR(vbi011001.kj_riyoseim, '車検') > 0 THEN '車検'
            ELSE NULL
        END AS '入庫区分漢字'
        , (IF(vbi011004.dt_nyuukoyt >= DATE_ADD(tz031m.dd_jisiyote, INTERVAL -2 MONTH)
                AND vbi011004.dt_nyuukoyt <= DATE_ADD(tz031m.dd_jisiyote, INTERVAL 1 MONTH)
                ,vbi011004.dt_nyuukoyt
                ,NULL)) AS 'SMB予約入庫日時'
    FROM ai21rep_ve_dx.tbaz030m tz030m
    LEFT JOIN dx_ve.vbi011001
        ON tz030m.cd_hansya = vbi011001.cd_hansya
        AND tz030m.cd_kaisya = vbi011001.cd_kaisya
        AND tz030m.kb_mntkeiya = TRIM(vbi011001.kb_keiyaku)
        AND tz030m.no_edaban = vbi011001.no_edaban
        AND CAST(tz030m.nu_sotezert AS INT) = vbi011001.nu_sotezert
    LEFT JOIN ai21rep_ve_dx.tbaz031m tz031m
        ON tz030m.cd_hansya = tz031m.cd_hansya
        AND tz030m.cd_kaisya = tz031m.cd_kaisya
        AND tz030m.cd_okyaku = tz031m.cd_okyaku
        AND tz030m.cd_norikusi = tz031m.cd_norikusi
        AND tz030m.kb_nosyasyu = tz031m.kb_nosyasyu
        AND tz030m.cd_nogyotai = tz031m.cd_nogyotai
        AND tz030m.no_noseiri = tz031m.no_noseiri
        AND vbi011001.no_renban = LPAD(CAST(tz031m.no_table AS STRING), 2, '0')
    LEFT JOIN ai21rep_ve_dx.tbfy232m ty232m
        ON tz030m.cd_hansya = ty232m.cd_hansya
        AND tz030m.cd_kaisya = ty232m.cd_kaisya
        AND ty232m.kb_syosnyuk = " "
        AND CASE
                WHEN INSTR(vbi011001.kj_riyoseim, '無') > 0 THEN '無点'
                  WHEN INSTR(vbi011001.kj_riyoseim, '１２') > 0 THEN '１２点'
                  WHEN INSTR(vbi011001.kj_riyoseim, '６') > 0 THEN '６点'
                  WHEN INSTR(vbi011001.kj_riyoseim, '車検') > 0 THEN '車検'
                ELSE NULL
            END = REPLACE(REPLACE(ty232m.kj_nyuukom, '　', ''), ' ', '')
    LEFT JOIN(
        SELECT
            cd_hansya
            , cd_kaisya
            , cd_okyaku
            , cd_norikusi
            , kb_nosyasyu
            , cd_nogyotai
            , no_noseiri
            , kb_nyuuko
            , max(dt_nyuukoyt) AS 'dt_nyuukoyt'
        FROM dx_ve.vbi011004
        GROUP BY
            cd_hansya,
            cd_kaisya,
            cd_okyaku,
            cd_norikusi,
            kb_nosyasyu,
            cd_nogyotai,
            no_noseiri,
            kb_nyuuko
    )vbi011004
        ON tz030m.cd_hansya = vbi011004.cd_hansya
        AND tz030m.cd_kaisya = vbi011004.cd_kaisya
        AND tz030m.cd_okyaku = vbi011004.cd_okyaku
        AND tz030m.cd_norikusi = vbi011004.cd_norikusi
        AND tz030m.kb_nosyasyu = vbi011004.kb_nosyasyu
        AND tz030m.cd_nogyotai = vbi011004.cd_nogyotai
        AND tz030m.no_noseiri = vbi011004.no_noseiri
        AND vbi011004.kb_nyuuko = ty232m.kb_nyuuko
INNER JOIN dx_ve.vbi011005
    ON tz030m.cd_hansya = vbi011005.cd_hansya
    AND tz030m.cd_kaisya = vbi011005.cd_kaisya
    AND tz030m.cd_okyaku = vbi011005.cd_okyaku
;
