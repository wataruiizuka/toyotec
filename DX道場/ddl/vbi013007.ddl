CREATE TABLE gold.vbi013007 (
    `主キー` STRING,
    `販社コード` STRING,
    `会社コード` STRING,
    `注文ＮＯ` STRING,
    `販社会社注文NO` STRING,
    `日付_順番用` STRING,
    `日付` STRING,
    `項目名` STRING,
    `発生額` STRING,
    `入金額` STRING,
    `空白欄` STRING,
    `伝票番号` STRING,
    `業務区分` STRING,
    `入金区分` STRING,
    `件数` STRING
) USING PARQUET
;
