CREATE TABLE gold.vbi019003 (
    `販社コード` STRING,
    `会社コード` STRING,
    `店舗コード` STRING,
    `店舗名称` STRING,
    `販売スタッフコード` STRING,
    `社員名` STRING,
    `月` STRING,
    `受注` STRING,
    `受注キャンセル反映` STRING,
    `受注除軽` STRING,
    `受注除軽キャンセル反映` STRING,
    `販売` STRING,
    `販売キャンセル反映` STRING,
    `販売除軽` STRING,
    `販売除軽キャンセル反映` STRING,
    `割賦` STRING,
    `メンテナンスパック` STRING,
    `ソート順` STRING
) USING PARQUET
;
