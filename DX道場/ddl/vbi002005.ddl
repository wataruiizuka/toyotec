CREATE TABLE gold.vbi002005 (
    `販社コード` STRING,
    `会社コード` STRING,
    `販社会社店舗コード` STRING,
    `登録済件数` STRING,
    `下取車なし総件数` STRING,
    `未回収総件数` STRING,
    `未回収総金額` STRING,
    `未回収現金総件数` STRING,
    `未回収現金総金額` STRING,
    `未回収割賦総総件数` STRING,
    `未回収割賦総総金額` STRING,
    `未回収下取総件数` STRING,
    `未回収下取総金額` STRING,
    `登録済未納車件数` STRING
) USING PARQUET
;
