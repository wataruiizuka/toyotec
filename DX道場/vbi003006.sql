DROP TABLE IF EXISTS gold.vbi003006;
CREATE TABLE gold.vbi003006 AS
SELECT
    cd_hansya AS `販社コード`
    , cd_kaisya AS `会社コード`
    , cd_tenpo AS `店舗コード`
    , no_yoyakuid AS `予約ＩＤ`
    , cd_yoykmsai AS `予約明細ＩＤ`
    , no_stall AS `ストール番号`
    , mj_gyme AS `ご用命`
    , kb_koutei AS `工程区分`
    , dt_nyuukoyt AS `入庫予定日時`
    , dt_shukkoyt AS `出庫予定日時`
    , tm_siyotime AS `使用所要時間`
    , kb_nyuuko AS `入庫区分`
    , cd_jisekist AS `実績ステータス`
    , mj_jisekist AS `実績ステータス名`
    , cd_restcros AS `休憩跨ぎ区分`
    , mj_sakujyo AS `ＳＭＢ削除フラグ`
    , cd_hansyakaisyatenpostalldate AS `販社会社店舗ストール番号日付`
    , dd_nyuukoyt AS `入庫予定日`
    , mj_yoyaku AS `予約`
    , tm_shukkin AS `出勤時間`
    , tm_taikin AS `退勤時間`
    , tm_zangyo AS `残業時間`
FROM
    dx_ve.vbi003006_en
;
