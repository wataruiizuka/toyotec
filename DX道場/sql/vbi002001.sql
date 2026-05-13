DROP TABLE IF EXISTS gold.vbi002001;
CREATE TABLE gold.vbi002001 AS
SELECT
    su_store_number AS 店舗数
    , cd_hansya_kaisya_tenpo AS 販社会社店舗コード
    , cd_hansya_kaisya_zon_tenpo AS 販社会社ゾーン店舗コード
    , cd_hansya AS 販社コード
    , cd_kaisya AS 会社コード
    , cd_tenpo AS 店舗コード
    , kj_tenpomei AS 店舗名称
    , kj_tentanms AS 店舗短縮名称
    , cd_zon AS ゾーンコード
    , cd_nczon AS ンゾン
    , kj_zonmei AS ゾーン名称
    , zone_name_abbreviation AS ゾーン名略
    , sort_order AS ソート順
FROM
    dx_ve.vbi002001_en vbi002001
;
