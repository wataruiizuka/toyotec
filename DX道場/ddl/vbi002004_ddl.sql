CREATE TABLE gold.vbi002004 (
    `販社コード` STRING,
    `会社コード` STRING,
    `店舗コード` STRING,
    `販社会社店舗コード` STRING,
    `受注台数` STRING,
    `登録台数` STRING,
    `当月登録内下取車なし` STRING,
    `当月回収完了分平均リードタイム` STRING,
    `現在登録済未回収件数` STRING,
    `現在登録済未回収金額` STRING,
    `前月登録済未回収件数` STRING,
    `前月登録済未回収金額` STRING,
    `前月以前登録済未回収件数` STRING,
    `前月以前登録済未回収金額` STRING,
    `件数` STRING,
    `金額` STRING,
    `ソート順` STRING
) USING PARQUET
;
