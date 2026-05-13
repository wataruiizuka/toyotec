CREATE TABLE gold.vbi010004 (
    `販社コード` STRING,
    `会社コード` STRING,
    `店舗コード` STRING,
    `販社会社店舗` STRING,
    `TAD販売実績` STRING,
    `TAD下取数` STRING,
    `TAD入会数` STRING,
    `Ucar下取数` STRING,
    `UCar買取数` STRING,
    `UCar入会数` STRING,
    `UCar小売` STRING,
    `UCar卸` STRING
) USING PARQUET
;
