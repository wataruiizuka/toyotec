CREATE TABLE gold.vbi000005 (
    `販社コード` STRING,
    `会社コード` STRING,
    `フォロー店舗コード` STRING,
    `入庫予定店舗` STRING,
    `整理ＮＯ` STRING,
    `フレーム型式` STRING,
    `リコール名称` STRING,
    `適用期間始期` STRING,
    `一時抹消` STRING
) USING PARQUET
;
