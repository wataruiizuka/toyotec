CREATE TABLE gold.vbi011006 (
    `販社コード` STRING,
    `会社コード` STRING,
    `お客様コード` STRING,
    `スタッフエリアコード` STRING,
    `スタッフエリア名` STRING,
    `スタッフ店舗名` STRING,
    `テーブル店舗名` STRING,
    `スタッフ名` STRING,
    `店舗スタッフ` STRING,
    `実施区分` STRING,
    `メンテパック名称` STRING,
    `項目利用整備名称` STRING,
    `契約区分` STRING,
    `税込金額` STRING,
    `新規連番` STRING,
    `実施予定年月日` STRING,
    `実施予定年月スライサー` STRING,
    `契約終了予定年月スライサー` STRING,
    `登録ＮＯ` STRING,
    `入庫区分漢字` STRING,
    `SMB予約入庫日時` STRING
) USING PARQUET
;
