CREATE TABLE gold.vbi001003 (
    `販社コード` STRING,
    `会社コード` STRING,
    `店舗コード` STRING,
    `車名` STRING,
    `店舗名称` STRING,
    `店舗短縮名称` STRING,
    `ゾーンコード` STRING,
    `ゾーン名称` STRING,
    `新車受注実績` STRING,
    `新車受注取消` STRING,
    `新車受注合計` STRING,
    `新車受注残` STRING,
    `新車販売実績` STRING,
    `新車販売取消` STRING,
    `新車販売合計` STRING,
    `受注日付` STRING,
    `新車販売日付` STRING,
    `店舗ソート順` STRING
    `車名ソート順` STRING
) USING PARQUET
;
